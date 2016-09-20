Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BCBD56B0253
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 22:01:40 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c84so8379960pfj.2
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 19:01:40 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 62si67165665pfc.60.2016.09.19.19.01.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Sep 2016 19:01:39 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -v3 01/10] mm, swap: Make swap cluster size same of THP size on x86_64
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
	<1473266769-2155-2-git-send-email-ying.huang@intel.com>
	<57D0FB10.5010609@linux.vnet.ibm.com>
	<20160919170951.GA1059@cmpxchg.org>
Date: Tue, 20 Sep 2016 10:01:30 +0800
In-Reply-To: <20160919170951.GA1059@cmpxchg.org> (Johannes Weiner's message of
	"Mon, 19 Sep 2016 10:09:51 -0700")
Message-ID: <87y42n2uth.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

Hi, Johannes,

Johannes Weiner <hannes@cmpxchg.org> writes:
> On Thu, Sep 08, 2016 at 11:15:52AM +0530, Anshuman Khandual wrote:
>> On 09/07/2016 10:16 PM, Huang, Ying wrote:
>> > From: Huang Ying <ying.huang@intel.com>
>> > 
>> > In this patch, the size of the swap cluster is changed to that of the
>> > THP (Transparent Huge Page) on x86_64 architecture (512).  This is for
>> > the THP swap support on x86_64.  Where one swap cluster will be used to
>> > hold the contents of each THP swapped out.  And some information of the
>> > swapped out THP (such as compound map count) will be recorded in the
>> > swap_cluster_info data structure.
>> > 
>> > For other architectures which want THP swap support, THP_SWAP_CLUSTER
>> > need to be selected in the Kconfig file for the architecture.
>> > 
>> > In effect, this will enlarge swap cluster size by 2 times on x86_64.
>> > Which may make it harder to find a free cluster when the swap space
>> > becomes fragmented.  So that, this may reduce the continuous swap space
>> > allocation and sequential write in theory.  The performance test in 0day
>> > shows no regressions caused by this.
>> 
>> This patch needs to be split into two separate ones
>> 
>> (1) Add THP_SWAP_CLUSTER config option
>> (2) Enable CONFIG_THP_SWAP_CLUSTER for X86_64
>
> No, don't do that. This is a bit of an anti-pattern in this series,
> where it introduces a thing in one patch, and a user for it in a later
> patch. However, in order to judge whether that thing is good or not, I
> need to know how exactly it's being used.
>
> So, please, split your series into logical steps, not geographical
> ones. When you introduce a function, config option, symbol, add it
> along with the code that actually *uses* it, in the same patch.
>
> It goes for this patch, but also stuff like the memcg accounting
> functions, get_huge_swap_page() etc.
>
> Start with the logical change, then try to isolate independent changes
> that could make sense even without the rest of the series. If that
> results in a large patch, then so be it. If a big change is hard to
> review, then making me switch back and forth between emails will make
> it harder, not easier, to make make sense of it.

It appears all patches other than [10/10] in the series is used by the
last patch [10/10], directly or indirectly.  And Without [10/10], they
don't make much sense.  So you suggest me to use one large patch?
Something like below?  Does that help you to review?

If other reviewers think this help them to review the code too, I will
send out a formal new version with better patch description.

Best Regards,
Huang, Ying

----------------------------------------------------------->
This patch is to optimize the performance of Transparent Huge Page
(THP) swap.

Recently, the performance of the storage devices improved so fast that
we cannot saturate the disk bandwidth when do page swap out even on a
high-end server machine.  Because the performance of the storage
device improved faster than that of CPU.  And it seems that the trend
will not change in the near future.  On the other hand, the THP
becomes more and more popular because of increased memory size.  So it
becomes necessary to optimize THP swap performance.

The advantages of the THP swap support include:

- Batch the swap operations for the THP to reduce lock
  acquiring/releasing, including allocating/freeing the swap space,
  adding/deleting to/from the swap cache, and writing/reading the swap
  space, etc.  This will help improve the performance of the THP swap.

- The THP swap space read/write will be 2M sequential IO.  It is
  particularly helpful for the swap read, which usually are 4k random
  IO.  This will improve the performance of the THP swap too.

- It will help the memory fragmentation, especially when the THP is
  heavily used by the applications.  The 2M continuous pages will be
  free up after THP swapping out.


This patch is based on 8/31 head of mmotm/master.

This patch is the first step for the THP swap support.  The plan is
to delay splitting THP step by step, finally avoid splitting THP
during the THP swapping out and swap out/in the THP as a whole.

As the first step, in this patch, the splitting huge page is
delayed from almost the first step of swapping out to after allocating
the swap space for the THP and adding the THP into the swap cache.
This will reduce lock acquiring/releasing for the locks used for the
swap cache management.

With the patch, the swap out throughput improves 12.1% (from about
1.12GB/s to about 1.25GB/s) in the vm-scalability swap-w-seq test case
with 16 processes.  The test is done on a Xeon E5 v3 system.  The swap
device used is a RAM simulated PMEM (persistent memory) device.  To
test the sequential swapping out, the test case uses 16 processes,
which sequentially allocate and write to the anonymous pages until the
RAM and part of the swap device is used up.

The detailed compare result is as follow,

base             base+patch
---------------- -------------------------- 
         %stddev     %change         %stddev
             \          |                \  
   1118821 A+-  0%     +12.1%    1254241 A+-  1%  vmstat.swap.so
   2460636 A+-  1%     +10.6%    2720983 A+-  1%  vm-scalability.throughput
    308.79 A+-  1%      -7.9%     284.53 A+-  1%  vm-scalability.time.elapsed_time
      1639 A+-  4%    +232.3%       5446 A+-  1%  meminfo.SwapCached
      0.70 A+-  3%      +8.7%       0.77 A+-  5%  perf-stat.ipc
      9.82 A+-  8%     -31.6%       6.72 A+-  2%  perf-profile.cycles-pp._raw_spin_lock_irq.__add_to_swap_cache.add_to_swap_cache.add_to_swap.shrink_page_list


