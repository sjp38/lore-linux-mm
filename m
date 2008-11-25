Date: Tue, 25 Nov 2008 21:46:00 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 7/9] swapfile: swap allocation use discard
In-Reply-To: <Pine.LNX.4.64.0811252140230.17555@blonde.site>
Message-ID: <Pine.LNX.4.64.0811252145190.20455@blonde.site>
References: <Pine.LNX.4.64.0811252132580.17555@blonde.site>
 <Pine.LNX.4.64.0811252140230.17555@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Woodhouse <dwmw2@infradead.org>, Jens Axboe <jens.axboe@oracle.com>, Matthew Wilcox <matthew@wil.cx>, Joern Engel <joern@logfs.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, Donjun Shin <djshin90@gmail.com>, Tejun Heo <teheo@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

When scan_swap_map() finds a free cluster of swap pages to allocate,
discard the old contents of the cluster if the device supports discard.
But don't bother when swap is so fragmented that we allocate single pages.

Be careful about racing allocations made while we're scanning for
a cluster; and hold up allocations made while we're discarding.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 include/linux/swap.h |    3 +
 mm/swapfile.c        |  119 ++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 121 insertions(+), 1 deletion(-)

--- swapfile6/include/linux/swap.h	2008-11-25 12:41:34.000000000 +0000
+++ swapfile7/include/linux/swap.h	2008-11-25 12:41:40.000000000 +0000
@@ -121,6 +121,7 @@ enum {
 	SWP_USED	= (1 << 0),	/* is slot in swap_info[] used? */
 	SWP_WRITEOK	= (1 << 1),	/* ok to write to this swap?	*/
 	SWP_DISCARDABLE = (1 << 2),	/* blkdev supports discard */
+	SWP_DISCARDING	= (1 << 3),	/* now discarding a free cluster */
 					/* add others here before... */
 	SWP_SCANNING	= (1 << 8),	/* refcount in scan_swap_map */
 };
@@ -144,6 +145,8 @@ struct swap_info_struct {
 	unsigned short *swap_map;
 	unsigned int lowest_bit;
 	unsigned int highest_bit;
+	unsigned int lowest_alloc;	/* while preparing discard cluster */
+	unsigned int highest_alloc;	/* while preparing discard cluster */
 	unsigned int cluster_next;
 	unsigned int cluster_nr;
 	unsigned int pages;
--- swapfile6/mm/swapfile.c	2008-11-25 12:41:34.000000000 +0000
+++ swapfile7/mm/swapfile.c	2008-11-25 12:41:40.000000000 +0000
@@ -115,14 +115,62 @@ static int discard_swap(struct swap_info
 	return err;		/* That will often be -EOPNOTSUPP */
 }
 
+/*
+ * swap allocation tell device that a cluster of swap can now be discarded,
+ * to allow the swap device to optimize its wear-levelling.
+ */
+static void discard_swap_cluster(struct swap_info_struct *si,
+				 pgoff_t start_page, pgoff_t nr_pages)
+{
+	struct swap_extent *se = si->curr_swap_extent;
+	int found_extent = 0;
+
+	while (nr_pages) {
+		struct list_head *lh;
+
+		if (se->start_page <= start_page &&
+		    start_page < se->start_page + se->nr_pages) {
+			pgoff_t offset = start_page - se->start_page;
+			sector_t start_block = se->start_block + offset;
+			pgoff_t nr_blocks = se->nr_pages - offset;
+
+			if (nr_blocks > nr_pages)
+				nr_blocks = nr_pages;
+			start_page += nr_blocks;
+			nr_pages -= nr_blocks;
+
+			if (!found_extent++)
+				si->curr_swap_extent = se;
+
+			start_block <<= PAGE_SHIFT - 9;
+			nr_blocks <<= PAGE_SHIFT - 9;
+			if (blkdev_issue_discard(si->bdev, start_block,
+							nr_blocks, GFP_NOIO))
+				break;
+		}
+
+		lh = se->list.next;
+		if (lh == &si->extent_list)
+			lh = lh->next;
+		se = list_entry(lh, struct swap_extent, list);
+	}
+}
+
+static int wait_for_discard(void *word)
+{
+	schedule();
+	return 0;
+}
+
 #define SWAPFILE_CLUSTER	256
 #define LATENCY_LIMIT		256
 
 static inline unsigned long scan_swap_map(struct swap_info_struct *si)
 {
 	unsigned long offset;
-	unsigned long last_in_cluster;
+	unsigned long last_in_cluster = 0;
 	int latency_ration = LATENCY_LIMIT;
+	int found_free_cluster = 0;
 
 	/*
 	 * We try to cluster swap pages by allocating them sequentially
@@ -142,6 +190,19 @@ static inline unsigned long scan_swap_ma
 			si->cluster_nr = SWAPFILE_CLUSTER - 1;
 			goto checks;
 		}
+		if (si->flags & SWP_DISCARDABLE) {
+			/*
+			 * Start range check on racing allocations, in case
+			 * they overlap the cluster we eventually decide on
+			 * (we scan without swap_lock to allow preemption).
+			 * It's hardly conceivable that cluster_nr could be
+			 * wrapped during our scan, but don't depend on it.
+			 */
+			if (si->lowest_alloc)
+				goto checks;
+			si->lowest_alloc = si->max;
+			si->highest_alloc = 0;
+		}
 		spin_unlock(&swap_lock);
 
 		offset = si->lowest_bit;
@@ -156,6 +217,7 @@ static inline unsigned long scan_swap_ma
 				offset -= SWAPFILE_CLUSTER - 1;
 				si->cluster_next = offset;
 				si->cluster_nr = SWAPFILE_CLUSTER - 1;
+				found_free_cluster = 1;
 				goto checks;
 			}
 			if (unlikely(--latency_ration < 0)) {
@@ -167,6 +229,7 @@ static inline unsigned long scan_swap_ma
 		offset = si->lowest_bit;
 		spin_lock(&swap_lock);
 		si->cluster_nr = SWAPFILE_CLUSTER - 1;
+		si->lowest_alloc = 0;
 	}
 
 checks:
