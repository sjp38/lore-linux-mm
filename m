Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id D56AD6B0062
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 05:03:16 -0500 (EST)
Subject: Re: [PATCH 1/3] slub: set a criteria for slub node partial adding
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <alpine.DEB.2.00.1112021401200.13405@router.home>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com>
	 <1322825802.2607.10.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1112021401200.13405@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 05 Dec 2011 18:01:16 +0800
Message-ID: <1323079276.16790.746.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sat, 2011-12-03 at 04:02 +0800, Christoph Lameter wrote:
> On Fri, 2 Dec 2011, Eric Dumazet wrote:
> 
> > netperf (loopback or ethernet) is a known stress test for slub, and your
> > patch removes code that might hurt netperf, but benefit real workload.
> >
> > Have you tried instead this far less intrusive solution ?
> >
> > if (tail == DEACTIVATE_TO_TAIL ||
> >     page->inuse > page->objects / 4)
> >          list_add_tail(&page->lru, &n->partial);
> > else
> >          list_add(&page->lru, &n->partial);
> 
> One could also move this logic to reside outside of the call to
> add_partial(). This is called mostly from __slab_free() so the logic could
> be put in there.
> 

After pcp adding, add_partial just be used in put_cpu_partial ->
unfreeze_partial without debug setting. If we need to do change, guess
it's better in this function. 

BTW
I collection some data with my PCP statistics patch. I will be very glad
if you like it. 

[alexs@lkp-ne04 ~]$ sudo grep . /sys/kernel/slab/kmalloc-256/*

/sys/kernel/slab/kmalloc-256/alloc_from_partial:4955645 
/sys/kernel/slab/kmalloc-256/alloc_from_pcp:6753981 
...
/sys/kernel/slab/kmalloc-256/pcp_from_free:11743977 
/sys/kernel/slab/kmalloc-256/pcp_from_node:5948883 
...
/sys/kernel/slab/kmalloc-256/unfreeze_pcp:834262 


--------------

>From aa754e20b81cb9f5ab63800a084858d25c18db31 Mon Sep 17 00:00:00 2001
From: Alex shi <alex.shi@intel.com>
Date: Tue, 6 Dec 2011 01:49:16 +0800
Subject: [PATCH] slub: per cpu partial statistics collection

PCP statistics were not collected in detail now. Add and change some variables
for this.

changed:
cpu_partial_alloc --> alloc_from_pcp,
cpu_partial_free  --> pcp_from_free, /* pcp refilled from slab free */

added:
pcp_from_node, /* pcp refilled from node partial */
unfreeze_pcp,  /* unfreeze pcp */

Signed-off-by: Alex Shi <alex.shi@intel.com>
---
 include/linux/slub_def.h |    8 +++++---
 mm/slub.c                |   22 ++++++++++++++--------
 tools/slub/slabinfo.c    |   12 ++++++------
 3 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index a32bcfd..1c2669b 100644
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
@@ -36,8 +36,10 @@ enum stat_item {
 	ORDER_FALLBACK,		/* Number of times fallback was necessary */
 	CMPXCHG_DOUBLE_CPU_FAIL,/* Failure of this_cpu_cmpxchg_double */
 	CMPXCHG_DOUBLE_FAIL,	/* Number of times that cmpxchg double did not match */
-	CPU_PARTIAL_ALLOC,	/* Used cpu partial on alloc */
-	CPU_PARTIAL_FREE,	/* USed cpu partial on free */
+	ALLOC_FROM_PCP,		/* Used cpu partial on alloc */
+	PCP_FROM_FREE,		/* Fill cpu partial from free */
+	PCP_FROM_NODE,		/* Fill cpu partial from node partial */
+	UNFREEZE_PCP,		/* Unfreeze per cpu partial */
 	NR_SLUB_STAT_ITEMS };
 
 struct kmem_cache_cpu {
diff --git a/mm/slub.c b/mm/slub.c
index ed3334d..5843846 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1558,6 +1558,7 @@ static void *get_partial_node(struct kmem_cache *s,
 		} else {
 			page->freelist = t;
 			available = put_cpu_partial(s, page, 0);
+			stat(s, PCP_FROM_NODE);
 		}
 		if (kmem_cache_debug(s) || available > s->cpu_partial / 2)
 			break;
@@ -1968,6 +1969,7 @@ int put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
 				local_irq_restore(flags);
 				pobjects = 0;
 				pages = 0;
+				stat(s, UNFREEZE_PCP);
 			}
 		}
 
@@ -1979,7 +1981,6 @@ int put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
 		page->next = oldpage;
 
 	} while (irqsafe_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page) != oldpage);
-	stat(s, CPU_PARTIAL_FREE);
 	return pobjects;
 }
 
