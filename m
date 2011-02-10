Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AA7B48D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 07:49:09 -0500 (EST)
Date: Thu, 10 Feb 2011 13:48:38 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch] vmscan: fix zone shrinking exit when scan work is done
Message-ID: <20110210124838.GU3347@random.random>
References: <20110209154606.GJ27110@cmpxchg.org>
 <20110209164656.GA1063@csn.ul.ie>
 <20110209182846.GN3347@random.random>
 <20110210102109.GB17873@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110210102109.GB17873@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Kent Overstreet <kent.overstreet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 10, 2011 at 10:21:10AM +0000, Mel Gorman wrote:
> We should not be ending up in a situation with the LRU list of only
> page_evictable pages and that situation persisting causing excessive (or
> infinite) looping. As unevictable pages are encountered on the LRU list,
> they should be moved to the unevictable lists by putback_lru_page().  Are you
> aware of a situation where this becomes broken?
> 
> I recognise that SWAP_CLUSTER_MAX pages could all be unevictable and they
> are all get moved. In this case, nr_scanned is positive and we continue
> to scan but this is expected and desirable: Reclaim/compaction needs more
> pages to be freed before it starts compaction. If it stops scanning early,
> then it would just fail the allocation later. This is what the "NOTE" is about.
> 
> I prefer Johannes' fix for the observed problem.

should_continue_reclaim is only needed for compaction. It tries to
free enough pages so that compaction can succeed in its defrag
attempt. So breaking the loop faster isn't going to cause failures for
0 order pages. My worry is that we loop too much in shrink_zone just
for compaction even when we don't do any progress. shrink_zone would
never scan more than SWAP_CLUSTER_MAX pages, before this change. Now
it can loop over the whole lru as long as we're scanning stuff. Ok to
overboost shrink_zone if we're making progress to allow compaction at
the next round, but if we don't visibly make progress, I'm concerned
that it may be too aggressive to scan the whole list. The performance
benefit of having an hugepage isn't as huge as scanning all pages in
the lru when before we would have broken the loop and declared failure
after only SWAP_CLUSTER_MAX pages, and then we would have fallen back
in a order 0 allocation. The fix may help of course, maybe it's enough
for his case I don't know, but I don't see it making a whole lot of
difference, except now it will stop when the lru is practically empty
which clearly is an improvement. I think we shouldn't be so worried
about succeeding compaction, the important thing is we don't waste
time in compaction if there's not enough free memory but
compaction_suitable used by both logics should be enough for that.

I'd rather prefer that if hugetlbfs has special needs it uses a __GFP_
flag or similar that increases how compaction is strict in succeeding,
up to scanning the whole lru in one go in order to make some free
memory for compaction to succeed.

Going ahead with the scan until compaction_suitable is true instead
makes sense when there's absence of memory pressure and nr_reclaimed
is never zero.

Maybe we should try a bit more times than just nr_reclaim but going
over the whole lru, sounds a bit extreme.

The issue isn't just for unevictable pages, that will be refiled
during the scan but it will also happen in presence of lots of
referenced pages. For example if we don't apply my fix, the current
code can take down all young bits in all ptes in one go in the whole
system before returning from shrink_zone, that is too much in my view,
and losing all that information in one go (not even to tell the cost
associated with losing it) can hardly be offseted by the improvement
given by 1 more hugepage.

But please let me know if I've misread something...

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
