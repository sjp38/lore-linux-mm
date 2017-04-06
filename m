Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D0BAD6B03E6
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 01:35:51 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id a72so25796706pge.10
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 22:35:51 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d76si681437pfe.306.2017.04.05.22.35.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 22:35:50 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v8 1/3] mm, THP, swap: Delay splitting THP during swap out
Date: Thu,  6 Apr 2017 13:35:13 +0800
Message-Id: <20170406053515.4842-2-ying.huang@intel.com>
In-Reply-To: <20170406053515.4842-1-ying.huang@intel.com>
References: <20170406053515.4842-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, cgroups@vger.kernel.org

From: Huang Ying <ying.huang@intel.com>

In this patch, splitting huge page is delayed from almost the first
step of swapping out to after allocating the swap space for the
THP (Transparent Huge Page) and adding the THP into the swap cache.
This will batch the corresponding operation, thus improve THP swap out
throughput.

This is the first step for the THP swap optimization.  The plan is to
delay splitting the THP step by step and avoid splitting the THP
finally.

The advantages of the THP swap support include:

- Batch the swap operations for the THP and reduce lock
  acquiring/releasing, including allocating/freeing the swap space,
  adding/deleting to/from the swap cache, and writing/reading the swap
  space, etc.  This will help to improve the THP swap performance.

- The THP swap space read/write will be 2M sequential IO.  It is
  particularly helpful for the swap read, which usually are 4k random
  IO.  This will help to improve the THP swap performance.

- It will help the memory fragmentation, especially when the THP is
  heavily used by the applications.  The 2M continuous pages will be
  free up after the THP swapping out.

- It will improve the THP utilization on the system with the swap
  turned on.  Because the speed for khugepaged to collapse the normal
  pages into the THP is quite slow.  After the THP is split during the
  swapping out, it will take quite long time for the normal pages to
  collapse back into the THP after being swapped in.  The high THP
  utilization helps the efficiency of the page based memory management
  too.

There are some concerns regarding THP swap in, mainly because possible
enlarged read/write IO size (for swap in/out) may put more overhead on
the storage device.  To deal with that, the THP swap in should be
turned on only when necessary.  For example, it can be selected via
"always/never/madvise" logic, to be turned on globally, turned off
globally, or turned on only for VMA with MADV_HUGEPAGE, etc.

In this patch, one swap cluster is used to hold the contents of each
THP swapped out.  So, the size of the swap cluster is changed to that
of the THP (Transparent Huge Page) on x86_64 architecture (512).  For
other architectures which want such THP swap optimization,
ARCH_USES_THP_SWAP_CLUSTER needs to be selected in the Kconfig file
for the architecture.  In effect, this will enlarge swap cluster size
by 2 times on x86_64.  Which may make it harder to find a free cluster
when the swap space becomes fragmented.  So that, this may reduce the
continuous swap space allocation and sequential write in theory.  The
performance test in 0day shows no regressions caused by this.

In the future of THP swap optimization, some information of the
swapped out THP (such as compound map count) will be recorded in the
swap_cluster_info data structure.

The mem cgroup swap accounting functions are enhanced to support
charge or uncharge a swap cluster backing a THP as a whole.

The swap cluster allocate/free functions are added to allocate/free a
swap cluster for a THP.  A fair simple algorithm is used for swap
cluster allocation, that is, only the first swap device in priority
list will be tried to allocate the swap cluster.  The function will
fail if the trying is not successful, and the caller will fallback to
allocate a single swap slot instead.  This works good enough for
normal cases.  If the difference of the number of the free swap
clusters among multiple swap devices is significant, it is possible
that some THPs are split earlier than necessary.  For example, this
could be caused by big size difference among multiple swap devices.

The swap cache functions is enhanced to support add/delete THP to/from
the swap cache as a set of (HPAGE_PMD_NR) sub-pages.  This may be
enhanced in the future with multi-order radix tree.  But because we
will split the THP soon during swapping out, that optimization doesn't
make much sense for this first step.

The THP splitting functions are enhanced to support to split THP in
swap cache during swapping out.  The page lock will be held during
allocating the swap cluster, adding the THP into the swap cache and
splitting the THP.  So in the code path other than swapping out, if
the THP need to be split, the PageSwapCache(THP) will be always false.

With the patchset, the swap out throughput improves 14.9% (from about
3.77GB/s to about 4.34GB/s) in the vm-scalability swap-w-seq test case
with 8 processes.  The test is done on a Xeon E5 v3 system.  The swap
device used is a RAM simulated PMEM (persistent memory) device.  To
test the sequential swapping out, the test case creates 8 processes,
which sequentially allocate and write to the anonymous pages until the
RAM and part of the swap device is used up.

The detailed comparison result is as follow,

