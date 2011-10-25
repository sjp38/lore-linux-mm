Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8DF656B0023
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 18:10:11 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p9PMA9B0026225
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 15:10:09 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by wpaz13.hot.corp.google.com with ESMTP id p9PM3HlE029425
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 15:10:08 -0700
Received: by pzk2 with SMTP id 2so3894126pzk.8
        for <linux-mm@kvack.org>; Tue, 25 Oct 2011 15:10:08 -0700 (PDT)
Date: Tue, 25 Oct 2011 15:10:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
In-Reply-To: <1319524789-22818-1-git-send-email-ccross@android.com>
Message-ID: <alpine.DEB.2.00.1110251503490.26017@chino.kir.corp.google.com>
References: <1319524789-22818-1-git-send-email-ccross@android.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Mon, 24 Oct 2011, Colin Cross wrote:

> Under the following conditions, __alloc_pages_slowpath can loop
> forever:
> gfp_mask & __GFP_WAIT is true
> gfp_mask & __GFP_FS is false
> reclaim and compaction make no progress
> order <= PAGE_ALLOC_COSTLY_ORDER
> 

The oom killer is only called for __GFP_FS because we want to ensure that 
we don't inadvertently kill something if we didn't have a chance to at 
least make a good effort at direct reclaim.  There's a very high liklihood 
that direct reclaim would succeed with __GFP_FS, so we loop endlessly 
waiting for either kswapd to reclaim in the background even though it 
might not be able to because of filesystem locks or another allocation 
happens in a context that allows reclaim to succeed or oom killing.

For low-order allocations (those at or below PAGE_ALLOC_COSTLY_ORDER) 
where fragmentation isn't a huge issue, __GFP_WAIT && !__GFP_FS && 
!did_some_progress makes sense.

> These conditions happen very often during suspend and resume,
> when pm_restrict_gfp_mask() effectively converts all GFP_KERNEL
> allocations into __GFP_WAIT.
> 

This is the problem.  All allocations now have no chance of ever having 
direct reclaim succeed nor the oom killer called.  It seems like you would 
want pm_restrict_gfp_mask() to also include __GFP_NORETRY and ensure it 
can never be called for __GFP_NOFAIL.

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index fef8dc3..dcd99b3 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2193,6 +2193,10 @@ rebalance:
>  			}
>  
>  			goto restart;
> +		} else {
> +			/* If we aren't going to try the OOM killer, give up */
> +			if (!(gfp_mask & __GFP_NOFAIL))
> +				goto nopage;
>  		}
>  	}
>  

Nack on this, it is going to cause many very verbose allocation failures 
(if !__GFP_NOWARN) when not using suspend because we're not in a context 
where we can do sensible reclaim or compaction and presently kswapd can 
either reclaim or another allocation will allow low-order amounts of 
memory to be reclaimed or the oom killer to free some memory.  It would 
introduce a regression into page allocation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
