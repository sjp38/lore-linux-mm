Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 923356B01A7
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 10:45:53 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id un15so2454647pbc.26
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 07:45:52 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v4, part3 27/41] mm/MIPS: prepare for removing num_physpages and simplify mem_init()
Date: Sat,  6 Apr 2013 22:32:26 +0800
Message-Id: <1365258760-30821-28-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1365258760-30821-1-git-send-email-jiang.liu@huawei.com>
References: <1365258760-30821-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, David Daney <david.daney@cavium.com>, Arnd Bergmann <arnd@arndb.de>, Jiri Kosina <jkosina@suse.cz>, John Crispin <blogic@openwrt.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@linux-mips.org

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: David Daney <david.daney@cavium.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Jiri Kosina <jkosina@suse.cz>
Cc: John Crispin <blogic@openwrt.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mips@linux-mips.org
Cc: linux-kernel@vger.kernel.org
---
 arch/mips/mm/init.c              |   57 ++++++++++++--------------------------
 arch/mips/pci/pci-lantiq.c       |    2 +-
 arch/mips/sgi-ip27/ip27-memory.c |   21 ++------------
 3 files changed, 21 insertions(+), 59 deletions(-)

diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
index de4ff2f..0392a1a 100644
--- a/arch/mips/mm/init.c
+++ b/arch/mips/mm/init.c
@@ -358,11 +358,24 @@ void __init paging_init(void)
 static struct kcore_list kcore_kseg0;
 #endif
 
-void __init mem_init(void)
+static inline void mem_init_free_highmem(void)
 {
-	unsigned long codesize, reservedpages, datasize, initsize;
-	unsigned long tmp, ram;
+#ifdef CONFIG_HIGHMEM
+	unsigned long tmp;
 
+	for (tmp = highstart_pfn; tmp < highend_pfn; tmp++) {
+		struct page *page = pfn_to_page(tmp);
+
+		if (!page_is_ram(tmp))
+			SetPageReserved(page);
+		else
+			free_highmem_page(page);
+	}
+#endif
+}
+
+void __init mem_init(void)
+{
 #ifdef CONFIG_HIGHMEM
 #ifdef CONFIG_DISCONTIGMEM
 #error "CONFIG_HIGHMEM and CONFIG_DISCONTIGMEM dont work together yet"
@@ -375,32 +388,8 @@ void __init mem_init(void)
 
 	free_all_bootmem();
 	setup_zero_pages();	/* Setup zeroed pages.  */
-
-	reservedpages = ram = 0;
-	for (tmp = 0; tmp < max_low_pfn; tmp++)
-		if (page_is_ram(tmp) && pfn_valid(tmp)) {
-			ram++;
-			if (PageReserved(pfn_to_page(tmp)))
-				reservedpages++;
-		}
-	num_physpages = ram;
-
-#ifdef CONFIG_HIGHMEM
-	for (tmp = highstart_pfn; tmp < highend_pfn; tmp++) {
-		struct page *page = pfn_to_page(tmp);
-
-		if (!page_is_ram(tmp)) {
-			SetPageReserved(page);
-			continue;
-		}
-		free_highmem_page(page);
-	}
-	num_physpages += totalhigh_pages;
-#endif
-
-	codesize =  (unsigned long) &_etext - (unsigned long) &_text;
-	datasize =  (unsigned long) &_edata - (unsigned long) &_etext;
-	initsize =  (unsigned long) &__init_end - (unsigned long) &__init_begin;
+	mem_init_free_highmem();
+	mem_init_print_info(NULL);
 
 #ifdef CONFIG_64BIT
 	if ((unsigned long) &_text > (unsigned long) CKSEG0)
@@ -409,16 +398,6 @@ void __init mem_init(void)
 		kclist_add(&kcore_kseg0, (void *) CKSEG0,
 				0x80000000 - 4, KCORE_TEXT);
 #endif
-
-	printk(KERN_INFO "Memory: %luk/%luk available (%ldk kernel code, "
-	       "%ldk reserved, %ldk data, %ldk init, %ldk highmem)\n",
-	       nr_free_pages() << (PAGE_SHIFT-10),
-	       ram << (PAGE_SHIFT-10),
-	       codesize >> 10,
-	       reservedpages << (PAGE_SHIFT-10),
-	       datasize >> 10,
-	       initsize >> 10,
-	       totalhigh_pages << (PAGE_SHIFT-10));
 }
 #endif /* !CONFIG_NEED_MULTIPLE_NODES */
 
diff --git a/arch/mips/pci/pci-lantiq.c b/arch/mips/pci/pci-lantiq.c
index 879077b..cb1ef99 100644
--- a/arch/mips/pci/pci-lantiq.c
+++ b/arch/mips/pci/pci-lantiq.c
@@ -89,7 +89,7 @@ static inline u32 ltq_calc_bar11mask(void)
 	u32 mem, bar11mask;
 
 	/* BAR11MASK value depends on available memory on system. */
-	mem = num_physpages * PAGE_SIZE;
+	mem = get_num_physpages() * PAGE_SIZE;
 	bar11mask = (0x0ffffff0 & ~((1 << (fls(mem) - 1)) - 1)) | 8;
 
 	return bar11mask;
diff --git a/arch/mips/sgi-ip27/ip27-memory.c b/arch/mips/sgi-ip27/ip27-memory.c
index 936e617..d074680 100644
--- a/arch/mips/sgi-ip27/ip27-memory.c
+++ b/arch/mips/sgi-ip27/ip27-memory.c
@@ -357,8 +357,6 @@ static void __init szmem(void)
 	int slot;
 	cnodeid_t node;
 
-	num_physpages = 0;
-
 	for_each_online_node(node) {
 		nodebytes = 0;
 		for (slot = 0; slot < MAX_MEM_SLOTS; slot++) {
@@ -381,7 +379,6 @@ static void __init szmem(void)
 				slot = MAX_MEM_SLOTS;
 				continue;
 			}
-			num_physpages += slot_psize;
 			memblock_add_node(PFN_PHYS(slot_getbasepfn(node, slot)),
 					  PFN_PHYS(slot_psize), node);
 		}
@@ -480,10 +477,9 @@ void __init paging_init(void)
 
 void __init mem_init(void)
 {
-	unsigned long codesize, datasize, initsize, tmp;
 	unsigned node;
 
-	high_memory = (void *) __va(num_physpages << PAGE_SHIFT);
+	high_memory = (void *) __va(get_num_physpages() << PAGE_SHIFT);
 
 	for_each_online_node(node) {
 		/*
@@ -494,18 +490,5 @@ void __init mem_init(void)
 
 	setup_zero_pages();	/* This comes from node 0 */
 
-	codesize =  (unsigned long) &_etext - (unsigned long) &_text;
-	datasize =  (unsigned long) &_edata - (unsigned long) &_etext;
-	initsize =  (unsigned long) &__init_end - (unsigned long) &__init_begin;
-
-	tmp = nr_free_pages();
-	printk(KERN_INFO "Memory: %luk/%luk available (%ldk kernel code, "
-	       "%ldk reserved, %ldk data, %ldk init, %ldk highmem)\n",
-	       tmp << (PAGE_SHIFT-10),
-	       num_physpages << (PAGE_SHIFT-10),
-	       codesize >> 10,
-	       (num_physpages - tmp) << (PAGE_SHIFT-10),
-	       datasize >> 10,
-	       initsize >> 10,
-	       totalhigh_pages << (PAGE_SHIFT-10));
+	mem_init_print_info(NULL);
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
