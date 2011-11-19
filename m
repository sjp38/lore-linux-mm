Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2ED866B006E
	for <linux-mm@kvack.org>; Sat, 19 Nov 2011 14:54:39 -0500 (EST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 5/8] mm: compaction: avoid overwork in migrate sync mode
Date: Sat, 19 Nov 2011 20:54:17 +0100
Message-Id: <1321732460-14155-6-git-send-email-aarcange@redhat.com>
In-Reply-To: <1321635524-8586-1-git-send-email-mgorman@suse.de>
References: <1321635524-8586-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, linux-kernel@vger.kernel.org

Add a lightweight sync migration (sync == 2) mode that avoids overwork
so more suitable to be used by compaction to provide lower latency but
still write throttling. It's unclear if this makes a lot of difference
or if we must make async migration more reliable, but looping 10 times
for compaction sounds excessive. 3 passes async, and 2 passes sync
should be more than enough to get good reliability of migrate when
invoked by sync compaction. Async compaction then runs 3 passes
async.

The sync + force flags were mostly overlapping and with almost the
same meaning so this removes the "sync" flag and keeps the "force"
flag from most migrate functions. Practically the only benefit of the
sync flag was to not retry on writeback pages if invoked through async
migration, but if we retry on the locked pages we can as well retry on
the writeback pages. It should be more worthwhile to retry only 3
times instead of 10 times, if we want to save CPU, than to avoid
retrying on the writeback pages only (but keep retrying on pinned and
locked pages). The locked pages are more likely to become unlocked
more quickly, the pinned pages too, but the benefit of not retrying on
writeback pages shouldn't be significant enough to require a special
flag.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/migrate.h |    8 ++--
 mm/compaction.c         |    2 +-
 mm/memory-failure.c     |    2 +-
 mm/memory_hotplug.c     |    2 +-
 mm/mempolicy.c          |    4 +-
 mm/migrate.c            |   95 +++++++++++++++++++++++++++++++----------------
 6 files changed, 72 insertions(+), 41 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index e39aeec..f26fc0e 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -14,10 +14,10 @@ extern int migrate_page(struct address_space *,
 			struct page *, struct page *);
 extern int migrate_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
-			bool sync);
+			int sync);
 extern int migrate_huge_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
-			bool sync);
+			int sync);
 
 extern int fail_migrate_page(struct address_space *,
 			struct page *, struct page *);
@@ -36,10 +36,10 @@ extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 static inline void putback_lru_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_page_t x,
 		unsigned long private, bool offlining,
-		bool sync) { return -ENOSYS; }
+		int sync) { return -ENOSYS; }
 static inline int migrate_huge_pages(struct list_head *l, new_page_t x,
 		unsigned long private, bool offlining,
-		bool sync) { return -ENOSYS; }
+		int sync) { return -ENOSYS; }
 
 static inline int migrate_prep(void) { return -ENOSYS; }
 static inline int migrate_prep_local(void) { return -ENOSYS; }
diff --git a/mm/compaction.c b/mm/compaction.c
index 615502b..9a7fbf5 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -552,7 +552,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		nr_migrate = cc->nr_migratepages;
 		err = migrate_pages(&cc->migratepages, compaction_alloc,
 				(unsigned long)cc, false,
-				cc->sync);
+				cc->sync ? 2 : 0);
 		update_nr_listpages(cc);
 		nr_remaining = cc->nr_migratepages;
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 06d3479..d8a41d3 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1557,7 +1557,7 @@ int soft_offline_page(struct page *page, int flags)
 					    page_is_file_cache(page));
 		list_add(&page->lru, &pagelist);
 		ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
