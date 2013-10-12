Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id B53D76B003C
	for <linux-mm@kvack.org>; Sat, 12 Oct 2013 17:59:34 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so5948960pad.33
        for <linux-mm@kvack.org>; Sat, 12 Oct 2013 14:59:34 -0700 (PDT)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [RFC 08/23] mm/memblock: debug: don't free reserved array if !ARCH_DISCARD_MEMBLOCK
Date: Sat, 12 Oct 2013 17:58:51 -0400
Message-ID: <1381615146-20342-9-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com>
References: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, yinghai@kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, grygorii.strashko@ti.com, Andrew Morton <akpm@linux-foundation.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>

From: Grygorii Strashko <grygorii.strashko@ti.com>

Now the Nobootmem allocator will always try to free memory allocated for
reserved memory regions (free_low_memory_core_early()) without taking
into to account current memblock debugging configuration
(CONFIG_ARCH_DISCARD_MEMBLOCK and CONFIG_DEBUG_FS state).
As result if:
 - CONFIG_DEBUG_FS defined
 - CONFIG_ARCH_DISCARD_MEMBLOCK not defined;
-  reserved memory regions array have been resized during boot

then:
- memory allocated for reserved memory regions array will be freed to
buddy allocator;
- debug_fs entry "sys/kernel/debug/memblock/reserved" will show garbage
instead of state of memory reservations. like:
   0: 0x98393bc0..0x9a393bbf
   1: 0xff120000..0xff11ffff
   2: 0x00000000..0xffffffff

Hence, do not free memory allocated for reserved memory regions if
defined(CONFIG_DEBUG_FS) && !defined(CONFIG_ARCH_DISCARD_MEMBLOCK).

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 mm/memblock.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/memblock.c b/mm/memblock.c
index d903138..1bb2cc0 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -169,6 +169,10 @@ phys_addr_t __init_memblock get_allocated_memblock_reserved_regions_info(
 	if (memblock.reserved.regions == memblock_reserved_init_regions)
 		return 0;
 
+	if (IS_ENABLED(CONFIG_DEBUG_FS) &&
+	    !IS_ENABLED(CONFIG_ARCH_DISCARD_MEMBLOCK))
+		return 0;
+
 	*addr = __pa(memblock.reserved.regions);
 
 	return PAGE_ALIGN(sizeof(struct memblock_region) *
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
