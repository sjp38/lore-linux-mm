Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0C76B72B9
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 00:37:17 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id p24so19807083qtl.2
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 21:37:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 63si6582545qth.271.2018.12.04.21.37.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 21:37:15 -0800 (PST)
From: jglisse@redhat.com
Subject: [PATCH v2 3/3] mm/mmu_notifier: contextual information for event triggering invalidation v2
Date: Wed,  5 Dec 2018 00:36:28 -0500
Message-Id: <20181205053628.3210-4-jglisse@redhat.com>
In-Reply-To: <20181205053628.3210-1-jglisse@redhat.com>
References: <20181205053628.3210-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <zwisler@kernel.org>, Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>, Felix Kuehling <felix.kuehling@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org, linux-rdma@vger.kernel.org, linux-fsdevel@vger.kernel.org, dri-devel@lists.freedesktop.org

From: Jérôme Glisse <jglisse@redhat.com>

CPU page table update can happens for many reasons, not only as a result
of a syscall (munmap(), mprotect(), mremap(), madvise(), ...) but also
as a result of kernel activities (memory compression, reclaim, migration,
...).

Users of mmu notifier API track changes to the CPU page table and take
specific action for them. While current API only provide range of virtual
address affected by the change, not why the changes is happening.

This patchset adds event information so that users of mmu notifier can
differentiate among broad category:
    - UNMAP: munmap() or mremap()
    - CLEAR: page table is cleared (migration, compaction, reclaim, ...)
    - PROTECTION_VMA: change in access protections for the range
    - PROTECTION_PAGE: change in access protections for page in the range
    - SOFT_DIRTY: soft dirtyness tracking

Being able to identify munmap() and mremap() from other reasons why the
page table is cleared is important to allow user of mmu notifier to
update their own internal tracking structure accordingly (on munmap or
mremap it is not longer needed to track range of virtual address as it
becomes invalid).

