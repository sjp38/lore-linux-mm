Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 42B9A6B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 08:22:13 -0400 (EDT)
Received: by lamp12 with SMTP id p12so5406323lam.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 05:22:12 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id gi6si12142852wjb.204.2015.09.09.05.22.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 09 Sep 2015 05:22:11 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id C2E391DC09D
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 12:22:10 +0000 (UTC)
Date: Wed, 9 Sep 2015 13:22:03 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 07/12] mm, page_alloc: Distinguish between being unable
 to sleep, unwilling to sleep and avoiding waking kswapd
Message-ID: <20150909122203.GY12432@techsingularity.net>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <1440418191-10894-8-git-send-email-mgorman@techsingularity.net>
 <CAAmzW4N+vrGcxx64B0t-7HXA7giyqRHbYcmRvnYLtw=_12AWPw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAAmzW4N+vrGcxx64B0t-7HXA7giyqRHbYcmRvnYLtw=_12AWPw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Sep 08, 2015 at 03:49:58PM +0900, Joonsoo Kim wrote:
> 2015-08-24 21:09 GMT+09:00 Mel Gorman <mgorman@techsingularity.net>:
> > __GFP_WAIT has been used to identify atomic context in callers that hold
> > spinlocks or are in interrupts. They are expected to be high priority and
> > have access one of two watermarks lower than "min" which can be referred
> > to as the "atomic reserve". __GFP_HIGH users get access to the first lower
> > watermark and can be called the "high priority reserve".
> >
> > Over time, callers had a requirement to not block when fallback options
> > were available. Some have abused __GFP_WAIT leading to a situation where
> > an optimisitic allocation with a fallback option can access atomic reserves.
> >
> > This patch uses __GFP_ATOMIC to identify callers that are truely atomic,
> > cannot sleep and have no alternative. High priority users continue to use
> > __GFP_HIGH. __GFP_DIRECT_RECLAIM identifies callers that can sleep and are
> > willing to enter direct reclaim. __GFP_KSWAPD_RECLAIM to identify callers
> > that want to wake kswapd for background reclaim. __GFP_WAIT is redefined
> > as a caller that is willing to enter direct reclaim and wake kswapd for
> > background reclaim.
> 
> Hello, Mel.
> 
> I think that it is better to do one thing at one patch.

This was a case where the incremental change felt unnecessary. The purpose
of the patch is to "distinguish between being unable to sleep, unwilling
to sleep and avoiding waking kswapd". Splitting that up is possible but
I'm not convinced it helps.

> To distinguish real atomic, we just need to introduce __GFP_ATOMIC and
> make GFP_ATOMIC to __GFP_ATOMIC | GFP_HARDER and change related
> things. __GFP_WAIT changes isn't needed at all for this purpose. It can
> reduce patch size and provides more good bisectability.
> 
> And, I don't think that introducing __GFP_KSWAPD_RECLAIM is good thing.
> Basically, kswapd reclaim should be enforced.

Several years ago, I would have agreed. Now there are callers that want
to control kswapd and I think it made more sense to clearly state whether
RECLAIM and KSWAPD are allowed instead of having RECLAIM and NO_KSWAPD
flags -- i.e. flags that consistently allow or consistently deny.

> New flag makes user who manually
> manipulate gfp flag more difficult. Without this change, your second hazard will
> be disappeared although it is almost harmless.
> 
> And, I doubt that this big one shot change is preferable. AFAIK, even if changes
> are one to one mapping and no functional difference, each one is made by
> one patch and send it to correct maintainer. I guess there is some difficulty
> in this patch to do like this, but, it could. Isn't it?
> 

Splitting this into one patch per maintainer would be a review and bisection
nightmare. If I saw someone else doing that I would wonder if they were
just trying to increase their patch count for no reason.

