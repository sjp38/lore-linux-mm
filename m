Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 06C4B6B0011
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:07 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id t27so15340409qki.11
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:07 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s123si6588335qke.479.2018.04.04.12.19.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:05 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 22/79] fs: add struct inode to block_read_full_page() arguments
Date: Wed,  4 Apr 2018 15:17:58 -0400
Message-Id: <20180404191831.5378-9-jglisse@redhat.com>
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

Add struct inode to block_read_full_page(). Note this patch only add
arguments and modify call site conservatily using page->mapping and
thus the end result is as before this patch.

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
 fs/adfs/inode.c             | 2 +-
 fs/affs/file.c              | 2 +-
 fs/befs/linuxvfs.c          | 3 ++-
 fs/bfs/file.c               | 2 +-
 fs/block_dev.c              | 2 +-
 fs/buffer.c                 | 4 ++--
 fs/efs/inode.c              | 2 +-
 fs/ext4/readpage.c          | 3 ++-
 fs/freevxfs/vxfs_subr.c     | 2 +-
 fs/hfs/inode.c              | 2 +-
 fs/hfsplus/inode.c          | 3 ++-
 fs/minix/inode.c            | 2 +-
 fs/mpage.c                  | 2 +-
 fs/ocfs2/aops.c             | 3 ++-
 fs/ocfs2/refcounttree.c     | 3 ++-
 fs/omfs/file.c              | 2 +-
 fs/qnx4/inode.c             | 2 +-
 fs/reiserfs/inode.c         | 3 ++-
 fs/sysv/itree.c             | 2 +-
 fs/ufs/inode.c              | 3 ++-
 include/linux/buffer_head.h | 2 +-
 21 files changed, 29 insertions(+), 22 deletions(-)

