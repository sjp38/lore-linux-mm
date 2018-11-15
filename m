Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D9B96B0495
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 10:44:52 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id h10so10772444pgv.20
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 07:44:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k3-v6sor33497753pfb.7.2018.11.15.07.44.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Nov 2018 07:44:51 -0800 (PST)
Date: Thu, 15 Nov 2018 21:18:26 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH 4/9] drm/rockchip/rockchip_drm_gem.c: Convert to use
 vm_insert_range
Message-ID: <20181115154826.GA27948@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, hjc@rock-chips.com, heiko@sntech.de, airlied@linux.ie
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org

Convert to use vm_insert_range() to map range of kernel
memory to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 drivers/gpu/drm/rockchip/rockchip_drm_gem.c | 20 ++------------------
 1 file changed, 2 insertions(+), 18 deletions(-)

diff --git a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
index a8db758..2cb83bb 100644
--- a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
+++ b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
@@ -221,26 +221,10 @@ static int rockchip_drm_gem_object_mmap_iommu(struct drm_gem_object *obj,
 					      struct vm_area_struct *vma)
 {
 	struct rockchip_gem_object *rk_obj = to_rockchip_obj(obj);
-	unsigned int i, count = obj->size >> PAGE_SHIFT;
 	unsigned long user_count = vma_pages(vma);
-	unsigned long uaddr = vma->vm_start;
-	unsigned long offset = vma->vm_pgoff;
-	unsigned long end = user_count + offset;
-	int ret;
-
-	if (user_count == 0)
-		return -ENXIO;
-	if (end > count)
-		return -ENXIO;
 
-	for (i = offset; i < end; i++) {
-		ret = vm_insert_page(vma, uaddr, rk_obj->pages[i]);
-		if (ret)
-			return ret;
-		uaddr += PAGE_SIZE;
-	}
-
-	return 0;
+	return vm_insert_range(vma, vma->vm_start, rk_obj->pages,
+				user_count);
 }
 
 static int rockchip_drm_gem_object_mmap_dma(struct drm_gem_object *obj,
-- 
1.9.1
