Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AAE3F6B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 13:16:03 -0500 (EST)
Date: Fri, 13 Nov 2009 18:15:57 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] vmscan: Stop kswapd waiting on congestion when the min
	watermark is not being met
Message-ID: <20091113181557.GM29804@csn.ul.ie>
References: <20091113142608.33B9.A69D9226@jp.fujitsu.com> <20091113135443.GF29804@csn.ul.ie> <20091114023138.3DA5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091114023138.3DA5.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

If reclaim fails to make sufficient progress, the priority is raised.
Once the priority is higher, kswapd starts waiting on congestion.  However,
if the zone is below the min watermark then kswapd needs to continue working
without delay as there is a danger of an increased rate of GFP_ATOMIC
allocation failure.

This patch changes the conditions under which kswapd waits on
congestion by only going to sleep if the min watermarks are being met.

This patch replaces
vmscan-take-order-into-consideration-when-deciding-if-kswapd-is-in-trouble.patch .

[mel@csn.ul.ie: Add stats to track how relevant the logic is]
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 include/linux/vmstat.h |    1 +
 mm/vmscan.c            |   18 ++++++++++++++++--
 mm/vmstat.c            |    1 +
 3 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 9716003..7d66695 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -41,6 +41,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #endif
 		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
 		KSWAPD_PREMATURE_FAST, KSWAPD_PREMATURE_SLOW,
+		KSWAPD_NO_CONGESTION_WAIT,
 		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ffa1766..70a2322 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1979,6 +1979,7 @@ loop_again:
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 		unsigned long lru_pages = 0;
+		int has_under_min_watermark_zone = 0;
 
 		/* The swap token gets in the way of swapout... */
 		if (!priority)
@@ -2085,6 +2086,15 @@ loop_again:
 			if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
 			    total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
 				sc.may_writepage = 1;
+
+			/*
+			 * We are still under min water mark. it mean we have
+			 * GFP_ATOMIC allocation failure risk. Hurry up!
+			 */
+			if (!zone_watermark_ok(zone, order, min_wmark_pages(zone),
+					      end_zone, 0))
+				has_under_min_watermark_zone = 1;
+
 		}
 		if (all_zones_ok)
 			break;		/* kswapd: all done */
@@ -2092,8 +2102,12 @@ loop_again:
 		 * OK, kswapd is getting into trouble.  Take a nap, then take
 		 * another pass across the zones.
 		 */
-		if (total_scanned && priority < DEF_PRIORITY - 2)
-			congestion_wait(BLK_RW_ASYNC, HZ/10);
+		if (total_scanned && (priority < DEF_PRIORITY - 2)) {
+			if (!has_under_min_watermark_zone)
+				count_vm_event(KSWAPD_NO_CONGESTION_WAIT);
+			else
+				congestion_wait(BLK_RW_ASYNC, HZ/10);
+		}
 
 		/*
 		 * We do this so kswapd doesn't build up large priorities for
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 90b11e4..bc09547 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -685,6 +685,7 @@ static const char * const vmstat_text[] = {
 	"kswapd_inodesteal",
 	"kswapd_slept_prematurely_fast",
 	"kswapd_slept_prematurely_slow",
+	"kswapd_no_congestion_wait",
 	"pageoutrun",
 	"allocstall",
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
