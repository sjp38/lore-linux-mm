Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 08DDF6B006E
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 21:28:46 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id b20so9699351yha.12
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 18:28:45 -0800 (PST)
Received: from comal.ext.ti.com (comal.ext.ti.com. [198.47.26.152])
        by mx.google.com with ESMTPS id 41si49040966yhf.102.2013.12.02.18.28.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 18:28:45 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH v2 01/23] mm/memblock: debug: correct displaying of upper memory boundary
Date: Mon, 2 Dec 2013 21:27:16 -0500
Message-ID: <1386037658-3161-2-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>

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
Cc: Andrew Morton <akpm@linux-foundation.org>
Acked-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 mm/memblock.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 53e477b..aab5669 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -643,7 +643,7 @@ int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
 {
 	memblock_dbg("   memblock_free: [%#016llx-%#016llx] %pF\n",
 		     (unsigned long long)base,
-		     (unsigned long long)base + size,
+		     (unsigned long long)base + size - 1,
 		     (void *)_RET_IP_);
 
 	return __memblock_remove(&memblock.reserved, base, size);
@@ -655,7 +655,7 @@ int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
 
 	memblock_dbg("memblock_reserve: [%#016llx-%#016llx] %pF\n",
 		     (unsigned long long)base,
-		     (unsigned long long)base + size,
+		     (unsigned long long)base + size - 1,
 		     (void *)_RET_IP_);
 
 	return memblock_add_region(_rgn, base, size, MAX_NUMNODES);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
