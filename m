Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1B47E6B005A
	for <linux-mm@kvack.org>; Sun, 28 Jun 2009 21:45:54 -0400 (EDT)
Subject: [PATCH 3/5]memhp: make pages from movable zone always isolatable
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain
Date: Mon, 29 Jun 2009 09:47:18 +0800
Message-Id: <1246240038.26292.19.camel@sli10-desk.sh.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Pages on movable zone have two types, MIGRATE_MOVABLE and MIGRATE_RESERVE,
both them can be movable, because only movable memory allocation can get
pages from movable zone. This makes pages in movable zone always be able
to migrate.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 mm/page_alloc.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c	2009-06-26 09:44:07.000000000 +0800
+++ linux/mm/page_alloc.c	2009-06-26 09:52:03.000000000 +0800
@@ -4900,13 +4900,16 @@ int set_migratetype_isolate(struct page 
 	struct zone *zone;
 	unsigned long flags;
 	int ret = -EBUSY;
+	int zone_idx;
 
 	zone = page_zone(page);
+	zone_idx = zone_idx(zone);
 	spin_lock_irqsave(&zone->lock, flags);
 	/*
 	 * In future, more migrate types will be able to be isolation target.
 	 */
-	if (get_pageblock_migratetype(page) != MIGRATE_MOVABLE)
+	if (get_pageblock_migratetype(page) != MIGRATE_MOVABLE &&
+	    zone_idx != ZONE_MOVABLE)
 		goto out;
 	set_pageblock_migratetype(page, MIGRATE_ISOLATE);
 	move_freepages_block(zone, page, MIGRATE_ISOLATE);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
