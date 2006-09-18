Date: Mon, 18 Sep 2006 15:58:52 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/6] Introduce CONFIG_ZONE_DMA
In-Reply-To: <20060918224548.GA6284@localhost.usen.ad.jp>
Message-ID: <Pine.LNX.4.64.0609181556430.29365@schroedinger.engr.sgi.com>
References: <20060918183614.19679.50359.sendpatchset@schroedinger.engr.sgi.com>
 <20060918183655.19679.51633.sendpatchset@schroedinger.engr.sgi.com>
 <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
 <20060911222739.4849.79915.sendpatchset@schroedinger.engr.sgi.com>
 <20060918135559.GB15096@infradead.org> <20060918152243.GA4320@localhost.na.rta>
 <Pine.LNX.4.64.0609181031420.19312@schroedinger.engr.sgi.com>
 <20060918224548.GA6284@localhost.usen.ad.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-ia64@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Arjan van de Ven <arjan@infradead.org>, Martin Bligh <mbligh@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <ak@suse.de>, linux-arch@vger.kernel.org, James Bottomley <James.Bottomley@steeleye.com>, Russell King <rmk@arm.linux.org.uk>
List-ID: <linux-mm.kvack.org>

On Tue, 19 Sep 2006, Paul Mundt wrote:

> You've missed the other ZONE_DMA references, if you scroll a bit further
> down that's where we fill in ZONE_DMA, this is simply the default zone
> layout that we rely on for nommu.

Are you sure that sh does not need ZONE_DMA? There is code in there
to check for the DMA boundary. The following patch disables that
code if CONFIG_ZONE_DMA is not set.



sh / sh64: Remove ZONE_DMA remains.

Both arches do not need ZONE_DMA

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc6-mm2/arch/sh/mm/init.c
===================================================================
--- linux-2.6.18-rc6-mm2.orig/arch/sh/mm/init.c	2006-09-18 13:27:48.125691412 -0500
+++ linux-2.6.18-rc6-mm2/arch/sh/mm/init.c	2006-09-18 17:56:23.632421140 -0500
@@ -156,7 +156,6 @@ void __init paging_init(void)
 	 * Setup some defaults for the zone sizes.. these should be safe
 	 * regardless of distcontiguous memory or MMU settings.
 	 */
-	zones_size[ZONE_DMA] = 0 >> PAGE_SHIFT;
 	zones_size[ZONE_NORMAL] = __MEMORY_SIZE >> PAGE_SHIFT;
 #ifdef CONFIG_HIGHMEM
 	zones_size[ZONE_HIGHMEM] = 0 >> PAGE_SHIFT;
@@ -186,13 +185,16 @@ void __init paging_init(void)
 		max_dma = virt_to_phys((char *)MAX_DMA_ADDRESS) >> PAGE_SHIFT;
 		low = MAX_LOW_PFN;
 
-		if (low < max_dma) {
-			zones_size[ZONE_DMA] = low - start_pfn;
-			zones_size[ZONE_NORMAL] = 0;
-		} else {
+#ifdef CONFIG_ZONE_DMA
+		if (low < max_dma)
+#endif
+			zones_size[ZONE_NORMAL] = low - start_pfn;
+#ifdef CONFIG_ZONE_DMA
+		else {
 			zones_size[ZONE_DMA] = max_dma - start_pfn;
 			zones_size[ZONE_NORMAL] = low - max_dma;
 		}
+#endif
 	}
 
 #elif defined(CONFIG_CPU_SH3) || defined(CONFIG_CPU_SH4)
Index: linux-2.6.18-rc6-mm2/arch/sh64/mm/init.c
===================================================================
--- linux-2.6.18-rc6-mm2.orig/arch/sh64/mm/init.c	2006-09-18 13:27:48.134481203 -0500
+++ linux-2.6.18-rc6-mm2/arch/sh64/mm/init.c	2006-09-18 17:54:14.263532486 -0500
@@ -118,10 +118,7 @@ void __init paging_init(void)
 
 	mmu_context_cache = MMU_CONTEXT_FIRST_VERSION;
 
-        /*
-	 * All memory is good as ZONE_NORMAL (fall-through) and ZONE_DMA.
-         */
-	zones_size[ZONE_DMA] = MAX_LOW_PFN - START_PFN;
+	zones_size[ZONE_NORMAL] = MAX_LOW_PFN - START_PFN;
 	NODE_DATA(0)->node_mem_map = NULL;
 	free_area_init_node(0, NODE_DATA(0), zones_size, __MEMORY_START >> PAGE_SHIFT, 0);
 }
Index: linux-2.6.18-rc6-mm2/arch/sh64/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm2.orig/arch/sh64/Kconfig	2006-09-18 13:27:48.145224281 -0500
+++ linux-2.6.18-rc6-mm2/arch/sh64/Kconfig	2006-09-18 17:54:14.285995416 -0500
@@ -36,9 +36,6 @@ config GENERIC_CALIBRATE_DELAY
 config RWSEM_XCHGADD_ALGORITHM
 	bool
 
-config GENERIC_ISA_DMA
-	bool
-
 source init/Kconfig
 
 menu "System type"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
