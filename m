Message-Id: <20061207162737.633957000@chello.nl>
References: <20061207161800.426936000@chello.nl>
Date: Thu, 07 Dec 2006 17:18:14 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 14/16] mm/fs: abstract address_space::nrpages
Content-Disposition: inline; filename=mapping_nrpages.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Currently the tree_lock protects mapping->nrpages, this will not be
possible much longer. Hence abstract the access to this variable so that
it can be easily replaced by an atomic_ulong_t.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/sh64/lib/dbg.c          |    2 +-
 fs/block_dev.c               |    2 +-
 fs/buffer.c                  |    2 +-
 fs/gfs2/glock.c              |    2 +-
 fs/gfs2/glops.c              |    6 +++---
 fs/gfs2/meta_io.c            |    2 +-
 fs/hugetlbfs/inode.c         |    2 +-
 fs/inode.c                   |   10 +++++-----
 fs/jffs/inode-v23.c          |    2 +-
 fs/jffs2/dir.c               |    4 ++--
 fs/jffs2/fs.c                |    2 +-
 fs/libfs.c                   |    2 +-
 fs/nfs/inode.c               |    6 +++---
 fs/xfs/linux-2.6/xfs_vnode.h |    2 +-
 include/linux/fs.h           |   22 +++++++++++++++++++++-
 include/linux/swap.h         |    2 +-
 ipc/shm.c                    |    4 ++--
 mm/filemap.c                 |   12 ++++++------
 mm/shmem.c                   |    8 ++++----
 mm/swap_state.c              |    4 ++--
 mm/truncate.c                |    2 +-
 21 files changed, 60 insertions(+), 40 deletions(-)

Index: linux-2.6-rt/arch/sh64/lib/dbg.c
===================================================================
--- linux-2.6-rt.orig/arch/sh64/lib/dbg.c	2006-12-02 22:23:38.000000000 +0100
+++ linux-2.6-rt/arch/sh64/lib/dbg.c	2006-12-02 22:23:42.000000000 +0100
@@ -424,6 +424,6 @@ void print_page(struct page *page)
 	printk("  page[%p] -> index 0x%lx,  count 0x%x,  flags 0x%lx\n",
 	       page, page->index, page_count(page), page->flags);
 	printk("       address_space = %p, pages =%ld\n", page->mapping,
-	       page->mapping->nrpages);
+	       mapping_nrpages(page->mapping));
 
 }
Index: linux-2.6-rt/fs/block_dev.c
===================================================================
--- linux-2.6-rt.orig/fs/block_dev.c	2006-12-02 22:23:38.000000000 +0100
+++ linux-2.6-rt/fs/block_dev.c	2006-12-02 22:23:42.000000000 +0100
@@ -398,7 +398,7 @@ long nr_blockdev_pages(void)
 	list_for_each(p, &all_bdevs) {
 		struct block_device *bdev;
 		bdev = list_entry(p, struct block_device, bd_list);
-		ret += bdev->bd_inode->i_mapping->nrpages;
+		ret += mapping_nrpages(bdev->bd_inode->i_mapping);
 	}
 	spin_unlock(&bdev_lock);
 	return ret;
