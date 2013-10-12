Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id DDBAF6B0071
	for <linux-mm@kvack.org>; Sat, 12 Oct 2013 17:59:49 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so5949086pad.33
        for <linux-mm@kvack.org>; Sat, 12 Oct 2013 14:59:49 -0700 (PDT)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [RFC 21/23] mm/ARM: kernel: Use memblock apis for early memory allocations
Date: Sat, 12 Oct 2013 17:59:04 -0400
Message-ID: <1381615146-20342-22-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com>
References: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, yinghai@kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, grygorii.strashko@ti.com, Santosh Shilimkar <santosh.shilimkar@ti.com>, Andrew Morton <akpm@linux-foundation.org>

Switch to memblock interfaces for early memory allocator

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>

Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 arch/arm/kernel/devtree.c |    2 +-
 arch/arm/kernel/setup.c   |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm/kernel/devtree.c b/arch/arm/kernel/devtree.c
index f35906b..881c495 100644
--- a/arch/arm/kernel/devtree.c
+++ b/arch/arm/kernel/devtree.c
@@ -33,7 +33,7 @@ void __init early_init_dt_add_memory_arch(u64 base, u64 size)
 
 void * __init early_init_dt_alloc_memory_arch(u64 size, u64 align)
 {
-	return alloc_bootmem_align(size, align);
+	return memblock_early_alloc_align(size, align);
 }
 
 void __init arm_dt_memblock_reserve(void)
diff --git a/arch/arm/kernel/setup.c b/arch/arm/kernel/setup.c
index e1b1394..d928500 100644
--- a/arch/arm/kernel/setup.c
+++ b/arch/arm/kernel/setup.c
@@ -707,7 +707,7 @@ static void __init request_standard_resources(const struct machine_desc *mdesc)
 	kernel_data.end     = virt_to_phys(_end - 1);
 
 	for_each_memblock(memory, region) {
-		res = alloc_bootmem_low(sizeof(*res));
+		res = memblock_early_alloc(sizeof(*res));
 		res->name  = "System RAM";
 		res->start = __pfn_to_phys(memblock_region_memory_base_pfn(region));
 		res->end = __pfn_to_phys(memblock_region_memory_end_pfn(region)) - 1;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