Changes since v1:
    - use mmu_notifier_range_init() helper to to optimize out the case
      when mmu notifier is not enabled
    - use kernel doc format for describing the enum values

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Acked-by: Christian König <christian.koenig@amd.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim Krčmář <rkrcmar@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Felix Kuehling <felix.kuehling@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: kvm@vger.kernel.org
Cc: linux-rdma@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org
Cc: dri-devel@lists.freedesktop.org
---
 fs/dax.c                     |  7 +++++++
 fs/proc/task_mmu.c           |  3 ++-
 include/linux/mmu_notifier.h | 35 +++++++++++++++++++++++++++++++++--
 kernel/events/uprobes.c      |  3 ++-
 mm/huge_memory.c             | 12 ++++++++----
 mm/hugetlb.c                 | 10 ++++++----
 mm/khugepaged.c              |  3 ++-
 mm/ksm.c                     |  6 ++++--
 mm/madvise.c                 |  3 ++-
 mm/memory.c                  | 18 ++++++++++++------
 mm/migrate.c                 |  5 +++--
 mm/mprotect.c                |  3 ++-
 mm/mremap.c                  |  3 ++-
 mm/oom_kill.c                |  2 +-
 mm/rmap.c                    |  6 ++++--
 15 files changed, 90 insertions(+), 29 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 874085bacaf5..6056b03a1626 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -768,6 +768,13 @@ static void dax_entry_mkclean(struct address_space *mapping, pgoff_t index,
 
 		address = pgoff_address(index, vma);
 
+		/*
+		 * All the field are populated by follow_pte_pmd() except
+		 * the event field.
+		 */
+		mmu_notifier_range_init(&range, NULL, 0, -1UL,
+					MMU_NOTIFY_PROTECTION_PAGE);
+
 		/*
 		 * Note because we provide start/end to follow_pte_pmd it will
 		 * call mmu_notifier_invalidate_range_start() on our behalf
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index b3ddceb003bc..f68a9ebb0218 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1141,7 +1141,8 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 				break;
 			}
 
-			mmu_notifier_range_init(&range, mm, 0, -1UL);
+			mmu_notifier_range_init(&range, mm, 0, -1UL,
+						MMU_NOTIFY_SOFT_DIRTY);
 			mmu_notifier_invalidate_range_start(&range);
 		}
 		walk_page_range(0, mm->highest_vm_end, &clear_refs_walk);
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 39b06772427f..d249e24acea5 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -25,10 +25,39 @@ struct mmu_notifier_mm {
 	spinlock_t lock;
 };
 
+/**
+ * enum mmu_notifier_event - reason for the mmu notifier callback
+ * @MMU_NOTIFY_UNMAP: either munmap() that unmap the range or a mremap() that
+ * move the range
+ *
+ * @MMU_NOTIFY_CLEAR: clear page table entry (many reasons for this like
+ * madvise() or replacing a page by another one, ...).
+ *
+ * @MMU_NOTIFY_PROTECTION_VMA: update is due to protection change for the range
+ * ie using the vma access permission (vm_page_prot) to update the whole range
+ * is enough no need to inspect changes to the CPU page table (mprotect()
+ * syscall)
+ *
+ * @MMU_NOTIFY_PROTECTION_PAGE: update is due to change in read/write flag for
+ * pages in the range so to mirror those changes the user must inspect the CPU
+ * page table (from the end callback).
+ *
+ * @MMU_NOTIFY_SOFT_DIRTY: soft dirty accounting (still same page and same
+ * access flags)
+ */
+enum mmu_notifier_event {
+	MMU_NOTIFY_UNMAP = 0,
+	MMU_NOTIFY_CLEAR,
+	MMU_NOTIFY_PROTECTION_VMA,
+	MMU_NOTIFY_PROTECTION_PAGE,
+	MMU_NOTIFY_SOFT_DIRTY,
+};
+
 struct mmu_notifier_range {
 	struct mm_struct *mm;
 	unsigned long start;
 	unsigned long end;
+	enum mmu_notifier_event event;
 	bool blockable;
 };
 
@@ -320,11 +349,13 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 static inline void mmu_notifier_range_init(struct mmu_notifier_range *range,
 					   struct mm_struct *mm,
 					   unsigned long start,
-					   unsigned long end)
+					   unsigned long end,
+					   enum mmu_notifier_event event)
 {
 	range->mm = mm;
 	range->start = start;
 	range->end = end;
+	range->event = event;
 }
 
 #define ptep_clear_flush_young_notify(__vma, __address, __ptep)		\
@@ -453,7 +484,7 @@ static inline void _mmu_notifier_range_init(struct mmu_notifier_range *range,
 	range->end = end;
 }
 
-#define mmu_notifier_range_init(range, mm, start, end) \
+#define mmu_notifier_range_init(range, mm, start, end, event) \
 	_mmu_notifier_range_init(range, start, end)
 
 
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 1fc8a93709c3..a70c3204f25d 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -174,7 +174,8 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	struct mmu_notifier_range range;
 	struct mem_cgroup *memcg;
 
-	mmu_notifier_range_init(&range, mm, addr, addr + PAGE_SIZE);
+	mmu_notifier_range_init(&range, mm, addr, addr + PAGE_SIZE,
+				MMU_NOTIFY_CLEAR);
 
 	VM_BUG_ON_PAGE(PageTransHuge(old_page), old_page);
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c1d3ce809416..b8d9029890c5 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1183,7 +1183,8 @@ static vm_fault_t do_huge_pmd_wp_page_fallback(struct vm_fault *vmf,
 	}
 
 	mmu_notifier_range_init(&range, vma->vm_mm, haddr,
-				haddr + HPAGE_PMD_SIZE);
+				haddr + HPAGE_PMD_SIZE,
+				MMU_NOTIFY_CLEAR);
 	mmu_notifier_invalidate_range_start(&range);
 
 	vmf->ptl = pmd_lock(vma->vm_mm, vmf->pmd);
