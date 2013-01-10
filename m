Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id DB0C56B005D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 04:25:12 -0500 (EST)
Date: Thu, 10 Jan 2013 09:25:11 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Message-ID: <20130110092511.GA32333@dcvr.yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <20130102200848.GA4500@dcvr.yhbt.net>
 <20130104160148.GB3885@suse.de>
 <20130106120700.GA24671@dcvr.yhbt.net>
 <20130107122516.GC3885@suse.de>
 <20130107223850.GA21311@dcvr.yhbt.net>
 <20130108224313.GA13304@suse.de>
 <20130108232325.GA5948@dcvr.yhbt.net>
 <20130109133746.GD13304@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130109133746.GD13304@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Mel Gorman <mgorman@suse.de> wrote:
> page->pfmemalloc can be left set for captured pages so try this but as
> capture is rarely used I'm strongly favouring a partial revert even if
> this works for you. I haven't reproduced this using your workload yet
> but I have found that high-order allocation stress tests for 3.8-rc2 are
> completely screwed. 71% success rates at rest in 3.7 and 6% in 3.8-rc2 so
> I have to chase that down too.
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9d20c13..c242d21 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2180,8 +2180,10 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  	current->flags &= ~PF_MEMALLOC;
>  
>  	/* If compaction captured a page, prep and use it */
> -	if (page && !prep_new_page(page, order, gfp_mask))
> +	if (page && !prep_new_page(page, order, gfp_mask)) {
> +		page->pfmemalloc = false;
>  		goto got_page;
> +	}
>  
>  	if (*did_some_progress != COMPACT_SKIPPED) {
>  		/* Page migration frees to the PCP lists but we want merging */

This (on top of your previous patch) seems to work great after several
hours of testing on both my VM and real machine.  I haven't tried your
partial revert, yet.  Will try that in a bit on the VM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
