Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 61C3A6B025E
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 17:36:12 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id jz4so35806393wjb.5
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 14:36:12 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.135])
        by mx.google.com with ESMTPS id m89si24100285wmh.34.2017.01.25.14.36.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 14:36:11 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] fixup! mm, fs: reduce fault, page_mkwrite, and pfn_mkwrite to take only vmf
Date: Wed, 25 Jan 2017 23:35:05 +0100
Message-Id: <20170125223558.1451224-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Jiang <dave.jiang@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>, David Airlie <airlied@linux.ie>, Lucas Stach <l.stach@pengutronix.de>, Christian Gmeiner <christian.gmeiner@gmail.com>, Tomi Valkeinen <tomi.valkeinen@ti.com>, Sebastian Reichel <sre@kernel.org>, Chris Wilson <chris@chris-wilson.co.uk>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Peter Ujfalusi <peter.ujfalusi@ti.com>, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, etnaviv@lists.freedesktop.org

I ran into a couple of build problems on ARM, these are the changes that
should be folded into the original patch that changed all the ->fault()
prototypes

Fixes: mmtom ("mm, fs: reduce fault, page_mkwrite, and pfn_mkwrite to take only vmf")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/gpu/drm/armada/armada_gem.c   | 9 +++++----
 drivers/gpu/drm/etnaviv/etnaviv_drv.h | 2 +-
 drivers/gpu/drm/omapdrm/omap_drv.h    | 2 +-
 drivers/hsi/clients/cmt_speech.c      | 4 ++--
 4 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/gpu/drm/armada/armada_gem.c b/drivers/gpu/drm/armada/armada_gem.c
index a293c8be232c..e1917adc30a4 100644
--- a/drivers/gpu/drm/armada/armada_gem.c
+++ b/drivers/gpu/drm/armada/armada_gem.c
@@ -14,14 +14,15 @@
 #include <drm/armada_drm.h>
 #include "armada_ioctlP.h"
 
-static int armada_gem_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
+static int armada_gem_vm_fault(struct vm_fault *vmf)
 {
-	struct armada_gem_object *obj = drm_to_armada_gem(vma->vm_private_data);
+	struct drm_gem_object *gobj = vmf->vma->vm_private_data;
+	struct armada_gem_object *obj = drm_to_armada_gem(gobj);
 	unsigned long pfn = obj->phys_addr >> PAGE_SHIFT;
 	int ret;
 
-	pfn += (vmf->address - vma->vm_start) >> PAGE_SHIFT;
-	ret = vm_insert_pfn(vma, vmf->address, pfn);
+	pfn += (vmf->address - vmf->vma->vm_start) >> PAGE_SHIFT;
+	ret = vm_insert_pfn(vmf->vma, vmf->address, pfn);
 
 	switch (ret) {
 	case 0:
diff --git a/drivers/gpu/drm/etnaviv/etnaviv_drv.h b/drivers/gpu/drm/etnaviv/etnaviv_drv.h
index c255eda40526..e41f38667c1c 100644
--- a/drivers/gpu/drm/etnaviv/etnaviv_drv.h
+++ b/drivers/gpu/drm/etnaviv/etnaviv_drv.h
@@ -73,7 +73,7 @@ int etnaviv_ioctl_gem_submit(struct drm_device *dev, void *data,
 		struct drm_file *file);
 
 int etnaviv_gem_mmap(struct file *filp, struct vm_area_struct *vma);
-int etnaviv_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf);
+int etnaviv_gem_fault(struct vm_fault *vmf);
 int etnaviv_gem_mmap_offset(struct drm_gem_object *obj, u64 *offset);
 struct sg_table *etnaviv_gem_prime_get_sg_table(struct drm_gem_object *obj);
 void *etnaviv_gem_prime_vmap(struct drm_gem_object *obj);
diff --git a/drivers/gpu/drm/omapdrm/omap_drv.h b/drivers/gpu/drm/omapdrm/omap_drv.h
index 7d9dd5400cef..7a8f4bf6effb 100644
--- a/drivers/gpu/drm/omapdrm/omap_drv.h
+++ b/drivers/gpu/drm/omapdrm/omap_drv.h
@@ -204,7 +204,7 @@ int omap_gem_dumb_create(struct drm_file *file, struct drm_device *dev,
 int omap_gem_mmap(struct file *filp, struct vm_area_struct *vma);
 int omap_gem_mmap_obj(struct drm_gem_object *obj,
 		struct vm_area_struct *vma);
-int omap_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf);
+int omap_gem_fault(struct vm_fault *vmf);
 int omap_gem_op_start(struct drm_gem_object *obj, enum omap_gem_op op);
 int omap_gem_op_finish(struct drm_gem_object *obj, enum omap_gem_op op);
 int omap_gem_op_sync(struct drm_gem_object *obj, enum omap_gem_op op);
diff --git a/drivers/hsi/clients/cmt_speech.c b/drivers/hsi/clients/cmt_speech.c
index 3deef6cc7d7c..7175e6bedf21 100644
--- a/drivers/hsi/clients/cmt_speech.c
+++ b/drivers/hsi/clients/cmt_speech.c
@@ -1098,9 +1098,9 @@ static void cs_hsi_stop(struct cs_hsi_iface *hi)
 	kfree(hi);
 }
 
-static int cs_char_vma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
+static int cs_char_vma_fault(struct vm_fault *vmf)
 {
-	struct cs_char *csdata = vma->vm_private_data;
+	struct cs_char *csdata = vmf->vma->vm_private_data;
 	struct page *page;
 
 	page = virt_to_page(csdata->mmap_base);
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
