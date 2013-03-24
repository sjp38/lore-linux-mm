Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 845656B0088
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 03:30:29 -0400 (EDT)
Received: by mail-da0-f50.google.com with SMTP id t1so1264262dae.23
        for <linux-mm@kvack.org>; Sun, 24 Mar 2013 00:30:28 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v2, part4 18/39] mm/h8300: prepare for removing num_physpages and simplify mem_init()
Date: Sun, 24 Mar 2013 15:24:53 +0800
Message-Id: <1364109934-7851-28-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
References: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Geert Uytterhoeven <geert@linux-m68k.org>

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: linux-kernel@vger.kernel.org
---
 arch/h8300/mm/init.c |   34 ++++++++--------------------------
 1 file changed, 8 insertions(+), 26 deletions(-)

diff --git a/arch/h8300/mm/init.c b/arch/h8300/mm/init.c
index 22fd869..0088f3a 100644
--- a/arch/h8300/mm/init.c
+++ b/arch/h8300/mm/init.c
@@ -121,40 +121,22 @@ void __init paging_init(void)
 
 void __init mem_init(void)
 {
-	int codek = 0, datak = 0, initk = 0;
-	/* DAVIDM look at setup memory map generically with reserved area */
-	unsigned long tmp;
-	extern unsigned long  _ramend, _ramstart;
-	unsigned long len = &_ramend - &_ramstart;
-	unsigned long start_mem = memory_start; /* DAVIDM - these must start at end of kernel */
-	unsigned long end_mem   = memory_end; /* DAVIDM - this must not include kernel stack at top */
+	unsigned long codesize = _etext - _stext;
 
 #ifdef DEBUG
-	printk(KERN_DEBUG "Mem_init: start=%lx, end=%lx\n", start_mem, end_mem);
+	pr_debug("Mem_init: start=%lx, end=%lx\n", memory_start, memory_end);
 #endif
 
-	end_mem &= PAGE_MASK;
-	high_memory = (void *) end_mem;
-
-	start_mem = PAGE_ALIGN(start_mem);
-	max_mapnr = num_physpages = MAP_NR(high_memory);
+	high_memory = (void *) (memory_end & PAGE_MASK);
+	max_mapnr = MAP_NR(high_memory);
 
 	/* this will put all low memory onto the freelists */
 	free_all_bootmem();
 
-	codek = (_etext - _stext) >> 10;
-	datak = (__bss_stop - _sdata) >> 10;
-	initk = (__init_begin - __init_end) >> 10;
-
-	tmp = nr_free_pages() << PAGE_SHIFT;
-	printk(KERN_INFO "Memory available: %luk/%luk RAM, %luk/%luk ROM (%dk kernel code, %dk data)\n",
-	       tmp >> 10,
-	       len >> 10,
-	       (rom_length > 0) ? ((rom_length >> 10) - codek) : 0,
-	       rom_length >> 10,
-	       codek,
-	       datak
-	       );
+	mem_init_print_info(NULL);
+	if (rom_length > 0 && rom_length > codesize)
+		pr_info("Memory available: %luK/%luK ROM\n",
+			(rom_length - codesize) >> 10, rom_length >> 10);
 }
 
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
