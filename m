Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DB8DA6B02FD
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:47:28 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 77so512246wms.0
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 04:47:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p25si2899215wmi.237.2017.07.26.04.47.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 04:47:27 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 10/10] mm: Remove nr_pages argument from pagevec_lookup{,_range}()
Date: Wed, 26 Jul 2017 13:47:04 +0200
Message-Id: <20170726114704.7626-11-jack@suse.cz>
In-Reply-To: <20170726114704.7626-1-jack@suse.cz>
References: <20170726114704.7626-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>

All users of pagevec_lookup() and pagevec_lookup_range() now pass
PAGEVEC_SIZE as a desired number of pages. Just drop the argument.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/buffer.c             | 5 ++---
 fs/ext4/file.c          | 2 +-
 fs/ext4/inode.c         | 5 ++---
 fs/fscache/page.c       | 2 +-
 fs/hugetlbfs/inode.c    | 3 +--
 fs/nilfs2/page.c        | 2 +-
 include/linux/pagevec.h | 7 +++----
 mm/swap.c               | 5 ++---
 8 files changed, 13 insertions(+), 18 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 8770b58ca569..50da0e102ca0 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1633,8 +1633,7 @@ void clean_bdev_aliases(struct block_device *bdev, sector_t block, sector_t len)
 
 	end = (block + len - 1) >> (PAGE_SHIFT - bd_inode->i_blkbits);
 	pagevec_init(&pvec, 0);
-	while (pagevec_lookup_range(&pvec, bd_mapping, &index, end,
-				    PAGEVEC_SIZE)) {
+	while (pagevec_lookup_range(&pvec, bd_mapping, &index, end)) {
 		count = pagevec_count(&pvec);
 		for (i = 0; i < count; i++) {
 			struct page *page = pvec.pages[i];
@@ -3552,7 +3551,7 @@ page_cache_seek_hole_data(struct inode *inode, loff_t offset, loff_t length,
 		unsigned nr_pages, i;
 
 		nr_pages = pagevec_lookup_range(&pvec, inode->i_mapping, &index,
-						end - 1, PAGEVEC_SIZE);
+						end - 1);
 		if (nr_pages == 0)
 			break;
 
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index ac39a6a1ea5d..2d5153b343b8 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -498,7 +498,7 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 		unsigned long nr_pages;
 
 		nr_pages = pagevec_lookup_range(&pvec, inode->i_mapping,
-					&index, end, PAGEVEC_SIZE);
+					&index, end);
 		if (nr_pages == 0)
 			break;
 
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index eb86c1baf40c..6bc99d5056cb 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1676,8 +1676,7 @@ static void mpage_release_unused_pages(struct mpage_da_data *mpd,
 
 	pagevec_init(&pvec, 0);
 	while (index <= end) {
-		nr_pages = pagevec_lookup_range(&pvec, mapping, &index, end,
-						PAGEVEC_SIZE);
+		nr_pages = pagevec_lookup_range(&pvec, mapping, &index, end);
 		if (nr_pages == 0)
 			break;
 		for (i = 0; i < nr_pages; i++) {
@@ -2304,7 +2303,7 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
 	pagevec_init(&pvec, 0);
 	while (start <= end) {
 		nr_pages = pagevec_lookup_range(&pvec, inode->i_mapping,
-						&start, end, PAGEVEC_SIZE);
+						&start, end);
 		if (nr_pages == 0)
 			break;
 		for (i = 0; i < nr_pages; i++) {
diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index 83018861dcd2..0ad3fd3ad0b4 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -1178,7 +1178,7 @@ void __fscache_uncache_all_inode_pages(struct fscache_cookie *cookie,
 	pagevec_init(&pvec, 0);
 	next = 0;
 	do {
-		if (!pagevec_lookup(&pvec, mapping, &next, PAGEVEC_SIZE))
+		if (!pagevec_lookup(&pvec, mapping, &next))
 			break;
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 8931236f3ef4..7c02b3f738e1 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -413,8 +413,7 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 		/*
 		 * When no more pages are found, we are done.
 		 */
-		if (!pagevec_lookup_range(&pvec, mapping, &next, end - 1,
-					  PAGEVEC_SIZE))
+		if (!pagevec_lookup_range(&pvec, mapping, &next, end - 1))
 			break;
 
 		for (i = 0; i < pagevec_count(&pvec); ++i) {
diff --git a/fs/nilfs2/page.c b/fs/nilfs2/page.c
index 382a36c72d72..8616c46d33da 100644
--- a/fs/nilfs2/page.c
+++ b/fs/nilfs2/page.c
@@ -312,7 +312,7 @@ void nilfs_copy_back_pages(struct address_space *dmap,
 
 	pagevec_init(&pvec, 0);
 repeat:
-	n = pagevec_lookup(&pvec, smap, &index, PAGEVEC_SIZE);
+	n = pagevec_lookup(&pvec, smap, &index);
 	if (!n)
 		return;
 
diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index 7df056910437..4dcd5506f1ed 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -29,13 +29,12 @@ unsigned pagevec_lookup_entries(struct pagevec *pvec,
 void pagevec_remove_exceptionals(struct pagevec *pvec);
 unsigned pagevec_lookup_range(struct pagevec *pvec,
 			      struct address_space *mapping,
-			      pgoff_t *start, pgoff_t end, unsigned nr_pages);
+			      pgoff_t *start, pgoff_t end);
 static inline unsigned pagevec_lookup(struct pagevec *pvec,
 				      struct address_space *mapping,
-				      pgoff_t *start, unsigned nr_pages)
+				      pgoff_t *start)
 {
-	return pagevec_lookup_range(pvec, mapping, start, (pgoff_t)-1,
-				    nr_pages);
+	return pagevec_lookup_range(pvec, mapping, start, (pgoff_t)-1);
 }
 
 unsigned pagevec_lookup_tag(struct pagevec *pvec,
diff --git a/mm/swap.c b/mm/swap.c
index e06e9aa2478e..62d96b8e5eb3 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -967,10 +967,9 @@ void pagevec_remove_exceptionals(struct pagevec *pvec)
  * reached.
  */
 unsigned pagevec_lookup_range(struct pagevec *pvec,
-		struct address_space *mapping, pgoff_t *start, pgoff_t end,
-		unsigned nr_pages)
+		struct address_space *mapping, pgoff_t *start, pgoff_t end)
 {
-	pvec->nr = find_get_pages_range(mapping, start, end, nr_pages,
+	pvec->nr = find_get_pages_range(mapping, start, end, PAGEVEC_SIZE,
 					pvec->pages);
 	return pagevec_count(pvec);
 }
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
