Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 3694E6B004A
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 01:28:15 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so6802467bkw.14
        for <linux-mm@kvack.org>; Mon, 19 Mar 2012 22:28:13 -0700 (PDT)
Message-ID: <4F681569.3080603@openvz.org>
Date: Tue, 20 Mar 2012 09:28:09 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH v3] radix-tree: introduce bit-optimized iterator
References: <20120210192542.5881.91143.stgit@zurg> <20120319051817.5031.91749.stgit@zurg> <20120319164201.8904963b.akpm@linux-foundation.org>
In-Reply-To: <20120319164201.8904963b.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Andrew Morton wrote:
> On Mon, 19 Mar 2012 09:19:08 +0400
> Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
>
>> This patch implements clean, simple and effective radix-tree iteration routine.
>>
>> Iterating divided into two phases:
>> * search for the next chunk of slots in radix-tree leaf node
>> * iterate through slots in this chunk
>>
>> Main iterator function radix_tree_next_chunk() returns pointer to first slot,
>> and stores in the struct radix_tree_iter index and next-to-last slot for chunk.
>> For tagged-iterating it also construct bit-mask of tags for slots in chunk.
>> All additional logic implemented as static-inline functions and macroses.
>>
>> Also patch adds radix_tree_find_next_bit() static-inline variant of
>> find_next_bit() optimized for small constant size arrays, because
>> find_next_bit() too heavy for searching in an array with one/two long elements.
>>
>> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
>>
>> ---
>> v3: No functional changes: renaming variables, updating comments, fixing style errors.
>
> Here's what you changed:
>
> --- a/include/linux/radix-tree.h~radix-tree-introduce-bit-optimized-iterator-v3
> +++ a/include/linux/radix-tree.h
> @@ -258,28 +258,76 @@ static inline void radix_tree_preload_en
>          preempt_enable();
>   }
>
> +/**
> + * struct radix_tree_iter - radix tree iterator state
> + *
> + * @index:     index of current slot
> + * @next_index:        next-to-last index for this chunk
> + * @tags:      bit-mask for tag-iterating
> + *
> + * Radix tree iterator works in terms of "chunks" of slots.
> + * Chunk is sub-interval of slots contained in one radix tree leaf node.
> + * It described by pointer to its first slot and struct radix_tree_iter
> + * which holds chunk position in tree and its size. For tagged iterating
> + * radix_tree_iter also holds slots' bit-mask for one chosen radix tree tag.
> + */
>   struct radix_tree_iter {
> -       unsigned long   index;          /* current index, do not overflow it */
> -       unsigned long   next_index;     /* next-to-last index for this chunk */
> -       unsigned long   tags;           /* bitmask for tag-iterating */
> +       unsigned long   index;
> +       unsigned long   next_index;
> +       unsigned long   tags;
>   };
>
>   #define RADIX_TREE_ITER_TAG_MASK       0x00FF  /* tag index in lower byte */
>   #define RADIX_TREE_ITER_TAGGED         0x0100  /* lookup tagged slots */
>   #define RADIX_TREE_ITER_CONTIG         0x0200  /* stop at first hole */
>
> -void **radix_tree_next_chunk(struct radix_tree_root *root,
> -                            struct radix_tree_iter *iter, unsigned flags);
> -
> -static inline
> -void **radix_tree_iter_init(struct radix_tree_iter *iter, unsigned long start)
> +/**
> + * radix_tree_iter_init - initialize radix tree iterator
> + *
> + * @iter:      pointer to iterator state
> + * @start:     iteration starting index
> + * Returns:    NULL
> + */
> +static __always_inline void **
> +radix_tree_iter_init(struct radix_tree_iter *iter, unsigned long start)
>   {
> -       iter->index = 0; /* to bypass next_index overflow protection */
> +       /*
> +        * Leave iter->tags unitialized. radix_tree_next_chunk()
> +        * anyway fill it in case successful tagged chunk lookup.
> +        * At unsuccessful or non-tagged lookup nobody cares about it.
> +        *
> +        * Set index to zero to bypass next_index overflow protection.
> +        * See comment inside radix_tree_next_chunk() for details.
> +        */
> +       iter->index = 0;
>          iter->next_index = start;
>          return NULL;
>   }
>
> -static inline unsigned long radix_tree_chunk_size(struct radix_tree_iter *iter)
> +/**
> + * radix_tree_next_chunk - find next chunk of slots for iteration
> + *
> + * @root:      radix tree root
> + * @iter:      iterator state
> + * @flags:     RADIX_TREE_ITER_* flags and tag index
> + * Returns:    pointer to chunk first slot, or NULL if there no more left
> + *
> + * This function lookup next chunk in the radix tree starting from
> + * @iter->next_index, it returns pointer to chunk first slot.
> + * Also it fills @iter with data about chunk: position in the tree (index),
> + * its end (next_index), and construct bit mask for tagged iterating (tags).
> + */
> +void **radix_tree_next_chunk(struct radix_tree_root *root,
> +                            struct radix_tree_iter *iter, unsigned flags);
> +
> +/**
> + * radix_tree_chunk_size - get current chunk size
> + *
> + * @iter:      pointer to radix tree iterator
> + * Returns:    current chunk size
> + */
> +static __always_inline unsigned
> +radix_tree_chunk_size(struct radix_tree_iter *iter)
>   {
>          return iter->next_index - iter->index;
>   }
> @@ -287,41 +335,40 @@ static inline unsigned long radix_tree_c
>   /**
>    * radix_tree_next_slot - find next slot in chunk
>    *
> - * @slot       pointer to slot
> - * @iter       iterator state
> - * @flags      RADIX_TREE_ITER_*
> - *
> - * Returns pointer to next slot, or NULL if no more left.
> - */
> -static __always_inline
> -void **radix_tree_next_slot(void **slot, struct radix_tree_iter *iter,
> -                           unsigned flags)
> + * @slot:      pointer to current slot
> + * @iter:      pointer to interator state
> + * @flags:     RADIX_TREE_ITER_*, should be constant
> + * Returns:    pointer to next slot, or NULL if there no more left
> + *
> + * This function updates @iter->index in case successful lookup.
> + * For tagged lookup it also eats @iter->tags.
> + */
> +static __always_inline void **
> +radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
>   {
> -       unsigned size, offset;
> -
> -       size = radix_tree_chunk_size(iter) - 1;
>          if (flags&  RADIX_TREE_ITER_TAGGED) {
>                  iter->tags>>= 1;
>                  if (likely(iter->tags&  1ul)) {
>                          iter->index++;
>                          return slot + 1;
>                  }
> -               if ((flags&  RADIX_TREE_ITER_CONTIG)&&  size)
> -                       return NULL;
> -               if (likely(iter->tags)) {
> -                       offset = __ffs(iter->tags);
> +               if (!(flags&  RADIX_TREE_ITER_CONTIG)&&  likely(iter->tags)) {
> +                       unsigned offset = __ffs(iter->tags);
> +
>                          iter->tags>>= offset;
>                          iter->index += offset + 1;
>                          return slot + offset + 1;
>                  }
>          } else {
> +               unsigned size = radix_tree_chunk_size(iter) - 1;
> +
>                  while (size--) {
>                          slot++;
>                          iter->index++;
>                          if (likely(*slot))
>                                  return slot;
>                          if (flags&  RADIX_TREE_ITER_CONTIG)
> -                               return NULL;
> +                               break;
>                  }
>          }
>          return NULL;
> @@ -330,70 +377,79 @@ void **radix_tree_next_slot(void **slot,
>   /**
>    * radix_tree_for_each_chunk - iterate over chunks
>    *
> - * @slot:      the void** for pointer to chunk first slot
> - * @root       the struct radix_tree_root pointer
> - * @iter       the struct radix_tree_iter pointer
> - * @start      starting index
> - * @flags      RADIX_TREE_ITER_* and tag index
> + * @slot:      the void** variable for pointer to chunk first slot
> + * @root:      the struct radix_tree_root pointer
> + * @iter:      the struct radix_tree_iter pointer
> + * @start:     iteration starting index
> + * @flags:     RADIX_TREE_ITER_* and tag index
>    *
> - * Locks can be released and reasquired between iterations.
> + * Locks can be released and reacquired between iterations.
>    */
>   #define radix_tree_for_each_chunk(slot, root, iter, start, flags)      \
> -       for ( slot = radix_tree_iter_init(iter, start) ;                \
> -             (slot = radix_tree_next_chunk(root, iter, flags)) ; )
> +       for (slot = radix_tree_iter_init(iter, start) ;                 \
> +             (slot = radix_tree_next_chunk(root, iter, flags)) ;)
>
>   /**
>    * radix_tree_for_each_chunk_slot - iterate over slots in one chunk
>    *
> - * @slot:      the void** for pointer to slot
> - * @iter       the struct radix_tree_iter pointer
> - * @flags      RADIX_TREE_ITER_*
> + * @slot:      the void** variable, at the beginning points to chunk first slot
> + * @iter:      the struct radix_tree_iter pointer
> + * @flags:     RADIX_TREE_ITER_*, should be constant
> + *
> + * This macro supposed to be nested inside radix_tree_for_each_chunk().
> + * @slot points to radix tree slot, @iter->index contains its index.
>    */
> -#define radix_tree_for_each_chunk_slot(slot, iter, flags)      \
> -       for ( ; slot ; slot = radix_tree_next_slot(slot, iter, flags) )
> +#define radix_tree_for_each_chunk_slot(slot, iter, flags)              \
> +       for (; slot ; slot = radix_tree_next_slot(slot, iter, flags))
>
>   /**
> - * radix_tree_for_each_slot - iterate over all slots
> + * radix_tree_for_each_slot - iterate over non-empty slots
>    *
> - * @slot:      the void** for pointer to slot
> - * @root       the struct radix_tree_root pointer
> - * @iter       the struct radix_tree_iter pointer
> - * @start      starting index
> + * @slot:      the void** variable for pointer to slot
> + * @root:      the struct radix_tree_root pointer
> + * @iter:      the struct radix_tree_iter pointer
> + * @start:     iteration starting index
> + *
> + * @slot points to radix tree slot, @iter->index contains its index.
>    */
> -#define radix_tree_for_each_slot(slot, root, iter, start)      \
> -       for ( slot = radix_tree_iter_init(iter, start) ;        \
> -             slot || (slot = radix_tree_next_chunk(root, iter, 0)) ; \
> -             slot = radix_tree_next_slot(slot, iter, 0) )
> +#define radix_tree_for_each_slot(slot, root, iter, start)              \
> +       for (slot = radix_tree_iter_init(iter, start) ;                 \
> +            slot || (slot = radix_tree_next_chunk(root, iter, 0)) ;    \
> +            slot = radix_tree_next_slot(slot, iter, 0))
>
>   /**
> - * radix_tree_for_each_contig - iterate over all contiguous slots
> + * radix_tree_for_each_contig - iterate over contiguous slots
> + *
> + * @slot:      the void** variable for pointer to slot
> + * @root:      the struct radix_tree_root pointer
> + * @iter:      the struct radix_tree_iter pointer
> + * @start:     iteration starting index
>    *
> - * @slot:      the void** for pointer to slot
> - * @root       the struct radix_tree_root pointer
> - * @iter       the struct radix_tree_iter pointer
> - * @start      starting index
> + * @slot points to radix tree slot, @iter->index contains its index.
>    */
>   #define radix_tree_for_each_contig(slot, root, iter, start)            \
> -       for ( slot = radix_tree_iter_init(iter, start) ;                \
> -             slot || (slot = radix_tree_next_chunk(root, iter,         \
> +       for (slot = radix_tree_iter_init(iter, start) ;                 \
> +            slot || (slot = radix_tree_next_chunk(root, iter,          \
>                                  RADIX_TREE_ITER_CONTIG)) ;              \
> -             slot = radix_tree_next_slot(slot, iter,                   \
> -                               RADIX_TREE_ITER_CONTIG) )
> +            slot = radix_tree_next_slot(slot, iter,                    \
> +                               RADIX_TREE_ITER_CONTIG))
>
>   /**
> - * radix_tree_for_each_tagged - iterate over all tagged slots
> + * radix_tree_for_each_tagged - iterate over tagged slots
> + *
> + * @slot:      the void** variable for pointer to slot
> + * @root:      the struct radix_tree_root pointer
> + * @iter:      the struct radix_tree_iter pointer
> + * @start:     iteration starting index
> + * @tag:       tag index
>    *
> - * @slot:      the void** for pointer to slot
> - * @root       the struct radix_tree_root pointer
> - * @iter       the struct radix_tree_iter pointer
> - * @start      starting index
> - * @tag                tag index
> + * @slot points to radix tree slot, @iter->index contains its index.
>    */
>   #define radix_tree_for_each_tagged(slot, root, iter, start, tag)       \
> -       for ( slot = radix_tree_iter_init(iter, start) ;                \
> -             slot || (slot = radix_tree_next_chunk(root, iter,         \
> +       for (slot = radix_tree_iter_init(iter, start) ;                 \
> +            slot || (slot = radix_tree_next_chunk(root, iter,          \
>                                RADIX_TREE_ITER_TAGGED | tag)) ;          \
> -             slot = radix_tree_next_slot(slot, iter,                   \
> -                               RADIX_TREE_ITER_TAGGED) )
> +            slot = radix_tree_next_slot(slot, iter,                    \
> +                               RADIX_TREE_ITER_TAGGED))
>
>   #endif /* _LINUX_RADIX_TREE_H */
> diff -puN lib/radix-tree.c~radix-tree-introduce-bit-optimized-iterator-v3 lib/radix-tree.c
> --- a/lib/radix-tree.c~radix-tree-introduce-bit-optimized-iterator-v3
> +++ a/lib/radix-tree.c
> @@ -150,6 +150,7 @@ static inline int any_tag_set(struct rad
>
>   /**
>    * radix_tree_find_next_bit - find the next set bit in a memory region
> + *
>    * @addr: The address to base the search on
>    * @size: The bitmap size in bits
>    * @offset: The bitnumber to start searching at
> @@ -158,8 +159,9 @@ static inline int any_tag_set(struct rad
>    * Tail bits starting from size to roundup(size, BITS_PER_LONG) must be zero.
>    * Returns next bit offset, or size if nothing found.
>    */
> -static inline unsigned long radix_tree_find_next_bit(const unsigned long *addr,
> -               unsigned long size, unsigned long offset)
> +static __always_inline unsigned long
> +radix_tree_find_next_bit(const unsigned long *addr,
> +                        unsigned long size, unsigned long offset)
>   {
>          if (!__builtin_constant_p(size))
>                  return find_next_bit(addr, size, offset);
> @@ -651,27 +653,26 @@ EXPORT_SYMBOL(radix_tree_tag_get);
>   /**
>    * radix_tree_next_chunk - find next chunk of slots for iteration
>    *
> - * @root:              radix tree root
> - * @iter:              iterator state
> - * @flags              RADIX_TREE_ITER_* flags and tag index
> - *
> - * Returns pointer to first slots in chunk, or NULL if there no more left
> + * @root:      radix tree root
> + * @iter:      iterator state
> + * @flags:     RADIX_TREE_ITER_* flags and tag index
> + * Returns:    pointer to chunk first slot, or NULL if iteration is over
>    */
>   void **radix_tree_next_chunk(struct radix_tree_root *root,
>                               struct radix_tree_iter *iter, unsigned flags)
>   {
>          unsigned shift, tag = flags&  RADIX_TREE_ITER_TAG_MASK;
>          struct radix_tree_node *rnode, *node;
> -       unsigned long i, index;
> +       unsigned long index, offset;
>
>          if ((flags&  RADIX_TREE_ITER_TAGGED)&&  !root_tag_get(root, tag))
>                  return NULL;
>
>          /*
> -        * Catch next_index overflow after ~0UL.
> -        * iter->index can be zero only at the beginning.
> -        * Because RADIX_TREE_MAP_SHIFT<  BITS_PER_LONG we cannot
> -        * oveflow iter->next_index in single step.
> +        * Catch next_index overflow after ~0UL. iter->index never overflows
> +        * during iterating, it can be zero only at the beginning.
> +        * And we cannot overflow iter->next_index in single step,
> +        * because RADIX_TREE_MAP_SHIFT<  BITS_PER_LONG.
>           */
>          index = iter->next_index;
>          if (!index&&  iter->index)
> @@ -691,34 +692,37 @@ void **radix_tree_next_chunk(struct radi
>
>   restart:
>          shift = (rnode->height - 1) * RADIX_TREE_MAP_SHIFT;
> -       i = index>>  shift;
> +       offset = index>>  shift;
>
> -       /* Index ouside of the tree */
> -       if (i>= RADIX_TREE_MAP_SIZE)
> +       /* Index outside of the tree */
> +       if (offset>= RADIX_TREE_MAP_SIZE)
>                  return NULL;
>
>          node = rnode;
>          while (1) {
>                  if ((flags&  RADIX_TREE_ITER_TAGGED) ?
> -                               !test_bit(i, node->tags[tag]) :
> -                               !node->slots[i]) {
> +                               !test_bit(offset, node->tags[tag]) :
> +                               !node->slots[offset]) {
>                          /* Hole detected */
>                          if (flags&  RADIX_TREE_ITER_CONTIG)
>                                  return NULL;
>
>                          if (flags&  RADIX_TREE_ITER_TAGGED)
> -                               i = radix_tree_find_next_bit(node->tags[tag],
> -                                               RADIX_TREE_MAP_SIZE, i + 1);
> +                               offset = radix_tree_find_next_bit(
> +                                               node->tags[tag],
> +                                               RADIX_TREE_MAP_SIZE,
> +                                               offset + 1);
>                          else
> -                               while (++i<  RADIX_TREE_MAP_SIZE&&
> -                                               !node->slots[i]);
> -
> +                               while (++offset<  RADIX_TREE_MAP_SIZE) {
> +                                       if (node->slots[offset])
> +                                               break;
> +                               }
>                          index&= ~((RADIX_TREE_MAP_SIZE<<  shift) - 1);
> -                       index += i<<  shift;
> +                       index += offset<<  shift;
>                          /* Overflow after ~0UL */
>                          if (!index)
>                                  return NULL;
> -                       if (i == RADIX_TREE_MAP_SIZE)
> +                       if (offset == RADIX_TREE_MAP_SIZE)
>                                  goto restart;
>                  }
>
> @@ -726,23 +730,23 @@ restart:
>                  if (!shift)
>                          break;
>
> -               node = rcu_dereference_raw(node->slots[i]);
> +               node = rcu_dereference_raw(node->slots[offset]);
>                  if (node == NULL)
>                          goto restart;
>                  shift -= RADIX_TREE_MAP_SHIFT;
> -               i = (index>>  shift)&  RADIX_TREE_MAP_MASK;
> +               offset = (index>>  shift)&  RADIX_TREE_MAP_MASK;
>          }
>
>          /* Update the iterator state */
>          iter->index = index;
>          iter->next_index = (index | RADIX_TREE_MAP_MASK) + 1;
>
> -       /* Construct iter->tags bitmask from node->tags[tag] array */
> +       /* Construct iter->tags bit-mask from node->tags[tag] array */
>          if (flags&  RADIX_TREE_ITER_TAGGED) {
>                  unsigned tag_long, tag_bit;
>
> -               tag_long = i / BITS_PER_LONG;
> -               tag_bit  = i % BITS_PER_LONG;
> +               tag_long = offset / BITS_PER_LONG;
> +               tag_bit  = offset % BITS_PER_LONG;
>                  iter->tags = node->tags[tag][tag_long]>>  tag_bit;
>                  /* This never happens if RADIX_TREE_TAG_LONGS == 1 */
>                  if (tag_long<  RADIX_TREE_TAG_LONGS - 1) {
> @@ -755,7 +759,7 @@ restart:
>                  }
>          }
>
> -       return node->slots + i;
> +       return node->slots + offset;
>   }
>   EXPORT_SYMBOL(radix_tree_next_chunk);
>
> _
>
>
>
> And here are some changes I made to that:
>
> --- a/include/linux/radix-tree.h~radix-tree-introduce-bit-optimized-iterator-v3-fix
> +++ a/include/linux/radix-tree.h
> @@ -265,11 +265,12 @@ static inline void radix_tree_preload_en
>    * @next_index:        next-to-last index for this chunk
>    * @tags:      bit-mask for tag-iterating
>    *
> - * Radix tree iterator works in terms of "chunks" of slots.
> - * Chunk is sub-interval of slots contained in one radix tree leaf node.
> - * It described by pointer to its first slot and struct radix_tree_iter
> - * which holds chunk position in tree and its size. For tagged iterating
> - * radix_tree_iter also holds slots' bit-mask for one chosen radix tree tag.
> + * This radix tree iterator works in terms of "chunks" of slots.  A chunk is a
> + * subinterval of slots contained within one radix tree leaf node.  It is
> + * described by a pointer to its first slot and a struct radix_tree_iter
> + * which holds the chunk's position in the tree and its size.  For tagged
> + * iteration radix_tree_iter also holds the slots' bit-mask for one chosen
> + * radix tree tag.
>    */
>   struct radix_tree_iter {
>          unsigned long   index;
> @@ -292,12 +293,12 @@ static __always_inline void **
>   radix_tree_iter_init(struct radix_tree_iter *iter, unsigned long start)
>   {
>          /*
> -        * Leave iter->tags unitialized. radix_tree_next_chunk()
> -        * anyway fill it in case successful tagged chunk lookup.
> -        * At unsuccessful or non-tagged lookup nobody cares about it.
> +        * Leave iter->tags uninitialized. radix_tree_next_chunk() will fill it
> +        * in the case of a successful tagged chunk lookup.  If the lookup was
> +        * unsuccessful or non-tagged then nobody cares about ->tags.
>           *
>           * Set index to zero to bypass next_index overflow protection.
> -        * See comment inside radix_tree_next_chunk() for details.
> +        * See the comment in radix_tree_next_chunk() for details.
>           */
>          iter->index = 0;
>          iter->next_index = start;
> @@ -312,10 +313,10 @@ radix_tree_iter_init(struct radix_tree_i
>    * @flags:     RADIX_TREE_ITER_* flags and tag index
>    * Returns:    pointer to chunk first slot, or NULL if there no more left
>    *
> - * This function lookup next chunk in the radix tree starting from
> - * @iter->next_index, it returns pointer to chunk first slot.
> + * This function looks up the next chunk in the radix tree starting from
> + * @iter->next_index.  It returns a pointer to the chunk's first slot.
>    * Also it fills @iter with data about chunk: position in the tree (index),
> - * its end (next_index), and construct bit mask for tagged iterating (tags).
> + * its end (next_index), and constructs a bit mask for tagged iterating (tags).
>    */
>   void **radix_tree_next_chunk(struct radix_tree_root *root,
>                               struct radix_tree_iter *iter, unsigned flags);
> @@ -340,7 +341,7 @@ radix_tree_chunk_size(struct radix_tree_
>    * @flags:     RADIX_TREE_ITER_*, should be constant
>    * Returns:    pointer to next slot, or NULL if there no more left
>    *
> - * This function updates @iter->index in case successful lookup.
> + * This function updates @iter->index in the case of a successful lookup.
>    * For tagged lookup it also eats @iter->tags.
>    */
>   static __always_inline void **
> @@ -396,8 +397,8 @@ radix_tree_next_slot(void **slot, struct
>    * @iter:      the struct radix_tree_iter pointer
>    * @flags:     RADIX_TREE_ITER_*, should be constant
>    *
> - * This macro supposed to be nested inside radix_tree_for_each_chunk().
> - * @slot points to radix tree slot, @iter->index contains its index.
> + * This macro is designed to be nested inside radix_tree_for_each_chunk().
> + * @slot points to the radix tree slot, @iter->index contains its index.
>    */
>   #define radix_tree_for_each_chunk_slot(slot, iter, flags)              \
>          for (; slot ; slot = radix_tree_next_slot(slot, iter, flags))
> diff -puN lib/radix-tree.c~radix-tree-introduce-bit-optimized-iterator-v3-fix lib/radix-tree.c
> --- a/lib/radix-tree.c~radix-tree-introduce-bit-optimized-iterator-v3-fix
> +++ a/lib/radix-tree.c
> @@ -670,8 +670,8 @@ void **radix_tree_next_chunk(struct radi
>
>          /*
>           * Catch next_index overflow after ~0UL. iter->index never overflows
> -        * during iterating, it can be zero only at the beginning.
> -        * And we cannot overflow iter->next_index in single step,
> +        * during iterating; it can be zero only at the beginning.
> +        * And we cannot overflow iter->next_index in a single step,
>           * because RADIX_TREE_MAP_SHIFT<  BITS_PER_LONG.
>           */
>          index = iter->next_index;
> _
>
>

Yes, I screwed up with the spelling, again =(
Please merge your changes into final patch =)

>
> The comment over radix_tree_next_slot() is a bit terse: "eats
> @iter->tags".  Can you please explain what's going on with iter->tags?
> afacit it gets copied from the radix-tree node's relevant tag field and
> then gets right-shifted as we advance across the radix-tree node, so
> that bit 0 of iter->tags always reflects the state of the tag bit for
> the slot which we're currently processing?

Yes, radix_tree_next_slot() search next tag with __ffs() and shift bits to right.
So bit 0 represent tag for current slot.

Also these is fast-path for testing tag for slot next after current,
because this is much likely case and this test works much faster than __ffs().

Usually bit 0 is set, except case if rcu-protected radix_tree_next_chink() is raced
with it's clearing, so this function saw this bit once in lookup loop. But when it comes
to iter->tags constructing this bit already cleared, but we expose this slot into iteration anyway.
iter->tags is for internal use, so this is ok, but maybe we should document this corner case.

>
> Why was it done this way, rather than simply testing the appropriate
> bit within the radix-tree node's tag?  That would do away with
> iter->tags altogether?
>

Because nested loop (which uses radix_tree_next_slot()) is inlined into outer code,
so here no pointers to radix_tree_node and even its type declaration.

Also this approach makes inlined code smaller and faster, because we prepare data for processing.
On 32-bit systems iterating is little bit twisted, because not all tags fits
into single unsigned long iter->tags field, but it still faster than old implementation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
