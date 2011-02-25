Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8FAFA8D0039
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 17:32:34 -0500 (EST)
Date: Fri, 25 Feb 2011 23:32:04 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] mm: compaction: Minimise the time IRQs are disabled
 while isolating pages for migration
Message-ID: <20110225223204.GW25382@cmpxchg.org>
References: <1298664299-10270-1-git-send-email-mel@csn.ul.ie>
 <1298664299-10270-3-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1298664299-10270-3-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arthur Marsh <arthur.marsh@internode.on.net>, Clemens Ladisch <cladisch@googlemail.com>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Feb 25, 2011 at 08:04:59PM +0000, Mel Gorman wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> compaction_alloc() isolates pages for migration in isolate_migratepages. While
> it's scanning, IRQs are disabled on the mistaken assumption the scanning
> should be short. Tests show this to be true for the most part but
> contention times on the LRU lock can be increased. Before this patch,
> the IRQ disabled times for a simple test looked like
> 
> Total sampled time IRQs off (not real total time): 5493
> Event shrink_inactive_list..shrink_zone                  1596 us count 1
> Event shrink_inactive_list..shrink_zone                  1530 us count 1
> Event shrink_inactive_list..shrink_zone                   956 us count 1
> Event shrink_inactive_list..shrink_zone                   541 us count 1
> Event shrink_inactive_list..shrink_zone                   531 us count 1
> Event split_huge_page..add_to_swap                        232 us count 1
> Event save_args..call_softirq                              36 us count 1
> Event save_args..call_softirq                              35 us count 2
> Event __wake_up..__wake_up                                  1 us count 1
> 
> This patch reduces the worst-case IRQs-disabled latencies by releasing the
> lock every SWAP_CLUSTER_MAX pages that are scanned and releasing the CPU if
> necessary. The cost of this is that the processing performing compaction will
> be slower but IRQs being disabled for too long a time has worse consequences
> as the following report shows;
> 
> Total sampled time IRQs off (not real total time): 4367
> Event shrink_inactive_list..shrink_zone                   881 us count 1
> Event shrink_inactive_list..shrink_zone                   875 us count 1
> Event shrink_inactive_list..shrink_zone                   868 us count 1
> Event shrink_inactive_list..shrink_zone                   555 us count 1
> Event split_huge_page..add_to_swap                        495 us count 1
> Event compact_zone..compact_zone_order                    269 us count 1
> Event split_huge_page..add_to_swap                        266 us count 1
> Event shrink_inactive_list..shrink_zone                    85 us count 1
> Event save_args..call_softirq                              36 us count 2
> Event __wake_up..__wake_up                                  1 us count 1
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/compaction.c |   18 ++++++++++++++++++
>  1 files changed, 18 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 11d88a2..ec9eb0f 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -279,9 +279,27 @@ static unsigned long isolate_migratepages(struct zone *zone,
>  	}
>  
>  	/* Time to isolate some pages for migration */
> +	cond_resched();
>  	spin_lock_irq(&zone->lru_lock);
>  	for (; low_pfn < end_pfn; low_pfn++) {
>  		struct page *page;
> +		bool unlocked = false;
> +
> +		/* give a chance to irqs before checking need_resched() */
> +		if (!((low_pfn+1) % SWAP_CLUSTER_MAX)) {
> +			spin_unlock_irq(&zone->lru_lock);
> +			unlocked = true;
> +		}
> +		if (need_resched() || spin_is_contended(&zone->lru_lock)) {
> +			if (!unlocked)
> +				spin_unlock_irq(&zone->lru_lock);
> +			cond_resched();
> +			spin_lock_irq(&zone->lru_lock);
> +			if (fatal_signal_pending(current))
> +				break;
> +		} else if (unlocked)
> +			spin_lock_irq(&zone->lru_lock);
> +

I don't understand why this conditional is broken up like this.
cond_resched() will have the right checks anyway.  Okay, you would
save fatal_signal_pending() in the 'did one cluster' case.  Is it that
expensive?  Couldn't this be simpler like

		did_cluster = ((low_pfn + 1) % SWAP_CLUSTER_MAX) == 0
		lock_contended = spin_is_contended(&zone->lru_lock);
		if (did_cluster || lock_contended || need_resched()) {
			spin_unlock_irq(&zone->lru_lock);
			cond_resched();
			spin_lock_irq(&zone->lru_lock);
			if (fatal_signal_pending(current))
				break;
		}

instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
