From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 04/11] readahead: replace ra->mmap_miss with ra->ra_flags
Date: Tue, 02 Feb 2010 23:28:39 +0800
Message-ID: <20100202153316.793651196@intel.com>
References: <20100202152835.683907822@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=readahead-flags.patch
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Steven Whitehouse <swhiteho@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Introduce a readahead flags field and embed the existing mmap_miss in it
(to save space).

It will be possible to lose the flags in race conditions, however the
impact should be limited.

CC: Nick Piggin <npiggin@suse.de>
CC: Andi Kleen <andi@firstfloor.org>
CC: Steven Whitehouse <swhiteho@redhat.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/fs.h |   30 +++++++++++++++++++++++++++++-
 mm/filemap.c       |    7 ++-----
 2 files changed, 31 insertions(+), 6 deletions(-)

--- linux.orig/include/linux/fs.h	2010-01-30 18:09:33.000000000 +0800
+++ linux/include/linux/fs.h	2010-01-30 18:10:04.000000000 +0800
@@ -889,10 +889,38 @@ struct file_ra_state {
 					   there are only # of pages ahead */
 
 	unsigned int ra_pages;		/* Maximum readahead window */
-	unsigned int mmap_miss;		/* Cache miss stat for mmap accesses */
+	unsigned int ra_flags;
 	loff_t prev_pos;		/* Cache last read() position */
 };
 
+/* ra_flags bits */
+#define	READAHEAD_MMAP_MISS	0x0000ffff /* cache misses for mmap access */
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
--- linux.orig/mm/filemap.c	2010-01-30 18:09:33.000000000 +0800
+++ linux/mm/filemap.c	2010-01-30 18:10:04.000000000 +0800
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
