Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id DD3C128034A
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 14:53:42 -0400 (EDT)
Received: by igbpg9 with SMTP id pg9so2254410igb.0
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 11:53:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id hv6si5193953igb.11.2015.07.17.11.53.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 11:53:42 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 07/15] HMM: add per mirror page table v4.
Date: Fri, 17 Jul 2015 14:52:17 -0400
Message-Id: <1437159145-6548-8-git-send-email-jglisse@redhat.com>
In-Reply-To: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
References: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

This patch add the per mirror page table. It also propagate CPU page
table update to this per mirror page table using mmu_notifier callback.
All update are contextualized with an HMM event structure that convey
all information needed by device driver to take proper actions (update
its own mmu to reflect changes and schedule proper flushing).

Core HMM is responsible for updating the per mirror page table once
the device driver is done with its update. Most importantly HMM will
properly propagate HMM page table dirty bit to underlying page.

Changed since v1:
  - Removed unused fence code to defer it to latter patches.

Changed since v2:
  - Use new bit flag helper for mirror page table manipulation.
  - Differentiate fork event with HMM_FORK from other events.

Changed since v3:
  - Get rid of HMM_ISDIRTY and rely on write protect instead.
  - Adapt to HMM page table changes

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
---
 include/linux/hmm.h |  83 ++++++++++++++++++++
 mm/hmm.c            | 218 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 301 insertions(+)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index b559c0b..5488fa9 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -46,6 +46,7 @@
 #include <linux/mmu_notifier.h>
 #include <linux/workqueue.h>
 #include <linux/mman.h>
+#include <linux/hmm_pt.h>
 
 
 struct hmm_device;
@@ -53,6 +54,38 @@ struct hmm_mirror;
 struct hmm;
 
 
+/*
+ * hmm_event - each event is described by a type associated with a struct.
+ */
+enum hmm_etype {
+	HMM_NONE = 0,
+	HMM_FORK,
+	HMM_MIGRATE,
+	HMM_MUNMAP,
+	HMM_DEVICE_RFAULT,
+	HMM_DEVICE_WFAULT,
+	HMM_WRITE_PROTECT,
+};
+
+/* struct hmm_event - memory event information.
+ *
+ * @list: So HMM can keep track of all active events.
+ * @start: First address (inclusive).
+ * @end: Last address (exclusive).
+ * @pte_mask: HMM pte update mask (bit(s) that are still valid).
+ * @etype: Event type (munmap, migrate, truncate, ...).
+ * @backoff: Only meaningful for device page fault.
+ */
+struct hmm_event {
+	struct list_head	list;
+	unsigned long		start;
+	unsigned long		end;
+	dma_addr_t		pte_mask;
+	enum hmm_etype		etype;
+	bool			backoff;
+};
+
+
 /* hmm_device - Each device must register one and only one hmm_device.
  *
  * The hmm_device is the link btw HMM and each device driver.
@@ -83,6 +116,54 @@ struct hmm_device_ops {
 	 * so device driver callback can not sleep.
 	 */
 	void (*free)(struct hmm_mirror *mirror);
+
+	/* update() - update device mmu following an event.
+	 *
+	 * @mirror: The mirror that link process address space with the device.
+	 * @event: The event that triggered the update.
+	 * Returns: 0 on success or error code {-EIO, -ENOMEM}.
+	 *
+	 * Called to update device page table for a range of address.
+	 * The event type provide the nature of the update :
+	 *   - Range is no longer valid (munmap).
+	 *   - Range protection changes (mprotect, COW, ...).
+	 *   - Range is unmapped (swap, reclaim, page migration, ...).
+	 *   - Device page fault.
+	 *   - ...
+	 *
+	 * Thought most device driver only need to use pte_mask as it reflects
+	 * change that will happen to the HMM page table ie :
+	 *   new_pte = old_pte & event->pte_mask;
+	 *
+	 * Device driver must not update the HMM mirror page table (except the
+	 * dirty bit see below). Core HMM will update HMM page table after the
+	 * update is done.
+	 *
+	 * Note that device must be cache coherent with system memory (snooping
+	 * in case of PCIE devices) so there should be no need for device to
+	 * flush anything.
+	 *
+	 * When write protection is turned on device driver must make sure the
+	 * hardware will no longer be able to write to the page otherwise file
+	 * system corruption may occur.
+	 *
+	 * Device must properly set the dirty bit using hmm_pte_set_bit() on
+	 * each page entry for memory that was written by the device. If device
+	 * can not properly account for write access then the dirty bit must be
+	 * set unconditionally so that proper write back of file backed page
+	 * can happen.
+	 *
+	 * Device driver must not fail lightly, any failure result in device
+	 * process being kill.
+	 *
+	 * Return 0 on success, error value otherwise :
+	 * -ENOMEM Not enough memory for performing the operation.
+	 * -EIO    Some input/output error with the device.
+	 *
+	 * All other return value trigger warning and are transformed to -EIO.
+	 */
+	int (*update)(struct hmm_mirror *mirror,
+		      struct hmm_event *event);
 };
 
 
