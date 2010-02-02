From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 10/11] readahead: dont do start-of-file readahead after lseek()
Date: Tue, 02 Feb 2010 23:28:45 +0800
Message-ID: <20100202153317.644170708@intel.com>
References: <20100202152835.683907822@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1NcKlm-0003oz-RG
	for glkm-linux-mm-2@m.gmane.org; Tue, 02 Feb 2010 16:34:27 +0100
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2E0916B007D
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 10:34:20 -0500 (EST)
Content-Disposition: inline; filename=readahead-lseek.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

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

CC: Linus Torvalds <torvalds@linux-foundation.org> 
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/read_write.c    |    3 +++
 include/linux/fs.h |    1 +
 mm/readahead.c     |    5 +++++
 3 files changed, 9 insertions(+)

--- linux.orig/mm/readahead.c	2010-02-02 21:52:19.000000000 +0800
+++ linux/mm/readahead.c	2010-02-02 21:52:32.000000000 +0800
@@ -625,6 +625,11 @@ ondemand_readahead(struct address_space 
 	if (!offset) {
 		ra_set_pattern(ra, RA_PATTERN_INITIAL);
 		ra->start = offset;
+		if ((ra->ra_flags & READAHEAD_LSEEK) && req_size <= max) {
+			ra->size = req_size;
+			ra->async_size = 0;
+			goto readit;
+		}
 		ra->size = get_init_ra_size(req_size, max);
 		ra->async_size = ra->size > req_size ?
 				 ra->size - req_size : ra->size;
--- linux.orig/fs/read_write.c	2010-02-02 21:50:51.000000000 +0800
+++ linux/fs/read_write.c	2010-02-02 21:53:04.000000000 +0800
@@ -71,6 +71,9 @@ generic_file_llseek_unlocked(struct file
 		file->f_version = 0;
 	}
 
+	if (!(file->f_ra.ra_flags & READAHEAD_LSEEK))
+		file->f_ra.ra_flags |= READAHEAD_LSEEK;
+
 	return offset;
 }
 EXPORT_SYMBOL(generic_file_llseek_unlocked);
--- linux.orig/include/linux/fs.h	2010-02-02 21:52:19.000000000 +0800
+++ linux/include/linux/fs.h	2010-02-02 21:52:19.000000000 +0800
@@ -899,6 +899,7 @@ struct file_ra_state {
 #define	READAHEAD_MMAP_MISS	0x0000ffff /* cache misses for mmap access */
 #define READAHEAD_THRASHED	0x10000000
 #define	READAHEAD_MMAP		0x20000000
+#define	READAHEAD_LSEEK		0x40000000 /* be conservative after lseek() */
 
 /*
  * Which policy makes decision to do the current read-ahead IO?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
