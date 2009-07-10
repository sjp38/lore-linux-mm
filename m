Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 93EDE6B0055
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 05:11:42 -0400 (EDT)
Date: Fri, 10 Jul 2009 11:35:08 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 3/3] fs: buffer_head page_lock i_size relax
Message-ID: <20090710093508.GI14666@wotan.suse.de>
References: <20090710073028.782561541@suse.de> <20090710093325.GG14666@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090710093325.GG14666@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: hch@infradead.org, viro@zeniv.linux.org.uk, jack@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


The previous patch allows us to relax the buffer.c requirement that the page
lock be held in order to avoid writepage zeroing out new data beyond isize.
[actually as I said I think it still has a bug due to writepage requiring
i_size_read]

---
 fs/buffer.c |   28 ++++++++--------------------
 mm/shmem.c  |    6 +++---
 2 files changed, 11 insertions(+), 23 deletions(-)

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -2049,33 +2049,20 @@ int generic_write_end(struct file *file,
 			struct page *page, void *fsdata)
 {
 	struct inode *inode = mapping->host;
-	int i_size_changed = 0;
 
 	copied = block_write_end(file, mapping, pos, len, copied, page, fsdata);
 
+	unlock_page(page);
+	page_cache_release(page);
+
 	/*
 	 * No need to use i_size_read() here, the i_size
 	 * cannot change under us because we hold i_mutex.
-	 *
-	 * But it's important to update i_size while still holding page lock:
-	 * page writeout could otherwise come in and zero beyond i_size.
 	 */
 	if (pos+copied > inode->i_size) {
 		i_size_write(inode, pos+copied);
-		i_size_changed = 1;
-	}
-
-	unlock_page(page);
-	page_cache_release(page);
-
-	/*
-	 * Don't mark the inode dirty under page lock. First, it unnecessarily
-	 * makes the holding time of page lock longer. Second, it forces lock
-	 * ordering of page lock and transaction start for journaling
-	 * filesystems.
-	 */
-	if (i_size_changed)
 		mark_inode_dirty(inode);
+	}
 
 	return copied;
 }
@@ -2624,14 +2611,15 @@ int nobh_write_end(struct file *file, st
 
 	SetPageUptodate(page);
 	set_page_dirty(page);
+
+	unlock_page(page);
+	page_cache_release(page);
+
 	if (pos+copied > inode->i_size) {
 		i_size_write(inode, pos+copied);
 		mark_inode_dirty(inode);
 	}
 
-	unlock_page(page);
-	page_cache_release(page);
-
 	while (head) {
 		bh = head;
 		head = head->b_this_page;
Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c
+++ linux-2.6/mm/shmem.c
@@ -1631,13 +1631,13 @@ shmem_write_end(struct file *file, struc
 {
 	struct inode *inode = mapping->host;
 
-	if (pos + copied > inode->i_size)
-		i_size_write(inode, pos + copied);
-
 	unlock_page(page);
 	set_page_dirty(page);
 	page_cache_release(page);
 
+	if (pos + copied > inode->i_size)
+		i_size_write(inode, pos + copied);
+
 	return copied;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
