From: Johannes Weiner <hannes@saeurebad.de>
Subject: [RFC 09/22] m32r: Use generic show_mem()
Date: Wed,  2 Apr 2008 22:40:15 +0200
Message-ID: <12071689301688-git-send-email-hannes@saeurebad.de>
References: <12071688283927-git-send-email-hannes@saeurebad.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763318AbYDBVpd@vger.kernel.org>
In-Reply-To: <12071688283927-git-send-email-hannes@saeurebad.de>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sf.net, takata@linux-m32r.org, geert@linux-m68k.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org


Signed-off-by: Johannes Weiner <hannes@saeurebad.de>

diff --git a/arch/m32r/Kconfig b/arch/m32r/Kconfig
index 2f51d8f..de153de 100644
--- a/arch/m32r/Kconfig
+++ b/arch/m32r/Kconfig
@@ -225,9 +225,6 @@ config ARCH_DISCONTIGMEM_ENABLE
 	depends on CHIP_M32700 || CHIP_M32102 || CHIP_VDEC2 || CHIP_OPSP || CHIP_M32104
 	default y
 
-config HAVE_ARCH_SHOW_MEM
-	def_bool y
-
 source "mm/Kconfig"
 
 config IRAM_START
diff --git a/arch/m32r/mm/init.c b/arch/m32r/mm/init.c
index bbd97c8..2a3e8b5 100644
--- a/arch/m32r/mm/init.c
+++ b/arch/m32r/mm/init.c
@@ -36,42 +36,6 @@ pgd_t swapper_pg_dir[1024];
 
 DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
 
-void show_mem(void)
-{
-	int total = 0, reserved = 0;
-	int shared = 0, cached = 0;
-	int highmem = 0;
-	struct page *page;
-	pg_data_t *pgdat;
-	unsigned long i;
-
-	printk("Mem-info:\n");
-	show_free_areas();
-	printk("Free swap:       %6ldkB\n",nr_swap_pages<<(PAGE_SHIFT-10));
-	for_each_online_pgdat(pgdat) {
-		unsigned long flags;
-		pgdat_resize_lock(pgdat, &flags);
-		for (i = 0; i < pgdat->node_spanned_pages; ++i) {
-			page = pgdat_page_nr(pgdat, i);
-			total++;
-			if (PageHighMem(page))
-				highmem++;
-			if (PageReserved(page))
-				reserved++;
-			else if (PageSwapCache(page))
-				cached++;
-			else if (page_count(page))
-				shared += page_count(page) - 1;
-		}
-		pgdat_resize_unlock(pgdat, &flags);
-	}
-	printk("%d pages of RAM\n", total);
-	printk("%d pages of HIGHMEM\n",highmem);
-	printk("%d reserved pages\n",reserved);
-	printk("%d pages shared\n",shared);
-	printk("%d pages swap cached\n",cached);
-}
-
 /*
  * Cache of MMU context last used.
  */
@@ -252,4 +216,3 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 	printk (KERN_INFO "Freeing initrd memory: %ldk freed\n", (end - start) >> 10);
 }
 #endif
-
-- 
1.5.2.2
