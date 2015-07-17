Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3614828034A
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 14:53:47 -0400 (EDT)
Received: by igbij6 with SMTP id ij6so43895379igb.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 11:53:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b199si9950321ioe.42.2015.07.17.11.53.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 11:53:46 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 08/15] HMM: add device page fault support v4.
Date: Fri, 17 Jul 2015 14:52:18 -0400
Message-Id: <1437159145-6548-9-git-send-email-jglisse@redhat.com>
In-Reply-To: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
References: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

This patch add helper for device page fault. Device page fault helper will
fill the mirror page table using the CPU page table all this synchronized
with any update to CPU page table.

Changed since v1:
  - Add comment about directory lock.

Changed since v2:
  - Check for mirror->hmm in hmm_mirror_fault()

Changed since v3:
  - Adapt to HMM page table changes.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
---
 include/linux/hmm.h |  15 +++
 mm/hmm.c            | 370 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 384 insertions(+), 1 deletion(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 5488fa9..d819ec9 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -85,6 +85,12 @@ struct hmm_event {
 	bool			backoff;
 };
 
+static inline bool hmm_event_overlap(const struct hmm_event *a,
+				     const struct hmm_event *b)
+{
+	return !((a->end <= b->start) || (a->start >= b->end));
+}
+
 
 /* hmm_device - Each device must register one and only one hmm_device.
  *
@@ -176,6 +182,10 @@ struct hmm_device_ops {
  * @rwsem: Serialize the mirror list modifications.
  * @mmu_notifier: The mmu_notifier of this mm.
  * @rcu: For delayed cleanup call from mmu_notifier.release() callback.
+ * @device_faults: List of all active device page faults.
+ * @ndevice_faults: Number of active device page faults.
+ * @wait_queue: Wait queue for event synchronization.
+ * @lock: Serialize device_faults list modification.
  *
  * For each process address space (mm_struct) there is one and only one hmm
  * struct. hmm functions will redispatch to each devices the change made to
@@ -192,6 +202,10 @@ struct hmm {
 	struct rw_semaphore	rwsem;
 	struct mmu_notifier	mmu_notifier;
 	struct rcu_head		rcu;
+	struct list_head	device_faults;
+	unsigned		ndevice_faults;
+	wait_queue_head_t	wait_queue;
+	spinlock_t		lock;
 };
 
 
@@ -250,6 +264,7 @@ int hmm_mirror_register(struct hmm_mirror *mirror);
 void hmm_mirror_unregister(struct hmm_mirror *mirror);
 struct hmm_mirror *hmm_mirror_ref(struct hmm_mirror *mirror);
 void hmm_mirror_unref(struct hmm_mirror **mirror);
+int hmm_mirror_fault(struct hmm_mirror *mirror, struct hmm_event *event);
 
 
 #endif /* CONFIG_HMM */
diff --git a/mm/hmm.c b/mm/hmm.c
index 08e9501..a9e3dc5 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -67,7 +67,7 @@ static inline int hmm_event_init(struct hmm_event *event,
 				 enum hmm_etype etype)
 {
 	event->start = start & PAGE_MASK;
-	event->end = min(end, hmm->vm_end);
+	event->end = PAGE_ALIGN(min(end, hmm->vm_end));
 	if (event->start >= event->end)
 		return -EINVAL;
 	event->etype = etype;
@@ -103,6 +103,10 @@ static int hmm_init(struct hmm *hmm)
 	kref_init(&hmm->kref);
 	INIT_HLIST_HEAD(&hmm->mirrors);
 	init_rwsem(&hmm->rwsem);
+	INIT_LIST_HEAD(&hmm->device_faults);
+	hmm->ndevice_faults = 0;
+	init_waitqueue_head(&hmm->wait_queue);
+	spin_lock_init(&hmm->lock);
 
 	/* register notifier */
 	hmm->mmu_notifier.ops = &hmm_notifier_ops;
@@ -167,6 +171,58 @@ static inline struct hmm *hmm_unref(struct hmm *hmm)
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
@@ -175,6 +231,8 @@ static void hmm_update(struct hmm *hmm, struct hmm_event *event)
 	if (hmm->mm->hmm != hmm)
 		return;
 
+	hmm_wait_device_fault(hmm, event);
+
 again:
 	down_read(&hmm->rwsem);
 	hlist_for_each_entry(mirror, &hmm->mirrors, mlist)
@@ -186,6 +244,33 @@ again:
 			goto again;
 		}
 	up_read(&hmm->rwsem);
+
+	wake_up(&hmm->wait_queue);
+}
+
+static int hmm_mm_fault(struct hmm *hmm,
+			struct hmm_event *event,
+			struct vm_area_struct *vma,
+			unsigned long addr)
+{
+	unsigned flags = FAULT_FLAG_ALLOW_RETRY;
+	struct mm_struct *mm = vma->vm_mm;
+	int r;
+
+	flags |= (event->etype == HMM_DEVICE_WFAULT) ? FAULT_FLAG_WRITE : 0;
+	for (addr &= PAGE_MASK; addr < event->end; addr += PAGE_SIZE) {
+
+		r = handle_mm_fault(mm, vma, addr, flags);
+		if (r & VM_FAULT_RETRY)
+			return -EBUSY;
+		if (r & VM_FAULT_ERROR) {
+			if (r & VM_FAULT_OOM)
+				return -ENOMEM;
+			/* Same error code for all other cases. */
+			return -EFAULT;
+		}
+	}
+	return 0;
 }
 
 