base             base+patchset
---------------- --------------------------
         %stddev     %change         %stddev
             \          |                \
   7043990 A+-  0%     +21.2%    8536807 A+-  0%  vm-scalability.throughput
    109.94 A+-  1%     -16.2%      92.09 A+-  0%  vm-scalability.time.elapsed_time
   3957091 A+-  0%     +14.9%    4547173 A+-  0%  vmstat.swap.so
     31.46 A+-  1%     -38.3%      19.42 A+-  0%  perf-stat.cache-miss-rate%
      1.04 A+-  1%     +22.2%       1.27 A+-  0%  perf-stat.ipc
      9.33 A+-  2%     -60.7%       3.67 A+-  1%  perf-profile.calltrace.cycles-pp.add_to_swap.shrink_page_list.shrink_inactive_list.shrink_node_memcg.shrink_node

The swap cluster is only available for SSD, so the THP swap
optimization in this patchset has no effect for HDD.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: cgroups@vger.kernel.org
Suggested-by: Andrew Morton <akpm@linux-foundation.org> [for config option]
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com> [for changes in huge_memory.c and huge_mm.h]
---
 arch/x86/Kconfig            |   1 +
 include/linux/page-flags.h  |   5 +-
 include/linux/swap.h        |  37 ++++--
 include/linux/swap_cgroup.h |   6 +-
 mm/Kconfig                  |  13 +++
 mm/huge_memory.c            |  11 +-
 mm/memcontrol.c             |  58 ++++++----
 mm/shmem.c                  |   6 +-
 mm/swap_cgroup.c            |  40 +++++--
 mm/swap_slots.c             |   7 +-
 mm/swap_state.c             | 125 +++++++++++++-------
 mm/swapfile.c               | 275 ++++++++++++++++++++++++++++++++------------
 mm/vmscan.c                 |   2 +-
 13 files changed, 413 insertions(+), 173 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 9a5af1e1cd61..7300c2f6bf13 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -178,6 +178,7 @@ config X86
 	select USER_STACKTRACE_SUPPORT
 	select VIRT_TO_BUS
 	select X86_FEATURE_NAMES		if PROC_FS
+	select ARCH_USES_THP_SWAP_CLUSTER	if X86_64
 
 config INSTRUCTION_DECODER
 	def_bool y
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 6b5818d6de32..f4acd6c4f808 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -326,11 +326,12 @@ PAGEFLAG_FALSE(HighMem)
 #ifdef CONFIG_SWAP
 static __always_inline int PageSwapCache(struct page *page)
 {
+	page = compound_head(page);
 	return PageSwapBacked(page) && test_bit(PG_swapcache, &page->flags);
 
 }
-SETPAGEFLAG(SwapCache, swapcache, PF_NO_COMPOUND)
-CLEARPAGEFLAG(SwapCache, swapcache, PF_NO_COMPOUND)
+SETPAGEFLAG(SwapCache, swapcache, PF_NO_TAIL)
+CLEARPAGEFLAG(SwapCache, swapcache, PF_NO_TAIL)
 #else
 PAGEFLAG_FALSE(SwapCache)
 #endif
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 486494e6b2fc..9295b583c268 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -386,15 +386,15 @@ static inline long get_nr_swap_pages(void)
 }
 
 extern void si_swapinfo(struct sysinfo *);
-extern swp_entry_t get_swap_page(void);
+extern swp_entry_t __get_swap_page(void);
 extern swp_entry_t get_swap_page_of_type(int);
-extern int get_swap_pages(int n, swp_entry_t swp_entries[]);
+extern int get_swap_pages(int n, swp_entry_t swp_entries[], bool huge);
 extern int add_swap_count_continuation(swp_entry_t, gfp_t);
 extern void swap_shmem_alloc(swp_entry_t);
 extern int swap_duplicate(swp_entry_t);
 extern int swapcache_prepare(swp_entry_t);
 extern void swap_free(swp_entry_t);
-extern void swapcache_free(swp_entry_t);
+extern void swapcache_free(swp_entry_t entry, bool huge);
 extern void swapcache_free_entries(swp_entry_t *entries, int n);
 extern int free_swap_and_cache(swp_entry_t);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
@@ -456,7 +456,7 @@ static inline void swap_free(swp_entry_t swp)
 {
 }
 
-static inline void swapcache_free(swp_entry_t swp)
+static inline void swapcache_free(swp_entry_t swp, bool huge)
 {
 }
 
@@ -518,7 +518,7 @@ static inline int try_to_free_swap(struct page *page)
 	return 0;
 }
 
