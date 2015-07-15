Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6733A28027E
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 02:34:23 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so19302566pdr.2
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 23:34:23 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id fo7si5834737pac.56.2015.07.14.23.34.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 23:34:22 -0700 (PDT)
Received: by pactm7 with SMTP id tm7so18733897pac.2
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 23:34:22 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 2/2] mm/page_owner: set correct gfp_mask on page_owner
Date: Wed, 15 Jul 2015 15:33:59 +0900
Message-Id: <1436942039-16897-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1436942039-16897-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1436942039-16897-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, we set wrong gfp_mask to page_owner info in case of
isolated freepage by compaction and split page. It causes incorrect
mixed pageblock report that we can get from '/proc/pagetypeinfo'.
This metric is really useful to measure fragmentation effect so
should be accurate. This patch fixes it by setting correct
information.

Without this patch, after kernel build workload is finished, number
of mixed pageblock is 112 among roughly 210 movable pageblocks.

But, with this fix, output shows that mixed pageblock is just 57.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/page_owner.h | 13 +++++++++++++
 mm/page_alloc.c            |  8 +++++---
 mm/page_owner.c            |  7 +++++++
 3 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/include/linux/page_owner.h b/include/linux/page_owner.h
index b48c347..cacaabe 100644
--- a/include/linux/page_owner.h
+++ b/include/linux/page_owner.h
@@ -8,6 +8,7 @@ extern struct page_ext_operations page_owner_ops;
 extern void __reset_page_owner(struct page *page, unsigned int order);
 extern void __set_page_owner(struct page *page,
 			unsigned int order, gfp_t gfp_mask);
+extern gfp_t __get_page_owner_gfp(struct page *page);
 
 static inline void reset_page_owner(struct page *page, unsigned int order)
 {
@@ -25,6 +26,14 @@ static inline void set_page_owner(struct page *page,
 
 	__set_page_owner(page, order, gfp_mask);
 }
+
+static inline gfp_t get_page_owner_gfp(struct page *page)
+{
+	if (likely(!page_owner_inited))
+		return 0;
+
+	return __get_page_owner_gfp(page);
+}
 #else
 static inline void reset_page_owner(struct page *page, unsigned int order)
 {
@@ -33,6 +42,10 @@ static inline void set_page_owner(struct page *page,
 			unsigned int order, gfp_t gfp_mask)
 {
 }
+static inline gfp_t get_page_owner_gfp(struct page *page)
+{
+	return 0;
+}
 
 #endif /* CONFIG_PAGE_OWNER */
 #endif /* __LINUX_PAGE_OWNER_H */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 70d6a85..3ce3ec2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1957,6 +1957,7 @@ void free_hot_cold_page_list(struct list_head *list, bool cold)
 void split_page(struct page *page, unsigned int order)
 {
 	int i;
+	gfp_t gfp_mask;
 
 	VM_BUG_ON_PAGE(PageCompound(page), page);
 	VM_BUG_ON_PAGE(!page_count(page), page);
@@ -1970,10 +1971,11 @@ void split_page(struct page *page, unsigned int order)
 		split_page(virt_to_page(page[0].shadow), order);
 #endif
 
-	set_page_owner(page, 0, 0);
+	gfp_mask = get_page_owner_gfp(page);
+	set_page_owner(page, 0, gfp_mask);
 	for (i = 1; i < (1 << order); i++) {
 		set_page_refcounted(page + i);
-		set_page_owner(page + i, 0, 0);
+		set_page_owner(page + i, 0, gfp_mask);
 	}
 }
 EXPORT_SYMBOL_GPL(split_page);
@@ -2003,7 +2005,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
 	zone->free_area[order].nr_free--;
 	rmv_page_order(page);
 
-	set_page_owner(page, order, 0);
+	set_page_owner(page, order, __GFP_MOVABLE);
 
 	/* Set the pageblock if the isolated page is at least a pageblock */
 	if (order >= pageblock_order - 1) {
diff --git a/mm/page_owner.c b/mm/page_owner.c
index 0993f5f..a3c4aed 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -76,6 +76,13 @@ void __set_page_owner(struct page *page, unsigned int order, gfp_t gfp_mask)
 	__set_bit(PAGE_EXT_OWNER, &page_ext->flags);
 }
 
+gfp_t __get_page_owner_gfp(struct page *page)
+{
+	struct page_ext *page_ext = lookup_page_ext(page);
+
+	return page_ext->gfp_mask;
+}
+
 static ssize_t
 print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 		struct page *page, struct page_ext *page_ext)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
