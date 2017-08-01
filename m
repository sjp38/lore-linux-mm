Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 389EF6B0553
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 09:43:13 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v102so2366769wrb.2
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 06:43:13 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g11si23130424edl.1.2017.08.01.06.43.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 01 Aug 2017 06:43:11 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/2] mm: rename global_page_state to global_zone_page_state
Date: Tue,  1 Aug 2017 09:42:56 -0400
Message-Id: <20170801134256.5400-2-hannes@cmpxchg.org>
In-Reply-To: <20170801134256.5400-1-hannes@cmpxchg.org>
References: <20170801134256.5400-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Josef Bacik <josef@toxicpanda.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

From: Michal Hocko <mhocko@suse.com>

global_page_state is error prone as a recent bug report pointed out [1].
It only returns proper values for zone based counters as the enum it
gets suggests. We already have global_node_page_state so let's rename
global_page_state to global_zone_page_state to be more explicit here.
All existing users seems to be correct
$ git grep "global_page_state(NR_" | sed 's@.*(\(NR_[A-Z_]*\)).*@\1@' | sort | uniq -c
      2 NR_BOUNCE
      2 NR_FREE_CMA_PAGES
     11 NR_FREE_PAGES
      1 NR_KERNEL_STACK_KB
      1 NR_MLOCK
      2 NR_PAGETABLE

This patch shouldn't introduce any functional change.

[1] http://lkml.kernel.org/r/201707260628.v6Q6SmaS030814@www262.sakura.ne.jp

Signed-off-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/proc/meminfo.c      | 10 +++++-----
 include/linux/swap.h   |  4 ++--
 include/linux/vmstat.h |  4 ++--
 mm/mmap.c              |  6 +++---
 mm/nommu.c             |  4 ++--
 mm/page-writeback.c    |  4 ++--
 mm/page_alloc.c        | 12 ++++++------
 mm/util.c              |  2 +-
 mm/vmstat.c            |  4 ++--
 9 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 509a61668d90..cdd979724c74 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -80,7 +80,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	show_val_kb(m, "Active(file):   ", pages[LRU_ACTIVE_FILE]);
 	show_val_kb(m, "Inactive(file): ", pages[LRU_INACTIVE_FILE]);
 	show_val_kb(m, "Unevictable:    ", pages[LRU_UNEVICTABLE]);
-	show_val_kb(m, "Mlocked:        ", global_page_state(NR_MLOCK));
+	show_val_kb(m, "Mlocked:        ", global_zone_page_state(NR_MLOCK));
 
 #ifdef CONFIG_HIGHMEM
 	show_val_kb(m, "HighTotal:      ", i.totalhigh);
@@ -114,9 +114,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	show_val_kb(m, "SUnreclaim:     ",
 		    global_node_page_state(NR_SLAB_UNRECLAIMABLE));
 	seq_printf(m, "KernelStack:    %8lu kB\n",
-		   global_page_state(NR_KERNEL_STACK_KB));
+		   global_zone_page_state(NR_KERNEL_STACK_KB));
 	show_val_kb(m, "PageTables:     ",
-		    global_page_state(NR_PAGETABLE));
+		    global_zone_page_state(NR_PAGETABLE));
 #ifdef CONFIG_QUICKLIST
 	show_val_kb(m, "Quicklists:     ", quicklist_total_size());
 #endif
@@ -124,7 +124,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	show_val_kb(m, "NFS_Unstable:   ",
 		    global_node_page_state(NR_UNSTABLE_NFS));
 	show_val_kb(m, "Bounce:         ",
-		    global_page_state(NR_BOUNCE));
+		    global_zone_page_state(NR_BOUNCE));
 	show_val_kb(m, "WritebackTmp:   ",
 		    global_node_page_state(NR_WRITEBACK_TEMP));
 	show_val_kb(m, "CommitLimit:    ", vm_commit_limit());
