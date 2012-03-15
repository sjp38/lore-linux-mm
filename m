Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id F33D46B0044
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 01:51:09 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so2562749bkw.14
        for <linux-mm@kvack.org>; Wed, 14 Mar 2012 22:51:07 -0700 (PDT)
Message-ID: <4F618347.8080400@openvz.org>
Date: Thu, 15 Mar 2012 09:51:03 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/3] radix-tree: introduce bit-optimized iterator
References: <20120210191611.5881.12646.stgit@zurg> <20120210192542.5881.91143.stgit@zurg> <20120314174356.40c35a07.akpm@linux-foundation.org>
In-Reply-To: <20120314174356.40c35a07.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Andrew Morton wrote:
> On Fri, 10 Feb 2012 23:25:42 +0400
> Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
>
>> This patch implements clean, simple and effective radix-tree iteration routine.
>>
>> Iterating divided into two phases:
>> * lookup next chunk in radix-tree leaf node
>> * iterating through slots in this chunk
>>
>> Main iterator function radix_tree_next_chunk() returns pointer to first slot,
>> and stores in the struct radix_tree_iter index of next-to-last slot.
>> For tagged-iterating it also constuct bitmask of tags for retunted chunk.
>> All additional logic implemented as static-inline functions and macroses.
>>
>> Also patch adds radix_tree_find_next_bit() static-inline variant of
>> find_next_bit() optimized for small constant size arrays, because
>> find_next_bit() too heavy for searching in an array with one/two long elements.
>>
>> ...
>>
>> +
>> +static inline
>> +void **radix_tree_iter_init(struct radix_tree_iter *iter, unsigned long start)
>
> Nit: if we're going to line break a function definition/declaration
> line like this then the usual way is to split it before the function
> name, so
>
> static inline void **
> radix_tree_iter_init(struct radix_tree_iter *iter, unsigned long start)
>
> Old-school people did this so they could find the function with
> /^radix_tree_iter_init in vi ;)

Thanks for watching! I'll try to fix all style problems.

>
>> +{
>> +     iter->index = 0; /* to bypass next_index overflow protection */
>> +     iter->next_index = start;
>> +     return NULL;
>> +}
>
> Why didn't it initialize .tags?
>
> In fact .tags only ever gets initialized deep inside
> radix_tree_next_chunk(), if !radix_tree_is_indirect_ptr().  Is this
> correct?

Yes, it correct.
.tags can be used only after success radix_tree_next_chunk() calling with RADIX_TREE_ITER_TAGGED
It initialized in two places: one for trivial single-entry tree and one at the end for normal chunk.

>
>>
>> ...
>>
>> +/**
>> + * radix_tree_next_slot - find next slot in chunk
>> + *
>> + * @slot     pointer to slot
>> + * @iter     iterator state
>> + * @flags    RADIX_TREE_ITER_*
>> + *
>> + * Returns pointer to next slot, or NULL if no more left.
>> + */
>> +static __always_inline
>> +void **radix_tree_next_slot(void **slot, struct radix_tree_iter *iter,
>> +                         unsigned flags)
>> +{
>> +     unsigned size, offset;
>
> 'offset' could be made local to the single code block which uses it.
> personally I find that this leads to clearer code.
>
>> +     size = radix_tree_chunk_size(iter) - 1;
>
> radix_tree_chunk_size() returns unsigned long, and we just threw away
> the upper 32 bits.  I'm unsure if that's a bug, but it's messy and
> possibly inefficient.

Would it be better to convert all to unsigned long?
As I remember, I was played there a lot trying to shrink code size for x86_64.
This function is really hot, so it should be carefully optimized.

>
>> +     if (flags&  RADIX_TREE_ITER_TAGGED) {
>> +             iter->tags>>= 1;
>> +             if (likely(iter->tags&  1ul)) {
>> +                     iter->index++;
>> +                     return slot + 1;
>> +             }
>> +             if ((flags&  RADIX_TREE_ITER_CONTIG)&&  size)
>> +                     return NULL;
>> +             if (likely(iter->tags)) {
>> +                     offset = __ffs(iter->tags);
>> +                     iter->tags>>= offset;
>> +                     iter->index += offset + 1;
>> +                     return slot + offset + 1;
>> +             }
>> +     } else {
>> +             while (size--) {
>> +                     slot++;
>> +                     iter->index++;
>> +                     if (likely(*slot))
>> +                             return slot;
>> +                     if (flags&  RADIX_TREE_ITER_CONTIG)
>> +                             return NULL;
>> +             }
>> +     }
>> +     return NULL;
>> +}
>
> This is a whopping big function.  Why was it inlined?  Are you sure
> that was a correct decision?

