Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 8F9476B00E8
	for <linux-mm@kvack.org>; Wed, 29 May 2013 09:59:22 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx1so9311533pab.27
        for <linux-mm@kvack.org>; Wed, 29 May 2013 06:59:21 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v6, part4 20/41] mm/h8300: prepare for removing num_physpages and simplify mem_init()
Date: Wed, 29 May 2013 21:57:38 +0800
Message-Id: <1369835879-23553-21-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1369835879-23553-1-git-send-email-jiang.liu@huawei.com>
References: <1369835879-23553-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Geert Uytterhoeven <geert@linux-m68k.org>

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: linux-kernel@vger.kernel.org
---
 arch/h8300/mm/init.c | 36 ++++++++----------------------------
 1 file changed, 8 insertions(+), 28 deletions(-)

diff --git a/arch/h8300/mm/init.c b/arch/h8300/mm/init.c
index a506dd4..6c1251e 100644
--- a/arch/h8300/mm/init.c
+++ b/arch/h8300/mm/init.c
@@ -121,40 +121,20 @@ void __init paging_init(void)
 
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
 
-#ifdef DEBUG
-	printk(KERN_DEBUG "Mem_init: start=%lx, end=%lx\n", start_mem, end_mem);
-#endif
-
-	end_mem &= PAGE_MASK;
-	high_memory = (void *) end_mem;
+	pr_devel("Mem_init: start=%lx, end=%lx\n", memory_start, memory_end);
 
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
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