@@ -149,6 +230,7 @@ int hmm_device_unregister(struct hmm_device *device);
  * @kref: Reference counter (private to HMM do not use).
  * @dlist: List of all hmm_mirror for same device.
  * @mlist: List of all hmm_mirror for same process.
+ * @pt: Mirror page table.
  *
  * Each device that want to mirror an address space must register one of this
  * struct for each of the address space it wants to mirror. Same device can
@@ -161,6 +243,7 @@ struct hmm_mirror {
 	struct kref		kref;
 	struct list_head	dlist;
 	struct hlist_node	mlist;
+	struct hmm_pt		pt;
 };
 
 int hmm_mirror_register(struct hmm_mirror *mirror);
diff --git a/mm/hmm.c b/mm/hmm.c
index 198fe37..08e9501 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -45,6 +45,50 @@
 #include "internal.h"
 
 static struct mmu_notifier_ops hmm_notifier_ops;
+static void hmm_mirror_kill(struct hmm_mirror *mirror);
+static inline int hmm_mirror_update(struct hmm_mirror *mirror,
+				    struct hmm_event *event);
+static void hmm_mirror_update_pt(struct hmm_mirror *mirror,
+				 struct hmm_event *event);
+
+
+/* hmm_event - use to track information relating to an event.
+ *
+ * Each change to cpu page table or fault from a device is considered as an
+ * event by hmm. For each event there is a common set of things that need to
+ * be tracked. The hmm_event struct centralize those and the helper functions
+ * help dealing with all this.
+ */
+
+static inline int hmm_event_init(struct hmm_event *event,
+				 struct hmm *hmm,
+				 unsigned long start,
+				 unsigned long end,
+				 enum hmm_etype etype)
+{
+	event->start = start & PAGE_MASK;
+	event->end = min(end, hmm->vm_end);
+	if (event->start >= event->end)
+		return -EINVAL;
+	event->etype = etype;
+	event->pte_mask = (dma_addr_t)-1ULL;
+	switch (etype) {
+	case HMM_DEVICE_RFAULT:
+	case HMM_DEVICE_WFAULT:
+		break;
+	case HMM_FORK:
+	case HMM_WRITE_PROTECT:
+		event->pte_mask ^= (1 << HMM_PTE_WRITE_BIT);
+		break;
+	case HMM_MIGRATE:
+	case HMM_MUNMAP:
+		event->pte_mask = 0;
+		break;
+	default:
+		return -EINVAL;
+	}
+	return 0;
+}
 
 
 /* hmm - core HMM functions.
@@ -123,6 +167,27 @@ static inline struct hmm *hmm_unref(struct hmm *hmm)
 	return NULL;
 }
 
+static void hmm_update(struct hmm *hmm, struct hmm_event *event)
+{
+	struct hmm_mirror *mirror;
+
+	/* Is this hmm already fully stop ? */
+	if (hmm->mm->hmm != hmm)
+		return;
+
+again:
+	down_read(&hmm->rwsem);
+	hlist_for_each_entry(mirror, &hmm->mirrors, mlist)
+		if (hmm_mirror_update(mirror, event)) {
+			mirror = hmm_mirror_ref(mirror);
+			up_read(&hmm->rwsem);
+			hmm_mirror_kill(mirror);
+			hmm_mirror_unref(&mirror);
+			goto again;
+		}
+	up_read(&hmm->rwsem);
+}
+
 
 /* hmm_notifier - HMM callback for mmu_notifier tracking change to process mm.
  *
@@ -139,6 +204,7 @@ static void hmm_notifier_release(struct mmu_notifier *mn, struct mm_struct *mm)
 	down_write(&hmm->rwsem);
 	while (hmm->mirrors.first) {
 		struct hmm_mirror *mirror;
+		struct hmm_event event;
 
 		/*
 		 * Here we are holding the mirror reference from the mirror
@@ -151,6 +217,10 @@ static void hmm_notifier_release(struct mmu_notifier *mn, struct mm_struct *mm)
 		hlist_del_init(&mirror->mlist);
 		up_write(&hmm->rwsem);
 
+		/* Make sure everything is unmapped. */
+		hmm_event_init(&event, mirror->hmm, 0, -1UL, HMM_MUNMAP);
+		hmm_mirror_update(mirror, &event);
+
 		mirror->device->ops->release(mirror);
 		hmm_mirror_unref(&mirror);
 
