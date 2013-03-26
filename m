Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id EA2A26B012B
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 12:02:51 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id wy12so4778098pbc.21
        for <linux-mm@kvack.org>; Tue, 26 Mar 2013 09:02:51 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v3, part4 32/39] mm/SPARC: prepare for removing num_physpages and simplify mem_init()
Date: Tue, 26 Mar 2013 23:54:51 +0800
Message-Id: <1364313298-17336-33-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364313298-17336-1-git-send-email-jiang.liu@huawei.com>
References: <1364313298-17336-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Sam Ravnborg <sam@ravnborg.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, sparclinux@vger.kernel.org

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Sam Ravnborg <sam@ravnborg.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: sparclinux@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
Hi all,
	Sorry for my mistake that my previous patch series has been screwed up.
So I regenerate a third version and also set up a git tree at:
	git://github.com/jiangliu/linux.git mem_init
	Any help to review and test are welcomed!

	Regards!
	Gerry
---
 arch/sparc/kernel/leon_smp.c |    3 ---
 arch/sparc/mm/init_32.c      |   33 +++------------------------------
 arch/sparc/mm/init_64.c      |   27 +++------------------------
 3 files changed, 6 insertions(+), 57 deletions(-)

diff --git a/arch/sparc/kernel/leon_smp.c b/arch/sparc/kernel/leon_smp.c
index 143b1a5..5a9ab8d 100644
--- a/arch/sparc/kernel/leon_smp.c
+++ b/arch/sparc/kernel/leon_smp.c
@@ -269,15 +269,12 @@ void __init leon_smp_done(void)
 	/* Free unneeded trap tables */
 	if (!cpu_present(1)) {
 		free_reserved_page(virt_to_page(&trapbase_cpu1));
-		num_physpages++;
 	}
 	if (!cpu_present(2)) {
 		free_reserved_page(virt_to_page(&trapbase_cpu2));
-		num_physpages++;
 	}
 	if (!cpu_present(3)) {
 		free_reserved_page(virt_to_page(&trapbase_cpu3));
-		num_physpages++;
 	}
 	/* Ok, they are spinning and ready to go. */
 	smp_processors_ready = 1;
