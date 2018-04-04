Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 185336B026F
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:24 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id r138so15343712qke.18
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:24 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id o103si2640105qko.458.2018.04.04.12.19.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:23 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 50/79] fs: stop relying on mapping field of struct page, get it from context
Date: Wed,  4 Apr 2018 15:18:14 -0400
Message-Id: <20180404191831.5378-25-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Holy grail, remove all usage of mapping field of struct page inside
common fs code.

spatch --sp-file zemantic-015a.spatch --in-place fs/*.c
----------------------------------------------------------------------
@exists@
struct page * P;
identifier I;
@@
struct address_space *I;
...
-P->mapping
+I

@exists@
identifier F, I;
struct page * P;
@@
F(..., struct address_space *I, ...) {
...
-P->mapping
+I
...
}

@@
@@
-mapping = mapping;

@@
@@
-struct address_space *mapping = _mapping;
----------------------------------------------------------------------

Hand edit:
    fs/mpage.c __mpage_writepage() coccinelle sematic is too hard ...

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
---
 fs/buffer.c | 11 +++++------
 fs/libfs.c  |  2 +-
 fs/mpage.c  |  9 ++++-----
 3 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index b968ac0b65e8..39d8c7315b55 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -327,7 +327,7 @@ void end_buffer_async_write(struct address_space *mapping, struct page *page,
 		set_buffer_uptodate(bh);
 	} else {
 		buffer_io_error(bh, ", lost async page write");
-		mark_buffer_write_io_error(page->mapping, page, bh);
+		mark_buffer_write_io_error(mapping, page, bh);
 		clear_buffer_uptodate(bh);
 		SetPageError(page);
 	}
@@ -597,11 +597,10 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
  *
  * The caller must hold lock_page_memcg().
  */
-static void __set_page_dirty(struct page *page, struct address_space *_mapping,
+static void __set_page_dirty(struct page *page, struct address_space *mapping,
 			     int warn)
 {
 	unsigned long flags;
-	struct address_space *mapping = page_mapping(page);
 
 	spin_lock_irqsave(&mapping->tree_lock, flags);
 	if (page_is_truncated(page, mapping)) {	/* Race with truncate? */
@@ -1954,7 +1953,7 @@ int __block_write_begin_int(struct address_space *mapping, struct page *page,
 {
 	unsigned from = pos & (PAGE_SIZE - 1);
 	unsigned to = from + len;
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = mapping->host;
 	unsigned block_start, block_end;
 	sector_t block;
 	int err = 0;
@@ -2456,7 +2455,7 @@ EXPORT_SYMBOL(cont_write_begin);
 int block_commit_write(struct address_space *mapping, struct page *page,
 		       unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = mapping->host;
 	__block_commit_write(inode,page,from,to);
 	return 0;
 }
@@ -2705,7 +2704,7 @@ int nobh_write_end(struct file *file, struct address_space *mapping,
 			loff_t pos, unsigned len, unsigned copied,
 			struct page *page, void *fsdata)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = mapping->host;
 	struct buffer_head *head = fsdata;
 	struct buffer_head *bh;
 	BUG_ON(fsdata != NULL && page_has_buffers(page));
diff --git a/fs/libfs.c b/fs/libfs.c
index ac76b269bbb7..585ef1f37d54 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -475,7 +475,7 @@ int simple_write_end(struct file *file, struct address_space *mapping,
 			loff_t pos, unsigned len, unsigned copied,
 			struct page *page, void *fsdata)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = mapping->host;
 	loff_t last_pos = pos + copied;
 
 	/* zero the stale part of the page if we did a short copy */
diff --git a/fs/mpage.c b/fs/mpage.c
index 1eec9d0df23e..ecdef63f464e 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -231,7 +231,7 @@ do_mpage_readpage(struct bio *bio, struct address_space *mapping,
 		 * so readpage doesn't have to repeat the get_block call
 		 */
 		if (buffer_uptodate(map_bh)) {
-			map_buffer_to_page(page->mapping->host, page,
+			map_buffer_to_page(mapping->host, page,
 					   map_bh, page_block);
 			goto confused;
 		}
@@ -312,7 +312,7 @@ do_mpage_readpage(struct bio *bio, struct address_space *mapping,
 	if (bio)
 		bio = mpage_bio_submit(REQ_OP_READ, 0, bio);
 	if (!PageUptodate(page))
-	        block_read_full_page(page->mapping->host, page, get_block);
+	        block_read_full_page(mapping->host, page, get_block);
 	else
 		unlock_page(page);
 	goto out;
@@ -484,13 +484,12 @@ void clean_page_buffers(struct address_space *mapping, struct page *page)
 	clean_buffers(mapping, page, ~0U);
 }
 
-static int __mpage_writepage(struct page *page, struct address_space *_mapping,
+static int __mpage_writepage(struct page *page, struct address_space *mapping,
 			     struct writeback_control *wbc, void *data)
 {
 	struct mpage_data *mpd = data;
 	struct bio *bio = mpd->bio;
-	struct address_space *mapping = page->mapping;
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = mapping->host;
 	const unsigned blkbits = inode->i_blkbits;
 	unsigned long end_index;
 	const unsigned blocks_per_page = PAGE_SIZE >> blkbits;
-- 
2.14.3
