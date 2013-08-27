Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 90BE76B003A
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 05:39:15 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 03/11] memblock: Introduce lowest limit in memblock.
Date: Tue, 27 Aug 2013 17:37:40 +0800
Message-Id: <1377596268-31552-4-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

The current memblock allocates memory from high address to low. And it has
a highest limit.

The next coming patches will improve memblock to be able to allocate memory
from low address to high. So we need a lowest limit.

Introduce current_limit_low to memblock. When users specify start address
as MEMBLOCK_ALLOC_ACCESSIBLE, memblock will use current_limit_low as the
low limit of allocation.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 include/linux/memblock.h |    1 +
 mm/memblock.c            |   18 +++++++++++++++---
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index c28cd6b..40eb18e 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -35,6 +35,7 @@ struct memblock_type {
 };
 
 struct memblock {
+	phys_addr_t current_limit_low;	/* lower boundary of accessable range */
 	phys_addr_t current_limit_high;	/* upper boundary of accessable range */
 	struct memblock_type memory;
 	struct memblock_type reserved;
diff --git a/mm/memblock.c b/mm/memblock.c
index d351911..0dd5387 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -32,6 +32,7 @@ struct memblock memblock __initdata_memblock = {
 	.reserved.cnt		= 1,	/* empty dummy entry */
 	.reserved.max		= INIT_MEMBLOCK_REGIONS,
 
+	.current_limit_low	= 0,
 	.current_limit_high	= MEMBLOCK_ALLOC_ANYWHERE,
 };
 
@@ -84,7 +85,7 @@ static long __init_memblock memblock_overlaps_region(struct memblock_type *type,
 
 /**
  * memblock_find_in_range_node - find free area in given range and node
- * @start: start of candidate range
+ * @start: start of candidate range, can be %MEMBLOCK_ALLOC_ACCESSIBLE
  * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
  * @size: size of free area to find
  * @align: alignment of free area to find
@@ -92,6 +93,15 @@ static long __init_memblock memblock_overlaps_region(struct memblock_type *type,
  *
  * Find @size free area aligned to @align in the specified range and node.
  *
+ * If @start is %MEMBLOCK_ALLOC_ACCESSIBLE, then set @start to
+ * memblock.current_limit_low which limit the lowest address memblock could
+ * access. %MEMBLOCK_ALLOC_ACCESSIBLE means nothing to @start.
+ *
+ * If @end is %MEMBLOCK_ALLOC_ACCESSIBLE, then set @start to
+ * memblock.current_limit_high which limit the highest address memblock could
+ * access. @end can also be %MEMBLOCK_ALLOC_ANYWHERE, which is the maximum
+ * physical address.
+ *
  * RETURNS:
  * Found address on success, %0 on failure.
  */
@@ -102,7 +112,9 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
 	phys_addr_t this_start, this_end, cand;
 	u64 i;
 
-	/* pump up @end */
+	/* pump up @start and @end */
+	if (start == MEMBLOCK_ALLOC_ACCESSIBLE)
+		start = memblock.current_limit_low;
 	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
 		end = memblock.current_limit_high;
 
@@ -126,7 +138,7 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
 
 /**
  * memblock_find_in_range - find free area in given range
- * @start: start of candidate range
+ * @start: start of candidate range, can be %MEMBLOCK_ALLOC_ACCESSIBLE
  * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
  * @size: size of free area to find
  * @align: alignment of free area to find
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
