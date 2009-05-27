Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 992946B00D4
	for <linux-mm@kvack.org>; Wed, 27 May 2009 17:48:18 -0400 (EDT)
Date: Wed, 27 May 2009 14:48:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [rfc][patch] swap: virtual swap readahead
Message-Id: <20090527144851.832a0375.akpm@linux-foundation.org>
In-Reply-To: <1243436746-2698-1-git-send-email-hannes@cmpxchg.org>
References: <1243436746-2698-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hugh.dickins@tiscali.co.uk, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 27 May 2009 17:05:46 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> The current swap readahead implementation reads a physically
> contiguous group of swap slots around the faulting page to take
> advantage of the disk head's position and in the hope that the
> surrounding pages will be needed soon as well.
> 
> This works as long as the physical swap slot order approximates the
> LRU order decently, otherwise it wastes memory and IO bandwidth to
> read in pages that are unlikely to be needed soon.
> 
> However, the physical swap slot layout diverges from the LRU order
> with increasing swap activity, i.e. high memory pressure situations,
> and this is exactly the situation where swapin should not waste any
> memory or IO bandwidth as both are the most contended resources at
> this point.
> 
> This patch makes swap-in base its readaround window on the virtual
> proximity of pages in the faulting VMA, as an indicator for pages
> needed in the near future, while still taking physical locality of
> swap slots into account.
> 
> This has the advantage of reading in big batches when the LRU order
> matches the swap slot order while automatically throttling readahead
> when the system is thrashing and swap slots are no longer nicely
> grouped by LRU order.
> 

Well.  It would be better to _not_ shrink readaround, but to make it
read the right pages (see below).

Or perhaps the readaround size is just too large.  I did spend some
time playing with its size back in the dark ages and ended up deciding
that the current setting is OK, but that was across a range of
workloads.

Did you try simply decreasing the cluster size and seeing if that had a
similar effect upon this workload?



Back in 2002 or thereabouts I had a patch <rummage, rummage.  Appended>
which does this the other way.  It attempts to ensure that swap space
is allocated so that virtually contiguous pages get physically
contiguous blocks on disk.  So that when swapspace readaround does its
thing, the blocks which it reads are populating pages which are
virtually "close" to the page which got the major fault.

Unfortunately I wasn't able to demonstrate much performance benefit
from it and didn't get around to working out why.

iirc, the way it worked was: divide swap into 1MB hunks.  When we
decide to add an anon page to swapcache, grab a 1MB hunk of swap and
then add the pages which are virtual neighbours of the target page to
swapcache as well.

Obviously the algorithm could be tweaked/tuned/fixed, but the idea
seems sound - the cost of reading a contiguous hunk of blocks is not a
lot more than reading the single block.

Maybe it's something you might like to have a think about.

> The missing shmem support is a big TODO, I will try to find time to
> tackle this when the overall idea is not refused in the first place.

heh, OK.

> - * Primitive swap readahead code. We simply read an aligned block of
> - * (1 << page_cluster) entries in the swap area. This method is chosen
> - * because it doesn't cost us any seek time.  We also make sure to queue
> - * the 'original' request together with the readahead ones...
> - *
> -	/*
> -	 * Get starting offset for readaround, and number of pages to read.
> -	 * Adjust starting address by readbehind (for NUMA interleave case)?
> -	 * No, it's very unlikely that swap layout would follow vma layout,
> -	 * more likely that neighbouring swap pages came from the same node:
> -	 * so use the same "addr" to choose the same node for each swap read.
> -	 */