Ok, I'll split it in two: for cases with/without RADIX_TREE_ITER_TAGGED,
and split radix_tree_for_each_chunk_slot() macro in two: tagged and non-tagged.

>
>> +/**
>> + * radix_tree_for_each_chunk - iterate over chunks
>> + *
>> + * @slot:    the void** for pointer to chunk first slot
>> + * @root     the struct radix_tree_root pointer
>> + * @iter     the struct radix_tree_iter pointer
>> + * @start    starting index
>> + * @flags    RADIX_TREE_ITER_* and tag index
>
> Some of the arguments have a colon, others don't.
>
>> + * Locks can be released and reasquired between iterations.
>
> "reacquired"
>
>> + */
>> +#define radix_tree_for_each_chunk(slot, root, iter, start, flags)    \
>> +     for ( slot = radix_tree_iter_init(iter, start) ;                \
>> +           (slot = radix_tree_next_chunk(root, iter, flags)) ; )
>
> I don't think I understand this whole interface :(
>
> The term "chunk" has not been defined anywhere in the code, which
> doesn't help.

Ok, description must be fixed.

"chunk" is array of slot-pointers from radix tree leaf node.
radix_tree_for_each_chunk() iterates through radix-tree with with long steps.

Iterator body can work with chunk as with array: slot[0..radix_tree_chunk_size(iter)-1]
or iterate through it with help radix_tree_for_each_chunk_slot()

>
> Neither radix_tree_for_each_chunk() nor
> radix_tree_for_each_chunk_slot() get used anywhere in this patchset so
> one can't go look at call sites to work out what they're for.

It was used it in "[PATCH 3/4] shmem: use radix-tree iterator in shmem_unuse_inode()" from
"[PATCH 0/4] shmem: radix-tree cleanups and swapoff optimizations"

