Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id AE7F16B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 21:07:49 -0500 (EST)
Received: by mail-da0-f42.google.com with SMTP id z17so434409dal.15
        for <linux-mm@kvack.org>; Fri, 25 Jan 2013 18:07:48 -0800 (PST)
Date: Fri, 25 Jan 2013 18:07:51 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 10/11] mm: remove offlining arg to migrate_pages
In-Reply-To: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
Message-ID: <alpine.LNX.2.00.1301251806330.29196@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

No functional change, but the only purpose of the offlining argument
to migrate_pages() etc, was to ensure that __unmap_and_move() could
migrate a KSM page for memory hotremove (which took ksm_thread_mutex)
but not for other callers.  Now all cases are safe, remove the arg.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/migrate.h |   14 ++++++--------
 mm/compaction.c         |    2 +-
 mm/memory-failure.c     |    7 +++----
 mm/memory_hotplug.c     |    3 +--
 mm/mempolicy.c          |    8 +++-----
 mm/migrate.c            |   35 +++++++++++++----------------------
 mm/page_alloc.c         |    6 ++----
 7 files changed, 29 insertions(+), 46 deletions(-)

--- mmotm.orig/include/linux/migrate.h	2013-01-24 12:28:38.740127550 -0800
+++ mmotm/include/linux/migrate.h	2013-01-25 14:38:51.468208776 -0800
@@ -40,11 +40,9 @@ extern void putback_movable_pages(struct
 extern int migrate_page(struct address_space *,
 			struct page *, struct page *, enum migrate_mode);
 extern int migrate_pages(struct list_head *l, new_page_t x,
-			unsigned long private, bool offlining,
-			enum migrate_mode mode, int reason);
+		unsigned long private, enum migrate_mode mode, int reason);
 extern int migrate_huge_page(struct page *, new_page_t x,
-			unsigned long private, bool offlining,
-			enum migrate_mode mode);
+		unsigned long private, enum migrate_mode mode);
 
 extern int fail_migrate_page(struct address_space *,
 			struct page *, struct page *);
@@ -62,11 +60,11 @@ extern int migrate_huge_page_move_mappin
 static inline void putback_lru_pages(struct list_head *l) {}
 static inline void putback_movable_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_page_t x,
-		unsigned long private, bool offlining,
-		enum migrate_mode mode, int reason) { return -ENOSYS; }
+		unsigned long private, enum migrate_mode mode, int reason)
+	{ return -ENOSYS; }
 static inline int migrate_huge_page(struct page *page, new_page_t x,
-		unsigned long private, bool offlining,
-		enum migrate_mode mode) { return -ENOSYS; }
+		unsigned long private, enum migrate_mode mode)
+	{ return -ENOSYS; }
 
 static inline int migrate_prep(void) { return -ENOSYS; }
 static inline int migrate_prep_local(void) { return -ENOSYS; }
