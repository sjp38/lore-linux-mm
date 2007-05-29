From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070529173649.1570.85922.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070529173609.1570.4686.sendpatchset@skynet.skynet.ie>
References: <20070529173609.1570.4686.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 2/7] KAMEZAWA Hiroyuki - migration by kernel
Date: Tue, 29 May 2007 18:36:50 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

This is a patch from KAMEZAWA Hiroyuki for using page migration on remote
processes without races. This patch is still undergoing development and
is expected to be a pre-requisite for both memory hot-remove and memory
compaction.

Changelog from KAMEZAWA Hiroyuki version
o Removed the MIGRATION_BY_KERNEL as a compile-time option

=====

This patch adds a feature that the kernel can migrate user pages by its own
context.

Now, sys_migrate(), a system call to migrate pages, works well.
When we want to migrate pages by some kernel codes, we have 2 approachs.

(a) acquire some mm->sem of a mapper of the target page.
(b) avoid race condition by additional check codes.

This patch implements (b) and adds following 2 codes.

1. delay freeing anon_vma while a page which belongs to it is migrated.
2. check page_mapped() before calling try_to_unmap().
 
Maybe more check will be needed. At least, this patch's migration_nocntext()
works well under heavy memory pressure on my environment.

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Yasonori Goto <y-goto@jp.fujitsu.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 include/linux/migrate.h |    3 ++-
 include/linux/rmap.h    |   24 ++++++++++++++++++++++++
 mm/migrate.c            |   42 +++++++++++++++++++++++++++++++++---------
 mm/rmap.c               |   23 +++++++++++++++++++++++
 4 files changed, 82 insertions(+), 10 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-001_lameter-v4r4/include/linux/migrate.h linux-2.6.22-rc2-mm1-005_migrate_nocontext/include/linux/migrate.h
--- linux-2.6.22-rc2-mm1-001_lameter-v4r4/include/linux/migrate.h	2007-05-19 05:06:17.000000000 +0100
+++ linux-2.6.22-rc2-mm1-005_migrate_nocontext/include/linux/migrate.h	2007-05-28 14:11:32.000000000 +0100
@@ -30,7 +30,8 @@ extern int putback_lru_pages(struct list
 extern int migrate_page(struct address_space *,
 			struct page *, struct page *);
 extern int migrate_pages(struct list_head *l, new_page_t x, unsigned long);
-
+extern int migrate_pages_nocontext(struct list_head *l, new_page_t x,
+					unsigned long);
 extern int fail_migrate_page(struct address_space *,
 			struct page *, struct page *);
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-001_lameter-v4r4/include/linux/rmap.h linux-2.6.22-rc2-mm1-005_migrate_nocontext/include/linux/rmap.h
--- linux-2.6.22-rc2-mm1-001_lameter-v4r4/include/linux/rmap.h	2007-05-19 05:06:17.000000000 +0100
+++ linux-2.6.22-rc2-mm1-005_migrate_nocontext/include/linux/rmap.h	2007-05-28 14:11:32.000000000 +0100
@@ -26,12 +26,16 @@
 struct anon_vma {
 	spinlock_t lock;	/* Serialize access to vma list */
 	struct list_head head;	/* List of private "related" vmas */
+#ifdef CONFIG_MIGRATION
+	atomic_t	ref;	/* special refcnt for migration */
+#endif
 };
 
 #ifdef CONFIG_MMU
 
 extern struct kmem_cache *anon_vma_cachep;
 
+#ifndef CONFIG_MIGRATION
 static inline struct anon_vma *anon_vma_alloc(void)
 {
 	return kmem_cache_alloc(anon_vma_cachep, GFP_KERNEL);
@@ -41,6 +45,26 @@ static inline void anon_vma_free(struct 
 {
 	kmem_cache_free(anon_vma_cachep, anon_vma);
 }
+#define anon_vma_hold(page)	do{}while(0)
+#define anon_vma_release(anon)	do{}while(0)
+
+#else /* CONFIG_MIGRATION */
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
+#endif /* CONFIG_MIGRATION */
 
 static inline void anon_vma_lock(struct vm_area_struct *vma)
 {
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-001_lameter-v4r4/mm/migrate.c linux-2.6.22-rc2-mm1-005_migrate_nocontext/mm/migrate.c
--- linux-2.6.22-rc2-mm1-001_lameter-v4r4/mm/migrate.c	2007-05-24 10:13:34.000000000 +0100
+++ linux-2.6.22-rc2-mm1-005_migrate_nocontext/mm/migrate.c	2007-05-28 14:11:32.000000000 +0100
@@ -607,11 +607,12 @@ static int move_to_new_page(struct page 
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
@@ -633,15 +634,22 @@ static int unmap_and_move(new_page_t get
 		wait_on_page_writeback(page);
 	}
 
-	/*
-	 * Establish migration ptes or remove ptes
-	 */
-	try_to_unmap(page, 1);
+	if (PageAnon(page) && context)
+		/* hold this anon_vma until page migration ends */
+		anon_vma = anon_vma_hold(page);
+
+	if (page_mapped(page))
+		try_to_unmap(page, 1);
+
 	if (!page_mapped(page))
 		rc = move_to_new_page(newpage, page);
 
-	if (rc)
+	if (rc) {
 		remove_migration_ptes(page, page);
+	}
+
+	if (anon_vma)
+		anon_vma_release(anon_vma);
 
 unlock:
 	unlock_page(page);
@@ -686,8 +694,8 @@ move_newpage:
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
@@ -707,7 +715,7 @@ int migrate_pages(struct list_head *from
 			cond_resched();
 
 			rc = unmap_and_move(get_new_page, private,
-						page, pass > 2);
+						page, pass > 2, context);
 
 			switch(rc) {
 			case -ENOMEM:
@@ -737,6 +745,22 @@ out:
 	return nr_failed + retry;
 }
 
+int migrate_pages(struct list_head *from,
+	new_page_t get_new_page, unsigned long private)
+{
+	return __migrate_pages(from, get_new_page, private, 0);
+}
+
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
 #ifdef CONFIG_NUMA
 /*
  * Move a list of individual pages
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-001_lameter-v4r4/mm/rmap.c linux-2.6.22-rc2-mm1-005_migrate_nocontext/mm/rmap.c
--- linux-2.6.22-rc2-mm1-001_lameter-v4r4/mm/rmap.c	2007-05-24 10:13:34.000000000 +0100
+++ linux-2.6.22-rc2-mm1-005_migrate_nocontext/mm/rmap.c	2007-05-28 14:11:32.000000000 +0100
@@ -204,6 +204,29 @@ static void page_unlock_anon_vma(struct 
 	rcu_read_unlock();
 }
 
+#ifdef CONFIG_MIGRATION
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
+#endif /* CONFIG_MIGRATION */
+
 /*
  * At what user virtual address is page expected in vma?
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