> Some nitpicks are below.
> 
> > <SNIP>
> >
> > diff --git a/arch/arm/xen/mm.c b/arch/arm/xen/mm.c
> > index 03e75fef15b8..86809bd2026d 100644
> > --- a/arch/arm/xen/mm.c
> > +++ b/arch/arm/xen/mm.c
> > @@ -25,7 +25,7 @@
> >  unsigned long xen_get_swiotlb_free_pages(unsigned int order)
> >  {
> >         struct memblock_region *reg;
> > -       gfp_t flags = __GFP_NOWARN;
> > +       gfp_t flags = __GFP_NOWARN|___GFP_KSWAPD_RECLAIM;
> 
> Please use __XXX rather than ___XXX.
> 

Fixed.

> > <SNIP>
> >
> > @@ -457,13 +457,13 @@ struct bio *bio_alloc_bioset(gfp_t gfp_mask, int nr_iovecs, struct bio_set *bs)
> >                  * We solve this, and guarantee forward progress, with a rescuer
> >                  * workqueue per bio_set. If we go to allocate and there are
> >                  * bios on current->bio_list, we first try the allocation
> > -                * without __GFP_WAIT; if that fails, we punt those bios we
> > -                * would be blocking to the rescuer workqueue before we retry
> > -                * with the original gfp_flags.
> > +                * without __GFP_DIRECT_RECLAIM; if that fails, we punt those
> > +                * bios we would be blocking to the rescuer workqueue before
> > +                * we retry with the original gfp_flags.
> >                  */
> >
> >                 if (current->bio_list && !bio_list_empty(current->bio_list))
> > -                       gfp_mask &= ~__GFP_WAIT;
> > +                       gfp_mask &= ~__GFP_DIRECT_RECLAIM;
> 
> How about introduce helper function to mask out __GFP_DIRECT_RECLAIM?
> It can be used many places.
> 

In this case, the pattern for removing a single flag is easier to recognise
than a helper whose implementation must be examined.

> >                 p = mempool_alloc(bs->bio_pool, gfp_mask);
> >                 if (!p && gfp_mask != saved_gfp) {
> > diff --git a/block/blk-core.c b/block/blk-core.c
> > index 627ed0c593fb..e3605acaaffc 100644
> > --- a/block/blk-core.c
> > +++ b/block/blk-core.c
> > @@ -1156,8 +1156,8 @@ static struct request *__get_request(struct request_list *rl, int rw_flags,
> >   * @bio: bio to allocate request for (can be %NULL)
> >   * @gfp_mask: allocation mask
> >   *
> > - * Get a free request from @q.  If %__GFP_WAIT is set in @gfp_mask, this
> > - * function keeps retrying under memory pressure and fails iff @q is dead.
> > + * Get a free request from @q.  If %__GFP_DIRECT_RECLAIM is set in @gfp_mask,
> > + * this function keeps retrying under memory pressure and fails iff @q is dead.
> >   *
> >   * Must be called with @q->queue_lock held and,
> >   * Returns ERR_PTR on failure, with @q->queue_lock held.
> > @@ -1177,7 +1177,7 @@ static struct request *get_request(struct request_queue *q, int rw_flags,
> >         if (!IS_ERR(rq))
> >                 return rq;
> >
> > -       if (!(gfp_mask & __GFP_WAIT) || unlikely(blk_queue_dying(q))) {
> > +       if (!gfpflags_allow_blocking(gfp_mask) || unlikely(blk_queue_dying(q))) {
> >                 blk_put_rl(rl);
> >                 return rq;
> >         }
> > @@ -1255,11 +1255,11 @@ EXPORT_SYMBOL(blk_get_request);
> >   * BUG.
> >   *
> >   * WARNING: When allocating/cloning a bio-chain, careful consideration should be
> > - * given to how you allocate bios. In particular, you cannot use __GFP_WAIT for
> > - * anything but the first bio in the chain. Otherwise you risk waiting for IO
> > - * completion of a bio that hasn't been submitted yet, thus resulting in a
> > - * deadlock. Alternatively bios should be allocated using bio_kmalloc() instead
> > - * of bio_alloc(), as that avoids the mempool deadlock.
> > + * given to how you allocate bios. In particular, you cannot use
> > + * __GFP_DIRECT_RECLAIM for anything but the first bio in the chain. Otherwise
> > + * you risk waiting for IO completion of a bio that hasn't been submitted yet,
> > + * thus resulting in a deadlock. Alternatively bios should be allocated using
> > + * bio_kmalloc() instead of bio_alloc(), as that avoids the mempool deadlock.
> >   * If possible a big IO should be split into smaller parts when allocation
> >   * fails. Partial allocation should not be an error, or you risk a live-lock.
> >   */
> > diff --git a/block/blk-ioc.c b/block/blk-ioc.c
> > index 1a27f45ec776..381cb50a673c 100644
> > --- a/block/blk-ioc.c
> > +++ b/block/blk-ioc.c
> > @@ -289,7 +289,7 @@ struct io_context *get_task_io_context(struct task_struct *task,
> >  {
> >         struct io_context *ioc;
> >
> > -       might_sleep_if(gfp_flags & __GFP_WAIT);
> > +       might_sleep_if(gfpflags_allow_blocking(gfp_flags));
> >
> >         do {
> >                 task_lock(task);
> > diff --git a/block/blk-mq-tag.c b/block/blk-mq-tag.c
> > index 9b6e28830b82..a8b46659ce4e 100644
> > --- a/block/blk-mq-tag.c
> > +++ b/block/blk-mq-tag.c
> > @@ -264,7 +264,7 @@ static int bt_get(struct blk_mq_alloc_data *data,
> >         if (tag != -1)
> >                 return tag;
> >
> > -       if (!(data->gfp & __GFP_WAIT))
> > +       if (!gfpflags_allow_blocking(data->gfp))
> >                 return -1;
> >
> >         bs = bt_wait_ptr(bt, hctx);
> > diff --git a/block/blk-mq.c b/block/blk-mq.c
> > index 7d842db59699..7d80379d7a38 100644
> > --- a/block/blk-mq.c
> > +++ b/block/blk-mq.c
> > @@ -85,7 +85,7 @@ static int blk_mq_queue_enter(struct request_queue *q, gfp_t gfp)
> >                 if (percpu_ref_tryget_live(&q->mq_usage_counter))
> >                         return 0;
> >
> > -               if (!(gfp & __GFP_WAIT))
> > +               if (!gfpflags_allow_blocking(gfp))
> >                         return -EBUSY;
> >
> >                 ret = wait_event_interruptible(q->mq_freeze_wq,
> > @@ -261,11 +261,11 @@ struct request *blk_mq_alloc_request(struct request_queue *q, int rw, gfp_t gfp,
> >
> >         ctx = blk_mq_get_ctx(q);
> >         hctx = q->mq_ops->map_queue(q, ctx->cpu);
> > -       blk_mq_set_alloc_data(&alloc_data, q, gfp & ~__GFP_WAIT,
> > +       blk_mq_set_alloc_data(&alloc_data, q, gfp & ~__GFP_DIRECT_RECLAIM,
> >                         reserved, ctx, hctx);
> >
> >         rq = __blk_mq_alloc_request(&alloc_data, rw);
> > -       if (!rq && (gfp & __GFP_WAIT)) {
> > +       if (!rq && (gfp & __GFP_DIRECT_RECLAIM)) {
> >                 __blk_mq_run_hw_queue(hctx);
> >                 blk_mq_put_ctx(ctx);
> 
> Is there any reason not to use gfpflags_allow_nonblocking() here?
> There are some places not using this helper and reason isn't
> specified.
> 

Strictly speaking the helper could be used. However, in cases where the
same function manipulates or examines the flag in any way, I did not use
the helper. It's in all those cases, I thought the final result was
easier to follow.
> >
> >  /*
> > + * A caller that is willing to wait may enter direct reclaim and will
> > + * wake kswapd to reclaim pages in the background until the high
> > + * watermark is met. A caller may wish to clear __GFP_DIRECT_RECLAIM to
> > + * avoid unnecessary delays when a fallback option is available but
> > + * still allow kswapd to reclaim in the background. The kswapd flag
> > + * can be cleared when the reclaiming of pages would cause unnecessary
> > + * disruption.
> > + */
> > +#define __GFP_WAIT (__GFP_DIRECT_RECLAIM|__GFP_KSWAPD_RECLAIM)
> 
> Convention is that combination of gfp flags don't use __XXX.
> 

I don't understand. GFP_MOVABLE_MASK, GFP_USER and a bunch of other
combinations use __XXX.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
