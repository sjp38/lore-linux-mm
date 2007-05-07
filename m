Message-Id: <20070507212408.225671736@sgi.com>
References: <20070507212240.254911542@sgi.com>
Date: Mon, 07 May 2007 14:22:44 -0700
From: clameter@sgi.com
Subject: [patch 04/17] SLUB: slabinfo upgrade
Content-Disposition: inline; filename=slabinfo_debug
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-e Show empty slabs
-d Modification of slab debug options at runtime
-o Operations. Display of ctor / dtor etc.
-r Report: Display all available information about a slabcache.

Cleanup tracking display and make it work right.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 Documentation/vm/slabinfo.c |  426 ++++++++++++++++++++++++++++++++++++--------
 1 file changed, 352 insertions(+), 74 deletions(-)

Index: slub/Documentation/vm/slabinfo.c
===================================================================
--- slub.orig/Documentation/vm/slabinfo.c	2007-05-07 13:51:40.000000000 -0700
+++ slub/Documentation/vm/slabinfo.c	2007-05-07 13:57:38.000000000 -0700
@@ -16,6 +16,7 @@
 #include <stdarg.h>
 #include <getopt.h>
 #include <regex.h>
+#include <errno.h>
 
 #define MAX_SLABS 500
 #define MAX_ALIASES 500
@@ -41,12 +42,15 @@ struct aliasinfo {
 } aliasinfo[MAX_ALIASES];
 
 int slabs = 0;
+int actual_slabs = 0;
 int aliases = 0;
 int alias_targets = 0;
 int highest_node = 0;
 
 char buffer[4096];
 
+int show_empty = 0;
+int show_report = 0;
 int show_alias = 0;
 int show_slab = 0;
 int skip_zero = 1;
@@ -59,6 +63,15 @@ int show_inverted = 0;
 int show_single_ref = 0;
 int show_totals = 0;
 int sort_size = 0;
+int set_debug = 0;
+int show_ops = 0;
+
+/* Debug options */
+int sanity = 0;
+int redzone = 0;
+int poison = 0;
+int tracking = 0;
+int tracing = 0;
 
 int page_size;
 
