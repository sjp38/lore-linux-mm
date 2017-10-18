Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 288A46B025E
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 03:59:56 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id o44so2076251wrf.0
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 00:59:56 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id k13si1570602edl.288.2017.10.18.00.59.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 00:59:54 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 722C41C2F81
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 08:59:54 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 6/8] mm: Remove cold parameter for release_pages
Date: Wed, 18 Oct 2017 08:59:50 +0100
Message-Id: <20171018075952.10627-7-mgorman@techsingularity.net>
In-Reply-To: <20171018075952.10627-1-mgorman@techsingularity.net>
References: <20171018075952.10627-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@techsingularity.net>

All callers of release_pages claim the pages being released are cache hot.
As no one cares about the hotness of pages being released to the allocator,
just ditch the parameter.

No performance impact is expected as the overhead is marginal. The parameter
is removed simply because it is a bit stupid to have a useless parameter
copied everywhere.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c  | 6 ++----
 drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c | 2 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c | 2 +-
 drivers/gpu/drm/etnaviv/etnaviv_gem.c   | 6 +++---
 drivers/gpu/drm/i915/i915_gem_userptr.c | 4 ++--
 drivers/gpu/drm/radeon/radeon_ttm.c     | 2 +-
 fs/fuse/dev.c                           | 2 +-
 include/linux/pagemap.h                 | 2 +-
 include/linux/swap.h                    | 2 +-
 mm/swap.c                               | 8 ++++----
 mm/swap_state.c                         | 2 +-
 11 files changed, 18 insertions(+), 20 deletions(-)

diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c
index 60d8bedb694d..cd664832f9e8 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c
@@ -553,8 +553,7 @@ static int amdgpu_cs_parser_bos(struct amdgpu_cs_parser *p,
 				 * invalidated it. Free it and try again
 				 */
 				release_pages(e->user_pages,
-					      e->robj->tbo.ttm->num_pages,
-					      false);
+					      e->robj->tbo.ttm->num_pages);
 				kvfree(e->user_pages);
 				e->user_pages = NULL;
 			}
@@ -691,8 +690,7 @@ static int amdgpu_cs_parser_bos(struct amdgpu_cs_parser *p,
 				continue;
 
 			release_pages(e->user_pages,
-				      e->robj->tbo.ttm->num_pages,
-				      false);
+				      e->robj->tbo.ttm->num_pages);
 			kvfree(e->user_pages);
 		}
 	}
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
index 7171968f261e..8cd32598276e 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
@@ -347,7 +347,7 @@ int amdgpu_gem_userptr_ioctl(struct drm_device *dev, void *data,
 	return 0;
 
 free_pages:
-	release_pages(bo->tbo.ttm->pages, bo->tbo.ttm->num_pages, false);
+	release_pages(bo->tbo.ttm->pages, bo->tbo.ttm->num_pages);
 
 unlock_mmap_sem:
 	up_read(&current->mm->mmap_sem);
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
index bc746131987f..d792959fac43 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
@@ -659,7 +659,7 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct page **pages)
 	return 0;
 
 release_pages:
-	release_pages(pages, pinned, 0);
+	release_pages(pages, pinned);
 	return r;
 }
 
diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gem.c b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
index 57881167ccd2..bcc8c2d7c7c9 100644
--- a/drivers/gpu/drm/etnaviv/etnaviv_gem.c
+++ b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
@@ -779,7 +779,7 @@ static struct page **etnaviv_gem_userptr_do_get_pages(
 	up_read(&mm->mmap_sem);
 
 	if (ret < 0) {
-		release_pages(pvec, pinned, 0);
+		release_pages(pvec, pinned);
 		kvfree(pvec);
 		return ERR_PTR(ret);
 	}
@@ -852,7 +852,7 @@ static int etnaviv_gem_userptr_get_pages(struct etnaviv_gem_object *etnaviv_obj)
 		}
 	}
 
-	release_pages(pvec, pinned, 0);
+	release_pages(pvec, pinned);
 	kvfree(pvec);
 
 	work = kmalloc(sizeof(*work), GFP_KERNEL);
@@ -886,7 +886,7 @@ static void etnaviv_gem_userptr_release(struct etnaviv_gem_object *etnaviv_obj)
 	if (etnaviv_obj->pages) {
 		int npages = etnaviv_obj->base.size >> PAGE_SHIFT;
 
-		release_pages(etnaviv_obj->pages, npages, 0);
+		release_pages(etnaviv_obj->pages, npages);
 		kvfree(etnaviv_obj->pages);
 	}
 	put_task_struct(etnaviv_obj->userptr.task);
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 709efe2357ea..aa22361bd5a1 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -554,7 +554,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 	}
 	mutex_unlock(&obj->mm.lock);
 
