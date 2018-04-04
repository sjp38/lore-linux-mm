Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6F5B06B0022
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:08 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id u8so6522154qkg.15
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:08 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 78si7197531qkq.78.2018.04.04.12.19.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:07 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 26/79] fs: add struct address_space to mpage_readpage() arguments
Date: Wed,  4 Apr 2018 15:18:00 -0400
Message-Id: <20180404191831.5378-11-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>, Jeff Layton <jlayton@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Add struct address_space to mpage_readpage(). Note this patch only add
arguments and modify call site conservatily using page->mapping and thus
the end result is as before this patch.

One step toward dropping reliance on page->mapping.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Jeff Layton <jlayton@redhat.com>
---
 fs/ext2/inode.c       |  2 +-
 fs/fat/inode.c        |  2 +-
 fs/gfs2/aops.c        |  2 +-
 fs/hpfs/file.c        |  2 +-
 fs/isofs/inode.c      |  2 +-
 fs/jfs/inode.c        |  2 +-
 fs/mpage.c            | 14 ++++++++------
 fs/nilfs2/inode.c     |  2 +-
 fs/qnx6/inode.c       |  2 +-
 fs/udf/inode.c        |  2 +-
 fs/xfs/xfs_aops.c     |  2 +-
 include/linux/mpage.h |  3 ++-
 12 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 11b3c3e7ea65..33873c0a4c14 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -872,7 +872,7 @@ static int ext2_writepage(struct address_space *mapping, struct page *page,
 static int ext2_readpage(struct file *file, struct address_space *mapping,
 			 struct page *page)
 {
-	return mpage_readpage(page, ext2_get_block);
+	return mpage_readpage(page->mapping, page, ext2_get_block);
 }
 
 static int
diff --git a/fs/fat/inode.c b/fs/fat/inode.c
index 4b70dcbcd192..9e6bc6364468 100644
--- a/fs/fat/inode.c
+++ b/fs/fat/inode.c
@@ -197,7 +197,7 @@ static int fat_writepages(struct address_space *mapping,
 static int fat_readpage(struct file *file, struct address_space *mapping,
 			struct page *page)
 {
-	return mpage_readpage(page, fat_get_block);
+	return mpage_readpage(page->mapping, page, fat_get_block);
 }
 
 static int fat_readpages(struct file *file, struct address_space *mapping,
diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
index ff02313b86e6..b42775bba6a1 100644
--- a/fs/gfs2/aops.c
+++ b/fs/gfs2/aops.c
@@ -524,7 +524,7 @@ static int __gfs2_readpage(void *file, struct address_space *mapping,
 		error = stuffed_readpage(ip, page);
 		unlock_page(page);
 	} else {
-		error = mpage_readpage(page, gfs2_block_map);
+		error = mpage_readpage(page->mapping, page, gfs2_block_map);
 	}
 
 	if (unlikely(test_bit(SDF_SHUTDOWN, &sdp->sd_flags)))
diff --git a/fs/hpfs/file.c b/fs/hpfs/file.c
index 3f2cc3fcee80..620dd9709a2c 100644
--- a/fs/hpfs/file.c
+++ b/fs/hpfs/file.c
@@ -118,7 +118,7 @@ static int hpfs_get_block(struct inode *inode, sector_t iblock, struct buffer_he
 static int hpfs_readpage(struct file *file, struct address_space *mapping,
 			 struct page *page)
 {
-	return mpage_readpage(page, hpfs_get_block);
+	return mpage_readpage(page->mapping, page, hpfs_get_block);
 }
 
 static int hpfs_writepage(struct address_space *mapping, struct page *page,
diff --git a/fs/isofs/inode.c b/fs/isofs/inode.c
index 541d89e0621a..7d73b1036321 100644
--- a/fs/isofs/inode.c
+++ b/fs/isofs/inode.c
@@ -1171,7 +1171,7 @@ struct buffer_head *isofs_bread(struct inode *inode, sector_t block)
 static int isofs_readpage(struct file *file, struct address_space *mapping,
 			  struct page *page)
 {
-	return mpage_readpage(page, isofs_get_block);
+	return mpage_readpage(page->mapping, page, isofs_get_block);
 }
 
 static int isofs_readpages(struct file *file, struct address_space *mapping,
diff --git a/fs/jfs/inode.c b/fs/jfs/inode.c
index be71214f4937..be6da161bc81 100644
--- a/fs/jfs/inode.c
+++ b/fs/jfs/inode.c
@@ -297,7 +297,7 @@ static int jfs_writepages(struct address_space *mapping,
 static int jfs_readpage(struct file *file, struct address_space *mapping,
 			struct page *page)
 {
-	return mpage_readpage(page, jfs_get_block);
+	return mpage_readpage(page->mapping, page, jfs_get_block);
 }
 
 static int jfs_readpages(struct file *file, struct address_space *mapping,
diff --git a/fs/mpage.c b/fs/mpage.c
index 8800bcde5f4e..52a6028e2066 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -143,12 +143,13 @@ map_buffer_to_page(struct inode *inode, struct page *page,
  * get_block() call.
  */
 static struct bio *
-do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
+do_mpage_readpage(struct bio *bio, struct address_space *mapping,
+		struct page *page, unsigned nr_pages,
 		sector_t *last_block_in_bio, struct buffer_head *map_bh,
 		unsigned long *first_logical_block, get_block_t get_block,
 		gfp_t gfp)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = mapping->host;
 	const unsigned blkbits = inode->i_blkbits;
 	const unsigned blocks_per_page = PAGE_SIZE >> blkbits;
 	const unsigned blocksize = 1 << blkbits;
@@ -381,7 +382,7 @@ mpage_readpages(struct address_space *mapping, struct list_head *pages,
 		if (!add_to_page_cache_lru(page, mapping,
 					page->index,
 					gfp)) {
-			bio = do_mpage_readpage(bio, page,
+			bio = do_mpage_readpage(bio, mapping, page,
 					nr_pages - page_idx,
 					&last_block_in_bio, &map_bh,
 					&first_logical_block,
@@ -399,17 +400,18 @@ EXPORT_SYMBOL(mpage_readpages);
 /*
  * This isn't called much at all
  */
-int mpage_readpage(struct page *page, get_block_t get_block)
+int mpage_readpage(struct address_space *mapping, struct page *page,
+		   get_block_t get_block)
 {
 	struct bio *bio = NULL;
 	sector_t last_block_in_bio = 0;
 	struct buffer_head map_bh;
 	unsigned long first_logical_block = 0;
-	gfp_t gfp = mapping_gfp_constraint(page->mapping, GFP_KERNEL);
+	gfp_t gfp = mapping_gfp_constraint(mapping, GFP_KERNEL);
 
 	map_bh.b_state = 0;
 	map_bh.b_size = 0;
-	bio = do_mpage_readpage(bio, page, 1, &last_block_in_bio,
+	bio = do_mpage_readpage(bio, mapping, page, 1, &last_block_in_bio,
 			&map_bh, &first_logical_block, get_block, gfp);
 	if (bio)
 		mpage_bio_submit(REQ_OP_READ, 0, bio);
diff --git a/fs/nilfs2/inode.c b/fs/nilfs2/inode.c
index 86d12a7822a9..7cc0268d68ce 100644
--- a/fs/nilfs2/inode.c
+++ b/fs/nilfs2/inode.c
@@ -152,7 +152,7 @@ int nilfs_get_block(struct inode *inode, sector_t blkoff,
 static int nilfs_readpage(struct file *file, struct address_space *mapping,
 			  struct page *page)
 {
-	return mpage_readpage(page, nilfs_get_block);
+	return mpage_readpage(page->mapping, page, nilfs_get_block);
 }
 
 /**
diff --git a/fs/qnx6/inode.c b/fs/qnx6/inode.c
index 98cb4671405e..c7f3623fd5f4 100644
--- a/fs/qnx6/inode.c
+++ b/fs/qnx6/inode.c
@@ -96,7 +96,7 @@ static int qnx6_check_blockptr(__fs32 ptr)
 static int qnx6_readpage(struct file *file, struct address_space *mapping,
 			 struct page *page)
 {
-	return mpage_readpage(page, qnx6_get_block);
+	return mpage_readpage(page->mapping, page, qnx6_get_block);
 }
 
 static int qnx6_readpages(struct file *file, struct address_space *mapping,
diff --git a/fs/udf/inode.c b/fs/udf/inode.c
index 63264d72999a..56cf8e70d298 100644
--- a/fs/udf/inode.c
+++ b/fs/udf/inode.c
@@ -188,7 +188,7 @@ static int udf_writepages(struct address_space *mapping,
 static int udf_readpage(struct file *file, struct address_space *mapping,
 			struct page *page)
 {
-	return mpage_readpage(page, udf_get_block);
+	return mpage_readpage(page->mapping, page, udf_get_block);
 }
 
 static int udf_readpages(struct file *file, struct address_space *mapping,
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 00922a82ede6..bed27e59720a 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -1415,7 +1415,7 @@ xfs_vm_readpage(
 	struct page		*page)
 {
 	trace_xfs_vm_readpage(page->mapping->host, 1);
-	return mpage_readpage(page, xfs_get_blocks);
+	return mpage_readpage(page->mapping, page, xfs_get_blocks);
 }
 
 STATIC int
diff --git a/include/linux/mpage.h b/include/linux/mpage.h
index e7f489fc090c..1708caae2640 100644
--- a/include/linux/mpage.h
+++ b/include/linux/mpage.h
@@ -16,7 +16,8 @@ struct writeback_control;
 
 int mpage_readpages(struct address_space *mapping, struct list_head *pages,
 				unsigned nr_pages, get_block_t get_block);
-int mpage_readpage(struct page *page, get_block_t get_block);
+int mpage_readpage(struct address_space *mapping, struct page *page,
+		   get_block_t get_block);
 int mpage_writepages(struct address_space *mapping,
 		struct writeback_control *wbc, get_block_t get_block);
 int mpage_writepage(struct address_space *mapping, struct page *page,
-- 
2.14.3
