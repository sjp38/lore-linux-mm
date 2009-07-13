Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2395A6B004F
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 22:10:54 -0400 (EDT)
Date: Mon, 13 Jul 2009 10:30:30 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: [PATCH] switch free memory back to MIGRATE_MOVABLE
Message-ID: <20090713023030.GA27269@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mel@csn.ul.ie, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

When page is back to buddy and its order is bigger than pageblock_order, we can
switch its type to MIGRATE_MOVABLE. This can reduce fragmentation. The patch
has obvious effect when read a block device and then drop caches.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 mm/page_alloc.c |    9 +++++++++
 1 file changed, 9 insertions(+)

Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c	2009-07-10 11:36:07.000000000 +0800
+++ linux/mm/page_alloc.c	2009-07-13 09:25:21.000000000 +0800
@@ -475,6 +475,15 @@ static inline void __free_one_page(struc
 		order++;
 	}
 	set_page_order(page, order);
+
+	if (order >= pageblock_order && migratetype != MIGRATE_MOVABLE) {
+		int i;
+
+		migratetype = MIGRATE_MOVABLE;
+		for (i = 0; i < (1 << (order - pageblock_order)); i++)
+			set_pageblock_migratetype(page +
+				i * pageblock_nr_pages, MIGRATE_MOVABLE);
+	}
 	list_add(&page->lru,
 		&zone->free_area[order].free_list[migratetype]);
 	zone->free_area[order].nr_free++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