@@ -2212,7 +2213,7 @@ new_slab:
 		c->page = c->partial;
 		c->partial = c->page->next;
 		c->node = page_to_nid(c->page);
-		stat(s, CPU_PARTIAL_ALLOC);
+		stat(s, ALLOC_FROM_PCP);
 		c->freelist = NULL;
 		goto redo;
 	}
@@ -2448,9 +2449,10 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 		 * If we just froze the page then put it onto the
 		 * per cpu partial list.
 		 */
-		if (new.frozen && !was_frozen)
+		if (new.frozen && !was_frozen) {
 			put_cpu_partial(s, page, 1);
-
+			stat(s, PCP_FROM_FREE);
+		}
 		/*
 		 * The list lock was not taken therefore no list
 		 * activity can be necessary.
@@ -5032,8 +5034,10 @@ STAT_ATTR(DEACTIVATE_BYPASS, deactivate_bypass);
 STAT_ATTR(ORDER_FALLBACK, order_fallback);
 STAT_ATTR(CMPXCHG_DOUBLE_CPU_FAIL, cmpxchg_double_cpu_fail);
 STAT_ATTR(CMPXCHG_DOUBLE_FAIL, cmpxchg_double_fail);
-STAT_ATTR(CPU_PARTIAL_ALLOC, cpu_partial_alloc);
-STAT_ATTR(CPU_PARTIAL_FREE, cpu_partial_free);
+STAT_ATTR(ALLOC_FROM_PCP, alloc_from_pcp);
+STAT_ATTR(PCP_FROM_FREE, pcp_from_free);
+STAT_ATTR(PCP_FROM_NODE, pcp_from_node);
+STAT_ATTR(UNFREEZE_PCP, unfreeze_pcp);
 #endif
 
 static struct attribute *slab_attrs[] = {
@@ -5097,8 +5101,10 @@ static struct attribute *slab_attrs[] = {
 	&order_fallback_attr.attr,
 	&cmpxchg_double_fail_attr.attr,
 	&cmpxchg_double_cpu_fail_attr.attr,
-	&cpu_partial_alloc_attr.attr,
-	&cpu_partial_free_attr.attr,
+	&alloc_from_pcp_attr.attr,
+	&pcp_from_free_attr.attr,
+	&pcp_from_node_attr.attr,
+	&unfreeze_pcp_attr.attr,
 #endif
 #ifdef CONFIG_FAILSLAB
 	&failslab_attr.attr,
diff --git a/tools/slub/slabinfo.c b/tools/slub/slabinfo.c
index 164cbcf..d8f67f0 100644
--- a/tools/slub/slabinfo.c
+++ b/tools/slub/slabinfo.c
@@ -42,7 +42,7 @@ struct slabinfo {
 	unsigned long deactivate_remote_frees, order_fallback;
 	unsigned long cmpxchg_double_cpu_fail, cmpxchg_double_fail;
 	unsigned long alloc_node_mismatch, deactivate_bypass;
-	unsigned long cpu_partial_alloc, cpu_partial_free;
+	unsigned long alloc_from_pcp, pcp_from_free;
 	int numa[MAX_NODES];
 	int numa_partial[MAX_NODES];
 } slabinfo[MAX_SLABS];
@@ -457,9 +457,9 @@ static void slab_stats(struct slabinfo *s)
 		s->free_remove_partial * 100 / total_free);
 
 	printf("Cpu partial list     %8lu %8lu %3lu %3lu\n",
-		s->cpu_partial_alloc, s->cpu_partial_free,
-		s->cpu_partial_alloc * 100 / total_alloc,
-		s->cpu_partial_free * 100 / total_free);
+		s->alloc_from_pcp, s->pcp_from_free,
+		s->alloc_from_pcp * 100 / total_alloc,
+		s->pcp_from_free * 100 / total_free);
 
 	printf("RemoteObj/SlabFrozen %8lu %8lu %3lu %3lu\n",
 		s->deactivate_remote_frees, s->free_frozen,
@@ -1215,8 +1215,8 @@ static void read_slab_dir(void)
 			slab->order_fallback = get_obj("order_fallback");
 			slab->cmpxchg_double_cpu_fail = get_obj("cmpxchg_double_cpu_fail");
 			slab->cmpxchg_double_fail = get_obj("cmpxchg_double_fail");
-			slab->cpu_partial_alloc = get_obj("cpu_partial_alloc");
-			slab->cpu_partial_free = get_obj("cpu_partial_free");
+			slab->alloc_from_pcp = get_obj("alloc_from_pcp");
+			slab->pcp_from_free = get_obj("pcp_from_free");
 			slab->alloc_node_mismatch = get_obj("alloc_node_mismatch");
 			slab->deactivate_bypass = get_obj("deactivate_bypass");
 			chdir("..");
-- 
1.7.0.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
