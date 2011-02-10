Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A9A118D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 09:15:21 -0500 (EST)
Date: Thu, 10 Feb 2011 15:14:47 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch] vmscan: fix zone shrinking exit when scan work is done
Message-ID: <20110210141447.GW3347@random.random>
References: <20110209154606.GJ27110@cmpxchg.org>
 <20110209164656.GA1063@csn.ul.ie>
 <20110209182846.GN3347@random.random>
 <20110210102109.GB17873@csn.ul.ie>
 <20110210124838.GU3347@random.random>
 <20110210133323.GH17873@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110210133323.GH17873@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Kent Overstreet <kent.overstreet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 10, 2011 at 01:33:24PM +0000, Mel Gorman wrote:
> Also true, I commented on this in the "Note" your patch deletes and a
> suggestion on how an alternative would be to break early unless GFP_REPEAT.

Yep noticed that ;), doing that with __GFP_REPEAT sounds just fine to me.

> Sortof. Lumpy reclaim would have scanned more than SWAP_CLUSTER_MAX so
> scanning was still pretty high. The other costs of lumpy reclaim would hide
> it of course.

Ok but we know lumpy reclaim was not ok to start with.

> What about other cases such as order-1 allocations for stack or order-3
> allocations for those network cards using jumbo frames without
> scatter/gather?

stack order 1 is one of the few cases that come to mind where failing
an allocation becomes fatal. Maybe we should use __GFP_REPEAT there
too.

But we probably need a way to discriminate callers that can gracefully
fallback. I'd be extremely surprised if the cost of looping all over
the lru taking down all young bits could ever be offseted by the jumbo
frame. In fact the jumbo frame I'm afraid might be better off without
using compaction at all because it's probably very latency
sensitive. We need a 'lowlatency' version of compaction for these
users where the improvement of having a compound page instead of a
regular page isn't very significant.

On a separated topic, I'm currently trying to use the new async
compaction code upstream with jumbo frames. I'm also wondering if I'll
have to set sync=0 by default unless __GFP_REPEAT is set. It seems
adding compaction to jumbo frames is increasing latency to certain
workloads in a measurable way. Things were fine when compaction was
only used by THP and not for all order allocations (but I didn't test
the async mode yet plus the other optimizations for compaction you did
recently, I hope they're enough to jumbo frames).

> Don't get me wrong, I see your point but I'm wondering if there really are
> cases where we routinely scan an entire LRU list of unevictable pages that
> are somehow not being migrated properly to the unevictable lists. If
> this is happening, we are also in trouble for reclaiming for order-0
> pages, right?

Well unevictable pages are just an example and like you said they last
only one round of the loop at most. But other caching bits like the
referenced bits and all young bits will get all taken down during all
later loops too. We definitely don't want to swap just to allow
compaction to succeed! I think this argument explains it pretty well,
if you takedown all young bits in a constant loop, then system may end
up swapping. That's definitely something we don't want.

Things may be different if this is a stack allocation without
fallback, or if it's hugetlbfs again without kernel fallback (only
userland fallback).

> It uses GFP_REPEAT. That is why I specifically mentioned it in the "NOTE"
> as an alternative to how we could break early while still being agressive
> when required. The only reason it's not that way now is because a) I didn't
> consider an LRU mostly full of unevictable pages to be the normal case and b)
> for allocations such as order-3 that are preferable not to fail.

Ok.

> Where should be draw the line? We could come up with ratio of the lists
> depending on priority but it'd be hard to measure the gain or loss
> without having a profile of a problem case to look at.

I would just stick to !nr_reclaimed to break the loop, and ignore the
nr_scanned unless __GFP_REPEAT is set, in which case you're welcome to
scan everything.

Then we've to decide if to add __GFP_REPEAT to the stack allocation...

> I don't think you have misread anything but if we're going to weaken
> this logic, I'd at least like to see the GFP_REPEAT option tried - i.e.

I see the point of __GFP_REPEAT, that sounds the best, I should have
just followed your comment but I felt scanning everything was too
heavyweight regardless, but ok I see you want as much accuracy as
possible in that case, even if that end up in a swap storm.

> preserve being aggressive if set. I'm also not convinced we routinely get
> into a situation where the LRU consists of almost all unevictable pages
> and if we are in this situation, that is a serious problem on its own. It
> would also be preferable if we could get latency figures on alloc_pages for
> hugepage-sized allocations and a count of how many are succeeding or failing
> to measure the impact (if any).

I think I made not the best example talking about unevictable pages. I
said that because the code is like below, but to me all the goto
something following the !page_evictable check were also relevant for
this shrink_zone loop. The real life issue is avoid swap storm (or
expensive loop flooding the whole system of ipis to takedown all young
bits in all ptes), to allocate an hugepage or jumboframe that has a
graceful fallback that performs not hugely slower than the
hugepage/jumboframe.

     	  sc->nr_scanned++;

          if (unlikely(!page_evictable(page, NULL)))
	      goto cull_mlocked;

I think making the !nr_scanned check conditional to __GFP_REPEAT as
the comment suggested, for now is the best way to go.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
