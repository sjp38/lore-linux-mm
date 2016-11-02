Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 074F26B02A1
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:34:11 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id i34so24641864qkh.1
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:34:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z187si1945359qka.18.2016.11.02.12.34.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:10 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 14/33] userfaultfd: hugetlbfs: add hugetlb_mcopy_atomic_pte for userfaultfd support
Date: Wed,  2 Nov 2016 20:33:46 +0100
Message-Id: <1478115245-32090-15-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

From: Mike Kravetz <mike.kravetz@oracle.com>

hugetlb_mcopy_atomic_pte is the low level routine that implements
the userfaultfd UFFDIO_COPY command.  It is based on the existing
mcopy_atomic_pte routine with modifications for huge pages.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/hugetlb.h |  8 ++++-
 mm/hugetlb.c            | 81 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 88 insertions(+), 1 deletion(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 48c76d6..fc27b66 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -81,6 +81,11 @@ void hugetlb_show_meminfo(void);
 unsigned long hugetlb_total_pages(void);
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags);
+int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm, pte_t *dst_pte,
+				struct vm_area_struct *dst_vma,
+				unsigned long dst_addr,
+				unsigned long src_addr,
+				struct page **pagep);
 int hugetlb_reserve_pages(struct inode *inode, long from, long to,
 						struct vm_area_struct *vma,
 						vm_flags_t vm_flags);
@@ -149,6 +154,8 @@ static inline void hugetlb_show_meminfo(void)
 #define is_hugepage_only_range(mm, addr, len)	0
 #define hugetlb_free_pgd_range(tlb, addr, end, floor, ceiling) ({BUG(); 0; })
 #define hugetlb_fault(mm, vma, addr, flags)	({ BUG(); 0; })
+#define hugetlb_mcopy_atomic_pte(dst_mm, dst_pte, dst_vma, dst_addr, \
+				src_addr, pagep)	({ BUG(); 0; })
 #define huge_pte_offset(mm, address)	0
 static inline int dequeue_hwpoisoned_huge_page(struct page *page)
 {
@@ -272,7 +279,6 @@ static inline bool is_file_hugepages(struct file *file)
 	return is_file_shm_hugepages(file);
 }
 
-
 #else /* !CONFIG_HUGETLBFS */
 
 #define is_file_hugepages(file)			false
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ec49d9e..baf7fd4 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3857,6 +3857,87 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return ret;
 }
 
+/*
+ * Used by userfaultfd UFFDIO_COPY.  Based on mcopy_atomic_pte with
+ * modifications for huge pages.
+ */
+int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
+			    pte_t *dst_pte,
+			    struct vm_area_struct *dst_vma,
+			    unsigned long dst_addr,
+			    unsigned long src_addr,
+			    struct page **pagep)
+{
+	struct hstate *h = hstate_vma(dst_vma);
+	pte_t _dst_pte;
+	spinlock_t *ptl;
+	int ret;
+	struct page *page;
+
+	if (!*pagep) {
+		ret = -ENOMEM;
+		page = alloc_huge_page(dst_vma, dst_addr, 0);
+		if (IS_ERR(page))
+			goto out;
+
+		ret = copy_huge_page_from_user(page,
+						(const void __user *) src_addr,
+						pages_per_huge_page(h));
+
+		/* fallback to copy_from_user outside mmap_sem */
+		if (unlikely(ret)) {
+			ret = -EFAULT;
+			*pagep = page;
+			/* don't free the page */
+			goto out;
+		}
+	} else {
+		page = *pagep;
+		*pagep = NULL;
+	}
+
+	/*
+	 * The memory barrier inside __SetPageUptodate makes sure that
+	 * preceding stores to the page contents become visible before
+	 * the set_pte_at() write.
+	 */
+	__SetPageUptodate(page);
+	set_page_huge_active(page);
+
+	ptl = huge_pte_lockptr(h, dst_mm, dst_pte);
+	spin_lock(ptl);
+
+	ret = -EEXIST;
+	if (!huge_pte_none(huge_ptep_get(dst_pte)))
+		goto out_release_unlock;
+
+	ClearPagePrivate(page);
+	hugepage_add_new_anon_rmap(page, dst_vma, dst_addr);
+
+	_dst_pte = make_huge_pte(dst_vma, page, dst_vma->vm_flags & VM_WRITE);
+	if (dst_vma->vm_flags & VM_WRITE)
+		_dst_pte = huge_pte_mkdirty(_dst_pte);
+	_dst_pte = pte_mkyoung(_dst_pte);
+
+	set_huge_pte_at(dst_mm, dst_addr, dst_pte, _dst_pte);
+
+	(void)huge_ptep_set_access_flags(dst_vma, dst_addr, dst_pte, _dst_pte,
+					dst_vma->vm_flags & VM_WRITE);
+	hugetlb_count_add(pages_per_huge_page(h), dst_mm);
+
+	/* No need to invalidate - it was non-present before */
+	update_mmu_cache(dst_vma, dst_addr, dst_pte);
+
+	spin_unlock(ptl);
+	ret = 0;
+out:
+	return ret;
+out_release_unlock:
+	spin_unlock(ptl);
+	put_page(page);
+	goto out;
+}
+
 long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			 struct page **pages, struct vm_area_struct **vmas,
 			 unsigned long *position, unsigned long *nr_pages,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
