Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7A19F6B003C
	for <linux-mm@kvack.org>; Sat, 12 Oct 2013 17:59:33 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so5747085pbc.11
        for <linux-mm@kvack.org>; Sat, 12 Oct 2013 14:59:33 -0700 (PDT)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [RFC 07/23] mm/memblock: debug: correct displaying of upper memory boundary
Date: Sat, 12 Oct 2013 17:58:50 -0400
Message-ID: <1381615146-20342-8-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com>
References: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, yinghai@kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, grygorii.strashko@ti.com, Andrew Morton <akpm@linux-foundation.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>

From: Grygorii Strashko <grygorii.strashko@ti.com>

When debugging is enabled (cmdline has "memblock=debug") the memblock
will display upper memory boundary per each allocated/freed memory range
wrongly. For example:
 memblock_reserve: [0x0000009e7e8000-0x0000009e7ed000] _memblock_early_alloc_try_nid_nopanic+0xfc/0x12c

The 0x0000009e7ed000 is displayed instead of 0x0000009e7ecfff

Hence, correct this by changing formula used to calculate upper memory
boundary to (u64)base + size - 1 instead of  (u64)base + size everywhere
in the debug messages.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 mm/memblock.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index c67f4bb..d903138 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -547,7 +547,7 @@ int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
 {
 	memblock_dbg("   memblock_free: [%#016llx-%#016llx] %pF\n",
 		     (unsigned long long)base,
-		     (unsigned long long)base + size,
+		     (unsigned long long)base + size - 1,
 		     (void *)_RET_IP_);
 
 	return __memblock_remove(&memblock.reserved, base, size);
@@ -559,7 +559,7 @@ int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
 
 	memblock_dbg("memblock_reserve: [%#016llx-%#016llx] %pF\n",
 		     (unsigned long long)base,
-		     (unsigned long long)base + size,
+		     (unsigned long long)base + size - 1,
 		     (void *)_RET_IP_);
 
 	return memblock_add_region(_rgn, base, size, MAX_NUMNODES);
@@ -914,7 +914,7 @@ void * __init memblock_early_alloc_try_nid(int nid,
 void __init __memblock_free_early(phys_addr_t base, phys_addr_t size)
 {
 	memblock_dbg("%s: [%#016llx-%#016llx] %pF\n",
-			__func__, (u64)base, (u64)base + size,
+			__func__, (u64)base, (u64)base + size - 1,
 			(void *)_RET_IP_);
 	kmemleak_free_part(__va(base), size);
 	__memblock_remove(&memblock.reserved, base, size);
@@ -925,7 +925,7 @@ void __init __memblock_free_late(phys_addr_t base, phys_addr_t size)
 	u64 cursor, end;
 
 	memblock_dbg("%s: [%#016llx-%#016llx] %pF\n",
-			__func__, (u64)base, (u64)base + size,
+			__func__, (u64)base, (u64)base + size - 1,
 			(void *)_RET_IP_);
 	kmemleak_free_part(__va(base), size);
 	cursor = PFN_UP(base);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
