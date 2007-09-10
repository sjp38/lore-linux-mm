Date: Mon, 10 Sep 2007 19:29:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [31/35] changes in
 SYSVFS
Message-Id: <20070910192925.40fe3b5a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: hch@infradead.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Changes page->mapping handlingi in SYSVFS.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 fs/sysv/dir.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

Index: test-2.6.23-rc4-mm1/fs/sysv/dir.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/sysv/dir.c
+++ test-2.6.23-rc4-mm1/fs/sysv/dir.c
@@ -40,7 +40,7 @@ static inline unsigned long dir_pages(st
 
 static int dir_commit_chunk(struct page *page, loff_t pos, unsigned len)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping_cache(page);
 	struct inode *dir = mapping->host;
 	int err = 0;
 
@@ -221,7 +221,8 @@ got_it:
 	pos = page_offset(page) +
 			(char*)de - (char*)page_address(page);
 	lock_page(page);
-	err = __sysv_write_begin(NULL, page->mapping, pos, SYSV_DIRSIZE,
+	err = __sysv_write_begin(NULL, page_mapping_cache(page),
+				pos, SYSV_DIRSIZE,
 				AOP_FLAG_UNINTERRUPTIBLE, &page, NULL);
 	if (err)
 		goto out_unlock;
@@ -242,7 +243,7 @@ out_unlock:
 
 int sysv_delete_entry(struct sysv_dir_entry *de, struct page *page)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping_cache(page);
 	struct inode *inode = (struct inode*)mapping->host;
 	char *kaddr = (char*)page_address(page);
 	loff_t pos = page_offset(page) + (char *)de - kaddr;
@@ -344,7 +345,7 @@ not_empty:
 void sysv_set_link(struct sysv_dir_entry *de, struct page *page,
 	struct inode *inode)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping_cache(page);
 	struct inode *dir = mapping->host;
 	loff_t pos = page_offset(page) +
 			(char *)de-(char*)page_address(page);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
