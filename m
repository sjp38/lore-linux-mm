Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id C284682F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:48:13 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id 4so106648266pfd.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:48:13 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id fd9si7103908pad.134.2016.03.20.11.41.49
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:49 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 38/71] gfs2: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:45 +0300
Message-Id: <1458499278-1516-39-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Steven Whitehouse <swhiteho@redhat.com>, Bob Peterson <rpeterso@redhat.com>

PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
with promise that one day it will be possible to implement page cache with
bigger chunks than PAGE_SIZE.

This promise never materialized. And unlikely will.

We have many places where PAGE_CACHE_SIZE assumed to be equal to
PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
or PAGE_* constant should be used in a particular case, especially on the
border between fs and mm.

Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
breakage to be doable.

Let's stop pretending that pages in page cache are special. They are not.

The changes are pretty straight-forward:

 - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};

 - page_cache_get() -> get_page();

 - page_cache_release() -> put_page();

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Steven Whitehouse <swhiteho@redhat.com>
Cc: Bob Peterson <rpeterso@redhat.com>
---
 fs/gfs2/aops.c    | 44 ++++++++++++++++++++++----------------------
 fs/gfs2/bmap.c    | 12 ++++++------
 fs/gfs2/file.c    | 16 ++++++++--------
 fs/gfs2/meta_io.c |  4 ++--
 fs/gfs2/quota.c   | 14 +++++++-------
 fs/gfs2/rgrp.c    |  5 ++---
 6 files changed, 47 insertions(+), 48 deletions(-)

diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
index aa016e4b8bec..1bbbee945f46 100644
--- a/fs/gfs2/aops.c
+++ b/fs/gfs2/aops.c
@@ -101,7 +101,7 @@ static int gfs2_writepage_common(struct page *page,
 	struct gfs2_inode *ip = GFS2_I(inode);
 	struct gfs2_sbd *sdp = GFS2_SB(inode);
 	loff_t i_size = i_size_read(inode);
-	pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
+	pgoff_t end_index = i_size >> PAGE_SHIFT;
 	unsigned offset;
 
 	if (gfs2_assert_withdraw(sdp, gfs2_glock_is_held_excl(ip->i_gl)))
@@ -109,9 +109,9 @@ static int gfs2_writepage_common(struct page *page,
 	if (current->journal_info)
 		goto redirty;
 	/* Is the page fully outside i_size? (truncate in progress) */
-	offset = i_size & (PAGE_CACHE_SIZE-1);
+	offset = i_size & (PAGE_SIZE-1);
 	if (page->index > end_index || (page->index == end_index && !offset)) {
-		page->mapping->a_ops->invalidatepage(page, 0, PAGE_CACHE_SIZE);
+		page->mapping->a_ops->invalidatepage(page, 0, PAGE_SIZE);
 		goto out;
 	}
 	return 1;
@@ -238,7 +238,7 @@ static int gfs2_write_jdata_pagevec(struct address_space *mapping,
 {
 	struct inode *inode = mapping->host;
 	struct gfs2_sbd *sdp = GFS2_SB(inode);
-	unsigned nrblocks = nr_pages * (PAGE_CACHE_SIZE/inode->i_sb->s_blocksize);
+	unsigned nrblocks = nr_pages * (PAGE_SIZE/inode->i_sb->s_blocksize);
 	int i;
 	int ret;
 
@@ -366,8 +366,8 @@ static int gfs2_write_cache_jdata(struct address_space *mapping,
 			cycled = 0;
 		end = -1;
 	} else {
-		index = wbc->range_start >> PAGE_CACHE_SHIFT;
-		end = wbc->range_end >> PAGE_CACHE_SHIFT;
+		index = wbc->range_start >> PAGE_SHIFT;
+		end = wbc->range_end >> PAGE_SHIFT;
 		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
 			range_whole = 1;
 		cycled = 1; /* ignore range_cyclic tests */
@@ -458,7 +458,7 @@ static int stuffed_readpage(struct gfs2_inode *ip, struct page *page)
 	 * so we need to supply one here. It doesn't happen often.
 	 */
 	if (unlikely(page->index)) {
-		zero_user(page, 0, PAGE_CACHE_SIZE);
+		zero_user(page, 0, PAGE_SIZE);
 		SetPageUptodate(page);
 		return 0;
 	}
@@ -471,7 +471,7 @@ static int stuffed_readpage(struct gfs2_inode *ip, struct page *page)
 	if (dsize > (dibh->b_size - sizeof(struct gfs2_dinode)))
 		dsize = (dibh->b_size - sizeof(struct gfs2_dinode));
 	memcpy(kaddr, dibh->b_data + sizeof(struct gfs2_dinode), dsize);
-	memset(kaddr + dsize, 0, PAGE_CACHE_SIZE - dsize);
+	memset(kaddr + dsize, 0, PAGE_SIZE - dsize);
 	kunmap_atomic(kaddr);
 	flush_dcache_page(page);
 	brelse(dibh);
@@ -560,8 +560,8 @@ int gfs2_internal_read(struct gfs2_inode *ip, char *buf, loff_t *pos,
                        unsigned size)
 {
 	struct address_space *mapping = ip->i_inode.i_mapping;
-	unsigned long index = *pos / PAGE_CACHE_SIZE;
-	unsigned offset = *pos & (PAGE_CACHE_SIZE - 1);
+	unsigned long index = *pos / PAGE_SIZE;
+	unsigned offset = *pos & (PAGE_SIZE - 1);
 	unsigned copied = 0;
 	unsigned amt;
 	struct page *page;
@@ -569,15 +569,15 @@ int gfs2_internal_read(struct gfs2_inode *ip, char *buf, loff_t *pos,
 
 	do {
 		amt = size - copied;
-		if (offset + size > PAGE_CACHE_SIZE)
-			amt = PAGE_CACHE_SIZE - offset;
+		if (offset + size > PAGE_SIZE)
+			amt = PAGE_SIZE - offset;
 		page = read_cache_page(mapping, index, __gfs2_readpage, NULL);
 		if (IS_ERR(page))
 			return PTR_ERR(page);
 		p = kmap_atomic(page);
 		memcpy(buf + copied, p + offset, amt);
 		kunmap_atomic(p);
-		page_cache_release(page);
+		put_page(page);
 		copied += amt;
 		index++;
 		offset = 0;
@@ -651,8 +651,8 @@ static int gfs2_write_begin(struct file *file, struct address_space *mapping,
 	unsigned requested = 0;
 	int alloc_required;
 	int error = 0;
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
-	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+	pgoff_t index = pos >> PAGE_SHIFT;
+	unsigned from = pos & (PAGE_SIZE - 1);
 	struct page *page;
 
 	gfs2_holder_init(ip->i_gl, LM_ST_EXCLUSIVE, 0, &ip->i_gh);
@@ -697,7 +697,7 @@ static int gfs2_write_begin(struct file *file, struct address_space *mapping,
 		rblocks += gfs2_rg_blocks(ip, requested);
 
 	error = gfs2_trans_begin(sdp, rblocks,
-				 PAGE_CACHE_SIZE/sdp->sd_sb.sb_bsize);
+				 PAGE_SIZE/sdp->sd_sb.sb_bsize);
 	if (error)
 		goto out_trans_fail;
 
@@ -727,7 +727,7 @@ out:
 		return 0;
 
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	gfs2_trans_end(sdp);
 	if (pos + len > ip->i_inode.i_size)
@@ -827,7 +827,7 @@ static int gfs2_stuffed_write_end(struct inode *inode, struct buffer_head *dibh,
 	if (!PageUptodate(page))
 		SetPageUptodate(page);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	if (copied) {
 		if (inode->i_size < to)
@@ -877,7 +877,7 @@ static int gfs2_write_end(struct file *file, struct address_space *mapping,
 	struct gfs2_sbd *sdp = GFS2_SB(inode);
 	struct gfs2_inode *m_ip = GFS2_I(sdp->sd_statfs_inode);
 	struct buffer_head *dibh;
-	unsigned int from = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned int from = pos & (PAGE_SIZE - 1);
 	unsigned int to = from + len;
 	int ret;
 	struct gfs2_trans *tr = current->journal_info;
@@ -888,7 +888,7 @@ static int gfs2_write_end(struct file *file, struct address_space *mapping,
 	ret = gfs2_meta_inode_buffer(ip, &dibh);
 	if (unlikely(ret)) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		goto failed;
 	}
 
@@ -992,7 +992,7 @@ static void gfs2_invalidatepage(struct page *page, unsigned int offset,
 {
 	struct gfs2_sbd *sdp = GFS2_SB(page->mapping->host);
 	unsigned int stop = offset + length;
-	int partial_page = (offset || length < PAGE_CACHE_SIZE);
+	int partial_page = (offset || length < PAGE_SIZE);
 	struct buffer_head *bh, *head;
 	unsigned long pos = 0;
 
@@ -1082,7 +1082,7 @@ static ssize_t gfs2_direct_IO(struct kiocb *iocb, struct iov_iter *iter,
 	 * the first place, mapping->nr_pages will always be zero.
 	 */
 	if (mapping->nrpages) {
-		loff_t lstart = offset & ~(PAGE_CACHE_SIZE - 1);
+		loff_t lstart = offset & ~(PAGE_SIZE - 1);
 		loff_t len = iov_iter_count(iter);
 		loff_t end = PAGE_ALIGN(offset + len) - 1;
 
diff --git a/fs/gfs2/bmap.c b/fs/gfs2/bmap.c
index 0860f0b5b3f1..24ce1cdd434a 100644
--- a/fs/gfs2/bmap.c
+++ b/fs/gfs2/bmap.c
@@ -75,7 +75,7 @@ static int gfs2_unstuffer_page(struct gfs2_inode *ip, struct buffer_head *dibh,
 			dsize = dibh->b_size - sizeof(struct gfs2_dinode);
 
 		memcpy(kaddr, dibh->b_data + sizeof(struct gfs2_dinode), dsize);
-		memset(kaddr + dsize, 0, PAGE_CACHE_SIZE - dsize);
+		memset(kaddr + dsize, 0, PAGE_SIZE - dsize);
 		kunmap(page);
 
 		SetPageUptodate(page);
@@ -98,7 +98,7 @@ static int gfs2_unstuffer_page(struct gfs2_inode *ip, struct buffer_head *dibh,
 
 	if (release) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	return 0;
@@ -932,8 +932,8 @@ static int gfs2_block_truncate_page(struct address_space *mapping, loff_t from)
 {
 	struct inode *inode = mapping->host;
 	struct gfs2_inode *ip = GFS2_I(inode);
-	unsigned long index = from >> PAGE_CACHE_SHIFT;
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	unsigned long index = from >> PAGE_SHIFT;
+	unsigned offset = from & (PAGE_SIZE-1);
 	unsigned blocksize, iblock, length, pos;
 	struct buffer_head *bh;
 	struct page *page;
@@ -945,7 +945,7 @@ static int gfs2_block_truncate_page(struct address_space *mapping, loff_t from)
 
 	blocksize = inode->i_sb->s_blocksize;
 	length = blocksize - (offset & (blocksize - 1));
-	iblock = index << (PAGE_CACHE_SHIFT - inode->i_sb->s_blocksize_bits);
+	iblock = index << (PAGE_SHIFT - inode->i_sb->s_blocksize_bits);
 
 	if (!page_has_buffers(page))
 		create_empty_buffers(page, blocksize, 0);
@@ -989,7 +989,7 @@ static int gfs2_block_truncate_page(struct address_space *mapping, loff_t from)
 	mark_buffer_dirty(bh);
 unlock:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return err;
 }
 
diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index c9384f932975..208efc70ad49 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -354,8 +354,8 @@ static int gfs2_allocate_page_backing(struct page *page)
 {
 	struct inode *inode = page->mapping->host;
 	struct buffer_head bh;
-	unsigned long size = PAGE_CACHE_SIZE;
-	u64 lblock = page->index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+	unsigned long size = PAGE_SIZE;
+	u64 lblock = page->index << (PAGE_SHIFT - inode->i_blkbits);
 
 	do {
 		bh.b_state = 0;
@@ -386,7 +386,7 @@ static int gfs2_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct gfs2_sbd *sdp = GFS2_SB(inode);
 	struct gfs2_alloc_parms ap = { .aflags = 0, };
 	unsigned long last_index;
-	u64 pos = page->index << PAGE_CACHE_SHIFT;
+	u64 pos = page->index << PAGE_SHIFT;
 	unsigned int data_blocks, ind_blocks, rblocks;
 	struct gfs2_holder gh;
 	loff_t size;
@@ -401,7 +401,7 @@ static int gfs2_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	if (ret)
 		goto out;
 
-	gfs2_size_hint(vma->vm_file, pos, PAGE_CACHE_SIZE);
+	gfs2_size_hint(vma->vm_file, pos, PAGE_SIZE);
 
 	gfs2_holder_init(ip->i_gl, LM_ST_EXCLUSIVE, 0, &gh);
 	ret = gfs2_glock_nq(&gh);
@@ -411,7 +411,7 @@ static int gfs2_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	set_bit(GLF_DIRTY, &ip->i_gl->gl_flags);
 	set_bit(GIF_SW_PAGED, &ip->i_flags);
 
-	if (!gfs2_write_alloc_required(ip, pos, PAGE_CACHE_SIZE)) {
+	if (!gfs2_write_alloc_required(ip, pos, PAGE_SIZE)) {
 		lock_page(page);
 		if (!PageUptodate(page) || page->mapping != inode->i_mapping) {
 			ret = -EAGAIN;
@@ -424,7 +424,7 @@ static int gfs2_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	if (ret)
 		goto out_unlock;
 
-	gfs2_write_calc_reserv(ip, PAGE_CACHE_SIZE, &data_blocks, &ind_blocks);
+	gfs2_write_calc_reserv(ip, PAGE_SIZE, &data_blocks, &ind_blocks);
 	ap.target = data_blocks + ind_blocks;
 	ret = gfs2_quota_lock_check(ip, &ap);
 	if (ret)
@@ -447,7 +447,7 @@ static int gfs2_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	lock_page(page);
 	ret = -EINVAL;
 	size = i_size_read(inode);
-	last_index = (size - 1) >> PAGE_CACHE_SHIFT;
+	last_index = (size - 1) >> PAGE_SHIFT;
 	/* Check page index against inode size */
 	if (size == 0 || (page->index > last_index))
 		goto out_trans_end;
@@ -873,7 +873,7 @@ static long __gfs2_fallocate(struct file *file, int mode, loff_t offset, loff_t
 			rblocks += data_blocks ? data_blocks : 1;
 
 		error = gfs2_trans_begin(sdp, rblocks,
-					 PAGE_CACHE_SIZE/sdp->sd_sb.sb_bsize);
+					 PAGE_SIZE/sdp->sd_sb.sb_bsize);
 		if (error)
 			goto out_trans_fail;
 
diff --git a/fs/gfs2/meta_io.c b/fs/gfs2/meta_io.c
index e137d96f1b17..0448524c11bc 100644
--- a/fs/gfs2/meta_io.c
+++ b/fs/gfs2/meta_io.c
@@ -124,7 +124,7 @@ struct buffer_head *gfs2_getbuf(struct gfs2_glock *gl, u64 blkno, int create)
 	if (mapping == NULL)
 		mapping = &sdp->sd_aspace;
 
-	shift = PAGE_CACHE_SHIFT - sdp->sd_sb.sb_bsize_shift;
+	shift = PAGE_SHIFT - sdp->sd_sb.sb_bsize_shift;
 	index = blkno >> shift;             /* convert block to page */
 	bufnum = blkno - (index << shift);  /* block buf index within page */
 
@@ -154,7 +154,7 @@ struct buffer_head *gfs2_getbuf(struct gfs2_glock *gl, u64 blkno, int create)
 		map_bh(bh, sdp->sd_vfs, blkno);
 
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return bh;
 }
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index a39891344259..ce7d69a2fdc0 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -701,7 +701,7 @@ static int gfs2_write_buf_to_page(struct gfs2_inode *ip, unsigned long index,
 	unsigned to_write = bytes, pg_off = off;
 	int done = 0;
 
-	blk = index << (PAGE_CACHE_SHIFT - sdp->sd_sb.sb_bsize_shift);
+	blk = index << (PAGE_SHIFT - sdp->sd_sb.sb_bsize_shift);
 	boff = off % bsize;
 
 	page = find_or_create_page(mapping, index, GFP_NOFS);
@@ -753,13 +753,13 @@ static int gfs2_write_buf_to_page(struct gfs2_inode *ip, unsigned long index,
 	flush_dcache_page(page);
 	kunmap_atomic(kaddr);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return 0;
 
 unlock_out:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return -EIO;
 }
 
@@ -773,13 +773,13 @@ static int gfs2_write_disk_quota(struct gfs2_inode *ip, struct gfs2_quota *qp,
 
 	nbytes = sizeof(struct gfs2_quota);
 
-	pg_beg = loc >> PAGE_CACHE_SHIFT;
-	pg_off = loc % PAGE_CACHE_SIZE;
+	pg_beg = loc >> PAGE_SHIFT;
+	pg_off = loc % PAGE_SIZE;
 
 	/* If the quota straddles a page boundary, split the write in two */
-	if ((pg_off + nbytes) > PAGE_CACHE_SIZE) {
+	if ((pg_off + nbytes) > PAGE_SIZE) {
 		pg_oflow = 1;
-		overflow = (pg_off + nbytes) - PAGE_CACHE_SIZE;
+		overflow = (pg_off + nbytes) - PAGE_SIZE;
 	}
 
 	ptr = qp;
diff --git a/fs/gfs2/rgrp.c b/fs/gfs2/rgrp.c
index 07c0265aa195..99a0bdac8796 100644
--- a/fs/gfs2/rgrp.c
+++ b/fs/gfs2/rgrp.c
@@ -918,9 +918,8 @@ static int read_rindex_entry(struct gfs2_inode *ip)
 		goto fail;
 
 	rgd->rd_gl->gl_object = rgd;
-	rgd->rd_gl->gl_vm.start = (rgd->rd_addr * bsize) & PAGE_CACHE_MASK;
-	rgd->rd_gl->gl_vm.end = PAGE_CACHE_ALIGN((rgd->rd_addr +
-						  rgd->rd_length) * bsize) - 1;
+	rgd->rd_gl->gl_vm.start = (rgd->rd_addr * bsize) & PAGE_MASK;
+	rgd->rd_gl->gl_vm.end = PAGE_ALIGN((rgd->rd_addr + rgd->rd_length) * bsize) - 1;
 	rgd->rd_rgl = (struct gfs2_rgrp_lvb *)rgd->rd_gl->gl_lksb.sb_lvbptr;
 	rgd->rd_flags &= ~(GFS2_RDF_UPTODATE | GFS2_RDF_PREFERRED);
 	if (rgd->rd_data > sdp->sd_max_rg_data)
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
