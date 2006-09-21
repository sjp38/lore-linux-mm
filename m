Date: Thu, 21 Sep 2006 15:11:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
In-Reply-To: <Pine.LNX.4.63.0609191222310.7790@chino.corp.google.com>
Message-ID: <Pine.LNX.4.63.0609211510130.17417@chino.corp.google.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org> <20060914234926.9b58fd77.pj@sgi.com>
 <20060915002325.bffe27d1.akpm@osdl.org> <20060915004402.88d462ff.pj@sgi.com>
 <20060915010622.0e3539d2.akpm@osdl.org> <Pine.LNX.4.63.0609151601230.9416@chino.corp.google.com>
 <Pine.LNX.4.63.0609161734220.16748@chino.corp.google.com>
 <20060917041707.28171868.pj@sgi.com> <Pine.LNX.4.64.0609170540020.14516@schroedinger.engr.sgi.com>
 <20060917060358.ac16babf.pj@sgi.com> <Pine.LNX.4.63.0609171329540.25459@chino.corp.google.com>
 <20060917152723.5bb69b82.pj@sgi.com> <Pine.LNX.4.63.0609171643340.26323@chino.corp.google.com>
 <20060917192010.cc360ece.pj@sgi.com> <20060918093434.e66b8887.pj@sgi.com>
 <Pine.LNX.4.63.0609191222310.7790@chino.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: clameter@sgi.com, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Sep 2006, David Rientjes wrote:

> As Paul and Andrew suggested, there are three additions to task_struct:
> 
>    1.	cached copy of struct zonelist *zonelist that was passed into
> 	get_page_from_freelist,
> 
>    2.	index of zone where free memory was located last, and
> 
>    3.	index of next zone to try when (2) is full.
> 
> get_page_from_freelist, in the case where the passed in zonelist* differs 
> from (1) or in the ~GFP_HARDWALL & ~ALLOC_CPUSET case, uses the current 
> implementation going through the zonelist and finding one with enough free 
> pages.  Otherwise, if we are in the NUMA emulation case, the node where 
> the memory was found most recently can be cached since all memory is 
> equal.  There is no consideration given to the distance between the last 
> used node and the node at the front of the zonelist because the distance 
> between all nodes is 10.  (If the passed in zonelist* differs from (1), 
> then the three additions to task_struct are reset per the new 
> configuration in the same sense as cpuset_update_task_memory_state since 
> the memory placement has changed relative to current->cpuset which 
> cpusets allows by outside manipulation.)  
> 

As suggested by Paul Jackson and friends, this patch abstracts a numa=fake 
macro to the global kernel code.  A macro, 'numa_emu_enabled', is defined 
that can be tested against to determine whether NUMA emulation was 
successful at boot.

In the NUMA emulation case, the most recently allocated from zone is now 
cached in task_struct and used whenever the same zonelist is passed into 
get_page_from_freelist with GFP_HARDWALL and ALLOC_CPUSET.  The node 
distance compared to the first zone's node_id is not compared because 
x86_64 NUMA emulation is not supported for real NUMA machines anyway 
(later work).

This patch is on top of my numa=fake patches that are not currently in -mm 
(this one appears for comments).  Also includes Christoph Lameter's 
z->zone_pgdat->node_id speedup moved away from zone_to_nid since it, too, 
does not appear in my tree.

These trials were the same as before: 3G machine, numa=fake=64, 'usemem -m 
1500 -s 100000 &' in 2G cpuset, and a kernel build in the remaining.

		unpatched	patched		no cpusets, numa=fake=off
	real	5m16.223s	5m9.711s	4m58.118s
	user	9m13.323s	9m16.803s	9m16.583s
	sys	1m7.756s	0m53.947s	0m30.994s

Unpatched top 13:
	8292 __cpuset_zone_allowed		39.4857 <-- ~210.0
	1813 mwait_idle				23.2436
	1042 clear_page				18.2807
	  24 clear_page_end			 3.4286
	 207 find_get_page			 2.9155
	 123 pfn_to_page			 2.6739
	 347 zone_watermark_ok			 2.2244
	 128 __down_read_trylock		 1.9394
	  84 page_remove_rmap			 1.9091
	 155 find_vma				 1.7816
	  80 page_to_pfn			 1.5686
	  60 __strnlen_user			 1.5385
	1250 get_page_from_freelist		 1.3426 <-- ~931.0
