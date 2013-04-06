Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 1EF696B0156
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 09:56:15 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id um15so2438301pbc.22
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 06:56:14 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v4, part3 04/15] mm/x86: use free_reserved_area() to simplify code
Date: Sat,  6 Apr 2013 21:54:58 +0800
Message-Id: <1365256509-29024-5-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1365256509-29024-1-git-send-email-jiang.liu@huawei.com>
References: <1365256509-29024-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Yinghai Lu <yinghai@kernel.org>, Tang Chen <tangchen@cn.fujitsu.com>

Use common help function free_reserved_area() to simplify code.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>
Cc: Jianguo Wu <wujianguo@huawei.com>
Cc: linux-kernel@vger.kernel.org
---
 arch/x86/mm/init.c    |   14 +++-----------
 arch/x86/mm/init_64.c |    5 ++---
 2 files changed, 5 insertions(+), 14 deletions(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index fdc5dca..6738e1b 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -477,7 +477,6 @@ int devmem_is_allowed(unsigned long pagenr)
 
 void free_init_pages(char *what, unsigned long begin, unsigned long end)
 {
-	unsigned long addr;
 	unsigned long begin_aligned, end_aligned;
 
 	/* Make sure boundaries are page aligned */
@@ -492,8 +491,6 @@ void free_init_pages(char *what, unsigned long begin, unsigned long end)
 	if (begin >= end)
 		return;
 
-	addr = begin;
-
 	/*
 	 * If debugging page accesses then do not free this memory but
 	 * mark them not present - any buggy init-section access will
@@ -512,18 +509,13 @@ void free_init_pages(char *what, unsigned long begin, unsigned long end)
 	set_memory_nx(begin, (end - begin) >> PAGE_SHIFT);
 	set_memory_rw(begin, (end - begin) >> PAGE_SHIFT);
 
-	printk(KERN_INFO "Freeing %s: %luk freed\n", what, (end - begin) >> 10);
-
-	for (; addr < end; addr += PAGE_SIZE) {
-		memset((void *)addr, POISON_FREE_INITMEM, PAGE_SIZE);
-		free_reserved_page(virt_to_page(addr));
-	}
+	free_reserved_area(begin, end, POISON_FREE_INITMEM, what);
 #endif
 }
 
 void free_initmem(void)
 {
-	free_init_pages("unused kernel memory",
+	free_init_pages("unused kernel",
 			(unsigned long)(&__init_begin),
 			(unsigned long)(&__init_end));
 }
@@ -549,7 +541,7 @@ void __init free_initrd_mem(unsigned long start, unsigned long end)
 	 *   - relocate_initrd()
 	 * So here We can do PAGE_ALIGN() safely to get partial page to be freed
 	 */
-	free_init_pages("initrd memory", start, PAGE_ALIGN(end));
+	free_init_pages("initrd", start, PAGE_ALIGN(end));
 }
 #endif
 
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index caad9a0..0c6efb8 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1165,11 +1165,10 @@ void mark_rodata_ro(void)
 	set_memory_ro(start, (end-start) >> PAGE_SHIFT);
 #endif
 
-	free_init_pages("unused kernel memory",
+	free_init_pages("unused kernel",
 			(unsigned long) __va(__pa_symbol(text_end)),
 			(unsigned long) __va(__pa_symbol(rodata_start)));
-
-	free_init_pages("unused kernel memory",
+	free_init_pages("unused kernel",
 			(unsigned long) __va(__pa_symbol(rodata_end)),
 			(unsigned long) __va(__pa_symbol(_sdata)));
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
