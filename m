Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id D39546B000C
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 13:44:21 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id r24-v6so6437908ljr.18
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 10:44:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z4-v6sor3890102lfh.21.2018.10.16.10.44.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Oct 2018 10:44:20 -0700 (PDT)
From: Kuo-Hsin Yang <vovoy@chromium.org>
Subject: [PATCH 2/2] drm/i915: Mark pinned shmemfs pages as unevictable
Date: Wed, 17 Oct 2018 01:43:00 +0800
Message-Id: <20181016174300.197906-3-vovoy@chromium.org>
In-Reply-To: <20181016174300.197906-1-vovoy@chromium.org>
References: <20181016174300.197906-1-vovoy@chromium.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org
Cc: mhocko@suse.com, akpm@linux-foundation.org, chris@chris-wilson.co.uk, peterz@infradead.org, dave.hansen@intel.com, corbet@lwn.net, hughd@google.com, joonas.lahtinen@linux.intel.com, marcheu@chromium.org, hoegsberg@chromium.org, Kuo-Hsin Yang <vovoy@chromium.org>

The i915 driver use shmemfs to allocate backing storage for gem objects.
These shmemfs pages can be pinned (increased ref count) by
shmem_read_mapping_page_gfp(). When a lot of pages are pinned, vmscan
wastes a lot of time scanning these pinned pages. Mark these pinned
pages as unevictable to speed up vmscan.

Signed-off-by: Kuo-Hsin Yang <vovoy@chromium.org>
---
 drivers/gpu/drm/i915/i915_gem.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index fcc73a6ab503..e0ff5b736128 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -2390,6 +2390,7 @@ i915_gem_object_put_pages_gtt(struct drm_i915_gem_object *obj,
 {
 	struct sgt_iter sgt_iter;
 	struct page *page;
+	struct address_space *mapping;
 
 	__i915_gem_object_release_shmem(obj, pages, true);
 
@@ -2409,6 +2410,10 @@ i915_gem_object_put_pages_gtt(struct drm_i915_gem_object *obj,
 	}
 	obj->mm.dirty = false;
 
+	mapping = file_inode(obj->base.filp)->i_mapping;
+	mapping_clear_unevictable(mapping);
+	shmem_unlock_mapping(mapping);
+
 	sg_free_table(pages);
 	kfree(pages);
 }
@@ -2551,6 +2556,7 @@ static int i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
 	 * Fail silently without starting the shrinker
 	 */
 	mapping = obj->base.filp->f_mapping;
+	mapping_set_unevictable(mapping);
 	noreclaim = mapping_gfp_constraint(mapping, ~__GFP_RECLAIM);
 	noreclaim |= __GFP_NORETRY | __GFP_NOWARN;
 
@@ -2664,6 +2670,8 @@ static int i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
 err_pages:
 	for_each_sgt_page(page, sgt_iter, st)
 		put_page(page);
+	mapping_clear_unevictable(mapping);
+	shmem_unlock_mapping(mapping);
 	sg_free_table(st);
 	kfree(st);
 
-- 
2.19.1.331.ge82ca0e54c-goog
