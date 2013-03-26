Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 8D50E6B00BC
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 01:37:15 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id kx1so972405pab.28
        for <linux-mm@kvack.org>; Mon, 25 Mar 2013 22:37:14 -0700 (PDT)
Date: Tue, 26 Mar 2013 13:37:06 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [patch 1/4 v4]swap: change block allocation algorithm for SSD
Message-ID: <20130326053706.GA19646@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, hughd@google.com, aquini@redhat.com

I'm using a fast SSD to do swap. scan_swap_map() sometimes uses up to 20~30%
CPU time (when cluster is hard to find, the CPU time can be up to 80%), which
becomes a bottleneck.  scan_swap_map() scans a byte array to search a 256 page
cluster, which is very slow.

Here I introduced a simple algorithm to search cluster. Since we only care
about 256 pages cluster, we can just use a counter to track if a cluster is
free. Every 256 pages use one int to store the counter. If the counter of a
cluster is 0, the cluster is free. All free clusters will be added to a list,
so searching cluster is very efficient. With this, scap_swap_map() overhead
disappears.

Since searching cluster with a list is easy, we can easily implement a per-cpu
cluster algorithm to do block allocation, which can make swapout more
efficient. This is in my TODO list.

This might help low end SD card swap too. Because if the cluster is aligned, SD
firmware can do flash erase more efficiently.

We only enable the algorithm for SSD. Hard disk swap isn't fast enough and has
downside with the algorithm which might introduce regression (see below).

The patch slightly changes which cluster is choosen. It always adds free
cluster to list tail. This can help wear leveling for low end SSD too. And if
no cluster found, the scan_swap_map() will do search from the end of last
cluster. So if no cluster found, the scan_swap_map() will do search from the
end of last free cluster, which is random. For SSD, this isn't a problem at
all.

Another downside is the cluster must be aligned to 256 pages, which will reduce
the chance to find a cluster. I would expect this isn't a big problem for SSD
because of the non-seek penality. (And this is the reason I only enable the
algorithm for SSD).

V3 -> V4:
clean up

V2 -> V3:
rebase to latest linux-next

V1 -> V2:
1. free cluster is added to a list, which makes searching cluster more efficient
2. only enable the algorithm for SSD.

Signed-off-by: Shaohua Li <shli@fusionio.com>
---
 include/linux/swap.h |    3 
 mm/swapfile.c        |  209 ++++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 200 insertions(+), 12 deletions(-)

