Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9ABFC6B0055
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 08:26:17 -0500 (EST)
Message-Id: <20111129131456.925952168@intel.com>
Date: Tue, 29 Nov 2011 21:09:08 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 8/9] readahead: basic support for backwards prefetching
References: <20111129130900.628549879@intel.com>
Content-Disposition: inline; filename=readahead-backwards.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Li Shaohua <shaohua.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Add the backwards prefetching feature. It's pretty simple if we don't
support async prefetching and interleaved reads.

Here is the behavior with an 8-page read sequence from 10000 down to 0.
(The readahead size is a bit large since it's an NFS mount.)

readahead-random(dev=0:16, ino=3948605, req=10000+8, ra=10000+8-0, async=0) = 8
readahead-backwards(dev=0:16, ino=3948605, req=9992+8, ra=9968+32-0, async=0) = 32
readahead-backwards(dev=0:16, ino=3948605, req=9960+8, ra=9840+128-0, async=0) = 128
readahead-backwards(dev=0:16, ino=3948605, req=9832+8, ra=9584+256-0, async=0) = 256
readahead-backwards(dev=0:16, ino=3948605, req=9576+8, ra=9072+512-0, async=0) = 512
readahead-backwards(dev=0:16, ino=3948605, req=9064+8, ra=8048+1024-0, async=0) = 1024
readahead-backwards(dev=0:16, ino=3948605, req=8040+8, ra=6128+1920-0, async=0) = 1920
readahead-backwards(dev=0:16, ino=3948605, req=6120+8, ra=4208+1920-0, async=0) = 1920
readahead-backwards(dev=0:16, ino=3948605, req=4200+8, ra=2288+1920-0, async=0) = 1920
readahead-backwards(dev=0:16, ino=3948605, req=2280+8, ra=368+1920-0, async=0) = 1920
readahead-backwards(dev=0:16, ino=3948605, req=360+8, ra=0+368-0, async=0) = 368

And a simple 1-page read sequence from 10000 down to 0.

readahead-random(dev=0:16, ino=3948605, req=10000+1, ra=10000+1-0, async=0) = 1
readahead-backwards(dev=0:16, ino=3948605, req=9999+1, ra=9996+4-0, async=0) = 4
readahead-backwards(dev=0:16, ino=3948605, req=9995+1, ra=9980+16-0, async=0) = 16
readahead-backwards(dev=0:16, ino=3948605, req=9979+1, ra=9916+64-0, async=0) = 64
readahead-backwards(dev=0:16, ino=3948605, req=9915+1, ra=9660+256-0, async=0) = 256
readahead-backwards(dev=0:16, ino=3948605, req=9659+1, ra=9148+512-0, async=0) = 512
readahead-backwards(dev=0:16, ino=3948605, req=9147+1, ra=8124+1024-0, async=0) = 1024
readahead-backwards(dev=0:16, ino=3948605, req=8123+1, ra=6204+1920-0, async=0) = 1920
readahead-backwards(dev=0:16, ino=3948605, req=6203+1, ra=4284+1920-0, async=0) = 1920
readahead-backwards(dev=0:16, ino=3948605, req=4283+1, ra=2364+1920-0, async=0) = 1920
readahead-backwards(dev=0:16, ino=3948605, req=2363+1, ra=444+1920-0, async=0) = 1920
readahead-backwards(dev=0:16, ino=3948605, req=443+1, ra=0+444-0, async=0) = 444

CC: Andi Kleen <andi@firstfloor.org>
CC: Li Shaohua <shaohua.li@intel.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/fs.h |    2 ++
 mm/readahead.c     |   15 +++++++++++++++
 2 files changed, 17 insertions(+)

--- linux-next.orig/include/linux/fs.h	2011-11-29 20:55:27.000000000 +0800
+++ linux-next/include/linux/fs.h	2011-11-29 20:57:07.000000000 +0800
@@ -968,6 +968,7 @@ struct file_ra_state {
  *				streams.
  * RA_PATTERN_MMAP_AROUND	read-around on mmap page faults
  *				(w/o any sequential/random hints)
+ * RA_PATTERN_BACKWARDS		reverse reading detected
  * RA_PATTERN_FADVISE		triggered by POSIX_FADV_WILLNEED or FMODE_RANDOM
  * RA_PATTERN_OVERSIZE		a random read larger than max readahead size,
  *				do max readahead to break down the read size
@@ -978,6 +979,7 @@ enum readahead_pattern {
 	RA_PATTERN_SUBSEQUENT,
 	RA_PATTERN_CONTEXT,
 	RA_PATTERN_MMAP_AROUND,
+	RA_PATTERN_BACKWARDS,
 	RA_PATTERN_FADVISE,
 	RA_PATTERN_OVERSIZE,
 	RA_PATTERN_RANDOM,
--- linux-next.orig/mm/readahead.c	2011-11-29 20:57:03.000000000 +0800
+++ linux-next/mm/readahead.c	2011-11-29 20:57:07.000000000 +0800
@@ -23,6 +23,7 @@ static const char * const ra_pattern_nam
 	[RA_PATTERN_SUBSEQUENT]         = "subsequent",
 	[RA_PATTERN_CONTEXT]            = "context",
 	[RA_PATTERN_MMAP_AROUND]        = "around",
+	[RA_PATTERN_BACKWARDS]          = "backwards",
 	[RA_PATTERN_FADVISE]            = "fadvise",
 	[RA_PATTERN_OVERSIZE]           = "oversize",
 	[RA_PATTERN_RANDOM]             = "random",
@@ -676,6 +677,20 @@ ondemand_readahead(struct address_space 
 	}
 
 	/*
+	 * backwards reading
+	 */
+	if (offset < ra->start && offset + req_size >= ra->start) {
+		ra->pattern = RA_PATTERN_BACKWARDS;
+		ra->size = get_next_ra_size(ra, max);
+		max = ra->start;
+		if (ra->size > max)
+			ra->size = max;
+		ra->async_size = 0;
+		ra->start -= ra->size;
+		goto readit;
+	}
+
+	/*
 	 * Query the page cache and look for the traces(cached history pages)
 	 * that a sequential stream would leave behind.
 	 */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
