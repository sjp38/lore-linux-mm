Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id DA0356B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 03:53:27 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id a45so3494863wra.14
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 00:53:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m18si511741edf.244.2017.11.30.00.53.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Nov 2017 00:53:25 -0800 (PST)
Date: Thu, 30 Nov 2017 09:53:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: NUMA stats code cleanup and enhancement
Message-ID: <20171130085322.tyys6xbzzvui7ogz@dhcp22.suse.cz>
References: <1511848824-18709-1-git-send-email-kemi.wang@intel.com>
 <20171129121740.f6drkbktc43l5ib6@dhcp22.suse.cz>
 <4b840074-cb5f-3c10-d65b-916bc02fb1ee@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4b840074-cb5f-3c10-d65b-916bc02fb1ee@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kemi <kemi.wang@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu 30-11-17 13:56:13, kemi wrote:
> 
> 
> On 2017a1'11ae??29ae?JPY 20:17, Michal Hocko wrote:
> > On Tue 28-11-17 14:00:23, Kemi Wang wrote:
> >> The existed implementation of NUMA counters is per logical CPU along with
> >> zone->vm_numa_stat[] separated by zone, plus a global numa counter array
> >> vm_numa_stat[]. However, unlike the other vmstat counters, numa stats don't
> >> effect system's decision and are only read from /proc and /sys, it is a
> >> slow path operation and likely tolerate higher overhead. Additionally,
> >> usually nodes only have a single zone, except for node 0. And there isn't
> >> really any use where you need these hits counts separated by zone.
> >>
> >> Therefore, we can migrate the implementation of numa stats from per-zone to
> >> per-node, and get rid of these global numa counters. It's good enough to
> >> keep everything in a per cpu ptr of type u64, and sum them up when need, as
> >> suggested by Andi Kleen. That's helpful for code cleanup and enhancement
> >> (e.g. save more than 130+ lines code).
> > 
> > I agree. Having these stats per zone is a bit of overcomplication. The
> > only consumer is /proc/zoneinfo and I would argue this doesn't justify
> > the additional complexity. Who does really need to know per zone broken
> > out numbers?
> > 
> > Anyway, I haven't checked your implementation too deeply but why don't
> > you simply define static percpu array for each numa node?
> 
> To be honest, there are another two ways I can think of listed below. but I don't
> think they are simpler than my current implementation. Maybe you have better idea.
> 
> static u64 __percpu vm_stat_numa[num_possible_nodes() * NR_VM_NUMA_STAT_ITEMS];
> But it's not correct.
> 
> Or we can add an u64 percpu array with size of NR_VM_NUMA_STAT_ITEMS in struct pglist_data.
> 
> My current implementation is quite straightforward by combining all of local counters
> together, only one percpu array with size of num_possible_nodes()*NR_VM_NUMA_STAT_ITEMS 
> is enough for that.

Well, this is certainly a matter of taste. But let's have a look what we
have currently. We have per zone, per node and numa stats. That looks one
way to many to me. Why don't we simply move the whole numa stat thingy
into per node stats? The code would simplify even more. We are going to
lose /proc/zoneinfo per-zone data but we are losing those without your
patch anyway. So I've just scratched the following on your patch and the
cumulative diff looks even better

 drivers/base/node.c    |  22 ++---
 include/linux/mmzone.h |  22 ++---
 include/linux/vmstat.h |  38 +--------
 mm/mempolicy.c         |   2 +-
 mm/page_alloc.c        |  20 ++---
 mm/vmstat.c            | 221 +------------------------------------------------
 6 files changed, 30 insertions(+), 295 deletions(-)

