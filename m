Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 399716B03A6
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 14:58:44 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id x39so49661035qtb.20
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 11:58:44 -0700 (PDT)
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com. [209.85.220.172])
        by mx.google.com with ESMTPS id a68si12704284qkf.6.2017.04.03.11.58.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 11:58:43 -0700 (PDT)
Received: by mail-qk0-f172.google.com with SMTP id g195so50929715qke.2
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 11:58:43 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv3 10/22] staging: android: ion: Remove import interface
Date: Mon,  3 Apr 2017 11:57:52 -0700
Message-Id: <1491245884-15852-11-git-send-email-labbott@redhat.com>
In-Reply-To: <1491245884-15852-1-git-send-email-labbott@redhat.com>
References: <1491245884-15852-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org, Laurent Pinchart <laurent.pinchart@ideasonboard.com>

With the expansion of dma-buf and the move for Ion to be come just an
allocator, the import mechanism is mostly useless. There isn't a kernel
component to Ion anymore and handles are private to Ion. Remove this
interface.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 drivers/staging/android/ion/compat_ion.c |  1 -
 drivers/staging/android/ion/ion-ioctl.c  | 11 -----
 drivers/staging/android/ion/ion.c        | 76 --------------------------------
 drivers/staging/android/uapi/ion.h       |  9 ----
 4 files changed, 97 deletions(-)

diff --git a/drivers/staging/android/ion/compat_ion.c b/drivers/staging/android/ion/compat_ion.c
index 5b192ea..ae1ffc3 100644
--- a/drivers/staging/android/ion/compat_ion.c
+++ b/drivers/staging/android/ion/compat_ion.c
@@ -145,7 +145,6 @@ long compat_ion_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 	}
 	case ION_IOC_SHARE:
 	case ION_IOC_MAP:
-	case ION_IOC_IMPORT:
 		return filp->f_op->unlocked_ioctl(filp, cmd,
 						(unsigned long)compat_ptr(arg));
 	default:
diff --git a/drivers/staging/android/ion/ion-ioctl.c b/drivers/staging/android/ion/ion-ioctl.c
index 2b475bf..7b54eea 100644
--- a/drivers/staging/android/ion/ion-ioctl.c
+++ b/drivers/staging/android/ion/ion-ioctl.c
@@ -131,17 +131,6 @@ long ion_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 			ret = data.fd.fd;
 		break;
 	}
-	case ION_IOC_IMPORT:
-	{
-		struct ion_handle *handle;
-
-		handle = ion_import_dma_buf_fd(client, data.fd.fd);
-		if (IS_ERR(handle))
-			ret = PTR_ERR(handle);
-		else
-			data.handle.handle = handle->id;
-		break;
-	}
 	case ION_IOC_HEAP_QUERY:
 		ret = ion_query_heaps(client, &data.query);
 		break;
diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index 125c537..3d979ef5 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -274,24 +274,6 @@ int ion_handle_put(struct ion_handle *handle)
 	return ret;
 }
 
-static struct ion_handle *ion_handle_lookup(struct ion_client *client,
-					    struct ion_buffer *buffer)
-{
-	struct rb_node *n = client->handles.rb_node;
-
-	while (n) {
-		struct ion_handle *entry = rb_entry(n, struct ion_handle, node);
-
-		if (buffer < entry->buffer)
-			n = n->rb_left;
-		else if (buffer > entry->buffer)
-			n = n->rb_right;
-		else
-			return entry;
-	}
-	return ERR_PTR(-EINVAL);
-}
-
 struct ion_handle *ion_handle_get_by_id_nolock(struct ion_client *client,
 					       int id)
 {
@@ -1023,64 +1005,6 @@ int ion_share_dma_buf_fd(struct ion_client *client, struct ion_handle *handle)
 }
 EXPORT_SYMBOL(ion_share_dma_buf_fd);
 
-struct ion_handle *ion_import_dma_buf(struct ion_client *client,
-				      struct dma_buf *dmabuf)
-{
-	struct ion_buffer *buffer;
-	struct ion_handle *handle;
-	int ret;
-
-	/* if this memory came from ion */
-
-	if (dmabuf->ops != &dma_buf_ops) {
-		pr_err("%s: can not import dmabuf from another exporter\n",
-		       __func__);
-		return ERR_PTR(-EINVAL);
-	}
-	buffer = dmabuf->priv;
-
-	mutex_lock(&client->lock);
-	/* if a handle exists for this buffer just take a reference to it */
-	handle = ion_handle_lookup(client, buffer);
-	if (!IS_ERR(handle)) {
-		ion_handle_get(handle);
-		mutex_unlock(&client->lock);
-		goto end;
-	}
-
-	handle = ion_handle_create(client, buffer);
-	if (IS_ERR(handle)) {
-		mutex_unlock(&client->lock);
-		goto end;
-	}
-
-	ret = ion_handle_add(client, handle);
-	mutex_unlock(&client->lock);
-	if (ret) {
-		ion_handle_put(handle);
-		handle = ERR_PTR(ret);
-	}
-
-end:
-	return handle;
-}
-EXPORT_SYMBOL(ion_import_dma_buf);
-
-struct ion_handle *ion_import_dma_buf_fd(struct ion_client *client, int fd)
-{
-	struct dma_buf *dmabuf;
-	struct ion_handle *handle;
-
-	dmabuf = dma_buf_get(fd);
-	if (IS_ERR(dmabuf))
-		return ERR_CAST(dmabuf);
-
-	handle = ion_import_dma_buf(client, dmabuf);
-	dma_buf_put(dmabuf);
-	return handle;
-}
-EXPORT_SYMBOL(ion_import_dma_buf_fd);
-
 int ion_query_heaps(struct ion_client *client, struct ion_heap_query *query)
 {
 	struct ion_device *dev = client->dev;
diff --git a/drivers/staging/android/uapi/ion.h b/drivers/staging/android/uapi/ion.h
index 8ff471d..3a59044 100644
--- a/drivers/staging/android/uapi/ion.h
+++ b/drivers/staging/android/uapi/ion.h
@@ -185,15 +185,6 @@ struct ion_heap_query {
 #define ION_IOC_SHARE		_IOWR(ION_IOC_MAGIC, 4, struct ion_fd_data)
 
 /**
- * DOC: ION_IOC_IMPORT - imports a shared file descriptor
- *
- * Takes an ion_fd_data struct with the fd field populated with a valid file
- * descriptor obtained from ION_IOC_SHARE and returns the struct with the handle
- * filed set to the corresponding opaque handle.
- */
-#define ION_IOC_IMPORT		_IOWR(ION_IOC_MAGIC, 5, struct ion_fd_data)
-
-/**
  * DOC: ION_IOC_HEAP_QUERY - information about available heaps
  *
  * Takes an ion_heap_query structure and populates information about
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