-static inline swp_entry_t get_swap_page(void)
+static inline swp_entry_t __get_swap_page(void)
 {
 	swp_entry_t entry;
 	entry.val = 0;
@@ -527,6 +527,21 @@ static inline swp_entry_t get_swap_page(void)
 
 #endif /* CONFIG_SWAP */
 
+static inline swp_entry_t get_swap_page(bool huge)
+{
+#ifdef CONFIG_THP_SWAP_CLUSTER
+	if (huge) {
+		swp_entry_t entry;
+
+		if (get_swap_pages(1, &entry, true))
+			return entry;
+		else
+			return (swp_entry_t) {0};
+	} else
+#endif
+		return __get_swap_page();
+}
+
 #ifdef CONFIG_MEMCG
 static inline int mem_cgroup_swappiness(struct mem_cgroup *memcg)
 {
@@ -550,8 +565,10 @@ static inline int mem_cgroup_swappiness(struct mem_cgroup *mem)
 
 #ifdef CONFIG_MEMCG_SWAP
 extern void mem_cgroup_swapout(struct page *page, swp_entry_t entry);
-extern int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry);
-extern void mem_cgroup_uncharge_swap(swp_entry_t entry);
+extern int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry,
+				      bool compound);
+extern void mem_cgroup_uncharge_swap(swp_entry_t entry,
+				     unsigned int nr_entries);
 extern long mem_cgroup_get_nr_swap_pages(struct mem_cgroup *memcg);
 extern bool mem_cgroup_swap_full(struct page *page);
 #else
@@ -560,12 +577,14 @@ static inline void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 }
 
 static inline int mem_cgroup_try_charge_swap(struct page *page,
-					     swp_entry_t entry)
+					     swp_entry_t entry,
+					     bool compound)
 {
 	return 0;
 }
 
-static inline void mem_cgroup_uncharge_swap(swp_entry_t entry)
+static inline void mem_cgroup_uncharge_swap(swp_entry_t entry,
+					    unsigned int nr_entries)
 {
 }
 
diff --git a/include/linux/swap_cgroup.h b/include/linux/swap_cgroup.h
index 145306bdc92f..b2b8ec7bda3f 100644
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
@@ -15,7 +16,8 @@ extern void swap_cgroup_swapoff(int type);
 #else
 
 static inline
-unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
+unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id,
+				  unsigned int nr_ents)
 {
 	return 0;
 }
diff --git a/mm/Kconfig b/mm/Kconfig
index c89f472b658c..3edfa6a4bf67 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -499,6 +499,19 @@ config FRONTSWAP
 
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
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d14dd961f626..4a5c1ca21894 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2185,7 +2185,7 @@ static void __split_huge_page_tail(struct page *head, int tail,
 	 * atomic_set() here would be safe on all archs (and not only on x86),
 	 * it's safer to use atomic_inc()/atomic_add().
 	 */
-	if (PageAnon(head)) {
+	if (PageAnon(head) && !PageSwapCache(head)) {
 		page_ref_inc(page_tail);
 	} else {
 		/* Additional pin to radix tree */
@@ -2196,6 +2196,7 @@ static void __split_huge_page_tail(struct page *head, int tail,
 	page_tail->flags |= (head->flags &
 			((1L << PG_referenced) |
 			 (1L << PG_swapbacked) |
+			 (1L << PG_swapcache) |
 			 (1L << PG_mlocked) |
 			 (1L << PG_uptodate) |
 			 (1L << PG_active) |
@@ -2258,7 +2259,11 @@ static void __split_huge_page(struct page *page, struct list_head *list,
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
@@ -2414,7 +2419,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			ret = -EBUSY;
 			goto out;
 		}
-		extra_pins = 0;
+		extra_pins = PageSwapCache(page) ? HPAGE_PMD_NR : 0;
 		mapping = NULL;
 		anon_vma_lock_write(anon_vma);
 	} else {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 490d5b4676c1..6987c6e91b35 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2393,10 +2393,9 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 
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
@@ -2422,8 +2421,8 @@ static int mem_cgroup_move_swap_account(swp_entry_t entry,
 	new_id = mem_cgroup_id(to);
 
 	if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id) {
-		mem_cgroup_swap_statistics(from, false);
-		mem_cgroup_swap_statistics(to, true);
+		mem_cgroup_swap_statistics(from, -1);
+		mem_cgroup_swap_statistics(to, 1);
 		return 0;
 	}
 	return -EINVAL;
@@ -5451,7 +5450,7 @@ void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
 		 * let's not wait for it.  The page already received a
 		 * memory+swap charge, drop the swap entry duplicate.
 		 */
-		mem_cgroup_uncharge_swap(entry);
+		mem_cgroup_uncharge_swap(entry, nr_pages);
 	}
 }
 
@@ -5879,9 +5878,9 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	 * ancestor for the swap instead and transfer the memory+swap charge.
 	 */
 	swap_memcg = mem_cgroup_id_get_online(memcg);
-	oldid = swap_cgroup_record(entry, mem_cgroup_id(swap_memcg));
+	oldid = swap_cgroup_record(entry, mem_cgroup_id(swap_memcg), 1);
 	VM_BUG_ON_PAGE(oldid, page);
-	mem_cgroup_swap_statistics(swap_memcg, true);
+	mem_cgroup_swap_statistics(swap_memcg, 1);
 
 	page->mem_cgroup = NULL;
 
@@ -5908,19 +5907,23 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 		css_put(&memcg->css);
 }
 
-/*
- * mem_cgroup_try_charge_swap - try charging a swap entry
+/**
+ * mem_cgroup_try_charge_swap - try charging a set of swap entries
  * @page: page being added to swap
- * @entry: swap entry to charge
+ * @entry: the first swap entry to charge
+ * @compound: charge the swap entries as compound or small swap entry
  *
- * Try to charge @entry to the memcg that @page belongs to.
+ * Try to charge a set of swap entries starting from @entry to the
+ * memcg that @page belongs to.
  *
  * Returns 0 on success, -ENOMEM on failure.
  */
-int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry)
+int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry,
+			       bool compound)
 {
 	struct mem_cgroup *memcg;
 	struct page_counter *counter;
+	unsigned int nr_entries = compound ? hpage_nr_pages(page) : 1;
 	unsigned short oldid;
 
 	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) || !do_swap_account)
