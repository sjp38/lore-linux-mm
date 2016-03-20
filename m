Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 93D3E828F4
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:42:25 -0400 (EDT)
Received: by mail-pf0-f174.google.com with SMTP id n5so237453491pfn.2
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:42:25 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id p86si16668950pfa.161.2016.03.20.11.42.14
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:42:14 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 53/71] ocfs2: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:41:00 +0300
Message-Id: <1458499278-1516-54-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>

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
Cc: Mark Fasheh <mfasheh@suse.com>
Cc: Joel Becker <jlbec@evilplan.org>
---
 fs/ocfs2/alloc.c             | 28 +++++++++++++-------------
 fs/ocfs2/aops.c              | 48 ++++++++++++++++++++++----------------------
 fs/ocfs2/cluster/heartbeat.c | 10 ++++-----
 fs/ocfs2/dlmfs/dlmfs.c       |  4 ++--
 fs/ocfs2/file.c              | 14 ++++++-------
 fs/ocfs2/mmap.c              |  6 +++---
 fs/ocfs2/ocfs2.h             | 20 +++++++++---------
 fs/ocfs2/refcounttree.c      | 24 +++++++++++-----------
 fs/ocfs2/super.c             |  4 ++--
 9 files changed, 79 insertions(+), 79 deletions(-)

