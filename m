Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 669166B0008
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 00:42:21 -0500 (EST)
Message-ID: <50FF75D1.6070303@cn.fujitsu.com>
Date: Wed, 23 Jan 2013 13:32:01 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: Build error of mmotm-2013-01-18-15-48
References: <20130123041101.GC2723@blaptop>
In-Reply-To: <20130123041101.GC2723@blaptop>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Tang Chen <tangchen@cn.fujitsu.com>

On 01/23/2013 12:11 PM, Minchan Kim wrote:
> Hi Tang Chen,
>
> I encountered build error from mmotm-2013-01-18-15-48 when I try to
> build ARM config. I know you sent a bunch of patches but not sure
> it was fixed via them.
>
> Thanks.
>
>    CHK     include/generated/uapi/linux/version.h
>    CHK     include/generated/utsrelease.h
> make[1]: `include/generated/mach-types.h' is up to date.
>    CALL    scripts/checksyscalls.sh
>    CC      mm/memblock.o
> mm/memblock.c: In function 'memblock_find_in_range_node':
> mm/memblock.c:104: error: invalid use of undefined type 'struct movablecore_map'
> mm/memblock.c:123: error: invalid use of undefined type 'struct movablecore_map'
> mm/memblock.c:130: error: invalid use of undefined type 'struct movablecore_map'
> mm/memblock.c:131: error: invalid use of undefined type 'struct movablecore_map'
>

Hi Minchan,

Thank you for reporting this. :)

I think this problem has been fixed by the following patch I sent yesterday.
But it is weird, I cannot access to the LKML site of 2013/1/22. So I didn't
get an url for you. :)

This patch was merged into -mm tree this morning.

And since I don't have an ARM platform, so I didn't test it on ARM.
Please tell me if your problem is not solved after applying this patch.

Thanks. :)



[PATCH Bug fix 1/4] Bug fix: Use CONFIG_HAVE_MEMBLOCK_NODE_MAP to 
protect movablecore_map in memblock_overlaps_region().

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
@@ -92,9 +92,13 @@ static long __init_memblock 
memblock_overlaps_region(struct memblock_type *type,
   *
   * Find @size free area aligned to @align in the specified range and node.
   *
+ * If we have CONFIG_HAVE_MEMBLOCK_NODE_MAP defined, we need to check 
if the
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
-- 1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
