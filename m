Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 105246B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 20:43:54 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p4V0hks8009920
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:43:46 -0700
Received: from pvh18 (pvh18.prod.google.com [10.241.210.210])
	by kpbe19.cbf.corp.google.com with ESMTP id p4V0hiL7031517
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:43:44 -0700
Received: by pvh18 with SMTP id 18so1808995pvh.3
        for <linux-mm@kvack.org>; Mon, 30 May 2011 17:43:44 -0700 (PDT)
Date: Mon, 30 May 2011 17:43:44 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 6/14] drm/i915: use shmem_read_mapping_page
In-Reply-To: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
Message-ID: <alpine.LSU.2.00.1105301742220.5482@sister.anvils>
References: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Keith Packard <keithp@keithp.com>, Dave Airlie <airlied@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Soon tmpfs will stop supporting ->readpage and read_cache_page_gfp():
once "tmpfs: add shmem_read_mapping_page_gfp" has been applied,
this patch can be applied to ease the transition.

i915_gem_object_get_pages_gtt() use shmem_read_mapping_page_gfp() in
the one place it's needed; elsewhere use shmem_read_mapping_page(),
with the mapping's gfp_mask properly initialized.

Forget about __GFP_COLD: since tmpfs initializes its pages with memset,
asking for a cold page is counter-productive.

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Keith Packard <keithp@keithp.com>
Cc: Dave Airlie <airlied@redhat.com>
---
 drivers/gpu/drm/i915/i915_gem.c |   30 +++++++++++++-----------------
 1 file changed, 13 insertions(+), 17 deletions(-)

--- linux.orig/drivers/gpu/drm/i915/i915_gem.c	2011-05-30 13:56:10.068796399 -0700
+++ linux/drivers/gpu/drm/i915/i915_gem.c	2011-05-30 14:26:13.121737248 -0700
@@ -359,8 +359,7 @@ i915_gem_shmem_pread_fast(struct drm_dev
 		if ((page_offset + remain) > PAGE_SIZE)
 			page_length = PAGE_SIZE - page_offset;
 
-		page = read_cache_page_gfp(mapping, offset >> PAGE_SHIFT,
-					   GFP_HIGHUSER | __GFP_RECLAIMABLE);
+		page = shmem_read_mapping_page(mapping, offset >> PAGE_SHIFT);
 		if (IS_ERR(page))
 			return PTR_ERR(page);
 
@@ -463,8 +462,7 @@ i915_gem_shmem_pread_slow(struct drm_dev
 		if ((data_page_offset + page_length) > PAGE_SIZE)
 			page_length = PAGE_SIZE - data_page_offset;
 
-		page = read_cache_page_gfp(mapping, offset >> PAGE_SHIFT,
-					   GFP_HIGHUSER | __GFP_RECLAIMABLE);
+		page = shmem_read_mapping_page(mapping, offset >> PAGE_SHIFT);
 		if (IS_ERR(page))
 			return PTR_ERR(page);
 
@@ -796,8 +794,7 @@ i915_gem_shmem_pwrite_fast(struct drm_de
 		if ((page_offset + remain) > PAGE_SIZE)
 			page_length = PAGE_SIZE - page_offset;
 
-		page = read_cache_page_gfp(mapping, offset >> PAGE_SHIFT,
-					   GFP_HIGHUSER | __GFP_RECLAIMABLE);
+		page = shmem_read_mapping_page(mapping, offset >> PAGE_SHIFT);
 		if (IS_ERR(page))
 			return PTR_ERR(page);
 
@@ -906,8 +903,7 @@ i915_gem_shmem_pwrite_slow(struct drm_de
 		if ((data_page_offset + page_length) > PAGE_SIZE)
 			page_length = PAGE_SIZE - data_page_offset;
 
-		page = read_cache_page_gfp(mapping, offset >> PAGE_SHIFT,
-					   GFP_HIGHUSER | __GFP_RECLAIMABLE);
+		page = shmem_read_mapping_page(mapping, offset >> PAGE_SHIFT);
 		if (IS_ERR(page)) {
 			ret = PTR_ERR(page);
 			goto out;
@@ -1556,12 +1552,10 @@ i915_gem_object_get_pages_gtt(struct drm
 
 	inode = obj->base.filp->f_path.dentry->d_inode;
 	mapping = inode->i_mapping;
+	gfpmask |= mapping_gfp_mask(mapping);
+
 	for (i = 0; i < page_count; i++) {
-		page = read_cache_page_gfp(mapping, i,
-					   GFP_HIGHUSER |
-					   __GFP_COLD |
-					   __GFP_RECLAIMABLE |
-					   gfpmask);
+		page = shmem_read_mapping_page_gfp(mapping, i, gfpmask);
 		if (IS_ERR(page))
 			goto err_pages;
 
@@ -3565,6 +3559,7 @@ struct drm_i915_gem_object *i915_gem_all
 {
 	struct drm_i915_private *dev_priv = dev->dev_private;
 	struct drm_i915_gem_object *obj;
+	struct address_space *mapping;
 
 	obj = kzalloc(sizeof(*obj), GFP_KERNEL);
 	if (obj == NULL)
@@ -3575,6 +3570,9 @@ struct drm_i915_gem_object *i915_gem_all
 		return NULL;
 	}
 
+	mapping = obj->base.filp->f_path.dentry->d_inode->i_mapping;
+	mapping_set_gfp_mask(mapping, GFP_HIGHUSER | __GFP_RECLAIMABLE);
+
 	i915_gem_info_add_obj(dev_priv, size);
 
 	obj->base.write_domain = I915_GEM_DOMAIN_CPU;
@@ -3950,8 +3948,7 @@ void i915_gem_detach_phys_object(struct
 
 	page_count = obj->base.size / PAGE_SIZE;
 	for (i = 0; i < page_count; i++) {
-		struct page *page = read_cache_page_gfp(mapping, i,
-							GFP_HIGHUSER | __GFP_RECLAIMABLE);
+		struct page *page = shmem_read_mapping_page(mapping, i);
 		if (!IS_ERR(page)) {
 			char *dst = kmap_atomic(page);
 			memcpy(dst, vaddr + i*PAGE_SIZE, PAGE_SIZE);
@@ -4012,8 +4009,7 @@ i915_gem_attach_phys_object(struct drm_d
 		struct page *page;
 		char *dst, *src;
 
-		page = read_cache_page_gfp(mapping, i,
-					   GFP_HIGHUSER | __GFP_RECLAIMABLE);
+		page = shmem_read_mapping_page(mapping, i);
 		if (IS_ERR(page))
 			return PTR_ERR(page);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
