Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id l87CWXvK021999
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 7 Sep 2007 21:32:34 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 71AFE53C11B
	for <linux-mm@kvack.org>; Fri,  7 Sep 2007 21:32:33 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (s7.gw.fujitsu.co.jp [10.0.50.97])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 44C3B24009A
	for <linux-mm@kvack.org>; Fri,  7 Sep 2007 21:32:33 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (s7 [127.0.0.1])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id E4C11161C00A
	for <linux-mm@kvack.org>; Fri,  7 Sep 2007 21:32:32 +0900 (JST)
Received: from fjm503.ms.jp.fujitsu.com (fjm503.ms.jp.fujitsu.com [10.56.99.77])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 4967D161C008
	for <linux-mm@kvack.org>; Fri,  7 Sep 2007 21:32:32 +0900 (JST)
Received: from fjmscan502.ms.jp.fujitsu.com (fjmscan502.ms.jp.fujitsu.com [10.56.99.142])by fjm503.ms.jp.fujitsu.com with ESMTP id l87CWS5e021054
	for <linux-mm@kvack.org>; Fri, 7 Sep 2007 21:32:28 +0900
Received: from GENEVIEVE ([10.124.100.187])
	by fjmscan502.ms.jp.fujitsu.com (8.13.1/8.12.11) with SMTP id l87CWNYp031685
	for <linux-mm@kvack.org>; Fri, 7 Sep 2007 21:32:28 +0900
Date: Fri, 7 Sep 2007 21:35:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] VM: hide page->mapping details from FS
Message-Id: <20070907213500.017c74f6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This (big) patch does
 - add page_mapping_anon() for getting anon_vma of a page.
 - add page_inode() for getting inode of a page
 - changes page->mapping from address_space* to unsigned long
 - fix page->mapping to page_mapiing(page) if appropriate
 - fix page->mapping->host  to page_inode(page) if appropriage

Purpose:
  Because we cannot increase size of struct page easily, members of struct
  page are tend to be overriden and are used for several purposes.

  page->mapping is one of overridden param but directly accessed from anywhere.
 
  This patch removes direct access to page->mapping (AMAP) and hide struct
  page's detail from fs (to some extent).

  Size of patch is big but what it does is simple.
  
  boot on my box and compile passed with all mod config. but I can't test
  all file systems...

To be honest:
  I may want to override page->mapping for some my purpose ;)
  But need more consideration..
  (encoding mlock information or put page_container here or something.)

Regrets:
  I put page_inode() in mm_inline.h...but this looks not so good.
  Do you have any recomendation ?

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 fs/affs/affs.h                           |    1 
 fs/affs/file.c                           |    4 +-
 fs/affs/symlink.c                        |    2 -
 fs/afs/file.c                            |    7 ++--
 fs/buffer.c                              |   49 ++++++++++++++++++-------------
 fs/cifs/file.c                           |   11 +++---
 fs/coda/symlink.c                        |    3 +
 fs/cramfs/inode.c                        |    3 +
 fs/ecryptfs/crypto.c                     |    9 +++--
 fs/ecryptfs/mmap.c                       |   15 +++++----
 fs/efs/symlink.c                         |    3 +
 fs/ext2/dir.c                            |   15 +++++----
 fs/ext3/inode.c                          |   11 +++---
 fs/ext4/inode.c                          |   11 +++---
 fs/ext4/writeback.c                      |   25 ++++++++-------
 fs/freevxfs/vxfs_immed.c                 |    3 +
 fs/fuse/file.c                           |    5 +--
 fs/gfs2/log.c                            |    5 +--
 fs/gfs2/lops.c                           |    2 -
 fs/gfs2/meta_io.c                        |    3 +
 fs/gfs2/ops_address.c                    |   17 +++++-----
 fs/hfs/inode.c                           |    3 +
 fs/hfsplus/inode.c                       |    3 +
 fs/hpfs/namei.c                          |    5 ++-
 fs/isofs/rock.c                          |    3 +
 fs/jbd/journal.c                         |    2 -
 fs/jffs2/file.c                          |    5 +--
 fs/jfs/jfs_metapage.c                    |    9 +++--
 fs/libfs.c                               |    3 +
 fs/minix/dir.c                           |    8 ++---
 fs/mpage.c                               |   14 +++++---
 fs/ncpfs/symlink.c                       |    3 +
 fs/nfs/file.c                            |   10 +++---
 fs/nfs/internal.h                        |    3 +
 fs/nfs/pagelist.c                        |    2 -
 fs/nfs/read.c                            |    4 +-
 fs/nfs/write.c                           |   34 ++++++++++-----------
 fs/ntfs/aops.c                           |   15 +++++----
 fs/ntfs/compress.c                       |    2 -
 fs/ntfs/file.c                           |    7 ++--
 fs/ocfs2/aops.c                          |    9 +++--
 fs/ocfs2/mmap.c                          |    2 -
 fs/reiser4/as_ops.c                      |   30 +++++++++---------
 fs/reiser4/entd.c                        |    6 +--
 fs/reiser4/jnode.c                       |   16 +++++-----
 fs/reiser4/page_cache.c                  |   10 +++---
 fs/reiser4/plugin/cluster.h              |   14 ++++----
 fs/reiser4/plugin/file/cryptcompress.c   |   14 ++++----
 fs/reiser4/plugin/file/file.c            |   22 ++++++-------
 fs/reiser4/plugin/file_ops.c             |    8 ++---
 fs/reiser4/plugin/item/ctail.c           |   17 +++++-----
 fs/reiser4/plugin/item/extent_file_ops.c |    6 +--
 fs/reiser4/plugin/item/tail.c            |    6 +--
 fs/reiser4/reiser4.h                     |    2 +
 fs/reiser4/wander.c                      |    2 -
 fs/reiserfs/inode.c                      |   17 +++++-----
 fs/reiserfs/journal.c                    |    2 -
 fs/reiserfs/tail_conversion.c            |    3 +
 fs/romfs/inode.c                         |    3 +
 fs/sysv/dir.c                            |    8 ++---
 fs/udf/file.c                            |    5 +--
 fs/udf/symlink.c                         |    3 +
 fs/ufs/dir.c                             |   11 +++---
 fs/unionfs/mmap.c                        |    8 ++---
 fs/unionfs/union.h                       |    1 
 fs/xfs/linux-2.6/xfs_aops.c              |    9 +++--
 include/linux/mm.h                       |   12 ++++++-
 include/linux/mm_inline.h                |    5 +++
 include/linux/mm_types.h                 |    2 -
 kernel/kexec.c                           |    2 -
 mm/filemap.c                             |   16 +++++-----
 mm/memory.c                              |    2 -
 mm/migrate.c                             |   11 ++----
 mm/page-writeback.c                      |    4 +-
 mm/rmap.c                                |   24 ++++++---------
 mm/shmem.c                               |    7 +---
 mm/swap_state.c                          |    5 +++
 mm/truncate.c                            |   18 ++++++-----
 78 files changed, 373 insertions(+), 308 deletions(-)

Index: test-2.6.23-rc4-mm1/mm/shmem.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/mm/shmem.c
+++ test-2.6.23-rc4-mm1/mm/shmem.c
@@ -49,6 +49,7 @@
 #include <linux/ctype.h>
 #include <linux/migrate.h>
 #include <linux/highmem.h>
+#include <linux/mm_inline.h>
 
 #include <asm/uaccess.h>
 #include <asm/div64.h>
