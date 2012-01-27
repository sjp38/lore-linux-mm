Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 1BCB76B0088
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 22:40:42 -0500 (EST)
Message-Id: <20120127031326.619964905@intel.com>
Date: Fri, 27 Jan 2012 11:05:26 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 2/9] readahead: record readahead patterns
References: <20120127030524.854259561@intel.com>
Content-Disposition: inline; filename=readahead-tracepoints.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Record the readahead pattern in ra->pattern and extend ra_submit()
parameters, to be used by the next readahead tracing/stats patches.

7 patterns are defined:

      	pattern			readahead for
-----------------------------------------------------------
	RA_PATTERN_INITIAL	start-of-file read
	RA_PATTERN_SUBSEQUENT	trivial sequential read
	RA_PATTERN_CONTEXT	interleaved sequential read
	RA_PATTERN_OVERSIZE	oversize read
	RA_PATTERN_MMAP_AROUND	mmap fault
	RA_PATTERN_FADVISE	posix_fadvise()
	RA_PATTERN_RANDOM	random read

Note that random reads will be recorded in file_ra_state now.
This won't deteriorate cache bouncing because the ra->prev_pos update
in do_generic_file_read() already pollutes the data cache, and
filemap_fault() will stop calling into us after MMAP_LOTSAMISS.

CC: Ingo Molnar <mingo@elte.hu>
CC: Jens Axboe <axboe@kernel.dk>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Acked-by: Jan Kara <jack@suse.cz>
Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/fs.h |   36 +++++++++++++++++++++++++++++++++++-
 include/linux/mm.h |    4 +++-
 mm/filemap.c       |    3 ++-
 mm/readahead.c     |   29 ++++++++++++++++++++++-------
 4 files changed, 62 insertions(+), 10 deletions(-)

--- linux-next.orig/include/linux/fs.h	2012-01-25 15:57:47.000000000 +0800
+++ linux-next/include/linux/fs.h	2012-01-25 15:57:50.000000000 +0800
@@ -952,11 +952,45 @@ struct file_ra_state {
 					   there are only # of pages ahead */
 
 	unsigned int ra_pages;		/* Maximum readahead window */
-	unsigned int mmap_miss;		/* Cache miss stat for mmap accesses */
+	u16 mmap_miss;			/* Cache miss stat for mmap accesses */
+	u8 pattern;			/* one of RA_PATTERN_* */
+
 	loff_t prev_pos;		/* Cache last read() position */
 };
 
 /*
+ * Which policy makes decision to do the current read-ahead IO?
+ *
+ * RA_PATTERN_INITIAL		readahead window is initially opened,
+ *				normally when reading from start of file
+ * RA_PATTERN_SUBSEQUENT	readahead window is pushed forward
+ * RA_PATTERN_CONTEXT		no readahead window available, querying the
+ *				page cache to decide readahead start/size.
+ *				This typically happens on interleaved reads (eg.
+ *				reading pages 0, 1000, 1, 1001, 2, 1002, ...)
+ *				where one file_ra_state struct is not enough
+ *				for recording 2+ interleaved sequential read
+ *				streams.
+ * RA_PATTERN_MMAP_AROUND	read-around on mmap page faults
+ *				(w/o any sequential/random hints)
+ * RA_PATTERN_FADVISE		triggered by POSIX_FADV_WILLNEED or FMODE_RANDOM
+ * RA_PATTERN_OVERSIZE		a random read larger than max readahead size,
+ *				do max readahead to break down the read size
+ * RA_PATTERN_RANDOM		a small random read
+ */
+enum readahead_pattern {
+	RA_PATTERN_INITIAL,
+	RA_PATTERN_SUBSEQUENT,
+	RA_PATTERN_CONTEXT,
+	RA_PATTERN_MMAP_AROUND,
+	RA_PATTERN_FADVISE,
+	RA_PATTERN_OVERSIZE,
+	RA_PATTERN_RANDOM,
+	RA_PATTERN_ALL,		/* for summary stats */
+	RA_PATTERN_MAX
+};
+
+/*
  * Check if @index falls in the readahead windows.
  */
 static inline int ra_has_index(struct file_ra_state *ra, pgoff_t index)