diff --git a/arch/sparc/mm/init_32.c b/arch/sparc/mm/init_32.c
index e96afed..25d10cf 100644
--- a/arch/sparc/mm/init_32.c
+++ b/arch/sparc/mm/init_32.c
@@ -288,10 +288,6 @@ static void map_high_region(unsigned long start_pfn, unsigned long end_pfn)
 
 void __init mem_init(void)
 {
-	int codepages = 0;
-	int datapages = 0;
-	int initpages = 0; 
-	int reservedpages = 0;
 	int i;
 
 	if (PKMAP_BASE+LAST_PKMAP*PAGE_SIZE >= FIXADDR_START) {
@@ -329,8 +325,6 @@ void __init mem_init(void)
 		unsigned long start_pfn = sp_banks[i].base_addr >> PAGE_SHIFT;
 		unsigned long end_pfn = (sp_banks[i].base_addr + sp_banks[i].num_bytes) >> PAGE_SHIFT;
 
-		num_physpages += sp_banks[i].num_bytes >> PAGE_SHIFT;
-
 		if (end_pfn <= highstart_pfn)
 			continue;
 
@@ -340,39 +334,18 @@ void __init mem_init(void)
 		map_high_region(start_pfn, end_pfn);
 	}
 	
-	codepages = (((unsigned long) &_etext) - ((unsigned long)&_start));
-	codepages = PAGE_ALIGN(codepages) >> PAGE_SHIFT;
-	datapages = (((unsigned long) &_edata) - ((unsigned long)&_etext));
-	datapages = PAGE_ALIGN(datapages) >> PAGE_SHIFT;
-	initpages = (((unsigned long) &__init_end) - ((unsigned long) &__init_begin));
-	initpages = PAGE_ALIGN(initpages) >> PAGE_SHIFT;
-
-	/* Ignore memory holes for the purpose of counting reserved pages */
-	for (i=0; i < max_low_pfn; i++)
-		if (test_bit(i >> (20 - PAGE_SHIFT), sparc_valid_addr_bitmap)
-		    && PageReserved(pfn_to_page(i)))
-			reservedpages++;
-
-	printk(KERN_INFO "Memory: %luk/%luk available (%dk kernel code, %dk reserved, %dk data, %dk init, %ldk highmem)\n",
-	       nr_free_pages() << (PAGE_SHIFT-10),
-	       num_physpages << (PAGE_SHIFT - 10),
-	       codepages << (PAGE_SHIFT-10),
-	       reservedpages << (PAGE_SHIFT - 10),
-	       datapages << (PAGE_SHIFT-10), 
-	       initpages << (PAGE_SHIFT-10),
-	       totalhigh_pages << (PAGE_SHIFT-10));
+	mem_init_print_info(NULL);
 }
 
 void free_initmem (void)
 {
-	num_physpages += free_initmem_default(POISON_FREE_INITMEM);
+	free_initmem_default(POISON_FREE_INITMEM);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	num_physpages += free_reserved_area(start, end, POISON_FREE_INITMEM,
-					    "initrd");
+	free_reserved_area(start, end, POISON_FREE_INITMEM, "initrd");
 }
 #endif
 
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index fde310e..6768e47 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2023,7 +2023,6 @@ static void __init patch_tlb_miss_handler_bitmap(void)
 
 void __init mem_init(void)
 {
-	unsigned long codepages, datapages, initpages;
 	unsigned long addr, last;
 
 	addr = PAGE_OFFSET + kern_base;
@@ -2051,11 +2050,6 @@ void __init mem_init(void)
 	free_all_bootmem();
 #endif
 
-	/* We subtract one to account for the mem_map_zero page
-	 * allocated below.
-	 */
-	num_physpages = totalram_pages - 1;
-
 	/*
 	 * Set up the zero page, mark it reserved, so that page count
 	 * is not manipulated when freeing the page from user ptes.
@@ -2067,19 +2061,7 @@ void __init mem_init(void)
 	}
 	mark_page_reserved(mem_map_zero);
 
-	codepages = (((unsigned long) _etext) - ((unsigned long) _start));
-	codepages = PAGE_ALIGN(codepages) >> PAGE_SHIFT;
-	datapages = (((unsigned long) _edata) - ((unsigned long) _etext));
-	datapages = PAGE_ALIGN(datapages) >> PAGE_SHIFT;
-	initpages = (((unsigned long) __init_end) - ((unsigned long) __init_begin));
-	initpages = PAGE_ALIGN(initpages) >> PAGE_SHIFT;
-
-	printk("Memory: %luk available (%ldk kernel code, %ldk data, %ldk init) [%016lx,%016lx]\n",
-	       nr_free_pages() << (PAGE_SHIFT-10),
-	       codepages << (PAGE_SHIFT-10),
-	       datapages << (PAGE_SHIFT-10), 
-	       initpages << (PAGE_SHIFT-10), 
-	       PAGE_OFFSET, (last_valid_pfn << PAGE_SHIFT));
+	mem_init_print_info(NULL);
 
 	if (tlb_type == cheetah || tlb_type == cheetah_plus)
 		cheetah_ecache_flush_init();
@@ -2111,18 +2093,15 @@ void free_initmem(void)
 			((unsigned long) KERNBASE));
 		memset((void *)addr, POISON_FREE_INITMEM, PAGE_SIZE);
 
-		if (do_free) {
+		if (do_free)
 			free_reserved_page(virt_to_page(page));
-			num_physpages++;
-		}
 	}
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	num_physpages += free_reserved_area(start, end, POISON_FREE_INITMEM,
-					    "initrd");
+	free_reserved_area(start, end, POISON_FREE_INITMEM, "initrd");
 }
 #endif
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
