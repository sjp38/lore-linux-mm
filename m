Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id DEB146B0036
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 19:51:34 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [patch 1/4 v5]swap: change block allocation algorithm for SSD
Date: Thu, 27 Jun 2013 20:50:53 -0300
Message-Id: <205cb7b2137df7528e39e999848ae6e1a2c3ab44.1372376365.git.aquini@redhat.com>
In-Reply-To: <20130624110324.GA15796@kernel.org>
References: <20130624110324.GA15796@kernel.org>
In-Reply-To: <20130624110324.GA15796@kernel.org>
References: <20130624110324.GA15796@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shli@kernel.org
Cc: akpm@linux-foundation.org, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, hughd@google.com, linux-mm@kvack.org

Hi Shaohua,

Would you consider rebasing your work in the latest linux-next to
leverage the following commit:
7bc1e13 swap: discard while swapping only if SWAP_FLAG_DISCARD_PAGES

As well as merging the following changes to this patch of yours?

The major reason for this 2nd suggestion is due to what's described
at http://lwn.net/Articles/478657/

Thanks in advance!
Rafael

---
 include/linux/swap.h |   3 +
 mm/swapfile.c        | 242 ++++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 233 insertions(+), 12 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index d95cde5..aaea27e 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -191,6 +191,9 @@ struct swap_info_struct {
 	signed char	next;		/* next type on the swap list */
 	unsigned int	max;		/* extent of the swap_map */
 	unsigned char *swap_map;	/* vmalloc'ed array of usage counts */
+	unsigned int *cluster_info;	/* cluster info. Only for SSD */
+	unsigned int free_cluster_head;
+	unsigned int free_cluster_tail;
 	unsigned int lowest_bit;	/* index of first free in swap_map */
 	unsigned int highest_bit;	/* index of last free in swap_map */
 	unsigned int pages;		/* total of usable pages of swap */
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 36af6ee..5d0a7d0 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -184,6 +184,141 @@ static int wait_for_discard(void *word)
 #define SWAPFILE_CLUSTER	256
 #define LATENCY_LIMIT		256
 
+/*
+ * Here is the way we organize and use the swap cluster info (unsigned int):
+ *  31      23                      0
+ *   +-------+----------------------+
+ *   | flags |         data         |
+ *   +-------+----------------------+
+ *
+ *   * the  8 leftmost bits are reserved for flags usage;
+ *   * the 24 rightmost bits are used as follows:
+ *      - to store the counter usage, if !SWP_CLUSTER_FLAG_FREE; or
+ *      - to store the next cluster, when the usage counter drops to 0 and
+ *        SWP_CLUSTER_FLAG_FREE is set.
+ */
+#define SWP_CLUSTER_FLAGS_SHIFT    24
+#define SWP_CLUSTER_FLAGS_MASK     (~((1U << SWP_CLUSTER_FLAGS_SHIFT) - 1))
+#define SWP_CLUSTER_FLAG_FREE      (1 << 0)
+#define SWP_CLUSTER_FLAG_NEXT_NULL (1 << 1)
+#define SWP_CLUSTER_NULL (SWP_CLUSTER_FLAG_NEXT_NULL << SWP_CLUSTER_FLAGS_SHIFT)
+
+static inline unsigned int __swap_cluster_get_flags(unsigned int info)
+{
+	return info >> SWP_CLUSTER_FLAGS_SHIFT;
+}
+
+static inline unsigned int __swap_cluster_get_data(unsigned int info)
+{
+	return info & ~SWP_CLUSTER_FLAGS_MASK;
+}
+
+static inline unsigned int __swap_cluster_set_flag(unsigned int info,
+						   unsigned int flag)
+{
+	return __swap_cluster_get_data(info) | (flag << SWP_CLUSTER_FLAGS_SHIFT);
+}
+
+static inline unsigned int __swap_cluster_set_data(unsigned int info,
+						  unsigned int data)
+{
+	return (__swap_cluster_get_flags(info) << SWP_CLUSTER_FLAGS_SHIFT) |data;
+}
+
+static inline void swap_cluster_set_flag(unsigned int *info, unsigned int flags)
+{
+	*info = __swap_cluster_set_flag(*info, flags);
+}
+
+static inline unsigned int swap_cluster_count(unsigned int info)
+{
+	return __swap_cluster_get_data(info);
+}
+
+static inline void swap_cluster_set_count(unsigned int *info, unsigned int count)
+{
+	*info = __swap_cluster_set_data(*info, count);
+}
+
+static inline unsigned int swap_cluster_next(unsigned int info)
+{
+	return __swap_cluster_get_data(info);
+}
+
+static inline void swap_cluster_set_next(unsigned int *info, unsigned int next)
+{
+	*info =  __swap_cluster_set_data(*info, next);
+}
+
+static inline bool swap_cluster_is_free(unsigned int info)
+{
+	return !(!(__swap_cluster_get_flags(info) & SWP_CLUSTER_FLAG_FREE));
+}
+
+static void swap_cluster_info_inc_page(struct swap_info_struct *p,
+					     unsigned int *cluster_info,
+					     unsigned long page_nr)
+{
+	unsigned long idx = page_nr / SWAPFILE_CLUSTER;
+
+	if (!cluster_info)
+		return;
+	if (swap_cluster_is_free(cluster_info[idx])) {
+		VM_BUG_ON(p->free_cluster_head != idx);
+		p->free_cluster_head = swap_cluster_next(cluster_info[idx]);
+		if (p->free_cluster_tail == idx) {
+			p->free_cluster_tail = SWP_CLUSTER_NULL;
+			p->free_cluster_head = SWP_CLUSTER_NULL;
+		}
+		swap_cluster_set_flag(&cluster_info[idx], 0);
+		swap_cluster_set_count(&cluster_info[idx], 0);
+	}
+
+	VM_BUG_ON(swap_cluster_count(cluster_info[idx]) >= SWAPFILE_CLUSTER);
+	swap_cluster_set_count(&cluster_info[idx],
+			      swap_cluster_count(cluster_info[idx]) + 1);
+}
+
+static void swap_cluster_info_dec_page(struct swap_info_struct *p,
+					     unsigned int *cluster_info,
+					     unsigned long page_nr)
+{
+	unsigned long idx = page_nr / SWAPFILE_CLUSTER;
+
+	if (!cluster_info)
+		return;
+
+	VM_BUG_ON(swap_cluster_count(cluster_info[idx]) == 0);
+	swap_cluster_set_count(&cluster_info[idx],
+			      swap_cluster_count(cluster_info[idx]) - 1);
+
+	if (swap_cluster_count(cluster_info[idx]) == 0) {
+		swap_cluster_set_flag(&cluster_info[idx], SWP_CLUSTER_FLAG_FREE);
+		if (p->free_cluster_head == SWP_CLUSTER_NULL) {
+			p->free_cluster_head = idx;
+			p->free_cluster_tail = idx;
+		} else {
+		       swap_cluster_set_next(&cluster_info[p->free_cluster_tail],
+					    idx);
+			p->free_cluster_tail = idx;
+		}
+	}
+}
+
+/*
+ * It's possible for scan_swap_map() attempting to use a free cluster in
+ * the middle of free cluster list. We must check for such occurrences
+ * to avoid cluster list corruption.
+ */
+static inline bool scan_swap_map_recheck_cluster(struct swap_info_struct *si,
+	unsigned long offset)
+{
+	offset /= SWAPFILE_CLUSTER;
+	return si->free_cluster_head != SWP_CLUSTER_NULL &&
+		offset != si->free_cluster_head &&
+		swap_cluster_is_free(si->cluster_info[offset]);
+}
+
 static unsigned long scan_swap_map(struct swap_info_struct *si,
 				   unsigned char usage)
 {
@@ -225,6 +360,24 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
 			si->lowest_alloc = si->max;
 			si->highest_alloc = 0;
 		}
+check_cluster:
+		if (si->free_cluster_head != SWP_CLUSTER_NULL) {
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
@@ -285,6 +438,8 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
 	}
 
 checks:
+	if (scan_swap_map_recheck_cluster(si, offset))
+		goto check_cluster;
 	if (!(si->flags & SWP_WRITEOK))
 		goto no_page;
 	if (!si->highest_bit)
@@ -317,6 +472,7 @@ checks:
 		si->highest_bit = 0;
 	}
 	si->swap_map[offset] = usage;
