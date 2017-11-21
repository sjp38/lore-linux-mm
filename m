Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D642F6B025E
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 17:51:17 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 192so14062169pgd.18
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 14:51:17 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id t22si12362473plj.482.2017.11.21.14.51.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 14:51:16 -0800 (PST)
Subject: [PATCH 1/2] mm,
 hugetlbfs: introduce ->split() to vm_operations_struct
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 21 Nov 2017 14:43:01 -0800
Message-ID: <151130418135.4029.6783191281930729710.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151130417573.4029.6745923267963684469.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151130417573.4029.6745923267963684469.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, stable@vger.kernel.org, linux-nvdimm@lists.01.org

The device-dax interface has similar constraints as hugetlbfs in that it
requires the munmap path to unmap in huge page aligned units.  Rather
than add more custom vma handling code in __split_vma() introduce a new
vm operation to perform this vma specific check.

Cc: <stable@vger.kernel.org>
Fixes: dee410792419 ("/dev/dax, core: file operations and dax-mmap")
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mm.h |    1 +
 mm/hugetlb.c       |    8 ++++++++
 mm/mmap.c          |    8 +++++---
 3 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ee073146aaa7..b3b6a7e313e9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -377,6 +377,7 @@ enum page_entry_size {
 struct vm_operations_struct {
 	void (*open)(struct vm_area_struct * area);
 	void (*close)(struct vm_area_struct * area);
+	int (*split)(struct vm_area_struct * area, unsigned long addr);
 	int (*mremap)(struct vm_area_struct * area);
 	int (*fault)(struct vm_fault *vmf);
 	int (*huge_fault)(struct vm_fault *vmf, enum page_entry_size pe_size);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 681b300185c0..698e8fb34031 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3125,6 +3125,13 @@ static void hugetlb_vm_op_close(struct vm_area_struct *vma)
 	}
 }
 
+static int hugetlb_vm_op_split(struct vm_area_struct *vma, unsigned long addr)
+{
+	if (addr & ~(huge_page_mask(hstate_vma(vma))))
+		return -EINVAL;
+	return 0;
+}
+
 /*
  * We cannot handle pagefaults against hugetlb pages at all.  They cause
  * handle_mm_fault() to try to instantiate regular-sized pages in the
@@ -3141,6 +3148,7 @@ const struct vm_operations_struct hugetlb_vm_ops = {
 	.fault = hugetlb_vm_op_fault,
 	.open = hugetlb_vm_op_open,
 	.close = hugetlb_vm_op_close,
+	.split = hugetlb_vm_op_split,
 };
 
 static pte_t make_huge_pte(struct vm_area_struct *vma, struct page *page,
diff --git a/mm/mmap.c b/mm/mmap.c
index 924839fac0e6..a4d546821214 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2555,9 +2555,11 @@ int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct vm_area_struct *new;
 	int err;
 
-	if (is_vm_hugetlb_page(vma) && (addr &
-					~(huge_page_mask(hstate_vma(vma)))))
-		return -EINVAL;
+	if (vma->vm_ops && vma->vm_ops->split) {
+		err = vma->vm_ops->split(vma, addr);
+		if (err)
+			return err;
+	}
 
 	new = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 	if (!new)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
