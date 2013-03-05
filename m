Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id AB5986B0025
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 10:01:19 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md12so4591872pbc.16
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 07:01:18 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v1 18/33] mm/ppc: use common help functions to free reserved pages
Date: Tue,  5 Mar 2013 22:55:01 +0800
Message-Id: <1362495317-32682-19-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
References: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Anatolij Gustschin <agust@denx.de>

Use common help functions to free reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Anatolij Gustschin <agust@denx.de>
---
 arch/powerpc/kernel/crash_dump.c             |    5 +----
 arch/powerpc/kernel/fadump.c                 |    5 +----
 arch/powerpc/kernel/kvm.c                    |    7 +------
 arch/powerpc/mm/mem.c                        |   29 ++------------------------
 arch/powerpc/platforms/512x/mpc512x_shared.c |    5 +----
 5 files changed, 6 insertions(+), 45 deletions(-)

diff --git a/arch/powerpc/kernel/crash_dump.c b/arch/powerpc/kernel/crash_dump.c
index b3ba516..9ec3fe1 100644
--- a/arch/powerpc/kernel/crash_dump.c
+++ b/arch/powerpc/kernel/crash_dump.c
@@ -150,10 +150,7 @@ void crash_free_reserved_phys_range(unsigned long begin, unsigned long end)
 		if (addr <= rtas_end && ((addr + PAGE_SIZE) > rtas_start))
 			continue;
 
-		ClearPageReserved(pfn_to_page(addr >> PAGE_SHIFT));
-		init_page_count(pfn_to_page(addr >> PAGE_SHIFT));
-		free_page((unsigned long)__va(addr));
-		totalram_pages++;
+		free_reserved_page(pfn_to_page(addr >> PAGE_SHIFT));
 	}
 }
 #endif
diff --git a/arch/powerpc/kernel/fadump.c b/arch/powerpc/kernel/fadump.c
index 06c8202..2230fd0 100644
--- a/arch/powerpc/kernel/fadump.c
+++ b/arch/powerpc/kernel/fadump.c
@@ -1045,10 +1045,7 @@ static void fadump_release_memory(unsigned long begin, unsigned long end)
 		if (addr <= ra_end && ((addr + PAGE_SIZE) > ra_start))
 			continue;
 
-		ClearPageReserved(pfn_to_page(addr >> PAGE_SHIFT));
-		init_page_count(pfn_to_page(addr >> PAGE_SHIFT));
-		free_page((unsigned long)__va(addr));
-		totalram_pages++;
+		free_reserved_page(pfn_to_page(addr >> PAGE_SHIFT));
 	}
 }
 
diff --git a/arch/powerpc/kernel/kvm.c b/arch/powerpc/kernel/kvm.c
index a61b133..6782221 100644
--- a/arch/powerpc/kernel/kvm.c
+++ b/arch/powerpc/kernel/kvm.c
@@ -756,12 +756,7 @@ static __init void kvm_free_tmp(void)
 	end = (ulong)&kvm_tmp[ARRAY_SIZE(kvm_tmp)] & PAGE_MASK;
 
 	/* Free the tmp space we don't need */
-	for (; start < end; start += PAGE_SIZE) {
-		ClearPageReserved(virt_to_page(start));
-		init_page_count(virt_to_page(start));
-		free_page(start);
-		totalram_pages++;
-	}
+	free_reserved_area(start, end, 0, NULL);
 }
 
 static int __init kvm_guest_init(void)
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index f1f7409..c756713 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -405,39 +405,14 @@ void __init mem_init(void)
 
 void free_initmem(void)
 {
-	unsigned long addr;
-
 	ppc_md.progress = ppc_printk_progress;
-
-	addr = (unsigned long)__init_begin;
-	for (; addr < (unsigned long)__init_end; addr += PAGE_SIZE) {
-		memset((void *)addr, POISON_FREE_INITMEM, PAGE_SIZE);
-		ClearPageReserved(virt_to_page(addr));
-		init_page_count(virt_to_page(addr));
-		free_page(addr);
-		totalram_pages++;
-	}
-	pr_info("Freeing unused kernel memory: %luk freed\n",
-		((unsigned long)__init_end -
-		(unsigned long)__init_begin) >> 10);
+	free_initmem_default(POISON_FREE_INITMEM);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
 void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
-	if (start >= end)
-		return;
-
-	start = _ALIGN_DOWN(start, PAGE_SIZE);
-	end = _ALIGN_UP(end, PAGE_SIZE);
-	pr_info("Freeing initrd memory: %ldk freed\n", (end - start) >> 10);
-
-	for (; start < end; start += PAGE_SIZE) {
-		ClearPageReserved(virt_to_page(start));
-		init_page_count(virt_to_page(start));
-		free_page(start);
-		totalram_pages++;
-	}
+	free_reserved_area(start, end, 0, "initrd");
 }
 #endif
 
diff --git a/arch/powerpc/platforms/512x/mpc512x_shared.c b/arch/powerpc/platforms/512x/mpc512x_shared.c
index d30235b..db6ac38 100644
--- a/arch/powerpc/platforms/512x/mpc512x_shared.c
+++ b/arch/powerpc/platforms/512x/mpc512x_shared.c
@@ -172,12 +172,9 @@ static struct fsl_diu_shared_fb __attribute__ ((__aligned__(8))) diu_shared_fb;
 
 static inline void mpc512x_free_bootmem(struct page *page)
 {
-	__ClearPageReserved(page);
 	BUG_ON(PageTail(page));
 	BUG_ON(atomic_read(&page->_count) > 1);
-	atomic_set(&page->_count, 1);
-	__free_page(page);
-	totalram_pages++;
+	free_reserved_page(page);
 }
 
 void mpc512x_release_bootmem(void)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
