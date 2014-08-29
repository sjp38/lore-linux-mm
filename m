Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD206B0055
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 15:10:40 -0400 (EDT)
Received: by mail-qc0-f180.google.com with SMTP id c9so2908481qcz.11
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:10:39 -0700 (PDT)
Received: from mail-qa0-x233.google.com (mail-qa0-x233.google.com [2607:f8b0:400d:c00::233])
        by mx.google.com with ESMTPS id y2si1475774qas.5.2014.08.29.12.10.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 Aug 2014 12:10:39 -0700 (PDT)
Received: by mail-qa0-f51.google.com with SMTP id j7so2502437qaq.38
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:10:39 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [RFC PATCH 6/6] hmm: add support for iommu domain.
Date: Fri, 29 Aug 2014 15:10:15 -0400
Message-Id: <1409339415-3626-7-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1409339415-3626-1-git-send-email-j.glisse@gmail.com>
References: <1409339415-3626-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Haggai Eran <haggaie@mellanox.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

This add support for grouping mirror of a process by share iommu domain
and mapping the necessary page into the iommu thus allowing hmm user to
share dma mapping of process pages and avoiding each of them to have to
individualy map each pages.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Joerg Roedel <joro@8bytes.org>
---
 include/linux/hmm.h |   8 ++
 mm/hmm.c            | 375 +++++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 368 insertions(+), 15 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index f7c379b..3d85721 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -49,10 +49,12 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/mman.h>
+#include <linux/iommu.h>
 
 
 struct hmm_device;
 struct hmm_device_ops;
+struct hmm_domain;
 struct hmm_mirror;
 struct hmm_event;
 struct hmm;