>From the swap out throughput number, we can find, even tested on a RAM
simulated PMEM (Persistent Memory) device, the swap out throughput can
reach only about 1.1GB/s.  While, in the file IO test, the sequential
write throughput of an Intel P3700 SSD can reach about 1.8GB/s
steadily.  And according the following URL,

https://www-ssl.intel.com/content/www/us/en/solid-state-drives/intel-ssd-dc-family-for-pcie.html

The sequential write throughput of Intel P3608 SSD can reach about
3.0GB/s, while the random read IOPS can reach about 850k.  It is clear
that the bottleneck has moved from the disk to the kernel swap
component itself.

The improved storage device performance should have made the swap
becomes a better feature than before with better performance.  But
because of the issues of kernel swap component itself, the swap
performance is still kept at the low level.  That prevents the swap
feature to be used by more users.  And this in turn causes few kernel
developers think it is necessary to optimize kernel swap component.
To break the loop, we need to optimize the performance of kernel swap
component.  Optimize the THP swap performance is part of it.


Changelog:

v3:

- Per Andrew's suggestion, used a more systematical way to determine
  whether to enable THP swap optimization
- Per Andrew's comments, moved as much as possible code into
  #ifdef CONFIG_TRANSPARENT_HUGE_PAGE/#endif or "if (PageTransHuge())"
- Fixed some coding style warning.

v2:

- Original [1/11] sent separately and merged
- Use switch in 10/10 per Hiff's suggestion

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 arch/x86/Kconfig            |    1 
 include/linux/huge_mm.h     |    6 +
 include/linux/page-flags.h  |    2 
 include/linux/swap.h        |   45 ++++++-
 include/linux/swap_cgroup.h |    6 -
 mm/Kconfig                  |   13 ++
 mm/huge_memory.c            |   26 +++-
 mm/memcontrol.c             |   55 +++++----
 mm/shmem.c                  |    2 
 mm/swap_cgroup.c            |   78 ++++++++++---
 mm/swap_state.c             |  124 +++++++++++++++++----
 mm/swapfile.c               |  259 ++++++++++++++++++++++++++++++++------------
 12 files changed, 471 insertions(+), 146 deletions(-)

--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -164,6 +164,7 @@ config X86
 	select HAVE_STACK_VALIDATION		if X86_64
 	select ARCH_USES_HIGH_VMA_FLAGS		if X86_INTEL_MEMORY_PROTECTION_KEYS
 	select ARCH_HAS_PKEYS			if X86_INTEL_MEMORY_PROTECTION_KEYS
+	select ARCH_USES_THP_SWAP_CLUSTER	if X86_64
 
 config INSTRUCTION_DECODER
 	def_bool y
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -503,6 +503,19 @@ config FRONTSWAP
 
 	  If unsure, say Y to enable frontswap.
 
+config ARCH_USES_THP_SWAP_CLUSTER
+	bool
+	default n
+
+config THP_SWAP_CLUSTER
+	bool
+	depends on SWAP && TRANSPARENT_HUGEPAGE && ARCH_USES_THP_SWAP_CLUSTER
+	default y
+	help
+	  Use one swap cluster to hold the contents of the THP
+	  (Transparent Huge Page) swapped out.  The size of the swap
+	  cluster will be same as that of THP.
+
 config CMA
 	bool "Contiguous Memory Allocator"
 	depends on HAVE_MEMBLOCK && MMU
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -196,7 +196,11 @@ static void discard_swap_cluster(struct
 	}
 }
 
+#ifdef CONFIG_THP_SWAP_CLUSTER
+#define SWAPFILE_CLUSTER	(HPAGE_SIZE / PAGE_SIZE)
+#else
 #define SWAPFILE_CLUSTER	256
+#endif
 #define LATENCY_LIMIT		256
 
 static inline void cluster_set_flag(struct swap_cluster_info *info,
@@ -322,6 +326,14 @@ static void swap_cluster_schedule_discar
 	schedule_work(&si->discard_work);
 }
 
