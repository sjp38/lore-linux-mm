Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 39B546B009A
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 15:37:00 -0500 (EST)
Date: Mon, 2 Nov 2009 20:36:55 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] vmscan: Force kswapd to take notice faster when
	high-order watermarks are being hit
Message-ID: <20091102203654.GD22046@csn.ul.ie>
References: <1256650833-15516-1-git-send-email-mel@csn.ul.ie> <20091028124756.7af44b6b.akpm@linux-foundation.org> <20091102160534.GA22046@csn.ul.ie> <200911021832.59035.elendil@planet.nl> <20091102173837.GB22046@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091102173837.GB22046@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 02, 2009 at 05:38:38PM +0000, Mel Gorman wrote:
> On Mon, Nov 02, 2009 at 06:32:54PM +0100, Frans Pop wrote:
> > On Monday 02 November 2009, Mel Gorman wrote:
> > > vmscan: Help debug kswapd issues by counting number of rewakeups and
> > > premature sleeps
> > >
> > > There is a growing amount of anedotal evidence that high-order atomic
> > > allocation failures have been increasing since 2.6.31-rc1. The two
> > > strongest possibilities are a marked increase in the number of
> > > GFP_ATOMIC allocations and alterations in timing. Debugging printk
> > > patches have shown for example that kswapd is sleeping for shorter
> > > intervals and going to sleep when watermarks are still not being met.
> > >
> > > This patch adds two kswapd counters to help identify if timing is an
> > > issue. The first counter kswapd_highorder_rewakeup counts the number of
> > > times that kswapd stops reclaiming at one order and restarts at a higher
> > > order. The second counter kswapd_slept_prematurely counts the number of
> > > times kswapd went to sleep when the high watermark was not met.
> > 
> > What testing would you like done with this patch?
> > 
> 
> Same reproduction as before except post what the contents of
> /proc/vmstat were after the problem was triggered.
> 

In the event there is a positive count for kswapd_slept_prematurely after
the error is produced, can you also check if the following patch makes a
difference and what the contents of vmstat are please? It alters how kswapd
behaves and when it goes to sleep.

Thanks

==== CUT HERE ====
vmscan: Have kswapd sleep for a short interval and double check it should be asleep

After kswapd balances all zones in a pgdat, it goes to sleep. In the event
of no IO congestion, kswapd can go to sleep very shortly after the high
watermark was reached. If there are a constant stream of allocations from
parallel processes, it can mean that kswapd went to sleep too quickly and
the high watermark is not being maintained for sufficient length time.

This patch makes kswapd go to sleep as a two-stage process. It first
tries to sleep for HZ/10. If it is woken up by another process or the
high watermark is no longer met, it's considered a premature sleep and
kswapd continues work. Otherwise it goes fully to sleep.

This adds more counters to distinguish between fast and slow breaches of
watermarks. A "fast" premature sleep is one where the low watermark was
hit in a very short time after kswapd going to sleep. A "slow" premature
sleep indicates that the high watermark was breached after a very short
interval.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/vmstat.h |    3 ++-
 mm/vmscan.c            |   31 +++++++++++++++++++++++++++----
 mm/vmstat.c            |    3 ++-
 3 files changed, 31 insertions(+), 6 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 2e0d18d..f344878 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -40,7 +40,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		PGSCAN_ZONE_RECLAIM_FAILED,
 #endif
 		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
-		KSWAPD_HIGHORDER_REWAKEUP, KSWAPD_PREMATURE_SLEEP,
+		KSWAPD_HIGHORDER_REWAKEUP,
+		KSWAPD_PREMATURE_FAST, KSWAPD_PREMATURE_SLOW,
 		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 11a69a8..70aeb05 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1905,10 +1905,14 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 #endif
 
 /* is kswapd sleeping prematurely? */
-static int sleeping_prematurely(int order)
+static int sleeping_prematurely(int order, long remaining)
 {
 	struct zone *zone;
 
+	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
+	if (remaining)
+		return 1;
+
 	/* If after HZ/10, a zone is below the high mark, it's premature */
 	for_each_populated_zone(zone)
 		if (!zone_watermark_ok(zone, order, high_wmark_pages(zone),
@@ -2209,9 +2213,28 @@ static int kswapd(void *p)
 			order = new_order;
 		} else {
 			if (!freezing(current)) {
-				if (sleeping_prematurely(order))
-					count_vm_event(KSWAPD_PREMATURE_SLEEP);
-				schedule();
+				long remaining = 0;
+
+				/* Try to sleep for a short interval */
+				if (!sleeping_prematurely(order, remaining)) {
+					remaining = schedule_timeout(HZ/10);
+					finish_wait(&pgdat->kswapd_wait, &wait);
+					prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
+				}
+
+				/*
+				 * After a short sleep, check if it was a
+				 * premature sleep. If not, then go fully
+				 * to sleep until explicitly woken up
+				 */
+				if (!sleeping_prematurely(order, remaining))
+					schedule();
+				else {
+					if (remaining)
+						count_vm_event(KSWAPD_PREMATURE_FAST);
+					else
+						count_vm_event(KSWAPD_PREMATURE_SLOW);
+				}
 			}
 
 			order = pgdat->kswapd_max_order;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index fa881c5..47a6914 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -684,7 +684,8 @@ static const char * const vmstat_text[] = {
 	"kswapd_steal",
 	"kswapd_inodesteal",
 	"kswapd_highorder_rewakeup",
-	"kswapd_slept_prematurely",
+	"kswapd_slept_prematurely_fast",
+	"kswapd_slept_prematurely_slow",
 	"pageoutrun",
 	"allocstall",
 
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
