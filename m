Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id ECDB56B025F
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:19 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id w17so15482981qkb.19
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:19 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 47si4090735qtx.215.2018.04.04.12.19.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:18 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 35/79] fs/buffer: add struct address_space and struct page to end_io callback
Date: Wed,  4 Apr 2018 15:18:09 -0400
Message-Id: <20180404191831.5378-20-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

For the holy crusade to stop relying on struct page mapping field, add
struct address_space and struct page to the end_io callback of buffer
head. Caller of this callback have more context information to find
the match page and mapping.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
CC: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
---
 drivers/md/md-bitmap.c      |  3 ++-
 fs/btrfs/disk-io.c          |  3 ++-
 fs/buffer.c                 | 26 +++++++++++++++++---------
 fs/ext4/ext4.h              |  3 ++-
 fs/ext4/ialloc.c            |  3 ++-
 fs/gfs2/meta_io.c           |  2 +-
 fs/jbd2/commit.c            |  3 ++-
 fs/ntfs/aops.c              |  9 ++++++---
 fs/reiserfs/journal.c       |  6 ++++--
 include/linux/buffer_head.h | 12 ++++++++----
 10 files changed, 46 insertions(+), 24 deletions(-)

diff --git a/drivers/md/md-bitmap.c b/drivers/md/md-bitmap.c
index 239c7bb3929b..717e99eabce9 100644
--- a/drivers/md/md-bitmap.c
+++ b/drivers/md/md-bitmap.c
@@ -313,7 +313,8 @@ static void write_page(struct bitmap *bitmap, struct page *page, int wait)
 		bitmap_file_kick(bitmap);
 }
 
