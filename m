Date: Mon, 10 Sep 2007 18:59:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [12/35] changes in
 EXT3
Message-Id: <20070910185907.36ac6079.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Change page->mapping handling in EXT3

Signed-off-by:	KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 fs/ext3/inode.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

Index: test-2.6.23-rc4-mm1/fs/ext3/inode.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/ext3/inode.c
+++ test-2.6.23-rc4-mm1/fs/ext3/inode.c
@@ -1484,7 +1484,7 @@ static int journal_dirty_data_fn(handle_
 static int ext3_ordered_writepage(struct page *page,
 				struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct buffer_head *page_bufs;
 	handle_t *handle = NULL;
 	int ret = 0;
@@ -1550,7 +1550,7 @@ out_fail:
 static int ext3_writeback_writepage(struct page *page,
 				struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	handle_t *handle = NULL;
 	int ret = 0;
 	int err;
@@ -1583,7 +1583,7 @@ out_fail:
 static int ext3_journalled_writepage(struct page *page,
 				struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	handle_t *handle = NULL;
 	int ret = 0;
 	int err;
@@ -1653,7 +1653,7 @@ ext3_readpages(struct file *file, struct
 
 static void ext3_invalidatepage(struct page *page, unsigned long offset)
 {
-	journal_t *journal = EXT3_JOURNAL(page->mapping->host);
+	journal_t *journal = EXT3_JOURNAL(page_inode(page));
 
 	/*
 	 * If it's a full truncate we just forget about the pending dirtying
@@ -1666,7 +1666,7 @@ static void ext3_invalidatepage(struct p
 
 static int ext3_releasepage(struct page *page, gfp_t wait)
 {
-	journal_t *journal = EXT3_JOURNAL(page->mapping->host);
+	journal_t *journal = EXT3_JOURNAL(page_inode(page));
 
 	WARN_ON(PageChecked(page));
 	if (!page_has_buffers(page))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
