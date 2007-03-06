Date: Tue, 6 Mar 2007 14:02:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC} memory unplug patchset prep [16/16] migration nocontext
Message-Id: <20070306140229.1b12a6e9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Delaying freeing anon_vma until migration finishes.

We cannot trust page->mapping (of ANON) when page_mapcount(page) ==0.

page migration puts page_mocount(page) to be 0. So we have to
guarantee anon_vma pointed by page->mapping is valid by some hook.

Usual page migration guarantees this by mm->sem. but we can't do it.
So, just delaying freeing anon_vma.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/migrate.h |    2 ++
 include/linux/rmap.h    |   21 +++++++++++++++++++++
 mm/Kconfig              |   12 ++++++++++++
 mm/memory_hotplug.c     |    4 ++--
 mm/migrate.c            |   35 +++++++++++++++++++++++++++++------
 mm/rmap.c               |   36 +++++++++++++++++++++++++++++++++++-
 6 files changed, 101 insertions(+), 9 deletions(-)

Index: devel-tree-2.6.20-mm2/mm/migrate.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/mm/migrate.c
+++ devel-tree-2.6.20-mm2/mm/migrate.c
@@ -601,7 +601,7 @@ static int move_to_new_page(struct page 
  * to the newly allocated page in newpage.
  */
 static int unmap_and_move(new_page_t get_new_page, unsigned long private,
-			struct page *page, int force)
+			struct page *page, int force, int nocontext)
 {
 	int rc = 0;
 	int *result = NULL;
@@ -626,7 +626,10 @@ static int unmap_and_move(new_page_t get
 			goto unlock;
 		wait_on_page_writeback(page);
 	}
-
+	if (PageAnon(page) && nocontext) {
+		/* hold this anon_vma until remove_migration_ptes() finishes */
+		anon_vma_hold(page);
+	}
 	/*
 	 * Establish migration ptes or remove ptes
 	 */
@@ -634,8 +637,14 @@ static int unmap_and_move(new_page_t get
 	if (!page_mapped(page))
 		rc = move_to_new_page(newpage, page);
 
-	if (rc)
+	if (rc) {
 		remove_migration_ptes(page, page);
+		if (PageAnon(page) && nocontext)
+			anon_vma_release(page);
+	} else {
+		if (PageAnon(newpage) && nocontext)
+			anon_vma_release(page);
+	}
 
 unlock:
 	unlock_page(page);
@@ -680,8 +689,8 @@ move_newpage:
  *
  * Return: Number of pages not migrated or error code.
  */
-int migrate_pages(struct list_head *from,
-		new_page_t get_new_page, unsigned long private)
+static int __migrate_pages(struct list_head *from,
+		new_page_t get_new_page, unsigned long private, int nocontext)
 {
 	int retry = 1;
 	int nr_failed = 0;
@@ -701,7 +710,7 @@ int migrate_pages(struct list_head *from
 			cond_resched();
 
 			rc = unmap_and_move(get_new_page, private,
-						page, pass > 2);
+						page, pass > 2, nocontext);
 
 			switch(rc) {
 			case -ENOMEM:
@@ -731,6 +740,20 @@ out:
 	return nr_failed + retry;
 }
 
+int migrate_pages(struct list_head *from,
+	new_page_t get_new_page, unsigned long private)
+{
+	return __migrate_pages(from, get_new_page, private, 0);
+}
+
+#ifdef CONFIG_MIGRATION_NOCONTEXT
+int migrate_pages_nocontext(struct list_head *from,
+	new_page_t get_new_page, unsigned long private)
+{
+	return __migrate_pages(from, get_new_page, private, 1);
+}
+#endif
+
 #ifdef CONFIG_NUMA
 /*
  * Move a list of individual pages
Index: devel-tree-2.6.20-mm2/include/linux/rmap.h
===================================================================
--- devel-tree-2.6.20-mm2.orig/include/linux/rmap.h
+++ devel-tree-2.6.20-mm2/include/linux/rmap.h
@@ -26,6 +26,9 @@
 struct anon_vma {
 	spinlock_t lock;	/* Serialize access to vma list */
 	struct list_head head;	/* List of private "related" vmas */
+#ifdef CONFIG_MIGRATION_NOCONTEXT
+	atomic_t	hold;	/* == 0 if we can free this immediately */
+#endif
 };
 
 #ifdef CONFIG_MMU
@@ -37,10 +40,14 @@ static inline struct anon_vma *anon_vma_
 	return kmem_cache_alloc(anon_vma_cachep, GFP_KERNEL);
 }
 
+#ifndef CONFIG_MIGRATION_NOCONTEXT
 static inline void anon_vma_free(struct anon_vma *anon_vma)
 {
 	kmem_cache_free(anon_vma_cachep, anon_vma);
 }
+#else
+extern void anon_vma_free(struct anon_vma *anon_vma);
+#endif
 
 static inline void anon_vma_lock(struct vm_area_struct *vma)
 {
@@ -74,6 +81,20 @@ void page_add_new_anon_rmap(struct page 
 void page_add_file_rmap(struct page *);
 void page_remove_rmap(struct page *, struct vm_area_struct *);
 
+#ifdef CONFIG_MIGRATION_NOCONTEXT
+/*
+ * While Page migration without any process context, we doesn't have
+ * mm->sem. Because page->mapcount goes down to 0 while migration,
+ * we cannot trust page->mapping value.
+ * THese two functions prevents anon_vma from being freed  while
+ * migration.
+ */
+void anon_vma_hold(struct page *page);
+void anon_vma_release(struct page *page);
+#else
+#define anon_vma_hold(page)	do{}while(0)
+#define anon_vma_release(page)	do{}while(0)
+#endif
 /**
  * page_dup_rmap - duplicate pte mapping to a page
  * @page:	the page to add the mapping to
Index: devel-tree-2.6.20-mm2/mm/rmap.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/mm/rmap.c
+++ devel-tree-2.6.20-mm2/mm/rmap.c
@@ -155,8 +155,9 @@ void anon_vma_unlink(struct vm_area_stru
 	empty = list_empty(&anon_vma->head);
 	spin_unlock(&anon_vma->lock);
 
-	if (empty)
+	if (empty) {
 		anon_vma_free(anon_vma);
+	}
 }
 
 static void anon_vma_ctor(void *data, struct kmem_cache *cachep,
@@ -939,3 +940,36 @@ int try_to_unmap(struct page *page, int 
 	return ret;
 }
 
+#ifdef CONFIG_MIGRATION_NOCONTEXT
+
+void anon_vma_free(struct anon_vma *anon)
+{
+	if (atomic_read(&anon->hold) == 0) {
+		kmem_cache_free(anon_vma_cachep, anon);
+	}
+}
+
+void anon_vma_hold(struct page *page)
+{
+	struct anon_vma *anon_vma;
+	anon_vma = page_lock_anon_vma(page);
+	if (!anon_vma)
+		return;
+	atomic_set(&anon_vma->hold, 1);
+	spin_unlock(&anon_vma->lock);
+}
+
+void anon_vma_release(struct page *page)
+{
+	struct anon_vma *anon_vma;
+	int empty;
+	anon_vma = page_lock_anon_vma(page);
+	if (!anon_vma)
+		return;
+	atomic_set(&anon_vma->hold, 0);
+	empty = list_empty(&anon_vma->head);
+	spin_unlock(&anon_vma->lock);
+	if (empty)
+		anon_vma_free(anon_vma);
+}
+#endif
Index: devel-tree-2.6.20-mm2/mm/Kconfig
===================================================================
--- devel-tree-2.6.20-mm2.orig/mm/Kconfig
+++ devel-tree-2.6.20-mm2/mm/Kconfig
@@ -132,6 +132,7 @@ config MEMORY_HOTREMOVE
 	select	ZONE_MOVABLE
 	select	MIGRATION
 	select  PAGE_ISOLATION
+	select  MIGRATION_NOCONTEXT
 
 # Heavily threaded applications may benefit from splitting the mm-wide
 # page_table_lock, so that faults on different parts of the user address
@@ -159,6 +160,17 @@ config MIGRATION
 	  example on NUMA systems to put pages nearer to the processors accessing
 	  the page.
 
+config MIGRATION_NOCONTEXT
+	bool "Page migration without process context"
+	def_bool y
+	depends on MEMORY_HOTREMOVE
+	help
+	  When Memory-Hotremove is executed, page migraion runs.
+	  But a process which does page migraion doesn't have context of
+	  migration target pages. This has a small race condition.
+	  If this config is selected, some workaround for fix them is enabled.
+	  This may be add slight performance influence.
+
 config RESOURCES_64BIT
 	bool "64 bit Memory and IO resources (EXPERIMENTAL)" if (!64BIT && EXPERIMENTAL)
 	default 64BIT
Index: devel-tree-2.6.20-mm2/include/linux/migrate.h
===================================================================
--- devel-tree-2.6.20-mm2.orig/include/linux/migrate.h
+++ devel-tree-2.6.20-mm2/include/linux/migrate.h
@@ -11,6 +11,8 @@ extern int putback_lru_pages(struct list
 extern int migrate_page(struct address_space *,
 			struct page *, struct page *);
 extern int migrate_pages(struct list_head *l, new_page_t x, unsigned long);
+extern int migrate_pages_nocontext(struct list_head *l,
+					new_page_t x, unsigned long);
 
 extern int fail_migrate_page(struct address_space *,
 			struct page *, struct page *);
Index: devel-tree-2.6.20-mm2/mm/memory_hotplug.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/mm/memory_hotplug.c
+++ devel-tree-2.6.20-mm2/mm/memory_hotplug.c
@@ -345,7 +345,7 @@ static int do_migrate_and_isolate_pages(
 		if (!pfn_valid(pfn))  /* never happens in sparsemem */
 			continue;
 		page = pfn_to_page(pfn);
-		if (is_page_isolated(info,page))
+		if (PageReserved(page))
 			continue;
 		ret = isolate_lru_page(page, &source);
 
@@ -367,7 +367,7 @@ static int do_migrate_and_isolate_pages(
 	if (list_empty(&source))
 		goto out;
 	/* this function returns # of failed pages */
-	ret = migrate_pages(&source, hotremove_migrate_alloc,
+	ret = migrate_pages_nocontext(&source, hotremove_migrate_alloc,
 			   (unsigned long)info);
 out:
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
