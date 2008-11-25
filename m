Date: Tue, 25 Nov 2008 21:47:44 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 9/9] swapfile: swap allocation cycle if nonrot
In-Reply-To: <Pine.LNX.4.64.0811252140230.17555@blonde.site>
Message-ID: <Pine.LNX.4.64.0811252147040.20455@blonde.site>
References: <Pine.LNX.4.64.0811252132580.17555@blonde.site>
 <Pine.LNX.4.64.0811252140230.17555@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Woodhouse <dwmw2@infradead.org>, Jens Axboe <jens.axboe@oracle.com>, Matthew Wilcox <matthew@wil.cx>, Joern Engel <joern@logfs.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, Donjun Shin <djshin90@gmail.com>, Tejun Heo <teheo@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Though attempting to find free clusters (Andrea), swap allocation has
always restarted its searches from the beginning of the swap area (sct),
to reduce seek times between swap pages, by not scattering them all over
the partition.

But on a solidstate swap device, seeks are cheap, and block remapping
to level the wear may be limited by zones: in that case it's better to
cycle around the whole partition.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/swapfile.c |   50 ++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 46 insertions(+), 4 deletions(-)

--- swapfile8/mm/swapfile.c	2008-11-25 12:41:42.000000000 +0000
+++ swapfile9/mm/swapfile.c	2008-11-25 12:41:44.000000000 +0000
@@ -169,6 +169,7 @@ static int wait_for_discard(void *word)
 static inline unsigned long scan_swap_map(struct swap_info_struct *si)
 {
 	unsigned long offset;
+	unsigned long scan_base;
 	unsigned long last_in_cluster = 0;
 	int latency_ration = LATENCY_LIMIT;
 	int found_free_cluster = 0;
@@ -181,10 +182,11 @@ static inline unsigned long scan_swap_ma
 	 * all over the entire swap partition, so that we reduce
 	 * overall disk seek times between swap pages.  -- sct
 	 * But we do now try to find an empty cluster.  -Andrea
+	 * And we let swap pages go all over an SSD partition.  Hugh
 	 */
 
 	si->flags += SWP_SCANNING;
-	offset = si->cluster_next;
+	scan_base = offset = si->cluster_next;
 
 	if (unlikely(!si->cluster_nr--)) {
 		if (si->pages - si->inuse_pages < SWAPFILE_CLUSTER) {
@@ -206,7 +208,16 @@ static inline unsigned long scan_swap_ma
 		}
 		spin_unlock(&swap_lock);
 
-		offset = si->lowest_bit;
+		/*
+		 * If seek is expensive, start searching for new cluster from
+		 * start of partition, to minimize the span of allocated swap.
+		 * But if seek is cheap, search from our current position, so
+		 * that swap is allocated from all over the partition: if the
+		 * Flash Translation Layer only remaps within limited zones,
+		 * we don't want to wear out the first zone too quickly.
+		 */
+		if (!(si->flags & SWP_SOLIDSTATE))
+			scan_base = offset = si->lowest_bit;
 		last_in_cluster = offset + SWAPFILE_CLUSTER - 1;
 
 		/* Locate the first empty (unaligned) cluster */
@@ -228,6 +239,27 @@ static inline unsigned long scan_swap_ma
 		}
 
 		offset = si->lowest_bit;
+		last_in_cluster = offset + SWAPFILE_CLUSTER - 1;
+
+		/* Locate the first empty (unaligned) cluster */
+		for (; last_in_cluster < scan_base; offset++) {
+			if (si->swap_map[offset])
+				last_in_cluster = offset + SWAPFILE_CLUSTER;
+			else if (offset == last_in_cluster) {
+				spin_lock(&swap_lock);
+				offset -= SWAPFILE_CLUSTER - 1;
+				si->cluster_next = offset;
+				si->cluster_nr = SWAPFILE_CLUSTER - 1;
+				found_free_cluster = 1;
+				goto checks;
+			}
+			if (unlikely(--latency_ration < 0)) {
+				cond_resched();
+				latency_ration = LATENCY_LIMIT;
+			}
+		}
+
+		offset = scan_base;
 		spin_lock(&swap_lock);
 		si->cluster_nr = SWAPFILE_CLUSTER - 1;
 		si->lowest_alloc = 0;
@@ -239,7 +271,7 @@ checks:
 	if (!si->highest_bit)
 		goto no_page;
 	if (offset > si->highest_bit)
-		offset = si->lowest_bit;
+		scan_base = offset = si->lowest_bit;
 	if (si->swap_map[offset])
 		goto scan;
 
@@ -323,8 +355,18 @@ scan:
 			latency_ration = LATENCY_LIMIT;
 		}
 	}
+	offset = si->lowest_bit;
+	while (++offset < scan_base) {
+		if (!si->swap_map[offset]) {
+			spin_lock(&swap_lock);
+			goto checks;
+		}
+		if (unlikely(--latency_ration < 0)) {
+			cond_resched();
+			latency_ration = LATENCY_LIMIT;
+		}
+	}
 	spin_lock(&swap_lock);
-	goto checks;
 
 no_page:
 	si->flags -= SWP_SCANNING;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
