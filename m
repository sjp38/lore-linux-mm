Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 65F1482F66
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 02:56:55 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id le9so139863717pab.0
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 23:56:55 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id r71si4108841pfb.169.2016.08.31.23.56.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Aug 2016 23:56:54 -0700 (PDT)
From: Zhen Lei <thunder.leizhen@huawei.com>
Subject: [PATCH v8 13/16] arm64/numa: remove the limitation that cpu0 must bind to node0
Date: Thu, 1 Sep 2016 14:55:04 +0800
Message-ID: <1472712907-12700-14-git-send-email-thunder.leizhen@huawei.com>
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

1. Remove the old binding code.
2. Read the nid of cpu0 from dts.
3. Fallback the nid of cpu0 to 0 when numa=off is set in bootargs.

Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
---
 arch/arm64/kernel/smp.c |  1 +
 arch/arm64/mm/numa.c    | 16 ++++++++++------
 2 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/arch/arm64/kernel/smp.c b/arch/arm64/kernel/smp.c
index d93d433..4879085 100644
--- a/arch/arm64/kernel/smp.c
+++ b/arch/arm64/kernel/smp.c
@@ -619,6 +619,7 @@ static void __init of_parse_and_init_cpus(void)
 			}

 			bootcpu_valid = true;
+			early_map_cpu_to_node(0, of_node_to_nid(dn));

 			/*
 			 * cpu_logical_map has already been
diff --git a/arch/arm64/mm/numa.c b/arch/arm64/mm/numa.c
index 72f4539..ef7e336 100644
--- a/arch/arm64/mm/numa.c
+++ b/arch/arm64/mm/numa.c
@@ -116,16 +116,24 @@ static void __init setup_node_to_cpumask_map(void)
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

 	cpu_to_node_map[cpu] = nid;
+
+	/*
+	 * We should set the numa node of cpu0 as soon as possible, because it
+	 * has already been set up online before. cpu_to_node(0) will soon be
+	 * called.
+	 */
+	if (!cpu)
+		set_cpu_numa_node(cpu, nid);
 }

 #ifdef CONFIG_HAVE_SETUP_PER_CPU_AREA
@@ -394,10 +402,6 @@ static int __init numa_init(int (*init_func)(void))

 	setup_node_to_cpumask_map();

-	/* init boot processor */
-	cpu_to_node_map[0] = 0;
-	map_cpu_to_node(0, 0);
-
 	return 0;
 }

--
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
