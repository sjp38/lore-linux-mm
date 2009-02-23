Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 19F2E6B00BE
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 10:33:17 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 11/20] Inline get_page_from_freelist() in the fast-path
Date: Tue, 24 Feb 2009 02:32:37 +1100
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <1235344649-18265-12-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1235344649-18265-12-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902240232.39140.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Monday 23 February 2009 10:17:20 Mel Gorman wrote:
> In the best-case scenario, use an inlined version of
> get_page_from_freelist(). This increases the size of the text but avoids
> time spent pushing arguments onto the stack.

I'm quite fond of inlining ;) But it can increase register pressure as
well as icache footprint as well. x86-64 isn't spilling a lot more
registers to stack after these changes, is it?

Also,


> @@ -1780,8 +1791,8 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int
> order, if (!preferred_zone)
>  		return NULL;
>
> -	/* First allocation attempt */
> -	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
> +	/* First allocation attempt. Fastpath uses inlined version */
> +	page = __get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
>  			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET,
>  			preferred_zone, migratetype);
>  	if (unlikely(!page))

I think in a common case where there is background reclaim going on,
it will be quite common to fail this, won't it? (I haven't run
statistics though).

In which case you will get extra icache footprint. What speedup does
it give in the cache-hot microbenchmark case?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
