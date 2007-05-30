Date: Wed, 30 May 2007 11:42:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/7] KAMEZAWA Hiroyuki - migration by kernel
Message-Id: <20070530114243.e3c3c75e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070529173649.1570.85922.sendpatchset@skynet.skynet.ie>
References: <20070529173609.1570.4686.sendpatchset@skynet.skynet.ie>
	<20070529173649.1570.85922.sendpatchset@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, 29 May 2007 18:36:50 +0100 (IST)
Mel Gorman <mel@csn.ul.ie> wrote:

> 
> This is a patch from KAMEZAWA Hiroyuki for using page migration on remote
> processes without races. This patch is still undergoing development and
> is expected to be a pre-requisite for both memory hot-remove and memory
> compaction.
> 
> Changelog from KAMEZAWA Hiroyuki version
> o Removed the MIGRATION_BY_KERNEL as a compile-time option
> 
This is my latest version.
(not tested because caller of this function is being rewritten now..)

I'll move this patch to the top of my series and prepare to post this patch as
a single patch.

==
page migration by kernel v2.

Changelog V1 -> V2
 *removed atomic ops.
 *removes changes in anon_vma_free() and add check before calling it.
 *reflected feedback of review.
 *remove CONFIG_MIGRATION_BY_KERNEL

In usual, migrate_pages(page,,) is called with holoding mm->sem by systemcall.
(mm here is a mm_struct which maps the migration target page.)
This semaphore helps avoiding some race conditions.

But, if we want to migrate a page by some kernel codes, we have to avoid
some races. This patch adds check code for following race condition.

1. A page which is not mapped can be target of migration. Then, we have
   to check page_mapped() before calling try_to_unmap().

2. We can't trust page->mapping if page_mapcount() can goes down to 0.
   But when we map newpage back to original ptes, we have to access
   anon_vma from a page, which page_mapcount() is 0.
   This patch adds a special refcnt to anon_vma, which is synced by
   anon_vma->lock and delays freeing anon_vma.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---
 include/linux/migrate.h |    5 ++++-
 include/linux/rmap.h    |   11 +++++++++++
 mm/migrate.c            |   35 +++++++++++++++++++++++++++++------
 mm/rmap.c               |   36 +++++++++++++++++++++++++++++++++++-
 4 files changed, 79 insertions(+), 8 deletions(-)

