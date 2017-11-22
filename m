Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 10E6C6B027F
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:08:22 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 82so15506967pfp.5
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:08:22 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o18si14097408pgn.16.2017.11.22.13.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:20 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 58/62] drm: Remove qxl driver IDR locks
Date: Wed, 22 Nov 2017 13:07:35 -0800
Message-Id: <20171122210739.29916-59-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

By switching to the internal IDR lock, we can get rid of the idr_preload
calls.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/gpu/drm/qxl/qxl_cmd.c     | 26 +++++++-------------------
 drivers/gpu/drm/qxl/qxl_drv.h     |  2 --
 drivers/gpu/drm/qxl/qxl_kms.c     |  2 --
 drivers/gpu/drm/qxl/qxl_release.c | 12 +++---------
 4 files changed, 10 insertions(+), 32 deletions(-)

diff --git a/drivers/gpu/drm/qxl/qxl_cmd.c b/drivers/gpu/drm/qxl/qxl_cmd.c
index c0fb52c6d4ca..b1cecc38ef5f 100644
--- a/drivers/gpu/drm/qxl/qxl_cmd.c
+++ b/drivers/gpu/drm/qxl/qxl_cmd.c
@@ -451,37 +451,29 @@ int qxl_surface_id_alloc(struct qxl_device *qdev,
 	int idr_ret;
 	int count = 0;
 again:
-	idr_preload(GFP_ATOMIC);
-	spin_lock(&qdev->surf_id_idr_lock);
-	idr_ret = idr_alloc(&qdev->surf_id_idr, NULL, 1, 0, GFP_NOWAIT);
-	spin_unlock(&qdev->surf_id_idr_lock);
-	idr_preload_end();
+	idr_ret = idr_alloc(&qdev->surf_id_idr, NULL, 1, 0, GFP_ATOMIC);
 	if (idr_ret < 0)
 		return idr_ret;
 	handle = idr_ret;
 
 	if (handle >= qdev->rom->n_surfaces) {
 		count++;
-		spin_lock(&qdev->surf_id_idr_lock);
 		idr_remove(&qdev->surf_id_idr, handle);
-		spin_unlock(&qdev->surf_id_idr_lock);
 		qxl_reap_surface_id(qdev, 2);
 		goto again;
 	}
 	surf->surface_id = handle;
 
-	spin_lock(&qdev->surf_id_idr_lock);
+	idr_lock(&qdev->surf_id_idr);
 	qdev->last_alloced_surf_id = handle;
-	spin_unlock(&qdev->surf_id_idr_lock);
+	idr_unlock(&qdev->surf_id_idr);
 	return 0;
 }
 
 void qxl_surface_id_dealloc(struct qxl_device *qdev,
 			    uint32_t surface_id)
 {
-	spin_lock(&qdev->surf_id_idr_lock);
 	idr_remove(&qdev->surf_id_idr, surface_id);
-	spin_unlock(&qdev->surf_id_idr_lock);
 }
 
 int qxl_hw_surface_alloc(struct qxl_device *qdev,
@@ -534,9 +526,7 @@ int qxl_hw_surface_alloc(struct qxl_device *qdev,
 	qxl_release_fence_buffer_objects(release);
 
 	surf->hw_surf_alloc = true;
-	spin_lock(&qdev->surf_id_idr_lock);
 	idr_replace(&qdev->surf_id_idr, surf, surf->surface_id);
-	spin_unlock(&qdev->surf_id_idr_lock);
 	return 0;
 }
 
@@ -559,9 +549,7 @@ int qxl_hw_surface_dealloc(struct qxl_device *qdev,
 
 	surf->surf_create = NULL;
 	/* remove the surface from the idr, but not the surface id yet */
-	spin_lock(&qdev->surf_id_idr_lock);
 	idr_replace(&qdev->surf_id_idr, NULL, surf->surface_id);
-	spin_unlock(&qdev->surf_id_idr_lock);
 	surf->hw_surf_alloc = false;
 
 	id = surf->surface_id;
@@ -650,9 +638,9 @@ static int qxl_reap_surface_id(struct qxl_device *qdev, int max_to_reap)
 	mutex_lock(&qdev->surf_evict_mutex);
 again:
 
-	spin_lock(&qdev->surf_id_idr_lock);
+	idr_lock(&qdev->surf_id_idr);
 	start = qdev->last_alloced_surf_id + 1;
-	spin_unlock(&qdev->surf_id_idr_lock);
+	idr_unlock(&qdev->surf_id_idr);
 
 	for (i = start; i < start + qdev->rom->n_surfaces; i++) {
 		void *objptr;
@@ -661,9 +649,9 @@ static int qxl_reap_surface_id(struct qxl_device *qdev, int max_to_reap)
 		/* this avoids the case where the objects is in the
 		   idr but has been evicted half way - its makes
 		   the idr lookup atomic with the eviction */
-		spin_lock(&qdev->surf_id_idr_lock);
+		idr_lock(&qdev->surf_id_idr);
 		objptr = idr_find(&qdev->surf_id_idr, surfid);
-		spin_unlock(&qdev->surf_id_idr_lock);
+		idr_unlock(&qdev->surf_id_idr);
 
 		if (!objptr)
 			continue;
diff --git a/drivers/gpu/drm/qxl/qxl_drv.h b/drivers/gpu/drm/qxl/qxl_drv.h
index 08752c0ffb35..07378adbf4e8 100644
--- a/drivers/gpu/drm/qxl/qxl_drv.h
+++ b/drivers/gpu/drm/qxl/qxl_drv.h
@@ -255,7 +255,6 @@ struct qxl_device {
 	spinlock_t	release_lock;
 	struct idr	release_idr;
 	uint32_t	release_seqno;
-	spinlock_t release_idr_lock;
 	struct mutex	async_io_mutex;
 	unsigned int last_sent_io_cmd;
 
@@ -277,7 +276,6 @@ struct qxl_device {
 	struct mutex		update_area_mutex;
 
 	struct idr	surf_id_idr;
-	spinlock_t surf_id_idr_lock;
 	int last_alloced_surf_id;
 
 	struct mutex surf_evict_mutex;
diff --git a/drivers/gpu/drm/qxl/qxl_kms.c b/drivers/gpu/drm/qxl/qxl_kms.c
index c5716a0ca3b8..276a5b25ae8e 100644
--- a/drivers/gpu/drm/qxl/qxl_kms.c
+++ b/drivers/gpu/drm/qxl/qxl_kms.c
@@ -204,11 +204,9 @@ int qxl_device_init(struct qxl_device *qdev,
 			GFP_KERNEL);
 
 	idr_init(&qdev->release_idr);
-	spin_lock_init(&qdev->release_idr_lock);
 	spin_lock_init(&qdev->release_lock);
 
 	idr_init(&qdev->surf_id_idr);
-	spin_lock_init(&qdev->surf_id_idr_lock);
 
 	mutex_init(&qdev->async_io_mutex);
 
diff --git a/drivers/gpu/drm/qxl/qxl_release.c b/drivers/gpu/drm/qxl/qxl_release.c
index a6da6fa6ad58..c327b3441b63 100644
--- a/drivers/gpu/drm/qxl/qxl_release.c
+++ b/drivers/gpu/drm/qxl/qxl_release.c
@@ -142,12 +142,10 @@ qxl_release_alloc(struct qxl_device *qdev, int type,
 	release->surface_release_id = 0;
 	INIT_LIST_HEAD(&release->bos);
 
-	idr_preload(GFP_KERNEL);
-	spin_lock(&qdev->release_idr_lock);
-	handle = idr_alloc(&qdev->release_idr, release, 1, 0, GFP_NOWAIT);
+	handle = idr_alloc(&qdev->release_idr, release, 1, 0, GFP_KERNEL);
+	idr_lock(&qdev->release_idr);
 	release->base.seqno = ++qdev->release_seqno;
-	spin_unlock(&qdev->release_idr_lock);
-	idr_preload_end();
+	idr_unlock(&qdev->release_idr);
 	if (handle < 0) {
 		kfree(release);
 		*ret = NULL;
@@ -184,9 +182,7 @@ qxl_release_free(struct qxl_device *qdev,
 	if (release->surface_release_id)
 		qxl_surface_id_dealloc(qdev, release->surface_release_id);
 
-	spin_lock(&qdev->release_idr_lock);
 	idr_remove(&qdev->release_idr, release->id);
-	spin_unlock(&qdev->release_idr_lock);
 
 	if (release->base.ops) {
 		WARN_ON(list_empty(&release->bos));
@@ -392,9 +388,7 @@ struct qxl_release *qxl_release_from_id_locked(struct qxl_device *qdev,
 {
 	struct qxl_release *release;
 
-	spin_lock(&qdev->release_idr_lock);
 	release = idr_find(&qdev->release_idr, id);
-	spin_unlock(&qdev->release_idr_lock);
 	if (!release) {
 		DRM_ERROR("failed to find id in release_idr\n");
 		return NULL;
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
