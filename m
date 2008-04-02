From: Johannes Weiner <hannes@saeurebad.de>
Subject: [RFC 17/22] s390: Use generic show_mem()
Date: Wed,  2 Apr 2008 22:40:23 +0200
Message-ID: <12071690203023-git-send-email-hannes@saeurebad.de>
References: <12071688283927-git-send-email-hannes@saeurebad.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761024AbYDBVsj@vger.kernel.org>
In-Reply-To: <12071688283927-git-send-email-hannes@saeurebad.de>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sf.net, takata@linux-m32r.org, geert@linux-m68k.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org


Signed-off-by: Johannes Weiner <hannes@saeurebad.de>

diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 6fb2b79..1831833 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -282,9 +282,6 @@ config WARN_STACK_SIZE
 config ARCH_POPULATES_NODE_MAP
 	def_bool y
 
-config HAVE_ARCH_SHOW_MEM
-	def_bool y
-
 comment "Kernel preemption"
 
 source "kernel/Kconfig.preempt"
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 8053245..27b94cb 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -42,42 +42,6 @@ DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
 pgd_t swapper_pg_dir[PTRS_PER_PGD] __attribute__((__aligned__(PAGE_SIZE)));
 char  empty_zero_page[PAGE_SIZE] __attribute__((__aligned__(PAGE_SIZE)));
 
-void show_mem(void)
-{
-	int i, total = 0, reserved = 0;
-	int shared = 0, cached = 0;
-	struct page *page;
-
-	printk("Mem-info:\n");
-	show_free_areas();
-	printk("Free swap:       %6ldkB\n", nr_swap_pages << (PAGE_SHIFT - 10));
-	i = max_mapnr;
-	while (i-- > 0) {
-		if (!pfn_valid(i))
-			continue;
-		page = pfn_to_page(i);
-		total++;
-		if (PageReserved(page))
-			reserved++;
-		else if (PageSwapCache(page))
-			cached++;
-		else if (page_count(page))
-			shared += page_count(page) - 1;
-	}
-	printk("%d pages of RAM\n", total);
-	printk("%d reserved pages\n", reserved);
-	printk("%d pages shared\n", shared);
-	printk("%d pages swap cached\n", cached);
-
-	printk("%lu pages dirty\n", global_page_state(NR_FILE_DIRTY));
-	printk("%lu pages writeback\n", global_page_state(NR_WRITEBACK));
-	printk("%lu pages mapped\n", global_page_state(NR_FILE_MAPPED));
-	printk("%lu pages slab\n",
-	       global_page_state(NR_SLAB_RECLAIMABLE) +
-	       global_page_state(NR_SLAB_UNRECLAIMABLE));
-	printk("%lu pages pagetables\n", global_page_state(NR_PAGETABLE));
-}
-
 static void __init setup_ro_region(void)
 {
 	pgd_t *pgd;
-- 
1.5.2.2
