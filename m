Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 366896B02B4
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 11:14:52 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id l34so22259358wrc.12
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 08:14:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x128si13729386wmf.71.2017.06.20.08.14.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Jun 2017 08:14:49 -0700 (PDT)
From: Nikolay Borisov <nborisov@suse.com>
Subject: [PATCH] mm: Refactor conversion of pages to bytes macro definitions
Date: Tue, 20 Jun 2017 18:14:28 +0300
Message-Id: <1497971668-30685-1-git-send-email-nborisov@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mgorman@techsingularity.net, cmetcalf@mellanox.com, minchan@kernel.org, vbabka@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, tj@kernel.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Nikolay Borisov <nborisov@suse.com>

Currently there are a multiple files with the following code:
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 ... some code..
 #undef K

This is mainly used to print out some memory-related statistics, where X is
given in pages and the macro just converts it to kilobytes. In the future
there is going to be more macros since there are intention to introduce
byte-based memory counters [1]. This could lead to proliferation of
multiple duplicated definition of various macros used to convert a quantity
from one unit to another. Let's try and consolidate such definition in the
mm.h header since currently it's being included in all files which exhibit
this pattern. Also let's rename it to something a bit more verbose.

This patch doesn't introduce any functional changes

[1] https://patchwork.kernel.org/patch/9395205/

Signed-off-by: Nikolay Borisov <nborisov@suse.com>
---
 arch/tile/mm/pgtable.c      |  2 --
 drivers/base/node.c         | 66 ++++++++++++++++++-------------------
 include/linux/mm.h          |  2 ++
 kernel/debug/kdb/kdb_main.c |  3 +-
 mm/backing-dev.c            | 22 +++++--------
 mm/memcontrol.c             | 17 +++++-----
 mm/oom_kill.c               | 19 +++++------
 mm/page_alloc.c             | 80 ++++++++++++++++++++++-----------------------
 8 files changed, 100 insertions(+), 111 deletions(-)

diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
index 492a7361e58e..f04af570c1c2 100644
--- a/arch/tile/mm/pgtable.c
+++ b/arch/tile/mm/pgtable.c
@@ -34,8 +34,6 @@
 #include <asm/tlbflush.h>
 #include <asm/homecache.h>
 
