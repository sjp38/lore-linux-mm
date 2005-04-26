From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17006.127.376459.93584@gargle.gargle.HOWL>
Date: Tue, 26 Apr 2005 12:49:03 +0400
Subject: Re: [PATCH]: VM 6/8 page_referenced(): move dirty
In-Reply-To: <20050425210016.6f8a47d1.akpm@osdl.org>
References: <16994.40677.105697.817303@gargle.gargle.HOWL>
	<20050425210016.6f8a47d1.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:
 > Nikita Danilov <nikita@clusterfs.com> wrote:
 > >
 > > transfer dirtiness from pte to the struct page in page_referenced().
 > 
 > This will increase the amount of physical I/O which the machine performs. 
 > 
 > If we're not really confident that we'll soon be able to reclaim a mmapped
 > page then we shouldn't bother writing it to disk, as it's quite likely that
 > userspace will redirty the page after we wrote it.

Yes, Rik van Riel was concerned with this also.

 > 
 > I can envision workloads (such as mmap 80% of memory and continuously dirty
 > it) which would end up performing continuous I/O with this patch.

Below is a version that tries to move dirtiness to the struct page only
if we are really going to deactivate the page. In your scenario above,
continuously dirty pages will be on the active list, so it should be
okay.

 > 
 > IOW: I'm gonna drop this one like it's made of lead!

Let's decrease atomic number by 3.

Nikita.

transfer dirtiness from pte to the struct page in page_referenced(). This
makes pages dirtied through mmap "visible" to the file system, that can write
them out through ->writepages() (otherwise pages are written from
->writepage() from tail of the inactive list).

Signed-off-by: Nikita Danilov <nikita@clusterfs.com>


 include/linux/rmap.h |    2 -
 mm/rmap.c            |   53 +++++++++++++++++++++++++++++++++++++++------------
 mm/vmscan.c          |   26 +++++++++++++++++++------
 3 files changed, 62 insertions(+), 19 deletions(-)

diff -puN mm/rmap.c~page_referenced-move-dirty mm/rmap.c
--- bk-linux/mm/rmap.c~page_referenced-move-dirty	2005-04-22 12:09:52.000000000 +0400
+++ bk-linux-nikita/mm/rmap.c	2005-04-22 12:09:52.000000000 +0400
@@ -283,12 +283,12 @@ static pte_t *page_check_address(struct 
  * repeatedly from either page_referenced_anon or page_referenced_file.
  */
 static int page_referenced_one(struct page *page,
-	struct vm_area_struct *vma, unsigned int *mapcount, int ignore_token)
+	struct vm_area_struct *vma, unsigned int *mapcount, int ignore_token,
+	int dirty, int referenced)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
 	pte_t *pte;
-	int referenced = 0;
 
 	if (!get_mm_counter(mm, rss))
 		goto out;
@@ -298,21 +298,37 @@ static int page_referenced_one(struct pa
 
 	pte = page_check_address(page, mm, address);
 	if (!IS_ERR(pte)) {
+		int is_dirty = 0;
+
 		if (ptep_clear_flush_young(vma, address, pte))
 			referenced++;
 
 		if (mm != current->mm && !ignore_token && has_swap_token(mm))
 			referenced++;
 
+		/*
+		 * transfer dirtiness from pte to the page, while we are here.
+		 *
+		 * This is supposed to improve write-out by detecting dirty
+		 * data early, when page is moved to the inactive list
+		 * (refill_inactive_zone()), so that balance_dirty_pages()
+		 * could write it.
+		 */
+
+		if (dirty > 0 || (dirty == 0 && referenced == 0))
+			is_dirty = ptep_test_and_clear_dirty(vma, address, pte);
+
 		(*mapcount)--;
 		pte_unmap(pte);
 		spin_unlock(&mm->page_table_lock);
+		if (is_dirty)
+			set_page_dirty(page);
 	}
 out:
 	return referenced;
 }
 
