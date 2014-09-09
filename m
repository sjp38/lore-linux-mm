Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id B00636B00A1
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 15:05:28 -0400 (EDT)
Received: by mail-ie0-f182.google.com with SMTP id tr6so3782545ieb.13
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 12:05:28 -0700 (PDT)
Received: from e8.ny.us.ibm.com (e8.ny.us.ibm.com. [32.97.182.138])
        by mx.google.com with ESMTPS id x6si17560655igl.40.2014.09.09.12.05.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Sep 2014 12:05:28 -0700 (PDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 9 Sep 2014 15:05:27 -0400
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 4CCBCC90045
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 15:05:15 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22035.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s89J5Nuq9240984
	for <linux-mm@kvack.org>; Tue, 9 Sep 2014 19:05:23 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s89J5LBT027067
	for <linux-mm@kvack.org>; Tue, 9 Sep 2014 15:05:23 -0400
Date: Tue, 9 Sep 2014 12:05:14 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: [PATCH 2/3] slub: fallback to node_to_mem_node() node if allocating
 on memoryless node
Message-ID: <20140909190514.GE22906@linux.vnet.ibm.com>
References: <20140909190154.GC22906@linux.vnet.ibm.com>
 <20140909190326.GD22906@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140909190326.GD22906@linux.vnet.ibm.com>
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
