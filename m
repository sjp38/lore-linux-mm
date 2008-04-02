From: Johannes Weiner <hannes@saeurebad.de>
Subject: [RFC 16/22] ppc: Use generic show_mem()
Date: Wed,  2 Apr 2008 22:40:22 +0200
Message-ID: <1207169009616-git-send-email-hannes@saeurebad.de>
References: <12071688283927-git-send-email-hannes@saeurebad.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764080AbYDBVsX@vger.kernel.org>
In-Reply-To: <12071688283927-git-send-email-hannes@saeurebad.de>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sf.net, takata@linux-m32r.org, geert@linux-m68k.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org


Signed-off-by: Johannes Weiner <hannes@saeurebad.de>

diff --git a/arch/ppc/Kconfig b/arch/ppc/Kconfig
index db5e6a1..abc877f 100644
--- a/arch/ppc/Kconfig
+++ b/arch/ppc/Kconfig
@@ -924,9 +924,6 @@ config HIGHMEM
 config ARCH_POPULATES_NODE_MAP
 	def_bool y
 
-config HAVE_ARCH_SHOW_MEM
-	def_bool y
-
 source kernel/Kconfig.hz
 source kernel/Kconfig.preempt
 source "mm/Kconfig"
diff --git a/arch/ppc/mm/init.c b/arch/ppc/mm/init.c
index 7444df3..132031a 100644
--- a/arch/ppc/mm/init.c
+++ b/arch/ppc/mm/init.c
@@ -101,37 +101,6 @@ unsigned long __max_memory;
 /* max amount of low RAM to map in */
 unsigned long __max_low_memory = MAX_LOW_MEM;
 
-void show_mem(void)
-{
-	int i,free = 0,total = 0,reserved = 0;
-	int shared = 0, cached = 0;
-	int highmem = 0;
-
-	printk("Mem-info:\n");
-	show_free_areas();
-	printk("Free swap:       %6ldkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
-	i = max_mapnr;
-	while (i-- > 0) {
-		total++;
-		if (PageHighMem(mem_map+i))
-			highmem++;
-		if (PageReserved(mem_map+i))
-			reserved++;
-		else if (PageSwapCache(mem_map+i))
-			cached++;
-		else if (!page_count(mem_map+i))
-			free++;
-		else
-			shared += page_count(mem_map+i) - 1;
-	}
-	printk("%d pages of RAM\n",total);
-	printk("%d pages of HIGHMEM\n", highmem);
-	printk("%d free pages\n",free);
-	printk("%d reserved pages\n",reserved);
-	printk("%d pages shared\n",shared);
-	printk("%d pages swap cached\n",cached);
-}
-
 /* Free up now-unused memory */
 static void free_sec(unsigned long start, unsigned long end, const char *name)
 {
-- 
1.5.2.2