@@ -191,6 +254,60 @@ checks:
 	si->swap_map[offset] = 1;
 	si->cluster_next = offset + 1;
 	si->flags -= SWP_SCANNING;
+
+	if (si->lowest_alloc) {
+		/*
+		 * Only set when SWP_DISCARDABLE, and there's a scan
+		 * for a free cluster in progress or just completed.
+		 */
+		if (found_free_cluster) {
+			/*
+			 * To optimize wear-levelling, discard the
+			 * old data of the cluster, taking care not to
+			 * discard any of its pages that have already
+			 * been allocated by racing tasks (offset has
+			 * already stepped over any at the beginning).
+			 */
+			if (offset < si->highest_alloc &&
+			    si->lowest_alloc <= last_in_cluster)
+				last_in_cluster = si->lowest_alloc - 1;
+			si->flags |= SWP_DISCARDING;
+			spin_unlock(&swap_lock);
+
+			if (offset < last_in_cluster)
+				discard_swap_cluster(si, offset,
+					last_in_cluster - offset + 1);
+
+			spin_lock(&swap_lock);
+			si->lowest_alloc = 0;
+			si->flags &= ~SWP_DISCARDING;
+
+			smp_mb();	/* wake_up_bit advises this */
+			wake_up_bit(&si->flags, ilog2(SWP_DISCARDING));
+
+		} else if (si->flags & SWP_DISCARDING) {
+			/*
+			 * Delay using pages allocated by racing tasks
+			 * until the whole discard has been issued. We
+			 * could defer that delay until swap_writepage,
+			 * but it's easier to keep this self-contained.
+			 */
+			spin_unlock(&swap_lock);
+			wait_on_bit(&si->flags, ilog2(SWP_DISCARDING),
+				wait_for_discard, TASK_UNINTERRUPTIBLE);
+			spin_lock(&swap_lock);
+		} else {
+			/*
+			 * Note pages allocated by racing tasks while
+			 * scan for a free cluster is in progress, so
+			 * that its final discard can exclude them.
+			 */
+			if (offset < si->lowest_alloc)
+				si->lowest_alloc = offset;
+			if (offset > si->highest_alloc)
+				si->highest_alloc = offset;
+		}
+	}
 	return offset;
 
 scan:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