@@ -161,8 +231,89 @@ static void hmm_notifier_release(struct mmu_notifier *mn, struct mm_struct *mm)
 	hmm_unref(hmm);
 }
 
+static void hmm_mmu_mprot_to_etype(struct mm_struct *mm,
+				   unsigned long addr,
+				   enum mmu_event mmu_event,
+				   enum hmm_etype *etype)
+{
+	struct vm_area_struct *vma;
+
+	vma = find_vma(mm, addr);
+	if (!vma || vma->vm_start > addr || !(vma->vm_flags & VM_READ)) {
+		*etype = HMM_MUNMAP;
+		return;
+	}
+
+	if (!(vma->vm_flags & VM_WRITE)) {
+		*etype = HMM_WRITE_PROTECT;
+		return;
+	}
+
+	*etype = HMM_NONE;
+}
+
+static void hmm_notifier_invalidate_range_start(struct mmu_notifier *mn,
+					struct mm_struct *mm,
+					const struct mmu_notifier_range *range)
+{
+	struct hmm_event event;
+	unsigned long start = range->start, end = range->end;
+	struct hmm *hmm;
+
+	hmm = container_of(mn, struct hmm, mmu_notifier);
+	if (start >= hmm->vm_end)
+		return;
+
+	switch (range->event) {
+	case MMU_FORK:
+		event.etype = HMM_FORK;
+		break;
+	case MMU_MUNLOCK:
+		/* Still same physical ram backing same address. */
+		return;
+	case MMU_MPROT:
+		hmm_mmu_mprot_to_etype(mm, start, range->event, &event.etype);
+		if (event.etype == HMM_NONE)
+			return;
+		break;
+	case MMU_CLEAR_SOFT_DIRTY:
+	case MMU_WRITE_BACK:
+	case MMU_KSM_WRITE_PROTECT:
+		event.etype = HMM_WRITE_PROTECT;
+		break;
+	case MMU_HUGE_PAGE_SPLIT:
+	case MMU_MUNMAP:
+		event.etype = HMM_MUNMAP;
+		break;
+	case MMU_MIGRATE:
+	default:
+		event.etype = HMM_MIGRATE;
+		break;
+	}
+
+	hmm_event_init(&event, hmm, start, end, event.etype);
+
+	hmm_update(hmm, &event);
+}
+
+static void hmm_notifier_invalidate_page(struct mmu_notifier *mn,
+					 struct mm_struct *mm,
+					 unsigned long addr,
+					 struct page *page,
+					 enum mmu_event mmu_event)
+{
+	struct mmu_notifier_range range;
+
+	range.start = addr & PAGE_MASK;
+	range.end = range.start + PAGE_SIZE;
+	range.event = mmu_event;
+	hmm_notifier_invalidate_range_start(mn, mm, &range);
+}
+
 static struct mmu_notifier_ops hmm_notifier_ops = {
 	.release		= hmm_notifier_release,
+	.invalidate_page	= hmm_notifier_invalidate_page,
+	.invalidate_range_start	= hmm_notifier_invalidate_range_start,
 };
 
 
