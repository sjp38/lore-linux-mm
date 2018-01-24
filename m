Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD34A800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 09:36:53 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id g13so2530245wrh.19
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 06:36:53 -0800 (PST)
Received: from smtp1.de.adit-jv.com (smtp1.de.adit-jv.com. [62.225.105.245])
        by mx.google.com with ESMTPS id j11si247895wmi.182.2018.01.24.06.36.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 06:36:52 -0800 (PST)
From: Eugeniu Rosca <erosca@de.adit-jv.com>
Subject: [PATCH v3 1/1] mm: page_alloc: skip over regions of invalid pfns on UMA
Date: Wed, 24 Jan 2018 15:35:45 +0100
Message-ID: <20180124143545.31963-2-erosca@de.adit-jv.com>
In-Reply-To: <20180124143545.31963-1-erosca@de.adit-jv.com>
References: <20180124143545.31963-1-erosca@de.adit-jv.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steven Sistare <steven.sistare@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Wei Yang <richard.weiyang@gmail.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Paul Burton <paul.burton@mips.com>, James Hartley <james.hartley@mips.com>
Cc: Eugeniu Rosca <erosca@de.adit-jv.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

As a result of bisecting the v4.10..v4.11 commit range, it was
determined that commits [1] and [2] are both responsible of a ~140ms
early startup improvement on Rcar-H3-ES20 arm64 platform.

Since Rcar Gen3 family is not NUMA, we don't define CONFIG_NUMA in the
rcar3 defconfig (which also reduces KNL binary image by ~64KB), but this
is how the boot time improvement is lost.

This patch makes optimization [2] available on UMA systems which
provide support for CONFIG_HAVE_MEMBLOCK.

Testing this change on Rcar H3-ES20-ULCB using v4.15-rc9 KNL and
vanilla arm64 defconfig + NUMA=n, a speed-up of ~139ms (from ~174ms [3]
to ~35ms [4]) is observed in the execution of memmap_init_zone().

No boot time improvement is sensed on Apollo Lake SoC.

[1] commit 0f84832fb8f9 ("arm64: defconfig: Enable NUMA and NUMA_BALANCING")
[2] commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns where possible")

[3] 174ms spent in memmap_init_zone() on H3ULCB w/o this patch (NUMA=n)
[    2.643685] On node 0 totalpages: 1015808
[    2.643688]   DMA zone: 3584 pages used for memmap
[    2.643691]   DMA zone: 0 pages reserved
[    2.643693]   DMA zone: 229376 pages, LIFO batch:31
[    2.643696] > memmap_init_zone
[    2.663628] < memmap_init_zone (19.932 ms)
[    2.663632]   Normal zone: 12288 pages used for memmap
[    2.663635]   Normal zone: 786432 pages, LIFO batch:31
[    2.663637] > memmap_init_zone
[    2.818012] < memmap_init_zone (154.375 ms)
[    2.818041] psci: probing for conduit method from DT.

[4] 35ms spent in memmap_init_zone() on H3ULCB with this patch (NUMA=n)
[    2.677202] On node 0 totalpages: 1015808
[    2.677205]   DMA zone: 3584 pages used for memmap
[    2.677208]   DMA zone: 0 pages reserved
[    2.677211]   DMA zone: 229376 pages, LIFO batch:31
[    2.677213] > memmap_init_zone
[    2.684378] < memmap_init_zone (7.165 ms)
[    2.684382]   Normal zone: 12288 pages used for memmap
[    2.684385]   Normal zone: 786432 pages, LIFO batch:31
[    2.684387] > memmap_init_zone
[    2.712556] < memmap_init_zone (28.169 ms)
[    2.712584] psci: probing for conduit method from DT.

Signed-off-by: Eugeniu Rosca <erosca@de.adit-jv.com>
Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/memblock.h | 1 -
 include/linux/mm.h       | 6 ++++++
 mm/memblock.c            | 2 ++
 mm/page_alloc.c          | 2 --
 4 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 7ed0f7782d16..9efd592c5da4 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -187,7 +187,6 @@ int memblock_search_pfn_nid(unsigned long pfn, unsigned long *start_pfn,
 			    unsigned long  *end_pfn);
 void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
 			  unsigned long *out_end_pfn, int *out_nid);
-unsigned long memblock_next_valid_pfn(unsigned long pfn, unsigned long max_pfn);
 
 /**
  * for_each_mem_pfn_range - early memory pfn range iterator
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ea818ff739cd..b82b30522585 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2064,8 +2064,14 @@ extern int __meminit __early_pfn_to_nid(unsigned long pfn,
 
 #ifdef CONFIG_HAVE_MEMBLOCK
 void zero_resv_unavail(void);
+unsigned long memblock_next_valid_pfn(unsigned long pfn, unsigned long max_pfn);
 #else
 static inline void zero_resv_unavail(void) {}
+static inline unsigned long memblock_next_valid_pfn(unsigned long pfn,
+						    unsigned long max_pfn)
+{
+	return pfn + 1;
+}
 #endif
 
 extern void set_dma_reserve(unsigned long new_dma_reserve);
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
index 76c9688b6a0a..4a3d5936a9a0 100644
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
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
