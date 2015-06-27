Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0DB4A6B006C
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 22:32:52 -0400 (EDT)
Received: by igcsj18 with SMTP id sj18so44481627igc.1
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 19:32:51 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id m5si671967igx.2.2015.06.26.19.32.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 26 Jun 2015 19:32:51 -0700 (PDT)
Message-ID: <558E0974.6060206@huawei.com>
Date: Sat, 27 Jun 2015 10:24:52 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC v2 PATCH 3/8] mm: find mirrored memory in memblock
References: <558E084A.60900@huawei.com>
In-Reply-To: <558E084A.60900@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, leon@leon.nu, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Add a macro for_each_mirror_pfn_range() to find mirrored memory in memblock.
This patch is based on Tony's patchset "Find mirrored memory, use for boot time
allocations"

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 include/linux/memblock.h | 25 ++++++++++++++++++++++---
 mm/memblock.c            |  6 +++++-
 2 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 0215ffd..97f71ca 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -171,7 +171,8 @@ static inline bool memblock_is_mirror(struct memblock_region *m)
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 int memblock_search_pfn_nid(unsigned long pfn, unsigned long *start_pfn,
 			    unsigned long  *end_pfn);
-void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
+void __next_mem_pfn_range(int *idx, int nid, ulong flags,
+			  unsigned long *out_start_pfn,
 			  unsigned long *out_end_pfn, int *out_nid);
 
 /**
@@ -185,8 +186,26 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
  * Walks over configured memory ranges.
  */
 #define for_each_mem_pfn_range(i, nid, p_start, p_end, p_nid)		\
-	for (i = -1, __next_mem_pfn_range(&i, nid, p_start, p_end, p_nid); \
-	     i >= 0; __next_mem_pfn_range(&i, nid, p_start, p_end, p_nid))
+	for (i = -1, __next_mem_pfn_range(&i, nid, MEMBLOCK_NONE,	\
+						p_start, p_end, p_nid); \
+	     i >= 0; __next_mem_pfn_range(&i, nid, MEMBLOCK_NONE,	\
+						p_start, p_end, p_nid))
+
+/**
+ * for_each_mirror_pfn_range - early mirrored memory pfn range iterator
+ * @i: an integer used as loop variable
+ * @nid: node selector, %MAX_NUMNODES for all nodes
+ * @p_start: ptr to ulong for start pfn of the range, can be %NULL
+ * @p_end: ptr to ulong for end pfn of the range, can be %NULL
+ * @p_nid: ptr to int for nid of the range, can be %NULL
+ *
+ * Walks over configured mirrored memory ranges.
+ */
+#define for_each_mirror_pfn_range(i, nid, p_start, p_end, p_nid)	\
+	for (i = -1, __next_mem_pfn_range(&i, nid, MEMBLOCK_MIRROR,	\
+						p_start, p_end, p_nid);	\
+	     i >= 0; __next_mem_pfn_range(&i, nid, MEMBLOCK_MIRROR,	\
+						p_start, p_end, p_nid))
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
 /**
diff --git a/mm/memblock.c b/mm/memblock.c
index 1b444c7..7612876 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1040,7 +1040,7 @@ void __init_memblock __next_mem_range_rev(u64 *idx, int nid, ulong flags,
 /*
  * Common iterator interface used to define for_each_mem_range().
  */
-void __init_memblock __next_mem_pfn_range(int *idx, int nid,
+void __init_memblock __next_mem_pfn_range(int *idx, int nid, ulong flags,
 				unsigned long *out_start_pfn,
 				unsigned long *out_end_pfn, int *out_nid)
 {
@@ -1050,6 +1050,10 @@ void __init_memblock __next_mem_pfn_range(int *idx, int nid,
 	while (++*idx < type->cnt) {
 		r = &type->regions[*idx];
 
+		/* if we want mirror memory skip non-mirror memory regions */
+		if ((flags & MEMBLOCK_MIRROR) && !memblock_is_mirror(r))
+			continue;
+
 		if (PFN_UP(r->base) >= PFN_DOWN(r->base + r->size))
 			continue;
 		if (nid == MAX_NUMNODES || nid == r->nid)
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