@@ -5935,25 +5938,29 @@ int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry)
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
@@ -5961,18 +5968,19 @@ void mem_cgroup_uncharge_swap(swp_entry_t entry)
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
-		mem_cgroup_id_put(memcg);
+		mem_cgroup_swap_statistics(memcg, -nr_entries);
+		mem_cgroup_id_put_many(memcg, nr_entries);
 	}
 	rcu_read_unlock();
 }
diff --git a/mm/shmem.c b/mm/shmem.c
index e67d6ba4e98e..2d7414241f71 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1290,11 +1290,11 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 		SetPageUptodate(page);
 	}
 
-	swap = get_swap_page();
+	swap = get_swap_page(false);
 	if (!swap.val)
 		goto redirty;
 
-	if (mem_cgroup_try_charge_swap(page, swap))
+	if (mem_cgroup_try_charge_swap(page, swap, false))
 		goto free_swap;
 
 	/*
@@ -1326,7 +1326,7 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 
 	mutex_unlock(&shmem_swaplist_mutex);
 free_swap:
-	swapcache_free(swap);
+	swapcache_free(swap, false);
 redirty:
 	set_page_dirty(page);
 	if (wbc->for_reclaim)
diff --git a/mm/swap_cgroup.c b/mm/swap_cgroup.c
index 310ac0b8f974..8cee2d125815 100644
--- a/mm/swap_cgroup.c
+++ b/mm/swap_cgroup.c
@@ -58,21 +58,27 @@ static int swap_cgroup_prepare(int type)
 	return -ENOMEM;
 }
 
+static struct swap_cgroup *__lookup_swap_cgroup(struct swap_cgroup_ctrl *ctrl,
+						pgoff_t offset)
+{
+	struct page *mappage;
+	struct swap_cgroup *sc;
+
+	mappage = ctrl->map[offset / SC_PER_PAGE];
+	sc = page_address(mappage);
+	return sc + offset % SC_PER_PAGE;
+}
+
 static struct swap_cgroup *lookup_swap_cgroup(swp_entry_t ent,
 					struct swap_cgroup_ctrl **ctrlp)
 {
 	pgoff_t offset = swp_offset(ent);
 	struct swap_cgroup_ctrl *ctrl;
-	struct page *mappage;
-	struct swap_cgroup *sc;
 
 	ctrl = &swap_cgroup_ctrl[swp_type(ent)];
 	if (ctrlp)
 		*ctrlp = ctrl;
-
-	mappage = ctrl->map[offset / SC_PER_PAGE];
-	sc = page_address(mappage);
-	return sc + offset % SC_PER_PAGE;
+	return __lookup_swap_cgroup(ctrl, offset);
 }
 
 /**
@@ -105,25 +111,39 @@ unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
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
 	struct swap_cgroup_ctrl *ctrl;
 	struct swap_cgroup *sc;
 	unsigned short old;
 	unsigned long flags;
+	pgoff_t offset = swp_offset(ent);
+	pgoff_t end = offset + nr_ents;
 
 	sc = lookup_swap_cgroup(ent, &ctrl);
 
 	spin_lock_irqsave(&ctrl->lock, flags);
 	old = sc->id;
-	sc->id = id;
+	for (;;) {
+		VM_BUG_ON(sc->id != old);
+		sc->id = id;
+		offset++;
+		if (offset == end)
+			break;
+		if (offset % SC_PER_PAGE)
+			sc++;
+		else
+			sc = __lookup_swap_cgroup(ctrl, offset);
+	}
 	spin_unlock_irqrestore(&ctrl->lock, flags);
 
 	return old;
diff --git a/mm/swap_slots.c b/mm/swap_slots.c
index aa1c415f4abd..093570d46b09 100644
--- a/mm/swap_slots.c
+++ b/mm/swap_slots.c
@@ -260,7 +260,8 @@ static int refill_swap_slots_cache(struct swap_slots_cache *cache)
 
 	cache->cur = 0;
 	if (swap_slot_cache_active)
-		cache->nr = get_swap_pages(SWAP_SLOTS_CACHE_SIZE, cache->slots);
+		cache->nr = get_swap_pages(SWAP_SLOTS_CACHE_SIZE, cache->slots,
+					   false);
 
 	return cache->nr;
 }
@@ -298,7 +299,7 @@ int free_swap_slot(swp_entry_t entry)
 	return 0;
 }
 
-swp_entry_t get_swap_page(void)
+swp_entry_t __get_swap_page(void)
 {
 	swp_entry_t entry, *pentry;
 	struct swap_slots_cache *cache;
@@ -334,7 +335,7 @@ swp_entry_t get_swap_page(void)
 			return entry;
 	}
 
-	get_swap_pages(1, &entry);
+	get_swap_pages(1, &entry, false);
 
 	return entry;
 }
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 7bfb9bd1ca21..7659557351cf 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -19,6 +19,7 @@
 #include <linux/migrate.h>
 #include <linux/vmalloc.h>
 #include <linux/swap_slots.h>
+#include <linux/huge_mm.h>
 
 #include <asm/pgtable.h>
 
@@ -38,6 +39,7 @@ struct address_space *swapper_spaces[MAX_SWAPFILES];
 static unsigned int nr_swapper_spaces[MAX_SWAPFILES];
 
 #define INC_CACHE_INFO(x)	do { swap_cache_info.x++; } while (0)
+#define ADD_CACHE_INFO(x, nr)	do { swap_cache_info.x += (nr); } while (0)
 
 static struct {
 	unsigned long add_total;
@@ -90,39 +92,52 @@ void show_swap_cache_info(void)
  */
 int __add_to_swap_cache(struct page *page, swp_entry_t entry)
 {
-	int error;
+	int error, i, nr = hpage_nr_pages(page);
 	struct address_space *address_space;
+	struct page *cur_page;
+	swp_entry_t cur_entry;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageSwapCache(page), page);
 	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
 
