Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 970A96B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 05:34:28 -0500 (EST)
Date: Tue, 17 Nov 2009 10:34:21 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] vmscan: Have kswapd sleep for a short interval and double
	check it should be asleep fix 1
Message-ID: <20091117103420.GX29804@csn.ul.ie>
References: <20091113142558.33B6.A69D9226@jp.fujitsu.com> <20091113141303.GI29804@csn.ul.ie> <20091114023901.3DA8.A69D9226@jp.fujitsu.com> <20091113181740.GN29804@csn.ul.ie> <2f11576a0911140134u21eafa83t9642bb25ccd953de@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <2f11576a0911140134u21eafa83t9642bb25ccd953de@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

When checking if kswapd is sleeping prematurely, all populated zones are
checked instead of the zones the instance of kswapd is responsible for.
The counters for kswapd going to sleep prematurely are also named poorly.
This patch makes kswapd only check its own zones and renames the relevant
counters.

This is a fix to the patch
vmscan-have-kswapd-sleep-for-a-short-interval-and-double-check-it-should-be-asleep.patch
and is based on top of mmotm-2009-11-13-19-59. It would be preferable if
Kosaki Motohiro signed off on it as he had comments on the patch but the
discussion petered out without a solid conclusion.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 include/linux/vmstat.h |    2 +-
 mm/vmscan.c            |   20 +++++++++++++-------
 mm/vmstat.c            |    4 ++--
 3 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 70c8093..117f0dd 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -40,7 +40,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		PGSCAN_ZONE_RECLAIM_FAILED,
 #endif
 		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
-		KSWAPD_PREMATURE_FAST, KSWAPD_PREMATURE_SLOW,
+		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
 		KSWAPD_SKIP_CONGESTION_WAIT,
 		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
 #ifdef CONFIG_HUGETLB_PAGE
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 81ef29b..da6cf42 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1907,19 +1907,25 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 #endif
 
 /* is kswapd sleeping prematurely? */
-static int sleeping_prematurely(int order, long remaining)
+static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
 {
-	struct zone *zone;
+	int i;
 
 	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
 	if (remaining)
 		return 1;
 
 	/* If after HZ/10, a zone is below the high mark, it's premature */
-	for_each_populated_zone(zone)
+	for (i = 0; i < pgdat->nr_zones; i++) {
+		struct zone *zone = pgdat->node_zones + i;
+
+		if (!populated_zone(zone))
+			continue;
+
 		if (!zone_watermark_ok(zone, order, high_wmark_pages(zone),
 								0, 0))
 			return 1;
+	}
 
 	return 0;
 }
@@ -2227,7 +2233,7 @@ static int kswapd(void *p)
 				long remaining = 0;
 
 				/* Try to sleep for a short interval */
-				if (!sleeping_prematurely(order, remaining)) {
+				if (!sleeping_prematurely(pgdat, order, remaining)) {
 					remaining = schedule_timeout(HZ/10);
 					finish_wait(&pgdat->kswapd_wait, &wait);
 					prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
@@ -2238,13 +2244,13 @@ static int kswapd(void *p)
 				 * premature sleep. If not, then go fully
 				 * to sleep until explicitly woken up
 				 */
-				if (!sleeping_prematurely(order, remaining))
+				if (!sleeping_prematurely(pgdat, order, remaining))
 					schedule();
 				else {
 					if (remaining)
-						count_vm_event(KSWAPD_PREMATURE_FAST);
+						count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
 					else
-						count_vm_event(KSWAPD_PREMATURE_SLOW);
+						count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
 				}
 			}
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 889254f..6051fba 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -683,8 +683,8 @@ static const char * const vmstat_text[] = {
 	"slabs_scanned",
 	"kswapd_steal",
 	"kswapd_inodesteal",
-	"kswapd_slept_prematurely_fast",
-	"kswapd_slept_prematurely_slow",
+	"kswapd_low_wmark_hit_quickly",
+	"kswapd_high_wmark_hit_quickly",
 	"kswapd_skip_congestion_wait",
 	"pageoutrun",
 	"allocstall",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
