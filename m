Message-Id: <20070925233007.778904086@sgi.com>
References: <20070925232543.036615409@sgi.com>
Date: Tue, 25 Sep 2007 16:25:53 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 10/14] SLUB: Rename NUMA defrag_ratio to remote_node_defrag_ratio
Content-Disposition: inline; filename=0003-slab_defrag_remote_node_defrag_ratio.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The NUMA defrag works by allocating objects from partial slabs on remote
nodes. Rename it to

	remote_node_defrag_ratio

to be clear about this.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 include/linux/slub_def.h |    5 ++++-
 mm/slub.c                |   17 +++++++++--------
 2 files changed, 13 insertions(+), 9 deletions(-)

Index: linux-2.6.23-rc8-mm1/include/linux/slub_def.h
===================================================================
--- linux-2.6.23-rc8-mm1.orig/include/linux/slub_def.h	2007-09-25 14:53:58.000000000 -0700
+++ linux-2.6.23-rc8-mm1/include/linux/slub_def.h	2007-09-25 14:54:43.000000000 -0700
@@ -59,7 +59,10 @@ struct kmem_cache {
 #endif
 
 #ifdef CONFIG_NUMA
-	int defrag_ratio;
+	/*
+	 * Defragmentation by allocating from a remote node.
+	 */
+	int remote_node_defrag_ratio;
 	struct kmem_cache_node *node[MAX_NUMNODES];
 #endif
 #ifdef CONFIG_SMP
Index: linux-2.6.23-rc8-mm1/mm/slub.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/mm/slub.c	2007-09-25 14:54:25.000000000 -0700
+++ linux-2.6.23-rc8-mm1/mm/slub.c	2007-09-25 14:54:43.000000000 -0700
@@ -1300,7 +1300,8 @@ static struct page *get_any_partial(stru
 	 * expensive if we do it every time we are trying to find a slab
 	 * with available objects.
 	 */
-	if (!s->defrag_ratio || get_cycles() % 1024 > s->defrag_ratio)
+	if (!s->remote_node_defrag_ratio ||
+			get_cycles() % 1024 > s->remote_node_defrag_ratio)
 		return NULL;
 
 	zonelist = &NODE_DATA(slab_node(current->mempolicy))
@@ -2231,7 +2232,7 @@ static int kmem_cache_open(struct kmem_c
 
 	s->refcount = 1;
 #ifdef CONFIG_NUMA
-	s->defrag_ratio = 100;
+	s->remote_node_defrag_ratio = 100;
 #endif
 	if (!init_kmem_cache_nodes(s, gfpflags & ~SLUB_DMA))
 		goto error;
@@ -3762,21 +3763,21 @@ static ssize_t free_calls_show(struct km
 SLAB_ATTR_RO(free_calls);
 
 #ifdef CONFIG_NUMA
-static ssize_t defrag_ratio_show(struct kmem_cache *s, char *buf)
+static ssize_t remote_node_defrag_ratio_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%d\n", s->defrag_ratio / 10);
+	return sprintf(buf, "%d\n", s->remote_node_defrag_ratio / 10);
 }
 
-static ssize_t defrag_ratio_store(struct kmem_cache *s,
+static ssize_t remote_node_defrag_ratio_store(struct kmem_cache *s,
 				const char *buf, size_t length)
 {
 	int n = simple_strtoul(buf, NULL, 10);
 
 	if (n < 100)
-		s->defrag_ratio = n * 10;
+		s->remote_node_defrag_ratio = n * 10;
 	return length;
 }
-SLAB_ATTR(defrag_ratio);
+SLAB_ATTR(remote_node_defrag_ratio);
 #endif
 
 static struct attribute * slab_attrs[] = {
@@ -3807,7 +3808,7 @@ static struct attribute * slab_attrs[] =
 	&cache_dma_attr.attr,
 #endif
 #ifdef CONFIG_NUMA
-	&defrag_ratio_attr.attr,
+	&remote_node_defrag_ratio_attr.attr,
 #endif
 	NULL
 };

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
