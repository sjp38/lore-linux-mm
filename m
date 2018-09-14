Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id DD2598E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:13:53 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id c46-v6so3504170otd.12
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 05:13:53 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k5-v6si3649754oih.2.2018.09.14.05.13.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 05:13:52 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8EC5McT144953
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:13:51 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mgcfxgw4p-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:13:51 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 14 Sep 2018 13:13:48 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 27/30] mm: remove nobootmem
Date: Fri, 14 Sep 2018 15:10:42 +0300
In-Reply-To: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536927045-23536-28-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, "David S. Miller" <davem@davemloft.net>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jonas Bonn <jonas@southpole.se>, Jonathan Corbet <corbet@lwn.net>, Ley Foon Tan <lftan@altera.com>, Mark Salter <msalter@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Palmer Dabbelt <palmer@sifive.com>, Paul Burton <paul.burton@mips.com>, Richard Kuo <rkuo@codeaurora.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Serge Semin <fancer.lancer@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, Mike Rapoport <rppt@linux.vnet.ibm.com>

Move a few remaining functions from nobootmem.c to memblock.c and remove
nobootmem

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/Makefile    |   1 -
 mm/memblock.c  | 104 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/nobootmem.c | 128 ---------------------------------------------------------
 3 files changed, 104 insertions(+), 129 deletions(-)
 delete mode 100644 mm/nobootmem.c

diff --git a/mm/Makefile b/mm/Makefile
index ca3c844..d210cc9 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -42,7 +42,6 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   debug.o $(mmu-y)
 
 obj-y += init-mm.o
-obj-y += nobootmem.o
 obj-y += memblock.o
 
 ifdef CONFIG_MMU
diff --git a/mm/memblock.c b/mm/memblock.c
index a2cd61d..4591f38 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -82,6 +82,16 @@
  * initialization compltes.
  */
 
+#ifndef CONFIG_NEED_MULTIPLE_NODES
+struct pglist_data __refdata contig_page_data;
+EXPORT_SYMBOL(contig_page_data);
+#endif
+
+unsigned long max_low_pfn;
+unsigned long min_low_pfn;
+unsigned long max_pfn;
+unsigned long long max_possible_pfn;
+
 static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
 static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
 #ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
@@ -1929,6 +1939,100 @@ static int __init early_memblock(char *p)
 }
 early_param("memblock", early_memblock);
 
