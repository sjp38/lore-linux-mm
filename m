Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D0E496001DA
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 06:24:39 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp03.in.ibm.com (8.14.3/8.13.1) with ESMTP id o1NBOWpx024258
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 16:54:32 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1NBOWwR2924758
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 16:54:32 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1NBOWfE029533
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 22:24:32 +1100
Date: Tue, 23 Feb 2010 16:54:31 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [patch -mm 8/9 v2] oom: avoid oom killer for lowmem allocations
Message-ID: <20100223112431.GA8871@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100216085706.c7af93e1.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1002151606320.14484@chino.kir.corp.google.com>
 <20100216064402.GC5723@laptop>
 <alpine.DEB.2.00.1002152334260.7470@chino.kir.corp.google.com>
 <20100216075330.GJ5723@laptop>
 <alpine.DEB.2.00.1002160024370.15201@chino.kir.corp.google.com>
 <20100217084858.fd72ec4f.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1002161555170.11952@chino.kir.corp.google.com>
 <20100217090303.6bd64209.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1002161609200.11952@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002161609200.11952@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* David Rientjes <rientjes@google.com> [2010-02-16 16:21:11]:

> On Wed, 17 Feb 2010, KAMEZAWA Hiroyuki wrote:
> 
> > > On Wed, 17 Feb 2010, KAMEZAWA Hiroyuki wrote:
> > > 
> > > > > > > I'll add this check to __alloc_pages_may_oom() for the !(gfp_mask & 
> > > > > > > __GFP_NOFAIL) path since we're all content with endlessly looping.
> > > > > > 
> > > > > > Thanks. Yes endlessly looping is far preferable to randomly oopsing
> > > > > > or corrupting memory.
> > > > > > 
> > > > > 
> > > > > Here's the new patch for your consideration.
> > > > > 
> > > > 
> > > > Then, can we take kdump in this endlessly looping situaton ?
> > > > 
> > > > panic_on_oom=always + kdump can do that. 
> > > > 
> > > 
> > > The endless loop is only helpful if something is going to free memory 
> > > external to the current page allocation: either another task with 
> > > __GFP_WAIT | __GFP_FS that invokes the oom killer, a task that frees 
> > > memory, or a task that exits.
> > > 
> > > The most notable endless loop in the page allocator is the one when a task 
> > > has been oom killed, gets access to memory reserves, and then cannot find 
> > > a page for a __GFP_NOFAIL allocation:
> > > 
> > > 	do {
> > > 		page = get_page_from_freelist(gfp_mask, nodemask, order,
> > > 			zonelist, high_zoneidx, ALLOC_NO_WATERMARKS,
> > > 			preferred_zone, migratetype);
> > > 
> > > 		if (!page && gfp_mask & __GFP_NOFAIL)
> > > 			congestion_wait(BLK_RW_ASYNC, HZ/50);
> > > 	} while (!page && (gfp_mask & __GFP_NOFAIL));
> > > 
> > > We don't expect any such allocations to happen during the exit path, but 
> > > we could probably find some in the fs layer.
> > > 
> > > I don't want to check sysctl_panic_on_oom in the page allocator because it 
> > > would start panicking the machine unnecessarily for the integrity 
> > > metadata GFP_NOIO | __GFP_NOFAIL allocation, for any 
> > > order > PAGE_ALLOC_COSTLY_ORDER, or for users who can't lock the zonelist 
> > > for oom kill that wouldn't have panicked before.
> > > 
> > 
> > Then, why don't you check higzone_idx in oom_kill.c
> > 
> 
> out_of_memory() doesn't return a value to specify whether the page 
> allocator should retry the allocation or just return NULL, all that policy 
> is kept in mm/page_alloc.c.  For highzone_idx < ZONE_NORMAL, we want to 
> fail the allocation when !(gfp_mask & __GFP_NOFAIL) and call the oom 
> killer when it's __GFP_NOFAIL.
> ---
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1696,6 +1696,9 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  		/* The OOM killer will not help higher order allocs */
>  		if (order > PAGE_ALLOC_COSTLY_ORDER)
>  			goto out;
> +		/* The OOM killer does not needlessly kill tasks for lowmem */
> +		if (high_zoneidx < ZONE_NORMAL)
> +			goto out;

I am not sure if this is a good idea, ZONE_DMA could have a lot of
memory on some architectures. IIUC, we return NULL for allocations
from ZONE_DMA? What is the reason for the heuristic?

>  		/*
>  		 * GFP_THISNODE contains __GFP_NORETRY and we never hit this.
>  		 * Sanity check for bare calls of __GFP_THISNODE, not real OOM.
> @@ -1924,15 +1927,23 @@ rebalance:
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

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
