Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id CF7276B0037
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 14:30:14 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id f73so4215109yha.21
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 11:30:14 -0800 (PST)
Received: from arroyo.ext.ti.com (arroyo.ext.ti.com. [192.94.94.40])
        by mx.google.com with ESMTPS id v65si14815500yhp.233.2013.12.10.11.30.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 11:30:13 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH 1/2] mm/ARM: dma: fix conflicting types for 'arm_dma_zone_size'
Date: Tue, 10 Dec 2013 14:29:57 -0500
Message-ID: <1386703798-26521-2-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1386703798-26521-1-git-send-email-santosh.shilimkar@ti.com>
References: <1386703798-26521-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Grygorii Strashko <grygorii.strashko@ti.com>, Russell King <linux@arm.linux.org.uk>, Rob Herring <rob.herring@calxeda.com>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>

From: Grygorii Strashko <grygorii.strashko@ti.com>

Commit 364230b9 "ARM: use phys_addr_t for DMA zone sizes" changes
type of arm_dma_zone_size to phys_addr_t, but misses to update
external definition of it in in arch/arm/include/asm/dma.h.
As result, kernel build is failed if CONFIG_ZONE_DMA is enabled:

arch/arm/mm/init.c:202:13: error: conflicting types for 'arm_dma_zone_size'
include/linux/bootmem.h:258:66: note: previous declaration of 'arm_dma_zone_size' was here

Hence, fix external definition of arm_dma_zone_size.

Cc: Russell King <linux@arm.linux.org.uk>
Cc: Rob Herring <rob.herring@calxeda.com>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 arch/arm/include/asm/dma.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm/include/asm/dma.h b/arch/arm/include/asm/dma.h
index 58b8c6a..1439b80 100644
--- a/arch/arm/include/asm/dma.h
+++ b/arch/arm/include/asm/dma.h
@@ -8,7 +8,7 @@
 #define MAX_DMA_ADDRESS	0xffffffffUL
 #else
 #define MAX_DMA_ADDRESS	({ \
-	extern unsigned long arm_dma_zone_size; \
+	extern phys_addr_t arm_dma_zone_size; \
 	arm_dma_zone_size ? \
 		(PAGE_OFFSET + arm_dma_zone_size) : 0xffffffffUL; })
 #endif
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
