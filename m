Date: Mon, 10 Sep 2007 18:43:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [2/35] changes in /mm
Message-Id: <20070910184348.ffc7b82f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Changes page->mapping handling in /mm directory.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---
 mm/filemap.c        |   24 +++++++++++++-----------
 mm/memory.c         |    6 ++++--
 mm/migrate.c        |   17 ++++++-----------
 mm/page-writeback.c |    4 ++--
 mm/rmap.c           |   27 ++++++++++++---------------
 mm/shmem.c          |    4 ++--
 mm/truncate.c       |   15 ++++++++-------
 7 files changed, 47 insertions(+), 50 deletions(-)

Index: test-2.6.23-rc4-mm1/mm/filemap.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/mm/filemap.c
+++ test-2.6.23-rc4-mm1/mm/filemap.c
@@ -115,11 +115,11 @@ generic_file_direct_IO(int rw, struct ki
  */
 void __remove_from_page_cache(struct page *page)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 
 	mem_container_uncharge_page(page);
 	radix_tree_delete(&mapping->page_tree, page->index);
-	page->mapping = NULL;
+	page->mapping = 0;
 	mapping->nrpages--;
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	BUG_ON(page_mapped(page));
@@ -127,7 +127,7 @@ void __remove_from_page_cache(struct pag
 
 void remove_from_page_cache(struct page *page)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 
 	BUG_ON(!PageLocked(page));
 
@@ -454,7 +454,7 @@ int add_to_page_cache(struct page *page,
 		if (!error) {
 			page_cache_get(page);
 			SetPageLocked(page);
-			page->mapping = mapping;
+			page->mapping = (unsigned long)mapping;
 			page->index = offset;
 			mapping->nrpages++;
 			__inc_zone_page_state(page, NR_FILE_PAGES);
@@ -642,7 +642,7 @@ repeat:
 			__lock_page(page);
 
 			/* Has the page been truncated while we slept? */
-			if (unlikely(page->mapping != mapping)) {
+			if (unlikely(!pagecache_consistent(page, mapping))) {
 				unlock_page(page);
 				page_cache_release(page);
 				goto repeat;
@@ -751,7 +751,8 @@ unsigned find_get_pages_contig(struct ad
 	ret = radix_tree_gang_lookup(&mapping->page_tree,
 				(void **)pages, index, nr_pages);
 	for (i = 0; i < ret; i++) {
-		if (pages[i]->mapping == NULL || pages[i]->index != index)
+		if (!page_is_pagecache(pages[i]) ||
+		     pages[i]->index != index)
 			break;
 
 		page_cache_get(pages[i]);
@@ -980,7 +981,7 @@ page_not_up_to_date:
 		lock_page(page);
 
 		/* Did it get truncated before we got the lock? */
-		if (!page->mapping) {
+		if (!page_is_pagecache(page)) {
 			unlock_page(page);
 			page_cache_release(page);
 			continue;
@@ -1007,7 +1008,7 @@ readpage:
 		if (!PageUptodate(page)) {
 			lock_page(page);
 			if (!PageUptodate(page)) {
-				if (page->mapping == NULL) {
+				if (!page_is_pagecache(page)) {
 					/*
 					 * invalidate_inode_pages got it
 					 */
@@ -1546,7 +1547,7 @@ retry:
 		goto out;
 
 	lock_page(page);
-	if (!page->mapping) {
+	if (page_is_pagecache(page)) {
 		unlock_page(page);
 		page_cache_release(page);
 		goto retry;
@@ -2113,7 +2114,8 @@ static ssize_t generic_perform_write_2co
 			 * use a non-zeroing copy, but the APIs aren't too
 			 * consistent.
 			 */
-			if (unlikely(!page->mapping || PageUptodate(page))) {
+			if (unlikely(!page_is_pagecache(page) ||
+					PageUptodate(page))) {
 				unlock_page(page);
 				page_cache_release(page);
 				page_cache_release(src_page);
@@ -2556,7 +2558,7 @@ out:
  */
 int try_to_release_page(struct page *page, gfp_t gfp_mask)
 {
-	struct address_space * const mapping = page->mapping;
+	struct address_space * const mapping = page_mapping(page);
 
 	BUG_ON(!PageLocked(page));
 	if (PageWriteback(page))
Index: test-2.6.23-rc4-mm1/mm/memory.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/mm/memory.c
+++ test-2.6.23-rc4-mm1/mm/memory.c
@@ -650,7 +650,8 @@ static unsigned long zap_pte_range(struc
 				 * unmap shared but keep private pages.
 				 */
 				if (details->check_mapping &&
-				    details->check_mapping != page->mapping)
+				    !pagecache_consistent(page,
+						details->check_mapping))
 					continue;
 				/*
 				 * Each page->index must be checked when
@@ -2309,7 +2310,8 @@ static int __do_fault(struct mm_struct *
 				 * reworking page_mkwrite locking API, which
 				 * is better done later.
 				 */
-				if (!page->mapping) {
+				if (!page_is_pagecache(page) &&
+				    !PageAnon(page)) {
 					ret = 0;
 					anon = 1; /* no anon but release vmf.page */
 					goto out;
Index: test-2.6.23-rc4-mm1/mm/migrate.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/mm/migrate.c
+++ test-2.6.23-rc4-mm1/mm/migrate.c
@@ -223,17 +223,12 @@ static void remove_anon_migration_ptes(s
 {
 	struct anon_vma *anon_vma;
 	struct vm_area_struct *vma;
-	unsigned long mapping;
-
-	mapping = (unsigned long)new->mapping;
-
-	if (!mapping || (mapping & PAGE_MAPPING_ANON) == 0)
-		return;
-
 	/*
 	 * We hold the mmap_sem lock. So no need to call page_lock_anon_vma.
 	 */
-	anon_vma = (struct anon_vma *) (mapping - PAGE_MAPPING_ANON);
+	anon_vma = page_mapping_anon(new);
+	if (!anon_vma)
+		return;
 	spin_lock(&anon_vma->lock);
 
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
@@ -388,7 +383,7 @@ static void migrate_page_copy(struct pag
 	ClearPageActive(page);
 	ClearPagePrivate(page);
 	set_page_private(page, 0);
-	page->mapping = NULL;
+	page->mapping = 0;
 
 	/*
 	 * If any waiters have accumulated on the new page then
@@ -601,7 +596,7 @@ static int move_to_new_page(struct page 
 	if (!rc)
 		remove_migration_ptes(page, newpage);
 	else
-		newpage->mapping = NULL;
+		newpage->mapping = 0;
 
 	unlock_page(newpage);
 
@@ -658,7 +653,7 @@ static int unmap_and_move(new_page_t get
 	 * Calling try_to_unmap() against a page->mapping==NULL page is
 	 * BUG. So handle it here.
 	 */
-	if (!page->mapping)
+	if (!page_is_pagecache(page) && !PageAnon(page))
 		goto rcu_unlock;
 	/* Establish migration ptes or remove ptes */
 	try_to_unmap(page, 1);
Index: test-2.6.23-rc4-mm1/mm/page-writeback.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/mm/page-writeback.c
+++ test-2.6.23-rc4-mm1/mm/page-writeback.c
@@ -650,7 +650,7 @@ retry:
 			 */
 			lock_page(page);
 
-			if (unlikely(page->mapping != mapping)) {
+			if (unlikely(!pagecache_consistent(page, mapping))) {
 				unlock_page(page);
 				continue;
 			}
@@ -758,7 +758,7 @@ int do_writepages(struct address_space *
  */
 int write_one_page(struct page *page, int wait)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 	int ret = 0;
 	struct writeback_control wbc = {
 		.sync_mode = WB_SYNC_ALL,
Index: test-2.6.23-rc4-mm1/mm/rmap.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/mm/rmap.c
+++ test-2.6.23-rc4-mm1/mm/rmap.c
@@ -160,16 +160,14 @@ void __init anon_vma_init(void)
 static struct anon_vma *page_lock_anon_vma(struct page *page)
 {
 	struct anon_vma *anon_vma;
-	unsigned long anon_mapping;
 
 	rcu_read_lock();
-	anon_mapping = (unsigned long) page->mapping;
-	if (!(anon_mapping & PAGE_MAPPING_ANON))
-		goto out;
+
 	if (!page_mapped(page))
 		goto out;
-
-	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
+	anon_vma = page_mapping_anon(page);
+	if (!anon_vma)
+		goto out;
 	spin_lock(&anon_vma->lock);
 	return anon_vma;
 out:
@@ -208,12 +206,11 @@ vma_address(struct page *page, struct vm
 unsigned long page_address_in_vma(struct page *page, struct vm_area_struct *vma)
 {
 	if (PageAnon(page)) {
-		if ((void *)vma->anon_vma !=
-		    (void *)page->mapping - PAGE_MAPPING_ANON)
+		if (vma->anon_vma != page_mapping_anon(page))
 			return -EFAULT;
 	} else if (page->mapping && !(vma->vm_flags & VM_NONLINEAR)) {
 		if (!vma->vm_file ||
-		    vma->vm_file->f_mapping != page->mapping)
+		    vma->vm_file->f_mapping != page_mapping_cache(page))
 			return -EFAULT;
 	} else
 		return -EFAULT;
@@ -344,7 +341,7 @@ static int page_referenced_file(struct p
 				struct mem_container *mem_cont)
 {
 	unsigned int mapcount;
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping_cache(page);
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
@@ -422,7 +419,7 @@ int page_referenced(struct page *page, i
 		else if (TestSetPageLocked(page))
 			referenced++;
 		else {
-			if (page->mapping)
+			if (page_mapping_cache(page))
 				referenced +=
 					page_referenced_file(page, mem_cont);
 			unlock_page(page);
@@ -514,7 +511,7 @@ static void __page_set_anon_rmap(struct 
 
 	BUG_ON(!anon_vma);
 	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
-	page->mapping = (struct address_space *) anon_vma;
+	page->mapping = (unsigned long) anon_vma;
 
 	page->index = linear_page_index(vma, address);
 
@@ -549,7 +546,7 @@ static void __page_check_anon_rmap(struc
 	 */
 	struct anon_vma *anon_vma = vma->anon_vma;
 	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
-	BUG_ON(page->mapping != (struct address_space *)anon_vma);
+	BUG_ON(page->mapping != (unsigned long)anon_vma);
 	BUG_ON(page->index != linear_page_index(vma, address));
 #endif
 }
@@ -649,7 +646,7 @@ void page_remove_rmap(struct page *page,
 			printk (KERN_EMERG "  page pfn = %lx\n", page_to_pfn(page));
 			printk (KERN_EMERG "  page->flags = %lx\n", page->flags);
 			printk (KERN_EMERG "  page->count = %x\n", page_count(page));
-			printk (KERN_EMERG "  page->mapping = %p\n", page->mapping);
+			printk (KERN_EMERG "  page->mapping = %p\n", (void*)page->mapping);
 			print_symbol (KERN_EMERG "  vma->vm_ops = %s\n", (unsigned long)vma->vm_ops);
 			if (vma->vm_ops) {
 				print_symbol (KERN_EMERG "  vma->vm_ops->nopage = %s\n", (unsigned long)vma->vm_ops->nopage);
@@ -894,7 +891,7 @@ static int try_to_unmap_anon(struct page
  */
 static int try_to_unmap_file(struct page *page, int migration)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping_cache(page);
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
Index: test-2.6.23-rc4-mm1/mm/shmem.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/mm/shmem.c
+++ test-2.6.23-rc4-mm1/mm/shmem.c
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
Index: test-2.6.23-rc4-mm1/mm/truncate.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/mm/truncate.c
+++ test-2.6.23-rc4-mm1/mm/truncate.c
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
 			if (account_size)
@@ -93,7 +93,7 @@ EXPORT_SYMBOL(cancel_dirty_page);
 static void
 truncate_complete_page(struct address_space *mapping, struct page *page)
 {
-	if (page->mapping != mapping)
+	if (!pagecache_consistent(page, mapping))
 		return;
 
 	cancel_dirty_page(page, PAGE_CACHE_SIZE);
@@ -120,7 +120,7 @@ invalidate_complete_page(struct address_
 {
 	int ret;
 
-	if (page->mapping != mapping)
+	if (!pagecache_consistent(page, mapping))
 		return 0;
 
 	if (PagePrivate(page) && !try_to_release_page(page, 0))
@@ -342,7 +342,7 @@ EXPORT_SYMBOL(invalidate_mapping_pages);
 static int
 invalidate_complete_page2(struct address_space *mapping, struct page *page)
 {
-	if (page->mapping != mapping)
+	if (!pagecache_consistent(page, mapping))
 		return 0;
 
 	if (PagePrivate(page) && !try_to_release_page(page, GFP_KERNEL))
@@ -367,7 +367,8 @@ static int do_launder_page(struct addres
 {
 	if (!PageDirty(page))
 		return 0;
-	if (page->mapping != mapping || mapping->a_ops->launder_page == NULL)
+	if (!pagecache_consistent(page, mapping) ||
+		mapping->a_ops->launder_page == NULL)
 		return 0;
 	return mapping->a_ops->launder_page(page);
 }
@@ -403,7 +404,7 @@ int invalidate_inode_pages2_range(struct
 			pgoff_t page_index;
 
 			lock_page(page);
-			if (page->mapping != mapping) {
+			if (!pagecache_consistent(page, mapping)) {
 				unlock_page(page);
 				continue;
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
