From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 03/12] Slab defragmentation: Updates to slabinfo.c
Date: Sat, 07 Jul 2007 20:05:41 -0700
Message-ID: <20070708030844.093584299@sgi.com>
References: <20070708030538.729027694@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756507AbXGHDKo@vger.kernel.org>
Content-Disposition: inline; filename=slab_defrag_slabinfo_updates
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com
List-Id: linux-mm.kvack.org

-D lists caches that support defragmentation

-C lists caches that use a ctor.

Change field names for defrag_ratio and remote_node_defrag_ratio.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 Documentation/vm/slabinfo.c |   52 +++++++++++++++++++++++++++++++++++++-------
 1 file changed, 44 insertions(+), 8 deletions(-)

Index: linux-2.6.22-rc6-mm1/Documentation/vm/slabinfo.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/Documentation/vm/slabinfo.c	2007-07-05 19:00:27.000000000 -0700
+++ linux-2.6.22-rc6-mm1/Documentation/vm/slabinfo.c	2007-07-05 19:04:14.000000000 -0700
@@ -30,6 +30,8 @@ struct slabinfo {
 	int hwcache_align, object_size, objs_per_slab;
 	int sanity_checks, slab_size, store_user, trace;
 	int order, poison, reclaim_account, red_zone;
+	int defrag, ctor;
+	int defrag_ratio, remote_node_defrag_ratio;
 	unsigned long partial, objects, slabs;
 	int numa[MAX_NODES];
 	int numa_partial[MAX_NODES];
@@ -56,6 +58,8 @@ int show_slab = 0;
 int skip_zero = 1;
 int show_numa = 0;
 int show_track = 0;
+int show_defrag = 0;
+int show_ctor = 0;
 int show_first_alias = 0;
 int validate = 0;
 int shrink = 0;
@@ -90,18 +94,20 @@ void fatal(const char *x, ...)
 void usage(void)
 {
 	printf("slabinfo 5/7/2007. (c) 2007 sgi. clameter@sgi.com\n\n"
-		"slabinfo [-ahnpvtsz] [-d debugopts] [slab-regexp]\n"
+		"slabinfo [-aCDefhilnosSrtTvz1] [-d debugopts] [slab-regexp]\n"
 		"-a|--aliases           Show aliases\n"
+		"-C|--ctor              Show slabs with ctors\n"
 		"-d<options>|--debug=<options> Set/Clear Debug options\n"
-		"-e|--empty		Show empty slabs\n"
+		"-D|--defrag            Show defragmentable caches\n"
+		"-e|--empty             Show empty slabs\n"
 		"-f|--first-alias       Show first alias\n"
 		"-h|--help              Show usage information\n"
 		"-i|--inverted          Inverted list\n"
 		"-l|--slabs             Show slabs\n"
 		"-n|--numa              Show NUMA information\n"
-		"-o|--ops		Show kmem_cache_ops\n"
+		"-o|--ops               Show kmem_cache_ops\n"
 		"-s|--shrink            Shrink slabs\n"
-		"-r|--report		Detailed report on single slabs\n"
+		"-r|--report            Detailed report on single slabs\n"
 		"-S|--Size              Sort by size\n"
 		"-t|--tracking          Show alloc/free information\n"
 		"-T|--Totals            Show summary information\n"
@@ -281,7 +287,7 @@ int line = 0;
 void first_line(void)
 {
 	printf("Name                   Objects Objsize    Space "
-		"Slabs/Part/Cpu  O/S O %%Fr %%Ef Flg\n");
+		"Slabs/Part/Cpu  O/S O %%Ra %%Ef Flg\n");
 }
 
 /*
@@ -324,7 +330,7 @@ void slab_numa(struct slabinfo *s, int m
 		return;
 
 	if (!line) {
-		printf("\n%-21s:", mode ? "NUMA nodes" : "Slab");
+		printf("\n%-21s: Rto ", mode ? "NUMA nodes" : "Slab");
 		for(node = 0; node <= highest_node; node++)
 			printf(" %4d", node);
 		printf("\n----------------------");
@@ -333,6 +339,7 @@ void slab_numa(struct slabinfo *s, int m
 		printf("\n");
 	}
 	printf("%-21s ", mode ? "All slabs" : s->name);
+	printf("%3d ", s->remote_node_defrag_ratio);
 	for(node = 0; node <= highest_node; node++) {
 		char b[20];
 
@@ -406,6 +413,8 @@ void report(struct slabinfo *s)
 		printf("** Slabs are destroyed via RCU\n");
 	if (s->reclaim_account)
 		printf("** Reclaim accounting active\n");
+	if (s->defrag)
+		printf("** Defragmentation at %d%%\n", s->defrag_ratio);
 
 	printf("\nSizes (bytes)     Slabs              Debug                Memory\n");
 	printf("------------------------------------------------------------------------\n");
@@ -452,6 +461,12 @@ void slabcache(struct slabinfo *s)
 	if (show_empty && s->slabs)
 		return;
 
+	if (show_defrag && !s->defrag)
+		return;
+
+	if (show_ctor && !s->ctor)
+		return;
+
 	store_size(size_str, slab_size(s));
 	sprintf(dist_str,"%lu/%lu/%d", s->slabs, s->partial, s->cpu_slabs);
 
@@ -462,6 +477,10 @@ void slabcache(struct slabinfo *s)
 		*p++ = '*';
 	if (s->cache_dma)
 		*p++ = 'd';
+	if (s->defrag)
+		*p++ = 'D';
+	if (s->ctor)
+		*p++ = 'C';
 	if (s->hwcache_align)
 		*p++ = 'A';
 	if (s->poison)
@@ -481,7 +500,7 @@ void slabcache(struct slabinfo *s)
 	printf("%-21s %8ld %7d %8s %14s %4d %1d %3ld %3ld %s\n",
 		s->name, s->objects, s->object_size, size_str, dist_str,
 		s->objs_per_slab, s->order,
-		s->slabs ? (s->partial * 100) / s->slabs : 100,
+		s->slabs ? (s->objects * 100) / (s->slabs * s->objs_per_slab) : 100,
 		s->slabs ? (s->objects * s->object_size * 100) /
 			(s->slabs * (page_size << s->order)) : 100,
 		flags);
@@ -1071,7 +1090,16 @@ void read_slab_dir(void)
 			decode_numa_list(slab->numa, t);
 			slab->store_user = get_obj("store_user");
 			slab->trace = get_obj("trace");
+			slab->defrag_ratio = get_obj("defrag_ratio");
+			slab->remote_node_defrag_ratio =
+					get_obj("remote_node_defrag_ratio");
 			chdir("..");
+			if (read_slab_obj(slab, "ops")) {
+				if (strstr(buffer, "ctor :"))
+					slab->ctor = 1;
+				if (strstr(buffer, "kick :"))
+					slab->defrag = 1;
+			}
 			if (slab->name[0] == ':')
 				alias_targets++;
 			slab++;
@@ -1121,7 +1149,9 @@ void output_slabs(void)
 
 struct option opts[] = {
 	{ "aliases", 0, NULL, 'a' },
+	{ "ctor", 0, NULL, 'C' },
 	{ "debug", 2, NULL, 'd' },
+	{ "defrag", 0, NULL, 'D' },
 	{ "empty", 0, NULL, 'e' },
 	{ "first-alias", 0, NULL, 'f' },
 	{ "help", 0, NULL, 'h' },
@@ -1146,7 +1176,7 @@ int main(int argc, char *argv[])
 
 	page_size = getpagesize();
 
-	while ((c = getopt_long(argc, argv, "ad::efhil1noprstvzTS",
+	while ((c = getopt_long(argc, argv, "ad::efhil1noprstvzCDTS",
 						opts, NULL)) != -1)
 	switch(c) {
 		case '1':
@@ -1196,6 +1226,12 @@ int main(int argc, char *argv[])
 		case 'z':
 			skip_zero = 0;
 			break;
+		case 'C':
+			show_ctor = 1;
+			break;
+		case 'D':
+			show_defrag = 1;
+			break;
 		case 'T':
 			show_totals = 1;
 			break;

-- 
