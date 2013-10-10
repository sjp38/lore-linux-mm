Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7CFF86B0031
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 16:16:34 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so3087451pbc.40
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 13:16:34 -0700 (PDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so3295748pab.12
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 13:16:31 -0700 (PDT)
Message-ID: <52570B04.2030608@gmail.com>
Date: Fri, 11 Oct 2013 04:16:04 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH part1 v7 1/6] memblock: Factor out of top-down allocation
References: <52570A6E.2010806@gmail.com>
In-Reply-To: <52570A6E.2010806@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Tejun Heo <tj@kernel.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, mina86@mina86.com, Minchan Kim <minchan@kernel.org>, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com
Cc: "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

From: Tang Chen <tangchen@cn.fujitsu.com>

This patch creates a new function __memblock_find_range_top_down
to factor out of top-down allocation from memblock_find_in_range_node.
This is a preparation because we will introduce a new bottom-up
allocation mode in the following patch.

Acked-by: Tejun Heo <tj@kernel.org>
Acked-by: Toshi Kani <toshi.kani@hp.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/memblock.c |   47 ++++++++++++++++++++++++++++++++++-------------
 1 files changed, 34 insertions(+), 13 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 0ac412a..accff10 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -83,33 +83,25 @@ static long __init_memblock memblock_overlaps_region(struct memblock_type *type,
 }
 
 /**
- * memblock_find_in_range_node - find free area in given range and node
+ * __memblock_find_range_top_down - find free area utility, in top-down
  * @start: start of candidate range
  * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
  * @size: size of free area to find
  * @align: alignment of free area to find
  * @nid: nid of the free area to find, %MAX_NUMNODES for any node
  *
- * Find @size free area aligned to @align in the specified range and node.
+ * Utility called from memblock_find_in_range_node(), find free area top-down.
  *
  * RETURNS:
  * Found address on success, %0 on failure.
  */
-phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
-					phys_addr_t end, phys_addr_t size,
-					phys_addr_t align, int nid)
+static phys_addr_t __init_memblock
+__memblock_find_range_top_down(phys_addr_t start, phys_addr_t end,
+			       phys_addr_t size, phys_addr_t align, int nid)
 {
 	phys_addr_t this_start, this_end, cand;
 	u64 i;
 
-	/* pump up @end */
-	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
-		end = memblock.current_limit;
-
-	/* avoid allocating the first page */
-	start = max_t(phys_addr_t, start, PAGE_SIZE);
-	end = max(start, end);
-
 	for_each_free_mem_range_reverse(i, nid, &this_start, &this_end, NULL) {
 		this_start = clamp(this_start, start, end);
 		this_end = clamp(this_end, start, end);
@@ -121,10 +113,39 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
 		if (cand >= this_start)
 			return cand;
 	}
+
 	return 0;
 }
 
 /**
+ * memblock_find_in_range_node - find free area in given range and node
+ * @start: start of candidate range
+ * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
+ * @size: size of free area to find
+ * @align: alignment of free area to find
+ * @nid: nid of the free area to find, %MAX_NUMNODES for any node
+ *
+ * Find @size free area aligned to @align in the specified range and node.
+ *
+ * RETURNS:
+ * Found address on success, %0 on failure.
+ */
+phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
+					phys_addr_t end, phys_addr_t size,
+					phys_addr_t align, int nid)
+{
+	/* pump up @end */
+	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
+		end = memblock.current_limit;
+
+	/* avoid allocating the first page */
+	start = max_t(phys_addr_t, start, PAGE_SIZE);
+	end = max(start, end);
+
+	return __memblock_find_range_top_down(start, end, size, align, nid);
+}
+
+/**
  * memblock_find_in_range - find free area in given range
  * @start: start of candidate range
  * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
