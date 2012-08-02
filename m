From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [RFC PATCH 18/23 V2] page_alloc: add kernelcore_max_addr
Date: Thu, 2 Aug 2012 10:53:06 +0800
Message-ID: <1343875991-7533-19-git-send-email-laijs@cn.fujitsu.com>
References: <1343875991-7533-1-git-send-email-laijs@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1343875991-7533-1-git-send-email-laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Cc: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>, Dan Magenheimer <dan.magenheimer-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>, Konstantin Khlebnikov <khlebnikov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>, Gavin Shan <shangw-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Petr Holasek <pholasek-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Wanlong Gao <gaowanlong-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, Djalal Harouni <tixxdz-Umm1ozX2/EEdnm+yROfE0A@public.gmane.org>, Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>, Wen Congyang <wency-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, Peter Zijlstra <a.p.zijlstra@ch>
List-Id: linux-mm.kvack.org

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

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
