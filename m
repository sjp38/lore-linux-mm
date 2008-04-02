From: Johannes Weiner <hannes@saeurebad.de>
Subject: [RFC 19/22] um: Use generic show_mem()
Date: Wed,  2 Apr 2008 22:40:25 +0200
Message-ID: <12071690432631-git-send-email-hannes@saeurebad.de>
References: <12071688283927-git-send-email-hannes@saeurebad.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764397AbYDBVti@vger.kernel.org>
In-Reply-To: <12071688283927-git-send-email-hannes@saeurebad.de>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sf.net, takata@linux-m32r.org, geert@linux-m68k.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org


Signed-off-by: Johannes Weiner <hannes@saeurebad.de>

diff --git a/arch/um/Kconfig b/arch/um/Kconfig
index f3b75af..dba8e05 100644
--- a/arch/um/Kconfig
+++ b/arch/um/Kconfig
@@ -86,10 +86,6 @@ config STATIC_LINK
 	  2.75G) for UML.
 
 source "arch/um/Kconfig.arch"
-
-config HAVE_ARCH_SHOW_MEM
-	def_bool y
-
 source "mm/Kconfig"
 source "kernel/time/Kconfig"
 
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index 2eea1ff..e1c7d20 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -295,37 +295,6 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 }
 #endif
 
-void show_mem(void)
-{
-	int pfn, total = 0, reserved = 0;
-	int shared = 0, cached = 0;
-	int high_mem = 0;
-	struct page *page;
-
-	printk(KERN_INFO "Mem-info:\n");
-	show_free_areas();
-	printk(KERN_INFO "Free swap:       %6ldkB\n",
-	       nr_swap_pages<<(PAGE_SHIFT-10));
-	pfn = max_mapnr;
-	while (pfn-- > 0) {
-		page = pfn_to_page(pfn);
-		total++;
-		if (PageHighMem(page))
-			high_mem++;
-		if (PageReserved(page))
-			reserved++;
-		else if (PageSwapCache(page))
-			cached++;
-		else if (page_count(page))
-			shared += page_count(page) - 1;
-	}
-	printk(KERN_INFO "%d pages of RAM\n", total);
-	printk(KERN_INFO "%d pages of HIGHMEM\n", high_mem);
-	printk(KERN_INFO "%d reserved pages\n", reserved);
-	printk(KERN_INFO "%d pages shared\n", shared);
-	printk(KERN_INFO "%d pages swap cached\n", cached);
-}
-
 /* Allocate and free page tables. */
 
 pgd_t *pgd_alloc(struct mm_struct *mm)
-- 
1.5.2.2
