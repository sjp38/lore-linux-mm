Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 820C56B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 12:21:59 -0400 (EDT)
Date: Wed, 6 Oct 2010 11:21:53 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: [UnifiedV4 slabinfo 2/2] slub: update slabinfo.c for queuing
In-Reply-To: <1286379979.1897.0.camel@castor.rsk>
Message-ID: <alpine.DEB.2.00.1010061121200.31538@router.home>
References: <20101005185725.088808842@linux.com>  <AANLkTinPU4T59PvDH1wX2Rcy7beL=TvmHOZh_wWuBU-T@mail.gmail.com>  <4CAC577F.9040401@rsk.demon.co.uk>  <AANLkTikr9B5Yb+Owe3t+Rb8KBO33DE=9YBQZ_1+Gwcu8@mail.gmail.com> <1286379979.1897.0.camel@castor.rsk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, npiggin@kernel.dk, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

Modify the slabinfo tool to report the queueing statistics

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 tools/slub/slabinfo.c |  120 +++++++++++++++++++++++---------------------------
 1 file changed, 57 insertions(+), 63 deletions(-)

Index: linux-2.6/tools/slub/slabinfo.c
===================================================================
--- linux-2.6.orig/tools/slub/slabinfo.c	2010-10-05 16:26:48.000000000 -0500
+++ linux-2.6/tools/slub/slabinfo.c	2010-10-06 11:17:40.000000000 -0500
@@ -27,18 +27,19 @@ struct slabinfo {
 	char *name;
 	int alias;
 	int refs;
-	int aliases, align, cache_dma, cpu_slabs, destroy_by_rcu;
+	int aliases, align, cache_dma, destroy_by_rcu;
 	int hwcache_align, object_size, objs_per_slab;
 	int sanity_checks, slab_size, store_user, trace;
 	int order, poison, reclaim_account, red_zone;
 	unsigned long partial, objects, slabs, objects_partial, objects_total;
-	unsigned long alloc_fastpath, alloc_slowpath;
-	unsigned long free_fastpath, free_slowpath;
-	unsigned long free_frozen, free_add_partial, free_remove_partial;
-	unsigned long alloc_from_partial, alloc_slab, free_slab, alloc_refill;
-	unsigned long cpuslab_flush, deactivate_full, deactivate_empty;
-	unsigned long deactivate_to_head, deactivate_to_tail;
-	unsigned long deactivate_remote_frees, order_fallback;
+	unsigned long alloc_fastpath, alloc_shared, alloc_alien, alloc_alien_slow;
+	unsigned long alloc_direct, alloc_slowpath;
+	unsigned long free_fastpath, free_shared, free_alien, free_alien_slow;
+	unsigned long free_direct, free_slowpath;
+	unsigned long free_add_partial, free_remove_partial;
+	unsigned long alloc_from_partial, alloc_remove_partial, alloc_free_partial;
+	unsigned long alloc_slab, free_slab;
+	unsigned long order_fallback, queue_flush;
 	int numa[MAX_NODES];
 	int numa_partial[MAX_NODES];
 } slabinfo[MAX_SLABS];
