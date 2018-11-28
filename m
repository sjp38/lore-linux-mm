Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Qian Cai <cai@gmx.us>
Subject: [PATCH] mm/memblock: skip kmemleak for kasan_init()
Date: Wed, 28 Nov 2018 12:40:33 -0500
Message-Id: <1543426833-24378-1-git-send-email-cai@gmx.us>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: catalin.marinas@arm.com, mhocko@suse.com, rppt@linux.vnet.ibm.com, aryabinin@virtuozzo.com, glider@google.com, dvyukov@google.com, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Qian Cai <cai@gmx.us>
List-ID: <linux-mm.kvack.org>

Kmemleak does not play well with KASAN (tested on both HPE Apollo 70 and
Huawei TaiShan 2280 aarch64 servers).

After calling start_kernel()->setup_arch()->kasan_init(), kmemleak early
log buffer went from something like 280 to 260000 which caused kmemleak
disabled and crash dump memory reservation failed. The multitude of
kmemleak_alloc() calls is from,

for_each_memblock(memory, reg) x \
while (pgdp++, addr = next, addr != end) x \
while (pudp++, addr = next, addr != end && pud_none(READ_ONCE(*pudp))) \
while (pmdp++, addr = next, addr != end && pmd_none(READ_ONCE(*pmdp))) \
while (ptep++, addr = next, addr != end && pte_none(READ_ONCE(*ptep)))

Signed-off-by: Qian Cai <cai@gmx.us>
---
 mm/memblock.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memblock.c b/mm/memblock.c
index 9a2d5ae..fd78e39 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1412,6 +1412,8 @@ static void * __init memblock_alloc_internal(
 done:
 	ptr = phys_to_virt(alloc);
 
+/* Skip kmemleak for kasan_init() due to high volume. */
+#ifndef CONFIG_KASAN
 	/*
 	 * The min_count is set to 0 so that bootmem allocated blocks
 	 * are never reported as leaks. This is because many of these blocks
@@ -1419,6 +1421,7 @@ static void * __init memblock_alloc_internal(
 	 * looked up by kmemleak.
 	 */
 	kmemleak_alloc(ptr, size, 0, 0);
+#endif
 
 	return ptr;
 }
-- 
1.8.3.1
