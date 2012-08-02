Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id E577F6B0075
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 02:01:23 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [RFC PATCH 18/23 V2] page_alloc: add kernelcore_max_addr
Date: Thu, 2 Aug 2012 14:01:23 +0800
Message-Id: <1343887288-8866-19-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1343887288-8866-1-git-send-email-laijs@cn.fujitsu.com>
References: <1343887288-8866-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org

Current ZONE_MOVABLE (kernelcore=) setting policy with boot option doesn't meet
our requirement. We need something like kernelcore_max_addr=XX boot option
to limit the kernelcore upper address.

The memory with higher address will be migratable(movable) and they
are easier to be offline(always ready to be offline when the system don't require
so much memory).

It makes things easy when we dynamic hot-add/remove memory, make better
utilities of memories, and helps for THP.

All kernelcore_max_addr=, kernelcore= and movablecore= can be safely specified
at the same time(or any 2 of them).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 Documentation/kernel-parameters.txt |    9 +++++++++
 mm/page_alloc.c                     |   29 ++++++++++++++++++++++++++++-
 2 files changed, 37 insertions(+), 1 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 12783fa..48dff61 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1216,6 +1216,15 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			use the HighMem zone if it exists, and the Normal
 			zone if it does not.
 
+	kernelcore_max_addr=nn[KMG]	[KNL,X86,IA-64,PPC] This parameter
+			is the same effect as kernelcore parameter, except it
+			specifies the up physical address of memory range
+			usable by the kernel for non-movable allocations.
+			If both kernelcore and kernelcore_max_addr are
+			specified, this requested's priority is higher than
+			kernelcore's.
+			See the kernelcore parameter.
+
 	kgdbdbgp=	[KGDB,HW] kgdb over EHCI usb debug port.
 			Format: <Controller#>[,poll interval]
 			The controller # is the number of the ehci usb debug
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 03ad63d..65ac5c9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -204,6 +204,7 @@ static unsigned long __meminitdata dma_reserve;
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 static unsigned long __meminitdata arch_zone_lowest_possible_pfn[MAX_NR_ZONES];
 static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
+static unsigned long __initdata required_kernelcore_max_pfn;
 static unsigned long __initdata required_kernelcore;
 static unsigned long __initdata required_movablecore;
 static unsigned long __meminitdata zone_movable_pfn[MAX_NUMNODES];
@@ -4600,6 +4601,7 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 {
 	int i, nid;
 	unsigned long usable_startpfn;
+	unsigned long kernelcore_max_pfn;
 	unsigned long kernelcore_node, kernelcore_remaining;
 	/* save the state before borrow the nodemask */
 	nodemask_t saved_node_state = node_states[N_MEMORY];
@@ -4628,6 +4630,9 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 		required_kernelcore = max(required_kernelcore, corepages);
 	}
 
+	if (required_kernelcore_max_pfn && !required_kernelcore)
+		required_kernelcore = totalpages;
+
 	/* If kernelcore was not specified, there is no ZONE_MOVABLE */
 	if (!required_kernelcore)
 		goto out;
@@ -4636,6 +4641,12 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 	find_usable_zone_for_movable();
 	usable_startpfn = arch_zone_lowest_possible_pfn[movable_zone];
 
+	if (required_kernelcore_max_pfn)
+		kernelcore_max_pfn = required_kernelcore_max_pfn;
+	else
+		kernelcore_max_pfn = ULONG_MAX >> PAGE_SHIFT;
+	kernelcore_max_pfn = max(kernelcore_max_pfn, usable_startpfn);
+
 restart:
 	/* Spread kernelcore memory as evenly as possible throughout nodes */
 	kernelcore_node = required_kernelcore / usable_nodes;
@@ -4662,8 +4673,12 @@ restart:
 			unsigned long size_pages;
 
 			start_pfn = max(start_pfn, zone_movable_pfn[nid]);
-			if (start_pfn >= end_pfn)
+			end_pfn = min(kernelcore_max_pfn, end_pfn);
+			if (start_pfn >= end_pfn) {
+				if (!zone_movable_pfn[nid])
+					zone_movable_pfn[nid] = start_pfn;
 				continue;
+			}
 
 			/* Account for what is only usable for kernelcore */
 			if (start_pfn < usable_startpfn) {
@@ -4854,6 +4869,18 @@ static int __init cmdline_parse_core(char *p, unsigned long *core)
 	return 0;
 }
 
+#ifdef CONFIG_MOVABLE_NODE
+/*
+ * kernelcore_max_addr=addr sets the up physical address of memory range
+ * for use for allocations that cannot be reclaimed or migrated.
+ */
+static int __init cmdline_parse_kernelcore_max_addr(char *p)
+{
+	return cmdline_parse_core(p, &required_kernelcore_max_pfn);
+}
+early_param("kernelcore_max_addr", cmdline_parse_kernelcore_max_addr);
+#endif
+
 /*
  * kernelcore=size sets the amount of memory for use for allocations that
  * cannot be reclaimed or migrated.
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
