From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 06/11] readahead: thrashing safe context readahead
Date: Sun, 07 Feb 2010 12:10:19 +0800
Message-ID: <20100207041043.584619057@intel.com>
References: <20100207041013.891441102@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1NdyXL-0000Va-Py
	for glkm-linux-mm-2@m.gmane.org; Sun, 07 Feb 2010 05:14:20 +0100
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8274F6B0078
	for <linux-mm@kvack.org>; Sat,  6 Feb 2010 23:14:11 -0500 (EST)
Content-Disposition: inline; filename=readahead-thrashing-safe-mode.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Wu Fengguang <fengguang.wu@intel.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Introduce a more complete version of context readahead, which is a
full-fledged readahead algorithm by itself. It replaces some of the
existing cases.

- oversize read
  no behavior change; except in thrashed mode, async_size will be 0
- random read
  no behavior change; implies some different internal handling
  The random read will now be recorded in file_ra_state, which means in
  an intermixed sequential+random pattern, the sequential part's state
  will be flushed by random ones, and hence will be serviced by the
  context readahead instead of the stateful one. Also means that the
  first readahead for a sequential read in the middle of file will be
  started by the stateful one, instead of the sequential cache miss.
- sequential cache miss
  better
  When walking out of a cached page segment, the readahead size will
  be fully restored immediately instead of ramping up from initial size.
- hit readahead marker without valid state
  better in rare cases; costs more radix tree lookups, but won't be a
  problem with optimized radix_tree_prev_hole().  The added radix tree
  scan for history pages is to calculate the thrashing safe readahead
  size and adaptive async size.

The algorithm first looks ahead to find the start point of next
read-ahead, then looks backward in the page cache to get an estimation
of the thrashing-threshold.

It is able to automatically adapt to the thrashing threshold in a smooth
workload.  The estimation theory can be illustrated with figure:

   chunk A           chunk B                      chunk C                 head

   l01 l11           l12   l21                    l22
| |-->|-->|       |------>|-->|                |------>|
| +-------+       +-----------+                +-------------+               |
| |   #   |       |       #   |                |       #     |               |
| +-------+       +-----------+                +-------------+               |
| |<==============|<===========================|<============================|
        L0                     L1                            L2

 Let f(l) = L be a map from
     l: the number of pages read by the stream
 to
     L: the number of pages pushed into inactive_list in the mean time
 then
     f(l01) <= L0
     f(l11 + l12) = L1
     f(l21 + l22) = L2
     ...
     f(l01 + l11 + ...) <= Sum(L0 + L1 + ...)
                        <= Length(inactive_list) = f(thrashing-threshold)

So the count of continuous history pages left in inactive_list is always a
lower estimation of the true thrashing-threshold. Given a stable workload,
the readahead size will keep ramping up and then stabilize in range

	(thrashing_threshold/2, thrashing_threshold)

This is good because, it's in fact bad to always reach thrashing_threshold.
That would not only be more susceptible to fluctuations, but also impose
eviction pressure to the cached pages.

To demo the thrashing safety, I run 300 200KB/s streams with mem=128M.

Only 2031/61325=3.3% readahead windows are thrashed (due to workload
fluctuation):

# cat /debug/readahead/stats
pattern     readahead    eof_hit  cache_hit         io    sync_io    mmap_io       size async_size    io_size
initial            20          9          4         20         20         12         73         37         35
subsequent          3          3          0          1          0          1          8          8          1
context         61325          1       5479      61325       6788          5         14          2         13
thrash           2031          0       1222       2031       2031          0          9          0          6
around            235         90        142        235        235        235         60          0         19
fadvise             0          0          0          0          0          0          0          0          0
random            223        133          0         91         91          1          1          0          1
all             63837        236       6847      63703       9165          0         14          2         13

And the readahead inside a single stream is working as expected:

