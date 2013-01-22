Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 63E8B6B0011
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 06:47:14 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH Bug fix 1/4] Bug fix: Use CONFIG_HAVE_MEMBLOCK_NODE_MAP to protect movablecore_map in memblock_overlaps_region().
Date: Tue, 22 Jan 2013 19:46:18 +0800
Message-Id: <1358855181-6160-2-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1358855181-6160-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1358855181-6160-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, jiang.liu@huawei.com, julian.calaby@gmail.com, sfr@canb.auug.org.au
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org

The definition of struct movablecore_map is protected by
CONFIG_HAVE_MEMBLOCK_NODE_MAP but its use in memblock_overlaps_region()
is not. So add CONFIG_HAVE_MEMBLOCK_NODE_MAP to protect the use of
movablecore_map in memblock_overlaps_region().

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 include/linux/memblock.h |    3 ++-
 mm/memblock.c            |   34 ++++++++++++++++++++++++++++++++++
 2 files changed, 36 insertions(+), 1 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 6e25597..ac52bbc 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -42,7 +42,6 @@ struct memblock {
 
 extern struct memblock memblock;
 extern int memblock_debug;
-extern struct movablecore_map movablecore_map;
 
 #define memblock_dbg(fmt, ...) \
 	if (memblock_debug) printk(KERN_INFO pr_fmt(fmt), ##__VA_ARGS__)
@@ -61,6 +60,8 @@ int memblock_reserve(phys_addr_t base, phys_addr_t size);
 void memblock_trim_memory(phys_addr_t align);
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
+extern struct movablecore_map movablecore_map;
+
 void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
 			  unsigned long *out_end_pfn, int *out_nid);
 
diff --git a/mm/memblock.c b/mm/memblock.c
index 1e48774..0218231 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -92,9 +92,13 @@ static long __init_memblock memblock_overlaps_region(struct memblock_type *type,
  *
  * Find @size free area aligned to @align in the specified range and node.
  *
+ * If we have CONFIG_HAVE_MEMBLOCK_NODE_MAP defined, we need to check if the
+ * memory we found if not in hotpluggable ranges.
+ *
  * RETURNS:
  * Found address on success, %0 on failure.
  */
+#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
 					phys_addr_t end, phys_addr_t size,
 					phys_addr_t align, int nid)
@@ -139,6 +143,36 @@ restart:
 
 	return 0;
 }
+#else /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
+phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
+					phys_addr_t end, phys_addr_t size,
+					phys_addr_t align, int nid)
+{
+	phys_addr_t this_start, this_end, cand;
+	u64 i;
+
+	/* pump up @end */
+	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
+		end = memblock.current_limit;
+
+	/* avoid allocating the first page */
+	start = max_t(phys_addr_t, start, PAGE_SIZE);
+	end = max(start, end);
+
+	for_each_free_mem_range_reverse(i, nid, &this_start, &this_end, NULL) {
+		this_start = clamp(this_start, start, end);
+		this_end = clamp(this_end, start, end);
+
+		if (this_end < size)
+			continue;
+
+		cand = round_down(this_end - size, align);
+		if (cand >= this_start)
+			return cand;
+	}
+	return 0;
+}
+#endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
 /**
  * memblock_find_in_range - find free area in given range
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
