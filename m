Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4D44E6B025E
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 02:56:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u81so54300398wmu.3
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 23:56:34 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id v5si723760wjv.113.2016.08.31.23.56.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Aug 2016 23:56:27 -0700 (PDT)
From: Zhen Lei <thunder.leizhen@huawei.com>
Subject: [PATCH v8 00/16] fix some type infos and bugs for arm64/of numa
Date: Thu, 1 Sep 2016 14:54:51 +0800
Message-ID: <1472712907-12700-1-git-send-email-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank
 Rowand <frowand.list@gmail.com>, devicetree <devicetree@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
Cc: Zefan Li <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>, Tianhong
 Ding <dingtianhong@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Zhen Lei <thunder.leizhen@huawei.com>

v7 -> v8:
Updated patches according to Will Deacon's review comments, thanks.

The changed patches is: 3, 5, 8, 9, 10, 11, 12, 13, 15
Patch 3 requires an ack from Rob Herring.
Patch 10 requires an ack from linux-mm.

Hi, Will:
Something should still be clarified:
Patch 5, I modified it according to my last reply. BTW, The last sentence
         "srat_disabled() ? -EINVAL : 0" of arm64_acpi_numa_init should be moved
         into acpi_numa_init, I think.
         
Patch 9, I still leave the code in arch/arm64.
         1) the implementation of setup_per_cpu_areas on all platforms are different.
         2) Although my implementation referred to PowerPC, but still something different.

Patch 15, I modified the description again. Can you take a look at it? If this patch is
	  dropped, the patch 14 should also be dropped.

Patch 16, How many times the function node_distance to be called rely on the APP(need many tasks
          to be scheduled), I have not prepared yet, so I give up this patch as your advise. 

v6 -> v7:
Fix a bug for this patch series when "numa=off" was set in bootargs, this
modification only impact patch 12.

Please refer https://lkml.org/lkml/2016/8/23/249 for more details.

@@ -119,13 +115,13 @@ static void __init setup_node_to_cpumask_map(void)
  */
 void numa_store_cpu_info(unsigned int cpu)
 {
-	map_cpu_to_node(cpu, numa_off ? 0 : cpu_to_node_map[cpu]);
+	map_cpu_to_node(cpu, cpu_to_node_map[cpu]);
 }

 void __init early_map_cpu_to_node(unsigned int cpu, int nid)
 {
 	/* fallback to node 0 */
-	if (nid < 0 || nid >= MAX_NUMNODES)
+	if (nid < 0 || nid >= MAX_NUMNODES || numa_off)
 		nid = 0;

v5 -> v6:
Move memblk nid check from arch/arm64/mm/numa.c into drivers/of/of_numa.c,
because this check is arch independent.

This modification only related to patch 3, but impacted the contents of patch 7 and 8,
other patches have no change.

v4 -> v5:
This version has no code changes, just add "Acked-by: Rob Herring <robh@kernel.org>"
into patches 1, 2, 4, 6, 7, 13, 14. Because these patches rely on some acpi numa
patches, and the latter had not been upstreamed in 4.7, but upstreamed in 4.8-rc1,
so I resend my patches again.

v3 -> v4:
1. Packed three patches of Kefeng Wang, patch6-8.
2. Add 6 new patches(9-15) to enhance the numa on arm64.

v2 -> v3:
1. Adjust patch2 and patch5 according to Matthias Brugger's advice, to make the
   patches looks more well. The final code have no change. 

v1 -> v2:
1. Base on https://lkml.org/lkml/2016/5/24/679
2. Rewrote of_numa_parse_memory_nodes according to Rob Herring's advice. So that it looks more clear.
3. Rewrote patch 5 because some scenes were not considered before.

Kefeng Wang (3):
  of_numa: Use of_get_next_parent to simplify code
  of_numa: Use pr_fmt()
  arm64: numa: Use pr_fmt()

Zhen Lei (13):
  of/numa: remove a duplicated pr_debug information
  of/numa: fix a memory@ node can only contains one memory block
  of/numa: add nid check for memory block
  of/numa: remove a duplicated warning
  arm64/numa: avoid inconsistent information to be printed
  arm64/numa: support HAVE_SETUP_PER_CPU_AREA
  mm/memblock: add a new function memblock_alloc_near_nid
  arm64/numa: support HAVE_MEMORYLESS_NODES
  arm64/numa: remove some useless code
  arm64/numa: remove the limitation that cpu0 must bind to node0
  of/numa: remove the constraint on the distances of node pairs
  Documentation: remove the constraint on the distances of node pairs
  arm64/numa: define numa_distance as array to simplify code

 Documentation/devicetree/bindings/numa.txt |  12 +-
 arch/arm64/Kconfig                         |  12 ++
 arch/arm64/include/asm/numa.h              |   1 -
 arch/arm64/kernel/acpi_numa.c              |   4 +-
 arch/arm64/kernel/smp.c                    |   1 +
 arch/arm64/mm/numa.c                       | 190 ++++++++++++++---------------
 drivers/of/of_numa.c                       |  88 +++++++------
 include/linux/memblock.h                   |   1 +
 mm/memblock.c                              |  28 +++++
 9 files changed, 184 insertions(+), 153 deletions(-)

--
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
