Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0CF626B00A0
	for <linux-mm@kvack.org>; Wed,  7 May 2014 19:16:27 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so1837692pab.0
        for <linux-mm@kvack.org>; Wed, 07 May 2014 16:16:27 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id vv4si2614096pbc.193.2014.05.07.16.16.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 07 May 2014 16:16:27 -0700 (PDT)
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0N5800NEE8NC3480@mailout2.samsung.com> for linux-mm@kvack.org;
 Thu, 08 May 2014 08:16:24 +0900 (KST)
From: Namjae Jeon <namjae.jeon@samsung.com>
Subject: [PATCH v3] ext4: fix data integrity sync in ordered mode
Date: Thu, 08 May 2014 08:16:24 +0900
Message-id: <000801cf6a4a$5d5c2dc0$18148940$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: linux-ext4 <linux-ext4@vger.kernel.org>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

When we perform a data integrity sync we tag all the dirty pages with
PAGECACHE_TAG_TOWRITE at start of ext4_da_writepages.
Later we check for this tag in write_cache_pages_da and creates a
struct mpage_da_data containing contiguously indexed pages tagged with this
tag and sync these pages with a call to mpage_da_map_and_submit.
This process is done in while loop until all the PAGECACHE_TAG_TOWRITE pages
are synced. We also do journal start and stop in each iteration.
journal_stop could initiate journal commit which would call ext4_writepage
which in turn will call ext4_bio_write_page even for delayed OR unwritten
buffers. When ext4_bio_write_page is called for such buffers, even though it
does not sync them but it clears the PAGECACHE_TAG_TOWRITE of the corresponding
page and hence these pages are also not synced by the currently running data
integrity sync. We will end up with dirty pages although sync is completed.

This could cause a potential data loss when the sync call is followed by a
truncate_pagecache call, which is exactly the case in collapse_range.
(It will cause generic/127 failure in xfstests)

To avoid this issue, we can use set_page_writeback_keepwrite instead of
set_page_writeback, which doesn't clear TOWRITE tag.

Signed-off-by: Namjae Jeon <namjae.jeon@samsung.com>
Signed-off-by: Ashish Sangwan <a.sangwan@samsung.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---

Changelog
v3:
 - define test_set_page_writeback() and test_set_page_writeback_keepwrite()
   as calls to __test_set_page_writeback(page, keep_write)

v2:
 - As Jan Kara suggested, Create set_page_writeback_keepwrite which doesn't
   clear TOWRITE tag.

 fs/ext4/ext4.h             |  3 ++-
 fs/ext4/inode.c            |  6 ++++--
 fs/ext4/page-io.c          |  8 ++++++--
 include/linux/page-flags.h | 12 +++++++++++-
 mm/page-writeback.c        | 11 ++++++-----
 5 files changed, 29 insertions(+), 11 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 6b45afa..78fed7b 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -2771,7 +2771,8 @@ extern void ext4_io_submit(struct ext4_io_submit *io);
 extern int ext4_bio_write_page(struct ext4_io_submit *io,
 			       struct page *page,
 			       int len,
-			       struct writeback_control *wbc);
+			       struct writeback_control *wbc,
+			       bool keep_towrite);
 
 /* mmp.c */
 extern int ext4_multi_mount_protect(struct super_block *, ext4_fsblk_t);
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index b1dc334..8d9cb26 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1846,6 +1846,7 @@ static int ext4_writepage(struct page *page,
 	struct buffer_head *page_bufs = NULL;
 	struct inode *inode = page->mapping->host;
 	struct ext4_io_submit io_submit;
+	bool keep_towrite = false;
 
 	trace_ext4_writepage(page);
 	size = i_size_read(inode);
@@ -1876,6 +1877,7 @@ static int ext4_writepage(struct page *page,
 			unlock_page(page);
 			return 0;
 		}
+		keep_towrite = true;
 	}
 
 	if (PageChecked(page) && ext4_should_journal_data(inode))