>
> It's a strange iterator - it never terminates.  It requires that the
> caller have an open-coded `break' in the search loop.

It terminates if radix_tree_next_chunk() returns NULL.

>
> A bit more description and perhaps a usage example would help.
>
>> +/**
>> + * radix_tree_for_each_chunk_slot - iterate over slots in one chunk
>> + *
>> + * @slot:    the void** for pointer to slot
>> + * @iter     the struct radix_tree_iter pointer
>> + * @flags    RADIX_TREE_ITER_*
>> + */
>> +#define radix_tree_for_each_chunk_slot(slot, iter, flags)    \
>> +     for ( ; slot ; slot = radix_tree_next_slot(slot, iter, flags) )
>
> Similar observations here.
>
>> +/**
>> + * radix_tree_for_each_slot - iterate over all slots
>> + *
>> + * @slot:    the void** for pointer to slot
>> + * @root     the struct radix_tree_root pointer
>> + * @iter     the struct radix_tree_iter pointer
>> + * @start    starting index
>> + */
>> +#define radix_tree_for_each_slot(slot, root, iter, start)    \
>> +     for ( slot = radix_tree_iter_init(iter, start) ;        \
>> +           slot || (slot = radix_tree_next_chunk(root, iter, 0)) ; \
>> +           slot = radix_tree_next_slot(slot, iter, 0) )
>
> All of these macros reference some of their arguments more than once.
> So wierd and wrong things will happen if they are invoked with an
> expression-with-side-effects.  Also they lack parenthesisation, so
>
>          radix_tree_for_each_slot(myslot + 1, ...)

slot must be lvalue, like "pos" in list_for_each_entry()

Description not explains arguments' roles...

>
> won't compile.  The first problem is more serious than the second.
>
> This is always a pain with complex macros and fixing it here would
> deeply uglify the code.  It's unlikely that anyone will be invoking
> these with expression-with-side-effects so I'd be inclined to just live
> with the dangers.
>
> otoh, someone *might* do
>
>          radix_tree_for_each_slot(slot,
>                                   expensive_function_which_returns_a_root(),
>                                   iter, start);
>
> and we'd call expensive_function_which_returns_a_root() each time
> around the loop.  But I don't think this is fixable.
>
> Anyway, have a think about it all.

list_for_each_entry() do the same for "head" argument, I think this is ok.

>
>> +/**
>> + * radix_tree_for_each_contig - iterate over all contiguous slots
>
> Now what does this mean?  Given a slot, iterate over that slot and all
> contiguous successor slots until we encounter a hole?

It start from "start" index and iterate till first empty slot.

>
> Maybe.  Again, better interface descriptions are needed, please.
>
>> + * @slot:    the void** for pointer to slot
>> + * @root     the struct radix_tree_root pointer
>> + * @iter     the struct radix_tree_iter pointer
>> + * @start    starting index
>> + */
>> +#define radix_tree_for_each_contig(slot, root, iter, start)          \
>> +     for ( slot = radix_tree_iter_init(iter, start) ;                \
>> +           slot || (slot = radix_tree_next_chunk(root, iter,         \
>> +                             RADIX_TREE_ITER_CONTIG)) ;              \
>> +           slot = radix_tree_next_slot(slot, iter,                   \
>> +                             RADIX_TREE_ITER_CONTIG) )
>> +
>> +/**
>> + * radix_tree_for_each_tagged - iterate over all tagged slots
>> + *
>> + * @slot:    the void** for pointer to slot
>> + * @root     the struct radix_tree_root pointer
>> + * @iter     the struct radix_tree_iter pointer
>> + * @start    starting index
>> + * @tag              tag index
>> + */
>> +#define radix_tree_for_each_tagged(slot, root, iter, start, tag)     \
>> +     for ( slot = radix_tree_iter_init(iter, start) ;                \
>> +           slot || (slot = radix_tree_next_chunk(root, iter,         \
>> +                           RADIX_TREE_ITER_TAGGED | tag)) ;          \
>> +           slot = radix_tree_next_slot(slot, iter,                   \
>> +                             RADIX_TREE_ITER_TAGGED) )
>> +
>>   #endif /* _LINUX_RADIX_TREE_H */
>>
>> ...
>>
>> +static inline unsigned long radix_tree_find_next_bit(const unsigned long *addr,
>> +             unsigned long size, unsigned long offset)
>> +{
>> +     if (!__builtin_constant_p(size))
>> +             return find_next_bit(addr, size, offset);
>> +
>> +     if (offset<  size) {
>> +             unsigned long tmp;
>> +
>> +             addr += offset / BITS_PER_LONG;
>> +             tmp = *addr>>  (offset % BITS_PER_LONG);
>> +             if (tmp)
>> +                     return __ffs(tmp) + offset;
>> +             offset = (offset + BITS_PER_LONG)&  ~(BITS_PER_LONG - 1);
>> +             while (offset<  size) {
>> +                     tmp = *++addr;
>> +                     if (tmp)
>> +                             return __ffs(tmp) + offset;
>> +                     offset += BITS_PER_LONG;
>> +             }
>> +     }
>> +     return size;
>> +}
>
> Beware that gcc will freely ignore your "inline" directive.
>
> When I compiled it, gcc did appear to inline it.  Then I added
> __always_inline and it was still inlined, but the text section in the
> .o file got 20 bytes larger.  Odd.
>
>>   /*
>>    * This assumes that the caller has performed appropriate preallocation, and
>>    * that the caller has pinned this thread of control to the current CPU.
>> @@ -613,6 +649,117 @@ int radix_tree_tag_get(struct radix_tree_root *root,
>>   EXPORT_SYMBOL(radix_tree_tag_get);
>>
>>   /**
>> + * radix_tree_next_chunk - find next chunk of slots for iteration
>> + *
>> + * @root:            radix tree root
>> + * @iter:            iterator state
>> + * @flags            RADIX_TREE_ITER_* flags and tag index
>> + *
>> + * Returns pointer to first slots in chunk, or NULL if there no more left
>> + */
>> +void **radix_tree_next_chunk(struct radix_tree_root *root,
>> +                          struct radix_tree_iter *iter, unsigned flags)
>> +{
>> +     unsigned shift, tag = flags&  RADIX_TREE_ITER_TAG_MASK;
>> +     struct radix_tree_node *rnode, *node;
>> +     unsigned long i, index;
>
> When a c programmer sees a variable called "i", he solidly expects it
> to have type "int".  Please choose a better name for this guy!
> Perferably something which helps the reader understand what the
> variable's role is.

=) Ok, I can make it "int"

>
>> +     if ((flags&  RADIX_TREE_ITER_TAGGED)&&  !root_tag_get(root, tag))
>> +             return NULL;
>> +
>> +     /*
>> +      * Catch next_index overflow after ~0UL.
>> +      * iter->index can be zero only at the beginning.
>> +      * Because RADIX_TREE_MAP_SHIFT<  BITS_PER_LONG we cannot
>> +      * oveflow iter->next_index in single step.
>> +      */
>> +     index = iter->next_index;
>> +     if (!index&&  iter->index)
>> +             return NULL;
>> +
>> +     rnode = rcu_dereference_raw(root->rnode);
>> +     if (radix_tree_is_indirect_ptr(rnode)) {
>> +             rnode = indirect_to_ptr(rnode);
>> +     } else if (rnode&&  !index) {
>> +             /* Single-slot tree */
>> +             iter->index = 0;
>> +             iter->next_index = 1;
>> +             iter->tags = 1;
>> +             return (void **)&root->rnode;
>> +     } else
>> +             return NULL;
>> +
>> +restart:
>> +     shift = (rnode->height - 1) * RADIX_TREE_MAP_SHIFT;
>> +     i = index>>  shift;
>> +
>> +     /* Index ouside of the tree */
>> +     if (i>= RADIX_TREE_MAP_SIZE)
>> +             return NULL;
>> +
>> +     node = rnode;
>> +     while (1) {
>> +             if ((flags&  RADIX_TREE_ITER_TAGGED) ?
>> +                             !test_bit(i, node->tags[tag]) :
>> +                             !node->slots[i]) {
>> +                     /* Hole detected */
>> +                     if (flags&  RADIX_TREE_ITER_CONTIG)
>> +                             return NULL;
>> +
>> +                     if (flags&  RADIX_TREE_ITER_TAGGED)
>> +                             i = radix_tree_find_next_bit(node->tags[tag],
>> +                                             RADIX_TREE_MAP_SIZE, i + 1);
>> +                     else
>> +                             while (++i<  RADIX_TREE_MAP_SIZE&&
>> +                                             !node->slots[i]);
>> +
>> +                     index&= ~((RADIX_TREE_MAP_SIZE<<  shift) - 1);
>> +                     index += i<<  shift;
>> +                     /* Overflow after ~0UL */
>> +                     if (!index)
>> +                             return NULL;
>> +                     if (i == RADIX_TREE_MAP_SIZE)
>> +                             goto restart;
>> +             }
>> +
>> +             /* This is leaf-node */
>> +             if (!shift)
>> +                     break;
>> +
>> +             node = rcu_dereference_raw(node->slots[i]);
>> +             if (node == NULL)
>> +                     goto restart;
>> +             shift -= RADIX_TREE_MAP_SHIFT;
>> +             i = (index>>  shift)&  RADIX_TREE_MAP_MASK;
>> +     }
>> +
>> +     /* Update the iterator state */
>> +     iter->index = index;
>> +     iter->next_index = (index | RADIX_TREE_MAP_MASK) + 1;
>> +
>> +     /* Construct iter->tags bitmask from node->tags[tag] array */
>> +     if (flags&  RADIX_TREE_ITER_TAGGED) {
>> +             unsigned tag_long, tag_bit;
>> +
>> +             tag_long = i / BITS_PER_LONG;
>> +             tag_bit  = i % BITS_PER_LONG;
>> +             iter->tags = node->tags[tag][tag_long]>>  tag_bit;
>> +             /* This never happens if RADIX_TREE_TAG_LONGS == 1 */
>> +             if (tag_long<  RADIX_TREE_TAG_LONGS - 1) {
>> +                     /* Pick tags from next element */
>> +                     if (tag_bit)
>> +                             iter->tags |= node->tags[tag][tag_long + 1]<<
>> +                                             (BITS_PER_LONG - tag_bit);
>> +                     /* Clip chunk size, here only BITS_PER_LONG tags */
>> +                     iter->next_index = index + BITS_PER_LONG;
>> +             }
>> +     }
>> +
>> +     return node->slots + i;
>> +}
>> +EXPORT_SYMBOL(radix_tree_next_chunk);
>> +
>> +/**
>>    * radix_tree_range_tag_if_tagged - for each item in given range set given
>>    *                              tag if item has another tag set
>>    * @root:            radix tree root
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
