Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f52.google.com (mail-oa0-f52.google.com [209.85.219.52])
	by kanga.kvack.org (Postfix) with ESMTP id E6A3D6B003A
	for <linux-mm@kvack.org>; Sat, 19 Apr 2014 22:26:56 -0400 (EDT)
Received: by mail-oa0-f52.google.com with SMTP id l6so3115342oag.11
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 19:26:56 -0700 (PDT)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id o5si25928985oeq.150.2014.04.19.19.26.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 19 Apr 2014 19:26:56 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 6/6] drm/exynos: call find_vma with the mmap_sem held
Date: Sat, 19 Apr 2014 19:26:31 -0700
Message-Id: <1397960791-16320-7-git-send-email-davidlohr@hp.com>
In-Reply-To: <1397960791-16320-1-git-send-email-davidlohr@hp.com>
References: <1397960791-16320-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: zeus@gnu.org, aswin@hp.com, davidlohr@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Inki Dae <inki.dae@samsung.com>, Joonyoung Shim <jy0922.shim@samsung.com>, David Airlie <airlied@linux.ie>, dri-devel@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org

From: Jonathan Gonzalez V <zeus@gnu.org>

Performing vma lookups without taking the mm->mmap_sem is asking
for trouble. While doing the search, the vma in question can be
modified or even removed before returning to the caller. Take the
lock (exclusively) in order to avoid races while iterating through
the vmacache and/or rbtree.

This patch is completely *untested*.

Signed-off-by: Jonathan Gonzalez V <zeus@gnu.org>
Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
Cc: Inki Dae <inki.dae@samsung.com>
Cc: Joonyoung Shim <jy0922.shim@samsung.com>
Cc: David Airlie <airlied@linux.ie>
Cc: dri-devel@lists.freedesktop.org
Cc: linux-samsung-soc@vger.kernel.org
---
 drivers/gpu/drm/exynos/exynos_drm_g2d.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/gpu/drm/exynos/exynos_drm_g2d.c b/drivers/gpu/drm/exynos/exynos_drm_g2d.c
index 6c1885e..8001587 100644
--- a/drivers/gpu/drm/exynos/exynos_drm_g2d.c
+++ b/drivers/gpu/drm/exynos/exynos_drm_g2d.c
@@ -467,14 +467,17 @@ static dma_addr_t *g2d_userptr_get_dma_addr(struct drm_device *drm_dev,
 		goto err_free;
 	}
 
+	down_read(&current->mm->mmap_sem);
 	vma = find_vma(current->mm, userptr);
 	if (!vma) {
+		up_read(&current->mm->mmap_sem);
 		DRM_ERROR("failed to get vm region.\n");
 		ret = -EFAULT;
 		goto err_free_pages;
 	}
 
 	if (vma->vm_end < userptr + size) {
+		up_read(&current->mm->mmap_sem);
 		DRM_ERROR("vma is too small.\n");
 		ret = -EFAULT;
 		goto err_free_pages;
@@ -482,6 +485,7 @@ static dma_addr_t *g2d_userptr_get_dma_addr(struct drm_device *drm_dev,
 
 	g2d_userptr->vma = exynos_gem_get_vma(vma);
 	if (!g2d_userptr->vma) {
+		up_read(&current->mm->mmap_sem);
 		DRM_ERROR("failed to copy vma.\n");
 		ret = -ENOMEM;
 		goto err_free_pages;
@@ -492,10 +496,12 @@ static dma_addr_t *g2d_userptr_get_dma_addr(struct drm_device *drm_dev,
 	ret = exynos_gem_get_pages_from_userptr(start & PAGE_MASK,
 						npages, pages, vma);
 	if (ret < 0) {
+		up_read(&current->mm->mmap_sem);
 		DRM_ERROR("failed to get user pages from userptr.\n");
 		goto err_put_vma;
 	}
 
+	up_read(&current->mm->mmap_sem);
 	g2d_userptr->pages = pages;
 
 	sgt = kzalloc(sizeof(*sgt), GFP_KERNEL);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