Index: linux/include/linux/swap.h
===================================================================
--- linux.orig/include/linux/swap.h	2013-03-22 14:37:51.046400844 +0800
+++ linux/include/linux/swap.h	2013-03-22 14:39:43.408988072 +0800
@@ -185,6 +185,9 @@ struct swap_info_struct {
 	signed char	next;		/* next type on the swap list */
 	unsigned int	max;		/* extent of the swap_map */
 	unsigned char *swap_map;	/* vmalloc'ed array of usage counts */
+	unsigned int *cluster_info;	/* cluster info. Only for SSD */
+	unsigned int free_cluster_head;
+	unsigned int free_cluster_tail;
 	unsigned int lowest_bit;	/* index of first free in swap_map */
 	unsigned int highest_bit;	/* index of last free in swap_map */
 	unsigned int pages;		/* total of usable pages of swap */
Index: linux/mm/swapfile.c
===================================================================
--- linux.orig/mm/swapfile.c	2013-03-22 14:37:51.034400903 +0800
+++ linux/mm/swapfile.c	2013-03-22 14:59:59.741697420 +0800
@@ -184,6 +184,109 @@ static int wait_for_discard(void *word)
 #define SWAPFILE_CLUSTER	256
 #define LATENCY_LIMIT		256
 
+/*
+ * cluster info is a unsigned int, the highest 8 bits stores flags, the low 24
+ * bits stores next cluster if the cluster is free or cluster counter otherwise
+ */
+#define CLUSTER_FLAG_FREE (1 << 0) /* This cluster is free */
+#define CLUSTER_FLAG_NEXT_NULL (1 << 1) /* This cluster has no next cluster */
+#define CLUSTER_NULL (CLUSTER_FLAG_NEXT_NULL << 24)
+static inline unsigned int cluster_flag(unsigned int info)
+{
+	return info >> 24;
+}
+
+static inline void cluster_set_flag(unsigned int *info, unsigned int flag)
+{
+	*info = ((*info) & 0xffffff) | (flag << 24);
+}
+
+static inline unsigned int cluster_count(unsigned int info)
+{
+	return info & 0xffffff;
+}
+
+static inline void cluster_set_count(unsigned int *info, unsigned int c)
+{
+	*info = (cluster_flag(*info) << 24) | c;
+}
+
+static inline unsigned int cluster_next(unsigned int info)
+{
+	return info & 0xffffff;
+}
+
+static inline void cluster_set_next(unsigned int *info, unsigned int n)
+{
+	*info = (cluster_flag(*info) << 24) | n;
+}
+
+static inline bool cluster_is_free(unsigned int info)
+{
+	return cluster_flag(info) & CLUSTER_FLAG_FREE;
+}
+
+static inline void inc_cluster_info_page(struct swap_info_struct *p,
+	unsigned int *cluster_info, unsigned long page_nr)
+{
+	unsigned long idx = page_nr / SWAPFILE_CLUSTER;
+
+	if (!cluster_info)
+		return;
+	if (cluster_is_free(cluster_info[idx])) {
+		VM_BUG_ON(p->free_cluster_head != idx);
+		p->free_cluster_head = cluster_next(cluster_info[idx]);
+		if (p->free_cluster_tail == idx) {
+			p->free_cluster_tail = CLUSTER_NULL;
+			p->free_cluster_head = CLUSTER_NULL;
+		}
+		cluster_set_flag(&cluster_info[idx], 0);
+		cluster_set_count(&cluster_info[idx], 0);
+	}
+
+	VM_BUG_ON(cluster_count(cluster_info[idx]) >= SWAPFILE_CLUSTER);
+	cluster_set_count(&cluster_info[idx],
+		cluster_count(cluster_info[idx]) + 1);
+}
+
+static inline void dec_cluster_info_page(struct swap_info_struct *p,
+	unsigned int *cluster_info, unsigned long page_nr)
+{
+	unsigned long idx = page_nr / SWAPFILE_CLUSTER;
+
+	if (!cluster_info)
+		return;
+
+	VM_BUG_ON(cluster_count(cluster_info[idx]) == 0);
+	cluster_set_count(&cluster_info[idx],
+		cluster_count(cluster_info[idx]) - 1);
+
+	if (cluster_count(cluster_info[idx]) == 0) {
+		cluster_set_flag(&cluster_info[idx], CLUSTER_FLAG_FREE);
+		if (p->free_cluster_head == CLUSTER_NULL) {
+			p->free_cluster_head = idx;
+			p->free_cluster_tail = idx;
+		} else {
+			cluster_set_next(&cluster_info[p->free_cluster_tail],
+				idx);
+			p->free_cluster_tail = idx;
+		}
+	}
+}
+
+/*
+ * It's possible scan_swap_map() uses a free cluster in the middle of free
+ * cluster list. Avoiding such abuse to avoid list corruption.
+ */
+static inline bool scan_swap_map_recheck_cluster(struct swap_info_struct *si,
+	unsigned long offset)
+{
+	offset /= SWAPFILE_CLUSTER;
+	return si->free_cluster_head != CLUSTER_NULL &&
+		offset != si->free_cluster_head &&
+		cluster_is_free(si->cluster_info[offset]);
+}
+
 static unsigned long scan_swap_map(struct swap_info_struct *si,
 				   unsigned char usage)
 {
@@ -225,6 +328,24 @@ static unsigned long scan_swap_map(struc
 			si->lowest_alloc = si->max;
 			si->highest_alloc = 0;
 		}
+check_cluster:
+		if (si->free_cluster_head != CLUSTER_NULL) {
+			offset = si->free_cluster_head * SWAPFILE_CLUSTER;
+			last_in_cluster = offset + SWAPFILE_CLUSTER - 1;
+			si->cluster_next = offset;
+			si->cluster_nr = SWAPFILE_CLUSTER - 1;
+			found_free_cluster = 1;
+			goto checks;
+		} else if (si->cluster_info) {
+			/*
+			 * Checking free cluster is fast enough, we can do the
+			 * check every time
+			 */
+			si->cluster_nr = 0;
+			si->lowest_alloc = 0;
+			goto checks;
+		}
+
 		spin_unlock(&si->lock);
 
 		/*
@@ -285,6 +406,8 @@ static unsigned long scan_swap_map(struc
 	}
 
 checks:
+	if (scan_swap_map_recheck_cluster(si, offset))
+		goto check_cluster;
 	if (!(si->flags & SWP_WRITEOK))
 		goto no_page;
 	if (!si->highest_bit)
@@ -317,6 +440,7 @@ checks:
 		si->highest_bit = 0;
 	}
 	si->swap_map[offset] = usage;
+	inc_cluster_info_page(si, si->cluster_info, offset);
 	si->cluster_next = offset + 1;
 	si->flags -= SWP_SCANNING;
 
@@ -600,6 +724,7 @@ static unsigned char swap_entry_free(str
 
 	/* free if no reference */
 	if (!usage) {
+		dec_cluster_info_page(p, p->cluster_info, offset);
 		if (offset < p->lowest_bit)
 			p->lowest_bit = offset;
 		if (offset > p->highest_bit)
@@ -1510,6 +1635,7 @@ static int setup_swap_extents(struct swa
 
 static void _enable_swap_info(struct swap_info_struct *p, int prio,
 				unsigned char *swap_map,
+				unsigned int *cluster_info,
 				unsigned long *frontswap_map)
 {
 	int i, prev;
@@ -1519,6 +1645,7 @@ static void _enable_swap_info(struct swa
 	else
 		p->prio = --least_priority;
 	p->swap_map = swap_map;
+	p->cluster_info = cluster_info;
 	frontswap_map_set(p, frontswap_map);
 	p->flags |= SWP_WRITEOK;
 	atomic_long_add(p->pages, &nr_swap_pages);
@@ -1540,11 +1667,12 @@ static void _enable_swap_info(struct swa
 
 static void enable_swap_info(struct swap_info_struct *p, int prio,
 				unsigned char *swap_map,
+				unsigned int *cluster_info,
 				unsigned long *frontswap_map)
 {
 	spin_lock(&swap_lock);
 	spin_lock(&p->lock);
-	_enable_swap_info(p, prio, swap_map, frontswap_map);
+	_enable_swap_info(p, prio, swap_map, cluster_info, frontswap_map);
 	frontswap_init(p->type);
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
@@ -1554,7 +1682,8 @@ static void reinsert_swap_info(struct sw
 {
 	spin_lock(&swap_lock);
 	spin_lock(&p->lock);
-	_enable_swap_info(p, p->prio, p->swap_map, frontswap_map_get(p));
+	_enable_swap_info(p, p->prio, p->swap_map, p->cluster_info,
+					frontswap_map_get(p));
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
 }
@@ -1563,6 +1692,7 @@ SYSCALL_DEFINE1(swapoff, const char __us
 {
 	struct swap_info_struct *p = NULL;
 	unsigned char *swap_map;
+	unsigned int *cluster_info;
 	struct file *swap_file, *victim;
 	struct address_space *mapping;
 	struct inode *inode;
@@ -1661,12 +1791,15 @@ SYSCALL_DEFINE1(swapoff, const char __us
 	p->max = 0;
 	swap_map = p->swap_map;
 	p->swap_map = NULL;
+	cluster_info = p->cluster_info;
+	p->cluster_info = NULL;
 	p->flags = 0;
 	frontswap_invalidate_area(type);
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
 	vfree(swap_map);
+	vfree(cluster_info);
 	vfree(frontswap_map_get(p));
 	/* Destroy swap account informatin */
 	swap_cgroup_swapoff(type);
@@ -1979,15 +2112,21 @@ static unsigned long read_swap_header(st
 static int setup_swap_map_and_extents(struct swap_info_struct *p,
 					union swap_header *swap_header,
 					unsigned char *swap_map,
+					unsigned int *cluster_info,
 					unsigned long maxpages,
 					sector_t *span)
 {
 	int i;
 	unsigned int nr_good_pages;
 	int nr_extents;
+	unsigned long nr_clusters = DIV_ROUND_UP(maxpages, SWAPFILE_CLUSTER);
+	unsigned long idx = p->cluster_next / SWAPFILE_CLUSTER;
 
 	nr_good_pages = maxpages - 1;	/* omit header page */
 
+	p->free_cluster_head = CLUSTER_NULL;
+	p->free_cluster_tail = CLUSTER_NULL;
+
 	for (i = 0; i < swap_header->info.nr_badpages; i++) {
 		unsigned int page_nr = swap_header->info.badpages[i];
 		if (page_nr == 0 || page_nr > swap_header->info.last_page)
@@ -1995,11 +2134,25 @@ static int setup_swap_map_and_extents(st
 		if (page_nr < maxpages) {
 			swap_map[page_nr] = SWAP_MAP_BAD;
 			nr_good_pages--;
+			/*
+			 * Haven't marked the cluster free yet, no list
+			 * operation involved
+			 */
+			inc_cluster_info_page(p, cluster_info, page_nr);
 		}
 	}
 
+	/* Haven't marked the cluster free yet, no list operation involved */
+	for (i = maxpages; i < round_up(maxpages, SWAPFILE_CLUSTER); i++)
+		inc_cluster_info_page(p, cluster_info, i);
+
 	if (nr_good_pages) {
 		swap_map[0] = SWAP_MAP_BAD;
+		/*
+		 * Not mark the cluster free yet, no list
+		 * operation involved
+		 */
+		inc_cluster_info_page(p, cluster_info, 0);
 		p->max = maxpages;
 		p->pages = nr_good_pages;
 		nr_extents = setup_swap_extents(p, span);
@@ -2012,6 +2165,27 @@ static int setup_swap_map_and_extents(st
 		return -EINVAL;
 	}
 
+	if (!cluster_info)
+		return nr_extents;
+
+	for (i = 0; i < nr_clusters; i++) {
+		if (!cluster_count(cluster_info[idx])) {
+			cluster_set_flag(&cluster_info[idx], CLUSTER_FLAG_FREE);
+			if (p->free_cluster_head == CLUSTER_NULL) {
+				p->free_cluster_head = idx;
+				p->free_cluster_tail = idx;
+			} else {
+				cluster_set_next(
+					&cluster_info[p->free_cluster_tail],
+					idx);
+				p->free_cluster_tail = idx;
+			}
+		}
+		idx++;
+		if (idx == nr_clusters)
+			idx = 0;
+	}
+
 	return nr_extents;
 }
 
@@ -2029,6 +2203,7 @@ SYSCALL_DEFINE2(swapon, const char __use
 	sector_t span;
 	unsigned long maxpages;
 	unsigned char *swap_map = NULL;
+	unsigned int *cluster_info = NULL;
 	unsigned long *frontswap_map = NULL;
 	struct page *page = NULL;
 	struct inode *inode = NULL;
@@ -2102,13 +2277,28 @@ SYSCALL_DEFINE2(swapon, const char __use
 		error = -ENOMEM;
 		goto bad_swap;
 	}
+	if (p->bdev && blk_queue_nonrot(bdev_get_queue(p->bdev))) {
+		p->flags |= SWP_SOLIDSTATE;
+		/*
+		 * select a random position to start with to help wear leveling
+		 * SSD
+		 */
+		p->cluster_next = 1 + (prandom_u32() % p->highest_bit);
+
+		cluster_info = vzalloc(DIV_ROUND_UP(maxpages,
+			SWAPFILE_CLUSTER) * sizeof(*cluster_info));
+		if (!cluster_info) {
+			error = -ENOMEM;
+			goto bad_swap;
+		}
+	}
 
 	error = swap_cgroup_swapon(p->type, maxpages);
 	if (error)
 		goto bad_swap;
 
 	nr_extents = setup_swap_map_and_extents(p, swap_header, swap_map,
-		maxpages, &span);
+		cluster_info, maxpages, &span);
 	if (unlikely(nr_extents < 0)) {
 		error = nr_extents;
 		goto bad_swap;
@@ -2117,21 +2307,15 @@ SYSCALL_DEFINE2(swapon, const char __use
 	if (frontswap_enabled)
 		frontswap_map = vzalloc(maxpages / sizeof(long));
 
-	if (p->bdev) {
-		if (blk_queue_nonrot(bdev_get_queue(p->bdev))) {
-			p->flags |= SWP_SOLIDSTATE;
-			p->cluster_next = 1 + (random32() % p->highest_bit);
-		}
-		if ((swap_flags & SWAP_FLAG_DISCARD) && discard_swap(p) == 0)
-			p->flags |= SWP_DISCARDABLE;
-	}
+	if (p->bdev && (swap_flags & SWAP_FLAG_DISCARD) && discard_swap(p) == 0)
+		p->flags |= SWP_DISCARDABLE;
 
 	mutex_lock(&swapon_mutex);
 	prio = -1;
 	if (swap_flags & SWAP_FLAG_PREFER)
 		prio =
 		  (swap_flags & SWAP_FLAG_PRIO_MASK) >> SWAP_FLAG_PRIO_SHIFT;
-	enable_swap_info(p, prio, swap_map, frontswap_map);
+	enable_swap_info(p, prio, swap_map, cluster_info, frontswap_map);
 
 	printk(KERN_INFO "Adding %uk swap on %s.  "
 			"Priority:%d extents:%d across:%lluk %s%s%s\n",
@@ -2161,6 +2345,7 @@ bad_swap:
 	p->flags = 0;
 	spin_unlock(&swap_lock);
 	vfree(swap_map);
+	vfree(cluster_info);
 	if (swap_file) {
 		if (inode && S_ISREG(inode->i_mode)) {
 			mutex_unlock(&inode->i_mutex);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
