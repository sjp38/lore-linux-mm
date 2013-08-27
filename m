Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 546416B0039
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 05:39:14 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 01/11] memblock: Rename current_limit to current_limit_high in memblock.
Date: Tue, 27 Aug 2013 17:37:38 +0800
Message-Id: <1377596268-31552-2-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

memblock.current_limit specifies the highest address that memblock
could allocate. The next coming patches will introduce a lowest
limit to memblock, so rename it to current_limit_high.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 include/linux/memblock.h |    2 +-
 mm/memblock.c            |   10 +++++-----
 mm/nobootmem.c           |    4 ++--
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index f388203..f0c0a91 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -35,7 +35,7 @@ struct memblock_type {
 };
 
 struct memblock {
-	phys_addr_t current_limit;
+	phys_addr_t current_limit_high;	/* upper boundary of accessable range */
 	struct memblock_type memory;
 	struct memblock_type reserved;
 };
diff --git a/mm/memblock.c b/mm/memblock.c
index a847bfe..ff2226f 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -32,7 +32,7 @@ struct memblock memblock __initdata_memblock = {
 	.reserved.cnt		= 1,	/* empty dummy entry */
 	.reserved.max		= INIT_MEMBLOCK_REGIONS,
 
-	.current_limit		= MEMBLOCK_ALLOC_ANYWHERE,
+	.current_limit_high	= MEMBLOCK_ALLOC_ANYWHERE,
 };
 
 int memblock_debug __initdata_memblock;
@@ -104,7 +104,7 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
 
 	/* pump up @end */
 	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
-		end = memblock.current_limit;
+		end = memblock.current_limit_high;
 
 	/* avoid allocating the first page */
 	start = max_t(phys_addr_t, start, PAGE_SIZE);
@@ -240,11 +240,11 @@ static int __init_memblock memblock_double_array(struct memblock_type *type,
 			new_area_start = new_area_size = 0;
 
 		addr = memblock_find_in_range(new_area_start + new_area_size,
-						memblock.current_limit,
+						memblock.current_limit_high,
 						new_alloc_size, PAGE_SIZE);
 		if (!addr && new_area_size)
 			addr = memblock_find_in_range(0,
-				min(new_area_start, memblock.current_limit),
+				min(new_area_start, memblock.current_limit_high),
 				new_alloc_size, PAGE_SIZE);
 
 		new_array = addr ? __va(addr) : NULL;
@@ -979,7 +979,7 @@ void __init_memblock memblock_trim_memory(phys_addr_t align)
 
 void __init_memblock memblock_set_current_limit(phys_addr_t limit)
 {
-	memblock.current_limit = limit;
+	memblock.current_limit_high = limit;
 }
 
 static void __init_memblock memblock_dump(struct memblock_type *type, char *name)
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 61107cf..8cc163c 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -38,8 +38,8 @@ static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
 	void *ptr;
 	u64 addr;
 
-	if (limit > memblock.current_limit)
-		limit = memblock.current_limit;
+	if (limit > memblock.current_limit_high)
+		limit = memblock.current_limit_high;
 
 	addr = memblock_find_in_range_node(goal, limit, size, align, nid);
 	if (!addr)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