-								0, true);
+				    false, 1);
 		if (ret) {
 			putback_lru_pages(&pagelist);
 			pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 2168489..e1d6176 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -809,7 +809,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 		}
 		/* this function returns # of failed pages */
 		ret = migrate_pages(&source, hotremove_migrate_alloc, 0,
-								true, true);
+				    true, 1);
 		if (ret)
 			putback_lru_pages(&source);
 	}
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index adc3954..0bf88ed 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -933,7 +933,7 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
 
 	if (!list_empty(&pagelist)) {
 		err = migrate_pages(&pagelist, new_node_page, dest,
-								false, true);
+				    false, 1);
 		if (err)
 			putback_lru_pages(&pagelist);
 	}
@@ -1154,7 +1154,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 		if (!list_empty(&pagelist)) {
 			nr_failed = migrate_pages(&pagelist, new_vma_page,
 						(unsigned long)vma,
-						false, true);
+						false, 1);
 			if (nr_failed)
 				putback_lru_pages(&pagelist);
 		}
diff --git a/mm/migrate.c b/mm/migrate.c
index 578e291..612c3ba 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -564,7 +564,7 @@ static int fallback_migrate_page(struct address_space *mapping,
  *  == 0 - success
  */
 static int move_to_new_page(struct page *newpage, struct page *page,
-					int remap_swapcache, bool sync)
+			    int remap_swapcache, bool force)
 {
 	struct address_space *mapping;
 	int rc;
@@ -588,11 +588,11 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 		rc = migrate_page(mapping, newpage, page);
 	else {
 		/*
-		 * Do not writeback pages if !sync and migratepage is
+		 * Do not writeback pages if !force and migratepage is
 		 * not pointing to migrate_page() which is nonblocking
 		 * (swapcache/tmpfs uses migratepage = migrate_page).
 		 */
-		if (PageDirty(page) && !sync &&
+		if (PageDirty(page) && !force &&
 		    mapping->a_ops->migratepage != migrate_page)
 			rc = -EBUSY;
 		else if (mapping->a_ops->migratepage)
@@ -622,7 +622,7 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 }
 
 static int __unmap_and_move(struct page *page, struct page *newpage,
-				int force, bool offlining, bool sync)
+			    bool force, bool offlining)
 {
 	int rc = -EAGAIN;
 	int remap_swapcache = 1;
@@ -631,7 +631,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	struct anon_vma *anon_vma = NULL;
 
 	if (!trylock_page(page)) {
-		if (!force || !sync)
+		if (!force)
 			goto out;
 
 		/*
@@ -676,14 +676,6 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	BUG_ON(charge);
 
 	if (PageWriteback(page)) {
-		/*
-		 * For !sync, there is no point retrying as the retry loop
-		 * is expected to be too short for PageWriteback to be cleared
-		 */
-		if (!sync) {
-			rc = -EBUSY;
-			goto uncharge;
-		}
 		if (!force)
 			goto uncharge;
 		wait_on_page_writeback(page);
@@ -751,7 +743,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 
 skip_unmap:
 	if (!page_mapped(page))
-		rc = move_to_new_page(newpage, page, remap_swapcache, sync);
+		rc = move_to_new_page(newpage, page, remap_swapcache, force);
 
 	if (rc && remap_swapcache)
 		remove_migration_ptes(page, page);
@@ -774,7 +766,7 @@ out:
  * to the newly allocated page in newpage.
  */
 static int unmap_and_move(new_page_t get_new_page, unsigned long private,
-			struct page *page, int force, bool offlining, bool sync)
+			  struct page *page, bool force, bool offlining)
 {
 	int rc = 0;
 	int *result = NULL;
@@ -792,7 +784,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 		if (unlikely(split_huge_page(page)))
 			goto out;
 
-	rc = __unmap_and_move(page, newpage, force, offlining, sync);
+	rc = __unmap_and_move(page, newpage, force, offlining);
 out:
 	if (rc != -EAGAIN) {
 		/*
@@ -840,7 +832,7 @@ out:
  */
 static int unmap_and_move_huge_page(new_page_t get_new_page,
 				unsigned long private, struct page *hpage,
-				int force, bool offlining, bool sync)
+				bool force, bool offlining)
 {
 	int rc = 0;
 	int *result = NULL;
@@ -853,7 +845,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	rc = -EAGAIN;
 
 	if (!trylock_page(hpage)) {
-		if (!force || !sync)
+		if (!force)
 			goto out;
 		lock_page(hpage);
 	}
@@ -864,7 +856,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	try_to_unmap(hpage, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
 
 	if (!page_mapped(hpage))
-		rc = move_to_new_page(new_hpage, hpage, 1, sync);
+		rc = move_to_new_page(new_hpage, hpage, 1, force);
 
 	if (rc)
 		remove_migration_ptes(hpage, hpage);
@@ -907,11 +899,11 @@ out:
  */
 int migrate_pages(struct list_head *from,
 		new_page_t get_new_page, unsigned long private, bool offlining,
-		bool sync)
+		int sync)
 {
 	int retry = 1;
 	int nr_failed = 0;
-	int pass = 0;
+	int pass, passes;
 	struct page *page;
 	struct page *page2;
 	int swapwrite = current->flags & PF_SWAPWRITE;
@@ -920,15 +912,34 @@ int migrate_pages(struct list_head *from,
 	if (!swapwrite)
 		current->flags |= PF_SWAPWRITE;
 
-	for(pass = 0; pass < 10 && retry; pass++) {
+	switch (sync) {
+	case 0:
+		/* 3 async  0 sync */
+		passes = 3;
+		break;
+	case 1:
+		/* 3 async, 7 sync */
+		passes = 10;
+		break;
+	case 2:
+		/*
+		 * sync = 2 asks for a lightweight synchronous mode:
+		 * 3 async, 2 sync.
+		 */
+		passes = 5;
+		break;
+	default:
+		BUG();
+	}
+
+	for(pass = 0; pass < passes && retry; pass++) {
 		retry = 0;
 
 		list_for_each_entry_safe(page, page2, from, lru) {
 			cond_resched();
 
-			rc = unmap_and_move(get_new_page, private,
-						page, pass > 2, offlining,
-						sync);
+			rc = unmap_and_move(get_new_page, private, page,
+					    pass > 2, offlining);
 
 			switch(rc) {
 			case -ENOMEM:
@@ -958,24 +969,44 @@ out:
 
 int migrate_huge_pages(struct list_head *from,
 		new_page_t get_new_page, unsigned long private, bool offlining,
-		bool sync)
+		int sync)
 {
 	int retry = 1;
 	int nr_failed = 0;
-	int pass = 0;
+	int pass, passes;
 	struct page *page;
 	struct page *page2;
 	int rc;
 
-	for (pass = 0; pass < 10 && retry; pass++) {
+	switch (sync) {
+	case 0:
+		/* 3 async  0 sync */
+		passes = 3;
+		break;
+	case 1:
+		/* 3 async, 7 sync */
+		passes = 10;
+		break;
+	case 2:
+		/*
+		 * sync = 2 asks for a lightweight synchronous mode:
+		 * 3 async, 2 sync.
+		 */
+		passes = 5;
+		break;
+	default:
+		BUG();
+	}
+
+	for (pass = 0; pass < passes && retry; pass++) {
 		retry = 0;
 
 		list_for_each_entry_safe(page, page2, from, lru) {
 			cond_resched();
 
-			rc = unmap_and_move_huge_page(get_new_page,
-					private, page, pass > 2, offlining,
-					sync);
+			rc = unmap_and_move_huge_page(get_new_page, private,
+						      page, pass > 2,
+						      offlining);
 
 			switch(rc) {
 			case -ENOMEM:
@@ -1104,7 +1135,7 @@ set_status:
 	err = 0;
 	if (!list_empty(&pagelist)) {
 		err = migrate_pages(&pagelist, new_page_node,
-				(unsigned long)pm, 0, true);
+				    (unsigned long)pm, false, 1);
 		if (err)
 			putback_lru_pages(&pagelist);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
