Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 158366B02F4
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 20:06:01 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id t7so26544237qta.3
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 17:06:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z66si1883216qkb.286.2017.08.16.17.05.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 17:05:59 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM-v25 04/19] mm/hmm/mirror: helper to snapshot CPU page table v4
Date: Wed, 16 Aug 2017 20:05:33 -0400
Message-Id: <20170817000548.32038-5-jglisse@redhat.com>
In-Reply-To: <20170817000548.32038-1-jglisse@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

This does not use existing page table walker because we want to share
same code for our page fault handler.

Changed since v3:
  - fix THP handling
Changed since v2:
  - s/device unaddressable/device private/
Changes since v1:
  - Use spinlock instead of rcu synchronized list traversal

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Evgeny Baskakov <ebaskakov@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
---
 include/linux/hmm.h |  55 +++++++++-
 mm/hmm.c            | 285 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 338 insertions(+), 2 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 61c707970aa6..4cb6f9706c3c 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -79,13 +79,26 @@ struct hmm;
  *
  * Flags:
  * HMM_PFN_VALID: pfn is valid
+ * HMM_PFN_READ:  CPU page table has read permission set
  * HMM_PFN_WRITE: CPU page table has write permission set
+ * HMM_PFN_ERROR: corresponding CPU page table entry points to poisoned memory
+ * HMM_PFN_EMPTY: corresponding CPU page table entry is pte_none()
+ * HMM_PFN_SPECIAL: corresponding CPU page table entry is special; i.e., the
+ *      result of vm_insert_pfn() or vm_insert_page(). Therefore, it should not
+ *      be mirrored by a device, because the entry will never have HMM_PFN_VALID
+ *      set and the pfn value is undefined.
+ * HMM_PFN_DEVICE_UNADDRESSABLE: unaddressable device memory (ZONE_DEVICE)
  */
 typedef unsigned long hmm_pfn_t;
 
 #define HMM_PFN_VALID (1 << 0)
-#define HMM_PFN_WRITE (1 << 1)
-#define HMM_PFN_SHIFT 2
+#define HMM_PFN_READ (1 << 1)
+#define HMM_PFN_WRITE (1 << 2)
+#define HMM_PFN_ERROR (1 << 3)
+#define HMM_PFN_EMPTY (1 << 4)
+#define HMM_PFN_SPECIAL (1 << 5)
+#define HMM_PFN_DEVICE_UNADDRESSABLE (1 << 6)
+#define HMM_PFN_SHIFT 7
 
 /*
  * hmm_pfn_t_to_page() - return struct page pointed to by a valid hmm_pfn_t
@@ -241,6 +254,44 @@ struct hmm_mirror {
 
 int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm);
 void hmm_mirror_unregister(struct hmm_mirror *mirror);
+
+
+/*
+ * struct hmm_range - track invalidation lock on virtual address range
+ *
+ * @list: all range lock are on a list
+ * @start: range virtual start address (inclusive)
+ * @end: range virtual end address (exclusive)
+ * @pfns: array of pfns (big enough for the range)
+ * @valid: pfns array did not change since it has been fill by an HMM function
+ */
+struct hmm_range {
+	struct list_head	list;
+	unsigned long		start;
+	unsigned long		end;
+	hmm_pfn_t		*pfns;
+	bool			valid;
+};
+
+/*
+ * To snapshot the CPU page table, call hmm_vma_get_pfns(), then take a device
+ * driver lock that serializes device page table updates, then call
+ * hmm_vma_range_done(), to check if the snapshot is still valid. The same
+ * device driver page table update lock must also be used in the
+ * hmm_mirror_ops.sync_cpu_device_pagetables() callback, so that CPU page
+ * table invalidation serializes on it.
+ *
+ * YOU MUST CALL hmm_vma_range_done() ONCE AND ONLY ONCE EACH TIME YOU CALL
+ * hmm_vma_get_pfns() WITHOUT ERROR !
+ *
+ * IF YOU DO NOT FOLLOW THE ABOVE RULE THE SNAPSHOT CONTENT MIGHT BE INVALID !
+ */
+int hmm_vma_get_pfns(struct vm_area_struct *vma,
+		     struct hmm_range *range,
+		     unsigned long start,
+		     unsigned long end,
+		     hmm_pfn_t *pfns);
+bool hmm_vma_range_done(struct vm_area_struct *vma, struct hmm_range *range);
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
 
