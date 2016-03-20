Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5E1E082F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:50:06 -0400 (EDT)
Received: by mail-pf0-f171.google.com with SMTP id n5so237583810pfn.2
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:50:06 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id oi7si1467849pab.183.2016.03.20.11.41.50
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:50 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 51/71] nilfs2: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:58 +0300
Message-Id: <1458499278-1516-52-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>

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
Cc: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
---
 fs/nilfs2/bmap.c          |  2 +-
 fs/nilfs2/btnode.c        | 10 +++++-----
 fs/nilfs2/dir.c           | 32 ++++++++++++++++----------------
 fs/nilfs2/gcinode.c       |  2 +-
 fs/nilfs2/inode.c         |  4 ++--
 fs/nilfs2/mdt.c           | 14 +++++++-------
 fs/nilfs2/namei.c         |  4 ++--
 fs/nilfs2/page.c          | 18 +++++++++---------
 fs/nilfs2/recovery.c      |  4 ++--
 fs/nilfs2/segment.c       |  2 +-
 include/linux/nilfs2_fs.h |  4 ++--
 11 files changed, 48 insertions(+), 48 deletions(-)

diff --git a/fs/nilfs2/bmap.c b/fs/nilfs2/bmap.c
index 27f75bcbeb30..a9fb3636c142 100644
--- a/fs/nilfs2/bmap.c
+++ b/fs/nilfs2/bmap.c
@@ -458,7 +458,7 @@ __u64 nilfs_bmap_data_get_key(const struct nilfs_bmap *bmap,
 	struct buffer_head *pbh;
 	__u64 key;
 
-	key = page_index(bh->b_page) << (PAGE_CACHE_SHIFT -
+	key = page_index(bh->b_page) << (PAGE_SHIFT -
 					 bmap->b_inode->i_blkbits);
 	for (pbh = page_buffers(bh->b_page); pbh != bh; pbh = pbh->b_this_page)
 		key++;
diff --git a/fs/nilfs2/btnode.c b/fs/nilfs2/btnode.c
index a35ae35e6932..e0c9daf9aa22 100644
--- a/fs/nilfs2/btnode.c
+++ b/fs/nilfs2/btnode.c
@@ -62,7 +62,7 @@ nilfs_btnode_create_block(struct address_space *btnc, __u64 blocknr)
 	set_buffer_uptodate(bh);
 
 	unlock_page(bh->b_page);
-	page_cache_release(bh->b_page);
+	put_page(bh->b_page);
 	return bh;
 }
 
@@ -128,7 +128,7 @@ found:
 
 out_locked:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return err;
 }
 
@@ -146,7 +146,7 @@ void nilfs_btnode_delete(struct buffer_head *bh)
 	pgoff_t index = page_index(page);
 	int still_dirty;
 
-	page_cache_get(page);
+	get_page(page);
 	lock_page(page);
 	wait_on_page_writeback(page);
 
@@ -154,7 +154,7 @@ void nilfs_btnode_delete(struct buffer_head *bh)
 	still_dirty = PageDirty(page);
 	mapping = page->mapping;
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	if (!still_dirty && mapping)
 		invalidate_inode_pages2_range(mapping, index, index);
