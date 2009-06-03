Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 92A686B00E4
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:47:04 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <20090603846.816684333@firstfloor.org>
In-Reply-To: <20090603846.816684333@firstfloor.org>
Subject: [PATCH] [8/16] HWPOISON: Use bitmask/action code for try_to_unmap behaviour
Message-Id: <20090603184641.868D31D0282@basil.firstfloor.org>
Date: Wed,  3 Jun 2009 20:46:41 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: Lee.Schermerhorn@hp.com, npiggin@suse.de, akpm@linux-foundation.orgnpiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>


try_to_unmap currently has multiple modi (migration, munlock, normal unmap)
which are selected by magic flag variables. The logic is not very straight
forward, because each of these flag change multiple behaviours (e.g.
migration turns off aging, not only sets up migration ptes etc.)
Also the different flags interact in magic ways.

A later patch in this series adds another mode to try_to_unmap, so 
this becomes quickly unmanageable.

Replace the different flags with a action code (migration, munlock, munmap)
and some additional flags as modifiers (ignore mlock, ignore aging).
This makes the logic more straight forward and allows easier extension
to new behaviours. Change all the caller to declare what they want to 
do.

This patch is supposed to be a nop in behaviour. If anyone can prove 
it is not that would be a bug.

Cc: Lee.Schermerhorn@hp.com
Cc: npiggin@suse.de

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 include/linux/rmap.h |   14 +++++++++++++-
 mm/migrate.c         |    2 +-
 mm/rmap.c            |   40 ++++++++++++++++++++++------------------
 mm/vmscan.c          |    2 +-
 4 files changed, 37 insertions(+), 21 deletions(-)

Index: linux/include/linux/rmap.h
===================================================================
--- linux.orig/include/linux/rmap.h	2009-06-03 19:36:23.000000000 +0200
+++ linux/include/linux/rmap.h	2009-06-03 20:39:50.000000000 +0200
@@ -84,7 +84,19 @@
  * Called from mm/vmscan.c to handle paging out
  */
 int page_referenced(struct page *, int is_locked, struct mem_cgroup *cnt);
-int try_to_unmap(struct page *, int ignore_refs);
+
+enum ttu_flags {
+	TTU_UNMAP = 0,			/* unmap mode */
+	TTU_MIGRATION = 1,		/* migration mode */
+	TTU_MUNLOCK = 2,		/* munlock mode */
+	TTU_ACTION_MASK = 0xff,
+
+	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
+	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
+};
+#define TTU_ACTION(x) ((x) & TTU_ACTION_MASK)
+
+int try_to_unmap(struct page *, enum ttu_flags flags);
 
 /*
  * Called from mm/filemap_xip.c to unmap empty zero page
Index: linux/mm/rmap.c
===================================================================
--- linux.orig/mm/rmap.c	2009-06-03 19:36:23.000000000 +0200
+++ linux/mm/rmap.c	2009-06-03 20:39:50.000000000 +0200
@@ -897,7 +897,7 @@
  * repeatedly from either try_to_unmap_anon or try_to_unmap_file.
  */
 static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
-				int migration)
+				enum ttu_flags flags)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
@@ -919,11 +919,13 @@
 	 * If it's recently referenced (perhaps page_referenced
 	 * skipped over this mm) then we should reactivate it.
 	 */
