Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CE8896B0009
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 22:58:14 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id j12so1295588pff.18
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 19:58:14 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id a6-v6si4013805plz.497.2018.03.01.19.58.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Mar 2018 19:58:13 -0800 (PST)
Subject: [PATCH v3 2/3] mm,
 hugetlbfs: introduce ->pagesize() to vm_operations_struct
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 01 Mar 2018 19:49:07 -0800
Message-ID: <151996254734.27922.15813097401404359642.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151996253609.27922.9983044853291257359.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151996253609.27922.9983044853291257359.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jane Chu <jane.chu@oracle.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org

When device-dax is operating in huge-page mode we want it to behave like
hugetlbfs and report the MMU page mapping size that is being enforced by
the vma. Similar to commit 31383c6865a5 "mm, hugetlbfs: introduce
->split() to vm_operations_struct" it would be messy to teach
vma_mmu_pagesize() about device-dax page mapping sizes in the same
(hstate) way that hugetlbfs communicates this attribute.  Instead, these
patches introduce a new ->pagesize() vm operation.

Reported-by: Jane Chu <jane.chu@oracle.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mm.h |    1 +
 mm/hugetlb.c       |   19 +++++++++++--------
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ad06d42adb1a..be0040c9f81b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -383,6 +383,7 @@ struct vm_operations_struct {
 	int (*huge_fault)(struct vm_fault *vmf, enum page_entry_size pe_size);
 	void (*map_pages)(struct vm_fault *vmf,
 			pgoff_t start_pgoff, pgoff_t end_pgoff);
+	unsigned long (*pagesize)(struct vm_area_struct * area);
 
 	/* notification that a previously read-only page is about to become
 	 * writable, if an error is returned it will cause a SIGBUS */
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index f9c4ea42b04a..aaafe5ebaa3e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -636,14 +636,9 @@ EXPORT_SYMBOL_GPL(linear_hugepage_index);
  */
 unsigned long vma_kernel_pagesize(struct vm_area_struct *vma)
 {
-	struct hstate *hstate;
-
-	if (!is_vm_hugetlb_page(vma))
-		return PAGE_SIZE;
-
-	hstate = hstate_vma(vma);
-
-	return 1UL << huge_page_shift(hstate);
+	if (vma->vm_ops && vma->vm_ops->pagesize)
+		return vma->vm_ops->pagesize(vma);
+	return PAGE_SIZE;
 }
 EXPORT_SYMBOL_GPL(vma_kernel_pagesize);
 
@@ -3150,6 +3145,13 @@ static int hugetlb_vm_op_split(struct vm_area_struct *vma, unsigned long addr)
 	return 0;
 }
 
+static unsigned long hugetlb_vm_op_pagesize(struct vm_area_struct *vma)
+{
+	struct hstate *hstate = hstate_vma(vma);
+
+	return 1UL << huge_page_shift(hstate);
+}
+
 /*
  * We cannot handle pagefaults against hugetlb pages at all.  They cause
  * handle_mm_fault() to try to instantiate regular-sized pages in the
@@ -3167,6 +3169,7 @@ const struct vm_operations_struct hugetlb_vm_ops = {
 	.open = hugetlb_vm_op_open,
 	.close = hugetlb_vm_op_close,
 	.split = hugetlb_vm_op_split,
+	.pagesize = hugetlb_vm_op_pagesize,
 };
 
 static pte_t make_huge_pte(struct vm_area_struct *vma, struct page *page,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
