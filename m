Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id A2D916B00A4
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 22:59:43 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id kq14so507844pab.38
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 19:59:43 -0800 (PST)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id m9si916383pab.206.2014.03.04.19.59.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Mar 2014 19:59:42 -0800 (PST)
Received: by mail-pd0-f174.google.com with SMTP id y13so486289pdi.19
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 19:59:42 -0800 (PST)
Date: Tue, 4 Mar 2014 19:59:35 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 09/11] mm, page_alloc: allow system oom handlers to use memory
 reserves
In-Reply-To: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1403041956510.8067@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

The root memcg allows unlimited memory charging, so no memory may be
reserved for userspace oom handlers that are responsible for dealing
with system oom conditions.

Instead, this memory must come from per-zone memory reserves.  This
allows the memory allocation to succeed, and the memcg charge will
naturally succeed afterwards.

This patch introduces per-zone oom watermarks that aren't really
watermarks in the traditional sense.  The oom watermark is the root
memcg's oom reserve proportional to the size of the zone.  When a page
allocation is done, the effective watermark is

	[min/low/high watermark] - [oom watermark]

For the [min watermark] case, this is effectively the oom reserve.
However, it also adjusts the low and high watermark accordingly so
memory is actually only allocated from min reserves when appropriate.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/cgroups/memory.txt |  9 +++++++++
 Documentation/sysctl/vm.txt      |  5 +++++
 arch/m32r/mm/discontig.c         |  1 +
 include/linux/memcontrol.h       | 13 +++++++++++++
 include/linux/mmzone.h           |  2 ++
 mm/memcontrol.c                  | 26 +++++++++++++++++++++++++-
 mm/page_alloc.c                  | 17 ++++++++++++++++-
 7 files changed, 71 insertions(+), 2 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -798,6 +798,15 @@ are waiting on oom notifications to keep this vaue as minimal as
 possible, or allow it to be large enough so that its text can still
 be pagefaulted in under oom conditions when the value is known.
 
+For root processes that are responsible for handling system oom
+conditions, this reserve comes from the per-zone watermarks rather than
+exceeding the limit of the root memcg (since the limit of that memcg is
+always infinity).  Such processes may allocate into per-zone memory
+reserves proportional to the setting of the root memcg's oom reserve.
+If setting an oom reserve for the root memcg to handle system oom
+conditions, it is recommended that min_free_kbytes (see
+Documentation/sysctl/vm.txt) exceeds this value.
+
 11. Memory Pressure
 
 The pressure level notifications can be used to monitor the memory
diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -403,6 +403,11 @@ become subtly broken, and prone to deadlock under high loads.
 
 Setting this too high will OOM your machine instantly.
 
+If root memory controller OOM reserves are configured (see
+Documentation/cgroups/memory.txt), some of this memory may also be
+used for userspace processes that are responsible for handling
+system OOM conditions.
+
 =============================================================
 
 min_slab_ratio:
diff --git a/arch/m32r/mm/discontig.c b/arch/m32r/mm/discontig.c
--- a/arch/m32r/mm/discontig.c
+++ b/arch/m32r/mm/discontig.c
@@ -156,6 +156,7 @@ void __init zone_sizes_init(void)
 	 *  Use all area of internal RAM.
 	 *  see __alloc_pages()
 	 */
+	NODE_DATA(1)->node_zones->watermark[WMARK_OOM] = 0;
 	NODE_DATA(1)->node_zones->watermark[WMARK_MIN] = 0;
 	NODE_DATA(1)->node_zones->watermark[WMARK_LOW] = 0;
 	NODE_DATA(1)->node_zones->watermark[WMARK_HIGH] = 0;
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -156,6 +156,9 @@ static inline bool task_in_memcg_oom(struct task_struct *p)
 
 bool mem_cgroup_oom_synchronize(bool wait);
 
+extern bool mem_cgroup_alloc_use_oom_reserve(void);
+extern u64 mem_cgroup_root_oom_reserve(void);
+
 #ifdef CONFIG_MEMCG_SWAP
 extern int do_swap_account;
 #endif
@@ -397,6 +400,16 @@ static inline bool mem_cgroup_oom_synchronize(bool wait)
 	return false;
 }
 
