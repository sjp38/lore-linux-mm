Date: Sat, 28 Apr 2007 22:11:09 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB slabinfo: More statistic fixes and handling fixes
Message-ID: <Pine.LNX.4.64.0704282209210.29490@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Make -s be shrink. -r is kind of strange. Free up -s by making the rarely
used --slab option use -l as an abbreviation.

Fix some additional issues with the total statistics that showed up
during NUMA testing.

Replace "Waste" items by "Loss" lest one gets the wrong idea.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 Documentation/vm/slabinfo.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

Index: slub/Documentation/vm/slabinfo.c
===================================================================
--- slub.orig/Documentation/vm/slabinfo.c	2007-04-28 19:34:14.000000000 -0700
+++ slub/Documentation/vm/slabinfo.c	2007-04-28 20:52:15.000000000 -0700
@@ -80,12 +80,12 @@ void usage(void)
 		"-a|--aliases           Show aliases\n"
 		"-h|--help              Show usage information\n"
 		"-n|--numa              Show NUMA information\n"
-		"-r|--reduce	        Shrink slabs\n"
+		"-s|--shrink            Shrink slabs\n"
 		"-v|--validate          Validate slabs\n"
 		"-t|--tracking          Show alloc/free information\n"
-		"-T|--Totals		Show summary information\n"
-		"-s|--slabs             Show slabs\n"
-		"-S|--Size		Sort by size\n"
+		"-T|--Totals            Show summary information\n"
+		"-l|--slabs             Show slabs\n"
+		"-S|--Size              Sort by size\n"
 		"-z|--zero              Include empty slabs\n"
 		"-f|--first-alias       Show first alias\n"
 		"-i|--inverted          Inverted list\n"
@@ -371,9 +371,10 @@ void totals(void)
 				avg_size, total_size = 0;
 
 	/* Bytes used for object storage in a slab */
-	unsigned long long min_used = max, max_used = 0, avg_used, total_used = 0;
+	unsigned long long min_used = max, max_used = 0,
+				avg_used, total_used = 0;
 
-	/* Waste: Bytes used for aligned and padding */
+	/* Waste: Bytes used for alignment and padding */
 	unsigned long long min_waste = max, max_waste = 0,
 				avg_waste, total_waste = 0;
 	/* Number of objects in a slab */
@@ -381,11 +382,13 @@ void totals(void)
 				avg_objects, total_objects = 0;
 	/* Waste per object */
 	unsigned long long min_objwaste = max,
-				max_objwaste = 0, avg_objwaste;
+				max_objwaste = 0, avg_objwaste,
+				total_objwaste = 0;
 
 	/* Memory per object */
 	unsigned long long min_memobj = max,
-				max_memobj = 0, avg_memobj;
+				max_memobj = 0, avg_memobj,
+				total_objsize = 0;
 
 	/* Percentage of partial slabs per slab */
 	unsigned long min_ppart = 100, max_ppart = 0,
@@ -496,6 +499,9 @@ void totals(void)
 		total_partobj += objects_in_partial_slabs;
 		total_ppart += percentage_partial_slabs;
 		total_ppartobj += percentage_partial_objs;
+
+		total_objwaste += s->objects * objwaste;
+		total_objsize += s->objects * s->slab_size;
 	}
 
 	if (!total_objects) {
@@ -521,9 +527,9 @@ void totals(void)
 
 	/* Per object object sizes */
 	avg_objsize = total_used / total_objects;
-	avg_objwaste = total_waste / total_objects;
+	avg_objwaste = total_objwaste / total_objects;
 	avg_partobj = total_partobj * 100 / total_objects;
-	avg_memobj = total_size / total_objects;
+	avg_memobj = total_objsize / total_objects;
 
 	printf("Slabcache Totals\n");
 	printf("----------------\n");
@@ -584,9 +590,9 @@ void totals(void)
 	printf("Used      %10s  %10s  %10s  %10s\n",
 			b1,	b2,	b3,	b4);
 
-	store_size(b1, avg_slabs);store_size(b2, min_slabs);
-	store_size(b3, max_slabs);store_size(b4, total_slabs);
-	printf("Waste     %10s  %10s  %10s  %10s\n",
+	store_size(b1, avg_waste);store_size(b2, min_waste);
+	store_size(b3, max_waste);store_size(b4, total_waste);
+	printf("Loss      %10s  %10s  %10s  %10s\n",
 			b1,	b2,	b3,	b4);
 
 	printf("\n");
@@ -604,7 +610,7 @@ void totals(void)
 
 	store_size(b1, avg_objwaste);store_size(b2, min_objwaste);
 	store_size(b3, max_objwaste);
-	printf("Waste     %10s  %10s  %10s\n",
+	printf("Loss      %10s  %10s  %10s\n",
 			b1,	b2,	b3);
 }
 
@@ -838,13 +844,13 @@ void output_slabs(void)
 
 struct option opts[] = {
 	{ "aliases", 0, NULL, 'a' },
-	{ "slabs", 0, NULL, 's' },
+	{ "slabs", 0, NULL, 'l' },
 	{ "numa", 0, NULL, 'n' },
 	{ "zero", 0, NULL, 'z' },
 	{ "help", 0, NULL, 'h' },
 	{ "validate", 0, NULL, 'v' },
 	{ "first-alias", 0, NULL, 'f' },
-	{ "reduce", 0, NULL, 'r' },
+	{ "shrink", 0, NULL, 's' },
 	{ "track", 0, NULL, 't'},
 	{ "inverted", 0, NULL, 'i'},
 	{ "1ref", 0, NULL, '1'},
@@ -861,7 +867,7 @@ int main(int argc, char *argv[])
 	if (chdir("/sys/slab"))
 		fatal("This kernel does not have SLUB support.\n");
 
-	while ((c = getopt_long(argc, argv, "afhi1nprstvzTS", opts, NULL)) != -1)
+	while ((c = getopt_long(argc, argv, "afhil1npstvzTS", opts, NULL)) != -1)
 	switch(c) {
 		case '1':
 			show_single_ref = 1;
@@ -881,10 +887,10 @@ int main(int argc, char *argv[])
 		case 'n':
 			show_numa = 1;
 			break;
-		case 'r':
+		case 's':
 			shrink = 1;
 			break;
-		case 's':
+		case 'l':
 			show_slab = 1;
 			break;
 		case 't':

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