diff --git a/fs/adfs/inode.c b/fs/adfs/inode.c
index 1100d5da84d0..2270ab3d5392 100644
--- a/fs/adfs/inode.c
+++ b/fs/adfs/inode.c
@@ -45,7 +45,7 @@ static int adfs_writepage(struct address_space *mapping, struct page *page,
 static int adfs_readpage(struct file *file, struct address_space *mapping,
 			 struct page *page)
 {
-	return block_read_full_page(page, adfs_get_block);
+	return block_read_full_page(page->mapping->host, page, adfs_get_block);
 }
 
 static void adfs_write_failed(struct address_space *mapping, loff_t to)
diff --git a/fs/affs/file.c b/fs/affs/file.c
index 55ab72c1b228..136cb90f332f 100644
--- a/fs/affs/file.c
+++ b/fs/affs/file.c
@@ -379,7 +379,7 @@ static int affs_writepage(struct address_space *mapping, struct page *page,
 static int affs_readpage(struct file *file, struct address_space *mapping,
 			 struct page *page)
 {
-	return block_read_full_page(page, affs_get_block);
+	return block_read_full_page(page->mapping->host, page, affs_get_block);
 }
 
 static void affs_write_failed(struct address_space *mapping, loff_t to)
diff --git a/fs/befs/linuxvfs.c b/fs/befs/linuxvfs.c
index f6844b4ae77f..4436123674d3 100644
--- a/fs/befs/linuxvfs.c
+++ b/fs/befs/linuxvfs.c
@@ -112,7 +112,8 @@ static int
 befs_readpage(struct file *file, struct address_space *mapping,
 	      struct page *page)
 {
-	return block_read_full_page(page, befs_get_block);
+	return block_read_full_page(page->mapping->host, page,
+				    befs_get_block);
 }
 
 static sector_t
diff --git a/fs/bfs/file.c b/fs/bfs/file.c
index 1c4593429f7d..b1255ee4cd75 100644
--- a/fs/bfs/file.c
+++ b/fs/bfs/file.c
@@ -160,7 +160,7 @@ static int bfs_writepage(struct address_space *mapping, struct page *page,
 static int bfs_readpage(struct file *file, struct address_space *mapping,
 			struct page *page)
 {
-	return block_read_full_page(page, bfs_get_block);
+	return block_read_full_page(page->mapping->host, page, bfs_get_block);
 }
 
 static void bfs_write_failed(struct address_space *mapping, loff_t to)
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 2bf1b17aeff3..9ac6bf760272 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -571,7 +571,7 @@ static int blkdev_writepage(struct address_space *mapping, struct page *page,
 static int blkdev_readpage(struct file * file, struct address_space *mapping,
 			   struct page * page)
 {
-	return block_read_full_page(page, blkdev_get_block);
+	return block_read_full_page(page->mapping->host,page,blkdev_get_block);
 }
 
 static int blkdev_readpages(struct file *file, struct address_space *mapping,
diff --git a/fs/buffer.c b/fs/buffer.c
index 99818e876ad8..aa7d9be68581 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2231,9 +2231,9 @@ EXPORT_SYMBOL(block_is_partially_uptodate);
  * set/clear_buffer_uptodate() functions propagate buffer state into the
  * page struct once IO has completed.
  */
-int block_read_full_page(struct page *page, get_block_t *get_block)
+int block_read_full_page(struct inode *inode, struct page *page,
+			 get_block_t *get_block)
 {
-	struct inode *inode = page->mapping->host;
 	sector_t iblock, lblock;
 	struct buffer_head *bh, *head, *arr[MAX_BUF_PER_PAGE];
 	unsigned int blocksize, bbits;
diff --git a/fs/efs/inode.c b/fs/efs/inode.c
index 05aab4a5e8a1..a2f47227124e 100644
--- a/fs/efs/inode.c
+++ b/fs/efs/inode.c
@@ -16,7 +16,7 @@
 static int efs_readpage(struct file *file, struct address_space *mapping,
 			struct page *page)
 {
-	return block_read_full_page(page,efs_get_block);
+	return block_read_full_page(page->mapping->host, page,efs_get_block);
 }
 static sector_t _efs_bmap(struct address_space *mapping, sector_t block)
 {
diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index 9ffa6fad18db..e43dc995f978 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -280,7 +280,8 @@ int ext4_mpage_readpages(struct address_space *mapping,
 			bio = NULL;
 		}
 		if (!PageUptodate(page))
-			block_read_full_page(page, ext4_get_block);
+			block_read_full_page(page->mapping->host, page,
+					     ext4_get_block);
 		else
 			unlock_page(page);
 	next_page:
diff --git a/fs/freevxfs/vxfs_subr.c b/fs/freevxfs/vxfs_subr.c
index 25f15ce143b5..91c5a39083c0 100644
--- a/fs/freevxfs/vxfs_subr.c
+++ b/fs/freevxfs/vxfs_subr.c
@@ -162,7 +162,7 @@ static int
 vxfs_readpage(struct file *file, struct address_space *mapping,
 	      struct page *page)
 {
-	return block_read_full_page(page, vxfs_getblk);
+	return block_read_full_page(page->mapping->host, page, vxfs_getblk);
 }
  
 /**
diff --git a/fs/hfs/inode.c b/fs/hfs/inode.c
index 17c96905191d..3851e95e9625 100644
--- a/fs/hfs/inode.c
+++ b/fs/hfs/inode.c
@@ -38,7 +38,7 @@ static int hfs_writepage(struct address_space *mapping, struct page *page,
 static int hfs_readpage(struct file *file, struct address_space *mapping,
 			struct page *page)
 {
-	return block_read_full_page(page, hfs_get_block);
+	return block_read_full_page(page->mapping->host, page, hfs_get_block);
 }
 
 static void hfs_write_failed(struct address_space *mapping, loff_t to)
diff --git a/fs/hfsplus/inode.c b/fs/hfsplus/inode.c
index d3a1ae620a14..a39d6114375a 100644
--- a/fs/hfsplus/inode.c
+++ b/fs/hfsplus/inode.c
@@ -26,7 +26,8 @@
 static int hfsplus_readpage(struct file *file, struct address_space *mapping,
 			    struct page *page)
 {
-	return block_read_full_page(page, hfsplus_get_block);
+	return block_read_full_page(page->mapping->host, page,
+				    hfsplus_get_block);
 }
 
 static int hfsplus_writepage(struct address_space *mapping, struct page *page,
diff --git a/fs/minix/inode.c b/fs/minix/inode.c
index 218697f38375..2a151fa6b013 100644
--- a/fs/minix/inode.c
+++ b/fs/minix/inode.c
@@ -391,7 +391,7 @@ static int minix_writepage(struct address_space *mapping, struct page *page,
 static int minix_readpage(struct file *file, struct address_space *mapping,
 			  struct page *page)
 {
-	return block_read_full_page(page,minix_get_block);
+	return block_read_full_page(page->mapping->host,page,minix_get_block);
 }
 
 int minix_prepare_chunk(struct page *page, loff_t pos, unsigned len)
diff --git a/fs/mpage.c b/fs/mpage.c
index d25f08f46090..c40ed2aa9bee 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -309,7 +309,7 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 	if (bio)
 		bio = mpage_bio_submit(REQ_OP_READ, 0, bio);
 	if (!PageUptodate(page))
-	        block_read_full_page(page, get_block);
+	        block_read_full_page(page->mapping->host, page, get_block);
 	else
 		unlock_page(page);
 	goto out;
diff --git a/fs/ocfs2/aops.c b/fs/ocfs2/aops.c
index c1d3b33e8676..9942ee775e08 100644
--- a/fs/ocfs2/aops.c
+++ b/fs/ocfs2/aops.c
@@ -343,7 +343,8 @@ static int ocfs2_readpage(struct file *file, struct address_space *mapping,
 	if (oi->ip_dyn_features & OCFS2_INLINE_DATA_FL)
 		ret = ocfs2_readpage_inline(inode, page);
 	else
-		ret = block_read_full_page(page, ocfs2_get_block);
+		ret = block_read_full_page(page->mapping->host, page,
+					   ocfs2_get_block);
 	unlock = 0;
 
 out_alloc:
diff --git a/fs/ocfs2/refcounttree.c b/fs/ocfs2/refcounttree.c
index ab156e35ec00..163f639caf5e 100644
--- a/fs/ocfs2/refcounttree.c
+++ b/fs/ocfs2/refcounttree.c
@@ -2961,7 +2961,8 @@ int ocfs2_duplicate_clusters_by_page(handle_t *handle,
 			BUG_ON(PageDirty(page));
 
 		if (!PageUptodate(page)) {
-			ret = block_read_full_page(page, ocfs2_get_block);
+			ret = block_read_full_page(page->mapping->host, page,
+						   ocfs2_get_block);
 			if (ret) {
 				mlog_errno(ret);
 				goto unlock;
diff --git a/fs/omfs/file.c b/fs/omfs/file.c
index 71e9b27ee89d..ac27a4b2186a 100644
--- a/fs/omfs/file.c
+++ b/fs/omfs/file.c
@@ -287,7 +287,7 @@ static int omfs_get_block(struct inode *inode, sector_t block,
 static int omfs_readpage(struct file *file, struct address_space *mapping,
 			 struct page *page)
 {
-	return block_read_full_page(page, omfs_get_block);
+	return block_read_full_page(page->mapping->host, page, omfs_get_block);
 }
 
 static int omfs_readpages(struct file *file, struct address_space *mapping,
diff --git a/fs/qnx4/inode.c b/fs/qnx4/inode.c
index efc60096dd75..429f9295ec95 100644
--- a/fs/qnx4/inode.c
+++ b/fs/qnx4/inode.c
@@ -246,7 +246,7 @@ static void qnx4_kill_sb(struct super_block *sb)
 static int qnx4_readpage(struct file *file, struct address_space *mapping,
 			 struct page *page)
 {
-	return block_read_full_page(page,qnx4_get_block);
+	return block_read_full_page(page->mapping->host, page,qnx4_get_block);
 }
 
 static sector_t qnx4_bmap(struct address_space *mapping, sector_t block)
diff --git a/fs/reiserfs/inode.c b/fs/reiserfs/inode.c
index cc2dfbe8e31b..d4ab2d45f846 100644
--- a/fs/reiserfs/inode.c
+++ b/fs/reiserfs/inode.c
@@ -2734,7 +2734,8 @@ static int reiserfs_write_full_page(struct page *page,
 static int reiserfs_readpage(struct file *f, struct address_space *mapping,
 			     struct page *page)
 {
-	return block_read_full_page(page, reiserfs_get_block);
+	return block_read_full_page(page->mapping->host, page,
+				    reiserfs_get_block);
 }
 
 static int reiserfs_writepage(struct address_space *mapping, struct page *page,
diff --git a/fs/sysv/itree.c b/fs/sysv/itree.c
index d50dfd8a4465..7cec1e024dc3 100644
--- a/fs/sysv/itree.c
+++ b/fs/sysv/itree.c
@@ -460,7 +460,7 @@ static int sysv_writepage(struct address_space *mapping, struct page *page,
 static int sysv_readpage(struct file *file, struct address_space *mapping,
 			 struct page *page)
 {
-	return block_read_full_page(page,get_block);
+	return block_read_full_page(page->mapping->host, page,get_block);
 }
 
 int sysv_prepare_chunk(struct page *page, loff_t pos, unsigned len)
diff --git a/fs/ufs/inode.c b/fs/ufs/inode.c
index d04c6ed42be5..8589b934be09 100644
--- a/fs/ufs/inode.c
+++ b/fs/ufs/inode.c
@@ -477,7 +477,8 @@ static int ufs_writepage(struct address_space *mapping, struct page *page,
 static int ufs_readpage(struct file *file, struct address_space *mapping,
 			struct page *page)
 {
-	return block_read_full_page(page,ufs_getfrag_block);
+	return block_read_full_page(page->mapping->host, page,
+				    ufs_getfrag_block);
 }
 
 int ufs_prepare_chunk(struct page *page, loff_t pos, unsigned len)
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index 052f7a8aa7cf..cab143668834 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -222,7 +222,7 @@ int block_write_full_page(struct inode *inode, struct page *page,
 int __block_write_full_page(struct inode *inode, struct page *page,
 			get_block_t *get_block, struct writeback_control *wbc,
 			bh_end_io_t *handler);
-int block_read_full_page(struct page*, get_block_t*);
+int block_read_full_page(struct inode *inode, struct page*, get_block_t*);
 int block_is_partially_uptodate(struct page *page,
 	struct address_space *mapping, unsigned long from,
 	unsigned long count);
-- 
2.14.3