-#define K(x) ((x) << (PAGE_SHIFT-10))
-
 /**
  * shatter_huge_page() - ensure a given address is mapped by a small page.
  *
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 5548f9686016..b6f563a3a3a9 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -50,7 +50,6 @@ static inline ssize_t node_read_cpulist(struct device *dev,
 static DEVICE_ATTR(cpumap,  S_IRUGO, node_read_cpumask, NULL);
 static DEVICE_ATTR(cpulist, S_IRUGO, node_read_cpulist, NULL);
 
-#define K(x) ((x) << (PAGE_SHIFT - 10))
 static ssize_t node_read_meminfo(struct device *dev,
 			struct device_attribute *attr, char *buf)
 {
@@ -72,19 +71,19 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d Inactive(file): %8lu kB\n"
 		       "Node %d Unevictable:    %8lu kB\n"
 		       "Node %d Mlocked:        %8lu kB\n",
-		       nid, K(i.totalram),
-		       nid, K(i.freeram),
-		       nid, K(i.totalram - i.freeram),
-		       nid, K(node_page_state(pgdat, NR_ACTIVE_ANON) +
+		       nid, PtoK(i.totalram),
+		       nid, PtoK(i.freeram),
+		       nid, PtoK(i.totalram - i.freeram),
+		       nid, PtoK(node_page_state(pgdat, NR_ACTIVE_ANON) +
 				node_page_state(pgdat, NR_ACTIVE_FILE)),
-		       nid, K(node_page_state(pgdat, NR_INACTIVE_ANON) +
+		       nid, PtoK(node_page_state(pgdat, NR_INACTIVE_ANON) +
 				node_page_state(pgdat, NR_INACTIVE_FILE)),
-		       nid, K(node_page_state(pgdat, NR_ACTIVE_ANON)),
-		       nid, K(node_page_state(pgdat, NR_INACTIVE_ANON)),
-		       nid, K(node_page_state(pgdat, NR_ACTIVE_FILE)),
-		       nid, K(node_page_state(pgdat, NR_INACTIVE_FILE)),
-		       nid, K(node_page_state(pgdat, NR_UNEVICTABLE)),
-		       nid, K(sum_zone_node_page_state(nid, NR_MLOCK)));
+		       nid, PtoK(node_page_state(pgdat, NR_ACTIVE_ANON)),
+		       nid, PtoK(node_page_state(pgdat, NR_INACTIVE_ANON)),
+		       nid, PtoK(node_page_state(pgdat, NR_ACTIVE_FILE)),
+		       nid, PtoK(node_page_state(pgdat, NR_INACTIVE_FILE)),
+		       nid, PtoK(node_page_state(pgdat, NR_UNEVICTABLE)),
+		       nid, PtoK(sum_zone_node_page_state(nid, NR_MLOCK)));
 
 #ifdef CONFIG_HIGHMEM
 	n += sprintf(buf + n,
@@ -92,10 +91,10 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d HighFree:       %8lu kB\n"
 		       "Node %d LowTotal:       %8lu kB\n"
 		       "Node %d LowFree:        %8lu kB\n",
-		       nid, K(i.totalhigh),
-		       nid, K(i.freehigh),
-		       nid, K(i.totalram - i.totalhigh),
-		       nid, K(i.freeram - i.freehigh));
+		       nid, PtoK(i.totalhigh),
+		       nid, PtoK(i.freehigh),
+		       nid, PtoK(i.totalram - i.totalhigh),
+		       nid, PtoK(i.freeram - i.freehigh));
 #endif
 	n += sprintf(buf + n,
 		       "Node %d Dirty:          %8lu kB\n"
@@ -118,36 +117,35 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d ShmemPmdMapped: %8lu kB\n"
 #endif
 			,
-		       nid, K(node_page_state(pgdat, NR_FILE_DIRTY)),
-		       nid, K(node_page_state(pgdat, NR_WRITEBACK)),
-		       nid, K(node_page_state(pgdat, NR_FILE_PAGES)),
-		       nid, K(node_page_state(pgdat, NR_FILE_MAPPED)),
-		       nid, K(node_page_state(pgdat, NR_ANON_MAPPED)),
-		       nid, K(i.sharedram),
+		       nid, PtoK(node_page_state(pgdat, NR_FILE_DIRTY)),
+		       nid, PtoK(node_page_state(pgdat, NR_WRITEBACK)),
+		       nid, PtoK(node_page_state(pgdat, NR_FILE_PAGES)),
+		       nid, PtoK(node_page_state(pgdat, NR_FILE_MAPPED)),
+		       nid, PtoK(node_page_state(pgdat, NR_ANON_MAPPED)),
+		       nid, PtoK(i.sharedram),
 		       nid, sum_zone_node_page_state(nid, NR_KERNEL_STACK_KB),
-		       nid, K(sum_zone_node_page_state(nid, NR_PAGETABLE)),
-		       nid, K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
-		       nid, K(sum_zone_node_page_state(nid, NR_BOUNCE)),
-		       nid, K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
-		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_RECLAIMABLE) +
+		       nid, PtoK(sum_zone_node_page_state(nid, NR_PAGETABLE)),
+		       nid, PtoK(node_page_state(pgdat, NR_UNSTABLE_NFS)),
+		       nid, PtoK(sum_zone_node_page_state(nid, NR_BOUNCE)),
+		       nid, PtoK(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
+		       nid, PtoK(sum_zone_node_page_state(nid, NR_SLAB_RECLAIMABLE) +
 				sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
-		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_RECLAIMABLE)),
+		       nid, PtoK(sum_zone_node_page_state(nid, NR_SLAB_RECLAIMABLE)),
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
-		       nid, K(node_page_state(pgdat, NR_ANON_THPS) *
+		       nid, PtoK(sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
+		       nid, PtoK(node_page_state(pgdat, NR_ANON_THPS) *
 				       HPAGE_PMD_NR),
-		       nid, K(node_page_state(pgdat, NR_SHMEM_THPS) *
+		       nid, PtoK(node_page_state(pgdat, NR_SHMEM_THPS) *
 				       HPAGE_PMD_NR),
-		       nid, K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED) *
+		       nid, PtoK(node_page_state(pgdat, NR_SHMEM_PMDMAPPED) *
 				       HPAGE_PMD_NR));
 #else
-		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE)));
+		       nid, PtoK(sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE)));
 #endif
 	n += hugetlb_report_node_meminfo(nid, buf + n);
 	return n;
 }
 
-#undef K
 static DEVICE_ATTR(meminfo, S_IRUGO, node_read_meminfo, NULL);
 
 static ssize_t node_read_numastat(struct device *dev,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6f543a47fc92..d8d80e2e9194 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -93,6 +93,8 @@ extern int mmap_rnd_compat_bits __read_mostly;
 #define mm_forbids_zeropage(X)	(0)
 #endif
 
+#define PtoK(pages) ((pages) << (PAGE_SHIFT-10))
+
 /*
  * Default maximum number of active map areas, this limits the number of vmas
  * per mm struct. Users can overwrite this number by sysctl but there is a
diff --git a/kernel/debug/kdb/kdb_main.c b/kernel/debug/kdb/kdb_main.c
index c8146d53ca67..e833cb02d2c8 100644
--- a/kernel/debug/kdb/kdb_main.c
+++ b/kernel/debug/kdb/kdb_main.c
@@ -2582,10 +2582,9 @@ static int kdb_summary(int argc, const char **argv)
 #undef LOAD_INT
 #undef LOAD_FRAC
 	/* Display in kilobytes */
