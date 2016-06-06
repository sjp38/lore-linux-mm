Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0024F6B0260
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 13:53:26 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 5so37648397ioy.2
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 10:53:25 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id t9si13644067ita.40.2016.06.06.10.53.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 10:53:22 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 3/6] mm/userfaultfd: add __mcopy_atomic_hugetlb for huge page UFFDIO_COPY
Date: Mon,  6 Jun 2016 10:45:28 -0700
Message-Id: <1465235131-6112-4-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1465235131-6112-1-git-send-email-mike.kravetz@oracle.com>
References: <1465235131-6112-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

__mcopy_atomic_hugetlb performs the UFFDIO_COPY operation for huge
pages.  It is based on the existing __mcopy_atomic routine for normal
pages.  Unlike normal pages, there is no huge page support for the
UFFDIO_ZEROPAGE operation.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/userfaultfd.c | 179 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 179 insertions(+)

diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index af817e5..c006f46 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -14,6 +14,8 @@
 #include <linux/swapops.h>
 #include <linux/userfaultfd_k.h>
 #include <linux/mmu_notifier.h>
+#include <linux/hugetlb.h>
+#include <linux/pagemap.h>
 #include <asm/tlbflush.h>
 #include "internal.h"
 
@@ -139,6 +141,176 @@ static pmd_t *mm_alloc_pmd(struct mm_struct *mm, unsigned long address)
 	return pmd;
 }
 
+
+#ifdef CONFIG_HUGETLB_PAGE
+/*
+ * __mcopy_atomic processing for HUGETLB vmas.  Note that this routine is
+ * called with mmap_sem held, it will release mmap_sem before returning.
+ */
+static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
+					      struct vm_area_struct *dst_vma,
+					      unsigned long dst_start,
+					      unsigned long src_start,
+					      unsigned long len,
+					      bool zeropage)
+{
+	ssize_t err;
+	pte_t *dst_pte;
+	unsigned long src_addr, dst_addr;
+	long copied;
+	struct page *page;
+	struct hstate *h;
+	unsigned long vma_hpagesize;
+	pgoff_t idx;
+	u32 hash;
+	struct address_space *mapping;
+
+	/*
+	 * There is no default zero huge page for all huge page sizes as
+	 * supported by hugetlb.  A PMD_SIZE huge pages may exist as used
+	 * by THP.  Since we can not reliably insert a zero page, this
+	 * feature is not supported.
+	 */
+	if (zeropage)
+		return -EINVAL;
+
+	src_addr = src_start;
+	dst_addr = dst_start;
+	copied = 0;
+	page = NULL;
+	vma_hpagesize = vma_kernel_pagesize(dst_vma);
+
+retry:
+	/*
+	 * On routine entry dst_vma is set.  If we had to drop mmap_sem and
+	 * retry, dst_vma will be set to NULL and we must lookup again.
+	 */
+	err = -EINVAL;
+	if (!dst_vma) {
+		dst_vma = find_vma(dst_mm, dst_start);
+		vma_hpagesize = vma_kernel_pagesize(dst_vma);
+
+		/*
+		 * Make sure the vma is not shared, that the dst range is
+		 * both valid and fully within a single existing vma.
+		 */
+		if (dst_vma->vm_flags & VM_SHARED)
+			goto out_unlock;
+		if (dst_start < dst_vma->vm_start ||
+		    dst_start + len > dst_vma->vm_end)
+			goto out_unlock;
+	}
+
+	/*
+	 * Validate alignment based on huge page size
+	 */
+	if (dst_start & (vma_hpagesize - 1) || len & (vma_hpagesize - 1))
+		goto out_unlock;
+
+	/*
+	 * Only allow __mcopy_atomic_hugetlb on userfaultfd registered ranges.
+	 */
+	if (!dst_vma->vm_userfaultfd_ctx.ctx)
+		goto out_unlock;
+
+	/*
+	 * Ensure the dst_vma has a anon_vma.
+	 */
+	err = -ENOMEM;
+	if (unlikely(anon_vma_prepare(dst_vma)))
+		goto out_unlock;
+
+	h = hstate_vma(dst_vma);
+
+	while (src_addr < src_start + len) {
+		pte_t dst_pteval;
+
+		BUG_ON(dst_addr >= dst_start + len);
+		dst_addr &= huge_page_mask(h);
+
+		/*
+		 * Serialize via hugetlb_fault_mutex
+		 */
+		idx = linear_page_index(dst_vma, dst_addr);
+		mapping = dst_vma->vm_file->f_mapping;
+		hash = hugetlb_fault_mutex_hash(h, dst_mm, dst_vma, mapping,
+								idx, dst_addr);
+		mutex_lock(&hugetlb_fault_mutex_table[hash]);
+
+		err = -ENOMEM;
+		dst_pte = huge_pte_alloc(dst_mm, dst_addr, huge_page_size(h));
+		if (!dst_pte) {
+			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
+			goto out_unlock;
+		}
+
+		err = -EEXIST;
+		dst_pteval = huge_ptep_get(dst_pte);
+		if (!huge_pte_none(dst_pteval)) {
+			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
+			goto out_unlock;
+		}
+
+		err = hugetlb_mcopy_atomic_pte(dst_mm, dst_pte, dst_vma,
+						dst_addr, src_addr, &page);
+
+		mutex_unlock(&hugetlb_fault_mutex_table[hash]);
+
+		cond_resched();
+
+		if (unlikely(err == -EFAULT)) {
+			up_read(&dst_mm->mmap_sem);
+			BUG_ON(!page);
+
+			err = copy_huge_page_from_user(
+						(const void __user *)src_addr,
+						page, pages_per_huge_page(h));
+			if (unlikely(err)) {
+				err = -EFAULT;
+				goto out;
+			}
+			down_read(&dst_mm->mmap_sem);
+
+			dst_vma = NULL;
+			goto retry;
+		} else
+			BUG_ON(page);
+
+		if (!err) {
+			dst_addr += vma_hpagesize;
+			src_addr += vma_hpagesize;
+			copied += vma_hpagesize;
+
+			if (fatal_signal_pending(current))
+				err = -EINTR;
+		}
+		if (err)
+			break;
+	}
+
+out_unlock:
+	up_read(&dst_mm->mmap_sem);
+out:
+	if (page)
+		put_page(page);
+	BUG_ON(copied < 0);
+	BUG_ON(err > 0);
+	BUG_ON(!copied && !err);
+	return copied ? copied : err;
+}
+#else /* !CONFIG_HUGETLB_PAGE */
+static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
+					      struct vm_area_struct *dst_vma,
+					      unsigned long dst_start,
+					      unsigned long src_start,
+					      unsigned long len,
+					      bool zeropage)
+{
+	up_read(&dst_mm->mmap_sem);	/* HUGETLB not configured */
+	BUG();
+}
+#endif /* CONFIG_HUGETLB_PAGE */
+
 static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 					      unsigned long dst_start,
 					      unsigned long src_start,
@@ -182,6 +354,13 @@ retry:
 		goto out_unlock;
 
 	/*
+	 * If this is a HUGETLB vma, pass off to appropriate routine
+	 */
+	if (dst_vma->vm_flags & VM_HUGETLB)
+		return  __mcopy_atomic_hugetlb(dst_mm, dst_vma, dst_start,
+						src_start, len, false);
+
+	/*
 	 * Be strict and only allow __mcopy_atomic on userfaultfd
 	 * registered ranges to prevent userland errors going
 	 * unnoticed. As far as the VM consistency is concerned, it
-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