+static void __init __free_pages_memory(unsigned long start, unsigned long end)
+{
+	int order;
+
+	while (start < end) {
+		order = min(MAX_ORDER - 1UL, __ffs(start));
+
+		while (start + (1UL << order) > end)
+			order--;
+
+		memblock_free_pages(pfn_to_page(start), start, order);
+
+		start += (1UL << order);
+	}
+}
+
+static unsigned long __init __free_memory_core(phys_addr_t start,
+				 phys_addr_t end)
+{
+	unsigned long start_pfn = PFN_UP(start);
+	unsigned long end_pfn = min_t(unsigned long,
+				      PFN_DOWN(end), max_low_pfn);
+
+	if (start_pfn >= end_pfn)
+		return 0;
+
+	__free_pages_memory(start_pfn, end_pfn);
+
+	return end_pfn - start_pfn;
+}
+
+static unsigned long __init free_low_memory_core_early(void)
+{
+	unsigned long count = 0;
+	phys_addr_t start, end;
+	u64 i;
+
+	memblock_clear_hotplug(0, -1);
+
+	for_each_reserved_mem_region(i, &start, &end)
+		reserve_bootmem_region(start, end);
+
+	/*
+	 * We need to use NUMA_NO_NODE instead of NODE_DATA(0)->node_id
+	 *  because in some case like Node0 doesn't have RAM installed
+	 *  low ram will be on Node1
+	 */
+	for_each_free_mem_range(i, NUMA_NO_NODE, MEMBLOCK_NONE, &start, &end,
+				NULL)
+		count += __free_memory_core(start, end);
+
+	return count;
+}
+
+static int reset_managed_pages_done __initdata;
+
+void reset_node_managed_pages(pg_data_t *pgdat)
+{
+	struct zone *z;
+
+	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
+		z->managed_pages = 0;
+}
+
+void __init reset_all_zones_managed_pages(void)
+{
+	struct pglist_data *pgdat;
+
+	if (reset_managed_pages_done)
+		return;
+
+	for_each_online_pgdat(pgdat)
+		reset_node_managed_pages(pgdat);
+
+	reset_managed_pages_done = 1;
+}
+
+/**
+ * memblock_free_all - release free pages to the buddy allocator
+ *
+ * Return: the number of pages actually released.
+ */
+unsigned long __init memblock_free_all(void)
+{
+	unsigned long pages;
+
+	reset_all_zones_managed_pages();
+
+	pages = free_low_memory_core_early();
+	totalram_pages += pages;
+
+	return pages;
+}
+
 #if defined(CONFIG_DEBUG_FS) && !defined(CONFIG_ARCH_DISCARD_MEMBLOCK)
 
 static int memblock_debug_show(struct seq_file *m, void *private)
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
deleted file mode 100644
index 9608bc5..0000000
--- a/mm/nobootmem.c
+++ /dev/null
@@ -1,128 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- *  bootmem - A boot-time physical memory allocator and configurator
- *
- *  Copyright (C) 1999 Ingo Molnar
- *                1999 Kanoj Sarcar, SGI
- *                2008 Johannes Weiner
- *
- * Access to this subsystem has to be serialized externally (which is true
- * for the boot process anyway).
- */
-#include <linux/init.h>
-#include <linux/pfn.h>
-#include <linux/slab.h>
-#include <linux/export.h>
-#include <linux/kmemleak.h>
-#include <linux/range.h>
-#include <linux/memblock.h>
-#include <linux/bootmem.h>
-
-#include <asm/bug.h>
-#include <asm/io.h>
-
-#include "internal.h"
-
-#ifndef CONFIG_NEED_MULTIPLE_NODES
-struct pglist_data __refdata contig_page_data;
-EXPORT_SYMBOL(contig_page_data);
-#endif
-
-unsigned long max_low_pfn;
-unsigned long min_low_pfn;
-unsigned long max_pfn;
-unsigned long long max_possible_pfn;
-
-static void __init __free_pages_memory(unsigned long start, unsigned long end)
-{
-	int order;
-
-	while (start < end) {
-		order = min(MAX_ORDER - 1UL, __ffs(start));
-
-		while (start + (1UL << order) > end)
-			order--;
-
-		memblock_free_pages(pfn_to_page(start), start, order);
-
-		start += (1UL << order);
-	}
-}
-
-static unsigned long __init __free_memory_core(phys_addr_t start,
-				 phys_addr_t end)
-{
-	unsigned long start_pfn = PFN_UP(start);
-	unsigned long end_pfn = min_t(unsigned long,
-				      PFN_DOWN(end), max_low_pfn);
-
-	if (start_pfn >= end_pfn)
-		return 0;
-
-	__free_pages_memory(start_pfn, end_pfn);
-
-	return end_pfn - start_pfn;
-}
-
-static unsigned long __init free_low_memory_core_early(void)
-{
-	unsigned long count = 0;
-	phys_addr_t start, end;
-	u64 i;
-
-	memblock_clear_hotplug(0, -1);
-
-	for_each_reserved_mem_region(i, &start, &end)
-		reserve_bootmem_region(start, end);
-
-	/*
-	 * We need to use NUMA_NO_NODE instead of NODE_DATA(0)->node_id
-	 *  because in some case like Node0 doesn't have RAM installed
-	 *  low ram will be on Node1
-	 */
-	for_each_free_mem_range(i, NUMA_NO_NODE, MEMBLOCK_NONE, &start, &end,
-				NULL)
-		count += __free_memory_core(start, end);
-
-	return count;
-}
-
-static int reset_managed_pages_done __initdata;
-
-void reset_node_managed_pages(pg_data_t *pgdat)
-{
-	struct zone *z;
-
-	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
-		z->managed_pages = 0;
-}
-
-void __init reset_all_zones_managed_pages(void)
-{
-	struct pglist_data *pgdat;
-
-	if (reset_managed_pages_done)
-		return;
-
-	for_each_online_pgdat(pgdat)
-		reset_node_managed_pages(pgdat);
-
-	reset_managed_pages_done = 1;
-}
-
-/**
- * memblock_free_all - release free pages to the buddy allocator
- *
- * Return: the number of pages actually released.
- */
-unsigned long __init memblock_free_all(void)
-{
-	unsigned long pages;
-
-	reset_all_zones_managed_pages();
-
-	pages = free_low_memory_core_early();
-	totalram_pages += pages;
-
-	return pages;
-}
-- 
2.7.4