+static void __free_cluster(struct swap_info_struct *si, unsigned long idx)
+{
+	struct swap_cluster_info *ci = si->cluster_info;
+
+	cluster_set_flag(ci + idx, CLUSTER_FLAG_FREE);
+	cluster_list_add_tail(&si->free_clusters, ci, idx);
+}
+
 /*
  * Doing discard actually. After a cluster discard is finished, the cluster
  * will be added to free cluster list. caller should hold si->lock.
@@ -341,8 +353,7 @@ static void swap_do_scheduled_discard(st
 				SWAPFILE_CLUSTER);
 
 		spin_lock(&si->lock);
-		cluster_set_flag(&info[idx], CLUSTER_FLAG_FREE);
-		cluster_list_add_tail(&si->free_clusters, info, idx);
+		__free_cluster(si, idx);
 		memset(si->swap_map + idx * SWAPFILE_CLUSTER,
 				0, SWAPFILE_CLUSTER);
 	}
@@ -359,6 +370,34 @@ static void swap_discard_work(struct wor
 	spin_unlock(&si->lock);
 }
 
+static void alloc_cluster(struct swap_info_struct *si, unsigned long idx)
+{
+	struct swap_cluster_info *ci = si->cluster_info;
+
+	VM_BUG_ON(cluster_list_first(&si->free_clusters) != idx);
+	cluster_list_del_first(&si->free_clusters, ci);
+	cluster_set_count_flag(ci + idx, 0, 0);
+}
+
+static void free_cluster(struct swap_info_struct *si, unsigned long idx)
+{
+	struct swap_cluster_info *ci = si->cluster_info + idx;
+
+	VM_BUG_ON(cluster_count(ci) != 0);
+	/*
+	 * If the swap is discardable, prepare discard the cluster
+	 * instead of free it immediately. The cluster will be freed
+	 * after discard.
+	 */
+	if ((si->flags & (SWP_WRITEOK | SWP_PAGE_DISCARD)) ==
+	    (SWP_WRITEOK | SWP_PAGE_DISCARD)) {
+		swap_cluster_schedule_discard(si, idx);
+		return;
+	}
+
+	__free_cluster(si, idx);
+}
+
 /*
  * The cluster corresponding to page_nr will be used. The cluster will be
  * removed from free cluster list and its usage counter will be increased.
@@ -370,11 +409,8 @@ static void inc_cluster_info_page(struct
 
 	if (!cluster_info)
 		return;
-	if (cluster_is_free(&cluster_info[idx])) {
-		VM_BUG_ON(cluster_list_first(&p->free_clusters) != idx);
-		cluster_list_del_first(&p->free_clusters, cluster_info);
-		cluster_set_count_flag(&cluster_info[idx], 0, 0);
-	}
+	if (cluster_is_free(&cluster_info[idx]))
+		alloc_cluster(p, idx);
 
 	VM_BUG_ON(cluster_count(&cluster_info[idx]) >= SWAPFILE_CLUSTER);
 	cluster_set_count(&cluster_info[idx],
@@ -398,21 +434,8 @@ static void dec_cluster_info_page(struct
 	cluster_set_count(&cluster_info[idx],
 		cluster_count(&cluster_info[idx]) - 1);
 
-	if (cluster_count(&cluster_info[idx]) == 0) {
-		/*
-		 * If the swap is discardable, prepare discard the cluster
-		 * instead of free it immediately. The cluster will be freed
-		 * after discard.
-		 */
-		if ((p->flags & (SWP_WRITEOK | SWP_PAGE_DISCARD)) ==
-				 (SWP_WRITEOK | SWP_PAGE_DISCARD)) {
-			swap_cluster_schedule_discard(p, idx);
-			return;
-		}
-
-		cluster_set_flag(&cluster_info[idx], CLUSTER_FLAG_FREE);
-		cluster_list_add_tail(&p->free_clusters, cluster_info, idx);
-	}
+	if (cluster_count(&cluster_info[idx]) == 0)
+		free_cluster(p, idx);
 }
 
 /*
@@ -493,6 +516,69 @@ new_cluster:
 	*scan_base = tmp;
 }
 
+#ifdef CONFIG_THP_SWAP_CLUSTER
+static inline unsigned int huge_cluster_nr_entries(bool huge)
+{
+	return huge ? SWAPFILE_CLUSTER : 1;
+}
+#else
+#define huge_cluster_nr_entries(huge)	1
+#endif
+
+static void __swap_entry_alloc(struct swap_info_struct *si,
+			       unsigned long offset, bool huge)
+{
+	unsigned int nr_entries = huge_cluster_nr_entries(huge);
+	unsigned int end = offset + nr_entries - 1;
+
+	if (offset == si->lowest_bit)
+		si->lowest_bit += nr_entries;
+	if (end == si->highest_bit)
+		si->highest_bit -= nr_entries;
+	si->inuse_pages += nr_entries;
+	if (si->inuse_pages == si->pages) {
+		si->lowest_bit = si->max;
+		si->highest_bit = 0;
+		spin_lock(&swap_avail_lock);
+		plist_del(&si->avail_list, &swap_avail_head);
+		spin_unlock(&swap_avail_lock);
+	}
+}
+
+static void __swap_entry_free(struct swap_info_struct *si, unsigned long offset,
+			      bool huge)
+{
+	unsigned int nr_entries = huge_cluster_nr_entries(huge);
+	unsigned long end = offset + nr_entries - 1;
+	void (*swap_slot_free_notify)(struct block_device *, unsigned long);
+
+	if (offset < si->lowest_bit)
+		si->lowest_bit = offset;
+	if (end > si->highest_bit) {
+		bool was_full = !si->highest_bit;
+
+		si->highest_bit = end;
+		if (was_full && (si->flags & SWP_WRITEOK)) {
+			spin_lock(&swap_avail_lock);
+			WARN_ON(!plist_node_empty(&si->avail_list));
+			if (plist_node_empty(&si->avail_list))
+				plist_add(&si->avail_list, &swap_avail_head);
+			spin_unlock(&swap_avail_lock);
+		}
+	}
+	atomic_long_add(nr_entries, &nr_swap_pages);
+	si->inuse_pages -= nr_entries;
+	if (si->flags & SWP_BLKDEV)
+		swap_slot_free_notify =
+			si->bdev->bd_disk->fops->swap_slot_free_notify;
+	while (offset <= end) {
+		frontswap_invalidate_page(si->type, offset);
+		if (swap_slot_free_notify)
+			swap_slot_free_notify(si->bdev, offset);
+		offset++;
+	}
+}
+
 static unsigned long scan_swap_map(struct swap_info_struct *si,
 				   unsigned char usage)
 {
@@ -587,18 +673,7 @@ checks:
 	if (si->swap_map[offset])
 		goto scan;
 
-	if (offset == si->lowest_bit)
-		si->lowest_bit++;
-	if (offset == si->highest_bit)
-		si->highest_bit--;
-	si->inuse_pages++;
-	if (si->inuse_pages == si->pages) {
-		si->lowest_bit = si->max;
-		si->highest_bit = 0;
-		spin_lock(&swap_avail_lock);
-		plist_del(&si->avail_list, &swap_avail_head);
-		spin_unlock(&swap_avail_lock);
-	}
+	__swap_entry_alloc(si, offset, false);
 	si->swap_map[offset] = usage;
 	inc_cluster_info_page(si, si->cluster_info, offset);
 	si->cluster_next = offset + 1;
@@ -645,14 +720,80 @@ no_page:
 	return 0;
 }
 
-swp_entry_t get_swap_page(void)
+#ifdef CONFIG_THP_SWAP_CLUSTER
+static void swap_free_huge_cluster(struct swap_info_struct *si,
+				   unsigned long idx)
+{
+	struct swap_cluster_info *ci = si->cluster_info + idx;
+	unsigned long offset = idx * SWAPFILE_CLUSTER;
+
+	cluster_set_count_flag(ci, 0, 0);
+	free_cluster(si, idx);
+	__swap_entry_free(si, offset, true);
+}
+
+/*
+ * Caller should hold si->lock.
+ */
+static void swapcache_free_trans_huge(struct swap_info_struct *si,
+				      swp_entry_t entry)
+{
+	unsigned long offset = swp_offset(entry);
+	unsigned long idx = offset / SWAPFILE_CLUSTER;
+	unsigned char *map;
+	unsigned int i;
+
+	map = si->swap_map + offset;
+	for (i = 0; i < SWAPFILE_CLUSTER; i++) {
+		VM_BUG_ON(map[i] != SWAP_HAS_CACHE);
+		map[i] &= ~SWAP_HAS_CACHE;
+	}
+	mem_cgroup_uncharge_swap(entry, SWAPFILE_CLUSTER);
+	swap_free_huge_cluster(si, idx);
+}
+
+static unsigned long swap_alloc_huge_cluster(struct swap_info_struct *si)
+{
+	unsigned long idx;
+	struct swap_cluster_info *ci;
+	unsigned long offset, i;
+	unsigned char *map;
+
+	if (cluster_list_empty(&si->free_clusters))
+		return 0;
+	idx = cluster_list_first(&si->free_clusters);
+	alloc_cluster(si, idx);
+	ci = si->cluster_info + idx;
+	cluster_set_count_flag(ci, SWAPFILE_CLUSTER, 0);
+
+	offset = idx * SWAPFILE_CLUSTER;
+	__swap_entry_alloc(si, offset, true);
+	map = si->swap_map + offset;
+	for (i = 0; i < SWAPFILE_CLUSTER; i++)
+		map[i] = SWAP_HAS_CACHE;
+	return offset;
+}
+#else
+static inline unsigned long swap_alloc_huge_cluster(struct swap_info_struct *si)
+{
+	return 0;
+}
+
+static inline void swapcache_free_trans_huge(struct swap_info_struct *si,
+					     swp_entry_t entry)
+{
+}
+#endif
+
+swp_entry_t __get_swap_page(bool huge)
 {
 	struct swap_info_struct *si, *next;
 	pgoff_t offset;
+	int nr_pages = huge_cluster_nr_entries(huge);
 
-	if (atomic_long_read(&nr_swap_pages) <= 0)
+	if (atomic_long_read(&nr_swap_pages) < nr_pages)
 		goto noswap;
-	atomic_long_dec(&nr_swap_pages);
+	atomic_long_sub(nr_pages, &nr_swap_pages);
 
 	spin_lock(&swap_avail_lock);
 
@@ -680,10 +821,15 @@ start_over:
 		}
 
 		/* This is called for allocating swap entry for cache */
