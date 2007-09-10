Date: Mon, 10 Sep 2007 19:18:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [24/35] changes in
 MINIX FS
Message-Id: <20070910191854.a79319a0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Changes page->mapping handling in MINIXFS


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/minix/dir.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

Index: test-2.6.23-rc4-mm1/fs/minix/dir.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/minix/dir.c
+++ test-2.6.23-rc4-mm1/fs/minix/dir.c
@@ -52,7 +52,7 @@ static inline unsigned long dir_pages(st
 
 static int dir_commit_chunk(struct page *page, loff_t pos, unsigned len)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping_cache(page);
 	struct inode *dir = mapping->host;
 	int err = 0;
 	block_write_end(NULL, mapping, pos, len, len, page, NULL);
@@ -281,7 +281,8 @@ int minix_add_link(struct dentry *dentry
 
 got_it:
 	pos = (page->index >> PAGE_CACHE_SHIFT) + p - (char*)page_address(page);
-	err = __minix_write_begin(NULL, page->mapping, pos, sbi->s_dirsize,
+	err = __minix_write_begin(NULL,
+				page_mapping_cache(page), pos, sbi->s_dirsize,
 					AOP_FLAG_UNINTERRUPTIBLE, &page, NULL);
 	if (err)
 		goto out_unlock;
@@ -307,7 +308,7 @@ out_unlock:
 
 int minix_delete_entry(struct minix_dir_entry *de, struct page *page)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping_cache(page);
 	struct inode *inode = (struct inode*)mapping->host;
 	char *kaddr = page_address(page);
 	loff_t pos = page_offset(page) + (char*)de - kaddr;
@@ -431,7 +432,7 @@ not_empty:
 void minix_set_link(struct minix_dir_entry *de, struct page *page,
 	struct inode *inode)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping_cache(page);
 	struct inode *dir = mapping->host;
 	struct minix_sb_info *sbi = minix_sb(dir->i_sb);
 	loff_t pos = page_offset(page) +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