@@ -1892,7 +1894,7 @@ static int ext4_writepage(struct page *page,
 		unlock_page(page);
 		return -ENOMEM;
 	}
-	ret = ext4_bio_write_page(&io_submit, page, len, wbc);
+	ret = ext4_bio_write_page(&io_submit, page, len, wbc, keep_towrite);
 	ext4_io_submit(&io_submit);
 	/* Drop io_end reference we got from init */
 	ext4_put_io_end_defer(io_submit.io_end);
@@ -1911,7 +1913,7 @@ static int mpage_submit_page(struct mpage_da_data *mpd, struct page *page)
 	else
 		len = PAGE_CACHE_SIZE;
 	clear_page_dirty_for_io(page);
-	err = ext4_bio_write_page(&mpd->io_submit, page, len, mpd->wbc);
+	err = ext4_bio_write_page(&mpd->io_submit, page, len, mpd->wbc, false);
 	if (!err)
 		mpd->wbc->nr_to_write--;
 	mpd->first_page++;
diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index 1a64e7a..4a2dd07 100644
--- a/fs/ext4/page-io.c
+++ b/fs/ext4/page-io.c
@@ -401,7 +401,8 @@ submit_and_retry:
 int ext4_bio_write_page(struct ext4_io_submit *io,
 			struct page *page,
 			int len,
-			struct writeback_control *wbc)
+			struct writeback_control *wbc,
+			bool keep_towrite)
 {
 	struct inode *inode = page->mapping->host;
 	unsigned block_start, blocksize;
@@ -414,7 +415,10 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
 	BUG_ON(!PageLocked(page));
 	BUG_ON(PageWriteback(page));
 
-	set_page_writeback(page);
+	if (keep_towrite)
+		set_page_writeback_keepwrite(page);
+	else
+		set_page_writeback(page);
 	ClearPageError(page);
 
 	/*
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index bc2007e..9b68718 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -317,13 +317,23 @@ CLEARPAGEFLAG(Uptodate, uptodate)
 extern void cancel_dirty_page(struct page *page, unsigned int account_size);
 
 int test_clear_page_writeback(struct page *page);
-int test_set_page_writeback(struct page *page);
+int __test_set_page_writeback(struct page *page, bool keep_write);
+
+#define test_set_page_writeback(page)			\
+	__test_set_page_writeback(page, false)
+#define test_set_page_writeback_keepwrite(page)	\
+	__test_set_page_writeback(page, true)
 
 static inline void set_page_writeback(struct page *page)
 {
 	test_set_page_writeback(page);
 }
 
+static inline void set_page_writeback_keepwrite(struct page *page)
+{
+	test_set_page_writeback_keepwrite(page);
+}
+
 #ifdef CONFIG_PAGEFLAGS_EXTENDED
 /*
  * System with lots of page flags available. This allows separate
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 310d329..ba037e3 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2398,7 +2398,7 @@ int test_clear_page_writeback(struct page *page)
 	return ret;
 }
 
-int test_set_page_writeback(struct page *page)
+int __test_set_page_writeback(struct page *page, bool keep_write)
 {
 	struct address_space *mapping = page_mapping(page);
 	int ret;
@@ -2423,9 +2423,10 @@ int test_set_page_writeback(struct page *page)
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
-		radix_tree_tag_clear(&mapping->page_tree,
-				     page_index(page),
-				     PAGECACHE_TAG_TOWRITE);
+		if (!keep_write)
+			radix_tree_tag_clear(&mapping->page_tree,
+						page_index(page),
+						PAGECACHE_TAG_TOWRITE);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 	} else {
 		ret = TestSetPageWriteback(page);
@@ -2436,7 +2437,7 @@ int test_set_page_writeback(struct page *page)
 	return ret;
 
 }
-EXPORT_SYMBOL(test_set_page_writeback);
+EXPORT_SYMBOL(__test_set_page_writeback);
 
 /*
  * Return true if any of the pages in the mapping are marked with the
-- 
1.7.11-rc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
