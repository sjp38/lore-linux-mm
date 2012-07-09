Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 45EC66B006E
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 04:50:13 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (mailout3.samsung.com [203.254.224.33])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M6V00I77XV6F8U0@mailout3.samsung.com> for
 linux-mm@kvack.org; Mon, 09 Jul 2012 17:50:11 +0900 (KST)
Received: from localhost.localdomain ([107.108.73.106])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M6V00EFQXURP160@mmp2.samsung.com> for linux-mm@kvack.org;
 Mon, 09 Jul 2012 17:50:11 +0900 (KST)
From: Prathyush K <prathyush.k@samsung.com>
Subject: [PATCH v2] ARM: dma-mapping: modify condition check while freeing pages
Date: Mon, 09 Jul 2012 14:33:43 +0530
Message-id: <1341824623-7472-1-git-send-email-prathyush.k@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org
Cc: m.szyprowski@samsung.com

WARNING: at mm/vmalloc.c:1471 __iommu_free_buffer+0xcc/0xd0()
Trying to vfree() nonexistent vm area (ef095000)
Modules linked in:
[<c0015a18>] (unwind_backtrace+0x0/0xfc) from [<c0025a94>] (warn_slowpath_common+0x54/0x64)
[<c0025a94>] (warn_slowpath_common+0x54/0x64) from [<c0025b38>] (warn_slowpath_fmt+0x30/0x40)
[<c0025b38>] (warn_slowpath_fmt+0x30/0x40) from [<c0016de0>] (__iommu_free_buffer+0xcc/0xd0)
[<c0016de0>] (__iommu_free_buffer+0xcc/0xd0) from [<c0229a5c>] (exynos_drm_free_buf+0xe4/0x138)
[<c0229a5c>] (exynos_drm_free_buf+0xe4/0x138) from [<c022b358>] (exynos_drm_gem_destroy+0x80/0xfc)
[<c022b358>] (exynos_drm_gem_destroy+0x80/0xfc) from [<c0211230>] (drm_gem_object_free+0x28/0x34)
[<c0211230>] (drm_gem_object_free+0x28/0x34) from [<c0211bd0>] (drm_gem_object_release_handle+0xcc/0xd8)
[<c0211bd0>] (drm_gem_object_release_handle+0xcc/0xd8) from [<c01abe10>] (idr_for_each+0x74/0xb8)
[<c01abe10>] (idr_for_each+0x74/0xb8) from [<c02114e4>] (drm_gem_release+0x1c/0x30)
[<c02114e4>] (drm_gem_release+0x1c/0x30) from [<c0210ae8>] (drm_release+0x608/0x694)
[<c0210ae8>] (drm_release+0x608/0x694) from [<c00b75a0>] (fput+0xb8/0x228)
[<c00b75a0>] (fput+0xb8/0x228) from [<c00b40c4>] (filp_close+0x64/0x84)
[<c00b40c4>] (filp_close+0x64/0x84) from [<c0029d54>] (put_files_struct+0xe8/0x104)
[<c0029d54>] (put_files_struct+0xe8/0x104) from [<c002b930>] (do_exit+0x608/0x774)
[<c002b930>] (do_exit+0x608/0x774) from [<c002bae4>] (do_group_exit+0x48/0xb4)
[<c002bae4>] (do_group_exit+0x48/0xb4) from [<c002bb60>] (sys_exit_group+0x10/0x18)
[<c002bb60>] (sys_exit_group+0x10/0x18) from [<c000ee80>] (ret_fast_syscall+0x0/0x30)

This patch modifies the condition while freeing to match the condition
used while allocation. This fixes the above warning which arises when
array size is equal to PAGE_SIZE where allocation is done using kzalloc
but free is done using vfree.

Signed-off-by: Prathyush K <prathyush.k@samsung.com>
---
 arch/arm/mm/dma-mapping.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index dc560dc..0f9358b 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1091,7 +1091,7 @@ error:
 	while (--i)
 		if (pages[i])
 			__free_pages(pages[i], 0);
-	if (array_size < PAGE_SIZE)
+	if (array_size <= PAGE_SIZE)
 		kfree(pages);
 	else
 		vfree(pages);
@@ -1106,7 +1106,7 @@ static int __iommu_free_buffer(struct device *dev, struct page **pages, size_t s
 	for (i = 0; i < count; i++)
 		if (pages[i])
 			__free_pages(pages[i], 0);
-	if (array_size < PAGE_SIZE)
+	if (array_size <= PAGE_SIZE)
 		kfree(pages);
 	else
 		vfree(pages);
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
