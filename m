Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 177C06B03B1
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:35:14 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r203so8703243wmb.2
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:35:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b30si21502467wrd.184.2017.06.01.02.33.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 02:33:16 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 25/35] mm: Remove nr_pages argument from pagevec_lookup_{,range}_tag()
Date: Thu,  1 Jun 2017 11:32:35 +0200
Message-Id: <20170601093245.29238-26-jack@suse.cz>
In-Reply-To: <20170601093245.29238-1-jack@suse.cz>
References: <20170601093245.29238-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu, linux-ext4@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Jan Kara <jack@suse.cz>

All users of pagevec_lookup() and pagevec_lookup_range() now pass
PAGEVEC_SIZE as a desired number of pages. Just drop the argument.

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
index 6287eaba30ac..53d742a5a99b 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -3838,7 +3838,7 @@ int btree_write_cache_pages(struct address_space *mapping,
 		tag_pages_for_writeback(mapping, index, end);
 	while (!done && !nr_to_write_done && (index <= end) &&
 	       (nr_pages = pagevec_lookup_range_tag(&pvec, mapping, &index, end,
-			tag, PAGEVEC_SIZE))) {
+			tag))) {
 		unsigned i;
 
 		scanned = 1;
@@ -3979,8 +3979,8 @@ static int extent_write_cache_pages(struct address_space *mapping,
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
index 0b7e56ae3b8c..a0d5c46fc9bf 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -848,8 +848,7 @@ static int ceph_writepages_start(struct address_space *mapping,
 get_more_pages:
 		first = -1;
 		pvec_pages = pagevec_lookup_range_tag(&pvec, mapping, &index,
-						end, PAGECACHE_TAG_DIRTY,
-						PAGEVEC_SIZE);
+						end, PAGECACHE_TAG_DIRTY);
 		dout("pagevec_lookup_range_tag got %d\n", pvec_pages);
 		if (!pvec_pages && !locked_pages)
 			break;
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 050fba2d12c2..d1896f14d72f 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -2556,7 +2556,7 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 	mpd->next_page = index;
 	while (index <= end) {
 		nr_pages = pagevec_lookup_range_tag(&pvec, mapping, &index, end,
-				tag, PAGEVEC_SIZE);
+				tag);
 		if (nr_pages == 0)
 			goto out;
 
diff --git a/fs/f2fs/checkpoint.c b/fs/f2fs/checkpoint.c
index 6da86eac758a..ad5bc5340ba2 100644
--- a/fs/f2fs/checkpoint.c
+++ b/fs/f2fs/checkpoint.c
@@ -310,7 +310,7 @@ long sync_meta_pages(struct f2fs_sb_info *sbi, enum page_type type,
 	blk_start_plug(&plug);
 
 	while (nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
-				PAGECACHE_TAG_DIRTY, PAGEVEC_SIZE)) {
+				PAGECACHE_TAG_DIRTY)) {
 		int i;
 
 		for (i = 0; i < nr_pages; i++) {
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 3e6244a82ac5..afca42392fbd 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -1604,7 +1604,7 @@ static int f2fs_write_cache_pages(struct address_space *mapping,
 		int i;
 
 		nr_pages = pagevec_lookup_range_tag(&pvec, mapping, &index, end,
-				tag, PAGEVEC_SIZE);
+				tag);
 		if (nr_pages == 0)
 			break;
 
diff --git a/fs/f2fs/node.c b/fs/f2fs/node.c
index dd53bcd9fc46..00cae42c778a 100644
--- a/fs/f2fs/node.c
+++ b/fs/f2fs/node.c
@@ -1268,7 +1268,7 @@ static struct page *last_fsync_dnode(struct f2fs_sb_info *sbi, nid_t ino)
 	index = 0;
 
 	while (nr_pages = pagevec_lookup_tag(&pvec, NODE_MAPPING(sbi), &index,
-				PAGECACHE_TAG_DIRTY, PAGEVEC_SIZE)) {
+				PAGECACHE_TAG_DIRTY)) {
 		int i;
 
 		for (i = 0; i < nr_pages; i++) {
@@ -1418,7 +1418,7 @@ int fsync_node_pages(struct f2fs_sb_info *sbi, struct inode *inode,
 	index = 0;
 
 	while (nr_pages = pagevec_lookup_tag(&pvec, NODE_MAPPING(sbi), &index,
-				PAGECACHE_TAG_DIRTY, PAGEVEC_SIZE)) {
+				PAGECACHE_TAG_DIRTY)) {
 		int i;
 
 		for (i = 0; i < nr_pages; i++) {
@@ -1530,7 +1530,7 @@ int sync_node_pages(struct f2fs_sb_info *sbi, struct writeback_control *wbc)
 	index = 0;
 
 	while (nr_pages = pagevec_lookup_tag(&pvec, NODE_MAPPING(sbi), &index,
-				PAGECACHE_TAG_DIRTY, PAGEVEC_SIZE)) {
+				PAGECACHE_TAG_DIRTY)) {
 		int i;
 
 		for (i = 0; i < nr_pages; i++) {
@@ -1627,7 +1627,7 @@ int wait_on_node_pages_writeback(struct f2fs_sb_info *sbi, nid_t ino)
 	pagevec_init(&pvec, 0);
 
 	while (nr_pages = pagevec_lookup_tag(&pvec, NODE_MAPPING(sbi), &index,
-				PAGECACHE_TAG_WRITEBACK, PAGEVEC_SIZE)) {
+				PAGECACHE_TAG_WRITEBACK)) {
 		int i;
 
 		for (i = 0; i < nr_pages; i++) {
diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
index 158ceb900ab5..903a1c9f60a5 100644
--- a/fs/gfs2/aops.c
+++ b/fs/gfs2/aops.c
@@ -386,7 +386,7 @@ static int gfs2_write_cache_jdata(struct address_space *mapping,
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
index fd9eeca5f784..c123f1590e41 100644
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
index 371edacc10d5..f3f2b9690764 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -39,13 +39,11 @@ static inline unsigned pagevec_lookup(struct pagevec *pvec,
 
 unsigned pagevec_lookup_range_tag(struct pagevec *pvec,
 		struct address_space *mapping, pgoff_t *index, pgoff_t end,
-		int tag, unsigned nr_pages);
+		int tag);
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
index 8039b6bb9c27..910f2e39fef2 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -391,7 +391,7 @@ static int __filemap_fdatawait_range(struct address_space *mapping,
 	pagevec_init(&pvec, 0);
 	while ((index <= end) &&
 			(nr_pages = pagevec_lookup_range_tag(&pvec, mapping,
-			&index, end, PAGECACHE_TAG_WRITEBACK, PAGEVEC_SIZE))) {
+			&index, end, PAGECACHE_TAG_WRITEBACK))) {
 		unsigned i;
 
 		for (i = 0; i < nr_pages; i++) {
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index c77c387465ec..6fd235139d8e 100644
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
index 4714d07965c1..dc63970f79b9 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -971,10 +971,10 @@ EXPORT_SYMBOL(pagevec_lookup_range);
 
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
