#!r6rs
(library (pfds sequences)
(export make-sequence
        sequence?
        sequence-empty?
        sequence-size
        sequence-cons
        sequence-uncons
        sequence-snoc
        sequence-unsnoc
        sequence-append
        list->sequence
        sequence->list
        (rename (%sequence sequence))
        sequence-split-at
        sequence-take
        sequence-drop
        sequence-ref
        sequence-fold
        sequence-fold-right
        sequence-reverse
        sequence-empty-condition?
        )

(import (rnrs)
        (pfds fingertrees))

;; Note: as sequences are not a subtype of fingertrees, but rather a
;; particular instantiation of them, &sequence-empty is not a subtype
;; of &fingertree-empty
(define-condition-type &sequence-empty
  &assertion
  make-sequence-empty-condition
  sequence-empty-condition?)

(define-record-type (sequence %make-sequence sequence?)
  (fields fingertree))

(define (make-sequence)
 (%make-sequence (make-fingertree 0 + (lambda (x) 1))))

(define (sequence-empty? seq)
  (fingertree-empty? (sequence-fingertree seq)))

(define (sequence-size seq)
  (fingertree-measure (sequence-fingertree seq)))

(define (sequence-cons value seq)
  (%make-sequence
   (fingertree-cons value (sequence-fingertree seq))))

(define (sequence-snoc seq value)
  (%make-sequence
   (fingertree-snoc (sequence-fingertree seq) value)))

(define (sequence-uncons seq)
  (call-with-values
      (lambda ()
        (define ft (sequence-fingertree seq))
        (when (fingertree-empty? ft)
          (raise
           (condition
            (make-sequence-empty-condition)
            (make-who-condition 'sequence-uncons)
            (make-message-condition "There are no elements to uncons")
            (make-irritants-condition (list seq)))))
        (fingertree-uncons ft))
    (lambda (head tree)
      (values head (%make-sequence tree)))))

(define (sequence-unsnoc seq)
  (call-with-values
      (lambda ()
        (define ft (sequence-fingertree seq))
        (when (fingertree-empty? ft)
          (raise
           (condition
            (make-sequence-empty-condition)
            (make-who-condition 'sequence-unsnoc)
            (make-message-condition "There are no elements to unsnoc")
            (make-irritants-condition (list seq)))))
        (fingertree-unsnoc ft))
    (lambda (head tree)
      (values head (%make-sequence tree)))))

(define (sequence-append seq1 seq2)
  (%make-sequence
   (fingertree-append (sequence-fingertree seq1)
                      (sequence-fingertree seq2))))

(define (list->sequence list)
  (fold-left sequence-snoc
             (make-sequence)
             list))

(define (sequence->list seq)
  (fingertree->list (sequence-fingertree seq)))

(define (%sequence . args)
  (list->sequence args))

(define (sequence-split-at seq i)
  (let-values (((l r)
                (fingertree-split (lambda (x) (< i x))
                                  (sequence-fingertree seq))))
    (values (%make-sequence l)
            (%make-sequence r))))

(define (sequence-take seq i)
  (let-values (((head tail)
                (sequence-split-at seq i)))
    head))

(define (sequence-drop seq i)
  (let-values (((head tail)
                (sequence-split-at seq i)))
    tail))

(define (sequence-ref seq i)
  (define size (sequence-size seq))
  (unless (<= 0 i size)
    (assertion-violation 'sequence-ref "Index out of range" i))
  (let-values (((_l x _r)
                (fingertree-split3 (lambda (x) (< i x))
                                   (sequence-fingertree seq))))
    x))

(define (sequence-fold proc base seq)
  (fingertree-fold proc base (sequence-fingertree seq)))

(define (sequence-fold-right proc base seq)
  (fingertree-fold-right proc base (sequence-fingertree seq)))

(define (sequence-reverse seq)
  (%make-sequence (fingertree-reverse (sequence-fingertree seq))))

)
