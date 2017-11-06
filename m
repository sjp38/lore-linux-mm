Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A402D4403DD
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 04:22:38 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id r18so12179261pgu.9
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 01:22:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e10sor3061720pgo.244.2017.11.06.01.22.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 01:22:37 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, sparse: do not swamp log with huge vmemmap allocation failures
Date: Mon,  6 Nov 2017 10:22:28 +0100
Message-Id: <20171106092228.31098-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

While doing a memory hotplug tests under a heavy memory pressure we have
noticed too many page allocation failures when allocating vmemmap memmap
backed by huge page
[146792.281354] kworker/u3072:1: page allocation failure: order:9, mode:0x24084c0(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO)
[...]
[146792.281394] Call Trace:
[146792.281430]  [<ffffffff81019a99>] dump_trace+0x59/0x310
[146792.281436]  [<ffffffff81019e3a>] show_stack_log_lvl+0xea/0x170
[146792.281440]  [<ffffffff8101abc1>] show_stack+0x21/0x40
[146792.281448]  [<ffffffff8130f040>] dump_stack+0x5c/0x7c
[146792.281464]  [<ffffffff8118c982>] warn_alloc_failed+0xe2/0x150
[146792.281471]  [<ffffffff8118cddd>] __alloc_pages_nodemask+0x3ed/0xb20
[146792.281489]  [<ffffffff811d3aaf>] alloc_pages_current+0x7f/0x100
[146792.281503]  [<ffffffff815dfa2c>] vmemmap_alloc_block+0x79/0xb6
[146792.281510]  [<ffffffff815dfbd3>] __vmemmap_alloc_block_buf+0x136/0x145
[146792.281524]  [<ffffffff815dd0c5>] vmemmap_populate+0xd2/0x2b9
[146792.281529]  [<ffffffff815dffd9>] sparse_mem_map_populate+0x23/0x30
[146792.281532]  [<ffffffff815df88d>] sparse_add_one_section+0x68/0x18e
[146792.281537]  [<ffffffff815d9f5a>] __add_pages+0x10a/0x1d0
[146792.281553]  [<ffffffff8106249a>] arch_add_memory+0x4a/0xc0
[146792.281559]  [<ffffffff815da1f9>] add_memory_resource+0x89/0x160
[146792.281564]  [<ffffffff815da33d>] add_memory+0x6d/0xd0
[146792.281585]  [<ffffffff813d36c4>] acpi_memory_device_add+0x181/0x251
[146792.281597]  [<ffffffff813946e5>] acpi_bus_attach+0xfd/0x19b
[146792.281602]  [<ffffffff81394866>] acpi_bus_scan+0x59/0x69
[146792.281604]  [<ffffffff813949de>] acpi_device_hotplug+0xd2/0x41f
[146792.281608]  [<ffffffff8138db67>] acpi_hotplug_work_fn+0x1a/0x23
[146792.281623]  [<ffffffff81093cee>] process_one_work+0x14e/0x410
[146792.281630]  [<ffffffff81094546>] worker_thread+0x116/0x490
[146792.281637]  [<ffffffff810999ed>] kthread+0xbd/0xe0
[146792.281651]  [<ffffffff815e4e7f>] ret_from_fork+0x3f/0x70

and we do see many of those because essentially every the allocation
failes for each memory section. This is overly excessive way to tell
user that there is nothing to really worry about because we do have
a fallback mechanism to use base pages. The only downside might be a
performance degradation due to TLB pressure.

This patch changes vmemmap_alloc_block to use __GFP_NOWARN and warn
explicitly once on the first allocation failure. This will reduce the
noise in the kernel log considerably, while we still have an indication
that a performance might be impacted.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi,
this has somehow fell of my radar completely. The patch is essentially
what Johannes suggested [1] so I have added his s-o-b and added the
changelog into it.

Can we have this merged?

[1] http://lkml.kernel.org/r/20170711214541.GA11141@cmpxchg.org

 arch/x86/mm/init_64.c |  1 -
 mm/sparse-vmemmap.c   | 11 +++++++++--
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 126e09625979..5eb954f930be 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1405,7 +1405,6 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 			vmemmap_verify((pte_t *)pmd, node, addr, next);
 			continue;
 		}
-		pr_warn_once("vmemmap: falling back to regular page backing\n");
 		if (vmemmap_populate_basepages(addr, next, node))
 			return -ENOMEM;
 	}
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index d0860aab1c89..3f85084cb8bb 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -52,12 +52,19 @@ void * __meminit vmemmap_alloc_block(unsigned long size, int node)
 {
 	/* If the main allocator is up use that, fallback to bootmem. */
 	if (slab_is_available()) {
+		gfp_t gfp_mask = GFP_KERNEL | __GFP_RETRY_MAYFAIL | __GFP_NOWARN;
+		int order = get_order(size);
+		static bool warned;
 		struct page *page;
 
-		page = alloc_pages_node(node, GFP_KERNEL | __GFP_RETRY_MAYFAIL,
-					get_order(size));
+		page = alloc_pages_node(node, gfp_mask, order);
 		if (page)
 			return page_address(page);
+
+		if (!warned) {
+			warn_alloc(gfp_mask, NULL, "vmemmap alloc failure: order:%u", order);
+			warned = true;
+		}
 		return NULL;
 	} else
 		return __earlyonly_bootmem_alloc(node, size, size,
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