-static int page_referenced_anon(struct page *page, int ignore_token)
+static int page_referenced_anon(struct page *page, int ignore_token, int dirty)
 {
 	unsigned int mapcount;
 	struct anon_vma *anon_vma;
@@ -325,8 +341,9 @@ static int page_referenced_anon(struct p
 
 	mapcount = page_mapcount(page);
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
-		referenced += page_referenced_one(page, vma, &mapcount,
-							ignore_token);
+		referenced = page_referenced_one(page, vma, &mapcount,
+						 ignore_token,
+						 dirty, referenced);
 		if (!mapcount)
 			break;
 	}
@@ -345,7 +362,7 @@ static int page_referenced_anon(struct p
  *
  * This function is only called from page_referenced for object-based pages.
  */
-static int page_referenced_file(struct page *page, int ignore_token)
+static int page_referenced_file(struct page *page, int ignore_token, int dirty)
 {
 	unsigned int mapcount;
 	struct address_space *mapping = page->mapping;
@@ -383,8 +400,9 @@ static int page_referenced_file(struct p
 			referenced++;
 			break;
 		}
-		referenced += page_referenced_one(page, vma, &mapcount,
-							ignore_token);
+		referenced = page_referenced_one(page, vma, &mapcount,
+						 ignore_token,
+						 dirty, referenced);
 		if (!mapcount)
 			break;
 	}
@@ -397,11 +415,19 @@ static int page_referenced_file(struct p
  * page_referenced - test if the page was referenced
  * @page: the page to test
  * @is_locked: caller holds lock on the page
+ * @ignore_token: unless this is set, extra reference is counted for pages in
+ *                mm_struct holding swap token.
+ * @dirty: controls how dirtiness from pte is moved to the struct page:
+ *
+ *                  < 0 never
+ *                    0 only if page is not referenced
+ *                  > 0 always
  *
  * Quick test_and_clear_referenced for all mappings to a page,
  * returns the number of ptes which referenced the page.
  */
-int page_referenced(struct page *page, int is_locked, int ignore_token)
+int page_referenced(struct page *page,
+		    int is_locked, int ignore_token, int dirty)
 {
 	int referenced = 0;
 
@@ -416,15 +442,18 @@ int page_referenced(struct page *page, i
 
 	if (page_mapped(page) && page->mapping) {
 		if (PageAnon(page))
-			referenced += page_referenced_anon(page, ignore_token);
+			referenced += page_referenced_anon(page, ignore_token,
+							   dirty);
 		else if (is_locked)
-			referenced += page_referenced_file(page, ignore_token);
+			referenced += page_referenced_file(page, ignore_token,
+							   dirty);
 		else if (TestSetPageLocked(page))
 			referenced++;
 		else {
 			if (page->mapping)
 				referenced += page_referenced_file(page,
-								ignore_token);
+								   ignore_token,
+								   dirty);
 			unlock_page(page);
 		}
 	}
diff -puN mm/vmscan.c~page_referenced-move-dirty mm/vmscan.c
--- bk-linux/mm/vmscan.c~page_referenced-move-dirty	2005-04-22 12:09:52.000000000 +0400
+++ bk-linux-nikita/mm/vmscan.c	2005-04-22 12:09:52.000000000 +0400
@@ -471,6 +471,7 @@ static int shrink_list(struct list_head 
 		struct page *page;
 		int may_enter_fs;
 		int referenced;
+		int inuse;
 
 		cond_resched();
 
@@ -490,9 +491,11 @@ static int shrink_list(struct list_head 
 		if (PageWriteback(page))
 			goto keep_locked;
 
-		referenced = page_referenced(page, 1, sc->priority <= 0);
+		inuse = page_mapping_inuse(page);
+		referenced = page_referenced(page, 1, sc->priority <= 0,
+					     inuse ? -1 : +1);
 		/* In active use or really unfreeable?  Activate it. */
-		if (referenced && page_mapping_inuse(page))
+		if (referenced && inuse)
 			goto activate_locked;
 
 #ifdef CONFIG_SWAP
@@ -876,13 +879,24 @@ refill_inactive_zone(struct zone *zone, 
 		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
 		if (page_mapped(page)) {
-			if (!reclaim_mapped ||
-			    (total_swap_pages == 0 && PageAnon(page)) ||
-			    page_referenced(page, 0, sc->priority <= 0)) {
+  			int referenced;
+			int skip;
+
+			/*
+			 * The delicate dance below is because we only want to
+			 * transfer dirtiness from pte to struct page when
+			 * page is really about to be deactivated.
+			 */
+
+			skip = !reclaim_mapped ||
+				(total_swap_pages == 0 && PageAnon(page));
+			referenced = page_referenced(page, 0, sc->priority <= 0,
+						     skip ? -1 : 0);
+			if (skip || referenced) {
 				list_add(&page->lru, &l_active);
 				continue;
 			}
-		}
+  		}
 		list_add(&page->lru, &l_inactive);
 	}
 
diff -puN include/linux/rmap.h~page_referenced-move-dirty include/linux/rmap.h
--- bk-linux/include/linux/rmap.h~page_referenced-move-dirty	2005-04-22 12:09:52.000000000 +0400
+++ bk-linux-nikita/include/linux/rmap.h	2005-04-22 12:09:52.000000000 +0400
@@ -89,7 +89,7 @@ static inline void page_dup_rmap(struct 
 /*
  * Called from mm/vmscan.c to handle paging out
  */
-int page_referenced(struct page *, int is_locked, int ignore_token);
+int page_referenced(struct page *, int is_locked, int ignore_token, int dirty);
 int try_to_unmap(struct page *);
 
 /*

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
