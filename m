Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 64FED6B0352
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 17:46:53 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so6982300pad.2
        for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:46:53 -0700 (PDT)
Received: from psmtp.com ([74.125.245.168])
        by mx.google.com with SMTP id ei3si9613602pbc.350.2013.10.21.14.46.51
        for <linux-mm@kvack.org>;
        Mon, 21 Oct 2013 14:46:52 -0700 (PDT)
Received: by mail-pb0-f51.google.com with SMTP id wz7so2913176pbc.24
        for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:46:50 -0700 (PDT)
Date: Mon, 21 Oct 2013 14:46:46 -0700
From: Ning Qu <quning@google.com>
Subject: [PATCHv2 04/13] mm, thp, tmpfs: handle huge page cases in
 shmem_getpage_gfp
Message-ID: <20131021214646.GE29870@hippobay.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>, Ning Qu <quning@gmail.com>

We don't support huge page when page is moved from page cache to swap.
So in this function, we enable huge page handling in two case:

1) when a huge page is found in the page cache,
2) or we need to alloc a huge page for page cache

We have to refactor all the calls to shmem_getpages to simplify the job
of caller. Right now shmem_getpage does:

1) simply request a page, default as a small page
2) or caller specify a flag to request either a huge page or a small page,
then leave the caller to decide how to use it

Signed-off-by: Ning Qu <quning@gmail.com>
---
 mm/shmem.c | 128 ++++++++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 97 insertions(+), 31 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 45fcca2..5bde8d0 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -115,14 +115,33 @@ static unsigned long shmem_default_max_inodes(void)
 static bool shmem_should_replace_page(struct page *page, gfp_t gfp);
 static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 				struct shmem_inode_info *info, pgoff_t index);
+
 static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
-	struct page **pagep, enum sgp_type sgp, gfp_t gfp, int *fault_type);
+	struct page **pagep, enum sgp_type sgp, gfp_t gfp, int flags,
+	int *fault_type);
 
 static inline int shmem_getpage(struct inode *inode, pgoff_t index,
-	struct page **pagep, enum sgp_type sgp, int *fault_type)
+	struct page **pagep, enum sgp_type sgp, gfp_t gfp, int flags,
+	int *fault_type)
 {
-	return shmem_getpage_gfp(inode, index, pagep, sgp,
-			mapping_gfp_mask(inode->i_mapping), fault_type);
+	int ret = 0;
+	struct page *page = NULL;
+
+	if ((flags & AOP_FLAG_TRANSHUGE) &&
+	    mapping_can_have_hugepages(inode->i_mapping)) {
+		ret = shmem_getpage_gfp(inode, index & ~HPAGE_CACHE_INDEX_MASK,
+					&page, sgp, gfp, flags,
+					NULL);
+		BUG_ON(page && !PageTransHugeCache(page));
+	}
+
+	if (!page) {
+		ret = shmem_getpage_gfp(inode, index, &page, sgp, gfp,
+					0, NULL);
+	}
+
+	*pagep = page;
+	return ret;
 }
 
 static inline struct shmem_sb_info *SHMEM_SB(struct super_block *sb)
