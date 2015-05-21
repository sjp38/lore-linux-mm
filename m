Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id B4A736B019C
	for <linux-mm@kvack.org>; Thu, 21 May 2015 16:23:55 -0400 (EDT)
Received: by qget53 with SMTP id t53so48088448qge.3
        for <linux-mm@kvack.org>; Thu, 21 May 2015 13:23:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 199si1824029qhy.40.2015.05.21.13.23.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 13:23:55 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 28/36] HMM: add mirror fault support for system to device memory migration.
Date: Thu, 21 May 2015 16:23:04 -0400
Message-Id: <1432239792-5002-9-git-send-email-jglisse@redhat.com>
In-Reply-To: <1432239792-5002-1-git-send-email-jglisse@redhat.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
 <1432239792-5002-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Migration to device memory is done as a special kind of device mirror
fault. Memory migration being initiated by device driver and never by
HMM (unless it is a migration back to system memory).

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
---
 mm/hmm.c | 181 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 181 insertions(+)

diff --git a/mm/hmm.c b/mm/hmm.c
index 1a7554d..7c044f0 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -56,6 +56,10 @@ static int hmm_mirror_migrate_back(struct hmm_mirror *mirror,
 				   dma_addr_t *dst,
 				   unsigned long start,
 				   unsigned long end);
+static int hmm_mirror_migrate(struct hmm_mirror *mirror,
+			      struct hmm_event *event,
+			      struct vm_area_struct *vma,
+			      struct hmm_pt_iter *iter);
 static inline int hmm_mirror_update(struct hmm_mirror *mirror,
 				    struct hmm_event *event,
 				    struct page *page);
@@ -110,6 +114,12 @@ static inline int hmm_event_init(struct hmm_event *event,
 	return 0;
 }
 
