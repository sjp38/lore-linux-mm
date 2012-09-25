Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id F06426B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 03:02:13 -0400 (EDT)
Date: Tue, 25 Sep 2012 16:05:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 5/9] mm: compaction: Acquire the zone->lru_lock as late
 as possible
Message-ID: <20120925070517.GK13234@bbox>
References: <1348224383-1499-1-git-send-email-mgorman@suse.de>
 <1348224383-1499-6-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1348224383-1499-6-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Mel,

I have a question below.

On Fri, Sep 21, 2012 at 11:46:19AM +0100, Mel Gorman wrote:
> Compactions migrate scanner acquires the zone->lru_lock when scanning a range
> of pages looking for LRU pages to acquire. It does this even if there are
> no LRU pages in the range. If multiple processes are compacting then this
> can cause severe locking contention. To make matters worse commit b2eef8c0
> (mm: compaction: minimise the time IRQs are disabled while isolating pages
> for migration) releases the lru_lock every SWAP_CLUSTER_MAX pages that are
> scanned.
> 
> This patch makes two changes to how the migrate scanner acquires the LRU
> lock. First, it only releases the LRU lock every SWAP_CLUSTER_MAX pages if
> the lock is contended. This reduces the number of times it unnecessarily
> disables and re-enables IRQs. The second is that it defers acquiring the
> LRU lock for as long as possible. If there are no LRU pages or the only
> LRU pages are transhuge then the LRU lock will not be acquired at all
> which reduces contention on zone->lru_lock.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
>  mm/compaction.c |   63 +++++++++++++++++++++++++++++++++++++------------------
>  1 file changed, 43 insertions(+), 20 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 6b55491..a6068ff 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -50,6 +50,11 @@ static inline bool migrate_async_suitable(int migratetype)
>  	return is_migrate_cma(migratetype) || migratetype == MIGRATE_MOVABLE;
>  }
>  
> +static inline bool should_release_lock(spinlock_t *lock)
> +{
> +	return need_resched() || spin_is_contended(lock);
> +}
> +
>  /*
>   * Compaction requires the taking of some coarse locks that are potentially
>   * very heavily contended. Check if the process needs to be scheduled or
> @@ -62,7 +67,7 @@ static inline bool migrate_async_suitable(int migratetype)
>  static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
>  				      bool locked, struct compact_control *cc)
>  {
> -	if (need_resched() || spin_is_contended(lock)) {
> +	if (should_release_lock(lock)) {
>  		if (locked) {
>  			spin_unlock_irqrestore(lock, *flags);
>  			locked = false;
> @@ -327,7 +332,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  	isolate_mode_t mode = 0;
>  	struct lruvec *lruvec;
>  	unsigned long flags;
> -	bool locked;
> +	bool locked = false;
>  
>  	/*
>  	 * Ensure that there are not too many pages isolated from the LRU
> @@ -347,23 +352,17 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  
>  	/* Time to isolate some pages for migration */
>  	cond_resched();
> -	spin_lock_irqsave(&zone->lru_lock, flags);
> -	locked = true;
>  	for (; low_pfn < end_pfn; low_pfn++) {
>  		struct page *page;
>  
>  		/* give a chance to irqs before checking need_resched() */
> -		if (!((low_pfn+1) % SWAP_CLUSTER_MAX)) {
> -			spin_unlock_irqrestore(&zone->lru_lock, flags);
> -			locked = false;
> +		if (locked && !((low_pfn+1) % SWAP_CLUSTER_MAX)) {
> +			if (should_release_lock(&zone->lru_lock)) {
> +				spin_unlock_irqrestore(&zone->lru_lock, flags);
> +				locked = false;
> +			}
>  		}
>  
> -		/* Check if it is ok to still hold the lock */
> -		locked = compact_checklock_irqsave(&zone->lru_lock, &flags,
> -								locked, cc);
> -		if (!locked || fatal_signal_pending(current))
> -			break;
> -
>  		/*
>  		 * migrate_pfn does not necessarily start aligned to a
>  		 * pageblock. Ensure that pfn_valid is called when moving
> @@ -403,21 +402,38 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  		pageblock_nr = low_pfn >> pageblock_order;
>  		if (!cc->sync && last_pageblock_nr != pageblock_nr &&
>  		    !migrate_async_suitable(get_pageblock_migratetype(page))) {
> -			low_pfn += pageblock_nr_pages;
> -			low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
> -			last_pageblock_nr = pageblock_nr;
> -			continue;
> +			goto next_pageblock;
>  		}
>  
> +		/* Check may be lockless but that's ok as we recheck later */
>  		if (!PageLRU(page))
>  			continue;
>  
>  		/*
> -		 * PageLRU is set, and lru_lock excludes isolation,
> -		 * splitting and collapsing (collapsing has already
> -		 * happened if PageLRU is set).
> +		 * PageLRU is set. lru_lock normally excludes isolation
> +		 * splitting and collapsing (collapsing has already happened
> +		 * if PageLRU is set) but the lock is not necessarily taken
> +		 * here and it is wasteful to take it just to check transhuge.
> +		 * Check transhuge without lock and skip if it's either a
> +		 * transhuge or hugetlbfs page.
>  		 */
>  		if (PageTransHuge(page)) {
> +			if (!locked)
> +				goto next_pageblock;

Why skip all pages in a pageblock if !locked?
Shouldn't we add some comment?

> +			low_pfn += (1 << compound_order(page)) - 1;
> +			continue;
> +		}
> +
> +		/* Check if it is ok to still hold the lock */
> +		locked = compact_checklock_irqsave(&zone->lru_lock, &flags,
> +								locked, cc);
> +		if (!locked || fatal_signal_pending(current))
> +			break;
> +
> +		/* Recheck PageLRU and PageTransHuge under lock */
> +		if (!PageLRU(page))
> +			continue;
> +		if (PageTransHuge(page)) {
>  			low_pfn += (1 << compound_order(page)) - 1;
>  			continue;
>  		}
> @@ -444,6 +460,13 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  			++low_pfn;
>  			break;
>  		}
> +
> +		continue;
> +
> +next_pageblock:
> +		low_pfn += pageblock_nr_pages;
> +		low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
> +		last_pageblock_nr = pageblock_nr;
>  	}
>  
>  	acct_isolated(zone, locked, cc);
> -- 
> 1.7.9.2
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
