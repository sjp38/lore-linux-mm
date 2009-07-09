Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 68A2E6B0092
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 21:38:24 -0400 (EDT)
Date: Wed, 8 Jul 2009 21:51:05 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [RFC PATCH 1/2] vmscan don't isolate too many pages in a zone
Message-ID: <20090708215105.5016c929@bree.surriel.com>
In-Reply-To: <20090708031901.GA9924@localhost>
References: <20090707182947.0C6D.A69D9226@jp.fujitsu.com>
	<20090707184034.0C70.A69D9226@jp.fujitsu.com>
	<4A539B11.5020803@redhat.com>
	<20090708031901.GA9924@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>
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
On Wed, 8 Jul 2009 11:19:01 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> > I guess I should mail out my (ugly) approach, so we can
> > compare the two :)
> 
> And it helps to be aware of all the alternatives, now and future :)

Here is the per-zone alternative to Kosaki's patch.

I believe Kosaki's patch will result in better performance
and is more elegant overall, but here it is :)

 mm/vmscan.c |   25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

Index: mmotm/mm/vmscan.c
===================================================================
--- mmotm.orig/mm/vmscan.c	2009-07-08 21:37:01.000000000 -0400
+++ mmotm/mm/vmscan.c	2009-07-08 21:39:02.000000000 -0400
@@ -1035,6 +1035,27 @@ int isolate_lru_page(struct page *page)
 }
 
 /*
+ * Are there way too many processes in the direct reclaim path already?
+ */
+static int too_many_isolated(struct zone *zone, int file)
+{
+	unsigned long inactive, isolated;
+
+	if (current_is_kswapd())
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
@@ -1049,6 +1070,10 @@ static unsigned long shrink_inactive_lis
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 	int lumpy_reclaim = 0;
 
+	while (unlikely(too_many_isolated(zone, file))) {
+		schedule_timeout_interruptible(HZ/10);
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
