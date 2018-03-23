Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 897666B0005
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 13:18:08 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 29so8292916qto.10
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 10:18:08 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id k97si6757756qkh.153.2018.03.23.10.18.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 10:18:07 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 2/3] mm/mmu_notifier: provide context information about range invalidation
Date: Fri, 23 Mar 2018 13:17:47 -0400
Message-Id: <20180323171748.20359-3-jglisse@redhat.com>
In-Reply-To: <20180323171748.20359-1-jglisse@redhat.com>
References: <20180323171748.20359-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, David Rientjes <rientjes@google.com>, Joerg Roedel <joro@8bytes.org>, Dan Williams <dan.j.williams@intel.com>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Michal Hocko <mhocko@suse.com>, Leon Romanovsky <leonro@mellanox.com>, Artemy Kovalyov <artemyko@mellanox.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Alex Deucher <alexander.deucher@amd.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

This patch just add the information it does not introduce any optimi-
zation, thus there are no functional change with this patch.

The mmu_notifier callback for range invalidation happens for a number
of reasons. Provide some context information to callback to allow for
optimization. For instance a device driver only need to free tracking
structure for a range if notification is for an munmap. Prior to this
patch the driver would have to free them on each mmu_notifier callback
and reallocate them on next page fault (as it would have to assume it
was an munmap).

Protection change also might turn into a no-op for a driver if driver
mapped a range read only and CPU page table is updated from read and
write to read only then device page table do not need update.

Those are just some of the optimization this patch allows.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Joerg Roedel <joro@8bytes.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Christian KA?nig <christian.koenig@amd.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Leon Romanovsky <leonro@mellanox.com>
Cc: Artemy Kovalyov <artemyko@mellanox.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>
Cc: Dennis Dalessandro <dennis.dalessandro@intel.com>
Cc: Alex Deucher <alexander.deucher@amd.com>
Cc: Sudeep Dutt <sudeep.dutt@intel.com>
Cc: Ashutosh Dixit <ashutosh.dixit@intel.com>
Cc: Dimitri Sivanich <sivanich@sgi.com>
---
 fs/dax.c                     |  1 +
 fs/proc/task_mmu.c           |  1 +
 include/linux/mmu_notifier.h | 24 ++++++++++++++++++++++++
 kernel/events/uprobes.c      |  1 +
 mm/huge_memory.c             |  5 +++++
 mm/hugetlb.c                 |  4 ++++
 mm/khugepaged.c              |  1 +
 mm/ksm.c                     |  2 ++
 mm/madvise.c                 |  1 +
 mm/memory.c                  |  5 +++++
 mm/migrate.c                 |  3 +++
 mm/mprotect.c                |  1 +
 mm/mremap.c                  |  1 +
 mm/oom_kill.c                |  1 +
 mm/rmap.c                    |  2 ++
 15 files changed, 53 insertions(+)

diff --git a/fs/dax.c b/fs/dax.c
index 81f76b23d2fe..2b91e8b41375 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -611,6 +611,7 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
 		 * call mmu_notifier_invalidate_range_start() on our behalf
 		 * before taking any lock.
 		 */
+		range.event = NOTIFY_UPDATE;
 		if (follow_pte_pmd(vma->vm_mm, address, &range, &ptep, &pmdp, &ptl))
 			continue;
 
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 43557d75c050..6cea948ac914 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1164,6 +1164,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 			}
 			range.start = 0;
 			range.end = TASK_SIZE;
+			range.event = NOTIFY_CLEAR_SOFT_DIRTY;
 			mmu_notifier_invalidate_range_start(mm, &range);
 		}
 		walk_page_range(0, mm->highest_vm_end, &clear_refs_walk);
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 4a981daeb0a1..e59db7a1e86d 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -14,6 +14,26 @@ struct mmu_notifier_ops;
 /* mmu_notifier_ops flags */
 #define MMU_INVALIDATE_DOES_NOT_BLOCK	(0x01)
 
