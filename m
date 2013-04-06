Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 9D94D6B01FC
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 10:47:03 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id xa7so2472592pbc.13
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 07:47:02 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v4, part3 35/41] mm/SPARC: prepare for removing num_physpages and simplify mem_init()
Date: Sat,  6 Apr 2013 22:32:34 +0800
Message-Id: <1365258760-30821-36-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1365258760-30821-1-git-send-email-jiang.liu@huawei.com>
References: <1365258760-30821-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Sam Ravnborg <sam@ravnborg.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, sparclinux@vger.kernel.org

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Sam Ravnborg <sam@ravnborg.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: sparclinux@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 arch/sparc/kernel/leon_smp.c |    3 ---
 arch/sparc/mm/init_32.c      |   33 +++------------------------------
 arch/sparc/mm/init_64.c      |   23 ++---------------------
 3 files changed, 5 insertions(+), 54 deletions(-)

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
index 541a3bc..b1e35b7 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2039,7 +2039,6 @@ static void __init register_page_bootmem_info(void)
 }
 void __init mem_init(void)
 {
-	unsigned long codepages, datapages, initpages;
 	unsigned long addr, last;
 
 	addr = PAGE_OFFSET + kern_base;
@@ -2057,11 +2056,6 @@ void __init mem_init(void)
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
@@ -2073,19 +2067,7 @@ void __init mem_init(void)
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
@@ -2125,8 +2107,7 @@ void free_initmem(void)
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
