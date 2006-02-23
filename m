Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
        by fgwmail6.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k1N90XZq027583 for <linux-mm@kvack.org>; Thu, 23 Feb 2006 18:00:33 +0900
        (envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s6.gw.fujitsu.co.jp by m1.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k1N90VtL030023 for <linux-mm@kvack.org>; Thu, 23 Feb 2006 18:00:31 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s6.gw.fujitsu.co.jp (s6 [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B2A902A0C03
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 18:00:31 +0900 (JST)
Received: from fjm506.ms.jp.fujitsu.com (fjm506.ms.jp.fujitsu.com [10.56.99.86])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 50E4C2A0BF9
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 18:00:31 +0900 (JST)
Received: from aworks (fjmscan503.ms.jp.fujitsu.com [10.56.99.143])by fjm506.ms.jp.fujitsu.com with SMTP id k1N90Hxe015580
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 18:00:17 +0900
Date: Thu, 23 Feb 2006 18:00:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] memory-layout-free zones (for review) [3/3]  fix
 for_each_page_in_zone
Message-Id: <20060223180023.396d2cfe.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

To remove zone_start_pfn/zone_spanned_pages, for_each_page_in_zone()
must be modified. This pacth uses pgdat instead of zones and calls
page_zone() to check page is in zone.
Maybe slower (>_<......

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: node-hot-add2/include/linux/mm.h
===================================================================
--- node-hot-add2.orig/include/linux/mm.h
+++ node-hot-add2/include/linux/mm.h
@@ -549,6 +549,64 @@ void page_address_init(void);
 #define page_address_init()  do { } while(0)
 #endif
 
+
+/*
+ *  These inline function for for_each_page_in_zone can work
+ *  even if CONFIG_SPARSEMEM=y.
+ */
+static inline struct page *first_page_in_zone(struct zone *zone)
+{
+	struct pglist_data *pgdat;
+	unsigned long start_pfn;
+	unsigned long i = 0;
+
+	if (!populated_zone(zone))
+		return NULL;
+
+	pgdat = zone->zone_pgdat;
+	zone = pgdat->node_start_pfn;
+
+	for (i = 0; i < pgdat->zone_spanned_pages; i++) {
+		if (pfn_valid(start_pfn + i) && page_zone(page) == zone)
+			break;
+	}
+	BUG_ON(i == pgdat->node_spanned_pages); /* zone is populated */
+	return pfn_to_page(start_pfn + i);
+}
+
+static inline struct page *next_page_in_zone(struct page *page,
+					     struct zone *zone)
+{
+	struct pglist_data *pgdat;
+	unsigned long start_pfn;
+	unsigned long i;
+
+	if (!populated_zone(zone))
+		return NULL;
+	pgdat = zone->zone_pgdat;
+	start_pfn = pgdat->node_start_pfn;
+	i = page_to_pfn(page) - start_pfn;
+
+	for (i = i + 1; i < pgdat->node_spanned_pages; i++) {
+		if (pfn_vlaid(start_pfn + i) && page_zone(page) == zone)
+			break;
+	}
+	if (i == pgdat->node_spanned_pages)
+		return NULL;
+	return pfn_to_page(start_pfn + i);
+}
+
+/**
+ * for_each_page_in_zone -- helper macro to iterate over all pages in a zone.
+ * @page - pointer to page
+ * @zone - pointer to zone
+ *
+ */
+#define for_each_page_in_zone(page, zone)		\
+	for (page = (first_page_in_zone((zone)));	\
+	     page;					\
+	     page = next_page_in_zone(page, (zone)));
+
 /*
  * On an anonymous page mapped into a user virtual memory area,
  * page->mapping points to its anon_vma, not to a struct address_space;
Index: node-hot-add2/include/linux/mmzone.h
===================================================================
--- node-hot-add2.orig/include/linux/mmzone.h
+++ node-hot-add2/include/linux/mmzone.h
@@ -457,53 +457,6 @@ static inline struct zone *next_zone(str
 	     zone;					\
 	     zone = next_zone(zone))
 
-/*
- *  These inline function for for_each_page_in_zone can work
- *  even if CONFIG_SPARSEMEM=y.
- */
-static inline struct page *first_page_in_zone(struct zone *zone)
-{
-	unsigned long start_pfn = zone->zone_start_pfn;
-	unsigned long i = 0;
-
-	if (!populated_zone(zone))
-		return NULL;
-
-	for (i = 0; i < zone->zone_spanned_pages; i++) {
-		if (pfn_valid(start_pfn + i))
-			break;
-	}
-	return pfn_to_page(start_pfn + i);
-}
-
-static inline struct page *next_page_in_zone(struct page *page,
-					     struct zone *zone)
-{
-	unsigned long start_pfn = zone->zone_start_pfn;
-	unsigned long i = page_to_pfn(page) - start_pfn;
-
-	if (!populated_zone(zone))
-		return NULL;
-
-	for (i = i + 1; i < zone->zone_spanned_pages; i++) {
-		if (pfn_vlaid(start_pfn + i))
-			break;
-	}
-	if (i == zone->zone_spanned_pages)
-		return NULL;
-	return pfn_to_page(start_pfn + i);
-}
-
-/**
- * for_each_page_in_zone -- helper macro to iterate over all pages in a zone.
- * @page - pointer to page
- * @zone - pointer to zone
- *
- */
-#define for_each_page_in_zone(page, zone)		\
-	for (page = (first_page_in_zone((zone)));	\
-	     page;					\
-	     page = next_page_in_zone(page, (zone)));
 
 #ifdef CONFIG_SPARSEMEM
 #include <asm/sparsemem.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