-#define K(x) ((x) << (PAGE_SHIFT - 10))
 	kdb_printf("\nMemTotal:       %8lu kB\nMemFree:        %8lu kB\n"
 		   "Buffers:        %8lu kB\n",
-		   K(val.totalram), K(val.freeram), K(val.bufferram));
+		   PtoK(val.totalram), PtoK(val.freeram), PtoK(val.bufferram));
 	return 0;
 }
 
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index f028a9a472fd..0c09dd103109 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -67,7 +67,6 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 	global_dirty_limits(&background_thresh, &dirty_thresh);
 	wb_thresh = wb_calc_thresh(wb, dirty_thresh);
 
-#define K(x) ((x) << (PAGE_SHIFT - 10))
 	seq_printf(m,
 		   "BdiWriteback:       %10lu kB\n"
 		   "BdiReclaimable:     %10lu kB\n"
@@ -83,20 +82,19 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   "b_dirty_time:       %10lu\n"
 		   "bdi_list:           %10u\n"
 		   "state:              %10lx\n",
-		   (unsigned long) K(wb_stat(wb, WB_WRITEBACK)),
-		   (unsigned long) K(wb_stat(wb, WB_RECLAIMABLE)),
-		   K(wb_thresh),
-		   K(dirty_thresh),
-		   K(background_thresh),
-		   (unsigned long) K(wb_stat(wb, WB_DIRTIED)),
-		   (unsigned long) K(wb_stat(wb, WB_WRITTEN)),
-		   (unsigned long) K(wb->write_bandwidth),
+		   (unsigned long) PtoK(wb_stat(wb, WB_WRITEBACK)),
+		   (unsigned long) PtoK(wb_stat(wb, WB_RECLAIMABLE)),
+		   PtoK(wb_thresh),
+		   PtoK(dirty_thresh),
+		   PtoK(background_thresh),
+		   (unsigned long) PtoK(wb_stat(wb, WB_DIRTIED)),
+		   (unsigned long) PtoK(wb_stat(wb, WB_WRITTEN)),
+		   (unsigned long) PtoK(wb->write_bandwidth),
 		   nr_dirty,
 		   nr_io,
 		   nr_more_io,
 		   nr_dirty_time,
 		   !list_empty(&bdi->bdi_list), bdi->wb.state);
-#undef K
 
 	return 0;
 }
