Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 163FA6B0037
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 03:07:01 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id y10so1391269pdj.40
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 00:07:00 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id yg10si181085pbc.32.2014.02.06.00.06.58
        for <linux-mm@kvack.org>;
        Thu, 06 Feb 2014 00:06:59 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 1/3] slub: search partial list on numa_mem_id(), instead of numa_node_id()
Date: Thu,  6 Feb 2014 17:07:04 +0900
Message-Id: <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <20140206020757.GC5433@linux.vnet.ibm.com>
References: <20140206020757.GC5433@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Currently, if allocation constraint to node is NUMA_NO_NODE, we search
a partial slab on numa_node_id() node. This doesn't work properly on the
system having memoryless node, since it can have no memory on that node and
there must be no partial slab on that node.

On that node, page allocation always fallback to numa_mem_id() first. So
searching a partial slab on numa_node_id() in that case is proper solution
for memoryless node case.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slub.c b/mm/slub.c
index 545a170..cc1f995 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1698,7 +1698,7 @@ static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
 		struct kmem_cache_cpu *c)
 {
 	void *object;
-	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
+	int searchnode = (node == NUMA_NO_NODE) ? numa_mem_id() : node;
 
 	object = get_partial_node(s, get_node(s, searchnode), c, flags);
 	if (object || node != NUMA_NO_NODE)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