-		offset = scan_swap_map(si, SWAP_HAS_CACHE);
+		if (likely(nr_pages == 1))
+			offset = scan_swap_map(si, SWAP_HAS_CACHE);
+		else
+			offset = swap_alloc_huge_cluster(si);
 		spin_unlock(&si->lock);
 		if (offset)
 			return swp_entry(si->type, offset);
+		else if (unlikely(nr_pages != 1))
+			goto fail_alloc;
 		pr_debug("scan_swap_map of si %d failed to find offset\n",
 		       si->type);
 		spin_lock(&swap_avail_lock);
@@ -703,8 +849,8 @@ nextsi:
 	}
 
 	spin_unlock(&swap_avail_lock);
-
-	atomic_long_inc(&nr_swap_pages);
+fail_alloc:
+	atomic_long_add(nr_pages, &nr_swap_pages);
 noswap:
 	return (swp_entry_t) {0};
 }
@@ -802,31 +948,9 @@ static unsigned char swap_entry_free(str
 
 	/* free if no reference */
 	if (!usage) {
-		mem_cgroup_uncharge_swap(entry);
+		mem_cgroup_uncharge_swap(entry, 1);
 		dec_cluster_info_page(p, p->cluster_info, offset);
-		if (offset < p->lowest_bit)
-			p->lowest_bit = offset;
-		if (offset > p->highest_bit) {
-			bool was_full = !p->highest_bit;
-			p->highest_bit = offset;
-			if (was_full && (p->flags & SWP_WRITEOK)) {
-				spin_lock(&swap_avail_lock);
-				WARN_ON(!plist_node_empty(&p->avail_list));
-				if (plist_node_empty(&p->avail_list))
-					plist_add(&p->avail_list,
-						  &swap_avail_head);
-				spin_unlock(&swap_avail_lock);
-			}
-		}
-		atomic_long_inc(&nr_swap_pages);
-		p->inuse_pages--;
-		frontswap_invalidate_page(p->type, offset);
-		if (p->flags & SWP_BLKDEV) {
-			struct gendisk *disk = p->bdev->bd_disk;
-			if (disk->fops->swap_slot_free_notify)
-				disk->fops->swap_slot_free_notify(p->bdev,
-								  offset);
-		}
+		__swap_entry_free(p, offset, false);
 	}
 
 	return usage;
@@ -850,13 +974,16 @@ void swap_free(swp_entry_t entry)
 /*
  * Called after dropping swapcache to decrease refcnt to swap entries.
  */
-void swapcache_free(swp_entry_t entry)
+void __swapcache_free(swp_entry_t entry, bool huge)
 {
 	struct swap_info_struct *p;
 
 	p = swap_info_get(entry);
 	if (p) {
-		swap_entry_free(p, entry, SWAP_HAS_CACHE);
+		if (unlikely(huge))
+			swapcache_free_trans_huge(p, entry);
+		else
+			swap_entry_free(p, entry, SWAP_HAS_CACHE);
 		spin_unlock(&p->lock);
 	}
 }
--- a/mm/swap_cgroup.c
+++ b/mm/swap_cgroup.c
@@ -18,6 +18,13 @@ struct swap_cgroup {
 };
 #define SC_PER_PAGE	(PAGE_SIZE/sizeof(struct swap_cgroup))
 
+struct swap_cgroup_iter {
+	struct swap_cgroup_ctrl *ctrl;
+	struct swap_cgroup *sc;
+	swp_entry_t entry;
+	unsigned long flags;
+};
+
 /*
  * SwapCgroup implements "lookup" and "exchange" operations.
  * In typical usage, this swap_cgroup is accessed via memcg's charge/uncharge
@@ -75,6 +82,35 @@ static struct swap_cgroup *lookup_swap_c
 	return sc + offset % SC_PER_PAGE;
 }
 
+static void swap_cgroup_iter_init(struct swap_cgroup_iter *iter,
+				  swp_entry_t ent)
+{
+	iter->entry = ent;
+	iter->sc = lookup_swap_cgroup(ent, &iter->ctrl);
+	spin_lock_irqsave(&iter->ctrl->lock, iter->flags);
+}
+
+static void swap_cgroup_iter_exit(struct swap_cgroup_iter *iter)
+{
+	spin_unlock_irqrestore(&iter->ctrl->lock, iter->flags);
+}
+
+/*
+ * swap_cgroup is stored in a kind of discontinuous array.  That is,
+ * they are continuous in one page, but not across page boundary.  And
+ * there is one lock for each page.
+ */
+static void swap_cgroup_iter_advance(struct swap_cgroup_iter *iter)
+{
+	iter->sc++;
+	iter->entry.val++;
+	if (!(((unsigned long)iter->sc) & PAGE_MASK)) {
+		spin_unlock_irqrestore(&iter->ctrl->lock, iter->flags);
+		iter->sc = lookup_swap_cgroup(iter->entry, &iter->ctrl);
+		spin_lock_irqsave(&iter->ctrl->lock, iter->flags);
+	}
+}
+
 /**
  * swap_cgroup_cmpxchg - cmpxchg mem_cgroup's id for this swp_entry.
  * @ent: swap entry to be cmpxchged
@@ -87,45 +123,49 @@ static struct swap_cgroup *lookup_swap_c
 unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
 					unsigned short old, unsigned short new)
 {
-	struct swap_cgroup_ctrl *ctrl;
-	struct swap_cgroup *sc;
-	unsigned long flags;
+	struct swap_cgroup_iter iter;
 	unsigned short retval;
 
-	sc = lookup_swap_cgroup(ent, &ctrl);
+	swap_cgroup_iter_init(&iter, ent);
 
-	spin_lock_irqsave(&ctrl->lock, flags);
-	retval = sc->id;
+	retval = iter.sc->id;
 	if (retval == old)
-		sc->id = new;
+		iter.sc->id = new;
 	else
 		retval = 0;
-	spin_unlock_irqrestore(&ctrl->lock, flags);
+
+	swap_cgroup_iter_exit(&iter);
 	return retval;
 }
 
 /**
- * swap_cgroup_record - record mem_cgroup for this swp_entry.
- * @ent: swap entry to be recorded into
+ * swap_cgroup_record - record mem_cgroup for a set of swap entries
+ * @ent: the first swap entry to be recorded into
  * @id: mem_cgroup to be recorded
+ * @nr_ents: number of swap entries to be recorded
  *
  * Returns old value at success, 0 at failure.
  * (Of course, old value can be 0.)
  */
-unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
+unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id,
+				  unsigned int nr_ents)
 {
-	struct swap_cgroup_ctrl *ctrl;
-	struct swap_cgroup *sc;
+	struct swap_cgroup_iter iter;
 	unsigned short old;
-	unsigned long flags;
 
-	sc = lookup_swap_cgroup(ent, &ctrl);
+	swap_cgroup_iter_init(&iter, ent);
 
-	spin_lock_irqsave(&ctrl->lock, flags);
-	old = sc->id;
-	sc->id = id;
-	spin_unlock_irqrestore(&ctrl->lock, flags);
+	old = iter.sc->id;
+	for (;;) {
+		VM_BUG_ON(iter.sc->id != old);
+		iter.sc->id = id;
+		nr_ents--;
+		if (!nr_ents)
+			break;
+		swap_cgroup_iter_advance(&iter);
+	}
 
+	swap_cgroup_iter_exit(&iter);
 	return old;
 }
 
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -399,14 +399,14 @@ static inline long get_nr_swap_pages(voi
 }
 
 extern void si_swapinfo(struct sysinfo *);