@@ -910,16 +911,14 @@ static int shmem_writepage(struct page *
 {
 	struct shmem_inode_info *info;
 	swp_entry_t *entry, swap;
-	struct address_space *mapping;
 	unsigned long index;
 	struct inode *inode;
 
 	BUG_ON(!PageLocked(page));
 	BUG_ON(page_mapped(page));
 
-	mapping = page->mapping;
 	index = page->index;
-	inode = mapping->host;
+	inode = page_inode(page);
 	info = SHMEM_I(inode);
 	if (info->flags & VM_LOCKED)
 		goto redirty;
@@ -1454,7 +1453,7 @@ static const struct inode_operations shm
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
@@ -37,7 +37,8 @@
 void do_invalidatepage(struct page *page, unsigned long offset)
 {
 	void (*invalidatepage)(struct page *, unsigned long);
-	invalidatepage = page->mapping->a_ops->invalidatepage;
+	struct address_space *mapping = page_mapping(page);
+	invalidatepage = mapping->a_ops->invalidatepage;
 #ifdef CONFIG_BLOCK
 	if (!invalidatepage)
 		invalidatepage = block_invalidatepage;
@@ -70,7 +71,7 @@ static inline void truncate_partial_page
 void cancel_dirty_page(struct page *page, unsigned int account_size)
 {
 	if (TestClearPageDirty(page)) {
-		struct address_space *mapping = page->mapping;
+		struct address_space *mapping = page_mapping(page);
 		if (mapping && mapping_cap_account_dirty(mapping)) {
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			if (account_size)
@@ -85,7 +86,7 @@ EXPORT_SYMBOL(cancel_dirty_page);
  * becomes anonymous.  It will be left on the LRU and may even be mapped into
  * user pagetables if we're racing with filemap_fault().
  *
- * We need to bale out if page->mapping is no longer equal to the original
+ * We need to bale out if page_mapping(page) is no longer equal to the original
  * mapping.  This happens a) when the VM reclaimed the page while we waited on
  * its lock, b) when a concurrent invalidate_mapping_pages got there first and
  * c) when tmpfs swizzles a page between a tmpfs inode and swapper_space.
@@ -93,7 +94,7 @@ EXPORT_SYMBOL(cancel_dirty_page);
 static void
 truncate_complete_page(struct address_space *mapping, struct page *page)
 {
-	if (page->mapping != mapping)
+	if (page_mapping(page) != mapping)
 		return;
 
 	cancel_dirty_page(page, PAGE_CACHE_SIZE);
@@ -120,7 +121,7 @@ invalidate_complete_page(struct address_
 {
 	int ret;
 
-	if (page->mapping != mapping)
+	if (page_mapping(page) != mapping)
 		return 0;
 
 	if (PagePrivate(page) && !try_to_release_page(page, 0))
@@ -342,7 +343,7 @@ EXPORT_SYMBOL(invalidate_mapping_pages);
 static int
 invalidate_complete_page2(struct address_space *mapping, struct page *page)
 {
-	if (page->mapping != mapping)
+	if (page_mapping(page) != mapping)
 		return 0;
 
 	if (PagePrivate(page) && !try_to_release_page(page, GFP_KERNEL))
@@ -365,9 +366,10 @@ failed:
 
 static int do_launder_page(struct address_space *mapping, struct page *page)
 {
+	struct address_space *as = page_mapping(page);
 	if (!PageDirty(page))
 		return 0;
-	if (page->mapping != mapping || mapping->a_ops->launder_page == NULL)
+	if (as != mapping || mapping->a_ops->launder_page == NULL)
 		return 0;
 	return mapping->a_ops->launder_page(page);
 }
@@ -403,7 +405,7 @@ int invalidate_inode_pages2_range(struct
 			pgoff_t page_index;
 
 			lock_page(page);
-			if (page->mapping != mapping) {
+			if (page_mapping(page) != mapping) {
 				unlock_page(page);
 				continue;
 			}
Index: test-2.6.23-rc4-mm1/mm/rmap.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/mm/rmap.c
+++ test-2.6.23-rc4-mm1/mm/rmap.c
@@ -160,16 +160,13 @@ void __init anon_vma_init(void)
 static struct anon_vma *page_lock_anon_vma(struct page *page)
 {
 	struct anon_vma *anon_vma;
-	unsigned long anon_mapping;
 
 	rcu_read_lock();
-	anon_mapping = (unsigned long) page->mapping;
-	if (!(anon_mapping & PAGE_MAPPING_ANON))
-		goto out;
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
@@ -209,11 +206,11 @@ unsigned long page_address_in_vma(struct
 {
 	if (PageAnon(page)) {
 		if ((void *)vma->anon_vma !=
-		    (void *)page->mapping - PAGE_MAPPING_ANON)
+		    (void *)page_mapping_anon(page))
 			return -EFAULT;
 	} else if (page->mapping && !(vma->vm_flags & VM_NONLINEAR)) {
 		if (!vma->vm_file ||
-		    vma->vm_file->f_mapping != page->mapping)
+		    vma->vm_file->f_mapping != page_mapping(page))
 			return -EFAULT;
 	} else
 		return -EFAULT;
@@ -344,7 +341,7 @@ static int page_referenced_file(struct p
 				struct mem_container *mem_cont)
 {
 	unsigned int mapcount;
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
@@ -514,7 +511,7 @@ static void __page_set_anon_rmap(struct 
 
 	BUG_ON(!anon_vma);
 	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
-	page->mapping = (struct address_space *) anon_vma;
+	page->mapping = (unsigned long) anon_vma;
 
 	page->index = linear_page_index(vma, address);
 
@@ -548,8 +545,7 @@ static void __page_check_anon_rmap(struc
 	 * over the call to page_add_new_anon_rmap.
 	 */
 	struct anon_vma *anon_vma = vma->anon_vma;
-	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
-	BUG_ON(page->mapping != (struct address_space *)anon_vma);
+	BUG_ON(page_mapping_anon(page) != anon_vma);
 	BUG_ON(page->index != linear_page_index(vma, address));
 #endif
 }
@@ -649,7 +645,7 @@ void page_remove_rmap(struct page *page,
 			printk (KERN_EMERG "  page pfn = %lx\n", page_to_pfn(page));
 			printk (KERN_EMERG "  page->flags = %lx\n", page->flags);
 			printk (KERN_EMERG "  page->count = %x\n", page_count(page));
-			printk (KERN_EMERG "  page->mapping = %p\n", page->mapping);
+			printk (KERN_EMERG "  page->mapping = %p\n", (void*)page->mapping);
 			print_symbol (KERN_EMERG "  vma->vm_ops = %s\n", (unsigned long)vma->vm_ops);
 			if (vma->vm_ops) {
 				print_symbol (KERN_EMERG "  vma->vm_ops->nopage = %s\n", (unsigned long)vma->vm_ops->nopage);
@@ -894,7 +890,7 @@ static int try_to_unmap_anon(struct page
  */
 static int try_to_unmap_file(struct page *page, int migration)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
Index: test-2.6.23-rc4-mm1/mm/page-writeback.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/mm/page-writeback.c
+++ test-2.6.23-rc4-mm1/mm/page-writeback.c
@@ -650,7 +650,7 @@ retry:
 			 */
 			lock_page(page);
 
-			if (unlikely(page->mapping != mapping)) {
+			if (unlikely(page_mapping(page) != mapping)) {
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
Index: test-2.6.23-rc4-mm1/mm/migrate.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/mm/migrate.c
+++ test-2.6.23-rc4-mm1/mm/migrate.c
@@ -223,17 +223,14 @@ static void remove_anon_migration_ptes(s
 {
 	struct anon_vma *anon_vma;
 	struct vm_area_struct *vma;
-	unsigned long mapping;
 
-	mapping = (unsigned long)new->mapping;
+	anon_vma = page_mapping_anon(new);
 
-	if (!mapping || (mapping & PAGE_MAPPING_ANON) == 0)
+	if (!anon_vma)
 		return;
-
 	/*
 	 * We hold the mmap_sem lock. So no need to call page_lock_anon_vma.
 	 */
-	anon_vma = (struct anon_vma *) (mapping - PAGE_MAPPING_ANON);
 	spin_lock(&anon_vma->lock);
 
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
@@ -388,7 +385,7 @@ static void migrate_page_copy(struct pag
 	ClearPageActive(page);
 	ClearPagePrivate(page);
 	set_page_private(page, 0);
-	page->mapping = NULL;
+	page->mapping = 0;
 
 	/*
 	 * If any waiters have accumulated on the new page then
@@ -601,7 +598,7 @@ static int move_to_new_page(struct page 
 	if (!rc)
 		remove_migration_ptes(page, newpage);
 	else
-		newpage->mapping = NULL;
+		newpage->mapping = 0;
 
 	unlock_page(newpage);
 
Index: test-2.6.23-rc4-mm1/mm/memory.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/mm/memory.c
+++ test-2.6.23-rc4-mm1/mm/memory.c
@@ -650,7 +650,7 @@ static unsigned long zap_pte_range(struc
 				 * unmap shared but keep private pages.
 				 */
 				if (details->check_mapping &&
-				    details->check_mapping != page->mapping)
+				    details->check_mapping != page_mapping(page))
 					continue;
 				/*
 				 * Each page->index must be checked when
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
+			if (unlikely(page_mapping(page) != mapping)) {
 				unlock_page(page);
 				page_cache_release(page);
 				goto repeat;
@@ -751,7 +751,7 @@ unsigned find_get_pages_contig(struct ad
 	ret = radix_tree_gang_lookup(&mapping->page_tree,
 				(void **)pages, index, nr_pages);
 	for (i = 0; i < ret; i++) {
-		if (pages[i]->mapping == NULL || pages[i]->index != index)
+		if (!pages[i]->mapping || pages[i]->index != index)
 			break;
 
 		page_cache_get(pages[i]);
@@ -1007,7 +1007,7 @@ readpage:
 		if (!PageUptodate(page)) {
 			lock_page(page);
 			if (!PageUptodate(page)) {
-				if (page->mapping == NULL) {
+				if (!page->mapping) {
 					/*
 					 * invalidate_inode_pages got it
 					 */
@@ -2556,7 +2556,7 @@ out:
  */
 int try_to_release_page(struct page *page, gfp_t gfp_mask)
 {
-	struct address_space * const mapping = page->mapping;
+	struct address_space * const mapping = page_mapping(page);
 
 	BUG_ON(!PageLocked(page));
 	if (PageWriteback(page))
Index: test-2.6.23-rc4-mm1/fs/buffer.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/buffer.c
+++ test-2.6.23-rc4-mm1/fs/buffer.c
@@ -41,6 +41,7 @@
 #include <linux/bitops.h>
 #include <linux/mpage.h>
 #include <linux/bit_spinlock.h>
+#include <linux/mm_inline.h>
 
 static int fsync_buffers_list(spinlock_t *lock, struct list_head *list);
 
@@ -454,6 +455,7 @@ static void end_buffer_async_write(struc
 	struct buffer_head *first;
 	struct buffer_head *tmp;
 	struct page *page;
+	struct address_space *mapping;
 
 	BUG_ON(!buffer_async_write(bh));
 
@@ -467,7 +469,8 @@ static void end_buffer_async_write(struc
 					"I/O error on %s\n",
 			       bdevname(bh->b_bdev, b));
 		}
-		set_bit(AS_EIO, &page->mapping->flags);
+		mapping = page_mapping(page);
+		set_bit(AS_EIO, &mapping->flags);
 		set_buffer_write_io_error(bh);
 		clear_buffer_uptodate(bh);
 		SetPageError(page);
@@ -678,7 +681,7 @@ void write_boundary_block(struct block_d
 void mark_buffer_dirty_inode(struct buffer_head *bh, struct inode *inode)
 {
 	struct address_space *mapping = inode->i_mapping;
-	struct address_space *buffer_mapping = bh->b_page->mapping;
+	struct address_space *buffer_mapping = page_mapping(bh->b_page);
 
 	mark_buffer_dirty(bh);
 	if (!mapping->assoc_mapping) {
@@ -1202,7 +1205,7 @@ void __bforget(struct buffer_head *bh)
 {
 	clear_buffer_dirty(bh);
 	if (!list_empty(&bh->b_assoc_buffers)) {
-		struct address_space *buffer_mapping = bh->b_page->mapping;
+		struct address_space *buffer_mapping = page_mapping(bh->b_page);
 
 		spin_lock(&buffer_mapping->private_lock);
 		list_del_init(&bh->b_assoc_buffers);
@@ -1532,6 +1535,7 @@ void create_empty_buffers(struct page *p
 			unsigned long blocksize, unsigned long b_state)
 {
 	struct buffer_head *bh, *head, *tail;
+	struct address_space *mapping;
 
 	head = alloc_page_buffers(page, blocksize, 1);
 	bh = head;
@@ -1542,7 +1546,8 @@ void create_empty_buffers(struct page *p
 	} while (bh);
 	tail->b_this_page = head;
 
-	spin_lock(&page->mapping->private_lock);
+	mapping = page_mapping(page);
+	spin_lock(&mapping->private_lock);
 	if (PageUptodate(page) || PageDirty(page)) {
 		bh = head;
 		do {
@@ -1554,7 +1559,7 @@ void create_empty_buffers(struct page *p
 		} while (bh != head);
 	}
 	attach_page_buffers(page, head);
-	spin_unlock(&page->mapping->private_lock);
+	spin_unlock(&mapping->private_lock);
 }
 EXPORT_SYMBOL(create_empty_buffers);
 
@@ -1761,7 +1766,7 @@ recover:
 	} while ((bh = bh->b_this_page) != head);
 	SetPageError(page);
 	BUG_ON(PageWriteback(page));
-	mapping_set_error(page->mapping, err);
+	mapping_set_error(page_mapping(page), err);
 	set_page_writeback(page);
 	do {
 		struct buffer_head *next = bh->b_this_page;
@@ -2075,7 +2080,7 @@ EXPORT_SYMBOL(generic_write_end);
  */
 int block_read_full_page(struct page *page, get_block_t *get_block)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	sector_t iblock, lblock;
 	struct buffer_head *bh, *head, *arr[MAX_BUF_PER_PAGE];
 	unsigned int blocksize;
@@ -2296,7 +2301,7 @@ out:
 int block_prepare_write(struct page *page, unsigned from, unsigned to,
 			get_block_t *get_block)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	int err = __block_prepare_write(inode, page, from, to, get_block);
 	if (err)
 		ClearPageUptodate(page);
@@ -2305,7 +2310,7 @@ int block_prepare_write(struct page *pag
 
 int block_commit_write(struct page *page, unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	__block_commit_write(inode,page,from,to);
 	return 0;
 }
@@ -2313,7 +2318,7 @@ int block_commit_write(struct page *page
 int generic_commit_write(struct file *file, struct page *page,
 		unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
 	__block_commit_write(inode,page,from,to);
 	/*
@@ -2353,7 +2358,7 @@ block_page_mkwrite(struct vm_area_struct
 
 	lock_page(page);
 	size = i_size_read(inode);
-	if ((page->mapping != inode->i_mapping) ||
+	if ((page_inode(page) != inode) ||
 	    (page_offset(page) > size)) {
 		/* page got truncated out from underneath us */
 		goto out_unlock;
@@ -2391,7 +2396,8 @@ static void end_buffer_read_nobh(struct 
 int nobh_prepare_write(struct page *page, unsigned from, unsigned to,
 			get_block_t *get_block)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
+	struct address_space *mapping;
 	const unsigned blkbits = inode->i_blkbits;
 	const unsigned blocksize = 1 << blkbits;
 	struct buffer_head *head, *bh;
@@ -2505,7 +2511,8 @@ failed:
 	 * the handling of potential IO errors during writeout would be hard
 	 * (could try doing synchronous writeout, but what if that fails too?)
 	 */
-	spin_lock(&page->mapping->private_lock);
+	mapping = page_mapping(page);
+	spin_lock(&mapping->private_lock);
 	bh = head;
 	block_start = 0;
 	do {
@@ -2535,7 +2542,7 @@ next:
 		bh = bh->b_this_page;
 	} while (bh != head);
 	attach_page_buffers(page, head);
-	spin_unlock(&page->mapping->private_lock);
+	spin_unlock(&mapping->private_lock);
 
 	return ret;
 }
@@ -2548,7 +2555,7 @@ EXPORT_SYMBOL(nobh_prepare_write);
 int nobh_commit_write(struct file *file, struct page *page,
 		unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
 
 	if (page_has_buffers(page))
@@ -2572,7 +2579,7 @@ EXPORT_SYMBOL(nobh_commit_write);
 int nobh_writepage(struct page *page, get_block_t *get_block,
 			struct writeback_control *wbc)
 {
-	struct inode * const inode = page->mapping->host;
+	struct inode * const inode = page_inode(page);
 	loff_t i_size = i_size_read(inode);
 	const pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
 	unsigned offset;
@@ -2737,7 +2744,7 @@ out:
 int block_write_full_page(struct page *page, get_block_t *get_block,
 			struct writeback_control *wbc)
 {
-	struct inode * const inode = page->mapping->host;
+	struct inode * const inode = page_inode(page);
 	loff_t i_size = i_size_read(inode);
 	const pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
 	unsigned offset;
@@ -2963,11 +2970,13 @@ drop_buffers(struct page *page, struct b
 {
 	struct buffer_head *head = page_buffers(page);
 	struct buffer_head *bh;
+	struct address_space *mapping;
 
 	bh = head;
 	do {
-		if (buffer_write_io_error(bh) && page->mapping)
-			set_bit(AS_EIO, &page->mapping->flags);
+		mapping = page_mapping(page);
+		if (buffer_write_io_error(bh) && mapping)
+			set_bit(AS_EIO, &mapping->flags);
 		if (buffer_busy(bh))
 			goto failed;
 		bh = bh->b_this_page;
@@ -2989,7 +2998,7 @@ failed:
 
 int try_to_free_buffers(struct page *page)
 {
-	struct address_space * const mapping = page->mapping;
+	struct address_space * const mapping = page_mapping(page);
 	struct buffer_head *buffers_to_free = NULL;
 	int ret = 0;
 
Index: test-2.6.23-rc4-mm1/fs/libfs.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/libfs.c
+++ test-2.6.23-rc4-mm1/fs/libfs.c
@@ -8,6 +8,7 @@
 #include <linux/mount.h>
 #include <linux/vfs.h>
 #include <linux/mutex.h>
+#include <linux/mm_inline.h>
 
 #include <asm/uaccess.h>
 
@@ -374,7 +375,7 @@ int simple_write_begin(struct file *file
 static int simple_commit_write(struct file *file, struct page *page,
 			       unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
 
 	if (!PageUptodate(page))
Index: test-2.6.23-rc4-mm1/fs/mpage.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/mpage.c
+++ test-2.6.23-rc4-mm1/fs/mpage.c
@@ -26,6 +26,7 @@
 #include <linux/writeback.h>
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
+#include <linux/mm_inline.h>
 
 /*
  * I/O completion handler for multipage BIOs.
@@ -80,9 +81,10 @@ static int mpage_end_io_write(struct bio
 			prefetchw(&bvec->bv_page->flags);
 
 		if (!uptodate){
+			struct address_space *mapping = page_mapping(page);
 			SetPageError(page);
-			if (page->mapping)
-				set_bit(AS_EIO, &page->mapping->flags);
+			if (mapping)
+				set_bit(AS_EIO, &mapping->flags);
 		}
 		end_page_writeback(page);
 	} while (bvec >= bio->bi_io_vec);
@@ -133,7 +135,7 @@ mpage_alloc(struct block_device *bdev,
 static void 
 map_buffer_to_page(struct page *page, struct buffer_head *bh, int page_block) 
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct buffer_head *page_bh, *head;
 	int block = 0;
 
@@ -177,7 +179,7 @@ do_mpage_readpage(struct bio *bio, struc
 		sector_t *last_block_in_bio, struct buffer_head *map_bh,
 		unsigned long *first_logical_block, get_block_t get_block)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	const unsigned blkbits = inode->i_blkbits;
 	const unsigned blocks_per_page = PAGE_CACHE_SIZE >> blkbits;
 	const unsigned blocksize = 1 << blkbits;
@@ -460,8 +462,8 @@ static int __mpage_writepage(struct page
 {
 	struct mpage_data *mpd = data;
 	struct bio *bio = mpd->bio;
-	struct address_space *mapping = page->mapping;
-	struct inode *inode = page->mapping->host;
+	struct address_space *mapping = page_mapping(page);
+	struct inode *inode = page_inode(page);
 	const unsigned blkbits = inode->i_blkbits;
 	unsigned long end_index;
 	const unsigned blocks_per_page = PAGE_CACHE_SIZE >> blkbits;
Index: test-2.6.23-rc4-mm1/include/linux/mm.h
===================================================================
--- test-2.6.23-rc4-mm1.orig/include/linux/mm.h
+++ test-2.6.23-rc4-mm1/include/linux/mm.h
@@ -563,7 +563,7 @@ void page_address_init(void);
 extern struct address_space swapper_space;
 static inline struct address_space *page_mapping(struct page *page)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = (struct address_space *)page->mapping;
 
 	VM_BUG_ON(PageSlab(page));
 	if (unlikely(PageSwapCache(page)))
@@ -577,6 +577,14 @@ static inline struct address_space *page
 	return mapping;
 }
 
+static inline struct anon_vma *page_mapping_anon(struct page *page)
+{
+	unsigned long mapping = page->mapping;
+	if (!(mapping & PAGE_MAPPING_ANON))
+		return NULL;
+	return (struct anon_vma *)(mapping - PAGE_MAPPING_ANON);
+}
+
 static inline int PageAnon(struct page *page)
 {
 	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
@@ -848,7 +856,7 @@ static inline pmd_t *pmd_alloc(struct mm
 #define pte_lock_init(_page)	do {					\
 	spin_lock_init(__pte_lockptr(_page));				\
 } while (0)
-#define pte_lock_deinit(page)	((page)->mapping = NULL)
+#define pte_lock_deinit(page)	((page)->mapping = 0)
 #define pte_lockptr(mm, pmd)	({(void)(mm); __pte_lockptr(pmd_page(*(pmd)));})
 #else
 /*
Index: test-2.6.23-rc4-mm1/include/linux/mm_inline.h
===================================================================
--- test-2.6.23-rc4-mm1.orig/include/linux/mm_inline.h
+++ test-2.6.23-rc4-mm1/include/linux/mm_inline.h
@@ -38,3 +38,8 @@ del_page_from_lru(struct zone *zone, str
 	}
 }
 
+static inline struct inode *page_inode(const struct page* page)
+{
+	BUG_ON(page->mapping & PAGE_MAPPING_ANON);
+	return ((struct address_space *)page->mapping)->host;
+}
Index: test-2.6.23-rc4-mm1/fs/cifs/file.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/cifs/file.c
+++ test-2.6.23-rc4-mm1/fs/cifs/file.c
@@ -30,6 +30,7 @@
 #include <linux/writeback.h>
 #include <linux/task_io_accounting_ops.h>
 #include <linux/delay.h>
+#include <linux/mm_inline.h>
 #include <asm/div64.h>
 #include "cifsfs.h"
 #include "cifspdu.h"
@@ -1056,7 +1057,7 @@ struct cifsFileInfo *find_writable_file(
 
 static int cifs_partialpagewrite(struct page *page, unsigned from, unsigned to)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 	loff_t offset = (loff_t)page->index << PAGE_CACHE_SHIFT;
 	char *write_data;
 	int rc = -EFAULT;
@@ -1069,7 +1070,7 @@ static int cifs_partialpagewrite(struct 
 	if (!mapping || !mapping->host)
 		return -EFAULT;
 
-	inode = page->mapping->host;
+	inode = page_inode(page);
 	cifs_sb = CIFS_SB(inode->i_sb);
 	pTcon = cifs_sb->tcon;
 
@@ -1209,7 +1210,7 @@ retry:
 			else if (TestSetPageLocked(page))
 				break;
 
-			if (unlikely(page->mapping != mapping)) {
+			if (unlikely(page_mapping(page) != mapping)) {
 				unlock_page(page);
 				break;
 			}
@@ -1371,7 +1372,7 @@ static int cifs_commit_write(struct file
 {
 	int xid;
 	int rc = 0;
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	loff_t position = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
 	char *page_data;
 
@@ -1973,7 +1974,7 @@ static int cifs_prepare_write(struct fil
 	}
 
 	offset = (loff_t)page->index << PAGE_CACHE_SHIFT;
-	i_size = i_size_read(page->mapping->host);
+	i_size = i_size_read(page_inode(page));
 
 	if ((offset >= i_size) ||
 	    ((from == 0) && (offset + to) >= i_size)) {
Index: test-2.6.23-rc4-mm1/include/linux/mm_types.h
===================================================================
--- test-2.6.23-rc4-mm1.orig/include/linux/mm_types.h
+++ test-2.6.23-rc4-mm1/include/linux/mm_types.h
@@ -48,7 +48,7 @@ struct page {
 						 * indicates order in the buddy
 						 * system if PG_buddy is set.
 						 */
-		struct address_space *mapping;	/* If low bit clear, points to
+		unsigned long mapping;	/* If low bit clear, points to
 						 * inode address_space, or NULL.
 						 * If page mapped as anonymous
 						 * memory, low bit is set, and
Index: test-2.6.23-rc4-mm1/kernel/kexec.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/kernel/kexec.c
+++ test-2.6.23-rc4-mm1/kernel/kexec.c
@@ -347,7 +347,7 @@ static struct page *kimage_alloc_pages(g
 	pages = alloc_pages(gfp_mask, order);
 	if (pages) {
 		unsigned int count, i;
-		pages->mapping = NULL;
+		pages->mapping = 0;
 		set_page_private(pages, order);
 		count = 1 << order;
 		for (i = 0; i < count; i++)
Index: test-2.6.23-rc4-mm1/fs/cramfs/inode.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/cramfs/inode.c
+++ test-2.6.23-rc4-mm1/fs/cramfs/inode.c
@@ -23,6 +23,7 @@
 #include <linux/buffer_head.h>
 #include <linux/vfs.h>
 #include <linux/mutex.h>
+#include <linux/mm_inline.h>
 #include <asm/semaphore.h>
 
 #include <asm/uaccess.h>
@@ -469,7 +470,7 @@ static struct dentry * cramfs_lookup(str
 
 static int cramfs_readpage(struct file *file, struct page * page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	u32 maxblock, bytes_filled;
 	void *pgdata;
 
Index: test-2.6.23-rc4-mm1/fs/ext2/dir.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/ext2/dir.c
+++ test-2.6.23-rc4-mm1/fs/ext2/dir.c
@@ -25,6 +25,7 @@
 #include <linux/buffer_head.h>
 #include <linux/pagemap.h>
 #include <linux/swap.h>
+#include <linux/mm_inline.h>
 
 typedef struct ext2_dir_entry_2 ext2_dirent;
 
@@ -65,7 +66,7 @@ ext2_last_byte(struct inode *inode, unsi
 
 static int ext2_commit_chunk(struct page *page, loff_t pos, unsigned len)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 	struct inode *dir = mapping->host;
 	int err = 0;
 
@@ -87,7 +88,7 @@ static int ext2_commit_chunk(struct page
 
 static void ext2_check_page(struct page *page)
 {
-	struct inode *dir = page->mapping->host;
+	struct inode *dir = page_inode(page);
 	struct super_block *sb = dir->i_sb;
 	unsigned chunk_size = ext2_chunk_size(dir);
 	char *kaddr = page_address(page);
@@ -429,7 +430,7 @@ void ext2_set_link(struct inode *dir, st
 	int err;
 
 	lock_page(page);
-	err = __ext2_write_begin(NULL, page->mapping, pos, len,
+	err = __ext2_write_begin(NULL, page_mapping(page), pos, len,
 				AOP_FLAG_UNINTERRUPTIBLE, &page, NULL);
 	BUG_ON(err);
 	de->inode = cpu_to_le32(inode->i_ino);
@@ -512,7 +513,7 @@ int ext2_add_link (struct dentry *dentry
 got_it:
 	pos = page_offset(page) +
 		(char*)de - (char*)page_address(page);
-	err = __ext2_write_begin(NULL, page->mapping, pos, rec_len, 0,
+	err = __ext2_write_begin(NULL, page_mapping(page), pos, rec_len, 0,
 							&page, NULL);
 	if (err)
 		goto out_unlock;
@@ -546,7 +547,7 @@ out_unlock:
  */
 int ext2_delete_entry (struct ext2_dir_entry_2 * dir, struct page * page )
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 	struct inode *inode = mapping->host;
 	char *kaddr = page_address(page);
 	unsigned from = ((char*)dir - kaddr) & ~(ext2_chunk_size(inode)-1);
@@ -570,7 +571,7 @@ int ext2_delete_entry (struct ext2_dir_e
 		from = (char*)pde - (char*)page_address(page);
 	pos = page_offset(page) + from;
 	lock_page(page);
-	err = __ext2_write_begin(NULL, page->mapping, pos, to - from, 0,
+	err = __ext2_write_begin(NULL, page_mapping(page), pos, to - from, 0,
 							&page, NULL);
 	BUG_ON(err);
 	if (pde)
@@ -600,7 +601,7 @@ int ext2_make_empty(struct inode *inode,
 	if (!page)
 		return -ENOMEM;
 
-	err = __ext2_write_begin(NULL, page->mapping, 0, chunk_size, 0,
+	err = __ext2_write_begin(NULL, page_mapping(page), 0, chunk_size, 0,
 							&page, NULL);
 	if (err) {
 		unlock_page(page);
Index: test-2.6.23-rc4-mm1/fs/ext3/inode.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/ext3/inode.c
+++ test-2.6.23-rc4-mm1/fs/ext3/inode.c
@@ -36,6 +36,7 @@
 #include <linux/mpage.h>
 #include <linux/uio.h>
 #include <linux/bio.h>
+#include <linux/mm_inline.h>
 #include "xattr.h"
 #include "acl.h"
 
@@ -1484,7 +1485,7 @@ static int journal_dirty_data_fn(handle_
 static int ext3_ordered_writepage(struct page *page,
 				struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct buffer_head *page_bufs;
 	handle_t *handle = NULL;
 	int ret = 0;
@@ -1550,7 +1551,7 @@ out_fail:
 static int ext3_writeback_writepage(struct page *page,
 				struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	handle_t *handle = NULL;
 	int ret = 0;
 	int err;
@@ -1583,7 +1584,7 @@ out_fail:
 static int ext3_journalled_writepage(struct page *page,
 				struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	handle_t *handle = NULL;
 	int ret = 0;
 	int err;
@@ -1653,7 +1654,7 @@ ext3_readpages(struct file *file, struct
 
 static void ext3_invalidatepage(struct page *page, unsigned long offset)
 {
-	journal_t *journal = EXT3_JOURNAL(page->mapping->host);
+	journal_t *journal = EXT3_JOURNAL(page_inode(page));
 
 	/*
 	 * If it's a full truncate we just forget about the pending dirtying
@@ -1666,7 +1667,7 @@ static void ext3_invalidatepage(struct p
 
 static int ext3_releasepage(struct page *page, gfp_t wait)
 {
-	journal_t *journal = EXT3_JOURNAL(page->mapping->host);
+	journal_t *journal = EXT3_JOURNAL(page_inode(page));
 
 	WARN_ON(PageChecked(page));
 	if (!page_has_buffers(page))
Index: test-2.6.23-rc4-mm1/fs/freevxfs/vxfs_immed.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/freevxfs/vxfs_immed.c
+++ test-2.6.23-rc4-mm1/fs/freevxfs/vxfs_immed.c
@@ -33,6 +33,7 @@
 #include <linux/fs.h>
 #include <linux/pagemap.h>
 #include <linux/namei.h>
+#include <linux/mm_inline.h>
 
 #include "vxfs.h"
 #include "vxfs_inode.h"
@@ -98,7 +99,7 @@ vxfs_immed_follow_link(struct dentry *dp
 static int
 vxfs_immed_readpage(struct file *fp, struct page *pp)
 {
-	struct vxfs_inode_info	*vip = VXFS_INO(pp->mapping->host);
+	struct vxfs_inode_info	*vip = VXFS_INO(page_inode(pp));
 	u_int64_t	offset = (u_int64_t)pp->index << PAGE_CACHE_SHIFT;
 	caddr_t		kaddr;
 
Index: test-2.6.23-rc4-mm1/fs/gfs2/log.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/gfs2/log.c
+++ test-2.6.23-rc4-mm1/fs/gfs2/log.c
@@ -16,6 +16,7 @@
 #include <linux/crc32.h>
 #include <linux/lm_interface.h>
 #include <linux/delay.h>
+#include <linux/mm_inline.h>
 
 #include "gfs2.h"
 #include "incore.h"
@@ -229,8 +230,8 @@ static void gfs2_ail2_empty_one(struct g
 		list_del(&bd->bd_ail_st_list);
 		list_del(&bd->bd_ail_gl_list);
 		atomic_dec(&bd->bd_gl->gl_ail_count);
-		if (bd->bd_bh->b_page->mapping) {
-			bh_ip = GFS2_I(bd->bd_bh->b_page->mapping->host);
+		if (page_mapping(bd->bd_bh->b_page)) {
+			bh_ip = GFS2_I(page_inode(bd->bd_bh->b_page));
 			gfs2_meta_cache_flush(bh_ip);
 		}
 		brelse(bd->bd_bh);
Index: test-2.6.23-rc4-mm1/fs/gfs2/lops.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/gfs2/lops.c
+++ test-2.6.23-rc4-mm1/fs/gfs2/lops.c
@@ -473,7 +473,7 @@ static void databuf_lo_add(struct gfs2_s
 {
 	struct gfs2_bufdata *bd = container_of(le, struct gfs2_bufdata, bd_le);
 	struct gfs2_trans *tr = current->journal_info;
-	struct address_space *mapping = bd->bd_bh->b_page->mapping;
+	struct address_space *mapping = page_mapping(bd->bd_bh->b_page);
 	struct gfs2_inode *ip = GFS2_I(mapping->host);
 
 	gfs2_log_lock(sdp);
Index: test-2.6.23-rc4-mm1/fs/gfs2/meta_io.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/gfs2/meta_io.c
+++ test-2.6.23-rc4-mm1/fs/gfs2/meta_io.c
@@ -20,6 +20,7 @@
 #include <linux/bio.h>
 #include <linux/gfs2_ondisk.h>
 #include <linux/lm_interface.h>
+#include <linux/mm_inline.h>
 
 #include "gfs2.h"
 #include "incore.h"
@@ -388,7 +389,7 @@ void gfs2_meta_wipe(struct gfs2_inode *i
 			if (test_clear_buffer_pinned(bh)) {
 				struct gfs2_trans *tr = current->journal_info;
 				struct gfs2_inode *bh_ip =
-					GFS2_I(bh->b_page->mapping->host);
+					GFS2_I(page_inode(bh->b_page));
 
 				gfs2_log_lock(sdp);
 				list_del_init(&bd->bd_le.le_list);
Index: test-2.6.23-rc4-mm1/fs/gfs2/ops_address.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/gfs2/ops_address.c
+++ test-2.6.23-rc4-mm1/fs/gfs2/ops_address.c
@@ -20,6 +20,7 @@
 #include <linux/swap.h>
 #include <linux/gfs2_ondisk.h>
 #include <linux/lm_interface.h>
+#include <linux/mm_inline.h>
 
 #include "gfs2.h"
 #include "incore.h"
@@ -114,7 +115,7 @@ static int gfs2_get_block_direct(struct 
 
 static int gfs2_writepage(struct page *page, struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct gfs2_inode *ip = GFS2_I(inode);
 	struct gfs2_sbd *sdp = GFS2_SB(inode);
 	loff_t i_size = i_size_read(inode);
@@ -133,7 +134,7 @@ static int gfs2_writepage(struct page *p
 	/* Is the page fully outside i_size? (truncate in progress) */
         offset = i_size & (PAGE_CACHE_SIZE-1);
 	if (page->index > end_index || (page->index == end_index && !offset)) {
-		page->mapping->a_ops->invalidatepage(page, 0);
+		page_mapping(page)->a_ops->invalidatepage(page, 0);
 		unlock_page(page);
 		return 0; /* don't care */
 	}
@@ -241,8 +242,8 @@ static int stuffed_readpage(struct gfs2_
 
 static int gfs2_readpage(struct file *file, struct page *page)
 {
-	struct gfs2_inode *ip = GFS2_I(page->mapping->host);
-	struct gfs2_sbd *sdp = GFS2_SB(page->mapping->host);
+	struct gfs2_inode *ip = GFS2_I(page_inode(page));
+	struct gfs2_sbd *sdp = GFS2_SB(page_inode(page));
 	struct gfs2_file *gf = NULL;
 	struct gfs2_holder gh;
 	int error;
@@ -560,7 +561,7 @@ static int gfs2_write_end(struct file *f
 			  loff_t pos, unsigned len, unsigned copied,
 			  struct page *page, void *fsdata)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct gfs2_inode *ip = GFS2_I(inode);
 	struct gfs2_sbd *sdp = GFS2_SB(inode);
 	struct buffer_head *dibh;
@@ -624,8 +625,8 @@ failed:
  
 static int gfs2_set_page_dirty(struct page *page)
 {
-	struct gfs2_inode *ip = GFS2_I(page->mapping->host);
-	struct gfs2_sbd *sdp = GFS2_SB(page->mapping->host);
+	struct gfs2_inode *ip = GFS2_I(page_inode(page));
+	struct gfs2_sbd *sdp = GFS2_SB(page_inode(page));
 
 	if (sdp->sd_args.ar_data == GFS2_DATA_ORDERED || gfs2_is_jdata(ip))
 		SetPageChecked(page);
@@ -746,7 +747,7 @@ out:
 
 int gfs2_releasepage(struct page *page, gfp_t gfp_mask)
 {
-	struct inode *aspace = page->mapping->host;
+	struct inode *aspace = page_inode(page);
 	struct gfs2_sbd *sdp = aspace->i_sb->s_fs_info;
 	struct buffer_head *bh, *head;
 	struct gfs2_bufdata *bd;
Index: test-2.6.23-rc4-mm1/fs/hfs/inode.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/hfs/inode.c
+++ test-2.6.23-rc4-mm1/fs/hfs/inode.c
@@ -14,6 +14,7 @@
 #include <linux/pagemap.h>
 #include <linux/mpage.h>
 #include <linux/sched.h>
+#include <linux/mm_inline.h>
 
 #include "hfs_fs.h"
 #include "btree.h"
@@ -52,7 +53,7 @@ static sector_t hfs_bmap(struct address_
 
 static int hfs_releasepage(struct page *page, gfp_t mask)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct super_block *sb = inode->i_sb;
 	struct hfs_btree *tree;
 	struct hfs_bnode *node;
Index: test-2.6.23-rc4-mm1/fs/hfsplus/inode.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/hfsplus/inode.c
+++ test-2.6.23-rc4-mm1/fs/hfsplus/inode.c
@@ -13,6 +13,7 @@
 #include <linux/pagemap.h>
 #include <linux/mpage.h>
 #include <linux/sched.h>
+#include <linux/mm_inline.h>
 
 #include "hfsplus_fs.h"
 #include "hfsplus_raw.h"
@@ -44,7 +45,7 @@ static sector_t hfsplus_bmap(struct addr
 
 static int hfsplus_releasepage(struct page *page, gfp_t mask)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct super_block *sb = inode->i_sb;
 	struct hfs_btree *tree;
 	struct hfs_bnode *node;
Index: test-2.6.23-rc4-mm1/fs/isofs/rock.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/isofs/rock.c
+++ test-2.6.23-rc4-mm1/fs/isofs/rock.c
@@ -9,6 +9,7 @@
 #include <linux/slab.h>
 #include <linux/pagemap.h>
 #include <linux/smp_lock.h>
+#include <linux/mm_inline.h>
 
 #include "isofs.h"
 #include "rock.h"
@@ -640,7 +641,7 @@ int parse_rock_ridge_inode(struct iso_di
  */
 static int rock_ridge_symlink_readpage(struct file *file, struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct iso_inode_info *ei = ISOFS_I(inode);
 	char *link = kmap(page);
 	unsigned long bufsize = ISOFS_BUFFER_SIZE(inode);
Index: test-2.6.23-rc4-mm1/fs/jbd/journal.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/jbd/journal.c
+++ test-2.6.23-rc4-mm1/fs/jbd/journal.c
@@ -1830,7 +1830,7 @@ repeat:
 			if (bh->b_page)
 				printk(KERN_EMERG "%s: "
 						"bh->b_page->mapping=%p\n",
-					__FUNCTION__, bh->b_page->mapping);
+					__FUNCTION__, (void*)bh->b_page->mapping);
 		}
 
 		if (!new_jh) {
Index: test-2.6.23-rc4-mm1/fs/nfs/internal.h
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/nfs/internal.h
+++ test-2.6.23-rc4-mm1/fs/nfs/internal.h
@@ -3,6 +3,7 @@
  */
 
 #include <linux/mount.h>
+#include <linux/mm_inline.h>
 
 struct nfs_string;
 struct nfs_mount_data;
@@ -220,7 +221,7 @@ void nfs_super_set_maxbytes(struct super
 static inline
 unsigned int nfs_page_length(struct page *page)
 {
-	loff_t i_size = i_size_read(page->mapping->host);
+	loff_t i_size = i_size_read(page_inode(page));
 
 	if (i_size > 0) {
 		pgoff_t end_index = (i_size - 1) >> PAGE_CACHE_SHIFT;
Index: test-2.6.23-rc4-mm1/fs/nfs/file.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/nfs/file.c
+++ test-2.6.23-rc4-mm1/fs/nfs/file.c
@@ -357,7 +357,7 @@ static void nfs_invalidate_page(struct p
 	if (offset != 0)
 		return;
 	/* Cancel any unstarted writes on this page */
-	nfs_wb_page_cancel(page->mapping->host, page);
+	nfs_wb_page_cancel(page_inode(page), page);
 }
 
 static int nfs_release_page(struct page *page, gfp_t gfp)
@@ -368,7 +368,7 @@ static int nfs_release_page(struct page 
 
 static int nfs_launder_page(struct page *page)
 {
-	return nfs_wb_page(page->mapping->host, page);
+	return nfs_wb_page(page_inode(page), page);
 }
 
 const struct address_space_operations nfs_file_aops = {
@@ -395,16 +395,16 @@ static int nfs_vm_page_mkwrite(struct vm
 	void *fsdata;
 
 	lock_page(page);
-	if (page->mapping != vma->vm_file->f_path.dentry->d_inode->i_mapping)
+	if (page_mapping(page) != vma->vm_file->f_path.dentry->d_inode->i_mapping)
 		goto out_unlock;
 	pagelen = nfs_page_length(page);
 	if (pagelen == 0)
 		goto out_unlock;
-	ret = nfs_write_begin(filp, page->mapping,
+	ret = nfs_write_begin(filp, page_mapping(page),
 				(loff_t)page->index << PAGE_CACHE_SHIFT,
 				pagelen, 0, &page, &fsdata);
 	if (!ret)
-		ret = nfs_write_end(filp, page->mapping,
+		ret = nfs_write_end(filp, page_mapping(page),
 				(loff_t)page->index << PAGE_CACHE_SHIFT,
 				pagelen, pagelen, page, fsdata);
 out_unlock:
Index: test-2.6.23-rc4-mm1/fs/nfs/pagelist.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/nfs/pagelist.c
+++ test-2.6.23-rc4-mm1/fs/nfs/pagelist.c
@@ -81,7 +81,7 @@ nfs_create_request(struct nfs_open_conte
 	page_cache_get(page);
 	BUG_ON(PagePrivate(page));
 	BUG_ON(!PageLocked(page));
-	BUG_ON(page->mapping->host != inode);
+	BUG_ON(page_inode(page) != inode);
 	req->wb_offset  = offset;
 	req->wb_pgbase	= offset;
 	req->wb_bytes   = count;
Index: test-2.6.23-rc4-mm1/fs/nfs/read.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/nfs/read.c
+++ test-2.6.23-rc4-mm1/fs/nfs/read.c
@@ -466,7 +466,7 @@ static const struct rpc_call_ops nfs_rea
 int nfs_readpage(struct file *file, struct page *page)
 {
 	struct nfs_open_context *ctx;
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	int		error;
 
 	dprintk("NFS: nfs_readpage (%p %ld@%lu)\n",
@@ -517,7 +517,7 @@ static int
 readpage_async_filler(void *data, struct page *page)
 {
 	struct nfs_readdesc *desc = (struct nfs_readdesc *)data;
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct nfs_page *new;
 	unsigned int len;
 	int error;
Index: test-2.6.23-rc4-mm1/fs/nfs/write.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/nfs/write.c
+++ test-2.6.23-rc4-mm1/fs/nfs/write.c
@@ -131,7 +131,7 @@ static struct nfs_page *nfs_page_find_re
 
 static struct nfs_page *nfs_page_find_request(struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct nfs_page *req = NULL;
 
 	spin_lock(&inode->i_lock);
@@ -143,7 +143,7 @@ static struct nfs_page *nfs_page_find_re
 /* Adjust the file length if we're writing beyond the end */
 static void nfs_grow_file(struct page *page, unsigned int offset, unsigned int count)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	loff_t end, i_size = i_size_read(inode);
 	pgoff_t end_index = (i_size - 1) >> PAGE_CACHE_SHIFT;
 
@@ -160,7 +160,7 @@ static void nfs_grow_file(struct page *p
 static void nfs_set_pageerror(struct page *page)
 {
 	SetPageError(page);
-	nfs_zap_mapping(page->mapping->host, page->mapping);
+	nfs_zap_mapping(page_inode(page), page_mapping(page));
 }
 
 /* We can set the PG_uptodate flag if we see that a write request
@@ -192,7 +192,7 @@ static int nfs_writepage_setup(struct nf
 		ret = PTR_ERR(req);
 		if (ret != -EBUSY)
 			return ret;
-		ret = nfs_wb_page(page->mapping->host, page);
+		ret = nfs_wb_page(page_inode(page), page);
 		if (ret != 0)
 			return ret;
 	}
@@ -226,7 +226,7 @@ static int nfs_set_page_writeback(struct
 	int ret = test_set_page_writeback(page);
 
 	if (!ret) {
-		struct inode *inode = page->mapping->host;
+		struct inode *inode = page_inode(page);
 		struct nfs_server *nfss = NFS_SERVER(inode);
 
 		if (atomic_long_inc_return(&nfss->writeback) >
@@ -238,7 +238,7 @@ static int nfs_set_page_writeback(struct
 
 static void nfs_end_page_writeback(struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct nfs_server *nfss = NFS_SERVER(inode);
 
 	end_page_writeback(page);
@@ -255,7 +255,7 @@ static void nfs_end_page_writeback(struc
 static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 				struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_page *req;
 	int ret;
@@ -301,7 +301,7 @@ static int nfs_page_async_flush(struct n
 
 static int nfs_do_writepage(struct page *page, struct writeback_control *wbc, struct nfs_pageio_descriptor *pgio)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGE);
 	nfs_add_stats(inode, NFSIOS_WRITEPAGES, 1);
@@ -318,7 +318,7 @@ static int nfs_writepage_locked(struct p
 	struct nfs_pageio_descriptor pgio;
 	int err;
 
-	nfs_pageio_init_write(&pgio, page->mapping->host, wb_priority(wbc));
+	nfs_pageio_init_write(&pgio, page_inode(page), wb_priority(wbc));
 	err = nfs_do_writepage(page, wbc, &pgio);
 	nfs_pageio_complete(&pgio);
 	if (err < 0)
@@ -585,7 +585,7 @@ static inline int nfs_scan_commit(struct
 static struct nfs_page * nfs_update_request(struct nfs_open_context* ctx,
 		struct page *page, unsigned int offset, unsigned int bytes)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 	struct inode *inode = mapping->host;
 	struct nfs_page		*req, *new = NULL;
 	pgoff_t		rqend, end;
@@ -687,7 +687,7 @@ int nfs_flush_incompatible(struct file *
 		nfs_release_request(req);
 		if (!do_flush)
 			return 0;
-		status = nfs_wb_page(page->mapping->host, page);
+		status = nfs_wb_page(page_inode(page), page);
 	} while (status == 0);
 	return status;
 }
@@ -702,7 +702,7 @@ int nfs_updatepage(struct file *file, st
 		unsigned int offset, unsigned int count)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
-	struct inode	*inode = page->mapping->host;
+	struct inode	*inode = page_inode(page);
 	int		status = 0;
 
 	nfs_inc_stats(inode, NFSIOS_VFSUPDATEPAGE);
@@ -958,7 +958,7 @@ static void nfs_writeback_done_partial(s
 	}
 
 	if (nfs_write_need_commit(data)) {
-		struct inode *inode = page->mapping->host;
+		struct inode *inode = page_inode(page);
 
 		spin_lock(&inode->i_lock);
 		if (test_bit(PG_NEED_RESCHED, &req->wb_flags)) {
@@ -1386,7 +1386,7 @@ int nfs_wb_page_cancel(struct inode *ino
 	loff_t range_start = page_offset(page);
 	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
 	struct writeback_control wbc = {
-		.bdi = page->mapping->backing_dev_info,
+		.bdi = page_mapping(page)->backing_dev_info,
 		.sync_mode = WB_SYNC_ALL,
 		.nr_to_write = LONG_MAX,
 		.range_start = range_start,
@@ -1419,7 +1419,7 @@ int nfs_wb_page_cancel(struct inode *ino
 	}
 	if (!PagePrivate(page))
 		return 0;
-	ret = nfs_sync_mapping_wait(page->mapping, &wbc, FLUSH_INVALIDATE);
+	ret = nfs_sync_mapping_wait(page_mapping(page), &wbc, FLUSH_INVALIDATE);
 out:
 	return ret;
 }
@@ -1429,7 +1429,7 @@ int nfs_wb_page_priority(struct inode *i
 	loff_t range_start = page_offset(page);
 	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
 	struct writeback_control wbc = {
-		.bdi = page->mapping->backing_dev_info,
+		.bdi = page_mapping(page)->backing_dev_info,
 		.sync_mode = WB_SYNC_ALL,
 		.nr_to_write = LONG_MAX,
 		.range_start = range_start,
@@ -1445,7 +1445,7 @@ int nfs_wb_page_priority(struct inode *i
 	}
 	if (!PagePrivate(page))
 		return 0;
-	ret = nfs_sync_mapping_wait(page->mapping, &wbc, how);
+	ret = nfs_sync_mapping_wait(page_mapping(page), &wbc, how);
 	if (ret >= 0)
 		return 0;
 out:
Index: test-2.6.23-rc4-mm1/fs/udf/file.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/udf/file.c
+++ test-2.6.23-rc4-mm1/fs/udf/file.c
@@ -37,13 +37,14 @@
 #include <linux/pagemap.h>
 #include <linux/buffer_head.h>
 #include <linux/aio.h>
+#include <linux/mm_inline.h>
 
 #include "udf_i.h"
 #include "udf_sb.h"
 
 static int udf_adinicb_readpage(struct file *file, struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	char *kaddr;
 
 	BUG_ON(!PageLocked(page));
@@ -61,7 +62,7 @@ static int udf_adinicb_readpage(struct f
 
 static int udf_adinicb_writepage(struct page *page, struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	char *kaddr;
 
 	BUG_ON(!PageLocked(page));
Index: test-2.6.23-rc4-mm1/fs/udf/symlink.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/udf/symlink.c
+++ test-2.6.23-rc4-mm1/fs/udf/symlink.c
@@ -31,6 +31,7 @@
 #include <linux/pagemap.h>
 #include <linux/smp_lock.h>
 #include <linux/buffer_head.h>
+#include <linux/mm_inline.h>
 #include "udf_i.h"
 
 static void udf_pc_to_char(struct super_block *sb, char *from, int fromlen, char *to)
@@ -73,7 +74,7 @@ static void udf_pc_to_char(struct super_
 
 static int udf_symlink_filler(struct file *file, struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct buffer_head *bh = NULL;
 	char *symlink;
 	int err = -EIO;
Index: test-2.6.23-rc4-mm1/fs/affs/affs.h
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/affs/affs.h
+++ test-2.6.23-rc4-mm1/fs/affs/affs.h
@@ -2,6 +2,7 @@
 #include <linux/fs.h>
 #include <linux/buffer_head.h>
 #include <linux/amigaffs.h>
+#include <linux/mm_inline.h>
 
 /* AmigaOS allows file names with up to 30 characters length.
  * Names longer than that will be silently truncated. If you
Index: test-2.6.23-rc4-mm1/fs/affs/file.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/affs/file.c
+++ test-2.6.23-rc4-mm1/fs/affs/file.c
@@ -485,7 +485,7 @@ affs_getemptyblk_ino(struct inode *inode
 static int
 affs_do_readpage_ofs(struct file *file, struct page *page, unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct super_block *sb = inode->i_sb;
 	struct buffer_head *bh;
 	char *data;
@@ -593,7 +593,7 @@ out:
 static int
 affs_readpage_ofs(struct file *file, struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	u32 to;
 	int err;
 
Index: test-2.6.23-rc4-mm1/fs/affs/symlink.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/affs/symlink.c
+++ test-2.6.23-rc4-mm1/fs/affs/symlink.c
@@ -13,7 +13,7 @@
 static int affs_symlink_readpage(struct file *file, struct page *page)
 {
 	struct buffer_head *bh;
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	char *link = kmap(page);
 	struct slink_front *lf;
 	int err;
Index: test-2.6.23-rc4-mm1/fs/afs/file.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/afs/file.c
+++ test-2.6.23-rc4-mm1/fs/afs/file.c
@@ -16,6 +16,7 @@
 #include <linux/fs.h>
 #include <linux/pagemap.h>
 #include <linux/writeback.h>
+#include <linux/mm_inline.h>
 #include "internal.h"
 
 static int afs_readpage(struct file *file, struct page *page);
@@ -145,7 +146,7 @@ static int afs_readpage(struct file *fil
 	off_t offset;
 	int ret;
 
-	inode = page->mapping->host;
+	inode = page_inode(page);
 
 	ASSERT(file != NULL);
 	key = file->private_data;
@@ -253,7 +254,7 @@ static void afs_invalidatepage(struct pa
 
 			ret = 0;
 			if (!PageWriteback(page))
-				ret = page->mapping->a_ops->releasepage(page,
+				ret = page_mapping(page)->a_ops->releasepage(page,
 									0);
 			/* possibly should BUG_ON(!ret); - neilb */
 		}
@@ -277,7 +278,7 @@ static int afs_launder_page(struct page 
  */
 static int afs_releasepage(struct page *page, gfp_t gfp_flags)
 {
-	struct afs_vnode *vnode = AFS_FS_I(page->mapping->host);
+	struct afs_vnode *vnode = AFS_FS_I(page_inode(page));
 	struct afs_writeback *wb;
 
 	_enter("{{%x:%u}[%lu],%lx},%x",
Index: test-2.6.23-rc4-mm1/fs/coda/symlink.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/coda/symlink.c
+++ test-2.6.23-rc4-mm1/fs/coda/symlink.c
@@ -15,6 +15,7 @@
 #include <linux/errno.h>
 #include <linux/pagemap.h>
 #include <linux/smp_lock.h>
+#include <linux/mm_inline.h>
 
 #include <linux/coda.h>
 #include <linux/coda_linux.h>
@@ -23,7 +24,7 @@
 
 static int coda_symlink_filler(struct file *file, struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	int error;
 	struct coda_inode_info *cii;
 	unsigned int len = PAGE_SIZE;
Index: test-2.6.23-rc4-mm1/fs/ecryptfs/mmap.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/ecryptfs/mmap.c
+++ test-2.6.23-rc4-mm1/fs/ecryptfs/mmap.c
@@ -32,6 +32,7 @@
 #include <linux/file.h>
 #include <linux/crypto.h>
 #include <linux/scatterlist.h>
+#include <linux/mm_inline.h>
 #include "ecryptfs_kernel.h"
 
 struct kmem_cache *ecryptfs_lower_page_cache;
@@ -363,7 +364,7 @@ out:
  */
 static int fill_zeros_to_end_of_page(struct page *page, unsigned int to)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	int end_byte_in_page;
 
 	if ((i_size_read(inode) / PAGE_CACHE_SIZE) != page->index)
@@ -411,7 +412,7 @@ static int ecryptfs_prepare_write(struct
 	if (page->index != 0) {
 		loff_t end_of_prev_pg_pos = page_offset(page) - 1;
 
-		if (end_of_prev_pg_pos > i_size_read(page->mapping->host)) {
+		if (end_of_prev_pg_pos > i_size_read(page_inode(page))) {
 			rc = ecryptfs_truncate(file->f_path.dentry,
 					       end_of_prev_pg_pos);
 			if (rc) {
@@ -421,7 +422,7 @@ static int ecryptfs_prepare_write(struct
 				goto out;
 			}
 		}
-		if (end_of_prev_pg_pos + 1 > i_size_read(page->mapping->host))
+		if (end_of_prev_pg_pos + 1 > i_size_read(page_inode(page)))
 			zero_user_page(page, 0, PAGE_CACHE_SIZE, KM_USER0);
 	}
 out:
@@ -683,7 +684,7 @@ static int ecryptfs_commit_write(struct 
 	struct ecryptfs_crypt_stat *crypt_stat;
 	int rc;
 
-	inode = page->mapping->host;
+	inode = page_inode(page);
 	lower_inode = ecryptfs_inode_to_lower(inode);
 	lower_file = ecryptfs_file_to_lower(file);
 	mutex_lock(&lower_inode->i_mutex);
@@ -805,7 +806,7 @@ static void ecryptfs_sync_page(struct pa
 	struct inode *lower_inode;
 	struct page *lower_page;
 
-	inode = page->mapping->host;
+	inode = page_inode(page);
 	lower_inode = ecryptfs_inode_to_lower(inode);
 	/* NOTE: Recently swapped with grab_cache_page(), since
 	 * sync_page() just makes sure that pending I/O gets done. */
@@ -814,8 +815,8 @@ static void ecryptfs_sync_page(struct pa
 		ecryptfs_printk(KERN_DEBUG, "find_lock_page failed\n");
 		return;
 	}
-	if (lower_page->mapping->a_ops->sync_page)
-		lower_page->mapping->a_ops->sync_page(lower_page);
+	if (page_mapping(lower_page)->a_ops->sync_page)
+		page_mapping(lower_page)->a_ops->sync_page(lower_page);
 	ecryptfs_printk(KERN_DEBUG, "Unlocking page with index = [0x%.16x]\n",
 			lower_page->index);
 	unlock_page(lower_page);
Index: test-2.6.23-rc4-mm1/fs/efs/symlink.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/efs/symlink.c
+++ test-2.6.23-rc4-mm1/fs/efs/symlink.c
@@ -11,12 +11,13 @@
 #include <linux/pagemap.h>
 #include <linux/buffer_head.h>
 #include <linux/smp_lock.h>
+#include <linux/mm_inline.h>
 
 static int efs_symlink_readpage(struct file *file, struct page *page)
 {
 	char *link = kmap(page);
 	struct buffer_head * bh;
-	struct inode * inode = page->mapping->host;
+	struct inode * inode = page_inode(page);
 	efs_block_t size = inode->i_size;
 	int err;
   
Index: test-2.6.23-rc4-mm1/mm/swap_state.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/mm/swap_state.c
+++ test-2.6.23-rc4-mm1/mm/swap_state.c
@@ -45,6 +45,11 @@ struct address_space swapper_space = {
 	.backing_dev_info = &swap_backing_dev_info,
 };
 
+/*
+ * inline function page_mapping() has ref to &swapper_space.
+ */
+EXPORT_SYMBOL(swapper_space);
+
 #define INC_CACHE_INFO(x)	do { swap_cache_info.x++; } while (0)
 
 static struct {
Index: test-2.6.23-rc4-mm1/fs/ecryptfs/crypto.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/ecryptfs/crypto.c
+++ test-2.6.23-rc4-mm1/fs/ecryptfs/crypto.c
@@ -33,6 +33,7 @@
 #include <linux/crypto.h>
 #include <linux/file.h>
 #include <linux/scatterlist.h>
+#include <linux/mm_inline.h>
 #include "ecryptfs_kernel.h"
 
 static int
@@ -504,8 +505,8 @@ int ecryptfs_encrypt_page(struct ecryptf
 #define ECRYPTFS_PAGE_STATE_WRITTEN   3
 	int page_state;
 
-	lower_inode = ecryptfs_inode_to_lower(ctx->page->mapping->host);
-	inode_info = ecryptfs_inode_to_private(ctx->page->mapping->host);
+	lower_inode = ecryptfs_inode_to_lower(page_inode(ctx->page));
+	inode_info = ecryptfs_inode_to_private(page_inode(ctx->page));
 	crypt_stat = &inode_info->crypt_stat;
 	if (!(crypt_stat->flags & ECRYPTFS_ENCRYPTED)) {
 		rc = ecryptfs_copy_page_to_lower(ctx->page, lower_inode,
@@ -637,8 +638,8 @@ int ecryptfs_decrypt_page(struct file *f
 	int page_state;
 
 	crypt_stat = &(ecryptfs_inode_to_private(
-			       page->mapping->host)->crypt_stat);
-	lower_inode = ecryptfs_inode_to_lower(page->mapping->host);
+			       page_inode(page))->crypt_stat);
+	lower_inode = ecryptfs_inode_to_lower(page_inode(page));
 	if (!(crypt_stat->flags & ECRYPTFS_ENCRYPTED)) {
 		rc = ecryptfs_do_readpage(file, page, page->index);
 		if (rc)
Index: test-2.6.23-rc4-mm1/fs/ext4/inode.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/ext4/inode.c
+++ test-2.6.23-rc4-mm1/fs/ext4/inode.c
@@ -36,6 +36,7 @@
 #include <linux/mpage.h>
 #include <linux/uio.h>
 #include <linux/bio.h>
+#include <linux/mm_inline.h>
 #include "xattr.h"
 #include "acl.h"
 
@@ -1482,7 +1483,7 @@ static int jbd2_journal_dirty_data_fn(ha
 static int ext4_ordered_writepage(struct page *page,
 				struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct buffer_head *page_bufs;
 	handle_t *handle = NULL;
 	int ret = 0;
@@ -1548,7 +1549,7 @@ out_fail:
 static int ext4_writeback_writepage(struct page *page,
 				struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	handle_t *handle = NULL;
 	int ret = 0;
 	int err;
@@ -1581,7 +1582,7 @@ out_fail:
 static int ext4_journalled_writepage(struct page *page,
 				struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	handle_t *handle = NULL;
 	int ret = 0;
 	int err;
@@ -1651,7 +1652,7 @@ ext4_readpages(struct file *file, struct
 
 static void ext4_invalidatepage(struct page *page, unsigned long offset)
 {
-	journal_t *journal = EXT4_JOURNAL(page->mapping->host);
+	journal_t *journal = EXT4_JOURNAL(page_inode(page));
 
 	/*
 	 * If it's a full truncate we just forget about the pending dirtying
@@ -1664,7 +1665,7 @@ static void ext4_invalidatepage(struct p
 
 static int ext4_releasepage(struct page *page, gfp_t wait)
 {
-	journal_t *journal = EXT4_JOURNAL(page->mapping->host);
+	journal_t *journal = EXT4_JOURNAL(page_inode(page));
 
 	WARN_ON(PageChecked(page));
 	if (!page_has_buffers(page))
Index: test-2.6.23-rc4-mm1/fs/fuse/file.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/fuse/file.c
+++ test-2.6.23-rc4-mm1/fs/fuse/file.c
@@ -12,6 +12,7 @@
 #include <linux/slab.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
+#include <linux/mm_inline.h>
 
 static const struct file_operations fuse_direct_io_file_operations;
 
@@ -310,7 +311,7 @@ static size_t fuse_send_read(struct fuse
 
 static int fuse_readpage(struct file *file, struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct fuse_conn *fc = get_fuse_conn(inode);
 	struct fuse_req *req;
 	int err;
@@ -342,7 +343,7 @@ static void fuse_readpages_end(struct fu
 {
 	int i;
 
-	fuse_invalidate_attr(req->pages[0]->mapping->host); /* atime changed */
+	fuse_invalidate_attr(page_inode(req->pages[0])); /* atime changed */
 
 	for (i = 0; i < req->num_pages; i++) {
 		struct page *page = req->pages[i];
Index: test-2.6.23-rc4-mm1/fs/ext4/writeback.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/ext4/writeback.c
+++ test-2.6.23-rc4-mm1/fs/ext4/writeback.c
@@ -51,6 +51,7 @@
 #include <linux/pagevec.h>
 #include <linux/backing-dev.h>
 #include <linux/spinlock.h>
+#include <linux/mm_inline.h>
 
 /*
  * If EXT4_WB_STATS is defined, then some stats are collected.
@@ -175,7 +176,7 @@ static struct bio *ext4_wb_bio_submit(st
 
 int inline ext4_wb_reserve_space_page(struct page *page, int blocks)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	int total, mdb, err;
 
 	wb_debug("reserve %d blocks for page %lu from inode %lu\n",
@@ -263,7 +264,7 @@ static inline int ext4_wb_drop_page_rese
 	 * reserved blocks. we could release reserved blocks right
 	 * now, but I'd prefer to make this once per several blocks */
 	wb_debug("drop reservation from page %lu from inode %lu\n",
-			page->index, page->mapping->host->i_ino);
+			page->index, page_inode(page)->i_ino);
 	BUG_ON(!PageBooked(page));
 	ClearPageBooked(page);
 	return 0;
@@ -711,7 +712,7 @@ int ext4_wb_writepages(struct address_sp
 			if (wbc->sync_mode != WB_SYNC_NONE)
 				wait_on_page_writeback(page);
 
-			if (page->mapping != mapping) {
+			if (page_mapping(page) != mapping) {
 				unlock_page(page);
 				continue;
 			}
@@ -853,12 +854,12 @@ static void ext4_wb_clear_page(struct pa
 int ext4_wb_prepare_write(struct file *file, struct page *page,
 			      unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct buffer_head bh, *bhw = &bh;
 	int err = 0;
 
 	wb_debug("prepare page %lu (%u-%u) for inode %lu\n",
-			page->index, from, to, page->mapping->host->i_ino);
+			page->index, from, to, page_inode(page)->i_ino);
 
 	/* if page is uptodate this means that ->prepare_write() has
 	 * been called on page before and page is mapped to disk or
@@ -912,7 +913,7 @@ int ext4_wb_commit_write(struct file *fi
 			     unsigned from, unsigned to)
 {
 	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	int err = 0;
 
 	wb_debug("commit page %lu (%u-%u) for inode %lu\n",
@@ -952,7 +953,7 @@ int ext4_wb_commit_write(struct file *fi
 int ext4_wb_write_single_page(struct page *page,
 					struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct ext4_wb_control wc;
 	int err;
 
@@ -964,7 +965,7 @@ int ext4_wb_write_single_page(struct pag
 		atomic_inc(&EXT4_SB(inode->i_sb)->s_wb_collisions_sp);
 #endif
 
-	ext4_wb_init_control(&wc, page->mapping);
+	ext4_wb_init_control(&wc, page_mapping(page));
 
 	BUG_ON(PageWriteback(page));
 	set_page_writeback(page);
@@ -988,7 +989,7 @@ int ext4_wb_write_single_page(struct pag
 
 int ext4_wb_writepage(struct page *page, struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	loff_t i_size = i_size_read(inode);
 	pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
 	unsigned offset;
@@ -1002,7 +1003,7 @@ int ext4_wb_writepage(struct page *page,
 	 * hasn't space on a disk yet, leave it for that thread
 	 */
 #if 1
-	if (atomic_read(&EXT4_I(page->mapping->host)->i_wb_writers)
+	if (atomic_read(&EXT4_I(page_inode(page))->i_wb_writers)
 			&& !PageMappedToDisk(page)) {
 		__set_page_dirty_nobuffers(page);
 		unlock_page(page);
@@ -1054,7 +1055,7 @@ int ext4_wb_releasepage(struct page *pag
 	wb_debug("release %sM%sR page %lu from inode %lu (wait %d)\n",
 			PageMappedToDisk(page) ? "" : "!",
 			PageBooked(page) ? "" : "!",
-			page->index, page->mapping->host->i_ino, wait);
+			page->index, page_inode(page)->i_ino, wait);
 
 	if (PageWriteback(page))
 		return 0;
@@ -1066,7 +1067,7 @@ int ext4_wb_releasepage(struct page *pag
 
 void ext4_wb_invalidatepage(struct page *page, unsigned long offset)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	int ret = 0;
 
 	/* ->invalidatepage() is called when page is marked Private.
Index: test-2.6.23-rc4-mm1/fs/hpfs/namei.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/hpfs/namei.c
+++ test-2.6.23-rc4-mm1/fs/hpfs/namei.c
@@ -6,6 +6,9 @@
  *  adding & removing files & directories
  */
 #include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/fs.h>
+#include <linux/mm_inline.h>
 #include "hpfs_fn.h"
 
 static int hpfs_mkdir(struct inode *dir, struct dentry *dentry, int mode)
@@ -511,7 +514,7 @@ out:
 static int hpfs_symlink_readpage(struct file *file, struct page *page)
 {
 	char *link = kmap(page);
-	struct inode *i = page->mapping->host;
+	struct inode *i = page_inode(page);
 	struct fnode *fnode;
 	struct buffer_head *bh;
 	int err;
Index: test-2.6.23-rc4-mm1/fs/jffs2/file.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/jffs2/file.c
+++ test-2.6.23-rc4-mm1/fs/jffs2/file.c
@@ -17,6 +17,7 @@
 #include <linux/highmem.h>
 #include <linux/crc32.h>
 #include <linux/jffs2.h>
+#include <linux/mm_inline.h>
 #include "nodelist.h"
 
 static int jffs2_write_end(struct file *filp, struct address_space *mapping,
@@ -111,11 +112,11 @@ int jffs2_do_readpage_unlock(struct inod
 
 static int jffs2_readpage (struct file *filp, struct page *pg)
 {
-	struct jffs2_inode_info *f = JFFS2_INODE_INFO(pg->mapping->host);
+	struct jffs2_inode_info *f = JFFS2_INODE_INFO(page_inode(pg));
 	int ret;
 
 	down(&f->sem);
-	ret = jffs2_do_readpage_unlock(pg->mapping->host, pg);
+	ret = jffs2_do_readpage_unlock(page_inode(pg), pg);
 	up(&f->sem);
 	return ret;
 }
Index: test-2.6.23-rc4-mm1/fs/minix/dir.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/minix/dir.c
+++ test-2.6.23-rc4-mm1/fs/minix/dir.c
@@ -52,7 +52,7 @@ static inline unsigned long dir_pages(st
 
 static int dir_commit_chunk(struct page *page, loff_t pos, unsigned len)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 	struct inode *dir = mapping->host;
 	int err = 0;
 	block_write_end(NULL, mapping, pos, len, len, page, NULL);
@@ -281,7 +281,7 @@ int minix_add_link(struct dentry *dentry
 
 got_it:
 	pos = (page->index >> PAGE_CACHE_SHIFT) + p - (char*)page_address(page);
-	err = __minix_write_begin(NULL, page->mapping, pos, sbi->s_dirsize,
+	err = __minix_write_begin(NULL, page_mapping(page), pos, sbi->s_dirsize,
 					AOP_FLAG_UNINTERRUPTIBLE, &page, NULL);
 	if (err)
 		goto out_unlock;
@@ -307,7 +307,7 @@ out_unlock:
 
 int minix_delete_entry(struct minix_dir_entry *de, struct page *page)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 	struct inode *inode = (struct inode*)mapping->host;
 	char *kaddr = page_address(page);
 	loff_t pos = page_offset(page) + (char*)de - kaddr;
@@ -431,7 +431,7 @@ not_empty:
 void minix_set_link(struct minix_dir_entry *de, struct page *page,
 	struct inode *inode)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 	struct inode *dir = mapping->host;
 	struct minix_sb_info *sbi = minix_sb(dir->i_sb);
 	loff_t pos = page_offset(page) +
Index: test-2.6.23-rc4-mm1/fs/jfs/jfs_metapage.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/jfs/jfs_metapage.c
+++ test-2.6.23-rc4-mm1/fs/jfs/jfs_metapage.c
@@ -23,6 +23,7 @@
 #include <linux/init.h>
 #include <linux/buffer_head.h>
 #include <linux/mempool.h>
+#include <linux/mm_inline.h>
 #include "jfs_incore.h"
 #include "jfs_superblock.h"
 #include "jfs_filsys.h"
@@ -113,7 +114,7 @@ static inline int insert_metapage(struct
 	}
 
 	if (mp) {
-		l2mp_blocks = L2PSIZE - page->mapping->host->i_blkbits;
+		l2mp_blocks = L2PSIZE - page_inode(page)->i_blkbits;
 		index = (mp->index >> l2mp_blocks) & (MPS_PER_PAGE - 1);
 		a->mp_count++;
 		a->mp[index] = mp;
@@ -125,7 +126,7 @@ static inline int insert_metapage(struct
 static inline void remove_metapage(struct page *page, struct metapage *mp)
 {
 	struct meta_anchor *a = mp_anchor(page);
-	int l2mp_blocks = L2PSIZE - page->mapping->host->i_blkbits;
+	int l2mp_blocks = L2PSIZE - page_inode(page)->i_blkbits;
 	int index;
 
 	index = (mp->index >> l2mp_blocks) & (MPS_PER_PAGE - 1);
@@ -364,7 +365,7 @@ static int metapage_writepage(struct pag
 {
 	struct bio *bio = NULL;
 	unsigned int block_offset;	/* block offset of mp within page */
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	unsigned int blocks_per_mp = JFS_SBI(inode->i_sb)->nbperpage;
 	unsigned int len;
 	unsigned int xlen;
@@ -484,7 +485,7 @@ skip:
 
 static int metapage_readpage(struct file *fp, struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct bio *bio = NULL;
 	unsigned int block_offset;
 	unsigned int blocks_per_page = PAGE_CACHE_SIZE >> inode->i_blkbits;
Index: test-2.6.23-rc4-mm1/fs/ncpfs/symlink.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/ncpfs/symlink.c
+++ test-2.6.23-rc4-mm1/fs/ncpfs/symlink.c
@@ -29,6 +29,7 @@
 #include <linux/time.h>
 #include <linux/mm.h>
 #include <linux/stat.h>
+#include <linux/mm_inline.h>
 #include "ncplib_kernel.h"
 
 
@@ -42,7 +43,7 @@
 
 static int ncp_symlink_readpage(struct file *file, struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	int error, length, len;
 	char *link, *rawlink;
 	char *buf = kmap(page);
Index: test-2.6.23-rc4-mm1/fs/ntfs/aops.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/ntfs/aops.c
+++ test-2.6.23-rc4-mm1/fs/ntfs/aops.c
@@ -29,6 +29,7 @@
 #include <linux/buffer_head.h>
 #include <linux/writeback.h>
 #include <linux/bit_spinlock.h>
+#include <linux/mm_inline.h>
 
 #include "aops.h"
 #include "attrib.h"
@@ -65,7 +66,7 @@ static void ntfs_end_buffer_async_read(s
 	int page_uptodate = 1;
 
 	page = bh->b_page;
-	vi = page->mapping->host;
+	vi = page_inode(page);
 	ni = NTFS_I(vi);
 
 	if (likely(uptodate)) {
@@ -194,7 +195,7 @@ static int ntfs_read_block(struct page *
 	int i, nr;
 	unsigned char blocksize_bits;
 
-	vi = page->mapping->host;
+	vi = page_inode(page);
 	ni = NTFS_I(vi);
 	vol = ni->vol;
 
@@ -413,7 +414,7 @@ retry_readpage:
 		unlock_page(page);
 		return 0;
 	}
-	vi = page->mapping->host;
+	vi = page_inode(page);
 	ni = NTFS_I(vi);
 	/*
 	 * Only $DATA attributes can be encrypted and only unnamed $DATA
@@ -553,7 +554,7 @@ static int ntfs_write_block(struct page 
 	bool need_end_writeback;
 	unsigned char blocksize_bits;
 
-	vi = page->mapping->host;
+	vi = page_inode(page);
 	ni = NTFS_I(vi);
 	vol = ni->vol;
 
@@ -909,7 +910,7 @@ static int ntfs_write_mst_block(struct p
 		struct writeback_control *wbc)
 {
 	sector_t block, dblock, rec_block;
-	struct inode *vi = page->mapping->host;
+	struct inode *vi = page_inode(page);
 	ntfs_inode *ni = NTFS_I(vi);
 	ntfs_volume *vol = ni->vol;
 	u8 *kaddr;
@@ -1342,7 +1343,7 @@ done:
 static int ntfs_writepage(struct page *page, struct writeback_control *wbc)
 {
 	loff_t i_size;
-	struct inode *vi = page->mapping->host;
+	struct inode *vi = page_inode(page);
 	ntfs_inode *base_ni = NULL, *ni = NTFS_I(vi);
 	char *kaddr;
 	ntfs_attr_search_ctx *ctx = NULL;
@@ -1579,7 +1580,7 @@ const struct address_space_operations nt
  * need the lock since try_to_free_buffers() does not free dirty buffers.
  */
 void mark_ntfs_record_dirty(struct page *page, const unsigned int ofs) {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 	ntfs_inode *ni = NTFS_I(mapping->host);
 	struct buffer_head *bh, *head, *buffers_to_free = NULL;
 	unsigned int end, bh_size, bh_ofs;
Index: test-2.6.23-rc4-mm1/fs/ntfs/file.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/ntfs/file.c
+++ test-2.6.23-rc4-mm1/fs/ntfs/file.c
@@ -26,6 +26,7 @@
 #include <linux/swap.h>
 #include <linux/uio.h>
 #include <linux/writeback.h>
+#include <linux/mm_inline.h>
 
 #include <asm/page.h>
 #include <asm/uaccess.h>
@@ -520,7 +521,7 @@ static int ntfs_prepare_pages_for_non_re
 	BUG_ON(!nr_pages);
 	BUG_ON(!pages);
 	BUG_ON(!*pages);
-	vi = pages[0]->mapping->host;
+	vi = page_inode(pages[0]);
 	ni = NTFS_I(vi);
 	vol = ni->vol;
 	ntfs_debug("Entering for inode 0x%lx, attribute type 0x%x, start page "
@@ -1494,7 +1495,7 @@ static inline int ntfs_commit_pages_afte
 	unsigned blocksize, u;
 	int err;
 
-	vi = pages[0]->mapping->host;
+	vi = page_inode(pages[0]);
 	ni = NTFS_I(vi);
 	blocksize = vi->i_sb->s_blocksize;
 	end = pos + bytes;
@@ -1654,7 +1655,7 @@ static int ntfs_commit_pages_after_write
 	BUG_ON(!pages);
 	page = pages[0];
 	BUG_ON(!page);
-	vi = page->mapping->host;
+	vi = page_inode(page);
 	ni = NTFS_I(vi);
 	ntfs_debug("Entering for inode 0x%lx, attribute type 0x%x, start page "
 			"index 0x%lx, nr_pages 0x%x, pos 0x%llx, bytes 0x%zx.",
Index: test-2.6.23-rc4-mm1/fs/ocfs2/aops.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/ocfs2/aops.c
+++ test-2.6.23-rc4-mm1/fs/ocfs2/aops.c
@@ -26,6 +26,7 @@
 #include <asm/byteorder.h>
 #include <linux/swap.h>
 #include <linux/pipe_fs_i.h>
+#include <linux/mm_inline.h>
 
 #define MLOG_MASK_PREFIX ML_FILE_IO
 #include <cluster/masklog.h>
@@ -208,7 +209,7 @@ bail:
 
 static int ocfs2_readpage(struct file *file, struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	loff_t start = (loff_t)page->index << PAGE_CACHE_SHIFT;
 	int ret, unlock = 1;
 
@@ -540,14 +541,14 @@ static void ocfs2_dio_end_io(struct kioc
  */
 static void ocfs2_invalidatepage(struct page *page, unsigned long offset)
 {
-	journal_t *journal = OCFS2_SB(page->mapping->host->i_sb)->journal->j_journal;
+	journal_t *journal = OCFS2_SB(page_inode(page)->i_sb)->journal->j_journal;
 
 	journal_invalidatepage(journal, page, offset);
 }
 
 static int ocfs2_releasepage(struct page *page, gfp_t wait)
 {
-	journal_t *journal = OCFS2_SB(page->mapping->host->i_sb)->journal->j_journal;
+	journal_t *journal = OCFS2_SB(page_inode(page)->i_sb)->journal->j_journal;
 
 	if (!page_has_buffers(page))
 		return 0;
@@ -1065,7 +1066,7 @@ static int ocfs2_grab_pages_for_write(st
 			 */
 			lock_page(mmap_page);
 
-			if (mmap_page->mapping != mapping) {
+			if (page_mapping(mmap_page) != mapping) {
 				unlock_page(mmap_page);
 				/*
 				 * Sanity check - the locking in
Index: test-2.6.23-rc4-mm1/fs/romfs/inode.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/romfs/inode.c
+++ test-2.6.23-rc4-mm1/fs/romfs/inode.c
@@ -75,6 +75,7 @@
 #include <linux/smp_lock.h>
 #include <linux/buffer_head.h>
 #include <linux/vfs.h>
+#include <linux/mm_inline.h>
 
 #include <asm/uaccess.h>
 
@@ -417,7 +418,7 @@ out:	unlock_kernel();
 static int
 romfs_readpage(struct file *file, struct page * page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	loff_t offset, avail, readlen;
 	void *buf;
 	int result = -EIO;
Index: test-2.6.23-rc4-mm1/fs/reiser4/jnode.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/jnode.c
+++ test-2.6.23-rc4-mm1/fs/reiser4/jnode.c
@@ -594,7 +594,7 @@ static jnode *do_jget(reiser4_tree * tre
 	 */
 
 	jnode *result;
-	oid_t oid = get_inode_oid(pg->mapping->host);
+	oid_t oid = get_inode_oid(page_inode(pg));
 
 	assert("umka-176", pg != NULL);
 	assert("nikita-2394", PageLocked(pg));
@@ -606,18 +606,18 @@ static jnode *do_jget(reiser4_tree * tre
 	tree = reiser4_tree_by_page(pg);
 
 	/* check hash-table first */
-	result = jfind(pg->mapping, pg->index);
+	result = jfind(page_mapping(pg), pg->index);
 	if (unlikely(result != NULL)) {
 		spin_lock_jnode(result);
 		jnode_attach_page(result, pg);
 		spin_unlock_jnode(result);
-		result->key.j.mapping = pg->mapping;
+		result->key.j.mapping = page_mapping(pg);
 		return result;
 	}
 
 	/* since page is locked, jnode should be allocated with GFP_NOFS flag */
 	reiser4_ctx_gfp_mask_force(GFP_NOFS);
-	result = find_get_jnode(tree, pg->mapping, oid, pg->index);
+	result = find_get_jnode(tree, page_mapping(pg), oid, pg->index);
 	if (unlikely(IS_ERR(result)))
 		return result;
 	/* attach jnode to page */
@@ -646,13 +646,13 @@ jnode *jnode_of_page(struct page * pg)
 			assert("nikita-2364",
 			       jprivate(pg)->key.j.index == pg->index);
 			assert("nikita-2367",
-			       jprivate(pg)->key.j.mapping == pg->mapping);
+			       jprivate(pg)->key.j.mapping == page_mapping(pg));
 			assert("nikita-2365",
 			       jprivate(pg)->key.j.objectid ==
-			       get_inode_oid(pg->mapping->host));
+			       get_inode_oid(page_inode(pg)));
 			assert("vs-1200",
 			       jprivate(pg)->key.j.objectid ==
-			       pg->mapping->host->i_ino);
+			       page_inode(pg)->i_ino);
 			assert("nikita-2356",
 			       jnode_is_unformatted(jnode_by_page(pg)));
 		}
@@ -812,7 +812,7 @@ static struct page *jnode_get_page_locke
 		page_cache_get(page);
 		spin_unlock_jnode(node);
 		lock_page(page);
-		assert("nikita-3134", page->mapping == jnode_get_mapping(node));
+		assert("nikita-3134", page_mapping(page) == jnode_get_mapping(node));
 	}
 
 	spin_lock_jnode(node);
Index: test-2.6.23-rc4-mm1/fs/ocfs2/mmap.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/ocfs2/mmap.c
+++ test-2.6.23-rc4-mm1/fs/ocfs2/mmap.c
@@ -112,7 +112,7 @@ static int __ocfs2_page_mkwrite(struct i
 	 * page mapping after taking the page lock inside of
 	 * ocfs2_write_begin_nolock().
 	 */
-	if (!PageUptodate(page) || page->mapping != inode->i_mapping) {
+	if (!PageUptodate(page) || page_mapping(page) != inode->i_mapping) {
 		ret = -EINVAL;
 		goto out;
 	}
Index: test-2.6.23-rc4-mm1/fs/reiser4/plugin/cluster.h
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/plugin/cluster.h
+++ test-2.6.23-rc4-mm1/fs/reiser4/plugin/cluster.h
@@ -92,9 +92,9 @@ static inline unsigned off_to_cloff(loff
 static inline  pgoff_t offset_in_clust(struct page * page)
 {
 	assert("edward-1488", page != NULL);
-	assert("edward-1489", page->mapping != NULL);
+	assert("edward-1489", page->mapping != 0);
 
-	return page_index(page) & ((cluster_nrpages(page->mapping->host)) - 1);
+	return page_index(page) & ((cluster_nrpages(page_inode(page))) - 1);
 }
 
 static inline int first_page_in_cluster(struct page * page)
@@ -105,7 +105,7 @@ static inline int first_page_in_cluster(
 static inline int last_page_in_cluster(struct page * page)
 {
 	return offset_in_clust(page) ==
-		cluster_nrpages(page->mapping->host) - 1;
+		cluster_nrpages(page_inode(page)) - 1;
 }
 
 static inline unsigned
@@ -200,11 +200,11 @@ static inline int same_page_cluster(stru
 {
 	assert("edward-1490", p1 != NULL);
 	assert("edward-1491", p2 != NULL);
-	assert("edward-1492", p1->mapping != NULL);
-	assert("edward-1493", p2->mapping != NULL);
+	assert("edward-1492", p1->mapping != 0);
+	assert("edward-1493", p2->mapping != 0);
 
-	return (pg_to_clust(page_index(p1), p1->mapping->host) ==
-		pg_to_clust(page_index(p2), p2->mapping->host));
+	return (pg_to_clust(page_index(p1), page_inode(p1)) ==
+		pg_to_clust(page_index(p2), page_inode(p2)));
 }
 
 static inline int cluster_is_complete(struct cluster_handle * clust,
Index: test-2.6.23-rc4-mm1/fs/reiser4/reiser4.h
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/reiser4.h
+++ test-2.6.23-rc4-mm1/fs/reiser4/reiser4.h
@@ -12,6 +12,8 @@
 #include <linux/fs.h>
 #include <linux/hardirq.h>
 #include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/mm_inline.h>
 
 /*
  * reiser4 compilation options.
Index: test-2.6.23-rc4-mm1/fs/reiserfs/inode.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiserfs/inode.c
+++ test-2.6.23-rc4-mm1/fs/reiserfs/inode.c
@@ -18,6 +18,7 @@
 #include <linux/writeback.h>
 #include <linux/quotaops.h>
 #include <linux/swap.h>
+#include <linux/mm_inline.h>
 
 int reiserfs_commit_write(struct file *f, struct page *page,
 			  unsigned from, unsigned to);
@@ -2331,7 +2332,7 @@ static int map_block_for_writepage(struc
 static int reiserfs_write_full_page(struct page *page,
 				    struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	unsigned long end_index = inode->i_size >> PAGE_CACHE_SHIFT;
 	int error = 0;
 	unsigned long block;
@@ -2546,7 +2547,7 @@ static int reiserfs_readpage(struct file
 
 static int reiserfs_writepage(struct page *page, struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	reiserfs_wait_on_write_block(inode->i_sb);
 	return reiserfs_write_full_page(page, wbc);
 }
@@ -2624,7 +2625,7 @@ static int reiserfs_write_begin(struct f
 int reiserfs_prepare_write(struct file *f, struct page *page,
 			   unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	int ret;
 	int old_ref = 0;
 
@@ -2679,7 +2680,7 @@ static int reiserfs_write_end(struct fil
 			      loff_t pos, unsigned len, unsigned copied,
 			      struct page *page, void *fsdata)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	int ret = 0;
 	int update_sd = 0;
 	struct reiserfs_transaction_handle *th;
@@ -2772,7 +2773,7 @@ static int reiserfs_write_end(struct fil
 int reiserfs_commit_write(struct file *f, struct page *page,
 			  unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	loff_t pos = ((loff_t) page->index << PAGE_CACHE_SHIFT) + to;
 	int ret = 0;
 	int update_sd = 0;
@@ -2951,7 +2952,7 @@ static int invalidatepage_can_drop(struc
 static void reiserfs_invalidatepage(struct page *page, unsigned long offset)
 {
 	struct buffer_head *head, *bh, *next;
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	unsigned int curr_off = 0;
 	int ret = 1;
 
@@ -2997,7 +2998,7 @@ static void reiserfs_invalidatepage(stru
 
 static int reiserfs_set_page_dirty(struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	if (reiserfs_file_data_log(inode)) {
 		SetPageChecked(page);
 		return __set_page_dirty_nobuffers(page);
@@ -3016,7 +3017,7 @@ static int reiserfs_set_page_dirty(struc
  */
 static int reiserfs_releasepage(struct page *page, gfp_t unused_gfp_flags)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct reiserfs_journal *j = SB_JOURNAL(inode->i_sb);
 	struct buffer_head *head;
 	struct buffer_head *bh;
Index: test-2.6.23-rc4-mm1/fs/reiserfs/journal.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiserfs/journal.c
+++ test-2.6.23-rc4-mm1/fs/reiserfs/journal.c
@@ -889,7 +889,7 @@ static int write_ordered_buffers(spinloc
 		 * the buffer. We're safe if we write the page one last time
 		 * after freeing the journal header.
 		 */
-		if (buffer_dirty(bh) && unlikely(bh->b_page->mapping == NULL)) {
+		if (buffer_dirty(bh) && unlikely(bh->b_page->mapping == 0)) {
 			spin_unlock(lock);
 			ll_rw_block(WRITE, 1, &bh);
 			spin_lock(lock);
Index: test-2.6.23-rc4-mm1/fs/reiserfs/tail_conversion.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiserfs/tail_conversion.c
+++ test-2.6.23-rc4-mm1/fs/reiserfs/tail_conversion.c
@@ -6,6 +6,7 @@
 #include <linux/pagemap.h>
 #include <linux/buffer_head.h>
 #include <linux/reiserfs_fs.h>
+#include <linux/mm_inline.h>
 
 /* access to tail : when one is going to read tail it must make sure, that is not running.
  direct2indirect and indirect2direct can not run concurrently */
@@ -151,7 +152,7 @@ void reiserfs_unmap_buffer(struct buffer
 	   interested in removing it from per-sb j_dirty_buffers list, to avoid
 	   BUG() on attempt to write not mapped buffer */
 	if ((!list_empty(&bh->b_assoc_buffers) || bh->b_private) && bh->b_page) {
-		struct inode *inode = bh->b_page->mapping->host;
+		struct inode *inode = page_inode(bh->b_page);
 		struct reiserfs_journal *j = SB_JOURNAL(inode->i_sb);
 		spin_lock(&j->j_dirty_buffers_lock);
 		list_del_init(&bh->b_assoc_buffers);
Index: test-2.6.23-rc4-mm1/fs/sysv/dir.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/sysv/dir.c
+++ test-2.6.23-rc4-mm1/fs/sysv/dir.c
@@ -40,7 +40,7 @@ static inline unsigned long dir_pages(st
 
 static int dir_commit_chunk(struct page *page, loff_t pos, unsigned len)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 	struct inode *dir = mapping->host;
 	int err = 0;
 
@@ -221,7 +221,7 @@ got_it:
 	pos = page_offset(page) +
 			(char*)de - (char*)page_address(page);
 	lock_page(page);
-	err = __sysv_write_begin(NULL, page->mapping, pos, SYSV_DIRSIZE,
+	err = __sysv_write_begin(NULL, page_mapping(page), pos, SYSV_DIRSIZE,
 				AOP_FLAG_UNINTERRUPTIBLE, &page, NULL);
 	if (err)
 		goto out_unlock;
@@ -242,7 +242,7 @@ out_unlock:
 
 int sysv_delete_entry(struct sysv_dir_entry *de, struct page *page)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 	struct inode *inode = (struct inode*)mapping->host;
 	char *kaddr = (char*)page_address(page);
 	loff_t pos = page_offset(page) + (char *)de - kaddr;
@@ -344,7 +344,7 @@ not_empty:
 void sysv_set_link(struct sysv_dir_entry *de, struct page *page,
 	struct inode *inode)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 	struct inode *dir = mapping->host;
 	loff_t pos = page_offset(page) +
 			(char *)de-(char*)page_address(page);
Index: test-2.6.23-rc4-mm1/fs/ufs/dir.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/ufs/dir.c
+++ test-2.6.23-rc4-mm1/fs/ufs/dir.c
@@ -20,6 +20,7 @@
 #include <linux/fs.h>
 #include <linux/ufs_fs.h>
 #include <linux/swap.h>
+#include <linux/mm_inline.h>
 
 #include "ufs.h"
 #include "swab.h"
@@ -42,7 +43,7 @@ static inline int ufs_match(struct super
 
 static int ufs_commit_chunk(struct page *page, loff_t pos, unsigned len)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 	struct inode *dir = mapping->host;
 	int err = 0;
 
@@ -95,7 +96,7 @@ void ufs_set_link(struct inode *dir, str
 	int err;
 
 	lock_page(page);
-	err = __ufs_write_begin(NULL, page->mapping, pos, len,
+	err = __ufs_write_begin(NULL, page_mapping(page), pos, len,
 				AOP_FLAG_UNINTERRUPTIBLE, &page, NULL);
 	BUG_ON(err);
 
@@ -111,7 +112,7 @@ void ufs_set_link(struct inode *dir, str
 
 static void ufs_check_page(struct page *page)
 {
-	struct inode *dir = page->mapping->host;
+	struct inode *dir = page_inode(page);
 	struct super_block *sb = dir->i_sb;
 	char *kaddr = page_address(page);
 	unsigned offs, rec_len;
@@ -381,7 +382,7 @@ int ufs_add_link(struct dentry *dentry, 
 got_it:
 	pos = page_offset(page) +
 			(char*)de - (char*)page_address(page);
-	err = __ufs_write_begin(NULL, page->mapping, pos, rec_len,
+	err = __ufs_write_begin(NULL, page_mapping(page), pos, rec_len,
 				AOP_FLAG_UNINTERRUPTIBLE, &page, NULL);
 	if (err)
 		goto out_unlock;
@@ -518,7 +519,7 @@ int ufs_delete_entry(struct inode *inode
 		     struct page * page)
 {
 	struct super_block *sb = inode->i_sb;
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 	char *kaddr = page_address(page);
 	unsigned from = ((char*)dir - kaddr) & ~(UFS_SB(sb)->s_uspi->s_dirblksize - 1);
 	unsigned to = ((char*)dir - kaddr) + fs16_to_cpu(sb, dir->d_reclen);
Index: test-2.6.23-rc4-mm1/fs/reiser4/as_ops.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/as_ops.c
+++ test-2.6.23-rc4-mm1/fs/reiser4/as_ops.c
@@ -64,24 +64,24 @@
 int reiser4_set_page_dirty(struct page *page)
 {
 	/* this page can be unformatted only */
-	assert("vs-1734", (page->mapping &&
-			   page->mapping->host &&
-			   reiser4_get_super_fake(page->mapping->host->i_sb) !=
-			   page->mapping->host
-			   && reiser4_get_cc_fake(page->mapping->host->i_sb) !=
-			   page->mapping->host
-			   && reiser4_get_bitmap_fake(page->mapping->host->i_sb) !=
-			   page->mapping->host));
+	assert("vs-1734", (page_mapping(page) &&
+			   page_inode(page) &&
+			   reiser4_get_super_fake(page_inode(page)->i_sb) !=
+			   page_inode(page)
+			   && reiser4_get_cc_fake(page_inode(page)->i_sb) !=
+			   page_inode(page)
+			   && reiser4_get_bitmap_fake(page_inode(page)->i_sb) !=
+			   page_inode(page)));
 
 	if (!TestSetPageDirty(page)) {
-		struct address_space *mapping = page->mapping;
+		struct address_space *mapping = page_mapping(page);
 
 		if (mapping) {
 			write_lock_irq(&mapping->tree_lock);
 
 			/* check for race with truncate */
 			if (page->mapping) {
-				assert("vs-1652", page->mapping == mapping);
+				assert("vs-1652", page_mapping(page) == mapping);
 				if (mapping_cap_account_dirty(mapping))
 					inc_zone_page_state(page,
 							NR_FILE_DIRTY);
@@ -140,7 +140,7 @@ void reiser4_invalidatepage(struct page 
 
 	assert("nikita-3137", PageLocked(page));
 	assert("nikita-3138", !PageWriteback(page));
-	inode = page->mapping->host;
+	inode = page_inode(page);
 
 	/*
 	 * ->invalidatepage() should only be called for the unformatted
@@ -157,7 +157,7 @@ void reiser4_invalidatepage(struct page 
 		return;
 	assert("vs-1426", PagePrivate(page));
 	assert("vs-1427",
-	       page->mapping == jnode_get_mapping(jnode_by_page(page)));
+	       page_mapping(page) == jnode_get_mapping(jnode_by_page(page)));
 	assert("", jprivate(page) != NULL);
 	assert("", ergo(inode_file_plugin(inode) !=
 			file_plugin_by_id(CRYPTCOMPRESS_FILE_PLUGIN_ID),
@@ -287,8 +287,8 @@ int reiser4_releasepage(struct page *pag
 
 	node = jnode_by_page(page);
 	assert("nikita-2258", node != NULL);
-	assert("reiser4-4", page->mapping != NULL);
-	assert("reiser4-5", page->mapping->host != NULL);
+	assert("reiser4-4", page->mapping != 0);
+	assert("reiser4-5", page_inode(page) != NULL);
 
 	if (PageDirty(page))
 		return 0;
@@ -305,7 +305,7 @@ int reiser4_releasepage(struct page *pag
 	if (jnode_is_releasable(node)) {
 		struct address_space *mapping;
 
-		mapping = page->mapping;
+		mapping = page_mapping(page);
 		jref(node);
 		/* there is no need to synchronize against
 		 * jnode_extent_write() here, because pages seen by
Index: test-2.6.23-rc4-mm1/fs/reiser4/entd.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/entd.c
+++ test-2.6.23-rc4-mm1/fs/reiser4/entd.c
@@ -266,9 +266,9 @@ int write_page_by_ent(struct page *page,
 	struct wbq rq;
 
 	assert("", PageLocked(page));
-	assert("", page->mapping != NULL);
+	assert("", page->mapping != 0);
 
-	sb = page->mapping->host->i_sb;
+	sb = page_inode(page)->i_sb;
 	ent = get_entd_context(sb);
 	assert("", ent && ent->done == 0);
 
@@ -283,7 +283,7 @@ int write_page_by_ent(struct page *page,
 	 * pin inode in memory, unlock page, entd_flush will iput. We can not
 	 * iput here becasue we can not allow delete_inode to be called here
 	 */
-	inode = igrab(page->mapping->host);
+	inode = igrab(page_inode(page));
 	unlock_page(page);
 	if (inode == NULL)
 		/* inode is getting freed */
Index: test-2.6.23-rc4-mm1/fs/reiser4/page_cache.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/page_cache.c
+++ test-2.6.23-rc4-mm1/fs/reiser4/page_cache.c
@@ -312,7 +312,7 @@ void reiser4_wait_page_writeback(struct 
 reiser4_tree *reiser4_tree_by_page(const struct page *page /* page to query */ )
 {
 	assert("nikita-2461", page != NULL);
-	return &get_super_private(page->mapping->host->i_sb)->tree;
+	return &get_super_private(page_inode(page)->i_sb)->tree;
 }
 
 /* completion handler for single page bio-based read.
@@ -400,7 +400,7 @@ int reiser4_page_io(struct page *page, j
 	assert("nikita-2893", rw == READ || rw == WRITE);
 
 	if (rw) {
-		if (unlikely(page->mapping->host->i_sb->s_flags & MS_RDONLY)) {
+		if (unlikely(page_inode(page)->i_sb->s_flags & MS_RDONLY)) {
 			unlock_page(page);
 			return 0;
 		}
@@ -441,7 +441,7 @@ static struct bio *page_bio(struct page 
 		struct super_block *super;
 		reiser4_block_nr blocknr;
 
-		super = page->mapping->host->i_sb;
+		super = page_inode(page)->i_sb;
 		assert("nikita-2029", super != NULL);
 		blksz = super->s_blocksize;
 		assert("nikita-2028", blksz == (int)PAGE_CACHE_SIZE);
@@ -479,7 +479,7 @@ int reiser4_set_page_dirty_internal(stru
 {
 	struct address_space *mapping;
 
-	mapping = page->mapping;
+	mapping = page_mapping(page);
 	BUG_ON(mapping == NULL);
 
 	if (!TestSetPageDirty(page)) {
@@ -528,7 +528,7 @@ int reiser4_writepage(struct page *page,
 
 	assert("vs-828", PageLocked(page));
 
-	s = page->mapping->host->i_sb;
+	s = page_inode(page)->i_sb;
 	ctx = get_current_context_check();
 
 	//assert("", can_hit_entd(ctx, s));
Index: test-2.6.23-rc4-mm1/fs/reiser4/wander.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/wander.c
+++ test-2.6.23-rc4-mm1/fs/reiser4/wander.c
@@ -765,7 +765,7 @@ static int write_jnodes_to_disk_extent(
 
 			spin_lock_jnode(cur);
 			assert("nikita-3166",
-			       pg->mapping == jnode_get_mapping(cur));
+			       page_mapping(pg) == jnode_get_mapping(cur));
 			assert("zam-912", !JF_ISSET(cur, JNODE_WRITEBACK));
 #if REISER4_DEBUG
 			spin_lock(&cur->load);
Index: test-2.6.23-rc4-mm1/fs/unionfs/mmap.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/unionfs/mmap.c
+++ test-2.6.23-rc4-mm1/fs/unionfs/mmap.c
@@ -61,7 +61,7 @@ static int unionfs_writepage(struct page
 	char *kaddr, *lower_kaddr;
 	int saved_for_writepages = wbc->for_writepages;
 
-	inode = page->mapping->host;
+	inode = page_inode(page);
 	lower_inode = unionfs_lower_inode(inode);
 
 	/* find lower page (returns a locked page) */
@@ -225,7 +225,7 @@ static int unionfs_commit_write(struct f
 	if ((err = unionfs_file_revalidate(file, 1)))
 		goto out;
 
-	inode = page->mapping->host;
+	inode = page_inode(page);
 	lower_inode = unionfs_lower_inode(inode);
 
 	if (UNIONFS_F(file) != NULL)
@@ -283,7 +283,7 @@ static void unionfs_sync_page(struct pag
 	struct page *lower_page;
 	struct address_space *mapping;
 
-	inode = page->mapping->host;
+	inode = page_inode(page);
 	lower_inode = unionfs_lower_inode(inode);
 
 	/* find lower page (returns a locked page) */
@@ -292,7 +292,7 @@ static void unionfs_sync_page(struct pag
 		goto out;
 
 	/* do the actual sync */
-	mapping = lower_page->mapping;
+	mapping = page_mapping(lower_page);
 	/*
 	 * XXX: can we optimize ala RAIF and set the lower page to be
 	 * discarded after a successful sync_page?
Index: test-2.6.23-rc4-mm1/fs/unionfs/union.h
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/unionfs/union.h
+++ test-2.6.23-rc4-mm1/fs/unionfs/union.h
@@ -43,6 +43,7 @@
 #include <linux/fs_stack.h>
 #include <linux/magic.h>
 #include <linux/log2.h>
+#include <linux/mm_inline.h>
 
 #include <asm/mman.h>
 #include <asm/system.h>
Index: test-2.6.23-rc4-mm1/fs/xfs/linux-2.6/xfs_aops.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/xfs/linux-2.6/xfs_aops.c
+++ test-2.6.23-rc4-mm1/fs/xfs/linux-2.6/xfs_aops.c
@@ -41,6 +41,7 @@
 #include <linux/mpage.h>
 #include <linux/pagevec.h>
 #include <linux/writeback.h>
+#include <linux/mm_inline.h>
 
 STATIC void
 xfs_count_page_state(
@@ -752,7 +753,7 @@ xfs_convert_page(
 		goto fail;
 	if (PageWriteback(page))
 		goto fail_unlock_page;
-	if (page->mapping != inode->i_mapping)
+	if (page_mapping(page) != inode->i_mapping)
 		goto fail_unlock_page;
 	if (!xfs_is_delayed_page(page, (*ioendp)->io_type))
 		goto fail_unlock_page;
@@ -1178,7 +1179,7 @@ xfs_vm_writepage(
 	int			error;
 	int			need_trans;
 	int			delalloc, unmapped, unwritten;
-	struct inode		*inode = page->mapping->host;
+	struct inode		*inode = page_inode(page);
 
 	xfs_page_trace(XFS_WRITEPAGE_ENTER, inode, page, 0);
 
@@ -1270,7 +1271,7 @@ xfs_vm_releasepage(
 	struct page		*page,
 	gfp_t			gfp_mask)
 {
-	struct inode		*inode = page->mapping->host;
+	struct inode		*inode = page_inode(page);
 	int			dirty, delalloc, unmapped, unwritten;
 	struct writeback_control wbc = {
 		.sync_mode = WB_SYNC_ALL,
@@ -1562,7 +1563,7 @@ xfs_vm_invalidatepage(
 	unsigned long		offset)
 {
 	xfs_page_trace(XFS_INVALIDPAGE_ENTER,
-			page->mapping->host, page, offset);
+			page_inode(page), page, offset);
 	block_invalidatepage(page, offset);
 }
 
Index: test-2.6.23-rc4-mm1/fs/reiser4/plugin/file/file.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/plugin/file/file.c
+++ test-2.6.23-rc4-mm1/fs/reiser4/plugin/file/file.c
@@ -790,8 +790,8 @@ int find_or_create_extent(struct page *p
 
 	jnode *node;
 
-	assert("vs-1065", page->mapping && page->mapping->host);
-	inode = page->mapping->host;
+	assert("vs-1065", page->mapping && page_inode(page));
+	inode = page_inode(page);
 
 	lock_page(page);
 	node = jnode_of_page(page);
@@ -866,8 +866,8 @@ static int capture_page_and_create_exten
 	int result;
 	struct inode *inode;
 
-	assert("vs-1084", page->mapping && page->mapping->host);
-	inode = page->mapping->host;
+	assert("vs-1084", page->mapping && page_inode(page));
+	inode = page_inode(page);
 	assert("vs-1139",
 	       unix_file_inode_data(inode)->container == UF_CONTAINER_EXTENTS);
 	/* page belongs to file */
@@ -905,8 +905,8 @@ commit_write_unix_file(struct file *file
 
 	SetPageUptodate(page);
 
-	inode = page->mapping->host;
-	ctx = reiser4_init_context(page->mapping->host->i_sb);
+	inode = page_inode(page);
+	ctx = reiser4_init_context(page_inode(page)->i_sb);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 	page_cache_get(page);
@@ -1433,9 +1433,9 @@ int readpage_unix_file(struct file *file
 
 	assert("vs-1062", PageLocked(page));
 	assert("vs-976", !PageUptodate(page));
-	assert("vs-1061", page->mapping && page->mapping->host);
+	assert("vs-1061", page->mapping && page_inode(page));
 
-	if (page->mapping->host->i_size <= page_offset(page)) {
+	if (page_inode(page)->i_size <= page_offset(page)) {
 		/* page is out of file */
 		zero_user_page(page, 0, PAGE_CACHE_SIZE, KM_USER0);
 		SetPageUptodate(page);
@@ -1443,7 +1443,7 @@ int readpage_unix_file(struct file *file
 		return 0;
 	}
 
-	inode = page->mapping->host;
+	inode = page_inode(page);
 	ctx = reiser4_init_context(inode->i_sb);
 	if (IS_ERR(ctx)) {
 		unlock_page(page);
@@ -1476,7 +1476,7 @@ int readpage_unix_file(struct file *file
 	lock_page(page);
 	page_cache_release(page);
 
-	if (page->mapping == NULL) {
+	if (!page->mapping) {
 		/*
 		 * readpage allows truncate to run concurrently. Page was
 		 * truncated while it was not locked
@@ -1604,7 +1604,7 @@ static int uf_readpages_filler(void * da
 	reiser4_extent *ext;
 	__u64 ext_index;
 	int cbk_done = 0;
-	struct address_space * mapping = page->mapping;
+	struct address_space * mapping = page_mapping(page);
 
 	if (PageUptodate(page)) {
 		unlock_page(page);
Index: test-2.6.23-rc4-mm1/fs/reiser4/plugin/file/cryptcompress.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/plugin/file/cryptcompress.c
+++ test-2.6.23-rc4-mm1/fs/reiser4/plugin/file/cryptcompress.c
@@ -1233,16 +1233,16 @@ int readpage_cryptcompress(struct file *
 
 	assert("edward-88", PageLocked(page));
 	assert("vs-976", !PageUptodate(page));
-	assert("edward-89", page->mapping && page->mapping->host);
+	assert("edward-89", page->mapping && page_inode(page));
 
-	ctx = reiser4_init_context(page->mapping->host->i_sb);
+	ctx = reiser4_init_context(page_inode(page)->i_sb);
 	if (IS_ERR(ctx)) {
 		unlock_page(page);
 		return PTR_ERR(ctx);
 	}
 	assert("edward-113",
 	       ergo(file != NULL,
-		    page->mapping == file->f_dentry->d_inode->i_mapping));
+		    page_mapping(page) == file->f_dentry->d_inode->i_mapping));
 
 	if (PageUptodate(page)) {
 		warning("edward-1338", "page is already uptodate\n");
@@ -1873,7 +1873,7 @@ static void checkout_page_cluster(struct
 			assert("edward-1480",
 			       i_size_read(inode) <= page_offset(clust->pages[i]));
 			assert("edward-1481",
-			       clust->pages[i]->mapping != inode->i_mapping);
+			      page_mapping(clust->pages[i]) != inode->i_mapping);
 			unlock_page(clust->pages[i]);
 			break;
 		}
@@ -2651,13 +2651,13 @@ int set_cluster_by_page(struct cluster_h
 
 	assert("edward-1358", clust != NULL);
 	assert("edward-1359", page != NULL);
-	assert("edward-1360", page->mapping != NULL);
-	assert("edward-1361", page->mapping->host != NULL);
+	assert("edward-1360", page->mapping != 0);
+	assert("edward-1361", page_inode(page) != NULL);
 
 	setting_actor =
 		(clust->pages ? reset_cluster_pgset : alloc_cluster_pgset);
 	result = setting_actor(clust, count);
-	clust->index = pg_to_clust(page->index, page->mapping->host);
+	clust->index = pg_to_clust(page->index, page_inode(page));
 	return result;
 }
 
Index: test-2.6.23-rc4-mm1/fs/reiser4/plugin/file_ops.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/plugin/file_ops.c
+++ test-2.6.23-rc4-mm1/fs/reiser4/plugin/file_ops.c
@@ -93,7 +93,7 @@ prepare_write_common(struct file *file, 
 	reiser4_context *ctx;
 	int result;
 
-	ctx = reiser4_init_context(page->mapping->host->i_sb);
+	ctx = reiser4_init_context(page_inode(page)->i_sb);
 	result = do_prepare_write(file, page, from, to);
 
 	/* don't commit transaction under inode semaphore */
@@ -120,13 +120,13 @@ do_prepare_write(struct file *file, stru
 	if (to - from == PAGE_CACHE_SIZE || PageUptodate(page))
 		return 0;
 
-	inode = page->mapping->host;
+	inode = page_inode(page);
 	fplug = inode_file_plugin(inode);
 
-	if (page->mapping->a_ops->readpage == NULL)
+	if (page_mapping(page)->a_ops->readpage == NULL)
 		return RETERR(-EINVAL);
 
-	result = page->mapping->a_ops->readpage(file, page);
+	result = page_mapping(page)->a_ops->readpage(file, page);
 	if (result != 0) {
 		SetPageError(page);
 		ClearPageUptodate(page);
Index: test-2.6.23-rc4-mm1/fs/reiser4/plugin/item/ctail.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/plugin/item/ctail.c
+++ test-2.6.23-rc4-mm1/fs/reiser4/plugin/item/ctail.c
@@ -37,6 +37,7 @@ Internal on-disk structure:
 #include <linux/pagevec.h>
 #include <linux/swap.h>
 #include <linux/fs.h>
+#include <linux/mm.h>
 
 /* return body of ctail item at @coord */
 static ctail_item_format *ctail_formatted_at(const coord_t * coord)
@@ -580,7 +581,7 @@ static int ctail_read_disk_cluster(struc
 	 */
 	assert("edward-1528", znode_is_any_locked(clust->hint->lh.node));
 
-	if (page->mapping != inode->i_mapping) {
+	if (page_mapping(page) != inode->i_mapping) {
 		/* page was truncated */
 		reiser4_unset_hint(clust->hint);
 		reset_cluster_params(clust);
@@ -632,7 +633,7 @@ int do_readpage_ctail(struct inode * ino
 
 	assert("edward-212", PageLocked(page));
 
-	if (unlikely(page->mapping != inode->i_mapping))
+	if (unlikely(page_mapping(page) != inode->i_mapping))
 		return AOP_TRUNCATED_PAGE;
 	if (PageUptodate(page))
 		goto exit;
@@ -713,7 +714,7 @@ int readpage_ctail(void *vp, struct page
 	assert("edward-114", clust != NULL);
 	assert("edward-115", PageLocked(page));
 	assert("edward-116", !PageUptodate(page));
-	assert("edward-118", page->mapping && page->mapping->host);
+	assert("edward-118", page->mapping && page_inode(page));
 	assert("edward-867", !tfm_cluster_is_uptodate(&clust->tc));
 
 	hint = kmalloc(sizeof(*hint), reiser4_ctx_gfp_mask_get());
@@ -730,7 +731,7 @@ int readpage_ctail(void *vp, struct page
 	}
 	assert("vs-25", hint->ext_coord.lh == &hint->lh);
 
-	result = do_readpage_ctail(page->mapping->host, clust, page,
+	result = do_readpage_ctail(page_inode(page), clust, page,
 				   ZNODE_READ_LOCK);
 	assert("edward-213", PageLocked(page));
 	assert("edward-1163", ergo(!result, PageUptodate(page)));
@@ -781,7 +782,7 @@ static int ctail_readpages_filler(void *
 	struct cluster_handle * clust = data;
 	struct inode * inode = clust->file->f_dentry->d_inode;
 
-	assert("edward-1525", page->mapping == inode->i_mapping);
+	assert("edward-1525", page_mapping(page) == inode->i_mapping);
 
 	if (PageUptodate(page)) {
 		unlock_page(page);
@@ -1110,7 +1111,7 @@ int scan_ctail(flush_scan * scan)
 	assert("edward-639", znode_is_write_locked(scan->parent_lock.node));
 
 	page = jnode_page(node);
-	inode = page->mapping->host;
+	inode = page_inode(page);
 
 	if (!reiser4_scanning_left(scan))
 		return result;
@@ -1516,9 +1517,9 @@ int convert_ctail(flush_pos_t * pos)
 			assert("edward-264", pos->child != NULL);
 			assert("edward-265", jnode_page(pos->child) != NULL);
 			assert("edward-266",
-			       jnode_page(pos->child)->mapping != NULL);
+			       page_mapping(jnode_page(pos->child)) != NULL);
 
-			inode = jnode_page(pos->child)->mapping->host;
+			inode = page_inode(jnode_page(pos->child));
 
 			assert("edward-267", inode != NULL);
 
Index: test-2.6.23-rc4-mm1/fs/reiser4/plugin/item/tail.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/plugin/item/tail.c
+++ test-2.6.23-rc4-mm1/fs/reiser4/plugin/item/tail.c
@@ -317,7 +317,7 @@ static int do_readpage_tail(uf_coord_t *
 	/* saving passed coord in order to do not move it by tap. */
 	init_lh(&lh);
 	copy_lh(&lh, uf_coord->lh);
-	inode = page->mapping->host;
+	inode = page_inode(page);
 	coord_dup(&coord, &uf_coord->coord);
 
 	reiser4_tap_init(&tap, &coord, &lh, ZNODE_READ_LOCK);
@@ -421,14 +421,14 @@ int readpage_tail(void *vp, struct page 
 	assert("umka-2515", PageLocked(page));
 	assert("umka-2516", !PageUptodate(page));
 	assert("umka-2517", !jprivate(page) && !PagePrivate(page));
-	assert("umka-2518", page->mapping && page->mapping->host);
+	assert("umka-2518", page->mapping && page_inode(page));
 
 	assert("umka-2519", znode_is_loaded(coord->node));
 	assert("umka-2520", item_is_tail(coord));
 	assert("umka-2521", coord_is_existing_unit(coord));
 	assert("umka-2522", znode_is_rlocked(coord->node));
 	assert("umka-2523",
-	       page->mapping->host->i_ino ==
+	       page_inode(page)->i_ino ==
 	       get_key_objectid(item_key_by_coord(coord, &key)));
 
 	return do_readpage_tail(uf_coord, page);
Index: test-2.6.23-rc4-mm1/fs/reiser4/plugin/item/extent_file_ops.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/plugin/item/extent_file_ops.c
+++ test-2.6.23-rc4-mm1/fs/reiser4/plugin/item/extent_file_ops.c
@@ -1124,7 +1124,7 @@ int reiser4_do_readpage_extent(reiser4_e
 	oid_t oid;
 	reiser4_block_nr block;
 
-	mapping = page->mapping;
+	mapping = page_mapping(page);
 	oid = get_inode_oid(mapping->host);
 	index = page->index;
 
@@ -1324,14 +1324,14 @@ int reiser4_readpage_extent(void *vp, st
 
 	assert("vs-1040", PageLocked(page));
 	assert("vs-1050", !PageUptodate(page));
-	assert("vs-1039", page->mapping && page->mapping->host);
+	assert("vs-1039", page->mapping && page_inode(page));
 
 	assert("vs-1044", znode_is_loaded(coord->node));
 	assert("vs-758", item_is_extent(coord));
 	assert("vs-1046", coord_is_existing_unit(coord));
 	assert("vs-1045", znode_is_rlocked(coord->node));
 	assert("vs-1047",
-	       page->mapping->host->i_ino ==
+	       page_inode(page)->i_ino ==
 	       get_key_objectid(item_key_by_coord(coord, &key)));
 	check_uf_coord(uf_coord, NULL);
 
Index: test-2.6.23-rc4-mm1/fs/ntfs/compress.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/ntfs/compress.c
+++ test-2.6.23-rc4-mm1/fs/ntfs/compress.c
@@ -482,7 +482,7 @@ int ntfs_read_compressed_block(struct pa
 {
 	loff_t i_size;
 	s64 initialized_size;
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 	ntfs_inode *ni = NTFS_I(mapping->host);
 	ntfs_volume *vol = ni->vol;
 	struct super_block *sb = vol->sb;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
