Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AF85C6B006C
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 04:40:58 -0500 (EST)
Message-Id: <20111121093847.015852579@intel.com>
Date: Mon, 21 Nov 2011 17:18:27 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 8/8] readahead: dont do start-of-file readahead after lseek()
References: <20111121091819.394895091@intel.com>
Content-Disposition: inline; filename=readahead-lseek.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

Some applications (eg. blkid, id3tool etc.) seek around the file
to get information. For example, blkid does

	     seek to	0
	     read	1024
	     seek to	1536
	     read	16384

The start-of-file readahead heuristic is wrong for them, whose
access pattern can be identified by lseek() calls.

So test-and-set a READAHEAD_LSEEK flag on lseek() and don't
do start-of-file readahead on seeing it. Proposed by Linus.

Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/read_write.c    |    4 ++++
 include/linux/fs.h |    1 +
 mm/readahead.c     |    3 +++
 3 files changed, 8 insertions(+)

--- linux-next.orig/mm/readahead.c	2011-11-20 22:02:01.000000000 +0800
+++ linux-next/mm/readahead.c	2011-11-20 22:02:03.000000000 +0800
@@ -629,6 +629,8 @@ ondemand_readahead(struct address_space 
 	 * start of file
 	 */
 	if (!offset) {
+		if ((ra->ra_flags & READAHEAD_LSEEK) && req_size < max)
+			goto random_read;
 		ra_set_pattern(ra, RA_PATTERN_INITIAL);
 		goto initial_readahead;
 	}
@@ -707,6 +709,7 @@ ondemand_readahead(struct address_space 
 	if (try_context_readahead(mapping, ra, offset, req_size, max))
 		goto readit;
 
+random_read:
 	/*
 	 * standalone, small random read
 	 */
--- linux-next.orig/fs/read_write.c	2011-11-20 22:02:01.000000000 +0800
+++ linux-next/fs/read_write.c	2011-11-20 22:02:03.000000000 +0800
@@ -47,6 +47,10 @@ static loff_t lseek_execute(struct file 
 		file->f_pos = offset;
 		file->f_version = 0;
 	}
+
+	if (!(file->f_ra.ra_flags & READAHEAD_LSEEK))
+		file->f_ra.ra_flags |= READAHEAD_LSEEK;
+
 	return offset;
 }
 
--- linux-next.orig/include/linux/fs.h	2011-11-20 22:02:01.000000000 +0800
+++ linux-next/include/linux/fs.h	2011-11-20 22:02:03.000000000 +0800
@@ -952,6 +952,7 @@ struct file_ra_state {
 /* ra_flags bits */
 #define	READAHEAD_MMAP_MISS	0x000003ff /* cache misses for mmap access */
 #define	READAHEAD_MMAP		0x00010000
+#define	READAHEAD_LSEEK		0x00020000 /* be conservative after lseek() */
 
 #define READAHEAD_PATTERN_SHIFT	28
 #define READAHEAD_PATTERN	0xf0000000


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
