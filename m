Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id A10C06B0096
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 21:29:09 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id w5so5214935qac.14
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 18:29:09 -0800 (PST)
Received: from devils.ext.ti.com (devils.ext.ti.com. [198.47.26.153])
        by mx.google.com with ESMTPS id q2si17962343qas.133.2013.12.02.18.29.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 18:29:08 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH v2 21/23] mm/ARM: kernel: Use memblock apis for early memory allocations
Date: Mon, 2 Dec 2013 21:27:36 -0500
Message-ID: <1386037658-3161-22-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Santosh Shilimkar <santosh.shilimkar@ti.com>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Switch to memblock interfaces for early memory allocator instead of
bootmem allocator. No functional change in beahvior than what it is
in current code from bootmem users points of view.

Archs already converted to NO_BOOTMEM now directly use memblock
interfaces instead of bootmem wrappers build on top of memblock. And the
archs which still uses bootmem, these new apis just fallback to exiting
bootmem APIs.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 arch/arm/kernel/devtree.c |    2 +-
 arch/arm/kernel/setup.c   |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm/kernel/devtree.c b/arch/arm/kernel/devtree.c
index 739c3df..85b9b3b 100644
--- a/arch/arm/kernel/devtree.c
+++ b/arch/arm/kernel/devtree.c
@@ -33,7 +33,7 @@ void __init early_init_dt_add_memory_arch(u64 base, u64 size)
 
 void * __init early_init_dt_alloc_memory_arch(u64 size, u64 align)
 {
-	return alloc_bootmem_align(size, align);
+	return memblock_virt_alloc_align(size, align);
 }
 
 void __init arm_dt_memblock_reserve(void)
diff --git a/arch/arm/kernel/setup.c b/arch/arm/kernel/setup.c
index 6a1b8a8..0d3c6aa 100644
--- a/arch/arm/kernel/setup.c
+++ b/arch/arm/kernel/setup.c
@@ -717,7 +717,7 @@ static void __init request_standard_resources(const struct machine_desc *mdesc)
 	kernel_data.end     = virt_to_phys(_end - 1);
 
 	for_each_memblock(memory, region) {
-		res = alloc_bootmem_low(sizeof(*res));
+		res = memblock_virt_alloc(sizeof(*res));
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