-	get_page(page);
+	page_ref_add(page, nr);
 	SetPageSwapCache(page);
-	set_page_private(page, entry.val);
 
 	address_space = swap_address_space(entry);
+	cur_page = page;
+	cur_entry.val = entry.val;
 	spin_lock_irq(&address_space->tree_lock);
-	error = radix_tree_insert(&address_space->page_tree,
-				  swp_offset(entry), page);
-	if (likely(!error)) {
-		address_space->nrpages++;
-		__inc_node_page_state(page, NR_FILE_PAGES);
-		INC_CACHE_INFO(add_total);
+	for (i = 0; i < nr; i++, cur_page++, cur_entry.val++) {
+		set_page_private(cur_page, cur_entry.val);
+		error = radix_tree_insert(&address_space->page_tree,
+					  swp_offset(cur_entry), cur_page);
+		if (unlikely(error))
+			break;
 	}
-	spin_unlock_irq(&address_space->tree_lock);
-
-	if (unlikely(error)) {
+	if (likely(!error)) {
+		address_space->nrpages += nr;
+		__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, nr);
+		ADD_CACHE_INFO(add_total, nr);
+	} else {
 		/*
 		 * Only the context which have set SWAP_HAS_CACHE flag
 		 * would call add_to_swap_cache().
 		 * So add_to_swap_cache() doesn't returns -EEXIST.
 		 */
 		VM_BUG_ON(error == -EEXIST);
-		set_page_private(page, 0UL);
+		set_page_private(cur_page, 0UL);
+		while (i--) {
+			cur_page--;
+			cur_entry.val--;
+			radix_tree_delete(&address_space->page_tree,
+					  swp_offset(cur_entry));
+			set_page_private(cur_page, 0UL);
+		}
 		ClearPageSwapCache(page);
-		put_page(page);
+		page_ref_sub(page, nr);
 	}
+	spin_unlock_irq(&address_space->tree_lock);
 
 	return error;
 }