@@ -228,6 +313,7 @@ static void hmm_notifier_release(struct mmu_notifier *mn, struct mm_struct *mm)
 	}
 	up_write(&hmm->rwsem);
 
+	wake_up(&hmm->wait_queue);
 	hmm_unref(hmm);
 }
 
@@ -416,6 +502,288 @@ static void hmm_mirror_update_pt(struct hmm_mirror *mirror,
 	hmm_pt_iter_fini(&iter);
 }
 
+static inline bool hmm_mirror_is_dead(struct hmm_mirror *mirror)
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
+		unsigned long i = 0, next = end;
+		dma_addr_t *hmm_pte;
+
+		hmm_pte = hmm_pt_iter_populate(iter, addr, &next);
+		if (!hmm_pte)
+			return -ENOMEM;
+
+		/*
+		 * The directory lock protect against concurrent clearing of
+		 * page table bit flags. Exceptions being the dirty bit and
+		 * the device driver private flags.
+		 */
+		hmm_pt_iter_directory_lock(iter);
+		do {
+			if (!hmm_pte_test_valid_pfn(&hmm_pte[i])) {
+				hmm_pte[i] = hmm_pte_from_pfn(pfn);
+				hmm_pt_iter_directory_ref(iter);
+			}
+			BUG_ON(hmm_pte_pfn(hmm_pte[i]) != pfn);
+			if (pmd_write(*pmdp))
+				hmm_pte_set_write(&hmm_pte[i]);
+		} while (addr += PAGE_SIZE, pfn++, i++, addr != next);
+		hmm_pt_iter_directory_unlock(iter);
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
+		unsigned long i = 0, next = end;
+		dma_addr_t *hmm_pte;
+		pte_t *ptep;
+
+		hmm_pte = hmm_pt_iter_populate(iter, addr, &next);
+		if (!hmm_pte)
+			return -ENOMEM;
+
+		ptep = pte_offset_map(pmdp, start);
+		hmm_pt_iter_directory_lock(iter);
+		do {
+			if (!pte_present(*ptep) ||
+			    (write && !pte_write(*ptep))) {
+				ret = -ENOENT;
+				ptep++;
+				break;
+			}
+
+			if (!hmm_pte_test_valid_pfn(&hmm_pte[i])) {
+				hmm_pte[i] = hmm_pte_from_pfn(pte_pfn(*ptep));
+				hmm_pt_iter_directory_ref(iter);
+			}
+			BUG_ON(hmm_pte_pfn(hmm_pte[i]) != pte_pfn(*ptep));
+			if (pte_write(*ptep))
+				hmm_pte_set_write(&hmm_pte[i]);
+		} while (addr += PAGE_SIZE, ptep++, i++, addr != next);
+		hmm_pt_iter_directory_unlock(iter);
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
+		ret = mirror->device->ops->update(mirror, event);
+		if (!ret) {
+			addr = mirror_fault.addr;
+			goto again;
+		}
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
+	mirror = hmm_mirror_ref(mirror);
+	if (!mirror)
+		return -ENODEV;
+	if (event->start >= mirror->hmm->vm_end) {
+		hmm_mirror_unref(&mirror);
+		return -EINVAL;
+	}
+	if (hmm_event_init(event, mirror->hmm, event->start,
+			   event->end, event->etype)) {
+		hmm_mirror_unref(&mirror);
+		return -EINVAL;
+	}
+	hmm_pt_iter_init(&iter, &mirror->pt);
+
+retry:
+	if (hmm_mirror_is_dead(mirror)) {
+		hmm_mirror_unref(&mirror);
+		return -ENODEV;
+	}
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
+	if (ret != -EBUSY)
+		up_read(&mirror->hmm->mm->mmap_sem);
+	wake_up(&mirror->hmm->wait_queue);
+	if (ret == -EAGAIN)
+		goto retry;
+	hmm_pt_iter_fini(&iter);
+	hmm_mirror_unref(&mirror);
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
