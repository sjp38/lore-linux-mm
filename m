Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0E3F76B025F
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 14:48:08 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y77so14632615pfd.2
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 11:48:08 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id f10si4527532pgr.778.2017.09.25.11.48.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 11:48:07 -0700 (PDT)
From: Matthew Auld <matthew.auld@intel.com>
Subject: [PATCH 04/22] drm/i915/gemfs: enable THP
Date: Mon, 25 Sep 2017 19:47:19 +0100
Message-Id: <20170925184737.8807-5-matthew.auld@intel.com>
In-Reply-To: <20170925184737.8807-1-matthew.auld@intel.com>
References: <20170925184737.8807-1-matthew.auld@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Chris Wilson <chris@chris-wilson.co.uk>, Dave Hansen <dave.hansen@intel.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

Enable transparent-huge-pages through gemfs by mounting with
huge=within_size.

v2: prefer kern_mount_data

Signed-off-by: Matthew Auld <matthew.auld@intel.com>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org
---
 drivers/gpu/drm/i915/i915_gemfs.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/i915/i915_gemfs.c b/drivers/gpu/drm/i915/i915_gemfs.c
index 168d0bd98f60..dc35719814f0 100644
--- a/drivers/gpu/drm/i915/i915_gemfs.c
+++ b/drivers/gpu/drm/i915/i915_gemfs.c
@@ -24,6 +24,7 @@
 
 #include <linux/fs.h>
 #include <linux/mount.h>
+#include <linux/pagemap.h>
 
 #include "i915_drv.h"
 #include "i915_gemfs.h"
@@ -32,12 +33,17 @@ int i915_gemfs_init(struct drm_i915_private *i915)
 {
 	struct file_system_type *type;
 	struct vfsmount *gemfs;
+	char within_size[] = "huge=within_size";
+	char *options = NULL;
 
 	type = get_fs_type("tmpfs");
 	if (!type)
 		return -ENODEV;
 
-	gemfs = kern_mount(type);
+	if (has_transparent_hugepage())
+		options = within_size;
+
+	gemfs = kern_mount_data(type, options);
 	if (IS_ERR(gemfs))
 		return PTR_ERR(gemfs);
 
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
