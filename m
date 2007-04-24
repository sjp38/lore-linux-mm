Message-Id: <20070424013432.115048000@suse.de>
References: <20070424012346.696840000@suse.de>
Date: Tue, 24 Apr 2007 11:23:48 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 02/44] Revert 81b0c8713385ce1b1b9058e916edcf9561ad76d6
Content-Disposition: inline; filename=mm-revert-buffered-write-zero-length-iov.patch
Sender: owner-linux-mm@kvack.org
From: Andrew Morton <akpm@osdl.org>
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Filesystems <linux-fsdevel@vger.kernel.org>, Mark Fasheh <mark.fasheh@oracle.com>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

This was a bugfix against 6527c2bdf1f833cc18e8f42bd97973d583e4aa83, which we
also revert.

Cc: Linux Memory Management <linux-mm@kvack.org>
Cc: Linux Filesystems <linux-fsdevel@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
Signed-off-by: Nick Piggin <npiggin@suse.de>

 mm/filemap.c |    9 +--------
 mm/filemap.h |    4 ++--
 2 files changed, 3 insertions(+), 10 deletions(-)

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -2001,12 +2001,6 @@ generic_file_buffered_write(struct kiocb
 			break;
 		}
 
-		if (unlikely(bytes == 0)) {
-			status = 0;
-			copied = 0;
-			goto zero_length_segment;
-		}
-
 		status = a_ops->prepare_write(file, page, offset, offset+bytes);
 		if (unlikely(status)) {
 			loff_t isize = i_size_read(inode);
@@ -2036,8 +2030,7 @@ generic_file_buffered_write(struct kiocb
 			page_cache_release(page);
 			continue;
 		}
-zero_length_segment:
-		if (likely(copied >= 0)) {
+		if (likely(copied > 0)) {
 			if (!status)
 				status = copied;
 
Index: linux-2.6/mm/filemap.h
===================================================================
--- linux-2.6.orig/mm/filemap.h
+++ linux-2.6/mm/filemap.h
@@ -87,7 +87,7 @@ filemap_set_next_iovec(const struct iove
 	const struct iovec *iov = *iovp;
 	size_t base = *basep;
 
-	do {
+	while (bytes) {
 		int copy = min(bytes, iov->iov_len - base);
 
 		bytes -= copy;
@@ -96,7 +96,7 @@ filemap_set_next_iovec(const struct iove
 			iov++;
 			base = 0;
 		}
-	} while (bytes);
+	}
 	*iovp = iov;
 	*basep = base;
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