@@ -76,20 +89,33 @@ void fatal(const char *x, ...)
 
 void usage(void)
 {
-	printf("slabinfo [-ahnpvtsz] [slab-regexp]\n"
+	printf("slabinfo 5/7/2007. (c) 2007 sgi. clameter@sgi.com\n\n"
+		"slabinfo [-ahnpvtsz] [-d debugopts] [slab-regexp]\n"
 		"-a|--aliases           Show aliases\n"
+		"-d<options>|--debug=<options> Set/Clear Debug options\n"
+		"-e|--empty		Show empty slabs\n"
+		"-f|--first-alias       Show first alias\n"
 		"-h|--help              Show usage information\n"
+		"-i|--inverted          Inverted list\n"
+		"-l|--slabs             Show slabs\n"
 		"-n|--numa              Show NUMA information\n"
+		"-o|--ops		Show kmem_cache_ops\n"
 		"-s|--shrink            Shrink slabs\n"
-		"-v|--validate          Validate slabs\n"
+		"-r|--report		Detailed report on single slabs\n"
+		"-S|--Size              Sort by size\n"
 		"-t|--tracking          Show alloc/free information\n"
 		"-T|--Totals            Show summary information\n"
-		"-l|--slabs             Show slabs\n"
-		"-S|--Size              Sort by size\n"
+		"-v|--validate          Validate slabs\n"
 		"-z|--zero              Include empty slabs\n"
-		"-f|--first-alias       Show first alias\n"
-		"-i|--inverted          Inverted list\n"
 		"-1|--1ref              Single reference\n"
+		"\nValid debug options (FZPUT may be combined)\n"
+		"a / A          Switch on all debug options (=FZUP)\n"
+		"-              Switch off all debug options\n"
+		"f / F          Sanity Checks (SLAB_DEBUG_FREE)\n"
+		"z / Z          Redzoning\n"
+		"p / P          Poisoning\n"
+		"u / U          Tracking\n"
+		"t / T          Tracing\n"
 	);
 }
 
@@ -143,11 +169,10 @@ unsigned long get_obj_and_str(char *name
 void set_obj(struct slabinfo *s, char *name, int n)
 {
 	char x[100];
+	FILE *f;
 
 	sprintf(x, "%s/%s", s->name, name);
-
-	FILE *f = fopen(x, "w");
-
+	f = fopen(x, "w");
 	if (!f)
 		fatal("Cannot write to %s\n", x);
 
@@ -155,6 +180,26 @@ void set_obj(struct slabinfo *s, char *n
 	fclose(f);
 }
 
+unsigned long read_slab_obj(struct slabinfo *s, char *name)
+{
+	char x[100];
+	FILE *f;
+	int l;
+
+	sprintf(x, "%s/%s", s->name, name);
+	f = fopen(x, "r");
+	if (!f) {
+		buffer[0] = 0;
+		l = 0;
+	} else {
+		l = fread(buffer, 1, sizeof(buffer), f);
+		buffer[l] = 0;
+		fclose(f);
+	}
+	return l;
+}
+
+
 /*
  * Put a size string together
  */
@@ -226,7 +271,7 @@ int line = 0;
 
 void first_line(void)
 {
-	printf("Name                 Objects   Objsize    Space "
+	printf("Name                   Objects Objsize    Space "
 		"Slabs/Part/Cpu  O/S O %%Fr %%Ef Flg\n");
 }
 
@@ -246,10 +291,7 @@ struct aliasinfo *find_one_alias(struct 
 					return best;
 			}
 	}
-	if (best)
-		return best;
-	fatal("Cannot find alias for %s\n", find->name);
-	return NULL;
+	return best;
 }
 
 unsigned long slab_size(struct slabinfo *s)
@@ -257,6 +299,126 @@ unsigned long slab_size(struct slabinfo 
 	return 	s->slabs * (page_size << s->order);
 }
 
+void slab_numa(struct slabinfo *s, int mode)
+{
+	int node;
+
+	if (strcmp(s->name, "*") == 0)
+		return;
+
+	if (!highest_node) {
+		printf("\n%s: No NUMA information available.\n", s->name);
+		return;
+	}
+
+	if (skip_zero && !s->slabs)
+		return;
+
+	if (!line) {
+		printf("\n%-21s:", mode ? "NUMA nodes" : "Slab");
+		for(node = 0; node <= highest_node; node++)
+			printf(" %4d", node);
+		printf("\n----------------------");
+		for(node = 0; node <= highest_node; node++)
+			printf("-----");
+		printf("\n");
+	}
+	printf("%-21s ", mode ? "All slabs" : s->name);
+	for(node = 0; node <= highest_node; node++) {
+		char b[20];
+
+		store_size(b, s->numa[node]);
+		printf(" %4s", b);
+	}
+	printf("\n");
+	if (mode) {
+		printf("%-21s ", "Partial slabs");
+		for(node = 0; node <= highest_node; node++) {
+			char b[20];
+
+			store_size(b, s->numa_partial[node]);
+			printf(" %4s", b);
+		}
+		printf("\n");
+	}
+	line++;
+}
+
+void show_tracking(struct slabinfo *s)
+{
+	printf("\n%s: Kernel object allocation\n", s->name);
+	printf("-----------------------------------------------------------------------\n");
+	if (read_slab_obj(s, "alloc_calls"))
+		printf(buffer);
+	else
+		printf("No Data\n");
+
+	printf("\n%s: Kernel object freeing\n", s->name);
+	printf("------------------------------------------------------------------------\n");
+	if (read_slab_obj(s, "free_calls"))
+		printf(buffer);
+	else
+		printf("No Data\n");
+
+}
+
+void ops(struct slabinfo *s)
+{
+	if (strcmp(s->name, "*") == 0)
+		return;
+
+	if (read_slab_obj(s, "ops")) {
+		printf("\n%s: kmem_cache operations\n", s->name);
+		printf("--------------------------------------------\n");
+		printf(buffer);
+	} else
+		printf("\n%s has no kmem_cache operations\n", s->name);
+}
+
+const char *onoff(int x)
+{
+	if (x)
+		return "On ";
+	return "Off";
+}
+
+void report(struct slabinfo *s)
+{
+	if (strcmp(s->name, "*") == 0)
+		return;
+	printf("\nSlabcache: %-20s  Aliases: %2d Order : %2d\n", s->name, s->aliases, s->order);
+	if (s->hwcache_align)
+		printf("** Hardware cacheline aligned\n");
+	if (s->cache_dma)
+		printf("** Memory is allocated in a special DMA zone\n");
+	if (s->destroy_by_rcu)
+		printf("** Slabs are destroyed via RCU\n");
+	if (s->reclaim_account)
+		printf("** Reclaim accounting active\n");
+
+	printf("\nSizes (bytes)     Slabs              Debug                Memory\n");
+	printf("------------------------------------------------------------------------\n");
+	printf("Object : %7d  Total  : %7ld   Sanity Checks : %s  Total: %7ld\n",
+			s->object_size, s->slabs, onoff(s->sanity_checks),
+			s->slabs * (page_size << s->order));
+	printf("SlabObj: %7d  Full   : %7ld   Redzoning     : %s  Used : %7ld\n",
+			s->slab_size, s->slabs - s->partial - s->cpu_slabs,
+			onoff(s->red_zone), s->objects * s->object_size);
+	printf("SlabSiz: %7d  Partial: %7ld   Poisoning     : %s  Loss : %7ld\n",
+			page_size << s->order, s->partial, onoff(s->poison),
+			s->slabs * (page_size << s->order) - s->objects * s->object_size);
+	printf("Loss   : %7d  CpuSlab: %7d   Tracking      : %s  Lalig: %7ld\n",
+			s->slab_size - s->object_size, s->cpu_slabs, onoff(s->store_user),
+			(s->slab_size - s->object_size) * s->objects);
+	printf("Align  : %7d  Objects: %7d   Tracing       : %s  Lpadd: %7ld\n",
+			s->align, s->objs_per_slab, onoff(s->trace),
+			((page_size << s->order) - s->objs_per_slab * s->slab_size) *
+			s->slabs);
+
+	ops(s);
+	show_tracking(s);
+	slab_numa(s, 1);
+}
 
 void slabcache(struct slabinfo *s)
 {
@@ -265,7 +427,18 @@ void slabcache(struct slabinfo *s)
 	char flags[20];
 	char *p = flags;
 
-	if (skip_zero && !s->slabs)
+	if (strcmp(s->name, "*") == 0)
+		return;
+
+	if (actual_slabs == 1) {
+		report(s);
+		return;
+	}
+
+	if (skip_zero && !show_empty && !s->slabs)
+		return;
+
+	if (show_empty && s->slabs)
 		return;
 
 	store_size(size_str, slab_size(s));
@@ -303,48 +476,128 @@ void slabcache(struct slabinfo *s)
 		flags);
 }
 
-void slab_numa(struct slabinfo *s)
+/*
+ * Analyze debug options. Return false if something is amiss.
+ */
+int debug_opt_scan(char *opt)
 {
-	int node;
+	if (!opt || !opt[0] || strcmp(opt, "-") == 0)
+		return 1;
 
-	if (!highest_node)
-		fatal("No NUMA information available.\n");
+	if (strcasecmp(opt, "a") == 0) {
+		sanity = 1;
+		poison = 1;
+		redzone = 1;
+		tracking = 1;
+		return 1;
+	}
+
+	for ( ; *opt; opt++)
+	 	switch (*opt) {
+		case 'F' : case 'f':
+			if (sanity)
+				return 0;
+			sanity = 1;
+			break;
+		case 'P' : case 'p':
+			if (poison)
+				return 0;
+			poison = 1;
+			break;
 
-	if (skip_zero && !s->slabs)
-		return;
+		case 'Z' : case 'z':
+			if (redzone)
+				return 0;
+			redzone = 1;
+			break;
 
-	if (!line) {
-		printf("\nSlab             Node ");
-		for(node = 0; node <= highest_node; node++)
-			printf(" %4d", node);
-		printf("\n----------------------");
-		for(node = 0; node <= highest_node; node++)
-			printf("-----");
-		printf("\n");
-	}
-	printf("%-21s ", s->name);
-	for(node = 0; node <= highest_node; node++) {
-		char b[20];
+		case 'U' : case 'u':
+			if (tracking)
+				return 0;
+			tracking = 1;
+			break;
 
-		store_size(b, s->numa[node]);
-		printf(" %4s", b);
-	}
-	printf("\n");
-	line++;
+		case 'T' : case 't':
+			if (tracing)
+				return 0;
+			tracing = 1;
+			break;
+		default:
+			return 0;
+		}
+	return 1;
 }
 
-void show_tracking(struct slabinfo *s)
+int slab_empty(struct slabinfo *s)
 {
-	printf("\n%s: Calls to allocate a slab object\n", s->name);
-	printf("---------------------------------------------------\n");
-	if (read_obj("alloc_calls"))
-		printf(buffer);
+	if (s->objects > 0)
+		return 0;
 
-	printf("%s: Calls to free a slab object\n", s->name);
-	printf("-----------------------------------------------\n");
-	if (read_obj("free_calls"))
-		printf(buffer);
+	/*
+	 * We may still have slabs even if there are no objects. Shrinking will
+	 * remove them.
+	 */
+	if (s->slabs != 0)
+		set_obj(s, "shrink", 1);
 
+	return 1;
+}
+
+void slab_debug(struct slabinfo *s)
+{
+	if (sanity && !s->sanity_checks) {
+		set_obj(s, "sanity", 1);
+	}
+	if (!sanity && s->sanity_checks) {
+		if (slab_empty(s))
+			set_obj(s, "sanity", 0);
+		else
+			fprintf(stderr, "%s not empty cannot disable sanity checks\n", s->name);
+	}
+	if (redzone && !s->red_zone) {
+		if (slab_empty(s))
+			set_obj(s, "red_zone", 1);
+		else
+			fprintf(stderr, "%s not empty cannot enable redzoning\n", s->name);
+	}
+	if (!redzone && s->red_zone) {
+		if (slab_empty(s))
+			set_obj(s, "red_zone", 0);
+		else
+			fprintf(stderr, "%s not empty cannot disable redzoning\n", s->name);
+	}
+	if (poison && !s->poison) {
+		if (slab_empty(s))
+			set_obj(s, "poison", 1);
+		else
+			fprintf(stderr, "%s not empty cannot enable poisoning\n", s->name);
+	}
+	if (!poison && s->poison) {
+		if (slab_empty(s))
+			set_obj(s, "poison", 0);
+		else
+			fprintf(stderr, "%s not empty cannot disable poisoning\n", s->name);
+	}
+	if (tracking && !s->store_user) {
+		if (slab_empty(s))
+			set_obj(s, "store_user", 1);
+		else
+			fprintf(stderr, "%s not empty cannot enable tracking\n", s->name);
+	}
+	if (!tracking && s->store_user) {
+		if (slab_empty(s))
+			set_obj(s, "store_user", 0);
+		else
+			fprintf(stderr, "%s not empty cannot disable tracking\n", s->name);
+	}
+	if (tracing && !s->trace) {
+		if (slabs == 1)
+			set_obj(s, "trace", 1);
+		else
+			fprintf(stderr, "%s can only enable trace for one slab at a time\n", s->name);
+	}
+	if (!tracing && s->trace)
+		set_obj(s, "trace", 1);
 }
 
 void totals(void)
@@ -673,7 +926,7 @@ void link_slabs(void)
 
 	for (a = aliasinfo; a < aliasinfo + aliases; a++) {
 
-		for(s = slabinfo; s < slabinfo + slabs; s++)
+		for (s = slabinfo; s < slabinfo + slabs; s++)
 			if (strcmp(a->ref, s->name) == 0) {
 				a->slab = s;
 				s->refs++;
@@ -704,7 +957,7 @@ void alias(void)
 					continue;
 				}
 			}
-			printf("\n%-20s <- %s", a->slab->name, a->name);
+			printf("\n%-12s <- %s", a->slab->name, a->name);
 			active = a->slab->name;
 		}
 		else