-extern swp_entry_t get_swap_page(void);
+extern swp_entry_t __get_swap_page(bool huge);
 extern swp_entry_t get_swap_page_of_type(int);
 extern int add_swap_count_continuation(swp_entry_t, gfp_t);
 extern void swap_shmem_alloc(swp_entry_t);
 extern int swap_duplicate(swp_entry_t);
 extern int swapcache_prepare(swp_entry_t);
 extern void swap_free(swp_entry_t);
-extern void swapcache_free(swp_entry_t);
+extern void __swapcache_free(swp_entry_t, bool);
 extern int free_swap_and_cache(swp_entry_t);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
 extern unsigned int count_swap_pages(int, int);
@@ -419,6 +419,23 @@ extern bool reuse_swap_page(struct page
 extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
 
+static inline swp_entry_t get_swap_page(void)
+{
+	return __get_swap_page(false);
+}
+
+#ifdef CONFIG_THP_SWAP_CLUSTER
+static inline swp_entry_t get_huge_swap_page(void)
+{
+	return __get_swap_page(true);
+}
+#else
+static inline swp_entry_t get_huge_swap_page(void)
+{
+	return (swp_entry_t) {0};
+}
+#endif
+
 #else /* CONFIG_SWAP */
 
 #define swap_address_space(entry)		(NULL)
@@ -461,7 +478,7 @@ static inline void swap_free(swp_entry_t
 {
 }
 
-static inline void swapcache_free(swp_entry_t swp)
+static inline void __swapcache_free(swp_entry_t swp, bool huge)
 {
 }
 
@@ -525,8 +542,18 @@ static inline swp_entry_t get_swap_page(
 	return entry;
 }
 
+static inline swp_entry_t get_huge_swap_page(void)
+{
+	return (swp_entry_t) {0};
+}
+
 #endif /* CONFIG_SWAP */
 
+static inline void swapcache_free(swp_entry_t entry)
+{
+	__swapcache_free(entry, false);
+}
+
 #ifdef CONFIG_MEMCG
 static inline int mem_cgroup_swappiness(struct mem_cgroup *memcg)
 {
@@ -550,8 +577,10 @@ static inline int mem_cgroup_swappiness(
 
 #ifdef CONFIG_MEMCG_SWAP
 extern void mem_cgroup_swapout(struct page *page, swp_entry_t entry);
-extern int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry);
-extern void mem_cgroup_uncharge_swap(swp_entry_t entry);
+extern int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry,
+				      unsigned int nr_entries);
+extern void mem_cgroup_uncharge_swap(swp_entry_t entry,
+				     unsigned int nr_entries);
 extern long mem_cgroup_get_nr_swap_pages(struct mem_cgroup *memcg);
 extern bool mem_cgroup_swap_full(struct page *page);
 #else
@@ -560,12 +589,14 @@ static inline void mem_cgroup_swapout(st
 }
 
 static inline int mem_cgroup_try_charge_swap(struct page *page,
-					     swp_entry_t entry)
+					     swp_entry_t entry,
+					     unsigned int nr_entries)
 {
 	return 0;
 }
 
-static inline void mem_cgroup_uncharge_swap(swp_entry_t entry)
+static inline void mem_cgroup_uncharge_swap(swp_entry_t entry,
+					    unsigned int nr_entries)
 {
 }
 
--- a/include/linux/swap_cgroup.h
+++ b/include/linux/swap_cgroup.h
@@ -7,7 +7,8 @@
 
 extern unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
 					unsigned short old, unsigned short new);