Index: linux-2.6-rt/fs/buffer.c
===================================================================
--- linux-2.6-rt.orig/fs/buffer.c	2006-12-02 22:23:42.000000000 +0100
+++ linux-2.6-rt/fs/buffer.c	2006-12-02 23:17:12.000000000 +0100
@@ -335,7 +335,7 @@ void invalidate_bdev(struct block_device
 {
 	struct address_space *mapping = bdev->bd_inode->i_mapping;
 
-	if (mapping->nrpages == 0)
+	if (mapping_nrpages(mapping) == 0)
 		return;
 
 	invalidate_bh_lrus();
Index: linux-2.6-rt/fs/gfs2/glock.c
===================================================================
--- linux-2.6-rt.orig/fs/gfs2/glock.c	2006-12-02 22:23:38.000000000 +0100
+++ linux-2.6-rt/fs/gfs2/glock.c	2006-12-02 22:23:42.000000000 +0100
@@ -2128,7 +2128,7 @@ static int dump_glock(struct gfs2_glock 
 		    (list_empty(&gl->gl_reclaim)) ? "no" : "yes");
 	if (gl->gl_aspace)
 		printk(KERN_INFO "  aspace = 0x%p nrpages = %lu\n", gl->gl_aspace,
-		       gl->gl_aspace->i_mapping->nrpages);
+		       mapping_nrpages(gl->gl_aspace->i_mapping));
 	else
 		printk(KERN_INFO "  aspace = no\n");
 	printk(KERN_INFO "  ail = %d\n", atomic_read(&gl->gl_ail_count));
Index: linux-2.6-rt/fs/gfs2/glops.c
===================================================================
--- linux-2.6-rt.orig/fs/gfs2/glops.c	2006-12-02 22:23:38.000000000 +0100
+++ linux-2.6-rt/fs/gfs2/glops.c	2006-12-02 22:23:42.000000000 +0100
@@ -123,7 +123,7 @@ static void gfs2_page_inval(struct gfs2_
 		return;
 
 	truncate_inode_pages(inode->i_mapping, 0);
-	gfs2_assert_withdraw(GFS2_SB(&ip->i_inode), !inode->i_mapping->nrpages);
+	gfs2_assert_withdraw(GFS2_SB(&ip->i_inode), !mapping_nrpages(inode->i_mapping));
 	clear_bit(GIF_PAGED, &ip->i_flags);
 }
 
@@ -324,7 +324,7 @@ static int inode_go_demote_ok(struct gfs
 	struct gfs2_sbd *sdp = gl->gl_sbd;
 	int demote = 0;
 
-	if (!gl->gl_object && !gl->gl_aspace->i_mapping->nrpages)
+	if (!gl->gl_object && !mapping_nrpages(gl->gl_aspace->i_mapping))
 		demote = 1;
 	else if (!sdp->sd_args.ar_localcaching &&
 		 time_after_eq(jiffies, gl->gl_stamp +
@@ -428,7 +428,7 @@ static void inode_greedy(struct gfs2_glo
 
 static int rgrp_go_demote_ok(struct gfs2_glock *gl)
 {
-	return !gl->gl_aspace->i_mapping->nrpages;
+	return !mapping_nrpages(gl->gl_aspace->i_mapping);
 }
 
 /**
Index: linux-2.6-rt/fs/gfs2/meta_io.c
===================================================================
--- linux-2.6-rt.orig/fs/gfs2/meta_io.c	2006-12-02 22:23:38.000000000 +0100
+++ linux-2.6-rt/fs/gfs2/meta_io.c	2006-12-02 22:23:42.000000000 +0100
@@ -104,7 +104,7 @@ void gfs2_meta_inval(struct gfs2_glock *
 	truncate_inode_pages(mapping, 0);
 	atomic_dec(&aspace->i_writecount);
 
-	gfs2_assert_withdraw(sdp, !mapping->nrpages);
+	gfs2_assert_withdraw(sdp, !mapping_nrpages(mapping));
 }
 
 /**
Index: linux-2.6-rt/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6-rt.orig/fs/hugetlbfs/inode.c	2006-12-02 22:23:38.000000000 +0100
+++ linux-2.6-rt/fs/hugetlbfs/inode.c	2006-12-02 22:23:42.000000000 +0100
@@ -214,7 +214,7 @@ static void truncate_hugepages(struct in
 		}
 		huge_pagevec_release(&pvec);
 	}
-	BUG_ON(!lstart && mapping->nrpages);
+	BUG_ON(!lstart && mapping_nrpages(mapping));
 	hugetlb_unreserve_pages(inode, start, freed);
 }
 
Index: linux-2.6-rt/fs/jffs/inode-v23.c
===================================================================
--- linux-2.6-rt.orig/fs/jffs/inode-v23.c	2006-12-02 22:23:38.000000000 +0100
+++ linux-2.6-rt/fs/jffs/inode-v23.c	2006-12-02 22:23:42.000000000 +0100
@@ -1352,7 +1352,7 @@ jffs_create(struct inode *dir, struct de
 	inode->i_op = &jffs_file_inode_operations;
 	inode->i_fop = &jffs_file_operations;
 	inode->i_mapping->a_ops = &jffs_address_operations;
-	inode->i_mapping->nrpages = 0;
+	mapping_nrpages_init(inode->i_mapping);
 
 	d_instantiate(dentry, inode);
  jffs_create_end:
Index: linux-2.6-rt/fs/jffs2/dir.c
===================================================================
--- linux-2.6-rt.orig/fs/jffs2/dir.c	2006-12-02 22:23:38.000000000 +0100
+++ linux-2.6-rt/fs/jffs2/dir.c	2006-12-02 22:23:42.000000000 +0100
@@ -206,7 +206,7 @@ static int jffs2_create(struct inode *di
 	inode->i_op = &jffs2_file_inode_operations;
 	inode->i_fop = &jffs2_file_operations;
 	inode->i_mapping->a_ops = &jffs2_file_address_operations;
-	inode->i_mapping->nrpages = 0;
+	mapping_nrpages_init(inode->i_mapping);
 
 	f = JFFS2_INODE_INFO(inode);
 	dir_f = JFFS2_INODE_INFO(dir_i);
@@ -230,7 +230,7 @@ static int jffs2_create(struct inode *di
 	d_instantiate(dentry, inode);
 
 	D1(printk(KERN_DEBUG "jffs2_create: Created ino #%lu with mode %o, nlink %d(%d). nrpages %ld\n",
-		  inode->i_ino, inode->i_mode, inode->i_nlink, f->inocache->nlink, inode->i_mapping->nrpages));
+		  inode->i_ino, inode->i_mode, inode->i_nlink, f->inocache->nlink, mapping_nrpages(inode->i_mapping)));
 	return 0;
 
  fail:
Index: linux-2.6-rt/fs/jffs2/fs.c
===================================================================
--- linux-2.6-rt.orig/fs/jffs2/fs.c	2006-12-02 22:23:38.000000000 +0100
+++ linux-2.6-rt/fs/jffs2/fs.c	2006-12-02 22:23:42.000000000 +0100
@@ -293,7 +293,7 @@ void jffs2_read_inode (struct inode *ino
 		inode->i_op = &jffs2_file_inode_operations;
 		inode->i_fop = &jffs2_file_operations;
 		inode->i_mapping->a_ops = &jffs2_file_address_operations;
-		inode->i_mapping->nrpages = 0;
+		mapping_nrpages_init(inode->i_mapping);
 		break;
 
 	case S_IFBLK:
Index: linux-2.6-rt/fs/libfs.c
===================================================================
--- linux-2.6-rt.orig/fs/libfs.c	2006-12-02 22:23:38.000000000 +0100
+++ linux-2.6-rt/fs/libfs.c	2006-12-02 22:23:42.000000000 +0100
@@ -16,7 +16,7 @@ int simple_getattr(struct vfsmount *mnt,
 {
 	struct inode *inode = dentry->d_inode;
 	generic_fillattr(inode, stat);
-	stat->blocks = inode->i_mapping->nrpages << (PAGE_CACHE_SHIFT - 9);
+	stat->blocks = mapping_nrpages(inode->i_mapping) << (PAGE_CACHE_SHIFT - 9);
 	return 0;
 }
 
Index: linux-2.6-rt/fs/nfs/inode.c
===================================================================
--- linux-2.6-rt.orig/fs/nfs/inode.c	2006-12-02 22:23:38.000000000 +0100
+++ linux-2.6-rt/fs/nfs/inode.c	2006-12-02 22:23:42.000000000 +0100
@@ -93,7 +93,7 @@ int nfs_sync_mapping(struct address_spac
 {
 	int ret;
 
-	if (mapping->nrpages == 0)
+	if (mapping_nrpages(mapping) == 0)
 		return 0;
 	unmap_mapping_range(mapping, 0, 0, 0);
 	ret = filemap_write_and_wait(mapping);
@@ -133,7 +133,7 @@ void nfs_zap_caches(struct inode *inode)
 
 void nfs_zap_mapping(struct inode *inode, struct address_space *mapping)
 {
-	if (mapping->nrpages != 0) {
+	if (mapping_nrpages(mapping) != 0) {
 		spin_lock(&inode->i_lock);
 		NFS_I(inode)->cache_validity |= NFS_INO_INVALID_DATA;
 		spin_unlock(&inode->i_lock);
@@ -684,7 +684,7 @@ int nfs_revalidate_mapping(struct inode 
 		goto out;
 
 	if (nfsi->cache_validity & NFS_INO_INVALID_DATA) {
-		if (mapping->nrpages != 0) {
+		if (mapping_nrpages(mapping) != 0) {
 			if (S_ISREG(inode->i_mode)) {
 				ret = nfs_sync_mapping(mapping);
 				if (ret < 0)
Index: linux-2.6-rt/fs/xfs/linux-2.6/xfs_vnode.h
===================================================================
--- linux-2.6-rt.orig/fs/xfs/linux-2.6/xfs_vnode.h	2006-12-02 22:23:38.000000000 +0100
+++ linux-2.6-rt/fs/xfs/linux-2.6/xfs_vnode.h	2006-12-02 22:23:42.000000000 +0100
@@ -548,7 +548,7 @@ static inline void vn_atime_to_time_t(bh
  * Some useful predicates.
  */
 #define VN_MAPPED(vp)	mapping_mapped(vn_to_inode(vp)->i_mapping)
-#define VN_CACHED(vp)	(vn_to_inode(vp)->i_mapping->nrpages)
+#define VN_CACHED(vp)	mapping_nrpages(vn_to_inode(vp)->i_mapping)
 #define VN_DIRTY(vp)	mapping_tagged(vn_to_inode(vp)->i_mapping, \
 					PAGECACHE_TAG_DIRTY)
 #define VN_TRUNC(vp)	((vp)->v_flag & VTRUNCATED)
Index: linux-2.6-rt/include/linux/fs.h
===================================================================
--- linux-2.6-rt.orig/include/linux/fs.h	2006-12-02 22:23:42.000000000 +0100
+++ linux-2.6-rt/include/linux/fs.h	2006-12-02 23:17:11.000000000 +0100
@@ -436,7 +436,7 @@ struct address_space {
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
 	spinlock_t		i_mmap_lock;	/* protect tree, count, list */
 	unsigned int		truncate_count;	/* Cover race condition with truncate */
-	unsigned long		nrpages;	/* number of total pages */
+	unsigned long		__nrpages;	/* number of total pages */
 	pgoff_t			writeback_index;/* writeback starts here */
 	const struct address_space_operations *a_ops;	/* methods */
 	unsigned long		flags;		/* error bits/gfp mask */
@@ -451,6 +451,26 @@ struct address_space {
 	 * of struct page's "mapping" pointer be used for PAGE_MAPPING_ANON.
 	 */
 
+static inline void mapping_nrpages_init(struct address_space *mapping)
+{
+	mapping->__nrpages = 0;
+}
+
+static inline unsigned long mapping_nrpages(struct address_space *mapping)
+{
+	return mapping->__nrpages;
+}
+
+static inline void mapping_nrpages_inc(struct address_space *mapping)
+{
+	mapping->__nrpages++;
+}
+
+static inline void mapping_nrpages_dec(struct address_space *mapping)
+{
+	mapping->__nrpages--;
+}
+
 struct block_device {
 	dev_t			bd_dev;  /* not a kdev_t - it's a search key */
 	struct inode *		bd_inode;	/* will die */
Index: linux-2.6-rt/ipc/shm.c
===================================================================
--- linux-2.6-rt.orig/ipc/shm.c	2006-12-02 22:23:38.000000000 +0100
+++ linux-2.6-rt/ipc/shm.c	2006-12-02 22:23:42.000000000 +0100
@@ -499,11 +499,11 @@ static void shm_get_stat(struct ipc_name
 
 		if (is_file_hugepages(shp->shm_file)) {
 			struct address_space *mapping = inode->i_mapping;
-			*rss += (HPAGE_SIZE/PAGE_SIZE)*mapping->nrpages;
+			*rss += (HPAGE_SIZE/PAGE_SIZE)*mapping_nrpages(mapping);
 		} else {
 			struct shmem_inode_info *info = SHMEM_I(inode);
 			spin_lock(&info->lock);
-			*rss += inode->i_mapping->nrpages;
+			*rss += mapping_nrpages(inode->i_mapping);
 			*swp += info->swapped;
 			spin_unlock(&info->lock);
 		}
Index: linux-2.6-rt/mm/filemap.c
===================================================================
--- linux-2.6-rt.orig/mm/filemap.c	2006-12-02 22:23:42.000000000 +0100
+++ linux-2.6-rt/mm/filemap.c	2006-12-02 23:17:12.000000000 +0100
@@ -118,7 +118,7 @@ void __remove_from_page_cache(struct pag
 
 	radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = NULL;
-	mapping->nrpages--;
+	mapping_nrpages_dec(mapping);
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 }
 
@@ -190,7 +190,7 @@ int __filemap_fdatawrite_range(struct ad
 	int ret;
 	struct writeback_control wbc = {
 		.sync_mode = sync_mode,
-		.nr_to_write = mapping->nrpages * 2,
+		.nr_to_write = mapping_nrpages(mapping) * 2,
 		.range_start = start,
 		.range_end = end,
 	};
@@ -372,7 +372,7 @@ int filemap_write_and_wait(struct addres
 {
 	int err = 0;
 
-	if (mapping->nrpages) {
+	if (mapping_nrpages(mapping)) {
 		err = filemap_fdatawrite(mapping);
 		/*
 		 * Even if the above returned error, the pages may be
@@ -406,7 +406,7 @@ int filemap_write_and_wait_range(struct 
 {
 	int err = 0;
 
-	if (mapping->nrpages) {
+	if (mapping_nrpages(mapping)) {
 		err = __filemap_fdatawrite_range(mapping, lstart, lend,
 						 WB_SYNC_ALL);
 		/* See comment of filemap_write_and_wait() */
@@ -448,7 +448,7 @@ int add_to_page_cache(struct page *page,
 			SetPageLocked(page);
 			page->mapping = mapping;
 			page->index = offset;
-			mapping->nrpages++;
+			mapping_nrpages_inc(mapping);
 			__inc_zone_page_state(page, NR_FILE_PAGES);
 		}
 		spin_unlock_irq(&mapping->tree_lock);
@@ -2469,7 +2469,7 @@ generic_file_direct_IO(int rw, struct ki
 	if (retval == 0) {
 		retval = mapping->a_ops->direct_IO(rw, iocb, iov,
 						offset, nr_segs);
-		if (rw == WRITE && mapping->nrpages) {
+		if (rw == WRITE && mapping_nrpages(mapping)) {
 			pgoff_t end = (offset + write_len - 1)
 						>> PAGE_CACHE_SHIFT;
 			int err = invalidate_inode_pages2_range(mapping,
Index: linux-2.6-rt/mm/shmem.c
===================================================================
--- linux-2.6-rt.orig/mm/shmem.c	2006-12-02 22:23:38.000000000 +0100
+++ linux-2.6-rt/mm/shmem.c	2006-12-02 22:23:42.000000000 +0100
@@ -211,8 +211,8 @@ static void shmem_free_blocks(struct ino
  * We have to calculate the free blocks since the mm can drop
  * undirtied hole pages behind our back.
  *
- * But normally   info->alloced == inode->i_mapping->nrpages + info->swapped
- * So mm freed is info->alloced - (inode->i_mapping->nrpages + info->swapped)
+ * But normally   info->alloced == mapping_nrpages(inode->i_mapping) + info->swapped
+ * So mm freed is info->alloced - (mapping_nrpages(inode->i_mapping) + info->swapped)
  *
  * It has to be called with the spinlock held.
  */
@@ -221,7 +221,7 @@ static void shmem_recalc_inode(struct in
 	struct shmem_inode_info *info = SHMEM_I(inode);
 	long freed;
 
-	freed = info->alloced - info->swapped - inode->i_mapping->nrpages;
+	freed = info->alloced - info->swapped - mapping_nrpages(inode->i_mapping);
 	if (freed > 0) {
 		info->alloced -= freed;
 		shmem_unacct_blocks(info->flags, freed);
@@ -602,7 +602,7 @@ static void shmem_truncate_range(struct 
 done1:
 	shmem_dir_unmap(dir);
 done2:
-	if (inode->i_mapping->nrpages && (info->flags & SHMEM_PAGEIN)) {
+	if (mapping_nrpages(inode->i_mapping) && (info->flags & SHMEM_PAGEIN)) {
 		/*
 		 * Call truncate_inode_pages again: racing shmem_unuse_inode
 		 * may have swizzled a page in from swap since vmtruncate or
Index: linux-2.6-rt/mm/swap_state.c
===================================================================
--- linux-2.6-rt.orig/mm/swap_state.c	2006-12-02 22:23:42.000000000 +0100
+++ linux-2.6-rt/mm/swap_state.c	2006-12-02 23:17:12.000000000 +0100
@@ -87,7 +87,7 @@ static int __add_to_swap_cache(struct pa
 			SetPageLocked(page);
 			SetPageSwapCache(page);
 			set_page_private(page, entry.val);
-			total_swapcache_pages++;
+			mapping_nrpages_inc(&swapper_space);
 			__inc_zone_page_state(page, NR_FILE_PAGES);
 		}
 		spin_unlock_irq(&swapper_space.tree_lock);
@@ -133,7 +133,7 @@ void __delete_from_swap_cache(struct pag
 	radix_tree_delete(&swapper_space.page_tree, page_private(page));
 	set_page_private(page, 0);
 	ClearPageSwapCache(page);
-	total_swapcache_pages--;
+	mapping_nrpages_dec(&swapper_space);
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	INC_CACHE_INFO(del_total);
 }
Index: linux-2.6-rt/mm/truncate.c
===================================================================
--- linux-2.6-rt.orig/mm/truncate.c	2006-12-02 22:23:42.000000000 +0100
+++ linux-2.6-rt/mm/truncate.c	2006-12-02 23:17:12.000000000 +0100
@@ -134,7 +134,7 @@ void truncate_inode_pages_range(struct a
 	pgoff_t next;
 	int i;
 
-	if (mapping->nrpages == 0)
+	if (mapping_nrpages(mapping) == 0)
 		return;
 
 	BUG_ON((lend & (PAGE_CACHE_SIZE - 1)) != (PAGE_CACHE_SIZE - 1));
Index: linux-2.6-rt/include/linux/swap.h
===================================================================
--- linux-2.6-rt.orig/include/linux/swap.h	2006-12-02 22:23:38.000000000 +0100
+++ linux-2.6-rt/include/linux/swap.h	2006-12-02 22:23:42.000000000 +0100
@@ -224,7 +224,7 @@ extern int end_swap_bio_read(struct bio 
 
 /* linux/mm/swap_state.c */
 extern struct address_space swapper_space;
-#define total_swapcache_pages  swapper_space.nrpages
+#define total_swapcache_pages  mapping_nrpages(&swapper_space)
 extern void show_swap_cache_info(void);
 extern int add_to_swap(struct page *, gfp_t);
 extern void __delete_from_swap_cache(struct page *);
Index: linux-2.6-rt/fs/inode.c
===================================================================
--- linux-2.6-rt.orig/fs/inode.c	2006-12-02 22:32:32.000000000 +0100
+++ linux-2.6-rt/fs/inode.c	2006-12-02 23:17:11.000000000 +0100
@@ -246,7 +246,7 @@ void clear_inode(struct inode *inode)
 	might_sleep();
 	invalidate_inode_buffers(inode);
        
-	BUG_ON(inode->i_data.nrpages);
+	BUG_ON(mapping_nrpages(&inode->i_data));
 	BUG_ON(!(inode->i_state & I_FREEING));
 	BUG_ON(inode->i_state & I_CLEAR);
 	wait_on_inode(inode);
@@ -279,7 +279,7 @@ static void dispose_list(struct list_hea
 		inode = list_entry(head->next, struct inode, i_list);
 		list_del(&inode->i_list);
 
-		if (inode->i_data.nrpages)
+		if (mapping_nrpages(&inode->i_data))
 			truncate_inode_pages(&inode->i_data, 0);
 		clear_inode(inode);
 
@@ -371,7 +371,7 @@ static int can_unuse(struct inode *inode
 		return 0;
 	if (atomic_read(&inode->i_count))
 		return 0;
-	if (inode->i_data.nrpages)
+	if (mapping_nrpages(&inode->i_data))
 		return 0;
 	return 1;
 }
@@ -410,7 +410,7 @@ static void prune_icache(int nr_to_scan)
 			list_move(&inode->i_list, &inode_unused);
 			continue;
 		}
-		if (inode_has_buffers(inode) || inode->i_data.nrpages) {
+		if (inode_has_buffers(inode) || mapping_nrpages(&inode->i_data)) {
 			__iget(inode);
 			spin_unlock(&inode_lock);
 			if (remove_inode_buffers(inode))
@@ -1057,7 +1057,7 @@ static void generic_forget_inode(struct 
 	inode->i_state |= I_FREEING;
 	inodes_stat.nr_inodes--;
 	spin_unlock(&inode_lock);
-	if (inode->i_data.nrpages)
+	if (mapping_nrpages(&inode->i_data))
 		truncate_inode_pages(&inode->i_data, 0);
 	clear_inode(inode);
 	wake_up_inode(inode);

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
