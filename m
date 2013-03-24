Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id B9A596B0027
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 03:28:04 -0400 (EDT)
Received: by mail-da0-f42.google.com with SMTP id n15so2793150dad.15
        for <linux-mm@kvack.org>; Sun, 24 Mar 2013 00:28:04 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v2, part4 08/39] mm: introduce helper function mem_init_print_info() to simplify mem_init()
Date: Sun, 24 Mar 2013 15:24:34 +0800
Message-Id: <1364109934-7851-9-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
References: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>

Introduce helper function mem_init_print_info() to simplify mem_init()
across different architectures, which also unifies the format and
information printed.

Function mem_init_print_info() calculates memory statistics information
without walking each page, so it should be a little faster on some
architectures.

Also introduce another helper get_num_physpages() to kill the global
variable num_physpages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michel Lespinasse <walken@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 include/linux/mm.h |   12 ++++++++++++
 mm/page_alloc.c    |   52 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 64 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index c03d029..c225a4f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1312,6 +1312,7 @@ extern void free_highmem_page(struct page *page);
 #endif
 
 extern void adjust_managed_page_count(struct page *page, long count);
+extern void mem_init_print_info(const char *str);
 
 /* Free the reserved page into the buddy system, so it gets managed. */
 static inline void __free_reserved_page(struct page *page)
@@ -1348,6 +1349,17 @@ static inline unsigned long free_initmem_default(int poison)
 				  poison, "unused kernel");
 }
 
+static inline unsigned long get_num_physpages(void)
+{
+	int nid;
+	unsigned long phys_pages = 0;
+
+	for_each_online_node(nid)
+		phys_pages += node_present_pages(nid);
+
+	return phys_pages;
+}
+
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 /*
  * With CONFIG_HAVE_MEMBLOCK_NODE_MAP set, an architecture may initialise its
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ebfb042..577acec 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -59,6 +59,7 @@
 #include <linux/migrate.h>
 #include <linux/page-debug-flags.h>
 
+#include <asm/sections.h>
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
 #include "internal.h"
@@ -5168,6 +5169,57 @@ void free_highmem_page(struct page *page)
 }
 #endif
 
+
+void __init mem_init_print_info(const char *str)
+{
+	unsigned long physpages, codesize, datasize, rosize;
+	unsigned long init_code_size, init_data_size;
+
+	physpages = get_num_physpages();
+	codesize = _etext - _stext;
+	datasize = _edata - _sdata;
+	rosize = __end_rodata - __start_rodata;
+	init_data_size = __init_end - __init_begin;
+	init_code_size = _einittext - _sinittext;
+
+	/*
+	 * Detect special cases and adjust section sizes accordingly:
+	 * 1) .init.* may be embedded into .data sections
+	 * 2) .init.text.* may be out of [__init_begin, __init_end],
+	 *    please refer to arch/tile/kernel/vmlinux.lds.S.
+	 * 3) .rodata.* may be embedded into .text or .data sections.
+	 */
+#define adj_init_size(start, end, size, pos, adj) \
+	if (start <= pos && pos < end && size > adj) \
+		size -= adj;
+
+	adj_init_size(__init_begin, __init_end, init_data_size,
+		     _sinittext, init_code_size);
+	adj_init_size(_stext, _etext, codesize, _sinittext, init_code_size);
+	adj_init_size(_sdata, _edata, datasize, __init_begin, init_data_size);
+	adj_init_size(_stext, _etext, codesize, __start_rodata, rosize);
+	adj_init_size(_sdata, _edata, datasize, __start_rodata, rosize);
+
+#undef	adj_init_size
+
+	printk("Memory: %luK/%luK available "
+	       "(%luK kernel code, %luK data, %luK rodata, "
+	       "%luK init, %luK bss, %luK reserved"
+#ifdef	CONFIG_HIGHMEM
+	       ", %luK highmem"
+#endif
+	       "%s%s)\n",
+	       nr_free_pages() << (PAGE_SHIFT-10), physpages << (PAGE_SHIFT-10),
+	       codesize >> 10, datasize >> 10, rosize >> 10,
+	       (init_data_size + init_code_size) >> 10,
+	       (__bss_stop - __bss_start) >> 10,
+	       (physpages - totalram_pages) << (PAGE_SHIFT-10),
+#ifdef	CONFIG_HIGHMEM
+	       totalhigh_pages << (PAGE_SHIFT-10),
+#endif
+	       str ? ", " : "", str ? str : "");
+}
+
 /**
  * set_dma_reserve - set the specified number of pages reserved in the first zone
  * @new_dma_reserve: The number of pages to mark reserved
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