-	if (!migration) {
+	if (!(flags & TTU_IGNORE_MLOCK)) {
 		if (vma->vm_flags & VM_LOCKED) {
 			ret = SWAP_MLOCK;
 			goto out_unmap;
 		}
+	}
+	if (!(flags & TTU_IGNORE_ACCESS)) {
 		if (ptep_clear_flush_young_notify(vma, address, pte)) {
 			ret = SWAP_FAIL;
 			goto out_unmap;
@@ -963,12 +965,12 @@
 			 * pte. do_swap_page() will wait until the migration
 			 * pte is removed and then restart fault handling.
 			 */
-			BUG_ON(!migration);
+			BUG_ON(TTU_ACTION(flags) != TTU_MIGRATION);
 			entry = make_migration_entry(page, pte_write(pteval));
 		}
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 		BUG_ON(pte_file(*pte));
-	} else if (PAGE_MIGRATION && migration) {
+	} else if (PAGE_MIGRATION && (TTU_ACTION(flags) == TTU_MIGRATION)) {
 		/* Establish migration entry for a file page */
 		swp_entry_t entry;
 		entry = make_migration_entry(page, pte_write(pteval));
@@ -1137,12 +1139,13 @@
  * vm_flags for that VMA.  That should be OK, because that vma shouldn't be
  * 'LOCKED.
  */
-static int try_to_unmap_anon(struct page *page, int unlock, int migration)
+static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
 {
 	struct anon_vma *anon_vma;
 	struct vm_area_struct *vma;
 	unsigned int mlocked = 0;
 	int ret = SWAP_AGAIN;
+	int unlock = TTU_ACTION(flags) == TTU_MUNLOCK;
 
 	if (MLOCK_PAGES && unlikely(unlock))
 		ret = SWAP_SUCCESS;	/* default for try_to_munlock() */
@@ -1158,7 +1161,7 @@
 				continue;  /* must visit all unlocked vmas */
 			ret = SWAP_MLOCK;  /* saw at least one mlocked vma */
 		} else {
-			ret = try_to_unmap_one(page, vma, migration);
+			ret = try_to_unmap_one(page, vma, flags);
 			if (ret == SWAP_FAIL || !page_mapped(page))
 				break;
 		}
@@ -1182,8 +1185,7 @@
 /**
  * try_to_unmap_file - unmap/unlock file page using the object-based rmap method
  * @page: the page to unmap/unlock
- * @unlock:  request for unlock rather than unmap [unlikely]
- * @migration:  unmapping for migration - ignored if @unlock
+ * @flags: action and flags
  *
  * Find all the mappings of a page using the mapping pointer and the vma chains
  * contained in the address_space struct it points to.
@@ -1195,7 +1197,7 @@
  * vm_flags for that VMA.  That should be OK, because that vma shouldn't be
  * 'LOCKED.
  */
-static int try_to_unmap_file(struct page *page, int unlock, int migration)
+static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 {
 	struct address_space *mapping = page->mapping;
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
@@ -1207,6 +1209,7 @@
 	unsigned long max_nl_size = 0;
 	unsigned int mapcount;
 	unsigned int mlocked = 0;
+	int unlock = TTU_ACTION(flags) == TTU_MUNLOCK;
 
 	if (MLOCK_PAGES && unlikely(unlock))
 		ret = SWAP_SUCCESS;	/* default for try_to_munlock() */
@@ -1219,7 +1222,7 @@
 				continue;	/* must visit all vmas */
 			ret = SWAP_MLOCK;
 		} else {
-			ret = try_to_unmap_one(page, vma, migration);
+			ret = try_to_unmap_one(page, vma, flags);
 			if (ret == SWAP_FAIL || !page_mapped(page))
 				goto out;
 		}
@@ -1244,7 +1247,8 @@
 			ret = SWAP_MLOCK;	/* leave mlocked == 0 */
 			goto out;		/* no need to look further */
 		}
-		if (!MLOCK_PAGES && !migration && (vma->vm_flags & VM_LOCKED))
+		if (!MLOCK_PAGES && !(flags & TTU_IGNORE_MLOCK) &&
+			(vma->vm_flags & VM_LOCKED))
 			continue;
 		cursor = (unsigned long) vma->vm_private_data;
 		if (cursor > max_nl_cursor)
@@ -1278,7 +1282,7 @@
 	do {
 		list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
 						shared.vm_set.list) {
-			if (!MLOCK_PAGES && !migration &&
+			if (!MLOCK_PAGES && !(flags & TTU_IGNORE_MLOCK) &&
 			    (vma->vm_flags & VM_LOCKED))
 				continue;
 			cursor = (unsigned long) vma->vm_private_data;
@@ -1318,7 +1322,7 @@
 /**
  * try_to_unmap - try to remove all page table mappings to a page
  * @page: the page to get unmapped
- * @migration: migration flag
+ * @flags: action and flags
  *
  * Tries to remove all the page table entries which are mapping this
  * page, used in the pageout path.  Caller must hold the page lock.
@@ -1329,16 +1333,16 @@
  * SWAP_FAIL	- the page is unswappable
  * SWAP_MLOCK	- page is mlocked.
  */
-int try_to_unmap(struct page *page, int migration)
+int try_to_unmap(struct page *page, enum ttu_flags flags)
 {
 	int ret;
 
 	BUG_ON(!PageLocked(page));
 
 	if (PageAnon(page))
-		ret = try_to_unmap_anon(page, 0, migration);
+		ret = try_to_unmap_anon(page, flags);
 	else
-		ret = try_to_unmap_file(page, 0, migration);
+		ret = try_to_unmap_file(page, flags);
 	if (ret != SWAP_MLOCK && !page_mapped(page))
 		ret = SWAP_SUCCESS;
 	return ret;
@@ -1363,8 +1367,8 @@
 	VM_BUG_ON(!PageLocked(page) || PageLRU(page));
 
 	if (PageAnon(page))
-		return try_to_unmap_anon(page, 1, 0);
+		return try_to_unmap_anon(page, TTU_MUNLOCK);
 	else
-		return try_to_unmap_file(page, 1, 0);
+		return try_to_unmap_file(page, TTU_MUNLOCK);
 }
 
Index: linux/mm/vmscan.c
===================================================================
--- linux.orig/mm/vmscan.c	2009-06-03 19:36:21.000000000 +0200
+++ linux/mm/vmscan.c	2009-06-03 19:36:23.000000000 +0200
@@ -659,7 +659,7 @@
 		 * processes. Try to unmap it here.
 		 */
 		if (page_mapped(page) && mapping) {
-			switch (try_to_unmap(page, 0)) {
+			switch (try_to_unmap(page, TTU_UNMAP)) {
 			case SWAP_FAIL:
 				goto activate_locked;
 			case SWAP_AGAIN:
Index: linux/mm/migrate.c
===================================================================
--- linux.orig/mm/migrate.c	2009-06-03 19:36:21.000000000 +0200
+++ linux/mm/migrate.c	2009-06-03 19:36:23.000000000 +0200
@@ -669,7 +669,7 @@
 	}
 
 	/* Establish migration ptes or remove ptes */
-	try_to_unmap(page, 1);
+	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
 
 	if (!page_mapped(page))
 		rc = move_to_new_page(newpage, page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
