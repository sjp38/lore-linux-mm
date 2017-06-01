Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9C96D6B03B7
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:35:15 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d127so8646021wmf.15
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:35:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d81si22003090wmi.122.2017.06.01.02.33.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 02:33:16 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 19/35] f2fs: Simplify page iteration loops
Date: Thu,  1 Jun 2017 11:32:29 +0200
Message-Id: <20170601093245.29238-20-jack@suse.cz>
In-Reply-To: <20170601093245.29238-1-jack@suse.cz>
References: <20170601093245.29238-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu, linux-ext4@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Jan Kara <jack@suse.cz>

In several places we want to iterate over all tagged pages in a mapping.
However the code was apparently copied from places that iterate only
over a limited range and thus it checks for index <= end, optimizes the
case where we are coming close to range end which is all pointless when
end == ULONG_MAX. So just remove this dead code.

CC: Jaegeuk Kim <jaegeuk@kernel.org>
CC: linux-f2fs-devel@lists.sourceforge.net
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/f2fs/checkpoint.c | 13 ++++-------
 fs/f2fs/node.c       | 65 +++++++++++++++++++---------------------------------
 2 files changed, 28 insertions(+), 50 deletions(-)

diff --git a/fs/f2fs/checkpoint.c b/fs/f2fs/checkpoint.c
index ea9c317b5916..6da86eac758a 100644
--- a/fs/f2fs/checkpoint.c
+++ b/fs/f2fs/checkpoint.c
@@ -296,9 +296,10 @@ long sync_meta_pages(struct f2fs_sb_info *sbi, enum page_type type,
 						long nr_to_write)
 {
 	struct address_space *mapping = META_MAPPING(sbi);
-	pgoff_t index = 0, end = ULONG_MAX, prev = ULONG_MAX;
+	pgoff_t index = 0, prev = ULONG_MAX;
 	struct pagevec pvec;
 	long nwritten = 0;
+	int nr_pages;
 	struct writeback_control wbc = {
 		.for_reclaim = 0,
 	};
@@ -308,13 +309,9 @@ long sync_meta_pages(struct f2fs_sb_info *sbi, enum page_type type,
 
 	blk_start_plug(&plug);
 
-	while (index <= end) {
-		int i, nr_pages;
-		nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
-				PAGECACHE_TAG_DIRTY,
-				min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1);
-		if (unlikely(nr_pages == 0))
-			break;
+	while (nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
+				PAGECACHE_TAG_DIRTY, PAGEVEC_SIZE)) {
+		int i;
 
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
diff --git a/fs/f2fs/node.c b/fs/f2fs/node.c
index 4547c5c5cd98..dd53bcd9fc46 100644
--- a/fs/f2fs/node.c
+++ b/fs/f2fs/node.c
@@ -1259,21 +1259,17 @@ void move_node_page(struct page *node_page, int gc_type)
 
 static struct page *last_fsync_dnode(struct f2fs_sb_info *sbi, nid_t ino)
 {
-	pgoff_t index, end;
+	pgoff_t index;
 	struct pagevec pvec;
 	struct page *last_page = NULL;
+	int nr_pages;
 
 	pagevec_init(&pvec, 0);
 	index = 0;
-	end = ULONG_MAX;
-
-	while (index <= end) {
-		int i, nr_pages;
-		nr_pages = pagevec_lookup_tag(&pvec, NODE_MAPPING(sbi), &index,
-				PAGECACHE_TAG_DIRTY,
-				min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1);
-		if (nr_pages == 0)
-			break;
+
+	while (nr_pages = pagevec_lookup_tag(&pvec, NODE_MAPPING(sbi), &index,
+				PAGECACHE_TAG_DIRTY, PAGEVEC_SIZE)) {
+		int i;
 
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
@@ -1403,13 +1399,14 @@ static int f2fs_write_node_page(struct page *page,
 int fsync_node_pages(struct f2fs_sb_info *sbi, struct inode *inode,
 			struct writeback_control *wbc, bool atomic)
 {
-	pgoff_t index, end;
+	pgoff_t index;
 	pgoff_t last_idx = ULONG_MAX;
 	struct pagevec pvec;
 	int ret = 0;
 	struct page *last_page = NULL;
 	bool marked = false;
 	nid_t ino = inode->i_ino;
+	int nr_pages;
 
 	if (atomic) {
 		last_page = last_fsync_dnode(sbi, ino);
@@ -1419,15 +1416,10 @@ int fsync_node_pages(struct f2fs_sb_info *sbi, struct inode *inode,
 retry:
 	pagevec_init(&pvec, 0);
 	index = 0;
-	end = ULONG_MAX;
-
-	while (index <= end) {
-		int i, nr_pages;
-		nr_pages = pagevec_lookup_tag(&pvec, NODE_MAPPING(sbi), &index,
-				PAGECACHE_TAG_DIRTY,
-				min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1);
-		if (nr_pages == 0)
-			break;
+
+	while (nr_pages = pagevec_lookup_tag(&pvec, NODE_MAPPING(sbi), &index,
+				PAGECACHE_TAG_DIRTY, PAGEVEC_SIZE)) {
+		int i;
 
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
@@ -1525,25 +1517,21 @@ int fsync_node_pages(struct f2fs_sb_info *sbi, struct inode *inode,
 
 int sync_node_pages(struct f2fs_sb_info *sbi, struct writeback_control *wbc)
 {
-	pgoff_t index, end;
+	pgoff_t index;
 	struct pagevec pvec;
 	int step = 0;
 	int nwritten = 0;
 	int ret = 0;
+	int nr_pages;
 
 	pagevec_init(&pvec, 0);
 
 next_step:
 	index = 0;
-	end = ULONG_MAX;
-
-	while (index <= end) {
-		int i, nr_pages;
-		nr_pages = pagevec_lookup_tag(&pvec, NODE_MAPPING(sbi), &index,
-				PAGECACHE_TAG_DIRTY,
-				min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1);
-		if (nr_pages == 0)
-			break;
+
+	while (nr_pages = pagevec_lookup_tag(&pvec, NODE_MAPPING(sbi), &index,
+				PAGECACHE_TAG_DIRTY, PAGEVEC_SIZE)) {
+		int i;
 
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
@@ -1631,27 +1619,20 @@ int sync_node_pages(struct f2fs_sb_info *sbi, struct writeback_control *wbc)
 
 int wait_on_node_pages_writeback(struct f2fs_sb_info *sbi, nid_t ino)
 {
-	pgoff_t index = 0, end = ULONG_MAX;
+	pgoff_t index = 0;
 	struct pagevec pvec;
 	int ret2, ret = 0;
+	int nr_pages;
 
 	pagevec_init(&pvec, 0);
 
-	while (index <= end) {
-		int i, nr_pages;
-		nr_pages = pagevec_lookup_tag(&pvec, NODE_MAPPING(sbi), &index,
-				PAGECACHE_TAG_WRITEBACK,
-				min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1);
-		if (nr_pages == 0)
-			break;
+	while (nr_pages = pagevec_lookup_tag(&pvec, NODE_MAPPING(sbi), &index,
+				PAGECACHE_TAG_WRITEBACK, PAGEVEC_SIZE)) {
+		int i;
 
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
 
-			/* until radix tree lookup accepts end_index */
-			if (unlikely(page->index > end))
-				continue;
-
 			if (ino && ino_of_node(page) == ino) {
 				f2fs_wait_on_page_writeback(page, NODE, true);
 				if (TestClearPageError(page))
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
