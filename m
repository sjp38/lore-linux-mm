Message-Id: <20070427042908.949211861@sgi.com>
References: <20070427042655.019305162@sgi.com>
Date: Thu, 26 Apr 2007 21:27:02 -0700
From: clameter@sgi.com
Subject: [patch 07/10] SLUB: Major slabinfo update
Content-Disposition: inline; filename=slub_slabinfo_update
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Enhancement to slabinfo
- Support for slab shrinking (-r option)
- Slab summary showing system totals (-T option)
- Sync with new form of alias handling
- Sort by size, reverse sorting etc (-S -i option)
- Alias lookups (-a)
- NUMA allocation tables table output (-n option)

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc7-mm2/Documentation/vm/slabinfo.c
===================================================================
--- linux-2.6.21-rc7-mm2.orig/Documentation/vm/slabinfo.c	2007-04-26 20:58:01.000000000 -0700
+++ linux-2.6.21-rc7-mm2/Documentation/vm/slabinfo.c	2007-04-26 21:00:24.000000000 -0700
@@ -3,7 +3,7 @@
  *
  * (C) 2007 sgi, Christoph Lameter <clameter@sgi.com>
  *
- * Compile by doing:
+ * Compile by:
  *
  * gcc -o slabinfo slabinfo.c
  */
@@ -17,15 +17,47 @@
 #include <getopt.h>
 #include <regex.h>
 
+#define MAX_SLABS 500
+#define MAX_ALIASES 500
+#define MAX_NODES 1024
+
+struct slabinfo {
+	char *name;
+	int alias;
+	int refs;
+	int aliases, align, cache_dma, cpu_slabs, destroy_by_rcu;
+	int hwcache_align, object_size, objs_per_slab;
+	int sanity_checks, slab_size, store_user, trace;
+	int order, poison, reclaim_account, red_zone;
+	unsigned long partial, objects, slabs;
+	int numa[MAX_NODES];
+	int numa_partial[MAX_NODES];
+} slabinfo[MAX_SLABS];
+
+struct aliasinfo {
+	char *name;
+	char *ref;
+	struct slabinfo *slab;
+} aliasinfo[MAX_ALIASES];
+
+int slabs = 0;
+int aliases = 0;
+int highest_node = 0;
+
 char buffer[4096];
 
 int show_alias = 0;
 int show_slab = 0;
-int show_parameters = 0;
 int skip_zero = 1;
 int show_numa = 0;
 int show_track = 0;
+int show_first_alias = 0;
 int validate = 0;
+int shrink = 0;
+int show_inverted = 0;
+int show_single_ref = 0;
+int show_totals = 0;
+int sort_size = 0;
 
 int page_size;
 
@@ -47,11 +79,16 @@ void usage(void)
 		"-a|--aliases           Show aliases\n"
 		"-h|--help              Show usage information\n"
 		"-n|--numa              Show NUMA information\n"
-		"-p|--parameters        Show global parameters\n"
+		"-r|--reduce	        Shrink slabs\n"
 		"-v|--validate          Validate slabs\n"
 		"-t|--tracking          Show alloc/free information\n"
+		"-T|--Totals		Show summary information\n"
 		"-s|--slabs             Show slabs\n"
+		"-S|--Size		Sort by size\n"
 		"-z|--zero              Include empty slabs\n"
+		"-f|--first-alias       Show first alias\n"
+		"-i|--inverted          Inverted list\n"
+		"-1|--1ref              Single reference\n"
 	);
 }
 
@@ -86,23 +123,32 @@ unsigned long get_obj(char *name)
 unsigned long get_obj_and_str(char *name, char **x)
 {
 	unsigned long result = 0;
+	char *p;
+
+	*x = NULL;
 
 	if (!read_obj(name)) {
 		x = NULL;
 		return 0;
 	}
-	result = strtoul(buffer, x, 10);
-	while (**x == ' ')
-		(*x)++;
+	result = strtoul(buffer, &p, 10);
+	while (*p == ' ')
+		p++;
+	if (*p)
+		*x = strdup(p);
 	return result;
 }
 
