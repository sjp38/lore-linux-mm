Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id EA84E82F66
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 02:56:45 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 33so53320470lfw.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 23:56:45 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id q1si4170666wja.276.2016.08.31.23.56.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Aug 2016 23:56:30 -0700 (PDT)
From: Zhen Lei <thunder.leizhen@huawei.com>
Subject: [PATCH v8 11/16] arm64/numa: support HAVE_MEMORYLESS_NODES
Date: Thu, 1 Sep 2016 14:55:02 +0800
Message-ID: <1472712907-12700-12-git-send-email-thunder.leizhen@huawei.com>
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

Some numa nodes may have no memory. For example:
1. cpu0 on node0
2. cpu1 on node1
3. device0 access the momory from node0 and node1 take the same time.

So, we can not simply classify device0 to node0 or node1, but we can
define a node2 which distances to node0 and node1 are the same.

Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
---
 arch/arm64/Kconfig   |  4 ++++
 arch/arm64/mm/numa.c | 11 ++++++-----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 2815af6..3a2b6ed 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -611,6 +611,10 @@ config NEED_PER_CPU_EMBED_FIRST_CHUNK
 	def_bool y
 	depends on NUMA

+config HAVE_MEMORYLESS_NODES
+	def_bool y
+	depends on NUMA
+
 source kernel/Kconfig.preempt
 source kernel/Kconfig.hz

diff --git a/arch/arm64/mm/numa.c b/arch/arm64/mm/numa.c
index 087064d..891bdaa 100644
--- a/arch/arm64/mm/numa.c
+++ b/arch/arm64/mm/numa.c
@@ -149,10 +149,11 @@ static int __init pcpu_cpu_distance(unsigned int from, unsigned int to)
 static void * __init pcpu_fc_alloc(unsigned int cpu, size_t size,
 				       size_t align)
 {
-	int nid = early_cpu_to_node(cpu);
+	phys_addr_t alloc;

-	return  memblock_virt_alloc_try_nid(size, align,
-			__pa(MAX_DMA_ADDRESS), MEMBLOCK_ALLOC_ACCESSIBLE, nid);
+	alloc = memblock_alloc_near_nid(size, align, early_cpu_to_node(cpu));
+
+	return phys_to_virt(alloc);
 }

 static void __init pcpu_fc_free(void *ptr, size_t size)
@@ -222,7 +223,7 @@ static void __init setup_node_data(int nid, u64 start_pfn, u64 end_pfn)
 	pr_info("Initmem setup node %d [mem %#010Lx-%#010Lx]\n",
 		nid, start_pfn << PAGE_SHIFT, (end_pfn << PAGE_SHIFT) - 1);

-	nd_pa = memblock_alloc_try_nid(nd_size, SMP_CACHE_BYTES, nid);
+	nd_pa = memblock_alloc_near_nid(nd_size, SMP_CACHE_BYTES, nid);
 	nd = __va(nd_pa);

 	/* report and initialize */
@@ -232,7 +233,7 @@ static void __init setup_node_data(int nid, u64 start_pfn, u64 end_pfn)
 	if (tnid != nid)
 		pr_info("NODE_DATA(%d) on node %d\n", nid, tnid);

-	node_data[nid] = nd;
+	NODE_DATA(nid) = nd;
 	memset(NODE_DATA(nid), 0, sizeof(pg_data_t));
 	NODE_DATA(nid)->node_id = nid;
 	NODE_DATA(nid)->node_start_pfn = start_pfn;
--
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
