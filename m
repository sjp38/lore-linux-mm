Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C7A2A6B0275
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:25 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id s138so3565177qke.10
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:25 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id o103si2640146qko.458.2018.04.04.12.19.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:24 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 52/79] fs/buffer: use _page_has_buffers() instead of page_has_buffers()
Date: Wed,  4 Apr 2018 15:18:16 -0400
Message-Id: <20180404191831.5378-27-jglisse@redhat.com>
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

The former need the address_space for which the buffer_head is being
lookup.

----------------------------------------------------------------------
@exists@
identifier M;
expression E;
@@
struct address_space *M;
...
-page_buffers(E)
+_page_buffers(E, M)

@exists@
identifier M, F;
expression E;
@@
F(..., struct address_space *M, ...) {...
-page_buffers(E)
+_page_buffers(E, M)
...}

@exists@
identifier M;
expression E;
@@
struct address_space *M;
...
-page_has_buffers(E)
+_page_has_buffers(E, M)

@exists@
identifier M, F;
expression E;
@@
F(..., struct address_space *M, ...) {...
-page_has_buffers(E)
+_page_has_buffers(E, M)
...}

@exists@
identifier I;
expression E;
@@
struct inode *I;
...
-page_buffers(E)
+_page_buffers(E, I->i_mapping)

@exists@
identifier I, F;
expression E;
@@
F(..., struct inode *I, ...) {...
-page_buffers(E)
+_page_buffers(E, I->i_mapping)
...}

@exists@
identifier I;
expression E;
@@
struct inode *I;
...
-page_has_buffers(E)
+_page_has_buffers(E, I->i_mapping)

