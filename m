Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8DC686B02BA
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:10:10 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id s11so17275597pgc.15
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:10:10 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id bi1si14210725plb.566.2017.11.22.13.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:20 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 59/62] drm: Replace virtio IDRs with IDAs
Date: Wed, 22 Nov 2017 13:07:36 -0800
Message-Id: <20171122210739.29916-60-willy@infradead.org>
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
 drivers/gpu/drm/virtio/virtgpu_drv.h |  6 ++----
 drivers/gpu/drm/virtio/virtgpu_kms.c | 18 ++++--------------
 drivers/gpu/drm/virtio/virtgpu_vq.c  | 12 ++----------
 3 files changed, 8 insertions(+), 28 deletions(-)

diff --git a/drivers/gpu/drm/virtio/virtgpu_drv.h b/drivers/gpu/drm/virtio/virtgpu_drv.h
index da2fb585fea4..6852e8bbc1b0 100644
--- a/drivers/gpu/drm/virtio/virtgpu_drv.h
+++ b/drivers/gpu/drm/virtio/virtgpu_drv.h
@@ -181,8 +181,7 @@ struct virtio_gpu_device {
 	struct kmem_cache *vbufs;
 	bool vqs_ready;
 
-	struct idr	resource_idr;
-	spinlock_t resource_idr_lock;
+	struct ida	resource_ida;
 
 	wait_queue_head_t resp_wq;
 	/* current display info */
@@ -191,8 +190,7 @@ struct virtio_gpu_device {
 
 	struct virtio_gpu_fence_driver fence_drv;
 
-	struct idr	ctx_id_idr;
-	spinlock_t ctx_id_idr_lock;
+	struct ida	ctx_id_ida;
 
 	bool has_virgl_3d;
 
diff --git a/drivers/gpu/drm/virtio/virtgpu_kms.c b/drivers/gpu/drm/virtio/virtgpu_kms.c
index 6400506a06b0..29c08b63d8d3 100644
--- a/drivers/gpu/drm/virtio/virtgpu_kms.c
+++ b/drivers/gpu/drm/virtio/virtgpu_kms.c
@@ -55,21 +55,13 @@ static void virtio_gpu_config_changed_work_func(struct work_struct *work)
 static void virtio_gpu_ctx_id_get(struct virtio_gpu_device *vgdev,
 				  uint32_t *resid)
 {
-	int handle;
-
-	idr_preload(GFP_KERNEL);
-	spin_lock(&vgdev->ctx_id_idr_lock);
-	handle = idr_alloc(&vgdev->ctx_id_idr, NULL, 1, 0, 0);
-	spin_unlock(&vgdev->ctx_id_idr_lock);
-	idr_preload_end();
+	int handle = ida_simple_get(&vgdev->ctx_id_ida, 1, 0, GFP_KERNEL);
 	*resid = handle;
 }
 
 static void virtio_gpu_ctx_id_put(struct virtio_gpu_device *vgdev, uint32_t id)
 {
-	spin_lock(&vgdev->ctx_id_idr_lock);
-	idr_remove(&vgdev->ctx_id_idr, id);
-	spin_unlock(&vgdev->ctx_id_idr_lock);
+	ida_simple_remove(&vgdev->ctx_id_ida, id);
 }
 
 static void virtio_gpu_context_create(struct virtio_gpu_device *vgdev,
@@ -151,10 +143,8 @@ int virtio_gpu_driver_load(struct drm_device *dev, unsigned long flags)
 	vgdev->dev = dev->dev;
 
 	spin_lock_init(&vgdev->display_info_lock);
-	spin_lock_init(&vgdev->ctx_id_idr_lock);
-	idr_init(&vgdev->ctx_id_idr);
-	spin_lock_init(&vgdev->resource_idr_lock);
-	idr_init(&vgdev->resource_idr);
+	ida_init(&vgdev->ctx_id_ida);
+	ida_init(&vgdev->resource_ida);
 	init_waitqueue_head(&vgdev->resp_wq);
 	virtio_gpu_init_vq(&vgdev->ctrlq, virtio_gpu_dequeue_ctrl_func);
 	virtio_gpu_init_vq(&vgdev->cursorq, virtio_gpu_dequeue_cursor_func);
diff --git a/drivers/gpu/drm/virtio/virtgpu_vq.c b/drivers/gpu/drm/virtio/virtgpu_vq.c
index 9eb96fb2c147..b35b5f2c056c 100644
--- a/drivers/gpu/drm/virtio/virtgpu_vq.c
+++ b/drivers/gpu/drm/virtio/virtgpu_vq.c
@@ -41,21 +41,13 @@
 void virtio_gpu_resource_id_get(struct virtio_gpu_device *vgdev,
 				uint32_t *resid)
 {
-	int handle;
-
-	idr_preload(GFP_KERNEL);
-	spin_lock(&vgdev->resource_idr_lock);
-	handle = idr_alloc(&vgdev->resource_idr, NULL, 1, 0, GFP_NOWAIT);
-	spin_unlock(&vgdev->resource_idr_lock);
-	idr_preload_end();
+	int handle = ida_simple_get(&vgdev->resource_ida, 1, 0, GFP_KERNEL);
 	*resid = handle;
 }
 
 void virtio_gpu_resource_id_put(struct virtio_gpu_device *vgdev, uint32_t id)
 {
-	spin_lock(&vgdev->resource_idr_lock);
-	idr_remove(&vgdev->resource_idr, id);
-	spin_unlock(&vgdev->resource_idr_lock);
+	ida_simple_remove(&vgdev->resource_ida, id);
 }
 
 void virtio_gpu_ctrl_ack(struct virtqueue *vq)
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