@@ -1347,7 +1348,8 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 	__SetPageUptodate(new_page);
 
 	mmu_notifier_range_init(&range, vma->vm_mm, haddr,
-				haddr + HPAGE_PMD_SIZE);
+				haddr + HPAGE_PMD_SIZE,
+				MMU_NOTIFY_CLEAR);
 	mmu_notifier_invalidate_range_start(&range);
 
 	spin_lock(vmf->ptl);
@@ -2027,7 +2029,8 @@ void __split_huge_pud(struct vm_area_struct *vma, pud_t *pud,
 	struct mmu_notifier_range range;
 
 	mmu_notifier_range_init(&range, vma->vm_mm, address & HPAGE_PUD_MASK,
-				(address & HPAGE_PUD_MASK) + HPAGE_PUD_SIZE);
+				(address & HPAGE_PUD_MASK) + HPAGE_PUD_SIZE,
+				MMU_NOTIFY_CLEAR);
 	mmu_notifier_invalidate_range_start(&range);
 	ptl = pud_lock(vma->vm_mm, pud);
 	if (unlikely(!pud_trans_huge(*pud) && !pud_devmap(*pud)))
@@ -2243,7 +2246,8 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	struct mmu_notifier_range range;
 
 	mmu_notifier_range_init(&range, vma->vm_mm, address & HPAGE_PMD_MASK,
-				(address & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE);
+				(address & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE,
+				MMU_NOTIFY_CLEAR);
 	mmu_notifier_invalidate_range_start(&range);
 	ptl = pmd_lock(vma->vm_mm, pmd);
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e7c179cbcd75..fd1395918bb3 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3246,7 +3246,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 
 	if (cow) {
 		mmu_notifier_range_init(&range, src, vma->vm_start,
-					vma->vm_end);
+					vma->vm_end, MMU_NOTIFY_CLEAR);
 		mmu_notifier_invalidate_range_start(&range);
 	}
 
@@ -3357,7 +3357,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	/*
 	 * If sharing possible, alert mmu notifiers of worst case.
 	 */
-	mmu_notifier_range_init(&range, mm, start, end);
+	mmu_notifier_range_init(&range, mm, start, end, MMU_NOTIFY_CLEAR);
 	adjust_range_if_pmd_sharing_possible(vma, &range.start, &range.end);
 	mmu_notifier_invalidate_range_start(&range);
 	address = start;
@@ -3625,7 +3625,8 @@ static vm_fault_t hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 	__SetPageUptodate(new_page);
 	set_page_huge_active(new_page);
 
-	mmu_notifier_range_init(&range, mm, haddr, haddr + huge_page_size(h));
+	mmu_notifier_range_init(&range, mm, haddr, haddr + huge_page_size(h),
+				MMU_NOTIFY_CLEAR);
 	mmu_notifier_invalidate_range_start(&range);
 
 	/*
@@ -4345,7 +4346,8 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	 * start/end.  Set range.start/range.end to cover the maximum possible
 	 * range if PMD sharing is possible.
 	 */
-	mmu_notifier_range_init(&range, mm, start, end);
+	mmu_notifier_range_init(&range, mm, start, end,
+				MMU_NOTIFY_PROTECTION_VMA);
 	adjust_range_if_pmd_sharing_possible(vma, &range.start, &range.end);
 
 	BUG_ON(address >= end);
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 7736f6c37f19..331dc2738f48 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1016,7 +1016,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 	pte = pte_offset_map(pmd, address);
 	pte_ptl = pte_lockptr(mm, pmd);
 
