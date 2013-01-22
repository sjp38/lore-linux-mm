Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id CD8AD6B0023
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 06:47:16 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH Bug fix 4/4] Rename movablecore_map to movablemem_map.
Date: Tue, 22 Jan 2013 19:46:21 +0800
Message-Id: <1358855181-6160-5-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1358855181-6160-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1358855181-6160-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, jiang.liu@huawei.com, julian.calaby@gmail.com, sfr@canb.auug.org.au
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org

Since "core" could be confused with cpu cores, but here it is memory,
so rename the boot option movablecore_map to movablemem_map.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 Documentation/kernel-parameters.txt |    8 ++--
 include/linux/memblock.h            |    2 +-
 include/linux/mm.h                  |    8 ++--
 mm/memblock.c                       |    8 ++--
 mm/page_alloc.c                     |   96 +++++++++++++++++-----------------
 5 files changed, 61 insertions(+), 61 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index f02aa4c..7770611 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1637,7 +1637,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			that the amount of memory usable for all allocations
 			is not too small.
 
-	movablecore_map=nn[KMG]@ss[KMG]
+	movablemem_map=nn[KMG]@ss[KMG]
 			[KNL,X86,IA-64,PPC] This parameter is similar to
 			memmap except it specifies the memory map of
 			ZONE_MOVABLE.
@@ -1647,11 +1647,11 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			ss to the end of the 1st node will be ZONE_MOVABLE,
 			and all the rest nodes will only have ZONE_MOVABLE.
 			If memmap is specified at the same time, the
-			movablecore_map will be limited within the memmap
+			movablemem_map will be limited within the memmap
 			areas. If kernelcore or movablecore is also specified,
-			movablecore_map will have higher priority to be
+			movablemem_map will have higher priority to be
 			satisfied. So the administrator should be careful that
-			the amount of movablecore_map areas are not too large.
+			the amount of movablemem_map areas are not too large.
 			Otherwise kernel won't have enough memory to start.
 
 	MTD_Partition=	[MTD]
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index ac52bbc..1094952 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -60,7 +60,7 @@ int memblock_reserve(phys_addr_t base, phys_addr_t size);
 void memblock_trim_memory(phys_addr_t align);
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
-extern struct movablecore_map movablecore_map;
+extern struct movablemem_map movablemem_map;
 
 void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
 			  unsigned long *out_end_pfn, int *out_nid);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1559e35..7cef651 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1359,15 +1359,15 @@ extern void free_bootmem_with_active_regions(int nid,
 						unsigned long max_low_pfn);
 extern void sparse_memory_present_with_active_regions(int nid);
 
