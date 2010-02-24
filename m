From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 06/15] readahead: replace ra->mmap_miss with ra->ra_flags
Date: Wed, 24 Feb 2010 11:10:07 +0800
Message-ID: <20100224031054.449606633@intel.com>
References: <20100224031001.026464755@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Nk7fa-0006BH-9o
	for glkm-linux-mm-2@m.gmane.org; Wed, 24 Feb 2010 04:12:14 +0100
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 75A036B0047
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 22:12:07 -0500 (EST)
Content-Disposition: inline; filename=readahead-flags.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Steven Whitehouse <swhiteho@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Matt Mackall <mpm@selenic.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Introduce a readahead flags field and embed the existing mmap_miss in it
(mainly to save space).

It also changes the mmap_miss upper bound from LONG_MAX to 4096.
This is to help adapt properly for changing mmap access patterns.

It will be possible to lose the flags in race conditions, however the
impact should be limited.  For the race to happen, there must be two
threads sharing the same file descriptor to be in page fault or
readahead at the same time.

Note that it has always been racy for "page faults" at the same time.

And if ever the race happen, we'll lose one mmap_miss++ or mmap_miss--.
Which may change some concrete readahead behavior, but won't really
impact overall I/O performance.

CC: Nick Piggin <npiggin@suse.de>
CC: Andi Kleen <andi@firstfloor.org>
CC: Steven Whitehouse <swhiteho@redhat.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/fs.h |   30 +++++++++++++++++++++++++++++-
 mm/filemap.c       |    7 ++-----
 2 files changed, 31 insertions(+), 6 deletions(-)

--- linux.orig/include/linux/fs.h	2010-02-24 10:44:30.000000000 +0800
+++ linux/include/linux/fs.h	2010-02-24 10:44:43.000000000 +0800
@@ -889,10 +889,38 @@ struct file_ra_state {
 					   there are only # of pages ahead */
 
 	unsigned int ra_pages;		/* Maximum readahead window */
-	unsigned int mmap_miss;		/* Cache miss stat for mmap accesses */
+	unsigned int ra_flags;
 	loff_t prev_pos;		/* Cache last read() position */
 };
 
+/* ra_flags bits */
+#define	READAHEAD_MMAP_MISS	0x00000fff /* cache misses for mmap access */
+
+/*
+ * Don't do ra_flags++ directly to avoid possible overflow:
+ * the ra fields can be accessed concurrently in a racy way.
+ */
+static inline unsigned int ra_mmap_miss_inc(struct file_ra_state *ra)
+{
+	unsigned int miss = ra->ra_flags & READAHEAD_MMAP_MISS;
+
+	if (miss < READAHEAD_MMAP_MISS) {
+		miss++;
+		ra->ra_flags = miss | (ra->ra_flags &~ READAHEAD_MMAP_MISS);
+	}
+	return miss;
+}
+
+static inline void ra_mmap_miss_dec(struct file_ra_state *ra)
+{
+	unsigned int miss = ra->ra_flags & READAHEAD_MMAP_MISS;
+
+	if (miss) {
+		miss--;
+		ra->ra_flags = miss | (ra->ra_flags &~ READAHEAD_MMAP_MISS);
+	}
+}
+
 /*
  * Check if @index falls in the readahead windows.
  */
--- linux.orig/mm/filemap.c	2010-02-24 10:44:25.000000000 +0800
+++ linux/mm/filemap.c	2010-02-24 10:44:43.000000000 +0800
@@ -1418,14 +1418,12 @@ static void do_sync_mmap_readahead(struc
 		return;
 	}
 
-	if (ra->mmap_miss < INT_MAX)
-		ra->mmap_miss++;
 
 	/*
 	 * Do we miss much more than hit in this file? If so,
 	 * stop bothering with read-ahead. It will only hurt.
 	 */
-	if (ra->mmap_miss > MMAP_LOTSAMISS)
+	if (ra_mmap_miss_inc(ra) > MMAP_LOTSAMISS)
 		return;
 
 	/*
@@ -1455,8 +1453,7 @@ static void do_async_mmap_readahead(stru
 	/* If we don't want any read-ahead, don't bother */
 	if (VM_RandomReadHint(vma))
 		return;
-	if (ra->mmap_miss > 0)
-		ra->mmap_miss--;
+	ra_mmap_miss_dec(ra);
 	if (PageReadahead(page))
 		page_cache_async_readahead(mapping, ra, file,
 					   page, offset, ra->ra_pages);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
