Date: Thu, 3 Apr 2003 14:24:41 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH 2.5.66-mm3] New page_convert_anon
Message-Id: <20030403142441.4a8a713e.akpm@digeo.com>
In-Reply-To: <75590000.1049407939@baldur.austin.ibm.com>
References: <61050000.1049405305@baldur.austin.ibm.com>
	<20030403135522.254e700c.akpm@digeo.com>
	<75590000.1049407939@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dave McCracken <dmccr@us.ibm.com> wrote:
>
> How does this patch look?

It's more conventional to lock the page in the caller.  And we forgot the
whole reason for locking it: to keep truncate away.  We need to check that
the page is still on the address_space after the page lock has been acquired.

This applies on top of your first.

 25-akpm/mm/filemap.c |    3 +++
 25-akpm/mm/fremap.c  |    5 ++++-
 25-akpm/mm/rmap.c    |   27 ++++++++++++++++++---------
 3 files changed, 25 insertions(+), 10 deletions(-)

diff -puN mm/filemap.c~page_convert_anon-lock_page mm/filemap.c
--- 25/mm/filemap.c~page_convert_anon-lock_page	Thu Apr  3 14:20:40 2003
+++ 25-akpm/mm/filemap.c	Thu Apr  3 14:20:40 2003
@@ -64,6 +64,9 @@
  *  ->mmap_sem
  *    ->i_shared_sem		(various places)
  *
+ *  ->lock_page
+ *    ->i_shared_sem		(page_convert_anon)
+ *
  *  ->inode_lock
  *    ->sb_lock			(fs/fs-writeback.c)
  *    ->mapping->page_lock	(__sync_single_inode)
diff -puN mm/rmap.c~page_convert_anon-lock_page mm/rmap.c
--- 25/mm/rmap.c~page_convert_anon-lock_page	Thu Apr  3 14:20:40 2003
+++ 25-akpm/mm/rmap.c	Thu Apr  3 14:22:17 2003
@@ -764,21 +764,29 @@ out:
  * Find all the mappings for an object-based page and convert them
  * to 'anonymous', ie create a pte_chain and store all the pte pointers there.
  *
- * This function takes the address_space->i_shared_sem, sets the PageAnon flag, then
- * sets the mm->page_table_lock for each vma and calls page_add_rmap.  This means
- * there is a period when PageAnon is set, but still has some mappings with no
- * pte_chain entry.  This is in fact safe, since page_remove_rmap will simply not
- * find it.  try_to_unmap might erroneously return success, but kswapd will correctly
- * see that there are still users of the page and send it around again.
+ * This function takes the address_space->i_shared_sem, sets the PageAnon flag,
+ * then sets the mm->page_table_lock for each vma and calls page_add_rmap. This
+ * means there is a period when PageAnon is set, but still has some mappings
+ * with no pte_chain entry.  This is in fact safe, since page_remove_rmap will
+ * simply not find it.  try_to_unmap might erroneously return success, but it
+ * will never be called because the page_convert_anon() caller has locked the
+ * page.
+ *
+ * page_referenced() may fail to scan all the appropriate pte's and may return
+ * an inaccurate result.  This is so rare that it does not matter.
  */
 int page_convert_anon(struct page *page)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping;
 	struct vm_area_struct *vma;
 	struct pte_chain *pte_chain = NULL;
 	pte_t *pte;
 	int err = 0;
 
+	mapping = page->mapping;
+	if (mapping == NULL)
+		goto out;		/* truncate won the lock_page() race */
+
 	down(&mapping->i_shared_sem);
 	pte_chain_lock(page);
 	SetPageLocked(page);
@@ -801,8 +809,8 @@ int page_convert_anon(struct page *page)
 	page->pte.mapcount = 0;
 
 	/*
-	 * Now that the page is marked as anon, unlock it.  page_add_rmap will lock
-	 * it as necessary.
+	 * Now that the page is marked as anon, unlock it.  page_add_rmap will
+	 * lock it as necessary.
 	 */
 	pte_chain_unlock(page);
 
@@ -849,6 +857,7 @@ out_unlock:
 	pte_chain_free(pte_chain);
 	ClearPageLocked(page);
 	up(&mapping->i_shared_sem);
+out:
 	return err;
 }
 
diff -puN mm/fremap.c~page_convert_anon-lock_page mm/fremap.c
--- 25/mm/fremap.c~page_convert_anon-lock_page	Thu Apr  3 14:20:40 2003
+++ 25-akpm/mm/fremap.c	Thu Apr  3 14:20:40 2003
@@ -73,7 +73,10 @@ int install_page(struct mm_struct *mm, s
 	pgidx += vma->vm_pgoff;
 	pgidx >>= PAGE_CACHE_SHIFT - PAGE_SHIFT;
 	if (!PageAnon(page) && (page->index != pgidx)) {
-		if (page_convert_anon(page) < 0)
+		lock_page(page);
+		err = page_convert_anon(page);
+		unlock_page(page);
+		if (err < 0)
 			goto err_free;
 	}
 

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
