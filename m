Date: Thu, 14 Jun 2007 15:59:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] memory unplug v5 [1/6] migration by kernel
Message-Id: <20070614155929.2be37edb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, clameter@sgi.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

page migratio by kernel v5.

Changelog V4->V5
- Removed new functions. just add add/remove dummy_vma codes.
- page_lock_anon_vma() is exported.

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
 mm/migrate.c |   21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

Index: devel-2.6.22-rc4-mm2/mm/migrate.c
===================================================================
--- devel-2.6.22-rc4-mm2.orig/mm/migrate.c
+++ devel-2.6.22-rc4-mm2/mm/migrate.c
@@ -602,6 +602,8 @@ static int move_to_new_page(struct page 
 	return rc;
 }
 
+/* By this DUMMY VMA, vma_address() always return -EFAULT */
+#define DUMMY_VMA	{.vm_mm = NULL, .vm_start = 0, .vm_end = 0,}
 /*
  * Obtain the lock on page, remove all ptes and migrate the page
  * to the newly allocated page in newpage.
@@ -612,6 +614,8 @@ static int unmap_and_move(new_page_t get
 	int rc = 0;
 	int *result = NULL;
 	struct page *newpage = get_new_page(page, private, &result);
+	struct anon_vma *anon_vma = NULL;
+	struct vm_area_struct dummy = DUMMY_VMA;
 
 	if (!newpage)
 		return -ENOMEM;
@@ -632,17 +636,30 @@ static int unmap_and_move(new_page_t get
 			goto unlock;
 		wait_on_page_writeback(page);
 	}
-
+	/* hold this anon_vma until page migration ends */
+	if (PageAnon(page) && page_mapped(page)) {
+		anon_vma = page_lock_anon_vma(page);
+		if (anon_vma) {
+			dummy.anon_vma = anon_vma;
+			__anon_vma_link(&dummy);
+			page_unlock_anon_vma(anon_vma);
+		}
+	}
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
 
+	if (anon_vma)
+		anon_vma_unlink(&dummy);
+
 unlock:
 	unlock_page(page);
 
Index: devel-2.6.22-rc4-mm2/include/linux/rmap.h
===================================================================
--- devel-2.6.22-rc4-mm2.orig/include/linux/rmap.h
+++ devel-2.6.22-rc4-mm2/include/linux/rmap.h
@@ -56,6 +56,9 @@ static inline void anon_vma_unlock(struc
 		spin_unlock(&anon_vma->lock);
 }
 
+struct anon_vma *page_lock_anon_vma(struct page *page);
+void page_unlock_anon_vma(struct anon_vma *anon_vma);
+
 /*
  * anon_vma helper functions.
  */
Index: devel-2.6.22-rc4-mm2/mm/rmap.c
===================================================================
--- devel-2.6.22-rc4-mm2.orig/mm/rmap.c
+++ devel-2.6.22-rc4-mm2/mm/rmap.c
@@ -178,7 +178,7 @@ void __init anon_vma_init(void)
  * Getting a lock on a stable anon_vma from a page off the LRU is
  * tricky: page_lock_anon_vma rely on RCU to guard against the races.
  */
-static struct anon_vma *page_lock_anon_vma(struct page *page)
+struct anon_vma *page_lock_anon_vma(struct page *page)
 {
 	struct anon_vma *anon_vma;
 	unsigned long anon_mapping;
@@ -198,7 +198,7 @@ out:
 	return NULL;
 }
 
-static void page_unlock_anon_vma(struct anon_vma *anon_vma)
+void page_unlock_anon_vma(struct anon_vma *anon_vma)
 {
 	spin_unlock(&anon_vma->lock);
 	rcu_read_unlock();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
