Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id CCB4B6B0255
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 10:56:03 -0400 (EDT)
Received: by wiga1 with SMTP id a1so72042359wig.0
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 07:56:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fx5si13880753wib.35.2015.07.13.07.55.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Jul 2015 07:55:58 -0700 (PDT)
From: Jan Kara <jack@suse.com>
Subject: [PATCH 4/9] vb2: Provide helpers for mapping virtual addresses
Date: Mon, 13 Jul 2015 16:55:46 +0200
Message-Id: <1436799351-21975-5-git-send-email-jack@suse.com>
In-Reply-To: <1436799351-21975-1-git-send-email-jack@suse.com>
References: <1436799351-21975-1-git-send-email-jack@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hans Verkuil <hverkuil@xs4all.nl>
Cc: linux-media@vger.kernel.org, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, linux-samsung-soc@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>

From: Jan Kara <jack@suse.cz>

Provide simple helper functions to map virtual address range into an
array of pfns / pages.

Acked-by: Marek Szyprowski <m.szyprowski@samsung.com>
Tested-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/media/v4l2-core/Kconfig            |  1 +
 drivers/media/v4l2-core/videobuf2-memops.c | 58 ++++++++++++++++++++++++++++++
 include/media/videobuf2-memops.h           |  5 +++
 3 files changed, 64 insertions(+)

diff --git a/drivers/media/v4l2-core/Kconfig b/drivers/media/v4l2-core/Kconfig
index b4b022933e29..82876a67f144 100644
--- a/drivers/media/v4l2-core/Kconfig
+++ b/drivers/media/v4l2-core/Kconfig
@@ -84,6 +84,7 @@ config VIDEOBUF2_CORE
 
 config VIDEOBUF2_MEMOPS
 	tristate
+	select FRAME_VECTOR
 
 config VIDEOBUF2_DMA_CONTIG
 	tristate
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
