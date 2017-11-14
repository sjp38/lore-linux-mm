Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4BC5E6B0069
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 15:04:52 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 70so10172034pgf.5
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 12:04:52 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id e4si16284597pgf.23.2017.11.14.12.04.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Nov 2017 12:04:50 -0800 (PST)
Subject: [PATCH v2 1/4] mm: introduce get_user_pages_longterm
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 14 Nov 2017 11:56:34 -0800
Message-ID: <151068939435.7446.13560129395419350737.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151068938905.7446.12333914805308312313.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151068938905.7446.12333914805308312313.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, stable@vger.kernel.org, linux-nvdimm@lists.01.org

Until there is a solution to the dma-to-dax vs truncate problem it is
not safe to allow long standing memory registrations against
filesytem-dax vmas. Device-dax vmas do not have this problem and are
explicitly allowed.

This is temporary until a "memory registration with layout-lease"
mechanism can be implemented for the affected sub-systems (RDMA and
V4L2).

Cc: <stable@vger.kernel.org>
Fixes: 3565fce3a659 ("mm, x86: get_user_pages() for dax mappings")
Suggested-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/fs.h |   14 +++++++++++
 include/linux/mm.h |   13 +++++++++++
 mm/gup.c           |   64 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 91 insertions(+)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 57added3201d..0bacccc9461e 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -3175,6 +3175,20 @@ static inline bool vma_is_dax(struct vm_area_struct *vma)
 	return vma->vm_file && IS_DAX(vma->vm_file->f_mapping->host);
 }
 
+static inline bool vma_is_fsdax(struct vm_area_struct *vma)
+{
+	struct inode *inode;
+
+	if (!vma->vm_file)
+		return false;
+	if (!vma_is_dax(vma))
+		return false;
+	inode = file_inode(vma->vm_file);
+	if (inode->i_mode == S_IFCHR)
+		return false; /* device-dax */
+	return true;
+}
+
 static inline int iocb_flags(struct file *file)
 {
 	int res = 0;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8d9f52a84f77..34ff8830f717 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1369,6 +1369,19 @@ long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 		    unsigned int gup_flags, struct page **pages, int *locked);
 long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 		    struct page **pages, unsigned int gup_flags);
+#ifdef CONFIG_FS_DAX
+long get_user_pages_longterm(unsigned long start, unsigned long nr_pages,
+			    unsigned int gup_flags, struct page **pages,
+			    struct vm_area_struct **vmas);
+#else
+static inline long get_user_pages_longterm(unsigned long start,
+		unsigned long nr_pages, unsigned int gup_flags,
+		struct page **pages, struct vm_area_struct **vmas)
+{
+	return get_user_pages(start, nr_pages, gup_flags, pages, vmas);
+}
+#endif /* CONFIG_FS_DAX */
+
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages);
 
diff --git a/mm/gup.c b/mm/gup.c
index b2b4d4263768..ad9d13987f14 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1095,6 +1095,70 @@ long get_user_pages(unsigned long start, unsigned long nr_pages,
 }
 EXPORT_SYMBOL(get_user_pages);
 
+#ifdef CONFIG_FS_DAX
+/*
+ * This is the same as get_user_pages() in that it assumes we are
+ * operating on the current task's mm, but it goes further to validate
+ * that the vmas associated with the address range are suitable for
+ * longterm elevated page reference counts. For example, filesystem-dax
+ * mappings are subject to the lifetime enforced by the filesystem and
+ * we need guarantees that longterm users like RDMA and V4L2 only
+ * establish mappings that have a kernel enforced revocation mechanism.
+ *
+ * "longterm" == userspace controlled elevated page count lifetime.
+ * Contrast this to iov_iter_get_pages() usages which are transient.
+ */
+long get_user_pages_longterm(unsigned long start, unsigned long nr_pages,
+		unsigned int gup_flags, struct page **pages,
+		struct vm_area_struct **vmas_arg)
+{
+	struct vm_area_struct **vmas = vmas_arg;
+	struct vm_area_struct *vma_prev = NULL;
+	long rc, i;
+
+	if (!pages)
+		return -EINVAL;
+
+	if (!vmas) {
+		vmas = kzalloc(sizeof(struct vm_area_struct *) * nr_pages,
+				GFP_KERNEL);
+		if (!vmas)
+			return -ENOMEM;
+	}
+
+	rc = get_user_pages(start, nr_pages, gup_flags, pages, vmas);
+
+	for (i = 0; i < rc; i++) {
+		struct vm_area_struct *vma = vmas[i];
+
+		if (vma == vma_prev)
+			continue;
+
+		vma_prev = vma;
+
+		if (vma_is_fsdax(vma))
+			break;
+	}
+
+	/*
+	 * Either get_user_pages() failed, or the vma validation
+	 * succeeded, in either case we don't need to put_page() before
+	 * returning.
+	 */
+	if (i >= rc)
+		goto out;
+
+	for (i = 0; i < rc; i++)
+		put_page(pages[i]);
+	rc = -EOPNOTSUPP;
+out:
+	if (vmas != vmas_arg)
+		kfree(vmas);
+	return rc;
+}
+EXPORT_SYMBOL(get_user_pages_longterm);
+#endif /* CONFIG_FS_DAX */
+
 /**
  * populate_vma_page_range() -  populate a range of pages in the vma.
  * @vma:   target vma

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
