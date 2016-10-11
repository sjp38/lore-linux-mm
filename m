Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75E7F280251
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 19:50:49 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e6so26293274pfk.2
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 16:50:49 -0700 (PDT)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id f2si5128011pad.343.2016.10.11.16.50.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 16:50:48 -0700 (PDT)
Received: by mail-pf0-x22b.google.com with SMTP id 128so9709557pfz.0
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 16:50:48 -0700 (PDT)
From: Ruchi Kandoi <kandoiruchi@google.com>
Subject: [RFC 6/6] drivers: staging: ion: add ION_IOC_TAG ioctl
Date: Tue, 11 Oct 2016 16:50:10 -0700
Message-Id: <1476229810-26570-7-git-send-email-kandoiruchi@google.com>
In-Reply-To: <1476229810-26570-1-git-send-email-kandoiruchi@google.com>
References: <1476229810-26570-1-git-send-email-kandoiruchi@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kandoiruchi@google.com, gregkh@linuxfoundation.org, arve@android.com, riandrews@android.com, sumit.semwal@linaro.org, arnd@arndb.de, labbott@redhat.com, viro@zeniv.linux.org.uk, jlayton@poochiereds.net, bfields@fieldses.org, mingo@redhat.com, peterz@infradead.org, akpm@linux-foundation.org, keescook@chromium.org, mhocko@suse.com, oleg@redhat.com, john.stultz@linaro.org, mguzik@redhat.com, jdanis@google.com, adobriyan@gmail.com, ghackmann@google.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, dave.hansen@linux.intel.com, dan.j.williams@intel.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, luto@kernel.org, tj@kernel.org, vdavydov.dev@gmail.com, ebiederm@xmission.com, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

From: Greg Hackmann <ghackmann@google.com>

ION_IOC_TAG provides a userspace interface for tagging buffers with
their memtrack usage after allocation.

Signed-off-by: Ruchi Kandoi <kandoiruchi@google.com>
---
 drivers/staging/android/ion/ion-ioctl.c | 17 +++++++++++++++++
 drivers/staging/android/uapi/ion.h      | 25 +++++++++++++++++++++++++
 2 files changed, 42 insertions(+)

diff --git a/drivers/staging/android/ion/ion-ioctl.c b/drivers/staging/android/ion/ion-ioctl.c
index 7e7431d..8745a85 100644
--- a/drivers/staging/android/ion/ion-ioctl.c
+++ b/drivers/staging/android/ion/ion-ioctl.c
@@ -28,6 +28,7 @@ union ion_ioctl_arg {
 	struct ion_handle_data handle;
 	struct ion_custom_data custom;
 	struct ion_heap_query query;
+	struct ion_tag_data tag;
 };
 
 static int validate_ioctl_arg(unsigned int cmd, union ion_ioctl_arg *arg)
@@ -162,6 +163,22 @@ long ion_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 	case ION_IOC_HEAP_QUERY:
 		ret = ion_query_heaps(client, &data.query);
 		break;
+	case ION_IOC_TAG:
+	{
+#ifdef CONFIG_MEMTRACK
+		struct ion_handle *handle;
+
+		handle = ion_handle_get_by_id(client, data.tag.handle);
+		if (IS_ERR(handle))
+			return PTR_ERR(handle);
+		data.tag.tag[sizeof(data.tag.tag) - 1] = 0;
+		memtrack_buffer_set_tag(&handle->buffer->memtrack_buffer,
+					data.tag.tag);
+#else
+		ret = -ENOTTY;
+#endif
+		break;
+	}
 	default:
 		return -ENOTTY;
 	}
diff --git a/drivers/staging/android/uapi/ion.h b/drivers/staging/android/uapi/ion.h
index 14cd873..4c26196 100644
--- a/drivers/staging/android/uapi/ion.h
+++ b/drivers/staging/android/uapi/ion.h
@@ -115,6 +115,22 @@ struct ion_handle_data {
 	ion_user_handle_t handle;
 };
 
+#define ION_MAX_TAG_LEN 32
+
+/**
+ * struct ion_fd_data - metadata passed from userspace for a handle
+ * @handle:	a handle
+ * @tag: a string describing the buffer
+ *
+ * For ION_IOC_TAG userspace populates the handle field with
+ * the handle returned from ion alloc and type contains the memtrack_type which
+ * accurately describes the usage for the memory.
+ */
+struct ion_tag_data {
+	ion_user_handle_t handle;
+	char tag[ION_MAX_TAG_LEN];
+};
+
 /**
  * struct ion_custom_data - metadata passed to/from userspace for a custom ioctl
  * @cmd:	the custom ioctl function to call
@@ -217,6 +233,15 @@ struct ion_heap_query {
 #define ION_IOC_SYNC		_IOWR(ION_IOC_MAGIC, 7, struct ion_fd_data)
 
 /**
+ * DOC: ION_IOC_TAG - adds a memtrack descriptor tag to memory
+ *
+ * Takes an ion_tag_data struct with the type field populated with a
+ * memtrack_type and handle populated with a valid opaque handle. The
+ * memtrack_type should accurately define the usage for the memory.
+ */
+#define ION_IOC_TAG		_IOWR(ION_IOC_MAGIC, 8, struct ion_tag_data)
+
+/**
  * DOC: ION_IOC_CUSTOM - call architecture specific ion ioctl
  *
  * Takes the argument of the architecture specific ioctl to call and
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