I haven't tested it at all yet. This is just to show the idea.
---
commit 92f8f58d1b6cb5c54a5a197a42e02126a5f7ea1a
Author: Michal Hocko <mhocko@suse.com>
Date:   Thu Nov 30 09:49:45 2017 +0100

    - move NUMA stats to node stats

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 0be5fbdadaac..315156310c99 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -190,17 +190,9 @@ static ssize_t node_read_vmstat(struct device *dev,
 		n += sprintf(buf+n, "%s %lu\n", vmstat_text[i],
 			     sum_zone_node_page_state(nid, i));
 
-#ifdef CONFIG_NUMA
-	for (i = 0; i < NR_VM_NUMA_STAT_ITEMS; i++)
-		n += sprintf(buf+n, "%s %lu\n",
-			     vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
-			     node_numa_state_snapshot(nid, i));
-#endif
-
 	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
 		n += sprintf(buf+n, "%s %lu\n",
-			     vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
-			     NR_VM_NUMA_STAT_ITEMS],
+			     vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
 			     node_page_state(pgdat, i));
 
 	return n;
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index b2d264f8c0c6..2c9c8b13c44b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -115,20 +115,6 @@ struct zone_padding {
 #define ZONE_PADDING(name)
 #endif
 
-#ifdef CONFIG_NUMA
-enum numa_stat_item {
-	NUMA_HIT,		/* allocated in intended node */
-	NUMA_MISS,		/* allocated in non intended node */
-	NUMA_FOREIGN,		/* was intended here, hit elsewhere */
-	NUMA_INTERLEAVE_HIT,	/* interleaver preferred this zone */
-	NUMA_LOCAL,		/* allocation from local node */
-	NUMA_OTHER,		/* allocation from other node */
-	NR_VM_NUMA_STAT_ITEMS
-};
-#else
-#define NR_VM_NUMA_STAT_ITEMS 0
-#endif
-
 enum zone_stat_item {
 	/* First 128 byte cacheline (assuming 64 bit words) */
 	NR_FREE_PAGES,
@@ -180,6 +166,12 @@ enum node_stat_item {
 	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
 	NR_DIRTIED,		/* page dirtyings since bootup */
 	NR_WRITTEN,		/* page writings since bootup */
+	NUMA_HIT,		/* allocated in intended node */
+	NUMA_MISS,		/* allocated in non intended node */
+	NUMA_FOREIGN,		/* was intended here, hit elsewhere */
+	NUMA_INTERLEAVE_HIT,	/* interleaver preferred this zone */
+	NUMA_LOCAL,		/* allocation from local node */
+	NUMA_OTHER,		/* allocation from other node */
 	NR_VM_NODE_STAT_ITEMS
 };
 
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index c07850f413de..cc1edd95e949 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -187,19 +187,15 @@ static inline unsigned long zone_page_state_snapshot(struct zone *zone,
 #endif
 	return x;
 }
-
 #ifdef CONFIG_NUMA
-extern void __inc_numa_state(struct zone *zone, enum numa_stat_item item);
+extern unsigned long node_page_state(struct pglist_data *pgdat,
+                                               enum node_stat_item item);
 extern unsigned long sum_zone_node_page_state(int node,
 					      enum zone_stat_item item);
-extern unsigned long sum_zone_numa_state(int node, enum numa_stat_item item);
-extern unsigned long node_page_state(struct pglist_data *pgdat,
-						enum node_stat_item item);
 #else
 #define sum_zone_node_page_state(node, item) global_zone_page_state(item)
 #define node_page_state(node, item) global_node_page_state(item)
 #endif /* CONFIG_NUMA */
-
 #define add_zone_page_state(__z, __i, __d) mod_zone_page_state(__z, __i, __d)
 #define sub_zone_page_state(__z, __i, __d) mod_zone_page_state(__z, __i, -(__d))
 #define add_node_page_state(__p, __i, __d) mod_node_page_state(__p, __i, __d)
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index f604b22ebb65..84e72f2b5748 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1939,7 +1939,7 @@ static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
 		return page;
 	if (page && page_to_nid(page) == nid) {
 		preempt_disable();
-		__inc_numa_state(page_zone(page), NUMA_INTERLEAVE_HIT);
+		inc_node_page_state(page, NUMA_INTERLEAVE_HIT);
 		preempt_enable();
 	}
 	return page;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 044daba8c11a..c8e34157f7b8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2785,25 +2785,25 @@ int __isolate_free_page(struct page *page, unsigned int order)
  *
  * Must be called with interrupts disabled.
  */
-static inline void zone_statistics(struct zone *preferred_zone, struct zone *z)
+static inline void zone_statistics(int preferred_nid, int page_nid)
 {
 #ifdef CONFIG_NUMA
-	enum numa_stat_item local_stat = NUMA_LOCAL;
+	enum node_stat_item local_stat = NUMA_LOCAL;
 
 	/* skip numa counters update if numa stats is disabled */
 	if (!static_branch_likely(&vm_numa_stat_key))
 		return;
 
-	if (z->node != numa_node_id())
+	if (page_nid != numa_node_id())
 		local_stat = NUMA_OTHER;
 
-	if (z->node == preferred_zone->node)
-		__inc_numa_state(z, NUMA_HIT);
+	if (page_nid == preferred_nid)
+		inc_node_state(NODE_DATA(page_nid), NUMA_HIT);
 	else {
-		__inc_numa_state(z, NUMA_MISS);
-		__inc_numa_state(preferred_zone, NUMA_FOREIGN);
+		inc_node_state(NODE_DATA(page_nid), NUMA_MISS);
+		inc_node_state(NODE_DATA(preferred_nid), NUMA_FOREIGN);
 	}
-	__inc_numa_state(z, local_stat);
+	inc_node_state(NODE_DATA(page_nid), local_stat);
 #endif
 }
 
@@ -2847,7 +2847,7 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
 	page = __rmqueue_pcplist(zone,  migratetype, pcp, list);
 	if (page) {
 		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
-		zone_statistics(preferred_zone, zone);
+		zone_statistics(preferred_zone->node, zone->node);
 	}
 	local_irq_restore(flags);
 	return page;
@@ -2895,7 +2895,7 @@ struct page *rmqueue(struct zone *preferred_zone,
 				  get_pcppage_migratetype(page));
 
 	__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
-	zone_statistics(preferred_zone, zone);
+	zone_statistics(preferred_zone->node, zone->node);
 	local_irq_restore(flags);
 
 out:
@@ -5580,7 +5580,6 @@ void __init setup_per_cpu_pageset(void)
 {
 	struct pglist_data *pgdat;
 	struct zone *zone;
-	size_t size, align;
 
 	for_each_populated_zone(zone)
 		setup_zone_pageset(zone);
@@ -5588,12 +5587,6 @@ void __init setup_per_cpu_pageset(void)
 	for_each_online_pgdat(pgdat)
 		pgdat->per_cpu_nodestats =
 			alloc_percpu(struct per_cpu_nodestat);
-
-#ifdef CONFIG_NUMA
-	size = sizeof(u64) * num_possible_nodes() * NR_VM_NUMA_STAT_ITEMS;
-	align = __alignof__(u64[num_possible_nodes() * NR_VM_NUMA_STAT_ITEMS]);
-	vm_numa_stat = (u64 __percpu *)__alloc_percpu(size, align);
-#endif
 }
 
 static __meminit void zone_pcp_init(struct zone *zone)
diff --git a/mm/vmstat.c b/mm/vmstat.c
index bbabd96d1a4b..c9739104589f 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -33,17 +33,6 @@
 #ifdef CONFIG_NUMA
 int sysctl_vm_numa_stat = ENABLE_NUMA_STAT;
 
-static void invalid_numa_statistics(void)
-{
-	int i, cpu;
-
-	for_each_possible_cpu(cpu) {
-		for (i = 0; i < num_possible_nodes() *
-				NR_VM_NUMA_STAT_ITEMS; i++)
-			per_cpu_ptr(vm_numa_stat, cpu)[i] = 0;
-	}
-}
-
 static DEFINE_MUTEX(vm_numa_stat_lock);
 
 int sysctl_vm_numa_stat_handler(struct ctl_table *table, int write,
@@ -65,7 +54,6 @@ int sysctl_vm_numa_stat_handler(struct ctl_table *table, int write,
 		pr_info("enable numa statistics\n");
 	} else {
 		static_branch_disable(&vm_numa_stat_key);
-		invalid_numa_statistics();
 		pr_info("disable numa statistics, and clear numa counters\n");
 	}
 
@@ -829,49 +817,6 @@ void drain_zonestat(struct zone *zone, struct per_cpu_pageset *pset)
 }
 #endif
 
-#ifdef CONFIG_NUMA
-void __inc_numa_state(struct zone *zone,
-				 enum numa_stat_item item)
-{
-	int offset = zone->node * NR_VM_NUMA_STAT_ITEMS + item;
-	u64 __percpu *p = vm_numa_stat + offset;
-
-	__this_cpu_inc(*p);
-}
-
-/*
- * Determine the per node value of a stat item. This function
- * is called frequently in a NUMA machine, so try to be as
- * frugal as possible.
- */
-unsigned long sum_zone_node_page_state(int node,
-				 enum zone_stat_item item)
-{
-	struct zone *zones = NODE_DATA(node)->node_zones;
-	int i;
-	unsigned long count = 0;
-
-	for (i = 0; i < MAX_NR_ZONES; i++)
-		count += zone_page_state(zones + i, item);
-
-	return count;
-}
-
-/*
- * Determine the per node value of a stat item.
- */
-unsigned long node_page_state(struct pglist_data *pgdat,
-				enum node_stat_item item)
-{
-	long x = atomic_long_read(&pgdat->vm_stat[item]);
-#ifdef CONFIG_SMP
-	if (x < 0)
-		x = 0;
-#endif
-	return x;
-}
-#endif
-
 #ifdef CONFIG_COMPACTION
 
 struct contig_page_info {
@@ -1441,8 +1386,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		seq_printf(m, "\n  per-node stats");
 		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++) {
 			seq_printf(m, "\n      %-12s %lu",
-				vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
-				NR_VM_NUMA_STAT_ITEMS],
+				vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
 				node_page_state(pgdat, i));
 		}
 	}
