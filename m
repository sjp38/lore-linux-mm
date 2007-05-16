Date: Tue, 15 May 2007 22:31:04 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: slabinfo fixes
Message-ID: <Pine.LNX.4.64.0705152230360.5528@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Align the output of % with K/M/G of sizes.

Check for empty NUMA information to avoid segfault on !NUMA.

-r should work directly not only if we match a single slab
   without additional options.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 Documentation/vm/slabinfo.c |   17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

Index: slub/Documentation/vm/slabinfo.c
===================================================================
--- slub.orig/Documentation/vm/slabinfo.c	2007-05-15 21:32:49.000000000 -0700
+++ slub/Documentation/vm/slabinfo.c	2007-05-15 22:27:43.000000000 -0700
@@ -242,6 +242,9 @@ void decode_numa_list(int *numa, char *t
 
 	memset(numa, 0, MAX_NODES * sizeof(int));
 
+	if (!t)
+		return;
+
 	while (*t == 'N') {
 		t++;
 		node = strtoul(t, &t, 10);
@@ -386,7 +389,9 @@ void report(struct slabinfo *s)
 {
 	if (strcmp(s->name, "*") == 0)
 		return;
-	printf("\nSlabcache: %-20s  Aliases: %2d Order : %2d\n", s->name, s->aliases, s->order);
+
+	printf("\nSlabcache: %-20s  Aliases: %2d Order : %2d Objects: %d\n",
+		s->name, s->aliases, s->order, s->objects);
 	if (s->hwcache_align)
 		printf("** Hardware cacheline aligned\n");
 	if (s->cache_dma)
@@ -791,11 +796,11 @@ void totals(void)
 
 	store_size(b1, total_size);store_size(b2, total_waste);
 	store_size(b3, total_waste * 100 / total_used);
-	printf("Memory used: %6s   # Loss   : %6s   MRatio: %6s%%\n", b1, b2, b3);
+	printf("Memory used: %6s   # Loss   : %6s   MRatio:%6s%%\n", b1, b2, b3);
 
 	store_size(b1, total_objects);store_size(b2, total_partobj);
 	store_size(b3, total_partobj * 100 / total_objects);
-	printf("# Objects  : %6s   # PartObj: %6s   ORatio: %6s%%\n", b1, b2, b3);
+	printf("# Objects  : %6s   # PartObj: %6s   ORatio:%6s%%\n", b1, b2, b3);
 
 	printf("\n");
 	printf("Per Cache    Average         Min         Max       Total\n");
@@ -818,7 +823,7 @@ void totals(void)
 	store_size(b1, avg_ppart);store_size(b2, min_ppart);
 	store_size(b3, max_ppart);
 	store_size(b4, total_partial * 100  / total_slabs);
-	printf("%%PartSlab %10s%% %10s%% %10s%% %10s%%\n",
+	printf("%%PartSlab%10s%% %10s%% %10s%% %10s%%\n",
 			b1,	b2,	b3,	b4);
 
 	store_size(b1, avg_partobj);store_size(b2, min_partobj);
@@ -830,7 +835,7 @@ void totals(void)
 	store_size(b1, avg_ppartobj);store_size(b2, min_ppartobj);
 	store_size(b3, max_ppartobj);
 	store_size(b4, total_partobj * 100 / total_objects);
-	printf("%% PartObj %10s%% %10s%% %10s%% %10s%%\n",
+	printf("%% PartObj%10s%% %10s%% %10s%% %10s%%\n",
 			b1,	b2,	b3,	b4);
 
 	store_size(b1, avg_size);store_size(b2, min_size);
@@ -1100,6 +1105,8 @@ void output_slabs(void)
 			ops(slab);
 		else if (show_slab)
 			slabcache(slab);
+		else if (show_report)
+			report(slab);
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