--- mmotm.orig/mm/compaction.c	2013-01-24 12:28:38.740127550 -0800
+++ mmotm/mm/compaction.c	2013-01-25 14:38:51.472208776 -0800
@@ -980,7 +980,7 @@ static int compact_zone(struct zone *zon
 
 		nr_migrate = cc->nr_migratepages;
 		err = migrate_pages(&cc->migratepages, compaction_alloc,
-				(unsigned long)cc, false,
+				(unsigned long)cc,
 				cc->sync ? MIGRATE_SYNC_LIGHT : MIGRATE_ASYNC,
 				MR_COMPACTION);
 		update_nr_listpages(cc);
--- mmotm.orig/mm/memory-failure.c	2013-01-24 12:28:38.740127550 -0800
+++ mmotm/mm/memory-failure.c	2013-01-25 14:38:51.472208776 -0800
@@ -1432,7 +1432,7 @@ static int soft_offline_huge_page(struct
 		goto done;
 
 	/* Keep page count to indicate a given hugepage is isolated. */
-	ret = migrate_huge_page(hpage, new_page, MPOL_MF_MOVE_ALL, false,
+	ret = migrate_huge_page(hpage, new_page, MPOL_MF_MOVE_ALL,
 				MIGRATE_SYNC);
 	put_page(hpage);
 	if (ret) {
@@ -1564,11 +1564,10 @@ int soft_offline_page(struct page *page,
 	if (!ret) {
 		LIST_HEAD(pagelist);
 		inc_zone_page_state(page, NR_ISOLATED_ANON +
-					    page_is_file_cache(page));
+					page_is_file_cache(page));
 		list_add(&page->lru, &pagelist);
 		ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
-							false, MIGRATE_SYNC,
-							MR_MEMORY_FAILURE);
+					MIGRATE_SYNC, MR_MEMORY_FAILURE);
 		if (ret) {
 			putback_lru_pages(&pagelist);
 			pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
--- mmotm.orig/mm/memory_hotplug.c	2013-01-24 12:28:38.740127550 -0800
+++ mmotm/mm/memory_hotplug.c	2013-01-25 14:38:51.472208776 -0800
@@ -1283,8 +1283,7 @@ do_migrate_range(unsigned long start_pfn
 		 * migrate_pages returns # of failed pages.
 		 */
 		ret = migrate_pages(&source, alloc_migrate_target, 0,
-							true, MIGRATE_SYNC,
-							MR_MEMORY_HOTPLUG);
+					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
 		if (ret)
 			putback_lru_pages(&source);
 	}
--- mmotm.orig/mm/mempolicy.c	2013-01-25 14:38:49.596208731 -0800
+++ mmotm/mm/mempolicy.c	2013-01-25 14:38:51.472208776 -0800
@@ -1014,8 +1014,7 @@ static int migrate_to_node(struct mm_str
 
 	if (!list_empty(&pagelist)) {
 		err = migrate_pages(&pagelist, new_node_page, dest,
-							false, MIGRATE_SYNC,
-							MR_SYSCALL);
+					MIGRATE_SYNC, MR_SYSCALL);
 		if (err)
 			putback_lru_pages(&pagelist);
 	}
@@ -1259,9 +1258,8 @@ static long do_mbind(unsigned long start
 		if (!list_empty(&pagelist)) {
 			WARN_ON_ONCE(flags & MPOL_MF_LAZY);
 			nr_failed = migrate_pages(&pagelist, new_vma_page,
-						(unsigned long)vma,
-						false, MIGRATE_SYNC,
-						MR_MEMPOLICY_MBIND);
+					(unsigned long)vma,
+					MIGRATE_SYNC, MR_MEMPOLICY_MBIND);
 			if (nr_failed)
 				putback_lru_pages(&pagelist);
 		}
--- mmotm.orig/mm/migrate.c	2013-01-25 14:38:49.596208731 -0800
+++ mmotm/mm/migrate.c	2013-01-25 14:38:51.476208776 -0800
@@ -701,7 +701,7 @@ static int move_to_new_page(struct page
 }
 
 static int __unmap_and_move(struct page *page, struct page *newpage,
-			int force, bool offlining, enum migrate_mode mode)
+				int force, enum migrate_mode mode)
 {
 	int rc = -EAGAIN;
 	int remap_swapcache = 1;
@@ -847,8 +847,7 @@ out:
  * to the newly allocated page in newpage.
  */
 static int unmap_and_move(new_page_t get_new_page, unsigned long private,
-			struct page *page, int force, bool offlining,
-			enum migrate_mode mode)
+			struct page *page, int force, enum migrate_mode mode)
 {
 	int rc = 0;
 	int *result = NULL;
@@ -866,7 +865,7 @@ static int unmap_and_move(new_page_t get
 		if (unlikely(split_huge_page(page)))
 			goto out;
 
-	rc = __unmap_and_move(page, newpage, force, offlining, mode);
+	rc = __unmap_and_move(page, newpage, force, mode);
 
 	if (unlikely(rc == MIGRATEPAGE_BALLOON_SUCCESS)) {
 		/*
@@ -927,8 +926,7 @@ out:
  */
 static int unmap_and_move_huge_page(new_page_t get_new_page,
 				unsigned long private, struct page *hpage,
-				int force, bool offlining,
-				enum migrate_mode mode)
+				int force, enum migrate_mode mode)
 {
 	int rc = 0;
 	int *result = NULL;
@@ -990,9 +988,8 @@ out:
  *
  * Return: Number of pages not migrated or error code.
  */
-int migrate_pages(struct list_head *from,
-		new_page_t get_new_page, unsigned long private, bool offlining,
-		enum migrate_mode mode, int reason)
+int migrate_pages(struct list_head *from, new_page_t get_new_page,
+		unsigned long private, enum migrate_mode mode, int reason)
 {
 	int retry = 1;
 	int nr_failed = 0;
@@ -1013,8 +1010,7 @@ int migrate_pages(struct list_head *from
 			cond_resched();
 
 			rc = unmap_and_move(get_new_page, private,
-						page, pass > 2, offlining,
-						mode);
+						page, pass > 2, mode);
 
 			switch(rc) {
 			case -ENOMEM:
@@ -1047,15 +1043,13 @@ out:
 }
 
 int migrate_huge_page(struct page *hpage, new_page_t get_new_page,
-		      unsigned long private, bool offlining,
-		      enum migrate_mode mode)
+		      unsigned long private, enum migrate_mode mode)
 {
 	int pass, rc;
 
 	for (pass = 0; pass < 10; pass++) {
-		rc = unmap_and_move_huge_page(get_new_page,
-					      private, hpage, pass > 2, offlining,
-					      mode);
+		rc = unmap_and_move_huge_page(get_new_page, private,
+						hpage, pass > 2, mode);
 		switch (rc) {
 		case -ENOMEM:
 			goto out;
@@ -1178,8 +1172,7 @@ set_status:
 	err = 0;
 	if (!list_empty(&pagelist)) {
 		err = migrate_pages(&pagelist, new_page_node,
-				(unsigned long)pm, 0, MIGRATE_SYNC,
-				MR_SYSCALL);
+				(unsigned long)pm, MIGRATE_SYNC, MR_SYSCALL);
 		if (err)
 			putback_lru_pages(&pagelist);
 	}
@@ -1614,10 +1607,8 @@ int migrate_misplaced_page(struct page *
 		goto out;
 
 	list_add(&page->lru, &migratepages);
-	nr_remaining = migrate_pages(&migratepages,
-			alloc_misplaced_dst_page,
-			node, false, MIGRATE_ASYNC,
-			MR_NUMA_MISPLACED);
+	nr_remaining = migrate_pages(&migratepages, alloc_misplaced_dst_page,
+				     node, MIGRATE_ASYNC, MR_NUMA_MISPLACED);
 	if (nr_remaining) {
 		putback_lru_pages(&migratepages);
 		isolated = 0;
--- mmotm.orig/mm/page_alloc.c	2013-01-24 12:28:38.740127550 -0800
+++ mmotm/mm/page_alloc.c	2013-01-25 14:38:51.476208776 -0800
@@ -6064,10 +6064,8 @@ static int __alloc_contig_migrate_range(
 							&cc->migratepages);
 		cc->nr_migratepages -= nr_reclaimed;
 
-		ret = migrate_pages(&cc->migratepages,
-				    alloc_migrate_target,
-				    0, false, MIGRATE_SYNC,
-				    MR_CMA);
+		ret = migrate_pages(&cc->migratepages, alloc_migrate_target,
+				    0, MIGRATE_SYNC, MR_CMA);
 	}
 	if (ret < 0) {
 		putback_movable_pages(&cc->migratepages);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
