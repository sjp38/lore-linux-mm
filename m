From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070204063716.23659.90293.sendpatchset@linux.site>
In-Reply-To: <20070204063707.23659.20741.sendpatchset@linux.site>
References: <20070204063707.23659.20741.sendpatchset@linux.site>
Subject: [patch 1/9] fs: libfs buffered write leak fix
Date: Sun,  4 Feb 2007 09:49:50 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

simple_prepare_write and nobh_prepare_write leak uninitialised kernel data.
This happens because the prepare_write functions leave an uninitialised
"hole" over the part of the page that the write is expected to go to. This
is fine, but they then mark the page uptodate, which means a concurrent read
can come in and copy the uninitialised memory into userspace before it written
to.

Fix simple_readpage by simply initialising the whole page in the case of a
partial-page write. In the case of a full-page write, we don't SetPageDirty
until commit_write time.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/fs/libfs.c
===================================================================
--- linux-2.6.orig/fs/libfs.c
+++ linux-2.6/fs/libfs.c
@@ -327,25 +327,32 @@ int simple_readpage(struct file *file, s
 int simple_prepare_write(struct file *file, struct page *page,
 			unsigned from, unsigned to)
 {
-	if (!PageUptodate(page)) {
-		if (to - from != PAGE_CACHE_SIZE) {
-			void *kaddr = kmap_atomic(page, KM_USER0);
-			memset(kaddr, 0, from);
-			memset(kaddr + to, 0, PAGE_CACHE_SIZE - to);
-			flush_dcache_page(page);
-			kunmap_atomic(kaddr, KM_USER0);
-		}
+	if (PageUptodate(page))
+		return 0;
+
+	if (to - from != PAGE_CACHE_SIZE) {
+		/*
+		 * Partial-page write? Initialise the complete page and
+		 * set it uptodate. We could avoid initialising the
+		 * (from, to) hole, and opt to mark it uptodate in
+		 * simple_commit_write, but that's probably only a win
+		 * for filesystems that would need to read blocks off disk.
+		 */
+		memclear_highpage_flush(page, 0, PAGE_CACHE_SIZE);
 		SetPageUptodate(page);
 	}
+
 	return 0;
 }
 
 int simple_commit_write(struct file *file, struct page *page,
-			unsigned offset, unsigned to)
+			unsigned from, unsigned to)
 {
 	struct inode *inode = page->mapping->host;
 	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
 
+	if (to - from == PAGE_CACHE_SIZE)
+		SetPageUptodate(page);
 	/*
 	 * No need to use i_size_read() here, the i_size
 	 * cannot change under us because we hold the i_mutex.
@@ -353,6 +360,7 @@ int simple_commit_write(struct file *fil
 	if (pos > inode->i_size)
 		i_size_write(inode, pos);
 	set_page_dirty(page);
+
 	return 0;
 }
 
Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -2344,17 +2344,6 @@ int nobh_prepare_write(struct page *page
 
 	if (is_mapped_to_disk)
 		SetPageMappedToDisk(page);
-	SetPageUptodate(page);
-
-	/*
-	 * Setting the page dirty here isn't necessary for the prepare_write
-	 * function - commit_write will do that.  But if/when this function is
-	 * used within the pagefault handler to ensure that all mmapped pages
-	 * have backing space in the filesystem, we will need to dirty the page
-	 * if its contents were altered.
-	 */
-	if (dirtied_it)
-		set_page_dirty(page);
 
 	return 0;
 
@@ -2384,6 +2373,7 @@ int nobh_commit_write(struct file *file,
 	struct inode *inode = page->mapping->host;
 	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
 
+	SetPageUptodate(page);
 	set_page_dirty(page);
 	if (pos > inode->i_size) {
 		i_size_write(inode, pos);
Index: linux-2.6/Documentation/filesystems/vfs.txt
===================================================================
--- linux-2.6.orig/Documentation/filesystems/vfs.txt
+++ linux-2.6/Documentation/filesystems/vfs.txt
@@ -617,6 +617,11 @@ struct address_space_operations {
 	In this case the prepare_write will be retried one the lock is
   	regained.
 
+	Note: the page _must not_ be marked uptodate in this function
+	(or anywhere else) unless it actually is uptodate right now. As
+	soon as a page is marked uptodate, it is possible for a concurrent
+	read(2) to copy it to userspace.
+
   commit_write: If prepare_write succeeds, new data will be copied
         into the page and then commit_write will be called.  It will
         typically update the size of the file (if appropriate) and

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
