Date: Tue, 23 Dec 2003 17:13:23 +0100
From: Roger Luethi <rl@hellgate.ch>
Subject: Re: load control demotion/promotion policy
Message-ID: <20031223161323.GA6082@k3.hellgate.ch>
References: <Pine.LNX.4.44.0312202125580.26393-100000@chimarrao.boston.redhat.com> <20031221235541.GA22896@k3.hellgate.ch> <20031222012126.GC11655@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031222012126.GC11655@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@digeo.com>
List-ID: <linux-mm.kvack.org>

On Sun, 21 Dec 2003 17:21:26 -0800, William Lee Irwin III wrote:
> Obviously, the simple regressions should be corrected first. We're not
> interested in programming them ourselves because as far as we know,
> you've already written the fixes. It would be premature to do

Sorry about the delay. Buried in work.

I wonder how I managed to make that impression. I created one patch as
a proof of concept. It demonstrates that the data I collected can be
used to identify regressions and -- sometimes -- roll them back.

I repeated the benchmarks just to be sure. Numbers are not accurate
(2.6.0 performance has a huge variance), but quite reliable
nevertheless. I should do more runs, but 10 is about as many as I can
get done in time.  Median run time (in seconds) for each benchmark are
as follows (priority, kswapd_throttling refer to the two hunks in the
patch below):

	efax	kbuild	qsbench
2.6.0 vanilla
	865	500	275
priority
	860	491	299
kswapd_throttling
	659	500	362
priority + kswapd_throttling
	560	433	327

The numbers look pretty good, but the patch is lame. It does not even
properly revert the distress changes let alone deal with the issue the
changes in 2.6.0-test3 were supposed to address.

That's the only patch I have reasonably solid data for.

Roger


diff -uNp -X /home/rl/data/doc/kernel/dontdiff-2.6 /data/exp/tmp/18_binsearch/linux-2.6.0/mm/vmscan.c ./mm/vmscan.c
--- /data/exp/tmp/18_binsearch/linux-2.6.0/mm/vmscan.c	Wed Oct 15 15:03:46 2003
+++ ./mm/vmscan.c	Tue Dec 23 08:25:42 2003
@@ -632,7 +632,7 @@ refill_inactive_zone(struct zone *zone, 
 	 * `distress' is a measure of how much trouble we're having reclaiming
 	 * pages.  0 -> no problems.  100 -> great trouble.
 	 */
-	distress = 100 >> zone->prev_priority;
+	distress = 100 >> priority;
 
 	/*
 	 * The point of this algorithm is to decide when to start reclaiming
@@ -981,8 +981,7 @@ static int balance_pgdat(pg_data_t *pgda
 		}
 		if (all_zones_ok)
 			break;
-		if (to_free > 0)
-			blk_congestion_wait(WRITE, HZ/10);
+		blk_congestion_wait(WRITE, HZ/10);
 	}
 
 	for (i = 0; i < pgdat->nr_zones; i++) {
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
