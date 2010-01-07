Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7301F6B003D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 08:58:44 -0500 (EST)
Date: Thu, 7 Jan 2010 13:58:31 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Commit f50de2d38 seems to be breaking my oom killer
Message-ID: <20100107135831.GA29564@csn.ul.ie>
References: <87a5b0801001070434m7f6b0fd6vfcdf49ab73a06cbb@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <87a5b0801001070434m7f6b0fd6vfcdf49ab73a06cbb@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Will Newton <will.newton@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 07, 2010 at 12:34:54PM +0000, Will Newton wrote:
> Hi,
> 
> I'm having some problems on a small embedded box with 24Mb of RAM and
> no swap. If a process tries to use large amounts of memory and gets
> OOM killed, with 2.6.32 it's fine, but with 2.6.33-rc2 kswapd gets
> stuck and the system locks up.

By stuck, do you mean it consumes 100% CPU and never goes to sleep?

> The problem appears to have been
> introduced with f50de2d38. If I change sleeping_prematurely to skip
> the for_each_populated_zone test then OOM killing operates as
> expected. I'm guessing it's caused by the new code not allowing kswapd
> to schedule when it is required to let the killed task exit. Does that
> sound plausible?
> 

It's conceivable. The expectation was that the cond_resched() in
balance_pgdat() should have been called at

        if (!all_zones_ok) {
                cond_resched();

But it would appear that if all zones are unreclaimable, all_zones_ok == 1.
It could be looping there indefinitly never calling schedule because it
never reaches the points where cond_resched is called.

> I'll try and investigate further into what's going on.
> 

Can you try the following?

==== CUT HERE ====
vmscan: kswapd should notice that all zones are not ok if they are unreclaimble

In the event all zones are unreclaimble, it is possible for kswapd to
never go to sleep because "all zones are ok even though watermarks are
not reached". It gets into a situation where cond_reched() is not
called.

This patch notes that if all zones are unreclaimable then the zones are
not ok and cond_resched() should be called.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 mm/vmscan.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2ad8603..d3c0848 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2022,8 +2022,10 @@ loop_again:
 				break;
 			}
 		}
-		if (i < 0)
+		if (i < 0) {
+			all_zones_ok = 0;
 			goto out;
+		}
 
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
