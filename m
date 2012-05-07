Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id B68AE6B00E9
	for <linux-mm@kvack.org>; Mon,  7 May 2012 07:38:14 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 06/10] mm: bootmem: unify allocation policy of (non-)panicking node allocations
Date: Mon,  7 May 2012 13:37:48 +0200
Message-Id: <1336390672-14421-7-git-send-email-hannes@cmpxchg.org>
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
 mm/bootmem.c |   44 ++++++++++++++++++++++++--------------------
 1 file changed, 24 insertions(+), 20 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index b5babdf..d9185c3 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -698,7 +698,7 @@ void * __init __alloc_bootmem(unsigned long size, unsigned long align,
 	return ___alloc_bootmem(size, align, goal, limit);
 }
 
-static void * __init ___alloc_bootmem_node(bootmem_data_t *bdata,
+static void * __init ___alloc_bootmem_node_nopanic(bootmem_data_t *bdata,
 				unsigned long size, unsigned long align,
 				unsigned long goal, unsigned long limit)
 {
@@ -722,6 +722,29 @@ again:
 		goto again;
 	}
 
+	return NULL;
+}
+
+void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
+				   unsigned long align, unsigned long goal)
+{
+	if (WARN_ON_ONCE(slab_is_available()))
+		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
+
+	return ___alloc_bootmem_node_nopanic(pgdat->bdata, size,
+					     align, goal, 0);
+}
+
+void * __init ___alloc_bootmem_node(bootmem_data_t *bdata, unsigned long size,
+				    unsigned long align, unsigned long goal,
+				    unsigned long limit)
+{
+	void *ptr;
+
+	ptr = ___alloc_bootmem_node_nopanic(bdata, size, align, goal, 0);
+	if (ptr)
+		return ptr;
+
 	printk(KERN_ALERT "bootmem alloc of %lu bytes failed!\n", size);
 	panic("Out of memory");
 	return NULL;
@@ -802,25 +825,6 @@ void * __init alloc_bootmem_section(unsigned long size,
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
-	ptr = alloc_arch_preferred_bootmem(pgdat->bdata, size, align, goal, 0);
-	if (ptr)
-		return ptr;
-
-	ptr = alloc_bootmem_bdata(pgdat->bdata, size, align, goal, 0);
-	if (ptr)
-		return ptr;
-
-	return __alloc_bootmem_nopanic(size, align, goal);
-}
-
 #ifndef ARCH_LOW_ADDRESS_LIMIT
 #define ARCH_LOW_ADDRESS_LIMIT	0xffffffffUL
 #endif
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
