Date: Sat, 3 Feb 2007 03:09:26 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/9] fs: libfs buffered write leak fix
Message-ID: <20070203020926.GD27300@wotan.suse.de>
References: <20070129081905.23584.97878.sendpatchset@linux.site> <20070129081914.23584.23886.sendpatchset@linux.site> <20070202155236.dae54aa2.akpm@linux-foundation.org> <20070203013316.GB27300@wotan.suse.de> <20070202175801.3f97f79b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070202175801.3f97f79b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 02, 2007 at 05:58:01PM -0800, Andrew Morton wrote:
> On Sat, 3 Feb 2007 02:33:16 +0100
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > I think just setting page uptodate in commit_write might do the
> > trick? (and getting rid of the set_page_dirty there).
> 
> Yes, the page just isn't uptodate yet in prepare_write() - moving things
> to commti_write() sounds sane.
> 
> But please, can we have sufficient changelogs and comments in the next version?

You're right, sorry. Is this any better? (warning: nobh code is untested)

--
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
