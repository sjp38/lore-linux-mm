Date: Mon, 18 Sep 2006 11:36:45 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060918183645.19679.4719.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060918183614.19679.50359.sendpatchset@schroedinger.engr.sgi.com>
References: <20060918183614.19679.50359.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 6/8] Optional ZONE_DMA for ia64
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-arch@vger.kernel.org
Cc: Paul Mundt <lethal@linux-sh.org>, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@SteelEye.com>, Arjan van de Ven <arjan@infradead.org>, linux-mm@kvack.org, Russell King <rmk@arm.linux.org.uk>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

ZONE_DMA less operation for IA64 SGI platform

Disable ZONE_DMA for SGI SN2. All memory is addressable by all
devices and we do not need any special memory pool.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc6-mm1/arch/ia64/mm/discontig.c
===================================================================
--- linux-2.6.18-rc6-mm1.orig/arch/ia64/mm/discontig.c	2006-09-11 16:42:07.206714114 -0500
+++ linux-2.6.18-rc6-mm1/arch/ia64/mm/discontig.c	2006-09-11 16:51:50.094129334 -0500
@@ -37,7 +37,9 @@
 	unsigned long pernode_size;
 	struct bootmem_data bootmem_data;
 	unsigned long num_physpages;
+#ifdef CONFIG_ZONE_DMA
 	unsigned long num_dma_physpages;
+#endif
 	unsigned long min_pfn;
 	unsigned long max_pfn;
 };
@@ -656,9 +658,11 @@
 
 	add_active_range(node, start >> PAGE_SHIFT, end >> PAGE_SHIFT);
 	mem_data[node].num_physpages += len >> PAGE_SHIFT;
+#ifdef CONFIG_ZONE_DMA
 	if (start <= __pa(MAX_DMA_ADDRESS))
 		mem_data[node].num_dma_physpages +=
 			(min(end, __pa(MAX_DMA_ADDRESS)) - start) >>PAGE_SHIFT;
+#endif
 	start = GRANULEROUNDDOWN(start);
 	start = ORDERROUNDDOWN(start);
 	end = GRANULEROUNDUP(end);
@@ -709,7 +713,9 @@
 			max_pfn = mem_data[node].max_pfn;
 	}
 
+#ifdef CONFIG_ZONE_DMA
 	max_zone_pfns[ZONE_DMA] = max_dma;
+#endif
 	max_zone_pfns[ZONE_NORMAL] = max_pfn;
 	free_area_init_nodes(max_zone_pfns);
 
Index: linux-2.6.18-rc6-mm1/arch/ia64/mm/contig.c
===================================================================
--- linux-2.6.18-rc6-mm1.orig/arch/ia64/mm/contig.c	2006-09-11 16:42:07.215503923 -0500
+++ linux-2.6.18-rc6-mm1/arch/ia64/mm/contig.c	2006-09-11 16:51:50.104872434 -0500
@@ -231,8 +231,10 @@
 	num_physpages = 0;
 	efi_memmap_walk(count_pages, &num_physpages);
 
+#ifdef CONFIG_ZONE_DMA
 	max_dma = virt_to_phys((void *) MAX_DMA_ADDRESS) >> PAGE_SHIFT;
 	max_zone_pfns[ZONE_DMA] = max_dma;
+#endif
 	max_zone_pfns[ZONE_NORMAL] = max_low_pfn;
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
Index: linux-2.6.18-rc6-mm1/arch/ia64/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm1.orig/arch/ia64/Kconfig	2006-09-11 16:44:55.649739769 -0500
+++ linux-2.6.18-rc6-mm1/arch/ia64/Kconfig	2006-09-11 16:51:50.114638888 -0500
@@ -23,8 +23,8 @@
 	default y
 
 config ZONE_DMA
-	bool
-	default y
+	def_bool y
+	depends on !IA64_SGI_SN2
 
 config MMU
 	bool

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
