Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 85C238D0039
	for <linux-mm@kvack.org>; Sun, 27 Feb 2011 21:24:07 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id EE85F3EE0BB
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 11:24:03 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D111345DE5E
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 11:24:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B6B7A45DE59
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 11:24:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A6AC3E18003
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 11:24:03 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 63478E08003
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 11:24:03 +0900 (JST)
Date: Mon, 28 Feb 2011 11:17:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] mm: compaction: Minimise the time IRQs are disabled
 while isolating pages for migration
Message-Id: <20110228111746.34f3f3e0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1298664299-10270-3-git-send-email-mel@csn.ul.ie>
References: <1298664299-10270-1-git-send-email-mel@csn.ul.ie>
	<1298664299-10270-3-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arthur Marsh <arthur.marsh@internode.on.net>, Clemens Ladisch <cladisch@googlemail.com>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, 25 Feb 2011 20:04:59 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

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
>  		if (!pfn_valid_within(low_pfn))
>  			continue;
>  		nr_scanned++;

Hmm.... I don't like this kind of complicated locks and 'give-a-chance' logic.

BTW, I forget why we always take zone->lru_lock with IRQ disabled....
rotate_lru_page() is a bad thing ? 
If so, I think it can be implemented in other way...


Thanks,
-Kame









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
