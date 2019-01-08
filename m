Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9B98F8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 14:29:46 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id r13so2600781pgb.7
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 11:29:46 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p64si4814585pfg.79.2019.01.08.11.29.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 11:29:45 -0800 (PST)
From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 4.20 117/117] mm/memblock.c: skip kmemleak for kasan_init()
Date: Tue,  8 Jan 2019 14:26:25 -0500
Message-Id: <20190108192628.121270-117-sashal@kernel.org>
In-Reply-To: <20190108192628.121270-1-sashal@kernel.org>
References: <20190108192628.121270-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc: Qian Cai <cai@gmx.us>, Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sashal@kernel.org>, kasan-dev@googlegroups.com, linux-mm@kvack.org

From: Qian Cai <cai@gmx.us>

[ Upstream commit fed84c78527009d4f799a3ed9a566502fa026d82 ]

Kmemleak does not play well with KASAN (tested on both HPE Apollo 70 and
Huawei TaiShan 2280 aarch64 servers).

After calling start_kernel()->setup_arch()->kasan_init(), kmemleak early
log buffer went from something like 280 to 260000 which caused kmemleak
disabled and crash dump memory reservation failed.  The multitude of
kmemleak_alloc() calls is from nested loops while KASAN is setting up full
memory mappings, so let early kmemleak allocations skip those
memblock_alloc_internal() calls came from kasan_init() given that those
early KASAN memory mappings should not reference to other memory.  Hence,
no kmemleak false positives.

kasan_init
  kasan_map_populate [1]
    kasan_pgd_populate [2]
      kasan_pud_populate [3]
        kasan_pmd_populate [4]
          kasan_pte_populate [5]
            kasan_alloc_zeroed_page
              memblock_alloc_try_nid
                memblock_alloc_internal
                  kmemleak_alloc

[1] for_each_memblock(memory, reg)
[2] while (pgdp++, addr = next, addr != end)
[3] while (pudp++, addr = next, addr != end && pud_none(READ_ONCE(*pudp)))
[4] while (pmdp++, addr = next, addr != end && pmd_none(READ_ONCE(*pmdp)))
[5] while (ptep++, addr = next, addr != end && pte_none(READ_ONCE(*ptep)))

Link: http://lkml.kernel.org/r/1543442925-17794-1-git-send-email-cai@gmx.us
Signed-off-by: Qian Cai <cai@gmx.us>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 arch/arm64/mm/kasan_init.c |  2 +-
 include/linux/memblock.h   |  1 +
 mm/memblock.c              | 19 +++++++++++--------
 3 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
index 63527e585aac..fcb2ca30b6f1 100644
--- a/arch/arm64/mm/kasan_init.c
+++ b/arch/arm64/mm/kasan_init.c
@@ -39,7 +39,7 @@ static phys_addr_t __init kasan_alloc_zeroed_page(int node)
 {
 	void *p = memblock_alloc_try_nid(PAGE_SIZE, PAGE_SIZE,
 					      __pa(MAX_DMA_ADDRESS),
-					      MEMBLOCK_ALLOC_ACCESSIBLE, node);
+					      MEMBLOCK_ALLOC_KASAN, node);
 	return __pa(p);
 }
 
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index aee299a6aa76..3ef3086ed52f 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -320,6 +320,7 @@ static inline int memblock_get_region_node(const struct memblock_region *r)
 /* Flags for memblock allocation APIs */
 #define MEMBLOCK_ALLOC_ANYWHERE	(~(phys_addr_t)0)
 #define MEMBLOCK_ALLOC_ACCESSIBLE	0
+#define MEMBLOCK_ALLOC_KASAN		1
 
 /* We are using top down, so it is safe to use 0 here */
 #define MEMBLOCK_LOW_LIMIT 0
diff --git a/mm/memblock.c b/mm/memblock.c
index 81ae63ca78d0..f45a049532fe 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -262,7 +262,8 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
 	phys_addr_t kernel_end, ret;
 
 	/* pump up @end */
-	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
+	if (end == MEMBLOCK_ALLOC_ACCESSIBLE ||
+	    end == MEMBLOCK_ALLOC_KASAN)
 		end = memblock.current_limit;
 
 	/* avoid allocating the first page */
@@ -1412,13 +1413,15 @@ static void * __init memblock_alloc_internal(
 done:
 	ptr = phys_to_virt(alloc);
 
-	/*
-	 * The min_count is set to 0 so that bootmem allocated blocks
-	 * are never reported as leaks. This is because many of these blocks
-	 * are only referred via the physical address which is not
-	 * looked up by kmemleak.
-	 */
-	kmemleak_alloc(ptr, size, 0, 0);
+	/* Skip kmemleak for kasan_init() due to high volume. */
+	if (max_addr != MEMBLOCK_ALLOC_KASAN)
+		/*
+		 * The min_count is set to 0 so that bootmem allocated
+		 * blocks are never reported as leaks. This is because many
+		 * of these blocks are only referred via the physical
+		 * address which is not looked up by kmemleak.
+		 */
+		kmemleak_alloc(ptr, size, 0, 0);
 
 	return ptr;
 }
-- 
2.19.1
