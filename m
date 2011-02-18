Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 61E6F8D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 07:22:34 -0500 (EST)
Date: Fri, 18 Feb 2011 12:22:03 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: vmscan: Stop reclaim/compaction earlier due to
	insufficient progress if !__GFP_REPEAT
Message-ID: <20110218122203.GA13246@csn.ul.ie>
References: <20110209154606.GJ27110@cmpxchg.org> <20110209164656.GA1063@csn.ul.ie> <20110209182846.GN3347@random.random> <20110210102109.GB17873@csn.ul.ie> <20110210124838.GU3347@random.random> <20110210133323.GH17873@csn.ul.ie> <20110210141447.GW3347@random.random> <20110210145813.GK17873@csn.ul.ie> <20110216095048.GA4473@csn.ul.ie> <20110217142209.8736cca1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110217142209.8736cca1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Kent Overstreet <kent.overstreet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 17, 2011 at 02:22:09PM -0800, Andrew Morton wrote:
> On Wed, 16 Feb 2011 09:50:49 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > should_continue_reclaim() for reclaim/compaction allows scanning to continue
> > even if pages are not being reclaimed until the full list is scanned. In
> > terms of allocation success, this makes sense but potentially it introduces
> > unwanted latency for high-order allocations such as transparent hugepages
> > and network jumbo frames that would prefer to fail the allocation attempt
> > and fallback to order-0 pages.  Worse, there is a potential that the full
> > LRU scan will clear all the young bits, distort page aging information and
> > potentially push pages into swap that would have otherwise remained resident.
> 
> afaict the patch affects order-0 allocations as well.  What are the
> implications of this?
> 

order-0 allocation should not be affected because RECLAIM_MODE_COMPACTION
is not set so the following avoids the gfp_mask being examined;

        if (!(sc->reclaim_mode & RECLAIM_MODE_COMPACTION))
                return false;

> Also, what might be the downsides of this change, and did you test for
> them?
> 

The main downside that I predict is that the worst-case latencies for
successful transparent hugepage allocations will be increased as there will
be more looping in do_try_to_free_pages() at higher priorities. I would also
not be surprised if there were fewer successful allocations.

Latencies did seem to be worse for order-9 allocations in testing but it was
offset by lower latencies for lower orders and seemed an acceptable trade-off.

Other major consequences did not spring to mind.

> > This patch will stop reclaim/compaction if no pages were reclaimed in the
> > last SWAP_CLUSTER_MAX pages that were considered.
> 
> a) Why SWAP_CLUSTER_MAX?  Is (SWAP_CLUSTER_MAX+7) better or worse?
> 

SWAP_CLUSTER_MAX is the standard "unit of reclaim" and that's what I had
in mind when writing the comment but it's wrong and misleading. More on
this below.

> b) The sentence doesn't seem even vaguely accurate.  shrink_zone()
>    will scan vastly more than SWAP_CLUSTER_MAX pages before calling
>    should_continue_reclaim().  Confused.
> 
> c) The patch doesn't "stop reclaim/compaction" fully.  It stops it
>    against one zone.  reclaim will then advance on to any other
>    eligible zones.

You're right on both counts and this comment is inaccurate. It should
have read;

This patch will stop reclaim/compaction for the current zone in shrink_zone()
if there were no pages reclaimed in the last batch of scanning at the
current priority.  For allocations such as hugetlbfs that use __GFP_REPEAT
and have fewer fallback options, the full LRU list may still be scanned.

The comment in the code itself then becomes

+               /*
+                * For non-__GFP_REPEAT allocations which can presumably
+                * fail without consequence, stop if we failed to reclaim
+                * any pages from the last batch of pages that were scanned.
+                * This will return to the caller faster at the risk that
+                * reclaim/compaction and the resulting allocation attempt
+                * fails
+                */

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
