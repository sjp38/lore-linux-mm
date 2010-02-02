From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 07/11] readahead: record readahead patterns
Date: Tue, 02 Feb 2010 23:28:42 +0800
Message-ID: <20100202153317.227922645@intel.com>
References: <20100202152835.683907822@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1NcKll-0003of-OA
	for glkm-linux-mm-2@m.gmane.org; Tue, 02 Feb 2010 16:34:26 +0100
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 918096B0078
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 10:34:18 -0500 (EST)
Content-Disposition: inline; filename=readahead-tracepoints.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Record the readahead pattern in ra_flags. This info can be examined by
users via the readahead tracing/stats interfaces.

Currently 7 patterns are defined:

      	pattern			readahead for
-----------------------------------------------------------
	RA_PATTERN_INITIAL	start-of-file/oversize read
	RA_PATTERN_SUBSEQUENT	trivial     sequential read
	RA_PATTERN_CONTEXT	interleaved sequential read
	RA_PATTERN_THRASH	thrashed    sequential read
	RA_PATTERN_MMAP_AROUND	mmap fault
	RA_PATTERN_FADVISE	posix_fadvise()
	RA_PATTERN_RANDOM	random read

CC: Ingo Molnar <mingo@elte.hu> 
CC: Jens Axboe <jens.axboe@oracle.com> 
CC: Peter Zijlstra <a.p.zijlstra@chello.nl> 
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/fs.h |   32 ++++++++++++++++++++++++++++++++
 include/linux/mm.h |    4 +++-
 mm/filemap.c       |    9 +++++++--
 mm/readahead.c     |   17 +++++++++++++----
 4 files changed, 55 insertions(+), 7 deletions(-)

--- linux.orig/include/linux/fs.h	2010-02-02 21:50:52.000000000 +0800
+++ linux/include/linux/fs.h	2010-02-02 21:51:59.000000000 +0800
@@ -894,8 +894,40 @@ struct file_ra_state {
 };
 
 /* ra_flags bits */
+#define READAHEAD_PATTERN_SHIFT	20
+#define READAHEAD_PATTERN	0x00f00000
 #define	READAHEAD_MMAP_MISS	0x0000ffff /* cache misses for mmap access */
 #define READAHEAD_THRASHED	0x10000000
