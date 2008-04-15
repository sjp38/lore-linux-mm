Date: Tue, 15 Apr 2008 00:07:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Smarter retry of costly-order allocations
Message-Id: <20080415000745.9af1b269.akpm@linux-foundation.org>
In-Reply-To: <20080411233553.GB19078@us.ibm.com>
References: <20080411233500.GA19078@us.ibm.com>
	<20080411233553.GB19078@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: mel@csn.ul.ie, clameter@sgi.com, apw@shadowen.org, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 11 Apr 2008 16:35:53 -0700 Nishanth Aravamudan <nacc@us.ibm.com> wrote:

> Because of page order checks in __alloc_pages(), hugepage (and similarly
> large order) allocations will not retry unless explicitly marked
> __GFP_REPEAT. However, the current retry logic is nearly an infinite
> loop (or until reclaim does no progress whatsoever). For these costly
> allocations, that seems like overkill and could potentially never
> terminate.
> 
> Modify try_to_free_pages() to indicate how many pages were reclaimed.
> Use that information in __alloc_pages() to eventually fail a large
> __GFP_REPEAT allocation when we've reclaimed an order of pages equal to
> or greater than the allocation's order. This relies on lumpy reclaim
> functioning as advertised. Due to fragmentation, lumpy reclaim may not
> be able to free up the order needed in one invocation, so multiple
> iterations may be requred. In other words, the more fragmented memory
> is, the more retry attempts __GFP_REPEAT will make (particularly for
> higher order allocations).
> 

hm, there's rather a lot of speculation and wishful thinking in that
changelog.

If we put this through -mm and into mainline then nobody will test it 
and we won't discover whether it's good or bad until late -rc at best.

So... would like to see some firmer-looking testing results, please.

I _assume_ this patch was inspired by some observed problem?  What was that
problem, and what effect did the patch have?

And what scenarios might be damaged by this patch, and how do we test for
them?

The "repeat until we've reclaimed 1<<order pages" thing is in fact a magic
number, and its value is "1".  How did we arrive at this magic number and
why isn't "2" a better one?  Or "0.5"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
