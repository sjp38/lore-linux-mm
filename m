Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AB53560021B
	for <linux-mm@kvack.org>; Fri,  1 Jan 2010 18:20:31 -0500 (EST)
Subject: Re: [PATCH] mm, lockdep: annotate reclaim context to zone reclaim
 too
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1262339141-4682-1-git-send-email-kosaki.motohiro@jp.fujitsu.com>
References: 
	 <1262339141-4682-1-git-send-email-kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 02 Jan 2010 00:19:46 +0100
Message-ID: <1262387986.16572.234.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-01-01 at 18:45 +0900, KOSAKI Motohiro wrote:
> Commit cf40bd16fd (lockdep: annotate reclaim context) introduced reclaim
> context annotation. But it didn't annotate zone reclaim. This patch do it.

And yet you didn't CC anyone involved in that patch, nor explain why you
think it necessary, massive FAIL.

The lockdep annotations cover all of kswapd() and direct reclaim through
__alloc_pages_direct_reclaim(). So why would you need an explicit
annotation in __zone_reclaim()?

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/vmscan.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 2bbee91..a039e78 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2547,6 +2547,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  	 * and RECLAIM_SWAP.
>  	 */
>  	p->flags |= PF_MEMALLOC | PF_SWAPWRITE;
> +	lockdep_set_current_reclaim_state(gfp_mask);
>  	reclaim_state.reclaimed_slab = 0;
>  	p->reclaim_state = &reclaim_state;
>  
> @@ -2590,6 +2591,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  
>  	p->reclaim_state = NULL;
>  	current->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE);
> +	lockdep_clear_current_reclaim_state();
>  	return sc.nr_reclaimed >= nr_pages;
>  }
>  


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
