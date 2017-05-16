Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 231876B02F2
	for <linux-mm@kvack.org>; Tue, 16 May 2017 04:30:04 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e8so120294335pfl.4
        for <linux-mm@kvack.org>; Tue, 16 May 2017 01:30:04 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id p2si10265605pfg.78.2017.05.16.01.30.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 01:30:03 -0700 (PDT)
From: Matthew Auld <matthew.auld@intel.com>
Subject: [PATCH 07/17] drm/i915: request THP for shmem backed objects
Date: Tue, 16 May 2017 09:29:38 +0100
Message-Id: <20170516082948.28090-8-matthew.auld@intel.com>
In-Reply-To: <20170516082948.28090-1-matthew.auld@intel.com>
References: <20170516082948.28090-1-matthew.auld@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Daniel Vetter <daniel@ffwll.ch>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

Default to transparent-huge-pages for shmem backed objects through the
SHMEM_HUGE_WITHIN_SIZE huge option. Best effort only.

Signed-off-by: Matthew Auld <matthew.auld@intel.com>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Daniel Vetter <daniel@ffwll.ch>
Cc: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org
---
 drivers/gpu/drm/i915/i915_gem.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 6a5e864d7710..e4ee54f0f55f 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -4308,6 +4308,16 @@ i915_gem_object_create(struct drm_i915_private *dev_priv, u64 size)
 	mapping = obj->base.filp->f_mapping;
 	mapping_set_gfp_mask(mapping, mask);
 
+	/* If configured attempt to use THP through shmemfs. This will
+	 * effectively default to huge-pages for this mapping if it makes sense
+	 * given the object size and HPAGE_PMD_SIZE. This is best effort only.
+	 */
+#ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
+	if (has_transparent_hugepage() &&
+	    HAS_PAGE_SIZE(dev_priv, HPAGE_PMD_SIZE))
+		SHMEM_I(mapping->host)->huge = SHMEM_HUGE_WITHIN_SIZE;
+#endif
+
 	i915_gem_object_init(obj, &i915_gem_object_ops);
 
 	obj->base.write_domain = I915_GEM_DOMAIN_CPU;
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