+/*
+ * enum mmu_notifier_event - the type of change happening to the address range
+ * @NOTIFY_MUNMAP: page table being clear and vma is freed (default)
+ * @NOTIFY_UPDATE: page table pointing to same page just different protections
+ * @NOTIFY_CHANGE: page table pointing to a new different page
+ * @NOTIFY_CHANGE_NOTIFY: same as NOTIFY_CHANGE but with ->change_pte()
+ * @NOTIFY_CLEAR_SOFT_DIRTY: clear soft dirty flag
+ * @NOTIFY_UNMAP: page table being clear (swap, migration entry, ...)
+ * @NOTIFY_SPLIT: huge pmd or pud being split, still pointing to same page
+ */
+enum mmu_notifier_event {
+	NOTIFY_MUNMAP = 0,
+	NOTIFY_UPDATE,
+	NOTIFY_CHANGE,
+	NOTIFY_CHANGE_NOTIFY,
+	NOTIFY_CLEAR_SOFT_DIRTY,
+	NOTIFY_UNMAP,
+	NOTIFY_SPLIT,
+};
+
 #ifdef CONFIG_MMU_NOTIFIER
 
 /*
@@ -34,11 +54,13 @@ struct mmu_notifier_mm {
  * @mm: mm_struct invalidation is against
  * @start: start address of range (inclusive)
  * @end: end address of range (exclusive)
+ * @event: type of invalidation (see enum mmu_notifier_event)
  */
 struct mmu_notifier_range {
 	struct mm_struct *mm;
 	unsigned long start;
 	unsigned long end;
+	enum mmu_notifier_event event;
 };
 
 struct mmu_notifier_ops {
@@ -448,10 +470,12 @@ extern void mmu_notifier_synchronize(void);
  * struct mmu_notifier_range - range being invalidated with range_start/end
  * @start: start address of range (inclusive)
  * @end: end address of range (exclusive)
+ * @event: type of invalidation (see enum mmu_notifier_event)
  */
 struct mmu_notifier_range {
 	unsigned long start;
 	unsigned long end;
+	enum mmu_notifier_event event;
 };
 
 static inline int mm_has_notifiers(struct mm_struct *mm)
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index bb80f6251b15..a245f54bf38e 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -176,6 +176,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 
 	range.start = addr;
 	range.end = range.start + PAGE_SIZE;
+	range.event = NOTIFY_CHANGE_NOTIFY;
 	mmu_notifier_invalidate_range_start(mm, &range);
 	err = -EAGAIN;
 	if (!page_vma_mapped_walk(&pvmw)) {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5452698975de..01dd2dc4d02b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1172,6 +1172,7 @@ static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
 
 	range.start = haddr;
 	range.end = haddr + HPAGE_PMD_SIZE;
+	range.event = NOTIFY_CHANGE;
 	mmu_notifier_invalidate_range_start(vma->vm_mm, &range);
 
 	vmf->ptl = pmd_lock(vma->vm_mm, vmf->pmd);
@@ -1334,6 +1335,7 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 
 	range.start = haddr;
 	range.end = range.start + HPAGE_PMD_SIZE;
+	range.event = NOTIFY_CHANGE;
 	mmu_notifier_invalidate_range_start(vma->vm_mm, &range);
 
 	spin_lock(vmf->ptl);
@@ -2005,6 +2007,7 @@ void __split_huge_pud(struct vm_area_struct *vma, pud_t *pud,
 
 	range.start = address & HPAGE_PUD_MASK;
 	range.end = range.start + HPAGE_PUD_SIZE;
+	range.event = NOTIFY_SPLIT;
 	mmu_notifier_invalidate_range_start(mm, &range);
 	ptl = pud_lock(mm, pud);
 	if (unlikely(!pud_trans_huge(*pud) && !pud_devmap(*pud)))
@@ -2220,6 +2223,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 
 	range.start = address & HPAGE_PMD_MASK;
 	range.end = range.start + HPAGE_PMD_SIZE;
+	range.event = NOTIFY_SPLIT;
 	mmu_notifier_invalidate_range_start(mm, &range);
 	ptl = pmd_lock(mm, pmd);
 
@@ -2885,6 +2889,7 @@ void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
 
 	range.start = pvmw->address;
 	range.end = range.start + HPAGE_PMD_SIZE;
+	range.event = NOTIFY_UNMAP;
 	mmu_notifier_invalidate_range_start(mm, &range);
 
 	flush_cache_range(vma, range.start, range.end);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 66674a20fecf..04875688b231 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3243,6 +3243,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 
 	range.start = vma->vm_start;
 	range.end = vma->vm_end;
+	range.event = NOTIFY_UPDATE;
 	if (cow)
 		mmu_notifier_invalidate_range_start(src, &range);
 
@@ -3336,6 +3337,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	tlb_start_vma(tlb, vma);
 	range.start = start;
 	range.end = end;
+	range.event = NOTIFY_MUNMAP;
 	mmu_notifier_invalidate_range_start(mm, &range);
 	address = start;
 	for (; address < end; address += sz) {
@@ -3589,6 +3591,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	range.start = address & huge_page_mask(h);
 	range.end = range.start + huge_page_size(h);
+	range.event = NOTIFY_CHANGE;
 	mmu_notifier_invalidate_range_start(mm, &range);
 
 	/*
@@ -4304,6 +4307,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 
 	range.start = address;
 	range.end = end;
+	range.event = NOTIFY_UPDATE;
 	mmu_notifier_invalidate_range_start(mm, &range);
 	i_mmap_lock_write(vma->vm_file->f_mapping);
 	for (; address < end; address += huge_page_size(h)) {
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 4978d21807d4..47d70e395baa 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1019,6 +1019,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	range.start = address;
 	range.end = range.start + HPAGE_PMD_SIZE;
+	range.event = NOTIFY_CHANGE;
 	mmu_notifier_invalidate_range_start(mm, &range);
 	pmd_ptl = pmd_lock(mm, pmd); /* probably unnecessary */
 	/*
diff --git a/mm/ksm.c b/mm/ksm.c
index d886f3dd498b..ef5556f8121d 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1029,6 +1029,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 
 	range.start = pvmw.address;
 	range.end = range.start + PAGE_SIZE;
+	range.event = NOTIFY_UPDATE;
 	mmu_notifier_invalidate_range_start(mm, &range);
 
 	if (!page_vma_mapped_walk(&pvmw))
@@ -1117,6 +1118,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 
 	range.start = addr;
 	range.end = range.start + PAGE_SIZE;
+	range.event = NOTIFY_CHANGE;
 	mmu_notifier_invalidate_range_start(mm, &range);
 
 	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
diff --git a/mm/madvise.c b/mm/madvise.c
index 6ef485907a30..f941c776ba94 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -472,6 +472,7 @@ static int madvise_free_single_vma(struct vm_area_struct *vma,
 	range.end = min(vma->vm_end, end_addr);
 	if (range.end <= vma->vm_start)
 		return -EINVAL;
+	range.event = NOTIFY_UNMAP;
 
 	lru_add_drain();
 	tlb_gather_mmu(&tlb, mm, range.start, range.end);
diff --git a/mm/memory.c b/mm/memory.c
index 020c7219d2cd..047ca231c25f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1255,6 +1255,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	is_cow = is_cow_mapping(vma->vm_flags);
 	range.start = addr;
 	range.end = end;
+	range.event = NOTIFY_UPDATE;
 	if (is_cow)
 		mmu_notifier_invalidate_range_start(src_mm, &range);
 
@@ -1583,6 +1584,7 @@ void unmap_vmas(struct mmu_gather *tlb,
 
 	range.start = start_addr;
 	range.end = end_addr;
+	range.event = NOTIFY_MUNMAP;
 	mmu_notifier_invalidate_range_start(mm, &range);
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next)
 		unmap_single_vma(tlb, vma, start_addr, end_addr, NULL);
@@ -1609,6 +1611,7 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
 	range.end = start + size;
 	tlb_gather_mmu(&tlb, mm, range.start, range.end);
 	update_hiwater_rss(mm);
+	range.event = NOTIFY_UNMAP;
 	mmu_notifier_invalidate_range_start(mm, &range);
 	for ( ; vma && vma->vm_start < range.end; vma = vma->vm_next) {
 		unmap_single_vma(&tlb, vma, range.start, range.end, NULL);
@@ -1647,6 +1650,7 @@ static void zap_page_range_single(struct vm_area_struct *vma, unsigned long addr
 	lru_add_drain();
 	range.start = address;
 	range.end = address + size;
+	range.event = NOTIFY_UNMAP;
 	tlb_gather_mmu(&tlb, mm, range.start, range.end);
 	update_hiwater_rss(mm);
 	mmu_notifier_invalidate_range_start(mm, &range);
@@ -2505,6 +2509,7 @@ static int wp_page_copy(struct vm_fault *vmf)
 
 	range.start = vmf->address & PAGE_MASK;
 	range.end = range.start + PAGE_SIZE;
+	range.event = NOTIFY_CHANGE;
 	mmu_notifier_invalidate_range_start(mm, &range);
 
 	/*
diff --git a/mm/migrate.c b/mm/migrate.c
index b34407867ee4..280aca671108 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2004,6 +2004,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	/* Recheck the target PMD */
 	range.start = address & HPAGE_PMD_MASK;
 	range.end = range.start + HPAGE_PMD_SIZE;
+	range.event = NOTIFY_UNMAP;
 	mmu_notifier_invalidate_range_start(mm, &range);
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_same(*pmd, entry) || !page_ref_freeze(page, 2))) {
@@ -2326,6 +2327,7 @@ static void migrate_vma_collect(struct migrate_vma *migrate)
 
 	range.start = migrate->start;
 	range.end = migrate->end;
+	range.event = NOTIFY_UNMAP;
 	mmu_notifier_invalidate_range_start(mm_walk.mm, &range);
 	walk_page_range(migrate->start, migrate->end, &mm_walk);
 	mmu_notifier_invalidate_range_end(mm_walk.mm, &range);
@@ -2734,6 +2736,7 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 				range.start = addr;
 				range.end = addr + ((npages - i) << PAGE_SHIFT);
 				notified = true;
+				range.event = NOTIFY_CHANGE;
 				mmu_notifier_invalidate_range_start(mm,
 								    &range);
 			}
diff --git a/mm/mprotect.c b/mm/mprotect.c
index cf2661c1ad46..b7ef9a7c0aaf 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -177,6 +177,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		if (!range.start) {
 			range.start = addr;
 			range.end = end;
+			range.event = NOTIFY_UPDATE;
 			mmu_notifier_invalidate_range_start(mm, &range);
 		}
 
diff --git a/mm/mremap.c b/mm/mremap.c
index d7c25c93ebb2..5500c42e5430 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -208,6 +208,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 
 	range.start = old_addr;
 	range.end = old_end;
+	range.event = NOTIFY_MUNMAP;
 	mmu_notifier_invalidate_range_start(vma->vm_mm, &range);
 
 	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 268e00bcf988..021c3f3199df 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -561,6 +561,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 
 			range.start = vma->vm_start;
 			range.end = vma->vm_end;
+			range.event = NOTIFY_MUNMAP;
 			tlb_gather_mmu(&tlb, mm, range.start, range.end);
 			mmu_notifier_invalidate_range_start(mm, &range);
 			unmap_page_range(&tlb, vma, range.start,
diff --git a/mm/rmap.c b/mm/rmap.c
index 7fbd32966ab4..ac9f54ad4eff 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -898,6 +898,7 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 	range.start = address;
 	range.end = min(vma->vm_end, range.start +
 			(PAGE_SIZE << compound_order(page)));
+	range.event = NOTIFY_UPDATE;
 	mmu_notifier_invalidate_range_start(vma->vm_mm, &range);
 
 	while (page_vma_mapped_walk(&pvmw)) {
@@ -1370,6 +1371,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	range.start = address;
 	range.end = min(vma->vm_end,
 			range.start + (PAGE_SIZE << compound_order(page)));
+	range.event = NOTIFY_UNMAP;
 	mmu_notifier_invalidate_range_start(vma->vm_mm, &range);
 
 	while (page_vma_mapped_walk(&pvmw)) {
-- 
2.14.3
