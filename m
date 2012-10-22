Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id B9F666B0062
	for <linux-mm@kvack.org>; Sun, 21 Oct 2012 22:31:02 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so1678719pad.14
        for <linux-mm@kvack.org>; Sun, 21 Oct 2012 19:31:02 -0700 (PDT)
Date: Mon, 22 Oct 2012 10:30:51 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [RFC 1/2]swap: add a simple buddy allocator
Message-ID: <20121022023051.GA20255@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, hughd@google.com, riel@redhat.com

I'm using a fast SSD to do swap. scan_swap_map() sometimes uses up to 20~30%
CPU time (when cluster is hard to find), which becomes a bottleneck.
scan_swap_map() scans a byte array to search a 256 page cluster, which is very
slow.

Here I introduced a simple buddy allocator. Since we only care about 256 pages
cluster, we can just use a counter to implement the buddy allocator. Every 256
pages use one int to store the counter, so searching cluster is very efficient.
With this, scap_swap_map() overhead disappears.

This might help low end SD card swap too. Because if the cluster is aligned, SD
firmware can do flash erase more efficiently.

The downside is the cluster must be aligned to 256 pages, which will reduce the
chance to find a cluster.

Signed-off-by: Shaohua Li <shli@fusionio.com>
---
 include/linux/swap.h |    1 
 mm/swapfile.c        |   74 +++++++++++++++++++++++++++++++++++++++------------
 2 files changed, 58 insertions(+), 17 deletions(-)