+static inline bool mem_cgroup_alloc_use_oom_reserve(void)
+{
+	return false;
+}
+
+static inline u64 mem_cgroup_root_oom_reserve(void)
+{
+	return 0;
+}
+
 static inline void mem_cgroup_inc_page_stat(struct page *page,
 					    enum mem_cgroup_stat_index idx)
 {
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -226,12 +226,14 @@ struct lruvec {
 typedef unsigned __bitwise__ isolate_mode_t;
 
 enum zone_watermarks {
+	WMARK_OOM,
 	WMARK_MIN,
 	WMARK_LOW,
 	WMARK_HIGH,
 	NR_WMARK
 };
 
+#define oom_wmark_pages(z) (z->watermark[WMARK_OOM])
 #define min_wmark_pages(z) (z->watermark[WMARK_MIN])
 #define low_wmark_pages(z) (z->watermark[WMARK_LOW])
 #define high_wmark_pages(z) (z->watermark[WMARK_HIGH])
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6026,7 +6026,31 @@ static int mem_cgroup_oom_reserve_write(struct cgroup_subsys_state *css,
 	if (ret)
 		return ret;
 
-	return mem_cgroup_resize_oom_reserve(memcg, val);
+	ret = mem_cgroup_resize_oom_reserve(memcg, val);
+	if (ret)
+		return ret;
+
+	/* Zone oom watermarks need to be reset for root memcg changes */
+	if (memcg == root_mem_cgroup)
+		setup_per_zone_wmarks();
+	return 0;
+}
+
+bool mem_cgroup_alloc_use_oom_reserve(void)
+{
+	bool ret = false;
+
+	rcu_read_lock();
+	if (mem_cgroup_from_task(current) == root_mem_cgroup)
+		ret = true;
+	rcu_read_unlock();
+
+	return ret;
+}
+
+u64 mem_cgroup_root_oom_reserve(void)
+{
+	return root_mem_cgroup->oom_reserve >> PAGE_SHIFT;
 }
 
 #ifdef CONFIG_MEMCG_KMEM
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1722,6 +1722,12 @@ bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
 								free_pages);
 }
 
+static bool use_oom_reserves(void)
+{
+	return (current->flags & PF_OOM_HANDLER) && !in_interrupt() &&
+	       mem_cgroup_alloc_use_oom_reserve();
+}
+
 #ifdef CONFIG_NUMA
 /*
  * zlc_setup - Setup for "zonelist cache".  Uses cached zone data to
@@ -1982,6 +1988,9 @@ zonelist_scan:
 			goto this_zone_full;
 
 		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
+		if (unlikely(use_oom_reserves()))
+			mark -= min_wmark_pages(zone) - oom_wmark_pages(zone);
+
 		if (!zone_watermark_ok(zone, order, mark,
 				       classzone_idx, alloc_flags)) {
 			int ret;
@@ -5595,11 +5604,15 @@ static void __setup_per_zone_wmarks(void)
 	}
 
 	for_each_zone(zone) {
-		u64 tmp;
+		u64 tmp, oom;
 
 		spin_lock_irqsave(&zone->lock, flags);
 		tmp = (u64)pages_min * zone->managed_pages;
 		do_div(tmp, lowmem_pages);
+		oom = mem_cgroup_root_oom_reserve() * zone->managed_pages;
+		do_div(oom, lowmem_pages);
+		if (oom > tmp)
+			oom = tmp;
 		if (is_highmem(zone)) {
 			/*
 			 * __GFP_HIGH and PF_MEMALLOC allocations usually don't
@@ -5615,12 +5628,14 @@ static void __setup_per_zone_wmarks(void)
 			min_pages = zone->managed_pages / 1024;
 			min_pages = clamp(min_pages, SWAP_CLUSTER_MAX, 128UL);
 			zone->watermark[WMARK_MIN] = min_pages;
+			zone->watermark[WMARK_OOM] = min_pages;
 		} else {
 			/*
 			 * If it's a lowmem zone, reserve a number of pages
 			 * proportionate to the zone's size.
 			 */
 			zone->watermark[WMARK_MIN] = tmp;
+			zone->watermark[WMARK_OOM] = oom;
 		}
 
 		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + (tmp >> 2);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
