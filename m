Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 6C2F58D0003
	for <linux-mm@kvack.org>; Mon, 24 Dec 2012 07:10:31 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v5 07/14] memory-hotplug: move pgdat_resize_lock into sparse_remove_one_section()
Date: Mon, 24 Dec 2012 20:09:17 +0800
Message-Id: <1356350964-13437-8-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

In __remove_section(), we locked pgdat_resize_lock when calling
sparse_remove_one_section(). This lock will disable irq. But we don't need
to lock the whole function. If we do some work to free pagetables in
free_section_usemap(), we need to call flush_tlb_all(), which need
irq enabled. Otherwise the WARN_ON_ONCE() in smp_call_function_many()
will be triggered.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 mm/memory_hotplug.c |    4 ----
 mm/sparse.c         |    5 ++++-
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 34c656b..c12bd55 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -442,8 +442,6 @@ static int __remove_section(struct zone *zone, struct mem_section *ms)
 #else
 static int __remove_section(struct zone *zone, struct mem_section *ms)
 {
-	unsigned long flags;
-	struct pglist_data *pgdat = zone->zone_pgdat;
 	int ret = -EINVAL;
 
 	if (!valid_section(ms))
@@ -453,9 +451,7 @@ static int __remove_section(struct zone *zone, struct mem_section *ms)
 	if (ret)
 		return ret;
 
-	pgdat_resize_lock(pgdat, &flags);
 	sparse_remove_one_section(zone, ms);
-	pgdat_resize_unlock(pgdat, &flags);
 	return 0;
 }
 #endif
diff --git a/mm/sparse.c b/mm/sparse.c
index aadbb2a..05ca73a 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -796,8 +796,10 @@ static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
 void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
 {
 	struct page *memmap = NULL;
-	unsigned long *usemap = NULL;
+	unsigned long *usemap = NULL, flags;
+	struct pglist_data *pgdat = zone->zone_pgdat;
 
+	pgdat_resize_lock(pgdat, &flags);
 	if (ms->section_mem_map) {
 		usemap = ms->pageblock_flags;
 		memmap = sparse_decode_mem_map(ms->section_mem_map,
@@ -805,6 +807,7 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
 		ms->section_mem_map = 0;
 		ms->pageblock_flags = NULL;
 	}
+	pgdat_resize_unlock(pgdat, &flags);
 
 	clear_hwpoisoned_pages(memmap, PAGES_PER_SECTION);
 	free_section_usemap(memmap, usemap);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
