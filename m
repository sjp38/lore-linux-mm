Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 69FC382F66
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 02:56:37 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id e7so53354834lfe.0
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 23:56:37 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id t187si1992737wma.147.2016.08.31.23.56.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Aug 2016 23:56:27 -0700 (PDT)
From: Zhen Lei <thunder.leizhen@huawei.com>
Subject: [PATCH v8 10/16] mm/memblock: add a new function memblock_alloc_near_nid
Date: Thu, 1 Sep 2016 14:55:01 +0800
Message-ID: <1472712907-12700-11-git-send-email-thunder.leizhen@huawei.com>
In-Reply-To: <1472712907-12700-1-git-send-email-thunder.leizhen@huawei.com>
References: <1472712907-12700-1-git-send-email-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank
 Rowand <frowand.list@gmail.com>, devicetree <devicetree@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
Cc: Zefan Li <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>, Tianhong
 Ding <dingtianhong@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Zhen Lei <thunder.leizhen@huawei.com>

If HAVE_MEMORYLESS_NODES is selected, and some memoryless numa nodes are
actually exist. The percpu variable areas and numa control blocks of that
memoryless numa nodes must be allocated from the nearest available node
to improve performance.

Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
---
 include/linux/memblock.h |  1 +
 mm/memblock.c            | 28 ++++++++++++++++++++++++++++
 2 files changed, 29 insertions(+)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 2925da2..8e866e0 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -290,6 +290,7 @@ static inline int memblock_get_region_node(const struct memblock_region *r)

 phys_addr_t memblock_alloc_nid(phys_addr_t size, phys_addr_t align, int nid);
 phys_addr_t memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid);
+phys_addr_t memblock_alloc_near_nid(phys_addr_t size, phys_addr_t align, int nid);

 phys_addr_t memblock_alloc(phys_addr_t size, phys_addr_t align);

diff --git a/mm/memblock.c b/mm/memblock.c
index 483197e..6578fff 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1189,6 +1189,34 @@ again:
 	return ret;
 }

+phys_addr_t __init memblock_alloc_near_nid(phys_addr_t size, phys_addr_t align, int nid)
+{
+	int i, best_nid, distance;
+	u64 pa;
+	DECLARE_BITMAP(nodes_map, MAX_NUMNODES);
+
+	bitmap_zero(nodes_map, MAX_NUMNODES);
+
+find_nearest_node:
+	best_nid = NUMA_NO_NODE;
+	distance = INT_MAX;
+
+	for_each_clear_bit(i, nodes_map, MAX_NUMNODES)
+		if (node_distance(nid, i) < distance) {
+			best_nid = i;
+			distance = node_distance(nid, i);
+		}
+
+	pa = memblock_alloc_nid(size, align, best_nid);
+	if (!pa) {
+		BUG_ON(best_nid == NUMA_NO_NODE);
+		bitmap_set(nodes_map, best_nid, 1);
+		goto find_nearest_node;
+	}
+
+	return pa;
+}
+
 phys_addr_t __init __memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
 {
 	return memblock_alloc_base_nid(size, align, max_addr, NUMA_NO_NODE,
--
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
