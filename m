Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9524D6B0038
	for <linux-mm@kvack.org>; Sun, 31 Dec 2017 00:36:02 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v18so8821748wrf.21
        for <linux-mm@kvack.org>; Sat, 30 Dec 2017 21:36:02 -0800 (PST)
Received: from smtp1.de.adit-jv.com (smtp1.de.adit-jv.com. [62.225.105.245])
        by mx.google.com with ESMTPS id 16si9931807wru.468.2017.12.30.21.35.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Dec 2017 21:35:59 -0800 (PST)
From: Eugeniu Rosca <erosca@de.adit-jv.com>
Subject: [PATCH] [RFC] mm: page_alloc: skip over regions of invalid pfns on UMA
Date: Sun, 31 Dec 2017 06:31:57 +0100
Message-ID: <20171231053157.28528-1-erosca@de.adit-jv.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steven Sistare <steven.sistare@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Wei Yang <richard.weiyang@gmail.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Paul Burton <paul.burton@imgtec.com>, Paul Burton <paul.burton@mips.com>, James Hartley <james.hartley@imgtec.com>
Cc: Eugeniu Rosca <erosca@de.adit-jv.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

As a result of bisecting the v4.10..v4.11 commit range, it was
determined that commits [1] and [2] are both responsible of a ~170ms
early startup improvement on Rcar-H3-ES20 arm64 platform.

Since Rcar Gen3 family is not NUMA, we don't define CONFIG_NUMA in the
rcar3 defconfig, but this is how the boot time improvement is lost.

Make optimization [2] available on arm64 UMA systems and reduce the
time spent in memmap_init_zone() from 201ms to 34ms. Testing this
change on Apollo Lake SoC, boot time didn't change.

[1] commit 0f84832fb8f9 ("arm64: defconfig: Enable NUMA and NUMA_BALANCING")
[2] commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns where possible")
[3] 201ms spent in memmap_init_zone() on H3ULCB before this patch (NUMA not set)
[    2.048087] On node 0 totalpages: 1003520
[    2.048091]   DMA zone: 3392 pages used for memmap
[    2.048094]   DMA zone: 0 pages reserved
[    2.048096]   DMA zone: 217088 pages, LIFO batch:31
[    2.048099] memmap_init_zone: start
[    2.068881] memmap_init_zone: end
[    2.068884]   Normal zone: 12288 pages used for memmap
[    2.068888]   Normal zone: 786432 pages, LIFO batch:31
[    2.068890] memmap_init_zone: start
[    2.249791] memmap_init_zone: end
[    2.249824] psci: probing for conduit method from DT.

[4] 34ms spent in memmap_init_zone() on H3ULCB after this patch
[    2.072935] On node 0 totalpages: 1003520
[    2.072940]   DMA zone: 3392 pages used for memmap
[    2.072942]   DMA zone: 0 pages reserved
[    2.072945]   DMA zone: 217088 pages, LIFO batch:31
[    2.072948] memmap_init_zone: start
[    2.080442] memmap_init_zone: end
[    2.080446]   Normal zone: 12288 pages used for memmap
[    2.080449]   Normal zone: 786432 pages, LIFO batch:31
[    2.080451] memmap_init_zone: start
[    2.107935] memmap_init_zone: end
[    2.107965] psci: probing for conduit method from DT.

Signed-off-by: Eugeniu Rosca <erosca@de.adit-jv.com>
---
 include/linux/memblock.h | 3 ++-
 mm/memblock.c            | 2 ++
 mm/page_alloc.c          | 2 --
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 7ed0f7782d16..876c0a334164 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -182,12 +182,13 @@ static inline bool memblock_is_nomap(struct memblock_region *m)
 	return m->flags & MEMBLOCK_NOMAP;
 }
 
+unsigned long memblock_next_valid_pfn(unsigned long pfn, unsigned long max_pfn);
+
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 int memblock_search_pfn_nid(unsigned long pfn, unsigned long *start_pfn,
 			    unsigned long  *end_pfn);
 void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
 			  unsigned long *out_end_pfn, int *out_nid);
-unsigned long memblock_next_valid_pfn(unsigned long pfn, unsigned long max_pfn);
 
 /**
  * for_each_mem_pfn_range - early memory pfn range iterator
diff --git a/mm/memblock.c b/mm/memblock.c
index 46aacdfa4f4d..ad48cf200e3b 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1100,6 +1100,7 @@ void __init_memblock __next_mem_pfn_range(int *idx, int nid,
 	if (out_nid)
 		*out_nid = r->nid;
 }
+#endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
 unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn,
 						      unsigned long max_pfn)
@@ -1129,6 +1130,7 @@ unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn,
 		return min(PHYS_PFN(type->regions[right].base), max_pfn);
 }
 
+#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 /**
  * memblock_set_node - set node ID on memblock regions
  * @base: base of area to set node ID for
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7e5e775e97f4..defd5ef08c54 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5344,14 +5344,12 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			goto not_early;
 
 		if (!early_pfn_valid(pfn)) {
-#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 			/*
 			 * Skip to the pfn preceding the next valid one (or
 			 * end_pfn), such that we hit a valid pfn (or end_pfn)
 			 * on our next iteration of the loop.
 			 */
 			pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
-#endif
 			continue;
 		}
 		if (!early_pfn_in_nid(pfn, nid))
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
