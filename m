Date: Wed, 09 May 2007 12:11:54 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [RFC] memory hotremove patch take 2 [07/10] (delay freeing anon_vma)
In-Reply-To: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
References: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
Message-Id: <20070509120732.B914.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Delaying freeing anon_vma until migration finishes.

We cannot trust page->mapping (of ANON) when page_mapcount(page) ==0.

page migration puts page_mocount(page) to be 0. So we have to
guarantee anon_vma pointed by page->mapping is valid by some hook.

Usual page migration guarantees this by mm->sem. but we can't do it.
So, just delaying freeing anon_vma.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

 include/linux/migrate.h        |    2 ++
 include/linux/page_isolation.h |   14 ++++++++++++++
 include/linux/rmap.h           |   22 ++++++++++++++++++++++
 mm/Kconfig                     |   12 ++++++++++++
 mm/memory_hotplug.c            |    4 ++--
 mm/migrate.c                   |   37 +++++++++++++++++++++++++++++++------
 mm/rmap.c                      |   36 +++++++++++++++++++++++++++++++++++-
 7 files changed, 118 insertions(+), 9 deletions(-)

Index: current_test/mm/migrate.c
===================================================================
--- current_test.orig/mm/migrate.c	2007-05-08 15:06:50.000000000 +0900
+++ current_test/mm/migrate.c	2007-05-08 15:08:24.000000000 +0900
@@ -28,6 +28,7 @@
 #include <linux/mempolicy.h>
 #include <linux/vmalloc.h>
 #include <linux/security.h>
+#include <linux/page_isolation.h>
 
 #include "internal.h"
 
