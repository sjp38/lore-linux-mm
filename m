Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 60CFE6B0031
	for <linux-mm@kvack.org>; Sat, 28 Sep 2013 04:34:14 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so3544103pde.24
        for <linux-mm@kvack.org>; Sat, 28 Sep 2013 01:34:14 -0700 (PDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so3745084pad.2
        for <linux-mm@kvack.org>; Sat, 28 Sep 2013 01:34:11 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] mm: pagevec: cleanup: drop pvec->cold argument in all places
Date: Sat, 28 Sep 2013 16:33:58 +0800
Message-Id: <1380357239-30102-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com, minchan@kernel.org, Bob Liu <bob.liu@oracle.com>

Nobody uses the pvec->cold argument of pagevec and it's also unreasonable for
pages in pagevec released as cold page, so drop the cold argument from pagevec.

Signed-off-by: Bob Liu <bob.liu@oracle.com>
---
 fs/9p/cache.c           |    2 +-
 fs/afs/cache.c          |    2 +-
 fs/afs/write.c          |    4 ++--
 fs/btrfs/extent_io.c    |    4 ++--
 fs/cachefiles/rdwr.c    |    8 ++++----
 fs/ceph/addr.c          |    6 +++---
 fs/ceph/cache.c         |    2 +-
 fs/cifs/cache.c         |    2 +-
 fs/ext4/file.c          |    2 +-
 fs/ext4/inode.c         |    6 +++---
 fs/f2fs/checkpoint.c    |    2 +-
 fs/f2fs/node.c          |    2 +-
 fs/fscache/page.c       |    4 ++--
 fs/gfs2/aops.c          |    2 +-
 fs/hugetlbfs/inode.c    |    4 ++--
 fs/nfs/fscache-index.c  |    2 +-
 fs/nilfs2/btree.c       |    2 +-
 fs/nilfs2/page.c        |    8 ++++----
 fs/nilfs2/segment.c     |    4 ++--
 fs/xfs/xfs_aops.c       |    2 +-
 fs/xfs/xfs_file.c       |    2 +-
 include/linux/pagevec.h |    9 +--------
 mm/filemap.c            |    2 +-
 mm/mlock.c              |    4 ++--
 mm/page-writeback.c     |    2 +-
 mm/shmem.c              |    6 +++---
 mm/swap.c               |    8 ++++----
 mm/truncate.c           |    6 +++---
 28 files changed, 51 insertions(+), 58 deletions(-)

