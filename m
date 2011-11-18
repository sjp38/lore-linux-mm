Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 236116B006C
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 12:59:28 -0500 (EST)
Date: Fri, 18 Nov 2011 18:59:23 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: Do not stall in synchronous compaction for THP
 allocations
Message-ID: <20111118175923.GD3579@redhat.com>
References: <20111110151211.523fa185.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1111101536330.2194@chino.kir.corp.google.com>
 <20111111101414.GJ3083@suse.de>
 <20111114154408.10de1bc7.akpm@linux-foundation.org>
 <20111115132513.GF27150@suse.de>
 <alpine.DEB.2.00.1111151303230.23579@chino.kir.corp.google.com>
 <20111115234845.GK27150@suse.de>
 <alpine.DEB.2.00.1111151554190.3781@chino.kir.corp.google.com>
 <20111116041350.GA3306@redhat.com>
 <20111116133056.GC3306@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111116133056.GC3306@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 16, 2011 at 02:30:56PM +0100, Andrea Arcangeli wrote:
> On Wed, Nov 16, 2011 at 05:13:50AM +0100, Andrea Arcangeli wrote:
> > After checking my current thp vmstat I think Andrew was right and we
> > backed out for a good reason before. I'm getting significantly worse
> > success rate, not sure why it was a small reduction in success rate
> > but hey I cannot exclude I may have broke something with some other
> > patch. I've been running it together with a couple more changes. If
> > it's this change that reduced the success rate, I'm afraid going
> > always async is not ok.
> 
> I wonder if the high failure rate when shutting off "sync compaction"
> and forcing only "async compaction" for THP (your patch queued in -mm)
> is also because of ISOLATE_CLEAN being set in compaction from commit
> 39deaf8. ISOLATE_CLEAN skipping PageDirty means all tmpfs/anon pages

I think I tracked down the source of the thp allocation
regression. They're commit e0887c19b2daa140f20ca8104bdc5740f39dbb86
and e0c23279c9f800c403f37511484d9014ac83adec. They're also wrong
because compaction_suitable doesn't check that there is enough free
memory in the number of "movable" pageblocks.

I'm going to test this not sure if it helps. But the more free memory
the more likely compaction succeeds, so there's still a risk we're
reducing the compaction success.

With the two commits above reverted my compaction success rate returns
near 100%, with the two commits above applied it goes to <50%... Now
we'll see what happens with the below patch.

===
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] compaction: correct reverse check for compaction_deferred

Otherwise when compaction is deferred, reclaim stops to, leading to
high failure rate of high order allocations.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/vmscan.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f7f7677..ce745f0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2144,8 +2144,8 @@ static bool shrink_zones(int priority, struct zonelist *zonelist,
 				 * allocations.
 				 */
 				if (sc->order > PAGE_ALLOC_COSTLY_ORDER &&
-					(compaction_suitable(zone, sc->order) ||
-					 compaction_deferred(zone))) {
+				    (compaction_suitable(zone, sc->order) &&
+				     !compaction_deferred(zone))) {
 					should_abort_reclaim = true;
 					continue;
 				}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
