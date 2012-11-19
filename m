Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 2911D6B007D
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 10:49:37 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 5/5] page_alloc: Bootmem limit with movablecore_map
Date: Mon, 19 Nov 2012 22:27:26 +0800
Message-Id: <1353335246-9127-6-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1353335246-9127-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1353335246-9127-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tangchen@cn.fujitsu.com, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, rob@landley.net, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, yinghai@kernel.org, rusty@rustcorp.com.au
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

This patch make sure bootmem will not allocate memory from areas that
may be ZONE_MOVABLE. The map info is from movablecore_map boot option.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Wen Congyang <wency@cn.fujitsu.com>
Tested-by: Lin Feng <linfeng@cn.fujitsu.com>
---
 include/linux/memblock.h |    1 +
 mm/memblock.c            |   43 ++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 41 insertions(+), 3 deletions(-)

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
index 6259055..0f74c73 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -19,6 +19,7 @@
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
 #include <linux/memblock.h>
+#include <linux/mm.h>
 
 static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
 static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
@@ -99,8 +100,9 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
 					phys_addr_t end, phys_addr_t size,
 					phys_addr_t align, int nid)
 {
-	phys_addr_t this_start, this_end, cand;
+	phys_addr_t this_start, this_end, map_start, map_end, cand;
 	u64 i;
+	int curr = movablecore_map.nr_map;
 
 	/* pump up @end */
 	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
@@ -114,12 +116,47 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
 		this_start = clamp(this_start, start, end);
 		this_end = clamp(this_end, start, end);
 
+restart:
 		if (this_end < size)
 			continue;
 
 		cand = round_down(this_end - size, align);
-		if (cand >= this_start)
-			return cand;
+		if (cand < this_start)
+			continue;
+
+		/*
+		 * We start in reverse order to find out if [cand, this_end) is
+		 * in a movablecore_map range.
+		 */
+		while (--curr >= 0) {
+			map_start =
+				movablecore_map.map[curr].start << PAGE_SHIFT;
+			map_end =
+				movablecore_map.map[curr].end << PAGE_SHIFT;
+
+			/*
+			 * Find the previous range of [this_start, this_end).
+			 * Since memory is allocated in reverse order, we need
+			 * to make sure this_end is after the end of the range.
+			 */
+			if (this_end <= map_end)
+				continue;
+
+			/* [cand, this_end) and range are not overlapped. */
+			if (cand >= map_end)
+				return cand;
+			else {
+				/* Otherwise, goto the previous range. */
+				this_end = map_start;
+				goto restart;
+			}
+		}
+
+		/*
+		 * If movablecore_map has not been initialized yet,
+		 * just return cand.
+		 */
+		return cand;
 	}
 	return 0;
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
