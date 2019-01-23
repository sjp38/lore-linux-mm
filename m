Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id CEFB98E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 17:23:39 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id y27so3418236qkj.21
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 14:23:39 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r15si790382qtj.56.2019.01.23.14.23.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 14:23:38 -0800 (PST)
From: jglisse@redhat.com
Subject: [PATCH v4 3/9] mm/mmu_notifier: use correct mmu_notifier events for each invalidation
Date: Wed, 23 Jan 2019 17:23:09 -0500
Message-Id: <20190123222315.1122-4-jglisse@redhat.com>
In-Reply-To: <20190123222315.1122-1-jglisse@redhat.com>
References: <20190123222315.1122-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Jan Kara <jack@suse.cz>, Felix Kuehling <Felix.Kuehling@amd.com>, Jason Gunthorpe <jgg@mellanox.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <zwisler@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, linux-fsdevel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>

From: Jérôme Glisse <jglisse@redhat.com>

This update each existing invalidation to use the correct mmu notifier
event that represent what is happening to the CPU page table. See the
patch which introduced the events to see the rational behind this.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Christian König <christian.koenig@amd.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim Krčmář <rkrcmar@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: kvm@vger.kernel.org
Cc: dri-devel@lists.freedesktop.org
Cc: linux-rdma@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>
---
 fs/proc/task_mmu.c      |  2 +-
 kernel/events/uprobes.c |  2 +-
 mm/huge_memory.c        | 14 ++++++--------
 mm/hugetlb.c            |  7 ++++---
 mm/khugepaged.c         |  2 +-
 mm/ksm.c                |  4 ++--
 mm/madvise.c            |  2 +-
 mm/memory.c             | 16 ++++++++--------
 mm/migrate.c            |  4 ++--
 mm/mprotect.c           |  5 +++--
 mm/rmap.c               |  6 +++---
 11 files changed, 32 insertions(+), 32 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 57e7f98647d3..cce226f3305f 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1143,7 +1143,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 				break;
 			}
 
-			mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP,
+			mmu_notifier_range_init(&range, MMU_NOTIFY_SOFT_DIRTY,
 						NULL, mm, 0, -1UL);
 			mmu_notifier_invalidate_range_start(&range);
 		}
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index b67fe7e59621..87e76a1dc758 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -174,7 +174,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	struct mmu_notifier_range range;
 	struct mem_cgroup *memcg;
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, vma, mm, addr,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, vma, mm, addr,
 				addr + PAGE_SIZE);
 
 	VM_BUG_ON_PAGE(PageTransHuge(old_page), old_page);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b353e8b7876f..957d23754217 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1182,9 +1182,8 @@ static vm_fault_t do_huge_pmd_wp_page_fallback(struct vm_fault *vmf,
 		cond_resched();
 	}
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, vma, vma->vm_mm,
-				haddr,
-				haddr + HPAGE_PMD_SIZE);
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, vma, vma->vm_mm,
+				haddr, haddr + HPAGE_PMD_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
 
 	vmf->ptl = pmd_lock(vma->vm_mm, vmf->pmd);
@@ -1346,9 +1345,8 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 				    vma, HPAGE_PMD_NR);
 	__SetPageUptodate(new_page);
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, vma, vma->vm_mm,
-				haddr,
-				haddr + HPAGE_PMD_SIZE);
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, vma, vma->vm_mm,
+				haddr, haddr + HPAGE_PMD_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
 
 	spin_lock(vmf->ptl);
@@ -2025,7 +2023,7 @@ void __split_huge_pud(struct vm_area_struct *vma, pud_t *pud,
 	spinlock_t *ptl;
 	struct mmu_notifier_range range;
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, vma, vma->vm_mm,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, vma, vma->vm_mm,
 				address & HPAGE_PUD_MASK,
 				(address & HPAGE_PUD_MASK) + HPAGE_PUD_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
@@ -2244,7 +2242,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	spinlock_t *ptl;
 	struct mmu_notifier_range range;
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, vma, vma->vm_mm,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, vma, vma->vm_mm,
 				address & HPAGE_PMD_MASK,
 				(address & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index cbda46ad6a30..f691398ac6b6 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3246,7 +3246,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	cow = (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
 
 	if (cow) {
-		mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, vma, src,
+		mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, vma, src,
 					vma->vm_start,
 					vma->vm_end);
 		mmu_notifier_invalidate_range_start(&range);
@@ -3627,7 +3627,7 @@ static vm_fault_t hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 	__SetPageUptodate(new_page);
 	set_page_huge_active(new_page);
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, vma, mm, haddr,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, vma, mm, haddr,
 				haddr + huge_page_size(h));
 	mmu_notifier_invalidate_range_start(&range);
 
@@ -4348,7 +4348,8 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	 * start/end.  Set range.start/range.end to cover the maximum possible
 	 * range if PMD sharing is possible.
 	 */
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, vma, mm, start, end);
+	mmu_notifier_range_init(&range, MMU_NOTIFY_PROTECTION_VMA,
+				vma, mm, start, end);
 	adjust_range_if_pmd_sharing_possible(vma, &range.start, &range.end);
 
 	BUG_ON(address >= end);
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index f903acb1b0a6..d09d71f10f0f 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1016,7 +1016,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	pte = pte_offset_map(pmd, address);
 	pte_ptl = pte_lockptr(mm, pmd);
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, NULL, mm, address,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, NULL, mm, address,
 				address + HPAGE_PMD_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
 	pmd_ptl = pmd_lock(mm, pmd); /* probably unnecessary */
diff --git a/mm/ksm.c b/mm/ksm.c
index 6b27c4f0fb1f..97757c5fa15f 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1051,7 +1051,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 
 	BUG_ON(PageTransCompound(page));
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, vma, mm,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, vma, mm,
 				pvmw.address,
 				pvmw.address + PAGE_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
@@ -1140,7 +1140,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	if (!pmd)
 		goto out;
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, vma, mm, addr,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, vma, mm, addr,
 				addr + PAGE_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
 
diff --git a/mm/madvise.c b/mm/madvise.c
index 04446dabba56..a2f91bd286d9 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -472,7 +472,7 @@ static int madvise_free_single_vma(struct vm_area_struct *vma,
 	range.end = min(vma->vm_end, end_addr);
 	if (range.end <= vma->vm_start)
 		return -EINVAL;
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, vma, mm,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, vma, mm,
 				range.start, range.end);
 
 	lru_add_drain();
diff --git a/mm/memory.c b/mm/memory.c
index d9b7c935e812..a8c6922526f6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1009,8 +1009,8 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	is_cow = is_cow_mapping(vma->vm_flags);
 
 	if (is_cow) {
-		mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, vma, src_mm,
-					addr, end);
+		mmu_notifier_range_init(&range, MMU_NOTIFY_PROTECTION_PAGE,
+					vma, src_mm, addr, end);
 		mmu_notifier_invalidate_range_start(&range);
 	}
 
