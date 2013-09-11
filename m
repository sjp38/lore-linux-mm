Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 105096B0033
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 06:05:27 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 2/9] x86, memblock: Introduce memblock_alloc_bottom_up() to memblock.
Date: Wed, 11 Sep 2013 18:07:30 +0800
Message-Id: <1378894057-30946-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1378894057-30946-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1378894057-30946-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, toshi.kani@hp.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

This patch introduces a new API memblock_alloc_bottom_up() to make memblock be
able to allocate from bottom upwards.

During early boot, if the bottom up mode is set, just try allocating bottom up
from the end of kernel image, and if that fails, do normal top down allocation.

Suggested-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 include/linux/memblock.h |    2 ++
 mm/memblock.c            |   38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index fbf6b6d..9a0958f 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -151,6 +151,8 @@ phys_addr_t memblock_alloc_nid(phys_addr_t size, phys_addr_t align, int nid);
 phys_addr_t memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid);
 
 phys_addr_t memblock_alloc(phys_addr_t size, phys_addr_t align);
+phys_addr_t memblock_alloc_bottom_up(phys_addr_t start, phys_addr_t end,
+				     phys_addr_t size, phys_addr_t align);
 
 static inline bool memblock_direction_bottom_up(void)
 {
diff --git a/mm/memblock.c b/mm/memblock.c
index 7add615..d7485b9 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -20,6 +20,8 @@
 #include <linux/seq_file.h>
 #include <linux/memblock.h>
 
+#include <asm-generic/sections.h>
+
 static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
 static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
 
@@ -786,6 +788,42 @@ static phys_addr_t __init memblock_alloc_base_nid(phys_addr_t size,
 	return 0;
 }
 
+/**
+ * memblock_alloc_bottom_up - allocate memory from bottom upwards
+ * @start: start of candidate range, can be %MEMBLOCK_ALLOC_ACCESSIBLE
+ * @@end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
+ * @size: size of free area to allocate
+ * @align: alignment of free area to allocate
+ *
+ * Allocate @size free area aligned to @align from the end of the kernel image
+ * upwards.
+ *
+ * Found address on success, %0 on failure.
+ */
+phys_addr_t __init_memblock memblock_alloc_bottom_up(phys_addr_t start,
+					phys_addr_t end, phys_addr_t size,
+					phys_addr_t align)
+{
+	phys_addr_t this_start, this_end, cand;
+	u64 i;
+
+	if (start == MEMBLOCK_ALLOC_ACCESSIBLE)
+		start = __pa_symbol(_end);	/* End of kernel image. */
+	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
+		end = memblock.current_limit;
+
+	for_each_free_mem_range(i, MAX_NUMNODES, &this_start, &this_end, NULL) {
+		this_start = clamp(this_start, start, end);
+		this_end = clamp(this_end, start, end);
+
+		cand = round_up(this_start, align);
+		if (cand < this_end && this_end - cand >= size)
+			return cand;
+	}
+
+	return 0;
+}
+
 phys_addr_t __init memblock_alloc_nid(phys_addr_t size, phys_addr_t align, int nid)
 {
 	return memblock_alloc_base_nid(size, align, MEMBLOCK_ALLOC_ACCESSIBLE, nid);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