@@ -607,7 +608,7 @@ static int move_to_new_page(struct page 
  * to the newly allocated page in newpage.
  */
 static int unmap_and_move(new_page_t get_new_page, unsigned long private,
-			struct page *page, int force)
+			struct page *page, int force, int flag)
 {
 	int rc = 0;
 	int *result = NULL;
@@ -632,7 +633,10 @@ static int unmap_and_move(new_page_t get
 			goto unlock;
 		wait_on_page_writeback(page);
 	}
-
+	if (PageAnon(page) && is_migrate_nocontext(flag)) {
+		/* hold this anon_vma until remove_migration_ptes() finishes */
+		anon_vma_hold(page);
+	}
 	/*
 	 * Establish migration ptes or remove ptes
 	 */
@@ -640,8 +644,14 @@ static int unmap_and_move(new_page_t get
 	if (!page_mapped(page))
 		rc = move_to_new_page(newpage, page);
 
-	if (rc)
+	if (rc) {
 		remove_migration_ptes(page, page);
+		if (PageAnon(page) && is_migrate_nocontext(flag))
+			anon_vma_release(page);
+	} else {
+		if (PageAnon(newpage) && is_migrate_nocontext(flag))
+			anon_vma_release(page);
+	}
 
 unlock:
 	unlock_page(page);
@@ -686,8 +696,8 @@ move_newpage:
  *
  * Return: Number of pages not migrated or error code.
  */
-int migrate_pages(struct list_head *from,
-		new_page_t get_new_page, unsigned long private)
+static int __migrate_pages(struct list_head *from,
+		new_page_t get_new_page, unsigned long private, int flag)
 {
 	int retry = 1;
 	int nr_failed = 0;
@@ -707,7 +717,7 @@ int migrate_pages(struct list_head *from
 			cond_resched();
 
 			rc = unmap_and_move(get_new_page, private,
-						page, pass > 2);
+						page, pass > 2, flag);
 
 			switch(rc) {
 			case -ENOMEM:
@@ -737,6 +747,21 @@ out:
 	return nr_failed + retry;
 }
 
+int migrate_pages(struct list_head *from,
+	new_page_t get_new_page, unsigned long private)
+{
+	return __migrate_pages(from, get_new_page, private, 0);
+}
+
+#ifdef CONFIG_MIGRATION_REMOVE
+int migrate_pages_and_remove(struct list_head *from,
+	new_page_t get_new_page, unsigned long private)
+{
+	return __migrate_pages(from, get_new_page, private,
+		MIGRATE_NOCONTEXT);
+}
+#endif
+
 #ifdef CONFIG_NUMA
 /*
  * Move a list of individual pages
Index: current_test/include/linux/rmap.h
===================================================================
--- current_test.orig/include/linux/rmap.h	2007-05-08 15:06:49.000000000 +0900
+++ current_test/include/linux/rmap.h	2007-05-08 15:08:07.000000000 +0900
@@ -26,6 +26,9 @@
 struct anon_vma {
 	spinlock_t lock;	/* Serialize access to vma list */
 	struct list_head head;	/* List of private "related" vmas */
+#ifdef CONFIG_MIGRATION_REMOVE
+	atomic_t	hold;	/* == 0 if we can free this immediately */
+#endif
 };
 
 #ifdef CONFIG_MMU
@@ -37,10 +40,14 @@ static inline struct anon_vma *anon_vma_
 	return kmem_cache_alloc(anon_vma_cachep, GFP_KERNEL);
 }
 
+#ifndef CONFIG_MIGRATION_REMOVE
 static inline void anon_vma_free(struct anon_vma *anon_vma)
 {
 	kmem_cache_free(anon_vma_cachep, anon_vma);
 }
+#else
+extern void anon_vma_free(struct anon_vma *anon_vma);
+#endif
 
 static inline void anon_vma_lock(struct vm_area_struct *vma)
 {
@@ -75,6 +82,21 @@ void page_add_file_rmap(struct page *);
 void page_dup_rmap(struct page *page, struct vm_area_struct *vma, unsigned long address);
 void page_remove_rmap(struct page *, struct vm_area_struct *);
 
+#ifdef CONFIG_MIGRATION_REMOVE
+/*
+ * While Page migration without any process context, we doesn't have
+ * mm->sem. Because page->mapcount goes down to 0 while migration,
+ * we cannot trust page->mapping value.
+ * These two functions prevents anon_vma from being freed  while
+ * migration.
+ */
+void anon_vma_hold(struct page *page);
+void anon_vma_release(struct page *page);
+#else  /* !CONFIG_MIGRATION_REMOVE */
+#define anon_vma_hold(page)	do{}while(0)
+#define anon_vma_release(page)	do{}while(0)
+#endif /* CONFIG_MIGRATION_REMOVE */
+
 /*
  * Called from mm/vmscan.c to handle paging out
  */
Index: current_test/mm/rmap.c
===================================================================
--- current_test.orig/mm/rmap.c	2007-05-08 15:06:50.000000000 +0900
+++ current_test/mm/rmap.c	2007-05-08 15:08:07.000000000 +0900
@@ -155,8 +155,9 @@ void anon_vma_unlink(struct vm_area_stru
 	empty = list_empty(&anon_vma->head);
 	spin_unlock(&anon_vma->lock);
 
-	if (empty)
+	if (empty) {
 		anon_vma_free(anon_vma);
+	}
 }
 
 static void anon_vma_ctor(void *data, struct kmem_cache *cachep,
@@ -1003,3 +1004,36 @@ int try_to_unmap(struct page *page, int 
 	return ret;
 }
 
+#ifdef CONFIG_MIGRATION_REMOVE
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
Index: current_test/mm/Kconfig
===================================================================
--- current_test.orig/mm/Kconfig	2007-05-08 15:08:06.000000000 +0900
+++ current_test/mm/Kconfig	2007-05-08 15:08:24.000000000 +0900
@@ -131,6 +131,7 @@ config MEMORY_HOTREMOVE
 	depends on MEMORY_HOTPLUG_SPARSE
 	select	MIGRATION
 	select  PAGE_ISOLATION
+	select  MIGRATION_REMOVE
 
 # Heavily threaded applications may benefit from splitting the mm-wide
 # page_table_lock, so that faults on different parts of the user address
@@ -158,6 +159,17 @@ config MIGRATION
 	  example on NUMA systems to put pages nearer to the processors accessing
 	  the page.
 
+config MIGRATION_REMOVE
+	bool "Page migration for memory remove"
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
Index: current_test/include/linux/migrate.h
===================================================================
--- current_test.orig/include/linux/migrate.h	2007-05-08 15:06:49.000000000 +0900
+++ current_test/include/linux/migrate.h	2007-05-08 15:08:07.000000000 +0900
@@ -30,6 +30,8 @@ extern int putback_lru_pages(struct list
 extern int migrate_page(struct address_space *,
 			struct page *, struct page *);
 extern int migrate_pages(struct list_head *l, new_page_t x, unsigned long);
+extern int migrate_pages_and_remove(struct list_head *l,
+					new_page_t x, unsigned long);
 
 extern int fail_migrate_page(struct address_space *,
 			struct page *, struct page *);
Index: current_test/mm/memory_hotplug.c
===================================================================
--- current_test.orig/mm/memory_hotplug.c	2007-05-08 15:08:06.000000000 +0900
+++ current_test/mm/memory_hotplug.c	2007-05-08 15:08:07.000000000 +0900
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
+	ret = migrate_pages_and_remove(&source, hotremove_migrate_alloc,
 			   (unsigned long)info);
 out:
 	return ret;
Index: current_test/include/linux/page_isolation.h
===================================================================
--- current_test.orig/include/linux/page_isolation.h	2007-05-08 15:08:05.000000000 +0900
+++ current_test/include/linux/page_isolation.h	2007-05-08 15:08:24.000000000 +0900
@@ -32,6 +32,13 @@ is_page_isolated(struct isolation_info *
 	return 0;
 }
 
+#define MIGRATE_NOCONTEXT 0x1
+static inline int
+is_migrate_nocontext(int flag)
+{
+	return (flag & MIGRATE_NOCONTEXT) == MIGRATE_NOCONTEXT;
+}
+
 extern struct isolation_info *
 register_isolation(unsigned long start, unsigned long end);
 
@@ -50,5 +57,12 @@ page_under_isolation(struct zone *zone, 
 	return 0;
 }
 
+
+static inline int
+is_migrate_nocontext(int flag)
+{
+	return 0;
+}
+
 #endif
 #endif

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
