Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id EFE6D6B0010
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:04 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id v7so18546713pgo.8
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q75si3546836pfq.220.2018.02.04.17.28.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:03 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 07/64] mm/hugetlb: teach hugetlb_fault() about range locking
Date: Mon,  5 Feb 2018 02:26:57 +0100
Message-Id: <20180205012754.23615-8-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

Such that we can pass the mmrange along to vm_fault for
page in userfault range (handle_userfault()) which gets
funky with mmap_sem - just look at the locking rules.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 include/linux/hugetlb.h |  9 +++++----
 mm/gup.c                |  3 ++-
 mm/hugetlb.c            | 16 +++++++++++-----
 mm/memory.c             |  2 +-
 4 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 36fa6a2a82e3..df0a89a95bdc 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -91,7 +91,7 @@ int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_ar
 long follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *,
 			 struct page **, struct vm_area_struct **,
 			 unsigned long *, unsigned long *, long, unsigned int,
-			 int *);
+			 int *, struct range_lock *);
 void unmap_hugepage_range(struct vm_area_struct *,
 			  unsigned long, unsigned long, struct page *);
 void __unmap_hugepage_range_final(struct mmu_gather *tlb,
@@ -106,7 +106,8 @@ int hugetlb_report_node_meminfo(int, char *);
 void hugetlb_show_meminfo(void);
 unsigned long hugetlb_total_pages(void);
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, unsigned int flags);
+		  unsigned long address, unsigned int flags,
+		  struct range_lock *mmrange);
 int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm, pte_t *dst_pte,
 				struct vm_area_struct *dst_vma,
 				unsigned long dst_addr,
@@ -170,7 +171,7 @@ static inline unsigned long hugetlb_total_pages(void)
 	return 0;
 }
 
-#define follow_hugetlb_page(m,v,p,vs,a,b,i,w,n)	({ BUG(); 0; })
+#define follow_hugetlb_page(m,v,p,vs,a,b,i,w,n,r) ({ BUG(); 0; })
 #define follow_huge_addr(mm, addr, write)	ERR_PTR(-EINVAL)
 #define copy_hugetlb_page_range(src, dst, vma)	({ BUG(); 0; })
 static inline void hugetlb_report_meminfo(struct seq_file *m)
@@ -189,7 +190,7 @@ static inline void hugetlb_show_meminfo(void)
 #define pud_huge(x)	0
 #define is_hugepage_only_range(mm, addr, len)	0
 #define hugetlb_free_pgd_range(tlb, addr, end, floor, ceiling) ({BUG(); 0; })
-#define hugetlb_fault(mm, vma, addr, flags)	({ BUG(); 0; })
+#define hugetlb_fault(mm, vma, addr, flags,mmrange)	({ BUG(); 0; })
 #define hugetlb_mcopy_atomic_pte(dst_mm, dst_pte, dst_vma, dst_addr, \
 				src_addr, pagep)	({ BUG(); 0; })
 #define huge_pte_offset(mm, address, sz)	0
diff --git a/mm/gup.c b/mm/gup.c
index 01983a7b3750..3d1b6dd11616 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -684,7 +684,8 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			if (is_vm_hugetlb_page(vma)) {
 				i = follow_hugetlb_page(mm, vma, pages, vmas,
 						&start, &nr_pages, i,
-						gup_flags, nonblocking);
+						gup_flags, nonblocking,
+						mmrange);
 				continue;
 			}
 		}
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 7c204e3d132b..fd22459e89ef 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3675,7 +3675,8 @@ int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
 
 static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			   struct address_space *mapping, pgoff_t idx,
-			   unsigned long address, pte_t *ptep, unsigned int flags)
+			   unsigned long address, pte_t *ptep, unsigned int flags,
+			   struct range_lock *mmrange)
 {
 	struct hstate *h = hstate_vma(vma);
 	int ret = VM_FAULT_SIGBUS;
@@ -3716,6 +3717,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				.vma = vma,
 				.address = address,
 				.flags = flags,
+				.lockrange = mmrange,
 				/*
 				 * Hard to debug if it ends up being
 				 * used by a callee that assumes
@@ -3869,7 +3871,8 @@ u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
 #endif
 
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, unsigned int flags)
+		  unsigned long address, unsigned int flags,
+		  struct range_lock *mmrange)
 {
 	pte_t *ptep, entry;
 	spinlock_t *ptl;
@@ -3912,7 +3915,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	entry = huge_ptep_get(ptep);
 	if (huge_pte_none(entry)) {
-		ret = hugetlb_no_page(mm, vma, mapping, idx, address, ptep, flags);
+		ret = hugetlb_no_page(mm, vma, mapping, idx, address, ptep,
+				      flags, mmrange);
 		goto out_mutex;
 	}
 
@@ -4140,7 +4144,8 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			 struct page **pages, struct vm_area_struct **vmas,
 			 unsigned long *position, unsigned long *nr_pages,
-			 long i, unsigned int flags, int *nonblocking)
+			 long i, unsigned int flags, int *nonblocking,
+			 struct range_lock *mmrange)
 {
 	unsigned long pfn_offset;
 	unsigned long vaddr = *position;
@@ -4221,7 +4226,8 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 						FAULT_FLAG_ALLOW_RETRY);
 				fault_flags |= FAULT_FLAG_TRIED;
 			}
-			ret = hugetlb_fault(mm, vma, vaddr, fault_flags);
+			ret = hugetlb_fault(mm, vma, vaddr, fault_flags,
+					    mmrange);
 			if (ret & VM_FAULT_ERROR) {
 				err = vm_fault_to_errno(ret, flags);
 				remainder = 0;
diff --git a/mm/memory.c b/mm/memory.c
index b3561a052939..2d087b0e174d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4136,7 +4136,7 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		mem_cgroup_oom_enable();
 
 	if (unlikely(is_vm_hugetlb_page(vma)))
-		ret = hugetlb_fault(vma->vm_mm, vma, address, flags);
+		ret = hugetlb_fault(vma->vm_mm, vma, address, flags, mmrange);
 	else
 		ret = __handle_mm_fault(vma, address, flags, mmrange);
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