+static inline unsigned long hmm_event_npages(const struct hmm_event *event)
+{
+	return (PAGE_ALIGN(event->end) - (event->start & PAGE_MASK)) >>
+	       PAGE_SHIFT;
+}
+
 
 /* hmm - core HMM functions.
  *
@@ -1198,6 +1208,9 @@ retry:
 	}
 
 	switch (event->etype) {
+	case HMM_COPY_TO_DEVICE:
+		ret = hmm_mirror_migrate(mirror, event, vma, &iter);
+		break;
 	case HMM_DEVICE_RFAULT:
 	case HMM_DEVICE_WFAULT:
 		ret = hmm_mirror_handle_fault(mirror, event, vma, &iter);
@@ -1330,6 +1343,174 @@ static int hmm_mirror_migrate_back(struct hmm_mirror *mirror,
 	return ret ? ret : r;
 }
 
+static int hmm_mirror_migrate(struct hmm_mirror *mirror,
+			      struct hmm_event *event,
+			      struct vm_area_struct *vma,
+			      struct hmm_pt_iter *iter)
+{
+	struct hmm_device *device = mirror->device;
+	struct hmm *hmm = mirror->hmm;
+	struct hmm_event invalidate;
+	unsigned long addr, npages;
+	struct hmm_mirror *tmp;
+	dma_addr_t *dst;
+	pte_t *save_pte;
+	int r = 0, ret;
+
+	/* Only allow migration of private anonymous memory. */
+	if (vma->vm_ops || unlikely(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)))
+		return -EINVAL;
+
+	/*
+	 * TODO More advance loop for splitting migration into several chunk.
+	 * For now limit the amount that can be migrated in one shot. Also we
+	 * would need to see if we need rescheduling if this is happening as
+	 * part of system call to the device driver.
+	 */
+	npages = hmm_event_npages(event);
+	if (npages * max(sizeof(*dst), sizeof(*save_pte)) > PAGE_SIZE)
+		return -EINVAL;
+	dst = kzalloc(npages * sizeof(*dst), GFP_KERNEL);
+	if (dst == NULL)
+		return -ENOMEM;
+	save_pte = kzalloc(npages * sizeof(*save_pte), GFP_KERNEL);
+	if (save_pte == NULL) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	ret = mm_hmm_migrate(hmm->mm, vma, save_pte, &event->backoff,
+			     &hmm->mmu_notifier, event->start, event->end);
+	if (ret == -EAGAIN)
+		goto out;
+	if (ret)
+		goto out_cleanup;
+
+	/*
+	 * Now invalidate for all other device, note that they can not race
+	 * with us as the CPU page table is full of special entry.
+	 */
+	hmm_event_init(&invalidate, mirror->hmm, event->start,
+		       event->end, HMM_MIGRATE);
+again:
+	down_read(&hmm->rwsem);
+	hlist_for_each_entry(tmp, &hmm->mirrors, mlist) {
+		if (tmp == mirror)
+			continue;
+		if (hmm_mirror_update(tmp, &invalidate, NULL)) {
+			hmm_mirror_ref(tmp);
+			up_read(&hmm->rwsem);
+			hmm_mirror_kill(tmp);
+			hmm_mirror_unref(&tmp);
+			goto again;
+		}
+	}
+	up_read(&hmm->rwsem);
+
+	/*
+	 * Populate the mirror page table with saved entry and also mark entry
+	 * that can be migrated.
+	 */
+	for (addr = event->start; addr < event->end;) {
+		unsigned long i, idx, next, npages;
+		dma_addr_t *hmm_pte;
+
+		hmm_pte = hmm_pt_iter_fault(iter, &mirror->pt, addr);
+		if (!hmm_pte) {
+			ret = -ENOMEM;
+			goto out_cleanup;
+		}
+
+		next = hmm_pt_level_next(&mirror->pt, addr, event->end,
+					 mirror->pt.llevel - 1);
+
+		npages = (next - addr) >> PAGE_SHIFT;
+		idx = (addr - event->start) >> PAGE_SHIFT;
+		hmm_pt_iter_directory_lock(iter, &mirror->pt);
+		for (i = 0; i < npages; i++, idx++) {
+			hmm_pte_clear_select(&hmm_pte[i]);
+			if (!pte_present(save_pte[idx]))
+				continue;
+			hmm_pte_set_select(&hmm_pte[i]);
+			/* This can not be a valid device entry here. */
+			VM_BUG_ON(hmm_pte_test_valid_dev(&hmm_pte[i]));
+			if (hmm_pte_test_valid_dma(&hmm_pte[i]))
+				continue;
+
+			if (hmm_pte_test_valid_pfn(&hmm_pte[i]))
+				continue;
+
+			hmm_pt_iter_directory_ref(iter, mirror->pt.llevel);
+			hmm_pte[i] = hmm_pte_from_pfn(pte_pfn(save_pte[idx]));
+			if (pte_write(save_pte[idx]))
+				hmm_pte_set_write(&hmm_pte[i]);
+			hmm_pte_set_select(&hmm_pte[i]);
+		}
+		hmm_pt_iter_directory_unlock(iter, &mirror->pt);
+
+		if (device->dev) {
+			spinlock_t *lock;
+
+			lock = hmm_pt_iter_directory_lock_ptr(iter,
+							      &mirror->pt);
+			ret = hmm_mirror_dma_map_range(mirror, hmm_pte,
+						       lock, npages);
+			/* Keep going only for entry that have been mapped. */
+			if (ret) {
+				for (i = 0; i < npages; ++i) {
+					if (!hmm_pte_test_select(&dst[i]))
+						continue;
+					if (!hmm_pte_test_valid_dma(&dst[i]))
+						continue;
+					hmm_pte_clear_select(&hmm_pte[i]);
+				}
+			}
+		}
+		addr = next;
+	}
+
+	/* Now Waldo we can do the copy. */
+	r = device->ops->copy_to_device(mirror, event, dst,
+					event->start, event->end);
+
+	/* Update mirror page table with successfully migrated entry. */
+	for (addr = event->start; addr < event->end;) {
+		unsigned long i, idx, next, npages;
+		dma_addr_t *hmm_pte;
+
+		hmm_pte = hmm_pt_iter_update(iter, &mirror->pt, addr);
+		if (!hmm_pte) {
+			addr = hmm_pt_iter_next(iter, &mirror->pt,
+						addr, event->end);
+			continue;
+		}
+
+		next = hmm_pt_level_next(&mirror->pt, addr, event->end,
+					 mirror->pt.llevel - 1);
+
+		npages = (next - addr) >> PAGE_SHIFT;
+		idx = (addr - event->start) >> PAGE_SHIFT;
+		hmm_pt_iter_directory_lock(iter, &mirror->pt);
+		for (i = 0; i < npages; i++, idx++) {
+			if (!hmm_pte_test_valid_dev(&dst[idx]))
+				continue;
+
+			VM_BUG_ON(!hmm_pte_test_select(&hmm_pte[i]));
+			hmm_pte[i] = dst[idx];
+		}
+		hmm_pt_iter_directory_unlock(iter, &mirror->pt);
+		addr = next;
+	}
+
+out_cleanup:
+	mm_hmm_migrate_cleanup(hmm->mm, vma, save_pte, dst,
+			       event->start, event->end);
+out:
+	kfree(save_pte);
+	kfree(dst);
+	return ret ? ret : r;
+}
+
 /* hmm_mirror_range_discard() - discard a range of address.
  *
  * @mirror: The mirror struct.
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