@@ -561,7 +580,9 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 
 	if (partial_start) {
 		struct page *page = NULL;
-		shmem_getpage(inode, start - 1, &page, SGP_READ, NULL);
+		gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
+
+		shmem_getpage(inode, start - 1, &page, SGP_READ, gfp, 0, NULL);
 		if (page) {
 			unsigned int top = PAGE_CACHE_SIZE;
 			if (start > end) {
@@ -576,7 +597,9 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 	}
 	if (partial_end) {
 		struct page *page = NULL;
-		shmem_getpage(inode, end, &page, SGP_READ, NULL);
+		gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
+
+		shmem_getpage(inode, end, &page, SGP_READ, gfp, 0, NULL);
 		if (page) {
 			zero_user_segment(page, 0, partial_end);
 			set_page_dirty(page);
@@ -1151,7 +1174,8 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
  * entry since a page cannot live in both the swap and page cache
  */
 static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
-	struct page **pagep, enum sgp_type sgp, gfp_t gfp, int *fault_type)
+	struct page **pagep, enum sgp_type sgp, gfp_t gfp, int flags,
+	int *fault_type)
 {
 	struct address_space *mapping = inode->i_mapping;
 	struct shmem_inode_info *info;
@@ -1161,6 +1185,8 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	int error;
 	int once = 0;
 	int alloced = 0;
+	bool must_use_thp = flags & AOP_FLAG_TRANSHUGE;
+	int nr = 1;
 
 	if (index > (MAX_LFS_FILESIZE >> PAGE_CACHE_SHIFT))
 		return -EFBIG;
@@ -1170,6 +1196,11 @@ repeat:
 	if (radix_tree_exceptional_entry(page)) {
 		swap = radix_to_swp_entry(page);
 		page = NULL;
+		/* in swap, it's not a huge page for sure */
+		if (must_use_thp) {
+			*pagep = NULL;
+			return 0;
+		}
 	}
 
 	if (sgp != SGP_WRITE && sgp != SGP_FALLOC &&
@@ -1186,6 +1217,16 @@ repeat:
 		page_cache_release(page);
 		page = NULL;
 	}
+
+	if (page) {
+		if (must_use_thp && !PageTransHugeCache(page)) {
+			unlock_page(page);
+			page_cache_release(page);
+			*pagep = NULL;
+			return 0;
+		}
+	}
+
 	if (page || (sgp == SGP_READ && !swap.val)) {
 		*pagep = page;
 		return 0;
@@ -1274,14 +1315,25 @@ repeat:
 				error = -ENOSPC;
 				goto unacct;
 			}
-			percpu_counter_inc(&sbinfo->used_blocks);
 		}
 
-		page = shmem_alloc_page(gfp, info, index);
+		if (must_use_thp) {
+			page = shmem_alloc_hugepage(gfp, info, index);
+			if (page)
+				count_vm_event(THP_WRITE_ALLOC);
+			else
+				count_vm_event(THP_WRITE_ALLOC_FAILED);
+		} else
+			page = shmem_alloc_page(gfp, info, index);
+
 		if (!page) {
 			error = -ENOMEM;
-			goto decused;
+			goto unacct;
 		}
+		nr = hpagecache_nr_pages(page);
+
+		if (sbinfo->max_blocks)
+			percpu_counter_add(&sbinfo->used_blocks, nr);
 
 		SetPageSwapBacked(page);
 		__set_page_locked(page);
@@ -1289,12 +1341,9 @@ repeat:
 						gfp & GFP_RECLAIM_MASK);
 		if (error)
 			goto decused;
-		error = radix_tree_maybe_preload(gfp & GFP_RECLAIM_MASK);
-		if (!error) {
-			error = shmem_add_to_page_cache(page, mapping, index,
-							gfp, NULL);
-			radix_tree_preload_end();
-		}
+
+		error = shmem_add_to_page_cache(page, mapping, index,
+						gfp, NULL);
 		if (error) {
 			mem_cgroup_uncharge_cache_page(page);
 			goto decused;
@@ -1302,8 +1351,8 @@ repeat:
 		lru_cache_add_anon(page);
 
 		spin_lock(&info->lock);
-		info->alloced++;
-		inode->i_blocks += BLOCKS_PER_PAGE;
+		info->alloced += nr;
+		inode->i_blocks += BLOCKS_PER_PAGE * nr;
 		shmem_recalc_inode(inode);
 		spin_unlock(&info->lock);
 		alloced = true;
@@ -1320,7 +1369,7 @@ clear:
 		 * it now, lest undo on failure cancel our earlier guarantee.
 		 */
 		if (sgp != SGP_WRITE) {
-			clear_highpage(page);
+			clear_pagecache_page(page);
 			flush_dcache_page(page);
 			SetPageUptodate(page);
 		}
@@ -1354,7 +1403,7 @@ trunc:
 decused:
 	sbinfo = SHMEM_SB(inode->i_sb);
 	if (sbinfo->max_blocks)
-		percpu_counter_add(&sbinfo->used_blocks, -1);
+		percpu_counter_add(&sbinfo->used_blocks, -nr);
 unacct:
 	shmem_unacct_blocks(info->flags, 1);
 failed:
@@ -1383,8 +1432,10 @@ static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct inode *inode = file_inode(vma->vm_file);
 	int error;
 	int ret = VM_FAULT_LOCKED;
+	gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
 
-	error = shmem_getpage(inode, vmf->pgoff, &vmf->page, SGP_CACHE, &ret);
+	error = shmem_getpage(inode, vmf->pgoff, &vmf->page, SGP_CACHE, gfp,
+				0, &ret);
 	if (error)
 		return ((error == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS);
 
@@ -1520,7 +1571,9 @@ shmem_write_begin(struct file *file, struct address_space *mapping,
 {
 	struct inode *inode = mapping->host;
 	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
-	return shmem_getpage(inode, index, pagep, SGP_WRITE, NULL);
+	gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
+
+	return shmem_getpage(inode, index, pagep, SGP_WRITE, gfp, 0, NULL);
 }
 
 static int
@@ -1551,6 +1604,7 @@ shmem_write_end(struct file *file, struct address_space *mapping,
 static void do_shmem_file_read(struct file *filp, loff_t *ppos, read_descriptor_t *desc, read_actor_t actor)
 {
 	struct inode *inode = file_inode(filp);
+	gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
 	struct address_space *mapping = inode->i_mapping;
 	pgoff_t index;
 	unsigned long offset;
@@ -1582,7 +1636,8 @@ static void do_shmem_file_read(struct file *filp, loff_t *ppos, read_descriptor_
 				break;
 		}
 
-		desc->error = shmem_getpage(inode, index, &page, sgp, NULL);
+		desc->error = shmem_getpage(inode, index, &page, sgp, gfp,
+						0, NULL);
 		if (desc->error) {
 			if (desc->error == -EINVAL)
 				desc->error = 0;
@@ -1692,6 +1747,7 @@ static ssize_t shmem_file_splice_read(struct file *in, loff_t *ppos,
 {
 	struct address_space *mapping = in->f_mapping;
 	struct inode *inode = mapping->host;
+	gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
 	unsigned int loff, nr_pages, req_pages;
 	struct page *pages[PIPE_DEF_BUFFERS];
 	struct partial_page partial[PIPE_DEF_BUFFERS];
@@ -1730,7 +1786,8 @@ static ssize_t shmem_file_splice_read(struct file *in, loff_t *ppos,
 	error = 0;
 
 	while (spd.nr_pages < nr_pages) {
-		error = shmem_getpage(inode, index, &page, SGP_CACHE, NULL);
+		error = shmem_getpage(inode, index, &page, SGP_CACHE, gfp,
+					0, NULL);
 		if (error)
 			break;
 		unlock_page(page);
@@ -1752,8 +1809,8 @@ static ssize_t shmem_file_splice_read(struct file *in, loff_t *ppos,
 		page = spd.pages[page_nr];
 
 		if (!PageUptodate(page) || page->mapping != mapping) {
-			error = shmem_getpage(inode, index, &page,
-							SGP_CACHE, NULL);
+			error = shmem_getpage(inode, index, &page, SGP_CACHE,
+					gfp, 0, NULL);
 			if (error)
 				break;
 			unlock_page(page);
@@ -1945,9 +2002,11 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 			error = -EINTR;
 		else if (shmem_falloc.nr_unswapped > shmem_falloc.nr_falloced)
 			error = -ENOMEM;
-		else
+		else {
+			gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
 			error = shmem_getpage(inode, index, &page, SGP_FALLOC,
-									NULL);
+					      gfp, 0, NULL);
+		}
 		if (error) {
 			/* Remove the !PageUptodate pages we added */
 			shmem_undo_range(inode,
@@ -2213,7 +2272,10 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
 		}
 		inode->i_op = &shmem_short_symlink_operations;
 	} else {
-		error = shmem_getpage(inode, 0, &page, SGP_WRITE, NULL);
+		gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
+
+		error = shmem_getpage(inode, 0, &page, SGP_WRITE, gfp,
+					0, NULL);
 		if (error) {
 			iput(inode);
 			return error;
@@ -2243,8 +2305,12 @@ static void *shmem_follow_short_symlink(struct dentry *dentry, struct nameidata
 
 static void *shmem_follow_link(struct dentry *dentry, struct nameidata *nd)
 {
+	struct inode *inode = dentry->d_inode;
+	gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
 	struct page *page = NULL;
-	int error = shmem_getpage(dentry->d_inode, 0, &page, SGP_READ, NULL);
+	int error;
+
+	error = shmem_getpage(inode, 0, &page, SGP_READ, gfp, 0, NULL);
 	nd_set_link(nd, error ? ERR_PTR(error) : kmap(page));
 	if (page)
 		unlock_page(page);
@@ -3107,7 +3173,7 @@ struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
 	int error;
 
 	BUG_ON(mapping->a_ops != &shmem_aops);
-	error = shmem_getpage_gfp(inode, index, &page, SGP_CACHE, gfp, NULL);
+	error = shmem_getpage(inode, index, &page, SGP_CACHE, gfp, 0, NULL);
 	if (error)
 		page = ERR_PTR(error);
 	else
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
