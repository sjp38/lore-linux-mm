Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 495976B003A
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 13:04:00 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id un1so5098489pbc.26
        for <linux-mm@kvack.org>; Sat, 16 Mar 2013 10:03:59 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part3 03/12] mm/x86: use common help functions to furthur simplify code
Date: Sun, 17 Mar 2013 01:03:24 +0800
Message-Id: <1363453413-8139-4-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1363453413-8139-1-git-send-email-jiang.liu@huawei.com>
References: <1363453413-8139-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Yinghai Lu <yinghai@kernel.org>, Tang Chen <tangchen@cn.fujitsu.com>

Use common help functions to free reserved pages.

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
 arch/x86/mm/init_64.c |    4 ++--
 2 files changed, 5 insertions(+), 13 deletions(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 1120b82..de63100 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -334,7 +334,6 @@ int devmem_is_allowed(unsigned long pagenr)
 
 void free_init_pages(char *what, unsigned long begin, unsigned long end)
 {
-	unsigned long addr;
 	unsigned long begin_aligned, end_aligned;
 
 	/* Make sure boundaries are page aligned */
@@ -349,8 +348,6 @@ void free_init_pages(char *what, unsigned long begin, unsigned long end)
 	if (begin >= end)
 		return;
 
-	addr = begin;
-
 	/*
 	 * If debugging page accesses then do not free this memory but
 	 * mark them not present - any buggy init-section access will
@@ -369,18 +366,13 @@ void free_init_pages(char *what, unsigned long begin, unsigned long end)
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
@@ -397,7 +389,7 @@ void __init free_initrd_mem(unsigned long start, unsigned long end)
 	 *   - relocate_initrd()
 	 * So here We can do PAGE_ALIGN() safely to get partial page to be freed
 	 */
-	free_init_pages("initrd memory", start, PAGE_ALIGN(end));
+	free_init_pages("initrd", start, PAGE_ALIGN(end));
 }
 #endif
 
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 6087e02..05ef3ff 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1152,11 +1152,11 @@ void mark_rodata_ro(void)
 	set_memory_ro(start, (end-start) >> PAGE_SHIFT);
 #endif
 
-	free_init_pages("unused kernel memory",
+	free_init_pages("unused kernel",
 			(unsigned long) page_address(virt_to_page(text_end)),
 			(unsigned long)
 				 page_address(virt_to_page(rodata_start)));
-	free_init_pages("unused kernel memory",
+	free_init_pages("unused kernel",
 			(unsigned long) page_address(virt_to_page(rodata_end)),
 			(unsigned long) page_address(virt_to_page(data_start)));
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