@@ -1334,7 +1334,7 @@ void unmap_vmas(struct mmu_gather *tlb,
 {
 	struct mmu_notifier_range range;
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, vma, vma->vm_mm,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, NULL, vma->vm_mm,
 				start_addr, end_addr);
 	mmu_notifier_invalidate_range_start(&range);
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next)
@@ -1357,7 +1357,7 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
 	struct mmu_gather tlb;
 
 	lru_add_drain();
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, vma, vma->vm_mm,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, vma, vma->vm_mm,
 				start, start + size);
 	tlb_gather_mmu(&tlb, vma->vm_mm, start, range.end);
 	update_hiwater_rss(vma->vm_mm);
@@ -1384,7 +1384,7 @@ static void zap_page_range_single(struct vm_area_struct *vma, unsigned long addr
 	struct mmu_gather tlb;
 
 	lru_add_drain();
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, vma, vma->vm_mm,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, vma, vma->vm_mm,
 				address, address + size);
 	tlb_gather_mmu(&tlb, vma->vm_mm, address, range.end);
 	update_hiwater_rss(vma->vm_mm);
@@ -2275,7 +2275,7 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 
 	__SetPageUptodate(new_page);
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, vma, mm,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, vma, mm,
 				vmf->address & PAGE_MASK,
 				(vmf->address & PAGE_MASK) + PAGE_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
@@ -4086,7 +4086,7 @@ static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
 			goto out;
 
 		if (range) {
-			mmu_notifier_range_init(range, MMU_NOTIFY_UNMAP, NULL,
+			mmu_notifier_range_init(range, MMU_NOTIFY_CLEAR, NULL,
 						mm, address & PMD_MASK,
 						(address & PMD_MASK) + PMD_SIZE);
 			mmu_notifier_invalidate_range_start(range);
@@ -4105,7 +4105,7 @@ static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
 		goto out;
 
 	if (range) {
-		mmu_notifier_range_init(range, MMU_NOTIFY_UNMAP, NULL, mm,
+		mmu_notifier_range_init(range, MMU_NOTIFY_CLEAR, NULL, mm,
 					address & PAGE_MASK,
 					(address & PAGE_MASK) + PAGE_SIZE);
 		mmu_notifier_invalidate_range_start(range);
diff --git a/mm/migrate.c b/mm/migrate.c
index 385c59d5c28d..384cde91d886 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2342,7 +2342,7 @@ static void migrate_vma_collect(struct migrate_vma *migrate)
 	mm_walk.mm = migrate->vma->vm_mm;
 	mm_walk.private = migrate;
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, NULL, mm_walk.mm,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, NULL, mm_walk.mm,
 				migrate->start,
 				migrate->end);
 	mmu_notifier_invalidate_range_start(&range);
@@ -2751,7 +2751,7 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 				notified = true;
 
 				mmu_notifier_range_init(&range,
-							MMU_NOTIFY_UNMAP,
+							MMU_NOTIFY_CLEAR,
 							NULL,
 							migrate->vma->vm_mm,
 							addr, migrate->end);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index b22e660701f1..c19e8bdc2648 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -185,8 +185,9 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 
 		/* invoke the mmu notifier if the pmd is populated */
 		if (!range.start) {
-			mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, vma,
-						vma->vm_mm, addr, end);
+			mmu_notifier_range_init(&range,
+						MMU_NOTIFY_PROTECTION_VMA,
+						vma, vma->vm_mm, addr, end);
 			mmu_notifier_invalidate_range_start(&range);
 		}
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 49c75f0c6c33..81ea84ab511a 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -896,8 +896,8 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 	 * We have to assume the worse case ie pmd for invalidation. Note that
 	 * the page can not be free from this function.
 	 */
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, vma, vma->vm_mm,
-				address,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_PROTECTION_PAGE, vma,
+				vma->vm_mm, address,
 				min(vma->vm_end, address +
 				    (PAGE_SIZE << compound_order(page))));
 	mmu_notifier_invalidate_range_start(&range);
@@ -1372,7 +1372,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	 * Note that the page can not be free in this function as call of
 	 * try_to_unmap() must hold a reference on the page.
 	 */
-	mmu_notifier_range_init(&range, MMU_NOTIFY_UNMAP, vma, vma->vm_mm,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, vma, vma->vm_mm,
 				address,
 				min(vma->vm_end, address +
 				    (PAGE_SIZE << compound_order(page))));
-- 
2.17.2
