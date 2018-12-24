Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Mon, 24 Dec 2018 18:54:53 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH v5 5/9] drm/xen/xen_drm_front_gem.c: Convert to use
 vm_insert_range
Message-ID: <20181224132453.GA22132@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, oleksandr_andrushchenko@epam.com, airlied@linux.ie, linux@armlinux.org.uk, robin.murphy@arm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, xen-devel@lists.xen.org
List-ID: <linux-mm.kvack.org>

Convert to use vm_insert_range() to map range of kernel
memory to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Matthew Wilcox <willy@infradead.org>
Reviewed-by: Oleksandr Andrushchenko <oleksandr_andrushchenko@epam.com>
---
 drivers/gpu/drm/xen/xen_drm_front_gem.c | 20 ++++++--------------
 1 file changed, 6 insertions(+), 14 deletions(-)

diff --git a/drivers/gpu/drm/xen/xen_drm_front_gem.c b/drivers/gpu/drm/xen/xen_drm_front_gem.c
index 47ff019..c21e5d1 100644
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
-
-		addr += PAGE_SIZE;
-	}
-	return 0;
+	ret = vm_insert_range(vma, vma->vm_start, xen_obj->pages,
+				xen_obj->num_pages);
+	if (ret < 0)
+		DRM_ERROR("Failed to insert pages into vma: %d\n", ret);
+	return ret;
 }
 
 int xen_drm_front_gem_mmap(struct file *filp, struct vm_area_struct *vma)
-- 
1.9.1
