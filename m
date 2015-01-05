Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id E533D6B0080
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 17:45:26 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id dc16so15447470qab.22
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 14:45:26 -0800 (PST)
Received: from mail-qg0-x235.google.com (mail-qg0-x235.google.com. [2607:f8b0:400d:c04::235])
        by mx.google.com with ESMTPS id j10si46357078qga.33.2015.01.05.14.45.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 Jan 2015 14:45:25 -0800 (PST)
Received: by mail-qg0-f53.google.com with SMTP id l89so15860023qgf.40
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 14:45:25 -0800 (PST)
From: j.glisse@gmail.com
Subject: [PATCH 6/6] HMM: add device page fault support.
Date: Mon,  5 Jan 2015 17:44:49 -0500
Message-Id: <1420497889-10088-7-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1420497889-10088-1-git-send-email-j.glisse@gmail.com>
References: <1420497889-10088-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

This patch add helper for device page fault. Device page fault helper will
fill the mirror page table using the CPU page table all this synchronized
with any update to CPU page table.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
---
 include/linux/hmm.h |   1 +
 mm/hmm.c            | 384 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 385 insertions(+)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index dd34572..72e168b 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -259,6 +259,7 @@ struct hmm_mirror {
 
 int hmm_mirror_register(struct hmm_mirror *mirror, struct hmm_device *device);
 void hmm_mirror_unregister(struct hmm_mirror *mirror);
+int hmm_mirror_fault(struct hmm_mirror *mirror, struct hmm_event *event);
 
 
 #endif /* CONFIG_HMM */
diff --git a/mm/hmm.c b/mm/hmm.c
index 719e43c..409750f 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -55,6 +55,9 @@ static struct srcu_struct srcu;
  * @lock: Serialize the mirror list modifications.
  * @kref: Reference counter
  * @mmu_notifier: The mmu_notifier of this mm.
+ * @device_faults: List of all active device page faults.
+ * @ndevice_faults: Number of active device page faults.
+ * @wait_queue: Wait queue for event synchronization.
  *
  * For each process address space (mm_struct) there is one and only one hmm
  * struct. hmm functions will redispatch to each devices the change made to
@@ -67,6 +70,9 @@ struct hmm {
 	spinlock_t		lock;
 	struct kref		kref;
 	struct mmu_notifier	mmu_notifier;
+	struct list_head	device_faults;
+	unsigned		ndevice_faults;
+	wait_queue_head_t	wait_queue;
 };
 
 static struct mmu_notifier_ops hmm_notifier_ops;
@@ -88,6 +94,11 @@ static void hmm_mirror_update_pt(struct hmm_mirror *mirror,
  * help dealing with all this.
  */
 
+static inline bool hmm_event_overlap(struct hmm_event *a, struct hmm_event *b)
+{
+	return !((a->end <= b->start) || (a->start >= b->end));
+}
+
 static inline int hmm_event_init(struct hmm_event *event,
 				 struct hmm *hmm,
 				 unsigned long start,
@@ -149,6 +160,9 @@ static int hmm_init(struct hmm *hmm)
 	hmm->vm_end = TASK_SIZE;
 	kref_init(&hmm->kref);
 	INIT_HLIST_HEAD(&hmm->mirrors);
+	INIT_LIST_HEAD(&hmm->device_faults);
+	hmm->ndevice_faults = 0;
+	init_waitqueue_head(&hmm->wait_queue);
 	spin_lock_init(&hmm->lock);
 
 	/* register notifier */
@@ -205,6 +219,60 @@ static inline struct hmm *hmm_unref(struct hmm *hmm)
 	return NULL;
 }
 
+static int hmm_device_fault_start(struct hmm *hmm, struct hmm_event *event)
+{
+	int ret = 0;
+
+	mmu_notifier_range_wait_valid(hmm->mm, event->start, event->end);
+
+	spin_lock(&hmm->lock);
+	if (mmu_notifier_range_is_valid(hmm->mm, event->start, event->end)) {
+		list_add_tail(&event->list, &hmm->device_faults);
+		hmm->ndevice_faults++;
+		event->backoff = false;
+	} else
+		ret = -EAGAIN;
+	spin_unlock(&hmm->lock);
+
+	wake_up(&hmm->wait_queue);
+
+	return ret;
+}
+
+static void hmm_device_fault_end(struct hmm *hmm, struct hmm_event *event)
+{
+	hmm_event_wait(event);
+
+	spin_lock(&hmm->lock);
+	list_del_init(&event->list);
+	hmm->ndevice_faults--;
+	spin_unlock(&hmm->lock);
+
+	wake_up(&hmm->wait_queue);
+}
+
+static void hmm_wait_device_fault(struct hmm *hmm, struct hmm_event *ievent)
+{
+	struct hmm_event *fevent;
+	unsigned long wait_for = 0;
+
+again:
+	spin_lock(&hmm->lock);
+	list_for_each_entry(fevent, &hmm->device_faults, list) {
+		if (!hmm_event_overlap(fevent, ievent))
+			continue;
+		fevent->backoff = true;
+		wait_for = hmm->ndevice_faults;
+	}
+	spin_unlock(&hmm->lock);
+
+	if (wait_for > 0) {
+		wait_event(hmm->wait_queue, wait_for != hmm->ndevice_faults);
+		wait_for = 0;
+		goto again;
+	}
+}
+
 static void hmm_update(struct hmm *hmm, struct hmm_event *event)
 {
 	struct hmm_mirror *mirror;
@@ -214,6 +282,8 @@ static void hmm_update(struct hmm *hmm, struct hmm_event *event)
 	if (hmm->mm->hmm != hmm)
 		return;
 
+	hmm_wait_device_fault(hmm, event);
+
 	id = srcu_read_lock(&srcu);
 
 	hlist_for_each_entry_rcu(mirror, &hmm->mirrors, mlist)
@@ -226,6 +296,35 @@ static void hmm_update(struct hmm *hmm, struct hmm_event *event)
 		hmm_mirror_update_pt(mirror, event);
 
 	srcu_read_unlock(&srcu, id);
+
+	wake_up(&hmm->wait_queue);
+}
+
+static int hmm_mm_fault(struct hmm *hmm,
+			struct hmm_event *event,
+			struct vm_area_struct *vma,
+			unsigned long addr)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned flags;
+	int r;
+
+	flags = (event->etype == HMM_DEVICE_WFAULT) ? FAULT_FLAG_WRITE : 0;
+	for (addr &= PAGE_MASK; addr < event->end; addr += PAGE_SIZE) {
+
+		flags |= FAULT_FLAG_ALLOW_RETRY;
+		do {
+			r = handle_mm_fault(mm, vma, addr, flags);
+			if (!(r & VM_FAULT_RETRY) && (r & VM_FAULT_ERROR)) {
+				if (r & VM_FAULT_OOM)
+					return -ENOMEM;
+				/* Same error code for all other cases. */
+				return -EFAULT;
+			}
+			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+		} while (r & VM_FAULT_RETRY);
+	}
+	return 0;
 }
 
 
@@ -267,6 +366,8 @@ static void hmm_notifier_release(struct mmu_notifier *mn, struct mm_struct *mm)
 	spin_unlock(&hmm->lock);
 
 	srcu_read_unlock(&srcu, id);
+
+	wake_up(&hmm->wait_queue);
 }
 
 static void hmm_mmu_mprot_to_etype(struct mm_struct *mm,
@@ -422,6 +523,289 @@ static void hmm_mirror_update_pt(struct hmm_mirror *mirror,
 	hmm_pt_iter_fini(&iter, &mirror->pt);
 }
 
+static inline bool hmm_mirror_is_stopped(struct hmm_mirror *mirror)
+{
+	if (hlist_unhashed(&mirror->mlist) || list_empty(&mirror->dlist))
+		return true;
+	return false;
+}
+
+struct hmm_mirror_fault {
+	struct hmm_mirror	*mirror;
+	struct hmm_event	*event;
+	struct vm_area_struct	*vma;
+	unsigned long		addr;
+	struct hmm_pt_iter	*iter;
+};
+
+static int hmm_mirror_fault_hpmd(struct hmm_mirror *mirror,
+				 struct hmm_event *event,
+				 struct vm_area_struct *vma,
+				 struct hmm_pt_iter *iter,
+				 pmd_t *pmdp,
+				 struct hmm_mirror_fault *mirror_fault,
+				 unsigned long start,
+				 unsigned long end)
+{
+	struct page *page;
+	unsigned long addr, pfn;
+	unsigned flags = FOLL_TOUCH;
+	spinlock_t *ptl;
+	int ret;
+
+	ptl = pmd_lock(mirror->hmm->mm, pmdp);
+	if (unlikely(!pmd_trans_huge(*pmdp))) {
+		spin_unlock(ptl);
+		return -EAGAIN;
+	}
+	if (unlikely(pmd_trans_splitting(*pmdp))) {
+		spin_unlock(ptl);
+		wait_split_huge_page(vma->anon_vma, pmdp);
+		return -EAGAIN;
+	}
+	flags |= event->etype == HMM_DEVICE_WFAULT ? FOLL_WRITE : 0;
+	page = follow_trans_huge_pmd(vma, start, pmdp, flags);
+	pfn = page_to_pfn(page);
+	spin_unlock(ptl);
+
+	/* Just fault in the whole PMD. */
+	start &= PMD_MASK;
+	end = start + PMD_SIZE - 1;
+
+	if (!pmd_write(*pmdp) && event->etype == HMM_DEVICE_WFAULT)
+			return -ENOENT;
+
+	for (ret = 0, addr = start; !ret && addr < end;) {
+		unsigned long i = 0, hmm_end, next;
+		dma_addr_t *hmm_pte;
+
+		hmm_pte = hmm_pt_iter_fault(iter, &mirror->pt, addr);
+		if (!hmm_pte)
+			return -ENOMEM;
+
+		hmm_end = hmm_pt_level_next(&mirror->pt, addr, end,
+					    mirror->pt.llevel - 1);
+		hmm_pt_iter_directory_lock(iter, &mirror->pt);
+		do {
+			next = hmm_pt_level_next(&mirror->pt, addr, hmm_end,
+						 mirror->pt.llevel);
+
+			if (!(hmm_pte[i] & HMM_PTE_VALID)) {
+				hmm_pte[i] = hmm_pte_from_pfn(pfn);
+				hmm_pt_iter_directory_ref(iter,
+							  mirror->pt.llevel);
+			}
+			BUG_ON(hmm_pte_pfn(hmm_pte[i]) != pfn);
+			hmm_pte[i] |= pmd_write(*pmdp) ? HMM_PTE_WRITE : 0;
+		} while (addr = next, pfn++, i++, addr != hmm_end);
+		hmm_pt_iter_directory_unlock(iter, &mirror->pt);
+		mirror_fault->addr = addr;
+	}
+
+	return 0;
+}
+
+static int hmm_mirror_fault_pmd(pmd_t *pmdp,
+				unsigned long start,
+				unsigned long end,
+				struct mm_walk *walk)
+{
+	struct hmm_mirror_fault *mirror_fault = walk->private;
+	struct hmm_mirror *mirror = mirror_fault->mirror;
+	struct hmm_event *event = mirror_fault->event;
+	struct hmm_pt_iter *iter = mirror_fault->iter;
+	bool write = (event->etype == HMM_DEVICE_WFAULT);
+	unsigned long addr;
+	int ret = 0;
+
+	/* Make sure there was no gap. */
+	if (start != mirror_fault->addr)
+		return -ENOENT;
+
+	if (event->backoff)
+		return -EAGAIN;
+
+	if (pmd_none(*pmdp))
+		return -ENOENT;
+
+	if (pmd_trans_huge(*pmdp))
+		return hmm_mirror_fault_hpmd(mirror, event, mirror_fault->vma,
+					     iter, pmdp, mirror_fault, start,
+					     end);
+
+	if (pmd_none_or_trans_huge_or_clear_bad(pmdp))
+		return -EFAULT;
+
+	for (ret = 0, addr = start; !ret && addr < end;) {
+		unsigned long i = 0, hmm_end, next;
+		dma_addr_t *hmm_pte;
+		pte_t *ptep;
+
+		hmm_pte = hmm_pt_iter_fault(iter, &mirror->pt, addr);
+		if (!hmm_pte)
+			return -ENOMEM;
+
+		hmm_end = hmm_pt_level_next(&mirror->pt, addr, end,
+					    mirror->pt.llevel - 1);
+		ptep = pte_offset_map(pmdp, start);
+		hmm_pt_iter_directory_lock(iter, &mirror->pt);
+		do {
+			next = hmm_pt_level_next(&mirror->pt, addr, hmm_end,
+						 mirror->pt.llevel);
+			if (!pte_present(*ptep) || (write && !pte_write(*ptep))) {
+				ret = -ENOENT;
+				ptep++;
+				break;
+			}
+
+			if (!(hmm_pte[i] & HMM_PTE_VALID)) {
+				hmm_pte[i] = hmm_pte_from_pfn(pte_pfn(*ptep));
+				hmm_pt_iter_directory_ref(iter,
+							  mirror->pt.llevel);
+			}
+			BUG_ON(hmm_pte_pfn(hmm_pte[i]) != pte_pfn(*ptep));
+			hmm_pte[i] |= pte_write(*ptep) ? HMM_PTE_WRITE : 0;
+		} while (addr = next, ptep++, i++, addr != hmm_end);
+		hmm_pt_iter_directory_unlock(iter, &mirror->pt);
+		pte_unmap(ptep - 1);
+		mirror_fault->addr = addr;
+	}
+
+	return ret;
+}
+
+static int hmm_mirror_handle_fault(struct hmm_mirror *mirror,
+				   struct hmm_event *event,
+				   struct vm_area_struct *vma,
+				   struct hmm_pt_iter *iter)
+{
+	struct hmm_mirror_fault mirror_fault;
+	unsigned long addr = event->start;
+	struct mm_walk walk = {0};
+	int ret = 0;
+
+	if ((event->etype == HMM_DEVICE_WFAULT) && !(vma->vm_flags & VM_WRITE))
+		return -EACCES;
+
+	ret = hmm_device_fault_start(mirror->hmm, event);
+	if (ret)
+		return ret;
+
+again:
+	if (event->backoff) {
+		ret = -EAGAIN;
+		goto out;
+	}
+	if (addr >= event->end)
+		goto out;
+
+	mirror_fault.event = event;
+	mirror_fault.mirror = mirror;
+	mirror_fault.vma = vma;
+	mirror_fault.addr = addr;
+	mirror_fault.iter = iter;
+	walk.mm = mirror->hmm->mm;
+	walk.private = &mirror_fault;
+	walk.pmd_entry = hmm_mirror_fault_pmd;
+	ret = walk_page_range(addr, event->end, &walk);
+	if (!ret) {
+		struct hmm_fence *fence;
+
+		fence = mirror->device->ops->update(mirror, event);
+		if (fence) {
+			if (IS_ERR(fence)) {
+				ret = PTR_ERR(fence);
+				goto out;
+			} else {
+				fence->mirror = mirror;
+				list_add_tail(&fence->list, &event->fences);
+			}
+		}
+		addr = mirror_fault.addr;
+		goto again;
+	}
+
+out:
+	hmm_device_fault_end(mirror->hmm, event);
+	if (ret == -ENOENT) {
+		ret = hmm_mm_fault(mirror->hmm, event, vma, addr);
+		ret = ret ? ret : -EAGAIN;
+	}
+	return ret;
+}
+
+int hmm_mirror_fault(struct hmm_mirror *mirror, struct hmm_event *event)
+{
+	struct vm_area_struct *vma;
+	struct hmm_pt_iter iter;
+	int ret = 0;
+
+	if (!mirror || event->start >= mirror->hmm->vm_end)
+		return -EINVAL;
+	if (hmm_event_init(event, mirror->hmm, event->start,
+			   event->end, event->etype))
+		return -EINVAL;
+	hmm_pt_iter_init(&iter);
+
+retry:
+	if (hmm_mirror_is_stopped(mirror))
+		return -ENODEV;
+
+	/*
+	 * So synchronization with the cpu page table is the most important
+	 * and tedious aspect of device page fault. There must be a strong
+	 * ordering btw call to device->update() for device page fault and
+	 * device->update() for cpu page table invalidation/update.
+	 *
+	 * Page that are exposed to device driver must stay valid while the
+	 * callback is in progress ie any cpu page table invalidation that
+	 * render those pages obsolete must call device->update() after the
+	 * device->update() call that faulted those pages.
+	 *
+	 * To achieve this we rely on few things. First the mmap_sem insure
+	 * us that any munmap() syscall will serialize with us. So issue are
+	 * with unmap_mapping_range() and with migrate or merge page. For this
+	 * hmm keep track of affected range of address and block device page
+	 * fault that hit overlapping range.
+	 */
+	down_read(&mirror->hmm->mm->mmap_sem);
+	vma = find_vma_intersection(mirror->hmm->mm, event->start, event->end);
+	if (!vma) {
+		ret = -EFAULT;
+		goto out;
+	}
+	if (vma->vm_start > event->start) {
+		event->end = vma->vm_start;
+		ret = -EFAULT;
+		goto out;
+	}
+	event->end = min(event->end, vma->vm_end) & PAGE_MASK;
+	if ((vma->vm_flags & (VM_IO | VM_PFNMAP | VM_MIXEDMAP | VM_HUGETLB))) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	switch (event->etype) {
+	case HMM_DEVICE_RFAULT:
+	case HMM_DEVICE_WFAULT:
+		ret = hmm_mirror_handle_fault(mirror, event, vma, &iter);
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+out:
+	/* Drop the mmap_sem so anyone waiting on it have a chance. */
+	up_read(&mirror->hmm->mm->mmap_sem);
+	wake_up(&mirror->hmm->wait_queue);
+	if (ret == -EAGAIN)
+		goto retry;
+	hmm_pt_iter_fini(&iter, &mirror->pt);
+	return ret;
+}
+EXPORT_SYMBOL(hmm_mirror_fault);
+
 /* hmm_mirror_register() - register mirror against current process for a device.
  *
  * @mirror: The mirror struct being registered.
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
