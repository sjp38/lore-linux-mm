Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f42.google.com (mail-oa0-f42.google.com [209.85.219.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8D6876B0037
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 20:15:29 -0400 (EDT)
Received: by mail-oa0-f42.google.com with SMTP id n16so406489oag.29
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 17:15:29 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id b10si4835440obq.41.2014.08.13.17.15.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 Aug 2014 17:15:29 -0700 (PDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Wed, 13 Aug 2014 18:15:28 -0600
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTPS id 253E13E40047
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 18:15:26 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s7E0FQN222937638
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 02:15:26 +0200
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s7E0FOpo008394
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 18:15:25 -0600
Date: Wed, 13 Aug 2014 17:15:19 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: [RFC PATCH 2/4] slub: fallback to node_to_mem_node() node if
 allocating on memoryless node
Message-ID: <20140814001518.GK11121@linux.vnet.ibm.com>
References: <20140814001301.GI11121@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140814001301.GI11121@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Update the SLUB code to search for partial slabs on the nearest node
with memory in the presence of memoryless nodes. Additionally, do not
consider it to be an ALLOC_NODE_MISMATCH (and deactivate the slab) when
a memoryless-node specified allocation goes off-node.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
    
---
v1 -> v2 (Nishanth):
  Add commit message
  Clean-up conditions in get_partial()

diff --git a/mm/slub.c b/mm/slub.c
index 3e8afcc07a76..497fdfed2f01 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1699,7 +1699,12 @@ static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
 		struct kmem_cache_cpu *c)
 {
 	void *object;
-	int searchnode = (node == NUMA_NO_NODE) ? numa_mem_id() : node;
+	int searchnode = node;
+
+	if (node == NUMA_NO_NODE)
+		searchnode = numa_mem_id();
+	else if (!node_present_pages(node))
+		searchnode = node_to_mem_node(node);
 
 	object = get_partial_node(s, get_node(s, searchnode), c, flags);
 	if (object || node != NUMA_NO_NODE)
@@ -2280,11 +2285,18 @@ static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 redo:
 
 	if (unlikely(!node_match(page, node))) {
-		stat(s, ALLOC_NODE_MISMATCH);
-		deactivate_slab(s, page, c->freelist);
-		c->page = NULL;
-		c->freelist = NULL;
-		goto new_slab;
+		int searchnode = node;
+
+		if (node != NUMA_NO_NODE && !node_present_pages(node))
+			searchnode = node_to_mem_node(node);
+
+		if (unlikely(!node_match(page, searchnode))) {
+			stat(s, ALLOC_NODE_MISMATCH);
+			deactivate_slab(s, page, c->freelist);
+			c->page = NULL;
+			c->freelist = NULL;
+			goto new_slab;
+		}
 	}
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
