Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id E15376B0075
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 18:10:55 -0500 (EST)
Date: Mon, 9 Jan 2012 18:10:23 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm] make swapin readahead skip over holes
Message-ID: <20120109181023.7c81d0be@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>

Ever since abandoning the virtual scan of processes, for scalability
reasons, swap space has been a little more fragmented than before.
This can lead to the situation where a large memory user is killed,
swap space ends up full of "holes" and swapin readahead is totally
ineffective.

On my home system, after killing a leaky firefox it took over an
hour to page just under 2GB of memory back in, slowing the virtual
machines down to a crawl.

This patch makes swapin readahead simply skip over holes, instead
of stopping at them.  This allows the system to swap things back in
at rates of several MB/second, instead of a few hundred kB/second.

The checks done in valid_swaphandles are already done in 
read_swap_cache_async as well, allowing us to remove a fair amount
of code.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 include/linux/swap.h |    2 +-
 mm/swap_state.c      |   17 ++++----------
 mm/swapfile.c        |   56 +++++++++++--------------------------------------
 3 files changed, 19 insertions(+), 56 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 1e22e12..6e1282e 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -328,7 +328,7 @@ extern long total_swap_pages;
 extern void si_swapinfo(struct sysinfo *);
 extern swp_entry_t get_swap_page(void);
 extern swp_entry_t get_swap_page_of_type(int);
-extern int valid_swaphandles(swp_entry_t, unsigned long *);
+extern void get_swap_cluster(swp_entry_t, unsigned long *, unsigned long *);
 extern int add_swap_count_continuation(swp_entry_t, gfp_t);
 extern void swap_shmem_alloc(swp_entry_t);
 extern int swap_duplicate(swp_entry_t);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 78cc4d1..36501b3 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -373,25 +373,18 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 			struct vm_area_struct *vma, unsigned long addr)
 {
-	int nr_pages;
 	struct page *page;
-	unsigned long offset;
+	unsigned long offset = swp_offset(entry);
 	unsigned long end_offset;
 
-	/*
-	 * Get starting offset for readaround, and number of pages to read.
-	 * Adjust starting address by readbehind (for NUMA interleave case)?
-	 * No, it's very unlikely that swap layout would follow vma layout,
-	 * more likely that neighbouring swap pages came from the same node:
-	 * so use the same "addr" to choose the same node for each swap read.
-	 */
-	nr_pages = valid_swaphandles(entry, &offset);
-	for (end_offset = offset + nr_pages; offset < end_offset; offset++) {
+	get_swap_cluster(entry, &offset, &end_offset);
+
+	for (; offset <= end_offset ; offset++) {
 		/* Ok, do the async read-ahead now */
 		page = read_swap_cache_async(swp_entry(swp_type(entry), offset),
 						gfp_mask, vma, addr);
 		if (!page)
-			break;
+			continue;
 		page_cache_release(page);
 	}
 	lru_add_drain();	/* Push any new pages onto the LRU now */
diff --git a/mm/swapfile.c b/mm/swapfile.c
index b1cd120..8dae1ca 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2289,55 +2289,25 @@ int swapcache_prepare(swp_entry_t entry)
 }
 
 /*
- * swap_lock prevents swap_map being freed. Don't grab an extra
- * reference on the swaphandle, it doesn't matter if it becomes unused.
+ * Return a swap cluster sized and aligned block around offset.
  */
-int valid_swaphandles(swp_entry_t entry, unsigned long *offset)
+void get_swap_cluster(swp_entry_t entry, unsigned long *begin,
+			unsigned long *end)
 {
 	struct swap_info_struct *si;
-	int our_page_cluster = page_cluster;
-	pgoff_t target, toff;
-	pgoff_t base, end;
-	int nr_pages = 0;
-
-	if (!our_page_cluster)	/* no readahead */
-		return 0;
-
-	si = swap_info[swp_type(entry)];
-	target = swp_offset(entry);
-	base = (target >> our_page_cluster) << our_page_cluster;
-	end = base + (1 << our_page_cluster);
-	if (!base)		/* first page is swap header */
-		base++;
+	unsigned long offset = swp_offset(entry);
 
 	spin_lock(&swap_lock);
-	if (end > si->max)	/* don't go beyond end of map */
-		end = si->max;
-
-	/* Count contiguous allocated slots above our target */
-	for (toff = target; ++toff < end; nr_pages++) {
-		/* Don't read in free or bad pages */
-		if (!si->swap_map[toff])
-			break;
-		if (swap_count(si->swap_map[toff]) == SWAP_MAP_BAD)
-			break;
-	}
-	/* Count contiguous allocated slots below our target */
-	for (toff = target; --toff >= base; nr_pages++) {
-		/* Don't read in free or bad pages */
-		if (!si->swap_map[toff])
-			break;
-		if (swap_count(si->swap_map[toff]) == SWAP_MAP_BAD)
-			break;
-	}
+	si = swap_info[swp_type(entry)];
+	/* Round the begin down to a page_cluster boundary. */
+	offset = (offset >> page_cluster) << page_cluster;
+	*begin = offset;
+	/* Round the end up, but not beyond the end of the swap device. */
+	offset = offset + (1 << page_cluster);
+	if (offset > si->max)
+		offset = si->max;
+	*end = offset;
 	spin_unlock(&swap_lock);
-
-	/*
-	 * Indicate starting offset, and return number of pages to get:
-	 * if only 1, say 0, since there's then no readahead to be done.
-	 */
-	*offset = ++toff;
-	return nr_pages? ++nr_pages: 0;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
