Date: Mon, 10 Sep 2007 18:55:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [9/35] changes in
 ECRYPTFS
Message-Id: <20070910185515.1dcf643e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: mhalcrow@us.ibm.com, phillip@hellewell.homeip.net, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Change page->mapping handling in ecryptfs

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---
 fs/ecryptfs/crypto.c |    9 ++++-----
 fs/ecryptfs/mmap.c   |   14 +++++++-------
 2 files changed, 11 insertions(+), 12 deletions(-)

Index: test-2.6.23-rc4-mm1/fs/ecryptfs/crypto.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/ecryptfs/crypto.c
+++ test-2.6.23-rc4-mm1/fs/ecryptfs/crypto.c
@@ -504,8 +504,8 @@ int ecryptfs_encrypt_page(struct ecryptf
 #define ECRYPTFS_PAGE_STATE_WRITTEN   3
 	int page_state;
 
-	lower_inode = ecryptfs_inode_to_lower(ctx->page->mapping->host);
-	inode_info = ecryptfs_inode_to_private(ctx->page->mapping->host);
+	lower_inode = ecryptfs_inode_to_lower(page_inode(ctx->page));
+	inode_info = ecryptfs_inode_to_private(page_inode(ctx->page));
 	crypt_stat = &inode_info->crypt_stat;
 	if (!(crypt_stat->flags & ECRYPTFS_ENCRYPTED)) {
 		rc = ecryptfs_copy_page_to_lower(ctx->page, lower_inode,
@@ -636,9 +636,8 @@ int ecryptfs_decrypt_page(struct file *f
 	int num_extents_per_page;
 	int page_state;
 
-	crypt_stat = &(ecryptfs_inode_to_private(
-			       page->mapping->host)->crypt_stat);
-	lower_inode = ecryptfs_inode_to_lower(page->mapping->host);
+	crypt_stat = &(ecryptfs_inode_to_private(page_inode(page))->crypt_stat);
+	lower_inode = ecryptfs_inode_to_lower(page_inode(page));
 	if (!(crypt_stat->flags & ECRYPTFS_ENCRYPTED)) {
 		rc = ecryptfs_do_readpage(file, page, page->index);
 		if (rc)
Index: test-2.6.23-rc4-mm1/fs/ecryptfs/mmap.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/ecryptfs/mmap.c
+++ test-2.6.23-rc4-mm1/fs/ecryptfs/mmap.c
@@ -363,7 +363,7 @@ out:
  */
 static int fill_zeros_to_end_of_page(struct page *page, unsigned int to)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	int end_byte_in_page;
 
 	if ((i_size_read(inode) / PAGE_CACHE_SIZE) != page->index)
@@ -411,7 +411,7 @@ static int ecryptfs_prepare_write(struct
 	if (page->index != 0) {
 		loff_t end_of_prev_pg_pos = page_offset(page) - 1;
 
-		if (end_of_prev_pg_pos > i_size_read(page->mapping->host)) {
+		if (end_of_prev_pg_pos > i_size_read(page_inode(page))) {
 			rc = ecryptfs_truncate(file->f_path.dentry,
 					       end_of_prev_pg_pos);
 			if (rc) {
@@ -421,7 +421,7 @@ static int ecryptfs_prepare_write(struct
 				goto out;
 			}
 		}
-		if (end_of_prev_pg_pos + 1 > i_size_read(page->mapping->host))
+		if (end_of_prev_pg_pos + 1 > i_size_read(page_inode(page)))
 			zero_user_page(page, 0, PAGE_CACHE_SIZE, KM_USER0);
 	}
 out:
@@ -683,7 +683,7 @@ static int ecryptfs_commit_write(struct 
 	struct ecryptfs_crypt_stat *crypt_stat;
 	int rc;
 
-	inode = page->mapping->host;
+	inode = page_inode(page);
 	lower_inode = ecryptfs_inode_to_lower(inode);
 	lower_file = ecryptfs_file_to_lower(file);
 	mutex_lock(&lower_inode->i_mutex);
@@ -805,7 +805,7 @@ static void ecryptfs_sync_page(struct pa
 	struct inode *lower_inode;
 	struct page *lower_page;
 
-	inode = page->mapping->host;
+	inode = page_inode(page);
 	lower_inode = ecryptfs_inode_to_lower(inode);
 	/* NOTE: Recently swapped with grab_cache_page(), since
 	 * sync_page() just makes sure that pending I/O gets done. */
@@ -814,8 +814,8 @@ static void ecryptfs_sync_page(struct pa
 		ecryptfs_printk(KERN_DEBUG, "find_lock_page failed\n");
 		return;
 	}
-	if (lower_page->mapping->a_ops->sync_page)
-		lower_page->mapping->a_ops->sync_page(lower_page);
+	if (page_mapping_cache(lower_page)->a_ops->sync_page)
+		page_mapping_cache(lower_page)->a_ops->sync_page(lower_page);
 	ecryptfs_printk(KERN_DEBUG, "Unlocking page with index = [0x%.16x]\n",
 			lower_page->index);
 	unlock_page(lower_page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
