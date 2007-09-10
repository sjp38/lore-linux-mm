Date: Mon, 10 Sep 2007 18:50:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [6/35] changes in CIFS
Message-Id: <20070910185021.a34206eb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: sfrench@samba.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Change page->mapping handling in CIFS

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---
 fs/cifs/file.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

Index: test-2.6.23-rc4-mm1/fs/cifs/file.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/cifs/file.c
+++ test-2.6.23-rc4-mm1/fs/cifs/file.c
@@ -1056,7 +1056,7 @@ struct cifsFileInfo *find_writable_file(
 
 static int cifs_partialpagewrite(struct page *page, unsigned from, unsigned to)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping_cache(page);
 	loff_t offset = (loff_t)page->index << PAGE_CACHE_SHIFT;
 	char *write_data;
 	int rc = -EFAULT;
@@ -1069,7 +1069,7 @@ static int cifs_partialpagewrite(struct 
 	if (!mapping || !mapping->host)
 		return -EFAULT;
 
-	inode = page->mapping->host;
+	inode = page_inode(page);
 	cifs_sb = CIFS_SB(inode->i_sb);
 	pTcon = cifs_sb->tcon;
 
@@ -1209,7 +1209,7 @@ retry:
 			else if (TestSetPageLocked(page))
 				break;
 
-			if (unlikely(page->mapping != mapping)) {
+			if (unlikely(pagecache_consistent(page, mapping))) {
 				unlock_page(page);
 				break;
 			}
@@ -1371,7 +1371,7 @@ static int cifs_commit_write(struct file
 {
 	int xid;
 	int rc = 0;
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	loff_t position = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
 	char *page_data;
 
@@ -1973,7 +1973,7 @@ static int cifs_prepare_write(struct fil
 	}
 
 	offset = (loff_t)page->index << PAGE_CACHE_SHIFT;
-	i_size = i_size_read(page->mapping->host);
+	i_size = i_size_read(page_inode(page));
 
 	if ((offset >= i_size) ||
 	    ((from == 0) && (offset + to) >= i_size)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
