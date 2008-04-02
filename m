From: Johannes Weiner <hannes@saeurebad.de>
Subject: [RFC 14/22] parisc: Use generic show_mem()
Date: Wed,  2 Apr 2008 22:40:20 +0200
Message-ID: <12071689863221-git-send-email-hannes@saeurebad.de>
References: <12071688283927-git-send-email-hannes@saeurebad.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763936AbYDBVrj@vger.kernel.org>
In-Reply-To: <12071688283927-git-send-email-hannes@saeurebad.de>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sf.net, takata@linux-m32r.org, geert@linux-m68k.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org


Signed-off-by: Johannes Weiner <hannes@saeurebad.de>

diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
index 9ec4fcd..bc7a19d 100644
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -240,9 +240,6 @@ config NODES_SHIFT
 	default "3"
 	depends on NEED_MULTIPLE_NODES
 
-config HAVE_ARCH_SHOW_MEM
-	def_bool y
-
 source "kernel/Kconfig.preempt"
 source "kernel/Kconfig.hz"
 source "mm/Kconfig"
diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index eb80f5e..e8e9891 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -548,78 +548,6 @@ void __init mem_init(void)
 
 unsigned long *empty_zero_page __read_mostly;
 
-void show_mem(void)
-{
-	int i,free = 0,total = 0,reserved = 0;
-	int shared = 0, cached = 0;
-
-	printk(KERN_INFO "Mem-info:\n");
-	show_free_areas();
-	printk(KERN_INFO "Free swap:	 %6ldkB\n",
-				nr_swap_pages<<(PAGE_SHIFT-10));
-#ifndef CONFIG_DISCONTIGMEM
-	i = max_mapnr;
-	while (i-- > 0) {
-		total++;
-		if (PageReserved(mem_map+i))
-			reserved++;
-		else if (PageSwapCache(mem_map+i))
-			cached++;
-		else if (!page_count(&mem_map[i]))
-			free++;
-		else
-			shared += page_count(&mem_map[i]) - 1;
-	}
-#else
-	for (i = 0; i < npmem_ranges; i++) {
-		int j;
-
-		for (j = node_start_pfn(i); j < node_end_pfn(i); j++) {
-			struct page *p;
-			unsigned long flags;
-
-			pgdat_resize_lock(NODE_DATA(i), &flags);
-			p = nid_page_nr(i, j) - node_start_pfn(i);
-
-			total++;
-			if (PageReserved(p))
-				reserved++;
-			else if (PageSwapCache(p))
-				cached++;
-			else if (!page_count(p))
-				free++;
-			else
-				shared += page_count(p) - 1;
-			pgdat_resize_unlock(NODE_DATA(i), &flags);
-        	}
-	}
-#endif
-	printk(KERN_INFO "%d pages of RAM\n", total);
-	printk(KERN_INFO "%d reserved pages\n", reserved);
-	printk(KERN_INFO "%d pages shared\n", shared);
-	printk(KERN_INFO "%d pages swap cached\n", cached);
-
-
-#ifdef CONFIG_DISCONTIGMEM
-	{
-		struct zonelist *zl;
-		int i, j, k;
-
-		for (i = 0; i < npmem_ranges; i++) {
-			for (j = 0; j < MAX_NR_ZONES; j++) {
-				zl = NODE_DATA(i)->node_zonelists + j;
-
-				printk("Zone list for zone %d on node %d: ", j, i);
-				for (k = 0; zl->zones[k] != NULL; k++) 
-					printk("[%d/%s] ", zone_to_nid(zl->zones[k]), zl->zones[k]->name);
-				printk("\n");
-			}
-		}
-	}
-#endif
-}
-
-
 static void __init map_pages(unsigned long start_vaddr, unsigned long start_paddr, unsigned long size, pgprot_t pgprot)
 {
 	pgd_t *pg_dir;
-- 
1.5.2.2
