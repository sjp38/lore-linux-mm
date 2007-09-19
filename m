Date: Wed, 19 Sep 2007 16:44:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] page->mapping clarification [2/3] changes in /mm
Message-Id: <20070919164457.e8359bb3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070919164308.281f9960.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070919164308.281f9960.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, ricknu-0@student.ltu.se
List-ID: <linux-mm.kvack.org>

Make use of page-cache.h functions in /mm layer.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/filemap.c        |   19 ++++++++++---------
 mm/memory.c         |    5 +++--
 mm/migrate.c        |    8 ++------
 mm/page-writeback.c |    4 ++--
 mm/rmap.c           |   36 ++++++++++++++----------------------
 mm/shmem.c          |    4 ++--
 mm/truncate.c       |   15 ++++++++-------
 7 files changed, 41 insertions(+), 50 deletions(-)

Index: linux-2.6.23-rc6-mm1/mm/filemap.c
===================================================================
--- linux-2.6.23-rc6-mm1.orig/mm/filemap.c
+++ linux-2.6.23-rc6-mm1/mm/filemap.c
@@ -115,7 +115,7 @@ generic_file_direct_IO(int rw, struct ki
  */
 void __remove_from_page_cache(struct page *page)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping_cache(page);
 
 	mem_container_uncharge_page(page);
 	radix_tree_delete(&mapping->page_tree, page->index);
@@ -127,7 +127,7 @@ void __remove_from_page_cache(struct pag
 
 void remove_from_page_cache(struct page *page)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping_cache(page);
 
 	BUG_ON(!PageLocked(page));
 
@@ -641,7 +641,7 @@ repeat:
 			__lock_page(page);
 
 			/* Has the page been truncated while we slept? */
-			if (unlikely(page->mapping != mapping)) {
+			if (unlikely(!is_page_consistent(page, mapping))) {
 				unlock_page(page);
 				page_cache_release(page);
 				goto repeat;
@@ -750,7 +750,7 @@ unsigned find_get_pages_contig(struct ad
 	ret = radix_tree_gang_lookup(&mapping->page_tree,
 				(void **)pages, index, nr_pages);
 	for (i = 0; i < ret; i++) {
-		if (pages[i]->mapping == NULL || pages[i]->index != index)
+		if (!page_is_pagecache(pages[i]) || pages[i]->index != index)
 			break;
 
 		page_cache_get(pages[i]);
@@ -979,7 +979,7 @@ page_not_up_to_date:
 		lock_page(page);
 
 		/* Did it get truncated before we got the lock? */
-		if (!page->mapping) {
+		if (!page_is_pagecache(page)) {
 			unlock_page(page);
 			page_cache_release(page);
 			continue;
@@ -1006,7 +1006,7 @@ readpage:
 		if (!PageUptodate(page)) {
 			lock_page(page);
 			if (!PageUptodate(page)) {
-				if (page->mapping == NULL) {
+				if (!page_is_pagecache(page)) {
 					/*
 					 * invalidate_inode_pages got it
 					 */
@@ -1545,7 +1545,7 @@ retry:
 		goto out;
 
 	lock_page(page);
-	if (!page->mapping) {
+	if (!page_is_pagecache(page)) {
 		unlock_page(page);
 		page_cache_release(page);
 		goto retry;
@@ -2112,7 +2112,8 @@ static ssize_t generic_perform_write_2co
 			 * use a non-zeroing copy, but the APIs aren't too
 			 * consistent.
 			 */
-			if (unlikely(!page->mapping || PageUptodate(page))) {
+			if (unlikely(!page_is_pagecache(page) ||
+				      PageUptodate(page))) {
 				unlock_page(page);
 				page_cache_release(page);
 				page_cache_release(src_page);
@@ -2555,7 +2556,7 @@ out:
  */
 int try_to_release_page(struct page *page, gfp_t gfp_mask)
 {
-	struct address_space * const mapping = page->mapping;
+	struct address_space * const mapping = page_mapping_cache(page);
 
 	BUG_ON(!PageLocked(page));
 	if (PageWriteback(page))
Index: linux-2.6.23-rc6-mm1/mm/memory.c
===================================================================
--- linux-2.6.23-rc6-mm1.orig/mm/memory.c
+++ linux-2.6.23-rc6-mm1/mm/memory.c
@@ -650,7 +650,8 @@ static unsigned long zap_pte_range(struc
 				 * unmap shared but keep private pages.
 				 */
 				if (details->check_mapping &&
-				    details->check_mapping != page->mapping)
+				    !is_page_consistent(page,
+						details->check_mapping))
 					continue;
 				/*
 				 * Each page->index must be checked when
@@ -2310,7 +2311,7 @@ static int __do_fault(struct mm_struct *
 				 * reworking page_mkwrite locking API, which
 				 * is better done later.
 				 */
-				if (!page->mapping) {
+				if (!page_is_pagecache(page)) {
 					ret = 0;
 					anon = 1; /* no anon but release vmf.page */
 					goto out;
Index: linux-2.6.23-rc6-mm1/mm/migrate.c
===================================================================
--- linux-2.6.23-rc6-mm1.orig/mm/migrate.c
+++ linux-2.6.23-rc6-mm1/mm/migrate.c
@@ -223,17 +223,13 @@ static void remove_anon_migration_ptes(s
 {
 	struct anon_vma *anon_vma;
 	struct vm_area_struct *vma;
-	unsigned long mapping;
-
-	mapping = (unsigned long)new->mapping;
 
-	if (!mapping || (mapping & PAGE_MAPPING_ANON) == 0)
+	anon_vma = page_mapping_anon(new);
+	if (!anon_vma)
 		return;
-
 	/*
 	 * We hold the mmap_sem lock. So no need to call page_lock_anon_vma.
 	 */
-	anon_vma = (struct anon_vma *) (mapping - PAGE_MAPPING_ANON);
 	spin_lock(&anon_vma->lock);
 
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
Index: linux-2.6.23-rc6-mm1/mm/page-writeback.c
===================================================================
--- linux-2.6.23-rc6-mm1.orig/mm/page-writeback.c
+++ linux-2.6.23-rc6-mm1/mm/page-writeback.c
@@ -832,7 +832,7 @@ retry:
 			 */
 			lock_page(page);
 
-			if (unlikely(page->mapping != mapping)) {
+			if (unlikely(!is_page_consistent(page, mapping))) {
 				unlock_page(page);
 				continue;
 			}
@@ -940,7 +940,7 @@ int do_writepages(struct address_space *
  */
 int write_one_page(struct page *page, int wait)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping_cache(page);
 	int ret = 0;
 	struct writeback_control wbc = {
 		.sync_mode = WB_SYNC_ALL,
Index: linux-2.6.23-rc6-mm1/mm/rmap.c
===================================================================
--- linux-2.6.23-rc6-mm1.orig/mm/rmap.c
+++ linux-2.6.23-rc6-mm1/mm/rmap.c
@@ -159,16 +159,13 @@ void __init anon_vma_init(void)
 static struct anon_vma *page_lock_anon_vma(struct page *page)
 {
 	struct anon_vma *anon_vma;
-	unsigned long anon_mapping;
 
 	rcu_read_lock();
-	anon_mapping = (unsigned long) page->mapping;
-	if (!(anon_mapping & PAGE_MAPPING_ANON))
+	anon_vma = page_mapping_anon(page);
+	if (!anon_vma)
 		goto out;
 	if (!page_mapped(page))
 		goto out;
-
-	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
 	spin_lock(&anon_vma->lock);
 	return anon_vma;
 out:
@@ -207,12 +204,11 @@ vma_address(struct page *page, struct vm
 unsigned long page_address_in_vma(struct page *page, struct vm_area_struct *vma)
 {
 	if (PageAnon(page)) {
-		if ((void *)vma->anon_vma !=
-		    (void *)page->mapping - PAGE_MAPPING_ANON)
+		if (vma->anon_vma != page_mapping_anon(page))
 			return -EFAULT;
-	} else if (page->mapping && !(vma->vm_flags & VM_NONLINEAR)) {
+	} else if (page_is_pagecache(page) && !(vma->vm_flags & VM_NONLINEAR)) {
 		if (!vma->vm_file ||
-		    vma->vm_file->f_mapping != page->mapping)
+		    !is_page_consistent(page, vma->vm_file->f_mapping))
 			return -EFAULT;
 	} else
 		return -EFAULT;
@@ -333,9 +329,9 @@ static int page_referenced_anon(struct p
  * @page: the page we're checking references on.
  *
  * For an object-based mapped page, find all the places it is mapped and
- * check/clear the referenced flag.  This is done by following the page->mapping
- * pointer, then walking the chain of vmas it holds.  It returns the number
- * of references it found.
+ * check/clear the referenced flag.  This is done by following the
+ * address_space of page_maping_cache(), then walking the chain of vmas it
+ * holds.  It returns the number of references it found.
  *
  * This function is only called from page_referenced for object-based pages.
  */
@@ -343,18 +339,16 @@ static int page_referenced_file(struct p
 				struct mem_container *mem_cont)
 {
 	unsigned int mapcount;
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping_cache(page);
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
 	int referenced = 0;
 
 	/*
-	 * The caller's checks on page->mapping and !PageAnon have made
-	 * sure that this is a file page: the check for page->mapping
-	 * excludes the case just before it gets set on an anon page.
+	 * Make sure this is a file page.
 	 */
-	BUG_ON(PageAnon(page));
+	BUG_ON(!mapping);
 
 	/*
 	 * The page lock not only makes sure that page->mapping cannot
@@ -421,7 +415,7 @@ int page_referenced(struct page *page, i
 		else if (TestSetPageLocked(page))
 			referenced++;
 		else {
-			if (page->mapping)
+			if (page_is_pagecache(page))
 				referenced +=
 					page_referenced_file(page, mem_cont);
 			unlock_page(page);
@@ -546,9 +540,7 @@ static void __page_check_anon_rmap(struc
 	 * are initially only visible via the pagetables, and the pte is locked
 	 * over the call to page_add_new_anon_rmap.
 	 */
-	struct anon_vma *anon_vma = vma->anon_vma;
-	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
-	BUG_ON(page->mapping != (struct address_space *)anon_vma);
+	BUG_ON(vma->anon_vma != page_mapping_anon(page));
 	BUG_ON(page->index != linear_page_index(vma, address));
 #endif
 }
@@ -893,7 +885,7 @@ static int try_to_unmap_anon(struct page
  */
 static int try_to_unmap_file(struct page *page, int migration)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping_cache(page);
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
Index: linux-2.6.23-rc6-mm1/mm/shmem.c
===================================================================
--- linux-2.6.23-rc6-mm1.orig/mm/shmem.c
+++ linux-2.6.23-rc6-mm1/mm/shmem.c
@@ -917,7 +917,7 @@ static int shmem_writepage(struct page *
 	BUG_ON(!PageLocked(page));
 	BUG_ON(page_mapped(page));
 
-	mapping = page->mapping;
+	mapping = page_mapping_cache(page);
 	index = page->index;
 	inode = mapping->host;
 	info = SHMEM_I(inode);
@@ -1454,7 +1454,7 @@ static const struct inode_operations shm
  */
 static int shmem_readpage(struct file *file, struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	int error = shmem_getpage(inode, page->index, &page, SGP_CACHE, NULL);
 	unlock_page(page);
 	return error;
Index: linux-2.6.23-rc6-mm1/mm/truncate.c
===================================================================
--- linux-2.6.23-rc6-mm1.orig/mm/truncate.c
+++ linux-2.6.23-rc6-mm1/mm/truncate.c
@@ -37,7 +37,7 @@
 void do_invalidatepage(struct page *page, unsigned long offset)
 {
 	void (*invalidatepage)(struct page *, unsigned long);
-	invalidatepage = page->mapping->a_ops->invalidatepage;
+	invalidatepage = page_mapping_cache(page)->a_ops->invalidatepage;
 #ifdef CONFIG_BLOCK
 	if (!invalidatepage)
 		invalidatepage = block_invalidatepage;
@@ -70,7 +70,7 @@ static inline void truncate_partial_page
 void cancel_dirty_page(struct page *page, unsigned int account_size)
 {
 	if (TestClearPageDirty(page)) {
-		struct address_space *mapping = page->mapping;
+		struct address_space *mapping = page_mapping_cache(page);
 		if (mapping && mapping_cap_account_dirty(mapping)) {
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(mapping->backing_dev_info,
@@ -95,7 +95,7 @@ EXPORT_SYMBOL(cancel_dirty_page);
 static void
 truncate_complete_page(struct address_space *mapping, struct page *page)
 {
-	if (page->mapping != mapping)
+	if (!is_page_consistent(page, mapping))
 		return;
 
 	cancel_dirty_page(page, PAGE_CACHE_SIZE);
@@ -122,7 +122,7 @@ invalidate_complete_page(struct address_
 {
 	int ret;
 
-	if (page->mapping != mapping)
+	if (!is_page_consistent(page, mapping))
 		return 0;
 
 	if (PagePrivate(page) && !try_to_release_page(page, 0))
@@ -344,7 +344,7 @@ EXPORT_SYMBOL(invalidate_mapping_pages);
 static int
 invalidate_complete_page2(struct address_space *mapping, struct page *page)
 {
-	if (page->mapping != mapping)
+	if (!is_page_consistent(page, mapping))
 		return 0;
 
 	if (PagePrivate(page) && !try_to_release_page(page, GFP_KERNEL))
@@ -369,7 +369,8 @@ static int do_launder_page(struct addres
 {
 	if (!PageDirty(page))
 		return 0;
-	if (page->mapping != mapping || mapping->a_ops->launder_page == NULL)
+	if (!is_page_consistent(page, mapping) ||
+		mapping->a_ops->launder_page == NULL)
 		return 0;
 	return mapping->a_ops->launder_page(page);
 }
@@ -405,7 +406,7 @@ int invalidate_inode_pages2_range(struct
 			pgoff_t page_index;
 
 			lock_page(page);
-			if (page->mapping != mapping) {
+			if (!is_page_consistent(page, mapping)) {
 				unlock_page(page);
 				continue;
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