diff --git a/fs/9p/cache.c b/fs/9p/cache.c
index a9ea73d..c17798c 100644
--- a/fs/9p/cache.c
+++ b/fs/9p/cache.c
@@ -158,7 +158,7 @@ static void v9fs_cache_inode_now_uncached(void *cookie_netfs_data)
 	pgoff_t first;
 	int loop, nr_pages;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	first = 0;
 
 	for (;;) {
diff --git a/fs/afs/cache.c b/fs/afs/cache.c
index 577763c3..ae3fb3e 100644
--- a/fs/afs/cache.c
+++ b/fs/afs/cache.c
@@ -377,7 +377,7 @@ static void afs_vnode_cache_now_uncached(void *cookie_netfs_data)
 	_enter("{%x,%x,%Lx}",
 	       vnode->fid.vnode, vnode->fid.unique, vnode->status.data_version);
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	first = 0;
 
 	for (;;) {
diff --git a/fs/afs/write.c b/fs/afs/write.c
index a890db4..7ace426 100644
--- a/fs/afs/write.c
+++ b/fs/afs/write.c
@@ -284,7 +284,7 @@ static void afs_kill_pages(struct afs_vnode *vnode, bool error,
 	_enter("{%x:%u},%lx-%lx",
 	       vnode->fid.vid, vnode->fid.vnode, first, last);
 
-	pagevec_init(&pv, 0);
+	pagevec_init(&pv);
 
 	do {
 		_debug("kill %lx-%lx", first, last);
@@ -582,7 +582,7 @@ void afs_pages_written_back(struct afs_vnode *vnode, struct afs_call *call)
 
 	ASSERT(wb != NULL);
 
-	pagevec_init(&pv, 0);
+	pagevec_init(&pv);
 
 	do {
 		_debug("done %lx-%lx", first, last);
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 09582b8..11deea7 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -3517,7 +3517,7 @@ int btree_write_cache_pages(struct address_space *mapping,
 	int scanned = 0;
 	int tag;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	if (wbc->range_cyclic) {
 		index = mapping->writeback_index; /* Start from prev offset */
 		end = -1;
@@ -3661,7 +3661,7 @@ static int extent_write_cache_pages(struct extent_io_tree *tree,
 	if (!igrab(inode))
 		return 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	if (wbc->range_cyclic) {
 		index = mapping->writeback_index; /* Start from prev offset */
 		end = -1;
diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index ebaff36..aa82d15 100644
--- a/fs/cachefiles/rdwr.c
+++ b/fs/cachefiles/rdwr.c
@@ -160,7 +160,7 @@ static void cachefiles_read_copier(struct fscache_operation *_op)
 
 	_enter("{ino=%lu}", object->backer->d_inode->i_ino);
 
-	pagevec_init(&pagevec, 0);
+	pagevec_init(&pagevec);
 
 	max = 8;
 	spin_lock_irq(&object->work_lock);
@@ -429,7 +429,7 @@ int cachefiles_read_or_alloc_page(struct fscache_retrieval *op,
 	op->op.flags |= FSCACHE_OP_ASYNC;
 	op->op.processor = cachefiles_read_copier;
 
-	pagevec_init(&pagevec, 0);
+	pagevec_init(&pagevec);
 
 	/* we assume the absence or presence of the first block is a good
 	 * enough indication for the page as a whole
@@ -729,7 +729,7 @@ int cachefiles_read_or_alloc_pages(struct fscache_retrieval *op,
 
 	shift = PAGE_SHIFT - inode->i_sb->s_blocksize_bits;
 
-	pagevec_init(&pagevec, 0);
+	pagevec_init(&pagevec);
 
 	op->op.flags &= FSCACHE_OP_KEEP_FLAGS;
 	op->op.flags |= FSCACHE_OP_ASYNC;
@@ -863,7 +863,7 @@ int cachefiles_allocate_pages(struct fscache_retrieval *op,
 
 	ret = cachefiles_has_space(cache, 0, *nr_pages);
 	if (ret == 0) {
-		pagevec_init(&pagevec, 0);
+		pagevec_init(&pagevec);
 
 		list_for_each_entry(page, pages, lru) {
 			if (pagevec_add(&pagevec, page) == 0)
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 6df8bd4..34c3033 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -555,7 +555,7 @@ static void ceph_release_pages(struct page **pages, int num)
 	struct pagevec pvec;
 	int i;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	for (i = 0; i < num; i++) {
 		if (pagevec_add(&pvec, pages[i]) == 0)
 			pagevec_release(&pvec);
@@ -695,7 +695,7 @@ static int ceph_writepages_start(struct address_space *mapping,
 		wsize = PAGE_CACHE_SIZE;
 	max_pages_ever = wsize >> PAGE_CACHE_SHIFT;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 
 	/* where to start/end? */
 	if (wbc->range_cyclic) {
@@ -900,7 +900,7 @@ get_more_pages:
 			if (pvec_pages && i == pvec_pages &&
 			    locked_pages < max_pages) {
 				dout("reached end pvec, trying for more\n");
-				pagevec_reinit(&pvec);
+				pagevec_init(&pvec);
 				goto get_more_pages;
 			}
 
diff --git a/fs/ceph/cache.c b/fs/ceph/cache.c
index 6bfe65e..08036a5 100644
--- a/fs/ceph/cache.c
+++ b/fs/ceph/cache.c
@@ -150,7 +150,7 @@ static void ceph_fscache_inode_now_uncached(void* cookie_netfs_data)
 	pgoff_t first;
 	int loop, nr_pages;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	first = 0;
 
 	dout("ceph inode 0x%p now uncached", ci);
diff --git a/fs/cifs/cache.c b/fs/cifs/cache.c
index 6c665bf..e3c9a48 100644
--- a/fs/cifs/cache.c
+++ b/fs/cifs/cache.c
@@ -299,7 +299,7 @@ static void cifs_fscache_inode_now_uncached(void *cookie_netfs_data)
 	pgoff_t first;
 	int loop, nr_pages;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	first = 0;
 
 	cifs_dbg(FYI, "%s: cifs inode 0x%p now uncached\n", __func__, cifsi);
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 3da2194..fc5d776 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -304,7 +304,7 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 	index = startoff >> PAGE_CACHE_SHIFT;
 	end = endoff >> PAGE_CACHE_SHIFT;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	do {
 		int i, num;
 		unsigned long nr_pages;
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 0d424d7..5c335fe 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1451,7 +1451,7 @@ static void mpage_release_unused_pages(struct mpage_da_data *mpd,
 		ext4_es_remove_extent(inode, start, last - start + 1);
 	}
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	while (index <= end) {
 		nr_pages = pagevec_lookup(&pvec, mapping, index, PAGEVEC_SIZE);
 		if (nr_pages == 0)
@@ -2050,7 +2050,7 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
 	lblk = start << bpp_bits;
 	pblock = mpd->map.m_pblk;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	while (start <= end) {
 		nr_pages = pagevec_lookup(&pvec, inode->i_mapping, start,
 					  PAGEVEC_SIZE);
@@ -2308,7 +2308,7 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 	else
 		tag = PAGECACHE_TAG_DIRTY;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	mpd->map.m_len = 0;
 	mpd->next_page = index;
 	while (index <= end) {
diff --git a/fs/f2fs/checkpoint.c b/fs/f2fs/checkpoint.c
index bb31220..b3cafcc 100644
--- a/fs/f2fs/checkpoint.c
+++ b/fs/f2fs/checkpoint.c
@@ -129,7 +129,7 @@ long sync_meta_pages(struct f2fs_sb_info *sbi, enum page_type type,
 		.for_reclaim = 0,
 	};
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 
 	while (index <= end) {
 		int i, nr_pages;
diff --git a/fs/f2fs/node.c b/fs/f2fs/node.c
index 51ef278..7382fc3 100644
--- a/fs/f2fs/node.c
+++ b/fs/f2fs/node.c
@@ -1054,7 +1054,7 @@ int sync_node_pages(struct f2fs_sb_info *sbi, nid_t ino,
 	int step = ino ? 2 : 0;
 	int nwritten = 0, wrote = 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 
 next_step:
 	index = 0;
diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index 73899c1..8253284 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -1112,7 +1112,7 @@ void fscache_mark_pages_cached(struct fscache_retrieval *op,
 	for (loop = 0; loop < pagevec->nr; loop++)
 		fscache_mark_page_cached(op, pagevec->pages[loop]);
 
-	pagevec_reinit(pagevec);
+	pagevec_init(pagevec);
 }
 EXPORT_SYMBOL(fscache_mark_pages_cached);
 
@@ -1135,7 +1135,7 @@ void __fscache_uncache_all_inode_pages(struct fscache_cookie *cookie,
 		return;
 	}
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	next = 0;
 	do {
 		if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE))
diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
index 1f7d805..04679fa 100644
--- a/fs/gfs2/aops.c
+++ b/fs/gfs2/aops.c
@@ -311,7 +311,7 @@ static int gfs2_write_cache_jdata(struct address_space *mapping,
 	int scanned = 0;
 	int range_whole = 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	if (wbc->range_cyclic) {
 		index = mapping->writeback_index; /* Start from prev offset */
 		end = -1;
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index d19b30a..980e133 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -92,7 +92,7 @@ static void huge_pagevec_release(struct pagevec *pvec)
 	for (i = 0; i < pagevec_count(pvec); ++i)
 		put_page(pvec->pages[i]);
 
-	pagevec_reinit(pvec);
+	pagevec_init(pvec);
 }
 
 static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
@@ -337,7 +337,7 @@ static void truncate_hugepages(struct inode *inode, loff_t lstart)
 	pgoff_t next;
 	int i, freed = 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	next = start;
 	while (1) {
 		if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
diff --git a/fs/nfs/fscache-index.c b/fs/nfs/fscache-index.c
index 7cf2c46..b58a3e9 100644
--- a/fs/nfs/fscache-index.c
+++ b/fs/nfs/fscache-index.c
@@ -266,7 +266,7 @@ static void nfs_fscache_inode_now_uncached(void *cookie_netfs_data)
 	pgoff_t first;
 	int loop, nr_pages;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	first = 0;
 
 	dprintk("NFS: nfs_inode_now_uncached: nfs_inode 0x%p\n", nfsi);
diff --git a/fs/nilfs2/btree.c b/fs/nilfs2/btree.c
index b2e3ff3..b539d83 100644
--- a/fs/nilfs2/btree.c
+++ b/fs/nilfs2/btree.c
@@ -2061,7 +2061,7 @@ static void nilfs_btree_lookup_dirty_buffers(struct nilfs_bmap *btree,
 	     level++)
 		INIT_LIST_HEAD(&lists[level]);
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 
 	while (pagevec_lookup_tag(&pvec, btcache, &index, PAGECACHE_TAG_DIRTY,
 				  PAGEVEC_SIZE)) {
diff --git a/fs/nilfs2/page.c b/fs/nilfs2/page.c
index 0ba6798..4818f29 100644
--- a/fs/nilfs2/page.c
+++ b/fs/nilfs2/page.c
@@ -261,7 +261,7 @@ int nilfs_copy_dirty_pages(struct address_space *dmap,
 	pgoff_t index = 0;
 	int err = 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 repeat:
 	if (!pagevec_lookup_tag(&pvec, smap, &index, PAGECACHE_TAG_DIRTY,
 				PAGEVEC_SIZE))
@@ -316,7 +316,7 @@ void nilfs_copy_back_pages(struct address_space *dmap,
 	pgoff_t index = 0;
 	int err;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 repeat:
 	n = pagevec_lookup(&pvec, smap, index, PAGEVEC_SIZE);
 	if (!n)
@@ -381,7 +381,7 @@ void nilfs_clear_dirty_pages(struct address_space *mapping, bool silent)
 	unsigned int i;
 	pgoff_t index = 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 
 	while (pagevec_lookup_tag(&pvec, mapping, &index, PAGECACHE_TAG_DIRTY,
 				  PAGEVEC_SIZE)) {
@@ -530,7 +530,7 @@ unsigned long nilfs_find_uncommitted_extent(struct inode *inode,
 	index = start_blk >> (PAGE_CACHE_SHIFT - inode->i_blkbits);
 	nblocks_in_page = 1U << (PAGE_CACHE_SHIFT - inode->i_blkbits);
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 
 repeat:
 	pvec.nr = find_get_pages_contig(inode->i_mapping, index, PAGEVEC_SIZE,
diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
index bd88a74..7391f4b 100644
--- a/fs/nilfs2/segment.c
+++ b/fs/nilfs2/segment.c
@@ -643,7 +643,7 @@ static size_t nilfs_lookup_dirty_data_buffers(struct inode *inode,
 		index = start >> PAGE_SHIFT;
 		last = end >> PAGE_SHIFT;
 	}
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
  repeat:
 	if (unlikely(index > last) ||
 	    !pagevec_lookup_tag(&pvec, mapping, &index, PAGECACHE_TAG_DIRTY,
@@ -692,7 +692,7 @@ static void nilfs_lookup_dirty_node_buffers(struct inode *inode,
 	unsigned int i;
 	pgoff_t index = 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 
 	while (pagevec_lookup_tag(&pvec, mapping, &index, PAGECACHE_TAG_DIRTY,
 				  PAGEVEC_SIZE)) {
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index e51e581..5282cd1 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -810,7 +810,7 @@ xfs_cluster_write(
 	struct pagevec		pvec;
 	int			done = 0, i;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	while (!done && tindex <= tlast) {
 		unsigned len = min_t(pgoff_t, PAGEVEC_SIZE, tlast - tindex + 1);
 
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 4c749ab..d5e0336 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1046,7 +1046,7 @@ xfs_find_get_desired_pgoff(
 	loff_t			lastoff = startoff;
 	bool			found = false;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 
 	index = startoff >> PAGE_CACHE_SHIFT;
 	endoff = XFS_FSB_TO_B(mp, map->br_startoff + map->br_blockcount);
diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index e4dbfab..423c23d 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -16,7 +16,6 @@ struct address_space;
 
 struct pagevec {
 	unsigned long nr;
-	unsigned long cold;
 	struct page *pages[PAGEVEC_SIZE];
 };
 
@@ -28,13 +27,7 @@ unsigned pagevec_lookup_tag(struct pagevec *pvec,
 		struct address_space *mapping, pgoff_t *index, int tag,
 		unsigned nr_pages);
 
-static inline void pagevec_init(struct pagevec *pvec, int cold)
-{
-	pvec->nr = 0;
-	pvec->cold = cold;
-}
-
-static inline void pagevec_reinit(struct pagevec *pvec)
+static inline void pagevec_init(struct pagevec *pvec)
 {
 	pvec->nr = 0;
 }
diff --git a/mm/filemap.c b/mm/filemap.c
index 1e6aec4..8ea4e39 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -285,7 +285,7 @@ int filemap_fdatawait_range(struct address_space *mapping, loff_t start_byte,
 	if (end_byte < start_byte)
 		goto out;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	while ((index <= end) &&
 			(nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
 			PAGECACHE_TAG_WRITEBACK,
diff --git a/mm/mlock.c b/mm/mlock.c
index d638026..0e3a927 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -329,7 +329,7 @@ skip_munlock:
 	spin_unlock_irq(&zone->lru_lock);
 
 	/* Phase 2: page munlock */
-	pagevec_init(&pvec_putback, 0);
+	pagevec_init(&pvec_putback);
 	for (i = 0; i < nr; i++) {
 		struct page *page = pvec->pages[i];
 
@@ -441,7 +441,7 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 		struct zone *zone;
 		int zoneid;
 
-		pagevec_init(&pvec, 0);
+		pagevec_init(&pvec);
 		/*
 		 * Although FOLL_DUMP is intended for get_dump_page(),
 		 * it just so happens that its special treatment of the
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index f5236f8..50de62b 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1880,7 +1880,7 @@ int write_cache_pages(struct address_space *mapping,
 	int range_whole = 0;
 	int tag;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	if (wbc->range_cyclic) {
 		writeback_index = mapping->writeback_index; /* prev offset */
 		index = writeback_index;
diff --git a/mm/shmem.c b/mm/shmem.c
index 8297623..a8a4646 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -420,7 +420,7 @@ void shmem_unlock_mapping(struct address_space *mapping)
 	pgoff_t indices[PAGEVEC_SIZE];
 	pgoff_t index = 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	/*
 	 * Minor point, but we might as well stop if someone else SHM_LOCKs it.
 	 */
@@ -463,7 +463,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 	if (lend == -1)
 		end = -1;	/* unsigned, so actually very big */
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	index = start;
 	while (index < end) {
 		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
@@ -1728,7 +1728,7 @@ static pgoff_t shmem_seek_hole_data(struct address_space *mapping,
 	bool done = false;
 	int i;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	pvec.nr = 1;		/* start small: we may be there already */
 	while (!done) {
 		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
diff --git a/mm/swap.c b/mm/swap.c
index 759c3ca..c17d45f 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -344,8 +344,8 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
 	}
 	if (zone)
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
-	release_pages(pvec->pages, pvec->nr, pvec->cold);
-	pagevec_reinit(pvec);
+	release_pages(pvec->pages, pvec->nr, 0);
+	pagevec_init(pvec);
 }
 
 static void pagevec_move_tail_fn(struct page *page, struct lruvec *lruvec,
@@ -821,8 +821,8 @@ EXPORT_SYMBOL(release_pages);
 void __pagevec_release(struct pagevec *pvec)
 {
 	lru_add_drain();
-	release_pages(pvec->pages, pagevec_count(pvec), pvec->cold);
-	pagevec_reinit(pvec);
+	release_pages(pvec->pages, pagevec_count(pvec), 0);
+	pagevec_init(pvec);
 }
 EXPORT_SYMBOL(__pagevec_release);
 
diff --git a/mm/truncate.c b/mm/truncate.c
index 353b683..ee2246e 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -236,7 +236,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	else
 		end = (lend + 1) >> PAGE_CACHE_SHIFT;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	index = start;
 	while (index < end && pagevec_lookup(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE))) {
@@ -389,7 +389,7 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 	 * (most pages are dirty), and already skips over any difficulties.
 	 */
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	while (index <= end && pagevec_lookup(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
 		mem_cgroup_uncharge_start();
@@ -489,7 +489,7 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 	int did_range_unmap = 0;
 
 	cleancache_invalidate_inode(mapping);
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	index = start;
 	while (index <= end && pagevec_lookup(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
