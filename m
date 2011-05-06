Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5B8E06B0025
	for <linux-mm@kvack.org>; Fri,  6 May 2011 17:17:35 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 1/2] Add alloc_pages_exact_nid()
Date: Fri,  6 May 2011 14:17:16 -0700
Message-Id: <1304716637-19556-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

From: Andi Kleen <ak@linux.intel.com>

Add a alloc_pages_exact_nid() that allocates on a specific node.

The naming is quite broken, but fixing that would need a larger
renaming action.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 include/linux/gfp.h |    2 ++
 mm/page_alloc.c     |   48 ++++++++++++++++++++++++++++++++++++------------
 2 files changed, 38 insertions(+), 12 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index bfb8f93..56d8fc8 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -353,6 +353,8 @@ extern unsigned long get_zeroed_page(gfp_t gfp_mask);
 
 void *alloc_pages_exact(size_t size, gfp_t gfp_mask);
 void free_pages_exact(void *virt, size_t size);
+/* This is different from alloc_pages_exact_node !!! */
+void *alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
 
 #define __get_free_page(gfp_mask) \
 		__get_free_pages((gfp_mask), 0)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9f8a97b..44e175d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2317,6 +2317,21 @@ void free_pages(unsigned long addr, unsigned int order)
 
 EXPORT_SYMBOL(free_pages);
 
+static void *make_alloc_exact(unsigned long addr, unsigned order, size_t size)
+{
+	if (addr) {
+		unsigned long alloc_end = addr + (PAGE_SIZE << order);
+		unsigned long used = addr + PAGE_ALIGN(size);
+
+		split_page(virt_to_page((void *)addr), order);
+		while (used < alloc_end) {
+			free_page(used);
+			used += PAGE_SIZE;
+		}
+	}
+	return (void *)addr;	
+}
+
 /**
  * alloc_pages_exact - allocate an exact number physically-contiguous pages.
  * @size: the number of bytes to allocate
@@ -2336,22 +2351,31 @@ void *alloc_pages_exact(size_t size, gfp_t gfp_mask)
 	unsigned long addr;
 
 	addr = __get_free_pages(gfp_mask, order);
-	if (addr) {
-		unsigned long alloc_end = addr + (PAGE_SIZE << order);
-		unsigned long used = addr + PAGE_ALIGN(size);
-
-		split_page(virt_to_page((void *)addr), order);
-		while (used < alloc_end) {
-			free_page(used);
-			used += PAGE_SIZE;
-		}
-	}
-
-	return (void *)addr;
+	return make_alloc_exact(addr, order, size);
 }
 EXPORT_SYMBOL(alloc_pages_exact);
 
 /**
+ * alloc_pages_exact_nid - allocate an exact number physically-contiguous pages on node.
+ * @size: the number of bytes to allocate
+ * @gfp_mask: GFP flags for the allocation
+ *
+ * Like alloc_pages_exact, but try to allocate on node nid first
+ * before falling back.
+ * Note this is not alloc_pages_exact_node() which allocates
+ * on a specific node, but is not exact.
+ */
+void *alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask)
+{
+	unsigned order = get_order(size);
+	struct page *p = alloc_pages_node(nid, gfp_mask, order);
+	if (!p)
+		return NULL;
+	return make_alloc_exact((unsigned long)page_address(p), order, size);
+}
+EXPORT_SYMBOL(alloc_pages_exact_nid);
+
+/**
  * free_pages_exact - release memory allocated via alloc_pages_exact()
  * @virt: the value returned by alloc_pages_exact.
  * @size: size of allocation, same value as passed to alloc_pages_exact().
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