-#define MOVABLECORE_MAP_MAX MAX_NUMNODES
-struct movablecore_entry {
+#define MOVABLEMEM_MAP_MAX MAX_NUMNODES
+struct movablemem_entry {
 	unsigned long start_pfn;    /* start pfn of memory segment */
 	unsigned long end_pfn;      /* end pfn of memory segment (exclusive) */
 };
 
-struct movablecore_map {
+struct movablemem_map {
 	int nr_map;
-	struct movablecore_entry map[MOVABLECORE_MAP_MAX];
+	struct movablemem_entry map[MOVABLEMEM_MAP_MAX];
 };
 
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
diff --git a/mm/memblock.c b/mm/memblock.c
index 0218231..c47ddd5 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -105,7 +105,7 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
 {
 	phys_addr_t this_start, this_end, cand;
 	u64 i;
-	int curr = movablecore_map.nr_map - 1;
+	int curr = movablemem_map.nr_map - 1;
 
 	/* pump up @end */
 	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
@@ -124,15 +124,15 @@ restart:
 			continue;
 
 		for (; curr >= 0; curr--) {
-			if ((movablecore_map.map[curr].start_pfn << PAGE_SHIFT)
+			if ((movablemem_map.map[curr].start_pfn << PAGE_SHIFT)
 			    < this_end)
 				break;
 		}
 
 		cand = round_down(this_end - size, align);
 		if (curr >= 0 &&
-		    cand < movablecore_map.map[curr].end_pfn << PAGE_SHIFT) {
-			this_end = movablecore_map.map[curr].start_pfn
+		    cand < movablemem_map.map[curr].end_pfn << PAGE_SHIFT) {
+			this_end = movablemem_map.map[curr].start_pfn
 				   << PAGE_SHIFT;
 			goto restart;
 		}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2bd529e..3978797 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -202,7 +202,7 @@ static unsigned long __meminitdata dma_reserve;
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 /* Movable memory ranges, will also be used by memblock subsystem. */
-struct movablecore_map movablecore_map;
+struct movablemem_map movablemem_map;
 
 static unsigned long __meminitdata arch_zone_lowest_possible_pfn[MAX_NR_ZONES];
 static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
@@ -4375,7 +4375,7 @@ static unsigned long __meminit zone_absent_pages_in_node(int nid,
  * sanitize_zone_movable_limit() - Sanitize the zone_movable_limit array.
  *
  * zone_movable_limit is initialized as 0. This function will try to get
- * the first ZONE_MOVABLE pfn of each node from movablecore_map, and
+ * the first ZONE_MOVABLE pfn of each node from movablemem_map, and
  * assigne them to zone_movable_limit.
  * zone_movable_limit[nid] == 0 means no limit for the node.
  *
@@ -4386,7 +4386,7 @@ static void __meminit sanitize_zone_movable_limit(void)
 	int map_pos = 0, i, nid;
 	unsigned long start_pfn, end_pfn;
 
-	if (!movablecore_map.nr_map)
+	if (!movablemem_map.nr_map)
 		return;
 
 	/* Iterate all ranges from minimum to maximum */
@@ -4420,22 +4420,22 @@ static void __meminit sanitize_zone_movable_limit(void)
 		if (start_pfn >= end_pfn)
 			continue;
 
-		while (map_pos < movablecore_map.nr_map) {
-			if (end_pfn <= movablecore_map.map[map_pos].start_pfn)
+		while (map_pos < movablemem_map.nr_map) {
+			if (end_pfn <= movablemem_map.map[map_pos].start_pfn)
 				break;
 
-			if (start_pfn >= movablecore_map.map[map_pos].end_pfn) {
+			if (start_pfn >= movablemem_map.map[map_pos].end_pfn) {
 				map_pos++;
 				continue;
 			}
 
 			/*
 			 * The start_pfn of ZONE_MOVABLE is either the minimum
-			 * pfn specified by movablecore_map, or 0, which means
+			 * pfn specified by movablemem_map, or 0, which means
 			 * the node has no ZONE_MOVABLE.
 			 */
 			zone_movable_limit[nid] = max(start_pfn,
-					movablecore_map.map[map_pos].start_pfn);
+					movablemem_map.map[map_pos].start_pfn);
 
 			break;
 		}
@@ -4898,12 +4898,12 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 	}
 
 	/*
-	 * If neither kernelcore/movablecore nor movablecore_map is specified,
-	 * there is no ZONE_MOVABLE. But if movablecore_map is specified, the
+	 * If neither kernelcore/movablecore nor movablemem_map is specified,
+	 * there is no ZONE_MOVABLE. But if movablemem_map is specified, the
 	 * start pfn of ZONE_MOVABLE has been stored in zone_movable_limit[].
 	 */
 	if (!required_kernelcore) {
-		if (movablecore_map.nr_map)
+		if (movablemem_map.nr_map)
 			memcpy(zone_movable_pfn, zone_movable_limit,
 				sizeof(zone_movable_pfn));
 		goto out;
@@ -5168,14 +5168,14 @@ early_param("kernelcore", cmdline_parse_kernelcore);
 early_param("movablecore", cmdline_parse_movablecore);
 
 /**
- * insert_movablecore_map() - Insert a memory range in to movablecore_map.map.
+ * insert_movablemem_map() - Insert a memory range in to movablemem_map.map.
  * @start_pfn:	start pfn of the range
  * @end_pfn:	end pfn of the range
  *
  * This function will also merge the overlapped ranges, and sort the array
  * by start_pfn in monotonic increasing order.
  */
-static void __init insert_movablecore_map(unsigned long start_pfn,
+static void __init insert_movablemem_map(unsigned long start_pfn,
 					  unsigned long end_pfn)
 {
 	int pos, overlap;
@@ -5184,31 +5184,31 @@ static void __init insert_movablecore_map(unsigned long start_pfn,
 	 * pos will be at the 1st overlapped range, or the position
 	 * where the element should be inserted.
 	 */
-	for (pos = 0; pos < movablecore_map.nr_map; pos++)
-		if (start_pfn <= movablecore_map.map[pos].end_pfn)
+	for (pos = 0; pos < movablemem_map.nr_map; pos++)
+		if (start_pfn <= movablemem_map.map[pos].end_pfn)
 			break;
 
 	/* If there is no overlapped range, just insert the element. */
-	if (pos == movablecore_map.nr_map ||
-	    end_pfn < movablecore_map.map[pos].start_pfn) {
+	if (pos == movablemem_map.nr_map ||
+	    end_pfn < movablemem_map.map[pos].start_pfn) {
 		/*
 		 * If pos is not the end of array, we need to move all
 		 * the rest elements backward.
 		 */
-		if (pos < movablecore_map.nr_map)
-			memmove(&movablecore_map.map[pos+1],
-				&movablecore_map.map[pos],
-				sizeof(struct movablecore_entry) *
-				(movablecore_map.nr_map - pos));
-		movablecore_map.map[pos].start_pfn = start_pfn;
-		movablecore_map.map[pos].end_pfn = end_pfn;
-		movablecore_map.nr_map++;
+		if (pos < movablemem_map.nr_map)
+			memmove(&movablemem_map.map[pos+1],
+				&movablemem_map.map[pos],
+				sizeof(struct movablemem_entry) *
+				(movablemem_map.nr_map - pos));
+		movablemem_map.map[pos].start_pfn = start_pfn;
+		movablemem_map.map[pos].end_pfn = end_pfn;
+		movablemem_map.nr_map++;
 		return;
 	}
 
 	/* overlap will be at the last overlapped range */
-	for (overlap = pos + 1; overlap < movablecore_map.nr_map; overlap++)
-		if (end_pfn < movablecore_map.map[overlap].start_pfn)
+	for (overlap = pos + 1; overlap < movablemem_map.nr_map; overlap++)
+		if (end_pfn < movablemem_map.map[overlap].start_pfn)
 			break;
 
 	/*
@@ -5216,29 +5216,29 @@ static void __init insert_movablecore_map(unsigned long start_pfn,
 	 * and move the rest elements forward.
 	 */
 	overlap--;
-	movablecore_map.map[pos].start_pfn = min(start_pfn,
-					movablecore_map.map[pos].start_pfn);
-	movablecore_map.map[pos].end_pfn = max(end_pfn,
-					movablecore_map.map[overlap].end_pfn);
+	movablemem_map.map[pos].start_pfn = min(start_pfn,
+					movablemem_map.map[pos].start_pfn);
+	movablemem_map.map[pos].end_pfn = max(end_pfn,
+					movablemem_map.map[overlap].end_pfn);
 
-	if (pos != overlap && overlap + 1 != movablecore_map.nr_map)
-		memmove(&movablecore_map.map[pos+1],
-			&movablecore_map.map[overlap+1],
-			sizeof(struct movablecore_entry) *
-			(movablecore_map.nr_map - overlap - 1));
+	if (pos != overlap && overlap + 1 != movablemem_map.nr_map)
+		memmove(&movablemem_map.map[pos+1],
+			&movablemem_map.map[overlap+1],
+			sizeof(struct movablemem_entry) *
+			(movablemem_map.nr_map - overlap - 1));
 
-	movablecore_map.nr_map -= overlap - pos;
+	movablemem_map.nr_map -= overlap - pos;
 }
 
 /**
- * movablecore_map_add_region() - Add a memory range into movablecore_map.
+ * movablemem_map_add_region() - Add a memory range into movablemem_map.
  * @start:	physical start address of range
  * @end:	physical end address of range
  *
  * This function transform the physical address into pfn, and then add the
- * range into movablecore_map by calling insert_movablecore_map().
+ * range into movablemem_map by calling insert_movablemem_map().
  */
-static void __init movablecore_map_add_region(u64 start, u64 size)
+static void __init movablemem_map_add_region(u64 start, u64 size)
 {
 	unsigned long start_pfn, end_pfn;
 
@@ -5246,8 +5246,8 @@ static void __init movablecore_map_add_region(u64 start, u64 size)
 	if (start + size <= start)
 		return;
 
-	if (movablecore_map.nr_map >= ARRAY_SIZE(movablecore_map.map)) {
-		pr_err("movable_memory_map: too many entries;"
+	if (movablemem_map.nr_map >= ARRAY_SIZE(movablemem_map.map)) {
+		pr_err("movablemem_map: too many entries;"
 			" ignoring [mem %#010llx-%#010llx]\n",
 			(unsigned long long) start,
 			(unsigned long long) (start + size - 1));
@@ -5256,19 +5256,19 @@ static void __init movablecore_map_add_region(u64 start, u64 size)
 
 	start_pfn = PFN_DOWN(start);
 	end_pfn = PFN_UP(start + size);
-	insert_movablecore_map(start_pfn, end_pfn);
+	insert_movablemem_map(start_pfn, end_pfn);
 }
 
 /*
- * cmdline_parse_movablecore_map() - Parse boot option movablecore_map.
+ * cmdline_parse_movablemem_map() - Parse boot option movablemem_map.
  * @p:	The boot option of the following format:
- * 	movablecore_map=nn[KMG]@ss[KMG]
+ * 	movablemem_map=nn[KMG]@ss[KMG]
  *
  * This option sets the memory range [ss, ss+nn) to be used as movable memory.
  *
  * Return: 0 on success or -EINVAL on failure.
  */
-static int __init cmdline_parse_movablecore_map(char *p)
+static int __init cmdline_parse_movablemem_map(char *p)
 {
 	char *oldp;
 	u64 start_at, mem_size;
@@ -5287,13 +5287,13 @@ static int __init cmdline_parse_movablecore_map(char *p)
 		if (p == oldp || *p != '\0')
 			goto err;
 
-		movablecore_map_add_region(start_at, mem_size);
+		movablemem_map_add_region(start_at, mem_size);
 		return 0;
 	}
 err:
 	return -EINVAL;
 }
-early_param("movablecore_map", cmdline_parse_movablecore_map);
+early_param("movablemem_map", cmdline_parse_movablemem_map);
 
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