@@ -99,7 +100,7 @@ static void fatal(const char *x, ...)

 static void usage(void)
 {
-	printf("slabinfo 5/7/2007. (c) 2007 sgi.\n\n"
+	printf("slabinfo 10/10/2010. (c) 2010 sgi/linux foundation.\n\n"
 		"slabinfo [-ahnpvtsz] [-d debugopts] [slab-regexp]\n"
 		"-a|--aliases           Show aliases\n"
 		"-A|--activity          Most active slabs first\n"
@@ -376,20 +377,17 @@ static void slab_numa(struct slabinfo *s

 static void show_tracking(struct slabinfo *s)
 {
-	printf("\n%s: Kernel object allocation\n", s->name);
-	printf("-----------------------------------------------------------------------\n");
-	if (read_slab_obj(s, "alloc_calls"))
-		printf(buffer);
-	else
-		printf("No Data\n");
-
-	printf("\n%s: Kernel object freeing\n", s->name);
-	printf("------------------------------------------------------------------------\n");
-	if (read_slab_obj(s, "free_calls"))
-		printf(buffer);
-	else
-		printf("No Data\n");
+	if (read_slab_obj(s, "alloc_calls")) {
+		printf("\n%s: Kernel object allocation\n", s->name);
+		printf("-----------------------------------------------------------------------\n");
+		printf("%s", buffer);
+	}

+	if (read_slab_obj(s, "free_calls")) {
+		printf("\n%s: Kernel object freeing\n", s->name);
+		printf("------------------------------------------------------------------------\n");
+		printf("%s", buffer);
+	}
 }

 static void ops(struct slabinfo *s)
@@ -400,7 +398,7 @@ static void ops(struct slabinfo *s)
 	if (read_slab_obj(s, "ops")) {
 		printf("\n%s: kmem_cache operations\n", s->name);
 		printf("--------------------------------------------\n");
-		printf(buffer);
+		printf("%s", buffer);
 	} else
 		printf("\n%s has no kmem_cache operations\n", s->name);
 }
@@ -421,8 +419,10 @@ static void slab_stats(struct slabinfo *
 	if (!s->alloc_slab)
 		return;

-	total_alloc = s->alloc_fastpath + s->alloc_slowpath;
-	total_free = s->free_fastpath + s->free_slowpath;
+	total_alloc = s->alloc_fastpath + s->alloc_shared + s->alloc_alien
+			+ s->alloc_alien_slow + s->alloc_slowpath + s->alloc_direct;
+	total_free = s->free_fastpath + s->free_shared + s->free_alien
+			+ s->free_alien_slow + s->free_slowpath + s->free_direct;

 	if (!total_alloc)
 		return;
@@ -434,47 +434,44 @@ static void slab_stats(struct slabinfo *
 		s->alloc_fastpath, s->free_fastpath,
 		s->alloc_fastpath * 100 / total_alloc,
 		s->free_fastpath * 100 / total_free);
+	printf("Shared Cache         %8lu %8lu %3lu %3lu\n",
+		s->alloc_shared, s->free_shared,
+		s->alloc_shared * 100 / total_alloc,
+		s->free_shared * 100 / total_free);
+	printf("Alien Cache          %8lu %8lu %3lu %3lu\n",
+		s->alloc_alien, s->free_alien,
+		s->alloc_alien * 100 / total_alloc,
+		s->free_alien * 100 / total_free);
 	printf("Slowpath             %8lu %8lu %3lu %3lu\n",
 		total_alloc - s->alloc_fastpath, s->free_slowpath,
 		(total_alloc - s->alloc_fastpath) * 100 / total_alloc,
 		s->free_slowpath * 100 / total_free);
+	printf("Alien Cache Slow     %8lu %8lu %3lu %3lu\n",
+		s->alloc_alien_slow, s->free_alien_slow,
+		s->alloc_alien_slow * 100 / total_alloc,
+		s->free_alien_slow * 100 / total_free);
+	printf("Direct               %8lu %8lu %3lu %3lu\n",
+		s->alloc_direct, s->free_direct,
+		s->alloc_direct * 100 / total_alloc,
+		s->free_direct * 100 / total_free);
 	printf("Page Alloc           %8lu %8lu %3lu %3lu\n",
 		s->alloc_slab, s->free_slab,
 		s->alloc_slab * 100 / total_alloc,
 		s->free_slab * 100 / total_free);
 	printf("Add partial          %8lu %8lu %3lu %3lu\n",
-		s->deactivate_to_head + s->deactivate_to_tail,
+		s->alloc_free_partial,
 		s->free_add_partial,
-		(s->deactivate_to_head + s->deactivate_to_tail) * 100 / total_alloc,
+		s->alloc_free_partial * 100 / total_alloc,
 		s->free_add_partial * 100 / total_free);
 	printf("Remove partial       %8lu %8lu %3lu %3lu\n",
 		s->alloc_from_partial, s->free_remove_partial,
 		s->alloc_from_partial * 100 / total_alloc,
 		s->free_remove_partial * 100 / total_free);

-	printf("RemoteObj/SlabFrozen %8lu %8lu %3lu %3lu\n",
-		s->deactivate_remote_frees, s->free_frozen,
-		s->deactivate_remote_frees * 100 / total_alloc,
-		s->free_frozen * 100 / total_free);
-
 	printf("Total                %8lu %8lu\n\n", total_alloc, total_free);

-	if (s->cpuslab_flush)
-		printf("Flushes %8lu\n", s->cpuslab_flush);
-
-	if (s->alloc_refill)
-		printf("Refill %8lu\n", s->alloc_refill);
-
-	total = s->deactivate_full + s->deactivate_empty +
-			s->deactivate_to_head + s->deactivate_to_tail;
-
-	if (total)
-		printf("Deactivate Full=%lu(%lu%%) Empty=%lu(%lu%%) "
-			"ToHead=%lu(%lu%%) ToTail=%lu(%lu%%)\n",
-			s->deactivate_full, (s->deactivate_full * 100) / total,
-			s->deactivate_empty, (s->deactivate_empty * 100) / total,
-			s->deactivate_to_head, (s->deactivate_to_head * 100) / total,
-			s->deactivate_to_tail, (s->deactivate_to_tail * 100) / total);
+	if (s->queue_flush)
+		printf("Flushes %8lu\n", s->queue_flush);
 }

 static void report(struct slabinfo *s)
@@ -499,13 +496,13 @@ static void report(struct slabinfo *s)
 			s->object_size, s->slabs, onoff(s->sanity_checks),
 			s->slabs * (page_size << s->order));
 	printf("SlabObj: %7d  Full   : %7ld   Redzoning     : %s  Used : %7ld\n",
-			s->slab_size, s->slabs - s->partial - s->cpu_slabs,
+			s->slab_size, s->slabs - s->partial,
 			onoff(s->red_zone), s->objects * s->object_size);
 	printf("SlabSiz: %7d  Partial: %7ld   Poisoning     : %s  Loss : %7ld\n",
 			page_size << s->order, s->partial, onoff(s->poison),
 			s->slabs * (page_size << s->order) - s->objects * s->object_size);
-	printf("Loss   : %7d  CpuSlab: %7d   Tracking      : %s  Lalig: %7ld\n",
-			s->slab_size - s->object_size, s->cpu_slabs, onoff(s->store_user),
+	printf("Loss   : %7d                     Tracking      : %s  Lalig: %7ld\n",
+			s->slab_size - s->object_size, onoff(s->store_user),
 			(s->slab_size - s->object_size) * s->objects);
 	printf("Align  : %7d  Objects: %7d   Tracing       : %s  Lpadd: %7ld\n",
 			s->align, s->objs_per_slab, onoff(s->trace),
@@ -540,8 +537,7 @@ static void slabcache(struct slabinfo *s
 		return;

 	store_size(size_str, slab_size(s));
-	snprintf(dist_str, 40, "%lu/%lu/%d", s->slabs - s->cpu_slabs,
-						s->partial, s->cpu_slabs);
+	snprintf(dist_str, 40, "%lu/%lu", s->slabs, s->partial);

 	if (!line++)
 		first_line();
@@ -1149,7 +1145,6 @@ static void read_slab_dir(void)
 			slab->aliases = get_obj("aliases");
 			slab->align = get_obj("align");
 			slab->cache_dma = get_obj("cache_dma");
-			slab->cpu_slabs = get_obj("cpu_slabs");
 			slab->destroy_by_rcu = get_obj("destroy_by_rcu");
 			slab->hwcache_align = get_obj("hwcache_align");
 			slab->object_size = get_obj("object_size");
@@ -1173,22 +1168,22 @@ static void read_slab_dir(void)
 			slab->store_user = get_obj("store_user");
 			slab->trace = get_obj("trace");
 			slab->alloc_fastpath = get_obj("alloc_fastpath");
+			slab->alloc_shared = get_obj("alloc_shared");
+			slab->alloc_alien = get_obj("alloc_alien");
+			slab->alloc_alien_slow = get_obj("alloc_alien_slow");
 			slab->alloc_slowpath = get_obj("alloc_slowpath");
+			slab->alloc_direct = get_obj("alloc_direct");
 			slab->free_fastpath = get_obj("free_fastpath");
+			slab->free_shared = get_obj("free_shared");
+			slab->free_alien = get_obj("free_alien");
+			slab->free_alien_slow = get_obj("free_alien_slow");
 			slab->free_slowpath = get_obj("free_slowpath");
-			slab->free_frozen= get_obj("free_frozen");
+			slab->free_direct = get_obj("free_direct");
 			slab->free_add_partial = get_obj("free_add_partial");
 			slab->free_remove_partial = get_obj("free_remove_partial");
 			slab->alloc_from_partial = get_obj("alloc_from_partial");
 			slab->alloc_slab = get_obj("alloc_slab");
-			slab->alloc_refill = get_obj("alloc_refill");
 			slab->free_slab = get_obj("free_slab");
-			slab->cpuslab_flush = get_obj("cpuslab_flush");
-			slab->deactivate_full = get_obj("deactivate_full");
-			slab->deactivate_empty = get_obj("deactivate_empty");
-			slab->deactivate_to_head = get_obj("deactivate_to_head");
-			slab->deactivate_to_tail = get_obj("deactivate_to_tail");
-			slab->deactivate_remote_frees = get_obj("deactivate_remote_frees");
 			slab->order_fallback = get_obj("order_fallback");
 			chdir("..");
 			if (slab->name[0] == ':')
@@ -1218,7 +1213,6 @@ static void output_slabs(void)
 		if (slab->alias)
 			continue;

-
 		if (show_numa)
 			slab_numa(slab, 0);
 		else if (show_track)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
