Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C8A8B6B005C
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 08:26:16 -0500 (EST)
Message-Id: <20111129131456.405886521@intel.com>
Date: Tue, 29 Nov 2011 21:09:04 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 4/9] readahead: tag mmap page fault call sites
References: <20111129130900.628549879@intel.com>
Content-Disposition: inline; filename=readahead-for-mmap
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Introduce a bit field ra->for_mmap for tagging mmap reads.
The tag will be cleared immediate after submitting the IO.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/fs.h |    1 +
 mm/filemap.c       |    6 +++++-
 mm/readahead.c     |    1 +
 3 files changed, 7 insertions(+), 1 deletion(-)

--- linux-next.orig/include/linux/fs.h	2011-11-29 10:12:19.000000000 +0800
+++ linux-next/include/linux/fs.h	2011-11-29 10:13:08.000000000 +0800
@@ -947,6 +947,7 @@ struct file_ra_state {
 	unsigned int ra_pages;		/* Maximum readahead window */
 	u16 mmap_miss;			/* Cache miss stat for mmap accesses */
 	u8 pattern;			/* one of RA_PATTERN_* */
+	unsigned int for_mmap:1;	/* readahead for mmap accesses */
 
 	loff_t prev_pos;		/* Cache last read() position */
 };
--- linux-next.orig/mm/filemap.c	2011-11-29 09:48:49.000000000 +0800
+++ linux-next/mm/filemap.c	2011-11-29 10:13:08.000000000 +0800
@@ -1592,6 +1592,7 @@ static void do_sync_mmap_readahead(struc
 		return;
 
 	if (VM_SequentialReadHint(vma)) {
+		ra->for_mmap = 1;
 		page_cache_sync_readahead(mapping, ra, file, offset,
 					  ra->ra_pages);
 		return;
@@ -1611,6 +1612,7 @@ static void do_sync_mmap_readahead(struc
 	/*
 	 * mmap read-around
 	 */
+	ra->for_mmap = 1;
 	ra->pattern = RA_PATTERN_MMAP_AROUND;
 	ra_pages = max_sane_readahead(ra->ra_pages);
 	ra->start = max_t(long, 0, offset - ra_pages / 2);
@@ -1636,9 +1638,11 @@ static void do_async_mmap_readahead(stru
 		return;
 	if (ra->mmap_miss > 0)
 		ra->mmap_miss--;
-	if (PageReadahead(page))
+	if (PageReadahead(page)) {
+		ra->for_mmap = 1;
 		page_cache_async_readahead(mapping, ra, file,
 					   page, offset, ra->ra_pages);
+	}
 }
 
 /**
--- linux-next.orig/mm/readahead.c	2011-11-29 09:48:49.000000000 +0800
+++ linux-next/mm/readahead.c	2011-11-29 10:13:08.000000000 +0800
@@ -267,6 +267,7 @@ unsigned long ra_submit(struct file_ra_s
 	actual = __do_page_cache_readahead(mapping, filp,
 					ra->start, ra->size, ra->async_size);
 
+	ra->for_mmap = 0;
 	return actual;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
