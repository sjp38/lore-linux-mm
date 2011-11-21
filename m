Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3C21E6B0074
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 04:40:59 -0500 (EST)
Message-Id: <20111121093846.510441032@intel.com>
Date: Mon, 21 Nov 2011 17:18:23 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 4/8] readahead: record readahead patterns
References: <20111121091819.394895091@intel.com>
Content-Disposition: inline; filename=readahead-tracepoints.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

Record the readahead pattern in ra_flags and extend the ra_submit()
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
CC: Jens Axboe <jens.axboe@oracle.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/fs.h |   33 +++++++++++++++++++++++++++++++++
 include/linux/mm.h |    4 +++-
 mm/filemap.c       |    9 +++++++--
 mm/readahead.c     |   30 +++++++++++++++++++++++-------
 4 files changed, 66 insertions(+), 10 deletions(-)

--- linux-next.orig/include/linux/fs.h	2011-11-20 20:10:48.000000000 +0800
+++ linux-next/include/linux/fs.h	2011-11-20 20:18:29.000000000 +0800
@@ -951,6 +951,39 @@ struct file_ra_state {
 
 /* ra_flags bits */
 #define	READAHEAD_MMAP_MISS	0x000003ff /* cache misses for mmap access */
+#define	READAHEAD_MMAP		0x00010000
+
+#define READAHEAD_PATTERN_SHIFT	28
+#define READAHEAD_PATTERN	0xf0000000
+
+/*
+ * Which policy makes decision to do the current read-ahead IO?
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
+static inline unsigned int ra_pattern(unsigned int ra_flags)
+{
+	unsigned int pattern = ra_flags >> READAHEAD_PATTERN_SHIFT;
+
+	return min_t(unsigned int, pattern, RA_PATTERN_ALL);
+}
+
+static inline void ra_set_pattern(struct file_ra_state *ra,
+				  unsigned int pattern)
+{
+	ra->ra_flags = (ra->ra_flags & ~READAHEAD_PATTERN) |
+			    (pattern << READAHEAD_PATTERN_SHIFT);
+}
 
 /*
  * Don't do ra_flags++ directly to avoid possible overflow:
--- linux-next.orig/mm/readahead.c	2011-11-20 20:10:48.000000000 +0800
+++ linux-next/mm/readahead.c	2011-11-20 20:18:14.000000000 +0800
@@ -268,13 +268,17 @@ unsigned long max_sane_readahead(unsigne
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
 
 	actual = __do_page_cache_readahead(mapping, filp,
 					ra->start, ra->size, ra->async_size);
 
+	ra->ra_flags &= ~READAHEAD_MMAP;
 	return actual;
 }
 
@@ -401,6 +405,7 @@ static int try_context_readahead(struct 
 	if (size >= offset)
 		size *= 2;
 
+	ra_set_pattern(ra, RA_PATTERN_CONTEXT);
 	ra->start = offset;
 	ra->size = get_init_ra_size(size + req_size, max);
 	ra->async_size = ra->size;
@@ -422,8 +427,10 @@ ondemand_readahead(struct address_space 
 	/*
 	 * start of file
 	 */
-	if (!offset)
+	if (!offset) {
+		ra_set_pattern(ra, RA_PATTERN_INITIAL);
 		goto initial_readahead;
+	}
 
 	/*
 	 * It's the expected callback offset, assume sequential access.
@@ -431,6 +438,7 @@ ondemand_readahead(struct address_space 
 	 */
 	if ((offset == (ra->start + ra->size - ra->async_size) ||
 	     offset == (ra->start + ra->size))) {
+		ra_set_pattern(ra, RA_PATTERN_SUBSEQUENT);
 		ra->start += ra->size;
 		ra->size = get_next_ra_size(ra, max);
 		ra->async_size = ra->size;
@@ -453,6 +461,7 @@ ondemand_readahead(struct address_space 
 		if (!start || start - offset > max)
 			return 0;
 
+		ra_set_pattern(ra, RA_PATTERN_CONTEXT);
 		ra->start = start;
 		ra->size = start - offset;	/* old async_size */
 		ra->size += req_size;
@@ -464,14 +473,18 @@ ondemand_readahead(struct address_space 
 	/*
 	 * oversize read
 	 */
-	if (req_size > max)
+	if (req_size > max) {
+		ra_set_pattern(ra, RA_PATTERN_OVERSIZE);
 		goto initial_readahead;
+	}
 
 	/*
 	 * sequential cache miss
 	 */
-	if (offset - (ra->prev_pos >> PAGE_CACHE_SHIFT) <= 1UL)
+	if (offset - (ra->prev_pos >> PAGE_CACHE_SHIFT) <= 1UL) {
+		ra_set_pattern(ra, RA_PATTERN_INITIAL);
 		goto initial_readahead;
+	}
 
 	/*
 	 * Query the page cache and look for the traces(cached history pages)
@@ -482,9 +495,12 @@ ondemand_readahead(struct address_space 
 
 	/*
 	 * standalone, small random read
-	 * Read as is, and do not pollute the readahead state.
 	 */
-	return __do_page_cache_readahead(mapping, filp, offset, req_size, 0);
+	ra_set_pattern(ra, RA_PATTERN_RANDOM);
+	ra->start = offset;
+	ra->size = req_size;
+	ra->async_size = 0;
+	goto readit;
 
 initial_readahead:
 	ra->start = offset;
@@ -502,7 +518,7 @@ readit:
 		ra->size += ra->async_size;
 	}
 
-	return ra_submit(ra, mapping, filp);
+	return ra_submit(ra, mapping, filp, offset, req_size);
 }
 
 /**
--- linux-next.orig/include/linux/mm.h	2011-11-20 20:10:48.000000000 +0800
+++ linux-next/include/linux/mm.h	2011-11-20 20:10:49.000000000 +0800
@@ -1456,7 +1456,9 @@ void page_cache_async_readahead(struct a
 unsigned long max_sane_readahead(unsigned long nr);
 unsigned long ra_submit(struct file_ra_state *ra,
 			struct address_space *mapping,
-			struct file *filp);
+			struct file *filp,
+			pgoff_t offset,
+			unsigned long req_size);
 
 /* Generic expand stack which grows the stack according to GROWS{UP,DOWN} */
 extern int expand_stack(struct vm_area_struct *vma, unsigned long address);
--- linux-next.orig/mm/filemap.c	2011-11-20 20:10:48.000000000 +0800
+++ linux-next/mm/filemap.c	2011-11-20 20:10:49.000000000 +0800
@@ -1592,6 +1592,7 @@ static void do_sync_mmap_readahead(struc
 		return;
 
 	if (VM_SequentialReadHint(vma)) {
+		ra->ra_flags |= READAHEAD_MMAP;
 		page_cache_sync_readahead(mapping, ra, file, offset,
 					  ra->ra_pages);
 		return;
@@ -1607,11 +1608,13 @@ static void do_sync_mmap_readahead(struc
 	/*
 	 * mmap read-around
 	 */
+	ra->ra_flags |= READAHEAD_MMAP;
+	ra_set_pattern(ra, RA_PATTERN_MMAP_AROUND);
 	ra_pages = max_sane_readahead(ra->ra_pages);
 	ra->start = max_t(long, 0, offset - ra_pages / 2);
 	ra->size = ra_pages;
 	ra->async_size = ra_pages / 4;
-	ra_submit(ra, mapping, file);
+	ra_submit(ra, mapping, file, offset, 1);
 }
 
 /*
@@ -1630,9 +1633,11 @@ static void do_async_mmap_readahead(stru
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
