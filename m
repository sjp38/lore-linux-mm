Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0F61228027C
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:23:04 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id a9so12126079pgf.12
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:23:04 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id z185si4539550pgb.202.2018.01.17.12.23.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:23:02 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 81/99] i915: Convert handles_vma to XArray
Date: Wed, 17 Jan 2018 12:21:45 -0800
Message-Id: <20180117202203.19756-82-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Straightforward conversion.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/gpu/drm/i915/i915_gem.c               |  2 +-
 drivers/gpu/drm/i915/i915_gem_context.c       | 12 +++++-------
 drivers/gpu/drm/i915/i915_gem_context.h       |  4 ++--
 drivers/gpu/drm/i915/i915_gem_execbuffer.c    |  6 +++---
 drivers/gpu/drm/i915/selftests/mock_context.c |  2 +-
 5 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 25ce7bcf9988..69e944f4dfce 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -3351,7 +3351,7 @@ void i915_gem_close_object(struct drm_gem_object *gem, struct drm_file *file)
 		if (ctx->file_priv != fpriv)
 			continue;
 
-		vma = radix_tree_delete(&ctx->handles_vma, lut->handle);
+		vma = xa_erase(&ctx->handles_vma, lut->handle);
 		GEM_BUG_ON(vma->obj != obj);
 
 		/* We allow the process to have multiple handles to the same
diff --git a/drivers/gpu/drm/i915/i915_gem_context.c b/drivers/gpu/drm/i915/i915_gem_context.c
index f782cf2069c1..1aff35ba6e18 100644
--- a/drivers/gpu/drm/i915/i915_gem_context.c
+++ b/drivers/gpu/drm/i915/i915_gem_context.c
@@ -95,9 +95,9 @@
 
 static void lut_close(struct i915_gem_context *ctx)
 {
+	XA_STATE(xas, &ctx->handles_vma, 0);
 	struct i915_lut_handle *lut, *ln;
-	struct radix_tree_iter iter;
-	void __rcu **slot;
+	struct i915_vma *vma;
 
 	list_for_each_entry_safe(lut, ln, &ctx->handles_list, ctx_link) {
 		list_del(&lut->obj_link);
@@ -105,10 +105,8 @@ static void lut_close(struct i915_gem_context *ctx)
 	}
 
 	rcu_read_lock();
-	radix_tree_for_each_slot(slot, &ctx->handles_vma, &iter, 0) {
-		struct i915_vma *vma = rcu_dereference_raw(*slot);
-
-		radix_tree_iter_delete(&ctx->handles_vma, &iter, slot);
+	xas_for_each(&xas, vma, ULONG_MAX) {
+		xas_store(&xas, NULL);
 		__i915_gem_object_release_unless_active(vma->obj);
 	}
 	rcu_read_unlock();
@@ -276,7 +274,7 @@ __create_hw_context(struct drm_i915_private *dev_priv,
 	ctx->i915 = dev_priv;
 	ctx->priority = I915_PRIORITY_NORMAL;
 
-	INIT_RADIX_TREE(&ctx->handles_vma, GFP_KERNEL);
+	xa_init(&ctx->handles_vma);
 	INIT_LIST_HEAD(&ctx->handles_list);
 
 	/* Default context will never have a file_priv */
diff --git a/drivers/gpu/drm/i915/i915_gem_context.h b/drivers/gpu/drm/i915/i915_gem_context.h
index 44688e22a5c2..8e3e0d002f77 100644
--- a/drivers/gpu/drm/i915/i915_gem_context.h
+++ b/drivers/gpu/drm/i915/i915_gem_context.h
@@ -181,11 +181,11 @@ struct i915_gem_context {
 	/** remap_slice: Bitmask of cache lines that need remapping */
 	u8 remap_slice;
 
-	/** handles_vma: rbtree to look up our context specific obj/vma for
+	/** handles_vma: lookup our context specific obj/vma for
 	 * the user handle. (user handles are per fd, but the binding is
 	 * per vm, which may be one per context or shared with the global GTT)
 	 */
-	struct radix_tree_root handles_vma;
+	struct xarray handles_vma;
 
 	/** handles_list: reverse list of all the rbtree entries in use for
 	 * this context, which allows us to free all the allocations on
diff --git a/drivers/gpu/drm/i915/i915_gem_execbuffer.c b/drivers/gpu/drm/i915/i915_gem_execbuffer.c
index 435ed95df144..828f4b5473ea 100644
--- a/drivers/gpu/drm/i915/i915_gem_execbuffer.c
+++ b/drivers/gpu/drm/i915/i915_gem_execbuffer.c
@@ -683,7 +683,7 @@ static int eb_select_context(struct i915_execbuffer *eb)
 
 static int eb_lookup_vmas(struct i915_execbuffer *eb)
 {
-	struct radix_tree_root *handles_vma = &eb->ctx->handles_vma;
+	struct xarray *handles_vma = &eb->ctx->handles_vma;
 	struct drm_i915_gem_object *obj;
 	unsigned int i;
 	int err;
@@ -702,7 +702,7 @@ static int eb_lookup_vmas(struct i915_execbuffer *eb)
 		struct i915_lut_handle *lut;
 		struct i915_vma *vma;
 
-		vma = radix_tree_lookup(handles_vma, handle);
+		vma = xa_load(handles_vma, handle);
 		if (likely(vma))
 			goto add_vma;
 
@@ -724,7 +724,7 @@ static int eb_lookup_vmas(struct i915_execbuffer *eb)
 			goto err_obj;
 		}
 
-		err = radix_tree_insert(handles_vma, handle, vma);
+		err = xa_err(xa_store(handles_vma, handle, vma, GFP_KERNEL));
 		if (unlikely(err)) {
 			kfree(lut);
 			goto err_obj;
diff --git a/drivers/gpu/drm/i915/selftests/mock_context.c b/drivers/gpu/drm/i915/selftests/mock_context.c
index bbf80d42e793..b664a7159242 100644
--- a/drivers/gpu/drm/i915/selftests/mock_context.c
+++ b/drivers/gpu/drm/i915/selftests/mock_context.c
@@ -40,7 +40,7 @@ mock_context(struct drm_i915_private *i915,
 	INIT_LIST_HEAD(&ctx->link);
 	ctx->i915 = i915;
 
-	INIT_RADIX_TREE(&ctx->handles_vma, GFP_KERNEL);
+	xa_init(&ctx->handles_vma);
 	INIT_LIST_HEAD(&ctx->handles_list);
 
 	ret = ida_simple_get(&i915->contexts.hw_ida,
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