@@ -151,7 +151,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 #ifdef CONFIG_CMA
 	show_val_kb(m, "CmaTotal:       ", totalcma_pages);
 	show_val_kb(m, "CmaFree:        ",
-		    global_page_state(NR_FREE_CMA_PAGES));
+		    global_zone_page_state(NR_FREE_CMA_PAGES));
 #endif
 
 	hugetlb_report_meminfo(m);
diff --git a/include/linux/swap.h b/include/linux/swap.h
index d83d28e53e62..bf49b79218f4 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -262,8 +262,8 @@ extern unsigned long totalreserve_pages;
 extern unsigned long nr_free_buffer_pages(void);
 extern unsigned long nr_free_pagecache_pages(void);
 
-/* Definition of global_page_state not available yet */
-#define nr_free_pages() global_page_state(NR_FREE_PAGES)
+/* Definition of global_zone_page_state not available yet */
+#define nr_free_pages() global_zone_page_state(NR_FREE_PAGES)
 
 
 /* linux/mm/swap.c */
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index b3d85f30d424..97e11ab573f0 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -123,7 +123,7 @@ static inline void node_page_state_add(long x, struct pglist_data *pgdat,
 	atomic_long_add(x, &vm_node_stat[item]);
 }
 
-static inline unsigned long global_page_state(enum zone_stat_item item)
+static inline unsigned long global_zone_page_state(enum zone_stat_item item)
 {
 	long x = atomic_long_read(&vm_zone_stat[item]);
 #ifdef CONFIG_SMP
@@ -199,7 +199,7 @@ extern unsigned long sum_zone_node_page_state(int node,
 extern unsigned long node_page_state(struct pglist_data *pgdat,
 						enum node_stat_item item);
 #else
-#define sum_zone_node_page_state(node, item) global_page_state(item)
+#define sum_zone_node_page_state(node, item) global_zone_page_state(item)
 #define node_page_state(node, item) global_node_page_state(item)
 #endif /* CONFIG_NUMA */
 
diff --git a/mm/mmap.c b/mm/mmap.c
index f19efcf75418..9800e29763f4 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3514,7 +3514,7 @@ static int init_user_reserve(void)
 {
 	unsigned long free_kbytes;
 
-	free_kbytes = global_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);
+	free_kbytes = global_zone_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);
 
 	sysctl_user_reserve_kbytes = min(free_kbytes / 32, 1UL << 17);
 	return 0;
@@ -3535,7 +3535,7 @@ static int init_admin_reserve(void)
 {
 	unsigned long free_kbytes;
 
-	free_kbytes = global_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);
+	free_kbytes = global_zone_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);
 
 	sysctl_admin_reserve_kbytes = min(free_kbytes / 32, 1UL << 13);
 	return 0;
@@ -3579,7 +3579,7 @@ static int reserve_mem_notifier(struct notifier_block *nb,
 
 		break;
 	case MEM_OFFLINE:
-		free_kbytes = global_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);
+		free_kbytes = global_zone_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);
 
 		if (sysctl_user_reserve_kbytes > free_kbytes) {
 			init_user_reserve();
diff --git a/mm/nommu.c b/mm/nommu.c
index fc184f597d59..53d5175a5c14 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1962,7 +1962,7 @@ static int __meminit init_user_reserve(void)
 {
 	unsigned long free_kbytes;
 
-	free_kbytes = global_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);
+	free_kbytes = global_zone_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);
 
 	sysctl_user_reserve_kbytes = min(free_kbytes / 32, 1UL << 17);
 	return 0;
