Date: Mon, 10 Sep 2007 19:00:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [13/35] changes in
 EXT4
Message-Id: <20070910190006.e2970b76.kamezawa.hiroyu@jp.fujitsu.com>
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

Changes page->mapping handling in EXT4

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 fs/ext4/inode.c     |   10 +++++-----
 fs/ext4/writeback.c |   24 ++++++++++++------------
 2 files changed, 17 insertions(+), 17 deletions(-)

Index: test-2.6.23-rc4-mm1/fs/ext4/inode.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/ext4/inode.c
+++ test-2.6.23-rc4-mm1/fs/ext4/inode.c
@@ -1482,7 +1482,7 @@ static int jbd2_journal_dirty_data_fn(ha
 static int ext4_ordered_writepage(struct page *page,
 				struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct buffer_head *page_bufs;
 	handle_t *handle = NULL;
 	int ret = 0;
@@ -1548,7 +1548,7 @@ out_fail:
 static int ext4_writeback_writepage(struct page *page,
 				struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	handle_t *handle = NULL;
 	int ret = 0;
 	int err;
@@ -1581,7 +1581,7 @@ out_fail:
 static int ext4_journalled_writepage(struct page *page,
 				struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	handle_t *handle = NULL;
 	int ret = 0;
 	int err;
@@ -1651,7 +1651,7 @@ ext4_readpages(struct file *file, struct
 
 static void ext4_invalidatepage(struct page *page, unsigned long offset)
 {
-	journal_t *journal = EXT4_JOURNAL(page->mapping->host);
+	journal_t *journal = EXT4_JOURNAL(page_inode(page));
 
 	/*
 	 * If it's a full truncate we just forget about the pending dirtying
@@ -1664,7 +1664,7 @@ static void ext4_invalidatepage(struct p
 
 static int ext4_releasepage(struct page *page, gfp_t wait)
 {
-	journal_t *journal = EXT4_JOURNAL(page->mapping->host);
+	journal_t *journal = EXT4_JOURNAL(page_inode(page));
 
 	WARN_ON(PageChecked(page));
 	if (!page_has_buffers(page))
Index: test-2.6.23-rc4-mm1/fs/ext4/writeback.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/ext4/writeback.c
+++ test-2.6.23-rc4-mm1/fs/ext4/writeback.c
@@ -175,7 +175,7 @@ static struct bio *ext4_wb_bio_submit(st
 
 int inline ext4_wb_reserve_space_page(struct page *page, int blocks)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	int total, mdb, err;
 
 	wb_debug("reserve %d blocks for page %lu from inode %lu\n",
@@ -263,7 +263,7 @@ static inline int ext4_wb_drop_page_rese
 	 * reserved blocks. we could release reserved blocks right
 	 * now, but I'd prefer to make this once per several blocks */
 	wb_debug("drop reservation from page %lu from inode %lu\n",
-			page->index, page->mapping->host->i_ino);
+			page->index, page_inode(page)->i_ino);
 	BUG_ON(!PageBooked(page));
 	ClearPageBooked(page);
 	return 0;
@@ -711,7 +711,7 @@ int ext4_wb_writepages(struct address_sp
 			if (wbc->sync_mode != WB_SYNC_NONE)
 				wait_on_page_writeback(page);
 
-			if (page->mapping != mapping) {
+			if (pagecache_consistent(page, mapping)) {
 				unlock_page(page);
 				continue;
 			}
@@ -853,12 +853,12 @@ static void ext4_wb_clear_page(struct pa
 int ext4_wb_prepare_write(struct file *file, struct page *page,
 			      unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct buffer_head bh, *bhw = &bh;
 	int err = 0;
 
 	wb_debug("prepare page %lu (%u-%u) for inode %lu\n",
-			page->index, from, to, page->mapping->host->i_ino);
+			page->index, from, to, page_inode(page)->i_ino);
 
 	/* if page is uptodate this means that ->prepare_write() has
 	 * been called on page before and page is mapped to disk or
@@ -912,7 +912,7 @@ int ext4_wb_commit_write(struct file *fi
 			     unsigned from, unsigned to)
 {
 	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	int err = 0;
 
 	wb_debug("commit page %lu (%u-%u) for inode %lu\n",
@@ -952,7 +952,7 @@ int ext4_wb_commit_write(struct file *fi
 int ext4_wb_write_single_page(struct page *page,
 					struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct ext4_wb_control wc;
 	int err;
 
@@ -964,7 +964,7 @@ int ext4_wb_write_single_page(struct pag
 		atomic_inc(&EXT4_SB(inode->i_sb)->s_wb_collisions_sp);
 #endif
 
-	ext4_wb_init_control(&wc, page->mapping);
+	ext4_wb_init_control(&wc, page_mapping_cache(page));
 
 	BUG_ON(PageWriteback(page));
 	set_page_writeback(page);
@@ -988,7 +988,7 @@ int ext4_wb_write_single_page(struct pag
 
 int ext4_wb_writepage(struct page *page, struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	loff_t i_size = i_size_read(inode);
 	pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
 	unsigned offset;
@@ -1002,7 +1002,7 @@ int ext4_wb_writepage(struct page *page,
 	 * hasn't space on a disk yet, leave it for that thread
 	 */
 #if 1
-	if (atomic_read(&EXT4_I(page->mapping->host)->i_wb_writers)
+	if (atomic_read(&EXT4_I(page_inode(page))->i_wb_writers)
 			&& !PageMappedToDisk(page)) {
 		__set_page_dirty_nobuffers(page);
 		unlock_page(page);
@@ -1054,7 +1054,7 @@ int ext4_wb_releasepage(struct page *pag
 	wb_debug("release %sM%sR page %lu from inode %lu (wait %d)\n",
 			PageMappedToDisk(page) ? "" : "!",
 			PageBooked(page) ? "" : "!",
-			page->index, page->mapping->host->i_ino, wait);
+			page->index, page_inode(page)->i_ino, wait);
 
 	if (PageWriteback(page))
 		return 0;
@@ -1066,7 +1066,7 @@ int ext4_wb_releasepage(struct page *pag
 
 void ext4_wb_invalidatepage(struct page *page, unsigned long offset)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	int ret = 0;
 
 	/* ->invalidatepage() is called when page is marked Private.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
