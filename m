Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 743A56B01E6
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:42:04 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58Bg2nT012449
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:42:02 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C25C45DE58
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:02 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id CEC6C45DE52
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:01 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A2B1F1DB8043
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:01 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3514E1DB8040
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:01 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 11/18] oom: avoid oom killer for lowmem allocations
In-Reply-To: <alpine.DEB.2.00.1006061525450.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061525450.32225@chino.kir.corp.google.com>
Message-Id: <20100608203551.766F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:42:00 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> If memory has been depleted in lowmem zones even with the protection
> afforded to it by /proc/sys/vm/lowmem_reserve_ratio, it is unlikely that
> killing current users will help.  The memory is either reclaimable (or
> migratable) already, in which case we should not invoke the oom killer at
> all, or it is pinned by an application for I/O.  Killing such an
> application may leave the hardware in an unspecified state and there is no
> guarantee that it will be able to make a timely exit.
> 
> Lowmem allocations are now failed in oom conditions when __GFP_NOFAIL is
> not used so that the task can perhaps recover or try again later.
> 
> Previously, the heuristic provided some protection for those tasks with
> CAP_SYS_RAWIO, but this is no longer necessary since we will not be
> killing tasks for the purposes of ISA allocations.
> 
> high_zoneidx is gfp_zone(gfp_flags), meaning that ZONE_NORMAL will be the
> default for all allocations that are not __GFP_DMA, __GFP_DMA32,
> __GFP_HIGHMEM, and __GFP_MOVABLE on kernels configured to support those
> flags.  Testing for high_zoneidx being less than ZONE_NORMAL will only
> return true for allocations that have either __GFP_DMA or __GFP_DMA32.
> 
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/page_alloc.c |   29 ++++++++++++++++++++---------
>  1 files changed, 20 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1759,6 +1759,9 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  		/* The OOM killer will not help higher order allocs */
>  		if (order > PAGE_ALLOC_COSTLY_ORDER)
>  			goto out;
> +		/* The OOM killer does not needlessly kill tasks for lowmem */
> +		if (high_zoneidx < ZONE_NORMAL)
> +			goto out;
>  		/*
>  		 * GFP_THISNODE contains __GFP_NORETRY and we never hit this.
>  		 * Sanity check for bare calls of __GFP_THISNODE, not real OOM.
> @@ -2052,15 +2055,23 @@ rebalance:
>  			if (page)
>  				goto got_pg;
>  
> -			/*
> -			 * The OOM killer does not trigger for high-order
> -			 * ~__GFP_NOFAIL allocations so if no progress is being
> -			 * made, there are no other options and retrying is
> -			 * unlikely to help.
> -			 */
> -			if (order > PAGE_ALLOC_COSTLY_ORDER &&
> -						!(gfp_mask & __GFP_NOFAIL))
> -				goto nopage;
> +			if (!(gfp_mask & __GFP_NOFAIL)) {
> +				/*
> +				 * The oom killer is not called for high-order
> +				 * allocations that may fail, so if no progress
> +				 * is being made, there are no other options and
> +				 * retrying is unlikely to help.
> +				 */
> +				if (order > PAGE_ALLOC_COSTLY_ORDER)
> +					goto nopage;
> +				/*
> +				 * The oom killer is not called for lowmem
> +				 * allocations to prevent needlessly killing
> +				 * innocent tasks.
> +				 */
> +				if (high_zoneidx < ZONE_NORMAL)
> +					goto nopage;
> +			}
>  
>  			goto restart;
>  		}

pulled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
