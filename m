Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3B0E76B0080
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 11:49:33 -0500 (EST)
Received: by mail-qc0-f175.google.com with SMTP id b13so4046230qcw.34
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 08:49:33 -0800 (PST)
Received: from mail-qc0-x22f.google.com (mail-qc0-x22f.google.com. [2607:f8b0:400d:c01::22f])
        by mx.google.com with ESMTPS id 31si20531671qgi.56.2014.12.22.08.49.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 22 Dec 2014 08:49:31 -0800 (PST)
Received: by mail-qc0-f175.google.com with SMTP id b13so4030871qcw.6
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 08:49:31 -0800 (PST)
From: j.glisse@gmail.com
Subject: [PATCH 5/7] HMM: add per mirror page table.
Date: Mon, 22 Dec 2014 11:48:59 -0500
Message-Id: <1419266940-5440-6-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1419266940-5440-1-git-send-email-j.glisse@gmail.com>
References: <1419266940-5440-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

This patch add the per mirror page table. It also propagate CPU page table
update to this per mirror page table using mmu_notifier callback. All update
are contextualized with an HMM event structure that convey all information
needed by device driver to take proper actions (update its own mmu to reflect
changes and schedule proper flushing).

Core HMM is responsible for updating the per mirror page table once the device
driver is done with its update. Most importantly HMM will properly propagate
HMM page table dirty bit to underlying page.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
---
 include/linux/hmm.h | 136 +++++++++++++++++++++++++++
 mm/hmm.c            | 263 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 399 insertions(+)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 8eddc15..dd34572 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -46,12 +46,65 @@
 #include <linux/mmu_notifier.h>
 #include <linux/workqueue.h>
 #include <linux/mman.h>
+#include <linux/hmm_pt.h>
 
 
 struct hmm_device;
 struct hmm_mirror;
+struct hmm_fence;
 struct hmm;
 
