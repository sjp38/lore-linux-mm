Date: Sat, 6 Oct 2007 21:48:41 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 7/7] swapin: fix valid_swaphandles defect
In-Reply-To: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0710062147540.16223@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

valid_swaphandles is supposed to do a quick pass over the swap map
entries neigbouring the entry which swapin_readahead is targetting,
to determine for it a range worth reading all together.  But since
it always starts its search from the beginning of the swap "cluster",
a reject (free entry) there immediately curtails the readaround, and
every swapin_readahead from that cluster is for just a single page.
Instead scan forwards and backwards around the target entry.

Use better names for some variables: a swap_info pointer is usually
called "si" not "swapdev".  And at the end, if only the target page
should be read, return count of 0 to disable readaround, to avoid
the unnecessarily repeated call to read_swap_cache_async.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/swapfile.c |   49 ++++++++++++++++++++++++++++++++----------------
 1 file changed, 33 insertions(+), 16 deletions(-)

--- patch6/mm/swapfile.c	2007-10-04 19:24:36.000000000 +0100
+++ patch7/mm/swapfile.c	2007-10-04 19:24:46.000000000 +0100
@@ -1776,31 +1776,48 @@ get_swap_info_struct(unsigned type)
  */
 int valid_swaphandles(swp_entry_t entry, unsigned long *offset)
 {
+	struct swap_info_struct *si;
 	int our_page_cluster = page_cluster;
-	int ret = 0, i = 1 << our_page_cluster;
-	unsigned long toff;
-	struct swap_info_struct *swapdev = swp_type(entry) + swap_info;
+	pgoff_t target, toff;
+	pgoff_t base, end;
+	int nr_pages = 0;
 
 	if (!our_page_cluster)	/* no readahead */
 		return 0;
-	toff = (swp_offset(entry) >> our_page_cluster) << our_page_cluster;
-	if (!toff)		/* first page is swap header */
-		toff++, i--;
-	*offset = toff;
+
+	si = &swap_info[swp_type(entry)];
+	target = swp_offset(entry);
+	base = (target >> our_page_cluster) << our_page_cluster;
+	end = base + (1 << our_page_cluster);
+	if (!base)		/* first page is swap header */
+		base++;
 
 	spin_lock(&swap_lock);
-	do {
-		/* Don't read-ahead past the end of the swap area */
-		if (toff >= swapdev->max)
+	if (end > si->max)	/* don't go beyond end of map */
+		end = si->max;
+
+	/* Count contiguous allocated slots above our target */
+	for (toff = target; ++toff < end; nr_pages++) {
+		/* Don't read in free or bad pages */
+		if (!si->swap_map[toff])
 			break;
+		if (si->swap_map[toff] == SWAP_MAP_BAD)
+			break;
+	}
+	/* Count contiguous allocated slots below our target */
+	for (toff = target; --toff >= base; nr_pages++) {
 		/* Don't read in free or bad pages */
-		if (!swapdev->swap_map[toff])
+		if (!si->swap_map[toff])
 			break;
-		if (swapdev->swap_map[toff] == SWAP_MAP_BAD)
+		if (si->swap_map[toff] == SWAP_MAP_BAD)
 			break;
-		toff++;
-		ret++;
-	} while (--i);
+	}
 	spin_unlock(&swap_lock);
-	return ret;
+
+	/*
+	 * Indicate starting offset, and return number of pages to get:
+	 * if only 1, say 0, since there's then no readahead to be done.
+	 */
+	*offset = ++toff;
+	return nr_pages? ++nr_pages: 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
