Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8B1366B0392
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 16:24:50 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id n76so16916428ioe.1
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 13:24:50 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id t28si1694390ioe.54.2017.03.07.13.24.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 13:24:50 -0800 (PST)
Message-Id: <20170307212438.398832999@linux.com>
Date: Tue, 07 Mar 2017 15:24:35 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 6/6] slub: Extend slabinfo to support -D and -F options
References: <20170307212429.044249411@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=extend_slabinfo
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>

-F lists caches that support defragmentation

-C lists caches that use a ctor.

Change field names for defrag_ratio and remote_node_defrag_ratio.

Add determination of the allocation ratio for a slab. The allocation ratio
is the percentage of available slots for objects in use.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 Documentation/vm/slabinfo.c |   48 +++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 43 insertions(+), 5 deletions(-)

Index: linux/tools/vm/slabinfo.c
===================================================================
--- linux.orig/tools/vm/slabinfo.c
+++ linux/tools/vm/slabinfo.c
@@ -32,6 +32,8 @@ struct slabinfo {
 	int hwcache_align, object_size, objs_per_slab;
 	int sanity_checks, slab_size, store_user, trace;
 	int order, poison, reclaim_account, red_zone;
+	int defrag, ctor;
+	int defrag_ratio, remote_node_defrag_ratio;
 	unsigned long partial, objects, slabs, objects_partial, objects_total;
 	unsigned long alloc_fastpath, alloc_slowpath;
 	unsigned long free_fastpath, free_slowpath;
@@ -66,6 +68,8 @@ int show_report;
 int show_alias;
 int show_slab;
 int skip_zero = 1;
+int show_defrag;
+int show_ctor;
 int show_numa;
 int show_track;
 int show_first_alias;
@@ -107,14 +111,16 @@ static void fatal(const char *x, ...)
 
 static void usage(void)
 {
-	printf("slabinfo 4/15/2011. (c) 2007 sgi/(c) 2011 Linux Foundation.\n\n"
-		"slabinfo [-ahnpvtsz] [-d debugopts] [slab-regexp]\n"
+	printf("slabinfo 4/15/2017. (c) 2007 sgi/(c) 2011 Linux Foundation/(c) 2017 Jump Trading LLC.\n\n"
+		"slabinfo [-aCdDefFhnpvtsz] [-d debugopts] [slab-regexp]\n"
 		"-a|--aliases           Show aliases\n"
 		"-A|--activity          Most active slabs first\n"
 		"-d<options>|--debug=<options> Set/Clear Debug options\n"
+		"-C|--ctor              Show slabs with ctors\n"
 		"-D|--display-active    Switch line format to activity\n"
 		"-e|--empty             Show empty slabs\n"
 		"-f|--first-alias       Show first alias\n"
+		"-F|--defrag            Show defragmentable caches\n"
 		"-h|--help              Show usage information\n"
 		"-i|--inverted          Inverted list\n"
 		"-l|--slabs             Show slabs\n"
@@ -366,7 +372,7 @@ static void slab_numa(struct slabinfo *s
 		return;
 
 	if (!line) {
-		printf("\n%-21s:", mode ? "NUMA nodes" : "Slab");
+		printf("\n%-21s: Rto ", mode ? "NUMA nodes" : "Slab");
 		for(node = 0; node <= highest_node; node++)
 			printf(" %4d", node);
 		printf("\n----------------------");
@@ -375,6 +381,7 @@ static void slab_numa(struct slabinfo *s
 		printf("\n");
 	}
 	printf("%-21s ", mode ? "All slabs" : s->name);
+	printf("%3d ", s->remote_node_defrag_ratio);
 	for(node = 0; node <= highest_node; node++) {
 		char b[20];
 
@@ -532,6 +539,8 @@ static void report(struct slabinfo *s)
 		printf("** Slabs are destroyed via RCU\n");
 	if (s->reclaim_account)
 		printf("** Reclaim accounting active\n");
+	if (s->defrag)
+		printf("** Defragmentation at %d%%\n", s->defrag_ratio);
 
 	printf("\nSizes (bytes)     Slabs              Debug                Memory\n");
 	printf("------------------------------------------------------------------------\n");
@@ -579,6 +588,12 @@ static void slabcache(struct slabinfo *s
 	if (show_empty && s->slabs)
 		return;
 
+	if (show_defrag && !s->defrag)
+		return;
+
+	if (show_ctor && !s->ctor)
+		return;
+
 	if (sort_loss == 0)
 		store_size(size_str, slab_size(s));
 	else
@@ -593,6 +608,10 @@ static void slabcache(struct slabinfo *s
 		*p++ = '*';
 	if (s->cache_dma)
 		*p++ = 'd';
+	if (s->defrag)
+		*p++ = 'F';
+	if (s->ctor)
+		*p++ = 'C';
 	if (s->hwcache_align)
 		*p++ = 'A';
 	if (s->poison)
@@ -627,7 +646,8 @@ static void slabcache(struct slabinfo *s
 		printf("%-21s %8ld %7d %15s %14s %4d %1d %3ld %3ld %s\n",
 			s->name, s->objects, s->object_size, size_str, dist_str,
 			s->objs_per_slab, s->order,
-			s->slabs ? (s->partial * 100) / s->slabs : 100,
+			s->slabs ? (s->partial * 100) /
+					(s->slabs * s->objs_per_slab) : 100,
 			s->slabs ? (s->objects * s->object_size * 100) /
 				(s->slabs * (page_size << s->order)) : 100,
 			flags);
@@ -1246,7 +1266,17 @@ static void read_slab_dir(void)
 			slab->cpu_partial_free = get_obj("cpu_partial_free");
 			slab->alloc_node_mismatch = get_obj("alloc_node_mismatch");
 			slab->deactivate_bypass = get_obj("deactivate_bypass");
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
+
 			if (slab->name[0] == ':')
 				alias_targets++;
 			slab++;
@@ -1323,6 +1353,8 @@ static void xtotals(void)
 }
 
 struct option opts[] = {
+	{ "ctor", no_argument, NULL, 'C' },
+	{ "defrag", no_argument, NULL, 'F' },
 	{ "aliases", no_argument, NULL, 'a' },
 	{ "activity", no_argument, NULL, 'A' },
 	{ "debug", optional_argument, NULL, 'd' },
@@ -1357,7 +1389,7 @@ int main(int argc, char *argv[])
 
 	page_size = getpagesize();
 
-	while ((c = getopt_long(argc, argv, "aAd::Defhil1noprstvzTSN:LXB",
+	while ((c = getopt_long(argc, argv, "aACd::DefFhil1noprstvzTSN:LXB",
 						opts, NULL)) != -1)
 		switch (c) {
 		case '1':
@@ -1413,6 +1445,12 @@ int main(int argc, char *argv[])
 		case 'z':
 			skip_zero = 0;
 			break;
+		case 'C':
+			show_ctor = 1;
+			break;
+		case 'F':
+			show_defrag = 1;
+			break;
 		case 'T':
 			show_totals = 1;
 			break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
