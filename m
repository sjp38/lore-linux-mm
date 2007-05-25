Message-Id: <20070524053155.220551000@linux.local0.net>
References: <20070524052844.860329000@suse.de>
Date: Fri, 25 May 2007 22:21:57 +1000
From: npiggin@suse.de
Subject: [patch 13/41] mm: restore KERNEL_DS optimisations
Content-Disposition: inline; filename=fs-kernel_ds-opt.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, Mark Fasheh <mark.fasheh@oracle.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Restore the KERNEL_DS optimisation, especially helpful to the 2copy write
path.

This may be a pretty questionable gain in most cases, especially after the
legacy 2copy write path is removed, but it doesn't cost much.

Cc: Linux Memory Management <linux-mm@kvack.org>
Cc: Linux Filesystems <linux-fsdevel@vger.kernel.org>
Signed-off-by: Nick Piggin <npiggin@suse.de>

 mm/filemap.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -2123,7 +2123,7 @@ static ssize_t generic_perform_write_2co
 		 * cannot take a pagefault with the destination page locked.
 		 * So pin the source page to copy it.
 		 */
-		if (!PageUptodate(page)) {
+		if (!PageUptodate(page) && !segment_eq(get_fs(), KERNEL_DS)) {
 			unlock_page(page);
 
 			src_page = alloc_page(GFP_KERNEL);
@@ -2248,6 +2248,13 @@ static ssize_t generic_perform_write(str
 	const struct address_space_operations *a_ops = mapping->a_ops;
 	long status = 0;
 	ssize_t written = 0;
+	unsigned int flags = 0;
+
+	/*
+	 * Copies from kernel address space cannot fail (NFSD is a big user).
+	 */
+	if (segment_eq(get_fs(), KERNEL_DS))
+		flags |= AOP_FLAG_UNINTERRUPTIBLE;
 
 	do {
 		struct page *page;
@@ -2279,7 +2286,7 @@ again:
 			break;
 		}
 
-		status = a_ops->write_begin(file, mapping, pos, bytes, 0,
+		status = a_ops->write_begin(file, mapping, pos, bytes, flags,
 						&page, &fsdata);
 		if (unlikely(status))
 			break;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
