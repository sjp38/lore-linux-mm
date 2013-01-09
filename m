Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 10CE46B0062
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 04:33:32 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v6 07/15] memory-hotplug: move pgdat_resize_lock into sparse_remove_one_section()
Date: Wed, 9 Jan 2013 17:32:31 +0800
Message-Id: <1357723959-5416-8-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

In __remove_section(), we locked pgdat_resize_lock when calling
sparse_remove_one_section(). This lock will disable irq. But we don't need
to lock the whole function. If we do some work to free pagetables in
free_section_usemap(), we need to call flush_tlb_all(), which need
irq enabled. Otherwise the WARN_ON_ONCE() in smp_call_function_many()
will be triggered.

If we lock the whole sparse_remove_one_section(), then we come to this call trace:

[  454.796248] ------------[ cut here ]------------
[  454.851408] WARNING: at kernel/smp.c:461 smp_call_function_many+0xbd/0x260()
[  454.935620] Hardware name: PRIMEQUEST 1800E
......
[  455.652201] Call Trace:
[  455.681391]  [<ffffffff8106e73f>] warn_slowpath_common+0x7f/0xc0
[  455.753151]  [<ffffffff810560a0>] ? leave_mm+0x50/0x50
[  455.814527]  [<ffffffff8106e79a>] warn_slowpath_null+0x1a/0x20
[  455.884208]  [<ffffffff810e7a9d>] smp_call_function_many+0xbd/0x260
[  455.959082]  [<ffffffff810e7ecb>] smp_call_function+0x3b/0x50
[  456.027722]  [<ffffffff810560a0>] ? leave_mm+0x50/0x50
[  456.089098]  [<ffffffff810e7f4b>] on_each_cpu+0x3b/0xc0
[  456.151512]  [<ffffffff81055f0c>] flush_tlb_all+0x1c/0x20
[  456.216004]  [<ffffffff8104f8de>] remove_pagetable+0x14e/0x1d0
[  456.285683]  [<ffffffff8104f978>] vmemmap_free+0x18/0x20
[  456.349139]  [<ffffffff811b8797>] sparse_remove_one_section+0xf7/0x100
[  456.427126]  [<ffffffff811c5fc2>] __remove_section+0xa2/0xb0
[  456.494726]  [<ffffffff811c6070>] __remove_pages+0xa0/0xd0
[  456.560258]  [<ffffffff81669c7b>] arch_remove_memory+0x6b/0xc0
[  456.629937]  [<ffffffff8166ad28>] remove_memory+0xb8/0xf0
[  456.694431]  [<ffffffff813e686f>] acpi_memory_device_remove+0x53/0x96
[  456.771379]  [<ffffffff813b33c4>] acpi_device_remove+0x90/0xb2
[  456.841059]  [<ffffffff8144b02c>] __device_release_driver+0x7c/0xf0
[  456.915928]  [<ffffffff8144b1af>] device_release_driver+0x2f/0x50
[  456.988719]  [<ffffffff813b4476>] acpi_bus_remove+0x32/0x6d
[  457.055285]  [<ffffffff813b4542>] acpi_bus_trim+0x91/0x102
[  457.120814]  [<ffffffff813b463b>] acpi_bus_hot_remove_device+0x88/0x16b
[  457.199840]  [<ffffffff813afda7>] acpi_os_execute_deferred+0x27/0x34
[  457.275756]  [<ffffffff81091ece>] process_one_work+0x20e/0x5c0
[  457.345434]  [<ffffffff81091e5f>] ? process_one_work+0x19f/0x5c0
[  457.417190]  [<ffffffff813afd80>] ? acpi_os_wait_events_complete+0x23/0x23
[  457.499332]  [<ffffffff81093f6e>] worker_thread+0x12e/0x370
[  457.565896]  [<ffffffff81093e40>] ? manage_workers+0x180/0x180
[  457.635574]  [<ffffffff8109a09e>] kthread+0xee/0x100
[  457.694871]  [<ffffffff810dfaf9>] ? __lock_release+0x129/0x190
[  457.764552]  [<ffffffff81099fb0>] ? __init_kthread_worker+0x70/0x70
[  457.839427]  [<ffffffff81690aac>] ret_from_fork+0x7c/0xb0
[  457.903914]  [<ffffffff81099fb0>] ? __init_kthread_worker+0x70/0x70
[  457.978784] ---[ end trace 25e85300f542aa01 ]---

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memory_hotplug.c |    4 ----
 mm/sparse.c         |    5 ++++-
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 0682d2a..674e791 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -442,8 +442,6 @@ static int __remove_section(struct zone *zone, struct mem_section *ms)
 #else
 static int __remove_section(struct zone *zone, struct mem_section *ms)
 {
-	unsigned long flags;
-	struct pglist_data *pgdat = zone->zone_pgdat;
 	int ret = -EINVAL;
 
 	if (!valid_section(ms))
@@ -453,9 +451,7 @@ static int __remove_section(struct zone *zone, struct mem_section *ms)
 	if (ret)
 		return ret;
 
-	pgdat_resize_lock(pgdat, &flags);
 	sparse_remove_one_section(zone, ms);
-	pgdat_resize_unlock(pgdat, &flags);
 	return 0;
 }
 #endif
diff --git a/mm/sparse.c b/mm/sparse.c
index aadbb2a..05ca73a 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -796,8 +796,10 @@ static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
 void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
 {
 	struct page *memmap = NULL;
-	unsigned long *usemap = NULL;
+	unsigned long *usemap = NULL, flags;
+	struct pglist_data *pgdat = zone->zone_pgdat;
 
+	pgdat_resize_lock(pgdat, &flags);
 	if (ms->section_mem_map) {
 		usemap = ms->pageblock_flags;
 		memmap = sparse_decode_mem_map(ms->section_mem_map,
@@ -805,6 +807,7 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
 		ms->section_mem_map = 0;
 		ms->pageblock_flags = NULL;
 	}
+	pgdat_resize_unlock(pgdat, &flags);
 
 	clear_hwpoisoned_pages(memmap, PAGES_PER_SECTION);
 	free_section_usemap(memmap, usemap);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
