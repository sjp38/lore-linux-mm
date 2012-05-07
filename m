Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 5DF2C6B00EA
	for <linux-mm@kvack.org>; Mon,  7 May 2012 07:38:15 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 07/10] mm: nobootmem: panic on node-specific allocation failure
Date: Mon,  7 May 2012 13:37:49 +0200
Message-Id: <1336390672-14421-8-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
References: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, David Miller <davem@davemloft.net>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

__alloc_bootmem_node and __alloc_bootmem_low_node documentation claims
the functions panic on allocation failure.  Do it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/nobootmem.c |   20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index e53bb8a..b078ff8 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -306,11 +306,17 @@ again:
 
 	ptr = __alloc_memory_core_early(MAX_NUMNODES, size, align,
 					goal, -1ULL);
-	if (!ptr && goal) {
+	if (ptr)
+		return ptr;
+
+	if (goal) {
 		goal = 0;
 		goto again;
 	}
-	return ptr;
+
+	printk(KERN_ALERT "bootmem alloc of %lu bytes failed!\n", size);
+	panic("Out of memory");
+	return NULL;
 }
 
 void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
@@ -408,6 +414,12 @@ void * __init __alloc_bootmem_low_node(pg_data_t *pgdat, unsigned long size,
 	if (ptr)
 		return ptr;
 
-	return  __alloc_memory_core_early(MAX_NUMNODES, size, align,
-				goal, ARCH_LOW_ADDRESS_LIMIT);
+	ptr = __alloc_memory_core_early(MAX_NUMNODES, size, align,
+					goal, ARCH_LOW_ADDRESS_LIMIT);
+	if (ptr)
+		return ptr;
+
+	printk(KERN_ALERT "bootmem alloc of %lu bytes failed!\n", size);
+	panic("Out of memory");
+	return NULL;
 }
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
