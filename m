Date: Tue, 25 Nov 2008 21:40:11 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 5/9] swapfile: rearrange scan and swap_info
In-Reply-To: <Pine.LNX.4.64.0811252132580.17555@blonde.site>
Message-ID: <Pine.LNX.4.64.0811252139180.17555@blonde.site>
References: <Pine.LNX.4.64.0811252132580.17555@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Before making functional changes, rearrange scan_swap_map() to simplify
subsequent diffs.  Actually, there is one functional change in there:
leave cluster_nr negative while scanning for a new cluster - resetting
it early increased the likelihood that when we have difficulty finding
a free cluster, another task may come in and try doing exactly the same
- just a waste of cpu.

Before making functional changes, rearrange struct swap_info_struct
slightly: flags will be needed as an unsigned long (for wait_on_bit),
next is a good int to pair with prio, old_block_size is uninteresting
so shift it to the end.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 include/linux/swap.h |    8 ++--
 mm/swapfile.c        |   66 ++++++++++++++++++++++-------------------
 2 files changed, 41 insertions(+), 33 deletions(-)

--- swapfile4/include/linux/swap.h	2008-11-25 12:41:19.000000000 +0000
+++ swapfile5/include/linux/swap.h	2008-11-25 12:41:31.000000000 +0000
@@ -133,14 +133,14 @@ enum {
  * The in-memory structure used to track swap areas.
  */
 struct swap_info_struct {
-	unsigned int flags;
+	unsigned long flags;
 	int prio;			/* swap priority */
+	int next;			/* next entry on swap list */
 	struct file *swap_file;
 	struct block_device *bdev;
 	struct list_head extent_list;
 	struct swap_extent *curr_swap_extent;
-	unsigned old_block_size;
-	unsigned short * swap_map;
+	unsigned short *swap_map;
 	unsigned int lowest_bit;
 	unsigned int highest_bit;
 	unsigned int cluster_next;
@@ -148,7 +148,7 @@ struct swap_info_struct {
 	unsigned int pages;
 	unsigned int max;
 	unsigned int inuse_pages;
-	int next;			/* next entry on swap list */
+	unsigned int old_block_size;
 };
 
 struct swap_list_t {
--- swapfile4/mm/swapfile.c	2008-11-25 12:41:26.000000000 +0000
+++ swapfile5/mm/swapfile.c	2008-11-25 12:41:31.000000000 +0000
@@ -89,7 +89,8 @@ void swap_unplug_io_fn(struct backing_de
 
 static inline unsigned long scan_swap_map(struct swap_info_struct *si)
 {
-	unsigned long offset, last_in_cluster;
+	unsigned long offset;
+	unsigned long last_in_cluster;
 	int latency_ration = LATENCY_LIMIT;
 
 	/*
@@ -103,10 +104,13 @@ static inline unsigned long scan_swap_ma
 	 */
 
 	si->flags += SWP_SCANNING;
-	if (unlikely(!si->cluster_nr)) {
-		si->cluster_nr = SWAPFILE_CLUSTER - 1;
-		if (si->pages - si->inuse_pages < SWAPFILE_CLUSTER)
-			goto lowest;
+	offset = si->cluster_next;
+
+	if (unlikely(!si->cluster_nr--)) {
+		if (si->pages - si->inuse_pages < SWAPFILE_CLUSTER) {
+			si->cluster_nr = SWAPFILE_CLUSTER - 1;
+			goto checks;
+		}
 		spin_unlock(&swap_lock);
 
 		offset = si->lowest_bit;
@@ -118,43 +122,47 @@ static inline unsigned long scan_swap_ma
 				last_in_cluster = offset + SWAPFILE_CLUSTER;
 			else if (offset == last_in_cluster) {
 				spin_lock(&swap_lock);
-				si->cluster_next = offset-SWAPFILE_CLUSTER+1;
-				goto cluster;
+				offset -= SWAPFILE_CLUSTER - 1;
+				si->cluster_next = offset;
+				si->cluster_nr = SWAPFILE_CLUSTER - 1;
+				goto checks;
 			}
 			if (unlikely(--latency_ration < 0)) {
 				cond_resched();
 				latency_ration = LATENCY_LIMIT;
 			}
 		}
+
+		offset = si->lowest_bit;
 		spin_lock(&swap_lock);
-		goto lowest;
+		si->cluster_nr = SWAPFILE_CLUSTER - 1;
 	}
 
-	si->cluster_nr--;
-cluster:
-	offset = si->cluster_next;
-	if (offset > si->highest_bit)
-lowest:		offset = si->lowest_bit;
-checks:	if (!(si->flags & SWP_WRITEOK))
+checks:
+	if (!(si->flags & SWP_WRITEOK))
 		goto no_page;
 	if (!si->highest_bit)
 		goto no_page;
-	if (!si->swap_map[offset]) {
-		if (offset == si->lowest_bit)
-			si->lowest_bit++;
-		if (offset == si->highest_bit)
-			si->highest_bit--;
-		si->inuse_pages++;
-		if (si->inuse_pages == si->pages) {
-			si->lowest_bit = si->max;
-			si->highest_bit = 0;
-		}
-		si->swap_map[offset] = 1;
-		si->cluster_next = offset + 1;
-		si->flags -= SWP_SCANNING;
-		return offset;
+	if (offset > si->highest_bit)
+		offset = si->lowest_bit;
+	if (si->swap_map[offset])
+		goto scan;
+
+	if (offset == si->lowest_bit)
+		si->lowest_bit++;
+	if (offset == si->highest_bit)
+		si->highest_bit--;
+	si->inuse_pages++;
+	if (si->inuse_pages == si->pages) {
+		si->lowest_bit = si->max;
+		si->highest_bit = 0;
 	}
+	si->swap_map[offset] = 1;
+	si->cluster_next = offset + 1;
+	si->flags -= SWP_SCANNING;
+	return offset;
 
+scan:
 	spin_unlock(&swap_lock);
 	while (++offset <= si->highest_bit) {
 		if (!si->swap_map[offset]) {
@@ -167,7 +175,7 @@ checks:	if (!(si->flags & SWP_WRITEOK))
 		}
 	}
 	spin_lock(&swap_lock);
-	goto lowest;
+	goto checks;
 
 no_page:
 	si->flags -= SWP_SCANNING;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
