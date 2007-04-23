From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070423064927.5458.93496.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com>
References: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 08/16] Variable Order Page Cache: Fixup fallback functions
Date: Sun, 22 Apr 2007 23:49:27 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: William Lee Irwin III <wli@holomorphy.com>, Badari Pulavarty <pbadari@gmail.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Adam Litke <aglitke@gmail.com>, Christoph Lameter <clameter@sgi.com>, Dave Hansen <hansendc@us.ibm.com>, Mel Gorman <mel@skynet.ie>, Avi Kivity <avi@argo.co.il>
List-ID: <linux-mm.kvack.org>

Variable Order Page Cache: Fixup fallback functions

Fixup the fallback function in fs/libfs.c to be able to handle
higher order page cache pages.

FIXME: There is a use of kmap here that we leave unchanged
(none of my testing platforms use highmem). There needs to
be some way to clear higher order partial pages if a platform
supports HIGHMEM.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/libfs.c |   19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

Index: linux-2.6.21-rc7/fs/libfs.c
===================================================================
--- linux-2.6.21-rc7.orig/fs/libfs.c	2007-04-22 17:28:04.000000000 -0700
+++ linux-2.6.21-rc7/fs/libfs.c	2007-04-22 17:38:58.000000000 -0700
@@ -320,8 +320,8 @@ int simple_rename(struct inode *old_dir,
 
 int simple_readpage(struct file *file, struct page *page)
 {
-	clear_highpage(page);
-	flush_dcache_page(page);
+	clear_mapping_page(page);
+	flush_mapping_page(page);
 	SetPageUptodate(page);
 	unlock_page(page);
 	return 0;
@@ -331,11 +331,15 @@ int simple_prepare_write(struct file *fi
 			unsigned from, unsigned to)
 {
 	if (!PageUptodate(page)) {
-		if (to - from != PAGE_CACHE_SIZE) {
+		if (to - from != page_cache_size(file->f_mapping)) {
+			/*
+			 * Mapping to higher order pages need to be supported
+			 * if higher order pages can be in highmem
+			 */
 			void *kaddr = kmap_atomic(page, KM_USER0);
 			memset(kaddr, 0, from);
-			memset(kaddr + to, 0, PAGE_CACHE_SIZE - to);
-			flush_dcache_page(page);
+			memset(kaddr + to, 0, page_cache_size(file->f_mapping) - to);
+			flush_mapping_page(page);
 			kunmap_atomic(kaddr, KM_USER0);
 		}
 	}
@@ -345,8 +349,9 @@ int simple_prepare_write(struct file *fi
 int simple_commit_write(struct file *file, struct page *page,
 			unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
-	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
+	struct address_space *mapping = page->mapping;
+	struct inode *inode = mapping->host;
+	loff_t pos = page_cache_pos(mapping, page->index, to);
 
 	if (!PageUptodate(page))
 		SetPageUptodate(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
