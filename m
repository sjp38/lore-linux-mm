Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3CBF66B005C
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 23:53:19 -0400 (EDT)
Date: Wed, 15 Jul 2009 23:53:18 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm] throttle direct reclaim when too many pages are
 isolated already (v3)
Message-ID: <20090715235318.6d2f5247@bree.surriel.com>
In-Reply-To: <20090715203854.336de2d5.akpm@linux-foundation.org>
References: <20090715223854.7548740a@bree.surriel.com>
	<20090715194820.237a4d77.akpm@linux-foundation.org>
	<4A5E9A33.3030704@redhat.com>
	<20090715202114.789d36f7.akpm@linux-foundation.org>
	<4A5E9E4E.5000308@redhat.com>
	<20090715203854.336de2d5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

When way too many processes go into direct reclaim, it is possible
for all of the pages to be taken off the LRU.  One result of this
is that the next process in the page reclaim code thinks there are
no reclaimable pages left and triggers an out of memory kill.

One solution to this problem is to never let so many processes into
the page reclaim path that the entire LRU is emptied.  Limiting the
system to only having half of each inactive list isolated for
reclaim should be safe.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
v3: - only wait if scanning global lru (Kamezawa Hiroyuki)
    - make sure tasks with a fatal signal pending go through
      congestion_timeout at least once, to give other tasks a
      chance to free memory
v2: - fix the bugs pointed out by Andrew Morton

This patch goes on top of Kosaki's "Account the number of isolated pages"
patch series.

 mm/vmscan.c |   33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

Index: mmotm/mm/vmscan.c
===================================================================
--- mmotm.orig/mm/vmscan.c	2009-07-15 22:32:35.000000000 -0400
+++ mmotm/mm/vmscan.c	2009-07-15 23:50:01.000000000 -0400
@@ -1035,6 +1035,31 @@ int isolate_lru_page(struct page *page)
 }
 
 /*
+ * Are there way too many processes in the direct reclaim path already?
+ */
+static int too_many_isolated(struct zone *zone, int file,
+		struct scan_control *sc)
+{
+	unsigned long inactive, isolated;
+
+	if (current_is_kswapd())
+		return 0;
+
+	if (!scanning_global_lru(sc))
+		return 0;
+
+	if (file) {
+		inactive = zone_page_state(zone, NR_INACTIVE_FILE);
+		isolated = zone_page_state(zone, NR_ISOLATED_FILE);
+	} else {
+		inactive = zone_page_state(zone, NR_INACTIVE_ANON);
+		isolated = zone_page_state(zone, NR_ISOLATED_ANON);
+	}
+
+	return isolated > inactive;
+}
+
+/*
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
  */
@@ -1049,6 +1074,14 @@ static unsigned long shrink_inactive_lis
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 	int lumpy_reclaim = 0;
 
+	while (unlikely(too_many_isolated(zone, file, sc))) {
+		congestion_wait(WRITE, HZ/10);
+
+		/* We are about to die and free our memory. Return now. */
+		if (fatal_signal_pending(current))
+			return SWAP_CLUSTER_MAX;
+	}
+
 	/*
 	 * If we need a large contiguous chunk of memory, or have
 	 * trouble getting a small set of contiguous pages, we

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
