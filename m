Date: Fri, 28 Apr 2006 20:23:48 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060429032348.4999.11717.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
References: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
Subject: {PATCH 2/2} More PM: use migration entries for file pages
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

more page migration: Use migration entries for file backed pages

This implements the use of migration entries to preserve ptes of
file backed pages during migration. Processes can therefore
be migrated back and forth without loosing their connection to
pagecache pages.

Note that we implement the migration entries only for linear
mappings. Nonlinear mappings still require the unmapping of the ptes
for migration.

And another writepage() ugliness shows up. writepage() can drop
the page lock. Therefore we have to remove migration ptes
before calling writepages() in order to avoid having migration entries
point to unlocked pages.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc3/mm/migrate.c
===================================================================
--- linux-2.6.17-rc3.orig/mm/migrate.c	2006-04-28 19:37:31.941975877 -0700
+++ linux-2.6.17-rc3/mm/migrate.c	2006-04-28 19:44:13.640685963 -0700
@@ -170,19 +170,44 @@
 	if (is_write_migration_entry(entry))
 		pte = pte_mkwrite(pte);
 	set_pte_at(mm, addr, ptep, pte);
-	page_add_anon_rmap(new, vma, addr);
+
+	if (PageAnon(new))
+		page_add_anon_rmap(new, vma, addr);
+	else
+		page_add_file_rmap(new);
+
 out:
 	pte_unmap_unlock(pte, ptl);
 }
 
 /*
- * Get rid of all migration entries and replace them by
- * references to the indicated page.
- *
+ * Note that remove_file_migration_ptes will only work on regular mappings
+ * specialized other mappings will simply be unmapped and do not use
+ * migration entries.
+ */
+static void remove_file_migration_ptes(struct page *old, struct page *new)
+{
+	struct vm_area_struct *vma;
+	struct address_space *mapping = page_mapping(new);
+	struct prio_tree_iter iter;
+	pgoff_t pgoff = new->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+
+	if (!mapping)
+		return;
+
+	spin_lock(&mapping->i_mmap_lock);
+
+	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff)
+		remove_migration_pte(vma, page_address_in_vma(new, vma), old, new);
+
+	spin_unlock(&mapping->i_mmap_lock);
+}
+
+/*
  * Must hold mmap_sem lock on at least one of the vmas containing
  * the page so that the anon_vma cannot vanish.
  */
-static void remove_migration_ptes(struct page *old, struct page *new)
+static void remove_anon_migration_ptes(struct page *old, struct page *new)
 {
 	struct anon_vma *anon_vma;
 	struct vm_area_struct *vma;
@@ -207,6 +232,18 @@
 }
 
 /*
+ * Get rid of all migration entries and replace them by
+ * references to the indicated page.
+ */
+static void remove_migration_ptes(struct page *old, struct page *new)
+{
+	if (PageAnon(new))
+		remove_anon_migration_ptes(old, new);
+	else
+		remove_file_migration_ptes(old, new);
+}
+
+/*
  * Something used the pte of a page under migration. We need to
  * get to the page and wait until migration is finished.
  * When we return from this function the fault will be retried.
@@ -438,20 +475,18 @@
 	 * pages so try to write out any dirty pages first.
 	 */
 	if (PageDirty(page)) {
-		switch (pageout(page, mapping)) {
-		case PAGE_KEEP:
-		case PAGE_ACTIVATE:
-			return -EAGAIN;
+		/*
+		 * Remove the migration entries because pageout() may
+		 * unlock which may result in migration entries pointing
+		 * to unlocked pages.
+		 */
+		remove_migration_ptes(page, page);
 
-		case PAGE_SUCCESS:
-			/* Relock since we lost the lock */
+		if (pageout(page, mapping) == PAGE_SUCCESS)
+			/* unlocked. Relock */
 			lock_page(page);
-			/* Must retry since page state may have changed */
-			return -EAGAIN;
 
-		case PAGE_CLEAN:
-			; /* try to migrate the page below */
-		}
+		return -EAGAIN;
 	}
 
 	/*
Index: linux-2.6.17-rc3/mm/rmap.c
===================================================================
--- linux-2.6.17-rc3.orig/mm/rmap.c	2006-04-28 19:37:31.941975877 -0700
+++ linux-2.6.17-rc3/mm/rmap.c	2006-04-28 19:41:02.442586074 -0700
@@ -607,8 +607,14 @@
 		}
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 		BUG_ON(pte_file(*pte));
-	} else
+	} else if (!migration)
 		dec_mm_counter(mm, file_rss);
+	else {
+		/* Establish migration entry for a file page */
+		swp_entry_t entry;
+		entry = make_migration_entry(page, pte_write(pteval));
+		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
+	}
 
 	page_remove_rmap(page);
 	page_cache_release(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