diff --git a/fs/ocfs2/alloc.c b/fs/ocfs2/alloc.c
index d002579c6f2b..7b45d061096e 100644
--- a/fs/ocfs2/alloc.c
+++ b/fs/ocfs2/alloc.c
@@ -6648,7 +6648,7 @@ static void ocfs2_zero_cluster_pages(struct inode *inode, loff_t start,
 {
 	int i;
 	struct page *page;
-	unsigned int from, to = PAGE_CACHE_SIZE;
+	unsigned int from, to = PAGE_SIZE;
 	struct super_block *sb = inode->i_sb;
 
 	BUG_ON(!ocfs2_sparse_alloc(OCFS2_SB(sb)));
@@ -6656,21 +6656,21 @@ static void ocfs2_zero_cluster_pages(struct inode *inode, loff_t start,
 	if (numpages == 0)
 		goto out;
 
-	to = PAGE_CACHE_SIZE;
+	to = PAGE_SIZE;
 	for(i = 0; i < numpages; i++) {
 		page = pages[i];
 
-		from = start & (PAGE_CACHE_SIZE - 1);
-		if ((end >> PAGE_CACHE_SHIFT) == page->index)
-			to = end & (PAGE_CACHE_SIZE - 1);
+		from = start & (PAGE_SIZE - 1);
+		if ((end >> PAGE_SHIFT) == page->index)
+			to = end & (PAGE_SIZE - 1);
 
-		BUG_ON(from > PAGE_CACHE_SIZE);
-		BUG_ON(to > PAGE_CACHE_SIZE);
+		BUG_ON(from > PAGE_SIZE);
+		BUG_ON(to > PAGE_SIZE);
 
 		ocfs2_map_and_dirty_page(inode, handle, from, to, page, 1,
 					 &phys);
 
-		start = (page->index + 1) << PAGE_CACHE_SHIFT;
+		start = (page->index + 1) << PAGE_SHIFT;
 	}
 out:
 	if (pages)
@@ -6689,7 +6689,7 @@ int ocfs2_grab_pages(struct inode *inode, loff_t start, loff_t end,
 
 	numpages = 0;
 	last_page_bytes = PAGE_ALIGN(end);
-	index = start >> PAGE_CACHE_SHIFT;
+	index = start >> PAGE_SHIFT;
 	do {
 		pages[numpages] = find_or_create_page(mapping, index, GFP_NOFS);
 		if (!pages[numpages]) {
@@ -6700,7 +6700,7 @@ int ocfs2_grab_pages(struct inode *inode, loff_t start, loff_t end,
 
 		numpages++;
 		index++;
-	} while (index < (last_page_bytes >> PAGE_CACHE_SHIFT));
+	} while (index < (last_page_bytes >> PAGE_SHIFT));
 
 out:
 	if (ret != 0) {
@@ -6927,8 +6927,8 @@ int ocfs2_convert_inline_data_to_extents(struct inode *inode,
 		 * to do that now.
 		 */
 		if (!ocfs2_sparse_alloc(osb) &&
-		    PAGE_CACHE_SIZE < osb->s_clustersize)
-			end = PAGE_CACHE_SIZE;
+		    PAGE_SIZE < osb->s_clustersize)
+			end = PAGE_SIZE;
 
 		ret = ocfs2_grab_eof_pages(inode, 0, end, pages, &num_pages);
 		if (ret) {
@@ -6948,8 +6948,8 @@ int ocfs2_convert_inline_data_to_extents(struct inode *inode,
 			goto out_unlock;
 		}
 
-		page_end = PAGE_CACHE_SIZE;
-		if (PAGE_CACHE_SIZE > osb->s_clustersize)
+		page_end = PAGE_SIZE;
+		if (PAGE_SIZE > osb->s_clustersize)
 			page_end = osb->s_clustersize;
 
 		for (i = 0; i < num_pages; i++)
diff --git a/fs/ocfs2/aops.c b/fs/ocfs2/aops.c
index cda0361e95a4..af9298370d98 100644
--- a/fs/ocfs2/aops.c
+++ b/fs/ocfs2/aops.c
@@ -234,7 +234,7 @@ int ocfs2_read_inline_data(struct inode *inode, struct page *page,
 
 	size = i_size_read(inode);
 
-	if (size > PAGE_CACHE_SIZE ||
+	if (size > PAGE_SIZE ||
 	    size > ocfs2_max_inline_data_with_xattr(inode->i_sb, di)) {
 		ocfs2_error(inode->i_sb,
 			    "Inode %llu has with inline data has bad size: %Lu\n",
@@ -247,7 +247,7 @@ int ocfs2_read_inline_data(struct inode *inode, struct page *page,
 	if (size)
 		memcpy(kaddr, di->id2.i_data.id_data, size);
 	/* Clear the remaining part of the page */
-	memset(kaddr + size, 0, PAGE_CACHE_SIZE - size);
+	memset(kaddr + size, 0, PAGE_SIZE - size);
 	flush_dcache_page(page);
 	kunmap_atomic(kaddr);
 
@@ -282,7 +282,7 @@ static int ocfs2_readpage(struct file *file, struct page *page)
 {
 	struct inode *inode = page->mapping->host;
 	struct ocfs2_inode_info *oi = OCFS2_I(inode);
-	loff_t start = (loff_t)page->index << PAGE_CACHE_SHIFT;
+	loff_t start = (loff_t)page->index << PAGE_SHIFT;
 	int ret, unlock = 1;
 
 	trace_ocfs2_readpage((unsigned long long)oi->ip_blkno,
@@ -385,7 +385,7 @@ static int ocfs2_readpages(struct file *filp, struct address_space *mapping,
 	 * drop out in that case as it's not worth handling here.
 	 */
 	last = list_entry(pages->prev, struct page, lru);
-	start = (loff_t)last->index << PAGE_CACHE_SHIFT;
+	start = (loff_t)last->index << PAGE_SHIFT;
 	if (start >= i_size_read(inode))
 		goto out_unlock;
 
@@ -1015,12 +1015,12 @@ static void ocfs2_figure_cluster_boundaries(struct ocfs2_super *osb,
 					    unsigned int *start,
 					    unsigned int *end)
 {
-	unsigned int cluster_start = 0, cluster_end = PAGE_CACHE_SIZE;
+	unsigned int cluster_start = 0, cluster_end = PAGE_SIZE;
 
-	if (unlikely(PAGE_CACHE_SHIFT > osb->s_clustersize_bits)) {
+	if (unlikely(PAGE_SHIFT > osb->s_clustersize_bits)) {
 		unsigned int cpp;
 
-		cpp = 1 << (PAGE_CACHE_SHIFT - osb->s_clustersize_bits);
+		cpp = 1 << (PAGE_SHIFT - osb->s_clustersize_bits);
 
 		cluster_start = cpos % cpp;
 		cluster_start = cluster_start << osb->s_clustersize_bits;
@@ -1188,13 +1188,13 @@ next_bh:
 	return ret;
 }
 
-#if (PAGE_CACHE_SIZE >= OCFS2_MAX_CLUSTERSIZE)
+#if (PAGE_SIZE >= OCFS2_MAX_CLUSTERSIZE)
 #define OCFS2_MAX_CTXT_PAGES	1
 #else
-#define OCFS2_MAX_CTXT_PAGES	(OCFS2_MAX_CLUSTERSIZE / PAGE_CACHE_SIZE)
+#define OCFS2_MAX_CTXT_PAGES	(OCFS2_MAX_CLUSTERSIZE / PAGE_SIZE)
 #endif
 
-#define OCFS2_MAX_CLUSTERS_PER_PAGE	(PAGE_CACHE_SIZE / OCFS2_MIN_CLUSTERSIZE)
+#define OCFS2_MAX_CLUSTERS_PER_PAGE	(PAGE_SIZE / OCFS2_MIN_CLUSTERSIZE)
 
 /*
  * Describe the state of a single cluster to be written to.
@@ -1277,7 +1277,7 @@ void ocfs2_unlock_and_free_pages(struct page **pages, int num_pages)
 		if (pages[i]) {
 			unlock_page(pages[i]);
 			mark_page_accessed(pages[i]);
-			page_cache_release(pages[i]);
+			put_page(pages[i]);
 		}
 	}
 }
@@ -1300,7 +1300,7 @@ static void ocfs2_unlock_pages(struct ocfs2_write_ctxt *wc)
 			}
 		}
 		mark_page_accessed(wc->w_target_page);
-		page_cache_release(wc->w_target_page);
+		put_page(wc->w_target_page);
 	}
 	ocfs2_unlock_and_free_pages(wc->w_pages, wc->w_num_pages);
 }
@@ -1330,7 +1330,7 @@ static int ocfs2_alloc_write_ctxt(struct ocfs2_write_ctxt **wcp,
 	get_bh(di_bh);
 	wc->w_di_bh = di_bh;
 
-	if (unlikely(PAGE_CACHE_SHIFT > osb->s_clustersize_bits))
+	if (unlikely(PAGE_SHIFT > osb->s_clustersize_bits))
 		wc->w_large_pages = 1;
 	else
 		wc->w_large_pages = 0;
@@ -1392,7 +1392,7 @@ static void ocfs2_write_failure(struct inode *inode,
 				loff_t user_pos, unsigned user_len)
 {
 	int i;
-	unsigned from = user_pos & (PAGE_CACHE_SIZE - 1),
+	unsigned from = user_pos & (PAGE_SIZE - 1),
 		to = user_pos + user_len;
 	struct page *tmppage;
 
@@ -1431,7 +1431,7 @@ static int ocfs2_prepare_page_for_write(struct inode *inode, u64 *p_blkno,
 			(page_offset(page) <= user_pos));
 
 	if (page == wc->w_target_page) {
-		map_from = user_pos & (PAGE_CACHE_SIZE - 1);
+		map_from = user_pos & (PAGE_SIZE - 1);
 		map_to = map_from + user_len;
 
 		if (new)
@@ -1505,7 +1505,7 @@ static int ocfs2_grab_pages_for_write(struct address_space *mapping,
 	struct inode *inode = mapping->host;
 	loff_t last_byte;
 
-	target_index = user_pos >> PAGE_CACHE_SHIFT;
+	target_index = user_pos >> PAGE_SHIFT;
 
 	/*
 	 * Figure out how many pages we'll be manipulating here. For
@@ -1524,7 +1524,7 @@ static int ocfs2_grab_pages_for_write(struct address_space *mapping,
 		 */
 		last_byte = max(user_pos + user_len, i_size_read(inode));
 		BUG_ON(last_byte < 1);
-		end_index = ((last_byte - 1) >> PAGE_CACHE_SHIFT) + 1;
+		end_index = ((last_byte - 1) >> PAGE_SHIFT) + 1;
 		if ((start + wc->w_num_pages) > end_index)
 			wc->w_num_pages = end_index - start;
 	} else {
@@ -1551,7 +1551,7 @@ static int ocfs2_grab_pages_for_write(struct address_space *mapping,
 				goto out;
 			}
 
-			page_cache_get(mmap_page);
+			get_page(mmap_page);
 			wc->w_pages[i] = mmap_page;
 			wc->w_target_locked = true;
 		} else {
@@ -1731,7 +1731,7 @@ static void ocfs2_set_target_boundaries(struct ocfs2_super *osb,
 {
 	struct ocfs2_write_cluster_desc *desc;
 
-	wc->w_target_from = pos & (PAGE_CACHE_SIZE - 1);
+	wc->w_target_from = pos & (PAGE_SIZE - 1);
 	wc->w_target_to = wc->w_target_from + len;
 
 	if (alloc == 0)
@@ -1768,7 +1768,7 @@ static void ocfs2_set_target_boundaries(struct ocfs2_super *osb,
 							&wc->w_target_to);
 	} else {
 		wc->w_target_from = 0;
-		wc->w_target_to = PAGE_CACHE_SIZE;
+		wc->w_target_to = PAGE_SIZE;
 	}
 }
 
@@ -2368,7 +2368,7 @@ int ocfs2_write_end_nolock(struct address_space *mapping,
 			   struct page *page, void *fsdata)
 {
 	int i, ret;
-	unsigned from, to, start = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned from, to, start = pos & (PAGE_SIZE - 1);
 	struct inode *inode = mapping->host;
 	struct ocfs2_super *osb = OCFS2_SB(inode->i_sb);
 	struct ocfs2_write_ctxt *wc = fsdata;
@@ -2405,8 +2405,8 @@ int ocfs2_write_end_nolock(struct address_space *mapping,
 			from = wc->w_target_from;
 			to = wc->w_target_to;
 
-			BUG_ON(from > PAGE_CACHE_SIZE ||
-			       to > PAGE_CACHE_SIZE ||
+			BUG_ON(from > PAGE_SIZE ||
+			       to > PAGE_SIZE ||
 			       to < from);
 		} else {
 			/*
@@ -2415,7 +2415,7 @@ int ocfs2_write_end_nolock(struct address_space *mapping,
 			 * to flush their entire range.
 			 */
 			from = 0;
-			to = PAGE_CACHE_SIZE;
+			to = PAGE_SIZE;
 		}
 
 		if (page_has_buffers(tmppage)) {
diff --git a/fs/ocfs2/cluster/heartbeat.c b/fs/ocfs2/cluster/heartbeat.c
index ef6a2ec494de..2c85f5330e12 100644
--- a/fs/ocfs2/cluster/heartbeat.c
+++ b/fs/ocfs2/cluster/heartbeat.c
@@ -417,13 +417,13 @@ static struct bio *o2hb_setup_one_bio(struct o2hb_region *reg,
 	bio->bi_private = wc;
 	bio->bi_end_io = o2hb_bio_end_io;
 
-	vec_start = (cs << bits) % PAGE_CACHE_SIZE;
+	vec_start = (cs << bits) % PAGE_SIZE;
 	while(cs < max_slots) {
 		current_page = cs / spp;
 		page = reg->hr_slot_data[current_page];
 
-		vec_len = min(PAGE_CACHE_SIZE - vec_start,
-			      (max_slots-cs) * (PAGE_CACHE_SIZE/spp) );
+		vec_len = min(PAGE_SIZE - vec_start,
+			      (max_slots-cs) * (PAGE_SIZE/spp) );
 
 		mlog(ML_HB_BIO, "page %d, vec_len = %u, vec_start = %u\n",
 		     current_page, vec_len, vec_start);
@@ -431,7 +431,7 @@ static struct bio *o2hb_setup_one_bio(struct o2hb_region *reg,
 		len = bio_add_page(bio, page, vec_len, vec_start);
 		if (len != vec_len) break;
 
-		cs += vec_len / (PAGE_CACHE_SIZE/spp);
+		cs += vec_len / (PAGE_SIZE/spp);
 		vec_start = 0;
 	}
 
@@ -1576,7 +1576,7 @@ static ssize_t o2hb_region_dev_show(struct config_item *item, char *page)
 
 static void o2hb_init_region_params(struct o2hb_region *reg)
 {
-	reg->hr_slots_per_page = PAGE_CACHE_SIZE >> reg->hr_block_bits;
+	reg->hr_slots_per_page = PAGE_SIZE >> reg->hr_block_bits;
 	reg->hr_timeout_ms = O2HB_REGION_TIMEOUT_MS;
 
 	mlog(ML_HEARTBEAT, "hr_start_block = %llu, hr_blocks = %u\n",
diff --git a/fs/ocfs2/dlmfs/dlmfs.c b/fs/ocfs2/dlmfs/dlmfs.c
index 03768bb3aab1..47b3b2d4e775 100644
--- a/fs/ocfs2/dlmfs/dlmfs.c
+++ b/fs/ocfs2/dlmfs/dlmfs.c
@@ -571,8 +571,8 @@ static int dlmfs_fill_super(struct super_block * sb,
 			    int silent)
 {
 	sb->s_maxbytes = MAX_LFS_FILESIZE;
-	sb->s_blocksize = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_blocksize = PAGE_SIZE;
+	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = DLMFS_MAGIC;
 	sb->s_op = &dlmfs_ops;
 	sb->s_root = d_make_root(dlmfs_get_root_inode(sb));
diff --git a/fs/ocfs2/file.c b/fs/ocfs2/file.c
index 7cb38fdca229..32e19a63a4fa 100644
--- a/fs/ocfs2/file.c
+++ b/fs/ocfs2/file.c
@@ -770,14 +770,14 @@ static int ocfs2_write_zero_page(struct inode *inode, u64 abs_from,
 {
 	struct address_space *mapping = inode->i_mapping;
 	struct page *page;
-	unsigned long index = abs_from >> PAGE_CACHE_SHIFT;
+	unsigned long index = abs_from >> PAGE_SHIFT;
 	handle_t *handle;
 	int ret = 0;
 	unsigned zero_from, zero_to, block_start, block_end;
 	struct ocfs2_dinode *di = (struct ocfs2_dinode *)di_bh->b_data;
 
 	BUG_ON(abs_from >= abs_to);
-	BUG_ON(abs_to > (((u64)index + 1) << PAGE_CACHE_SHIFT));
+	BUG_ON(abs_to > (((u64)index + 1) << PAGE_SHIFT));
 	BUG_ON(abs_from & (inode->i_blkbits - 1));
 
 	handle = ocfs2_zero_start_ordered_transaction(inode, di_bh);
@@ -794,10 +794,10 @@ static int ocfs2_write_zero_page(struct inode *inode, u64 abs_from,
 	}
 
 	/* Get the offsets within the page that we want to zero */
-	zero_from = abs_from & (PAGE_CACHE_SIZE - 1);
-	zero_to = abs_to & (PAGE_CACHE_SIZE - 1);
+	zero_from = abs_from & (PAGE_SIZE - 1);
+	zero_to = abs_to & (PAGE_SIZE - 1);
 	if (!zero_to)
-		zero_to = PAGE_CACHE_SIZE;
+		zero_to = PAGE_SIZE;
 
 	trace_ocfs2_write_zero_page(
 			(unsigned long long)OCFS2_I(inode)->ip_blkno,
@@ -851,7 +851,7 @@ static int ocfs2_write_zero_page(struct inode *inode, u64 abs_from,
 
 out_unlock:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 out_commit_trans:
 	if (handle)
 		ocfs2_commit_trans(OCFS2_SB(inode->i_sb), handle);
@@ -959,7 +959,7 @@ static int ocfs2_zero_extend_range(struct inode *inode, u64 range_start,
 	BUG_ON(range_start >= range_end);
 
 	while (zero_pos < range_end) {
-		next_pos = (zero_pos & PAGE_CACHE_MASK) + PAGE_CACHE_SIZE;
+		next_pos = (zero_pos & PAGE_MASK) + PAGE_SIZE;
 		if (next_pos > range_end)
 			next_pos = range_end;
 		rc = ocfs2_write_zero_page(inode, zero_pos, next_pos, di_bh);
diff --git a/fs/ocfs2/mmap.c b/fs/ocfs2/mmap.c
index 77ebc2bc1cca..872e6800267f 100644
--- a/fs/ocfs2/mmap.c
+++ b/fs/ocfs2/mmap.c
@@ -65,13 +65,13 @@ static int __ocfs2_page_mkwrite(struct file *file, struct buffer_head *di_bh,
 	struct inode *inode = file_inode(file);
 	struct address_space *mapping = inode->i_mapping;
 	loff_t pos = page_offset(page);
-	unsigned int len = PAGE_CACHE_SIZE;
+	unsigned int len = PAGE_SIZE;
 	pgoff_t last_index;
 	struct page *locked_page = NULL;
 	void *fsdata;
 	loff_t size = i_size_read(inode);
 
-	last_index = (size - 1) >> PAGE_CACHE_SHIFT;
+	last_index = (size - 1) >> PAGE_SHIFT;
 
 	/*
 	 * There are cases that lead to the page no longer bebongs to the
@@ -102,7 +102,7 @@ static int __ocfs2_page_mkwrite(struct file *file, struct buffer_head *di_bh,
 	 * because the "write" would invalidate their data.
 	 */
 	if (page->index == last_index)
-		len = ((size - 1) & ~PAGE_CACHE_MASK) + 1;
+		len = ((size - 1) & ~PAGE_MASK) + 1;
 
 	ret = ocfs2_write_begin_nolock(file, mapping, pos, len, 0, &locked_page,
 				       &fsdata, di_bh, page);
diff --git a/fs/ocfs2/ocfs2.h b/fs/ocfs2/ocfs2.h
index 7a0126267847..7a592877c33b 100644
--- a/fs/ocfs2/ocfs2.h
+++ b/fs/ocfs2/ocfs2.h
@@ -814,10 +814,10 @@ static inline unsigned int ocfs2_page_index_to_clusters(struct super_block *sb,
 	u32 clusters = pg_index;
 	unsigned int cbits = OCFS2_SB(sb)->s_clustersize_bits;
 
-	if (unlikely(PAGE_CACHE_SHIFT > cbits))
-		clusters = pg_index << (PAGE_CACHE_SHIFT - cbits);
-	else if (PAGE_CACHE_SHIFT < cbits)
-		clusters = pg_index >> (cbits - PAGE_CACHE_SHIFT);
+	if (unlikely(PAGE_SHIFT > cbits))
+		clusters = pg_index << (PAGE_SHIFT - cbits);
+	else if (PAGE_SHIFT < cbits)
+		clusters = pg_index >> (cbits - PAGE_SHIFT);
 
 	return clusters;
 }
@@ -831,10 +831,10 @@ static inline pgoff_t ocfs2_align_clusters_to_page_index(struct super_block *sb,
 	unsigned int cbits = OCFS2_SB(sb)->s_clustersize_bits;
         pgoff_t index = clusters;
 
-	if (PAGE_CACHE_SHIFT > cbits) {
-		index = (pgoff_t)clusters >> (PAGE_CACHE_SHIFT - cbits);
-	} else if (PAGE_CACHE_SHIFT < cbits) {
-		index = (pgoff_t)clusters << (cbits - PAGE_CACHE_SHIFT);
+	if (PAGE_SHIFT > cbits) {
+		index = (pgoff_t)clusters >> (PAGE_SHIFT - cbits);
+	} else if (PAGE_SHIFT < cbits) {
+		index = (pgoff_t)clusters << (cbits - PAGE_SHIFT);
 	}
 
 	return index;
@@ -845,8 +845,8 @@ static inline unsigned int ocfs2_pages_per_cluster(struct super_block *sb)
 	unsigned int cbits = OCFS2_SB(sb)->s_clustersize_bits;
 	unsigned int pages_per_cluster = 1;
 
-	if (PAGE_CACHE_SHIFT < cbits)
-		pages_per_cluster = 1 << (cbits - PAGE_CACHE_SHIFT);
+	if (PAGE_SHIFT < cbits)
+		pages_per_cluster = 1 << (cbits - PAGE_SHIFT);
 
 	return pages_per_cluster;
 }
diff --git a/fs/ocfs2/refcounttree.c b/fs/ocfs2/refcounttree.c
index 3eff031aaf26..744d5d90c363 100644
--- a/fs/ocfs2/refcounttree.c
+++ b/fs/ocfs2/refcounttree.c
@@ -2937,16 +2937,16 @@ int ocfs2_duplicate_clusters_by_page(handle_t *handle,
 		end = i_size_read(inode);
 
 	while (offset < end) {
-		page_index = offset >> PAGE_CACHE_SHIFT;
-		map_end = ((loff_t)page_index + 1) << PAGE_CACHE_SHIFT;
+		page_index = offset >> PAGE_SHIFT;
+		map_end = ((loff_t)page_index + 1) << PAGE_SHIFT;
 		if (map_end > end)
 			map_end = end;
 
 		/* from, to is the offset within the page. */
-		from = offset & (PAGE_CACHE_SIZE - 1);
-		to = PAGE_CACHE_SIZE;
-		if (map_end & (PAGE_CACHE_SIZE - 1))
-			to = map_end & (PAGE_CACHE_SIZE - 1);
+		from = offset & (PAGE_SIZE - 1);
+		to = PAGE_SIZE;
+		if (map_end & (PAGE_SIZE - 1))
+			to = map_end & (PAGE_SIZE - 1);
 
 		page = find_or_create_page(mapping, page_index, GFP_NOFS);
 		if (!page) {
@@ -2956,10 +2956,10 @@ int ocfs2_duplicate_clusters_by_page(handle_t *handle,
 		}
 
 		/*
-		 * In case PAGE_CACHE_SIZE <= CLUSTER_SIZE, This page
+		 * In case PAGE_SIZE <= CLUSTER_SIZE, This page
 		 * can't be dirtied before we CoW it out.
 		 */
-		if (PAGE_CACHE_SIZE <= OCFS2_SB(sb)->s_clustersize)
+		if (PAGE_SIZE <= OCFS2_SB(sb)->s_clustersize)
 			BUG_ON(PageDirty(page));
 
 		if (!PageUptodate(page)) {
@@ -2987,7 +2987,7 @@ int ocfs2_duplicate_clusters_by_page(handle_t *handle,
 		mark_page_accessed(page);
 unlock:
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		page = NULL;
 		offset = map_end;
 		if (ret)
@@ -3165,8 +3165,8 @@ int ocfs2_cow_sync_writeback(struct super_block *sb,
 	}
 
 	while (offset < end) {
-		page_index = offset >> PAGE_CACHE_SHIFT;
-		map_end = ((loff_t)page_index + 1) << PAGE_CACHE_SHIFT;
+		page_index = offset >> PAGE_SHIFT;
+		map_end = ((loff_t)page_index + 1) << PAGE_SHIFT;
 		if (map_end > end)
 			map_end = end;
 
@@ -3182,7 +3182,7 @@ int ocfs2_cow_sync_writeback(struct super_block *sb,
 			mark_page_accessed(page);
 
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		page = NULL;
 		offset = map_end;
 		if (ret)
diff --git a/fs/ocfs2/super.c b/fs/ocfs2/super.c
index 302854ee0985..455155ca742e 100644
--- a/fs/ocfs2/super.c
+++ b/fs/ocfs2/super.c
@@ -610,8 +610,8 @@ static unsigned long long ocfs2_max_file_offset(unsigned int bbits,
 	/*
 	 * We might be limited by page cache size.
 	 */
-	if (bytes > PAGE_CACHE_SIZE) {
-		bytes = PAGE_CACHE_SIZE;
+	if (bytes > PAGE_SIZE) {
+		bytes = PAGE_SIZE;
 		trim = 1;
 		/*
 		 * Shift by 31 here so that we don't get larger than
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
