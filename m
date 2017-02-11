Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4E46B6B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 21:19:39 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 80so76167690pfy.2
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 18:19:39 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id b64si3332715pfg.70.2017.02.10.18.19.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 18:19:38 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id 68so1466213pfx.2
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 18:19:38 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [RFC PATCH 1/2] mm/memblock: introduce for_each_mem_pfn_range_rev()
Date: Sat, 11 Feb 2017 10:18:28 +0800
Message-Id: <20170211021829.9646-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, tj@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

This patch introduces the helper function for_each_mem_pfn_range_rev() for
later use.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 include/linux/memblock.h | 18 ++++++++++++++++++
 mm/memblock.c            | 39 ++++++++++++++++++++++++++++++++++++++-
 2 files changed, 56 insertions(+), 1 deletion(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 5b759c9acf97..87a0ebe18606 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -203,6 +203,8 @@ int memblock_search_pfn_nid(unsigned long pfn, unsigned long *start_pfn,
 			    unsigned long  *end_pfn);
 void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
 			  unsigned long *out_end_pfn, int *out_nid);
+void __next_mem_pfn_range_rev(int *idx, int nid, unsigned long *out_start_pfn,
+			  unsigned long *out_end_pfn, int *out_nid);
 
 /**
  * for_each_mem_pfn_range - early memory pfn range iterator
@@ -217,6 +219,22 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
 #define for_each_mem_pfn_range(i, nid, p_start, p_end, p_nid)		\
 	for (i = -1, __next_mem_pfn_range(&i, nid, p_start, p_end, p_nid); \
 	     i >= 0; __next_mem_pfn_range(&i, nid, p_start, p_end, p_nid))
+
+/**
+ * for_each_mem_pfn_range_rev - early memory pfn range rev-iterator
+ * @i: an integer used as loop variable
+ * @nid: node selector, %NUMA_NO_NODE for all nodes
+ * @p_start: ptr to ulong for start pfn of the range, can be %NULL
+ * @p_end: ptr to ulong for end pfn of the range, can be %NULL
+ * @p_nid: ptr to int for nid of the range, can be %NULL
+ *
+ * Walks over configured memory ranges in reverse order.
+ */
+#define for_each_mem_pfn_range_rev(i, nid, p_start, p_end, p_nid)	\
+	for (i = (int)INT_MAX,						\
+	      __next_mem_pfn_range_rev(&i, nid, p_start, p_end, p_nid); \
+	     i != (int)INT_MAX;						\
+	      __next_mem_pfn_range_rev(&i, nid, p_start, p_end, p_nid))
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
 /**
diff --git a/mm/memblock.c b/mm/memblock.c
index 7608bc305936..79490005ecd6 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1075,7 +1075,7 @@ void __init_memblock __next_mem_range_rev(u64 *idx, int nid, ulong flags,
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 /*
- * Common iterator interface used to define for_each_mem_range().
+ * Common iterator interface used to define for_each_mem_pfn_range().
  */
 void __init_memblock __next_mem_pfn_range(int *idx, int nid,
 				unsigned long *out_start_pfn,
@@ -1105,6 +1105,43 @@ void __init_memblock __next_mem_pfn_range(int *idx, int nid,
 		*out_nid = r->nid;
 }
 
+/*
+ * Common rev-iterator interface used to define for_each_mem_pfn_range_rev().
+ */
+void __init_memblock __next_mem_pfn_range_rev(int *idx, int nid,
+				unsigned long *out_start_pfn,
+				unsigned long *out_end_pfn, int *out_nid)
+{
+	struct memblock_type *type = &memblock.memory;
+	struct memblock_region *r;
+
+	if (WARN_ONCE(nid == MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
+		nid = NUMA_NO_NODE;
+
+	if (*idx == (int)INT_MAX)
+		*idx = type->cnt;
+
+	while (--*idx >= 0) {
+		r = &type->regions[*idx];
+
+		if (PFN_UP(r->base) >= PFN_DOWN(r->base + r->size))
+			continue;
+		if (nid == NUMA_NO_NODE || nid == r->nid)
+			break;
+	}
+	if (*idx < 0) {
+		*idx = (int)INT_MAX;
+		return;
+	}
+
+	if (out_start_pfn)
+		*out_start_pfn = PFN_UP(r->base);
+	if (out_end_pfn)
+		*out_end_pfn = PFN_DOWN(r->base + r->size);
+	if (out_nid)
+		*out_nid = r->nid;
+}
+
 /**
  * memblock_set_node - set node ID on memblock regions
  * @base: base of area to set node ID for
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
