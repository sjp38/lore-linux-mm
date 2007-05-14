Message-Id: <20070514060650.076653000@wotan.suse.de>
References: <20070514060619.689648000@wotan.suse.de>
Date: Mon, 14 May 2007 16:06:20 +1000
From: npiggin@suse.de
Subject: [patch 01/41] mm: revert KERNEL_DS buffered write optimisation
Content-Disposition: inline; filename=mm-revert-nfsd-writev-opt.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

Revert the patch from Neil Brown to optimise NFSD writev handling.

Cc: Linux Memory Management <linux-mm@kvack.org>
Cc: Linux Filesystems <linux-fsdevel@vger.kernel.org>
Cc: Neil Brown <neilb@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>

 mm/filemap.c |   32 +++++++++++++-------------------
 1 file changed, 13 insertions(+), 19 deletions(-)

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -1936,27 +1936,21 @@ generic_file_buffered_write(struct kiocb
 		/* Limit the size of the copy to the caller's write size */
 		bytes = min(bytes, count);
 
-		/* We only need to worry about prefaulting when writes are from
-		 * user-space.  NFSd uses vfs_writev with several non-aligned
-		 * segments in the vector, and limiting to one segment a time is
-		 * a noticeable performance for re-write
+		/*
+		 * Limit the size of the copy to that of the current segment,
+		 * because fault_in_pages_readable() doesn't know how to walk
+		 * segments.
 		 */
-		if (!segment_eq(get_fs(), KERNEL_DS)) {
-			/*
-			 * Limit the size of the copy to that of the current
-			 * segment, because fault_in_pages_readable() doesn't
-			 * know how to walk segments.
-			 */
-			bytes = min(bytes, cur_iov->iov_len - iov_base);
+		bytes = min(bytes, cur_iov->iov_len - iov_base);
+
+		/*
+		 * Bring in the user page that we will copy from _first_.
+		 * Otherwise there's a nasty deadlock on copying from the
+		 * same page as we're writing to, without it being marked
+		 * up-to-date.
+		 */
+		fault_in_pages_readable(buf, bytes);
 
-			/*
-			 * Bring in the user page that we will copy from
-			 * _first_.  Otherwise there's a nasty deadlock on
-			 * copying from the same page as we're writing to,
-			 * without it being marked up-to-date.
-			 */
-			fault_in_pages_readable(buf, bytes);
-		}
 		page = __grab_cache_page(mapping,index,&cached_page,&lru_pvec);
 		if (!page) {
 			status = -ENOMEM;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
