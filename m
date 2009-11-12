Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 21A636B007B
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 14:30:49 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 4/5] vmscan: Have kswapd sleep for a short interval and double check it should be asleep
Date: Thu, 12 Nov 2009 19:30:34 +0000
Message-Id: <1258054235-3208-5-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1258054235-3208-1-git-send-email-mel@csn.ul.ie>
References: <1258054235-3208-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>
Cc: linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

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
 include/linux/vmstat.h |    1 +
 mm/vmscan.c            |   44 ++++++++++++++++++++++++++++++++++++++++++--
 mm/vmstat.c            |    2 ++
 3 files changed, 45 insertions(+), 2 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 2d0f222..9716003 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -40,6 +40,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		PGSCAN_ZONE_RECLAIM_FAILED,
 #endif
 		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
+		KSWAPD_PREMATURE_FAST, KSWAPD_PREMATURE_SLOW,
 		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 190bae1..ffa1766 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1904,6 +1904,24 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 }
 #endif
 
+/* is kswapd sleeping prematurely? */
+static int sleeping_prematurely(int order, long remaining)
+{
+	struct zone *zone;
+
+	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
+	if (remaining)
+		return 1;
+
+	/* If after HZ/10, a zone is below the high mark, it's premature */
+	for_each_populated_zone(zone)
+		if (!zone_watermark_ok(zone, order, high_wmark_pages(zone),
+								0, 0))
+			return 1;
+
+	return 0;
+}
+
 /*
  * For kswapd, balance_pgdat() will work across all this node's zones until
  * they are all at high_wmark_pages(zone).
@@ -2184,8 +2202,30 @@ static int kswapd(void *p)
 			 */
 			order = new_order;
 		} else {
-			if (!freezing(current))
-				schedule();
+			if (!freezing(current)) {
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
+			}
 
 			order = pgdat->kswapd_max_order;
 		}
diff --git a/mm/vmstat.c b/mm/vmstat.c
index c81321f..90b11e4 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -683,6 +683,8 @@ static const char * const vmstat_text[] = {
 	"slabs_scanned",
 	"kswapd_steal",
 	"kswapd_inodesteal",
+	"kswapd_slept_prematurely_fast",
+	"kswapd_slept_prematurely_slow",
 	"pageoutrun",
 	"allocstall",
 
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
