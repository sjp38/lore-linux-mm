Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id C2D986B012A
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 21:32:16 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id rp16so1419522pbb.9
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 18:32:16 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id fi4si36136702pbb.193.2014.06.10.18.32.14
        for <linux-mm@kvack.org>;
        Tue, 10 Jun 2014 18:32:15 -0700 (PDT)
Date: Wed, 11 Jun 2014 10:32:18 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 03/10] mm, compaction: periodically drop lock and restore
 IRQs in scanners
Message-ID: <20140611013218.GD15630@bbox>
References: <1402305982-6928-1-git-send-email-vbabka@suse.cz>
 <1402305982-6928-3-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402305982-6928-3-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Mon, Jun 09, 2014 at 11:26:15AM +0200, Vlastimil Babka wrote:
> Compaction scanners regularly check for lock contention and need_resched()
> through the compact_checklock_irqsave() function. However, if there is no
> contention, the lock can be held and IRQ disabled for potentially long time.
> 
> This has been addressed by commit b2eef8c0d0 ("mm: compaction: minimise the
> time IRQs are disabled while isolating pages for migration") for the migration
> scanner. However, the refactoring done by commit 748446bb6b ("mm: compaction:
> acquire the zone->lru_lock as late as possible") has changed the conditions so
> that the lock is dropped only when there's contention on the lock or
> need_resched() is true. Also, need_resched() is checked only when the lock is
> already held. The comment "give a chance to irqs before checking need_resched"
> is therefore misleading, as IRQs remain disabled when the check is done.
> 
> This patch restores the behavior intended by commit b2eef8c0d0 and also tries
> to better balance and make more deterministic the time spent by checking for
> contention vs the time the scanners might run between the checks. It also
> avoids situations where checking has not been done often enough before. The
> result should be avoiding both too frequent and too infrequent contention
> checking, and especially the potentially long-running scans with IRQs disabled
> and no checking of need_resched() or for fatal signal pending, which can happen
> when many consecutive pages or pageblocks fail the preliminary tests and do not
> reach the later call site to compact_checklock_irqsave(), as explained below.
> 
> Before the patch:
> 
> In the migration scanner, compact_checklock_irqsave() was called each loop, if
> reached. If not reached, some lower-frequency checking could still be done if
> the lock was already held, but this would not result in aborting contended
> async compaction until reaching compact_checklock_irqsave() or end of
> pageblock. In the free scanner, it was similar but completely without the
> periodical checking, so lock can be potentially held until reaching the end of
> pageblock.
> 
> After the patch, in both scanners:
> 
> The periodical check is done as the first thing in the loop on each
> SWAP_CLUSTER_MAX aligned pfn, using the new compact_unlock_should_abort()
> function, which always unlocks the lock (if locked) and aborts async compaction
> if scheduling is needed or someone else holds the lock. It also aborts any type
> of compaction when a fatal signal is pending.
> 
> The compact_checklock_irqsave() function is replaced with a slightly different
> compact_trylock_irqsave(). The biggest difference is that the function is not
> called at all if the lock is already held. The periodical contention checking
> is left solely to compact_unlock_should_abort(). If the lock is not held, the
> function however does avoid contended run for async compaction by aborting when
> trylock fails. Sync compaction does not use trylock.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Generally, I like this but below a question.

> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> ---
> V2: do not consider need/cond_resched() in compact_trylock_irqsave(); spelling
>     remove inline: compaction.o size reduced
>  mm/compaction.c | 121 ++++++++++++++++++++++++++++++++++++--------------------
>  1 file changed, 79 insertions(+), 42 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index d37f4a8..e1a4283 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -185,54 +185,77 @@ static void update_pageblock_skip(struct compact_control *cc,
>  }
>  #endif /* CONFIG_COMPACTION */
>  
> -enum compact_contended should_release_lock(spinlock_t *lock)
> +/*
> + * Compaction requires the taking of some coarse locks that are potentially
> + * very heavily contended. For async compaction, back out if the lock cannot
> + * be taken immediately. For sync compaction, spin on the lock if needed.
> + *
> + * Returns true if the lock is held
> + * Returns false if the lock is not held and compaction should abort
> + */
> +static bool compact_trylock_irqsave(spinlock_t *lock,
> +			unsigned long *flags, struct compact_control *cc)
>  {
> -	if (need_resched())
> -		return COMPACT_CONTENDED_SCHED;
> -	else if (spin_is_contended(lock))
> -		return COMPACT_CONTENDED_LOCK;
> -	else
> -		return COMPACT_CONTENDED_NONE;
> +	if (cc->mode == MIGRATE_ASYNC) {
> +		if (!spin_trylock_irqsave(lock, *flags)) {
> +			cc->contended = COMPACT_CONTENDED_LOCK;
> +			return false;
> +		}
> +	} else {
> +		spin_lock_irqsave(lock, *flags);
> +	}
> +
> +	return true;
>  }
>  
>  /*
>   * Compaction requires the taking of some coarse locks that are potentially
> - * very heavily contended. Check if the process needs to be scheduled or
> - * if the lock is contended. For async compaction, back out in the event
> - * if contention is severe. For sync compaction, schedule.
> + * very heavily contended. The lock should be periodically unlocked to avoid
> + * having disabled IRQs for a long time, even when there is nobody waiting on
> + * the lock. It might also be that allowing the IRQs will result in
> + * need_resched() becoming true. If scheduling is needed, or somebody else
> + * has taken the lock, async compaction aborts. Sync compaction schedules.
> + * Either compaction type will also abort if a fatal signal is pending.
> + * In either case if the lock was locked, it is dropped and not regained.
>   *
> - * Returns true if the lock is held.
> - * Returns false if the lock is released and compaction should abort
> + * Returns true if compaction should abort due to fatal signal pending, or
> + *		async compaction due to lock contention or need to schedule
> + * Returns false when compaction can continue (sync compaction might have
> + *		scheduled)
>   */
> -static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
> -				      bool locked, struct compact_control *cc)
> +static bool compact_unlock_should_abort(spinlock_t *lock,
> +		unsigned long flags, bool *locked, struct compact_control *cc)
>  {
> -	enum compact_contended contended = should_release_lock(lock);
> +	if (*locked) {
> +		spin_unlock_irqrestore(lock, flags);
> +		*locked = false;
> +	}
>  
> -	if (contended) {
> -		if (locked) {
> -			spin_unlock_irqrestore(lock, *flags);
> -			locked = false;
> -		}
> +	if (fatal_signal_pending(current)) {
> +		cc->contended = COMPACT_CONTENDED_SCHED;
> +		return true;
> +	}
>  
> -		/* async aborts if taking too long or contended */
> -		if (cc->mode == MIGRATE_ASYNC) {
> -			cc->contended = contended;
> -			return false;
> +	if (cc->mode == MIGRATE_ASYNC) {
> +		if (need_resched()) {
> +			cc->contended = COMPACT_CONTENDED_SCHED;
> +			return true;
>  		}
> -
> +		if (spin_is_locked(lock)) {

Why do you use spin_is_locked instead of spin_is_contended?

> +			cc->contended = COMPACT_CONTENDED_LOCK;
> +			return true;
> +		}
> +	} else {
>  		cond_resched();
>  	}
>  
> -	if (!locked)
> -		spin_lock_irqsave(lock, *flags);
> -	return true;
> +	return false;
>  }
>  
>  /*
>   * Aside from avoiding lock contention, compaction also periodically checks
>   * need_resched() and either schedules in sync compaction or aborts async
> - * compaction. This is similar to what compact_checklock_irqsave() does, but
> + * compaction. This is similar to what compact_unlock_should_abort() does, but
>   * is used where no lock is concerned.
>   *
>   * Returns false when no scheduling was needed, or sync compaction scheduled.
> @@ -291,6 +314,16 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>  		int isolated, i;
>  		struct page *page = cursor;
>  
> +		/*
> +		 * Periodically drop the lock (if held) regardless of its
> +		 * contention, to give chance to IRQs. Abort async compaction
> +		 * if contended.
> +		 */
> +		if (!(blockpfn % SWAP_CLUSTER_MAX)
> +		    && compact_unlock_should_abort(&cc->zone->lock, flags,
> +								&locked, cc))
> +			break;
> +
>  		nr_scanned++;
>  		if (!pfn_valid_within(blockpfn))
>  			goto isolate_fail;
> @@ -308,8 +341,9 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>  		 * spin on the lock and we acquire the lock as late as
>  		 * possible.
>  		 */
> -		locked = compact_checklock_irqsave(&cc->zone->lock, &flags,
> -								locked, cc);
> +		if (!locked)
> +			locked = compact_trylock_irqsave(&cc->zone->lock,
> +								&flags, cc);
>  		if (!locked)
>  			break;
>  
> @@ -514,13 +548,15 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  
>  	/* Time to isolate some pages for migration */
>  	for (; low_pfn < end_pfn; low_pfn++) {
> -		/* give a chance to irqs before checking need_resched() */
> -		if (locked && !(low_pfn % SWAP_CLUSTER_MAX)) {
> -			if (should_release_lock(&zone->lru_lock)) {
> -				spin_unlock_irqrestore(&zone->lru_lock, flags);
> -				locked = false;
> -			}
> -		}
> +		/*
> +		 * Periodically drop the lock (if held) regardless of its
> +		 * contention, to give chance to IRQs. Abort async compaction
> +		 * if contended.
> +		 */
> +		if (!(low_pfn % SWAP_CLUSTER_MAX)
> +		    && compact_unlock_should_abort(&zone->lru_lock, flags,
> +								&locked, cc))
> +			break;
>  
>  		/*
>  		 * migrate_pfn does not necessarily start aligned to a
> @@ -622,10 +658,11 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  		    page_count(page) > page_mapcount(page))
>  			continue;
>  
> -		/* Check if it is ok to still hold the lock */
> -		locked = compact_checklock_irqsave(&zone->lru_lock, &flags,
> -								locked, cc);
> -		if (!locked || fatal_signal_pending(current))
> +		/* If the lock is not held, try to take it */
> +		if (!locked)
> +			locked = compact_trylock_irqsave(&zone->lru_lock,
> +								&flags, cc);
> +		if (!locked)
>  			break;
>  
>  		/* Recheck PageLRU and PageTransHuge under lock */
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
