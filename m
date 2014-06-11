Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 267A86B0128
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 21:10:16 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id ma3so160427pbc.0
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 18:10:15 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id fc3si4648919pad.241.2014.06.10.18.10.14
        for <linux-mm@kvack.org>;
        Tue, 10 Jun 2014 18:10:15 -0700 (PDT)
Date: Wed, 11 Jun 2014 10:10:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 02/10] mm, compaction: report compaction as contended
 only due to lock contention
Message-ID: <20140611011019.GC15630@bbox>
References: <1402305982-6928-1-git-send-email-vbabka@suse.cz>
 <1402305982-6928-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402305982-6928-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Mon, Jun 09, 2014 at 11:26:14AM +0200, Vlastimil Babka wrote:
> Async compaction aborts when it detects zone lock contention or need_resched()
> is true. David Rientjes has reported that in practice, most direct async
> compactions for THP allocation abort due to need_resched(). This means that a
> second direct compaction is never attempted, which might be OK for a page
> fault, but hugepaged is intended to attempt a sync compaction in such case and
> in these cases it won't.
> 
> This patch replaces "bool contended" in compact_control with an enum that
> distinguieshes between aborting due to need_resched() and aborting due to lock
> contention. This allows propagating the abort through all compaction functions
> as before, but declaring the direct compaction as contended only when lock
> contantion has been detected.
> 
> As a result, hugepaged will proceed with second sync compaction as intended,
> when the preceding async compaction aborted due to need_resched().

You said "second direct compaction is never attempted, which might be OK
for a page fault" and said "hugepagd is intented to attempt a sync compaction"
so I feel you want to handle khugepaged so special unlike other direct compact
(ex, page fault).

By this patch, direct compaction take care only lock contention, not rescheduling
so that pop questions.

Is it okay not to consider need_resched in direct compaction really?
We have taken care of it in direct reclaim path so why direct compaction is
so special?

Why does khugepaged give up easily if lock contention/need_resched happens?
khugepaged is important for success ratio as I read your description so IMO,
khugepaged should do synchronously without considering early bail out by
lock/rescheduling.

If it causes problems, user should increase scan_sleep_millisecs/alloc_sleep_millisecs,
which is exactly the knob for that cases.

So, my point is how about making khugepaged doing always dumb synchronous
compaction thorough PG_KHUGEPAGED or GFP_SYNC_TRANSHUGE?

> 
> Reported-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> ---
>  mm/compaction.c | 20 ++++++++++++++------
>  mm/internal.h   | 15 +++++++++++----
>  2 files changed, 25 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index b73b182..d37f4a8 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -185,9 +185,14 @@ static void update_pageblock_skip(struct compact_control *cc,
>  }
>  #endif /* CONFIG_COMPACTION */
>  
> -static inline bool should_release_lock(spinlock_t *lock)
> +enum compact_contended should_release_lock(spinlock_t *lock)
>  {
> -	return need_resched() || spin_is_contended(lock);
> +	if (need_resched())
> +		return COMPACT_CONTENDED_SCHED;
> +	else if (spin_is_contended(lock))
> +		return COMPACT_CONTENDED_LOCK;
> +	else
> +		return COMPACT_CONTENDED_NONE;
>  }
>  
>  /*
> @@ -202,7 +207,9 @@ static inline bool should_release_lock(spinlock_t *lock)
>  static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
>  				      bool locked, struct compact_control *cc)
>  {
> -	if (should_release_lock(lock)) {
> +	enum compact_contended contended = should_release_lock(lock);
> +
> +	if (contended) {
>  		if (locked) {
>  			spin_unlock_irqrestore(lock, *flags);
>  			locked = false;
> @@ -210,7 +217,7 @@ static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
>  
>  		/* async aborts if taking too long or contended */
>  		if (cc->mode == MIGRATE_ASYNC) {
> -			cc->contended = true;
> +			cc->contended = contended;
>  			return false;
>  		}
>  
> @@ -236,7 +243,7 @@ static inline bool compact_should_abort(struct compact_control *cc)
>  	/* async compaction aborts if contended */
>  	if (need_resched()) {
>  		if (cc->mode == MIGRATE_ASYNC) {
> -			cc->contended = true;
> +			cc->contended = COMPACT_CONTENDED_SCHED;
>  			return true;
>  		}
>  
> @@ -1095,7 +1102,8 @@ static unsigned long compact_zone_order(struct zone *zone, int order,
>  	VM_BUG_ON(!list_empty(&cc.freepages));
>  	VM_BUG_ON(!list_empty(&cc.migratepages));
>  
> -	*contended = cc.contended;
> +	/* We only signal lock contention back to the allocator */
> +	*contended = cc.contended == COMPACT_CONTENDED_LOCK;
>  	return ret;
>  }
>  
> diff --git a/mm/internal.h b/mm/internal.h
> index 7f22a11f..4659e8e 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -117,6 +117,13 @@ extern int user_min_free_kbytes;
>  
>  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
>  
> +/* Used to signal whether compaction detected need_sched() or lock contention */
> +enum compact_contended {
> +	COMPACT_CONTENDED_NONE = 0, /* no contention detected */
> +	COMPACT_CONTENDED_SCHED,    /* need_sched() was true */
> +	COMPACT_CONTENDED_LOCK,     /* zone lock or lru_lock was contended */
> +};
> +
>  /*
>   * in mm/compaction.c
>   */
> @@ -144,10 +151,10 @@ struct compact_control {
>  	int order;			/* order a direct compactor needs */
>  	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
>  	struct zone *zone;
> -	bool contended;			/* True if a lock was contended, or
> -					 * need_resched() true during async
> -					 * compaction
> -					 */
> +	enum compact_contended contended; /* Signal need_sched() or lock
> +					   * contention detected during
> +					   * compaction
> +					   */
>  };
>  
>  unsigned long
> -- 
> 1.8.4.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
