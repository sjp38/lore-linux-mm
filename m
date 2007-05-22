Date: Tue, 22 May 2007 16:04:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [Patch] memory unplug v3 [2/4] migration by kernel
Message-Id: <20070522160437.6607f445.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070522155824.563f5873.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070522155824.563f5873.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

This patch adds a feature that the kernel can migrate user pages by its own
context.

Now, sys_migrate(), a system call to migrate pages, works well.
When we want to migrate pages by some kernel codes, we have 2 approachs.

(a) acquire some mm->sem of a mapper of the target page.
(b) avoid race condition by additional check codes.

This patch implemetns (b) and adds following 2 codes.

1. delay freeing anon_vma while a page which belongs to it is migrated.
2. check page_mapped() before calling try_to_unmap().
 
Maybe more check will be needed. At least, this patch's migration_nocntext()
works well under heavy memory pressure on my environment.

Signed-Off-By: Yasonori Goto <y-goto@jp.fujitsu.com>
Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: devel-2.6.22-rc1-mm1/mm/Kconfig
===================================================================
--- devel-2.6.22-rc1-mm1.orig/mm/Kconfig	2007-05-22 14:30:39.000000000 +0900
+++ devel-2.6.22-rc1-mm1/mm/Kconfig	2007-05-22 15:12:29.000000000 +0900
@@ -152,6 +152,15 @@
 	  example on NUMA systems to put pages nearer to the processors accessing
 	  the page.
 
+config MIGRATION_BY_KERNEL
+	bool "Page migration by kernel's page scan"
+	def_bool y
+	depends on MIGRATION
+	help
+	  Allows page migration from kernel context. This means page migration
+	  can be done by codes other than sys_migrate() system call. Will add
+	  some additional check code in page migration.
+
 config RESOURCES_64BIT
 	bool "64 bit Memory and IO resources (EXPERIMENTAL)" if (!64BIT && EXPERIMENTAL)
 	default 64BIT
Index: devel-2.6.22-rc1-mm1/mm/migrate.c
===================================================================
--- devel-2.6.22-rc1-mm1.orig/mm/migrate.c	2007-05-22 14:30:39.000000000 +0900
+++ devel-2.6.22-rc1-mm1/mm/migrate.c	2007-05-22 15:12:29.000000000 +0900
@@ -607,11 +607,12 @@
  * to the newly allocated page in newpage.
  */
 static int unmap_and_move(new_page_t get_new_page, unsigned long private,
-			struct page *page, int force)
+			struct page *page, int force, int context)
 {
 	int rc = 0;
 	int *result = NULL;
 	struct page *newpage = get_new_page(page, private, &result);
+	struct anon_vma *anon_vma = NULL;
 
 	if (!newpage)
 		return -ENOMEM;
@@ -632,16 +633,29 @@
 			goto unlock;
 		wait_on_page_writeback(page);
 	}
-
+#ifdef CONFIG_MIGRATION_BY_KERNEL
+	if (PageAnon(page) && context)
+		/* hold this anon_vma until page migration ends */
+		anon_vma = anon_vma_hold(page);
+
+	if (page_mapped(page))
+		try_to_unmap(page, 1);
+#else
 	/*
 	 * Establish migration ptes or remove ptes
 	 */
 	try_to_unmap(page, 1);
+#endif
 	if (!page_mapped(page))
 		rc = move_to_new_page(newpage, page);
 
-	if (rc)
+	if (rc) {
 		remove_migration_ptes(page, page);
+	}
+#ifdef CONFIG_MIGRATION_BY_KERNEL
+	if (anon_vma)
+		anon_vma_release(anon_vma);
+#endif
 
 unlock:
 	unlock_page(page);
@@ -686,8 +700,8 @@
  *
  * Return: Number of pages not migrated or error code.
  */
-int migrate_pages(struct list_head *from,
-		new_page_t get_new_page, unsigned long private)
+int __migrate_pages(struct list_head *from,
+		new_page_t get_new_page, unsigned long private, int context)
 {
 	int retry = 1;
 	int nr_failed = 0;
@@ -707,7 +721,7 @@
 			cond_resched();
 
 			rc = unmap_and_move(get_new_page, private,
-						page, pass > 2);
+						page, pass > 2, context);
 
 			switch(rc) {
 			case -ENOMEM:
@@ -737,6 +751,25 @@
 	return nr_failed + retry;
 }
 