-extern unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id);
+extern unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id,
+					 unsigned int nr_ents);
 extern unsigned short lookup_swap_cgroup_id(swp_entry_t ent);
 extern int swap_cgroup_swapon(int type, unsigned long max_pages);
 extern void swap_cgroup_swapoff(int type);
@@ -15,7 +16,8 @@ extern void swap_cgroup_swapoff(int type
 #else
 
 static inline
-unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
+unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id,
+				  unsigned int nr_ents)
 {
 	return 0;
 }
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2370,10 +2370,9 @@ void mem_cgroup_split_huge_fixup(struct
 
 #ifdef CONFIG_MEMCG_SWAP
 static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
-					 bool charge)
+				       int nr_entries)
 {
-	int val = (charge) ? 1 : -1;
-	this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_SWAP], val);
+	this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_SWAP], nr_entries);
 }
 
 /**
@@ -2399,8 +2398,8 @@ static int mem_cgroup_move_swap_account(
 	new_id = mem_cgroup_id(to);
 
 	if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id) {
-		mem_cgroup_swap_statistics(from, false);
-		mem_cgroup_swap_statistics(to, true);
+		mem_cgroup_swap_statistics(from, -1);
+		mem_cgroup_swap_statistics(to, 1);
 		return 0;
 	}
 	return -EINVAL;
@@ -5417,7 +5416,7 @@ void mem_cgroup_commit_charge(struct pag
 		 * let's not wait for it.  The page already received a
 		 * memory+swap charge, drop the swap entry duplicate.
 		 */
-		mem_cgroup_uncharge_swap(entry);
+		mem_cgroup_uncharge_swap(entry, nr_pages);
 	}
 }
 
@@ -5825,9 +5824,9 @@ void mem_cgroup_swapout(struct page *pag
 	 * ancestor for the swap instead and transfer the memory+swap charge.
 	 */
 	swap_memcg = mem_cgroup_id_get_online(memcg);
-	oldid = swap_cgroup_record(entry, mem_cgroup_id(swap_memcg));
+	oldid = swap_cgroup_record(entry, mem_cgroup_id(swap_memcg), 1);
 	VM_BUG_ON_PAGE(oldid, page);
-	mem_cgroup_swap_statistics(swap_memcg, true);
+	mem_cgroup_swap_statistics(swap_memcg, 1);
 
 	page->mem_cgroup = NULL;
 
@@ -5854,16 +5853,19 @@ void mem_cgroup_swapout(struct page *pag
 		css_put(&memcg->css);
 }
 
-/*
- * mem_cgroup_try_charge_swap - try charging a swap entry
+/**
+ * mem_cgroup_try_charge_swap - try charging a set of swap entries
  * @page: page being added to swap
- * @entry: swap entry to charge
+ * @entry: the first swap entry to charge
+ * @nr_entries: the number of swap entries to charge
  *
- * Try to charge @entry to the memcg that @page belongs to.
+ * Try to charge @nr_entries swap entries starting from @entry to the
+ * memcg that @page belongs to.
  *
  * Returns 0 on success, -ENOMEM on failure.
  */
-int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry)
+int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry,
+			       unsigned int nr_entries)
 {
 	struct mem_cgroup *memcg;
 	struct page_counter *counter;
@@ -5881,25 +5883,29 @@ int mem_cgroup_try_charge_swap(struct pa
 	memcg = mem_cgroup_id_get_online(memcg);
 
 	if (!mem_cgroup_is_root(memcg) &&
-	    !page_counter_try_charge(&memcg->swap, 1, &counter)) {
+	    !page_counter_try_charge(&memcg->swap, nr_entries, &counter)) {
 		mem_cgroup_id_put(memcg);
 		return -ENOMEM;
 	}
 
-	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
+	if (nr_entries > 1)
+		mem_cgroup_id_get_many(memcg, nr_entries - 1);
+	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg), nr_entries);
 	VM_BUG_ON_PAGE(oldid, page);
-	mem_cgroup_swap_statistics(memcg, true);
+	mem_cgroup_swap_statistics(memcg, nr_entries);
 
 	return 0;
 }
 
 /**
- * mem_cgroup_uncharge_swap - uncharge a swap entry
- * @entry: swap entry to uncharge
+ * mem_cgroup_uncharge_swap - uncharge a set of swap entries
+ * @entry: the first swap entry to uncharge
+ * @nr_entries: the number of swap entries to uncharge
  *
- * Drop the swap charge associated with @entry.
+ * Drop the swap charge associated with @nr_entries swap entries
+ * starting from @entry.
  */
