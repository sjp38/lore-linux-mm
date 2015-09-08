Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1346B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 02:50:01 -0400 (EDT)
Received: by obuk4 with SMTP id k4so76054146obu.2
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 23:50:01 -0700 (PDT)
Received: from mail-oi0-x22a.google.com (mail-oi0-x22a.google.com. [2607:f8b0:4003:c06::22a])
        by mx.google.com with ESMTPS id yx2si1581874obb.31.2015.09.07.23.49.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 23:49:59 -0700 (PDT)
Received: by oibi136 with SMTP id i136so53602761oib.3
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 23:49:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1440418191-10894-8-git-send-email-mgorman@techsingularity.net>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
	<1440418191-10894-8-git-send-email-mgorman@techsingularity.net>
Date: Tue, 8 Sep 2015 15:49:58 +0900
Message-ID: <CAAmzW4N+vrGcxx64B0t-7HXA7giyqRHbYcmRvnYLtw=_12AWPw@mail.gmail.com>
Subject: Re: [PATCH 07/12] mm, page_alloc: Distinguish between being unable to
 sleep, unwilling to sleep and avoiding waking kswapd
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2015-08-24 21:09 GMT+09:00 Mel Gorman <mgorman@techsingularity.net>:
> __GFP_WAIT has been used to identify atomic context in callers that hold
> spinlocks or are in interrupts. They are expected to be high priority and
> have access one of two watermarks lower than "min" which can be referred
> to as the "atomic reserve". __GFP_HIGH users get access to the first lower
> watermark and can be called the "high priority reserve".
>
> Over time, callers had a requirement to not block when fallback options
> were available. Some have abused __GFP_WAIT leading to a situation where
> an optimisitic allocation with a fallback option can access atomic reserves.
>
> This patch uses __GFP_ATOMIC to identify callers that are truely atomic,
> cannot sleep and have no alternative. High priority users continue to use
> __GFP_HIGH. __GFP_DIRECT_RECLAIM identifies callers that can sleep and are
> willing to enter direct reclaim. __GFP_KSWAPD_RECLAIM to identify callers
> that want to wake kswapd for background reclaim. __GFP_WAIT is redefined
> as a caller that is willing to enter direct reclaim and wake kswapd for
> background reclaim.

Hello, Mel.

I think that it is better to do one thing at one patch.
To distinguish real atomic, we just need to introduce __GFP_ATOMIC and
make GFP_ATOMIC to __GFP_ATOMIC | GFP_HARDER and change related
things. __GFP_WAIT changes isn't needed at all for this purpose. It can
reduce patch size and provides more good bisectability.

And, I don't think that introducing __GFP_KSWAPD_RECLAIM is good thing.
Basically, kswapd reclaim should be enforced. New flag makes user who manually
manipulate gfp flag more difficult. Without this change, your second hazard will
be disappeared although it is almost harmless.

And, I doubt that this big one shot change is preferable. AFAIK, even if changes
are one to one mapping and no functional difference, each one is made by
one patch and send it to correct maintainer. I guess there is some difficulty
in this patch to do like this, but, it could. Isn't it?

Some nitpicks are below.

