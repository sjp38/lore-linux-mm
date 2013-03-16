Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id B33706B0068
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 13:04:32 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id up1so5091338pbc.9
        for <linux-mm@kvack.org>; Sat, 16 Mar 2013 10:04:32 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part3 09/12] mm: avoid using __free_pages_bootmem() at runtime
Date: Sun, 17 Mar 2013 01:03:30 +0800
Message-Id: <1363453413-8139-10-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1363453413-8139-1-git-send-email-jiang.liu@huawei.com>
References: <1363453413-8139-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Yinghai Lu <yinghai@kernel.org>, x86@kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Avoid using __free_pages_bootmem() at runtime, so we could easily
manage totalram_pages and zone->managed_pages. With this change applied,
__free_pages_bootmem() is only used by bootmem.c and nobootmem.c at
boot time, so mark it as __init. And other callers of
__free_pages_bootmem() have been switched to free_reserved_page(),
which handles totalram_pages and zone->managed_pages in a safe way.

This patch also fix a bug in free_pagetable() for x86_64, which should
increase zone->managed_pages instead of zone->present_pages when freeing
reserved pages.

And free_reserved_page() protects totalram_pages and zone->managed_pages
with managed_pages_count_lock, so remove the redundant ppb_lock lock in
put_page_bootmem(). This makes the locking rules much more clear.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: x86@kernel.org
Cc: Wen Congyang <wency@cn.fujitsu.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 arch/x86/mm/init_64.c |   18 ++----------------
 mm/memory_hotplug.c   |   16 ++--------------
 mm/page_alloc.c       |    9 +--------
 3 files changed, 5 insertions(+), 38 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 05ef3ff..5e19126 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -694,36 +694,22 @@ EXPORT_SYMBOL_GPL(arch_add_memory);
 
 static void __meminit free_pagetable(struct page *page, int order)
 {
-	struct zone *zone;
-	bool bootmem = false;
 	unsigned long magic;
 	unsigned int nr_pages = 1 << order;
 
 	/* bootmem page has reserved flag */
 	if (PageReserved(page)) {
 		__ClearPageReserved(page);
-		bootmem = true;
 
 		magic = (unsigned long)page->lru.next;
 		if (magic == SECTION_INFO || magic == MIX_SECTION_INFO) {
 			while (nr_pages--)
 				put_page_bootmem(page++);
 		} else
-			__free_pages_bootmem(page, order);
+			while (nr_pages--)
+				free_reserved_page(page++);
 	} else
 		free_pages((unsigned long)page_address(page), order);
-
-	/*
-	 * SECTION_INFO pages and MIX_SECTION_INFO pages
-	 * are all allocated by bootmem.
-	 */
-	if (bootmem) {
-		zone = page_zone(page);
-		zone_span_writelock(zone);
-		zone->present_pages += nr_pages;
-		zone_span_writeunlock(zone);
-		totalram_pages += nr_pages;
-	}
 }
 
 static void __meminit free_pte_table(pte_t *pte_start, pmd_t *pmd)
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 40c3c78..a1debd0 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -101,12 +101,9 @@ void get_page_bootmem(unsigned long info,  struct page *page,
 	atomic_inc(&page->_count);
 }
 
-/* reference to __meminit __free_pages_bootmem is valid
- * so use __ref to tell modpost not to generate a warning */
-void __ref put_page_bootmem(struct page *page)
+void put_page_bootmem(struct page *page)
 {
 	unsigned long type;
-	static DEFINE_MUTEX(ppb_lock);
 
 	type = (unsigned long) page->lru.next;
 	BUG_ON(type < MEMORY_HOTPLUG_MIN_BOOTMEM_TYPE ||
@@ -116,17 +113,8 @@ void __ref put_page_bootmem(struct page *page)
 		ClearPagePrivate(page);
 		set_page_private(page, 0);
 		INIT_LIST_HEAD(&page->lru);
-
-		/*
-		 * Please refer to comment for __free_pages_bootmem()
-		 * for why we serialize here.
-		 */
-		mutex_lock(&ppb_lock);
-		__free_pages_bootmem(page, 0);
-		mutex_unlock(&ppb_lock);
-		totalram_pages++;
+		free_reserved_page(page);
 	}
-
 }
 
 #ifndef CONFIG_SPARSEMEM_VMEMMAP
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9d08d06..b0ca2b7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -740,14 +740,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	local_irq_restore(flags);
 }
 
-/*
- * Read access to zone->managed_pages is safe because it's unsigned long,
- * but we still need to serialize writers. Currently all callers of
- * __free_pages_bootmem() except put_page_bootmem() should only be used
- * at boot time. So for shorter boot time, we shift the burden to
- * put_page_bootmem() to serialize writers.
- */
-void __meminit __free_pages_bootmem(struct page *page, unsigned int order)
+void __init __free_pages_bootmem(struct page *page, unsigned int order)
 {
 	unsigned int nr_pages = 1 << order;
 	unsigned int loop;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
