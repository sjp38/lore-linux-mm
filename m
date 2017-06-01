Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 71F996B0315
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:33:17 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id g143so8705302wme.13
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:33:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b127si33853260wmf.46.2017.06.01.02.33.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 02:33:16 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 13/35] mm: Remove nr_pages argument from pagevec_lookup{,_range}()
Date: Thu,  1 Jun 2017 11:32:23 +0200
Message-Id: <20170601093245.29238-14-jack@suse.cz>
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
 fs/buffer.c             | 3 +--
 fs/ext4/file.c          | 2 +-
 fs/ext4/inode.c         | 5 ++---
 fs/fscache/page.c       | 2 +-
 fs/hugetlbfs/inode.c    | 3 +--
 fs/nilfs2/page.c        | 2 +-
 fs/xfs/xfs_file.c       | 2 +-
 include/linux/pagevec.h | 7 +++----
 mm/swap.c               | 5 ++---
 9 files changed, 13 insertions(+), 18 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index d63b22e50f38..89605cb42a55 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1638,8 +1638,7 @@ void clean_bdev_aliases(struct block_device *bdev, sector_t block, sector_t len)
 
 	end = (block + len - 1) >> (PAGE_SHIFT - bd_inode->i_blkbits);
 	pagevec_init(&pvec, 0);
-	while (pagevec_lookup_range(&pvec, bd_mapping, &index, end,
-				    PAGEVEC_SIZE)) {
+	while (pagevec_lookup_range(&pvec, bd_mapping, &index, end)) {
 		count = pagevec_count(&pvec);
 		for (i = 0; i < count; i++) {
 			struct page *page = pvec.pages[i];
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 6821070a388b..2d9a198026e5 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -482,7 +482,7 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 		unsigned long nr_pages;
 
 		nr_pages = pagevec_lookup_range(&pvec, inode->i_mapping,
-					&index, end, PAGEVEC_SIZE);
+					&index, end);
 		if (nr_pages == 0)
 			break;
 
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 59d82530d269..ace4bb9073d8 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1670,8 +1670,7 @@ static void mpage_release_unused_pages(struct mpage_da_data *mpd,
 
 	pagevec_init(&pvec, 0);
 	while (index <= end) {
-		nr_pages = pagevec_lookup_range(&pvec, mapping, &index, end,
-						PAGEVEC_SIZE);
+		nr_pages = pagevec_lookup_range(&pvec, mapping, &index, end);
 		if (nr_pages == 0)
 			break;
 		for (i = 0; i < nr_pages; i++) {
@@ -2284,7 +2283,7 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
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
index 99885f9b9d56..461e01500e60 100644
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
 
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index f9343dac7ff9..a7abc981e4a9 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1049,7 +1049,7 @@ xfs_find_get_desired_pgoff(
 		unsigned int	i;
 
 		nr_pages = pagevec_lookup_range(&pvec, inode->i_mapping,
-						&index, end, PAGEVEC_SIZE);
+						&index, end);
 		if (nr_pages == 0)
 			break;
 
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
index 804c9867af96..a07a0105154b 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -961,10 +961,9 @@ void pagevec_remove_exceptionals(struct pagevec *pvec)
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
