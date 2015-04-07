Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8F3A96B0070
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 17:05:42 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so34102578pdb.1
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 14:05:42 -0700 (PDT)
Received: from relay.fireflyinternet.com (hostedrelay.fireflyinternet.com. [109.228.30.76])
        by mx.google.com with ESMTP id wc6si13669910wjc.103.2015.04.07.09.31.44
        for <linux-mm@kvack.org>;
        Tue, 07 Apr 2015 09:31:45 -0700 (PDT)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH 5/5] drm/i915: Use remap_io_mapping() to prefault all PTE in a single pass
Date: Tue,  7 Apr 2015 17:31:39 +0100
Message-Id: <1428424299-13721-6-git-send-email-chris@chris-wilson.co.uk>
In-Reply-To: <1428424299-13721-1-git-send-email-chris@chris-wilson.co.uk>
References: <1428424299-13721-1-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: intel-gfx@lists.freedesktop.org, Chris Wilson <chris@chris-wilson.co.uk>, linux-mm@kvack.org

On an Ivybridge i7-3720qm with 1600MHz DDR3, with 32 fences,
Upload rate for 2 linear surfaces:  8134MiB/s -> 8154MiB/s
Upload rate for 2 tiled surfaces:   8625MiB/s -> 8632MiB/s
Upload rate for 4 linear surfaces:  8127MiB/s -> 8134MiB/s
Upload rate for 4 tiled surfaces:   8602MiB/s -> 8629MiB/s
Upload rate for 8 linear surfaces:  8124MiB/s -> 8137MiB/s
Upload rate for 8 tiled surfaces:   8603MiB/s -> 8624MiB/s
Upload rate for 16 linear surfaces: 8123MiB/s -> 8128MiB/s
Upload rate for 16 tiled surfaces:  8606MiB/s -> 8618MiB/s
Upload rate for 32 linear surfaces: 8121MiB/s -> 8128MiB/s
Upload rate for 32 tiled surfaces:  8605MiB/s -> 8614MiB/s
Upload rate for 64 linear surfaces: 8121MiB/s -> 8127MiB/s
Upload rate for 64 tiled surfaces:  3017MiB/s -> 5202MiB/s

Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Testcase: igt/gem_fence_upload/performance
Testcase: igt/gem_mmap_gtt
Reviewed-by: Brad Volkin <bradley.d.volkin@intel.com>
Cc: linux-mm@kvack.org
---
 drivers/gpu/drm/i915/i915_gem.c | 23 ++++++-----------------
 1 file changed, 6 insertions(+), 17 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 7ab8e0039790..90d772f72276 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -1667,25 +1667,14 @@ int i915_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	pfn = dev_priv->gtt.mappable_base + i915_gem_obj_ggtt_offset(obj);
 	pfn >>= PAGE_SHIFT;
 
-	if (!obj->fault_mappable) {
-		unsigned long size = min_t(unsigned long,
-					   vma->vm_end - vma->vm_start,
-					   obj->base.size);
-		int i;
+	ret = remap_io_mapping(vma,
+			       vma->vm_start, pfn, vma->vm_end - vma->vm_start,
+			       dev_priv->gtt.mappable);
+	if (ret)
+		goto unpin;
 
-		for (i = 0; i < size >> PAGE_SHIFT; i++) {
-			ret = vm_insert_pfn(vma,
-					    (unsigned long)vma->vm_start + i * PAGE_SIZE,
-					    pfn + i);
-			if (ret)
-				break;
-		}
+	obj->fault_mappable = true;
 
-		obj->fault_mappable = true;
-	} else
-		ret = vm_insert_pfn(vma,
-				    (unsigned long)vmf->virtual_address,
-				    pfn + page_offset);
 unpin:
 	i915_gem_object_ggtt_unpin(obj);
 unlock:
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