+/* hmm_fence - Device driver fence allowing to batch update and delay wait.
+ *
+ * @mirror: The HMM mirror this fence is associated with.
+ * @list: List of fence.
+ *
+ * Each time HMM callback into a device driver for update the device driver can
+ * return fence which core HMM will wait on. This allow HMM to batch update to
+ * several different device driver and then wait for each of them to complete.
+ *
+ * The hmm_fence structure is intended to be embedded inside a device driver
+ * specific fence structure.
+ */
+struct hmm_fence {
+	struct hmm_mirror	*mirror;
+	struct list_head	list;
+};
+
+
+/*
+ * hmm_event - each event is described by a type associated with a struct.
+ */
+enum hmm_etype {
+	HMM_NONE = 0,
+	HMM_ISDIRTY,
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
+ * @fences: List of device fences associated with this event.
+ * @pte_mask: HMM pte update mask (bit(s) that are still valid).
+ * @etype: Event type (munmap, migrate, truncate, ...).
+ * @backoff: Only meaningful for device page fault.
+ */
+struct hmm_event {
+	struct list_head	list;
+	unsigned long		start;
+	unsigned long		end;
+	struct list_head	fences;
+	dma_addr_t		pte_mask;
+	enum hmm_etype		etype;
+	bool			backoff;
+};
+
 
 /* hmm_device - Each device must register one and only one hmm_device.
  *
@@ -72,6 +125,87 @@ struct hmm_device_ops {
 	 * from the mirror page table.
 	 */
 	void (*release)(struct hmm_mirror *mirror);
+
+	/* fence_wait() - to wait on device driver fence.
+	 *
+	 * @fence: The device driver fence struct.
+	 * Returns: 0 on success,-EIO on error, -EAGAIN to wait again.
+	 *
+	 * Called when hmm want to wait for all operations associated with a
+	 * fence to complete (including device cache flush if the event mandate
+	 * it).
+	 *
+	 * Device driver must free fence and associated resources if it returns
+	 * something else thant -EAGAIN. On -EAGAIN the fence must not be free
+	 * as hmm will call back again.
+	 *
+	 * Return error if scheduled operation failed or if need to wait again.
+	 * -EIO Some input/output error with the device.
+	 * -EAGAIN The fence not yet signaled, hmm reschedule waiting thread.
+	 *
+	 * All other return value trigger warning and are transformed to -EIO.
+	 */
+	int (*fence_wait)(struct hmm_fence *fence);
+
+	/* fence_ref() - take a reference fence structure.
+	 *
+	 * @fence: Fence structure hmm is referencing.
+	 */
+	void (*fence_ref)(struct hmm_fence *fence);
+
+	/* fence_unref() - drop a reference fence structure.
+	 *
+	 * @fence: Fence structure hmm is dereferencing.
+	 */
+	void (*fence_unref)(struct hmm_fence *fence);
+
+	/* update() - update device mmu following an event.
+	 *
+	 * @mirror: The mirror that link process address space with the device.
+	 * @event: The event that triggered the update.
+	 * Returns: Valid fence ptr or NULL on success otherwise ERR_PTR.
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
+	 * Device driver must not update the HMM mirror page table. Core HMM
+	 * will update HMM page table after the update is done (ie if a fence
+	 * is returned after ->fence_wait() report fence is done).
+	 *
+	 * Any event that block further write to the memory must also trigger a
+	 * device cache flush and everything has to be flush to local memory by
+	 * the time the wait callback return (if this callback returned a fence
+	 * otherwise everything must be flush by the time the callback return).
+	 *
+	 * Device must properly set the dirty bit using hmm_pte_mk_dirty helper
+	 * on each HMM page table entry.
+	 *
+	 * The driver should return a fence pointer or NULL on success. Device
+	 * driver should return fence and delay wait for the operation to the
+	 * fence wait callback. Returning a fence allow hmm to batch update to
+	 * several devices and delay wait on those once they all have scheduled
+	 * the update.
+	 *
+	 * Device driver must not fail lightly, any failure result in device
+	 * process being kill.
+	 *
+	 * Return fence or NULL on success, error value otherwise :
+	 * -ENOMEM Not enough memory for performing the operation.
+	 * -EIO    Some input/output error with the device.
+	 *
+	 * All other return value trigger warning and are transformed to -EIO.
+	 */
+	struct hmm_fence *(*update)(struct hmm_mirror *mirror,
+				    const struct hmm_event *event);
 };
 
 /* struct hmm_device - per device HMM structure
@@ -108,6 +242,7 @@ int hmm_device_unregister(struct hmm_device *device);
  * @hmm: The hmm struct this hmm_mirror is associated to.
  * @dlist: List of all hmm_mirror for same device.
  * @mlist: List of all hmm_mirror for same process.
+ * @pt: Mirror page table.
  *
  * Each device that want to mirror an address space must register one of this
  * struct for each of the address space it wants to mirror. Same device can
@@ -119,6 +254,7 @@ struct hmm_mirror {
 	struct hmm		*hmm;
 	struct list_head	dlist;
 	struct hlist_node	mlist;
+	struct hmm_pt		pt;
 };
 
 int hmm_mirror_register(struct hmm_mirror *mirror, struct hmm_device *device);
diff --git a/mm/hmm.c b/mm/hmm.c
index 55afec0..90ebe75 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -71,6 +71,72 @@ struct hmm {
 
 static struct mmu_notifier_ops hmm_notifier_ops;
 
+static void hmm_device_fence_wait(struct hmm_device *device,
+				  struct hmm_fence *fence);
+static void hmm_mirror_release(struct hmm_mirror *mirror);
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
+	INIT_LIST_HEAD(&event->fences);
+	switch (etype) {
+	case HMM_ISDIRTY:
+		event->pte_mask = HMM_PTE_VALID | HMM_PTE_WRITE |
+				  HMM_PTE_DIRTY | HMM_PFN_MASK;
+		break;
+	case HMM_DEVICE_RFAULT:
+	case HMM_DEVICE_WFAULT:
+		event->pte_mask = HMM_PTE_VALID | HMM_PTE_WRITE |
+				  HMM_PFN_MASK;
+		break;
+	case HMM_WRITE_PROTECT:
+		event->pte_mask = HMM_PTE_VALID | HMM_PFN_MASK;
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
+
+static inline void hmm_event_wait(struct hmm_event *event)
+{
+	struct hmm_fence *fence, *tmp;
+
+	if (list_empty(&event->fences))
+		/* Nothing to wait for. */
+		return;
+
+	io_schedule();
+
+	list_for_each_entry_safe(fence, tmp, &event->fences, list)
+		hmm_device_fence_wait(fence->mirror->device, fence);
+}
+
 
 /* hmm - core HMM functions.
  *
@@ -139,6 +205,29 @@ static inline struct hmm *hmm_unref(struct hmm *hmm)
 	return NULL;
 }
 
+static void hmm_update(struct hmm *hmm, struct hmm_event *event)
+{
+	struct hmm_mirror *mirror;
+	int id;
+
+	/* Is this hmm already fully stop ? */
+	if (hmm->mm->hmm != hmm)
+		return;
+
+	id = srcu_read_lock(&srcu);
+
+	hlist_for_each_entry_rcu(mirror, &hmm->mirrors, mlist)
+		if (hmm_mirror_update(mirror, event))
+			hmm_mirror_release(mirror);
+
+	hmm_event_wait(event);
+
+	hlist_for_each_entry_rcu(mirror, &hmm->mirrors, mlist)
+		hmm_mirror_update_pt(mirror, event);
+
+	srcu_read_unlock(&srcu, id);
+}
+
 
 /* hmm_notifier - HMM callback for mmu_notifier tracking change to process mm.
  *
@@ -180,8 +269,87 @@ static void hmm_notifier_release(struct mmu_notifier *mn, struct mm_struct *mm)
 	srcu_read_unlock(&srcu, id);
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
+						struct mm_struct *mm,
+						const struct mmu_notifier_range *range)
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
+	case MMU_MUNLOCK:
+		/* Still same physical ram backing same address. */
+		return;
+	case MMU_MPROT:
+		hmm_mmu_mprot_to_etype(mm, start, range->event, &event.etype);
+		if (event.etype == HMM_NONE)
+			return;
+		break;
+	case MMU_WRITE_BACK:
+	case MMU_WRITE_PROTECT:
+		event.etype = HMM_WRITE_PROTECT;
+		break;
+	case MMU_ISDIRTY:
+		event.etype = HMM_ISDIRTY;
+		break;
+	case MMU_HSPLIT:
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
 
 
@@ -196,6 +364,64 @@ static struct mmu_notifier_ops hmm_notifier_ops = {
  * the device driver to fault in range of memory in the device page table.
  */
 
+static inline int hmm_mirror_update(struct hmm_mirror *mirror,
+				    struct hmm_event *event)
+{
+	struct hmm_device *device = mirror->device;
+	struct hmm_fence *fence;
+
+	fence = device->ops->update(mirror, event);
+	if (fence) {
+		if (IS_ERR(fence))
+			return PTR_ERR(fence);
+		fence->mirror = mirror;
+		list_add_tail(&fence->list, &event->fences);
+	}
+	return 0;
+}
+
+static void hmm_mirror_update_pt(struct hmm_mirror *mirror,
+				 struct hmm_event *event)
+{
+	unsigned long addr;
+	struct hmm_pt_iter iter;
+
+	hmm_pt_iter_init(&iter);
+	for (addr = event->start; addr != event->end;) {
+		unsigned long end, next;
+		dma_addr_t *hmm_pte;
+
+		hmm_pte = hmm_pt_iter_update(&iter, &mirror->pt, addr);
+		if (!hmm_pte) {
+			addr = hmm_pt_iter_next(&iter, &mirror->pt,
+						addr, event->end);
+			continue;
+		}
+		end = hmm_pt_level_next(&mirror->pt, addr, event->end,
+					 mirror->pt.llevel - 1);
+		hmm_pt_iter_directory_lock(&iter, &mirror->pt);
+		do {
+			next = hmm_pt_level_next(&mirror->pt, addr, end,
+						 mirror->pt.llevel);
+			if (!((*hmm_pte) & HMM_PTE_VALID))
+				continue;
+			if ((*hmm_pte) & HMM_PTE_DIRTY) {
+				struct page *page;
+
+				page = pfn_to_page(hmm_pte_pfn(*hmm_pte));
+				set_page_dirty(page);
+				*hmm_pte &= ~HMM_PTE_DIRTY;
+			}
+			*hmm_pte &= event->pte_mask;
+			if (((*hmm_pte) & HMM_PTE_VALID))
+				continue;
+			hmm_pt_iter_directory_unref(&iter, mirror->pt.llevel);
+		} while (addr = next, hmm_pte++, addr != end);
+		hmm_pt_iter_directory_unlock(&iter, &mirror->pt);
+	}
+	hmm_pt_iter_fini(&iter, &mirror->pt);
+}
+
 /* hmm_mirror_register() - register mirror against current process for a device.
  *
  * @mirror: The mirror struct being registered.
@@ -226,6 +452,11 @@ int hmm_mirror_register(struct hmm_mirror *mirror, struct hmm_device *device)
 	 * Initialize the mirror struct fields, the mlist init and del dance is
 	 * necessary to make the error path easier for driver and for hmm.
 	 */
+	mirror->pt.last = TASK_SIZE - 1;
+	if (hmm_pt_init(&mirror->pt)) {
+		kfree(mirror);
+		return -ENOMEM;
+	}
 	INIT_HLIST_NODE(&mirror->mlist);
 	INIT_LIST_HEAD(&mirror->dlist);
 	mutex_lock(&device->mutex);
@@ -263,6 +494,7 @@ int hmm_mirror_register(struct hmm_mirror *mirror, struct hmm_device *device)
 		hmm_unref(hmm);
 		goto error;
 	}
