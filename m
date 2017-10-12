Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 63FF16B0294
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 05:37:48 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id p186so2607704wmd.11
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 02:37:48 -0700 (PDT)
Received: from outbound-smtp13.blacknight.com (outbound-smtp13.blacknight.com. [46.22.139.230])
        by mx.google.com with ESMTPS id l36si257362edd.171.2017.10.12.02.37.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 02:37:46 -0700 (PDT)
Received: from mail.blacknight.com (unknown [81.17.254.17])
	by outbound-smtp13.blacknight.com (Postfix) with ESMTPS id 11EAB1C16E7
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 10:37:46 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 5/8] mm, pagevec: Remove cold parameter for pagevecs
Date: Thu, 12 Oct 2017 10:31:00 +0100
Message-Id: <20171012093103.13412-6-mgorman@techsingularity.net>
In-Reply-To: <20171012093103.13412-1-mgorman@techsingularity.net>
References: <20171012093103.13412-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@techsingularity.net>

Every pagevec_init user claims the pages being released are false even in
cases where it is unlikely the pages are hot. As no one cares about the
hotness of pages being released to the allocator, just ditch the parameter.

No performance impact is expected as the overhead is marginal. The parameter
is removed simply because it is a bit stupid to have a useless parameter
copied everywhere.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 drivers/gpu/drm/i915/i915_gem_gtt.c | 2 +-
 fs/afs/write.c                      | 4 ++--
 fs/btrfs/extent_io.c                | 4 ++--
 fs/buffer.c                         | 4 ++--
 fs/cachefiles/rdwr.c                | 4 ++--
 fs/ceph/addr.c                      | 4 ++--
 fs/dax.c                            | 2 +-
 fs/ext4/file.c                      | 2 +-
 fs/ext4/inode.c                     | 6 +++---
 fs/f2fs/checkpoint.c                | 2 +-
 fs/f2fs/data.c                      | 2 +-
 fs/f2fs/file.c                      | 2 +-
 fs/f2fs/node.c                      | 8 ++++----
 fs/fscache/page.c                   | 2 +-
 fs/gfs2/aops.c                      | 2 +-
 fs/hugetlbfs/inode.c                | 2 +-
 fs/nilfs2/btree.c                   | 2 +-
 fs/nilfs2/page.c                    | 8 ++++----
 fs/nilfs2/segment.c                 | 4 ++--
 include/linux/pagevec.h             | 4 +---
 mm/filemap.c                        | 2 +-
 mm/mlock.c                          | 4 ++--
 mm/page-writeback.c                 | 2 +-
 mm/shmem.c                          | 6 +++---
 mm/swap.c                           | 4 ++--
 mm/truncate.c                       | 6 +++---
 26 files changed, 46 insertions(+), 48 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_gem_gtt.c b/drivers/gpu/drm/i915/i915_gem_gtt.c
index e2410eb5d96e..b0a39578ccd1 100644
--- a/drivers/gpu/drm/i915/i915_gem_gtt.c
+++ b/drivers/gpu/drm/i915/i915_gem_gtt.c
@@ -1866,7 +1866,7 @@ static void i915_address_space_init(struct i915_address_space *vm,
 	INIT_LIST_HEAD(&vm->unbound_list);
 
 	list_add_tail(&vm->global_link, &dev_priv->vm_list);
-	pagevec_init(&vm->free_pages, false);
+	pagevec_init(&vm->free_pages);
 }
 
 static void i915_address_space_fini(struct i915_address_space *vm)
