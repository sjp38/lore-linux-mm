Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0DEEB828DF
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:42:05 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id n5so237447601pfn.2
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:42:05 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id f77si8534225pfd.64.2016.03.20.11.41.43
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:43 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 07/71] drm: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:14 +0300
Message-Id: <1458499278-1516-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Airlie <airlied@linux.ie>, Alex Deucher <alexander.deucher@amd.com>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Jani Nikula <jani.nikula@linux.intel.com>

PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
with promise that one day it will be possible to implement page cache with
bigger chunks than PAGE_SIZE.

This promise never materialized. And unlikely will.

We have many places where PAGE_CACHE_SIZE assumed to be equal to
PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
or PAGE_* constant should be used in a particular case, especially on the
border between fs and mm.

Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
breakage to be doable.

Let's stop pretending that pages in page cache are special. They are not.

The changes are pretty straight-forward:

 - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};

 - page_cache_get() -> get_page();

 - page_cache_release() -> put_page();

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: David Airlie <airlied@linux.ie>
Cc: Alex Deucher <alexander.deucher@amd.com>
Cc: Christian KA?nig <christian.koenig@amd.com>
Cc: Daniel Vetter <daniel.vetter@intel.com>
Cc: Jani Nikula <jani.nikula@linux.intel.com>
---
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c | 2 +-
 drivers/gpu/drm/armada/armada_gem.c     | 4 ++--
 drivers/gpu/drm/drm_gem.c               | 4 ++--
 drivers/gpu/drm/i915/i915_gem.c         | 8 ++++----
 drivers/gpu/drm/i915/i915_gem_userptr.c | 2 +-
 drivers/gpu/drm/radeon/radeon_ttm.c     | 2 +-
 drivers/gpu/drm/ttm/ttm_tt.c            | 4 ++--
 drivers/gpu/drm/via/via_dmablit.c       | 2 +-
 8 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
index 1cbb16e15307..d20a485c3aac 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
@@ -574,7 +574,7 @@ static void amdgpu_ttm_tt_unpin_userptr(struct ttm_tt *ttm)
 			set_page_dirty(page);
 
 		mark_page_accessed(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	sg_free_table(ttm->sg);
diff --git a/drivers/gpu/drm/armada/armada_gem.c b/drivers/gpu/drm/armada/armada_gem.c
index 6e731db31aa4..aca7f9cc6109 100644
--- a/drivers/gpu/drm/armada/armada_gem.c
+++ b/drivers/gpu/drm/armada/armada_gem.c
@@ -481,7 +481,7 @@ armada_gem_prime_map_dma_buf(struct dma_buf_attachment *attach,
 
  release:
 	for_each_sg(sgt->sgl, sg, num, i)
-		page_cache_release(sg_page(sg));
+		put_page(sg_page(sg));
  free_table:
 	sg_free_table(sgt);
  free_sgt:
@@ -502,7 +502,7 @@ static void armada_gem_prime_unmap_dma_buf(struct dma_buf_attachment *attach,
 	if (dobj->obj.filp) {
 		struct scatterlist *sg;
 		for_each_sg(sgt->sgl, sg, sgt->nents, i)
-			page_cache_release(sg_page(sg));
+			put_page(sg_page(sg));
 	}
 
 	sg_free_table(sgt);
diff --git a/drivers/gpu/drm/drm_gem.c b/drivers/gpu/drm/drm_gem.c
index 2e8c77e71e1f..da0c5320789f 100644
--- a/drivers/gpu/drm/drm_gem.c
+++ b/drivers/gpu/drm/drm_gem.c
@@ -534,7 +534,7 @@ struct page **drm_gem_get_pages(struct drm_gem_object *obj)
 
 fail:
 	while (i--)
-		page_cache_release(pages[i]);
+		put_page(pages[i]);
 
 	drm_free_large(pages);
 	return ERR_CAST(p);
@@ -569,7 +569,7 @@ void drm_gem_put_pages(struct drm_gem_object *obj, struct page **pages,
 			mark_page_accessed(pages[i]);
 
 		/* Undo the reference we took when populating the table */
-		page_cache_release(pages[i]);
+		put_page(pages[i]);
 	}
 
 	drm_free_large(pages);
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index bb44bad15403..7d6468407fd6 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -177,7 +177,7 @@ i915_gem_object_get_pages_phys(struct drm_i915_gem_object *obj)
 		drm_clflush_virt_range(vaddr, PAGE_SIZE);
 		kunmap_atomic(src);
 
-		page_cache_release(page);
+		put_page(page);
 		vaddr += PAGE_SIZE;
 	}
 
@@ -243,7 +243,7 @@ i915_gem_object_put_pages_phys(struct drm_i915_gem_object *obj)
 			set_page_dirty(page);
 			if (obj->madv == I915_MADV_WILLNEED)
 				mark_page_accessed(page);
-			page_cache_release(page);
+			put_page(page);
 			vaddr += PAGE_SIZE;
 		}
 		obj->dirty = 0;
@@ -2204,7 +2204,7 @@ i915_gem_object_put_pages_gtt(struct drm_i915_gem_object *obj)
 		if (obj->madv == I915_MADV_WILLNEED)
 			mark_page_accessed(page);
 
-		page_cache_release(page);
+		put_page(page);
 	}
 	obj->dirty = 0;
 
