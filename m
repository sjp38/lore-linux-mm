Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6AD416B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 15:26:32 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id e53so1951310eek.11
        for <linux-mm@kvack.org>; Wed, 21 May 2014 12:26:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t44si10706884eeg.164.2014.05.21.12.26.29
        for <linux-mm@kvack.org>;
        Wed, 21 May 2014 12:26:30 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/4] radix-tree: add end_index to support ranged iteration
Date: Wed, 21 May 2014 15:26:02 -0400
Message-Id: <537cfde6.446e0e0a.7cfa.fffff938SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <CALYGNiPKiKAyZm0miM1LCvMRMeNCz=zg6ToR1ZhJ-eQ0c_treg@mail.gmail.com>
References: <1400639194-3743-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1400639194-3743-2-git-send-email-n-horiguchi@ah.jp.nec.com> <CALYGNiPKiKAyZm0miM1LCvMRMeNCz=zg6ToR1ZhJ-eQ0c_treg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>

On Wed, May 21, 2014 at 12:21:15PM +0400, Konstantin Khlebnikov wrote:
> On Wed, May 21, 2014 at 6:26 AM, Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
> > It's useful if we can run only over a specific index range of radix trees,
> > which this patch does. This patch changes only radix_tree_for_each_slot()
> > and radix_tree_for_each_tagged(), because we need it only for them for now.
> 
> NAK, I don't see how this is usefull. Main users don't need this.

Right, this patch contains preparation for another patchset, which we don't
need at this patch series. I'll make change minimum for this specific patchset
in the next post.

> Barely used argument don't makes complicated macro easier.
> radix_tree_next_slot() is perfomance-critical. I'm not sure that
> compiler can throw out
> your checks if the end is -1, since it stored in structure which is
> passed into function.
> 
> Just write something like this where needed.
> 
> radix_tree_for_each_slot(..) {
>    if (iter.index > end)
>       goto out;
>    <...>
>    if (iter.index == end)
>       goto out;
> }
> out:
> 
> Probably this migh be hidden in a macro as well.
> There is simple way to abort iterating: set next_index to zero and
> break inner loop.

OK, sounds good. I'll do termination check in caller side.

Thanks,
Naoya Horiguchi

