Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id C9E806B0295
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:49:44 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id 71so92397385ioe.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:49:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o128si6173355ioe.82.2016.12.16.06.48.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:28 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 24/42] userfaultfd: hugetlbfs: gup: support VM_FAULT_RETRY
Date: Fri, 16 Dec 2016 15:48:03 +0100
Message-Id: <20161216144821.5183-25-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

Add support for VM_FAULT_RETRY to follow_hugetlb_page() so that
get_user_pages_unlocked/locked and "nonblocking/FOLL_NOWAIT" features
will work on hugetlbfs. This is required for fully functional
userfaultfd non-present support on hugetlbfs.

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/hugetlb.h |  5 +++--
 mm/gup.c                |  2 +-
 mm/hugetlb.c            | 48 ++++++++++++++++++++++++++++++++++++++++--------
 3 files changed, 44 insertions(+), 11 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index aab2fff..503099d 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -65,7 +65,8 @@ int hugetlb_mempolicy_sysctl_handler(struct ctl_table *, int,
 int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
 long follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *,
 			 struct page **, struct vm_area_struct **,
-			 unsigned long *, unsigned long *, long, unsigned int);
+			 unsigned long *, unsigned long *, long, unsigned int,
+			 int *);
 void unmap_hugepage_range(struct vm_area_struct *,
 			  unsigned long, unsigned long, struct page *);
 void __unmap_hugepage_range_final(struct mmu_gather *tlb,
@@ -136,7 +137,7 @@ static inline unsigned long hugetlb_total_pages(void)
 	return 0;
 }
 
-#define follow_hugetlb_page(m,v,p,vs,a,b,i,w)	({ BUG(); 0; })
+#define follow_hugetlb_page(m,v,p,vs,a,b,i,w,n)	({ BUG(); 0; })
 #define follow_huge_addr(mm, addr, write)	ERR_PTR(-EINVAL)
 #define copy_hugetlb_page_range(src, dst, vma)	({ BUG(); 0; })
 static inline void hugetlb_report_meminfo(struct seq_file *m)
diff --git a/mm/gup.c b/mm/gup.c
index 5531555..40abe4c 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -572,7 +572,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			if (is_vm_hugetlb_page(vma)) {
 				i = follow_hugetlb_page(mm, vma, pages, vmas,
 						&start, &nr_pages, i,
-						gup_flags);
+						gup_flags, nonblocking);
 				continue;
 			}
 		}
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 621ea74..e1bb7c6 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4046,7 +4046,7 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			 struct page **pages, struct vm_area_struct **vmas,
 			 unsigned long *position, unsigned long *nr_pages,
-			 long i, unsigned int flags)
+			 long i, unsigned int flags, int *nonblocking)
 {
 	unsigned long pfn_offset;
 	unsigned long vaddr = *position;
@@ -4109,16 +4109,43 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		    ((flags & FOLL_WRITE) &&
 		      !huge_pte_write(huge_ptep_get(pte)))) {
 			int ret;
+			unsigned int fault_flags = 0;
 
 			if (pte)
 				spin_unlock(ptl);
-			ret = hugetlb_fault(mm, vma, vaddr,
-				(flags & FOLL_WRITE) ? FAULT_FLAG_WRITE : 0);
-			if (!(ret & VM_FAULT_ERROR))
-				continue;
-
-			remainder = 0;
-			break;
+			if (flags & FOLL_WRITE)
+				fault_flags |= FAULT_FLAG_WRITE;
+			if (nonblocking)
+				fault_flags |= FAULT_FLAG_ALLOW_RETRY;
+			if (flags & FOLL_NOWAIT)
+				fault_flags |= FAULT_FLAG_ALLOW_RETRY |
+					FAULT_FLAG_RETRY_NOWAIT;
+			if (flags & FOLL_TRIED) {
+				VM_WARN_ON_ONCE(fault_flags &
+						FAULT_FLAG_ALLOW_RETRY);
+				fault_flags |= FAULT_FLAG_TRIED;
+			}
+			ret = hugetlb_fault(mm, vma, vaddr, fault_flags);
+			if (ret & VM_FAULT_ERROR) {
+				remainder = 0;
+				break;
+			}
+			if (ret & VM_FAULT_RETRY) {
+				if (nonblocking)
+					*nonblocking = 0;
+				*nr_pages = 0;
+				/*
+				 * VM_FAULT_RETRY must not return an
+				 * error, it will return zero
+				 * instead.
+				 *
+				 * No need to update "position" as the
+				 * caller will not check it after
+				 * *nr_pages is set to 0.
+				 */
+				return i;
+			}
+			continue;
 		}
 
 		pfn_offset = (vaddr & ~huge_page_mask(h)) >> PAGE_SHIFT;
@@ -4147,6 +4174,11 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		spin_unlock(ptl);
 	}
 	*nr_pages = remainder;
+	/*
+	 * setting position is actually required only if remainder is
+	 * not zero but it's faster not to add a "if (remainder)"
+	 * branch.
+	 */
 	*position = vaddr;
 
 	return i ? i : -EFAULT;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