# grep streams-3162 /debug/tracing/trace
         streams-3162  [000]  8602.455953: readahead: readahead-context(dev=0:2, ino=0, req=287352+1, ra=287354+10-2, async=1) = 10
         streams-3162  [000]  8602.907873: readahead: readahead-context(dev=0:2, ino=0, req=287362+1, ra=287364+20-3, async=1) = 20
         streams-3162  [000]  8604.027879: readahead: readahead-context(dev=0:2, ino=0, req=287381+1, ra=287384+14-2, async=1) = 14
         streams-3162  [000]  8604.754722: readahead: readahead-context(dev=0:2, ino=0, req=287396+1, ra=287398+10-2, async=1) = 10
         streams-3162  [000]  8605.191228: readahead: readahead-context(dev=0:2, ino=0, req=287406+1, ra=287408+18-3, async=1) = 18
         streams-3162  [000]  8606.831895: readahead: readahead-context(dev=0:2, ino=0, req=287423+1, ra=287426+12-2, async=1) = 12
         streams-3162  [000]  8606.919614: readahead: readahead-thrash(dev=0:2, ino=0, req=287425+1, ra=287425+8-0, async=0) = 1
         streams-3162  [000]  8607.545016: readahead: readahead-context(dev=0:2, ino=0, req=287436+1, ra=287438+9-2, async=1) = 9
         streams-3162  [000]  8607.960039: readahead: readahead-context(dev=0:2, ino=0, req=287445+1, ra=287447+18-3, async=1) = 18
         streams-3162  [000]  8608.790973: readahead: readahead-context(dev=0:2, ino=0, req=287462+1, ra=287465+21-3, async=1) = 21
         streams-3162  [000]  8609.763138: readahead: readahead-context(dev=0:2, ino=0, req=287483+1, ra=287486+15-2, async=1) = 15
         streams-3162  [000]  8611.467401: readahead: readahead-context(dev=0:2, ino=0, req=287499+1, ra=287501+11-2, async=1) = 11
         streams-3162  [000]  8642.512413: readahead: readahead-context(dev=0:2, ino=0, req=288053+1, ra=288056+10-2, async=1) = 10
         streams-3162  [000]  8643.246618: readahead: readahead-context(dev=0:2, ino=0, req=288064+1, ra=288066+22-3, async=1) = 22
         streams-3162  [000]  8644.278613: readahead: readahead-context(dev=0:2, ino=0, req=288085+1, ra=288088+16-3, async=1) = 16
         streams-3162  [000]  8644.395782: readahead: readahead-context(dev=0:2, ino=0, req=288087+1, ra=288087+21-3, async=0) = 5
         streams-3162  [000]  8645.109918: readahead: readahead-context(dev=0:2, ino=0, req=288101+1, ra=288108+8-1, async=1) = 8
         streams-3162  [000]  8645.285078: readahead: readahead-context(dev=0:2, ino=0, req=288105+1, ra=288116+8-1, async=1) = 8
         streams-3162  [000]  8645.731794: readahead: readahead-context(dev=0:2, ino=0, req=288115+1, ra=288122+14-2, async=1) = 13
         streams-3162  [000]  8646.114250: readahead: readahead-context(dev=0:2, ino=0, req=288123+1, ra=288136+8-1, async=1) = 8
         streams-3162  [000]  8646.626320: readahead: readahead-context(dev=0:2, ino=0, req=288134+1, ra=288144+16-3, async=1) = 16
         streams-3162  [000]  8647.035721: readahead: readahead-context(dev=0:2, ino=0, req=288143+1, ra=288160+10-2, async=1) = 10
         streams-3162  [000]  8647.693082: readahead: readahead-context(dev=0:2, ino=0, req=288157+1, ra=288165+12-2, async=1) = 8
         streams-3162  [000]  8648.221368: readahead: readahead-context(dev=0:2, ino=0, req=288168+1, ra=288177+15-2, async=1) = 15
         streams-3162  [000]  8649.280800: readahead: readahead-context(dev=0:2, ino=0, req=288190+1, ra=288192+23-3, async=1) = 23
	 [...]

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/fs.h |    1 
 mm/readahead.c     |  155 ++++++++++++++++++++++++-------------------
 2 files changed, 88 insertions(+), 68 deletions(-)

--- linux.orig/mm/readahead.c	2010-02-07 11:46:35.000000000 +0800
+++ linux/mm/readahead.c	2010-02-07 11:46:39.000000000 +0800
@@ -20,6 +20,11 @@
 #include <linux/pagemap.h>
 
 /*
+ * Set async size to 1/# of the thrashing threshold.
+ */
+#define READAHEAD_ASYNC_RATIO	8
+
+/*
  * Initialise a struct file's readahead state.  Assumes that the caller has
  * memset *ra to zero.
  */
@@ -393,39 +398,16 @@ static pgoff_t count_history_pages(struc
 }
 
 /*
- * page cache context based read-ahead
+ * Is @index recently readahead but not yet read by application?
+ * The low boundary is permissively estimated.
  */
-static int try_context_readahead(struct address_space *mapping,
-				 struct file_ra_state *ra,
-				 pgoff_t offset,
-				 unsigned long req_size,
-				 unsigned long max)
+static bool ra_thrashed(struct file_ra_state *ra, pgoff_t index)
 {
-	pgoff_t size;
-
-	size = count_history_pages(mapping, ra, offset, max);
-
-	/*
-	 * no history pages:
-	 * it could be a random read
-	 */
-	if (!size)
-		return 0;
-
-	/*
-	 * starts from beginning of file:
-	 * it is a strong indication of long-run stream (or whole-file-read)
-	 */
-	if (size >= offset)
-		size *= 2;
-
-	ra->start = offset;
-	ra->size = get_init_ra_size(size + req_size, max);
-	ra->async_size = ra->size;
-
-	return 1;
+	return (index >= ra->start - ra->size &&
+		index <  ra->start + ra->size);
 }
 
+
 /*
  * A minimal readahead algorithm for trivial sequential/random reads.
  */