@@ -132,7 +147,7 @@ int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp_mask)
 {
 	int error;
 
-	error = radix_tree_maybe_preload(gfp_mask);
+	error = radix_tree_maybe_preload_order(gfp_mask, compound_order(page));
 	if (!error) {
 		error = __add_to_swap_cache(page, entry);
 		radix_tree_preload_end();
@@ -148,6 +163,7 @@ void __delete_from_swap_cache(struct page *page)
 {
 	swp_entry_t entry;
 	struct address_space *address_space;
+	int i, nr = hpage_nr_pages(page);
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
@@ -155,12 +171,17 @@ void __delete_from_swap_cache(struct page *page)
 
 	entry.val = page_private(page);
 	address_space = swap_address_space(entry);
-	radix_tree_delete(&address_space->page_tree, swp_offset(entry));
-	set_page_private(page, 0);
+	for (i = 0; i < nr; i++, entry.val++) {
+		struct page *cur_page = page + i;
+
+		radix_tree_delete(&address_space->page_tree,
+				  swp_offset(entry));
+		set_page_private(cur_page, 0);
+	}
 	ClearPageSwapCache(page);
-	address_space->nrpages--;
-	__dec_node_page_state(page, NR_FILE_PAGES);
-	INC_CACHE_INFO(del_total);
+	address_space->nrpages -= nr;
+	__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, -nr);
+	ADD_CACHE_INFO(del_total, nr);
 }
 
 /**
@@ -168,30 +189,31 @@ void __delete_from_swap_cache(struct page *page)
  * @page: page we want to move to swap
  *
  * Allocate swap space for the page and add the page to the
- * swap cache.  Caller needs to hold the page lock. 
+ * swap cache.  Caller needs to hold the page lock.
  */
 int add_to_swap(struct page *page, struct list_head *list)
 {
 	swp_entry_t entry;
 	int err;
+	bool huge = false;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageUptodate(page), page);
 
-	entry = get_swap_page();
-	if (!entry.val)
-		return 0;
+#ifdef CONFIG_THP_SWAP_CLUSTER
+	huge = PageTransHuge(page);
+#endif
 
-	if (mem_cgroup_try_charge_swap(page, entry)) {
-		swapcache_free(entry);
-		return 0;
-	}
+retry:
+	entry = get_swap_page(huge);
+	if (!entry.val)
+		goto fail;
+	if (mem_cgroup_try_charge_swap(page, entry, huge))
+		goto free_fail;
 
-	if (unlikely(PageTransHuge(page)))
-		if (unlikely(split_huge_page_to_list(page, list))) {
-			swapcache_free(entry);
-			return 0;
-		}
+	if (unlikely(PageTransHuge(page)) && !huge)
+		if (unlikely(split_huge_page_to_list(page, list)))
+			goto free_fail;
 
 	/*
 	 * Radix-tree node allocations from PF_MEMALLOC contexts could
@@ -206,17 +228,32 @@ int add_to_swap(struct page *page, struct list_head *list)
 	 */
 	err = add_to_swap_cache(page, entry,
 			__GFP_HIGH|__GFP_NOMEMALLOC|__GFP_NOWARN);
-
-	if (!err) {
-		return 1;
-	} else {	/* -ENOMEM radix-tree allocation failure */
+	/* -ENOMEM radix-tree allocation failure */
+	if (err)
 		/*
 		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
 		 * clear SWAP_HAS_CACHE flag.
 		 */
-		swapcache_free(entry);
-		return 0;
+		goto free_fail;
+
+	if (unlikely(PageTransHuge(page)) && huge) {
+		err = split_huge_page_to_list(page, list);
+		if (err) {
+			delete_from_swap_cache(page);
+			return 0;
+		}
 	}
+
+	return 1;
+
+free_fail:
+	swapcache_free(entry, huge);
+fail:
+	if (huge) {
+		huge = false;
+		goto retry;
+	} else
+		return 0;
 }
 
 /*
@@ -237,8 +274,8 @@ void delete_from_swap_cache(struct page *page)
 	__delete_from_swap_cache(page);
 	spin_unlock_irq(&address_space->tree_lock);
 
-	swapcache_free(entry);
-	put_page(page);
+	swapcache_free(entry, PageTransHuge(page));
+	page_ref_sub(page, hpage_nr_pages(page));
 }
 
 /* 
@@ -295,7 +332,7 @@ struct page * lookup_swap_cache(swp_entry_t entry)
 
 	page = find_get_page(swap_address_space(entry), swp_offset(entry));
 
-	if (page) {
+	if (page && likely(!PageTransCompound(page))) {
 		INC_CACHE_INFO(find_success);
 		if (TestClearPageReadahead(page))
 			atomic_inc(&swapin_readahead_hits);
@@ -389,7 +426,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
 		 * clear SWAP_HAS_CACHE flag.
 		 */
-		swapcache_free(entry);
+		swapcache_free(entry, false);
 	} while (err != -ENOMEM);
 
 	if (new_page)
@@ -506,7 +543,7 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 						gfp_mask, vma, addr);
 		if (!page)
 			continue;
-		if (offset != entry_offset)
+		if (offset != entry_offset && likely(!PageTransCompound(page)))
 			SetPageReadahead(page);
 		put_page(page);
 	}
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 53b5881ee0d6..a3660a206727 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -199,7 +199,11 @@ static void discard_swap_cluster(struct swap_info_struct *si,
 	}
 }
 
+#ifdef CONFIG_THP_SWAP_CLUSTER
+#define SWAPFILE_CLUSTER	HPAGE_PMD_NR
+#else
 #define SWAPFILE_CLUSTER	256
