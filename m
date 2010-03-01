From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 12/16] readahead: dont do start-of-file readahead after lseek()
Date: Mon, 01 Mar 2010 13:27:03 +0800
Message-ID: <20100301053621.946764025@intel.com>
References: <20100301052651.857984880@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1NlyLP-0005J8-Va
	for glkm-linux-mm-2@m.gmane.org; Mon, 01 Mar 2010 06:39:04 +0100
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1EE526B0092
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 00:38:58 -0500 (EST)
Content-Disposition: inline; filename=readahead-lseek.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Matt Mackall <mpm@selenic.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
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

Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Linus Torvalds <torvalds@linux-foundation.org> 
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/read_write.c    |    3 +++
 include/linux/fs.h |    1 +
 mm/readahead.c     |    5 +++++
 3 files changed, 9 insertions(+)

--- linux.orig/mm/readahead.c	2010-03-01 13:23:45.000000000 +0800
+++ linux/mm/readahead.c	2010-03-01 13:23:45.000000000 +0800
@@ -670,6 +670,11 @@ ondemand_readahead(struct address_space 
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
--- linux.orig/fs/read_write.c	2010-03-01 13:21:43.000000000 +0800
+++ linux/fs/read_write.c	2010-03-01 13:23:45.000000000 +0800
@@ -71,6 +71,9 @@ generic_file_llseek_unlocked(struct file
 		file->f_version = 0;
 	}
 
+	if (!(file->f_ra.ra_flags & READAHEAD_LSEEK))
+		file->f_ra.ra_flags |= READAHEAD_LSEEK;
+
 	return offset;
 }
 EXPORT_SYMBOL(generic_file_llseek_unlocked);
--- linux.orig/include/linux/fs.h	2010-03-01 13:23:42.000000000 +0800
+++ linux/include/linux/fs.h	2010-03-01 13:23:45.000000000 +0800
@@ -899,6 +899,7 @@ struct file_ra_state {
 #define	READAHEAD_MMAP_MISS	0x00000fff /* cache misses for mmap access */
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