329093.6744

Patched top:
	5068 __cpuset_zone_allowed		25.3400 <-- 200.0
	1348 mwait_idle				17.2821
	 928 clear_page				16.2807
	 195 find_get_page			 2.7465
	  17 clear_page_end			 2.4286
	 106 pfn_to_page			 2.3043
	 344 zone_watermark_ok			 2.2051
	  44 nr_free_pages			 1.5172
	  66 page_remove_rmap			 1.5000
	  54 __strnlen_user			 1.3846
	 119 find_vma				 1.3678
	  62 page_to_pfn			 1.2157
	  73 __down_read_trylock		 1.1061
	1133 get_page_from_freelist		 1.0648 <-- ~1064.0

Tradeoff:
	Unpatched:	8292*39.4857 + 1250*1.3426 = 329093.6744
	Patched:	5068*25.3400 + 1133*1.0648 = 129629.5384

Not-signed-off-by: David Rientjes <rientjes@google.com>
---
 arch/x86_64/mm/numa.c  |    9 +++++++--
 arch/x86_64/mm/srat.c  |    2 ++
 include/linux/mmzone.h |    1 +
 include/linux/numa.h   |    7 +++++++
 include/linux/sched.h  |    4 ++++
 kernel/cpuset.c        |    9 +++++++--
 mm/page_alloc.c        |   17 +++++++++++++++--
 7 files changed, 43 insertions(+), 6 deletions(-)

diff --git a/arch/x86_64/mm/numa.c b/arch/x86_64/mm/numa.c
index 9a9e452..46ede0b 100644
--- a/arch/x86_64/mm/numa.c
+++ b/arch/x86_64/mm/numa.c
@@ -11,6 +11,7 @@ #include <linux/mmzone.h>
 #include <linux/ctype.h>
 #include <linux/module.h>
 #include <linux/nodemask.h>
+#include <linux/numa.h>
 
 #include <asm/e820.h>
 #include <asm/proto.h>
@@ -187,6 +188,7 @@ #define E820_ADDR_HOLE_SIZE(start, end)	
 	(e820_hole_size((start) >> PAGE_SHIFT, (end) >> PAGE_SHIFT) <<	\
 		PAGE_SHIFT)
 char *cmdline __initdata;
+int numa_emu;
 
 /*
  * Sets up nodeid to range from addr to addr + sz.  If the end boundary is
@@ -381,8 +383,11 @@ void __init numa_initmem_init(unsigned l
 	int i;
 
 #ifdef CONFIG_NUMA_EMU
-	if (cmdline && !numa_emulation(start_pfn, end_pfn))
- 		return;
+	if (cmdline) {
+		numa_emu = !numa_emulation(start_pfn, end_pfn);
+		if (numa_emu)
+			return;
+	}
 #endif
 
 #ifdef CONFIG_ACPI_NUMA
diff --git a/arch/x86_64/mm/srat.c b/arch/x86_64/mm/srat.c
index 66f375f..eed080c 100644
--- a/arch/x86_64/mm/srat.c
+++ b/arch/x86_64/mm/srat.c
@@ -436,6 +436,8 @@ int __node_distance(int a, int b)
 {
 	int index;
 
+	if (numa_emu_enabled)
+		return 10;
 	if (!acpi_slit)
 		return a == b ? 10 : 20;
 	index = acpi_slit->localities * node_to_pxm(a);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f45163c..81e047d 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -151,6 +151,7 @@ struct zone {
 	unsigned long		lowmem_reserve[MAX_NR_ZONES];
 
 #ifdef CONFIG_NUMA
+	int node;
 	/*
 	 * zone reclaim becomes active if more unmapped pages exist.
 	 */
diff --git a/include/linux/numa.h b/include/linux/numa.h
index a31a730..ff2720d 100644
--- a/include/linux/numa.h
+++ b/include/linux/numa.h
@@ -10,4 +10,11 @@ #endif
 
 #define MAX_NUMNODES    (1 << NODES_SHIFT)
 
+#ifdef CONFIG_NUMA_EMU
+extern int numa_emu;
+#define numa_emu_enabled	numa_emu
+#else
+#define numa_emu_enabled	0
+#endif
+
 #endif /* _LINUX_NUMA_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 34ed0d9..5a2a7f7 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -973,6 +973,10 @@ #ifdef CONFIG_NUMA
   	struct mempolicy *mempolicy;
 	short il_next;
 #endif
