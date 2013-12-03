Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9796B0071
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 21:28:47 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id b20so9544636yha.40
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 18:28:47 -0800 (PST)
Received: from arroyo.ext.ti.com (arroyo.ext.ti.com. [192.94.94.40])
        by mx.google.com with ESMTPS id p5si9260151yho.34.2013.12.02.18.28.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 18:28:46 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH v2 02/23] mm/memblock: debug: don't free reserved array if !ARCH_DISCARD_MEMBLOCK
Date: Mon, 2 Dec 2013 21:27:17 -0500
Message-ID: <1386037658-3161-3-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>

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
 mm/memblock.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/mm/memblock.c b/mm/memblock.c
index aab5669..53da534 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -265,6 +265,19 @@ phys_addr_t __init_memblock get_allocated_memblock_reserved_regions_info(
 	if (memblock.reserved.regions == memblock_reserved_init_regions)
 		return 0;
 
+	/*
+	 * Don't allow Nobootmem allocator to free reserved memory regions
+	 * array if
+	 *  - CONFIG_DEBUG_FS is enabled;
+	 *  - CONFIG_ARCH_DISCARD_MEMBLOCK is not enabled;
+	 *  - reserved memory regions array have been resized during boot.
+	 * Otherwise debug_fs entry "sys/kernel/debug/memblock/reserved"
+	 * will show garbage instead of state of memory reservations.
+	 */
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