@@ -192,6 +343,7 @@ static void hmm_mirror_destroy(struct kref *kref)
 	mirror = container_of(kref, struct hmm_mirror, kref);
 	device = mirror->device;
 
+	hmm_pt_fini(&mirror->pt);
 	hmm_unref(mirror->hmm);
 
 	spin_lock(&device->lock);
@@ -211,6 +363,59 @@ void hmm_mirror_unref(struct hmm_mirror **mirror)
 }
 EXPORT_SYMBOL(hmm_mirror_unref);
 
+static inline int hmm_mirror_update(struct hmm_mirror *mirror,
+				    struct hmm_event *event)
+{
+	struct hmm_device *device = mirror->device;
+	int ret = 0;
+
+	ret = device->ops->update(mirror, event);
+	hmm_mirror_update_pt(mirror, event);
+	return ret;
+}
+
+static void hmm_mirror_update_pt(struct hmm_mirror *mirror,
+				 struct hmm_event *event)
+{
+	unsigned long addr;
+	struct hmm_pt_iter iter;
+
+	hmm_pt_iter_init(&iter, &mirror->pt);
+	for (addr = event->start; addr != event->end;) {
+		unsigned long next = event->end;
+		dma_addr_t *hmm_pte;
+
+		hmm_pte = hmm_pt_iter_lookup(&iter, addr, &next);
+		if (!hmm_pte) {
+			addr = next;
+			continue;
+		}
+		/*
+		 * The directory lock protect against concurrent clearing of
+		 * page table bit flags. Exceptions being the dirty bit and
+		 * the device driver private flags.
+		 */
+		hmm_pt_iter_directory_lock(&iter);
+		do {
+			if (!hmm_pte_test_valid_pfn(hmm_pte))
+				continue;
+			if (hmm_pte_test_and_clear_dirty(hmm_pte) &&
+			    hmm_pte_test_write(hmm_pte)) {
+				struct page *page;
+
+				page = pfn_to_page(hmm_pte_pfn(*hmm_pte));
+				set_page_dirty(page);
+			}
+			*hmm_pte &= event->pte_mask;
+			if (hmm_pte_test_valid_pfn(hmm_pte))
+				continue;
+			hmm_pt_iter_directory_unref(&iter);
+		} while (addr += PAGE_SIZE, hmm_pte++, addr != next);
+		hmm_pt_iter_directory_unlock(&iter);
+	}
+	hmm_pt_iter_fini(&iter);
+}
+
 /* hmm_mirror_register() - register mirror against current process for a device.
  *
  * @mirror: The mirror struct being registered.
@@ -242,6 +447,11 @@ int hmm_mirror_register(struct hmm_mirror *mirror)
 	 * necessary to make the error path easier for driver and for hmm.
 	 */
 	kref_init(&mirror->kref);
+	mirror->pt.last = TASK_SIZE - 1;
+	if (hmm_pt_init(&mirror->pt)) {
+		kfree(mirror);
+		return -ENOMEM;
+	}
 	INIT_HLIST_NODE(&mirror->mlist);
 	INIT_LIST_HEAD(&mirror->dlist);
 	spin_lock(&mirror->device->lock);
@@ -278,6 +488,7 @@ int hmm_mirror_register(struct hmm_mirror *mirror)
 		hmm_unref(hmm);
 		goto error;
 	}
+	BUG_ON(mirror->pt.last >= hmm->vm_end);
 	return 0;
 
 error:
@@ -298,8 +509,15 @@ static void hmm_mirror_kill(struct hmm_mirror *mirror)
 
 	down_write(&hmm->rwsem);
 	if (!hlist_unhashed(&mirror->mlist)) {
+		struct hmm_event event;
+
 		hlist_del_init(&mirror->mlist);
 		up_write(&hmm->rwsem);
+
+		/* Make sure everything is unmapped. */
+		hmm_event_init(&event, mirror->hmm, 0, -1UL, HMM_MUNMAP);
+		hmm_mirror_update(mirror, &event);
+
 		device->ops->release(mirror);
 		hmm_mirror_unref(&mirror);
 	} else
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
