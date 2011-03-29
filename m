Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 264388D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 13:32:56 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V3] Add the pagefault count into memcg stats
Date: Tue, 29 Mar 2011 10:32:33 -0700
Message-Id: <1301419953-2282-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

Two new stats in per-memcg memory.stat which tracks the number of
page faults and number of major page faults.

"pgfault"
"pgmajfault"

They are different from "pgpgin"/"pgpgout" stat which count number of
pages charged/discharged to the cgroup and have no meaning of reading/
writing page to disk.

It is valuable to track the two stats for both measuring application's
performance as well as the efficiency of the kernel page reclaim path.
Counting pagefaults per process is useful, but we also need the aggregated
value since processes are monitored and controlled in cgroup basis in memcg.

Functional test: check the total number of pgfault/pgmajfault of all
memcgs and compare with global vmstat value:

$ cat /proc/vmstat | grep fault
pgfault 1070751
pgmajfault 553

$ cat /dev/cgroup/memory.stat | grep fault
pgfault 1071138
pgmajfault 553
total_pgfault 1071142
total_pgmajfault 553

$ cat /dev/cgroup/A/memory.stat | grep fault
pgfault 199
pgmajfault 0
total_pgfault 199
total_pgmajfault 0

Performance test: run page fault test(pft) wit 16 thread on faulting in 15G
anon pages in 16G container. There is no regression noticed on the "flt/cpu/s"

Sample output from pft:
TAG pft:anon-sys-default:
  Gb  Thr CLine   User     System     Wall    flt/cpu/s fault/wsec
  15   16   1     0.67s   233.41s    14.76s   16798.546 266356.260

+-------------------------------------------------------------------------+
    N           Min           Max        Median           Avg        Stddev
x  10     16682.962     17344.027     16913.524     16928.812      166.5362
+  10     16695.568     16923.896     16820.604     16824.652     84.816568
No difference proven at 95.0% confidence

Change v3..v2
1. removed the unnecessary function definition in memcontrol.h

Signed-off-by: Ying Han <yinghan@google.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memory.txt |    4 +++
 fs/ncpfs/mmap.c                  |    2 +
 include/linux/memcontrol.h       |    6 +++++
 mm/filemap.c                     |    1 +
 mm/memcontrol.c                  |   47 ++++++++++++++++++++++++++++++++++++++
 mm/memory.c                      |    2 +
 mm/shmem.c                       |    2 +
 7 files changed, 64 insertions(+), 0 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index b6ed61c..2db6103 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -385,6 +385,8 @@ mapped_file	- # of bytes of mapped file (includes tmpfs/shmem)
 pgpgin		- # of pages paged in (equivalent to # of charging events).
 pgpgout		- # of pages paged out (equivalent to # of uncharging events).
 swap		- # of bytes of swap usage
+pgfault		- # of page faults.
+pgmajfault	- # of major page faults.
 inactive_anon	- # of bytes of anonymous memory and swap cache memory on
 		LRU list.
 active_anon	- # of bytes of anonymous and swap cache memory on active
@@ -406,6 +408,8 @@ total_mapped_file	- sum of all children's "cache"
 total_pgpgin		- sum of all children's "pgpgin"
 total_pgpgout		- sum of all children's "pgpgout"
 total_swap		- sum of all children's "swap"
+total_pgfault		- sum of all children's "pgfault"
+total_pgmajfault	- sum of all children's "pgmajfault"
 total_inactive_anon	- sum of all children's "inactive_anon"
 total_active_anon	- sum of all children's "active_anon"
 total_inactive_file	- sum of all children's "inactive_file"
diff --git a/fs/ncpfs/mmap.c b/fs/ncpfs/mmap.c
index a7c07b4..e5d71b2 100644
--- a/fs/ncpfs/mmap.c
+++ b/fs/ncpfs/mmap.c
@@ -16,6 +16,7 @@
 #include <linux/mman.h>
 #include <linux/string.h>
 #include <linux/fcntl.h>
+#include <linux/memcontrol.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -92,6 +93,7 @@ static int ncp_file_mmap_fault(struct vm_area_struct *area,
 	 * -- wli
 	 */
 	count_vm_event(PGMAJFAULT);
+	mem_cgroup_count_vm_event(area->vm_mm, PGMAJFAULT);
 	return VM_FAULT_MAJOR;
 }
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5a5ce70..8a48f5b 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -24,6 +24,7 @@ struct mem_cgroup;
 struct page_cgroup;
 struct page;
 struct mm_struct;
+enum vm_event_item;
 
 /* Stats that can be updated by kernel. */
 enum mem_cgroup_page_stat_item {
@@ -147,6 +148,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask);
 u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
 
+void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail);
 #endif