@@ -2344,7 +2344,7 @@ i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
 err_pages:
 	sg_mark_end(sg);
 	for_each_sg_page(st->sgl, &sg_iter, st->nents, 0)
-		page_cache_release(sg_page_iter_page(&sg_iter));
+		put_page(sg_page_iter_page(&sg_iter));
 	sg_free_table(st);
 	kfree(st);
 
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 59e45b3a6937..7b5b6091bfdc 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -764,7 +764,7 @@ i915_gem_userptr_put_pages(struct drm_i915_gem_object *obj)
 			set_page_dirty(page);
 
 		mark_page_accessed(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	obj->dirty = 0;
 
diff --git a/drivers/gpu/drm/radeon/radeon_ttm.c b/drivers/gpu/drm/radeon/radeon_ttm.c
index e06ac546a90f..19fdacb6cf75 100644
--- a/drivers/gpu/drm/radeon/radeon_ttm.c
+++ b/drivers/gpu/drm/radeon/radeon_ttm.c
@@ -610,7 +610,7 @@ static void radeon_ttm_tt_unpin_userptr(struct ttm_tt *ttm)
 			set_page_dirty(page);
 
 		mark_page_accessed(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	sg_free_table(ttm->sg);
diff --git a/drivers/gpu/drm/ttm/ttm_tt.c b/drivers/gpu/drm/ttm/ttm_tt.c
index 4e19d0f9cc30..077ae9b2865d 100644
--- a/drivers/gpu/drm/ttm/ttm_tt.c
+++ b/drivers/gpu/drm/ttm/ttm_tt.c
@@ -311,7 +311,7 @@ int ttm_tt_swapin(struct ttm_tt *ttm)
 			goto out_err;
 
 		copy_highpage(to_page, from_page);
-		page_cache_release(from_page);
+		put_page(from_page);
 	}
 
 	if (!(ttm->page_flags & TTM_PAGE_FLAG_PERSISTENT_SWAP))
@@ -361,7 +361,7 @@ int ttm_tt_swapout(struct ttm_tt *ttm, struct file *persistent_swap_storage)
 		copy_highpage(to_page, from_page);
 		set_page_dirty(to_page);
 		mark_page_accessed(to_page);
-		page_cache_release(to_page);
+		put_page(to_page);
 	}
 
 	ttm_tt_unpopulate(ttm);
diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
index d0cbd5ecd7f0..0c76a4d429f2 100644
--- a/drivers/gpu/drm/via/via_dmablit.c
+++ b/drivers/gpu/drm/via/via_dmablit.c
@@ -188,7 +188,7 @@ via_free_sg_info(struct pci_dev *pdev, drm_via_sg_info_t *vsg)
 			if (NULL != (page = vsg->pages[i])) {
 				if (!PageReserved(page) && (DMA_FROM_DEVICE == vsg->direction))
 					SetPageDirty(page);
-				page_cache_release(page);
+				put_page(page);
 			}
 		}
 	case dr_via_pages_alloc:
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
