Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 61BBD90001B
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:28:22 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part1 PATCH v5 18/22] x86, mm, numa: Add early_initmem_init() stub
Date: Thu, 13 Jun 2013 21:03:05 +0800
Message-Id: <1371128589-8953-19-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Jacob Shin <jacob.shin@amd.com>

From: Yinghai Lu <yinghai@kernel.org>

Introduce early_initmem_init() to call early_x86_numa_init(),
which will be used to parse numa info earlier.

Later will call init_mem_mapping for all the nodes.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Jacob Shin <jacob.shin@amd.com>
Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
Tested-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/include/asm/page_types.h |    1 +
 arch/x86/kernel/setup.c           |    1 +
 arch/x86/mm/init.c                |    6 ++++++
 arch/x86/mm/numa.c                |    7 +++++--
 4 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/page_types.h b/arch/x86/include/asm/page_types.h
index b012b82..d04dd8c 100644
--- a/arch/x86/include/asm/page_types.h
+++ b/arch/x86/include/asm/page_types.h
@@ -55,6 +55,7 @@ bool pfn_range_is_mapped(unsigned long start_pfn, unsigned long end_pfn);
 extern unsigned long init_memory_mapping(unsigned long start,
 					 unsigned long end);
 
+void early_initmem_init(void);
 extern void initmem_init(void);
 
 #endif	/* !__ASSEMBLY__ */
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index d11b1b7..301165e 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1162,6 +1162,7 @@ void __init setup_arch(char **cmdline_p)
 
 	early_acpi_boot_init();
 
+	early_initmem_init();
 	initmem_init();
 	memblock_find_dma_reserve();
 
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 8554656..3c21f16 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -467,6 +467,12 @@ void __init init_mem_mapping(void)
 	early_memtest(0, max_pfn_mapped << PAGE_SHIFT);
 }
 
+#ifndef CONFIG_NUMA
+void __init early_initmem_init(void)
+{
+}
+#endif
+
 /*
  * devmem_is_allowed() checks to see if /dev/mem access to a certain address
  * is valid. The argument is a physical page number.
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 630e09f..7d76936 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -665,13 +665,16 @@ static void __init early_x86_numa_init(void)
 	numa_init(dummy_numa_init);
 }
 
+void __init early_initmem_init(void)
+{
+	early_x86_numa_init();
+}
+
 void __init x86_numa_init(void)
 {
 	int i, nid;
 	struct numa_meminfo *mi = &numa_meminfo;
 
-	early_x86_numa_init();
-
 #ifdef CONFIG_ACPI_NUMA
 	if (srat_used)
 		x86_acpi_numa_init_slit();
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
