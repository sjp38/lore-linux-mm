Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 951616B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 20:18:18 -0500 (EST)
Date: Wed, 4 Nov 2009 01:18:11 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] vmscan: Force kswapd to take notice faster when
	high-order watermarks are being hit
Message-ID: <20091104011811.GG22046@csn.ul.ie>
References: <1256650833-15516-1-git-send-email-mel@csn.ul.ie> <200911032301.59662.elendil@planet.nl> <20091103220808.GF22046@csn.ul.ie> <200911040101.50194.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200911040101.50194.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 04, 2009 at 01:01:46AM +0100, Frans Pop wrote:
> On Tuesday 03 November 2009, you wrote:
> > > With a representative test I get 0 for kswapd_slept_prematurely.
> > > Tested with .32-rc6 + patches 1-3 + this patch.
> >
> > Assuming the problem actually reproduced, can you still retest with the
> 
> Yes, it does.
> 
> > patch I posted as a follow-up and see if fast or slow premature sleeps
> > are happening and if the problem still occurs please? It's still
> > possible with the patch as-is could be timing related. After I posted
> > this patch, I continued testing and found I could get counts fairly
> > reliably if kswapd was calling printk() before making the premature
> > check so the window appears to be very small.
> 
> Tested with .32-rc6 and .31.1. With that follow-up patch I still get 
> freezes and SKB allocation errors. And I don't get anywhere near the fast, 
> smooth and reliable behavior I get when I do the congestion_wait() 
> reverts.
> 

Yeah. What it really appears to get down to is that the congestion changes
have altered the timing in a manner that frankly, I'm not sure how to define
as "good" or "bad". The congestion changes in themselves appear sane and
the amount of time callers sleep appears better but the actual result sucks
for the constant stream of high-order allocations that are occuring from
the driver. This abuse of high-order atomics has been addressed but it's
showing up in other horrible ways.

> The new case does trigger as you can see below, but I'm afraid I don't see 
> it making any significant difference for my test. Hope the data is still 
> useful for you.
> 
> From vmstat for .32-rc6:
> kswapd_highorder_rewakeup 8
> kswapd_slept_prematurely_fast 329
> kswapd_slept_prematurely_slow 55
> 
> From vmstat for .31.1:
> kswapd_highorder_rewakeup 20
> kswapd_slept_prematurely_fast 307
> kswapd_slept_prematurely_slow 105
> 

This is useful.

The high premature_fast shows that after kswapd apparently finishes its work,
the high waterwater marks are being breached very quickly (the fast counter
being positive). The "slow" counter is even worse. Your machine is getting
from the high to low watermark quickly without kswapd noticing and processes
depending on the atomics are not waiting long enough.

> If you'd like me to test with the congestion_wait() revert on top of this 
> for comparison, please let me know.
> 

No, there is resistance to rolling back the congestion_wait() changes from
what I gather because they were introduced for sane reasons. The consequence
is just that the reliability of high-order atomics are impacted because more
processes are making forward progress where previously they would have waited
until kswapd had done work. Your driver has already been fixed in this regard
and maybe it's a case that the other atomic users simply have to be fixed to
"not do that".

> P.S. Your follow-up patch did not apply cleanly on top of the debug one as 
> you seem to have made some changes between posting them (dropped kswapd_ 
> from the sleeping_prematurely() function name and added a comment).
> 

Sorry about that. Clearly I've gotten out of sync slightly with the
patchset I'm testing and basing upon as opposed to what I'm posting
here.

Here is yet another patch to be applied on top of the rest of the
patches. Sorry about any typo's, I was out for a friends birthday and I
have a few beers on me but it boots on qemu and passes basic stress tests
at least. The intention of the patch is to delay high-order allocations of
those that can wait for kswapd to do work in parallel. It will only help
the case where there are a mix of high-order allocations that can sleep and
those that can't. Because the main burst of your allocations appear to be
high-order atomics, it might not help but it might delay order-1 allocations
due to many instances of fork() in your workload if 8K stacks are being used.

==== CUT HERE ====
page allocator: Sleep where the intention was to sleep instead of waiting on congestion

At two points during page allocation, it is possible for the process to
sleep for a short interval depending on congestion. There is some anedotal
evidence that since 2.6.31-rc1, the processes are sleeping for less time
than before as the congestion_wait() logic has improved.

However, one consequence of this is that processes are waking up too
quickly, finding that forward progress is still difficult and failing
too early. This patch causes processes to sleep for a fixed interval
instead of sleeping depending on congestion.

With this patch applied, the number of premature sleeps of kswapd as
measured by kswapd_slept_prematurely is reduced while running a stress
test based on parallel executions of dd under QEMU. Furthermore, under
the stress test, the number of oom-killer occurances is drastically
reduced.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2bc2ac6..5884d6f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1726,8 +1726,10 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 			zonelist, high_zoneidx, ALLOC_NO_WATERMARKS,
 			preferred_zone, migratetype);
 
-		if (!page && gfp_mask & __GFP_NOFAIL)
-			congestion_wait(BLK_RW_ASYNC, HZ/50);
+		if (!page && gfp_mask & __GFP_NOFAIL) {
+			set_current_state(TASK_INTERRUPTIBLE);
+			schedule_timeout(HZ/50);
+		}
 	} while (!page && (gfp_mask & __GFP_NOFAIL));
 
 	return page;
@@ -1898,7 +1900,8 @@ rebalance:
 	pages_reclaimed += did_some_progress;
 	if (should_alloc_retry(gfp_mask, order, pages_reclaimed)) {
 		/* Wait for some write requests to complete then retry */
-		congestion_wait(BLK_RW_ASYNC, HZ/50);
+		set_current_state(TASK_INTERRUPTIBLE);
+		schedule_timeout(HZ/50);
 		goto rebalance;
 	}
 
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
