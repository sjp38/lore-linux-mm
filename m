Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5C7586B0039
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 03:07:01 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id x10so1395216pdj.36
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 00:07:01 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id n8si163474pax.102.2014.02.06.00.06.58
        for <linux-mm@kvack.org>;
        Thu, 06 Feb 2014 00:07:00 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 3/3] slub: fallback to get_numa_mem() node if we want to allocate on memoryless node
Date: Thu,  6 Feb 2014 17:07:06 +0900
Message-Id: <1391674026-20092-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <20140206020757.GC5433@linux.vnet.ibm.com>
 <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slub.c b/mm/slub.c
index cc1f995..c851f82 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1700,6 +1700,14 @@ static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
 	void *object;
 	int searchnode = (node == NUMA_NO_NODE) ? numa_mem_id() : node;
 
+	if (node == NUMA_NO_NODE)
+		searchnode = numa_mem_id();
+	else {
+		searchnode = node;
+		if (!node_present_pages(node))
+			searchnode = get_numa_mem(node);
+	}
+
 	object = get_partial_node(s, get_node(s, searchnode), c, flags);
 	if (object || node != NUMA_NO_NODE)
 		return object;
@@ -2277,11 +2285,18 @@ static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
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
+			searchnode = get_numa_mem(node);
+
+		if (!node_match(page, searchnode)) {
+			stat(s, ALLOC_NODE_MISMATCH);
+			deactivate_slab(s, page, c->freelist);
+			c->page = NULL;
+			c->freelist = NULL;
+			goto new_slab;
+		}
 	}
 
 	/*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