+	swap_cluster_info_inc_page(si, si->cluster_info, offset);
 	si->cluster_next = offset + 1;
 	si->flags -= SWP_SCANNING;
 
@@ -600,6 +756,7 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 
 	/* free if no reference */
 	if (!usage) {
+		swap_cluster_info_dec_page(p, p->cluster_info, offset);
 		if (offset < p->lowest_bit)
 			p->lowest_bit = offset;
 		if (offset > p->highest_bit)
@@ -1509,7 +1666,8 @@ static int setup_swap_extents(struct swap_info_struct *sis, sector_t *span)
 }
 
 static void _enable_swap_info(struct swap_info_struct *p, int prio,
-				unsigned char *swap_map)
+				unsigned char *swap_map,
+				unsigned int *cluster_info)
 {
 	int i, prev;
 
@@ -1518,6 +1676,7 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 	else
 		p->prio = --least_priority;
 	p->swap_map = swap_map;
+	p->cluster_info = cluster_info;
 	p->flags |= SWP_WRITEOK;
 	atomic_long_add(p->pages, &nr_swap_pages);
 	total_swap_pages += p->pages;
@@ -1538,12 +1697,13 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 
 static void enable_swap_info(struct swap_info_struct *p, int prio,
 				unsigned char *swap_map,
+				unsigned int *cluster_info,
 				unsigned long *frontswap_map)
 {
 	frontswap_init(p->type, frontswap_map);
 	spin_lock(&swap_lock);
 	spin_lock(&p->lock);
-	 _enable_swap_info(p, prio, swap_map);
+	 _enable_swap_info(p, prio, swap_map, cluster_info);
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
 }
@@ -1552,7 +1712,7 @@ static void reinsert_swap_info(struct swap_info_struct *p)
 {
 	spin_lock(&swap_lock);
 	spin_lock(&p->lock);
-	_enable_swap_info(p, p->prio, p->swap_map);
+	_enable_swap_info(p, p->prio, p->swap_map, p->cluster_info);
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
 }
@@ -1561,6 +1721,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 {
 	struct swap_info_struct *p = NULL;
 	unsigned char *swap_map;
+	unsigned int *cluster_info;
 	unsigned long *frontswap_map;
 	struct file *swap_file, *victim;
 	struct address_space *mapping;
@@ -1660,6 +1821,8 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	p->max = 0;
 	swap_map = p->swap_map;
 	p->swap_map = NULL;
+	cluster_info = p->cluster_info;
+	p->cluster_info = NULL;
 	p->flags = 0;
 	frontswap_map = frontswap_map_get(p);
 	frontswap_map_set(p, NULL);
@@ -1668,6 +1831,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	frontswap_invalidate_area(type);
 	mutex_unlock(&swapon_mutex);
 	vfree(swap_map);
+	vfree(cluster_info);
 	vfree(frontswap_map);
 	/* Destroy swap account informatin */
 	swap_cgroup_swapoff(type);
@@ -1980,15 +2144,21 @@ static unsigned long read_swap_header(struct swap_info_struct *p,
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
 
+	p->free_cluster_head = SWP_CLUSTER_NULL;
+	p->free_cluster_tail = SWP_CLUSTER_NULL;
+
 	for (i = 0; i < swap_header->info.nr_badpages; i++) {
 		unsigned int page_nr = swap_header->info.badpages[i];
 		if (page_nr == 0 || page_nr > swap_header->info.last_page)
@@ -1996,11 +2166,25 @@ static int setup_swap_map_and_extents(struct swap_info_struct *p,
 		if (page_nr < maxpages) {
 			swap_map[page_nr] = SWAP_MAP_BAD;
 			nr_good_pages--;
+			/*
+			 * Haven't marked the cluster free yet, no list
+			 * operation involved
+			 */
+			swap_cluster_info_inc_page(p, cluster_info, page_nr);
 		}
 	}
 
+	/* Haven't marked the cluster free yet, no list operation involved */
+	for (i = maxpages; i < round_up(maxpages, SWAPFILE_CLUSTER); i++)
+		swap_cluster_info_inc_page(p, cluster_info, i);
+
 	if (nr_good_pages) {
 		swap_map[0] = SWAP_MAP_BAD;
+		/*
+		 * Don't mark the cluster free yet, no list
+		 * operation involved
+		 */
+		swap_cluster_info_inc_page(p, cluster_info, 0);
 		p->max = maxpages;
 		p->pages = nr_good_pages;
 		nr_extents = setup_swap_extents(p, span);
@@ -2013,6 +2197,28 @@ static int setup_swap_map_and_extents(struct swap_info_struct *p,
 		return -EINVAL;
 	}
 
+	if (!cluster_info)
+		return nr_extents;
+
+	for (i = 0; i < nr_clusters; i++) {
+		if (!swap_cluster_count(cluster_info[idx])) {
+			swap_cluster_set_flag(&cluster_info[idx],
+					     SWP_CLUSTER_FLAG_FREE);
+			if (p->free_cluster_head == SWP_CLUSTER_NULL) {
+				p->free_cluster_head = idx;
+				p->free_cluster_tail = idx;
+			} else {
+				swap_cluster_set_next(
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
 
@@ -2044,6 +2250,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	sector_t span;
 	unsigned long maxpages;
 	unsigned char *swap_map = NULL;
+	unsigned int *cluster_info = NULL;
 	unsigned long *frontswap_map = NULL;
 	struct page *page = NULL;
 	struct inode *inode = NULL;
@@ -2117,13 +2324,28 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
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
@@ -2132,13 +2354,8 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	if (frontswap_enabled)
 		frontswap_map = vzalloc(BITS_TO_LONGS(maxpages) * sizeof(long));
 
-	if (p->bdev) {
-		if (blk_queue_nonrot(bdev_get_queue(p->bdev))) {
-			p->flags |= SWP_SOLIDSTATE;
-			p->cluster_next = 1 + (prandom_u32() % p->highest_bit);
-		}
-
-		if ((swap_flags & SWAP_FLAG_DISCARD) && swap_discardable(p)) {
+	if (p->bdev &&
+	    (swap_flags & SWAP_FLAG_DISCARD) && swap_discardable(p)) {
 			/*
 			 * When discard is enabled for swap with no particular
 			 * policy flagged, we set all swap discard flags here in
@@ -2175,7 +2392,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	if (swap_flags & SWAP_FLAG_PREFER)
 		prio =
 		  (swap_flags & SWAP_FLAG_PRIO_MASK) >> SWAP_FLAG_PRIO_SHIFT;
-	enable_swap_info(p, prio, swap_map, frontswap_map);
+	enable_swap_info(p, prio, swap_map, cluster_info, frontswap_map);
 
 	printk(KERN_INFO "Adding %uk swap on %s.  "
 			"Priority:%d extents:%d across:%lluk %s%s%s%s%s\n",
@@ -2207,6 +2424,7 @@ bad_swap:
 	p->flags = 0;
 	spin_unlock(&swap_lock);
 	vfree(swap_map);
+	vfree(cluster_info);
 	if (swap_file) {
 		if (inode && S_ISREG(inode->i_mode)) {
 			mutex_unlock(&inode->i_mutex);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
