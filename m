Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id A82966B0075
	for <linux-mm@kvack.org>; Wed,  6 May 2015 03:28:30 -0400 (EDT)
Received: by wgiu9 with SMTP id u9so1705056wgi.3
        for <linux-mm@kvack.org>; Wed, 06 May 2015 00:28:30 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ej3si351233wib.116.2015.05.06.00.28.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 May 2015 00:28:25 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 4/9] vb2: Provide helpers for mapping virtual addresses
Date: Wed,  6 May 2015 09:28:11 +0200
Message-Id: <1430897296-5469-5-git-send-email-jack@suse.cz>
In-Reply-To: <1430897296-5469-1-git-send-email-jack@suse.cz>
References: <1430897296-5469-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-media@vger.kernel.org, Hans Verkuil <hverkuil@xs4all.nl>, dri-devel@lists.freedesktop.org, Pawel Osciak <pawel@osciak.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, mgorman@suse.de, Marek Szyprowski <m.szyprowski@samsung.com>, linux-samsung-soc@vger.kernel.org, Jan Kara <jack@suse.cz>

Provide simple helper functions to map virtual address range into an
array of pfns / pages.

Acked-by: Marek Szyprowski <m.szyprowski@samsung.com>
Tested-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/media/v4l2-core/videobuf2-memops.c | 58 ++++++++++++++++++++++++++++++
 include/media/videobuf2-memops.h           |  5 +++
 2 files changed, 63 insertions(+)

diff --git a/drivers/media/v4l2-core/videobuf2-memops.c b/drivers/media/v4l2-core/videobuf2-memops.c
index 81c1ad8b2cf1..0ec186d41b9b 100644
--- a/drivers/media/v4l2-core/videobuf2-memops.c
+++ b/drivers/media/v4l2-core/videobuf2-memops.c
@@ -137,6 +137,64 @@ int vb2_get_contig_userptr(unsigned long vaddr, unsigned long size,
 EXPORT_SYMBOL_GPL(vb2_get_contig_userptr);
 
 /**
+ * vb2_create_framevec() - map virtual addresses to pfns
+ * @start:	Virtual user address where we start mapping
+ * @length:	Length of a range to map
+ * @write:	Should we map for writing into the area
+ *
+ * This function allocates and fills in a vector with pfns corresponding to
+ * virtual address range passed in arguments. If pfns have corresponding pages,
+ * page references are also grabbed to pin pages in memory. The function
+ * returns pointer to the vector on success and error pointer in case of
+ * failure. Returned vector needs to be freed via vb2_destroy_pfnvec().
+ */
+struct frame_vector *vb2_create_framevec(unsigned long start,
+					 unsigned long length,
+					 bool write)
+{
+	int ret;
+	unsigned long first, last;
+	unsigned long nr;
+	struct frame_vector *vec;
+
+	first = start >> PAGE_SHIFT;
+	last = (start + length - 1) >> PAGE_SHIFT;
+	nr = last - first + 1;
+	vec = frame_vector_create(nr);
+	if (!vec)
+		return ERR_PTR(-ENOMEM);
+	ret = get_vaddr_frames(start, nr, write, 1, vec);
+	if (ret < 0)
+		goto out_destroy;
+	/* We accept only complete set of PFNs */
+	if (ret != nr) {
+		ret = -EFAULT;
+		goto out_release;
+	}
+	return vec;
+out_release:
+	put_vaddr_frames(vec);
+out_destroy:
+	frame_vector_destroy(vec);
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL(vb2_create_framevec);
+
+/**
+ * vb2_destroy_framevec() - release vector of mapped pfns
+ * @vec:	vector of pfns / pages to release
+ *
+ * This releases references to all pages in the vector @vec (if corresponding
+ * pfns are backed by pages) and frees the passed vector.
+ */
+void vb2_destroy_framevec(struct frame_vector *vec)
+{
+	put_vaddr_frames(vec);
+	frame_vector_destroy(vec);
+}
+EXPORT_SYMBOL(vb2_destroy_framevec);
+
+/**
  * vb2_common_vm_open() - increase refcount of the vma
  * @vma:	virtual memory region for the mapping
  *
diff --git a/include/media/videobuf2-memops.h b/include/media/videobuf2-memops.h
index f05444ca8c0c..2f0564ff5f31 100644
--- a/include/media/videobuf2-memops.h
+++ b/include/media/videobuf2-memops.h
@@ -15,6 +15,7 @@
 #define _MEDIA_VIDEOBUF2_MEMOPS_H
 
 #include <media/videobuf2-core.h>
+#include <linux/mm.h>
 
 /**
  * vb2_vmarea_handler - common vma refcount tracking handler
@@ -36,5 +37,9 @@ int vb2_get_contig_userptr(unsigned long vaddr, unsigned long size,
 struct vm_area_struct *vb2_get_vma(struct vm_area_struct *vma);
 void vb2_put_vma(struct vm_area_struct *vma);
 
+struct frame_vector *vb2_create_framevec(unsigned long start,
+					 unsigned long length,
+					 bool write);
+void vb2_destroy_framevec(struct frame_vector *vec);
 
 #endif
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
