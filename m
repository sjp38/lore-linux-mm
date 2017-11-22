Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 373616B0266
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:10:09 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id m4so4618885pgc.23
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:10:09 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t1si13944930pgq.794.2017.11.22.13.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:21 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 60/62] drm: Replace vmwgfx IDRs with IDAs
Date: Wed, 22 Nov 2017 13:07:37 -0800
Message-Id: <20171122210739.29916-61-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

These IDRs were only being used to allocate unique numbers, not to look
up pointers, so they can use the more space-efficient IDA instead.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/gpu/drm/vmwgfx/vmwgfx_drv.c      |  6 +++---
 drivers/gpu/drm/vmwgfx/vmwgfx_drv.h      |  2 +-
 drivers/gpu/drm/vmwgfx/vmwgfx_resource.c | 28 ++++++++++------------------
 3 files changed, 14 insertions(+), 22 deletions(-)

diff --git a/drivers/gpu/drm/vmwgfx/vmwgfx_drv.c b/drivers/gpu/drm/vmwgfx/vmwgfx_drv.c
index 184340d486c3..fc6e04cf071e 100644
--- a/drivers/gpu/drm/vmwgfx/vmwgfx_drv.c
+++ b/drivers/gpu/drm/vmwgfx/vmwgfx_drv.c
@@ -652,7 +652,7 @@ static int vmw_driver_load(struct drm_device *dev, unsigned long chipset)
 	spin_lock_init(&dev_priv->cursor_lock);
 
 	for (i = vmw_res_context; i < vmw_res_max; ++i) {
-		idr_init(&dev_priv->res_idr[i]);
+		ida_init(&dev_priv->res_ida[i]);
 		INIT_LIST_HEAD(&dev_priv->res_lru[i]);
 	}
 
@@ -950,7 +950,7 @@ static int vmw_driver_load(struct drm_device *dev, unsigned long chipset)
 	vmw_ttm_global_release(dev_priv);
 out_err0:
 	for (i = vmw_res_context; i < vmw_res_max; ++i)
-		idr_destroy(&dev_priv->res_idr[i]);
+		ida_destroy(&dev_priv->res_ida[i]);
 
 	if (dev_priv->ctx.staged_bindings)
 		vmw_binding_state_free(dev_priv->ctx.staged_bindings);
@@ -1002,7 +1002,7 @@ static void vmw_driver_unload(struct drm_device *dev)
 	vmw_ttm_global_release(dev_priv);
 
 	for (i = vmw_res_context; i < vmw_res_max; ++i)
-		idr_destroy(&dev_priv->res_idr[i]);
+		ida_destroy(&dev_priv->res_ida[i]);
 
 	kfree(dev_priv);
 }
diff --git a/drivers/gpu/drm/vmwgfx/vmwgfx_drv.h b/drivers/gpu/drm/vmwgfx/vmwgfx_drv.h
index 7e5f30e234b1..96866a1e3547 100644
--- a/drivers/gpu/drm/vmwgfx/vmwgfx_drv.h
+++ b/drivers/gpu/drm/vmwgfx/vmwgfx_drv.h
@@ -429,7 +429,7 @@ struct vmw_private {
 	 */
 
 	rwlock_t resource_lock;
-	struct idr res_idr[vmw_res_max];
+	struct ida res_ida[vmw_res_max];
 	/*
 	 * Block lastclose from racing with firstopen.
 	 */
diff --git a/drivers/gpu/drm/vmwgfx/vmwgfx_resource.c b/drivers/gpu/drm/vmwgfx/vmwgfx_resource.c
index a96f90f017d1..ca0e2a1fd0c5 100644
--- a/drivers/gpu/drm/vmwgfx/vmwgfx_resource.c
+++ b/drivers/gpu/drm/vmwgfx/vmwgfx_resource.c
@@ -80,13 +80,11 @@ vmw_resource_reference_unless_doomed(struct vmw_resource *res)
 void vmw_resource_release_id(struct vmw_resource *res)
 {
 	struct vmw_private *dev_priv = res->dev_priv;
-	struct idr *idr = &dev_priv->res_idr[res->func->res_type];
+	struct ida *ida = &dev_priv->res_ida[res->func->res_type];
 
-	write_lock(&dev_priv->resource_lock);
 	if (res->id != -1)
-		idr_remove(idr, res->id);
+		ida_simple_remove(ida, res->id);
 	res->id = -1;
-	write_unlock(&dev_priv->resource_lock);
 }
 
 static void vmw_resource_release(struct kref *kref)
@@ -95,7 +93,7 @@ static void vmw_resource_release(struct kref *kref)
 	    container_of(kref, struct vmw_resource, kref);
 	struct vmw_private *dev_priv = res->dev_priv;
 	int id;
-	struct idr *idr = &dev_priv->res_idr[res->func->res_type];
+	struct ida *ida = &dev_priv->res_ida[res->func->res_type];
 
 	write_lock(&dev_priv->resource_lock);
 	res->avail = false;
@@ -132,10 +130,8 @@ static void vmw_resource_release(struct kref *kref)
 	else
 		kfree(res);
 
-	write_lock(&dev_priv->resource_lock);
 	if (id != -1)
-		idr_remove(idr, id);
-	write_unlock(&dev_priv->resource_lock);
+		ida_simple_remove(ida, id);
 }
 
 void vmw_resource_unreference(struct vmw_resource **p_res)
@@ -159,20 +155,16 @@ int vmw_resource_alloc_id(struct vmw_resource *res)
 {
 	struct vmw_private *dev_priv = res->dev_priv;
 	int ret;
-	struct idr *idr = &dev_priv->res_idr[res->func->res_type];
+	struct ida *ida = &dev_priv->res_ida[res->func->res_type];
 
 	BUG_ON(res->id != -1);
 
-	idr_preload(GFP_KERNEL);
-	write_lock(&dev_priv->resource_lock);
-
-	ret = idr_alloc(idr, res, 1, 0, GFP_NOWAIT);
-	if (ret >= 0)
-		res->id = ret;
+	ret = ida_simple_get(ida, 1, 0, GFP_KERNEL);
+	if (ret < 0)
+		return ret;
 
-	write_unlock(&dev_priv->resource_lock);
-	idr_preload_end();
-	return ret < 0 ? ret : 0;
+	res->id = ret;
+	return 0;
 }
 
 /**
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
