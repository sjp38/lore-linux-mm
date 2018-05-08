Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3A3426B000D
	for <linux-mm@kvack.org>; Mon,  7 May 2018 21:48:22 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id ay8-v6so859517plb.9
        for <linux-mm@kvack.org>; Mon, 07 May 2018 18:48:22 -0700 (PDT)
Received: from dev31.localdomain ([103.244.59.4])
        by mx.google.com with ESMTP id g77si24389439pfa.304.2018.05.07.18.48.19
        for <linux-mm@kvack.org>;
        Mon, 07 May 2018 18:48:19 -0700 (PDT)
From: Huaisheng Ye <yehs1@lenovo.com>
Subject: [RFC PATCH v1 4/6] arch/x86/kernel: mark NVDIMM regions from e820_table
Date: Tue,  8 May 2018 10:00:16 +0800
Message-Id: <1525744818-110207-5-git-send-email-yehs1@lenovo.com>
In-Reply-To: <1525744818-110207-1-git-send-email-yehs1@lenovo.com>
References: <1525744818-110207-1-git-send-email-yehs1@lenovo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: mhocko@suse.com, willy@infradead.org, vbabka@suse.cz, mgorman@techsingularity.net, pasha.tatashin@oracle.com, alexander.levin@verizon.com, hannes@cmpxchg.org, penguin-kernel@I-love.SAKURA.ne.jp, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, Huaisheng Ye <yehs1@lenovo.com>

During e820__memblock_setup memblock gets entries with type
E820_TYPE_RAM, E820_TYPE_RESERVED_KERN and E820_TYPE_PMEM from
e820_table, then marks NVDIMM regions with flag MEMBLOCK_NVDIMM.

Create function as e820__end_of_nvm_pfn to calculate max_pfn with
NVDIMM region, while zone_sizes_init needs max_pfn to get
arch_zone_lowest/highest_possible_pfn. During free_area_init_nodes,
the possible pfns need to be recalculated for ZONE_NVM.

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Signed-off-by: Ocean He <hehy1@lenovo.com>
---
 arch/x86/include/asm/e820/api.h |  3 +++
 arch/x86/kernel/e820.c          | 20 +++++++++++++++++++-
 arch/x86/kernel/setup.c         |  8 ++++++++
 3 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/e820/api.h b/arch/x86/include/asm/e820/api.h
index 62be73b..b8006c3 100644
--- a/arch/x86/include/asm/e820/api.h
+++ b/arch/x86/include/asm/e820/api.h
@@ -22,6 +22,9 @@
 extern void e820__update_table_print(void);
 
 extern unsigned long e820__end_of_ram_pfn(void);
+#ifdef CONFIG_ZONE_NVM
+extern unsigned long e820__end_of_nvm_pfn(void);
+#endif
 extern unsigned long e820__end_of_low_ram_pfn(void);
 
 extern u64  e820__memblock_alloc_reserved(u64 size, u64 align);
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 6a2cb14..1bf7876 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -840,6 +840,13 @@ unsigned long __init e820__end_of_ram_pfn(void)
 	return e820_end_pfn(MAX_ARCH_PFN, E820_TYPE_RAM);
 }
 
+#ifdef CONFIG_ZONE_NVM
+unsigned long __init e820__end_of_nvm_pfn(void)
+{
+	return e820_end_pfn(MAX_ARCH_PFN, E820_TYPE_PMEM);
+}
+#endif
+
 unsigned long __init e820__end_of_low_ram_pfn(void)
 {
 	return e820_end_pfn(1UL << (32 - PAGE_SHIFT), E820_TYPE_RAM);
@@ -1264,11 +1271,22 @@ void __init e820__memblock_setup(void)
 		end = entry->addr + entry->size;
 		if (end != (resource_size_t)end)
 			continue;
-
+#ifdef CONFIG_ZONE_NVM
+		if (entry->type != E820_TYPE_RAM && entry->type != E820_TYPE_RESERVED_KERN &&
+								entry->type != E820_TYPE_PMEM)
+#else
 		if (entry->type != E820_TYPE_RAM && entry->type != E820_TYPE_RESERVED_KERN)
+#endif
 			continue;
 
 		memblock_add(entry->addr, entry->size);
+
+#ifdef CONFIG_ZONE_NVM
+		if (entry->type == E820_TYPE_PMEM) {
+			/* Mark this region with PMEM flags */
+			memblock_mark_nvdimm(entry->addr, entry->size);
+		}
+#endif
 	}
 
 	/* Throw away partial pages: */
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 6285697..305975b 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1031,7 +1031,15 @@ void __init setup_arch(char **cmdline_p)
 	 * partially used pages are not usable - thus
 	 * we are rounding upwards:
 	 */
+#ifdef CONFIG_ZONE_NVM
+	max_pfn = e820__end_of_nvm_pfn();
+	if (!max_pfn) {
+		printk(KERN_INFO "No physical NVDIMM has been found\n");
+		max_pfn = e820__end_of_ram_pfn();
+	}
+#else
 	max_pfn = e820__end_of_ram_pfn();
+#endif
 
 	/* update e820 for memory not covered by WB MTRRs */
 	mtrr_bp_init();
-- 
1.8.3.1