-	mmu_notifier_range_init(&range, mm, address, address + HPAGE_PMD_SIZE);
+	mmu_notifier_range_init(&range, mm, address, address + HPAGE_PMD_SIZE,
+				MMU_NOTIFY_CLEAR);
 	mmu_notifier_invalidate_range_start(&range);
 	pmd_ptl = pmd_lock(mm, pmd); /* probably unnecessary */
 	/*
diff --git a/mm/ksm.c b/mm/ksm.c
index 6239d2df7a8e..98a627c01eb0 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1051,7 +1051,8 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 	BUG_ON(PageTransCompound(page));
 
 	mmu_notifier_range_init(&range, mm, pvmw.address,
-				pvmw.address + PAGE_SIZE);
+				pvmw.address + PAGE_SIZE,
+				MMU_NOTIFY_CLEAR);
 	mmu_notifier_invalidate_range_start(&range);
 
 	if (!page_vma_mapped_walk(&pvmw))
@@ -1138,7 +1139,8 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	if (!pmd)
 		goto out;
 
-	mmu_notifier_range_init(&range, mm, addr, addr + PAGE_SIZE);
+	mmu_notifier_range_init(&range, mm, addr, addr + PAGE_SIZE,
+				MMU_NOTIFY_CLEAR);
 	mmu_notifier_invalidate_range_start(&range);
 
 	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
diff --git a/mm/madvise.c b/mm/madvise.c
index 21a7881a2db4..d220ad7087ed 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -472,7 +472,8 @@ static int madvise_free_single_vma(struct vm_area_struct *vma,
 	range.end = min(vma->vm_end, end_addr);
 	if (range.end <= vma->vm_start)
 		return -EINVAL;
-	mmu_notifier_range_init(&range, mm, range.start, range.end);
+	mmu_notifier_range_init(&range, mm, range.start, range.end,
+				MMU_NOTIFY_CLEAR);
 
 	lru_add_drain();
 	tlb_gather_mmu(&tlb, mm, range.start, range.end);
diff --git a/mm/memory.c b/mm/memory.c
index 574307f11464..893e3bc4b895 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1009,7 +1009,8 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	is_cow = is_cow_mapping(vma->vm_flags);
 
 	if (is_cow) {
-		mmu_notifier_range_init(&range, src_mm, addr, end);
+		mmu_notifier_range_init(&range, src_mm, addr, end,
+					MMU_NOTIFY_PROTECTION_PAGE);
 		mmu_notifier_invalidate_range_start(&range);
 	}
 
@@ -1333,7 +1334,8 @@ void unmap_vmas(struct mmu_gather *tlb,
 {
 	struct mmu_notifier_range range;
 
-	mmu_notifier_range_init(&range, vma->vm_mm, start_addr, end_addr);
+	mmu_notifier_range_init(&range, vma->vm_mm, start_addr,
+				end_addr, MMU_NOTIFY_UNMAP);
 	mmu_notifier_invalidate_range_start(&range);
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next)
 		unmap_single_vma(tlb, vma, start_addr, end_addr, NULL);
@@ -1355,7 +1357,8 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
 	struct mmu_gather tlb;
 
 	lru_add_drain();
-	mmu_notifier_range_init(&range, vma->vm_mm, start, start + size);
+	mmu_notifier_range_init(&range, vma->vm_mm, start,
+				start + size, MMU_NOTIFY_CLEAR);
 	tlb_gather_mmu(&tlb, vma->vm_mm, start, range.end);
 	update_hiwater_rss(vma->vm_mm);
 	mmu_notifier_invalidate_range_start(&range);
@@ -1381,7 +1384,8 @@ static void zap_page_range_single(struct vm_area_struct *vma, unsigned long addr
 	struct mmu_gather tlb;
 
 	lru_add_drain();
-	mmu_notifier_range_init(&range, vma->vm_mm, address, address + size);
+	mmu_notifier_range_init(&range, vma->vm_mm, address,
+				address + size, MMU_NOTIFY_CLEAR);
 	tlb_gather_mmu(&tlb, vma->vm_mm, address, range.end);
 	update_hiwater_rss(vma->vm_mm);
 	mmu_notifier_invalidate_range_start(&range);
@@ -2272,7 +2276,8 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 	__SetPageUptodate(new_page);
 
 	mmu_notifier_range_init(&range, mm, vmf->address & PAGE_MASK,
-				(vmf->address & PAGE_MASK) + PAGE_SIZE);
+				(vmf->address & PAGE_MASK) + PAGE_SIZE,
+				MMU_NOTIFY_CLEAR);
 	mmu_notifier_invalidate_range_start(&range);
 
 	/*
@@ -4061,7 +4066,8 @@ static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
 
 		if (range) {
 			mmu_notifier_range_init(range, mm, address & PMD_MASK,
-					     (address & PMD_MASK) + PMD_SIZE);
+					     (address & PMD_MASK) + PMD_SIZE,
+					     range->event);
 			mmu_notifier_invalidate_range_start(range);
 		}
 		*ptlp = pmd_lock(mm, pmd);
diff --git a/mm/migrate.c b/mm/migrate.c
index 74f5b3208c05..f02bb4b22c1a 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2316,7 +2316,7 @@ static void migrate_vma_collect(struct migrate_vma *migrate)
 	mm_walk.private = migrate;
 
 	mmu_notifier_range_init(&range, mm_walk.mm, migrate->start,
-				migrate->end);
+				migrate->end, MMU_NOTIFY_CLEAR);
 	mmu_notifier_invalidate_range_start(&range);
 	walk_page_range(migrate->start, migrate->end, &mm_walk);
 	mmu_notifier_invalidate_range_end(&range);
@@ -2725,7 +2725,8 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 				notified = true;
 
 				mmu_notifier_range_init(&range, mm, addr,
-							migrate->end);
+							migrate->end,
+							MMU_NOTIFY_CLEAR);
 				mmu_notifier_invalidate_range_start(&range);
 			}
 			migrate_vma_insert_page(migrate, addr, newpage,
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 36cb358db170..d5bbe5ca61ac 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -185,7 +185,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 
 		/* invoke the mmu notifier if the pmd is populated */
 		if (!range.start) {
-			mmu_notifier_range_init(&range, vma->vm_mm, addr, end);
+			mmu_notifier_range_init(&range, vma->vm_mm, addr, end,
+						MMU_NOTIFY_PROTECTION_VMA);
 			mmu_notifier_invalidate_range_start(&range);
 		}
 
