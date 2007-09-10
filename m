Date: Mon, 10 Sep 2007 19:35:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [34/35] changes in
 UNIONFS
Message-Id: <20070910193539.8af2bb55.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: ezk@cs.sunysb.edu, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Changes page->mapping handling in UNIONFS

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 fs/unionfs/mmap.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: test-2.6.23-rc4-mm1/fs/unionfs/mmap.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/unionfs/mmap.c
+++ test-2.6.23-rc4-mm1/fs/unionfs/mmap.c
@@ -61,7 +61,7 @@ static int unionfs_writepage(struct page
 	char *kaddr, *lower_kaddr;
 	int saved_for_writepages = wbc->for_writepages;
 
-	inode = page->mapping->host;
+	inode = page_inode(page);
 	lower_inode = unionfs_lower_inode(inode);
 
 	/* find lower page (returns a locked page) */
@@ -225,7 +225,7 @@ static int unionfs_commit_write(struct f
 	if ((err = unionfs_file_revalidate(file, 1)))
 		goto out;
 
-	inode = page->mapping->host;
+	inode = page_inode(page);
 	lower_inode = unionfs_lower_inode(inode);
 
 	if (UNIONFS_F(file) != NULL)
@@ -283,7 +283,7 @@ static void unionfs_sync_page(struct pag
 	struct page *lower_page;
 	struct address_space *mapping;
 
-	inode = page->mapping->host;
+	inode = page_inode(page);
 	lower_inode = unionfs_lower_inode(inode);
 
 	/* find lower page (returns a locked page) */
@@ -292,7 +292,7 @@ static void unionfs_sync_page(struct pag
 		goto out;
 
 	/* do the actual sync */
-	mapping = lower_page->mapping;
+	mapping = page_mapping_cache(lower_page);
 	/*
 	 * XXX: can we optimize ala RAIF and set the lower page to be
 	 * discarded after a successful sync_page?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
