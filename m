Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4554F6B0038
	for <linux-mm@kvack.org>; Sun, 21 Jan 2018 09:50:08 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id b111so4891052wrd.16
        for <linux-mm@kvack.org>; Sun, 21 Jan 2018 06:50:08 -0800 (PST)
Received: from smtp1.de.adit-jv.com (smtp1.de.adit-jv.com. [62.225.105.245])
        by mx.google.com with ESMTPS id 62si11986436wrm.70.2018.01.21.06.50.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jan 2018 06:50:06 -0800 (PST)
From: Eugeniu Rosca <erosca@de.adit-jv.com>
Subject: [PATCH v2 1/1] mm: page_alloc: skip over regions of invalid pfns on UMA
Date: Sun, 21 Jan 2018 15:47:53 +0100
Message-ID: <20180121144753.3109-2-erosca@de.adit-jv.com>
In-Reply-To: <20180121144753.3109-1-erosca@de.adit-jv.com>
References: <20180121144753.3109-1-erosca@de.adit-jv.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steven Sistare <steven.sistare@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Wei Yang <richard.weiyang@gmail.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Paul Burton <paul.burton@mips.com>, James Hartley <james.hartley@mips.com>
Cc: Eugeniu Rosca <erosca@de.adit-jv.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

As a result of bisecting the v4.10..v4.11 commit range, it was
determined that commits [1] and [2] are both responsible of a ~140ms
early startup improvement on Rcar-H3-ES20 arm64 platform.

Since Rcar Gen3 family is not NUMA, we don't define CONFIG_NUMA in the
rcar3 defconfig (which also reduces KNL binary image by ~64KB), but this
is how the boot time improvement is lost.

This patch makes optimization [2] available on UMA systems which
provide support for CONFIG_HAVE_MEMBLOCK.

Testing this change on Rcar H3-ULCB using v4.15-rc8 KNL, vanilla arm64
defconfig + NUMA=n, a speed-up of ~140ms (from [3] to [4]) is observed
in the execution of memmap_init_zone().

No boot time improvement is sensed on Apollo Lake SoC.

[1] commit 0f84832fb8f9 ("arm64: defconfig: Enable NUMA and NUMA_BALANCING")
[2] commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns where possible")

[3] 179ms spent in memmap_init_zone() on H3ULCB w/o this patch (NUMA=n)
[    2.408716] On node 0 totalpages: 1015808
[    2.408720]   DMA zone: 3584 pages used for memmap
[    2.408723]   DMA zone: 0 pages reserved
[    2.408726]   DMA zone: 229376 pages, LIFO batch:31
[    2.408729] > memmap_init_zone
[    2.429506] < memmap_init_zone
[    2.429512]   Normal zone: 12288 pages used for memmap
[    2.429514]   Normal zone: 786432 pages, LIFO batch:31
[    2.429516] > memmap_init_zone
[    2.587980] < memmap_init_zone
[    2.588013] psci: probing for conduit method from DT.

[4] 38ms spent in memmap_init_zone() on H3ULCB with this patch (NUMA=n)
[    2.415661] On node 0 totalpages: 1015808
[    2.415664]   DMA zone: 3584 pages used for memmap
[    2.415667]   DMA zone: 0 pages reserved
[    2.415670]   DMA zone: 229376 pages, LIFO batch:31
[    2.415673] > memmap_init_zone
[    2.424245] < memmap_init_zone
[    2.424250]   Normal zone: 12288 pages used for memmap
[    2.424253]   Normal zone: 786432 pages, LIFO batch:31
[    2.424256] > memmap_init_zone
[    2.453984] < memmap_init_zone
[    2.454016] psci: probing for conduit method from DT.

Signed-off-by: Eugeniu Rosca <erosca@de.adit-jv.com>
---
 include/linux/memblock.h | 3 ++-
 mm/memblock.c            | 2 ++
 mm/page_alloc.c          | 2 +-
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 7ed0f778..876c0a33 100644
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
index 46aacdfa..ad48cf20 100644
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
index 76c9688b..9ad47f46 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5344,7 +5344,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			goto not_early;
 
 		if (!early_pfn_valid(pfn)) {
-#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
+#ifdef CONFIG_HAVE_MEMBLOCK
 			/*
 			 * Skip to the pfn preceding the next valid one (or
 			 * end_pfn), such that we hit a valid pfn (or end_pfn)
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
