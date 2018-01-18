Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 19F2F6B0261
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 11:49:22 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u26so4191366pfi.3
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 08:49:22 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0065.outbound.protection.outlook.com. [104.47.37.65])
        by mx.google.com with ESMTPS id a19si7063755pfi.52.2018.01.18.08.49.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 18 Jan 2018 08:49:20 -0800 (PST)
From: Andrey Grodzovsky <andrey.grodzovsky@amd.com>
Subject: [PATCH 3/4] drm/gem: adjust per file OOM badness on handling buffers
Date: Thu, 18 Jan 2018 11:47:51 -0500
Message-ID: <1516294072-17841-4-git-send-email-andrey.grodzovsky@amd.com>
In-Reply-To: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Cc: Christian.Koenig@amd.com, Andrey Grodzovsky <andrey.grodzovsky@amd.com>

Large amounts of VRAM are usually not CPU accessible, so they are not mapped
into the processes address space. But since the device drivers usually support
swapping buffers from VRAM to system memory we can still run into an out of
memory situation when userspace starts to allocate to much.

This patch gives the OOM another hint which process is
holding how many resources.

Signed-off-by: Andrey Grodzovsky <andrey.grodzovsky@amd.com>
---
 drivers/gpu/drm/drm_file.c | 12 ++++++++++++
 drivers/gpu/drm/drm_gem.c  |  8 ++++++++
 include/drm/drm_file.h     |  4 ++++
 3 files changed, 24 insertions(+)

diff --git a/drivers/gpu/drm/drm_file.c b/drivers/gpu/drm/drm_file.c
index b3c6e99..626cc76 100644
--- a/drivers/gpu/drm/drm_file.c
+++ b/drivers/gpu/drm/drm_file.c
@@ -747,3 +747,15 @@ void drm_send_event(struct drm_device *dev, struct drm_pending_event *e)
 	spin_unlock_irqrestore(&dev->event_lock, irqflags);
 }
 EXPORT_SYMBOL(drm_send_event);
+
+long drm_oom_badness(struct file *f)
+{
+
+	struct drm_file *file_priv = f->private_data;
+
+	if (file_priv)
+		return atomic_long_read(&file_priv->f_oom_badness);
+
+	return 0;
+}
+EXPORT_SYMBOL(drm_oom_badness);
diff --git a/drivers/gpu/drm/drm_gem.c b/drivers/gpu/drm/drm_gem.c
index 01f8d94..ffbadc8 100644
--- a/drivers/gpu/drm/drm_gem.c
+++ b/drivers/gpu/drm/drm_gem.c
@@ -264,6 +264,9 @@ drm_gem_object_release_handle(int id, void *ptr, void *data)
 		drm_gem_remove_prime_handles(obj, file_priv);
 	drm_vma_node_revoke(&obj->vma_node, file_priv);
 
+	atomic_long_sub(obj->size >> PAGE_SHIFT,
+				&file_priv->f_oom_badness);
+
 	drm_gem_object_handle_put_unlocked(obj);
 
 	return 0;
@@ -299,6 +302,8 @@ drm_gem_handle_delete(struct drm_file *filp, u32 handle)
 	idr_remove(&filp->object_idr, handle);
 	spin_unlock(&filp->table_lock);
 
+	atomic_long_sub(obj->size >> PAGE_SHIFT, &filp->f_oom_badness);
+
 	return 0;
 }
 EXPORT_SYMBOL(drm_gem_handle_delete);
@@ -417,6 +422,9 @@ drm_gem_handle_create_tail(struct drm_file *file_priv,
 	}
 
 	*handlep = handle;
+
+	atomic_long_add(obj->size >> PAGE_SHIFT,
+				&file_priv->f_oom_badness);
 	return 0;
 
 err_revoke:
diff --git a/include/drm/drm_file.h b/include/drm/drm_file.h
index 0e0c868..ac3aa75 100644
--- a/include/drm/drm_file.h
+++ b/include/drm/drm_file.h
@@ -317,6 +317,8 @@ struct drm_file {
 
 	/* private: */
 	unsigned long lock_count; /* DRI1 legacy lock count */
+
+	atomic_long_t		f_oom_badness;
 };
 
 /**
@@ -378,4 +380,6 @@ void drm_event_cancel_free(struct drm_device *dev,
 void drm_send_event_locked(struct drm_device *dev, struct drm_pending_event *e);
 void drm_send_event(struct drm_device *dev, struct drm_pending_event *e);
 
+long drm_oom_badness(struct file *f);
+
 #endif /* _DRM_FILE_H_ */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