@@ -1479,13 +1423,6 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		seq_printf(m, "\n      %-12s %lu", vmstat_text[i],
 				zone_page_state(zone, i));
 
-#ifdef CONFIG_NUMA
-	for (i = 0; i < NR_VM_NUMA_STAT_ITEMS; i++)
-		seq_printf(m, "\n      %-12s %lu",
-				vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
-				zone_numa_state_snapshot(zone, i));
-#endif
-
 	seq_printf(m, "\n  pagesets");
 	for_each_online_cpu(i) {
 		struct per_cpu_pageset *pageset;
@@ -1560,7 +1497,6 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 	if (*pos >= ARRAY_SIZE(vmstat_text))
 		return NULL;
 	stat_items_size = NR_VM_ZONE_STAT_ITEMS * sizeof(unsigned long) +
-			  NR_VM_NUMA_STAT_ITEMS * sizeof(unsigned long) +
 			  NR_VM_NODE_STAT_ITEMS * sizeof(unsigned long) +
 			  NR_VM_WRITEBACK_STAT_ITEMS * sizeof(unsigned long);
 
@@ -1576,12 +1512,6 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 		v[i] = global_zone_page_state(i);
 	v += NR_VM_ZONE_STAT_ITEMS;
 
-#ifdef CONFIG_NUMA
-	for (i = 0; i < NR_VM_NUMA_STAT_ITEMS; i++)
-		v[i] = global_numa_state(i);
-	v += NR_VM_NUMA_STAT_ITEMS;
-#endif
-
 	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
 		v[i] = global_node_page_state(i);
 	v += NR_VM_NODE_STAT_ITEMS;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