--- linux-next.orig/mm/readahead.c	2012-01-25 15:57:49.000000000 +0800
+++ linux-next/mm/readahead.c	2012-01-25 15:57:50.000000000 +0800
@@ -249,7 +249,10 @@ unsigned long max_sane_readahead(unsigne
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
 
@@ -382,6 +385,7 @@ static int try_context_readahead(struct 
 	if (size >= offset)
 		size *= 2;
 
+	ra->pattern = RA_PATTERN_CONTEXT;
 	ra->start = offset;
 	ra->size = min(size + req_size, max);
 	ra->async_size = 1;
@@ -403,8 +407,10 @@ ondemand_readahead(struct address_space 
 	/*
 	 * start of file
 	 */
-	if (!offset)
+	if (!offset) {
+		ra->pattern = RA_PATTERN_INITIAL;
 		goto initial_readahead;
+	}
 
 	/*
 	 * It's the expected callback offset, assume sequential access.
@@ -412,6 +418,7 @@ ondemand_readahead(struct address_space 
 	 */
 	if ((offset == (ra->start + ra->size - ra->async_size) ||
 	     offset == (ra->start + ra->size))) {
+		ra->pattern = RA_PATTERN_SUBSEQUENT;
 		ra->start += ra->size;
 		ra->size = get_next_ra_size(ra, max);
 		ra->async_size = ra->size;
@@ -434,6 +441,7 @@ ondemand_readahead(struct address_space 
 		if (!start || start - offset > max)
 			return 0;
 
+		ra->pattern = RA_PATTERN_CONTEXT;
 		ra->start = start;
 		ra->size = start - offset;	/* old async_size */
 		ra->size += req_size;
@@ -445,14 +453,18 @@ ondemand_readahead(struct address_space 
 	/*
 	 * oversize read
 	 */
-	if (req_size > max)
+	if (req_size > max) {
+		ra->pattern = RA_PATTERN_OVERSIZE;
 		goto initial_readahead;
+	}
 
 	/*
 	 * sequential cache miss
 	 */
-	if (offset - (ra->prev_pos >> PAGE_CACHE_SHIFT) <= 1UL)
+	if (offset - (ra->prev_pos >> PAGE_CACHE_SHIFT) <= 1UL) {
+		ra->pattern = RA_PATTERN_INITIAL;
 		goto initial_readahead;
+	}
 
 	/*
 	 * Query the page cache and look for the traces(cached history pages)
@@ -463,9 +475,12 @@ ondemand_readahead(struct address_space 
 
 	/*
 	 * standalone, small random read
-	 * Read as is, and do not pollute the readahead state.
 	 */
-	return __do_page_cache_readahead(mapping, filp, offset, req_size, 0);
+	ra->pattern = RA_PATTERN_RANDOM;
+	ra->start = offset;
+	ra->size = req_size;
+	ra->async_size = 0;
+	goto readit;
 
 initial_readahead:
 	ra->start = offset;
@@ -483,7 +498,7 @@ readit:
 		ra->size += ra->async_size;
 	}
 
-	return ra_submit(ra, mapping, filp);
+	return ra_submit(ra, mapping, filp, offset, req_size);
 }
 
 /**
--- linux-next.orig/include/linux/mm.h	2012-01-25 15:57:47.000000000 +0800
+++ linux-next/include/linux/mm.h	2012-01-25 15:57:50.000000000 +0800
@@ -1448,7 +1448,9 @@ void page_cache_async_readahead(struct a
 unsigned long max_sane_readahead(unsigned long nr);
 unsigned long ra_submit(struct file_ra_state *ra,
 			struct address_space *mapping,
-			struct file *filp);
+			struct file *filp,
+			pgoff_t offset,
+			unsigned long req_size);
 
 /* Generic expand stack which grows the stack according to GROWS{UP,DOWN} */
 extern int expand_stack(struct vm_area_struct *vma, unsigned long address);
--- linux-next.orig/mm/filemap.c	2012-01-25 15:57:47.000000000 +0800
+++ linux-next/mm/filemap.c	2012-01-25 15:57:50.000000000 +0800
@@ -1597,11 +1597,12 @@ static void do_sync_mmap_readahead(struc
 	/*
 	 * mmap read-around
 	 */
+	ra->pattern = RA_PATTERN_MMAP_AROUND;
 	ra_pages = max_sane_readahead(ra->ra_pages);
 	ra->start = max_t(long, 0, offset - ra_pages / 2);
 	ra->size = ra_pages;
 	ra->async_size = ra_pages / 4;
-	ra_submit(ra, mapping, file);
+	ra_submit(ra, mapping, file, offset, 1);
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