Index: linux/include/linux/swap.h
===================================================================
--- linux.orig/include/linux/swap.h	2012-10-22 09:20:40.802165198 +0800
+++ linux/include/linux/swap.h	2012-10-22 09:20:50.462043746 +0800
@@ -185,6 +185,7 @@ struct swap_info_struct {
 	signed char	next;		/* next type on the swap list */
 	unsigned int	max;		/* extent of the swap_map */
 	unsigned char *swap_map;	/* vmalloc'ed array of usage counts */
+	unsigned int *swap_cluster_count; /* cluster counter */
 	unsigned int lowest_bit;	/* index of first free in swap_map */
 	unsigned int highest_bit;	/* index of last free in swap_map */
 	unsigned int pages;		/* total of usable pages of swap */
Index: linux/mm/swapfile.c
===================================================================
--- linux.orig/mm/swapfile.c	2012-10-22 09:20:40.794165269 +0800
+++ linux/mm/swapfile.c	2012-10-22 09:21:34.317493506 +0800
@@ -182,6 +182,22 @@ static int wait_for_discard(void *word)
 #define SWAPFILE_CLUSTER	256
 #define LATENCY_LIMIT		256
 
+static inline void inc_swap_cluster_count(unsigned int *swap_cluster_count,
+					unsigned long page_nr)
+{
+	swap_cluster_count += page_nr/SWAPFILE_CLUSTER;
+	VM_BUG_ON(*swap_cluster_count >= SWAPFILE_CLUSTER);
+	(*swap_cluster_count)++;
+}
+
+static inline void dec_swap_cluster_count(unsigned int *swap_cluster_count,
+					unsigned long page_nr)
+{
+	swap_cluster_count += page_nr/SWAPFILE_CLUSTER;
+	VM_BUG_ON(*swap_cluster_count == 0);
+	(*swap_cluster_count)--;
+}
+
 static unsigned long scan_swap_map(struct swap_info_struct *si,
 				   unsigned char usage)
 {
@@ -206,6 +222,8 @@ static unsigned long scan_swap_map(struc
 	scan_base = offset = si->cluster_next;
 
 	if (unlikely(!si->cluster_nr--)) {
+		unsigned long base;
+
 		if (si->pages - si->inuse_pages < SWAPFILE_CLUSTER) {
 			si->cluster_nr = SWAPFILE_CLUSTER - 1;
 			goto checks;
@@ -235,15 +253,14 @@ static unsigned long scan_swap_map(struc
 		 */
 		if (!(si->flags & SWP_SOLIDSTATE))
 			scan_base = offset = si->lowest_bit;
-		last_in_cluster = offset + SWAPFILE_CLUSTER - 1;
 
-		/* Locate the first empty (unaligned) cluster */
-		for (; last_in_cluster <= si->highest_bit; offset++) {
-			if (si->swap_map[offset])
-				last_in_cluster = offset + SWAPFILE_CLUSTER;
-			else if (offset == last_in_cluster) {
+		/* Locate the first empty (aligned) cluster */
+		for (base = round_up(offset, SWAPFILE_CLUSTER);
+		     base <= si->highest_bit; base += SWAPFILE_CLUSTER) {
+			if (!si->swap_cluster_count[base/SWAPFILE_CLUSTER]) {
+				offset = base;
+				last_in_cluster = offset + SWAPFILE_CLUSTER - 1;
 				spin_lock(&swap_lock);
-				offset -= SWAPFILE_CLUSTER - 1;
 				si->cluster_next = offset;
 				si->cluster_nr = SWAPFILE_CLUSTER - 1;
 				found_free_cluster = 1;
@@ -256,15 +273,14 @@ static unsigned long scan_swap_map(struc
 		}
 
 		offset = si->lowest_bit;
-		last_in_cluster = offset + SWAPFILE_CLUSTER - 1;
 
-		/* Locate the first empty (unaligned) cluster */
-		for (; last_in_cluster < scan_base; offset++) {
-			if (si->swap_map[offset])
-				last_in_cluster = offset + SWAPFILE_CLUSTER;
-			else if (offset == last_in_cluster) {
+		/* Locate the first empty (aligned) cluster */
+		for (base = round_up(offset, SWAPFILE_CLUSTER);
+		     base < scan_base; base += SWAPFILE_CLUSTER) {
+			if (!si->swap_cluster_count[base/SWAPFILE_CLUSTER]) {
+				offset = base;
+				last_in_cluster = offset + SWAPFILE_CLUSTER - 1;
 				spin_lock(&swap_lock);
-				offset -= SWAPFILE_CLUSTER - 1;
 				si->cluster_next = offset;
 				si->cluster_nr = SWAPFILE_CLUSTER - 1;
 				found_free_cluster = 1;
@@ -315,6 +331,7 @@ checks:
 		si->highest_bit = 0;
 	}
 	si->swap_map[offset] = usage;
+	inc_swap_cluster_count(si->swap_cluster_count, offset);
 	si->cluster_next = offset + 1;
 	si->flags -= SWP_SCANNING;
 
@@ -549,6 +566,7 @@ static unsigned char swap_entry_free(str
 
 	/* free if no reference */
 	if (!usage) {
+		dec_swap_cluster_count(p->swap_cluster_count, offset);
 		if (offset < p->lowest_bit)
 			p->lowest_bit = offset;
 		if (offset > p->highest_bit)
@@ -1445,6 +1463,7 @@ static int setup_swap_extents(struct swa
 
 static void enable_swap_info(struct swap_info_struct *p, int prio,
 				unsigned char *swap_map,
+				unsigned int *swap_cluster_count,
 				unsigned long *frontswap_map)
 {
 	int i, prev;
@@ -1455,6 +1474,7 @@ static void enable_swap_info(struct swap
 	else
 		p->prio = --least_priority;
 	p->swap_map = swap_map;
+	p->swap_cluster_count = swap_cluster_count;
 	frontswap_map_set(p, frontswap_map);
 	p->flags |= SWP_WRITEOK;
 	nr_swap_pages += p->pages;
@@ -1480,6 +1500,7 @@ SYSCALL_DEFINE1(swapoff, const char __us
 {
 	struct swap_info_struct *p = NULL;
 	unsigned char *swap_map;
+	unsigned int *swap_cluster_count;
 	struct file *swap_file, *victim;
 	struct address_space *mapping;
 	struct inode *inode;
@@ -1556,7 +1577,8 @@ SYSCALL_DEFINE1(swapoff, const char __us
 		 * sys_swapoff for this swap_info_struct at this point.
 		 */
 		/* re-insert swap space back into swap_list */
-		enable_swap_info(p, p->prio, p->swap_map, frontswap_map_get(p));
+		enable_swap_info(p, p->prio, p->swap_map, p->swap_cluster_count,
+				frontswap_map_get(p));
 		goto out_dput;
 	}
 
@@ -1581,11 +1603,14 @@ SYSCALL_DEFINE1(swapoff, const char __us
 	p->max = 0;
 	swap_map = p->swap_map;
 	p->swap_map = NULL;
+	swap_cluster_count = p->swap_cluster_count;
+	p->swap_cluster_count = NULL;
 	p->flags = 0;
 	frontswap_invalidate_area(type);
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
 	vfree(swap_map);
+	vfree(swap_cluster_count);
 	vfree(frontswap_map_get(p));
 	/* Destroy swap account informatin */
 	swap_cgroup_swapoff(type);
@@ -1896,6 +1921,7 @@ static unsigned long read_swap_header(st
 static int setup_swap_map_and_extents(struct swap_info_struct *p,
 					union swap_header *swap_header,
 					unsigned char *swap_map,
+					unsigned int *swap_cluster_count,
 					unsigned long maxpages,
 					sector_t *span)
 {
@@ -1912,11 +1938,16 @@ static int setup_swap_map_and_extents(st
 		if (page_nr < maxpages) {
 			swap_map[page_nr] = SWAP_MAP_BAD;
 			nr_good_pages--;
+			inc_swap_cluster_count(swap_cluster_count, page_nr);
 		}
 	}
 
+	for (i = maxpages; i < round_up(maxpages, SWAPFILE_CLUSTER); i++)
+		inc_swap_cluster_count(swap_cluster_count, i);
+
 	if (nr_good_pages) {
 		swap_map[0] = SWAP_MAP_BAD;
+		inc_swap_cluster_count(swap_cluster_count, 0);
 		p->max = maxpages;
 		p->pages = nr_good_pages;
 		nr_extents = setup_swap_extents(p, span);
@@ -1946,6 +1977,7 @@ SYSCALL_DEFINE2(swapon, const char __use
 	sector_t span;
 	unsigned long maxpages;
 	unsigned char *swap_map = NULL;
+	unsigned int *swap_cluster_count = NULL;
 	unsigned long *frontswap_map = NULL;
 	struct page *page = NULL;
 	struct inode *inode = NULL;
@@ -2020,12 +2052,19 @@ SYSCALL_DEFINE2(swapon, const char __use
 		goto bad_swap;
 	}
 
+	swap_cluster_count = vzalloc(DIV_ROUND_UP(maxpages, SWAPFILE_CLUSTER) *
+					sizeof(int));
+	if (!swap_cluster_count) {
+		error = -ENOMEM;
+		goto bad_swap;
+	}
+
 	error = swap_cgroup_swapon(p->type, maxpages);
 	if (error)
 		goto bad_swap;
 
 	nr_extents = setup_swap_map_and_extents(p, swap_header, swap_map,
-		maxpages, &span);
+		swap_cluster_count, maxpages, &span);
 	if (unlikely(nr_extents < 0)) {
 		error = nr_extents;
 		goto bad_swap;
@@ -2048,7 +2087,7 @@ SYSCALL_DEFINE2(swapon, const char __use
 	if (swap_flags & SWAP_FLAG_PREFER)
 		prio =
 		  (swap_flags & SWAP_FLAG_PRIO_MASK) >> SWAP_FLAG_PRIO_SHIFT;
-	enable_swap_info(p, prio, swap_map, frontswap_map);
+	enable_swap_info(p, prio, swap_map, swap_cluster_count, frontswap_map);
 
 	printk(KERN_INFO "Adding %uk swap on %s.  "
 			"Priority:%d extents:%d across:%lluk %s%s%s\n",
@@ -2078,6 +2117,7 @@ bad_swap:
 	p->flags = 0;
 	spin_unlock(&swap_lock);
 	vfree(swap_map);
+	vfree(swap_cluster_count);
 	if (swap_file) {
 		if (inode && S_ISREG(inode->i_mode)) {
 			mutex_unlock(&inode->i_mutex);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