@@ -729,7 +982,12 @@ void rename_slabs(void)
 
 		a = find_one_alias(s);
 
-		s->name = a->name;
+		if (a)
+			s->name = a->name;
+		else {
+			s->name = "*";
+			actual_slabs--;
+		}
 	}
 }
 
@@ -748,11 +1006,14 @@ void read_slab_dir(void)
 	char *t;
 	int count;
 
+	if (chdir("/sys/slab"))
+		fatal("SYSFS support for SLUB not active\n");
+
 	dir = opendir(".");
 	while ((de = readdir(dir))) {
 		if (de->d_name[0] == '.' ||
-				slab_mismatch(de->d_name))
-			continue;
+			(de->d_name[0] != ':' && slab_mismatch(de->d_name)))
+				continue;
 		switch (de->d_type) {
 		   case DT_LNK:
 		   	alias->name = strdup(de->d_name);
@@ -807,6 +1068,7 @@ void read_slab_dir(void)
 	}
 	closedir(dir);
 	slabs = slab - slabinfo;
+	actual_slabs = slabs;
 	aliases = alias - aliasinfo;
 	if (slabs > MAX_SLABS)
 		fatal("Too many slabs\n");
@@ -825,34 +1087,37 @@ void output_slabs(void)
 
 
 		if (show_numa)
