Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9C09D6B002A
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 23:48:14 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id t1-v6so820515plb.5
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 20:48:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y38-v6sor1204650plh.37.2018.03.27.20.48.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 20:48:13 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm/page_alloc: optimize find_min_pfn_for_node() by geting the minimal pfn directly
Date: Wed, 28 Mar 2018 11:47:52 +0800
Message-Id: <20180328034752.96146-1-richard.weiyang@gmail.com>
In-Reply-To: <20180327183757.f66f5fc200109c06b7a4b620@linux-foundation.org>
References: <20180327183757.f66f5fc200109c06b7a4b620@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, tj@kernel.org, linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

find_min_pfn_for_node() iterates on pfn range to find the minimum pfn for a
node, while this process could be optimized. The memblock_region in
memblock_type are already in ascending order, so the first one is the
minimal one.

For example, if there are 30 memory regions, the original version would
iterate all 30 regions, while the new version just need iterate a single
time.

This patch does a trivial optimization by adding first_mem_pfn() and use
this to get the minimal pfn directly.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

---
v2:
    * add first_mem_pfn() and use it to replace for_each_mem_pfn_ragne()
    * some more meaningful words in change log
---
 include/linux/memblock.h |  9 +++++++++
 mm/page_alloc.c          | 14 ++++++++------
 2 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 8be5077efb5f..22932f45538f 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -189,6 +189,15 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
 			  unsigned long *out_end_pfn, int *out_nid);
 unsigned long memblock_next_valid_pfn(unsigned long pfn, unsigned long max_pfn);
 
+/**
+ * first_mem_pfn - get the first memory pfn
+ * @i: an integer used as an indicator
+ * @nid: node selector, %MAX_NUMNODES for all nodes
+ * @p_first: ptr to ulong for first pfn of the range, can be %NULL
+ */
+#define first_mem_pfn(i, nid, p_first)				\
+	__next_mem_pfn_range(&i, nid, p_first, NULL, NULL)
+
 /**
  * for_each_mem_pfn_range - early memory pfn range iterator
  * @i: an integer used as loop variable
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 635d7dd29d7f..8c964dcc3a9e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6365,14 +6365,16 @@ unsigned long __init node_map_pfn_alignment(void)
 /* Find the lowest pfn for a node */
 static unsigned long __init find_min_pfn_for_node(int nid)
 {
-	unsigned long min_pfn = ULONG_MAX;
-	unsigned long start_pfn;
-	int i;
+	unsigned long min_pfn;
+	int i = -1;
 
-	for_each_mem_pfn_range(i, nid, &start_pfn, NULL, NULL)
-		min_pfn = min(min_pfn, start_pfn);
+	/*
+	 * The first pfn on nid node is the minimal one, as the pfn's are
+	 * stored in ascending order.
+	 */
+	first_mem_pfn(i, nid, &min_pfn);
 
-	if (min_pfn == ULONG_MAX) {
+	if (i == -1) {
 		pr_warn("Could not find start_pfn for node %d\n", nid);
 		return 0;
 	}
-- 
2.15.1