Index: linux-2.6.22-rc2-mm1/mm/migrate.c
===================================================================
--- linux-2.6.22-rc2-mm1.orig/mm/migrate.c
+++ linux-2.6.22-rc2-mm1/mm/migrate.c
@@ -607,11 +607,12 @@ static int move_to_new_page(struct page 
  * to the newly allocated page in newpage.
  */
 static int unmap_and_move(new_page_t get_new_page, unsigned long private,
-			struct page *page, int force)
+			struct page *page, int force, int nocontext)
 {
 	int rc = 0;
 	int *result = NULL;
 	struct page *newpage = get_new_page(page, private, &result);
+	struct anon_vma *anon_vma = NULL;
 
 	if (!newpage)
 		return -ENOMEM;
@@ -632,17 +633,23 @@ static int unmap_and_move(new_page_t get
 			goto unlock;
 		wait_on_page_writeback(page);
 	}
-
+	/* hold this anon_vma until page migration ends */
+	if (nocontext && PageAnon(page) && page_mapped(page))
+		anon_vma = anon_vma_hold(page);
 	/*
 	 * Establish migration ptes or remove ptes
 	 */
-	try_to_unmap(page, 1);
+	if (page_mapped(page))
+		try_to_unmap(page, 1);
+
 	if (!page_mapped(page))
 		rc = move_to_new_page(newpage, page);
 
 	if (rc)
 		remove_migration_ptes(page, page);
 
+	anon_vma_release(anon_vma);
+
 unlock:
 	unlock_page(page);
 
@@ -686,8 +693,8 @@ move_newpage:
  *
  * Return: Number of pages not migrated or error code.
  */
-int migrate_pages(struct list_head *from,
-		new_page_t get_new_page, unsigned long private)
+int __migrate_pages(struct list_head *from,
+		new_page_t get_new_page, unsigned long private, int nocontext)
 {
 	int retry = 1;
 	int nr_failed = 0;
@@ -707,7 +714,7 @@ int migrate_pages(struct list_head *from
 			cond_resched();
 
 			rc = unmap_and_move(get_new_page, private,
-						page, pass > 2);
+						page, pass > 2, nocontext);
 
 			switch(rc) {
 			case -ENOMEM:
@@ -737,6 +744,22 @@ out:
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
Index: linux-2.6.22-rc2-mm1/include/linux/rmap.h
===================================================================
--- linux-2.6.22-rc2-mm1.orig/include/linux/rmap.h
+++ linux-2.6.22-rc2-mm1/include/linux/rmap.h
@@ -26,6 +26,9 @@
 struct anon_vma {
 	spinlock_t lock;	/* Serialize access to vma list */
 	struct list_head head;	/* List of private "related" vmas */
+#ifdef CONFIG_MIGRATION
+	int	ref;	/* special refcnt for migration */
+#endif
 };
 
 #ifdef CONFIG_MMU
@@ -42,6 +45,14 @@ static inline void anon_vma_free(struct 
 	kmem_cache_free(anon_vma_cachep, anon_vma);
 }
 
+#ifdef  CONFIG_MIGRATION
+extern struct anon_vma *anon_vma_hold(struct page *page);
+extern void anon_vma_release(struct anon_vma *anon_vma);
+#else
+#define anon_vma_hold(page)     do{}while(0)
+#define anon_vma_release(anon)  do{}while(0)
+#endif
+
 static inline void anon_vma_lock(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
Index: linux-2.6.22-rc2-mm1/mm/rmap.c
===================================================================
--- linux-2.6.22-rc2-mm1.orig/mm/rmap.c
+++ linux-2.6.22-rc2-mm1/mm/rmap.c
@@ -90,6 +90,9 @@ int anon_vma_prepare(struct vm_area_stru
 			anon_vma = anon_vma_alloc();
 			if (unlikely(!anon_vma))
 				return -ENOMEM;
+#ifdef CONFIG_MIGRATION
+			anon_vma->ref = 0;
+#endif
 			allocated = anon_vma;
 			locked = NULL;
 		}
@@ -150,9 +153,13 @@ void anon_vma_unlink(struct vm_area_stru
 	spin_lock(&anon_vma->lock);
 	validate_anon_vma(vma);
 	list_del(&vma->anon_vma_node);
-
 	/* We must garbage collect the anon_vma if it's empty */
 	empty = list_empty(&anon_vma->head);
+#ifdef CONFIG_MIGRATION
+	/* this means migrate_pages() has reference to this */
+	if (anon_vma->ref)
+		empty = 0;
+#endif
 	spin_unlock(&anon_vma->lock);
 
 	if (empty)
@@ -203,6 +210,33 @@ static void page_unlock_anon_vma(struct 
 	spin_unlock(&anon_vma->lock);
 	rcu_read_unlock();
 }
+#ifdef CONFIG_MIGRATION
+struct anon_vma *anon_vma_hold(struct page *page) {
+	struct anon_vma *anon_vma = NULL;
+	anon_vma = page_lock_anon_vma(page);
+	if (!anon_vma)
+		return NULL;
+	if (!list_empty(&anon_vma->head))
+		anon_vma->ref++;
+	spin_unlock(&anon_vma->lock);
+	return anon_vma;
+}
+
+void anon_vma_release(struct anon_vma *anon_vma)
+{
+	int empty;
+	if (!anon_vma) /* noting to do */
+		return;
+	spin_lock(&anon_vma->lock);
+	empty = list_empty(&anon_vma->head);
+	anon_vma->ref--;
+	if (!anon_vma->ref)
+		empty = 0;
+	spin_unlock(&anon_vma->lock);
+	if (empty)
+		anon_vma_free(anon_vma);
+}
+#endif
 
 /*
  * At what user virtual address is page expected in vma?
Index: linux-2.6.22-rc2-mm1/include/linux/migrate.h
===================================================================
--- linux-2.6.22-rc2-mm1.orig/include/linux/migrate.h
+++ linux-2.6.22-rc2-mm1/include/linux/migrate.h
@@ -30,7 +30,10 @@ extern int putback_lru_pages(struct list
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