@exists@
identifier I, F;
expression E;
@@
F(..., struct inode *I, ...) {...
-page_has_buffers(E)
+_page_has_buffers(E, I->i_mapping)
...}
----------------------------------------------------------------------

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
 fs/buffer.c | 60 ++++++++++++++++++++++++++++++------------------------------
 fs/mpage.c  | 14 +++++++-------
 2 files changed, 37 insertions(+), 37 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 3c424b7af5af..27b19c629308 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -89,13 +89,13 @@ void buffer_check_dirty_writeback(struct page *page,
 
 	BUG_ON(!PageLocked(page));
 
-	if (!page_has_buffers(page))
+	if (!_page_has_buffers(page, mapping))
 		return;
 
 	if (PageWriteback(page))
 		*writeback = true;
 
-	head = page_buffers(page);
+	head = _page_buffers(page, mapping);
 	bh = head;
 	do {
 		if (buffer_locked(bh))
@@ -211,9 +211,9 @@ __find_get_block_slow(struct block_device *bdev, sector_t block)
 		goto out;
 
 	spin_lock(&bd_mapping->private_lock);
-	if (!page_has_buffers(page))
+	if (!_page_has_buffers(page, bd_mapping))
 		goto out_unlock;
-	head = page_buffers(page);
+	head = _page_buffers(page, bd_mapping);
 	bh = head;
 	do {
 		if (!buffer_mapped(bh))
@@ -648,8 +648,8 @@ int __set_page_dirty_buffers(struct address_space *mapping,
 		return !TestSetPageDirty(page);
 
 	spin_lock(&mapping->private_lock);
-	if (page_has_buffers(page)) {
-		struct buffer_head *head = page_buffers(page);
+	if (_page_has_buffers(page, mapping)) {
+		struct buffer_head *head = _page_buffers(page, mapping);
 		struct buffer_head *bh = head;
 
 		do {
@@ -913,7 +913,7 @@ static sector_t
 init_page_buffers(struct address_space *buffer, struct page *page,
 		  struct block_device *bdev, sector_t block, int size)
 {
-	struct buffer_head *head = page_buffers(page);
+	struct buffer_head *head = _page_buffers(page, buffer);
 	struct buffer_head *bh = head;
 	int uptodate = PageUptodate(page);
 	sector_t end_block = blkdev_max_block(I_BDEV(bdev->bd_inode), size);
@@ -969,8 +969,8 @@ grow_dev_page(struct block_device *bdev, sector_t block,
 
 	BUG_ON(!PageLocked(page));
 
-	if (page_has_buffers(page)) {
-		bh = page_buffers(page);
+	if (_page_has_buffers(page, inode->i_mapping)) {
+		bh = _page_buffers(page, inode->i_mapping);
 		if (bh->b_size == size) {
 			end_block = init_page_buffers(inode->i_mapping, page,
 					bdev, (sector_t)index << sizebits,
@@ -1490,7 +1490,7 @@ void block_invalidatepage(struct address_space *mapping, struct page *page,
 	unsigned int stop = length + offset;
 
 	BUG_ON(!PageLocked(page));
-	if (!page_has_buffers(page))
+	if (!_page_has_buffers(page, mapping))
 		goto out;
 
 	/*
@@ -1498,7 +1498,7 @@ void block_invalidatepage(struct address_space *mapping, struct page *page,
 	 */
 	BUG_ON(stop > PAGE_SIZE || stop < length);
 
-	head = page_buffers(page);
+	head = _page_buffers(page, mapping);
 	bh = head;
 	do {
 		unsigned int next_off = curr_off + bh->b_size;
@@ -1605,7 +1605,7 @@ void clean_bdev_aliases(struct block_device *bdev, sector_t block, sector_t len)
 		for (i = 0; i < count; i++) {
 			struct page *page = pvec.pages[i];
 
-			if (!page_has_buffers(page))
+			if (!_page_has_buffers(page, bd_mapping))
 				continue;
 			/*
 			 * We use page lock instead of bd_mapping->private_lock
@@ -1614,9 +1614,9 @@ void clean_bdev_aliases(struct block_device *bdev, sector_t block, sector_t len)
 			 */
 			lock_page(page);
 			/* Recheck when the page is locked which pins bhs */
-			if (!page_has_buffers(page))
+			if (!_page_has_buffers(page, bd_inode->i_mapping))
 				goto unlock_page;
-			head = page_buffers(page);
+			head = _page_buffers(page, bd_mapping);
 			bh = head;
 			do {
 				if (!buffer_mapped(bh) || (bh->b_blocknr < block))
@@ -1658,11 +1658,11 @@ static struct buffer_head *create_page_buffers(struct page *page, struct inode *
 {
 	BUG_ON(!PageLocked(page));
 
-	if (!page_has_buffers(page))
+	if (!_page_has_buffers(page, inode->i_mapping))
 		create_empty_buffers(inode->i_mapping, page,
 				     1 << READ_ONCE(inode->i_blkbits),
 				     b_state);
-	return page_buffers(page);
+	return _page_buffers(page, inode->i_mapping);
 }
 
 /*
@@ -1870,10 +1870,10 @@ void page_zero_new_buffers(struct address_space *buffer, struct page *page,
 	struct buffer_head *head, *bh;
 
 	BUG_ON(!PageLocked(page));
-	if (!page_has_buffers(page))
+	if (!_page_has_buffers(page, buffer))
 		return;
 
-	bh = head = page_buffers(page);
+	bh = head = _page_buffers(page, buffer);
 	block_start = 0;
 	do {
 		block_end = block_start + bh->b_size;
@@ -2057,7 +2057,7 @@ static int __block_commit_write(struct inode *inode, struct page *page,
 	unsigned blocksize;
 	struct buffer_head *bh, *head;
 
-	bh = head = page_buffers(page);
+	bh = head = _page_buffers(page, inode->i_mapping);
 	blocksize = bh->b_size;
 
 	block_start = 0;
@@ -2209,10 +2209,10 @@ int block_is_partially_uptodate(struct page *page,
 	struct buffer_head *bh, *head;
 	int ret = 1;
 
-	if (!page_has_buffers(page))
+	if (!_page_has_buffers(page, mapping))
 		return 0;
 
-	head = page_buffers(page);
+	head = _page_buffers(page, mapping);
 	blocksize = head->b_size;
 	to = min_t(unsigned, PAGE_SIZE - from, count);
 	to = from + to;
@@ -2596,7 +2596,7 @@ int nobh_write_begin(struct address_space *mapping,
 	*pagep = page;
 	*fsdata = NULL;
 
-	if (page_has_buffers(page)) {
+	if (_page_has_buffers(page, mapping)) {
 		ret = __block_write_begin(mapping, page, pos, len, get_block);
 		if (unlikely(ret))
 			goto out_release;
@@ -2715,7 +2715,7 @@ int nobh_write_end(struct file *file, struct address_space *mapping,
 	struct inode *inode = mapping->host;
 	struct buffer_head *head = fsdata;
 	struct buffer_head *bh;
-	BUG_ON(fsdata != NULL && page_has_buffers(page));
+	BUG_ON(fsdata != NULL && _page_has_buffers(page, inode->i_mapping));
 
 	if (unlikely(copied < len) && head)
 		attach_nobh_buffers(mapping, page, head);
@@ -2822,7 +2822,7 @@ int nobh_truncate_page(struct address_space *mapping,
 	if (!page)
 		goto out;
 
-	if (page_has_buffers(page)) {
+	if (_page_has_buffers(page, mapping)) {
 has_buffers:
 		unlock_page(page);
 		put_page(page);
@@ -2857,7 +2857,7 @@ int nobh_truncate_page(struct address_space *mapping,
 			err = -EIO;
 			goto unlock;
 		}
-		if (page_has_buffers(page))
+		if (_page_has_buffers(page, inode->i_mapping))
 			goto has_buffers;
 	}
 	zero_user(page, offset, length);
@@ -2900,11 +2900,11 @@ int block_truncate_page(struct address_space *mapping,
 	if (!page)
 		goto out;
 
-	if (!page_has_buffers(page))
+	if (!_page_has_buffers(page, mapping))
 		create_empty_buffers(mapping, page, blocksize, 0);
 
 	/* Find the buffer that contains "offset" */
-	bh = page_buffers(page);
+	bh = _page_buffers(page, mapping);
 	pos = blocksize;
 	while (offset >= pos) {
 		bh = bh->b_this_page;
@@ -3260,7 +3260,7 @@ static int
 drop_buffers(struct address_space *mapping, struct page *page,
 	     struct buffer_head **buffers_to_free)
 {
-	struct buffer_head *head = page_buffers(page);
+	struct buffer_head *head = _page_buffers(page, mapping);
 	struct buffer_head *bh;
 
 	bh = head;
@@ -3491,7 +3491,7 @@ page_seek_hole_data(struct address_space *mapping, struct page *page,
 	if (lastoff < offset)
 		lastoff = offset;
 
-	bh = head = page_buffers(page);
+	bh = head = _page_buffers(page, mapping);
 	do {
 		offset += bh->b_size;
 		if (lastoff >= offset)
@@ -3563,7 +3563,7 @@ page_cache_seek_hole_data(struct inode *inode, loff_t offset, loff_t length,
 
 			lock_page(page);
 			if (likely(!page_is_truncated(page, inode->i_mapping)) &&
-			    page_has_buffers(page)) {
+			    _page_has_buffers(page, inode->i_mapping)) {
 				lastoff = page_seek_hole_data(inode->i_mapping,
 							page, lastoff, whence);
 				if (lastoff >= 0) {
diff --git a/fs/mpage.c b/fs/mpage.c
index ecdef63f464e..8141010b9f4c 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -107,7 +107,7 @@ map_buffer_to_page(struct inode *inode, struct page *page,
 	struct buffer_head *page_bh, *head;
 	int block = 0;
 
-	if (!page_has_buffers(page)) {
+	if (!_page_has_buffers(page, inode->i_mapping)) {
 		/*
 		 * don't make any buffers if there is only one buffer on
 		 * the page and the page just needs to be set up to date
@@ -120,7 +120,7 @@ map_buffer_to_page(struct inode *inode, struct page *page,
 		create_empty_buffers(inode->i_mapping, page,
 				     i_blocksize(inode), 0);
 	}
-	head = page_buffers(page);
+	head = _page_buffers(page, inode->i_mapping);
 	page_bh = head;
 	do {
 		if (block == page_block) {
@@ -166,7 +166,7 @@ do_mpage_readpage(struct bio *bio, struct address_space *mapping,
 	unsigned nblocks;
 	unsigned relative_block;
 
-	if (page_has_buffers(page))
+	if (_page_has_buffers(page, mapping))
 		goto confused;
 
 	block_in_file = (sector_t)page->index << (PAGE_SHIFT - blkbits);
@@ -453,9 +453,9 @@ static void clean_buffers(struct address_space *mapping, struct page *page,
 {
 	unsigned buffer_counter = 0;
 	struct buffer_head *bh, *head;
-	if (!page_has_buffers(page))
+	if (!_page_has_buffers(page, mapping))
 		return;
-	head = page_buffers(page);
+	head = _page_buffers(page, mapping);
 	bh = head;
 
 	do {
@@ -508,8 +508,8 @@ static int __mpage_writepage(struct page *page, struct address_space *mapping,
 	int ret = 0;
 	int op_flags = wbc_to_write_flags(wbc);
 
-	if (page_has_buffers(page)) {
-		struct buffer_head *head = page_buffers(page);
+	if (_page_has_buffers(page, mapping)) {
+		struct buffer_head *head = _page_buffers(page, mapping);
 		struct buffer_head *bh = head;
 
 		/* If they're all mapped and dirty, do it */
-- 
2.14.3
