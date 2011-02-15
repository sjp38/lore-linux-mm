Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C9ACD8D0039
	for <linux-mm@kvack.org>; Tue, 15 Feb 2011 17:38:42 -0500 (EST)
Date: Tue, 15 Feb 2011 16:38:40 -0600
From: Jack Steiner <steiner@sgi.com>
Subject: [PATCH] - Improve drain pages performance on large systems
Message-ID: <20110215223840.GA27420@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org


Heavy swapping within a cpuset causes frequent calls to drain_all_pages().
This sends IPIs to all cpus to free PCP pages. In most cases, there are
no pages to be freed on cpus outside of the swapping cpuset.

Add checks to minimize locking and updates to potentially hot cachelines.
Before acquiring locks, do a quick check to see if any pages are in the PCP
queues. Exit if none.

On a 128 node SGI UV system, this reduced the IPI overhead to cpus outside of the
swapping cpuset by 38% and improved time to run a pass of the swaping test
from 98 sec to 51 sec. These times are obviously test & configuration
dependent but the improvements are significant.


Signed-off-by: Jack Steiner <steiner@sgi.com>

---
 mm/page_alloc.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c	2011-02-15 16:28:36.165921713 -0600
+++ linux/mm/page_alloc.c	2011-02-15 16:29:43.085502487 -0600
@@ -592,10 +592,24 @@ static void free_pcppages_bulk(struct zo
 	int batch_free = 0;
 	int to_free = count;
 
+	/*
+	 * Quick scan of zones. If all are empty, there is nothing to do.
+	 */
+	for (migratetype = 0; migratetype < MIGRATE_PCPTYPES; migratetype++) {
+		struct list_head *list;
+
+		list = &pcp->lists[migratetype];
+		if (!list_empty(list))
+			break;
+	}
+	if (migratetype == MIGRATE_PCPTYPES)
+		return;
+
 	spin_lock(&zone->lock);
 	zone->all_unreclaimable = 0;
 	zone->pages_scanned = 0;
 
+	migratetype = 0;
 	while (to_free) {
 		struct page *page;
 		struct list_head *list;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
