From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 03/26] SLUB: Rename NUMA defrag_ratio to remote_node_defrag_ratio
Date: Fri, 31 Aug 2007 18:41:10 -0700
Message-ID: <20070901014219.988922690@sgi.com>
References: <20070901014107.719506437@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0003-slab_defrag_remote_node_defrag_ratio.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-Id: linux-mm.kvack.org

We need the defrag ratio for the non NUMA situation now. The NUMA defrag works
by allocating objects from partial slabs on remote nodes. Rename it to

	remote_node_defrag_ratio

to be clear about this.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 include/linux/slub_def.h |    5 ++++-
 mm/slub.c                |   17 +++++++++--------
 2 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 8aad7dc..5912b58 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
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
diff --git a/mm/slub.c b/mm/slub.c
index aad6f83..e63aba5 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1267,7 +1267,8 @@ static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
 	 * expensive if we do it every time we are trying to find a slab
 	 * with available objects.
 	 */
-	if (!s->defrag_ratio || get_cycles() % 1024 > s->defrag_ratio)
+	if (!s->remote_node_defrag_ratio ||
+			get_cycles() % 1024 > s->remote_node_defrag_ratio)
 		return NULL;
 
 	zonelist = &NODE_DATA(slab_node(current->mempolicy))
@@ -2200,7 +2201,7 @@ static int kmem_cache_open(struct kmem_cache *s, gfp_t gfpflags,
 
 	s->refcount = 1;
 #ifdef CONFIG_NUMA
-	s->defrag_ratio = 100;
+	s->remote_node_defrag_ratio = 100;
 #endif
 
 	if (!init_kmem_cache_nodes(s, gfpflags & ~SLUB_DMA))
@@ -3717,21 +3718,21 @@ static ssize_t free_calls_show(struct kmem_cache *s, char *buf)
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
@@ -3762,7 +3763,7 @@ static struct attribute * slab_attrs[] = {
 	&cache_dma_attr.attr,
 #endif
 #ifdef CONFIG_NUMA
-	&defrag_ratio_attr.attr,
+	&remote_node_defrag_ratio_attr.attr,
 #endif
 	NULL
 };
-- 
1.5.2.4

-- 
