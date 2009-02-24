Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DE6136B00AF
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 08:32:56 -0500 (EST)
Date: Tue, 24 Feb 2009 13:32:53 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 11/20] Inline get_page_from_freelist() in the fast-path
Message-ID: <20090224133253.GB26239@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <1235344649-18265-12-git-send-email-mel@csn.ul.ie> <200902240232.39140.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200902240232.39140.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 24, 2009 at 02:32:37AM +1100, Nick Piggin wrote:
> On Monday 23 February 2009 10:17:20 Mel Gorman wrote:
> > In the best-case scenario, use an inlined version of
> > get_page_from_freelist(). This increases the size of the text but avoids
> > time spent pushing arguments onto the stack.
> 
> I'm quite fond of inlining ;) But it can increase register pressure as
> well as icache footprint as well. x86-64 isn't spilling a lot more
> registers to stack after these changes, is it?
> 

I didn't actually check that closely so I don't know for sure. Is there a
handier way of figuring it out than eyeballing the assembly? In the end
I dropped the inline of this function anyway. It means the patches
reduce rather than increase text size which is a bit more clear-cut.

> Also,
> 
> 
> > @@ -1780,8 +1791,8 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int
> > order, if (!preferred_zone)
> >  		return NULL;
> >
> > -	/* First allocation attempt */
> > -	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
> > +	/* First allocation attempt. Fastpath uses inlined version */
> > +	page = __get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
> >  			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET,
> >  			preferred_zone, migratetype);
> >  	if (unlikely(!page))
> 
> I think in a common case where there is background reclaim going on,
> it will be quite common to fail this, won't it? (I haven't run
> statistics though).
> 

Good question. It would be common to fail when background reclaim has
been kicked off for the first time but once we are over the low
watermark, background reclaim will continue even though we are
allocating pages. I recall that ther eis a profile likely/unlikely debug
option. I dont' recall using it before but now might be a good time to
fire it up.

> In which case you will get extra icache footprint. What speedup does
> it give in the cache-hot microbenchmark case?
> 

I wasn't measuring with a microbenchmark at the time of writing so I don't
know. I was going entirely by profile counts running kernbench and the
time spent running the benchmark.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
