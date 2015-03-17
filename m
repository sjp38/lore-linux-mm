Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id DD8986B006E
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 07:57:06 -0400 (EDT)
Received: by wetk59 with SMTP id k59so5704583wet.3
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 04:57:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wc10si2760222wic.102.2015.03.17.04.56.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Mar 2015 04:56:59 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 4/9] vb2: Provide helpers for mapping virtual addresses
Date: Tue, 17 Mar 2015 12:56:34 +0100
Message-Id: <1426593399-6549-5-git-send-email-jack@suse.cz>
In-Reply-To: <1426593399-6549-1-git-send-email-jack@suse.cz>
References: <1426593399-6549-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-media@vger.kernel.org
Cc: Hans Verkuil <hans.verkuil@cisco.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>, Jan Kara <jack@suse.cz>

Provide simple helper functions to map virtual address range into an
array of pfns.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/media/v4l2-core/videobuf2-memops.c | 57 ++++++++++++++++++++++++++++++
 include/media/videobuf2-memops.h           |  4 +++
 2 files changed, 61 insertions(+)

diff --git a/drivers/media/v4l2-core/videobuf2-memops.c b/drivers/media/v4l2-core/videobuf2-memops.c
index 81c1ad8b2cf1..80ade22b920c 100644
--- a/drivers/media/v4l2-core/videobuf2-memops.c
+++ b/drivers/media/v4l2-core/videobuf2-memops.c
@@ -137,6 +137,63 @@ int vb2_get_contig_userptr(unsigned long vaddr, unsigned long size,
 EXPORT_SYMBOL_GPL(vb2_get_contig_userptr);
 
 /**
+ * vb2_create_pfnvec() - map virtual addresses to pfns
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
+struct pinned_pfns *vb2_create_pfnvec(unsigned long start, unsigned long length,
+				      bool write)
+{
+	int ret;
+	unsigned long first, last;
+	unsigned long nr;
+	struct pinned_pfns *pfns;
+
+	first = start >> PAGE_SHIFT;
+	last = (start + length - 1) >> PAGE_SHIFT;
+	nr = last - first + 1;
+	pfns = pfns_vector_create(nr);
+	if (!pfns)
+		return ERR_PTR(-ENOMEM);
+	ret = get_vaddr_pfns(start, nr, write, 1, pfns);
+	if (ret < 0)
+		goto out_destroy;
+	/* We accept only complete set of PFNs */
+	if (ret != nr) {
+		ret = -EFAULT;
+		goto out_release;
+	}
+	return pfns;
+out_release:
+	put_vaddr_pfns(pfns);
+out_destroy:
+	pfns_vector_destroy(pfns);
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL(vb2_create_pfnvec);
+
+/**
+ * vb2_destroy_pfnvec() - release vector of mapped pfns
+ * @pfns:	vector of pfns to release
+ *
+ * This releases references to all pages in the vector @pfns (if corresponding
+ * pfns are backed by pages) and frees the passed vector.
+ */
+void vb2_destroy_pfnvec(struct pinned_pfns *pfns)
+{
+	put_vaddr_pfns(pfns);
+	pfns_vector_destroy(pfns);
+}
+EXPORT_SYMBOL(vb2_destroy_pfnvec);
+
+/**
  * vb2_common_vm_open() - increase refcount of the vma
  * @vma:	virtual memory region for the mapping
  *
diff --git a/include/media/videobuf2-memops.h b/include/media/videobuf2-memops.h
index f05444ca8c0c..868f9c1cd92d 100644
--- a/include/media/videobuf2-memops.h
+++ b/include/media/videobuf2-memops.h
@@ -15,6 +15,7 @@
 #define _MEDIA_VIDEOBUF2_MEMOPS_H
 
 #include <media/videobuf2-core.h>
+#include <linux/mm.h>
 
 /**
  * vb2_vmarea_handler - common vma refcount tracking handler
@@ -36,5 +37,8 @@ int vb2_get_contig_userptr(unsigned long vaddr, unsigned long size,
 struct vm_area_struct *vb2_get_vma(struct vm_area_struct *vma);
 void vb2_put_vma(struct vm_area_struct *vma);
 
+struct pinned_pfns *vb2_create_pfnvec(unsigned long start, unsigned long length,
+				      bool write);
+void vb2_destroy_pfnvec(struct pinned_pfns *pfns);
 
 #endif
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