+#endif
 #define LATENCY_LIMIT		256
 
 static inline void cluster_set_flag(struct swap_cluster_info *info,
@@ -374,6 +378,14 @@ static void swap_cluster_schedule_discard(struct swap_info_struct *si,
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
@@ -394,10 +406,7 @@ static void swap_do_scheduled_discard(struct swap_info_struct *si)
 
 		spin_lock(&si->lock);
 		ci = lock_cluster(si, idx * SWAPFILE_CLUSTER);
-		cluster_set_flag(ci, CLUSTER_FLAG_FREE);
-		unlock_cluster(ci);
-		cluster_list_add_tail(&si->free_clusters, info, idx);
-		ci = lock_cluster(si, idx * SWAPFILE_CLUSTER);
+		__free_cluster(si, idx);
 		memset(si->swap_map + idx * SWAPFILE_CLUSTER,
 				0, SWAPFILE_CLUSTER);
 		unlock_cluster(ci);
@@ -415,6 +424,34 @@ static void swap_discard_work(struct work_struct *work)
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
@@ -426,11 +463,8 @@ static void inc_cluster_info_page(struct swap_info_struct *p,
 
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
@@ -454,21 +488,8 @@ static void dec_cluster_info_page(struct swap_info_struct *p,
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
@@ -558,6 +579,71 @@ static bool scan_swap_map_try_ssd_cluster(struct swap_info_struct *si,
 	return found_free;
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
+static void _swap_entry_alloc(struct swap_info_struct *si,
+			      unsigned long offset, bool huge)
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
+static void _swap_entry_free(struct swap_info_struct *si, unsigned long offset,
+			     bool huge)
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
+	else
+		swap_slot_free_notify = NULL;
+	while (offset <= end) {
+		frontswap_invalidate_page(si->type, offset);
+		if (swap_slot_free_notify)
+			swap_slot_free_notify(si->bdev, offset);
+		offset++;
+	}
+}
+
 static int scan_swap_map_slots(struct swap_info_struct *si,
 			       unsigned char usage, int nr,
 			       swp_entry_t slots[])
@@ -676,18 +762,7 @@ static int scan_swap_map_slots(struct swap_info_struct *si,
 	inc_cluster_info_page(si, si->cluster_info, offset);
 	unlock_cluster(ci);
 
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
+	_swap_entry_alloc(si, offset, false);
 	si->cluster_next = offset + 1;
 	slots[n_ret++] = swp_entry(si->type, offset);
 
@@ -766,6 +841,82 @@ static int scan_swap_map_slots(struct swap_info_struct *si,
 	return n_ret;
 }
 
+#ifdef CONFIG_THP_SWAP_CLUSTER
+static void swap_free_huge_cluster(struct swap_info_struct *si,
+				   unsigned long idx)
+{
+	struct swap_cluster_info *ci;
+	unsigned long offset = idx * SWAPFILE_CLUSTER;
+
+	ci = lock_cluster(si, offset);
+	cluster_set_count_flag(ci, 0, 0);
+	free_cluster(si, idx);
+	unlock_cluster(ci);
+	_swap_entry_free(si, offset, true);
+}
+
+static void swapcache_free_trans_huge(struct swap_info_struct *si,
+				      swp_entry_t entry)
+{
+	unsigned long offset = swp_offset(entry);
+	unsigned long idx = offset / SWAPFILE_CLUSTER;
+	struct swap_cluster_info *ci;
+	unsigned char *map;
+	unsigned int i;
+
+	spin_lock(&si->lock);
+	ci = lock_cluster(si, offset);
+	map = si->swap_map + offset;
+	for (i = 0; i < SWAPFILE_CLUSTER; i++) {
+		VM_BUG_ON(map[i] != SWAP_HAS_CACHE);
+		map[i] = 0;
+	}
+	unlock_cluster(ci);
+	/* Cluster size is same as huge pmd size */
+	mem_cgroup_uncharge_swap(entry, HPAGE_PMD_NR);
+	swap_free_huge_cluster(si, idx);
+	spin_unlock(&si->lock);
+}
+
+static int swap_alloc_huge_cluster(struct swap_info_struct *si,
+				   swp_entry_t *slot)
+{
+	unsigned long idx;
+	struct swap_cluster_info *ci;
+	unsigned long offset, i;
+	unsigned char *map;
+
+	if (cluster_list_empty(&si->free_clusters))
+		return 0;
+
+	idx = cluster_list_first(&si->free_clusters);
+	offset = idx * SWAPFILE_CLUSTER;
+	ci = lock_cluster(si, offset);
+	alloc_cluster(si, idx);
+	cluster_set_count_flag(ci, SWAPFILE_CLUSTER, 0);
+
+	map = si->swap_map + offset;
+	for (i = 0; i < SWAPFILE_CLUSTER; i++)
+		map[i] = SWAP_HAS_CACHE;
+	unlock_cluster(ci);
+	_swap_entry_alloc(si, offset, true);
+	*slot = swp_entry(si->type, offset);
+
+	return 1;
+}
+#else
+static inline int swap_alloc_huge_cluster(struct swap_info_struct *si,
+					  swp_entry_t *slot)
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
 static unsigned long scan_swap_map(struct swap_info_struct *si,
 				   unsigned char usage)
 {
@@ -781,13 +932,14 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
 
 }
 
-int get_swap_pages(int n_goal, swp_entry_t swp_entries[])
+int get_swap_pages(int n_goal, swp_entry_t swp_entries[], bool huge)
 {
 	struct swap_info_struct *si, *next;
 	long avail_pgs;
 	int n_ret = 0;
+	int nr_pages = huge_cluster_nr_entries(huge);
 
-	avail_pgs = atomic_long_read(&nr_swap_pages);
+	avail_pgs = atomic_long_read(&nr_swap_pages) / nr_pages;
 	if (avail_pgs <= 0)
 		goto noswap;
 
@@ -797,7 +949,7 @@ int get_swap_pages(int n_goal, swp_entry_t swp_entries[])
 	if (n_goal > avail_pgs)
 		n_goal = avail_pgs;
 
-	atomic_long_sub(n_goal, &nr_swap_pages);
+	atomic_long_sub(n_goal * nr_pages, &nr_swap_pages);
 
 	spin_lock(&swap_avail_lock);
 
@@ -823,10 +975,13 @@ int get_swap_pages(int n_goal, swp_entry_t swp_entries[])
 			spin_unlock(&si->lock);
 			goto nextsi;
 		}
-		n_ret = scan_swap_map_slots(si, SWAP_HAS_CACHE,
-					    n_goal, swp_entries);
+		if (likely(!huge))
+			n_ret = scan_swap_map_slots(si, SWAP_HAS_CACHE,
+						    n_goal, swp_entries);
+		else
+			n_ret = swap_alloc_huge_cluster(si, swp_entries);
 		spin_unlock(&si->lock);
-		if (n_ret)
+		if (n_ret || unlikely(huge))
 			goto check_out;
 		pr_debug("scan_swap_map of si %d failed to find offset\n",
 			si->type);
@@ -852,7 +1007,7 @@ int get_swap_pages(int n_goal, swp_entry_t swp_entries[])
 
 check_out:
 	if (n_ret < n_goal)
-		atomic_long_add((long) (n_goal-n_ret), &nr_swap_pages);
+		atomic_long_add((long)(n_goal-n_ret) * nr_pages, &nr_swap_pages);
 noswap:
 	return n_ret;
 }
@@ -1008,32 +1163,8 @@ static void swap_entry_free(struct swap_info_struct *p, swp_entry_t entry)
 	dec_cluster_info_page(p, p->cluster_info, offset);
 	unlock_cluster(ci);
 
-	mem_cgroup_uncharge_swap(entry);
-	if (offset < p->lowest_bit)
-		p->lowest_bit = offset;
-	if (offset > p->highest_bit) {
-		bool was_full = !p->highest_bit;
-
-		p->highest_bit = offset;
-		if (was_full && (p->flags & SWP_WRITEOK)) {
-			spin_lock(&swap_avail_lock);
-			WARN_ON(!plist_node_empty(&p->avail_list));
-			if (plist_node_empty(&p->avail_list))
-				plist_add(&p->avail_list,
-					  &swap_avail_head);
-			spin_unlock(&swap_avail_lock);
-		}
-	}
-	atomic_long_inc(&nr_swap_pages);
-	p->inuse_pages--;
-	frontswap_invalidate_page(p->type, offset);
-	if (p->flags & SWP_BLKDEV) {
-		struct gendisk *disk = p->bdev->bd_disk;
-
-		if (disk->fops->swap_slot_free_notify)
-			disk->fops->swap_slot_free_notify(p->bdev,
-							  offset);
-	}
+	mem_cgroup_uncharge_swap(entry, 1);
+	_swap_entry_free(p, offset, false);
 }
 
 /*
@@ -1054,13 +1185,15 @@ void swap_free(swp_entry_t entry)
 /*
  * Called after dropping swapcache to decrease refcnt to swap entries.
  */
-void swapcache_free(swp_entry_t entry)
+void swapcache_free(swp_entry_t entry, bool huge)
 {
 	struct swap_info_struct *p;
 
 	p = _swap_info_get(entry);
 	if (p) {
-		if (!__swap_entry_free(p, entry, SWAP_HAS_CACHE))
+		if (unlikely(huge))
+			swapcache_free_trans_huge(p, entry);
+		else if (!__swap_entry_free(p, entry, SWAP_HAS_CACHE))
 			free_swap_slot(entry);
 	}
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 58615bb27f2f..6bdf65a38df1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -708,7 +708,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 		mem_cgroup_swapout(page, swap);
 		__delete_from_swap_cache(page);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
-		swapcache_free(swap);
+		swapcache_free(swap, false);
 	} else {
 		void (*freepage)(struct page *);
 		void *shadow = NULL;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
