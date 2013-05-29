Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id F34736B0104
	for <linux-mm@kvack.org>; Wed, 29 May 2013 10:00:15 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so1850699pad.19
        for <linux-mm@kvack.org>; Wed, 29 May 2013 07:00:15 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v6, part4 35/41] mm/SPARC: prepare for removing num_physpages and simplify mem_init()
Date: Wed, 29 May 2013 21:57:53 +0800
Message-Id: <1369835879-23553-36-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1369835879-23553-1-git-send-email-jiang.liu@huawei.com>
References: <1369835879-23553-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, sparclinux@vger.kernel.org

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Acked-by: Sam Ravnborg <sam@ravnborg.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: sparclinux@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 arch/sparc/kernel/leon_smp.c |  3 ---
 arch/sparc/mm/init_32.c      | 34 ++++------------------------------
 arch/sparc/mm/init_64.c      | 24 +++---------------------
 3 files changed, 7 insertions(+), 54 deletions(-)

diff --git a/arch/sparc/kernel/leon_smp.c b/arch/sparc/kernel/leon_smp.c
index 6cfc1b0..d7aa524 100644
--- a/arch/sparc/kernel/leon_smp.c
+++ b/arch/sparc/kernel/leon_smp.c
@@ -254,15 +254,12 @@ void __init leon_smp_done(void)
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
index a438abb..db69870 100644
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
 
@@ -340,39 +334,19 @@ void __init mem_init(void)
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
-	num_physpages += free_reserved_area((void *)start, (void *)end,
-					    POISON_FREE_INITMEM, "initrd");
+	free_reserved_area((void *)start, (void *)end, POISON_FREE_INITMEM,
+			   "initrd");
 }
 #endif
 
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index ee6deda..f140dca 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2038,7 +2038,6 @@ static void __init register_page_bootmem_info(void)
 }
 void __init mem_init(void)
 {
-	unsigned long codepages, datapages, initpages;
 	unsigned long addr, last;
 
 	addr = PAGE_OFFSET + kern_base;
@@ -2056,11 +2055,6 @@ void __init mem_init(void)
 	register_page_bootmem_info();
 	free_all_bootmem();
 
-	/* We subtract one to account for the mem_map_zero page
-	 * allocated below.
-	 */
-	num_physpages = totalram_pages - 1;
-
 	/*
 	 * Set up the zero page, mark it reserved, so that page count
 	 * is not manipulated when freeing the page from user ptes.
@@ -2072,19 +2066,7 @@ void __init mem_init(void)
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
@@ -2124,8 +2106,8 @@ void free_initmem(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	num_physpages += free_reserved_area((void *)start, (void *)end,
-					    POISON_FREE_INITMEM, "initrd");
+	free_reserved_area((void *)start, (void *)end, POISON_FREE_INITMEM,
+			   "initrd");
 }
 #endif
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