-	release_pages(pvec, pinned, 0);
+	release_pages(pvec, pinned);
 	kvfree(pvec);
 
 	i915_gem_object_put(obj);
@@ -668,7 +668,7 @@ i915_gem_userptr_get_pages(struct drm_i915_gem_object *obj)
 		__i915_gem_userptr_set_active(obj, true);
 
 	if (IS_ERR(pages))
-		release_pages(pvec, pinned, 0);
+		release_pages(pvec, pinned);
 	kvfree(pvec);
 
 	return pages;
diff --git a/drivers/gpu/drm/radeon/radeon_ttm.c b/drivers/gpu/drm/radeon/radeon_ttm.c
index bf69bf9086bf..1fdfc7a46072 100644
--- a/drivers/gpu/drm/radeon/radeon_ttm.c
+++ b/drivers/gpu/drm/radeon/radeon_ttm.c
@@ -597,7 +597,7 @@ static int radeon_ttm_tt_pin_userptr(struct ttm_tt *ttm)
 	kfree(ttm->sg);
 
 release_pages:
-	release_pages(ttm->pages, pinned, 0);
+	release_pages(ttm->pages, pinned);
 	return r;
 }
 
diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
index 13c65dd2d37d..6ea5bd9fc023 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -1636,7 +1636,7 @@ static int fuse_notify_store(struct fuse_conn *fc, unsigned int size,
 
 static void fuse_retrieve_end(struct fuse_conn *fc, struct fuse_req *req)
 {
-	release_pages(req->pages, req->num_pages, false);
+	release_pages(req->pages, req->num_pages);
 }
 
 static int fuse_retrieve(struct fuse_conn *fc, struct inode *inode,
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 333349585776..514f6d9d8083 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -115,7 +115,7 @@ static inline void mapping_set_gfp_mask(struct address_space *m, gfp_t mask)
 	m->gfp_mask = mask;
 }
 
-void release_pages(struct page **pages, int nr, bool cold);
+void release_pages(struct page **pages, int nr);
 
 /*
  * speculatively take a reference to a page.
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 257c48a525c8..31a89eb48e71 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -492,7 +492,7 @@ extern void exit_swap_address_space(unsigned int type);
 #define free_page_and_swap_cache(page) \
 	put_page(page)
 #define free_pages_and_swap_cache(pages, nr) \
-	release_pages((pages), (nr), false);
+	release_pages((pages), (nr));
 
 static inline void show_swap_cache_info(void)
 {
diff --git a/mm/swap.c b/mm/swap.c
index 73682e1dc0a2..0b78ea3cbdea 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -210,7 +210,7 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
 	}
 	if (pgdat)
 		spin_unlock_irqrestore(&pgdat->lru_lock, flags);
-	release_pages(pvec->pages, pvec->nr, 0);
+	release_pages(pvec->pages, pvec->nr);
 	pagevec_reinit(pvec);
 }
 
@@ -740,7 +740,7 @@ void lru_add_drain_all(void)
  * Decrement the reference count on all the pages in @pages.  If it
  * fell to zero, remove the page from the LRU and free it.
  */
-void release_pages(struct page **pages, int nr, bool cold)
+void release_pages(struct page **pages, int nr)
 {
 	int i;
 	LIST_HEAD(pages_to_free);
@@ -817,7 +817,7 @@ void release_pages(struct page **pages, int nr, bool cold)
 		spin_unlock_irqrestore(&locked_pgdat->lru_lock, flags);
 
 	mem_cgroup_uncharge_list(&pages_to_free);
-	free_hot_cold_page_list(&pages_to_free, cold);
+	free_hot_cold_page_list(&pages_to_free, 0);
 }
 EXPORT_SYMBOL(release_pages);
 
@@ -837,7 +837,7 @@ void __pagevec_release(struct pagevec *pvec)
 		lru_add_drain();
 		pvec->drained = true;
 	}
-	release_pages(pvec->pages, pagevec_count(pvec), 0);
+	release_pages(pvec->pages, pagevec_count(pvec));
 	pagevec_reinit(pvec);
 }
 EXPORT_SYMBOL(__pagevec_release);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 05b6803f0cce..f7048f1c8e3e 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -318,7 +318,7 @@ void free_pages_and_swap_cache(struct page **pages, int nr)
 	lru_add_drain();
 	for (i = 0; i < nr; i++)
 		free_swap_cache(pagep[i]);
-	release_pages(pagep, nr, false);
+	release_pages(pagep, nr);
 }
 
 /*
-- 
2.14.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