@@ -1983,7 +1983,7 @@ static int __meminit init_admin_reserve(void)
 {
 	unsigned long free_kbytes;
 
-	free_kbytes = global_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);
+	free_kbytes = global_zone_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);
 
 	sysctl_admin_reserve_kbytes = min(free_kbytes / 32, 1UL << 13);
 	return 0;
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 96e93b214d31..88562a0feb14 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -363,7 +363,7 @@ static unsigned long global_dirtyable_memory(void)
 {
 	unsigned long x;
 
-	x = global_page_state(NR_FREE_PAGES);
+	x = global_zone_page_state(NR_FREE_PAGES);
 	/*
 	 * Pages reserved for the kernel should not be considered
 	 * dirtyable, to prevent a situation where reclaim has to
@@ -1405,7 +1405,7 @@ void wb_update_bandwidth(struct bdi_writeback *wb, unsigned long start_time)
  * will look to see if it needs to start dirty throttling.
  *
  * If dirty_poll_interval is too low, big NUMA machines will call the expensive
- * global_page_state() too often. So scale it near-sqrt to the safety margin
+ * global_zone_page_state() too often. So scale it near-sqrt to the safety margin
  * (the number of pages we may dirty without exceeding the dirty limits).
  */
 static unsigned long dirty_poll_interval(unsigned long dirty,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3e89731a86bd..ff153f7a0586 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4443,7 +4443,7 @@ long si_mem_available(void)
 	 * Estimate the amount of memory available for userspace allocations,
 	 * without causing swapping.
 	 */
-	available = global_page_state(NR_FREE_PAGES) - totalreserve_pages;
+	available = global_zone_page_state(NR_FREE_PAGES) - totalreserve_pages;
 
 	/*
 	 * Not all the page cache can be freed, otherwise the system will
@@ -4472,7 +4472,7 @@ void si_meminfo(struct sysinfo *val)
 {
 	val->totalram = totalram_pages;
 	val->sharedram = global_node_page_state(NR_SHMEM);
-	val->freeram = global_page_state(NR_FREE_PAGES);
+	val->freeram = global_zone_page_state(NR_FREE_PAGES);
 	val->bufferram = nr_blockdev_pages();
 	val->totalhigh = totalhigh_pages;
 	val->freehigh = nr_free_highpages();
@@ -4607,11 +4607,11 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 		global_node_page_state(NR_SLAB_UNRECLAIMABLE),
 		global_node_page_state(NR_FILE_MAPPED),
 		global_node_page_state(NR_SHMEM),
-		global_page_state(NR_PAGETABLE),
-		global_page_state(NR_BOUNCE),
-		global_page_state(NR_FREE_PAGES),
+		global_zone_page_state(NR_PAGETABLE),
+		global_zone_page_state(NR_BOUNCE),
+		global_zone_page_state(NR_FREE_PAGES),
 		free_pcp,
-		global_page_state(NR_FREE_CMA_PAGES));
+		global_zone_page_state(NR_FREE_CMA_PAGES));
 
 	for_each_online_pgdat(pgdat) {
 		if (show_mem_node_skip(filter, pgdat->node_id, nodemask))
diff --git a/mm/util.c b/mm/util.c
index 9ecddf568fe3..34e57fae959d 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -614,7 +614,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		return 0;
 
 	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
-		free = global_page_state(NR_FREE_PAGES);
+		free = global_zone_page_state(NR_FREE_PAGES);
 		free += global_node_page_state(NR_FILE_PAGES);
 
 		/*
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 9a4441bbeef2..4544d44e9594 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1500,7 +1500,7 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 	if (!v)
 		return ERR_PTR(-ENOMEM);
 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
-		v[i] = global_page_state(i);
+		v[i] = global_zone_page_state(i);
 	v += NR_VM_ZONE_STAT_ITEMS;
 
 	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
@@ -1589,7 +1589,7 @@ int vmstat_refresh(struct ctl_table *table, int write,
 	 * which can equally be echo'ed to or cat'ted from (by root),
 	 * can be used to update the stats just before reading them.
 	 *
-	 * Oh, and since global_page_state() etc. are so careful to hide
+	 * Oh, and since global_zone_page_state() etc. are so careful to hide
 	 * transiently negative values, report an error here if any of
 	 * the stats is negative, so we know to go looking for imbalance.
 	 */
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
