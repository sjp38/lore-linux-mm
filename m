Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 3C9C16B0002
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:26:58 -0500 (EST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 28 Feb 2013 14:26:56 -0700
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 7E8E13E40052
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 14:26:40 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1SLQjuD115752
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 14:26:46 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1SLTF0S016206
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 14:29:15 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 10/24] page_alloc: add return_pages_to_zone() when DYNAMIC_NUMA is enabled.
Date: Thu, 28 Feb 2013 13:26:07 -0800
Message-Id: <1362086781-16725-1-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>, David Hansen <dave@linux.vnet.ibm.com>

Add return_pages_to_zone(), which uses return_page_to_zone().
It is a minimized version of __free_pages_ok() which handles adding
pages which have been removed from another zone into a new zone.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/internal.h   |  5 ++++-
 mm/page_alloc.c | 17 +++++++++++++++++
 2 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/mm/internal.h b/mm/internal.h
index 6c63752..b075e34 100644
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
index 0dade3f..bbc9b6e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -449,6 +449,12 @@ static inline void set_page_order(struct page *page, int order)
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
@@ -745,6 +751,17 @@ static void __free_pages_ok(struct page *page, unsigned int order)
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
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
