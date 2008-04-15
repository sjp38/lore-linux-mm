Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3FHQGs0024924
	for <linux-mm@kvack.org>; Tue, 15 Apr 2008 13:26:16 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3FHQGbS340536
	for <linux-mm@kvack.org>; Tue, 15 Apr 2008 13:26:16 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3FHQGMd015286
	for <linux-mm@kvack.org>; Tue, 15 Apr 2008 13:26:16 -0400
Date: Tue, 15 Apr 2008 10:26:14 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] Smarter retry of costly-order allocations
Message-ID: <20080415172614.GE15840@us.ibm.com>
References: <20080411233500.GA19078@us.ibm.com> <20080411233553.GB19078@us.ibm.com> <20080415000745.9af1b269.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080415000745.9af1b269.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mel@csn.ul.ie, clameter@sgi.com, apw@shadowen.org, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 15.04.2008 [00:07:45 -0700], Andrew Morton wrote:
> On Fri, 11 Apr 2008 16:35:53 -0700 Nishanth Aravamudan <nacc@us.ibm.com> wrote:
> 
> > Because of page order checks in __alloc_pages(), hugepage (and similarly
> > large order) allocations will not retry unless explicitly marked
> > __GFP_REPEAT. However, the current retry logic is nearly an infinite
> > loop (or until reclaim does no progress whatsoever). For these costly
> > allocations, that seems like overkill and could potentially never
> > terminate.
> > 
> > Modify try_to_free_pages() to indicate how many pages were reclaimed.
> > Use that information in __alloc_pages() to eventually fail a large
> > __GFP_REPEAT allocation when we've reclaimed an order of pages equal to
> > or greater than the allocation's order. This relies on lumpy reclaim
> > functioning as advertised. Due to fragmentation, lumpy reclaim may not
> > be able to free up the order needed in one invocation, so multiple
> > iterations may be requred. In other words, the more fragmented memory
> > is, the more retry attempts __GFP_REPEAT will make (particularly for
> > higher order allocations).
> > 
> 
> hm, there's rather a lot of speculation and wishful thinking in that
> changelog.

Sorry about that -- I realized after sending (and reading your other
e-mails on LKML/linux-mm about changelogs) that I should have referred
to Mel's previous testing results, at a minimum.

> If we put this through -mm and into mainline then nobody will test it 
> and we won't discover whether it's good or bad until late -rc at best.
> 
> So... would like to see some firmer-looking testing results, please.

Do Mel's e-mails cover this sufficiently?

> I _assume_ this patch was inspired by some observed problem?  What was that
> problem, and what effect did the patch have?

To make it explicit, the problem is in the userspace interface to
growing the static hugepage pool (/proc/sys/vm/nr_hugepages). An
administrator may request 100 hugepages, but due to fragmentation, load,
etc. on the system, only 60 are granted. The administrator could,
however, try to request 100 hugepages again, and be granted 70 on the
second request. Then 72 on the third, then 73 on the fourth, 73 still on
the fifth, and then 74 on the sixth, etc. Numbers are made up here, but
similar patterns are observed in practice. Rather than force user space
to keep trying until some point (which user space is not really in a
point to observe, given patterns like {72, 73, 73, 74}, that is no
growth followed by growth) I think putting the smarts in the kernel to
leverage reclaim is a better approach. And Mel's results indicate the
/proc interface "performs" better (achieves a larger number of hugepages
on first try) than before.

> And what scenarios might be damaged by this patch, and how do we test
> for them?

This is a good question -- Mel's testing does cover some of this by
verifying the reclaim path is not destroyed by the extra checks.
However, unless there is quite serious fragmentation, I think most of
the lower-order allocations (which implicitly are __GFP_NOFAIL) succeed
on one iteration through __alloc_pages anyways. The impact to
lower-order allocations should just be the changed return value, though,
as we don't look at the reclaim success to determine if we should quite
reclaiming in that case.

> The "repeat until we've reclaimed 1<<order pages" thing is in fact a
> magic number, and its value is "1".  How did we arrive at this magic
> number and why isn't "2" a better one?  Or "0.5"?

Another good question, and one that should have been answered in my
changelog, I'm sorry.

We have some order of allocation to satisfy. Relying on lumpy reclaim to
attempt to free up lumps of memory, if we have reclaimed an order
greater than or equal to the order of the requested allocation, we
should be able to satisfy the allocation. If we can't at that point, we
fail the allocation. I believe this is a good balance between trying to
succeed large allocations when possible and looping in the core VM
forever.

"2" may be a better value in one sense, because we should be even more
likely to succeed the allocation if we've freed twice as many pages as
we needed, but we'd try longer at the tail end of the reclaim loop
(having gone through several times not getting a large enough contiguous
region free), even though we probably should have succeeded earlier.

"0.5" won't work, I don't think, because that would imply reclaiming
half as many pages as the original request. Unless there were already
about half the number of pages free (but no more), the allocation would
fail early, even though it might succeed a few more times down the road.
More importantly, "1" subsumes the case where half the pages are free
now, and we need to reclaim the other half -- as we'll succeed the
allocation at some point and stop reclaiming. Really, that's the same
reason that "2" would be better -- or really __GFP_NOFAIL would be. But
given that hugepage orders are very large (and this is all of
PAGE_ALLOC_COSTLY_ORDER to begin with), I don't think we want them to be
NOFAIL.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
