Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id C1BD26B00F1
	for <linux-mm@kvack.org>; Mon,  7 May 2012 07:38:16 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 08/10] mm: nobootmem: unify allocation policy of (non-)panicking node allocations
Date: Mon,  7 May 2012 13:37:50 +0200
Message-Id: <1336390672-14421-9-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
References: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, David Miller <davem@davemloft.net>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

While the panicking node-specific allocation function tries to satisfy
node+goal, goal, node, anywhere, the non-panicking function still does
node+goal, goal, anywhere.

Make it simpler: define the panicking version in terms of the
non-panicking one, like the node-agnostic interface, so they always
behave the same way apart from how to deal with allocation failure.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/nobootmem.c |  106 +++++++++++++++++++++++++++++---------------------------
 1 file changed, 54 insertions(+), 52 deletions(-)

diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index b078ff8..77069bb 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -275,6 +275,57 @@ void * __init __alloc_bootmem(unsigned long size, unsigned long align,
 	return ___alloc_bootmem(size, align, goal, limit);
 }
 
+static void * __init ___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
+						   unsigned long size,
+						   unsigned long align,
+						   unsigned long goal,
+						   unsigned long limit)
+{
+	void *ptr;
+
+again:
+	ptr = __alloc_memory_core_early(pgdat->node_id, size, align,
+					goal, limit);
+	if (ptr)
+		return ptr;
+
+	ptr = __alloc_memory_core_early(MAX_NUMNODES, size, align,
+					goal, limit);
+	if (ptr)
+		return ptr;
+
+	if (goal) {
+		goal = 0;
+		goto again;
+	}
+
+	return NULL;
+}
+
+void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
+				   unsigned long align, unsigned long goal)
+{
+	if (WARN_ON_ONCE(slab_is_available()))
+		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
+
+	return ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, 0);
+}
+
+void * __init ___alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
+				    unsigned long align, unsigned long goal,
+				    unsigned long limit)
+{
+	void *ptr;
+
+	ptr = ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, limit);
+	if (ptr)
+		return ptr;
+
+	printk(KERN_ALERT "bootmem alloc of %lu bytes failed!\n", size);
+	panic("Out of memory");
+	return NULL;
+}
+
 /**
  * __alloc_bootmem_node - allocate boot memory from a specific node
  * @pgdat: node to allocate from
@@ -293,30 +344,10 @@ void * __init __alloc_bootmem(unsigned long size, unsigned long align,
 void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
 				   unsigned long align, unsigned long goal)
 {
-	void *ptr;
-
 	if (WARN_ON_ONCE(slab_is_available()))
 		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
 
-again:
-	ptr = __alloc_memory_core_early(pgdat->node_id, size, align,
-					 goal, -1ULL);
-	if (ptr)
-		return ptr;
-
-	ptr = __alloc_memory_core_early(MAX_NUMNODES, size, align,
-					goal, -1ULL);
-	if (ptr)
-		return ptr;
-
-	if (goal) {
-		goal = 0;
-		goto again;
-	}
-
-	printk(KERN_ALERT "bootmem alloc of %lu bytes failed!\n", size);
-	panic("Out of memory");
-	return NULL;
+	return ___alloc_bootmem_node(pgdat, size, align, goal, 0);
 }
 
 void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
@@ -347,22 +378,6 @@ void * __init alloc_bootmem_section(unsigned long size,
 }
 #endif
 
-void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
-				   unsigned long align, unsigned long goal)
-{
-	void *ptr;
-
-	if (WARN_ON_ONCE(slab_is_available()))
-		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
-
-	ptr =  __alloc_memory_core_early(pgdat->node_id, size, align,
-						 goal, -1ULL);
-	if (ptr)
-		return ptr;
-
-	return __alloc_bootmem_nopanic(size, align, goal);
-}
-
 #ifndef ARCH_LOW_ADDRESS_LIMIT
 #define ARCH_LOW_ADDRESS_LIMIT	0xffffffffUL
 #endif
@@ -404,22 +419,9 @@ void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
 void * __init __alloc_bootmem_low_node(pg_data_t *pgdat, unsigned long size,
 				       unsigned long align, unsigned long goal)
 {
-	void *ptr;
-
 	if (WARN_ON_ONCE(slab_is_available()))
 		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
 
-	ptr = __alloc_memory_core_early(pgdat->node_id, size, align,
-				goal, ARCH_LOW_ADDRESS_LIMIT);
-	if (ptr)
-		return ptr;
-
-	ptr = __alloc_memory_core_early(MAX_NUMNODES, size, align,
-					goal, ARCH_LOW_ADDRESS_LIMIT);
-	if (ptr)
-		return ptr;
-
-	printk(KERN_ALERT "bootmem alloc of %lu bytes failed!\n", size);
-	panic("Out of memory");
-	return NULL;
+	return ___alloc_bootmem_node(pgdat, size, align, goal,
+				     ARCH_LOW_ADDRESS_LIMIT);
 }
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
