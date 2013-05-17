Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id A4B676B0036
	for <linux-mm@kvack.org>; Fri, 17 May 2013 11:46:07 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa10so3690145pad.19
        for <linux-mm@kvack.org>; Fri, 17 May 2013 08:46:06 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v7, part3 04/16] mm/x86: use free_reserved_area() to simplify code
Date: Fri, 17 May 2013 23:45:06 +0800
Message-Id: <1368805518-2634-5-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1368805518-2634-1-git-send-email-jiang.liu@huawei.com>
References: <1368805518-2634-1-git-send-email-jiang.liu@huawei.com>
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
 arch/x86/mm/init.c    | 14 +++-----------
 arch/x86/mm/init_64.c |  5 ++---
 2 files changed, 5 insertions(+), 14 deletions(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index fed9993..9048d94 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -494,7 +494,6 @@ int devmem_is_allowed(unsigned long pagenr)
 
 void free_init_pages(char *what, unsigned long begin, unsigned long end)
 {
-	unsigned long addr;
 	unsigned long begin_aligned, end_aligned;
 
 	/* Make sure boundaries are page aligned */
@@ -509,8 +508,6 @@ void free_init_pages(char *what, unsigned long begin, unsigned long end)
 	if (begin >= end)
 		return;
 
-	addr = begin;
-
 	/*
 	 * If debugging page accesses then do not free this memory but
 	 * mark them not present - any buggy init-section access will
@@ -529,18 +526,13 @@ void free_init_pages(char *what, unsigned long begin, unsigned long end)
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
@@ -566,7 +558,7 @@ void __init free_initrd_mem(unsigned long start, unsigned long end)
 	 *   - relocate_initrd()
 	 * So here We can do PAGE_ALIGN() safely to get partial page to be freed
 	 */
-	free_init_pages("initrd memory", start, PAGE_ALIGN(end));
+	free_init_pages("initrd", start, PAGE_ALIGN(end));
 }
 #endif
 
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index bb00c46..32e2f25 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1166,11 +1166,10 @@ void mark_rodata_ro(void)
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
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
