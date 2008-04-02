From: Johannes Weiner <hannes@saeurebad.de>
Subject: [RFC 04/22] avr32: Use generic show_mem()
Date: Wed,  2 Apr 2008 22:40:10 +0200
Message-ID: <12071688734124-git-send-email-hannes@saeurebad.de>
References: <12071688283927-git-send-email-hannes@saeurebad.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762803AbYDBVnf@vger.kernel.org>
In-Reply-To: <12071688283927-git-send-email-hannes@saeurebad.de>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sf.net, takata@linux-m32r.org, geert@linux-m68k.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org


Signed-off-by: Johannes Weiner <hannes@saeurebad.de>

diff --git a/arch/avr32/Kconfig b/arch/avr32/Kconfig
index 81e3360..c75d708 100644
--- a/arch/avr32/Kconfig
+++ b/arch/avr32/Kconfig
@@ -146,9 +146,6 @@ source "kernel/Kconfig.preempt"
 config HAVE_ARCH_BOOTMEM_NODE
 	def_bool n
 
-config HAVE_ARCH_SHOW_MEM
-	def_bool y
-
 config ARCH_HAVE_MEMORY_PRESENT
 	def_bool n
 
diff --git a/arch/avr32/mm/init.c b/arch/avr32/mm/init.c
index 480760b..3cbff55 100644
--- a/arch/avr32/mm/init.c
+++ b/arch/avr32/mm/init.c
@@ -37,45 +37,6 @@ unsigned long mmu_context_cache = NO_CONTEXT;
 #define START_PFN	(NODE_DATA(0)->bdata->node_boot_start >> PAGE_SHIFT)
 #define MAX_LOW_PFN	(NODE_DATA(0)->bdata->node_low_pfn)
 
-void show_mem(void)
-{
-	int total = 0, reserved = 0, cached = 0;
-	int slab = 0, free = 0, shared = 0;
-	pg_data_t *pgdat;
-
-	printk("Mem-info:\n");
-	show_free_areas();
-
-	for_each_online_pgdat(pgdat) {
-		struct page *page, *end;
-
-		page = pgdat->node_mem_map;
-		end = page + pgdat->node_spanned_pages;
-
-		do {
-			total++;
-			if (PageReserved(page))
-				reserved++;
-			else if (PageSwapCache(page))
-				cached++;
-			else if (PageSlab(page))
-				slab++;
-			else if (!page_count(page))
-				free++;
-			else
-				shared += page_count(page) - 1;
-			page++;
-		} while (page < end);
-	}
-
-	printk ("%d pages of RAM\n", total);
-	printk ("%d free pages\n", free);
-	printk ("%d reserved pages\n", reserved);
-	printk ("%d slab pages\n", slab);
-	printk ("%d pages shared\n", shared);
-	printk ("%d pages swap cached\n", cached);
-}
-
 /*
  * paging_init() sets up the page tables
  *
-- 
1.5.2.2