>
> This patch then converts a number of sites
>
> o __GFP_ATOMIC is used by callers that are high priority and have memory
>   pools for those requests. GFP_ATOMIC uses this flag.
>
> o Callers that have a limited mempool to guarantee forward progress use
>   __GFP_DIRECT_RECLAIM. bio allocations fall into this category where
>   kswapd will still be woken but atomic reserves are not used as there
>   is a one-entry mempool to guarantee progress.
>
> o Callers that are checking if they are non-blocking should use the
>   helper gfpflags_allow_blocking() where possible. This is because
>   checking for __GFP_WAIT as was done historically now can trigger false
>   positives. Some exceptions like dm-crypt.c exist where the code intent
>   is clearer if __GFP_DIRECT_RECLAIM is used instead of the helper due to
>   flag manipulations.
>
> o Callers that built their own GFP flags instead of starting with GFP_KERNEL
>   and friends now also need to specify __GFP_KSWAPD_RECLAIM.
>
> The first key hazard to watch out for is callers that removed __GFP_WAIT
> and was depending on access to atomic reserves for inconspicuous reasons.
> In some cases it may be appropriate for them to use __GFP_HIGH.
>
> The second key hazard is callers that assembled their own combination of
> GFP flags instead of starting with something like GFP_KERNEL. They may
> now wish to specify __GFP_KSWAPD_RECLAIM. It's almost certainly harmless
> if it's missed in most cases as other activity will wake kswapd.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  Documentation/vm/balance                           | 14 ++++---
>  arch/arm/mm/dma-mapping.c                          |  4 +-
>  arch/arm/xen/mm.c                                  |  2 +-
>  arch/arm64/mm/dma-mapping.c                        |  4 +-
>  arch/x86/kernel/pci-dma.c                          |  2 +-
>  block/bio.c                                        | 26 ++++++------
>  block/blk-core.c                                   | 16 ++++----
>  block/blk-ioc.c                                    |  2 +-
>  block/blk-mq-tag.c                                 |  2 +-
>  block/blk-mq.c                                     |  8 ++--
>  block/cfq-iosched.c                                |  4 +-
>  drivers/block/drbd/drbd_receiver.c                 |  3 +-
>  drivers/block/osdblk.c                             |  2 +-
>  drivers/connector/connector.c                      |  3 +-
>  drivers/firewire/core-cdev.c                       |  2 +-
>  drivers/gpu/drm/i915/i915_gem.c                    |  2 +-
>  drivers/infiniband/core/sa_query.c                 |  2 +-
>  drivers/iommu/amd_iommu.c                          |  2 +-
>  drivers/iommu/intel-iommu.c                        |  2 +-
>  drivers/md/dm-crypt.c                              |  6 +--
>  drivers/md/dm-kcopyd.c                             |  2 +-
>  drivers/media/pci/solo6x10/solo6x10-v4l2-enc.c     |  2 +-
>  drivers/media/pci/solo6x10/solo6x10-v4l2.c         |  2 +-
>  drivers/media/pci/tw68/tw68-video.c                |  2 +-
>  drivers/mtd/mtdcore.c                              |  3 +-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |  2 +-
>  drivers/staging/android/ion/ion_system_heap.c      |  2 +-
>  .../lustre/include/linux/libcfs/libcfs_private.h   |  2 +-
>  drivers/usb/host/u132-hcd.c                        |  2 +-
>  drivers/video/fbdev/vermilion/vermilion.c          |  2 +-
>  fs/btrfs/disk-io.c                                 |  2 +-
>  fs/btrfs/extent_io.c                               | 14 +++----
>  fs/btrfs/volumes.c                                 |  4 +-
>  fs/ext3/super.c                                    |  2 +-
>  fs/ext4/super.c                                    |  2 +-
>  fs/fscache/cookie.c                                |  2 +-
>  fs/fscache/page.c                                  |  6 +--
>  fs/jbd/transaction.c                               |  4 +-
>  fs/jbd2/transaction.c                              |  4 +-
>  fs/nfs/file.c                                      |  6 +--
>  fs/xfs/xfs_qm.c                                    |  2 +-
>  include/linux/gfp.h                                | 46 ++++++++++++++++------
>  include/linux/skbuff.h                             |  6 +--
>  include/net/sock.h                                 |  2 +-
>  include/trace/events/gfpflags.h                    |  5 ++-
>  kernel/audit.c                                     |  6 +--
>  kernel/locking/lockdep.c                           |  2 +-
>  kernel/power/snapshot.c                            |  2 +-
>  kernel/smp.c                                       |  2 +-
>  lib/idr.c                                          |  4 +-
>  lib/radix-tree.c                                   | 10 ++---
>  mm/backing-dev.c                                   |  2 +-
>  mm/dmapool.c                                       |  2 +-
>  mm/memcontrol.c                                    |  8 ++--
>  mm/mempool.c                                       | 10 ++---
>  mm/migrate.c                                       |  2 +-
>  mm/page_alloc.c                                    | 43 ++++++++++++--------
>  mm/slab.c                                          | 18 ++++-----
>  mm/slub.c                                          |  6 +--
>  mm/vmalloc.c                                       |  2 +-
>  mm/vmscan.c                                        |  4 +-
>  mm/zswap.c                                         |  5 ++-
>  net/core/skbuff.c                                  |  8 ++--
>  net/core/sock.c                                    |  6 ++-
>  net/netlink/af_netlink.c                           |  2 +-
>  net/rxrpc/ar-connection.c                          |  2 +-
>  net/sctp/associola.c                               |  2 +-
>  67 files changed, 211 insertions(+), 173 deletions(-)
>
> diff --git a/Documentation/vm/balance b/Documentation/vm/balance
> index c46e68cf9344..964595481af6 100644
> --- a/Documentation/vm/balance
> +++ b/Documentation/vm/balance
> @@ -1,12 +1,14 @@
>  Started Jan 2000 by Kanoj Sarcar <kanoj@sgi.com>
>
> -Memory balancing is needed for non __GFP_WAIT as well as for non
> -__GFP_IO allocations.
> +Memory balancing is needed for !__GFP_ATOMIC and !__GFP_KSWAPD_RECLAIM as
> +well as for non __GFP_IO allocations.
>
> -There are two reasons to be requesting non __GFP_WAIT allocations:
> -the caller can not sleep (typically intr context), or does not want
> -to incur cost overheads of page stealing and possible swap io for
> -whatever reasons.
> +The first reason why a caller may avoid reclaim is that the caller can not
> +sleep due to holding a spinlock or is in interrupt context. The second may
> +be that the caller is willing to fail the allocation without incurring the
> +overhead of page reclaim. This may happen for opportunistic high-order
> +allocation requests that have order-0 fallback options. In such cases,
> +the caller may also wish to avoid waking kswapd.
>
>  __GFP_IO allocation requests are made to prevent file system deadlocks.
>
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index cba12f34ff77..f999f0987a3e 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -650,7 +650,7 @@ static void *__dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
>
>         if (is_coherent || nommu())
>                 addr = __alloc_simple_buffer(dev, size, gfp, &page);
> -       else if (!(gfp & __GFP_WAIT))
> +       else if (!gfpflags_allow_blocking(gfp))
>                 addr = __alloc_from_pool(size, &page);
>         else if (!dev_get_cma_area(dev))
>                 addr = __alloc_remap_buffer(dev, size, gfp, prot, &page, caller, want_vaddr);
> @@ -1369,7 +1369,7 @@ static void *arm_iommu_alloc_attrs(struct device *dev, size_t size,
>         *handle = DMA_ERROR_CODE;
>         size = PAGE_ALIGN(size);
>
> -       if (!(gfp & __GFP_WAIT))
> +       if (!gfpflags_allow_blocking(gfp))
>                 return __iommu_alloc_atomic(dev, size, handle);
>
>         /*
> diff --git a/arch/arm/xen/mm.c b/arch/arm/xen/mm.c
> index 03e75fef15b8..86809bd2026d 100644
> --- a/arch/arm/xen/mm.c
> +++ b/arch/arm/xen/mm.c
> @@ -25,7 +25,7 @@
>  unsigned long xen_get_swiotlb_free_pages(unsigned int order)
>  {
>         struct memblock_region *reg;
> -       gfp_t flags = __GFP_NOWARN;
> +       gfp_t flags = __GFP_NOWARN|___GFP_KSWAPD_RECLAIM;

Please use __XXX rather than ___XXX.

>         for_each_memblock(memory, reg) {
>                 if (reg->base < (phys_addr_t)0xffffffff) {
> diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
> index d16a1cead23f..1f10b2503af8 100644
> --- a/arch/arm64/mm/dma-mapping.c
> +++ b/arch/arm64/mm/dma-mapping.c
> @@ -100,7 +100,7 @@ static void *__dma_alloc_coherent(struct device *dev, size_t size,
>         if (IS_ENABLED(CONFIG_ZONE_DMA) &&
>             dev->coherent_dma_mask <= DMA_BIT_MASK(32))
>                 flags |= GFP_DMA;
> -       if (IS_ENABLED(CONFIG_DMA_CMA) && (flags & __GFP_WAIT)) {
> +       if (IS_ENABLED(CONFIG_DMA_CMA) && gfpflags_allow_blocking(flags)) {
>                 struct page *page;
>                 void *addr;
>
> @@ -147,7 +147,7 @@ static void *__dma_alloc(struct device *dev, size_t size,
>
>         size = PAGE_ALIGN(size);
>
> -       if (!coherent && !(flags & __GFP_WAIT)) {
> +       if (!coherent && !gfpflags_allow_blocking(flags)) {
>                 struct page *page = NULL;
>                 void *addr = __alloc_from_pool(size, &page, flags);
>
> diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
> index 353972c1946c..0310e73e6b57 100644
> --- a/arch/x86/kernel/pci-dma.c
> +++ b/arch/x86/kernel/pci-dma.c
> @@ -101,7 +101,7 @@ void *dma_generic_alloc_coherent(struct device *dev, size_t size,
>  again:
>         page = NULL;
>         /* CMA can be used only in the context which permits sleeping */
> -       if (flag & __GFP_WAIT) {
> +       if (gfpflags_allow_blocking(flag)) {
>                 page = dma_alloc_from_contiguous(dev, count, get_order(size));
>                 if (page && page_to_phys(page) + size > dma_mask) {
>                         dma_release_from_contiguous(dev, page, count);
> diff --git a/block/bio.c b/block/bio.c
> index d6e5ba3399f0..fbc558b50e67 100644
> --- a/block/bio.c
> +++ b/block/bio.c
> @@ -211,7 +211,7 @@ struct bio_vec *bvec_alloc(gfp_t gfp_mask, int nr, unsigned long *idx,
>                 bvl = mempool_alloc(pool, gfp_mask);
>         } else {
>                 struct biovec_slab *bvs = bvec_slabs + *idx;
> -               gfp_t __gfp_mask = gfp_mask & ~(__GFP_WAIT | __GFP_IO);
> +               gfp_t __gfp_mask = gfp_mask & ~(__GFP_DIRECT_RECLAIM | __GFP_IO);
>
>                 /*
>                  * Make this allocation restricted and don't dump info on
> @@ -221,11 +221,11 @@ struct bio_vec *bvec_alloc(gfp_t gfp_mask, int nr, unsigned long *idx,
>                 __gfp_mask |= __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN;
>
>                 /*
> -                * Try a slab allocation. If this fails and __GFP_WAIT
> +                * Try a slab allocation. If this fails and __GFP_DIRECT_RECLAIM
>                  * is set, retry with the 1-entry mempool
>                  */
>                 bvl = kmem_cache_alloc(bvs->slab, __gfp_mask);
> -               if (unlikely(!bvl && (gfp_mask & __GFP_WAIT))) {
> +               if (unlikely(!bvl && (gfp_mask & __GFP_DIRECT_RECLAIM))) {
>                         *idx = BIOVEC_MAX_IDX;
>                         goto fallback;
>                 }
> @@ -393,12 +393,12 @@ static void punt_bios_to_rescuer(struct bio_set *bs)
>   *   If @bs is NULL, uses kmalloc() to allocate the bio; else the allocation is
>   *   backed by the @bs's mempool.
>   *
> - *   When @bs is not NULL, if %__GFP_WAIT is set then bio_alloc will always be
> - *   able to allocate a bio. This is due to the mempool guarantees. To make this
> - *   work, callers must never allocate more than 1 bio at a time from this pool.
> - *   Callers that need to allocate more than 1 bio must always submit the
> - *   previously allocated bio for IO before attempting to allocate a new one.
> - *   Failure to do so can cause deadlocks under memory pressure.
> + *   When @bs is not NULL, if %__GFP_DIRECT_RECLAIM is set then bio_alloc will
> + *   always be able to allocate a bio. This is due to the mempool guarantees.
> + *   To make this work, callers must never allocate more than 1 bio at a time
> + *   from this pool. Callers that need to allocate more than 1 bio must always
> + *   submit the previously allocated bio for IO before attempting to allocate
> + *   a new one. Failure to do so can cause deadlocks under memory pressure.
>   *
>   *   Note that when running under generic_make_request() (i.e. any block
>   *   driver), bios are not submitted until after you return - see the code in
> @@ -457,13 +457,13 @@ struct bio *bio_alloc_bioset(gfp_t gfp_mask, int nr_iovecs, struct bio_set *bs)
>                  * We solve this, and guarantee forward progress, with a rescuer
>                  * workqueue per bio_set. If we go to allocate and there are
>                  * bios on current->bio_list, we first try the allocation
> -                * without __GFP_WAIT; if that fails, we punt those bios we
> -                * would be blocking to the rescuer workqueue before we retry
> -                * with the original gfp_flags.
> +                * without __GFP_DIRECT_RECLAIM; if that fails, we punt those
> +                * bios we would be blocking to the rescuer workqueue before
> +                * we retry with the original gfp_flags.
>                  */
>
>                 if (current->bio_list && !bio_list_empty(current->bio_list))
> -                       gfp_mask &= ~__GFP_WAIT;
> +                       gfp_mask &= ~__GFP_DIRECT_RECLAIM;

How about introduce helper function to mask out __GFP_DIRECT_RECLAIM?
It can be used many places.

>                 p = mempool_alloc(bs->bio_pool, gfp_mask);
>                 if (!p && gfp_mask != saved_gfp) {
> diff --git a/block/blk-core.c b/block/blk-core.c
> index 627ed0c593fb..e3605acaaffc 100644
> --- a/block/blk-core.c
> +++ b/block/blk-core.c
> @@ -1156,8 +1156,8 @@ static struct request *__get_request(struct request_list *rl, int rw_flags,
>   * @bio: bio to allocate request for (can be %NULL)
>   * @gfp_mask: allocation mask
>   *
> - * Get a free request from @q.  If %__GFP_WAIT is set in @gfp_mask, this
> - * function keeps retrying under memory pressure and fails iff @q is dead.
> + * Get a free request from @q.  If %__GFP_DIRECT_RECLAIM is set in @gfp_mask,
> + * this function keeps retrying under memory pressure and fails iff @q is dead.
>   *
>   * Must be called with @q->queue_lock held and,
>   * Returns ERR_PTR on failure, with @q->queue_lock held.
> @@ -1177,7 +1177,7 @@ static struct request *get_request(struct request_queue *q, int rw_flags,
>         if (!IS_ERR(rq))
>                 return rq;
>
> -       if (!(gfp_mask & __GFP_WAIT) || unlikely(blk_queue_dying(q))) {
> +       if (!gfpflags_allow_blocking(gfp_mask) || unlikely(blk_queue_dying(q))) {
>                 blk_put_rl(rl);
>                 return rq;
>         }
> @@ -1255,11 +1255,11 @@ EXPORT_SYMBOL(blk_get_request);
>   * BUG.
>   *
>   * WARNING: When allocating/cloning a bio-chain, careful consideration should be
> - * given to how you allocate bios. In particular, you cannot use __GFP_WAIT for
> - * anything but the first bio in the chain. Otherwise you risk waiting for IO
> - * completion of a bio that hasn't been submitted yet, thus resulting in a
> - * deadlock. Alternatively bios should be allocated using bio_kmalloc() instead
> - * of bio_alloc(), as that avoids the mempool deadlock.
> + * given to how you allocate bios. In particular, you cannot use
> + * __GFP_DIRECT_RECLAIM for anything but the first bio in the chain. Otherwise
> + * you risk waiting for IO completion of a bio that hasn't been submitted yet,
> + * thus resulting in a deadlock. Alternatively bios should be allocated using
> + * bio_kmalloc() instead of bio_alloc(), as that avoids the mempool deadlock.
>   * If possible a big IO should be split into smaller parts when allocation
>   * fails. Partial allocation should not be an error, or you risk a live-lock.
>   */
> diff --git a/block/blk-ioc.c b/block/blk-ioc.c
> index 1a27f45ec776..381cb50a673c 100644
> --- a/block/blk-ioc.c
> +++ b/block/blk-ioc.c
> @@ -289,7 +289,7 @@ struct io_context *get_task_io_context(struct task_struct *task,
>  {
>         struct io_context *ioc;
>
> -       might_sleep_if(gfp_flags & __GFP_WAIT);
> +       might_sleep_if(gfpflags_allow_blocking(gfp_flags));
>
>         do {
>                 task_lock(task);
> diff --git a/block/blk-mq-tag.c b/block/blk-mq-tag.c
> index 9b6e28830b82..a8b46659ce4e 100644
> --- a/block/blk-mq-tag.c
> +++ b/block/blk-mq-tag.c
> @@ -264,7 +264,7 @@ static int bt_get(struct blk_mq_alloc_data *data,
>         if (tag != -1)
>                 return tag;
>
> -       if (!(data->gfp & __GFP_WAIT))
> +       if (!gfpflags_allow_blocking(data->gfp))
>                 return -1;
>
>         bs = bt_wait_ptr(bt, hctx);
> diff --git a/block/blk-mq.c b/block/blk-mq.c
> index 7d842db59699..7d80379d7a38 100644
> --- a/block/blk-mq.c
> +++ b/block/blk-mq.c
> @@ -85,7 +85,7 @@ static int blk_mq_queue_enter(struct request_queue *q, gfp_t gfp)
>                 if (percpu_ref_tryget_live(&q->mq_usage_counter))
>                         return 0;
>
> -               if (!(gfp & __GFP_WAIT))
> +               if (!gfpflags_allow_blocking(gfp))
>                         return -EBUSY;
>
>                 ret = wait_event_interruptible(q->mq_freeze_wq,
> @@ -261,11 +261,11 @@ struct request *blk_mq_alloc_request(struct request_queue *q, int rw, gfp_t gfp,
>
>         ctx = blk_mq_get_ctx(q);
>         hctx = q->mq_ops->map_queue(q, ctx->cpu);
> -       blk_mq_set_alloc_data(&alloc_data, q, gfp & ~__GFP_WAIT,
> +       blk_mq_set_alloc_data(&alloc_data, q, gfp & ~__GFP_DIRECT_RECLAIM,
>                         reserved, ctx, hctx);
>
>         rq = __blk_mq_alloc_request(&alloc_data, rw);
> -       if (!rq && (gfp & __GFP_WAIT)) {
> +       if (!rq && (gfp & __GFP_DIRECT_RECLAIM)) {
>                 __blk_mq_run_hw_queue(hctx);
>                 blk_mq_put_ctx(ctx);

Is there any reason not to use gfpflags_allow_nonblocking() here?
There are some places not using this helper and reason isn't
specified.

Thanks.

> @@ -1221,7 +1221,7 @@ static struct request *blk_mq_map_request(struct request_queue *q,
>                 ctx = blk_mq_get_ctx(q);
>                 hctx = q->mq_ops->map_queue(q, ctx->cpu);
>                 blk_mq_set_alloc_data(&alloc_data, q,
> -                               __GFP_WAIT|GFP_ATOMIC, false, ctx, hctx);
> +                               __GFP_WAIT|__GFP_HIGH, false, ctx, hctx);
>                 rq = __blk_mq_alloc_request(&alloc_data, rw);
>                 ctx = alloc_data.ctx;
>                 hctx = alloc_data.hctx;
> diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
> index c62bb2e650b8..ecd1d1b61382 100644
> --- a/block/cfq-iosched.c
> +++ b/block/cfq-iosched.c
> @@ -3674,7 +3674,7 @@ cfq_find_alloc_queue(struct cfq_data *cfqd, bool is_sync, struct cfq_io_cq *cic,
>                 if (new_cfqq) {
>                         cfqq = new_cfqq;
>                         new_cfqq = NULL;
> -               } else if (gfp_mask & __GFP_WAIT) {
> +               } else if (gfpflags_allow_blocking(gfp_mask)) {
>                         rcu_read_unlock();
>                         spin_unlock_irq(cfqd->queue->queue_lock);
>                         new_cfqq = kmem_cache_alloc_node(cfq_pool,
> @@ -4289,7 +4289,7 @@ cfq_set_request(struct request_queue *q, struct request *rq, struct bio *bio,
>         const bool is_sync = rq_is_sync(rq);
>         struct cfq_queue *cfqq;
>
> -       might_sleep_if(gfp_mask & __GFP_WAIT);
> +       might_sleep_if(gfpflags_allow_blocking(gfp_mask));
>
>         spin_lock_irq(q->queue_lock);
>
> diff --git a/drivers/block/drbd/drbd_receiver.c b/drivers/block/drbd/drbd_receiver.c
> index c097909c589c..b4b5680ac6ad 100644
> --- a/drivers/block/drbd/drbd_receiver.c
> +++ b/drivers/block/drbd/drbd_receiver.c
> @@ -357,7 +357,8 @@ drbd_alloc_peer_req(struct drbd_peer_device *peer_device, u64 id, sector_t secto
>         }
>
>         if (has_payload && data_size) {
> -               page = drbd_alloc_pages(peer_device, nr_pages, (gfp_mask & __GFP_WAIT));
> +               page = drbd_alloc_pages(peer_device, nr_pages,
> +                                       gfpflags_allow_blocking(gfp_mask));
>                 if (!page)
>                         goto fail;
>         }
> diff --git a/drivers/block/osdblk.c b/drivers/block/osdblk.c
> index e22942596207..1b709a4e3b5e 100644
> --- a/drivers/block/osdblk.c
> +++ b/drivers/block/osdblk.c
> @@ -271,7 +271,7 @@ static struct bio *bio_chain_clone(struct bio *old_chain, gfp_t gfpmask)
>                         goto err_out;
>
>                 tmp->bi_bdev = NULL;
> -               gfpmask &= ~__GFP_WAIT;
> +               gfpmask &= ~__GFP_DIRECT_RECLAIM;
>                 tmp->bi_next = NULL;
>
>                 if (!new_chain)
> diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
> index 30f522848c73..d7373ca69c99 100644
> --- a/drivers/connector/connector.c
> +++ b/drivers/connector/connector.c
> @@ -124,7 +124,8 @@ int cn_netlink_send_mult(struct cn_msg *msg, u16 len, u32 portid, u32 __group,
>         if (group)
>                 return netlink_broadcast(dev->nls, skb, portid, group,
>                                          gfp_mask);
> -       return netlink_unicast(dev->nls, skb, portid, !(gfp_mask&__GFP_WAIT));
> +       return netlink_unicast(dev->nls, skb, portid,
> +                       !gfpflags_allow_blocking(gfp_mask));
>  }
>  EXPORT_SYMBOL_GPL(cn_netlink_send_mult);
>
> diff --git a/drivers/firewire/core-cdev.c b/drivers/firewire/core-cdev.c
> index 2a3973a7c441..36a7c2d89a01 100644
> --- a/drivers/firewire/core-cdev.c
> +++ b/drivers/firewire/core-cdev.c
> @@ -486,7 +486,7 @@ static int ioctl_get_info(struct client *client, union ioctl_arg *arg)
>  static int add_client_resource(struct client *client,
>                                struct client_resource *resource, gfp_t gfp_mask)
>  {
> -       bool preload = !!(gfp_mask & __GFP_WAIT);
> +       bool preload = gfpflags_allow_blocking(gfp_mask);
>         unsigned long flags;
>         int ret;
>
> diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
> index 52b446b27b4d..c2b45081c5ab 100644
> --- a/drivers/gpu/drm/i915/i915_gem.c
> +++ b/drivers/gpu/drm/i915/i915_gem.c
> @@ -2225,7 +2225,7 @@ i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
>          */
>         mapping = file_inode(obj->base.filp)->i_mapping;
>         gfp = mapping_gfp_mask(mapping);
> -       gfp |= __GFP_NORETRY | __GFP_NOWARN | __GFP_NO_KSWAPD;
> +       gfp |= __GFP_NORETRY | __GFP_NOWARN;
>         gfp &= ~(__GFP_IO | __GFP_WAIT);
>         sg = st->sgl;
>         st->nents = 0;
> diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core/sa_query.c
> index ca919f429666..7474d79ffac0 100644
> --- a/drivers/infiniband/core/sa_query.c
> +++ b/drivers/infiniband/core/sa_query.c
> @@ -619,7 +619,7 @@ static void init_mad(struct ib_sa_mad *mad, struct ib_mad_agent *agent)
>
>  static int send_mad(struct ib_sa_query *query, int timeout_ms, gfp_t gfp_mask)
>  {
> -       bool preload = !!(gfp_mask & __GFP_WAIT);
> +       bool preload = gfpflags_allow_blocking(gfp_mask);
>         unsigned long flags;
>         int ret, id;
>
> diff --git a/drivers/iommu/amd_iommu.c b/drivers/iommu/amd_iommu.c
> index 658ee39e6569..95d4c70dc7b1 100644
> --- a/drivers/iommu/amd_iommu.c
> +++ b/drivers/iommu/amd_iommu.c
> @@ -2755,7 +2755,7 @@ static void *alloc_coherent(struct device *dev, size_t size,
>
>         page = alloc_pages(flag | __GFP_NOWARN,  get_order(size));
>         if (!page) {
> -               if (!(flag & __GFP_WAIT))
> +               if (!gfpflags_allow_blocking(flag))
>                         return NULL;
>
>                 page = dma_alloc_from_contiguous(dev, size >> PAGE_SHIFT,
> diff --git a/drivers/iommu/intel-iommu.c b/drivers/iommu/intel-iommu.c
> index 0649b94f5958..f77becf3d8d8 100644
> --- a/drivers/iommu/intel-iommu.c
> +++ b/drivers/iommu/intel-iommu.c
> @@ -3566,7 +3566,7 @@ static void *intel_alloc_coherent(struct device *dev, size_t size,
>                         flags |= GFP_DMA32;
>         }
>
> -       if (flags & __GFP_WAIT) {
> +       if (gfpflags_allow_blocking(flags)) {
>                 unsigned int count = size >> PAGE_SHIFT;
>
>                 page = dma_alloc_from_contiguous(dev, count, order);
> diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
> index 0f48fed44a17..6dda08385309 100644
> --- a/drivers/md/dm-crypt.c
> +++ b/drivers/md/dm-crypt.c
> @@ -993,7 +993,7 @@ static struct bio *crypt_alloc_buffer(struct dm_crypt_io *io, unsigned size)
>         struct bio_vec *bvec;
>
>  retry:
> -       if (unlikely(gfp_mask & __GFP_WAIT))
> +       if (unlikely(gfp_mask & __GFP_DIRECT_RECLAIM))
>                 mutex_lock(&cc->bio_alloc_lock);
>
>         clone = bio_alloc_bioset(GFP_NOIO, nr_iovecs, cc->bs);
> @@ -1009,7 +1009,7 @@ static struct bio *crypt_alloc_buffer(struct dm_crypt_io *io, unsigned size)
>                 if (!page) {
>                         crypt_free_buffer_pages(cc, clone);
>                         bio_put(clone);
> -                       gfp_mask |= __GFP_WAIT;
> +                       gfp_mask |= __GFP_DIRECT_RECLAIM;
>                         goto retry;
>                 }
>
> @@ -1026,7 +1026,7 @@ static struct bio *crypt_alloc_buffer(struct dm_crypt_io *io, unsigned size)
>         }
>
>  return_clone:
> -       if (unlikely(gfp_mask & __GFP_WAIT))
> +       if (unlikely(gfp_mask & __GFP_DIRECT_RECLAIM))
>                 mutex_unlock(&cc->bio_alloc_lock);
>
>         return clone;
> diff --git a/drivers/md/dm-kcopyd.c b/drivers/md/dm-kcopyd.c
> index 3a7cade5e27d..1452ed9aacb4 100644
> --- a/drivers/md/dm-kcopyd.c
> +++ b/drivers/md/dm-kcopyd.c
> @@ -244,7 +244,7 @@ static int kcopyd_get_pages(struct dm_kcopyd_client *kc,
>         *pages = NULL;
>
>         do {
> -               pl = alloc_pl(__GFP_NOWARN | __GFP_NORETRY);
> +               pl = alloc_pl(__GFP_NOWARN | __GFP_NORETRY | __GFP_KSWAPD_RECLAIM);
>                 if (unlikely(!pl)) {
>                         /* Use reserved pages */
>                         pl = kc->pages;
> diff --git a/drivers/media/pci/solo6x10/solo6x10-v4l2-enc.c b/drivers/media/pci/solo6x10/solo6x10-v4l2-enc.c
> index 53fff5425c13..fb2cb4bdc0c1 100644
> --- a/drivers/media/pci/solo6x10/solo6x10-v4l2-enc.c
> +++ b/drivers/media/pci/solo6x10/solo6x10-v4l2-enc.c
> @@ -1291,7 +1291,7 @@ static struct solo_enc_dev *solo_enc_alloc(struct solo_dev *solo_dev,
>         solo_enc->vidq.ops = &solo_enc_video_qops;
>         solo_enc->vidq.mem_ops = &vb2_dma_sg_memops;
>         solo_enc->vidq.drv_priv = solo_enc;
> -       solo_enc->vidq.gfp_flags = __GFP_DMA32;
> +       solo_enc->vidq.gfp_flags = __GFP_DMA32 | __GFP_KSWAPD_RECLAIM;
>         solo_enc->vidq.timestamp_flags = V4L2_BUF_FLAG_TIMESTAMP_MONOTONIC;
>         solo_enc->vidq.buf_struct_size = sizeof(struct solo_vb2_buf);
>         solo_enc->vidq.lock = &solo_enc->lock;
> diff --git a/drivers/media/pci/solo6x10/solo6x10-v4l2.c b/drivers/media/pci/solo6x10/solo6x10-v4l2.c
> index 63ae8a61f603..bde77b22340c 100644
> --- a/drivers/media/pci/solo6x10/solo6x10-v4l2.c
> +++ b/drivers/media/pci/solo6x10/solo6x10-v4l2.c
> @@ -675,7 +675,7 @@ int solo_v4l2_init(struct solo_dev *solo_dev, unsigned nr)
>         solo_dev->vidq.mem_ops = &vb2_dma_contig_memops;
>         solo_dev->vidq.drv_priv = solo_dev;
>         solo_dev->vidq.timestamp_flags = V4L2_BUF_FLAG_TIMESTAMP_MONOTONIC;
> -       solo_dev->vidq.gfp_flags = __GFP_DMA32;
> +       solo_dev->vidq.gfp_flags = __GFP_DMA32 | __GFP_KSWAPD_RECLAIM;
>         solo_dev->vidq.buf_struct_size = sizeof(struct solo_vb2_buf);
>         solo_dev->vidq.lock = &solo_dev->lock;
>         ret = vb2_queue_init(&solo_dev->vidq);
> diff --git a/drivers/media/pci/tw68/tw68-video.c b/drivers/media/pci/tw68/tw68-video.c
> index 8355e55b4e8e..e556f989aaab 100644
> --- a/drivers/media/pci/tw68/tw68-video.c
> +++ b/drivers/media/pci/tw68/tw68-video.c
> @@ -975,7 +975,7 @@ int tw68_video_init2(struct tw68_dev *dev, int video_nr)
>         dev->vidq.ops = &tw68_video_qops;
>         dev->vidq.mem_ops = &vb2_dma_sg_memops;
>         dev->vidq.drv_priv = dev;
> -       dev->vidq.gfp_flags = __GFP_DMA32;
> +       dev->vidq.gfp_flags = __GFP_DMA32 | __GFP_KSWAPD_RECLAIM;
>         dev->vidq.buf_struct_size = sizeof(struct tw68_buf);
>         dev->vidq.lock = &dev->lock;
>         dev->vidq.min_buffers_needed = 2;
> diff --git a/drivers/mtd/mtdcore.c b/drivers/mtd/mtdcore.c
> index 8bbbb751bf45..2dfb291a47c6 100644
> --- a/drivers/mtd/mtdcore.c
> +++ b/drivers/mtd/mtdcore.c
> @@ -1188,8 +1188,7 @@ EXPORT_SYMBOL_GPL(mtd_writev);
>   */
>  void *mtd_kmalloc_up_to(const struct mtd_info *mtd, size_t *size)
>  {
> -       gfp_t flags = __GFP_NOWARN | __GFP_WAIT |
> -                      __GFP_NORETRY | __GFP_NO_KSWAPD;
> +       gfp_t flags = __GFP_NOWARN | __GFP_DIRECT_RECLAIM | __GFP_NORETRY;
>         size_t min_alloc = max_t(size_t, mtd->writesize, PAGE_SIZE);
>         void *kbuf;
>
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> index f7fbdc9d1325..3a407e59acab 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> @@ -689,7 +689,7 @@ static void *bnx2x_frag_alloc(const struct bnx2x_fastpath *fp, gfp_t gfp_mask)
>  {
>         if (fp->rx_frag_size) {
>                 /* GFP_KERNEL allocations are used only during initialization */
> -               if (unlikely(gfp_mask & __GFP_WAIT))
> +               if (unlikely(gfpflags_allow_blocking(gfp_mask)))
>                         return (void *)__get_free_page(gfp_mask);
>
>                 return netdev_alloc_frag(fp->rx_frag_size);
> diff --git a/drivers/staging/android/ion/ion_system_heap.c b/drivers/staging/android/ion/ion_system_heap.c
> index da2a63c0a9ba..2615e0ae4f0a 100644
> --- a/drivers/staging/android/ion/ion_system_heap.c
> +++ b/drivers/staging/android/ion/ion_system_heap.c
> @@ -27,7 +27,7 @@
>  #include "ion_priv.h"
>
>  static gfp_t high_order_gfp_flags = (GFP_HIGHUSER | __GFP_ZERO | __GFP_NOWARN |
> -                                    __GFP_NORETRY) & ~__GFP_WAIT;
> +                                    __GFP_NORETRY) & ~__GFP_DIRECT_RECLAIM;
>  static gfp_t low_order_gfp_flags  = (GFP_HIGHUSER | __GFP_ZERO | __GFP_NOWARN);
>  static const unsigned int orders[] = {8, 4, 0};
>  static const int num_orders = ARRAY_SIZE(orders);
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> index ed37d26eb20d..5b0756cb6576 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> @@ -113,7 +113,7 @@ do {                                                \
>  do {                                                                       \
>         LASSERT(!in_interrupt() ||                                          \
>                 ((size) <= LIBCFS_VMALLOC_SIZE &&                           \
> -                ((mask) & __GFP_WAIT) == 0));                              \
> +                !gfpflags_allow_blocking(mask)));                          \
>  } while (0)
>
>  #define LIBCFS_ALLOC_POST(ptr, size)                                       \
> diff --git a/drivers/usb/host/u132-hcd.c b/drivers/usb/host/u132-hcd.c
> index d51687780b61..8d4c1806e32f 100644
> --- a/drivers/usb/host/u132-hcd.c
> +++ b/drivers/usb/host/u132-hcd.c
> @@ -2247,7 +2247,7 @@ static int u132_urb_enqueue(struct usb_hcd *hcd, struct urb *urb,
>  {
>         struct u132 *u132 = hcd_to_u132(hcd);
>         if (irqs_disabled()) {
> -               if (__GFP_WAIT & mem_flags) {
> +               if (gfpflags_allow_blocking(mem_flags)) {
>                         printk(KERN_ERR "invalid context for function that migh"
>                                 "t sleep\n");
>                         return -EINVAL;
> diff --git a/drivers/video/fbdev/vermilion/vermilion.c b/drivers/video/fbdev/vermilion/vermilion.c
> index 6b70d7f62b2f..1c1e95a0b8fa 100644
> --- a/drivers/video/fbdev/vermilion/vermilion.c
> +++ b/drivers/video/fbdev/vermilion/vermilion.c
> @@ -99,7 +99,7 @@ static int vmlfb_alloc_vram_area(struct vram_area *va, unsigned max_order,
>                  * below the first 16MB.
>                  */
>
> -               flags = __GFP_DMA | __GFP_HIGH;
> +               flags = __GFP_DMA | __GFP_HIGH | __GFP_KSWAPD_RECLAIM;
>                 va->logical =
>                          __get_free_pages(flags, --max_order);
>         } while (va->logical == 0 && max_order > min_order);
> diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
> index f556c3732c2c..3dd4792b8099 100644
> --- a/fs/btrfs/disk-io.c
> +++ b/fs/btrfs/disk-io.c
> @@ -2566,7 +2566,7 @@ int open_ctree(struct super_block *sb,
>         fs_info->commit_interval = BTRFS_DEFAULT_COMMIT_INTERVAL;
>         fs_info->avg_delayed_ref_runtime = NSEC_PER_SEC >> 6; /* div by 64 */
>         /* readahead state */
> -       INIT_RADIX_TREE(&fs_info->reada_tree, GFP_NOFS & ~__GFP_WAIT);
> +       INIT_RADIX_TREE(&fs_info->reada_tree, GFP_NOFS & ~__GFP_DIRECT_RECLAIM);
>         spin_lock_init(&fs_info->reada_lock);
>
>         fs_info->thread_pool_size = min_t(unsigned long,
> diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
> index 02d05817cbdf..c8a6cdcbef2b 100644
> --- a/fs/btrfs/extent_io.c
> +++ b/fs/btrfs/extent_io.c
> @@ -594,7 +594,7 @@ int clear_extent_bit(struct extent_io_tree *tree, u64 start, u64 end,
>         if (bits & (EXTENT_IOBITS | EXTENT_BOUNDARY))
>                 clear = 1;
>  again:
> -       if (!prealloc && (mask & __GFP_WAIT)) {
> +       if (!prealloc && gfpflags_allow_blocking(mask)) {
>                 /*
>                  * Don't care for allocation failure here because we might end
>                  * up not needing the pre-allocated extent state at all, which
> @@ -718,7 +718,7 @@ int clear_extent_bit(struct extent_io_tree *tree, u64 start, u64 end,
>         if (start > end)
>                 goto out;
>         spin_unlock(&tree->lock);
> -       if (mask & __GFP_WAIT)
> +       if (gfpflags_allow_blocking(mask))
>                 cond_resched();
>         goto again;
>  }
> @@ -850,7 +850,7 @@ __set_extent_bit(struct extent_io_tree *tree, u64 start, u64 end,
>
>         bits |= EXTENT_FIRST_DELALLOC;
>  again:
> -       if (!prealloc && (mask & __GFP_WAIT)) {
> +       if (!prealloc && gfpflags_allow_blocking(mask)) {
>                 prealloc = alloc_extent_state(mask);
>                 BUG_ON(!prealloc);
>         }
> @@ -1028,7 +1028,7 @@ __set_extent_bit(struct extent_io_tree *tree, u64 start, u64 end,
>         if (start > end)
>                 goto out;
>         spin_unlock(&tree->lock);
> -       if (mask & __GFP_WAIT)
> +       if (gfpflags_allow_blocking(mask))
>                 cond_resched();
>         goto again;
>  }
> @@ -1076,7 +1076,7 @@ int convert_extent_bit(struct extent_io_tree *tree, u64 start, u64 end,
>         btrfs_debug_check_extent_io_range(tree, start, end);
>
>  again:
> -       if (!prealloc && (mask & __GFP_WAIT)) {
> +       if (!prealloc && gfpflags_allow_blocking(mask)) {
>                 /*
>                  * Best effort, don't worry if extent state allocation fails
>                  * here for the first iteration. We might have a cached state
> @@ -1253,7 +1253,7 @@ int convert_extent_bit(struct extent_io_tree *tree, u64 start, u64 end,
>         if (start > end)
>                 goto out;
>         spin_unlock(&tree->lock);
> -       if (mask & __GFP_WAIT)
> +       if (gfpflags_allow_blocking(mask))
>                 cond_resched();
>         first_iteration = false;
>         goto again;
> @@ -4265,7 +4265,7 @@ int try_release_extent_mapping(struct extent_map_tree *map,
>         u64 start = page_offset(page);
>         u64 end = start + PAGE_CACHE_SIZE - 1;
>
> -       if ((mask & __GFP_WAIT) &&
> +       if (gfpflags_allow_blocking(mask) &&
>             page->mapping->host->i_size > 16 * 1024 * 1024) {
>                 u64 len;
>                 while (start <= end) {
> diff --git a/fs/btrfs/volumes.c b/fs/btrfs/volumes.c
> index fbe7c104531c..b1968f36a39b 100644
> --- a/fs/btrfs/volumes.c
> +++ b/fs/btrfs/volumes.c
> @@ -156,8 +156,8 @@ static struct btrfs_device *__alloc_device(void)
>         spin_lock_init(&dev->reada_lock);
>         atomic_set(&dev->reada_in_flight, 0);
>         atomic_set(&dev->dev_stats_ccnt, 0);
> -       INIT_RADIX_TREE(&dev->reada_zones, GFP_NOFS & ~__GFP_WAIT);
> -       INIT_RADIX_TREE(&dev->reada_extents, GFP_NOFS & ~__GFP_WAIT);
> +       INIT_RADIX_TREE(&dev->reada_zones, GFP_NOFS & ~__GFP_DIRECT_RECLAIM);
> +       INIT_RADIX_TREE(&dev->reada_extents, GFP_NOFS & ~__GFP_DIRECT_RECLAIM);
>
>         return dev;
>  }
> diff --git a/fs/ext3/super.c b/fs/ext3/super.c
> index 5ed0044fbb37..9004c786716f 100644
> --- a/fs/ext3/super.c
> +++ b/fs/ext3/super.c
> @@ -750,7 +750,7 @@ static int bdev_try_to_free_page(struct super_block *sb, struct page *page,
>                 return 0;
>         if (journal)
>                 return journal_try_to_free_buffers(journal, page,
> -                                                  wait & ~__GFP_WAIT);
> +                                               wait & ~__GFP_DIRECT_RECLAIM);
>         return try_to_free_buffers(page);
>  }
>
> diff --git a/fs/ext4/super.c b/fs/ext4/super.c
> index 58987b5c514b..abe76d41ef1e 100644
> --- a/fs/ext4/super.c
> +++ b/fs/ext4/super.c
> @@ -1045,7 +1045,7 @@ static int bdev_try_to_free_page(struct super_block *sb, struct page *page,
>                 return 0;
>         if (journal)
>                 return jbd2_journal_try_to_free_buffers(journal, page,
> -                                                       wait & ~__GFP_WAIT);
> +                                               wait & ~__GFP_DIRECT_RECLAIM);
>         return try_to_free_buffers(page);
>  }
>
> diff --git a/fs/fscache/cookie.c b/fs/fscache/cookie.c
> index d403c69bee08..4304072161aa 100644
> --- a/fs/fscache/cookie.c
> +++ b/fs/fscache/cookie.c
> @@ -111,7 +111,7 @@ struct fscache_cookie *__fscache_acquire_cookie(
>
>         /* radix tree insertion won't use the preallocation pool unless it's
>          * told it may not wait */
> -       INIT_RADIX_TREE(&cookie->stores, GFP_NOFS & ~__GFP_WAIT);
> +       INIT_RADIX_TREE(&cookie->stores, GFP_NOFS & ~__GFP_DIRECT_RECLAIM);
>
>         switch (cookie->def->type) {
>         case FSCACHE_COOKIE_TYPE_INDEX:
> diff --git a/fs/fscache/page.c b/fs/fscache/page.c
> index 483bbc613bf0..79483b3d8c6f 100644
> --- a/fs/fscache/page.c
> +++ b/fs/fscache/page.c
> @@ -58,7 +58,7 @@ bool release_page_wait_timeout(struct fscache_cookie *cookie, struct page *page)
>
>  /*
>   * decide whether a page can be released, possibly by cancelling a store to it
> - * - we're allowed to sleep if __GFP_WAIT is flagged
> + * - we're allowed to sleep if __GFP_DIRECT_RECLAIM is flagged
>   */
>  bool __fscache_maybe_release_page(struct fscache_cookie *cookie,
>                                   struct page *page,
> @@ -122,7 +122,7 @@ bool __fscache_maybe_release_page(struct fscache_cookie *cookie,
>          * allocator as the work threads writing to the cache may all end up
>          * sleeping on memory allocation, so we may need to impose a timeout
>          * too. */
> -       if (!(gfp & __GFP_WAIT) || !(gfp & __GFP_FS)) {
> +       if (!(gfp & __GFP_DIRECT_RECLAIM) || !(gfp & __GFP_FS)) {
>                 fscache_stat(&fscache_n_store_vmscan_busy);
>                 return false;
>         }
> @@ -132,7 +132,7 @@ bool __fscache_maybe_release_page(struct fscache_cookie *cookie,
>                 _debug("fscache writeout timeout page: %p{%lx}",
>                         page, page->index);
>
> -       gfp &= ~__GFP_WAIT;
> +       gfp &= ~__GFP_DIRECT_RECLAIM;
>         goto try_again;
>  }
>  EXPORT_SYMBOL(__fscache_maybe_release_page);
> diff --git a/fs/jbd/transaction.c b/fs/jbd/transaction.c
> index 1695ba8334a2..f45b90ba7c5c 100644
> --- a/fs/jbd/transaction.c
> +++ b/fs/jbd/transaction.c
> @@ -1690,8 +1690,8 @@ __journal_try_to_free_buffer(journal_t *journal, struct buffer_head *bh)
>   * @journal: journal for operation
>   * @page: to try and free
>   * @gfp_mask: we use the mask to detect how hard should we try to release
> - * buffers. If __GFP_WAIT and __GFP_FS is set, we wait for commit code to
> - * release the buffers.
> + * buffers. If __GFP_DIRECT_RECLAIM and __GFP_FS is set, we wait for commit
> + * code to release the buffers.
>   *
>   *
>   * For all the buffers on this page,
> diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
> index f3d06174b051..06e18bcdb888 100644
> --- a/fs/jbd2/transaction.c
> +++ b/fs/jbd2/transaction.c
> @@ -1893,8 +1893,8 @@ __journal_try_to_free_buffer(journal_t *journal, struct buffer_head *bh)
>   * @journal: journal for operation
>   * @page: to try and free
>   * @gfp_mask: we use the mask to detect how hard should we try to release
> - * buffers. If __GFP_WAIT and __GFP_FS is set, we wait for commit code to
> - * release the buffers.
> + * buffers. If __GFP_DIRECT_RECLAIM and __GFP_FS is set, we wait for commit
> + * code to release the buffers.
>   *
>   *
>   * For all the buffers on this page,
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index cc4fa1ed61fc..be6821967ec6 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -480,8 +480,8 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
>         dfprintk(PAGECACHE, "NFS: release_page(%p)\n", page);
>
>         /* Always try to initiate a 'commit' if relevant, but only
> -        * wait for it if __GFP_WAIT is set.  Even then, only wait 1
> -        * second and only if the 'bdi' is not congested.
> +        * wait for it if the caller allows blocking.  Even then,
> +        * only wait 1 second and only if the 'bdi' is not congested.
>          * Waiting indefinitely can cause deadlocks when the NFS
>          * server is on this machine, when a new TCP connection is
>          * needed and in other rare cases.  There is no particular
> @@ -491,7 +491,7 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
>         if (mapping) {
>                 struct nfs_server *nfss = NFS_SERVER(mapping->host);
>                 nfs_commit_inode(mapping->host, 0);
> -               if ((gfp & __GFP_WAIT) &&
> +               if (gfpflags_allow_blocking(gfp) &&
>                     !bdi_write_congested(&nfss->backing_dev_info)) {
>                         wait_on_page_bit_killable_timeout(page, PG_private,
>                                                           HZ);
> diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
> index eac9549efd52..587174fd4f2c 100644
> --- a/fs/xfs/xfs_qm.c
> +++ b/fs/xfs/xfs_qm.c
> @@ -525,7 +525,7 @@ xfs_qm_shrink_scan(
>         unsigned long           freed;
>         int                     error;
>
> -       if ((sc->gfp_mask & (__GFP_FS|__GFP_WAIT)) != (__GFP_FS|__GFP_WAIT))
> +       if ((sc->gfp_mask & (__GFP_FS|__GFP_DIRECT_RECLAIM)) != (__GFP_FS|__GFP_DIRECT_RECLAIM))
>                 return 0;
>
>         INIT_LIST_HEAD(&isol.buffers);
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index a10347ca5053..bd1937977d84 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -29,12 +29,13 @@ struct vm_area_struct;
>  #define ___GFP_NOMEMALLOC      0x10000u
>  #define ___GFP_HARDWALL                0x20000u
>  #define ___GFP_THISNODE                0x40000u
> -#define ___GFP_WAIT            0x80000u
> +#define ___GFP_ATOMIC          0x80000u
>  #define ___GFP_NOACCOUNT       0x100000u
>  #define ___GFP_NOTRACK         0x200000u
> -#define ___GFP_NO_KSWAPD       0x400000u
> +#define ___GFP_DIRECT_RECLAIM  0x400000u
>  #define ___GFP_OTHER_NODE      0x800000u
>  #define ___GFP_WRITE           0x1000000u
> +#define ___GFP_KSWAPD_RECLAIM  0x2000000u
>  /* If the above are modified, __GFP_BITS_SHIFT may need updating */
>
>  /*
> @@ -68,7 +69,7 @@ struct vm_area_struct;
>   * __GFP_MOVABLE: Flag that this page will be movable by the page migration
>   * mechanism or reclaimed
>   */
> -#define __GFP_WAIT     ((__force gfp_t)___GFP_WAIT)    /* Can wait and reschedule? */
> +#define __GFP_ATOMIC   ((__force gfp_t)___GFP_ATOMIC)  /* Caller cannot wait or reschedule */
>  #define __GFP_HIGH     ((__force gfp_t)___GFP_HIGH)    /* Should access emergency pools? */
>  #define __GFP_IO       ((__force gfp_t)___GFP_IO)      /* Can start physical IO? */
>  #define __GFP_FS       ((__force gfp_t)___GFP_FS)      /* Can call down to low-level FS? */
> @@ -91,23 +92,37 @@ struct vm_area_struct;
>  #define __GFP_NOACCOUNT        ((__force gfp_t)___GFP_NOACCOUNT) /* Don't account to kmemcg */
>  #define __GFP_NOTRACK  ((__force gfp_t)___GFP_NOTRACK)  /* Don't track with kmemcheck */
>
> -#define __GFP_NO_KSWAPD        ((__force gfp_t)___GFP_NO_KSWAPD)
>  #define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE) /* On behalf of other node */
>  #define __GFP_WRITE    ((__force gfp_t)___GFP_WRITE)   /* Allocator intends to dirty page */
>
>  /*
> + * A caller that is willing to wait may enter direct reclaim and will
> + * wake kswapd to reclaim pages in the background until the high
> + * watermark is met. A caller may wish to clear __GFP_DIRECT_RECLAIM to
> + * avoid unnecessary delays when a fallback option is available but
> + * still allow kswapd to reclaim in the background. The kswapd flag
> + * can be cleared when the reclaiming of pages would cause unnecessary
> + * disruption.
> + */
> +#define __GFP_WAIT (__GFP_DIRECT_RECLAIM|__GFP_KSWAPD_RECLAIM)

Convention is that combination of gfp flags don't use __XXX.

> +#define __GFP_DIRECT_RECLAIM   ((__force gfp_t)___GFP_DIRECT_RECLAIM) /* Caller can reclaim */
> +#define __GFP_KSWAPD_RECLAIM   ((__force gfp_t)___GFP_KSWAPD_RECLAIM) /* kswapd can wake */
> +
> +/*
>   * This may seem redundant, but it's a way of annotating false positives vs.
>   * allocations that simply cannot be supported (e.g. page tables).
>   */
>  #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
>
> -#define __GFP_BITS_SHIFT 25    /* Room for N __GFP_FOO bits */
> +#define __GFP_BITS_SHIFT 26    /* Room for N __GFP_FOO bits */
>  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
>
> -/* This equals 0, but use constants in case they ever change */
> -#define GFP_NOWAIT     (GFP_ATOMIC & ~__GFP_HIGH)
> -/* GFP_ATOMIC means both !wait (__GFP_WAIT not set) and use emergency pool */
> -#define GFP_ATOMIC     (__GFP_HIGH)
> +/*
> + * GFP_ATOMIC callers can not sleep, need the allocation to succeed.
> + * A lower watermark is applied to allow access to "atomic reserves"
> + */
> +#define GFP_ATOMIC     (__GFP_HIGH|__GFP_ATOMIC|__GFP_KSWAPD_RECLAIM)
> +#define GFP_NOWAIT     (__GFP_KSWAPD_RECLAIM)
>  #define GFP_NOIO       (__GFP_WAIT)
>  #define GFP_NOFS       (__GFP_WAIT | __GFP_IO)
>  #define GFP_KERNEL     (__GFP_WAIT | __GFP_IO | __GFP_FS)
> @@ -116,10 +131,10 @@ struct vm_area_struct;
>  #define GFP_USER       (__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
>  #define GFP_HIGHUSER   (GFP_USER | __GFP_HIGHMEM)
>  #define GFP_HIGHUSER_MOVABLE   (GFP_HIGHUSER | __GFP_MOVABLE)
> -#define GFP_IOFS       (__GFP_IO | __GFP_FS)
> -#define GFP_TRANSHUGE  (GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
> -                        __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN | \
> -                        __GFP_NO_KSWAPD)
> +#define GFP_IOFS       (__GFP_IO | __GFP_FS | __GFP_KSWAPD_RECLAIM)
> +#define GFP_TRANSHUGE  ((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
> +                        __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN) & \
> +                        ~__GFP_KSWAPD_RECLAIM)
>
>  /* This mask makes up all the page movable related flags */
>  #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
> @@ -161,6 +176,11 @@ static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
>         return (gfp_flags & GFP_MOVABLE_MASK) >> GFP_MOVABLE_SHIFT;
>  }
>
> +static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
> +{
> +       return gfp_flags & __GFP_DIRECT_RECLAIM;
> +}
> +
>  #ifdef CONFIG_HIGHMEM
>  #define OPT_ZONE_HIGHMEM ZONE_HIGHMEM
>  #else
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 22b6d9ca1654..55c4a9175801 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -1109,7 +1109,7 @@ static inline int skb_cloned(const struct sk_buff *skb)
>
>  static inline int skb_unclone(struct sk_buff *skb, gfp_t pri)
>  {
> -       might_sleep_if(pri & __GFP_WAIT);
> +       might_sleep_if(gfpflags_allow_blocking(pri));
>
>         if (skb_cloned(skb))
>                 return pskb_expand_head(skb, 0, 0, pri);
> @@ -1193,7 +1193,7 @@ static inline int skb_shared(const struct sk_buff *skb)
>   */
>  static inline struct sk_buff *skb_share_check(struct sk_buff *skb, gfp_t pri)
>  {
> -       might_sleep_if(pri & __GFP_WAIT);
> +       might_sleep_if(gfpflags_allow_blocking(pri));
>         if (skb_shared(skb)) {
>                 struct sk_buff *nskb = skb_clone(skb, pri);
>
> @@ -1229,7 +1229,7 @@ static inline struct sk_buff *skb_share_check(struct sk_buff *skb, gfp_t pri)
>  static inline struct sk_buff *skb_unshare(struct sk_buff *skb,
>                                           gfp_t pri)
>  {
> -       might_sleep_if(pri & __GFP_WAIT);
> +       might_sleep_if(gfpflags_allow_blocking(pri));
>         if (skb_cloned(skb)) {
>                 struct sk_buff *nskb = skb_copy(skb, pri);
>
> diff --git a/include/net/sock.h b/include/net/sock.h
> index f21f0708ec59..cec0c4b634dc 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -2035,7 +2035,7 @@ struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp,
>   */
>  static inline struct page_frag *sk_page_frag(struct sock *sk)
>  {
> -       if (sk->sk_allocation & __GFP_WAIT)
> +       if (gfpflags_allow_blocking(sk->sk_allocation))
>                 return &current->task_frag;
>
>         return &sk->sk_frag;
> diff --git a/include/trace/events/gfpflags.h b/include/trace/events/gfpflags.h
> index d6fd8e5b14b7..dde6bf092c8a 100644
> --- a/include/trace/events/gfpflags.h
> +++ b/include/trace/events/gfpflags.h
> @@ -20,7 +20,7 @@
>         {(unsigned long)GFP_ATOMIC,             "GFP_ATOMIC"},          \
>         {(unsigned long)GFP_NOIO,               "GFP_NOIO"},            \
>         {(unsigned long)__GFP_HIGH,             "GFP_HIGH"},            \
> -       {(unsigned long)__GFP_WAIT,             "GFP_WAIT"},            \
> +       {(unsigned long)__GFP_ATOMIC,           "GFP_ATOMIC"},          \
>         {(unsigned long)__GFP_IO,               "GFP_IO"},              \
>         {(unsigned long)__GFP_COLD,             "GFP_COLD"},            \
>         {(unsigned long)__GFP_NOWARN,           "GFP_NOWARN"},          \
> @@ -36,7 +36,8 @@
>         {(unsigned long)__GFP_RECLAIMABLE,      "GFP_RECLAIMABLE"},     \
>         {(unsigned long)__GFP_MOVABLE,          "GFP_MOVABLE"},         \
>         {(unsigned long)__GFP_NOTRACK,          "GFP_NOTRACK"},         \
> -       {(unsigned long)__GFP_NO_KSWAPD,        "GFP_NO_KSWAPD"},       \
> +       {(unsigned long)__GFP_DIRECT_RECLAIM,   "GFP_DIRECT_RECLAIM"},  \
> +       {(unsigned long)__GFP_KSWAPD_RECLAIM,   "GFP_KSWAPD_RECLAIM"},  \
>         {(unsigned long)__GFP_OTHER_NODE,       "GFP_OTHER_NODE"}       \
>         ) : "GFP_NOWAIT"
>
> diff --git a/kernel/audit.c b/kernel/audit.c
> index f9e6065346db..6ab7a55dbdff 100644
> --- a/kernel/audit.c
> +++ b/kernel/audit.c
> @@ -1357,16 +1357,16 @@ struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask,
>         if (unlikely(audit_filter_type(type)))
>                 return NULL;
>
> -       if (gfp_mask & __GFP_WAIT) {
> +       if (gfp_mask & __GFP_DIRECT_RECLAIM) {
>                 if (audit_pid && audit_pid == current->pid)
> -                       gfp_mask &= ~__GFP_WAIT;
> +                       gfp_mask &= ~__GFP_DIRECT_RECLAIM;
>                 else
>                         reserve = 0;
>         }
>
>         while (audit_backlog_limit
>                && skb_queue_len(&audit_skb_queue) > audit_backlog_limit + reserve) {
> -               if (gfp_mask & __GFP_WAIT && audit_backlog_wait_time) {
> +               if (gfp_mask & __GFP_DIRECT_RECLAIM && audit_backlog_wait_time) {
>                         long sleep_time;
>
>                         sleep_time = timeout_start + audit_backlog_wait_time - jiffies;
> diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
> index 8acfbf773e06..9aa39f20f593 100644
> --- a/kernel/locking/lockdep.c
> +++ b/kernel/locking/lockdep.c
> @@ -2738,7 +2738,7 @@ static void __lockdep_trace_alloc(gfp_t gfp_mask, unsigned long flags)
>                 return;
>
>         /* no reclaim without waiting on it */
> -       if (!(gfp_mask & __GFP_WAIT))
> +       if (!(gfp_mask & __GFP_DIRECT_RECLAIM))
>                 return;
>
>         /* this guy won't enter reclaim */
> diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
> index 5235dd4e1e2f..3a970604308f 100644
> --- a/kernel/power/snapshot.c
> +++ b/kernel/power/snapshot.c
> @@ -1779,7 +1779,7 @@ alloc_highmem_pages(struct memory_bitmap *bm, unsigned int nr_highmem)
>         while (to_alloc-- > 0) {
>                 struct page *page;
>
> -               page = alloc_image_page(__GFP_HIGHMEM);
> +               page = alloc_image_page(__GFP_HIGHMEM|__GFP_KSWAPD_RECLAIM);
>                 memory_bm_set_bit(bm, page_to_pfn(page));
>         }
>         return nr_highmem;
> diff --git a/kernel/smp.c b/kernel/smp.c
> index 07854477c164..d903c02223af 100644
> --- a/kernel/smp.c
> +++ b/kernel/smp.c
> @@ -669,7 +669,7 @@ void on_each_cpu_cond(bool (*cond_func)(int cpu, void *info),
>         cpumask_var_t cpus;
>         int cpu, ret;
>
> -       might_sleep_if(gfp_flags & __GFP_WAIT);
> +       might_sleep_if(gfpflags_allow_blocking(gfp_flags));
>
>         if (likely(zalloc_cpumask_var(&cpus, (gfp_flags|__GFP_NOWARN)))) {
>                 preempt_disable();
> diff --git a/lib/idr.c b/lib/idr.c
> index 5335c43adf46..6098336df267 100644
> --- a/lib/idr.c
> +++ b/lib/idr.c
> @@ -399,7 +399,7 @@ void idr_preload(gfp_t gfp_mask)
>          * allocation guarantee.  Disallow usage from those contexts.
>          */
>         WARN_ON_ONCE(in_interrupt());
> -       might_sleep_if(gfp_mask & __GFP_WAIT);
> +       might_sleep_if(gfpflags_allow_blocking(gfp_mask));
>
>         preempt_disable();
>
> @@ -453,7 +453,7 @@ int idr_alloc(struct idr *idr, void *ptr, int start, int end, gfp_t gfp_mask)
>         struct idr_layer *pa[MAX_IDR_LEVEL + 1];
>         int id;
>
> -       might_sleep_if(gfp_mask & __GFP_WAIT);
> +       might_sleep_if(gfpflags_allow_blocking(gfp_mask));
>
>         /* sanity checks */
>         if (WARN_ON_ONCE(start < 0))
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index f9ebe1c82060..c3775ee46cd6 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -188,7 +188,7 @@ radix_tree_node_alloc(struct radix_tree_root *root)
>          * preloading in the interrupt anyway as all the allocations have to
>          * be atomic. So just do normal allocation when in interrupt.
>          */
> -       if (!(gfp_mask & __GFP_WAIT) && !in_interrupt()) {
> +       if (!gfpflags_allow_blocking(gfp_mask) && !in_interrupt()) {
>                 struct radix_tree_preload *rtp;
>
>                 /*
> @@ -249,7 +249,7 @@ radix_tree_node_free(struct radix_tree_node *node)
>   * with preemption not disabled.
>   *
>   * To make use of this facility, the radix tree must be initialised without
> - * __GFP_WAIT being passed to INIT_RADIX_TREE().
> + * __GFP_DIRECT_RECLAIM being passed to INIT_RADIX_TREE().
>   */
>  static int __radix_tree_preload(gfp_t gfp_mask)
>  {
> @@ -286,12 +286,12 @@ static int __radix_tree_preload(gfp_t gfp_mask)
>   * with preemption not disabled.
>   *
>   * To make use of this facility, the radix tree must be initialised without
> - * __GFP_WAIT being passed to INIT_RADIX_TREE().
> + * __GFP_DIRECT_RECLAIM being passed to INIT_RADIX_TREE().
>   */
>  int radix_tree_preload(gfp_t gfp_mask)
>  {
>         /* Warn on non-sensical use... */
> -       WARN_ON_ONCE(!(gfp_mask & __GFP_WAIT));
> +       WARN_ON_ONCE(gfpflags_allow_blocking(gfp_mask));
>         return __radix_tree_preload(gfp_mask);
>  }
>  EXPORT_SYMBOL(radix_tree_preload);
> @@ -303,7 +303,7 @@ EXPORT_SYMBOL(radix_tree_preload);
>   */
>  int radix_tree_maybe_preload(gfp_t gfp_mask)
>  {
> -       if (gfp_mask & __GFP_WAIT)
> +       if (gfpflags_allow_blocking(gfp_mask))
>                 return __radix_tree_preload(gfp_mask);
>         /* Preloading doesn't help anything with this gfp mask, skip it */
>         preempt_disable();
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index dac5bf59309d..805ce70b72f3 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -632,7 +632,7 @@ struct bdi_writeback *wb_get_create(struct backing_dev_info *bdi,
>  {
>         struct bdi_writeback *wb;
>
> -       might_sleep_if(gfp & __GFP_WAIT);
> +       might_sleep_if(gfpflags_allow_blocking(gfp));
>
>         if (!memcg_css->parent)
>                 return &bdi->wb;
> diff --git a/mm/dmapool.c b/mm/dmapool.c
> index fd5fe4342e93..84dac666fc0c 100644
> --- a/mm/dmapool.c
> +++ b/mm/dmapool.c
> @@ -323,7 +323,7 @@ void *dma_pool_alloc(struct dma_pool *pool, gfp_t mem_flags,
>         size_t offset;
>         void *retval;
>
> -       might_sleep_if(mem_flags & __GFP_WAIT);
> +       might_sleep_if(gfpflags_allow_blocking(mem_flags));
>
>         spin_lock_irqsave(&pool->lock, flags);
>         list_for_each_entry(page, &pool->page_list, page_list) {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index acb93c554f6e..e34f6411da8c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2268,7 +2268,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>         if (unlikely(task_in_memcg_oom(current)))
>                 goto nomem;
>
> -       if (!(gfp_mask & __GFP_WAIT))
> +       if (!gfpflags_allow_blocking(gfp_mask))
>                 goto nomem;
>
>         mem_cgroup_events(mem_over_limit, MEMCG_MAX, 1);
> @@ -2327,7 +2327,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>         css_get_many(&memcg->css, batch);
>         if (batch > nr_pages)
>                 refill_stock(memcg, batch - nr_pages);
> -       if (!(gfp_mask & __GFP_WAIT))
> +       if (!gfpflags_allow_blocking(gfp_mask))
>                 goto done;
>         /*
>          * If the hierarchy is above the normal consumption range,
> @@ -4696,8 +4696,8 @@ static int mem_cgroup_do_precharge(unsigned long count)
>  {
>         int ret;
>
> -       /* Try a single bulk charge without reclaim first */
> -       ret = try_charge(mc.to, GFP_KERNEL & ~__GFP_WAIT, count);
> +       /* Try a single bulk charge without reclaim first, kswapd may wake */
> +       ret = try_charge(mc.to, GFP_KERNEL & ~__GFP_DIRECT_RECLAIM, count);
>         if (!ret) {
>                 mc.precharge += count;
>                 return ret;
> diff --git a/mm/mempool.c b/mm/mempool.c
> index 2cc08de8b1db..bfd2a0dd0e18 100644
> --- a/mm/mempool.c
> +++ b/mm/mempool.c
> @@ -317,13 +317,13 @@ void * mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
>         gfp_t gfp_temp;
>
>         VM_WARN_ON_ONCE(gfp_mask & __GFP_ZERO);
> -       might_sleep_if(gfp_mask & __GFP_WAIT);
> +       might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
>
>         gfp_mask |= __GFP_NOMEMALLOC;   /* don't allocate emergency reserves */
>         gfp_mask |= __GFP_NORETRY;      /* don't loop in __alloc_pages */
>         gfp_mask |= __GFP_NOWARN;       /* failures are OK */
>
> -       gfp_temp = gfp_mask & ~(__GFP_WAIT|__GFP_IO);
> +       gfp_temp = gfp_mask & ~(__GFP_DIRECT_RECLAIM|__GFP_IO);
>
>  repeat_alloc:
>
> @@ -346,7 +346,7 @@ void * mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
>         }
>
>         /*
> -        * We use gfp mask w/o __GFP_WAIT or IO for the first round.  If
> +        * We use gfp mask w/o direct reclaim or IO for the first round.  If
>          * alloc failed with that and @pool was empty, retry immediately.
>          */
>         if (gfp_temp != gfp_mask) {
> @@ -355,8 +355,8 @@ void * mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
>                 goto repeat_alloc;
>         }
>
> -       /* We must not sleep if !__GFP_WAIT */
> -       if (!(gfp_mask & __GFP_WAIT)) {
> +       /* We must not sleep if !__GFP_DIRECT_RECLAIM */
> +       if (!(gfp_mask & __GFP_DIRECT_RECLAIM)) {
>                 spin_unlock_irqrestore(&pool->lock, flags);
>                 return NULL;
>         }
> diff --git a/mm/migrate.c b/mm/migrate.c
> index eb4267107d1f..0e16c4047638 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1564,7 +1564,7 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
>                                          (GFP_HIGHUSER_MOVABLE |
>                                           __GFP_THISNODE | __GFP_NOMEMALLOC |
>                                           __GFP_NORETRY | __GFP_NOWARN) &
> -                                        ~GFP_IOFS, 0);
> +                                        ~(__GFP_IO | __GFP_FS), 0);
>
>         return newpage;
>  }
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 32d1cec124bc..68f961bdfdf8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -151,12 +151,12 @@ void pm_restrict_gfp_mask(void)
>         WARN_ON(!mutex_is_locked(&pm_mutex));
>         WARN_ON(saved_gfp_mask);
>         saved_gfp_mask = gfp_allowed_mask;
> -       gfp_allowed_mask &= ~GFP_IOFS;
> +       gfp_allowed_mask &= ~(__GFP_IO | __GFP_FS);
>  }
>
>  bool pm_suspended_storage(void)
>  {
> -       if ((gfp_allowed_mask & GFP_IOFS) == GFP_IOFS)
> +       if ((gfp_allowed_mask & (__GFP_IO | __GFP_FS)) == (__GFP_IO | __GFP_FS))
>                 return false;
>         return true;
>  }
> @@ -2158,7 +2158,7 @@ static bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
>                 return false;
>         if (fail_page_alloc.ignore_gfp_highmem && (gfp_mask & __GFP_HIGHMEM))
>                 return false;
> -       if (fail_page_alloc.ignore_gfp_wait && (gfp_mask & __GFP_WAIT))
> +       if (fail_page_alloc.ignore_gfp_wait && (gfp_mask & (__GFP_ATOMIC|__GFP_DIRECT_RECLAIM)))
>                 return false;
>
>         return should_fail(&fail_page_alloc.attr, 1 << order);
> @@ -2660,7 +2660,7 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
>                 if (test_thread_flag(TIF_MEMDIE) ||
>                     (current->flags & (PF_MEMALLOC | PF_EXITING)))
>                         filter &= ~SHOW_MEM_FILTER_NODES;
> -       if (in_interrupt() || !(gfp_mask & __GFP_WAIT))
> +       if (in_interrupt() || !(gfp_mask & __GFP_WAIT) || (gfp_mask & __GFP_ATOMIC))
>                 filter &= ~SHOW_MEM_FILTER_NODES;
>
>         if (fmt) {
> @@ -2915,7 +2915,6 @@ static inline int
>  gfp_to_alloc_flags(gfp_t gfp_mask)
>  {
>         int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
> -       const bool atomic = !(gfp_mask & (__GFP_WAIT | __GFP_NO_KSWAPD));
>
>         /* __GFP_HIGH is assumed to be the same as ALLOC_HIGH to save a branch. */
>         BUILD_BUG_ON(__GFP_HIGH != (__force gfp_t) ALLOC_HIGH);
> @@ -2924,11 +2923,11 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
>          * The caller may dip into page reserves a bit more if the caller
>          * cannot run direct reclaim, or if the caller has realtime scheduling
>          * policy or is asking for __GFP_HIGH memory.  GFP_ATOMIC requests will
> -        * set both ALLOC_HARDER (atomic == true) and ALLOC_HIGH (__GFP_HIGH).
> +        * set both ALLOC_HARDER (__GFP_ATOMIC) and ALLOC_HIGH (__GFP_HIGH).
>          */
>         alloc_flags |= (__force int) (gfp_mask & __GFP_HIGH);
>
> -       if (atomic) {
> +       if (gfp_mask & __GFP_ATOMIC) {
>                 /*
>                  * Not worth trying to allocate harder for __GFP_NOMEMALLOC even
>                  * if it can't schedule.
> @@ -2965,11 +2964,16 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>         return !!(gfp_to_alloc_flags(gfp_mask) & ALLOC_NO_WATERMARKS);
>  }
>
> +static inline bool is_thp_gfp_mask(gfp_t gfp_mask)
> +{
> +       return (gfp_mask & (GFP_TRANSHUGE | __GFP_KSWAPD_RECLAIM)) == GFP_TRANSHUGE;
> +}
> +
>  static inline struct page *
>  __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>                                                 struct alloc_context *ac)
>  {
> -       const gfp_t wait = gfp_mask & __GFP_WAIT;
> +       bool can_direct_reclaim = gfp_mask & __GFP_DIRECT_RECLAIM;
>         struct page *page = NULL;
>         int alloc_flags;
>         unsigned long pages_reclaimed = 0;
> @@ -2990,15 +2994,23 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>         }
>
>         /*
> +        * We also sanity check to catch abuse of atomic reserves being used by
> +        * callers that are not in atomic context.
> +        */
> +       if (WARN_ON_ONCE((gfp_mask & (__GFP_ATOMIC|__GFP_DIRECT_RECLAIM)) ==
> +                               (__GFP_ATOMIC|__GFP_DIRECT_RECLAIM)))
> +               gfp_mask &= ~__GFP_ATOMIC;
> +
> +       /*
>          * If this allocation cannot block and it is for a specific node, then
>          * fail early.  There's no need to wakeup kswapd or retry for a
>          * speculative node-specific allocation.
>          */
> -       if (IS_ENABLED(CONFIG_NUMA) && (gfp_mask & __GFP_THISNODE) && !wait)
> +       if (IS_ENABLED(CONFIG_NUMA) && (gfp_mask & __GFP_THISNODE) && !can_direct_reclaim)
>                 goto nopage;
>
>  retry:
> -       if (!(gfp_mask & __GFP_NO_KSWAPD))
> +       if (gfp_mask & __GFP_KSWAPD_RECLAIM)
>                 wake_all_kswapds(order, ac);
>
>         /*
> @@ -3041,8 +3053,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>                 }
>         }
>
> -       /* Atomic allocations - we can't balance anything */
> -       if (!wait) {
> +       /* Caller is not willing to reclaim, we can't balance anything */
> +       if (!can_direct_reclaim) {
>                 /*
>                  * All existing users of the deprecated __GFP_NOFAIL are
>                  * blockable, so warn of any new users that actually allow this
> @@ -3072,7 +3084,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>                 goto got_pg;
>
>         /* Checks for THP-specific high-order allocations */
> -       if ((gfp_mask & GFP_TRANSHUGE) == GFP_TRANSHUGE) {
> +       if (is_thp_gfp_mask(gfp_mask)) {
>                 /*
>                  * If compaction is deferred for high-order allocations, it is
>                  * because sync compaction recently failed. If this is the case
> @@ -3107,8 +3119,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>          * fault, so use asynchronous memory compaction for THP unless it is
>          * khugepaged trying to collapse.
>          */
> -       if ((gfp_mask & GFP_TRANSHUGE) != GFP_TRANSHUGE ||
> -                                               (current->flags & PF_KTHREAD))
> +       if (!is_thp_gfp_mask(gfp_mask) || (current->flags & PF_KTHREAD))
>                 migration_mode = MIGRATE_SYNC_LIGHT;
>
>         /* Try direct reclaim and then allocating */
> @@ -3179,7 +3190,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>
>         lockdep_trace_alloc(gfp_mask);
>
> -       might_sleep_if(gfp_mask & __GFP_WAIT);
> +       might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
>
>         if (should_fail_alloc_page(gfp_mask, order))
>                 return NULL;
> diff --git a/mm/slab.c b/mm/slab.c
> index 200e22412a16..f82bdb3eb1fc 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1030,12 +1030,12 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
>  }
>
>  /*
> - * Construct gfp mask to allocate from a specific node but do not invoke reclaim
> - * or warn about failures.
> + * Construct gfp mask to allocate from a specific node but do not direct reclaim
> + * or warn about failures. kswapd may still wake to reclaim in the background.
>   */
>  static inline gfp_t gfp_exact_node(gfp_t flags)
>  {
> -       return (flags | __GFP_THISNODE | __GFP_NOWARN) & ~__GFP_WAIT;
> +       return (flags | __GFP_THISNODE | __GFP_NOWARN) & ~__GFP_DIRECT_RECLAIM;
>  }
>  #endif
>
> @@ -2625,7 +2625,7 @@ static int cache_grow(struct kmem_cache *cachep,
>
>         offset *= cachep->colour_off;
>
> -       if (local_flags & __GFP_WAIT)
> +       if (gfpflags_allow_blocking(local_flags))
>                 local_irq_enable();
>
>         /*
> @@ -2655,7 +2655,7 @@ static int cache_grow(struct kmem_cache *cachep,
>
>         cache_init_objs(cachep, page);
>
> -       if (local_flags & __GFP_WAIT)
> +       if (gfpflags_allow_blocking(local_flags))
>                 local_irq_disable();
>         check_irq_off();
>         spin_lock(&n->list_lock);
> @@ -2669,7 +2669,7 @@ static int cache_grow(struct kmem_cache *cachep,
>  opps1:
>         kmem_freepages(cachep, page);
>  failed:
> -       if (local_flags & __GFP_WAIT)
> +       if (gfpflags_allow_blocking(local_flags))
>                 local_irq_disable();
>         return 0;
>  }
> @@ -2861,7 +2861,7 @@ static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags,
>  static inline void cache_alloc_debugcheck_before(struct kmem_cache *cachep,
>                                                 gfp_t flags)
>  {
> -       might_sleep_if(flags & __GFP_WAIT);
> +       might_sleep_if(gfpflags_allow_blocking(flags));
>  #if DEBUG
>         kmem_flagcheck(cachep, flags);
>  #endif
> @@ -3049,11 +3049,11 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
>                  */
>                 struct page *page;
>
> -               if (local_flags & __GFP_WAIT)
> +               if (gfpflags_allow_blocking(local_flags))
>                         local_irq_enable();
>                 kmem_flagcheck(cache, flags);
>                 page = kmem_getpages(cache, local_flags, numa_mem_id());
> -               if (local_flags & __GFP_WAIT)
> +               if (gfpflags_allow_blocking(local_flags))
>                         local_irq_disable();
>                 if (page) {
>                         /*
> diff --git a/mm/slub.c b/mm/slub.c
> index 816df0016555..a4661c59ff54 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1263,7 +1263,7 @@ static inline struct kmem_cache *slab_pre_alloc_hook(struct kmem_cache *s,
>  {
>         flags &= gfp_allowed_mask;
>         lockdep_trace_alloc(flags);
> -       might_sleep_if(flags & __GFP_WAIT);
> +       might_sleep_if(gfpflags_allow_blocking(flags));
>
>         if (should_failslab(s->object_size, flags, s->flags))
>                 return NULL;
> @@ -1339,7 +1339,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>
>         flags &= gfp_allowed_mask;
>
> -       if (flags & __GFP_WAIT)
> +       if (gfpflags_allow_blocking(flags))
>                 local_irq_enable();
>
>         flags |= s->allocflags;
> @@ -1380,7 +1380,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>                         kmemcheck_mark_unallocated_pages(page, pages);
>         }
>
> -       if (flags & __GFP_WAIT)
> +       if (gfpflags_allow_blocking(flags))
>                 local_irq_disable();
>         if (!page)
>                 return NULL;
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 2faaa2976447..9ad4dcb0631c 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1617,7 +1617,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>                         goto fail;
>                 }
>                 area->pages[i] = page;
> -               if (gfp_mask & __GFP_WAIT)
> +               if (gfpflags_allow_blocking(gfp_mask))
>                         cond_resched();
>         }
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index e950134c4b9a..837c440d60a9 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1465,7 +1465,7 @@ static int too_many_isolated(struct zone *zone, int file,
>          * won't get blocked by normal direct-reclaimers, forming a circular
>          * deadlock.
>          */
> -       if ((sc->gfp_mask & GFP_IOFS) == GFP_IOFS)
> +       if ((sc->gfp_mask & (__GFP_IO | __GFP_FS)) == (__GFP_IO | __GFP_FS))
>                 inactive >>= 3;
>
>         return isolated > inactive;
> @@ -3764,7 +3764,7 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>         /*
>          * Do not scan if the allocation should not be delayed.
>          */
> -       if (!(gfp_mask & __GFP_WAIT) || (current->flags & PF_MEMALLOC))
> +       if (!gfpflags_allow_blocking(gfp_mask) || (current->flags & PF_MEMALLOC))
>                 return ZONE_RECLAIM_NOSCAN;
>
>         /*
> diff --git a/mm/zswap.c b/mm/zswap.c
> index 2d5727baed59..26104a68c972 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -684,7 +684,8 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>
>         /* store */
>         len = dlen + sizeof(struct zswap_header);
> -       ret = zpool_malloc(zswap_pool, len, __GFP_NORETRY | __GFP_NOWARN,
> +       ret = zpool_malloc(zswap_pool, len,
> +               __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM,
>                 &handle);
>         if (ret == -ENOSPC) {
>                 zswap_reject_compress_poor++;
> @@ -900,7 +901,7 @@ static void __exit zswap_debugfs_exit(void) { }
>  **********************************/
>  static int __init init_zswap(void)
>  {
> -       gfp_t gfp = __GFP_NORETRY | __GFP_NOWARN;
> +       gfp_t gfp = __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM;
>
>         pr_info("loading zswap\n");
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index b6a19ca0f99e..6f025e2544de 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -414,7 +414,7 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev, unsigned int len,
>         len += NET_SKB_PAD;
>
>         if ((len > SKB_WITH_OVERHEAD(PAGE_SIZE)) ||
> -           (gfp_mask & (__GFP_WAIT | GFP_DMA))) {
> +           (gfp_mask & (__GFP_DIRECT_RECLAIM | GFP_DMA))) {
>                 skb = __alloc_skb(len, gfp_mask, SKB_ALLOC_RX, NUMA_NO_NODE);
>                 if (!skb)
>                         goto skb_fail;
> @@ -481,7 +481,7 @@ struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
>         len += NET_SKB_PAD + NET_IP_ALIGN;
>
>         if ((len > SKB_WITH_OVERHEAD(PAGE_SIZE)) ||
> -           (gfp_mask & (__GFP_WAIT | GFP_DMA))) {
> +           (gfp_mask & (__GFP_DIRECT_RECLAIM | GFP_DMA))) {
>                 skb = __alloc_skb(len, gfp_mask, SKB_ALLOC_RX, NUMA_NO_NODE);
>                 if (!skb)
>                         goto skb_fail;
> @@ -4452,7 +4452,7 @@ struct sk_buff *alloc_skb_with_frags(unsigned long header_len,
>                 return NULL;
>
>         gfp_head = gfp_mask;
> -       if (gfp_head & __GFP_WAIT)
> +       if (gfp_head & __GFP_DIRECT_RECLAIM)
>                 gfp_head |= __GFP_REPEAT;
>
>         *errcode = -ENOBUFS;
> @@ -4467,7 +4467,7 @@ struct sk_buff *alloc_skb_with_frags(unsigned long header_len,
>
>                 while (order) {
>                         if (npages >= 1 << order) {
> -                               page = alloc_pages((gfp_mask & ~__GFP_WAIT) |
> +                               page = alloc_pages((gfp_mask & ~__GFP_DIRECT_RECLAIM) |
>                                                    __GFP_COMP |
>                                                    __GFP_NOWARN |
>                                                    __GFP_NORETRY,
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 193901d09757..02b705cc9eb3 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1879,8 +1879,10 @@ bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t gfp)
>
>         pfrag->offset = 0;
>         if (SKB_FRAG_PAGE_ORDER) {
> -               pfrag->page = alloc_pages((gfp & ~__GFP_WAIT) | __GFP_COMP |
> -                                         __GFP_NOWARN | __GFP_NORETRY,
> +               /* Avoid direct reclaim but allow kswapd to wake */
> +               pfrag->page = alloc_pages((gfp & ~__GFP_DIRECT_RECLAIM) |
> +                                         __GFP_COMP | __GFP_NOWARN |
> +                                         __GFP_NORETRY,
>                                           SKB_FRAG_PAGE_ORDER);
>                 if (likely(pfrag->page)) {
>                         pfrag->size = PAGE_SIZE << SKB_FRAG_PAGE_ORDER;
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 67d210477863..8283d90dde74 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -2066,7 +2066,7 @@ int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb, u32 portid
>         consume_skb(info.skb2);
>
>         if (info.delivered) {
> -               if (info.congested && (allocation & __GFP_WAIT))
> +               if (info.congested && gfpflags_allow_blocking(allocation))
>                         yield();
>                 return 0;
>         }
> diff --git a/net/rxrpc/ar-connection.c b/net/rxrpc/ar-connection.c
> index 6631f4f1e39b..3b5de4b86058 100644
> --- a/net/rxrpc/ar-connection.c
> +++ b/net/rxrpc/ar-connection.c
> @@ -500,7 +500,7 @@ int rxrpc_connect_call(struct rxrpc_sock *rx,
>                 if (bundle->num_conns >= 20) {
>                         _debug("too many conns");
>
> -                       if (!(gfp & __GFP_WAIT)) {
> +                       if (!gfpflags_allow_blocking(gfp)) {
>                                 _leave(" = -EAGAIN");
>                                 return -EAGAIN;
>                         }
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 197c3f59ecbf..75369ae8de1e 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -1588,7 +1588,7 @@ int sctp_assoc_lookup_laddr(struct sctp_association *asoc,
>  /* Set an association id for a given association */
>  int sctp_assoc_set_id(struct sctp_association *asoc, gfp_t gfp)
>  {
> -       bool preload = !!(gfp & __GFP_WAIT);
> +       bool preload = gfpflags_allow_blocking(gfp);
>         int ret;
>
>         /* If the id is already assigned, keep it. */
> --
> 2.4.6
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
