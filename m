Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B51F66B0284
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:08:21 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id j16so17265669pgn.14
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:08:21 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id j4si11695580plb.812.2017.11.22.13.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:20 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 57/62] drm: Remove drm_syncobj_fd_to_handle
Date: Wed, 22 Nov 2017 13:07:34 -0800
Message-Id: <20171122210739.29916-58-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Now that the IDR handles its own locking, by removing our own lock, we
can also remove the idr_preload calls.

Also add a missing put call in a failure path.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/gpu/drm/drm_syncobj.c | 23 +++++------------------
 include/drm/drm_file.h        |  2 --
 2 files changed, 5 insertions(+), 20 deletions(-)

diff --git a/drivers/gpu/drm/drm_syncobj.c b/drivers/gpu/drm/drm_syncobj.c
index f776fc1cc543..fec56b26a0b6 100644
--- a/drivers/gpu/drm/drm_syncobj.c
+++ b/drivers/gpu/drm/drm_syncobj.c
@@ -68,14 +68,14 @@ struct drm_syncobj *drm_syncobj_find(struct drm_file *file_private,
 {
 	struct drm_syncobj *syncobj;
 
-	spin_lock(&file_private->syncobj_table_lock);
+	idr_lock(&file_private->syncobj_idr);
 
 	/* Check if we currently have a reference on the object */
 	syncobj = idr_find(&file_private->syncobj_idr, handle);
 	if (syncobj)
 		drm_syncobj_get(syncobj);
 
-	spin_unlock(&file_private->syncobj_table_lock);
+	idr_unlock(&file_private->syncobj_idr);
 
 	return syncobj;
 }
@@ -309,13 +309,7 @@ int drm_syncobj_get_handle(struct drm_file *file_private,
 	/* take a reference to put in the idr */
 	drm_syncobj_get(syncobj);
 
-	idr_preload(GFP_KERNEL);
-	spin_lock(&file_private->syncobj_table_lock);
-	ret = idr_alloc(&file_private->syncobj_idr, syncobj, 1, 0, GFP_NOWAIT);
-	spin_unlock(&file_private->syncobj_table_lock);
-
-	idr_preload_end();
-
+	ret = idr_alloc(&file_private->syncobj_idr, syncobj, 1, 0, GFP_KERNEL);
 	if (ret < 0) {
 		drm_syncobj_put(syncobj);
 		return ret;
@@ -346,9 +340,7 @@ static int drm_syncobj_destroy(struct drm_file *file_private,
 {
 	struct drm_syncobj *syncobj;
 
-	spin_lock(&file_private->syncobj_table_lock);
 	syncobj = idr_remove(&file_private->syncobj_idr, handle);
-	spin_unlock(&file_private->syncobj_table_lock);
 
 	if (!syncobj)
 		return -EINVAL;
@@ -449,14 +441,10 @@ static int drm_syncobj_fd_to_handle(struct drm_file *file_private,
 	/* take a reference to put in the idr */
 	drm_syncobj_get(syncobj);
 
-	idr_preload(GFP_KERNEL);
-	spin_lock(&file_private->syncobj_table_lock);
-	ret = idr_alloc(&file_private->syncobj_idr, syncobj, 1, 0, GFP_NOWAIT);
-	spin_unlock(&file_private->syncobj_table_lock);
-	idr_preload_end();
-
+	ret = idr_alloc(&file_private->syncobj_idr, syncobj, 1, 0, GFP_KERNEL);
 	if (ret < 0) {
 		fput(syncobj->file);
+		drm_syncobj_put(syncobj);
 		return ret;
 	}
 	*handle = ret;
@@ -527,7 +515,6 @@ void
 drm_syncobj_open(struct drm_file *file_private)
 {
 	idr_init(&file_private->syncobj_idr);
-	spin_lock_init(&file_private->syncobj_table_lock);
 }
 
 static int
diff --git a/include/drm/drm_file.h b/include/drm/drm_file.h
index dd3520d8ce60..dfabc20a5934 100644
--- a/include/drm/drm_file.h
+++ b/include/drm/drm_file.h
@@ -231,8 +231,6 @@ struct drm_file {
 
 	/** @syncobj_idr: Mapping of sync object handles to object pointers. */
 	struct idr syncobj_idr;
-	/** @syncobj_table_lock: Protects @syncobj_idr. */
-	spinlock_t syncobj_table_lock;
 
 	/** @filp: Pointer to the core file structure. */
 	struct file *filp;
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
