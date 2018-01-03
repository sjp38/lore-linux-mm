Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 234BE6B0302
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 03:26:12 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id d4so518280plr.8
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 00:26:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w22sor149636pll.119.2018.01.03.00.26.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 00:26:10 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/3] mm, migrate: remove reason argument from new_page_t
Date: Wed,  3 Jan 2018 09:25:54 +0100
Message-Id: <20180103082555.14592-3-mhocko@kernel.org>
In-Reply-To: <20180103082555.14592-1-mhocko@kernel.org>
References: <20180103082555.14592-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrea Reale <ar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

No allocation callback is using this argument anymore. new_page_node
used to use this parameter to convey node_id resp. migration error
up to move_pages code (do_move_page_to_node_array). The error status
never made it into the final status field and we have a better way
to communicate node id to the status field now. All other allocation
callbacks simply ignored the argument so we can drop it finally.

Reviewed-by: Zi Yan <zi.yan@cs.rutgers.edu>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/migrate.h        |  3 +--
 include/linux/page-isolation.h |  3 +--
 mm/compaction.c                |  3 +--
 mm/internal.h                  |  2 +-
 mm/memory_hotplug.c            |  3 +--
 mm/mempolicy.c                 |  6 +++---
 mm/migrate.c                   | 18 ++----------------
 mm/page_isolation.c            |  3 +--
 8 files changed, 11 insertions(+), 30 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index a2246cf670ba..e5d99ade2319 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -7,8 +7,7 @@
 #include <linux/migrate_mode.h>
 #include <linux/hugetlb.h>
 
-typedef struct page *new_page_t(struct page *page, unsigned long private,
-				int **reason);
+typedef struct page *new_page_t(struct page *page, unsigned long private);
 typedef void free_page_t(struct page *page, unsigned long private);
 
 /*
diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index cdad58bbfd8b..4ae347cbc36d 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -63,7 +63,6 @@ undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 			bool skip_hwpoisoned_pages);
 
-struct page *alloc_migrate_target(struct page *page, unsigned long private,
-				int **resultp);
+struct page *alloc_migrate_target(struct page *page, unsigned long private);
 
 #endif
diff --git a/mm/compaction.c b/mm/compaction.c
index b8c23882c8ae..4589830b5959 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1165,8 +1165,7 @@ static void isolate_freepages(struct compact_control *cc)
  * from the isolated freelists in the block we are migrating to.
  */
 static struct page *compaction_alloc(struct page *migratepage,
-					unsigned long data,
-					int **result)
+					unsigned long data)
 {
 	struct compact_control *cc = (struct compact_control *)data;
 	struct page *freepage;
diff --git a/mm/internal.h b/mm/internal.h
index 745e247aca9c..62d8c34e63d5 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -540,5 +540,5 @@ static inline bool is_migrate_highatomic_page(struct page *page)
 }
 
 void setup_zone_pageset(struct zone *zone);
-extern struct page *alloc_new_node_page(struct page *page, unsigned long node, int **x);
+extern struct page *alloc_new_node_page(struct page *page, unsigned long node);
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 262bfd26baf9..9a2381469172 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1344,8 +1344,7 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
 	return 0;
 }
 
-static struct page *new_node_page(struct page *page, unsigned long private,
-		int **result)
+static struct page *new_node_page(struct page *page, unsigned long private)
 {
 	int nid = page_to_nid(page);
 	nodemask_t nmask = node_states[N_MEMORY];
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 66c9c79b21be..4d849d3098e5 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -943,7 +943,7 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
 }
 
 /* page allocation callback for NUMA node migration */
-struct page *alloc_new_node_page(struct page *page, unsigned long node, int **x)
+struct page *alloc_new_node_page(struct page *page, unsigned long node)
 {
 	if (PageHuge(page))
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
@@ -1108,7 +1108,7 @@ int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
  * list of pages handed to migrate_pages()--which is how we get here--
  * is in virtual address order.
  */
-static struct page *new_page(struct page *page, unsigned long start, int **x)
+static struct page *new_page(struct page *page, unsigned long start)
 {
 	struct vm_area_struct *vma;
 	unsigned long uninitialized_var(address);
@@ -1153,7 +1153,7 @@ int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
 	return -ENOSYS;
 }
 
-static struct page *new_page(struct page *page, unsigned long start, int **x)
+static struct page *new_page(struct page *page, unsigned long start)
 {
 	return NULL;
 }
diff --git a/mm/migrate.c b/mm/migrate.c
index 8fb90bcd44a7..aba3759a2e27 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1136,10 +1136,9 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 				   enum migrate_reason reason)
 {
 	int rc = MIGRATEPAGE_SUCCESS;
-	int *result = NULL;
 	struct page *newpage;
 
-	newpage = get_new_page(page, private, &result);
+	newpage = get_new_page(page, private);
 	if (!newpage)
 		return -ENOMEM;
 
@@ -1230,12 +1229,6 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 			put_page(newpage);
 	}
 
-	if (result) {
-		if (rc)
-			*result = rc;
-		else
-			*result = page_to_nid(newpage);
-	}
 	return rc;
 }
 
@@ -1263,7 +1256,6 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 				enum migrate_mode mode, int reason)
 {
 	int rc = -EAGAIN;
-	int *result = NULL;
 	int page_was_mapped = 0;
 	struct page *new_hpage;
 	struct anon_vma *anon_vma = NULL;
@@ -1280,7 +1272,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 		return -ENOSYS;
 	}
 
-	new_hpage = get_new_page(hpage, private, &result);
+	new_hpage = get_new_page(hpage, private);
 	if (!new_hpage)
 		return -ENOMEM;
 
@@ -1345,12 +1337,6 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	else
 		putback_active_hugepage(new_hpage);
 
-	if (result) {
-		if (rc)
-			*result = rc;
-		else
-			*result = page_to_nid(new_hpage);
-	}
 	return rc;
 }
 
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 165ed8117bd1..53d801235e22 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -293,8 +293,7 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 	return pfn < end_pfn ? -EBUSY : 0;
 }
 
-struct page *alloc_migrate_target(struct page *page, unsigned long private,
-				  int **resultp)
+struct page *alloc_migrate_target(struct page *page, unsigned long private)
 {
 	return new_page_nodemask(page, numa_node_id(), &node_states[N_MEMORY]);
 }
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
