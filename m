Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 35D0C6B0126
	for <linux-mm@kvack.org>; Wed,  8 May 2013 11:57:40 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb10so1424342pad.9
        for <linux-mm@kvack.org>; Wed, 08 May 2013 08:57:39 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v5, part4 40/41] mm/xtensa: prepare for removing num_physpages and simplify mem_init()
Date: Wed,  8 May 2013 23:51:37 +0800
Message-Id: <1368028298-7401-41-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1368028298-7401-1-git-send-email-jiang.liu@huawei.com>
References: <1368028298-7401-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Geert Uytterhoeven <geert@linux-m68k.org>, linux-xtensa@linux-xtensa.org

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Chris Zankel <chris@zankel.net>
Cc: Max Filippov <jcmvbkbc@gmail.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: linux-xtensa@linux-xtensa.org
Cc: linux-kernel@vger.kernel.org
---
 arch/xtensa/mm/init.c |   27 ++-------------------------
 1 file changed, 2 insertions(+), 25 deletions(-)

diff --git a/arch/xtensa/mm/init.c b/arch/xtensa/mm/init.c
index dc6e009..267428e 100644
--- a/arch/xtensa/mm/init.c
+++ b/arch/xtensa/mm/init.c
@@ -173,12 +173,8 @@ void __init zones_init(void)
 
 void __init mem_init(void)
 {
-	unsigned long codesize, reservedpages, datasize, initsize;
-	unsigned long highmemsize, tmp, ram;
-
-	max_mapnr = num_physpages = max_low_pfn - ARCH_PFN_OFFSET;
+	max_mapnr = max_low_pfn - ARCH_PFN_OFFSET;
 	high_memory = (void *) __va(max_low_pfn << PAGE_SHIFT);
-	highmemsize = 0;
 
 #ifdef CONFIG_HIGHMEM
 #error HIGHGMEM not implemented in init.c
@@ -186,26 +182,7 @@ void __init mem_init(void)
 
 	free_all_bootmem();
 
-	reservedpages = ram = 0;
-	for (tmp = 0; tmp < max_mapnr; tmp++) {
-		ram++;
-		if (PageReserved(mem_map+tmp))
-			reservedpages++;
-	}
-
-	codesize =  (unsigned long) _etext - (unsigned long) _stext;
-	datasize =  (unsigned long) _edata - (unsigned long) _sdata;
-	initsize =  (unsigned long) __init_end - (unsigned long) __init_begin;
-
-	printk("Memory: %luk/%luk available (%ldk kernel code, %ldk reserved, "
-	       "%ldk data, %ldk init %ldk highmem)\n",
-	       nr_free_pages() << (PAGE_SHIFT-10),
-	       ram << (PAGE_SHIFT-10),
-	       codesize >> 10,
-	       reservedpages << (PAGE_SHIFT-10),
-	       datasize >> 10,
-	       initsize >> 10,
-	       highmemsize >> 10);
+	mem_init_print_info(NULL);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
