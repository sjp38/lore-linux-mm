Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 0C3EF6B0002
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 09:58:15 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id xb4so4547452pbc.15
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 06:58:15 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v1 02/33] mm/alpha: use common help functions to free reserved pages
Date: Tue,  5 Mar 2013 22:54:45 +0800
Message-Id: <1362495317-32682-3-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
References: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>

Use common help functions to free reserved pages.
Also include <asm/sections.h> to avoid local declarations.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Richard Henderson <rth@twiddle.net>
Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Cc: Matt Turner <mattst88@gmail.com>
---
 arch/alpha/kernel/sys_nautilus.c |    5 ++---
 arch/alpha/mm/init.c             |   24 +++---------------------
 arch/alpha/mm/numa.c             |    3 +--
 3 files changed, 6 insertions(+), 26 deletions(-)

diff --git a/arch/alpha/kernel/sys_nautilus.c b/arch/alpha/kernel/sys_nautilus.c
index 4d4c046..a8b9d66 100644
--- a/arch/alpha/kernel/sys_nautilus.c
+++ b/arch/alpha/kernel/sys_nautilus.c
@@ -185,7 +185,6 @@ nautilus_machine_check(unsigned long vector, unsigned long la_ptr)
 	mb();
 }
 
-extern void free_reserved_mem(void *, void *);
 extern void pcibios_claim_one_bus(struct pci_bus *);
 
 static struct resource irongate_mem = {
@@ -234,8 +233,8 @@ nautilus_init_pci(void)
 	if (pci_mem < memtop)
 		memtop = pci_mem;
 	if (memtop > alpha_mv.min_mem_address) {
-		free_reserved_mem(__va(alpha_mv.min_mem_address),
-				  __va(memtop));
+		free_reserved_area((unsigned long)__va(alpha_mv.min_mem_address),
+				   (unsigned long)__va(memtop), 0, NULL);
 		printk("nautilus_init_pci: %ldk freed\n",
 			(memtop - alpha_mv.min_mem_address) >> 10);
 	}
diff --git a/arch/alpha/mm/init.c b/arch/alpha/mm/init.c
index 1ad6ca7..0ba85ee 100644
--- a/arch/alpha/mm/init.c
+++ b/arch/alpha/mm/init.c
@@ -31,6 +31,7 @@
 #include <asm/console.h>
 #include <asm/tlb.h>
 #include <asm/setup.h>
+#include <asm/sections.h>
 
 extern void die_if_kernel(char *,struct pt_regs *,long);
 
@@ -281,8 +282,6 @@ printk_memory_info(void)
 {
 	unsigned long codesize, reservedpages, datasize, initsize, tmp;
 	extern int page_is_ram(unsigned long) __init;
-	extern char _text, _etext, _data, _edata;
-	extern char __init_begin, __init_end;
 
 	/* printk all informations */
 	reservedpages = 0;
@@ -318,32 +317,15 @@ mem_init(void)
 #endif /* CONFIG_DISCONTIGMEM */
 
 void
-free_reserved_mem(void *start, void *end)
-{
-	void *__start = start;
-	for (; __start < end; __start += PAGE_SIZE) {
-		ClearPageReserved(virt_to_page(__start));
-		init_page_count(virt_to_page(__start));
-		free_page((long)__start);
-		totalram_pages++;
-	}
-}
-
-void
 free_initmem(void)
 {
-	extern char __init_begin, __init_end;
-
-	free_reserved_mem(&__init_begin, &__init_end);
-	printk ("Freeing unused kernel memory: %ldk freed\n",
-		(&__init_end - &__init_begin) >> 10);
+	free_initmem_default(0);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
 void
 free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_mem((void *)start, (void *)end);
-	printk ("Freeing initrd memory: %ldk freed\n", (end - start) >> 10);
+	free_reserved_area(start, end, 0, "initrd");
 }
 #endif
diff --git a/arch/alpha/mm/numa.c b/arch/alpha/mm/numa.c
index 3973ae3..3388504 100644
--- a/arch/alpha/mm/numa.c
+++ b/arch/alpha/mm/numa.c
@@ -17,6 +17,7 @@
 
 #include <asm/hwrpb.h>
 #include <asm/pgalloc.h>
+#include <asm/sections.h>
 
 pg_data_t node_data[MAX_NUMNODES];
 EXPORT_SYMBOL(node_data);
@@ -325,8 +326,6 @@ void __init mem_init(void)
 {
 	unsigned long codesize, reservedpages, datasize, initsize, pfn;
 	extern int page_is_ram(unsigned long) __init;
-	extern char _text, _etext, _data, _edata;
-	extern char __init_begin, __init_end;
 	unsigned long nid, i;
 	high_memory = (void *) __va(max_low_pfn << PAGE_SHIFT);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