diff --git a/fs/afs/write.c b/fs/afs/write.c
index 106e43db1115..8766326c59fe 100644
--- a/fs/afs/write.c
+++ b/fs/afs/write.c
@@ -308,7 +308,7 @@ static void afs_kill_pages(struct afs_vnode *vnode, bool error,
 	_enter("{%x:%u},%lx-%lx",
 	       vnode->fid.vid, vnode->fid.vnode, first, last);
 
-	pagevec_init(&pv, 0);
+	pagevec_init(&pv);
 
 	do {
 		_debug("kill %lx-%lx", first, last);
@@ -609,7 +609,7 @@ void afs_pages_written_back(struct afs_vnode *vnode, struct afs_call *call)
 
 	ASSERT(wb != NULL);
 
-	pagevec_init(&pv, 0);
+	pagevec_init(&pv);
 
 	do {
 		_debug("done %lx-%lx", first, last);
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 970190cd347e..381acbda895c 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -3801,7 +3801,7 @@ int btree_write_cache_pages(struct address_space *mapping,
 	int scanned = 0;
 	int tag;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	if (wbc->range_cyclic) {
 		index = mapping->writeback_index; /* Start from prev offset */
 		end = -1;
@@ -3945,7 +3945,7 @@ static int extent_write_cache_pages(struct address_space *mapping,
 	if (!igrab(inode))
 		return 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	if (wbc->range_cyclic) {
 		index = mapping->writeback_index; /* Start from prev offset */
 		end = -1;
diff --git a/fs/buffer.c b/fs/buffer.c
index 170df856bdb9..de2ae6b15dd5 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1632,7 +1632,7 @@ void clean_bdev_aliases(struct block_device *bdev, sector_t block, sector_t len)
 	struct buffer_head *head;
 
 	end = (block + len - 1) >> (PAGE_SHIFT - bd_inode->i_blkbits);
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	while (pagevec_lookup_range(&pvec, bd_mapping, &index, end)) {
 		count = pagevec_count(&pvec);
 		for (i = 0; i < count; i++) {
@@ -3545,7 +3545,7 @@ page_cache_seek_hole_data(struct inode *inode, loff_t offset, loff_t length,
 	if (length <= 0)
 		return -ENOENT;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 
 	do {
 		unsigned nr_pages, i;
diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index 18d7aa61ef0f..23097cca2674 100644
--- a/fs/cachefiles/rdwr.c
+++ b/fs/cachefiles/rdwr.c
@@ -710,7 +710,7 @@ int cachefiles_read_or_alloc_pages(struct fscache_retrieval *op,
 	/* calculate the shift required to use bmap */
 	shift = PAGE_SHIFT - inode->i_sb->s_blocksize_bits;
 
-	pagevec_init(&pagevec, 0);
+	pagevec_init(&pagevec);
 
 	op->op.flags &= FSCACHE_OP_KEEP_FLAGS;
 	op->op.flags |= FSCACHE_OP_ASYNC;
@@ -844,7 +844,7 @@ int cachefiles_allocate_pages(struct fscache_retrieval *op,
 
 	ret = cachefiles_has_space(cache, 0, *nr_pages);
 	if (ret == 0) {
-		pagevec_init(&pagevec, 0);
+		pagevec_init(&pagevec);
 
 		list_for_each_entry(page, pages, lru) {
 			if (pagevec_add(&pagevec, page) == 0)
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index b3e3edc09d80..03afcea820e2 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -679,7 +679,7 @@ static void ceph_release_pages(struct page **pages, int num)
 	struct pagevec pvec;
 	int i;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	for (i = 0; i < num; i++) {
 		if (pagevec_add(&pvec, pages[i]) == 0)
 			pagevec_release(&pvec);
@@ -810,7 +810,7 @@ static int ceph_writepages_start(struct address_space *mapping,
 	if (fsc->mount_options->wsize < wsize)
 		wsize = fsc->mount_options->wsize;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 
 	start_index = wbc->range_cyclic ? mapping->writeback_index : 0;
 	index = start_index;
diff --git a/fs/dax.c b/fs/dax.c
index f001d8c72a06..83c50c0573bf 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -789,7 +789,7 @@ int dax_writeback_mapping_range(struct address_space *mapping,
 
 	tag_pages_for_writeback(mapping, start_index, end_index);
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	while (!done) {
 		pvec.nr = find_get_entries_tag(mapping, start_index,
 				PAGECACHE_TAG_TOWRITE, PAGEVEC_SIZE,
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index b1da660ac3bc..155ba5895efb 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -475,7 +475,7 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 	index = startoff >> PAGE_SHIFT;
 	end = (endoff - 1) >> PAGE_SHIFT;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	do {
 		int i;
 		unsigned long nr_pages;
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 31db875bc7a1..b15d227df6ae 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1718,7 +1718,7 @@ static void mpage_release_unused_pages(struct mpage_da_data *mpd,
 		ext4_es_remove_extent(inode, start, last - start + 1);
 	}
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	while (index <= end) {
 		nr_pages = pagevec_lookup_range(&pvec, mapping, &index, end);
 		if (nr_pages == 0)
@@ -2344,7 +2344,7 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
 	lblk = start << bpp_bits;
 	pblock = mpd->map.m_pblk;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	while (start <= end) {
 		nr_pages = pagevec_lookup_range(&pvec, inode->i_mapping,
 						&start, end);
@@ -2615,7 +2615,7 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 	else
 		tag = PAGECACHE_TAG_DIRTY;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	mpd->map.m_len = 0;
 	mpd->next_page = index;
 	while (index <= end) {
diff --git a/fs/f2fs/checkpoint.c b/fs/f2fs/checkpoint.c
index 04fe1df052b2..6bd32481f9aa 100644
--- a/fs/f2fs/checkpoint.c
+++ b/fs/f2fs/checkpoint.c
@@ -313,7 +313,7 @@ long sync_meta_pages(struct f2fs_sb_info *sbi, enum page_type type,
 	};
 	struct blk_plug plug;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 
 	blk_start_plug(&plug);
 
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 36b535207c88..83503e0ab287 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -1635,7 +1635,7 @@ static int f2fs_write_cache_pages(struct address_space *mapping,
 	int range_whole = 0;
 	int tag;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 
 	if (get_dirty_pages(mapping->host) <=
 				SM_I(F2FS_M_SB(mapping))->min_hot_blocks)
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 517e112c8a9a..fbf675c766d4 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -320,7 +320,7 @@ static pgoff_t __get_first_dirty_index(struct address_space *mapping,
 		return 0;
 
 	/* find first dirty page index */
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	nr_pages = pagevec_lookup_tag(&pvec, mapping, &pgofs,
 					PAGECACHE_TAG_DIRTY, 1);
 	pgofs = nr_pages ? pvec.pages[0]->index : ULONG_MAX;
diff --git a/fs/f2fs/node.c b/fs/f2fs/node.c
index fca87835a1da..fb512154a708 100644
--- a/fs/f2fs/node.c
+++ b/fs/f2fs/node.c
@@ -1281,7 +1281,7 @@ static struct page *last_fsync_dnode(struct f2fs_sb_info *sbi, nid_t ino)
 	struct pagevec pvec;
 	struct page *last_page = NULL;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	index = 0;
 	end = ULONG_MAX;
 
@@ -1439,7 +1439,7 @@ int fsync_node_pages(struct f2fs_sb_info *sbi, struct inode *inode,
 			return PTR_ERR_OR_ZERO(last_page);
 	}
 retry:
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	index = 0;
 	end = ULONG_MAX;
 
@@ -1554,7 +1554,7 @@ int sync_node_pages(struct f2fs_sb_info *sbi, struct writeback_control *wbc,
 	int nwritten = 0;
 	int ret = 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 
 next_step:
 	index = 0;
@@ -1659,7 +1659,7 @@ int wait_on_node_pages_writeback(struct f2fs_sb_info *sbi, nid_t ino)
 	struct pagevec pvec;
 	int ret2, ret = 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 
 	while (index <= end) {
 		int i, nr_pages;
diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index 0ad3fd3ad0b4..961029e04027 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -1175,7 +1175,7 @@ void __fscache_uncache_all_inode_pages(struct fscache_cookie *cookie,
 		return;
 	}
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	next = 0;
 	do {
 		if (!pagevec_lookup(&pvec, mapping, &next))
diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
index 68ed06962537..84310209827b 100644
--- a/fs/gfs2/aops.c
+++ b/fs/gfs2/aops.c
@@ -387,7 +387,7 @@ static int gfs2_write_cache_jdata(struct address_space *mapping,
 	int range_whole = 0;
 	int tag;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	if (wbc->range_cyclic) {
 		writeback_index = mapping->writeback_index; /* prev offset */
 		index = writeback_index;
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 59073e9f01a4..2c87306799c4 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -407,7 +407,7 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 
 	memset(&pseudo_vma, 0, sizeof(struct vm_area_struct));
 	pseudo_vma.vm_flags = (VM_HUGETLB | VM_MAYSHARE | VM_SHARED);
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	next = start;
 	while (next < end) {
 		/*
diff --git a/fs/nilfs2/btree.c b/fs/nilfs2/btree.c
index 06ffa135dfa6..5e90c5bd91d9 100644
--- a/fs/nilfs2/btree.c
+++ b/fs/nilfs2/btree.c
@@ -2156,7 +2156,7 @@ static void nilfs_btree_lookup_dirty_buffers(struct nilfs_bmap *btree,
 	     level++)
 		INIT_LIST_HEAD(&lists[level]);
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 
 	while (pagevec_lookup_tag(&pvec, btcache, &index, PAGECACHE_TAG_DIRTY,
 				  PAGEVEC_SIZE)) {
diff --git a/fs/nilfs2/page.c b/fs/nilfs2/page.c
index 8616c46d33da..60ee9d2b901d 100644
--- a/fs/nilfs2/page.c
+++ b/fs/nilfs2/page.c
@@ -255,7 +255,7 @@ int nilfs_copy_dirty_pages(struct address_space *dmap,
 	pgoff_t index = 0;
 	int err = 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 repeat:
 	if (!pagevec_lookup_tag(&pvec, smap, &index, PAGECACHE_TAG_DIRTY,
 				PAGEVEC_SIZE))
@@ -310,7 +310,7 @@ void nilfs_copy_back_pages(struct address_space *dmap,
 	pgoff_t index = 0;
 	int err;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 repeat:
 	n = pagevec_lookup(&pvec, smap, &index);
 	if (!n)
@@ -374,7 +374,7 @@ void nilfs_clear_dirty_pages(struct address_space *mapping, bool silent)
 	unsigned int i;
 	pgoff_t index = 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 
 	while (pagevec_lookup_tag(&pvec, mapping, &index, PAGECACHE_TAG_DIRTY,
 				  PAGEVEC_SIZE)) {
@@ -519,7 +519,7 @@ unsigned long nilfs_find_uncommitted_extent(struct inode *inode,
 	index = start_blk >> (PAGE_SHIFT - inode->i_blkbits);
 	nblocks_in_page = 1U << (PAGE_SHIFT - inode->i_blkbits);
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 
 repeat:
 	pvec.nr = find_get_pages_contig(inode->i_mapping, index, PAGEVEC_SIZE,
diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
index 70ded52dc1dd..0d56c4ea7216 100644
--- a/fs/nilfs2/segment.c
+++ b/fs/nilfs2/segment.c
@@ -708,7 +708,7 @@ static size_t nilfs_lookup_dirty_data_buffers(struct inode *inode,
 		index = start >> PAGE_SHIFT;
 		last = end >> PAGE_SHIFT;
 	}
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
  repeat:
 	if (unlikely(index > last) ||
 	    !pagevec_lookup_tag(&pvec, mapping, &index, PAGECACHE_TAG_DIRTY,
@@ -757,7 +757,7 @@ static void nilfs_lookup_dirty_node_buffers(struct inode *inode,
 	unsigned int i;
 	pgoff_t index = 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 
 	while (pagevec_lookup_tag(&pvec, mapping, &index, PAGECACHE_TAG_DIRTY,
 				  PAGEVEC_SIZE)) {
diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index 4231979be982..11fdbe539aa6 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -16,7 +16,6 @@ struct address_space;
 
 struct pagevec {
 	unsigned long nr;
-	bool cold;
 	bool drained;
 	struct page *pages[PAGEVEC_SIZE];
 };
@@ -42,10 +41,9 @@ unsigned pagevec_lookup_tag(struct pagevec *pvec,
 		struct address_space *mapping, pgoff_t *index, int tag,
 		unsigned nr_pages);
 
-static inline void pagevec_init(struct pagevec *pvec, int cold)
+static inline void pagevec_init(struct pagevec *pvec)
 {
 	pvec->nr = 0;
-	pvec->cold = cold;
 	pvec->drained = false;
 }
 
diff --git a/mm/filemap.c b/mm/filemap.c
index d8719d755ca9..e697d1051e97 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -520,7 +520,7 @@ static void __filemap_fdatawait_range(struct address_space *mapping,
 	if (end_byte < start_byte)
 		return;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	while ((index <= end) &&
 			(nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
 			PAGECACHE_TAG_WRITEBACK,
diff --git a/mm/mlock.c b/mm/mlock.c
index dfc6f1912176..936d39ad4c04 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -288,7 +288,7 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 	struct pagevec pvec_putback;
 	int pgrescued = 0;
 
-	pagevec_init(&pvec_putback, 0);
+	pagevec_init(&pvec_putback);
 
 	/* Phase 1: page isolation */
 	spin_lock_irq(zone_lru_lock(zone));
@@ -447,7 +447,7 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 		struct pagevec pvec;
 		struct zone *zone;
 
-		pagevec_init(&pvec, 0);
+		pagevec_init(&pvec);
 		/*
 		 * Although FOLL_DUMP is intended for get_dump_page(),
 		 * it just so happens that its special treatment of the
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index c3bed3f5cd24..21923ad7317b 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2167,7 +2167,7 @@ int write_cache_pages(struct address_space *mapping,
 	int range_whole = 0;
 	int tag;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	if (wbc->range_cyclic) {
 		writeback_index = mapping->writeback_index; /* prev offset */
 		index = writeback_index;
diff --git a/mm/shmem.c b/mm/shmem.c
index 07a1d22807be..d9f5b4061e4e 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -747,7 +747,7 @@ void shmem_unlock_mapping(struct address_space *mapping)
 	pgoff_t indices[PAGEVEC_SIZE];
 	pgoff_t index = 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	/*
 	 * Minor point, but we might as well stop if someone else SHM_LOCKs it.
 	 */
@@ -790,7 +790,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 	if (lend == -1)
 		end = -1;	/* unsigned, so actually very big */
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	index = start;
 	while (index < end) {
 		pvec.nr = find_get_entries(mapping, index,
@@ -2528,7 +2528,7 @@ static pgoff_t shmem_seek_hole_data(struct address_space *mapping,
 	bool done = false;
 	int i;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	pvec.nr = 1;		/* start small: we may be there already */
 	while (!done) {
 		pvec.nr = find_get_entries(mapping, index,
diff --git a/mm/swap.c b/mm/swap.c
index 31bd9d8a5db7..73682e1dc0a2 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -210,7 +210,7 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
 	}
 	if (pgdat)
 		spin_unlock_irqrestore(&pgdat->lru_lock, flags);
-	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	release_pages(pvec->pages, pvec->nr, 0);
 	pagevec_reinit(pvec);
 }
 
@@ -837,7 +837,7 @@ void __pagevec_release(struct pagevec *pvec)
 		lru_add_drain();
 		pvec->drained = true;
 	}
-	release_pages(pvec->pages, pagevec_count(pvec), pvec->cold);
+	release_pages(pvec->pages, pagevec_count(pvec), 0);
 	pagevec_reinit(pvec);
 }
 EXPORT_SYMBOL(__pagevec_release);
diff --git a/mm/truncate.c b/mm/truncate.c
index af1eaa5b9450..f4b8efb0fff0 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -322,7 +322,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	else
 		end = (lend + 1) >> PAGE_SHIFT;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	index = start;
 	while (index < end && pagevec_lookup_entries(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE),
@@ -554,7 +554,7 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 	unsigned long count = 0;
 	int i;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	while (index <= end && pagevec_lookup_entries(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
 			indices)) {
@@ -684,7 +684,7 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 	if (mapping->nrpages == 0 && mapping->nrexceptional == 0)
 		goto out;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	index = start;
 	while (index <= end && pagevec_lookup_entries(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
-- 
2.14.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
