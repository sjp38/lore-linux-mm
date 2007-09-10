Date: Mon, 10 Sep 2007 18:57:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [11/35] changes in
 EXT2
Message-Id: <20070910185746.2ebc741f.kamezawa.hiroyu@jp.fujitsu.com>
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

Change page->mapping handling in ext2

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 fs/ext2/dir.c |   20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

Index: test-2.6.23-rc4-mm1/fs/ext2/dir.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/ext2/dir.c
+++ test-2.6.23-rc4-mm1/fs/ext2/dir.c
@@ -65,7 +65,7 @@ ext2_last_byte(struct inode *inode, unsi
 
 static int ext2_commit_chunk(struct page *page, loff_t pos, unsigned len)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping_cache(page);
 	struct inode *dir = mapping->host;
 	int err = 0;
 
@@ -87,7 +87,7 @@ static int ext2_commit_chunk(struct page
 
 static void ext2_check_page(struct page *page)
 {
-	struct inode *dir = page->mapping->host;
+	struct inode *dir = page_inode(page);
 	struct super_block *sb = dir->i_sb;
 	unsigned chunk_size = ext2_chunk_size(dir);
 	char *kaddr = page_address(page);
@@ -429,7 +429,7 @@ void ext2_set_link(struct inode *dir, st
 	int err;
 
 	lock_page(page);
-	err = __ext2_write_begin(NULL, page->mapping, pos, len,
+	err = __ext2_write_begin(NULL, page_mapping_cache(page), pos, len,
 				AOP_FLAG_UNINTERRUPTIBLE, &page, NULL);
 	BUG_ON(err);
 	de->inode = cpu_to_le32(inode->i_ino);
@@ -512,8 +512,8 @@ int ext2_add_link (struct dentry *dentry
 got_it:
 	pos = page_offset(page) +
 		(char*)de - (char*)page_address(page);
-	err = __ext2_write_begin(NULL, page->mapping, pos, rec_len, 0,
-							&page, NULL);
+	err = __ext2_write_begin(NULL, page_mapping_cache(page), pos, rec_len,
+				0, &page, NULL);
 	if (err)
 		goto out_unlock;
 	if (de->inode) {
@@ -546,7 +546,7 @@ out_unlock:
  */
 int ext2_delete_entry (struct ext2_dir_entry_2 * dir, struct page * page )
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping_cache(page);
 	struct inode *inode = mapping->host;
 	char *kaddr = page_address(page);
 	unsigned from = ((char*)dir - kaddr) & ~(ext2_chunk_size(inode)-1);
@@ -570,8 +570,8 @@ int ext2_delete_entry (struct ext2_dir_e
 		from = (char*)pde - (char*)page_address(page);
 	pos = page_offset(page) + from;
 	lock_page(page);
-	err = __ext2_write_begin(NULL, page->mapping, pos, to - from, 0,
-							&page, NULL);
+	err = __ext2_write_begin(NULL, page_mapping_cache(page), pos,
+				to - from, 0, &page, NULL);
 	BUG_ON(err);
 	if (pde)
 		pde->rec_len = cpu_to_le16(to - from);
@@ -600,8 +600,8 @@ int ext2_make_empty(struct inode *inode,
 	if (!page)
 		return -ENOMEM;
 
-	err = __ext2_write_begin(NULL, page->mapping, 0, chunk_size, 0,
-							&page, NULL);
+	err = __ext2_write_begin(NULL, page_mapping_cache(page), 0, chunk_size,
+					0, &page, NULL);
 	if (err) {
 		unlock_page(page);
 		goto fail;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