-			slab_numa(slab);
-		else
-		if (show_track)
+			slab_numa(slab, 0);
+		else if (show_track)
 			show_tracking(slab);
-		else
-		if (validate)
+		else if (validate)
 			slab_validate(slab);
-		else
-		if (shrink)
+		else if (shrink)
 			slab_shrink(slab);
-		else {
-			if (show_slab)
-				slabcache(slab);
-		}
+		else if (set_debug)
+			slab_debug(slab);
+		else if (show_ops)
+			ops(slab);
+		else if (show_slab)
+			slabcache(slab);
 	}
 }
 
 struct option opts[] = {
 	{ "aliases", 0, NULL, 'a' },
-	{ "slabs", 0, NULL, 'l' },
-	{ "numa", 0, NULL, 'n' },
-	{ "zero", 0, NULL, 'z' },
-	{ "help", 0, NULL, 'h' },
-	{ "validate", 0, NULL, 'v' },
+	{ "debug", 2, NULL, 'd' },
+	{ "empty", 0, NULL, 'e' },
 	{ "first-alias", 0, NULL, 'f' },
+	{ "help", 0, NULL, 'h' },
+	{ "inverted", 0, NULL, 'i'},
+	{ "numa", 0, NULL, 'n' },
+	{ "ops", 0, NULL, 'o' },
+	{ "report", 0, NULL, 'r' },
 	{ "shrink", 0, NULL, 's' },
+	{ "slabs", 0, NULL, 'l' },
 	{ "track", 0, NULL, 't'},
-	{ "inverted", 0, NULL, 'i'},
+	{ "validate", 0, NULL, 'v' },
+	{ "zero", 0, NULL, 'z' },
 	{ "1ref", 0, NULL, '1'},
 	{ NULL, 0, NULL, 0 }
 };
