Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id DCAAC6B0261
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 23:02:43 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id f78so2321691oih.7
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:02:43 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id f20si6906744otc.75.2016.10.24.20.02.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 20:02:43 -0700 (PDT)
From: Zhen Lei <thunder.leizhen@huawei.com>
Subject: [PATCH 1/2] mm/memblock: prepare a capability to support memblock near alloc
Date: Tue, 25 Oct 2016 10:59:17 +0800
Message-ID: <1477364358-10620-2-git-send-email-thunder.leizhen@huawei.com>
In-Reply-To: <1477364358-10620-1-git-send-email-thunder.leizhen@huawei.com>
References: <1477364358-10620-1-git-send-email-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
Cc: Zefan Li <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Zhen Lei <thunder.leizhen@huawei.com>

If HAVE_MEMORYLESS_NODES is selected, and some memoryless numa nodes are
actually exist. The percpu variable areas and numa control blocks of that
memoryless numa nodes need to be allocated from the nearest available
node to improve performance.

Although memblock_alloc_try_nid and memblock_virt_alloc_try_nid try the
specified nid at the first time, but if that allocation failed it will
directly drop to use NUMA_NO_NODE. This mean any nodes maybe possible at
the second time.

To compatible the above old scene, I use a marco node_distance_ready to
control it. By default, the marco node_distance_ready is not defined in
any platforms, the above mentioned functions will work as normal as
before. Otherwise, they will try the nearest node first.

Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
---
 mm/memblock.c | 76 ++++++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 65 insertions(+), 11 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 7608bc3..556bbd2 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1213,9 +1213,71 @@ phys_addr_t __init memblock_alloc(phys_addr_t size, phys_addr_t align)
 	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
 }

+#ifndef node_distance_ready
+#define node_distance_ready()		0
+#endif
+
+static phys_addr_t __init memblock_alloc_near_nid(phys_addr_t size,
+					phys_addr_t align, phys_addr_t start,
+					phys_addr_t end, int nid, ulong flags,
+					int alloc_func_type)
+{
+	int nnid, round = 0;
+	u64 pa;
+	DECLARE_BITMAP(nodes_map, MAX_NUMNODES);
+
+	bitmap_zero(nodes_map, MAX_NUMNODES);
+
+again:
+	/*
+	 * There are total 4 cases:
+	 * <nid == NUMA_NO_NODE>
+	 *   1)2) node_distance_ready || !node_distance_ready
+	 *	Round 1, nnid = nid = NUMA_NO_NODE;
+	 * <nid != NUMA_NO_NODE>
+	 *   3) !node_distance_ready
+	 *	Round 1, nnid = nid;
+	 *    ::Round 2, currently only applicable for alloc_func_type = <0>
+	 *	Round 2, nnid = NUMA_NO_NODE;
+	 *   4) node_distance_ready
+	 *	Round 1, LOCAL_DISTANCE, nnid = nid;
+	 *	Round ?, nnid = nearest nid;
+	 */
+	if (!node_distance_ready() || (nid == NUMA_NO_NODE)) {
+		nnid = (++round == 1) ? nid : NUMA_NO_NODE;
+	} else {
+		int i, distance = INT_MAX;
+
+		for_each_clear_bit(i, nodes_map, MAX_NUMNODES)
+			if (node_distance(nid, i) < distance) {
+				nnid = i;
+				distance = node_distance(nid, i);
+			}
+	}
+
+	switch (alloc_func_type) {
+	case 0:
+		pa = memblock_find_in_range_node(size, align, start, end, nnid, flags);
+		break;
+
+	case 1:
+	default:
+		pa = memblock_alloc_nid(size, align, nnid);
+		if (!node_distance_ready())
+			return pa;
+	}
+
+	if (!pa && (nnid != NUMA_NO_NODE)) {
+		bitmap_set(nodes_map, nnid, 1);
+		goto again;
+	}
+
+	return pa;
+}
+
 phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid)
 {
-	phys_addr_t res = memblock_alloc_nid(size, align, nid);
+	phys_addr_t res = memblock_alloc_near_nid(size, align, 0, 0, nid, 0, 1);

 	if (res)
 		return res;
@@ -1276,19 +1338,11 @@ static void * __init memblock_virt_alloc_internal(
 		max_addr = memblock.current_limit;

 again:
-	alloc = memblock_find_in_range_node(size, align, min_addr, max_addr,
-					    nid, flags);
+	alloc = memblock_alloc_near_nid(size, align, min_addr, max_addr,
+					    nid, flags, 0);
 	if (alloc)
 		goto done;

-	if (nid != NUMA_NO_NODE) {
-		alloc = memblock_find_in_range_node(size, align, min_addr,
-						    max_addr, NUMA_NO_NODE,
-						    flags);
-		if (alloc)
-			goto done;
-	}
-
 	if (min_addr) {
 		min_addr = 0;
 		goto again;
--
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
