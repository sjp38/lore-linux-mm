Date: Mon, 10 Sep 2007 19:23:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [27/35] changes in
 NTFS
Message-Id: <20070910192309.d7fd4d04.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: aia21@cantab.net, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Changes page->mapping handling in NTFS

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 fs/ntfs/aops.c     |   14 +++++++-------
 fs/ntfs/compress.c |    2 +-
 fs/ntfs/file.c     |    6 +++---
 3 files changed, 11 insertions(+), 11 deletions(-)

Index: test-2.6.23-rc4-mm1/fs/ntfs/aops.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/ntfs/aops.c
+++ test-2.6.23-rc4-mm1/fs/ntfs/aops.c
@@ -65,7 +65,7 @@ static void ntfs_end_buffer_async_read(s
 	int page_uptodate = 1;
 
 	page = bh->b_page;
-	vi = page->mapping->host;
+	vi = page_inode(page);
 	ni = NTFS_I(vi);
 
 	if (likely(uptodate)) {
@@ -194,7 +194,7 @@ static int ntfs_read_block(struct page *
 	int i, nr;
 	unsigned char blocksize_bits;
 
-	vi = page->mapping->host;
+	vi = page_inode(page);
 	ni = NTFS_I(vi);
 	vol = ni->vol;
 
@@ -413,7 +413,7 @@ retry_readpage:
 		unlock_page(page);
 		return 0;
 	}
-	vi = page->mapping->host;
+	vi = page_inode(page);
 	ni = NTFS_I(vi);
 	/*
 	 * Only $DATA attributes can be encrypted and only unnamed $DATA
@@ -553,7 +553,7 @@ static int ntfs_write_block(struct page 
 	bool need_end_writeback;
 	unsigned char blocksize_bits;
 
-	vi = page->mapping->host;
+	vi = page_inode(page);
 	ni = NTFS_I(vi);
 	vol = ni->vol;
 
@@ -909,7 +909,7 @@ static int ntfs_write_mst_block(struct p
 		struct writeback_control *wbc)
 {
 	sector_t block, dblock, rec_block;
-	struct inode *vi = page->mapping->host;
+	struct inode *vi = page_inode(page);
 	ntfs_inode *ni = NTFS_I(vi);
 	ntfs_volume *vol = ni->vol;
 	u8 *kaddr;
@@ -1342,7 +1342,7 @@ done:
 static int ntfs_writepage(struct page *page, struct writeback_control *wbc)
 {
 	loff_t i_size;
-	struct inode *vi = page->mapping->host;
+	struct inode *vi = page_inode(page);
 	ntfs_inode *base_ni = NULL, *ni = NTFS_I(vi);
 	char *kaddr;
 	ntfs_attr_search_ctx *ctx = NULL;
@@ -1579,7 +1579,7 @@ const struct address_space_operations nt
  * need the lock since try_to_free_buffers() does not free dirty buffers.
  */
 void mark_ntfs_record_dirty(struct page *page, const unsigned int ofs) {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping_cache(page);
 	ntfs_inode *ni = NTFS_I(mapping->host);
 	struct buffer_head *bh, *head, *buffers_to_free = NULL;
 	unsigned int end, bh_size, bh_ofs;
Index: test-2.6.23-rc4-mm1/fs/ntfs/compress.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/ntfs/compress.c
+++ test-2.6.23-rc4-mm1/fs/ntfs/compress.c
@@ -482,7 +482,7 @@ int ntfs_read_compressed_block(struct pa
 {
 	loff_t i_size;
 	s64 initialized_size;
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping_cache(page);
 	ntfs_inode *ni = NTFS_I(mapping->host);
 	ntfs_volume *vol = ni->vol;
 	struct super_block *sb = vol->sb;
Index: test-2.6.23-rc4-mm1/fs/ntfs/file.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/ntfs/file.c
+++ test-2.6.23-rc4-mm1/fs/ntfs/file.c
@@ -520,7 +520,7 @@ static int ntfs_prepare_pages_for_non_re
 	BUG_ON(!nr_pages);
 	BUG_ON(!pages);
 	BUG_ON(!*pages);
-	vi = pages[0]->mapping->host;
+	vi = page_inode(pages[0]);
 	ni = NTFS_I(vi);
 	vol = ni->vol;
 	ntfs_debug("Entering for inode 0x%lx, attribute type 0x%x, start page "
@@ -1494,7 +1494,7 @@ static inline int ntfs_commit_pages_afte
 	unsigned blocksize, u;
 	int err;
 
-	vi = pages[0]->mapping->host;
+	vi = page_inode(pages[0]);
 	ni = NTFS_I(vi);
 	blocksize = vi->i_sb->s_blocksize;
 	end = pos + bytes;
@@ -1654,7 +1654,7 @@ static int ntfs_commit_pages_after_write
 	BUG_ON(!pages);
 	page = pages[0];
 	BUG_ON(!page);
-	vi = page->mapping->host;
+	vi = page_inode(page);
 	ni = NTFS_I(vi);
 	ntfs_debug("Entering for inode 0x%lx, attribute type 0x%x, start page "
 			"index 0x%lx, nr_pages 0x%x, pos 0x%llx, bytes 0x%zx.",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
