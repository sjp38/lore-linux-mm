Date: Tue, 25 Nov 2008 21:46:56 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 8/9] swapfile: swapon randomize if nonrot
In-Reply-To: <Pine.LNX.4.64.0811252140230.17555@blonde.site>
Message-ID: <Pine.LNX.4.64.0811252146090.20455@blonde.site>
References: <Pine.LNX.4.64.0811252132580.17555@blonde.site>
 <Pine.LNX.4.64.0811252140230.17555@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Woodhouse <dwmw2@infradead.org>, Jens Axboe <jens.axboe@oracle.com>, Matthew Wilcox <matthew@wil.cx>, Joern Engel <joern@logfs.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, Donjun Shin <djshin90@gmail.com>, Tejun Heo <teheo@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Swap allocation has always started from the beginning of the swap area;
but if we're dealing with a solidstate swap device which can only remap
blocks within limited zones, that would sooner wear out the first zone.

Therefore sys_swapon() test whether blk_queue is non-rotational,
and if so randomize the cluster_next starting position for allocation.

If blk_queue is nonrot, note SWP_SOLIDSTATE for later use, and report it
with an "SS" at the right end of the kernel's "Adding ... swap" message
(so that if it's both nonrot and discardable, "SSD" will be shown there).
Perhaps something should be shown in /proc/swaps (swapon -s), but we
have to be more cautious before making any addition to that format.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
But how to get my SD card, accessed by USB card reader, reported as NONROT?

 include/linux/swap.h |    1 +
 mm/swapfile.c        |   11 +++++++++--
 2 files changed, 10 insertions(+), 2 deletions(-)

--- swapfile7/include/linux/swap.h	2008-11-25 12:41:40.000000000 +0000
+++ swapfile8/include/linux/swap.h	2008-11-25 12:41:42.000000000 +0000
@@ -122,6 +122,7 @@ enum {
 	SWP_WRITEOK	= (1 << 1),	/* ok to write to this swap?	*/
 	SWP_DISCARDABLE = (1 << 2),	/* blkdev supports discard */
 	SWP_DISCARDING	= (1 << 3),	/* now discarding a free cluster */
+	SWP_SOLIDSTATE	= (1 << 4),	/* blkdev seeks are cheap */
 					/* add others here before... */
 	SWP_SCANNING	= (1 << 8),	/* refcount in scan_swap_map */
 };
--- swapfile7/mm/swapfile.c	2008-11-25 12:41:40.000000000 +0000
+++ swapfile8/mm/swapfile.c	2008-11-25 12:41:42.000000000 +0000
@@ -16,6 +16,7 @@
 #include <linux/namei.h>
 #include <linux/shm.h>
 #include <linux/blkdev.h>
+#include <linux/random.h>
 #include <linux/writeback.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -1797,6 +1798,11 @@ asmlinkage long sys_swapon(const char __
 		goto bad_swap;
 	}
 
+	if (blk_queue_nonrot(bdev_get_queue(p->bdev))) {
+		p->flags |= SWP_SOLIDSTATE;
+		srandom32((u32)get_seconds());
+		p->cluster_next = 1 + (random32() % p->highest_bit);
+	}
 	if (discard_swap(p) == 0)
 		p->flags |= SWP_DISCARDABLE;
 
@@ -1813,10 +1819,11 @@ asmlinkage long sys_swapon(const char __
 	total_swap_pages += nr_good_pages;
 
 	printk(KERN_INFO "Adding %uk swap on %s.  "
-			"Priority:%d extents:%d across:%lluk%s\n",
+			"Priority:%d extents:%d across:%lluk %s%s\n",
 		nr_good_pages<<(PAGE_SHIFT-10), name, p->prio,
 		nr_extents, (unsigned long long)span<<(PAGE_SHIFT-10),
-		(p->flags & SWP_DISCARDABLE) ? " D" : "");
+		(p->flags & SWP_SOLIDSTATE) ? "SS" : "",
+		(p->flags & SWP_DISCARDABLE) ? "D" : "");
 
 	/* insert swap space into swap_list: */
 	prev = -1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