@@ -155,8 +153,6 @@ static ssize_t read_ahead_kb_store(struct device *dev,
 	return count;
 }
 
-#define K(pages) ((pages) << (PAGE_SHIFT - 10))
-
 #define BDI_SHOW(name, expr)						\
 static ssize_t name##_show(struct device *dev,				\
 			   struct device_attribute *attr, char *page)	\
@@ -167,7 +163,7 @@ static ssize_t name##_show(struct device *dev,				\
 }									\
 static DEVICE_ATTR_RW(name);
 
-BDI_SHOW(read_ahead_kb, K(bdi->ra_pages))
+BDI_SHOW(read_ahead_kb, PtoK(bdi->ra_pages))
 
 static ssize_t min_ratio_store(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 94172089f52f..f0f1f4dbe816 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1132,7 +1132,6 @@ static const char *const memcg1_stat_names[] = {
 	"swap",
 };
 
-#define K(x) ((x) << (PAGE_SHIFT-10))
 /**
  * mem_cgroup_print_oom_info: Print OOM information relevant to memory controller.
  * @memcg: The memory cgroup that went over limit
@@ -1162,14 +1161,14 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 	rcu_read_unlock();
 
 	pr_info("memory: usage %llukB, limit %llukB, failcnt %lu\n",
-		K((u64)page_counter_read(&memcg->memory)),
-		K((u64)memcg->memory.limit), memcg->memory.failcnt);
+		PtoK((u64)page_counter_read(&memcg->memory)),
+		PtoK((u64)memcg->memory.limit), memcg->memory.failcnt);
 	pr_info("memory+swap: usage %llukB, limit %llukB, failcnt %lu\n",
-		K((u64)page_counter_read(&memcg->memsw)),
-		K((u64)memcg->memsw.limit), memcg->memsw.failcnt);
+		PtoK((u64)page_counter_read(&memcg->memsw)),
+		PtoK((u64)memcg->memsw.limit), memcg->memsw.failcnt);
 	pr_info("kmem: usage %llukB, limit %llukB, failcnt %lu\n",
-		K((u64)page_counter_read(&memcg->kmem)),
-		K((u64)memcg->kmem.limit), memcg->kmem.failcnt);
+		PtoK((u64)page_counter_read(&memcg->kmem)),
+		PtoK((u64)memcg->kmem.limit), memcg->kmem.failcnt);
 
 	for_each_mem_cgroup_tree(iter, memcg) {
 		pr_info("Memory cgroup stats for ");
@@ -1180,12 +1179,12 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 			if (memcg1_stats[i] == MEMCG_SWAP && !do_swap_account)
 				continue;
 			pr_cont(" %s:%luKB", memcg1_stat_names[i],
-				K(memcg_page_state(iter, memcg1_stats[i])));
+				PtoK(memcg_page_state(iter, memcg1_stats[i])));
 		}
 
 		for (i = 0; i < NR_LRU_LISTS; i++)
 			pr_cont(" %s:%luKB", mem_cgroup_lru_names[i],
-				K(mem_cgroup_nr_lru_pages(iter, BIT(i))));
+				PtoK(mem_cgroup_nr_lru_pages(iter, BIT(i))));
 
 		pr_cont("\n");
 	}
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 04c9143a8625..d83801347c96 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1,6 +1,6 @@
 /*
  *  linux/mm/oom_kill.c
- * 
+ *
  *  Copyright (C)  1998,2000  Rik van Riel
  *	Thanks go out to Claus Fischer for some serious inspiration and
  *	for goading me into coding this file...
@@ -435,8 +435,6 @@ static DECLARE_WAIT_QUEUE_HEAD(oom_victims_wait);
 
 static bool oom_killer_disabled __read_mostly;
 
-#define K(x) ((x) << (PAGE_SHIFT-10))
-
 /*
  * task->mm can be NULL if the task is the exited group leader.  So to
  * determine whether the task is using a particular mm, we examine all the
@@ -533,9 +531,9 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	tlb_finish_mmu(&tlb, 0, -1);
 	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 			task_pid_nr(tsk), tsk->comm,
-			K(get_mm_counter(mm, MM_ANONPAGES)),
-			K(get_mm_counter(mm, MM_FILEPAGES)),
-			K(get_mm_counter(mm, MM_SHMEMPAGES)));
+			PtoK(get_mm_counter(mm, MM_ANONPAGES)),
+			PtoK(get_mm_counter(mm, MM_FILEPAGES)),
+			PtoK(get_mm_counter(mm, MM_SHMEMPAGES)));
 	up_read(&mm->mmap_sem);
 
 	/*
@@ -884,10 +882,10 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	mark_oom_victim(victim);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
-		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
-		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
-		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
-		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
+		task_pid_nr(victim), victim->comm, PtoK(victim->mm->total_vm),
+		PtoK(get_mm_counter(victim->mm, MM_ANONPAGES)),
+		PtoK(get_mm_counter(victim->mm, MM_FILEPAGES)),
+		PtoK(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
 	task_unlock(victim);
 
 	/*
@@ -929,7 +927,6 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	mmdrop(mm);
 	put_task_struct(victim);
 }
-#undef K
 
 /*
  * Determines whether the kernel must panic because of the panic_on_oom sysctl.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2302f250d6b1..5785a2f8d7db 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4460,8 +4460,6 @@ static bool show_mem_node_skip(unsigned int flags, int nid, nodemask_t *nodemask
 	return !node_isset(nid, *nodemask);
 }
 
-#define K(x) ((x) << (PAGE_SHIFT-10))
-
 static void show_migration_types(unsigned char type)
 {
 	static const char types[MIGRATE_TYPES] = {
@@ -4565,25 +4563,27 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 			" all_unreclaimable? %s"
 			"\n",
 			pgdat->node_id,
-			K(node_page_state(pgdat, NR_ACTIVE_ANON)),
-			K(node_page_state(pgdat, NR_INACTIVE_ANON)),
-			K(node_page_state(pgdat, NR_ACTIVE_FILE)),
-			K(node_page_state(pgdat, NR_INACTIVE_FILE)),
-			K(node_page_state(pgdat, NR_UNEVICTABLE)),
-			K(node_page_state(pgdat, NR_ISOLATED_ANON)),
-			K(node_page_state(pgdat, NR_ISOLATED_FILE)),
-			K(node_page_state(pgdat, NR_FILE_MAPPED)),
-			K(node_page_state(pgdat, NR_FILE_DIRTY)),
-			K(node_page_state(pgdat, NR_WRITEBACK)),
-			K(node_page_state(pgdat, NR_SHMEM)),
+			PtoK(node_page_state(pgdat, NR_ACTIVE_ANON)),
+			PtoK(node_page_state(pgdat, NR_INACTIVE_ANON)),
+			PtoK(node_page_state(pgdat, NR_ACTIVE_FILE)),
+			PtoK(node_page_state(pgdat, NR_INACTIVE_FILE)),
+			PtoK(node_page_state(pgdat, NR_UNEVICTABLE)),
+			PtoK(node_page_state(pgdat, NR_ISOLATED_ANON)),
+			PtoK(node_page_state(pgdat, NR_ISOLATED_FILE)),
+			PtoK(node_page_state(pgdat, NR_FILE_MAPPED)),
+			PtoK(node_page_state(pgdat, NR_FILE_DIRTY)),
+			PtoK(node_page_state(pgdat, NR_WRITEBACK)),
+			PtoK(node_page_state(pgdat, NR_SHMEM)),
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-			K(node_page_state(pgdat, NR_SHMEM_THPS) * HPAGE_PMD_NR),
-			K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED)
+			PtoK(node_page_state(pgdat, NR_SHMEM_THPS) *
+			     HPAGE_PMD_NR),
+			PtoK(node_page_state(pgdat, NR_SHMEM_PMDMAPPED)
 					* HPAGE_PMD_NR),
-			K(node_page_state(pgdat, NR_ANON_THPS) * HPAGE_PMD_NR),
+			PtoK(node_page_state(pgdat, NR_ANON_THPS) *
+			     HPAGE_PMD_NR),
 #endif
-			K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
-			K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
+			PtoK(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
+			PtoK(node_page_state(pgdat, NR_UNSTABLE_NFS)),
 			pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES ?
 				"yes" : "no");
 	}
@@ -4624,27 +4624,27 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 			" free_cma:%lukB"
 			"\n",
 			zone->name,
-			K(zone_page_state(zone, NR_FREE_PAGES)),
-			K(min_wmark_pages(zone)),
-			K(low_wmark_pages(zone)),
-			K(high_wmark_pages(zone)),
-			K(zone_page_state(zone, NR_ZONE_ACTIVE_ANON)),
-			K(zone_page_state(zone, NR_ZONE_INACTIVE_ANON)),
-			K(zone_page_state(zone, NR_ZONE_ACTIVE_FILE)),
-			K(zone_page_state(zone, NR_ZONE_INACTIVE_FILE)),
-			K(zone_page_state(zone, NR_ZONE_UNEVICTABLE)),
-			K(zone_page_state(zone, NR_ZONE_WRITE_PENDING)),
-			K(zone->present_pages),
-			K(zone->managed_pages),
-			K(zone_page_state(zone, NR_MLOCK)),
-			K(zone_page_state(zone, NR_SLAB_RECLAIMABLE)),
-			K(zone_page_state(zone, NR_SLAB_UNRECLAIMABLE)),
+			PtoK(zone_page_state(zone, NR_FREE_PAGES)),
+			PtoK(min_wmark_pages(zone)),
+			PtoK(low_wmark_pages(zone)),
+			PtoK(high_wmark_pages(zone)),
+			PtoK(zone_page_state(zone, NR_ZONE_ACTIVE_ANON)),
+			PtoK(zone_page_state(zone, NR_ZONE_INACTIVE_ANON)),
+			PtoK(zone_page_state(zone, NR_ZONE_ACTIVE_FILE)),
+			PtoK(zone_page_state(zone, NR_ZONE_INACTIVE_FILE)),
+			PtoK(zone_page_state(zone, NR_ZONE_UNEVICTABLE)),
+			PtoK(zone_page_state(zone, NR_ZONE_WRITE_PENDING)),
+			PtoK(zone->present_pages),
+			PtoK(zone->managed_pages),
+			PtoK(zone_page_state(zone, NR_MLOCK)),
+			PtoK(zone_page_state(zone, NR_SLAB_RECLAIMABLE)),
+			PtoK(zone_page_state(zone, NR_SLAB_UNRECLAIMABLE)),
 			zone_page_state(zone, NR_KERNEL_STACK_KB),
-			K(zone_page_state(zone, NR_PAGETABLE)),
-			K(zone_page_state(zone, NR_BOUNCE)),
-			K(free_pcp),
-			K(this_cpu_read(zone->pageset->pcp.count)),
-			K(zone_page_state(zone, NR_FREE_CMA_PAGES)));
+			PtoK(zone_page_state(zone, NR_PAGETABLE)),
+			PtoK(zone_page_state(zone, NR_BOUNCE)),
+			PtoK(free_pcp),
+			PtoK(this_cpu_read(zone->pageset->pcp.count)),
+			PtoK(zone_page_state(zone, NR_FREE_CMA_PAGES)));
 		printk("lowmem_reserve[]:");
 		for (i = 0; i < MAX_NR_ZONES; i++)
 			printk(KERN_CONT " %ld", zone->lowmem_reserve[i]);
@@ -4678,11 +4678,11 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 		spin_unlock_irqrestore(&zone->lock, flags);
 		for (order = 0; order < MAX_ORDER; order++) {
 			printk(KERN_CONT "%lu*%lukB ",
-			       nr[order], K(1UL) << order);
+			       nr[order], PtoK(1UL) << order);
 			if (nr[order])
 				show_migration_types(types[order]);
 		}
-		printk(KERN_CONT "= %lukB\n", K(total));
+		printk(KERN_CONT "= %lukB\n", PtoK(total));
 	}
 
 	hugetlb_show_meminfo();
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