-void mem_cgroup_uncharge_swap(swp_entry_t entry)
+void mem_cgroup_uncharge_swap(swp_entry_t entry, unsigned int nr_entries)
 {
 	struct mem_cgroup *memcg;
 	unsigned short id;
@@ -5907,17 +5913,18 @@ void mem_cgroup_uncharge_swap(swp_entry_
 	if (!do_swap_account)
 		return;
 
-	id = swap_cgroup_record(entry, 0);
+	id = swap_cgroup_record(entry, 0, nr_entries);
 	rcu_read_lock();
 	memcg = mem_cgroup_from_id(id);
 	if (memcg) {
 		if (!mem_cgroup_is_root(memcg)) {
 			if (cgroup_subsys_on_dfl(memory_cgrp_subsys))
-				page_counter_uncharge(&memcg->swap, 1);
+				page_counter_uncharge(&memcg->swap, nr_entries);
 			else
-				page_counter_uncharge(&memcg->memsw, 1);
+				page_counter_uncharge(&memcg->memsw,
+						      nr_entries);
 		}
-		mem_cgroup_swap_statistics(memcg, false);
+		mem_cgroup_swap_statistics(memcg, -nr_entries);
 		mem_cgroup_id_put(memcg);
 	}
 	rcu_read_unlock();
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1248,7 +1248,7 @@ static int shmem_writepage(struct page *
 	if (!swap.val)
 		goto redirty;
 
-	if (mem_cgroup_try_charge_swap(page, swap))
+	if (mem_cgroup_try_charge_swap(page, swap, 1))
 		goto free_swap;
 
 	/*
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -17,6 +17,7 @@
 #include <linux/blkdev.h>
 #include <linux/pagevec.h>
 #include <linux/migrate.h>
+#include <linux/huge_mm.h>
 
 #include <asm/pgtable.h>
 
@@ -43,6 +44,7 @@ struct address_space swapper_spaces[MAX_
 };
 
 #define INC_CACHE_INFO(x)	do { swap_cache_info.x++; } while (0)
+#define ADD_CACHE_INFO(x, nr)	do { swap_cache_info.x += (nr); } while (0)
 
 static struct {
 	unsigned long add_total;
@@ -80,25 +82,32 @@ void show_swap_cache_info(void)
  */
 int __add_to_swap_cache(struct page *page, swp_entry_t entry)
 {
-	int error;
+	int error, i, nr = hpage_nr_pages(page);
 	struct address_space *address_space;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageSwapCache(page), page);
 	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
 
-	get_page(page);
+	page_ref_add(page, nr);
 	SetPageSwapCache(page);
-	set_page_private(page, entry.val);
 
 	address_space = swap_address_space(entry);
 	spin_lock_irq(&address_space->tree_lock);
-	error = radix_tree_insert(&address_space->page_tree,
-					entry.val, page);
+	for (i = 0; i < nr; i++) {
+		struct page *cur_page = page + i;
+		unsigned long index = entry.val + i;
+
+		set_page_private(cur_page, index);
+		error = radix_tree_insert(&address_space->page_tree,
+					  index, cur_page);
+		if (unlikely(error))
+			break;
+	}
 	if (likely(!error)) {
-		address_space->nrpages++;
-		__inc_node_page_state(page, NR_FILE_PAGES);
-		INC_CACHE_INFO(add_total);
+		address_space->nrpages += nr;
+		__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, nr);
+		ADD_CACHE_INFO(add_total, nr);
 	}
 	spin_unlock_irq(&address_space->tree_lock);
 
@@ -109,9 +118,16 @@ int __add_to_swap_cache(struct page *pag
 		 * So add_to_swap_cache() doesn't returns -EEXIST.
 		 */
 		VM_BUG_ON(error == -EEXIST);
-		set_page_private(page, 0UL);
 		ClearPageSwapCache(page);
-		put_page(page);
+		set_page_private(page + i, 0UL);
+		while (i--) {
+			struct page *cur_page = page + i;
+			unsigned long index = entry.val + i;
+
+			set_page_private(cur_page, 0UL);
+			radix_tree_delete(&address_space->page_tree, index);
+		}
+		page_ref_sub(page, nr);
 	}
 
 	return error;
@@ -122,7 +138,7 @@ int add_to_swap_cache(struct page *page,
 {
 	int error;
 
-	error = radix_tree_maybe_preload(gfp_mask);
+	error = radix_tree_maybe_preload_order(gfp_mask, compound_order(page));
 	if (!error) {
 		error = __add_to_swap_cache(page, entry);
 		radix_tree_preload_end();
@@ -138,6 +154,7 @@ void __delete_from_swap_cache(struct pag
 {
 	swp_entry_t entry;
 	struct address_space *address_space;
+	int i, nr = hpage_nr_pages(page);
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
@@ -145,20 +162,66 @@ void __delete_from_swap_cache(struct pag
 
 	entry.val = page_private(page);
 	address_space = swap_address_space(entry);
-	radix_tree_delete(&address_space->page_tree, page_private(page));
-	set_page_private(page, 0);
 	ClearPageSwapCache(page);
-	address_space->nrpages--;
-	__dec_node_page_state(page, NR_FILE_PAGES);
-	INC_CACHE_INFO(del_total);
+	for (i = 0; i < nr; i++) {
+		struct page *cur_page = page + i;
+
+		radix_tree_delete(&address_space->page_tree,
+				  page_private(cur_page));
+		set_page_private(cur_page, 0);
+	}
+	address_space->nrpages -= nr;
+	__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, -nr);
+	ADD_CACHE_INFO(del_total, nr);
+}
+
+#ifdef CONFIG_THP_SWAP_CLUSTER
+int add_to_swap_trans_huge(struct page *page, struct list_head *list)
+{
+	swp_entry_t entry;
+	int ret = 0;
+
+	/* cannot split, which may be needed during swap in, skip it */
+	if (!can_split_huge_page(page))
+		return -EBUSY;
+	/* fallback to split huge page firstly if no PMD map */
+	if (!compound_mapcount(page))
+		return 0;
+	entry = get_huge_swap_page();
+	if (!entry.val)
+		return 0;
+	if (mem_cgroup_try_charge_swap(page, entry, HPAGE_PMD_NR)) {
+		__swapcache_free(entry, true);
+		return -EOVERFLOW;
+	}
+	ret = add_to_swap_cache(page, entry,
+				__GFP_HIGH | __GFP_NOMEMALLOC|__GFP_NOWARN);
+	/* -ENOMEM radix-tree allocation failure */
+	if (ret) {
+		__swapcache_free(entry, true);
+		return 0;
+	}
+	ret = split_huge_page_to_list(page, list);
+	if (ret) {
+		delete_from_swap_cache(page);
+		return -EBUSY;
+	}
+	return 1;
+}
+#else
+static inline int add_to_swap_trans_huge(struct page *page,
+					 struct list_head *list)
+{
+	return 0;
 }
+#endif
 
 /**
  * add_to_swap - allocate swap space for a page
  * @page: page we want to move to swap
  *
  * Allocate swap space for the page and add the page to the
- * swap cache.  Caller needs to hold the page lock. 
+ * swap cache.  Caller needs to hold the page lock.
  */
 int add_to_swap(struct page *page, struct list_head *list)
 {
@@ -168,11 +231,23 @@ int add_to_swap(struct page *page, struc
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageUptodate(page), page);
 
+	if (unlikely(PageTransHuge(page))) {
+		err = add_to_swap_trans_huge(page, list);
+		switch (err) {
+		case 1:
+			return 1;
+		case 0:
+			/* fallback to split firstly if return 0 */
+			break;
+		default:
+			return 0;
+		}
+	}
 	entry = get_swap_page();
 	if (!entry.val)
 		return 0;
 
-	if (mem_cgroup_try_charge_swap(page, entry)) {
+	if (mem_cgroup_try_charge_swap(page, entry, 1)) {
 		swapcache_free(entry);
 		return 0;
 	}
@@ -227,8 +302,8 @@ void delete_from_swap_cache(struct page
 	__delete_from_swap_cache(page);
 	spin_unlock_irq(&address_space->tree_lock);
 
-	swapcache_free(entry);
-	put_page(page);
+	__swapcache_free(entry, PageTransHuge(page));
+	page_ref_sub(page, hpage_nr_pages(page));
 }
 
 /* 
@@ -285,7 +360,7 @@ struct page * lookup_swap_cache(swp_entr
 
 	page = find_get_page(swap_address_space(entry), entry.val);
 
-	if (page) {
+	if (page && likely(!PageTransCompound(page))) {
 		INC_CACHE_INFO(find_success);
 		if (TestClearPageReadahead(page))
 			atomic_inc(&swapin_readahead_hits);
@@ -311,8 +386,13 @@ struct page *__read_swap_cache_async(swp
 		 * that would confuse statistics.
 		 */
 		found_page = find_get_page(swapper_space, entry.val);
-		if (found_page)
+		if (found_page) {
+			if (unlikely(PageTransCompound(found_page))) {
+				put_page(found_page);
+				found_page = NULL;
+			}
 			break;
+		}
 
 		/*
 		 * Get a new page to read into from swap.
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -314,7 +314,7 @@ PAGEFLAG_FALSE(HighMem)
 #endif
 
 #ifdef CONFIG_SWAP
-PAGEFLAG(SwapCache, swapcache, PF_NO_COMPOUND)
+PAGEFLAG(SwapCache, swapcache, PF_NO_TAIL)
 #else
 PAGEFLAG_FALSE(SwapCache)
 #endif
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -94,6 +94,7 @@ extern unsigned long thp_get_unmapped_ar
 extern void prep_transhuge_page(struct page *page);
 extern void free_transhuge_page(struct page *page);
 
+bool can_split_huge_page(struct page *page);
 int split_huge_page_to_list(struct page *page, struct list_head *list);
 static inline int split_huge_page(struct page *page)
 {
@@ -176,6 +177,11 @@ static inline void prep_transhuge_page(s
 
 #define thp_get_unmapped_area	NULL
 
+static inline bool
+can_split_huge_page(struct page *page)
+{
+	return false;
+}
 static inline int
 split_huge_page_to_list(struct page *page, struct list_head *list)
 {
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1834,7 +1834,7 @@ static void __split_huge_page_tail(struc
 	 * atomic_set() here would be safe on all archs (and not only on x86),
 	 * it's safer to use atomic_inc()/atomic_add().
 	 */
-	if (PageAnon(head)) {
+	if (PageAnon(head) && !PageSwapCache(head)) {
 		page_ref_inc(page_tail);
 	} else {
 		/* Additional pin to radix tree */
@@ -1845,6 +1845,7 @@ static void __split_huge_page_tail(struc
 	page_tail->flags |= (head->flags &
 			((1L << PG_referenced) |
 			 (1L << PG_swapbacked) |
+			 (1L << PG_swapcache) |
 			 (1L << PG_mlocked) |
 			 (1L << PG_uptodate) |
 			 (1L << PG_active) |
@@ -1907,7 +1908,11 @@ static void __split_huge_page(struct pag
 	ClearPageCompound(head);
 	/* See comment in __split_huge_page_tail() */
 	if (PageAnon(head)) {
-		page_ref_inc(head);
+		/* Additional pin to radix tree of swap cache */
+		if (PageSwapCache(head))
+			page_ref_add(head, 2);
+		else
+			page_ref_inc(head);
 	} else {
 		/* Additional pin to radix tree */
 		page_ref_add(head, 2);
@@ -2016,6 +2021,19 @@ int page_trans_huge_mapcount(struct page
 	return ret;
 }
 
+/* Racy check whether the huge page can be split */
+bool can_split_huge_page(struct page *page)
+{
+	int extra_pins;
+
+	/* Additional pins from radix tree */
+	if (PageAnon(page))
+		extra_pins = PageSwapCache(page) ? HPAGE_PMD_NR : 0;
+	else
+		extra_pins = HPAGE_PMD_NR;
+	return total_mapcount(page) == page_count(page) - extra_pins - 1;
+}
+
 /*
  * This function splits huge page into normal pages. @page can point to any
  * subpage of huge page to split. Split doesn't change the position of @page.
@@ -2064,7 +2082,7 @@ int split_huge_page_to_list(struct page
 			ret = -EBUSY;
 			goto out;
 		}
-		extra_pins = 0;
+		extra_pins = PageSwapCache(head) ? HPAGE_PMD_NR : 0;
 		mapping = NULL;
 		anon_vma_lock_write(anon_vma);
 	} else {
@@ -2086,7 +2104,7 @@ int split_huge_page_to_list(struct page
 	 * Racy check if we can split the page, before freeze_page() will
 	 * split PMDs
 	 */
-	if (total_mapcount(head) != page_count(head) - extra_pins - 1) {
+	if (!can_split_huge_page(head)) {
 		ret = -EBUSY;
 		goto out_unlock;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
