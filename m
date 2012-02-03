Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 864306B13F0
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 03:14:00 -0500 (EST)
Subject: [rfc PATCH]slub: per cpu partial statistics change
From: "Alex,Shi" <alex.shi@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 03 Feb 2012 16:11:35 +0800
Message-ID: <1328256695.12669.24.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "cl@linux.com" <cl@linux.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, "linux-mm@kvack.org" <linux-mm@kvack.org>


This patch split the cpu_partial_free into 2 parts: cpu_partial_node, PCP refilling
times from node partial; and same name cpu_partial_free, PCP refilling times in
slab_free slow path. A new statistic 'release_cpu_partial' is added to get PCP
release times. These info are useful when do PCP tunning.

The slabinfo.c code is unchanged, since cpu_partial_node is not on slow path.

Signed-off-by: Alex Shi <alex.shi@intel.com>
---
 include/linux/slub_def.h |    6 ++++--
 mm/slub.c                |   12 +++++++++---
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index a32bcfd..57ea943 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -21,7 +21,7 @@ enum stat_item {
 	FREE_FROZEN,		/* Freeing to frozen slab */
 	FREE_ADD_PARTIAL,	/* Freeing moves slab to partial list */
 	FREE_REMOVE_PARTIAL,	/* Freeing removes last object */
-	ALLOC_FROM_PARTIAL,	/* Cpu slab acquired from partial list */
+	ALLOC_FROM_PARTIAL,	/* Cpu slab acquired from node partial list */
 	ALLOC_SLAB,		/* Cpu slab acquired from page allocator */
 	ALLOC_REFILL,		/* Refill cpu slab from slab freelist */
 	ALLOC_NODE_MISMATCH,	/* Switching cpu slab */
@@ -37,7 +37,9 @@ enum stat_item {
 	CMPXCHG_DOUBLE_CPU_FAIL,/* Failure of this_cpu_cmpxchg_double */
 	CMPXCHG_DOUBLE_FAIL,	/* Number of times that cmpxchg double did not match */
 	CPU_PARTIAL_ALLOC,	/* Used cpu partial on alloc */
-	CPU_PARTIAL_FREE,	/* USed cpu partial on free */
+	CPU_PARTIAL_FREE,	/* Refill cpu partial on free */
+	CPU_PARTIAL_NODE,	/* Refill cpu partial from node partial */
+	RELEASE_CPU_PARTIAL,	/* Release per cpu partial */
 	NR_SLUB_STAT_ITEMS };
 
 struct kmem_cache_cpu {
diff --git a/mm/slub.c b/mm/slub.c
index 4907563..5dd299c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1560,6 +1560,7 @@ static void *get_partial_node(struct kmem_cache *s,
 		} else {
 			page->freelist = t;
 			available = put_cpu_partial(s, page, 0);
+			stat(s, CPU_PARTIAL_NODE);
 		}
 		if (kmem_cache_debug(s) || available > s->cpu_partial / 2)
 			break;
@@ -1973,6 +1974,7 @@ int put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
 				local_irq_restore(flags);
 				pobjects = 0;
 				pages = 0;
+				stat(s, RELEASE_CPU_PARTIAL);
 			}
 		}
 
@@ -1984,7 +1986,6 @@ int put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
 		page->next = oldpage;
 
 	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page) != oldpage);
-	stat(s, CPU_PARTIAL_FREE);
 	return pobjects;
 }
 
@@ -2465,9 +2466,10 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 		 * If we just froze the page then put it onto the
 		 * per cpu partial list.
 		 */
-		if (new.frozen && !was_frozen)
+		if (new.frozen && !was_frozen) {
 			put_cpu_partial(s, page, 1);
-
+			stat(s, CPU_PARTIAL_FREE);
+		}
 		/*
 		 * The list lock was not taken therefore no list
 		 * activity can be necessary.
@@ -5059,6 +5061,8 @@ STAT_ATTR(CMPXCHG_DOUBLE_CPU_FAIL, cmpxchg_double_cpu_fail);
 STAT_ATTR(CMPXCHG_DOUBLE_FAIL, cmpxchg_double_fail);
 STAT_ATTR(CPU_PARTIAL_ALLOC, cpu_partial_alloc);
 STAT_ATTR(CPU_PARTIAL_FREE, cpu_partial_free);
+STAT_ATTR(CPU_PARTIAL_NODE, cpu_partial_node);
+STAT_ATTR(RELEASE_CPU_PARTIAL, release_cpu_partial);
 #endif
 
 static struct attribute *slab_attrs[] = {
@@ -5124,6 +5128,8 @@ static struct attribute *slab_attrs[] = {
 	&cmpxchg_double_cpu_fail_attr.attr,
 	&cpu_partial_alloc_attr.attr,
 	&cpu_partial_free_attr.attr,
+	&cpu_partial_node_attr.attr,
+	&release_cpu_partial_attr.attr,
 #endif
 #ifdef CONFIG_FAILSLAB
 	&failslab_attr.attr,
-- 
1.7.5.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