@@ -436,12 +418,26 @@ ondemand_readahead(struct address_space 
 		   unsigned long req_size)
 {
 	unsigned long max = max_sane_readahead(ra->ra_pages);
+	unsigned int size;
+	pgoff_t start;
 
 	/*
 	 * start of file
 	 */
-	if (!offset)
-		goto initial_readahead;
+	if (!offset) {
+		ra->start = offset;
+		ra->size = get_init_ra_size(req_size, max);
+		ra->async_size = ra->size > req_size ?
+				 ra->size - req_size : ra->size;
+		goto readit;
+	}
+
+	/*
+	 * Context readahead is thrashing safe, and can adapt to near the
+	 * thrashing threshold given a stable workload.
+	 */
+	if (ra->ra_flags & READAHEAD_THRASHED)
+		goto context_readahead;
 
 	/*
 	 * It's the expected callback offset, assume sequential access.
@@ -456,58 +452,81 @@ ondemand_readahead(struct address_space 
 	}
 
 	/*
-	 * Hit a marked page without valid readahead state.
-	 * E.g. interleaved reads.
-	 * Query the pagecache for async_size, which normally equals to
-	 * readahead size. Ramp it up and use it as the new readahead size.
+	 * oversize read, no need to query page cache
 	 */
-	if (hit_readahead_marker) {
-		pgoff_t start;
+	if (req_size > max && !hit_readahead_marker) {
+		ra->start = offset;
+		ra->size = max;
+		ra->async_size = max;
+		goto readit;
+	}
 
+	/*
+	 * page cache context based read-ahead
+	 *
+	 *     ==========================_____________..............
+	 *                          [ current window ]
+	 *                               ^offset
+	 * 1)                            |---- A ---->[start
+	 * 2) |<----------- H -----------|
+	 * 3)                            |----------- H ----------->]end
+	 *                                            [ new window ]
+	 *    [=] cached,visited [_] cached,to-be-visited [.] not cached
+	 *
+	 * 1) A = pages ahead = previous async_size
+	 * 2) H = history pages = thrashing safe size
+	 * 3) H - A = new readahead size
+	 */
+context_readahead:
+	if (hit_readahead_marker) {
 		rcu_read_lock();
-		start = radix_tree_next_hole(&mapping->page_tree, offset+1,max);
+		start = radix_tree_next_hole(&mapping->page_tree,
+					     offset + 1, max);
 		rcu_read_unlock();
-
+		/*
+		 * there are enough pages ahead: no readahead
+		 */
 		if (!start || start - offset > max)
 			return 0;
+	} else
+		start = offset;
 
+	size = count_history_pages(mapping, ra, offset,
+				   READAHEAD_ASYNC_RATIO * max);
+	/*
+	 * no history pages cached, could be
+	 * 	- a random read
+	 * 	- a thrashed sequential read
+	 */
+	if (!size && !hit_readahead_marker) {
+		if (!ra_thrashed(ra, offset)) {
+			ra->size = min(req_size, max);
+		} else {
+			retain_inactive_pages(mapping, offset, min(2 * max,
+						ra->start + ra->size - offset));
+			ra->size = max_t(int, ra->size/2, MIN_READAHEAD_PAGES);
+			ra->ra_flags |= READAHEAD_THRASHED;
+		}
+		ra->async_size = 0;
 		ra->start = start;
-		ra->size = start - offset;	/* old async_size */
-		ra->size += req_size;
-		ra->size = get_next_ra_size(ra, max);
-		ra->async_size = ra->size;
 		goto readit;
 	}
-
 	/*
-	 * oversize read
+	 * history pages start from beginning of file:
+	 * it is a strong indication of long-run stream (or whole-file reads)
 	 */
-	if (req_size > max)
-		goto initial_readahead;
-
-	/*
-	 * sequential cache miss
-	 */
-	if (offset - (ra->prev_pos >> PAGE_CACHE_SHIFT) <= 1UL)
-		goto initial_readahead;
-
-	/*
-	 * Query the page cache and look for the traces(cached history pages)
-	 * that a sequential stream would leave behind.
-	 */
-	if (try_context_readahead(mapping, ra, offset, req_size, max))
-		goto readit;
-
+	if (size >= offset)
+		size *= 2;
 	/*
-	 * standalone, small random read
-	 * Read as is, and do not pollute the readahead state.
+	 * pages to readahead are already cached
 	 */
-	return __do_page_cache_readahead(mapping, filp, offset, req_size, 0);
+	if (size <= start - offset)
+		return 0;
 
-initial_readahead:
-	ra->start = offset;
-	ra->size = get_init_ra_size(req_size, max);
-	ra->async_size = ra->size > req_size ? ra->size - req_size : ra->size;
+	size -= start - offset;
+	ra->start = start;
+	ra->size = clamp_t(unsigned int, size, MIN_READAHEAD_PAGES, max);
+	ra->async_size = min(ra->size, 1 + size / READAHEAD_ASYNC_RATIO);
 
 readit:
 	/*
--- linux.orig/include/linux/fs.h	2010-02-07 11:46:37.000000000 +0800
+++ linux/include/linux/fs.h	2010-02-07 11:46:39.000000000 +0800
@@ -898,6 +898,7 @@ struct file_ra_state {
 
 /* ra_flags bits */
 #define	READAHEAD_MMAP_MISS	0x0000ffff /* cache misses for mmap access */
+#define READAHEAD_THRASHED	0x10000000
 
 /*
  * Don't do ra_flags++ directly to avoid possible overflow:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