@@ -181,7 +181,7 @@ int nilfs_btnode_prepare_change_key(struct address_space *btnc,
 	obh = ctxt->bh;
 	ctxt->newbh = NULL;
 
-	if (inode->i_blkbits == PAGE_CACHE_SHIFT) {
+	if (inode->i_blkbits == PAGE_SHIFT) {
 		lock_page(obh->b_page);
 		/*
 		 * We cannot call radix_tree_preload for the kernels older
diff --git a/fs/nilfs2/dir.c b/fs/nilfs2/dir.c
index 6b8b92b19cec..e08f064e4bd7 100644
--- a/fs/nilfs2/dir.c
+++ b/fs/nilfs2/dir.c
@@ -58,7 +58,7 @@ static inline unsigned nilfs_chunk_size(struct inode *inode)
 static inline void nilfs_put_page(struct page *page)
 {
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 /*
@@ -69,9 +69,9 @@ static unsigned nilfs_last_byte(struct inode *inode, unsigned long page_nr)
 {
 	unsigned last_byte = inode->i_size;
 
-	last_byte -= page_nr << PAGE_CACHE_SHIFT;
-	if (last_byte > PAGE_CACHE_SIZE)
-		last_byte = PAGE_CACHE_SIZE;
+	last_byte -= page_nr << PAGE_SHIFT;
+	if (last_byte > PAGE_SIZE)
+		last_byte = PAGE_SIZE;
 	return last_byte;
 }
 
@@ -109,12 +109,12 @@ static void nilfs_check_page(struct page *page)
 	unsigned chunk_size = nilfs_chunk_size(dir);
 	char *kaddr = page_address(page);
 	unsigned offs, rec_len;
-	unsigned limit = PAGE_CACHE_SIZE;
+	unsigned limit = PAGE_SIZE;
 	struct nilfs_dir_entry *p;
 	char *error;
 
-	if ((dir->i_size >> PAGE_CACHE_SHIFT) == page->index) {
-		limit = dir->i_size & ~PAGE_CACHE_MASK;
+	if ((dir->i_size >> PAGE_SHIFT) == page->index) {
+		limit = dir->i_size & ~PAGE_MASK;
 		if (limit & (chunk_size - 1))
 			goto Ebadsize;
 		if (!limit)
@@ -161,7 +161,7 @@ Espan:
 bad_entry:
 	nilfs_error(sb, "nilfs_check_page", "bad entry in directory #%lu: %s - "
 		    "offset=%lu, inode=%lu, rec_len=%d, name_len=%d",
-		    dir->i_ino, error, (page->index<<PAGE_CACHE_SHIFT)+offs,
+		    dir->i_ino, error, (page->index<<PAGE_SHIFT)+offs,
 		    (unsigned long) le64_to_cpu(p->inode),
 		    rec_len, p->name_len);
 	goto fail;
@@ -170,7 +170,7 @@ Eend:
 	nilfs_error(sb, "nilfs_check_page",
 		    "entry in directory #%lu spans the page boundary"
 		    "offset=%lu, inode=%lu",
-		    dir->i_ino, (page->index<<PAGE_CACHE_SHIFT)+offs,
+		    dir->i_ino, (page->index<<PAGE_SHIFT)+offs,
 		    (unsigned long) le64_to_cpu(p->inode));
 fail:
 	SetPageChecked(page);
@@ -256,8 +256,8 @@ static int nilfs_readdir(struct file *file, struct dir_context *ctx)
 	loff_t pos = ctx->pos;
 	struct inode *inode = file_inode(file);
 	struct super_block *sb = inode->i_sb;
-	unsigned int offset = pos & ~PAGE_CACHE_MASK;
-	unsigned long n = pos >> PAGE_CACHE_SHIFT;
+	unsigned int offset = pos & ~PAGE_MASK;
+	unsigned long n = pos >> PAGE_SHIFT;
 	unsigned long npages = dir_pages(inode);
 /*	unsigned chunk_mask = ~(nilfs_chunk_size(inode)-1); */
 
@@ -272,7 +272,7 @@ static int nilfs_readdir(struct file *file, struct dir_context *ctx)
 		if (IS_ERR(page)) {
 			nilfs_error(sb, __func__, "bad page in #%lu",
 				    inode->i_ino);
-			ctx->pos += PAGE_CACHE_SIZE - offset;
+			ctx->pos += PAGE_SIZE - offset;
 			return -EIO;
 		}
 		kaddr = page_address(page);
@@ -361,7 +361,7 @@ nilfs_find_entry(struct inode *dir, const struct qstr *qstr,
 		if (++n >= npages)
 			n = 0;
 		/* next page is past the blocks we've got */
-		if (unlikely(n > (dir->i_blocks >> (PAGE_CACHE_SHIFT - 9)))) {
+		if (unlikely(n > (dir->i_blocks >> (PAGE_SHIFT - 9)))) {
 			nilfs_error(dir->i_sb, __func__,
 			       "dir %lu size %lld exceeds block count %llu",
 			       dir->i_ino, dir->i_size,
@@ -401,7 +401,7 @@ ino_t nilfs_inode_by_name(struct inode *dir, const struct qstr *qstr)
 	if (de) {
 		res = le64_to_cpu(de->inode);
 		kunmap(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	return res;
 }
@@ -460,7 +460,7 @@ int nilfs_add_link(struct dentry *dentry, struct inode *inode)
 		kaddr = page_address(page);
 		dir_end = kaddr + nilfs_last_byte(dir, n);
 		de = (struct nilfs_dir_entry *)kaddr;
-		kaddr += PAGE_CACHE_SIZE - reclen;
+		kaddr += PAGE_SIZE - reclen;
 		while ((char *)de <= kaddr) {
 			if ((char *)de == dir_end) {
 				/* We hit i_size */
@@ -603,7 +603,7 @@ int nilfs_make_empty(struct inode *inode, struct inode *parent)
 	kunmap_atomic(kaddr);
 	nilfs_commit_chunk(page, mapping, 0, chunk_size);
 fail:
-	page_cache_release(page);
+	put_page(page);
 	return err;
 }
 
diff --git a/fs/nilfs2/gcinode.c b/fs/nilfs2/gcinode.c
index 748ca238915a..0224b7826ace 100644
--- a/fs/nilfs2/gcinode.c
+++ b/fs/nilfs2/gcinode.c
@@ -115,7 +115,7 @@ int nilfs_gccache_submit_read_data(struct inode *inode, sector_t blkoff,
 
  failed:
 	unlock_page(bh->b_page);
-	page_cache_release(bh->b_page);
+	put_page(bh->b_page);
 	return err;
 }
 
diff --git a/fs/nilfs2/inode.c b/fs/nilfs2/inode.c
index 21a1e2e0d92f..534631358b13 100644
--- a/fs/nilfs2/inode.c
+++ b/fs/nilfs2/inode.c
@@ -249,7 +249,7 @@ static int nilfs_set_page_dirty(struct page *page)
 		if (nr_dirty)
 			nilfs_set_file_dirty(inode, nr_dirty);
 	} else if (ret) {
-		unsigned nr_dirty = 1 << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+		unsigned nr_dirty = 1 << (PAGE_SHIFT - inode->i_blkbits);
 
 		nilfs_set_file_dirty(inode, nr_dirty);
 	}
@@ -291,7 +291,7 @@ static int nilfs_write_end(struct file *file, struct address_space *mapping,
 			   struct page *page, void *fsdata)
 {
 	struct inode *inode = mapping->host;
-	unsigned start = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned start = pos & (PAGE_SIZE - 1);
 	unsigned nr_dirty;
 	int err;
 
diff --git a/fs/nilfs2/mdt.c b/fs/nilfs2/mdt.c
index 1125f40233ff..f6982b9153d5 100644
--- a/fs/nilfs2/mdt.c
+++ b/fs/nilfs2/mdt.c
@@ -110,7 +110,7 @@ static int nilfs_mdt_create_block(struct inode *inode, unsigned long block,
 
  failed_bh:
 	unlock_page(bh->b_page);
-	page_cache_release(bh->b_page);
+	put_page(bh->b_page);
 	brelse(bh);
 
  failed_unlock:
@@ -170,7 +170,7 @@ nilfs_mdt_submit_block(struct inode *inode, unsigned long blkoff,
 
  failed_bh:
 	unlock_page(bh->b_page);
-	page_cache_release(bh->b_page);
+	put_page(bh->b_page);
 	brelse(bh);
  failed:
 	return ret;
@@ -363,7 +363,7 @@ int nilfs_mdt_delete_block(struct inode *inode, unsigned long block)
 int nilfs_mdt_forget_block(struct inode *inode, unsigned long block)
 {
 	pgoff_t index = (pgoff_t)block >>
-		(PAGE_CACHE_SHIFT - inode->i_blkbits);
+		(PAGE_SHIFT - inode->i_blkbits);
 	struct page *page;
 	unsigned long first_block;
 	int ret = 0;
@@ -376,7 +376,7 @@ int nilfs_mdt_forget_block(struct inode *inode, unsigned long block)
 	wait_on_page_writeback(page);
 
 	first_block = (unsigned long)index <<
-		(PAGE_CACHE_SHIFT - inode->i_blkbits);
+		(PAGE_SHIFT - inode->i_blkbits);
 	if (page_has_buffers(page)) {
 		struct buffer_head *bh;
 
@@ -385,7 +385,7 @@ int nilfs_mdt_forget_block(struct inode *inode, unsigned long block)
 	}
 	still_dirty = PageDirty(page);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	if (still_dirty ||
 	    invalidate_inode_pages2_range(inode->i_mapping, index, index) != 0)
@@ -578,7 +578,7 @@ int nilfs_mdt_freeze_buffer(struct inode *inode, struct buffer_head *bh)
 	}
 
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return 0;
 }
 
@@ -597,7 +597,7 @@ nilfs_mdt_get_frozen_buffer(struct inode *inode, struct buffer_head *bh)
 			bh_frozen = nilfs_page_get_nth_block(page, n);
 		}
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	return bh_frozen;
 }
diff --git a/fs/nilfs2/namei.c b/fs/nilfs2/namei.c
index 7ccdb961eea9..151bc19d47c0 100644
--- a/fs/nilfs2/namei.c
+++ b/fs/nilfs2/namei.c
@@ -431,11 +431,11 @@ static int nilfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 out_dir:
 	if (dir_de) {
 		kunmap(dir_page);
-		page_cache_release(dir_page);
+		put_page(dir_page);
 	}
 out_old:
 	kunmap(old_page);
-	page_cache_release(old_page);
+	put_page(old_page);
 out:
 	nilfs_transaction_abort(old_dir->i_sb);
 	return err;
diff --git a/fs/nilfs2/page.c b/fs/nilfs2/page.c
index c20df77eff99..489391561cda 100644
--- a/fs/nilfs2/page.c
+++ b/fs/nilfs2/page.c
@@ -50,7 +50,7 @@ __nilfs_get_page_block(struct page *page, unsigned long block, pgoff_t index,
 	if (!page_has_buffers(page))
 		create_empty_buffers(page, 1 << blkbits, b_state);
 
-	first_block = (unsigned long)index << (PAGE_CACHE_SHIFT - blkbits);
+	first_block = (unsigned long)index << (PAGE_SHIFT - blkbits);
 	bh = nilfs_page_get_nth_block(page, block - first_block);
 
 	touch_buffer(bh);
@@ -64,7 +64,7 @@ struct buffer_head *nilfs_grab_buffer(struct inode *inode,
 				      unsigned long b_state)
 {
 	int blkbits = inode->i_blkbits;
-	pgoff_t index = blkoff >> (PAGE_CACHE_SHIFT - blkbits);
+	pgoff_t index = blkoff >> (PAGE_SHIFT - blkbits);
 	struct page *page;
 	struct buffer_head *bh;
 
@@ -75,7 +75,7 @@ struct buffer_head *nilfs_grab_buffer(struct inode *inode,
 	bh = __nilfs_get_page_block(page, blkoff, index, blkbits, b_state);
 	if (unlikely(!bh)) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		return NULL;
 	}
 	return bh;
@@ -288,7 +288,7 @@ repeat:
 		__set_page_dirty_nobuffers(dpage);
 
 		unlock_page(dpage);
-		page_cache_release(dpage);
+		put_page(dpage);
 		unlock_page(page);
 	}
 	pagevec_release(&pvec);
@@ -333,7 +333,7 @@ repeat:
 			WARN_ON(PageDirty(dpage));
 			nilfs_copy_page(dpage, page, 0);
 			unlock_page(dpage);
-			page_cache_release(dpage);
+			put_page(dpage);
 		} else {
 			struct page *page2;
 
@@ -350,7 +350,7 @@ repeat:
 			if (unlikely(err < 0)) {
 				WARN_ON(err == -EEXIST);
 				page->mapping = NULL;
-				page_cache_release(page); /* for cache */
+				put_page(page); /* for cache */
 			} else {
 				page->mapping = dmap;
 				dmap->nrpages++;
@@ -523,8 +523,8 @@ unsigned long nilfs_find_uncommitted_extent(struct inode *inode,
 	if (inode->i_mapping->nrpages == 0)
 		return 0;
 
-	index = start_blk >> (PAGE_CACHE_SHIFT - inode->i_blkbits);
-	nblocks_in_page = 1U << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+	index = start_blk >> (PAGE_SHIFT - inode->i_blkbits);
+	nblocks_in_page = 1U << (PAGE_SHIFT - inode->i_blkbits);
 
 	pagevec_init(&pvec, 0);
 
@@ -537,7 +537,7 @@ repeat:
 	if (length > 0 && pvec.pages[0]->index > index)
 		goto out;
 
-	b = pvec.pages[0]->index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+	b = pvec.pages[0]->index << (PAGE_SHIFT - inode->i_blkbits);
 	i = 0;
 	do {
 		page = pvec.pages[i];
diff --git a/fs/nilfs2/recovery.c b/fs/nilfs2/recovery.c
index 9b4f205d1173..5afa77fadc11 100644
--- a/fs/nilfs2/recovery.c
+++ b/fs/nilfs2/recovery.c
@@ -544,14 +544,14 @@ static int nilfs_recover_dsync_blocks(struct the_nilfs *nilfs,
 				blocksize, page, NULL);
 
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 
 		(*nr_salvaged_blocks)++;
 		goto next;
 
  failed_page:
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 
  failed_inode:
 		printk(KERN_WARNING
diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
index 3b65adaae7e4..4317f72568e6 100644
--- a/fs/nilfs2/segment.c
+++ b/fs/nilfs2/segment.c
@@ -2070,7 +2070,7 @@ static int nilfs_segctor_do_construct(struct nilfs_sc_info *sci, int mode)
 			goto failed_to_write;
 
 		if (nilfs_sc_cstage_get(sci) == NILFS_ST_DONE ||
-		    nilfs->ns_blocksize_bits != PAGE_CACHE_SHIFT) {
+		    nilfs->ns_blocksize_bits != PAGE_SHIFT) {
 			/*
 			 * At this point, we avoid double buffering
 			 * for blocksize < pagesize because page dirty
diff --git a/include/linux/nilfs2_fs.h b/include/linux/nilfs2_fs.h
index 9abb763e4b86..e9fcf90b270d 100644
--- a/include/linux/nilfs2_fs.h
+++ b/include/linux/nilfs2_fs.h
@@ -331,7 +331,7 @@ static inline unsigned nilfs_rec_len_from_disk(__le16 dlen)
 {
 	unsigned len = le16_to_cpu(dlen);
 
-#if !defined(__KERNEL__) || (PAGE_CACHE_SIZE >= 65536)
+#if !defined(__KERNEL__) || (PAGE_SIZE >= 65536)
 	if (len == NILFS_MAX_REC_LEN)
 		return 1 << 16;
 #endif
@@ -340,7 +340,7 @@ static inline unsigned nilfs_rec_len_from_disk(__le16 dlen)
 
 static inline __le16 nilfs_rec_len_to_disk(unsigned len)
 {
-#if !defined(__KERNEL__) || (PAGE_CACHE_SIZE >= 65536)
+#if !defined(__KERNEL__) || (PAGE_SIZE >= 65536)
 	if (len == (1 << 16))
 		return cpu_to_le16(NILFS_MAX_REC_LEN);
 	else if (len > (1 << 16))
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