+int migrate_pages(struct list_head *from,
+	new_page_t get_new_page, unsigned long private)
+{
+	return __migrate_pages(from, get_new_page, private, 0);
+}
+
+#ifdef CONFIG_MIGRATION_BY_KERNEL
+/*
+ * When page migration is issued by the kernel itself without page mapper's
+ * mm->sem, we have to be more careful to do page migration.
+ */
+int migrate_pages_nocontext(struct list_head *from,
+	new_page_t get_new_page, unsigned long private)
+{
+	return __migrate_pages(from, get_new_page, private, 1);
+}
+
+#endif /* CONFIG_MIGRATION_BY_KERNEL */
+
 #ifdef CONFIG_NUMA
 /*
  * Move a list of individual pages
Index: devel-2.6.22-rc1-mm1/include/linux/rmap.h
===================================================================
--- devel-2.6.22-rc1-mm1.orig/include/linux/rmap.h	2007-05-22 14:30:39.000000000 +0900
+++ devel-2.6.22-rc1-mm1/include/linux/rmap.h	2007-05-22 15:12:29.000000000 +0900
@@ -26,12 +26,16 @@
 struct anon_vma {
 	spinlock_t lock;	/* Serialize access to vma list */
 	struct list_head head;	/* List of private "related" vmas */
+#ifdef CONFIG_MIGRATION_BY_KERNEL
+	atomic_t	ref;	/* special refcnt for migration */
+#endif
 };
 
 #ifdef CONFIG_MMU
 
 extern struct kmem_cache *anon_vma_cachep;
 
+#ifndef CONFIG_MIGRATION_BY_KERNEL
 static inline struct anon_vma *anon_vma_alloc(void)
 {
 	return kmem_cache_alloc(anon_vma_cachep, GFP_KERNEL);
@@ -41,6 +45,26 @@
 {
 	kmem_cache_free(anon_vma_cachep, anon_vma);
 }
+#define anon_vma_hold(page)	do{}while(0)
+#define anon_vma_release(anon)	do{}while(0)
+
+#else /* CONFIG_MIGRATION_BY_KERNEL */
+static inline struct anon_vma *anon_vma_alloc(void)
+{
+	struct anon_vma *ret = kmem_cache_alloc(anon_vma_cachep, GFP_KERNEL);
+	if (ret)
+		atomic_set(&ret->ref, 0);
+	return ret;
+}
+static inline void anon_vma_free(struct anon_vma *anon_vma)
+{
+	if (atomic_read(&anon_vma->ref) == 0)
+		kmem_cache_free(anon_vma_cachep, anon_vma);
+}
+extern struct anon_vma *anon_vma_hold(struct page *page);
+extern void anon_vma_release(struct anon_vma *anon_vma);
+
+#endif /* CONFIG_MIGRATION_BY_KERNEL */
 
 static inline void anon_vma_lock(struct vm_area_struct *vma)
 {
Index: devel-2.6.22-rc1-mm1/mm/rmap.c
===================================================================
--- devel-2.6.22-rc1-mm1.orig/mm/rmap.c	2007-05-22 14:30:39.000000000 +0900
+++ devel-2.6.22-rc1-mm1/mm/rmap.c	2007-05-22 15:12:29.000000000 +0900
@@ -203,6 +203,28 @@
 	spin_unlock(&anon_vma->lock);
 	rcu_read_unlock();
 }
+#ifdef CONFIG_MIGRATION_BY_KERNEL
+struct anon_vma *anon_vma_hold(struct page *page) {
+	struct anon_vma *anon_vma;
+	anon_vma = page_lock_anon_vma(page);
+	if (!anon_vma)
+		return NULL;
+	atomic_set(&anon_vma->ref, 1);
+	spin_unlock(&anon_vma->lock);
+	return anon_vma;
+}
+
+void anon_vma_release(struct anon_vma *anon_vma)
+{
+	int empty;
+	spin_lock(&anon_vma->lock);
+	atomic_set(&anon_vma->ref, 0);
+	empty = list_empty(&anon_vma->head);
+	spin_unlock(&anon_vma->lock);
+	if (empty)
+		anon_vma_free(anon_vma);
+}
+#endif
 
 /*
  * At what user virtual address is page expected in vma?
Index: devel-2.6.22-rc1-mm1/include/linux/migrate.h
===================================================================
--- devel-2.6.22-rc1-mm1.orig/include/linux/migrate.h	2007-05-22 14:30:39.000000000 +0900
+++ devel-2.6.22-rc1-mm1/include/linux/migrate.h	2007-05-22 15:12:29.000000000 +0900
@@ -30,7 +30,10 @@
 extern int migrate_page(struct address_space *,
 			struct page *, struct page *);
 extern int migrate_pages(struct list_head *l, new_page_t x, unsigned long);
-
+#ifdef CONFIG_MIGRATION_BY_KERNEL
+extern int migrate_pages_nocontext(struct list_head *l, new_page_t x,
+					unsigned long);
+#endif
 extern int fail_migrate_page(struct address_space *,
 			struct page *, struct page *);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