diff --git a/mm/mremap.c b/mm/mremap.c
index def01d86e36f..386e3c492f6e 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -203,7 +203,8 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 	old_end = old_addr + len;
 	flush_cache_range(vma, old_addr, old_end);
 
-	mmu_notifier_range_init(&range, vma->vm_mm, old_addr, old_end);
+	mmu_notifier_range_init(&range, vma->vm_mm, old_addr,
+				old_end, MMU_NOTIFY_UNMAP);
 	mmu_notifier_invalidate_range_start(&range);
 
 	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1eea8b04f27a..4ac95032b898 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -520,7 +520,7 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
 			struct mmu_gather tlb;
 
 			mmu_notifier_range_init(&range, mm, vma->vm_start,
-						vma->vm_end);
+						vma->vm_end, MMU_NOTIFY_CLEAR);
 			tlb_gather_mmu(&tlb, mm, range.start, range.end);
 			if (mmu_notifier_invalidate_range_start_nonblock(&range)) {
 				tlb_finish_mmu(&tlb, range.start, range.end);
diff --git a/mm/rmap.c b/mm/rmap.c
index c75f72f6fe0e..6ca019cdc789 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -898,7 +898,8 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 	 */
 	mmu_notifier_range_init(&range, vma->vm_mm, address,
 				min(vma->vm_end, address +
-				    (PAGE_SIZE << compound_order(page))));
+				    (PAGE_SIZE << compound_order(page))),
+				MMU_NOTIFY_PROTECTION_PAGE);
 	mmu_notifier_invalidate_range_start(&range);
 
 	while (page_vma_mapped_walk(&pvmw)) {
@@ -1373,7 +1374,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	 */
 	mmu_notifier_range_init(&range, vma->vm_mm, vma->vm_start,
 				min(vma->vm_end, vma->vm_start +
-				    (PAGE_SIZE << compound_order(page))));
+				    (PAGE_SIZE << compound_order(page))),
+				MMU_NOTIFY_CLEAR);
 	if (PageHuge(page)) {
 		/*
 		 * If sharing is possible, start and end will be adjusted
-- 
2.17.2