@@ -354,6 +356,10 @@ static inline void mem_cgroup_split_huge_fixup(struct page *head,
 {
 }
 
+static inline
+void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
+{
+}
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
diff --git a/mm/filemap.c b/mm/filemap.c
index a6cfecf..e022229 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1683,6 +1683,7 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		/* No page in the page cache at all */
 		do_sync_mmap_readahead(vma, ra, file, offset);
 		count_vm_event(PGMAJFAULT);
+		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
 		ret = VM_FAULT_MAJOR;
 retry_find:
 		page = find_get_page(mapping, offset);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4407dd0..8f9cf7b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -94,6 +94,8 @@ enum mem_cgroup_events_index {
 	MEM_CGROUP_EVENTS_PGPGIN,	/* # of pages paged in */
 	MEM_CGROUP_EVENTS_PGPGOUT,	/* # of pages paged out */
 	MEM_CGROUP_EVENTS_COUNT,	/* # of pages paged in/out */
+	MEM_CGROUP_EVENTS_PGFAULT,	/* # of page-faults */
+	MEM_CGROUP_EVENTS_PGMAJFAULT,	/* # of major page-faults */
 	MEM_CGROUP_EVENTS_NSTATS,
 };
 /*
@@ -585,6 +587,16 @@ static void mem_cgroup_swap_statistics(struct mem_cgroup *mem,
 	this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_SWAPOUT], val);
 }
 
+void mem_cgroup_pgfault(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_PGFAULT], val);
+}
+
+void mem_cgroup_pgmajfault(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_PGMAJFAULT], val);
+}
+
 static unsigned long mem_cgroup_read_events(struct mem_cgroup *mem,
 					    enum mem_cgroup_events_index idx)
 {
@@ -813,6 +825,33 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
 	return (mem == root_mem_cgroup);
 }
 
+void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
+{
+	struct mem_cgroup *mem;
+
+	if (!mm)
+		return;
+
+	rcu_read_lock();
+	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
+	if (unlikely(!mem))
+		goto out;
+
+	switch (idx) {
+	case PGMAJFAULT:
+		mem_cgroup_pgmajfault(mem, 1);
+		break;
+	case PGFAULT:
+		mem_cgroup_pgfault(mem, 1);
+		break;
+	default:
+		BUG();
+	}
+out:
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL(mem_cgroup_count_vm_event);
+
 /*
  * Following LRU functions are allowed to be used without PCG_LOCK.
  * Operations are called by routine of global LRU independently from memcg.
@@ -3772,6 +3811,8 @@ enum {
 	MCS_PGPGIN,
 	MCS_PGPGOUT,
 	MCS_SWAP,
+	MCS_PGFAULT,
+	MCS_PGMAJFAULT,
 	MCS_INACTIVE_ANON,
 	MCS_ACTIVE_ANON,
 	MCS_INACTIVE_FILE,
@@ -3794,6 +3835,8 @@ struct {
 	{"pgpgin", "total_pgpgin"},
 	{"pgpgout", "total_pgpgout"},
 	{"swap", "total_swap"},
+	{"pgfault", "total_pgfault"},
+	{"pgmajfault", "total_pgmajfault"},
 	{"inactive_anon", "total_inactive_anon"},
 	{"active_anon", "total_active_anon"},
 	{"inactive_file", "total_inactive_file"},
@@ -3822,6 +3865,10 @@ mem_cgroup_get_local_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
 		val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_SWAPOUT);
 		s->stat[MCS_SWAP] += val * PAGE_SIZE;
 	}
+	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGFAULT);
+	s->stat[MCS_PGFAULT] += val;
+	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGMAJFAULT);
+	s->stat[MCS_PGMAJFAULT] += val;
 
 	/* per zone stat */
 	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON);
diff --git a/mm/memory.c b/mm/memory.c
index 8617d39..28d19b6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2836,6 +2836,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		/* Had to read the page from swap area: Major fault */
 		ret = VM_FAULT_MAJOR;
 		count_vm_event(PGMAJFAULT);
+		mem_cgroup_count_vm_event(mm, PGMAJFAULT);
 	} else if (PageHWPoison(page)) {
 		/*
 		 * hwpoisoned dirty swapcache pages are kept for killing
@@ -3375,6 +3376,7 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	__set_current_state(TASK_RUNNING);
 
 	count_vm_event(PGFAULT);
+	mem_cgroup_count_vm_event(mm, PGFAULT);
 
 	/* do counter updates before entering really critical section. */
 	check_sync_rss_stat(current);
diff --git a/mm/shmem.c b/mm/shmem.c
index ad8346b..fa0b2b8 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1289,6 +1289,8 @@ repeat:
 			/* here we actually do the io */
 			if (type && !(*type & VM_FAULT_MAJOR)) {
 				__count_vm_event(PGMAJFAULT);
+				mem_cgroup_count_vm_event(current->mm,
+							  PGMAJFAULT);
 				*type |= VM_FAULT_MAJOR;
 			}
 			spin_unlock(&info->lock);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