@@ -119,12 +121,14 @@ struct hmm_event {
  * @ptp: The page directory page struct.
  * @start: First address (inclusive).
  * @end: Last address (exclusive).
+ * @iova_base: base io virtual address for this range.
  */
 struct hmm_range {
 	unsigned long		*pte;
 	struct page		*ptp;
 	unsigned long		start;
 	unsigned long		end;
+	dma_addr_t		iova_base;
 };
 
 static inline unsigned long hmm_range_size(struct hmm_range *range)
@@ -288,6 +292,7 @@ struct hmm_device_ops {
 
 /* struct hmm_device - per device hmm structure
  *
+ * @iommu_domain: Iommu domain this device is associated with (NULL if none).
  * @name: Device name (uniquely identify the device on the system).
  * @ops: The hmm operations callback.
  * @mirrors: List of all active mirrors for the device.
@@ -297,6 +302,7 @@ struct hmm_device_ops {
  * struct (only once).
  */
 struct hmm_device {
+	struct iommu_domain		*iommu_domain;
 	const char			*name;
 	const struct hmm_device_ops	*ops;
 	struct list_head		mirrors;
@@ -317,6 +323,7 @@ int hmm_device_unregister(struct hmm_device *device);
 /* struct hmm_mirror - per device and per mm hmm structure
  *
  * @device: The hmm_device struct this hmm_mirror is associated to.
+ * @domain: The hmm domain this mirror belong to.
  * @hmm: The hmm struct this hmm_mirror is associated to.
  * @dlist: List of all hmm_mirror for same device.
  * @mlist: List of all hmm_mirror for same process.
@@ -329,6 +336,7 @@ int hmm_device_unregister(struct hmm_device *device);
  */
 struct hmm_mirror {
 	struct hmm_device	*device;
+	struct hmm_domain	*domain;
 	struct hmm		*hmm;
 	struct list_head	dlist;
 	struct list_head	mlist;
diff --git a/mm/hmm.c b/mm/hmm.c
index d29a2d9..cc6970b 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -49,8 +49,27 @@
 static struct srcu_struct srcu;
 
 
+/* struct hmm_domain - per iommu domain hmm struct.
+ *
+ * @domain: Iommu domain.
+ * @mirrors: List of all mirror of different devices in same domain.
+ * @iommu_pt: Page table storing the pfn of page use by iommu page table.
+ * @list: Head for hmm list of all hmm_domain.
+ *
+ * Device that belong to the same iommu domain and that mirror the same process
+ * are grouped together so that they can share the same iommu resources.
+ */
+struct hmm_domain {
+	struct iommu_domain	*iommu_domain;
+	struct gpt		pt;
+	struct list_head	mirrors;
+	struct list_head	list;
+};
+
+
 /* struct hmm - per mm_struct hmm structure
  *
+ * @domains: List of hmm_domain.
  * @mm: The mm struct this hmm is associated with.
  * @kref: Reference counter
  * @lock: Serialize the mirror list modifications.
@@ -65,6 +84,7 @@ static struct srcu_struct srcu;
  * the process address space.
  */
 struct hmm {
+	struct list_head	domains;
 	struct mm_struct	*mm;
 	struct kref		kref;
 	spinlock_t		lock;
@@ -179,6 +199,181 @@ static void hmm_range_clear(struct hmm_range *range, struct hmm *hmm)
 }
 
 
+/* hmm_domaine - iommu domain helper functions.
+ *
+ * To simplify and share resources hmm handle iommu on behalf of device.
+ */
+
+#define HMM_DPTE_LOCK_BIT	0UL
+#define HMM_DPTE_VALID_BIT	1UL
+
+static inline bool hmm_dpte_is_valid(const volatile unsigned long *dpte)
+{
+	return test_bit(HMM_DPTE_VALID_BIT, dpte);
+}
+
+static inline void hmm_dpte_lock(volatile unsigned long *dpte, struct hmm *hmm)
+{
+	do {
+		if (likely(!test_and_set_bit_lock(HMM_DPTE_LOCK_BIT, dpte)))
+			return;
+		wait_event(hmm->wait_queue, !test_bit(HMM_DPTE_LOCK_BIT, dpte));
+	} while (1);
+}
+
+static inline void hmm_dpte_unlock(volatile unsigned long *dpte,
+				   struct hmm *hmm)
+{
+	clear_bit(HMM_DPTE_LOCK_BIT, dpte);
+	wake_up(&hmm->wait_queue);
+}
+
+static inline bool hmm_dpte_clear_valid(volatile unsigned long *dpte)
+{
+	return test_and_clear_bit(HMM_DPTE_VALID_BIT, dpte);
+}
+
+static int hmm_domain_update_or_map(struct hmm_domain *domain,
+				    struct hmm *hmm,
+				    struct page *dptp,
+				    volatile unsigned long *dpte,
+				    unsigned long *pfns)
+{
+	dma_addr_t iova;
+	int ret;
+
+	pfns = (unsigned long *)((unsigned long)pfns & PAGE_MASK);
+	hmm_dpte_lock(dpte, hmm);
+	if (hmm_pte_is_valid_smem(dpte)) {
+		int n;
+
+		iova = *dpte & PAGE_MASK;
+		n = iommu_domain_update_directory(domain->iommu_domain,
+						  1UL << GPT_PDIR_NBITS,
+						  pfns, PAGE_MASK, PAGE_SHIFT,
+						  1 << HMM_PTE_VALID_SMEM_BIT,
+						  1 << HMM_PTE_WRITE_BIT,
+						  iova);
+		if (n > 0)
+			gpt_ptp_batch_ref(&domain->pt, dptp, n);
+		else if (n < 0)
+			gpt_ptp_batch_unref(&domain->pt, dptp, -n);
+		hmm_dpte_unlock(dpte, hmm);
+		return 0;
+	}
+
+	ret = iommu_domain_map_directory(domain->iommu_domain,
+					 1UL << GPT_PDIR_NBITS,
+					 pfns, PAGE_MASK, PAGE_SHIFT,
+					 1 << HMM_PTE_VALID_SMEM_BIT,
+					 1 << HMM_PTE_WRITE_BIT,
+					 &iova);
+	if (ret > 0) {
+		gpt_ptp_batch_ref(&domain->pt, dptp, ret);
+		ret = 0;
+	}
+	hmm_dpte_unlock(dpte, hmm);
+	return ret;
+}
+
+static bool hmm_domain_do_update(struct hmm_domain *domain,
+				 struct hmm *hmm,
+				 struct page *dptp,
+				 volatile unsigned long *dpte,
+				 unsigned long *pfns)
+{
+	bool present = false;
+
+	pfns = (unsigned long *)((unsigned long)pfns & PAGE_MASK);
+	hmm_dpte_lock(dpte, hmm);
+	if (hmm_pte_is_valid_smem(dpte)) {
+		dma_addr_t iova = *dpte & PAGE_MASK;
+		int n;
+
+		present = true;
+		n = iommu_domain_update_directory(domain->iommu_domain,
+						  1UL << GPT_PDIR_NBITS,
+						  pfns, PAGE_MASK, PAGE_SHIFT,
+						  1 << HMM_PTE_VALID_SMEM_BIT,
+						  1 << HMM_PTE_WRITE_BIT,
+						  iova);
+		if (n > 0)
+			gpt_ptp_batch_ref(&domain->pt, dptp, n);
+		else if (n < 0)
+			gpt_ptp_batch_unref(&domain->pt, dptp, -n);
+	}
+	hmm_dpte_unlock(dpte, hmm);
+
+	return present;
+}
+
+static void hmm_domain_update(struct hmm_domain *domain,
+			      struct hmm *hmm,
+			      const struct hmm_event *event,
+			      struct gpt_iter *iter)
+{
+	struct gpt_lock dlock;
+	struct gpt_iter diter;
+	unsigned long addr;
+
+	dlock.start = event->start;
+	dlock.end = event->end - 1UL;
+	BUG_ON(gpt_lock_update(&domain->pt, &dlock));
+	gpt_iter_init(&diter, &domain->pt, &dlock);
+
+	BUG_ON(!gpt_iter_first(iter, event->start, event->end - 1UL));
+	for (addr = iter->pte_addr; iter->pte;) {
+		if (gpt_iter_addr(&diter, addr))
+			hmm_domain_do_update(domain, hmm, diter.ptp,
+					     diter.pte, iter->pte);
+
+		addr = min(gpt_pdp_end(&domain->pt, iter->ptp) + 1UL,
+			   event->end);
+		gpt_iter_first(iter, addr, event->end - 1UL);
+	}
+
+	gpt_unlock_update(&domain->pt, &dlock);
+}
+
+static void hmm_domain_unmap(struct hmm_domain *domain,
+			     struct hmm *hmm,
+			     const struct hmm_event *event)
+{
+	struct gpt_lock dlock;
+	struct gpt_iter diter;
+
+	dlock.start = event->start;
+	dlock.end = event->end - 1UL;
+	BUG_ON(gpt_lock_update(&domain->pt, &dlock));
+	gpt_iter_init(&diter, &domain->pt, &dlock);
+	if (!gpt_iter_first(&diter, dlock.start, dlock.end))
+		goto out;
+	do {
+		unsigned long npages, *dpte;
+		dma_addr_t iova;
+		int n;
+
+		dpte = diter.pte;
+		iova = *dpte & PAGE_MASK;
+		hmm_dpte_lock(dpte, hmm);
+		if (!hmm_dpte_clear_valid(dpte)) {
+			hmm_dpte_unlock(dpte, hmm);
+			continue;
+		}
+
+		npages = 1UL << (PAGE_SHIFT - hmm->pt.pte_shift);
+		n = iommu_domain_unmap_directory(domain->iommu_domain,
+						 npages, iova);
+		if (n)
+			gpt_ptp_batch_unref(&domain->pt, diter.ptp, n);
+		hmm_dpte_unlock(dpte, hmm);
+	} while (gpt_iter_next(&diter));
+
+out:
+	gpt_unlock_update(&domain->pt, &dlock);
+}
+
+
 /* hmm - core hmm functions.
  *
  * Core hmm functions that deal with all the process mm activities and use
@@ -194,6 +389,7 @@ static int hmm_init(struct hmm *hmm, struct mm_struct *mm)
 	kref_init(&hmm->kref);
 	INIT_LIST_HEAD(&hmm->device_faults);
 	INIT_LIST_HEAD(&hmm->invalidations);
+	INIT_LIST_HEAD(&hmm->domains);
 	INIT_LIST_HEAD(&hmm->mirrors);
 	spin_lock_init(&hmm->lock);
 	init_waitqueue_head(&hmm->wait_queue);
@@ -219,23 +415,114 @@ static int hmm_init(struct hmm *hmm, struct mm_struct *mm)
 	return __mmu_notifier_register(&hmm->mmu_notifier, mm);
 }
 
+static struct hmm_domain *hmm_find_domain_locked(struct hmm *hmm,
+						 struct iommu_domain *iommu_domain)
+{
+	struct hmm_domain *domain;
+
+	list_for_each_entry (domain, &hmm->domains, list)
+		if (domain->iommu_domain == iommu_domain)
+			return domain;
+	return NULL;
+}
+
+static struct hmm_domain *hmm_new_domain(struct hmm *hmm)
+{
+	struct hmm_domain *domain;
+
+	domain = kmalloc(sizeof(*domain), GFP_KERNEL);
+	if (!domain)
+		return NULL;
+	domain->pt.max_addr = 0;
+	INIT_LIST_HEAD(&domain->list);
+	INIT_LIST_HEAD(&domain->mirrors);
+	/*
+	 * The domain page table store a dma address for each pld (page lower
+	 * directory level) of the hmm page table.
+	 */
+	domain->pt.max_addr = hmm->pt.max_addr;
+	domain->pt.page_shift = 2 * PAGE_SHIFT - (ffs(BITS_PER_LONG) - 4);
+	domain->pt.pfn_invalid = 0;
+	domain->pt.pfn_mask = PAGE_MASK;
+	domain->pt.pfn_shift = PAGE_SHIFT;
+	domain->pt.pfn_valid = 1UL << HMM_PTE_VALID_SMEM_BIT;
+	domain->pt.pte_shift = ffs(BITS_PER_LONG) - 4;
+	domain->pt.user_ops = NULL;
+	if (gpt_init(&domain->pt)) {
+		kfree(domain);
+		return NULL;
+	}
+	return domain;
+}
+
+static void hmm_free_domain_locked(struct hmm *hmm, struct hmm_domain *domain)
+{
+	struct hmm_event event;
+
+	BUG_ON(!list_empty(&domain->mirrors));
+
+	event.start = 0;
+	event.end = hmm->mm->highest_vm_end;
+	event.etype = HMM_MUNMAP;
+	hmm_domain_unmap(domain, hmm, &event);
+
+	list_del(&domain->list);
+	gpt_free(&domain->pt);
+	kfree(domain);
+}
+
 static void hmm_del_mirror_locked(struct hmm *hmm, struct hmm_mirror *mirror)
 {
 	list_del_rcu(&mirror->mlist);
+	if (mirror->domain && list_empty(&mirror->domain->mirrors))
+		hmm_free_domain_locked(hmm, mirror->domain);
+	mirror->domain = NULL;
 }
 
 static int hmm_add_mirror(struct hmm *hmm, struct hmm_mirror *mirror)
 {
+	struct hmm_device *device = mirror->device;
+	struct hmm_domain *domain;
 	struct hmm_mirror *tmp_mirror;
 
+	mirror->domain = NULL;
+
 	spin_lock(&hmm->lock);
-	list_for_each_entry_rcu (tmp_mirror, &hmm->mirrors, mlist)
-		if (tmp_mirror->device == mirror->device) {
-			/* Same device can mirror only once. */
+	if (device->iommu_domain) {
+		domain = hmm_find_domain_locked(hmm, device->iommu_domain);
+		if (!domain) {
+			struct hmm_domain *tmp_domain;
+
 			spin_unlock(&hmm->lock);
-			return -EINVAL;
+			tmp_domain = hmm_new_domain(hmm);
+			if (!tmp_domain)
+				return -ENOMEM;
+			spin_lock(&hmm->lock);
+			domain = hmm_find_domain_locked(hmm,
+							device->iommu_domain);
+			if (!domain) {
+				domain = tmp_domain;
+				list_add_tail(&domain->list, &hmm->domains);
+			} else
+				hmm_free_domain_locked(hmm, tmp_domain);
 		}
-	list_add_rcu(&mirror->mlist, &hmm->mirrors);
+		list_for_each_entry_rcu (tmp_mirror, &domain->mirrors, mlist)
+			if (tmp_mirror->device == mirror->device) {
+				/* Same device can mirror only once. */
+				spin_unlock(&hmm->lock);
+				return -EINVAL;
+			}
+		mirror->domain = domain;
+		list_add_rcu(&mirror->mlist, &domain->mirrors);
+	} else {
+		list_for_each_entry_rcu (tmp_mirror, &hmm->mirrors, mlist)
+			if (tmp_mirror->device == mirror->device) {
+				/* Same device can mirror only once. */
+				spin_unlock(&hmm->lock);
+				return -EINVAL;
+			}
+		list_add_rcu(&mirror->mlist, &hmm->mirrors);
+	}
 	spin_unlock(&hmm->lock);
 
 	return 0;
@@ -370,10 +657,12 @@ static void hmm_end_migrate(struct hmm *hmm, struct hmm_event *ievent)
 static void hmm_update(struct hmm *hmm,
 		       struct hmm_event *event)
 {
+	struct hmm_domain *domain;
 	struct hmm_range range;
 	struct gpt_lock lock;
 	struct gpt_iter iter;
 	struct gpt *pt = &hmm->pt;
+	int id;
 
 	/* This hmm is already fully stop. */
 	if (hmm->mm->hmm != hmm)
@@ -414,19 +703,34 @@ static void hmm_update(struct hmm *hmm,
 
 	hmm_event_wait(event);
 
-	if (event->etype == HMM_MUNMAP || event->etype == HMM_MIGRATE) {
-		BUG_ON(!gpt_iter_first(&iter, event->start, event->end - 1UL));
-		for (range.start = iter.pte_addr; iter.pte;) {
-			range.pte = iter.pte;
-			range.ptp = iter.ptp;
-			range.end = min(gpt_pdp_end(pt, iter.ptp) + 1UL,
-					event->end);
-			hmm_range_clear(&range, hmm);
-			range.start = range.end;
-			gpt_iter_first(&iter, range.start, event->end - 1UL);
+	if (event->etype == HMM_WRITE_PROTECT) {
+		id = srcu_read_lock(&srcu);
+		list_for_each_entry(domain, &hmm->domains, list) {
+			hmm_domain_update(domain, hmm, event, &iter);
 		}
+		srcu_read_unlock(&srcu, id);
 	}
 
+	if (event->etype != HMM_MUNMAP && event->etype != HMM_MIGRATE)
+		goto out;
+
+	BUG_ON(!gpt_iter_first(&iter, event->start, event->end - 1UL));
+	for (range.start = iter.pte_addr; iter.pte;) {
+		range.pte = iter.pte;
+		range.ptp = iter.ptp;
+		range.end = min(gpt_pdp_end(pt, iter.ptp) + 1UL,
+				event->end);
+		hmm_range_clear(&range, hmm);
+		range.start = range.end;
+		gpt_iter_first(&iter, range.start, event->end - 1UL);
+	}
+
+	id = srcu_read_lock(&srcu);
+	list_for_each_entry(domain, &hmm->domains, list)
+		hmm_domain_unmap(domain, hmm, event);
+	srcu_read_unlock(&srcu, id);
+
+out:
 	gpt_unlock_update(&hmm->pt, &lock);
 	if (event->etype != HMM_MIGRATE)
 		hmm_end_invalidations(hmm, event);
@@ -829,16 +1133,46 @@ void hmm_mirror_release(struct hmm_mirror *mirror)
 }
 EXPORT_SYMBOL(hmm_mirror_release);
 
+static int hmm_mirror_domain_update(struct hmm_mirror *mirror,
+				    struct hmm_range *range,
+				    struct gpt_iter *diter)
+{
+	unsigned long *dpte, offset;
+	struct hmm *hmm = mirror->hmm;
+	int ret;
+
+	BUG_ON(!gpt_iter_addr(diter, range->start));
+	offset = gpt_pdp_start(&mirror->domain->pt, diter->ptp) - range->start;
+	ret = hmm_domain_update_or_map(mirror->domain, hmm, diter->ptp,
+				       diter->pte, range->pte);
+	dpte = diter->pte;
+	range->iova_base = (*dpte & PAGE_MASK) + offset;
+	return ret;
+}
+
 static int hmm_mirror_update(struct hmm_mirror *mirror,
 			     struct hmm_event *event,
 			     unsigned long *start,
 			     struct gpt_iter *iter)
 {
 	unsigned long addr = *start & PAGE_MASK;
+	struct gpt_lock dlock;
+	struct gpt_iter diter;
 
 	if (!gpt_iter_addr(iter, addr))
 		return -EINVAL;
 
+	if (mirror->domain) {
+		int ret;
+
+		dlock.start = event->start;
+		dlock.end = event->end;
+		ret = gpt_lock_fault(&mirror->domain->pt, &dlock);
+		if (ret)
+			return ret;
+		gpt_iter_init(&diter, &mirror->domain->pt, &dlock);
+	}
+
 	do {
 		struct hmm_device *device = mirror->device;
 		unsigned long *pte = iter->pte;
@@ -864,6 +1198,14 @@ static int hmm_mirror_update(struct hmm_mirror *mirror,
 			}
 		}
 
+		if (mirror->domain) {
+			int ret;
+
+			ret = hmm_mirror_domain_update(mirror, &range, &diter);
+			if (ret)
+				return ret;
+		}
+
 		fence = device->ops->update(mirror, event, &range);
 		if (fence) {
 			if (IS_ERR(fence)) {
@@ -876,6 +1218,9 @@ static int hmm_mirror_update(struct hmm_mirror *mirror,
 
 	} while (addr < event->end && gpt_iter_addr(iter, addr));
 
+	if (mirror->domain)
+		gpt_unlock_fault(&mirror->domain->pt, &dlock);
+
 	*start = addr;
 	return 0;
 }
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