diff --git a/mm/hmm.c b/mm/hmm.c
index ff78c92cd34c..b8a24b80463e 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -19,8 +19,12 @@
  */
 #include <linux/mm.h>
 #include <linux/hmm.h>
+#include <linux/rmap.h>
+#include <linux/swap.h>
 #include <linux/slab.h>
 #include <linux/sched.h>
+#include <linux/swapops.h>
+#include <linux/hugetlb.h>
 #include <linux/mmu_notifier.h>
 
 
@@ -31,14 +35,18 @@ static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
  * struct hmm - HMM per mm struct
  *
  * @mm: mm struct this HMM struct is bound to
+ * @lock: lock protecting ranges list
  * @sequence: we track updates to the CPU page table with a sequence number
+ * @ranges: list of range being snapshotted
  * @mirrors: list of mirrors for this mm
  * @mmu_notifier: mmu notifier to track updates to CPU page table
  * @mirrors_sem: read/write semaphore protecting the mirrors list
  */
 struct hmm {
 	struct mm_struct	*mm;
+	spinlock_t		lock;
 	atomic_t		sequence;
+	struct list_head	ranges;
 	struct list_head	mirrors;
 	struct mmu_notifier	mmu_notifier;
 	struct rw_semaphore	mirrors_sem;
@@ -72,6 +80,8 @@ static struct hmm *hmm_register(struct mm_struct *mm)
 	init_rwsem(&hmm->mirrors_sem);
 	atomic_set(&hmm->sequence, 0);
 	hmm->mmu_notifier.ops = NULL;
+	INIT_LIST_HEAD(&hmm->ranges);
+	spin_lock_init(&hmm->lock);
 	hmm->mm = mm;
 
 	/*
@@ -112,6 +122,22 @@ static void hmm_invalidate_range(struct hmm *hmm,
 				 unsigned long end)
 {
 	struct hmm_mirror *mirror;
+	struct hmm_range *range;
+
+	spin_lock(&hmm->lock);
+	list_for_each_entry(range, &hmm->ranges, list) {
+		unsigned long addr, idx, npages;
+
+		if (end < range->start || start >= range->end)
+			continue;
+
+		range->valid = false;
+		addr = max(start, range->start);
+		idx = (addr - range->start) >> PAGE_SHIFT;
+		npages = (min(range->end, end) - addr) >> PAGE_SHIFT;
+		memset(&range->pfns[idx], 0, sizeof(*range->pfns) * npages);
+	}
+	spin_unlock(&hmm->lock);
 
 	down_read(&hmm->mirrors_sem);
 	list_for_each_entry(mirror, &hmm->mirrors, list)
@@ -209,4 +235,263 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror)
 	up_write(&hmm->mirrors_sem);
 }
 EXPORT_SYMBOL(hmm_mirror_unregister);
+
+static void hmm_pfns_special(hmm_pfn_t *pfns,
+			     unsigned long addr,
+			     unsigned long end)
+{
+	for (; addr < end; addr += PAGE_SIZE, pfns++)
+		*pfns = HMM_PFN_SPECIAL;
+}
+
+static int hmm_pfns_bad(unsigned long addr,
+			unsigned long end,
+			struct mm_walk *walk)
+{
+	struct hmm_range *range = walk->private;
+	hmm_pfn_t *pfns = range->pfns;
+	unsigned long i;
+
+	i = (addr - range->start) >> PAGE_SHIFT;
+	for (; addr < end; addr += PAGE_SIZE, i++)
+		pfns[i] = HMM_PFN_ERROR;
+
+	return 0;
+}
+
+static int hmm_vma_walk_hole(unsigned long addr,
+			     unsigned long end,
+			     struct mm_walk *walk)
+{
+	struct hmm_range *range = walk->private;
+	hmm_pfn_t *pfns = range->pfns;
+	unsigned long i;
+
+	i = (addr - range->start) >> PAGE_SHIFT;
+	for (; addr < end; addr += PAGE_SIZE, i++)
+		pfns[i] = HMM_PFN_EMPTY;
+
+	return 0;
+}
+
+static int hmm_vma_walk_clear(unsigned long addr,
+			      unsigned long end,
+			      struct mm_walk *walk)
+{
+	struct hmm_range *range = walk->private;
+	hmm_pfn_t *pfns = range->pfns;
+	unsigned long i;
+
+	i = (addr - range->start) >> PAGE_SHIFT;
+	for (; addr < end; addr += PAGE_SIZE, i++)
+		pfns[i] = 0;
+
+	return 0;
+}
+
+static int hmm_vma_walk_pmd(pmd_t *pmdp,
+			    unsigned long start,
+			    unsigned long end,
+			    struct mm_walk *walk)
+{
+	struct hmm_range *range = walk->private;
+	struct vm_area_struct *vma = walk->vma;
+	hmm_pfn_t *pfns = range->pfns;
+	unsigned long addr = start, i;
+	hmm_pfn_t flag;
+	pte_t *ptep;
+
+	i = (addr - range->start) >> PAGE_SHIFT;
+	flag = vma->vm_flags & VM_READ ? HMM_PFN_READ : 0;
+
+again:
+	if (pmd_none(*pmdp))
+		return hmm_vma_walk_hole(start, end, walk);
+
+	if (pmd_huge(*pmdp) && vma->vm_flags & VM_HUGETLB)
+		return hmm_pfns_bad(start, end, walk);
+
+	if (pmd_devmap(*pmdp) || pmd_trans_huge(*pmdp)) {
+		unsigned long pfn;
+		pmd_t pmd;
+
+		/*
+		 * No need to take pmd_lock here, even if some other threads
+		 * is splitting the huge pmd we will get that event through
+		 * mmu_notifier callback.
+		 *
+		 * So just read pmd value and check again its a transparent
+		 * huge or device mapping one and compute corresponding pfn
+		 * values.
+		 */
+		pmd = pmd_read_atomic(pmdp);
+		barrier();
+		if (!pmd_devmap(pmd) && !pmd_trans_huge(pmd))
+			goto again;
+		if (pmd_protnone(pmd))
+			return hmm_vma_walk_clear(start, end, walk);
+
+		pfn = pmd_pfn(pmd) + pte_index(addr);
+		flag |= pmd_write(pmd) ? HMM_PFN_WRITE : 0;
+		for (; addr < end; addr += PAGE_SIZE, i++, pfn++)
+			pfns[i] = hmm_pfn_t_from_pfn(pfn) | flag;
+		return 0;
+	}
+
+	if (pmd_bad(*pmdp))
+		return hmm_pfns_bad(start, end, walk);
+
+	ptep = pte_offset_map(pmdp, addr);
+	for (; addr < end; addr += PAGE_SIZE, ptep++, i++) {
+		pte_t pte = *ptep;
+
+		pfns[i] = 0;
+
+		if (pte_none(pte) || !pte_present(pte)) {
+			pfns[i] = HMM_PFN_EMPTY;
+			continue;
+		}
+
+		pfns[i] = hmm_pfn_t_from_pfn(pte_pfn(pte)) | flag;
+		pfns[i] |= pte_write(pte) ? HMM_PFN_WRITE : 0;
+	}
+	pte_unmap(ptep - 1);
+
+	return 0;
+}
+
+/*
+ * hmm_vma_get_pfns() - snapshot CPU page table for a range of virtual addresses
+ * @vma: virtual memory area containing the virtual address range
+ * @range: used to track snapshot validity
+ * @start: range virtual start address (inclusive)
+ * @end: range virtual end address (exclusive)
+ * @entries: array of hmm_pfn_t: provided by the caller, filled in by function
+ * Returns: -EINVAL if invalid argument, -ENOMEM out of memory, 0 success
+ *
+ * This snapshots the CPU page table for a range of virtual addresses. Snapshot
+ * validity is tracked by range struct. See hmm_vma_range_done() for further
+ * information.
+ *
+ * The range struct is initialized here. It tracks the CPU page table, but only
+ * if the function returns success (0), in which case the caller must then call
+ * hmm_vma_range_done() to stop CPU page table update tracking on this range.
+ *
+ * NOT CALLING hmm_vma_range_done() IF FUNCTION RETURNS 0 WILL LEAD TO SERIOUS
+ * MEMORY CORRUPTION ! YOU HAVE BEEN WARNED !
+ */
+int hmm_vma_get_pfns(struct vm_area_struct *vma,
+		     struct hmm_range *range,
+		     unsigned long start,
+		     unsigned long end,
+		     hmm_pfn_t *pfns)
+{
+	struct mm_walk mm_walk;
+	struct hmm *hmm;
+
+	/* FIXME support hugetlb fs */
+	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL)) {
+		hmm_pfns_special(pfns, start, end);
+		return -EINVAL;
+	}
+
+	/* Sanity check, this really should not happen ! */
+	if (start < vma->vm_start || start >= vma->vm_end)
+		return -EINVAL;
+	if (end < vma->vm_start || end > vma->vm_end)
+		return -EINVAL;
+
+	hmm = hmm_register(vma->vm_mm);
+	if (!hmm)
+		return -ENOMEM;
+	/* Caller must have registered a mirror, via hmm_mirror_register() ! */
+	if (!hmm->mmu_notifier.ops)
+		return -EINVAL;
+
+	/* Initialize range to track CPU page table update */
+	range->start = start;
+	range->pfns = pfns;
+	range->end = end;
+	spin_lock(&hmm->lock);
+	range->valid = true;
+	list_add_rcu(&range->list, &hmm->ranges);
+	spin_unlock(&hmm->lock);
+
+	mm_walk.vma = vma;
+	mm_walk.mm = vma->vm_mm;
+	mm_walk.private = range;
+	mm_walk.pte_entry = NULL;
+	mm_walk.test_walk = NULL;
+	mm_walk.hugetlb_entry = NULL;
+	mm_walk.pmd_entry = hmm_vma_walk_pmd;
+	mm_walk.pte_hole = hmm_vma_walk_hole;
+
+	walk_page_range(start, end, &mm_walk);
+
+	return 0;
+}
+EXPORT_SYMBOL(hmm_vma_get_pfns);
+
+/*
+ * hmm_vma_range_done() - stop tracking change to CPU page table over a range
+ * @vma: virtual memory area containing the virtual address range
+ * @range: range being tracked
+ * Returns: false if range data has been invalidated, true otherwise
+ *
+ * Range struct is used to track updates to the CPU page table after a call to
+ * either hmm_vma_get_pfns() or hmm_vma_fault(). Once the device driver is done
+ * using the data,  or wants to lock updates to the data it got from those
+ * functions, it must call the hmm_vma_range_done() function, which will then
+ * stop tracking CPU page table updates.
+ *
+ * Note that device driver must still implement general CPU page table update
+ * tracking either by using hmm_mirror (see hmm_mirror_register()) or by using
+ * the mmu_notifier API directly.
+ *
+ * CPU page table update tracking done through hmm_range is only temporary and
+ * to be used while trying to duplicate CPU page table contents for a range of
+ * virtual addresses.
+ *
+ * There are two ways to use this :
+ * again:
+ *   hmm_vma_get_pfns(vma, range, start, end, pfns);
+ *   trans = device_build_page_table_update_transaction(pfns);
+ *   device_page_table_lock();
+ *   if (!hmm_vma_range_done(vma, range)) {
+ *     device_page_table_unlock();
+ *     goto again;
+ *   }
+ *   device_commit_transaction(trans);
+ *   device_page_table_unlock();
+ *
+ * Or:
+ *   hmm_vma_get_pfns(vma, range, start, end, pfns);
+ *   device_page_table_lock();
+ *   hmm_vma_range_done(vma, range);
+ *   device_update_page_table(pfns);
+ *   device_page_table_unlock();
+ */
+bool hmm_vma_range_done(struct vm_area_struct *vma, struct hmm_range *range)
+{
+	unsigned long npages = (range->end - range->start) >> PAGE_SHIFT;
+	struct hmm *hmm;
+
+	if (range->end <= range->start) {
+		BUG();
+		return false;
+	}
+
+	hmm = hmm_register(vma->vm_mm);
+	if (!hmm) {
+		memset(range->pfns, 0, sizeof(*range->pfns) * npages);
+		return false;
+	}
+
+	spin_lock(&hmm->lock);
+	list_del_rcu(&range->list);
+	spin_unlock(&hmm->lock);
+
+	return range->valid;
+}
+EXPORT_SYMBOL(hmm_vma_range_done);
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
-- 
2.13.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