+#define	READAHEAD_MMAP		0x20000000
+
+/*
+ * Which policy makes decision to do the current read-ahead IO?
+ */
+enum readahead_pattern {
+	RA_PATTERN_INITIAL,
+	RA_PATTERN_SUBSEQUENT,
+	RA_PATTERN_CONTEXT,
+	RA_PATTERN_THRASH,
+	RA_PATTERN_MMAP_AROUND,
+	RA_PATTERN_FADVISE,
+	RA_PATTERN_RANDOM,
+	RA_PATTERN_ALL,		/* for summary stats */
+	RA_PATTERN_MAX
+};
+
+static inline int ra_pattern(int ra_flags)
+{
+	int pattern = (ra_flags & READAHEAD_PATTERN)
+			       >> READAHEAD_PATTERN_SHIFT;
+
+	return min(pattern, RA_PATTERN_ALL);
+}
+
+static inline void ra_set_pattern(struct file_ra_state *ra, int pattern)
+{
+	ra->ra_flags = (ra->ra_flags & ~READAHEAD_PATTERN) |
+			    (pattern << READAHEAD_PATTERN_SHIFT);
+}
 
 /*
  * Don't do ra_flags++ directly to avoid possible overflow:
--- linux.orig/mm/readahead.c	2010-02-02 21:51:53.000000000 +0800
+++ linux/mm/readahead.c	2010-02-02 21:52:01.000000000 +0800
@@ -291,7 +291,10 @@ unsigned long max_sane_readahead(unsigne
  * Submit IO for the read-ahead request in file_ra_state.
  */
 unsigned long ra_submit(struct file_ra_state *ra,
-		       struct address_space *mapping, struct file *filp)
+			struct address_space *mapping,
+			struct file *filp,
+			pgoff_t offset,
+			unsigned long req_size)
 {
 	int actual;
 
@@ -425,6 +428,7 @@ ondemand_readahead(struct address_space 
 	 * start of file
 	 */
 	if (!offset) {
+		ra_set_pattern(ra, RA_PATTERN_INITIAL);
 		ra->start = offset;
 		ra->size = get_init_ra_size(req_size, max);
 		ra->async_size = ra->size > req_size ?
@@ -445,6 +449,7 @@ ondemand_readahead(struct address_space 
 	 */
 	if ((offset == (ra->start + ra->size - ra->async_size) ||
 	     offset == (ra->start + ra->size))) {
+		ra_set_pattern(ra, RA_PATTERN_SUBSEQUENT);
 		ra->start += ra->size;
 		ra->size = get_next_ra_size(ra, max);
 		ra->async_size = ra->size;
@@ -455,6 +460,7 @@ ondemand_readahead(struct address_space 
 	 * oversize read, no need to query page cache
 	 */
 	if (req_size > max && !hit_readahead_marker) {
+		ra_set_pattern(ra, RA_PATTERN_INITIAL);
 		ra->start = offset;
 		ra->size = max;
 		ra->async_size = max;
@@ -500,8 +506,10 @@ context_readahead:
 	 */
 	if (!size && !hit_readahead_marker) {
 		if (!ra_thrashed(ra, offset)) {
+			ra_set_pattern(ra, RA_PATTERN_RANDOM);
 			ra->size = min(req_size, max);
 		} else {
+			ra_set_pattern(ra, RA_PATTERN_THRASH);
 			retain_inactive_pages(mapping, offset, min(2 * max,
 						ra->start + ra->size - offset));
 			ra->size = max_t(int, ra->size/2, MIN_READAHEAD_PAGES);
@@ -518,12 +526,13 @@ context_readahead:
 	if (size >= offset)
 		size *= 2;
 	/*
-	 * pages to readahead are already cached
+	 * Pages to readahead are already cached?
 	 */
 	if (size <= start - offset)
 		return 0;
-
 	size -= start - offset;
+
+	ra_set_pattern(ra, RA_PATTERN_CONTEXT);
 	ra->start = start;
 	ra->size = clamp_t(unsigned int, size, MIN_READAHEAD_PAGES, max);
 	ra->async_size = min(ra->size, 1 + size / READAHEAD_ASYNC_RATIO);
@@ -539,7 +548,7 @@ readit:
 		ra->size += ra->async_size;
 	}
 
-	return ra_submit(ra, mapping, filp);
+	return ra_submit(ra, mapping, filp, offset, req_size);
 }
 
 /**
--- linux.orig/include/linux/mm.h	2010-02-02 21:50:52.000000000 +0800
+++ linux/include/linux/mm.h	2010-02-02 21:51:59.000000000 +0800
@@ -1209,7 +1209,9 @@ void page_cache_async_readahead(struct a
 unsigned long max_sane_readahead(unsigned long nr);
 unsigned long ra_submit(struct file_ra_state *ra,
 			struct address_space *mapping,
-			struct file *filp);
+			struct file *filp,
+			pgoff_t offset,
+			unsigned long req_size);
 
 /* Do stack extension */
 extern int expand_stack(struct vm_area_struct *vma, unsigned long address);
--- linux.orig/mm/filemap.c	2010-02-02 21:50:52.000000000 +0800
+++ linux/mm/filemap.c	2010-02-02 21:51:59.000000000 +0800
@@ -1413,6 +1413,7 @@ static void do_sync_mmap_readahead(struc
 
 	if (VM_SequentialReadHint(vma) ||
 			offset - 1 == (ra->prev_pos >> PAGE_CACHE_SHIFT)) {
+		ra->ra_flags |= READAHEAD_MMAP;
 		page_cache_sync_readahead(mapping, ra, file, offset,
 					  ra->ra_pages);
 		return;
@@ -1431,10 +1432,12 @@ static void do_sync_mmap_readahead(struc
 	 */
 	ra_pages = max_sane_readahead(ra->ra_pages);
 	if (ra_pages) {
+		ra->ra_flags |= READAHEAD_MMAP;
+		ra_set_pattern(ra, RA_PATTERN_MMAP_AROUND);
 		ra->start = max_t(long, 0, offset - ra_pages/2);
 		ra->size = ra_pages;
 		ra->async_size = 0;
-		ra_submit(ra, mapping, file);
+		ra_submit(ra, mapping, file, offset, 1);
 	}
 }
 
@@ -1454,9 +1457,11 @@ static void do_async_mmap_readahead(stru
 	if (VM_RandomReadHint(vma))
 		return;
 	ra_mmap_miss_dec(ra);
-	if (PageReadahead(page))
+	if (PageReadahead(page)) {
+		ra->ra_flags |= READAHEAD_MMAP;
 		page_cache_async_readahead(mapping, ra, file,
 					   page, offset, ra->ra_pages);
+	}
 }
 
 /**


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
