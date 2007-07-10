Date: Tue, 10 Jul 2007 14:21:54 +0100
Subject: Re: zone movable patches comments
Message-ID: <20070710132154.GA9426@skynet.ie>
References: <4691E8D1.4030507@yahoo.com.au> <20070709110457.GB9305@skynet.ie> <469226CB.4010900@yahoo.com.au> <20070709132140.GC9305@skynet.ie> <46933BD7.2020200@yahoo.com.au> <20070710095116.GB12052@skynet.ie> <46935C84.9060407@yahoo.com.au> <46935CEB.3050204@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <46935CEB.3050204@yahoo.com.au>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On (10/07/07 20:18), Nick Piggin didst pronounce:
> Nick Piggin wrote:
> 
> >I'm not completely against kernelcore=, no. However I do think that
> >should be a general parameter that exists for the core kernel. I guess it
> >would override any other reservations and things, and it would specify the
> >absolute minimum kernelcore.
> >
> >Then if you add a movable_mem= (or something -- I don't know what the
> >exact name should be), then that would also specify the minimum movable
> >memory, although at a lower priority to kernelcore= (and you could have
> >the appropriate warnings and such if they cannot be satisfied).
> 
> Ah yes, I now read Andy's mail and this is what he is suggesting, so
> yes it seems like a good idea I think.
> 

*beats keyboard with stick* 

Does something like the following cover it? Tested on a standalone x86
and it seemed to behave as expected.

=====

This patch adds a new parameter for sizing ZONE_MOVABLE called
movablecore=. kernelcore is used to specify the minimum amount of memory that
must be available for all allocation types. movablecore= is used to specify
the minimum amount of memory that is used for migratable allocations. The
amount of memory used for migratable allocations determines how large the
huge page pool could be dynamically resized to at runtime for example.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 Documentation/kernel-parameters.txt |   10 +++++
 mm/page_alloc.c                     |   61 +++++++++++++++++++++++++++++++-----
 2 files changed, 64 insertions(+), 7 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-zonemovable/Documentation/kernel-parameters.txt linux-2.6.22-movablecore/Documentation/kernel-parameters.txt
--- linux-2.6.22-zonemovable/Documentation/kernel-parameters.txt	2007-07-09 11:50:18.000000000 +0100
+++ linux-2.6.22-movablecore/Documentation/kernel-parameters.txt	2007-07-10 11:38:04.000000000 +0100
@@ -850,6 +850,16 @@ and is between 256 and 4096 characters. 
 			use the HighMem zone if it exists, and the Normal
 			zone if it does not.
 
+	movablecore=nn[KMG]	[KNL,IA-32,IA-64,PPC,X86-64] This parameter
+			is similar to kernelcore except it specifies the
+			amount of memory used for migratable allocations.
+			If both kernelcore and movablecore is specified,
+			then kernelcore will be at *least* the specified
+			value but may be more. If movablecore on its own
+			is specified, the administrator must be careful
+			that the amount of memory usable for all allocations
+			is not too small.
+
 	keepinitrd	[HW,ARM]
 
 	kstack=N	[IA-32,X86-64] Print N words from the kernel stack
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-zonemovable/mm/page_alloc.c linux-2.6.22-movablecore/mm/page_alloc.c
--- linux-2.6.22-zonemovable/mm/page_alloc.c	2007-07-09 11:50:18.000000000 +0100
+++ linux-2.6.22-movablecore/mm/page_alloc.c	2007-07-10 12:31:39.000000000 +0100
@@ -137,6 +137,7 @@ static unsigned long __meminitdata dma_r
   unsigned long __initdata node_boundary_end_pfn[MAX_NUMNODES];
 #endif /* CONFIG_MEMORY_HOTPLUG_RESERVE */
   unsigned long __initdata required_kernelcore;
+  unsigned long __initdata required_movablecore;
   unsigned long __initdata zone_movable_pfn[MAX_NUMNODES];
 
   /* movable_zone is the "real" zone pages in ZONE_MOVABLE are taken from */
@@ -2980,6 +2981,18 @@ unsigned long __init find_max_pfn_with_a
 	return max_pfn;
 }
 
+unsigned long __init early_calculate_totalpages(void)
+{
+	int i;
+	unsigned long totalpages = 0;
+
+	for (i = 0; i < nr_nodemap_entries; i++)
+		totalpages += early_node_map[i].end_pfn -
+						early_node_map[i].start_pfn;
+
+	return totalpages;
+}
+
 /*
  * Find the PFN the Movable zone begins in each node. Kernel memory
  * is spread evenly between nodes as long as the nodes have enough
@@ -2993,6 +3006,25 @@ void __init find_zone_movable_pfns_for_n
 	unsigned long kernelcore_node, kernelcore_remaining;
 	int usable_nodes = num_online_nodes();
 
+	/*
+	 * If movablecore was specified, calculate what size of
+	 * kernelcore that corresponds so that memory usable for
+	 * any allocation type is evenly spread. If both kernelcore
+	 * and movablecore are specified, then the value of kernelcore
+	 * will be used for required_kernelcore if it's greater than
+	 * what movablecore would have allowed.
+	 */
+	if (required_movablecore) {
+		unsigned long totalpages = early_calculate_totalpages();
+		unsigned long corepages;
+		
+		required_movablecore =
+			roundup(required_movablecore, MAX_ORDER_NR_PAGES);
+		corepages = totalpages - required_movablecore;
+
+		required_kernelcore = max(required_kernelcore, corepages);
+	}
+		
 	/* If kernelcore was not specified, there is no ZONE_MOVABLE */
 	if (!required_kernelcore)
 		return;
@@ -3173,26 +3205,41 @@ void __init free_area_init_nodes(unsigne
 	}
 }
 
-/*
- * kernelcore=size sets the amount of memory for use for allocations that
- * cannot be reclaimed or migrated.
- */
-static int __init cmdline_parse_kernelcore(char *p)
+static int __init cmdline_parse_core(char *p, unsigned long *core)
 {
 	unsigned long long coremem;
 	if (!p)
 		return -EINVAL;
 
 	coremem = memparse(p, &p);
-	required_kernelcore = coremem >> PAGE_SHIFT;
+	*core = coremem >> PAGE_SHIFT;
 
-	/* Paranoid check that UL is enough for required_kernelcore */
+	/* Paranoid check that UL is enough for the coremem value */
 	WARN_ON((coremem >> PAGE_SHIFT) > ULONG_MAX);
 
 	return 0;
 }
 
+/*
+ * kernelcore=size sets the amount of memory for use for allocations that
+ * cannot be reclaimed or migrated.
+ */
+static int __init cmdline_parse_kernelcore(char *p)
+{
+	return cmdline_parse_core(p, &required_kernelcore);
+}
+
+/*
+ * movablecore=size sets the amount of memory for use for allocations that
+ * can be reclaimed or migrated.
+ */
+static int __init cmdline_parse_movablecore(char *p)
+{
+	return cmdline_parse_core(p, &required_movablecore);
+}
+
 early_param("kernelcore", cmdline_parse_kernelcore);
+early_param("movablecore", cmdline_parse_movablecore);
 
 #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
