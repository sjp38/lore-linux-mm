Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 132CE6B0260
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 11:15:27 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id q203so26524446wmb.0
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 08:15:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s63si6888460wmb.56.2017.10.09.08.14.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Oct 2017 08:14:07 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 14/16] mm: Remove nr_pages argument from pagevec_lookup_{,range}_tag()
Date: Mon,  9 Oct 2017 17:13:57 +0200
Message-Id: <20171009151359.31984-15-jack@suse.cz>
In-Reply-To: <20171009151359.31984-1-jack@suse.cz>
References: <20171009151359.31984-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Daniel Jordan <daniel.m.jordan@oracle.com>, Jan Kara <jack@suse.cz>

All users of pagevec_lookup() and pagevec_lookup_range() now pass
PAGEVEC_SIZE as a desired number of pages. Just drop the argument.

Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/btrfs/extent_io.c    | 6 +++---
 fs/ceph/addr.c          | 3 +--
 fs/ext4/inode.c         | 2 +-
 fs/f2fs/checkpoint.c    | 2 +-
 fs/f2fs/data.c          | 2 +-
 fs/f2fs/node.c          | 8 ++++----
 fs/gfs2/aops.c          | 2 +-
 fs/nilfs2/btree.c       | 4 ++--
 fs/nilfs2/page.c        | 7 +++----
 fs/nilfs2/segment.c     | 6 +++---
 include/linux/pagevec.h | 8 +++-----
 mm/filemap.c            | 2 +-
 mm/page-writeback.c     | 2 +-
 mm/swap.c               | 4 ++--
 14 files changed, 27 insertions(+), 31 deletions(-)

diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index a4eb6c988f27..b12552d21dab 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -3819,7 +3819,7 @@ int btree_write_cache_pages(struct address_space *mapping,
 		tag_pages_for_writeback(mapping, index, end);
 	while (!done && !nr_to_write_done && (index <= end) &&
 	       (nr_pages = pagevec_lookup_range_tag(&pvec, mapping, &index, end,
-			tag, PAGEVEC_SIZE))) {
+			tag))) {
 		unsigned i;
 
 		scanned = 1;
@@ -3960,8 +3960,8 @@ static int extent_write_cache_pages(struct address_space *mapping,
 		tag_pages_for_writeback(mapping, index, end);
 	done_index = index;
 	while (!done && !nr_to_write_done && (index <= end) &&
-	       (nr_pages = pagevec_lookup_range_tag(&pvec, mapping, &index, end,
-			tag, PAGEVEC_SIZE))) {
+			(nr_pages = pagevec_lookup_range_tag(&pvec, mapping,
+						&index, end, tag))) {
 		unsigned i;
 
 		scanned = 1;
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 87789c477381..182f92a6a9c2 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -1161,8 +1161,7 @@ static int ceph_writepages_start(struct address_space *mapping,
 			index = 0;
 			while ((index <= end) &&
 			       (nr = pagevec_lookup_tag(&pvec, mapping, &index,
-							PAGECACHE_TAG_WRITEBACK,
-							PAGEVEC_SIZE))) {
+						PAGECACHE_TAG_WRITEBACK))) {
 				for (i = 0; i < nr; i++) {
 					page = pvec.pages[i];
 					if (page_snap_context(page) != snapc)
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 69f11233d0d6..1e2c6d6e09eb 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -2620,7 +2620,7 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 	mpd->next_page = index;
 	while (index <= end) {
 		nr_pages = pagevec_lookup_range_tag(&pvec, mapping, &index, end,
-				tag, PAGEVEC_SIZE);
+				tag);
 		if (nr_pages == 0)
 			goto out;
 
diff --git a/fs/f2fs/checkpoint.c b/fs/f2fs/checkpoint.c
index 54ccf5ba8191..3ed9dcbf70ae 100644
--- a/fs/f2fs/checkpoint.c
+++ b/fs/f2fs/checkpoint.c
@@ -319,7 +319,7 @@ long sync_meta_pages(struct f2fs_sb_info *sbi, enum page_type type,
 	blk_start_plug(&plug);
 
 	while (nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
-				PAGECACHE_TAG_DIRTY, PAGEVEC_SIZE)) {
+				PAGECACHE_TAG_DIRTY)) {
 		int i;
 
 		for (i = 0; i < nr_pages; i++) {
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 17d2c2997ddd..687703755824 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -1670,7 +1670,7 @@ static int f2fs_write_cache_pages(struct address_space *mapping,
 		int i;
 
 		nr_pages = pagevec_lookup_range_tag(&pvec, mapping, &index, end,
-				tag, PAGEVEC_SIZE);
+				tag);
 		if (nr_pages == 0)
 			break;
 
diff --git a/fs/f2fs/node.c b/fs/f2fs/node.c
index f9ccbda73ea9..d4ceb9ebfe92 100644
--- a/fs/f2fs/node.c
+++ b/fs/f2fs/node.c
@@ -1286,7 +1286,7 @@ static struct page *last_fsync_dnode(struct f2fs_sb_info *sbi, nid_t ino)
 	index = 0;
 
 	while (nr_pages = pagevec_lookup_tag(&pvec, NODE_MAPPING(sbi), &index,
-				PAGECACHE_TAG_DIRTY, PAGEVEC_SIZE)) {
+				PAGECACHE_TAG_DIRTY)) {
 		int i;
 
 		for (i = 0; i < nr_pages; i++) {
@@ -1440,7 +1440,7 @@ int fsync_node_pages(struct f2fs_sb_info *sbi, struct inode *inode,
 	index = 0;
 
 	while (nr_pages = pagevec_lookup_tag(&pvec, NODE_MAPPING(sbi), &index,
-				PAGECACHE_TAG_DIRTY, PAGEVEC_SIZE)) {
+				PAGECACHE_TAG_DIRTY)) {
 		int i;
 
 		for (i = 0; i < nr_pages; i++) {
@@ -1553,7 +1553,7 @@ int sync_node_pages(struct f2fs_sb_info *sbi, struct writeback_control *wbc,
 	index = 0;
 
 	while (nr_pages = pagevec_lookup_tag(&pvec, NODE_MAPPING(sbi), &index,
-				PAGECACHE_TAG_DIRTY, PAGEVEC_SIZE)) {
+				PAGECACHE_TAG_DIRTY)) {
 		int i;
 
 		for (i = 0; i < nr_pages; i++) {
@@ -1651,7 +1651,7 @@ int wait_on_node_pages_writeback(struct f2fs_sb_info *sbi, nid_t ino)
 	pagevec_init(&pvec, 0);
 
 	while (nr_pages = pagevec_lookup_tag(&pvec, NODE_MAPPING(sbi), &index,
-				PAGECACHE_TAG_WRITEBACK, PAGEVEC_SIZE)) {
+				PAGECACHE_TAG_WRITEBACK)) {
 		int i;
 
 		for (i = 0; i < nr_pages; i++) {
diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
index d0848d9623fb..3fea3d7780b0 100644
--- a/fs/gfs2/aops.c
+++ b/fs/gfs2/aops.c
@@ -398,7 +398,7 @@ static int gfs2_write_cache_jdata(struct address_space *mapping,
 	done_index = index;
 	while (!done && (index <= end)) {
 		nr_pages = pagevec_lookup_range_tag(&pvec, mapping, &index, end,
-				tag, PAGEVEC_SIZE);
+				tag);
 		if (nr_pages == 0)
 			break;
 
diff --git a/fs/nilfs2/btree.c b/fs/nilfs2/btree.c
index 06ffa135dfa6..35989c7bb065 100644
--- a/fs/nilfs2/btree.c
+++ b/fs/nilfs2/btree.c
@@ -2158,8 +2158,8 @@ static void nilfs_btree_lookup_dirty_buffers(struct nilfs_bmap *btree,
 
 	pagevec_init(&pvec, 0);
 
-	while (pagevec_lookup_tag(&pvec, btcache, &index, PAGECACHE_TAG_DIRTY,
-				  PAGEVEC_SIZE)) {
+	while (pagevec_lookup_tag(&pvec, btcache, &index,
+					PAGECACHE_TAG_DIRTY)) {
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			bh = head = page_buffers(pvec.pages[i]);
 			do {
diff --git a/fs/nilfs2/page.c b/fs/nilfs2/page.c
index 8616c46d33da..1c16726915c1 100644
--- a/fs/nilfs2/page.c
+++ b/fs/nilfs2/page.c
@@ -257,8 +257,7 @@ int nilfs_copy_dirty_pages(struct address_space *dmap,
 
 	pagevec_init(&pvec, 0);
 repeat:
-	if (!pagevec_lookup_tag(&pvec, smap, &index, PAGECACHE_TAG_DIRTY,
-				PAGEVEC_SIZE))
+	if (!pagevec_lookup_tag(&pvec, smap, &index, PAGECACHE_TAG_DIRTY))
 		return 0;
 
 	for (i = 0; i < pagevec_count(&pvec); i++) {
@@ -376,8 +375,8 @@ void nilfs_clear_dirty_pages(struct address_space *mapping, bool silent)
 
 	pagevec_init(&pvec, 0);
 
-	while (pagevec_lookup_tag(&pvec, mapping, &index, PAGECACHE_TAG_DIRTY,
-				  PAGEVEC_SIZE)) {
+	while (pagevec_lookup_tag(&pvec, mapping, &index,
+					PAGECACHE_TAG_DIRTY)) {
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
index 68e5769cef3b..19366ab20bea 100644
--- a/fs/nilfs2/segment.c
+++ b/fs/nilfs2/segment.c
@@ -712,7 +712,7 @@ static size_t nilfs_lookup_dirty_data_buffers(struct inode *inode,
  repeat:
 	if (unlikely(index > last) ||
 	    !pagevec_lookup_range_tag(&pvec, mapping, &index, last,
-				PAGECACHE_TAG_DIRTY, PAGEVEC_SIZE))
+				PAGECACHE_TAG_DIRTY))
 		return ndirties;
 
 	for (i = 0; i < pagevec_count(&pvec); i++) {
@@ -755,8 +755,8 @@ static void nilfs_lookup_dirty_node_buffers(struct inode *inode,
 
 	pagevec_init(&pvec, 0);
 
-	while (pagevec_lookup_tag(&pvec, mapping, &index, PAGECACHE_TAG_DIRTY,
-				  PAGEVEC_SIZE)) {
+	while (pagevec_lookup_tag(&pvec, mapping, &index,
+					PAGECACHE_TAG_DIRTY)) {
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			bh = head = page_buffers(pvec.pages[i]);
 			do {
diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index 0281b1d3a91b..553b5e6fbbc5 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -39,16 +39,14 @@ static inline unsigned pagevec_lookup(struct pagevec *pvec,
 
 unsigned pagevec_lookup_range_tag(struct pagevec *pvec,
 		struct address_space *mapping, pgoff_t *index, pgoff_t end,
-		int tag, unsigned nr_pages);
+		int tag);
 unsigned pagevec_lookup_range_nr_tag(struct pagevec *pvec,
 		struct address_space *mapping, pgoff_t *index, pgoff_t end,
 		int tag, unsigned max_pages);
 static inline unsigned pagevec_lookup_tag(struct pagevec *pvec,
-		struct address_space *mapping, pgoff_t *index, int tag,
-		unsigned nr_pages)
+		struct address_space *mapping, pgoff_t *index, int tag)
 {
-	return pagevec_lookup_range_tag(pvec, mapping, index, (pgoff_t)-1, tag,
-					nr_pages);
+	return pagevec_lookup_range_tag(pvec, mapping, index, (pgoff_t)-1, tag);
 }
 
 static inline void pagevec_init(struct pagevec *pvec, int cold)
diff --git a/mm/filemap.c b/mm/filemap.c
index 229481d258bc..6eb4e32d99c8 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -424,7 +424,7 @@ static void __filemap_fdatawait_range(struct address_space *mapping,
 		unsigned i;
 
 		nr_pages = pagevec_lookup_range_tag(&pvec, mapping, &index,
-				end, PAGECACHE_TAG_WRITEBACK, PAGEVEC_SIZE);
+				end, PAGECACHE_TAG_WRITEBACK);
 		if (!nr_pages)
 			break;
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 43b18e185fbd..145054a2447f 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2195,7 +2195,7 @@ int write_cache_pages(struct address_space *mapping,
 		int i;
 
 		nr_pages = pagevec_lookup_range_tag(&pvec, mapping, &index, end,
-				tag, PAGEVEC_SIZE);
+				tag);
 		if (nr_pages == 0)
 			break;
 
diff --git a/mm/swap.c b/mm/swap.c
index 6c50fec2da92..4edac536fe24 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -988,10 +988,10 @@ EXPORT_SYMBOL(pagevec_lookup_range);
 
 unsigned pagevec_lookup_range_tag(struct pagevec *pvec,
 		struct address_space *mapping, pgoff_t *index, pgoff_t end,
-		int tag, unsigned nr_pages)
+		int tag)
 {
 	pvec->nr = find_get_pages_range_tag(mapping, index, end, tag,
-					nr_pages, pvec->pages);
+					PAGEVEC_SIZE, pvec->pages);
 	return pagevec_count(pvec);
 }
 EXPORT_SYMBOL(pagevec_lookup_range_tag);
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