@@ -864,10 +1129,9 @@ int main(int argc, char *argv[])
 	char *pattern_source;
 
 	page_size = getpagesize();
-	if (chdir("/sys/slab"))
-		fatal("This kernel does not have SLUB support.\n");
 
-	while ((c = getopt_long(argc, argv, "afhil1npstvzTS", opts, NULL)) != -1)
+	while ((c = getopt_long(argc, argv, "ad::efhil1noprstvzTS",
+						opts, NULL)) != -1)
 	switch(c) {
 		case '1':
 			show_single_ref = 1;
@@ -875,6 +1139,14 @@ int main(int argc, char *argv[])
 		case 'a':
 			show_alias = 1;
 			break;
+		case 'd':
+			set_debug = 1;
+			if (!debug_opt_scan(optarg))
+				fatal("Invalid debug option '%s'\n", optarg);
+			break;
+		case 'e':
+			show_empty = 1;
+			break;
 		case 'f':
 			show_first_alias = 1;
 			break;
@@ -887,6 +1159,12 @@ int main(int argc, char *argv[])
 		case 'n':
 			show_numa = 1;
 			break;
+		case 'o':
+			show_ops = 1;
+			break;
+		case 'r':
+			show_report = 1;
+			break;
 		case 's':
 			shrink = 1;
 			break;
@@ -914,8 +1192,8 @@ int main(int argc, char *argv[])
 
 	}
 
-	if (!show_slab && !show_alias && !show_track
-		&& !validate && !shrink)
+	if (!show_slab && !show_alias && !show_track && !show_report
+		&& !validate && !shrink && !set_debug && !show_ops)
 			show_slab = 1;
 
 	if (argc > optind)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
