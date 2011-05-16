Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E38D58D003B
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:26:34 -0400 (EDT)
Message-Id: <20110516202632.861615235@linux.com>
Date: Mon, 16 May 2011 15:26:25 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv5 20/25] slub: slabinfo update for cmpxchg handling
References: <20110516202605.274023469@linux.com>
Content-Disposition: inline; filename=update_slabinfo
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

Update the statistics handling and the slabinfo tool to include the new
statistics in the reports it generates.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 tools/slub/slabinfo.c |   57 ++++++++++++++++++++++++++++++++++----------------
 1 file changed, 39 insertions(+), 18 deletions(-)

Index: linux-2.6/tools/slub/slabinfo.c
===================================================================
--- linux-2.6.orig/tools/slub/slabinfo.c	2011-05-16 12:51:06.000000000 -0500
+++ linux-2.6/tools/slub/slabinfo.c	2011-05-16 12:52:08.501458494 -0500
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
