Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E7AED8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 10:06:38 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 75so10507440pfq.8
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 07:06:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i11sor3787964pfj.7.2019.01.11.07.06.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 07:06:37 -0800 (PST)
Date: Fri, 11 Jan 2019 20:40:37 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH 5/9] drm/xen/xen_drm_front_gem.c: Convert to use
 vm_insert_range
Message-ID: <20190111151037.GA2781@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, oleksandr_andrushchenko@epam.com, airlied@linux.ie, linux@armlinux.org.uk, robin.murphy@arm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, xen-devel@lists.xen.org

Convert to use vm_insert_range() to map range of kernel
memory to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 drivers/gpu/drm/xen/xen_drm_front_gem.c | 18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/drivers/gpu/drm/xen/xen_drm_front_gem.c b/drivers/gpu/drm/xen/xen_drm_front_gem.c
index 47ff019..9990c2f 100644
--- a/drivers/gpu/drm/xen/xen_drm_front_gem.c
+++ b/drivers/gpu/drm/xen/xen_drm_front_gem.c
@@ -225,8 +225,7 @@ struct drm_gem_object *
 static int gem_mmap_obj(struct xen_gem_object *xen_obj,
 			struct vm_area_struct *vma)
 {
-	unsigned long addr = vma->vm_start;
-	int i;
+	int ret;
 
 	/*
 	 * clear the VM_PFNMAP flag that was set by drm_gem_mmap(), and set the
@@ -247,18 +246,11 @@ static int gem_mmap_obj(struct xen_gem_object *xen_obj,
 	 * FIXME: as we insert all the pages now then no .fault handler must
 	 * be called, so don't provide one
 	 */
-	for (i = 0; i < xen_obj->num_pages; i++) {
-		int ret;
-
-		ret = vm_insert_page(vma, addr, xen_obj->pages[i]);
-		if (ret < 0) {
-			DRM_ERROR("Failed to insert pages into vma: %d\n", ret);
-			return ret;
-		}
+	ret = vm_insert_range(vma, xen_obj->pages, xen_obj->num_pages);
+	if (ret < 0)
+		DRM_ERROR("Failed to insert pages into vma: %d\n", ret);
 
-		addr += PAGE_SIZE;
-	}
-	return 0;
+	return ret;
 }
 
 int xen_drm_front_gem_mmap(struct file *filp, struct vm_area_struct *vma)
-- 
1.9.1