-void set_obj(char *name, int n)
+void set_obj(struct slabinfo *s, char *name, int n)
 {
-	FILE *f = fopen(name, "w");
+	char x[100];
+
+	sprintf(x, "%s/%s", s->name, name);
+
+	FILE *f = fopen(x, "w");
 
 	if (!f)
-		fatal("Cannot write to %s\n", name);
+		fatal("Cannot write to %s\n", x);
 
 	fprintf(f, "%d\n", n);
 	fclose(f);
@@ -143,167 +189,616 @@ int store_size(char *buffer, unsigned lo
 	return n;
 }
 
-void alias(const char *name)
+void decode_numa_list(int *numa, char *t)
 {
-	int count;
-	char *p;
-
-	if (!show_alias)
-		return;
+	int node;
+	int nr;
 
-	count = readlink(name, buffer, sizeof(buffer));
+	memset(numa, 0, MAX_NODES * sizeof(int));
 
-	if (count < 0)
-		return;
+	while (*t == 'N') {
+		t++;
+		node = strtoul(t, &t, 10);
+		if (*t == '=') {
+			t++;
+			nr = strtoul(t, &t, 10);
+			numa[node] = nr;
+			if (node > highest_node)
+				highest_node = node;
+		}
+		while (*t == ' ')
+			t++;
+	}
+}
 
-	buffer[count] = 0;
+char *hackname(struct slabinfo *s)
+{
+	char *n = s->name;
 
-	p = buffer + count;
+	if (n[0] == ':') {
+		char *nn = malloc(20);
+		char *p;
+
+		strncpy(nn, n, 20);
+		n = nn;
+		p = n + 4;
+		while (*p && *p !=':')
+			p++;
+		*p = 0;
+	}
+	return n;
+}
 
-	while (p > buffer && p[-1] != '/')
-		p--;
-	printf("%-20s -> %s\n", name, p);
+void slab_validate(struct slabinfo *s)
+{
+	set_obj(s, "validate", 1);
 }
 
-void slab_validate(char *name)
+void slab_shrink(struct slabinfo *s)
 {
-	set_obj("validate", 1);
+	set_obj(s, "shrink", 1);
 }
 
 int line = 0;
 
 void first_line(void)
 {
-	printf("Name                Objects   Objsize    Space "
-		"Slabs/Part/Cpu O/S O %%Fr %%Ef Flg\n");
+	printf("Name                 Objects   Objsize    Space "
+		"Slabs/Part/Cpu  O/S O %%Fr %%Ef Flg\n");
+}
+
+/*
+ * Find the shortest alias of a slab
+ */
+struct aliasinfo *find_one_alias(struct slabinfo *find)
+{
+	struct aliasinfo *a;
+	struct aliasinfo *best = NULL;
+
+	for(a = aliasinfo;a < aliasinfo + aliases; a++) {
+		if (a->slab == find &&
+			(!best || strlen(best->name) < strlen(a->name))) {
+				best = a;
+				if (strncmp(a->name,"kmall", 5) == 0)
+					return best;
+			}
+	}
+	if (best)
+		return best;
+	fatal("Cannot find alias for %s\n", find->name);
+	return NULL;
 }
 
-void slab(const char *name)
+unsigned long slab_size(struct slabinfo *s)
+{
+	return 	s->slabs * (page_size << s->order);
+}
+
+
+void slabcache(struct slabinfo *s)
 {
-	unsigned long aliases, align, cache_dma, cpu_slabs, destroy_by_rcu;
-	unsigned long hwcache_align, object_size, objects, objs_per_slab;
-	unsigned long order, partial, poison, reclaim_account, red_zone;
-	unsigned long sanity_checks, slab_size, slabs, store_user, trace;
 	char size_str[20];
 	char dist_str[40];
 	char flags[20];
 	char *p = flags;
+	char *n;
 
-	if (!show_slab)
+	if (skip_zero && !s->slabs)
 		return;
 
-	aliases = get_obj("aliases");
-	align = get_obj("align");
-	cache_dma = get_obj("cache_dma");
-	cpu_slabs = get_obj("cpu_slabs");
-	destroy_by_rcu = get_obj("destroy_by_rcu");
-	hwcache_align = get_obj("hwcache_align");
-	object_size = get_obj("object_size");
-	objects = get_obj("objects");
-	objs_per_slab = get_obj("objs_per_slab");
-	order = get_obj("order");
-	partial = get_obj("partial");
-	poison = get_obj("poison");
-	reclaim_account = get_obj("reclaim_account");
-	red_zone = get_obj("red_zone");
-	sanity_checks = get_obj("sanity_checks");
-	slab_size = get_obj("slab_size");
-	slabs = get_obj("slabs");
-	store_user = get_obj("store_user");
-	trace = get_obj("trace");
-
-	if (skip_zero && !slabs)
-		return;
-
-	store_size(size_str, slabs * page_size);
-	sprintf(dist_str,"%lu/%lu/%lu", slabs, partial, cpu_slabs);
+	store_size(size_str, slab_size(s));
+	sprintf(dist_str,"%lu/%lu/%d", s->slabs, s->partial, s->cpu_slabs);
 
 	if (!line++)
 		first_line();
 
-	if (aliases)
+	if (s->aliases)
 		*p++ = '*';
-	if (cache_dma)
+	if (s->cache_dma)
 		*p++ = 'd';
-	if (hwcache_align)
+	if (s->hwcache_align)
 		*p++ = 'A';
-	if (poison)
+	if (s->poison)
 		*p++ = 'P';
-	if (reclaim_account)
+	if (s->reclaim_account)
 		*p++ = 'a';
-	if (red_zone)
+	if (s->red_zone)
 		*p++ = 'Z';
-	if (sanity_checks)
+	if (s->sanity_checks)
 		*p++ = 'F';
-	if (store_user)
+	if (s->store_user)
 		*p++ = 'U';
-	if (trace)
+	if (s->trace)
 		*p++ = 'T';
 
 	*p = 0;
-	printf("%-20s %8ld %7ld %8s %14s %3ld %1ld %3ld %3ld %s\n",
-			name, objects, object_size, size_str, dist_str,
-			objs_per_slab, order,
-			slabs ? (partial * 100) / slabs : 100,
-			slabs ? (objects * object_size * 100) /
-				(slabs * (page_size << order)) : 100,
+	n = hackname(s);
+	printf("%-21s %8ld %7d %8s %14s %4d %1d %3ld %3ld %s\n",
+			n, s->objects, s->object_size, size_str, dist_str,
+			s->objs_per_slab, s->order,
+			s->slabs ? (s->partial * 100) / s->slabs : 100,
+			s->slabs ? (s->objects * s->object_size * 100) /
+				(s->slabs * (page_size << s->order)) : 100,
 			flags);
 }
 
-void slab_numa(const char *name)
+void slab_numa(struct slabinfo *s)
 {
-	unsigned long slabs;
-	char *numainfo;
+	char *n;
+	int node;
 
-	slabs = get_obj_and_str("slabs", &numainfo);
+	if (!highest_node)
+		fatal("No NUMA information available.\n");
 
-	if (skip_zero && !slabs)
+	if (skip_zero && !s->slabs)
 		return;
+	n = hackname(s);
 
-	printf("%-20s %s", name, numainfo);
-}
+	if (!line) {
+		printf("\nSlab             Node ");
+		for(node = 0; node <= highest_node; node++)
+			printf(" %4d", node);
+		printf("\n----------------------");
+		for(node = 0; node <= highest_node; node++)
+			printf("-----");
+		printf("\n");
+	}
+	printf("%-21s ", n);
+	for(node = 0; node <= highest_node; node++) {
+		char b[20];
 
-void parameter(const char *name)
-{
-	if (!show_parameters)
-		return;
+		store_size(b, s->numa[node]);
+		printf(" %4s", b);
+	}
+	printf("\n");
+	line++;
 }
 
-void show_tracking(const char *name)
+void show_tracking(struct slabinfo *s)
 {
-	printf("\n%s: Calls to allocate a slab object\n", name);
+	printf("\n%s: Calls to allocate a slab object\n", s->name);
 	printf("---------------------------------------------------\n");
 	if (read_obj("alloc_calls"))
 		printf(buffer);
 
-	printf("%s: Calls to free a slab object\n", name);
+	printf("%s: Calls to free a slab object\n", s->name);
 	printf("-----------------------------------------------\n");
 	if (read_obj("free_calls"))
 		printf(buffer);
 
 }
 
+void totals(void)
+{
+	struct slabinfo *s;
+
+	int used_slabs = 0;
+	char b1[20], b2[20], b3[20], b4[20];
+	unsigned long long min_objsize = 0, max_objsize = 0, avg_objsize;
+	unsigned long long min_partial = 0, max_partial = 0, avg_partial, total_partial = 0;
+	unsigned long long min_slabs = 0, max_slabs = 0, avg_slabs, total_slabs = 0;
+	unsigned long long min_size = 0, max_size = 0, avg_size, total_size = 0;
+	unsigned long long min_waste = 0, max_waste = 0, avg_waste, total_waste = 0;
+	unsigned long long min_objects = 0, max_objects = 0, avg_objects, total_objects = 0;
+	unsigned long long min_objwaste = 0, max_objwaste = 0, avg_objwaste;
+	unsigned long long min_used = 0, max_used = 0, avg_used, total_used = 0;
+	unsigned long min_ppart = 0, max_ppart = 0, avg_ppart, total_ppart = 0;
+	unsigned long min_partobj = 0, max_partobj = 0, avg_partobj;
+	unsigned long total_objects_in_partial = 0;
+
+	for (s = slabinfo; s < slabinfo + slabs; s++) {
+		unsigned long long size;
+		unsigned long partial;
+		unsigned long slabs;
+		unsigned long used;
+		unsigned long long wasted;
+		unsigned long long objwaste;
+		long long objects_in_partial;
+		unsigned long percentage_partial;
+
+		if (!s->slabs || !s->objects)
+			continue;
+
+		used_slabs++;
+
+		size = slab_size(s);
+		partial = s->partial << s->order;
+		slabs = s->slabs << s->order;
+		used = s->objects * s->object_size;
+		wasted = size - used;
+		objwaste = wasted / s->objects;
+
+		objects_in_partial = s->objects - (s->slabs - s->partial - s ->cpu_slabs)
+					* s->objs_per_slab;
+
+		if (objects_in_partial < 0)
+			objects_in_partial = 0;
+
+		percentage_partial = objects_in_partial * 100 / s->objects;
+		if (percentage_partial > 100)
+			percentage_partial = 100;
+
+		if (s->object_size < min_objsize || !min_objsize)
+			min_objsize = s->object_size;
+		if (partial && (partial < min_partial || !min_partial))
+			min_partial = partial;
+		if (slabs < min_slabs || !min_partial)
+			min_slabs = slabs;
+		if (size < min_size)
+			min_size = size;
+		if (wasted < min_waste && !min_waste)
+			min_waste = wasted;
+		if (objwaste < min_objwaste || !min_objwaste)
+			min_objwaste = objwaste;
+		if (s->objects < min_objects || !min_objects)
+			min_objects = s->objects;
+		if (used < min_used || !min_used)
+			min_used = used;
+		if (objects_in_partial < min_partobj || !min_partobj)
+			min_partobj = objects_in_partial;
+		if (percentage_partial < min_ppart || !min_ppart)
+			min_ppart = percentage_partial;
+
+		if (s->object_size > max_objsize)
+			max_objsize = s->object_size;
+		if (partial > max_partial)
+			max_partial = partial;
+		if (slabs > max_slabs)
+			max_slabs = slabs;
+		if (size > max_size)
+			max_size = size;
+		if (wasted > max_waste)
+			max_waste = wasted;
+		if (objwaste > max_objwaste)
+			max_objwaste = objwaste;
+		if (s->objects > max_objects)
+			max_objects = s->objects;
+		if (used > max_used)
+			max_used = used;
+		if (objects_in_partial > max_partobj)
+			max_partobj = objects_in_partial;
+		if (percentage_partial > max_ppart)
+			max_ppart = percentage_partial;
+
+		total_objects += s->objects;
+		total_partial += partial;
+		total_slabs += slabs;
+		total_used += used;
+		total_waste += wasted;
+		total_size += size;
+		total_ppart += percentage_partial;
+		total_objects_in_partial += objects_in_partial;
+	}
+
+	if (!total_objects) {
+		printf("No objects\n");
+		return;
+	}
+	if (!used_slabs) {
+		printf("No slabs\n");
+		return;
+	}
+	avg_partial = total_partial / used_slabs;
+	avg_slabs = total_slabs / used_slabs;
+	avg_waste = total_waste / used_slabs;
+	avg_size = total_waste / used_slabs;
+	avg_objects = total_objects / used_slabs;
+	avg_used = total_used / used_slabs;
+	avg_ppart = total_ppart / used_slabs;
+	avg_partobj = total_objects_in_partial / used_slabs;
+
+	avg_objsize = total_used / total_objects;
+	avg_objwaste = total_waste / total_objects;
+
+	printf("Slabcache Totals\n");
+	printf("----------------\n");
+	printf("Slabcaches : %3d      Aliases  : %3d      Active: %3d\n",
+			slabs, aliases, used_slabs);
+
+	store_size(b1, total_used);store_size(b2, total_waste);
+	store_size(b3, total_waste * 100 / total_used);
+	printf("Memory used: %6s   # Loss   : %6s   MRatio: %6s%%\n", b1, b2, b3);
+
+	store_size(b1, total_objects);store_size(b2, total_objects_in_partial);
+	store_size(b3, total_objects_in_partial * 100 / total_objects);
+	printf("# Objects  : %6s   # PartObj: %6s   ORatio: %6s%%\n", b1, b2, b3);
+
+	printf("\n");
+	printf("Per Cache    Average         Min         Max       Total\n");
+	printf("---------------------------------------------------------\n");
+
+	store_size(b1, avg_objects);store_size(b2, min_objects);
+	store_size(b3, max_objects);store_size(b4, total_objects);
+	printf("# Objects %10s  %10s  %10s  %10s\n",
+			b1,	b2,	b3,	b4);
+
+	store_size(b1, avg_slabs);store_size(b2, min_slabs);
+	store_size(b3, max_slabs);store_size(b4, total_slabs);
+	printf("# Slabs   %10s  %10s  %10s  %10s\n",
+			b1,	b2,	b3,	b4);
+
+	store_size(b1, avg_partial);store_size(b2, min_partial);
+	store_size(b3, max_partial);store_size(b4, total_partial);
+	printf("# Partial %10s  %10s  %10s  %10s\n",
+			b1,	b2,	b3,	b4);
+	store_size(b1, avg_ppart);store_size(b2, min_ppart);
+	store_size(b3, max_ppart);
+	printf("%% Partial %10s%% %10s%% %10s%%\n",
+			b1,	b2,	b3);
+
+	store_size(b1, avg_size);store_size(b2, min_size);
+	store_size(b3, max_size);store_size(b4, total_size);
+	printf("Memory    %10s  %10s  %10s  %10s\n",
+			b1,	b2,	b3,	b4);
+
+	store_size(b1, avg_used);store_size(b2, min_used);
+	store_size(b3, max_used);store_size(b4, total_used);
+	printf("Used      %10s  %10s  %10s  %10s\n",
+			b1,	b2,	b3,	b4);
+
+	store_size(b1, avg_slabs);store_size(b2, min_slabs);
+	store_size(b3, max_slabs);store_size(b4, total_slabs);
+	printf("Waste     %10s  %10s  %10s  %10s\n",
+			b1,	b2,	b3,	b4);
+
+	printf("\n");
+	printf("Per Object   Average         Min         Max\n");
+	printf("---------------------------------------------\n");
+
+	store_size(b1, avg_objsize);store_size(b2, min_objsize);
+	store_size(b3, max_objsize);
+	printf("Size      %10s  %10s  %10s\n",
+			b1,	b2,	b3);
+
+	store_size(b1, avg_objwaste);store_size(b2, min_objwaste);
+	store_size(b3, max_objwaste);
+	printf("Loss      %10s  %10s  %10s\n",
+			b1,	b2,	b3);
+}
+
+void sort_slabs(void)
+{
+	struct slabinfo *s1,*s2;
+
+	for (s1 = slabinfo; s1 < slabinfo + slabs; s1++) {
+		for (s2 = s1 + 1; s2 < slabinfo + slabs; s2++) {
+			int result;
+
+			if (sort_size)
+				result = slab_size(s1) < slab_size(s2);
+			else
+				result = strcasecmp(s1->name, s2->name);
+
+			if (show_inverted)
+				result = -result;
+
+			if (result > 0) {
+				struct slabinfo t;
+
+				memcpy(&t, s1, sizeof(struct slabinfo));
+				memcpy(s1, s2, sizeof(struct slabinfo));
+				memcpy(s2, &t, sizeof(struct slabinfo));
+			}
+		}
+	}
+}
+
+void sort_aliases(void)
+{
+	struct aliasinfo *a1,*a2;
+
+	for (a1 = aliasinfo; a1 < aliasinfo + aliases; a1++) {
+		for (a2 = a1 + 1; a2 < aliasinfo + aliases; a2++) {
+			char *n1, *n2;
+
+			n1 = a1->name;
+			n2 = a2->name;
+			if (show_alias && !show_inverted) {
+				n1 = a1->ref;
+				n2 = a2->ref;
+			}
+			if (strcasecmp(n1, n2) > 0) {
+				struct aliasinfo t;
+
+				memcpy(&t, a1, sizeof(struct aliasinfo));
+				memcpy(a1, a2, sizeof(struct aliasinfo));
+				memcpy(a2, &t, sizeof(struct aliasinfo));
+			}
+		}
+	}
+}
+
+void link_slabs(void)
+{
+	struct aliasinfo *a;
+	struct slabinfo *s;
+
+	for (a = aliasinfo; a < aliasinfo + aliases; a++) {
+
+		for(s = slabinfo; s < slabinfo + slabs; s++)
+			if (strcmp(a->ref, s->name) == 0) {
+				a->slab = s;
+				s->refs++;
+				break;
+			}
+		if (s == slabinfo + slabs)
+			fatal("Unresolved alias %s\n", a->ref);
+	}
+}
+
+void alias(void)
+{
+	struct aliasinfo *a;
+	char *active = NULL;
+
+	sort_aliases();
+	link_slabs();
+
+	for(a = aliasinfo; a < aliasinfo + aliases; a++) {
+
+		if (!show_single_ref && a->slab->refs == 1)
+			continue;
+
+		if (!show_inverted) {
+			if (active) {
+				if (strcmp(a->slab->name, active) == 0) {
+					printf(" %s", a->name);
+					continue;
+				}
+			}
+			printf("\n%-20s <- %s", a->slab->name, a->name);
+			active = a->slab->name;
+		}
+		else
+			printf("%-20s -> %s\n", a->name, a->slab->name);
+	}
+	if (active)
+		printf("\n");
+}
+
+
+void rename_slabs(void)
+{
+	struct slabinfo *s;
+	struct aliasinfo *a;
+
+	for (s = slabinfo; s < slabinfo + slabs; s++) {
+		if (*s->name != ':')
+			continue;
+
+		if (s->refs > 1 && !show_first_alias)
+			continue;
+
+		a = find_one_alias(s);
+
+		s->name = a->name;
+	}
+}
+
 int slab_mismatch(char *slab)
 {
 	return regexec(&pattern, slab, 0, NULL, 0);
 }
 
+void read_slab_dir(void)
+{
+	DIR *dir;
+	struct dirent *de;
+	struct slabinfo *slab = slabinfo;
+	struct aliasinfo *alias = aliasinfo;
+	char *p;
+	char *t;
+	int count;
+
+	dir = opendir(".");
+	while ((de = readdir(dir))) {
+		if (de->d_name[0] == '.' ||
+				slab_mismatch(de->d_name))
+			continue;
+		switch (de->d_type) {
+		   case DT_LNK:
+		   	alias->name = strdup(de->d_name);
+			count = readlink(de->d_name, buffer, sizeof(buffer));
+
+			if (count < 0)
+				fatal("Cannot read symlink %s\n", de->d_name);
+
+			buffer[count] = 0;
+			p = buffer + count;
+			while (p > buffer && p[-1] != '/')
+				p--;
+			alias->ref = strdup(p);
+			alias++;
+			break;
+		   case DT_DIR:
+			if (chdir(de->d_name))
+				fatal("Unable to access slab %s\n", slab->name);
+		   	slab->name = strdup(de->d_name);
+			slab->alias = 0;
+			slab->refs = 0;
+			slab->aliases = get_obj("aliases");
+			slab->align = get_obj("align");
+			slab->cache_dma = get_obj("cache_dma");
+			slab->cpu_slabs = get_obj("cpu_slabs");
+			slab->destroy_by_rcu = get_obj("destroy_by_rcu");
+			slab->hwcache_align = get_obj("hwcache_align");
+			slab->object_size = get_obj("object_size");
+			slab->objects = get_obj("objects");
+			slab->objs_per_slab = get_obj("objs_per_slab");
+			slab->order = get_obj("order");
+			slab->partial = get_obj("partial");
+			slab->partial = get_obj_and_str("partial", &t);
+			decode_numa_list(slab->numa_partial, t);
+			slab->poison = get_obj("poison");
+			slab->reclaim_account = get_obj("reclaim_account");
+			slab->red_zone = get_obj("red_zone");
+			slab->sanity_checks = get_obj("sanity_checks");
+			slab->slab_size = get_obj("slab_size");
+			slab->slabs = get_obj_and_str("slabs", &t);
+			decode_numa_list(slab->numa, t);
+			slab->store_user = get_obj("store_user");
+			slab->trace = get_obj("trace");
+			chdir("..");
+			slab++;
+			break;
+		   default :
+			fatal("Unknown file type %lx\n", de->d_type);
+		}
+	}
+	closedir(dir);
+	slabs = slab - slabinfo;
+	aliases = alias - aliasinfo;
+	if (slabs > MAX_SLABS)
+		fatal("Too many slabs\n");
+	if (aliases > MAX_ALIASES)
+		fatal("Too many aliases\n");
+}
+
+void output_slabs(void)
+{
+	struct slabinfo *slab;
+
+	for (slab = slabinfo; slab < slabinfo + slabs; slab++) {
+
+		if (slab->alias)
+			continue;
+
+
+		if (show_numa)
+			slab_numa(slab);
+		else
+		if (show_track)
+			show_tracking(slab);
+		else
+		if (validate)
+			slab_validate(slab);
+		else
+		if (shrink)
+			slab_shrink(slab);
+		else {
+			if (show_slab)
+				slabcache(slab);
+		}
+	}
+}
+
 struct option opts[] = {
 	{ "aliases", 0, NULL, 'a' },
 	{ "slabs", 0, NULL, 's' },
 	{ "numa", 0, NULL, 'n' },
-	{ "parameters", 0, NULL, 'p' },
 	{ "zero", 0, NULL, 'z' },
 	{ "help", 0, NULL, 'h' },
 	{ "validate", 0, NULL, 'v' },
+	{ "first-alias", 0, NULL, 'f' },
+	{ "reduce", 0, NULL, 'r' },
 	{ "track", 0, NULL, 't'},
+	{ "inverted", 0, NULL, 'i'},
+	{ "1ref", 0, NULL, '1'},
 	{ NULL, 0, NULL, 0 }
 };
 
 int main(int argc, char *argv[])
 {
-	DIR *dir;
-	struct dirent *de;
 	int c;
 	int err;
 	char *pattern_source;
@@ -312,22 +807,31 @@ int main(int argc, char *argv[])
 	if (chdir("/sys/slab"))
 		fatal("This kernel does not have SLUB support.\n");
 
-	while ((c = getopt_long(argc, argv, "ahtvnpsz", opts, NULL)) != -1)
+	while ((c = getopt_long(argc, argv, "afhi1nprstvzTS", opts, NULL)) != -1)
 	switch(c) {
-		case 's':
-			show_slab = 1;
+		case '1':
+			show_single_ref = 1;
 			break;
 		case 'a':
 			show_alias = 1;
 			break;
+		case 'f':
+			show_first_alias = 1;
+			break;
+		case 'h':
+			usage();
+			return 0;
+		case 'i':
+			show_inverted = 1;
+			break;
 		case 'n':
 			show_numa = 1;
 			break;
-		case 'p':
-			show_parameters = 1;
+		case 'r':
+			shrink = 1;
 			break;
-		case 'z':
-			skip_zero = 0;
+		case 's':
+			show_slab = 1;
 			break;
 		case 't':
 			show_track = 1;
@@ -335,17 +839,23 @@ int main(int argc, char *argv[])
 		case 'v':
 			validate = 1;
 			break;
-		case 'h':
-			usage();
-			return 0;
+		case 'z':
+			skip_zero = 0;
+			break;
+		case 'T':
+			show_totals = 1;
+			break;
+		case 'S':
+			sort_size = 1;
+			break;
 
 		default:
 			fatal("%s: Invalid option '%c'\n", argv[0], optopt);
 
 	}
 
-	if (!show_slab && !show_alias && !show_parameters && !show_track
-		&& !validate)
+	if (!show_slab && !show_alias && !show_track
+		&& !validate && !shrink)
 			show_slab = 1;
 
 	if (argc > optind)
@@ -357,39 +867,17 @@ int main(int argc, char *argv[])
 	if (err)
 		fatal("%s: Invalid pattern '%s' code %d\n",
 			argv[0], pattern_source, err);
-
-	dir = opendir(".");
-	while ((de = readdir(dir))) {
-		if (de->d_name[0] == '.' ||
-				slab_mismatch(de->d_name))
-			continue;
-		switch (de->d_type) {
-		   case DT_LNK:
-			alias(de->d_name);
-			break;
-		   case DT_DIR:
-			if (chdir(de->d_name))
-				fatal("Unable to access slab %s\n", de->d_name);
-
-		   	if (show_numa)
-				slab_numa(de->d_name);
-			else
-			if (show_track)
-				show_tracking(de->d_name);
-			else
-		   	if (validate)
-				slab_validate(de->d_name);
-			else
-				slab(de->d_name);
-			chdir("..");
-			break;
-		   case DT_REG:
-			parameter(de->d_name);
-			break;
-		   default :
-			fatal("Unknown file type %lx\n", de->d_type);
-		}
+	read_slab_dir();
+	if (show_alias)
+		alias();
+	else
+	if (show_totals)
+		totals();
+	else {
+		link_slabs();
+		rename_slabs();
+		sort_slabs();
+		output_slabs();
 	}
-	closedir(dir);
 	return 0;
 }

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
