Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 18B5C6B0062
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 03:16:11 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v4 6/6] page_alloc: Bootmem limit with movablecore_map
Date: Wed, 19 Dec 2012 16:15:03 +0800
Message-Id: <1355904903-22699-7-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1355904903-22699-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1355904903-22699-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, akpm@linux-foundation.org, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tang Chen <tangchen@cn.fujitsu.com>

This patch make sure bootmem will not allocate memory from areas that
may be ZONE_MOVABLE. The map info is from movablecore_map boot option.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
Reviewed-by: Wen Congyang <wency@cn.fujitsu.com>
Tested-by: Lin Feng <linfeng@cn.fujitsu.com>
---
 include/linux/memblock.h |    1 +
 mm/memblock.c            |   18 +++++++++++++++++-
 2 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index d452ee1..6e25597 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -42,6 +42,7 @@ struct memblock {
 
 extern struct memblock memblock;
 extern int memblock_debug;
+extern struct movablecore_map movablecore_map;
 
 #define memblock_dbg(fmt, ...) \
 	if (memblock_debug) printk(KERN_INFO pr_fmt(fmt), ##__VA_ARGS__)
diff --git a/mm/memblock.c b/mm/memblock.c
index 6259055..197c3be 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -101,6 +101,7 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
 {
 	phys_addr_t this_start, this_end, cand;
 	u64 i;
+	int curr = movablecore_map.nr_map - 1;
 
 	/* pump up @end */
 	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
@@ -114,13 +115,28 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
 		this_start = clamp(this_start, start, end);
 		this_end = clamp(this_end, start, end);
 
-		if (this_end < size)
+restart:
+		if (this_end <= this_start || this_end < size)
 			continue;
 
+		for (; curr >= 0; curr--) {
+			if ((movablecore_map.map[curr].start_pfn << PAGE_SHIFT)
+			    < this_end)
+				break;
+		}
+
 		cand = round_down(this_end - size, align);
+		if (curr >= 0 &&
+		    cand < movablecore_map.map[curr].end_pfn << PAGE_SHIFT) {
+			this_end = movablecore_map.map[curr].start_pfn
+				   << PAGE_SHIFT;
+			goto restart;
+		}
+
 		if (cand >= this_start)
 			return cand;
 	}
+
 	return 0;
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