+#ifdef CONFIG_NUMA_EMU
+	struct zonelist *last_zonelist;
+	u32 last_zone_used;
+#endif
 #ifdef CONFIG_CPUSETS
 	struct cpuset *cpuset;
 	nodemask_t mems_allowed;
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 4ea6f0d..df19ecf 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -35,6 +35,7 @@ #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/mount.h>
 #include <linux/namei.h>
+#include <linux/numa.h>
 #include <linux/pagemap.h>
 #include <linux/proc_fs.h>
 #include <linux/rcupdate.h>
@@ -677,6 +678,10 @@ void cpuset_update_task_memory_state(voi
 			tsk->flags |= PF_SPREAD_SLAB;
 		else
 			tsk->flags &= ~PF_SPREAD_SLAB;
+		if (numa_emu_enabled) {
+			tsk->last_zonelist = NULL;
+			tsk->last_zone_used = 0;
+		}
 		task_unlock(tsk);
 		mutex_unlock(&callback_mutex);
 		mpol_rebind_task(tsk, &tsk->mems_allowed);
@@ -2245,7 +2250,7 @@ int cpuset_zonelist_valid_mems_allowed(s
 	int i;
 
 	for (i = 0; zl->zones[i]; i++) {
-		int nid = zl->zones[i]->zone_pgdat->node_id;
+		int nid = zl->zones[i]->node;
 
 		if (node_isset(nid, current->mems_allowed))
 			return 1;
@@ -2318,7 +2323,7 @@ int __cpuset_zone_allowed(struct zone *z
 
 	if (in_interrupt())
 		return 1;
-	node = z->zone_pgdat->node_id;
+	node = z->node;
 	might_sleep_if(!(gfp_mask & __GFP_HARDWALL));
 	if (node_isset(node, current->mems_allowed))
 		return 1;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 54a4f53..c80d6a6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -34,6 +34,7 @@ #include <linux/cpu.h>
 #include <linux/cpuset.h>
 #include <linux/memory_hotplug.h>
 #include <linux/nodemask.h>
+#include <linux/numa.h>
 #include <linux/vmalloc.h>
 #include <linux/mempolicy.h>
 #include <linux/stop_machine.h>
@@ -870,6 +871,14 @@ get_page_from_freelist(gfp_t gfp_mask, u
 	struct zone **z = zonelist->zones;
 	struct page *page = NULL;
 	int classzone_idx = zone_idx(*z);
+	unsigned index = 0;
+
+	if (numa_emu_enabled) {
+		if (zonelist == current->last_zonelist &&
+		    (alloc_flags & __GFP_HARDWALL) && (alloc_flags & ALLOC_CPUSET))
+			z += current->last_zone_used;
+		current->last_zonelist = zonelist;
+	}
 
 	/*
 	 * Go through the zonelist once, looking for a zone with enough free.
@@ -897,8 +906,11 @@ get_page_from_freelist(gfp_t gfp_mask, u
 
 		page = buffered_rmqueue(zonelist, *z, order, gfp_mask);
 		if (page) {
+			if (numa_emu_enabled)
+				current->last_zone_used = index;
 			break;
 		}
+		index++;
 	} while (*(++z) != NULL);
 	return page;
 }
@@ -1203,7 +1215,7 @@ #endif
 #ifdef CONFIG_NUMA
 static void show_node(struct zone *zone)
 {
-	printk("Node %d ", zone->zone_pgdat->node_id);
+	printk("Node %d ", zone->node);
 }
 #else
 #define show_node(zone)	do { } while (0)
@@ -1965,7 +1977,7 @@ __meminit int init_currently_empty_zone(
 
 	zone->zone_start_pfn = zone_start_pfn;
 
-	memmap_init(size, pgdat->node_id, zone_idx(zone), zone_start_pfn);
+	memmap_init(size, zone->node, zone_idx(zone), zone_start_pfn);
 
 	zone_init_free_lists(pgdat, zone, zone->spanned_pages);
 
@@ -2006,6 +2018,7 @@ static void __meminit free_area_init_cor
 		zone->spanned_pages = size;
 		zone->present_pages = realsize;
 #ifdef CONFIG_NUMA
+		zone->node = nid;
 		zone->min_unmapped_ratio = (realsize*sysctl_min_unmapped_ratio)
 						/ 100;
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
