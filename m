Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 510916B03A0
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 07:55:04 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id i18so9791524wrb.21
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 04:55:04 -0700 (PDT)
Received: from mail-wr0-f196.google.com (mail-wr0-f196.google.com. [209.85.128.196])
        by mx.google.com with ESMTPS id s80si11783378wma.18.2017.03.30.04.55.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 04:55:03 -0700 (PDT)
Received: by mail-wr0-f196.google.com with SMTP id k6so10133258wre.3
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 04:55:02 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/6] mm, tile: drop arch_{add,remove}_memory
Date: Thu, 30 Mar 2017 13:54:50 +0200
Message-Id: <20170330115454.32154-3-mhocko@kernel.org>
In-Reply-To: <20170330115454.32154-1-mhocko@kernel.org>
References: <20170330115454.32154-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Chris Metcalf <cmetcalf@mellanox.com>

From: Michal Hocko <mhocko@suse.com>

these functions are unreachable because tile doesn't support memory
hotplug becasuse it doesn't select ARCH_ENABLE_MEMORY_HOTPLUG nor
it supports SPARSEMEM.

This code hasn't been compiled for a while obviously because nobody has
noticed that __add_pages has a different signature since 2009.

Cc: Chris Metcalf <cmetcalf@mellanox.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/tile/mm/init.c | 30 ------------------------------
 1 file changed, 30 deletions(-)

diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
index 3a97e4d7205c..5f757e04bcd2 100644
--- a/arch/tile/mm/init.c
+++ b/arch/tile/mm/init.c
@@ -857,36 +857,6 @@ void __init mem_init(void)
 #endif
 }
 
-/*
- * this is for the non-NUMA, single node SMP system case.
- * Specifically, in the case of x86, we will always add
- * memory to the highmem for now.
- */
-#ifndef CONFIG_NEED_MULTIPLE_NODES
-int arch_add_memory(u64 start, u64 size, bool for_device)
-{
-	struct pglist_data *pgdata = &contig_page_data;
-	struct zone *zone = pgdata->node_zones + MAX_NR_ZONES-1;
-	unsigned long start_pfn = start >> PAGE_SHIFT;
-	unsigned long nr_pages = size >> PAGE_SHIFT;
-
-	return __add_pages(zone, start_pfn, nr_pages);
-}
-
-int remove_memory(u64 start, u64 size)
-{
-	return -EINVAL;
-}
-
-#ifdef CONFIG_MEMORY_HOTREMOVE
-int arch_remove_memory(u64 start, u64 size)
-{
-	/* TODO */
-	return -EBUSY;
-}
-#endif
-#endif
-
 struct kmem_cache *pgd_cache;
 
 void __init pgtable_cache_init(void)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
