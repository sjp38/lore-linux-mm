Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 47F5F6B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 13:51:12 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id e16so6579473qcx.24
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 10:51:11 -0800 (PST)
Received: from qmta04.emeryville.ca.mail.comcast.net (qmta04.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:40])
        by mx.google.com with ESMTP id t101si4178230qge.151.2014.02.07.10.51.10
        for <linux-mm@kvack.org>;
        Fri, 07 Feb 2014 10:51:10 -0800 (PST)
Date: Fri, 7 Feb 2014 12:51:07 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for determining
 the fallback node
In-Reply-To: <alpine.DEB.2.10.1402071150090.15168@nuc>
Message-ID: <alpine.DEB.2.10.1402071245040.20246@nuc>
References: <20140206020757.GC5433@linux.vnet.ibm.com> <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com> <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com> <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com>
 <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com> <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com> <20140207054819.GC28952@lge.com> <alpine.DEB.2.10.1402071150090.15168@nuc>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Here is a draft of a patch to make this work with memoryless nodes.

The first thing is that we modify node_match to also match if we hit an
empty node. In that case we simply take the current slab if its there.

If there is no current slab then a regular allocation occurs with the
memoryless node. The page allocator will fallback to a possible node and
that will become the current slab. Next alloc from a memoryless node
will then use that slab.

For that we also add some tracking of allocations on nodes that were not
satisfied using the empty_node[] array. A successful alloc on a node
clears that flag.

I would rather avoid the empty_node[] array since its global and there may
be thread specific allocation restrictions but it would be expensive to do
an allocation attempt via the page allocator to make sure that there is
really no page available from the page allocator.

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2014-02-03 13:19:22.896853227 -0600
+++ linux/mm/slub.c	2014-02-07 12:44:49.311494806 -0600
@@ -132,6 +132,8 @@ static inline bool kmem_cache_has_cpu_pa
 #endif
 }

+static int empty_node[MAX_NUMNODES];
+
 /*
  * Issues still to be resolved:
  *
@@ -1405,16 +1407,22 @@ static struct page *new_slab(struct kmem
 	void *last;
 	void *p;
 	int order;
+	int alloc_node;

 	BUG_ON(flags & GFP_SLAB_BUG_MASK);

 	page = allocate_slab(s,
 		flags & (GFP_RECLAIM_MASK | GFP_CONSTRAINT_MASK), node);
-	if (!page)
+	if (!page) {
+		if (node != NUMA_NO_NODE)
+			empty_node[node] = 1;
 		goto out;
+	}

 	order = compound_order(page);
-	inc_slabs_node(s, page_to_nid(page), page->objects);
+	alloc_node = page_to_nid(page);
+	empty_node[alloc_node] = 0;
+	inc_slabs_node(s, alloc_node, page->objects);
 	memcg_bind_pages(s, order);
 	page->slab_cache = s;
 	__SetPageSlab(page);
@@ -1712,7 +1720,7 @@ static void *get_partial(struct kmem_cac
 		struct kmem_cache_cpu *c)
 {
 	void *object;
-	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
+	int searchnode = (node == NUMA_NO_NODE) ? numa_mem_id() : node;

 	object = get_partial_node(s, get_node(s, searchnode), c, flags);
 	if (object || node != NUMA_NO_NODE)
@@ -2107,8 +2115,25 @@ static void flush_all(struct kmem_cache
 static inline int node_match(struct page *page, int node)
 {
 #ifdef CONFIG_NUMA
-	if (!page || (node != NUMA_NO_NODE && page_to_nid(page) != node))
+	int page_node;
+
+	/* No data means no match */
+	if (!page)
 		return 0;
+
+	/* Node does not matter. Therefore anything is a match */
+	if (node == NUMA_NO_NODE)
+		return 1;
+
+	/* Did we hit the requested node ? */
+	page_node = page_to_nid(page);
+	if (page_node == node)
+		return 1;
+
+	/* If the node has available data then we can use it. Mismatch */
+	return !empty_node[page_node];
+
+	/* Target node empty so just take anything */
 #endif
 	return 1;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
