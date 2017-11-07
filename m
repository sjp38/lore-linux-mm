Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 32CE66B0069
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 20:05:32 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id k7so14627920pga.8
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 17:05:32 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id s15si38949plk.45.2017.11.06.17.05.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 17:05:31 -0800 (PST)
Subject: [PATCH 1/3] mm: introduce get_user_pages_longterm
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 06 Nov 2017 16:57:16 -0800
Message-ID: <151001623591.16354.4902423177617232098.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151001623063.16354.14661493921524115663.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151001623063.16354.14661493921524115663.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, stable@vger.kernel.org, linux-kernel@vger.kernel.org

Until there is a solution to the dma-to-dax vs truncate problem it is
not safe to allow long standing memory registrations against
filesytem-dax vmas. Device-dax vmas do not have this problem and are
explicitly allowed.

This is temporary until a "memory registration with layout-lease"
mechanism can be implemented for the affected sub-systems (RDMA and
V4L2).

Cc: <stable@vger.kernel.org>
Suggested-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mm.h |    3 ++
 mm/gup.c           |   75 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 78 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8d9f52a84f77..0ffe93072abf 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1365,6 +1365,9 @@ long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 long get_user_pages(unsigned long start, unsigned long nr_pages,
 			    unsigned int gup_flags, struct page **pages,
 			    struct vm_area_struct **vmas);
+long get_user_pages_longterm(unsigned long start, unsigned long nr_pages,
+			    unsigned int gup_flags, struct page **pages,
+			    struct vm_area_struct **vmas);
 long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 		    unsigned int gup_flags, struct page **pages, int *locked);
 long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
diff --git a/mm/gup.c b/mm/gup.c
index b2b4d4263768..6c913731acad 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1095,6 +1095,81 @@ long get_user_pages(unsigned long start, unsigned long nr_pages,
 }
 EXPORT_SYMBOL(get_user_pages);
 
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
+		struct vm_area_struct **vmas)
+{
+	struct vm_area_struct **__vmas = vmas;
+	struct vm_area_struct *vma_prev = NULL;
+	long rc, i;
+
+	if (!pages)
+		return -EINVAL;
+
+	if (!vmas && IS_ENABLED(CONFIG_FS_DAX)) {
+		__vmas = kzalloc(sizeof(struct vm_area_struct *) * nr_pages,
+				GFP_KERNEL);
+		if (!__vmas)
+			return -ENOMEM;
+	}
+
+	rc = get_user_pages(start, nr_pages, gup_flags, pages, __vmas);
+
+	/* skip scan for fs-dax vmas if they are compile time disabled */
+	if (!IS_ENABLED(CONFIG_FS_DAX))
+		goto out;
+
+	for (i = 0; i < rc; i++) {
+		struct inode *inode;
+		struct vm_area_struct *vma = __vmas[i];
+
+		if (vma == vma_prev)
+			continue;
+		vma_prev = vma;
+
+		if (!vma_is_dax(vma))
+			continue;
+		inode = file_inode(vma->vm_file);
+
+		/* device-dax is safe for longterm... */
+		inode = file_inode(vma->vm_file);
+		if (inode->i_mode == S_IFCHR)
+			continue;
+
+		/* ...filesystem-dax is not. */
+		break;
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
+	if (vmas != __vmas)
+		kfree(__vmas);
+	return rc;
+}
+EXPORT_SYMBOL(get_user_pages_longterm);
+
 /**
  * populate_vma_page_range() -  populate a range of pages in the vma.
  * @vma:   target vma

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
