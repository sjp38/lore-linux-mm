From: clameter@sgi.com
Subject: [patch 03/12] SLUB: Extend slabinfo to support -D and -C options
Date: Thu, 07 Jun 2007 14:55:32 -0700
Message-ID: <20070607215908.732209293@sgi.com>
References: <20070607215529.147027769@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S966231AbXFGWA3@vger.kernel.org>
Content-Disposition: inline; filename=slab_defrag_slabinfo_updates
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Michal Piotrowski <michal.k.k.piotrowski@gmail.com>, Mel Gorman <mel@skynet.ie>
List-Id: linux-mm.kvack.org

-D lists caches that support defragmentation

-C lists caches that use a ctor.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 Documentation/vm/slabinfo.c |   39 ++++++++++++++++++++++++++++++++++-----
 1 file changed, 34 insertions(+), 5 deletions(-)

Index: slub/Documentation/vm/slabinfo.c
===================================================================
--- slub.orig/Documentation/vm/slabinfo.c	2007-06-07 14:09:37.000000000 -0700
+++ slub/Documentation/vm/slabinfo.c	2007-06-07 14:12:27.000000000 -0700
@@ -30,6 +30,7 @@ struct slabinfo {
 	int hwcache_align, object_size, objs_per_slab;
 	int sanity_checks, slab_size, store_user, trace;
 	int order, poison, reclaim_account, red_zone;
+	int defrag, ctor;
 	unsigned long partial, objects, slabs;
 	int numa[MAX_NODES];
 	int numa_partial[MAX_NODES];
@@ -56,6 +57,8 @@ int show_slab = 0;
 int skip_zero = 1;
 int show_numa = 0;
 int show_track = 0;
+int show_defrag = 0;
+int show_ctor = 0;
 int show_first_alias = 0;
 int validate = 0;
 int shrink = 0;
@@ -90,18 +93,20 @@ void fatal(const char *x, ...)
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
@@ -452,6 +457,12 @@ void slabcache(struct slabinfo *s)
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
 
@@ -462,6 +473,10 @@ void slabcache(struct slabinfo *s)
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
@@ -1072,6 +1087,12 @@ void read_slab_dir(void)
 			slab->store_user = get_obj("store_user");
 			slab->trace = get_obj("trace");
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
@@ -1121,7 +1142,9 @@ void output_slabs(void)
 
 struct option opts[] = {
 	{ "aliases", 0, NULL, 'a' },
+	{ "ctor", 0, NULL, 'C' },
 	{ "debug", 2, NULL, 'd' },
+	{ "defrag", 0, NULL, 'D' },
 	{ "empty", 0, NULL, 'e' },
 	{ "first-alias", 0, NULL, 'f' },
 	{ "help", 0, NULL, 'h' },
@@ -1146,7 +1169,7 @@ int main(int argc, char *argv[])
 
 	page_size = getpagesize();
 
-	while ((c = getopt_long(argc, argv, "ad::efhil1noprstvzTS",
+	while ((c = getopt_long(argc, argv, "ad::efhil1noprstvzCDTS",
 						opts, NULL)) != -1)
 	switch(c) {
 		case '1':
@@ -1196,6 +1219,12 @@ int main(int argc, char *argv[])
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