+	BUG_ON(mirror->pt.last >= hmm->vm_end);
 	return 0;
 
 error:
@@ -275,6 +507,14 @@ EXPORT_SYMBOL(hmm_mirror_register);
 
 static void hmm_mirror_release(struct hmm_mirror *mirror)
 {
+	struct hmm_event event;
+
+	/* Make sure everything is unmapped. */
+	hmm_event_init(&event, mirror->hmm, 0, -1UL, HMM_MUNMAP);
+	hmm_mirror_update(mirror, &event);
+	hmm_event_wait(&event);
+	hmm_mirror_update_pt(mirror, &event);
+
 	spin_lock(&mirror->hmm->lock);
 	if (!hlist_unhashed(&mirror->mlist)) {
 		hlist_del_init_rcu(&mirror->mlist);
@@ -310,6 +550,7 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror)
 	 */
 	synchronize_srcu(&srcu);
 
+	hmm_pt_fini(&mirror->pt);
 	mirror->hmm = hmm_unref(mirror->hmm);
 }
 EXPORT_SYMBOL(hmm_mirror_unregister);
@@ -366,6 +607,28 @@ int hmm_device_unregister(struct hmm_device *device)
 }
 EXPORT_SYMBOL(hmm_device_unregister);
 
+static void hmm_device_fence_wait(struct hmm_device *device,
+				  struct hmm_fence *fence)
+{
+	struct hmm_mirror *mirror;
+	int r;
+
+	if (fence == NULL)
+		return;
+
+	list_del_init(&fence->list);
+	do {
+		r = device->ops->fence_wait(fence);
+		if (r == -EAGAIN)
+			io_schedule();
+	} while (r == -EAGAIN);
+
+	mirror = fence->mirror;
+	device->ops->fence_unref(fence);
+	if (r)
+		hmm_mirror_release(mirror);
+}
+
 
 static int __init hmm_subsys_init(void)
 {
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
