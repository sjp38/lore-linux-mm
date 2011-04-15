Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4F01E900098
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 16:13:10 -0400 (EDT)
Message-Id: <20110415201307.120925812@linux.com>
Date: Fri, 15 Apr 2011 15:13:07 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv333num@/21] slub: update statistics for cmpxchg handling
References: <20110415201246.096634892@linux.com>
Content-Disposition: inline; filename=statfixes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, linux-mm@kvack.org

Update the statistics handling and the slabinfo tool to include the new
statistics in the reports it generates.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 include/linux/slub_def.h |    2 +
 mm/slub.c                |   15 +++++++++---
 tools/slub/slabinfo.c    |   57 ++++++++++++++++++++++++++++++++---------------
 3 files changed, 52 insertions(+), 22 deletions(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2011-04-15 14:29:00.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2011-04-15 14:30:23.000000000 -0500
@@ -24,6 +24,7 @@ enum stat_item {
 	ALLOC_FROM_PARTIAL,	/* Cpu slab acquired from partial list */
 	ALLOC_SLAB,		/* Cpu slab acquired from page allocator */
 	ALLOC_REFILL,		/* Refill cpu slab from slab freelist */
+	ALLOC_NODE_MISMATCH,	/* Switching cpu slab */
 	FREE_SLAB,		/* Slab freed to the page allocator */
 	CPUSLAB_FLUSH,		/* Abandoning of the cpu slab */
 	DEACTIVATE_FULL,	/* Cpu slab was full when deactivated */
@@ -31,6 +32,7 @@ enum stat_item {
 	DEACTIVATE_TO_HEAD,	/* Cpu slab was moved to the head of partials */
 	DEACTIVATE_TO_TAIL,	/* Cpu slab was moved to the tail of partials */
 	DEACTIVATE_REMOTE_FREES,/* Slab contained remotely freed objects */
+	DEACTIVATE_BYPASS,	/* Implicit deactivation */
 	ORDER_FALLBACK,		/* Number of times fallback was necessary */
 	CMPXCHG_DOUBLE_CPU_FAIL,/* Failure of this_cpu_cmpxchg_double */
 	CMPXCHG_DOUBLE_FAIL,	/* Number of times that cmpxchg double did not match */
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-04-15 14:30:16.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-04-15 14:30:23.000000000 -0500
@@ -1782,6 +1782,7 @@ redo:
 		spin_unlock(&n->list_lock);
 
 	if (m == M_FREE) {
+		stat(s, DEACTIVATE_EMPTY);
 		discard_slab(s, page);
 		stat(s, FREE_SLAB);
 	}
@@ -1939,12 +1940,12 @@ static void *__slab_alloc(struct kmem_ca
 		goto new_slab;
 
 	if (unlikely(!node_match(c, node))) {
+		stat(s, ALLOC_NODE_MISMATCH);
 		deactivate_slab(s, c);
 		goto new_slab;
 	}
 
-	stat(s, ALLOC_REFILL);
-
+	stat(s, ALLOC_SLOWPATH);
 	{
 		struct page new;
 		unsigned long counters;
@@ -1976,9 +1977,12 @@ static void *__slab_alloc(struct kmem_ca
 
 	if (unlikely(!object)) {
 		c->page = NULL;
+		stat(s, DEACTIVATE_BYPASS);
 		goto new_slab;
 	}
 
+	stat(s, ALLOC_REFILL);
+
 load_freelist:
 	VM_BUG_ON(!page->frozen);
 	c->freelist = get_freepointer(s, object);
@@ -1987,7 +1991,6 @@ load_freelist:
 	c->tid = next_tid(c->tid);
 	local_irq_restore(flags);
 #endif
-	stat(s, ALLOC_SLOWPATH);
 	return object;
 
 new_slab:
@@ -4737,6 +4740,7 @@ STAT_ATTR(FREE_REMOVE_PARTIAL, free_remo
 STAT_ATTR(ALLOC_FROM_PARTIAL, alloc_from_partial);
 STAT_ATTR(ALLOC_SLAB, alloc_slab);
 STAT_ATTR(ALLOC_REFILL, alloc_refill);
+STAT_ATTR(ALLOC_NODE_MISMATCH, alloc_node_mismatch);
 STAT_ATTR(FREE_SLAB, free_slab);
 STAT_ATTR(CPUSLAB_FLUSH, cpuslab_flush);
 STAT_ATTR(DEACTIVATE_FULL, deactivate_full);
@@ -4744,6 +4748,7 @@ STAT_ATTR(DEACTIVATE_EMPTY, deactivate_e
 STAT_ATTR(DEACTIVATE_TO_HEAD, deactivate_to_head);
 STAT_ATTR(DEACTIVATE_TO_TAIL, deactivate_to_tail);
 STAT_ATTR(DEACTIVATE_REMOTE_FREES, deactivate_remote_frees);
+STAT_ATTR(DEACTIVATE_BYPASS, deactivate_bypass);
 STAT_ATTR(ORDER_FALLBACK, order_fallback);
 STAT_ATTR(CMPXCHG_DOUBLE_CPU_FAIL, cmpxchg_double_cpu_fail);
 STAT_ATTR(CMPXCHG_DOUBLE_FAIL, cmpxchg_double_fail);
@@ -4796,6 +4801,7 @@ static struct attribute *slab_attrs[] =
 	&alloc_from_partial_attr.attr,
 	&alloc_slab_attr.attr,
 	&alloc_refill_attr.attr,
+	&alloc_node_mismatch_attr.attr,
 	&free_slab_attr.attr,
 	&cpuslab_flush_attr.attr,
 	&deactivate_full_attr.attr,
@@ -4803,6 +4809,7 @@ static struct attribute *slab_attrs[] =
 	&deactivate_to_head_attr.attr,
 	&deactivate_to_tail_attr.attr,
 	&deactivate_remote_frees_attr.attr,
+	&deactivate_bypass_attr.attr,
 	&order_fallback_attr.attr,
 	&cmpxchg_double_fail_attr.attr,
 	&cmpxchg_double_cpu_fail_attr.attr,
Index: linux-2.6/tools/slub/slabinfo.c
===================================================================
--- linux-2.6.orig/tools/slub/slabinfo.c	2011-04-15 14:27:16.000000000 -0500
+++ linux-2.6/tools/slub/slabinfo.c	2011-04-15 14:30:23.000000000 -0500
@@ -2,8 +2,9 @@
  * Slabinfo: Tool to get reports about slabs
  *
  * (C) 2007 sgi, Christoph Lameter
+ * (C) 2011 Linux Foundation, Christoph Lameter
  *
- * Compile by:
+ * Compile with:
  *
  * gcc -o slabinfo slabinfo.c
  */
@@ -39,6 +40,8 @@ struct slabinfo {
 	unsigned long cpuslab_flush, deactivate_full, deactivate_empty;
 	unsigned long deactivate_to_head, deactivate_to_tail;
 	unsigned long deactivate_remote_frees, order_fallback;
+	unsigned long cmpxchg_double_cpu_fail, cmpxchg_double_fail;
+	unsigned long alloc_node_mismatch, deactivate_bypass;
 	int numa[MAX_NODES];
 	int numa_partial[MAX_NODES];
 } slabinfo[MAX_SLABS];
@@ -99,7 +102,7 @@ static void fatal(const char *x, ...)
 
 static void usage(void)
 {
-	printf("slabinfo 5/7/2007. (c) 2007 sgi.\n\n"
+	printf("slabinfo 4/15/2011. (c) 2007 sgi/(c) 2011 Linux Foundation.\n\n"
 		"slabinfo [-ahnpvtsz] [-d debugopts] [slab-regexp]\n"
 		"-a|--aliases           Show aliases\n"
 		"-A|--activity          Most active slabs first\n"
@@ -293,7 +296,7 @@ int line = 0;
 static void first_line(void)
 {
 	if (show_activity)
-		printf("Name                   Objects      Alloc       Free   %%Fast Fallb O\n");
+		printf("Name                   Objects      Alloc       Free   %%Fast Fallb O CmpX   UL\n");
 	else
 		printf("Name                   Objects Objsize    Space "
 			"Slabs/Part/Cpu  O/S O %%Fr %%Ef Flg\n");
@@ -379,14 +382,14 @@ static void show_tracking(struct slabinf
 	printf("\n%s: Kernel object allocation\n", s->name);
 	printf("-----------------------------------------------------------------------\n");
 	if (read_slab_obj(s, "alloc_calls"))
-		printf(buffer);
+		printf("%s", buffer);
 	else
 		printf("No Data\n");
 
 	printf("\n%s: Kernel object freeing\n", s->name);
 	printf("------------------------------------------------------------------------\n");
 	if (read_slab_obj(s, "free_calls"))
-		printf(buffer);
+		printf("%s", buffer);
 	else
 		printf("No Data\n");
 
@@ -400,7 +403,7 @@ static void ops(struct slabinfo *s)
 	if (read_slab_obj(s, "ops")) {
 		printf("\n%s: kmem_cache operations\n", s->name);
 		printf("--------------------------------------------\n");
-		printf(buffer);
+		printf("%s", buffer);
 	} else
 		printf("\n%s has no kmem_cache operations\n", s->name);
 }
@@ -462,19 +465,32 @@ static void slab_stats(struct slabinfo *
 	if (s->cpuslab_flush)
 		printf("Flushes %8lu\n", s->cpuslab_flush);
 
-	if (s->alloc_refill)
-		printf("Refill %8lu\n", s->alloc_refill);
-
 	total = s->deactivate_full + s->deactivate_empty +
-			s->deactivate_to_head + s->deactivate_to_tail;
+			s->deactivate_to_head + s->deactivate_to_tail + s->deactivate_bypass;
 
-	if (total)
-		printf("Deactivate Full=%lu(%lu%%) Empty=%lu(%lu%%) "
-			"ToHead=%lu(%lu%%) ToTail=%lu(%lu%%)\n",
-			s->deactivate_full, (s->deactivate_full * 100) / total,
-			s->deactivate_empty, (s->deactivate_empty * 100) / total,
-			s->deactivate_to_head, (s->deactivate_to_head * 100) / total,
+	if (total) {
+		printf("\nSlab Deactivation             Ocurrences  %%\n");
+		printf("-------------------------------------------------\n");
+		printf("Slab full                     %7lu  %3lu%%\n",
+			s->deactivate_full, (s->deactivate_full * 100) / total);
+		printf("Slab empty                    %7lu  %3lu%%\n",
+			s->deactivate_empty, (s->deactivate_empty * 100) / total);
+		printf("Moved to head of partial list %7lu  %3lu%%\n",
+			s->deactivate_to_head, (s->deactivate_to_head * 100) / total);
+		printf("Moved to tail of partial list %7lu  %3lu%%\n",
 			s->deactivate_to_tail, (s->deactivate_to_tail * 100) / total);
+		printf("Deactivation bypass           %7lu  %3lu%%\n",
+			s->deactivate_bypass, (s->deactivate_bypass * 100) / total);
+		printf("Refilled from foreign frees   %7lu  %3lu%%\n",
+			s->alloc_refill, (s->alloc_refill * 100) / total);
+		printf("Node mismatch                 %7lu  %3lu%%\n",
+			s->alloc_node_mismatch, (s->alloc_node_mismatch * 100) / total);
+	}
+
+	if (s->cmpxchg_double_fail || s->cmpxchg_double_cpu_fail)
+		printf("\nCmpxchg_double Looping\n------------------------\n");
+		printf("Locked Cmpxchg Double redos   %lu\nUnlocked Cmpxchg Double redos %lu\n",
+			s->cmpxchg_double_fail, s->cmpxchg_double_cpu_fail);
 }
 
 static void report(struct slabinfo *s)
@@ -573,12 +589,13 @@ static void slabcache(struct slabinfo *s
 		total_alloc = s->alloc_fastpath + s->alloc_slowpath;
 		total_free = s->free_fastpath + s->free_slowpath;
 
-		printf("%-21s %8ld %10ld %10ld %3ld %3ld %5ld %1d\n",
+		printf("%-21s %8ld %10ld %10ld %3ld %3ld %5ld %1d %4ld %4ld\n",
 			s->name, s->objects,
 			total_alloc, total_free,
 			total_alloc ? (s->alloc_fastpath * 100 / total_alloc) : 0,
 			total_free ? (s->free_fastpath * 100 / total_free) : 0,
-			s->order_fallback, s->order);
+			s->order_fallback, s->order, s->cmpxchg_double_fail,
+			s->cmpxchg_double_cpu_fail);
 	}
 	else
 		printf("%-21s %8ld %7d %8s %14s %4d %1d %3ld %3ld %s\n",
@@ -1190,6 +1207,10 @@ static void read_slab_dir(void)
 			slab->deactivate_to_tail = get_obj("deactivate_to_tail");
 			slab->deactivate_remote_frees = get_obj("deactivate_remote_frees");
 			slab->order_fallback = get_obj("order_fallback");
+			slab->cmpxchg_double_cpu_fail = get_obj("cmpxchg_double_cpu_fail");
+			slab->cmpxchg_double_fail = get_obj("cmpxchg_double_fail");
+			slab->alloc_node_mismatch = get_obj("alloc_node_mismatch");
+			slab->deactivate_bypass = get_obj("deactivate_bypass");
 			chdir("..");
 			if (slab->name[0] == ':')
 				alias_targets++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
