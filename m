Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 68BF76B0405
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 06:47:39 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u144so12435771wmu.1
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 03:47:39 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id v191si2198885wme.2.2016.11.18.03.47.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 03:47:37 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id g23so5370590wme.1
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 03:47:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1479341856-30320-59-git-send-email-mawilcox@linuxonhyperv.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com> <1479341856-30320-59-git-send-email-mawilcox@linuxonhyperv.com>
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Fri, 18 Nov 2016 14:47:35 +0300
Message-ID: <CALYGNiN++jFZZwvShjD4PDV=cZczVOs+K-ib-ZL=M+v2XU_aYQ@mail.gmail.com>
Subject: Re: [PATCH 20/29] radix tree: Improve multiorder iterators
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Matthew Wilcox <mawilcox@microsoft.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Nov 17, 2016 at 3:17 AM, Matthew Wilcox
<mawilcox@linuxonhyperv.com> wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>

This code still looks overengineered for me.

>
> This fixes several interlinked problems with the iterators in the
> presence of multiorder entries.
>
> 1. radix_tree_iter_next() would only advance by one slot, which would
> result in the iterators returning the same entry more than once if there
> were sibling entries.

Is this a problem? Do we have users who cannot evalate length of entry
by looking into it head?

>
> 2. radix_tree_next_slot() could return an internal pointer instead of
> a user pointer if a tagged multiorder entry was immediately followed by
> an entry of lower order.
>
> 3. radix_tree_next_slot() expanded to a lot more code than it used to
> when multiorder support was compiled in.  And I wasn't comfortable with
> entry_to_node() being in a header file.
>
> Fixing radix_tree_iter_next() for the presence of sibling entries
> necessarily involves examining the contents of the radix tree, so we now
> need to pass 'slot' to radix_tree_iter_next(), and we need to change the
> calling convention so it is called *before* dropping the lock which
> protects the tree.  Fortunately, unconverted code won't compile.
>
> radix_tree_next_slot() becomes closer to how it looked before multiorder
> support was introduced.  It only checks to see if the next entry in the
> chunk is a sibling entry or a pointer to a node; this should be rare
> enough that handling this case out of line is not a performance impact
> (and such impact is amortised by the fact that the entry we just
> processed was a multiorder entry).  Also, radix_tree_next_slot() used
> to force a new chunk lookup for untagged entries, which is more
> expensive than the out of line sibling entry
>
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  fs/btrfs/tests/btrfs-tests.c               |  2 +-
>  include/linux/radix-tree.h                 | 63 ++++++++------------
>  lib/radix-tree.c                           | 94 ++++++++++++++++++++++++++++++
>  mm/khugepaged.c                            |  2 +-
>  mm/shmem.c                                 |  6 +-
>  tools/testing/radix-tree/iteration_check.c |  4 +-
>  tools/testing/radix-tree/multiorder.c      | 12 ++++
>  tools/testing/radix-tree/regression3.c     |  6 +-
>  tools/testing/radix-tree/test.h            |  1 +
>  9 files changed, 142 insertions(+), 48 deletions(-)
>
> diff --git a/fs/btrfs/tests/btrfs-tests.c b/fs/btrfs/tests/btrfs-tests.c
> index 73076a0..6d3457a 100644
> --- a/fs/btrfs/tests/btrfs-tests.c
> +++ b/fs/btrfs/tests/btrfs-tests.c
> @@ -162,7 +162,7 @@ void btrfs_free_dummy_fs_info(struct btrfs_fs_info *fs_info)
>                                 slot = radix_tree_iter_retry(&iter);
>                         continue;
>                 }
> -               slot = radix_tree_iter_next(&iter);
> +               slot = radix_tree_iter_next(slot, &iter);
>                 spin_unlock(&fs_info->buffer_lock);
>                 free_extent_buffer_stale(eb);
>                 spin_lock(&fs_info->buffer_lock);
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index 66fb8c0..36c6175 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -424,15 +424,10 @@ __radix_tree_iter_add(struct radix_tree_iter *iter, unsigned long slots)
>   *
>   * If the iterator needs to release then reacquire a lock, the chunk may
>   * have been invalidated by an insertion or deletion.  Call this function
> - * to continue the iteration from the next index.
> + * before releasing the lock to continue the iteration from the next index.
>   */
> -static inline __must_check
> -void **radix_tree_iter_next(struct radix_tree_iter *iter)
> -{
> -       iter->next_index = __radix_tree_iter_add(iter, 1);
> -       iter->tags = 0;
> -       return NULL;
> -}
> +void **__must_check radix_tree_iter_next(void **slot,
> +                                       struct radix_tree_iter *iter);
>
>  /**
>   * radix_tree_chunk_size - get current chunk size
> @@ -446,10 +441,17 @@ radix_tree_chunk_size(struct radix_tree_iter *iter)
>         return (iter->next_index - iter->index) >> iter_shift(iter);
>  }
>
> -static inline struct radix_tree_node *entry_to_node(void *ptr)
> +#ifdef CONFIG_RADIX_TREE_MULTIORDER
> +void ** __radix_tree_next_slot(void **slot, struct radix_tree_iter *iter,
> +                               unsigned flags);
> +#else
> +/* Can't happen without sibling entries, but the compiler can't tell that */
> +static inline void ** __radix_tree_next_slot(void **slot,
> +                               struct radix_tree_iter *iter, unsigned flags)
>  {
> -       return (void *)((unsigned long)ptr & ~RADIX_TREE_INTERNAL_NODE);
> +       return slot;
>  }
> +#endif
>
>  /**
>   * radix_tree_next_slot - find next slot in chunk
> @@ -474,51 +476,31 @@ static __always_inline void **
>  radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
>  {
>         if (flags & RADIX_TREE_ITER_TAGGED) {
> -               void *canon = slot;
> -
>                 iter->tags >>= 1;
>                 if (unlikely(!iter->tags))
>                         return NULL;
> -               while (IS_ENABLED(CONFIG_RADIX_TREE_MULTIORDER) &&
> -                                       radix_tree_is_internal_node(slot[1])) {
> -                       if (entry_to_node(slot[1]) == canon) {
> -                               iter->tags >>= 1;
> -                               iter->index = __radix_tree_iter_add(iter, 1);
> -                               slot++;
> -                               continue;
> -                       }
> -                       iter->next_index = __radix_tree_iter_add(iter, 1);
> -                       return NULL;
> -               }
>                 if (likely(iter->tags & 1ul)) {
>                         iter->index = __radix_tree_iter_add(iter, 1);
> -                       return slot + 1;
> +                       slot++;
> +                       goto found;
>                 }
>                 if (!(flags & RADIX_TREE_ITER_CONTIG)) {
>                         unsigned offset = __ffs(iter->tags);
>
> -                       iter->tags >>= offset;
> -                       iter->index = __radix_tree_iter_add(iter, offset + 1);
> -                       return slot + offset + 1;
> +                       iter->tags >>= offset++;
> +                       iter->index = __radix_tree_iter_add(iter, offset);
> +                       slot += offset;
> +                       goto found;
>                 }
>         } else {
>                 long count = radix_tree_chunk_size(iter);
> -               void *canon = slot;
>
>                 while (--count > 0) {
>                         slot++;
>                         iter->index = __radix_tree_iter_add(iter, 1);
>
> -                       if (IS_ENABLED(CONFIG_RADIX_TREE_MULTIORDER) &&
> -                           radix_tree_is_internal_node(*slot)) {
> -                               if (entry_to_node(*slot) == canon)
> -                                       continue;
> -                               iter->next_index = iter->index;
> -                               break;
> -                       }
> -
>                         if (likely(*slot))
> -                               return slot;
> +                               goto found;
>                         if (flags & RADIX_TREE_ITER_CONTIG) {
>                                 /* forbid switching to the next chunk */
>                                 iter->next_index = 0;
> @@ -527,6 +509,11 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
>                 }
>         }
>         return NULL;
> +
> + found:
> +       if (unlikely(radix_tree_is_internal_node(*slot)))
> +               return __radix_tree_next_slot(slot, iter, flags);
> +       return slot;
>  }
>
>  /**
> @@ -577,6 +564,6 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
>              slot || (slot = radix_tree_next_chunk(root, iter,          \
>                               RADIX_TREE_ITER_TAGGED | tag)) ;          \
>              slot = radix_tree_next_slot(slot, iter,                    \
> -                               RADIX_TREE_ITER_TAGGED))
> +                               RADIX_TREE_ITER_TAGGED | tag))
>
>  #endif /* _LINUX_RADIX_TREE_H */
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index 09c5f1d..27b53ef 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -69,6 +69,11 @@ struct radix_tree_preload {
>  };
>  static DEFINE_PER_CPU(struct radix_tree_preload, radix_tree_preloads) = { 0, };
>
> +static inline struct radix_tree_node *entry_to_node(void *ptr)
> +{
> +       return (void *)((unsigned long)ptr & ~RADIX_TREE_INTERNAL_NODE);
> +}
> +
>  static inline void *node_to_entry(void *ptr)
>  {
>         return (void *)((unsigned long)ptr | RADIX_TREE_INTERNAL_NODE);
> @@ -1138,6 +1143,95 @@ static inline void __set_iter_shift(struct radix_tree_iter *iter,
>  #endif
>  }
>
> +static void ** __radix_tree_iter_next(struct radix_tree_node **nodep,
> +                       void **slot, struct radix_tree_iter *iter)
> +{
> +       void *sib = node_to_entry(slot - 1);
> +
> +       while (iter->index < iter->next_index) {
> +               *nodep = rcu_dereference_raw(*slot);
> +               if (*nodep && *nodep != sib)
> +                       return slot;
> +               slot++;
> +               iter->index = __radix_tree_iter_add(iter, 1);
> +               iter->tags >>= 1;
> +       }
> +
> +       *nodep = NULL;
> +       return NULL;
> +}
> +
> +#ifdef CONFIG_RADIX_TREE_MULTIORDER
> +void ** __radix_tree_next_slot(void **slot, struct radix_tree_iter *iter,
> +                                       unsigned flags)
> +{
> +       unsigned tag = flags & RADIX_TREE_ITER_TAG_MASK;
> +       struct radix_tree_node *node = rcu_dereference_raw(*slot);
> +
> +       slot = __radix_tree_iter_next(&node, slot, iter);
> +
> +       while (radix_tree_is_internal_node(node)) {
> +               unsigned offset;
> +
> +               if (node == RADIX_TREE_RETRY)
> +                       return slot;
> +               node = entry_to_node(node);
> +
> +               if (flags & RADIX_TREE_ITER_TAGGED) {
> +                       unsigned tag_long, tag_bit;
> +                       offset = radix_tree_find_next_bit(node, tag, 0);
> +                       if (offset == RADIX_TREE_MAP_SIZE)
> +                               return NULL;
> +                       slot = &node->slots[offset];
> +
> +                       tag_long = offset / BITS_PER_LONG;
> +                       tag_bit  = offset % BITS_PER_LONG;
> +                       iter->tags = node->tags[tag][tag_long] >> tag_bit;
> +                       BUG_ON(iter->tags >= (RADIX_TREE_MAP_SIZE * 2));
> +                       node = rcu_dereference_raw(*slot);
> +               } else {
> +                       offset = 0;
> +                       slot = &node->slots[0];
> +                       for (;;) {
> +                               node = rcu_dereference_raw(*slot);
> +                               if (node)
> +                                       break;
> +                               slot++;
> +                               offset++;
> +                               if (offset == RADIX_TREE_MAP_SIZE)
> +                                       return NULL;
> +                       }
> +               }
> +               if ((flags & RADIX_TREE_ITER_CONTIG) && (offset > 0))
> +                       goto none;
> +               iter->shift -= RADIX_TREE_MAP_SHIFT;
> +               iter->index = __radix_tree_iter_add(iter, offset);
> +               iter->next_index = (iter->index | shift_maxindex(iter->shift)) +
> +                                       1;
> +       }
> +
> +       return slot;
> + none:
> +       iter->next_index = 0;
> +       return NULL;
> +}
> +EXPORT_SYMBOL(__radix_tree_next_slot);
> +#endif
> +
> +void **radix_tree_iter_next(void **slot, struct radix_tree_iter *iter)
> +{
> +       struct radix_tree_node *node;
> +
> +       slot++;
> +       iter->index = __radix_tree_iter_add(iter, 1);
> +       node = rcu_dereference_raw(*slot);
> +       __radix_tree_iter_next(&node, slot, iter);
> +       iter->next_index = iter->index;
> +       iter->tags = 0;
> +       return NULL;
> +}
> +EXPORT_SYMBOL(radix_tree_iter_next);
> +
>  /**
>   * radix_tree_next_chunk - find next chunk of slots for iteration
>   *
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index 728d779..46155d1 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1614,8 +1614,8 @@ static void khugepaged_scan_shmem(struct mm_struct *mm,
>                 present++;
>
>                 if (need_resched()) {
> +                       slot = radix_tree_iter_next(slot, &iter);
>                         cond_resched_rcu();
> -                       slot = radix_tree_iter_next(&iter);
>                 }
>         }
>         rcu_read_unlock();
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 166ebf5..0b3fe33 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -658,8 +658,8 @@ unsigned long shmem_partial_swap_usage(struct address_space *mapping,
>                         swapped++;
>
>                 if (need_resched()) {
> +                       slot = radix_tree_iter_next(slot, &iter);
>                         cond_resched_rcu();
> -                       slot = radix_tree_iter_next(&iter);
>                 }
>         }
>
> @@ -2434,8 +2434,8 @@ static void shmem_tag_pins(struct address_space *mapping)
>                 }
>
>                 if (need_resched()) {
> +                       slot = radix_tree_iter_next(slot, &iter);
>                         cond_resched_rcu();
> -                       slot = radix_tree_iter_next(&iter);
>                 }
>         }
>         rcu_read_unlock();
> @@ -2504,8 +2504,8 @@ static int shmem_wait_for_pins(struct address_space *mapping)
>                         spin_unlock_irq(&mapping->tree_lock);
>  continue_resched:
>                         if (need_resched()) {
> +                               slot = radix_tree_iter_next(slot, &iter);
>                                 cond_resched_rcu();
> -                               slot = radix_tree_iter_next(&iter);
>                         }
>                 }
>                 rcu_read_unlock();
> diff --git a/tools/testing/radix-tree/iteration_check.c b/tools/testing/radix-tree/iteration_check.c
> index df71cb8..6eca4c2 100644
> --- a/tools/testing/radix-tree/iteration_check.c
> +++ b/tools/testing/radix-tree/iteration_check.c
> @@ -79,7 +79,7 @@ static void *tagged_iteration_fn(void *arg)
>                         }
>
>                         if (rand_r(&seeds[0]) % 50 == 0) {
> -                               slot = radix_tree_iter_next(&iter);
> +                               slot = radix_tree_iter_next(slot, &iter);
>                                 rcu_read_unlock();
>                                 rcu_barrier();
>                                 rcu_read_lock();
> @@ -127,7 +127,7 @@ static void *untagged_iteration_fn(void *arg)
>                         }
>
>                         if (rand_r(&seeds[1]) % 50 == 0) {
> -                               slot = radix_tree_iter_next(&iter);
> +                               slot = radix_tree_iter_next(slot, &iter);
>                                 rcu_read_unlock();
>                                 rcu_barrier();
>                                 rcu_read_lock();
> diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
> index 25e0463..588209a 100644
> --- a/tools/testing/radix-tree/multiorder.c
> +++ b/tools/testing/radix-tree/multiorder.c
> @@ -232,10 +232,14 @@ void multiorder_iteration(void)
>                         int height = order[i] / RADIX_TREE_MAP_SHIFT;
>                         int shift = height * RADIX_TREE_MAP_SHIFT;
>                         int mask = (1 << order[i]) - 1;
> +                       struct item *item = *slot;
>
>                         assert(iter.index >= (index[i] &~ mask));
>                         assert(iter.index <= (index[i] | mask));
>                         assert(iter.shift == shift);
> +                       assert(!radix_tree_is_internal_node(item));
> +                       assert(item->index >= (index[i] &~ mask));
> +                       assert(item->index <= (index[i] | mask));
>                         i++;
>                 }
>         }
> @@ -279,12 +283,16 @@ void multiorder_tagged_iteration(void)
>                 }
>
>                 radix_tree_for_each_tagged(slot, &tree, &iter, j, 1) {
> +                       struct item *item = *slot;
>                         for (k = i; index[k] < tag_index[i]; k++)
>                                 ;
>                         mask = (1 << order[k]) - 1;
>
>                         assert(iter.index >= (tag_index[i] &~ mask));
>                         assert(iter.index <= (tag_index[i] | mask));
> +                       assert(!radix_tree_is_internal_node(item));
> +                       assert(item->index >= (tag_index[i] &~ mask));
> +                       assert(item->index <= (tag_index[i] | mask));
>                         i++;
>                 }
>         }
> @@ -303,12 +311,16 @@ void multiorder_tagged_iteration(void)
>                 }
>
>                 radix_tree_for_each_tagged(slot, &tree, &iter, j, 2) {
> +                       struct item *item = *slot;
>                         for (k = i; index[k] < tag_index[i]; k++)
>                                 ;
>                         mask = (1 << order[k]) - 1;
>
>                         assert(iter.index >= (tag_index[i] &~ mask));
>                         assert(iter.index <= (tag_index[i] | mask));
> +                       assert(!radix_tree_is_internal_node(item));
> +                       assert(item->index >= (tag_index[i] &~ mask));
> +                       assert(item->index <= (tag_index[i] | mask));
>                         i++;
>                 }
>         }
> diff --git a/tools/testing/radix-tree/regression3.c b/tools/testing/radix-tree/regression3.c
> index 1f06ed7..4d28eeb 100644
> --- a/tools/testing/radix-tree/regression3.c
> +++ b/tools/testing/radix-tree/regression3.c
> @@ -88,7 +88,7 @@ void regression3_test(void)
>                 printf("slot %ld %p\n", iter.index, *slot);
>                 if (!iter.index) {
>                         printf("next at %ld\n", iter.index);
> -                       slot = radix_tree_iter_next(&iter);
> +                       slot = radix_tree_iter_next(slot, &iter);
>                 }
>         }
>
> @@ -96,7 +96,7 @@ void regression3_test(void)
>                 printf("contig %ld %p\n", iter.index, *slot);
>                 if (!iter.index) {
>                         printf("next at %ld\n", iter.index);
> -                       slot = radix_tree_iter_next(&iter);
> +                       slot = radix_tree_iter_next(slot, &iter);
>                 }
>         }
>
> @@ -106,7 +106,7 @@ void regression3_test(void)
>                 printf("tagged %ld %p\n", iter.index, *slot);
>                 if (!iter.index) {
>                         printf("next at %ld\n", iter.index);
> -                       slot = radix_tree_iter_next(&iter);
> +                       slot = radix_tree_iter_next(slot, &iter);
>                 }
>         }
>
> diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
> index 33d2b6b..b678f13 100644
> --- a/tools/testing/radix-tree/test.h
> +++ b/tools/testing/radix-tree/test.h
> @@ -43,6 +43,7 @@ void verify_tag_consistency(struct radix_tree_root *root, unsigned int tag);
>  extern int nr_allocated;
>
>  /* Normally private parts of lib/radix-tree.c */
> +struct radix_tree_node *entry_to_node(void *ptr);
>  void radix_tree_dump(struct radix_tree_root *root);
>  int root_tag_get(struct radix_tree_root *root, unsigned int tag);
>  unsigned long node_maxindex(struct radix_tree_node *);
> --
> 2.10.2
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
