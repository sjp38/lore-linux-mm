Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 301656B026E
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 04:58:56 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id r81-v6so26014936pfk.11
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 01:58:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p8-v6sor7099507pgf.59.2018.10.17.01.58.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Oct 2018 01:58:54 -0700 (PDT)
From: Kuo-Hsin Yang <vovoy@chromium.org>
Subject: [PATCH v2] shmem, drm/i915: mark pinned shmemfs pages as unevictable
Date: Wed, 17 Oct 2018 16:58:01 +0800
Message-Id: <20181017085801.220742-1-vovoy@chromium.org>
In-Reply-To: <20181016174300.197906-1-vovoy@chromium.org>
References: <20181016174300.197906-1-vovoy@chromium.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vovoy@chromium.org
Cc: akpm@linux-foundation.org, chris@chris-wilson.co.uk, corbet@lwn.net, dave.hansen@intel.com, hoegsberg@chromium.org, hughd@google.com, intel-gfx@lists.freedesktop.org, joonas.lahtinen@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, marcheu@chromium.org, mhocko@suse.com, peterz@infradead.org

The i915 driver uses shmemfs to allocate backing storage for gem
objects. These shmemfs pages can be pinned (increased ref count) by
shmem_read_mapping_page_gfp(). When a lot of pages are pinned, vmscan
wastes a lot of time scanning these pinned pages. In some extreme case,
all pages in the inactive anon lru are pinned, and only the inactive
anon lru is scanned due to inactive_ratio, the system cannot swap and
invokes the oom-killer. Mark these pinned pages as unevictable to speed
up vmscan.

By exporting shmem_unlock_mapping, drivers can: 1. mark a shmemfs
address space as unevictable with mapping_set_unevictable(), pages in
the address space will be moved to unevictable list in vmscan. 2. mark
an address space as evictable with mapping_clear_unevictable(), and move
these pages back to evictable list with shmem_unlock_mapping().

This patch was inspired by Chris Wilson's change [1].

[1]: https://patchwork.kernel.org/patch/9768741/

Signed-off-by: Kuo-Hsin Yang <vovoy@chromium.org>
---
Changes for v2:
 Squashed the two patches.

 Documentation/vm/unevictable-lru.rst | 4 +++-
 drivers/gpu/drm/i915/i915_gem.c      | 8 ++++++++
 mm/shmem.c                           | 2 ++
 3 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/Documentation/vm/unevictable-lru.rst b/Documentation/vm/unevictable-lru.rst
index fdd84cb8d511..a812fb55136d 100644
--- a/Documentation/vm/unevictable-lru.rst
+++ b/Documentation/vm/unevictable-lru.rst
@@ -143,7 +143,7 @@ using a number of wrapper functions:
 	Query the address space, and return true if it is completely
 	unevictable.
 
-These are currently used in two places in the kernel:
+These are currently used in three places in the kernel:
 
  (1) By ramfs to mark the address spaces of its inodes when they are created,
      and this mark remains for the life of the inode.
@@ -154,6 +154,8 @@ These are currently used in two places in the kernel:
      swapped out; the application must touch the pages manually if it wants to
      ensure they're in memory.
 
+ (3) By the i915 driver to mark pinned address space until it's unpinned.
+
 
 Detecting Unevictable Pages
 ---------------------------
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
 
diff --git a/mm/shmem.c b/mm/shmem.c
index 446942677cd4..d1ce34c09df6 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -786,6 +786,7 @@ void shmem_unlock_mapping(struct address_space *mapping)
 		cond_resched();
 	}
 }
+EXPORT_SYMBOL_GPL(shmem_unlock_mapping);
 
 /*
  * Remove range of pages and swap entries from radix tree, and free them.
@@ -3874,6 +3875,7 @@ int shmem_lock(struct file *file, int lock, struct user_struct *user)
 void shmem_unlock_mapping(struct address_space *mapping)
 {
 }
+EXPORT_SYMBOL_GPL(shmem_unlock_mapping);
 
 #ifdef CONFIG_MMU
 unsigned long shmem_get_unmapped_area(struct file *file,
-- 
2.19.1.331.ge82ca0e54c-goog
