Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5BC676B0082
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 04:08:08 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id uo5so5019489pbc.25
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 01:08:08 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id n8si6655856pax.247.2013.12.09.01.08.05
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 01:08:07 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 7/7] mm/migrate: remove result argument on page allocation function for migration
Date: Mon,  9 Dec 2013 18:10:48 +0900
Message-Id: <1386580248-22431-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, to allocate the page for migration, we implement their own functions
and pass it to migrate_pages(). These functions have 3 arguments, pointer
to original page, private data and result argument. Although there are
many allocation functions for migration, one of them, new_page_node() only
uses result argument. It uses result argument in following steps.

1. pass the pointer to allocation function to get an address for storing
information.
2. if we get an address and migration succeed, save node id of new page.
3. if we fail, save error number into it.

But, we don't need to store these information as it does.

First, we don't use error number in fail case. Call-path related to
new_page_node() is shown in the following.

do_move_page_to_node_array() -> migrate_pages() -> unmap_and_move()
-> new_page_node()

If unmap_and_move() failed, migrate_pages() also returns err, and then
do_move_page_to_node_array() skips to set page's status to user buffer.
So we don't need to set error number to each pages on failure case.

Next, we don't need to set node id of the new page in unmap_and_move(),
since it cannot be different with pm->node. In new_page_node(), we always
try to allocate the page in exact node by referencing pm->node. So it is
sufficient to set node id of the new page in new_page_node(), instead of
unmap_and_move().

These two changes make result argument useless, so we can remove it
entirely. It makes the code more undertandable.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 4308018..2755530 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -5,7 +5,7 @@
 #include <linux/mempolicy.h>
 #include <linux/migrate_mode.h>
 
-typedef struct page *new_page_t(struct page *, unsigned long private, int **);
+typedef struct page *new_page_t(struct page *, unsigned long private);
 
 /*
  * Return values from addresss_space_operations.migratepage():
diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 3fff8e7..2014211 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -62,7 +62,6 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
  */
 int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages);
 void unset_migratetype_isolate(struct page *page, unsigned migratetype);
-struct page *alloc_migrate_target(struct page *page, unsigned long private,
-				int **resultp);
+struct page *alloc_migrate_target(struct page *page, unsigned long private);
 
 #endif
diff --git a/mm/compaction.c b/mm/compaction.c
index f58bcd0..d340c9e 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -747,8 +747,7 @@ static void isolate_freepages(struct zone *zone,
  * from the isolated freelists in the block we are migrating to.
  */
 static struct page *compaction_alloc(struct page *migratepage,
-					unsigned long data,
-					int **result)
+					unsigned long data)
 {
 	struct compact_control *cc = (struct compact_control *)data;
 	struct page *freepage;
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 1debdea..f1a4665 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1399,7 +1399,7 @@ int unpoison_memory(unsigned long pfn)
 }
 EXPORT_SYMBOL(unpoison_memory);
 
-static struct page *new_page(struct page *p, unsigned long private, int **x)
+static struct page *new_page(struct page *p, unsigned long private)
 {
 	int nid = page_to_nid(p);
 	if (PageHuge(p))
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 6d04d37..978785e 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1027,7 +1027,7 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
 	}
 }
 
-static struct page *new_node_page(struct page *page, unsigned long node, int **x)
+static struct page *new_node_page(struct page *page, unsigned long node)
 {
 	if (PageHuge(page))
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
@@ -1186,7 +1186,7 @@ out:
  * list of pages handed to migrate_pages()--which is how we get here--
  * is in virtual address order.
  */
-static struct page *new_vma_page(struct page *page, unsigned long private, int **x)
+static struct page *new_vma_page(struct page *page, unsigned long private)
 {
 	struct vm_area_struct *vma = (struct vm_area_struct *)private;
 	unsigned long uninitialized_var(address);
@@ -1220,7 +1220,7 @@ int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
 	return -ENOSYS;
 }
 
-static struct page *new_vma_page(struct page *page, unsigned long private, int **x)
+static struct page *new_vma_page(struct page *page, unsigned long private)
 {
 	return NULL;
 }
diff --git a/mm/migrate.c b/mm/migrate.c
index b595f89..df8fa56 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -908,8 +908,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 			struct page *page, int force, enum migrate_mode mode)
 {
 	int rc = 0;
-	int *result = NULL;
-	struct page *newpage = get_new_page(page, private, &result);
+	struct page *newpage = get_new_page(page, private);
 
 	if (!newpage)
 		return -ENOMEM;
@@ -954,12 +953,6 @@ out:
 	 * then this will free the page.
 	 */
 	putback_lru_page(newpage);
-	if (result) {
-		if (rc)
-			*result = rc;
-		else
-			*result = page_to_nid(newpage);
-	}
 	return rc;
 }
 
@@ -986,7 +979,6 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 				int force, enum migrate_mode mode)
 {
 	int rc = 0;
-	int *result = NULL;
 	struct page *new_hpage;
 	struct anon_vma *anon_vma = NULL;
 
@@ -1002,7 +994,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 		return -ENOSYS;
 	}
 
-	new_hpage = get_new_page(hpage, private, &result);
+	new_hpage = get_new_page(hpage, private);
 	if (!new_hpage)
 		return -ENOMEM;
 
@@ -1036,12 +1028,6 @@ out:
 	if (rc != -EAGAIN)
 		putback_active_hugepage(hpage);
 	put_page(new_hpage);
-	if (result) {
-		if (rc)
-			*result = rc;
-		else
-			*result = page_to_nid(new_hpage);
-	}
 	return rc;
 }
 
@@ -1138,8 +1124,7 @@ struct page_to_node {
 	int status;
 };
 
-static struct page *new_page_node(struct page *p, unsigned long private,
-		int **result)
+static struct page *new_page_node(struct page *p, unsigned long private)
 {
 	struct page_to_node *pm = (struct page_to_node *)private;
 
@@ -1149,7 +1134,7 @@ static struct page *new_page_node(struct page *p, unsigned long private,
 	if (pm->node == MAX_NUMNODES)
 		return NULL;
 
-	*result = &pm->status;
+	pm->status = pm->node;
 
 	if (PageHuge(p))
 		return alloc_huge_page_node(page_hstate(compound_head(p)),
@@ -1535,8 +1520,7 @@ static bool migrate_balanced_pgdat(struct pglist_data *pgdat,
 }
 
 static struct page *alloc_misplaced_dst_page(struct page *page,
-					   unsigned long data,
-					   int **result)
+					   unsigned long data)
 {
 	int nid = (int) data;
 	struct page *newpage;
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index d1473b2..80efb1c 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -248,8 +248,7 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 	return ret ? 0 : -EBUSY;
 }
 
-struct page *alloc_migrate_target(struct page *page, unsigned long private,
-				  int **resultp)
+struct page *alloc_migrate_target(struct page *page, unsigned long private)
 {
 	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
