Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id B32856B0044
	for <linux-mm@kvack.org>; Sun,  5 Aug 2012 08:50:37 -0400 (EDT)
From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: [PATCH] ARM: dma-mapping: fix incorrect freeing of atomic allocations
Date: Sun,  5 Aug 2012 15:50:29 +0300
Message-Id: <1344171029-24804-1-git-send-email-aaro.koskinen@iki.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: m.szyprowski@samsung.com, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit e9da6e9905e639b0f842a244bc770b48ad0523e9 (ARM: dma-mapping:
remove custom consistent dma region) changed the way atomic allocations
are handled. However, arm_dma_free() was not modified accordingly, and
as a result freeing of atomic allocations does not work correctly when
CMA is disabled. Memory is leaked and following WARNINGs are seen:

[   57.698911] ------------[ cut here ]------------
[   57.753518] WARNING: at arch/arm/mm/dma-mapping.c:263 arm_dma_free+0x88/0xe4()
[   57.811473] trying to free invalid coherent area: e0848000
[   57.867398] Modules linked in: sata_mv(-)
[   57.921373] [<c000d270>] (unwind_backtrace+0x0/0xf0) from [<c0015430>] (warn_slowpath_common+0x50/0x68)
[   58.033924] [<c0015430>] (warn_slowpath_common+0x50/0x68) from [<c00154dc>] (warn_slowpath_fmt+0x30/0x40)
[   58.152024] [<c00154dc>] (warn_slowpath_fmt+0x30/0x40) from [<c000dc18>] (arm_dma_free+0x88/0xe4)
[   58.219592] [<c000dc18>] (arm_dma_free+0x88/0xe4) from [<c008fa30>] (dma_pool_destroy+0x100/0x148)
[   58.345526] [<c008fa30>] (dma_pool_destroy+0x100/0x148) from [<c019a64c>] (release_nodes+0x144/0x218)
[   58.475782] [<c019a64c>] (release_nodes+0x144/0x218) from [<c0197e10>] (__device_release_driver+0x60/0xb8)
[   58.614260] [<c0197e10>] (__device_release_driver+0x60/0xb8) from [<c0198608>] (driver_detach+0xd8/0xec)
[   58.756527] [<c0198608>] (driver_detach+0xd8/0xec) from [<c0197c54>] (bus_remove_driver+0x7c/0xc4)
[   58.901648] [<c0197c54>] (bus_remove_driver+0x7c/0xc4) from [<c004bfac>] (sys_delete_module+0x19c/0x220)
[   59.051447] [<c004bfac>] (sys_delete_module+0x19c/0x220) from [<c0009140>] (ret_fast_syscall+0x0/0x2c)
[   59.207996] ---[ end trace 0745420412c0325a ]---
[   59.287110] ------------[ cut here ]------------
[   59.366324] WARNING: at arch/arm/mm/dma-mapping.c:263 arm_dma_free+0x88/0xe4()
[   59.450511] trying to free invalid coherent area: e0847000
[   59.534357] Modules linked in: sata_mv(-)
[   59.616785] [<c000d270>] (unwind_backtrace+0x0/0xf0) from [<c0015430>] (warn_slowpath_common+0x50/0x68)
[   59.790030] [<c0015430>] (warn_slowpath_common+0x50/0x68) from [<c00154dc>] (warn_slowpath_fmt+0x30/0x40)
[   59.972322] [<c00154dc>] (warn_slowpath_fmt+0x30/0x40) from [<c000dc18>] (arm_dma_free+0x88/0xe4)
[   60.070701] [<c000dc18>] (arm_dma_free+0x88/0xe4) from [<c008fa30>] (dma_pool_destroy+0x100/0x148)
[   60.256817] [<c008fa30>] (dma_pool_destroy+0x100/0x148) from [<c019a64c>] (release_nodes+0x144/0x218)
[   60.445201] [<c019a64c>] (release_nodes+0x144/0x218) from [<c0197e10>] (__device_release_driver+0x60/0xb8)
[   60.634148] [<c0197e10>] (__device_release_driver+0x60/0xb8) from [<c0198608>] (driver_detach+0xd8/0xec)
[   60.823623] [<c0198608>] (driver_detach+0xd8/0xec) from [<c0197c54>] (bus_remove_driver+0x7c/0xc4)
[   61.013268] [<c0197c54>] (bus_remove_driver+0x7c/0xc4) from [<c004bfac>] (sys_delete_module+0x19c/0x220)
[   61.203472] [<c004bfac>] (sys_delete_module+0x19c/0x220) from [<c0009140>] (ret_fast_syscall+0x0/0x2c)
[   61.393390] ---[ end trace 0745420412c0325b ]---

The patch fixes this.

Signed-off-by: Aaro Koskinen <aaro.koskinen@iki.fi>
---
 arch/arm/mm/dma-mapping.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index c2cdf65..2cc77b7 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -648,12 +648,12 @@ void arm_dma_free(struct device *dev, size_t size, void *cpu_addr,
 
 	if (arch_is_coherent() || nommu()) {
 		__dma_free_buffer(page, size);
+	} else if (__free_from_pool(cpu_addr, size)) {
+		return;
 	} else if (!IS_ENABLED(CONFIG_CMA)) {
 		__dma_free_remap(cpu_addr, size);
 		__dma_free_buffer(page, size);
 	} else {
-		if (__free_from_pool(cpu_addr, size))
-			return;
 		/*
 		 * Non-atomic allocations cannot be freed with IRQs disabled
 		 */
-- 
1.7.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
