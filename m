Date: Fri, 8 Jun 2007 14:38:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: memory unplug v4 intro [1/6] migration without mm->sem
Message-Id: <20070608143844.569c2804.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070608143531.411c76df.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070608143531.411c76df.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, clameter@sgi.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

page migratio by kernel v4.

Changelog V3 -> V4
 *use dummy_vma instead of 'int' refcnt. 
 *add dummy_vma handling helper functions.
 *remove funcs for refcnt.
 *removed extra argment 'nocontext' to migrate_pages().
  This means extra check is always inserted into migrate_page() path.
 *removes migrate_pages_nocontext().


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
   This patch adds a special dummy_vma to anon_vma for avoiding
   anon_vma is freed while page is unmapped.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---
 include/linux/rmap.h |   30 ++++++++++++++++++++++++++++++
 mm/migrate.c         |   16 +++++++++++++---
 mm/rmap.c            |   33 +++++++++++++++++++++++++++++++++
 3 files changed, 76 insertions(+), 3 deletions(-)

Index: devel-2.6.22-rc4-mm2/mm/migrate.c
===================================================================
--- devel-2.6.22-rc4-mm2.orig/mm/migrate.c
+++ devel-2.6.22-rc4-mm2/mm/migrate.c
@@ -231,7 +231,8 @@ static void remove_anon_migration_ptes(s
 	spin_lock(&anon_vma->lock);
 
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
-		remove_migration_pte(vma, old, new);
+		if (!is_dummy_vma(vma))
+			remove_migration_pte(vma, old, new);
 
 	spin_unlock(&anon_vma->lock);
 }
@@ -612,6 +613,8 @@ static int unmap_and_move(new_page_t get
 	int rc = 0;
 	int *result = NULL;
 	struct page *newpage = get_new_page(page, private, &result);
+	struct anon_vma *anon_vma = NULL;
+	struct vm_area_struct holder;
 
 	if (!newpage)
 		return -ENOMEM;
@@ -632,17 +635,23 @@ static int unmap_and_move(new_page_t get
 			goto unlock;
 		wait_on_page_writeback(page);
 	}
-
+	/* hold this anon_vma until page migration ends */
+	if (PageAnon(page) && page_mapped(page))
+		anon_vma = anon_vma_hold(page, &holder);
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
 
+	anon_vma_release(anon_vma, &holder);
+
 unlock:
 	unlock_page(page);
 
@@ -685,6 +694,7 @@ move_newpage:
  * retruned to the LRU or freed.
  *
  * Return: Number of pages not migrated or error code.
+ *
  */
 int migrate_pages(struct list_head *from,
 		new_page_t get_new_page, unsigned long private)
Index: devel-2.6.22-rc4-mm2/include/linux/rmap.h
===================================================================
--- devel-2.6.22-rc4-mm2.orig/include/linux/rmap.h
+++ devel-2.6.22-rc4-mm2/include/linux/rmap.h
@@ -42,6 +42,36 @@ static inline void anon_vma_free(struct 
 	kmem_cache_free(anon_vma_cachep, anon_vma);
 }
 
+#ifdef  CONFIG_MIGRATION
+/*
+ * anon_vma->head works as refcnt for anon_vma struct.
+ * Migration needs one reference to anon_vma while unmapping -> remapping.
+ * dummy vm_area_struct is used for adding one ref to anon_vma.
+ *
+ * This means a list-walker of anon_vma->head have to check vma is dummy
+ * or not. please use is_dummy_vma() for check.
+ */
+
+extern struct anon_vma *anon_vma_hold(struct page *, struct vm_area_struct *);
+extern void anon_vma_release(struct anon_vma *, struct vm_area_struct *);
+
+static inline void init_dummy_vma(struct vm_area_struct *vma)
+{
+	vma->vm_mm = NULL;
+}
+
+static inline int is_dummy_vma(struct vm_area_struct *vma)
+{
+	if (unlikely(vma->vm_mm == NULL))
+		return 1;
+	return 0;
+}
+#else
+static inline int is_dummy_vma(struct vm_area_struct *vma) {
+	return 0;
+}
+#endif
+
 static inline void anon_vma_lock(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
Index: devel-2.6.22-rc4-mm2/mm/rmap.c
===================================================================
--- devel-2.6.22-rc4-mm2.orig/mm/rmap.c
+++ devel-2.6.22-rc4-mm2/mm/rmap.c
@@ -203,6 +203,35 @@ static void page_unlock_anon_vma(struct 
 	spin_unlock(&anon_vma->lock);
 	rcu_read_unlock();
 }
+#ifdef CONFIG_MIGRATION
+/*
+ * Record anon_vma in holder->anon_vma.
+ * Returns 1 if vma is linked to anon_vma. otherwise 0.
+ */
+struct anon_vma *
+anon_vma_hold(struct page *page, struct vm_area_struct *holder)
+{
+	struct anon_vma *anon_vma = NULL;
+	holder->anon_vma = NULL;
+	anon_vma = page_lock_anon_vma(page);
+	if (anon_vma && !list_empty(&anon_vma->head)) {
+		init_dummy_vma(holder);
+		holder->anon_vma = anon_vma;
+		__anon_vma_link(holder);
+	}
+	if (anon_vma)
+		page_unlock_anon_vma(anon_vma);
+	return holder->anon_vma;
+}
+
+void anon_vma_release(struct anon_vma *anon_vma, struct vm_area_struct *holder)
+{
+	if (!anon_vma)
+		return;
+	BUG_ON(anon_vma != holder->anon_vma);
+	anon_vma_unlink(holder);
+}
+#endif
 
 /*
  * At what user virtual address is page expected in vma?
@@ -333,6 +362,8 @@ static int page_referenced_anon(struct p
 
 	mapcount = page_mapcount(page);
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+		if (is_dummy_vma(vma))
+			continue;
 		referenced += page_referenced_one(page, vma, &mapcount);
 		if (!mapcount)
 			break;
@@ -864,6 +895,8 @@ static int try_to_unmap_anon(struct page
 		return ret;
 
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+		if (is_dummy_vma(vma))
+			continue;
 		ret = try_to_unmap_one(page, vma, migration);
 		if (ret == SWAP_FAIL || !page_mapped(page))
 			break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