-static void end_bitmap_write(struct buffer_head *bh, int uptodate)
+static void end_bitmap_write(struct address_space *mapping, struct page *page,
+			     struct buffer_head *bh, int uptodate)
 {
 	struct bitmap *bitmap = bh->b_private;
 
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index a976ccc6036b..df789cfdebd7 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -3123,7 +3123,8 @@ int open_ctree(struct super_block *sb,
 }
 ALLOW_ERROR_INJECTION(open_ctree, ERRNO);
 
-static void btrfs_end_buffer_write_sync(struct buffer_head *bh, int uptodate)
+static void btrfs_end_buffer_write_sync(struct address_space *mapping,
+		struct page *page, struct buffer_head *bh, int uptodate)
 {
 	if (uptodate) {
 		set_buffer_uptodate(bh);
diff --git a/fs/buffer.c b/fs/buffer.c
index c83878d0a4c0..9f2c5e90b64d 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -159,14 +159,16 @@ static void __end_buffer_read_notouch(struct buffer_head *bh, int uptodate)
  * Default synchronous end-of-IO handler..  Just mark it up-to-date and
  * unlock the buffer. This is what ll_rw_block uses too.
  */
-void end_buffer_read_sync(struct buffer_head *bh, int uptodate)
+void end_buffer_read_sync(struct address_space *mapping, struct page *page,
+			  struct buffer_head *bh, int uptodate)
 {
 	__end_buffer_read_notouch(bh, uptodate);
 	put_bh(bh);
 }
 EXPORT_SYMBOL(end_buffer_read_sync);
 
-void end_buffer_write_sync(struct buffer_head *bh, int uptodate)
+void end_buffer_write_sync(struct address_space *mapping, struct page *page,
+			   struct buffer_head *bh, int uptodate)
 {
 	if (uptodate) {
 		set_buffer_uptodate(bh);
@@ -250,12 +252,12 @@ __find_get_block_slow(struct block_device *bdev, sector_t block)
  * I/O completion handler for block_read_full_page() - pages
  * which come unlocked at the end of I/O.
  */
-static void end_buffer_async_read(struct buffer_head *bh, int uptodate)
+static void end_buffer_async_read(struct address_space *mapping,
+		struct page *page, struct buffer_head *bh, int uptodate)
 {
 	unsigned long flags;
 	struct buffer_head *first;
 	struct buffer_head *tmp;
-	struct page *page;
 	int page_uptodate = 1;
 
 	BUG_ON(!buffer_async_read(bh));
@@ -311,12 +313,12 @@ static void end_buffer_async_read(struct buffer_head *bh, int uptodate)
  * Completion handler for block_write_full_page() - pages which are unlocked
  * during I/O, and which have PageWriteback cleared upon I/O completion.
  */
-void end_buffer_async_write(struct buffer_head *bh, int uptodate)
+void end_buffer_async_write(struct address_space *mapping, struct page *page,
+			    struct buffer_head *bh, int uptodate)
 {
 	unsigned long flags;
 	struct buffer_head *first;
 	struct buffer_head *tmp;
-	struct page *page;
 
 	BUG_ON(!buffer_async_write(bh));
 
@@ -2311,7 +2313,7 @@ int block_read_full_page(struct inode *inode, struct page *page,
 	for (i = 0; i < nr; i++) {
 		bh = arr[i];
 		if (buffer_uptodate(bh))
-			end_buffer_async_read(bh, 1);
+			end_buffer_async_read(inode->i_mapping, page, bh, 1);
 		else
 			submit_bh(REQ_OP_READ, 0, bh);
 	}
@@ -2517,7 +2519,8 @@ EXPORT_SYMBOL(block_page_mkwrite);
  * immediately, while under the page lock.  So it needs a special end_io
  * handler which does not touch the bh after unlocking it.
  */
-static void end_buffer_read_nobh(struct buffer_head *bh, int uptodate)
+static void end_buffer_read_nobh(struct address_space *mapping,
+		struct page *page, struct buffer_head *bh, int uptodate)
 {
 	__end_buffer_read_notouch(bh, uptodate);
 }
@@ -2989,11 +2992,16 @@ EXPORT_SYMBOL(generic_block_bmap);
 static void end_bio_bh_io_sync(struct bio *bio)
 {
 	struct buffer_head *bh = bio->bi_private;
+	struct address_space *mapping;
+	struct page *page;
+
+	page = bh->b_page;
+	mapping = fs_page_mapping_get_with_bh(page, bh);
 
 	if (unlikely(bio_flagged(bio, BIO_QUIET)))
 		set_bit(BH_Quiet, &bh->b_state);
 
-	bh->b_end_io(bh, !bio->bi_status);
+	bh->b_end_io(mapping, page, bh, !bio->bi_status);
 	bio_put(bio);
 }
 
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 3241475a1733..3be14beacd9c 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -2389,7 +2389,8 @@ extern void ext4_check_inodes_bitmap(struct super_block *);
 extern void ext4_mark_bitmap_end(int start_bit, int end_bit, char *bitmap);
 extern int ext4_init_inode_table(struct super_block *sb,
 				 ext4_group_t group, int barrier);
-extern void ext4_end_bitmap_read(struct buffer_head *bh, int uptodate);
+extern void ext4_end_bitmap_read(struct address_space *mapping,
+		struct page *page, struct buffer_head *bh, int uptodate);
 
 /* mballoc.c */
 extern const struct file_operations ext4_seq_mb_groups_fops;
diff --git a/fs/ext4/ialloc.c b/fs/ext4/ialloc.c
index 7830d28df331..1475eb54b30e 100644
--- a/fs/ext4/ialloc.c
+++ b/fs/ext4/ialloc.c
@@ -104,7 +104,8 @@ static int ext4_init_inode_bitmap(struct super_block *sb,
 	return 0;
 }
 
-void ext4_end_bitmap_read(struct buffer_head *bh, int uptodate)
+void ext4_end_bitmap_read(struct address_space *mapping, struct page *page,
+			  struct buffer_head *bh, int uptodate)
 {
 	if (uptodate) {
 		set_buffer_uptodate(bh);
diff --git a/fs/gfs2/meta_io.c b/fs/gfs2/meta_io.c
index 1f1e9c330e9a..e1942636e7e8 100644
--- a/fs/gfs2/meta_io.c
+++ b/fs/gfs2/meta_io.c
@@ -202,7 +202,7 @@ static void gfs2_meta_read_endio(struct bio *bio)
 		do {
 			struct buffer_head *next = bh->b_this_page;
 			len -= bh->b_size;
-			bh->b_end_io(bh, !bio->bi_status);
+			bh->b_end_io(page->mapping, page, bh, !bio->bi_status);
 			bh = next;
 		} while (bh && len);
 	}
diff --git a/fs/jbd2/commit.c b/fs/jbd2/commit.c
index 8de0e7723316..2ab9edd17ea7 100644
--- a/fs/jbd2/commit.c
+++ b/fs/jbd2/commit.c
@@ -29,7 +29,8 @@
 /*
  * IO end handler for temporary buffer_heads handling writes to the journal.
  */
-static void journal_end_buffer_io_sync(struct buffer_head *bh, int uptodate)
+static void journal_end_buffer_io_sync(struct address_space *mapping,
+		struct page *page, struct buffer_head *bh, int uptodate)
 {
 	struct buffer_head *orig_bh = bh->b_private;
 
diff --git a/fs/ntfs/aops.c b/fs/ntfs/aops.c
index abd945849395..048c40786dc7 100644
--- a/fs/ntfs/aops.c
+++ b/fs/ntfs/aops.c
@@ -42,6 +42,8 @@
 
 /**
  * ntfs_end_buffer_async_read - async io completion for reading attributes
+ * @mapping:	address space for the page of buffer head
+ * @page:	page the buffer head belongs to
  * @bh:		buffer head on which io is completed
  * @uptodate:	whether @bh is now uptodate or not
  *
@@ -56,11 +58,11 @@
  * record size, and index_block_size_bits, to the log(base 2) of the ntfs
  * record size.
  */
-static void ntfs_end_buffer_async_read(struct buffer_head *bh, int uptodate)
+static void ntfs_end_buffer_async_read(struct address_space *mapping,
+		struct page *page, struct buffer_head *bh, int uptodate)
 {
 	unsigned long flags;
 	struct buffer_head *first, *tmp;
-	struct page *page;
 	struct inode *vi;
 	ntfs_inode *ni;
 	int page_uptodate = 1;
@@ -365,7 +367,8 @@ static int ntfs_read_block(struct page *page)
 			if (likely(!buffer_uptodate(tbh)))
 				submit_bh(REQ_OP_READ, 0, tbh);
 			else
-				ntfs_end_buffer_async_read(tbh, 1);
+				ntfs_end_buffer_async_read(page->mapping,
+							   page, tbh, 1);
 		}
 		return 0;
 	}
diff --git a/fs/reiserfs/journal.c b/fs/reiserfs/journal.c
index 70057359fbaf..230cb2a2309a 100644
--- a/fs/reiserfs/journal.c
+++ b/fs/reiserfs/journal.c
@@ -617,7 +617,8 @@ static void release_buffer_page(struct buffer_head *bh)
 	}
 }
 
-static void reiserfs_end_buffer_io_sync(struct buffer_head *bh, int uptodate)
+static void reiserfs_end_buffer_io_sync(struct address_space *mapping,
+		struct page *page, struct buffer_head *bh, int uptodate)
 {
 	if (buffer_journaled(bh)) {
 		reiserfs_warning(NULL, "clm-2084",
@@ -633,7 +634,8 @@ static void reiserfs_end_buffer_io_sync(struct buffer_head *bh, int uptodate)
 	release_buffer_page(bh);
 }
 
-static void reiserfs_end_ordered_io(struct buffer_head *bh, int uptodate)
+static void reiserfs_end_ordered_io(struct address_space *mapping,
+		struct page *page, struct buffer_head *bh, int uptodate)
 {
 	if (uptodate)
 		set_buffer_uptodate(bh);
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index dca0d3eb789a..61db6d5e7d85 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -49,7 +49,8 @@ enum bh_state_bits {
 struct page;
 struct buffer_head;
 struct address_space;
-typedef void (bh_end_io_t)(struct buffer_head *bh, int uptodate);
+typedef void (bh_end_io_t)(struct address_space *mapping, struct page *page,
+			   struct buffer_head *bh, int uptodate);
 
 /*
  * Historically, a buffer_head was used to map a single block
@@ -163,9 +164,12 @@ struct buffer_head *alloc_page_buffers(struct page *page, unsigned long size,
 		bool retry);
 void create_empty_buffers(struct page *, unsigned long,
 			unsigned long b_state);
-void end_buffer_read_sync(struct buffer_head *bh, int uptodate);
-void end_buffer_write_sync(struct buffer_head *bh, int uptodate);
-void end_buffer_async_write(struct buffer_head *bh, int uptodate);
+void end_buffer_read_sync(struct address_space *mapping, struct page *page,
+			  struct buffer_head *bh, int uptodate);
+void end_buffer_write_sync(struct address_space *mapping, struct page *page,
+			   struct buffer_head *bh, int uptodate);
+void end_buffer_async_write(struct address_space *mapping, struct page *page,
+			    struct buffer_head *bh, int uptodate);
 
 /* Things to do with buffers at mapping->private_list */
 void mark_buffer_dirty_inode(struct buffer_head *bh, struct inode *inode);
-- 
2.14.3