> >
> > ChangeLog:
> > - rebased onto v3.15-rc5, which has e a few new caller of radix_tree_for_each_slot(),
> >   so apply this change them too.
> >
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  drivers/gpu/drm/qxl/qxl_ttm.c |  2 +-
> >  include/linux/radix-tree.h    | 27 ++++++++++++++++++++-------
> >  kernel/irq/irqdomain.c        |  2 +-
> >  lib/radix-tree.c              |  8 ++++----
> >  mm/filemap.c                  |  8 ++++----
> >  5 files changed, 30 insertions(+), 17 deletions(-)
> >
> > diff --git v3.15-rc5.orig/drivers/gpu/drm/qxl/qxl_ttm.c v3.15-rc5/drivers/gpu/drm/qxl/qxl_ttm.c
> > index d52c27527b9a..d807e66fe308 100644
> > --- v3.15-rc5.orig/drivers/gpu/drm/qxl/qxl_ttm.c
> > +++ v3.15-rc5/drivers/gpu/drm/qxl/qxl_ttm.c
> > @@ -398,7 +398,7 @@ static int qxl_sync_obj_wait(void *sync_obj,
> >                 struct radix_tree_iter iter;
> >                 int release_id;
> >
> > -               radix_tree_for_each_slot(slot, &qfence->tree, &iter, 0) {
> > +               radix_tree_for_each_slot(slot, &qfence->tree, &iter, 0, ~0UL) {
> >                         struct qxl_release *release;
> >
> >                         release_id = iter.index;
> > diff --git v3.15-rc5.orig/include/linux/radix-tree.h v3.15-rc5/include/linux/radix-tree.h
> > index 33170dbd9db4..88258c34371f 100644
> > --- v3.15-rc5.orig/include/linux/radix-tree.h
> > +++ v3.15-rc5/include/linux/radix-tree.h
> > @@ -312,6 +312,7 @@ static inline void radix_tree_preload_end(void)
> >   * @index:     index of current slot
> >   * @next_index:        next-to-last index for this chunk
> >   * @tags:      bit-mask for tag-iterating
> > + * @end_index:  last index to be scanned
> >   *
> >   * This radix tree iterator works in terms of "chunks" of slots.  A chunk is a
> >   * subinterval of slots contained within one radix tree leaf node.  It is
> > @@ -324,6 +325,7 @@ struct radix_tree_iter {
> >         unsigned long   index;
> >         unsigned long   next_index;
> >         unsigned long   tags;
> > +       unsigned long   end_index;
> >  };
> >
> >  #define RADIX_TREE_ITER_TAG_MASK       0x00FF  /* tag index in lower byte */
> > @@ -335,10 +337,12 @@ struct radix_tree_iter {
> >   *
> >   * @iter:      pointer to iterator state
> >   * @start:     iteration starting index
> > + * @end:       iteration ending index
> >   * Returns:    NULL
> >   */
> >  static __always_inline void **
> > -radix_tree_iter_init(struct radix_tree_iter *iter, unsigned long start)
> > +radix_tree_iter_init(struct radix_tree_iter *iter, unsigned long start,
> > +                       unsigned long end)
> >  {
> >         /*
> >          * Leave iter->tags uninitialized. radix_tree_next_chunk() will fill it
> > @@ -350,6 +354,7 @@ radix_tree_iter_init(struct radix_tree_iter *iter, unsigned long start)
> >          */
> >         iter->index = 0;
> >         iter->next_index = start;
> > +       iter->end_index = end;
> >         return NULL;
> >  }
> >
> > @@ -399,6 +404,8 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
> >                 iter->tags >>= 1;
> >                 if (likely(iter->tags & 1ul)) {
> >                         iter->index++;
> > +                       if (iter->index > iter->end_index)
> > +                               return NULL;
> >                         return slot + 1;
> >                 }
> >                 if (!(flags & RADIX_TREE_ITER_CONTIG) && likely(iter->tags)) {
> > @@ -406,6 +413,8 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
> >
> >                         iter->tags >>= offset;
> >                         iter->index += offset + 1;
> > +                       if (iter->index > iter->end_index)
> > +                               return NULL;
> >                         return slot + offset + 1;
> >                 }
> >         } else {
> > @@ -414,6 +423,8 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
> >                 while (size--) {
> >                         slot++;
> >                         iter->index++;
> > +                       if (iter->index > iter->end_index)
> > +                               return NULL;
> >                         if (likely(*slot))
> >                                 return slot;
> >                         if (flags & RADIX_TREE_ITER_CONTIG) {
> > @@ -438,7 +449,7 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
> >   * Locks can be released and reacquired between iterations.
> >   */
> >  #define radix_tree_for_each_chunk(slot, root, iter, start, flags)      \
> > -       for (slot = radix_tree_iter_init(iter, start) ;                 \
> > +       for (slot = radix_tree_iter_init(iter, start, ~0UL) ;           \
> >               (slot = radix_tree_next_chunk(root, iter, flags)) ;)
> >
> >  /**
> > @@ -461,11 +472,12 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
> >   * @root:      the struct radix_tree_root pointer
> >   * @iter:      the struct radix_tree_iter pointer
> >   * @start:     iteration starting index
> > + * @end:       iteration ending index
> >   *
> >   * @slot points to radix tree slot, @iter->index contains its index.
> >   */
> > -#define radix_tree_for_each_slot(slot, root, iter, start)              \
> > -       for (slot = radix_tree_iter_init(iter, start) ;                 \
> > +#define radix_tree_for_each_slot(slot, root, iter, start, end)         \
> > +       for (slot = radix_tree_iter_init(iter, start, end) ;            \
> >              slot || (slot = radix_tree_next_chunk(root, iter, 0)) ;    \
> >              slot = radix_tree_next_slot(slot, iter, 0))
> >
> > @@ -480,7 +492,7 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
> >   * @slot points to radix tree slot, @iter->index contains its index.
> >   */
> >  #define radix_tree_for_each_contig(slot, root, iter, start)            \
> > -       for (slot = radix_tree_iter_init(iter, start) ;                 \
> > +       for (slot = radix_tree_iter_init(iter, start, ~0UL) ;           \
> >              slot || (slot = radix_tree_next_chunk(root, iter,          \
> >                                 RADIX_TREE_ITER_CONTIG)) ;              \
> >              slot = radix_tree_next_slot(slot, iter,                    \
> > @@ -493,12 +505,13 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
> >   * @root:      the struct radix_tree_root pointer
> >   * @iter:      the struct radix_tree_iter pointer
> >   * @start:     iteration starting index
> > + * @end:       iteration ending index
> >   * @tag:       tag index
> >   *
> >   * @slot points to radix tree slot, @iter->index contains its index.
> >   */
> > -#define radix_tree_for_each_tagged(slot, root, iter, start, tag)       \
> > -       for (slot = radix_tree_iter_init(iter, start) ;                 \
> > +#define radix_tree_for_each_tagged(slot, root, iter, start, end, tag)  \
> > +       for (slot = radix_tree_iter_init(iter, start, end) ;            \
> >              slot || (slot = radix_tree_next_chunk(root, iter,          \
> >                               RADIX_TREE_ITER_TAGGED | tag)) ;          \
> >              slot = radix_tree_next_slot(slot, iter,                    \
> > diff --git v3.15-rc5.orig/kernel/irq/irqdomain.c v3.15-rc5/kernel/irq/irqdomain.c
> > index f14033700c25..55fc49b412e1 100644
> > --- v3.15-rc5.orig/kernel/irq/irqdomain.c
> > +++ v3.15-rc5/kernel/irq/irqdomain.c
> > @@ -571,7 +571,7 @@ static int virq_debug_show(struct seq_file *m, void *private)
> >         mutex_lock(&irq_domain_mutex);
> >         list_for_each_entry(domain, &irq_domain_list, link) {
> >                 int count = 0;
> > -               radix_tree_for_each_slot(slot, &domain->revmap_tree, &iter, 0)
> > +               radix_tree_for_each_slot(slot, &domain->revmap_tree, &iter, 0, ~0UL)
> >                         count++;
> >                 seq_printf(m, "%c%-16s  %6u  %10u  %10u  %s\n",
> >                            domain == irq_default_domain ? '*' : ' ', domain->name,
> > diff --git v3.15-rc5.orig/lib/radix-tree.c v3.15-rc5/lib/radix-tree.c
> > index 9599aa72d7a0..531fba8a81db 100644
> > --- v3.15-rc5.orig/lib/radix-tree.c
> > +++ v3.15-rc5/lib/radix-tree.c
> > @@ -1007,7 +1007,7 @@ radix_tree_gang_lookup(struct radix_tree_root *root, void **results,
> >         if (unlikely(!max_items))
> >                 return 0;
> >
> > -       radix_tree_for_each_slot(slot, root, &iter, first_index) {
> > +       radix_tree_for_each_slot(slot, root, &iter, first_index, ~0UL) {
> >                 results[ret] = indirect_to_ptr(rcu_dereference_raw(*slot));
> >                 if (!results[ret])
> >                         continue;
> > @@ -1049,7 +1049,7 @@ radix_tree_gang_lookup_slot(struct radix_tree_root *root,
> >         if (unlikely(!max_items))
> >                 return 0;
> >
> > -       radix_tree_for_each_slot(slot, root, &iter, first_index) {
> > +       radix_tree_for_each_slot(slot, root, &iter, first_index, ~0UL) {
> >                 results[ret] = slot;
> >                 if (indices)
> >                         indices[ret] = iter.index;
> > @@ -1086,7 +1086,7 @@ radix_tree_gang_lookup_tag(struct radix_tree_root *root, void **results,
> >         if (unlikely(!max_items))
> >                 return 0;
> >
> > -       radix_tree_for_each_tagged(slot, root, &iter, first_index, tag) {
> > +       radix_tree_for_each_tagged(slot, root, &iter, first_index, ~0UL, tag) {
> >                 results[ret] = indirect_to_ptr(rcu_dereference_raw(*slot));
> >                 if (!results[ret])
> >                         continue;
> > @@ -1123,7 +1123,7 @@ radix_tree_gang_lookup_tag_slot(struct radix_tree_root *root, void ***results,
> >         if (unlikely(!max_items))
> >                 return 0;
> >
> > -       radix_tree_for_each_tagged(slot, root, &iter, first_index, tag) {
> > +       radix_tree_for_each_tagged(slot, root, &iter, first_index, ~0UL, tag) {
> >                 results[ret] = slot;
> >                 if (++ret == max_items)
> >                         break;
> > diff --git v3.15-rc5.orig/mm/filemap.c v3.15-rc5/mm/filemap.c
> > index 000a220e2a41..d684e4cffe96 100644
> > --- v3.15-rc5.orig/mm/filemap.c
> > +++ v3.15-rc5/mm/filemap.c
> > @@ -1118,7 +1118,7 @@ unsigned find_get_entries(struct address_space *mapping,
> >
> >         rcu_read_lock();
> >  restart:
> > -       radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
> > +       radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start, ~0UL) {
> >                 struct page *page;
> >  repeat:
> >                 page = radix_tree_deref_slot(slot);
> > @@ -1180,7 +1180,7 @@ unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
> >
> >         rcu_read_lock();
> >  restart:
> > -       radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
> > +       radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start, ~0UL) {
> >                 struct page *page;
> >  repeat:
> >                 page = radix_tree_deref_slot(slot);
> > @@ -1324,7 +1324,7 @@ unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
> >         rcu_read_lock();
> >  restart:
> >         radix_tree_for_each_tagged(slot, &mapping->page_tree,
> > -                                  &iter, *index, tag) {
> > +                                  &iter, *index, ~0UL, tag) {
> >                 struct page *page;
> >  repeat:
> >                 page = radix_tree_deref_slot(slot);
> > @@ -2023,7 +2023,7 @@ void filemap_map_pages(struct vm_area_struct *vma, struct vm_fault *vmf)
> >         pte_t *pte;
> >
> >         rcu_read_lock();
> > -       radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, vmf->pgoff) {
> > +       radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, vmf->pgoff, ~0UL) {
> >                 if (iter.index > vmf->max_pgoff)
> >                         break;
> >  repeat:
> > --
> > 1.9.0
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