The patch deletes the old design description but doesn't add a
description of the new design :(



 include/linux/swap.h  |    6 +--
 kernel/power/swsusp.c |    2 -
 mm/shmem.c            |    4 +-
 mm/swap_state.c       |    8 +++-
 mm/swapfile.c         |   98 ++++++++++++++++++++------------------------------
 mm/vmscan.c           |    5 ++
 6 files changed, 56 insertions(+), 67 deletions(-)

diff -puN include/linux/swap.h~swapspace-layout-improvements include/linux/swap.h
--- 25/include/linux/swap.h~swapspace-layout-improvements	2005-05-02 23:36:30.000000000 -0700
+++ 25-akpm/include/linux/swap.h	2005-05-02 23:36:30.000000000 -0700
@@ -193,7 +193,7 @@ extern int rw_swap_page_sync(int, swp_en
 extern struct address_space swapper_space;
 #define total_swapcache_pages  swapper_space.nrpages
 extern void show_swap_cache_info(void);
-extern int add_to_swap(struct page *);
+extern int add_to_swap(struct page *page, void *cookie, pgoff_t index);
 extern void __delete_from_swap_cache(struct page *);
 extern void delete_from_swap_cache(struct page *);
 extern int move_to_swap_cache(struct page *, swp_entry_t);
@@ -209,7 +209,7 @@ extern long total_swap_pages;
 extern unsigned int nr_swapfiles;
 extern struct swap_info_struct swap_info[];
 extern void si_swapinfo(struct sysinfo *);
-extern swp_entry_t get_swap_page(void);
+extern swp_entry_t get_swap_page(void *cookie, pgoff_t index);
 extern int swap_duplicate(swp_entry_t);
 extern int valid_swaphandles(swp_entry_t, unsigned long *);
 extern void swap_free(swp_entry_t);
@@ -276,7 +276,7 @@ static inline int remove_exclusive_swap_
 	return 0;
 }
 
-static inline swp_entry_t get_swap_page(void)
+static inline swp_entry_t get_swap_page(void *cookie, pgoff_t index)
 {
 	swp_entry_t entry;
 	entry.val = 0;
diff -puN kernel/power/swsusp.c~swapspace-layout-improvements kernel/power/swsusp.c
--- 25/kernel/power/swsusp.c~swapspace-layout-improvements	2005-05-02 23:36:30.000000000 -0700
+++ 25-akpm/kernel/power/swsusp.c	2005-05-02 23:36:30.000000000 -0700
@@ -240,7 +240,7 @@ static int write_page(unsigned long addr
 	swp_entry_t entry;
 	int error = 0;
 
-	entry = get_swap_page();
+	entry = get_swap_page(NULL, swp_offset(*loc));
 	if (swp_offset(entry) && 
 	    swapfile_used[swp_type(entry)] == SWAPFILE_SUSPEND) {
 		error = rw_swap_page_sync(WRITE, entry,
diff -puN mm/shmem.c~swapspace-layout-improvements mm/shmem.c
--- 25/mm/shmem.c~swapspace-layout-improvements	2005-05-02 23:36:30.000000000 -0700
+++ 25-akpm/mm/shmem.c	2005-05-02 23:36:30.000000000 -0700
@@ -812,7 +812,7 @@ static int shmem_writepage(struct page *
 	struct shmem_inode_info *info;
 	swp_entry_t *entry, swap;
 	struct address_space *mapping;
-	unsigned long index;
+	pgoff_t index;
 	struct inode *inode;
 
 	BUG_ON(!PageLocked(page));
@@ -824,7 +824,7 @@ static int shmem_writepage(struct page *
 	info = SHMEM_I(inode);
 	if (info->flags & VM_LOCKED)
 		goto redirty;
-	swap = get_swap_page();
+	swap = get_swap_page(mapping, index);
 	if (!swap.val)
 		goto redirty;
 
diff -puN mm/swapfile.c~swapspace-layout-improvements mm/swapfile.c
--- 25/mm/swapfile.c~swapspace-layout-improvements	2005-05-02 23:36:30.000000000 -0700
+++ 25-akpm/mm/swapfile.c	2005-05-02 23:36:30.000000000 -0700
@@ -13,6 +13,7 @@
 #include <linux/kernel_stat.h>
 #include <linux/swap.h>
 #include <linux/vmalloc.h>
+#include <linux/hash.h>
 #include <linux/pagemap.h>
 #include <linux/namei.h>
 #include <linux/shm.h>
@@ -84,71 +85,52 @@ void swap_unplug_io_fn(struct backing_de
 	up_read(&swap_unplug_sem);
 }
 
-static inline int scan_swap_map(struct swap_info_struct *si)
-{
-	unsigned long offset;
-	/* 
-	 * We try to cluster swap pages by allocating them
-	 * sequentially in swap.  Once we've allocated
-	 * SWAPFILE_CLUSTER pages this way, however, we resort to
-	 * first-free allocation, starting a new cluster.  This
-	 * prevents us from scattering swap pages all over the entire
-	 * swap partition, so that we reduce overall disk seek times
-	 * between swap pages.  -- sct */
-	if (si->cluster_nr) {
-		while (si->cluster_next <= si->highest_bit) {
-			offset = si->cluster_next++;
-			if (si->swap_map[offset])
-				continue;
-			si->cluster_nr--;
-			goto got_page;
-		}
-	}
-	si->cluster_nr = SWAPFILE_CLUSTER;
+int akpm;
 
-	/* try to find an empty (even not aligned) cluster. */
-	offset = si->lowest_bit;
- check_next_cluster:
-	if (offset+SWAPFILE_CLUSTER-1 <= si->highest_bit)
-	{
-		unsigned long nr;
-		for (nr = offset; nr < offset+SWAPFILE_CLUSTER; nr++)
-			if (si->swap_map[nr])
-			{
-				offset = nr+1;
-				goto check_next_cluster;
-			}
-		/* We found a completly empty cluster, so start
-		 * using it.
-		 */
-		goto got_page;
-	}
-	/* No luck, so now go finegrined as usual. -Andrea */
-	for (offset = si->lowest_bit; offset <= si->highest_bit ; offset++) {
-		if (si->swap_map[offset])
+/*
+ * We divide the swapdev into 1024 kilobyte chunks.  We use the cookie and the
+ * upper bits of the index to select a chunk and the rest of the index as the
+ * offset into the selected chunk.
+ */
+#define CHUNK_SHIFT	(20 - PAGE_SHIFT)
+#define CHUNK_MASK	(-1UL << CHUNK_SHIFT)
+
+static int
+scan_swap_map(struct swap_info_struct *si, void *cookie, pgoff_t index)
+{
+	unsigned long chunk;
+	unsigned long nchunks;
+	unsigned long block;
+	unsigned long scan;
+
+	nchunks = si->max >> CHUNK_SHIFT;
+	chunk = 0;
+	if (nchunks)
+		chunk = hash_long((unsigned long)cookie + (index & CHUNK_MASK),
+					BITS_PER_LONG) % nchunks;
+
+	block = (chunk << CHUNK_SHIFT) + (index & ~CHUNK_MASK);
+
+	for (scan = 0; scan < si->max; scan++, block++) {
+		if (block == si->max)
+			block = 0;
+		if (block == 0)
 			continue;
-		si->lowest_bit = offset+1;
-	got_page:
-		if (offset == si->lowest_bit)
-			si->lowest_bit++;
-		if (offset == si->highest_bit)
-			si->highest_bit--;
-		if (si->lowest_bit > si->highest_bit) {
-			si->lowest_bit = si->max;
-			si->highest_bit = 0;
-		}
-		si->swap_map[offset] = 1;
+		if (si->swap_map[block])
+			continue;
+		si->swap_map[block] = 1;
 		si->inuse_pages++;
 		nr_swap_pages--;
-		si->cluster_next = offset+1;
-		return offset;
+		if (akpm)
+			printk("cookie:%p, index:%lu, chunk:%lu nchunks:%lu "
+				"block:%lu\n",
+				cookie, index, chunk, nchunks, block);
+		return block;
 	}
-	si->lowest_bit = si->max;
-	si->highest_bit = 0;
 	return 0;
 }
 
-swp_entry_t get_swap_page(void)
+swp_entry_t get_swap_page(void *cookie, pgoff_t index)
 {
 	struct swap_info_struct * p;
 	unsigned long offset;
@@ -167,7 +149,7 @@ swp_entry_t get_swap_page(void)
 		p = &swap_info[type];
 		if ((p->flags & SWP_ACTIVE) == SWP_ACTIVE) {
 			swap_device_lock(p);
-			offset = scan_swap_map(p);
+			offset = scan_swap_map(p, cookie, index);
 			swap_device_unlock(p);
 			if (offset) {
 				entry = swp_entry(type,offset);
diff -puN mm/swap_state.c~swapspace-layout-improvements mm/swap_state.c
--- 25/mm/swap_state.c~swapspace-layout-improvements	2005-05-02 23:36:30.000000000 -0700
+++ 25-akpm/mm/swap_state.c	2005-05-02 23:36:30.000000000 -0700
@@ -139,8 +139,12 @@ void __delete_from_swap_cache(struct pag
  *
  * Allocate swap space for the page and add the page to the
  * swap cache.  Caller needs to hold the page lock. 
+ *
+ * We attempt to lay pages out on swap to that virtually-contiguous pages are
+ * contiguous on-disk.  To do this we utilise page->index (offset into vma) and
+ * page->mapping (the anon_vma's address).
  */
-int add_to_swap(struct page * page)
+int add_to_swap(struct page *page, void *cookie, pgoff_t index)
 {
 	swp_entry_t entry;
 	int err;
@@ -149,7 +153,7 @@ int add_to_swap(struct page * page)
 		BUG();
 
 	for (;;) {
-		entry = get_swap_page();
+		entry = get_swap_page(cookie, index);
 		if (!entry.val)
 			return 0;
 
diff -puN mm/vmscan.c~swapspace-layout-improvements mm/vmscan.c
--- 25/mm/vmscan.c~swapspace-layout-improvements	2005-05-02 23:36:30.000000000 -0700
+++ 25-akpm/mm/vmscan.c	2005-05-02 23:36:30.000000000 -0700
@@ -408,7 +408,10 @@ static int shrink_list(struct list_head 
 		 * Try to allocate it some swap space here.
 		 */
 		if (PageAnon(page) && !PageSwapCache(page)) {
-			if (!add_to_swap(page))
+			void *cookie = page->mapping;
+			pgoff_t index = page->index;
+
+			if (!add_to_swap(page, cookie, index))
 				goto activate_locked;
 		}
 #endif /* CONFIG_SWAP */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
