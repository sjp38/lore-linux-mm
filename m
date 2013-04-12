Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id CF49E6B0068
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:33 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 11 Apr 2013 21:14:32 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id B05BDC90048
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:23 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C1ENPa62718126
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:23 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C1EMr5015761
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 22:14:23 -0300
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 07/25] page_alloc: add return_pages_to_zone() when DYNAMIC_NUMA is enabled.
Date: Thu, 11 Apr 2013 18:13:39 -0700
Message-Id: <1365729237-29711-8-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

Add return_pages_to_zone(), which uses return_page_to_zone().
It is a minimized version of __free_pages_ok() which handles adding
pages which have been removed from another zone into a new zone.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/internal.h   |  5 ++++-
 mm/page_alloc.c | 17 +++++++++++++++++
 2 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/mm/internal.h b/mm/internal.h
index b11e574..a70c77b 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -104,6 +104,10 @@ extern void prep_compound_page(struct page *page, unsigned long order);
 #ifdef CONFIG_MEMORY_FAILURE
 extern bool is_free_buddy_page(struct page *page);
 #endif
+#ifdef CONFIG_DYNAMIC_NUMA
+void return_pages_to_zone(struct page *page, unsigned int order,
+			  struct zone *zone);
+#endif
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 /*
@@ -114,7 +118,6 @@ extern int ensure_zone_is_initialized(struct zone *zone,
 #endif
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
-
 /*
  * in mm/compaction.c
  */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 96909bb..1fbf5f2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -442,6 +442,12 @@ static inline void set_page_order(struct page *page, int order)
 	__SetPageBuddy(page);
 }
 
+static inline void set_free_page_order(struct page *page, int order)
+{
+	set_page_private(page, order);
+	VM_BUG_ON(!PageBuddy(page));
+}
+
 static inline void rmv_page_order(struct page *page)
 {
 	__ClearPageBuddy(page);
@@ -738,6 +744,17 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	local_irq_restore(flags);
 }
 
+#ifdef CONFIG_DYNAMIC_NUMA
+void return_pages_to_zone(struct page *page, unsigned int order,
+			  struct zone *zone)
+{
+	unsigned long flags;
+	local_irq_save(flags);
+	free_one_page(zone, page, order, get_freepage_migratetype(page));
+	local_irq_restore(flags);
+}
+#endif
+
 /*
  * Read access to zone->managed_pages is safe because it's unsigned long,
  * but we still need to serialize writers. Currently all callers of
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
