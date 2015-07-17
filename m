Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 238D528034A
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 14:54:09 -0400 (EDT)
Received: by igbpg9 with SMTP id pg9so2261930igb.0
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 11:54:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z16si10518130icq.31.2015.07.17.11.54.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 11:54:08 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 13/15] HMM: DMA map memory on behalf of device driver v2.
Date: Fri, 17 Jul 2015 14:52:23 -0400
Message-Id: <1437159145-6548-14-git-send-email-jglisse@redhat.com>
In-Reply-To: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
References: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Do the DMA mapping on behalf of the device as HMM is a good place
to perform this common task. Moreover in the future we hope to
add new infrastructure that would make DMA mapping more efficient
(lower overhead per page) by leveraging HMM data structure.

Changed since v1:
  - Adapt to HMM page table changes.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/hmm_pt.h |  11 +++
 mm/hmm.c               | 200 +++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 173 insertions(+), 38 deletions(-)

diff --git a/include/linux/hmm_pt.h b/include/linux/hmm_pt.h
index 4a8beb1..8a59a75 100644
--- a/include/linux/hmm_pt.h
+++ b/include/linux/hmm_pt.h
@@ -176,6 +176,17 @@ static inline dma_addr_t hmm_pte_from_pfn(dma_addr_t pfn)
 	return (pfn << PAGE_SHIFT) | (1 << HMM_PTE_VALID_PFN_BIT);
 }
 
+static inline dma_addr_t hmm_pte_from_dma_addr(dma_addr_t dma_addr)
+{
+	return (dma_addr & HMM_PTE_DMA_MASK) | (1 << HMM_PTE_VALID_DMA_BIT);
+}
+
+static inline dma_addr_t hmm_pte_dma_addr(dma_addr_t pte)
+{
+	/* FIXME Use max dma addr instead of 0 ? */
+	return hmm_pte_test_valid_dma(&pte) ? (pte & HMM_PTE_DMA_MASK) : 0;
+}
+
 static inline unsigned long hmm_pte_pfn(dma_addr_t pte)
 {
 	return hmm_pte_test_valid_pfn(&pte) ? pte >> PAGE_SHIFT : 0;
diff --git a/mm/hmm.c b/mm/hmm.c
index fa59581..6661f93 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -41,6 +41,7 @@
 #include <linux/mman.h>
 #include <linux/delay.h>
 #include <linux/workqueue.h>
+#include <linux/dma-mapping.h>
 
 #include "internal.h"
 
@@ -568,6 +569,46 @@ static inline int hmm_mirror_update(struct hmm_mirror *mirror,
 	return ret;
 }
 
+static void hmm_mirror_update_pte(struct hmm_mirror *mirror,
+				  struct hmm_event *event,
+				  struct hmm_pt_iter *iter,
+				  struct mm_pt_iter *mm_iter,
+				  struct page *page,
+				  dma_addr_t *hmm_pte,
+				  unsigned long addr)
+{
+	bool dirty = hmm_pte_test_and_clear_dirty(hmm_pte);
+
+	if (hmm_pte_test_valid_pfn(hmm_pte)) {
+		*hmm_pte &= event->pte_mask;
+		if (!hmm_pte_test_valid_pfn(hmm_pte))
+			hmm_pt_iter_directory_unref(iter);
+		goto out;
+	}
+
+	if (!hmm_pte_test_valid_dma(hmm_pte))
+		return;
+
+	if (!hmm_pte_test_valid_dma(&event->pte_mask)) {
+		struct device *dev = mirror->device->dev;
+		dma_addr_t dma_addr;
+
+		dma_addr = hmm_pte_dma_addr(*hmm_pte);
+		dma_unmap_page(dev, dma_addr, PAGE_SIZE, DMA_BIDIRECTIONAL);
+	}
+
+	*hmm_pte &= event->pte_mask;
+	if (!hmm_pte_test_valid_dma(hmm_pte))
+		hmm_pt_iter_directory_unref(iter);
+
+out:
+	if (dirty) {
+		page = page ? : mm_pt_iter_page(mm_iter, addr);
+		if (page)
+			set_page_dirty(page);
+	}
+}
+
 static void hmm_mirror_update_pt(struct hmm_mirror *mirror,
 				 struct hmm_event *event,
 				 struct page *page)
@@ -594,19 +635,9 @@ static void hmm_mirror_update_pt(struct hmm_mirror *mirror,
 		 */
 		hmm_pt_iter_directory_lock(&iter);
 		do {
-			if (!hmm_pte_test_valid_pfn(hmm_pte))
-				continue;
-			if (hmm_pte_test_and_clear_dirty(hmm_pte) &&
-			    hmm_pte_test_write(hmm_pte)) {
-				page = page ? : mm_pt_iter_page(&mm_iter, addr);
-				if (page)
-					set_page_dirty(page);
-				page = NULL;
-			}
-			*hmm_pte &= event->pte_mask;
-			if (hmm_pte_test_valid_pfn(hmm_pte))
-				continue;
-			hmm_pt_iter_directory_unref(&iter);
+			hmm_mirror_update_pte(mirror, event, &iter, &mm_iter,
+					      page, hmm_pte, addr);
+			page = NULL;
 		} while (addr += PAGE_SIZE, hmm_pte++, addr != next);
 		hmm_pt_iter_directory_unlock(&iter);
 	}
@@ -681,6 +712,9 @@ static int hmm_mirror_fault_hpmd(struct hmm_mirror *mirror,
 		 */
 		hmm_pt_iter_directory_lock(iter);
 		do {
+			if (hmm_pte_test_valid_dma(&hmm_pte[i]))
+				continue;
+
 			if (!hmm_pte_test_valid_pfn(&hmm_pte[i])) {
 				hmm_pte[i] = hmm_pte_from_pfn(pfn);
 				hmm_pt_iter_directory_ref(iter);
@@ -746,6 +780,9 @@ static int hmm_mirror_fault_pmd(pmd_t *pmdp,
 				break;
 			}
 
+			if (hmm_pte_test_valid_dma(&hmm_pte[i]))
+				continue;
+
 			if (!hmm_pte_test_valid_pfn(&hmm_pte[i])) {
 				hmm_pte[i] = hmm_pte_from_pfn(pte_pfn(*ptep));
 				hmm_pt_iter_directory_ref(iter);
@@ -762,6 +799,80 @@ static int hmm_mirror_fault_pmd(pmd_t *pmdp,
 	return ret;
 }
 
+static int hmm_mirror_dma_map(struct hmm_mirror *mirror,
+			      struct hmm_pt_iter *iter,
+			      unsigned long start,
+			      unsigned long end)
+{
+	struct device *dev = mirror->device->dev;
+	unsigned long addr;
+	int ret;
+
+	for (ret = 0, addr = start; !ret && addr < end;) {
+		unsigned long i = 0, next = end;
+		dma_addr_t *hmm_pte;
+
+		hmm_pte = hmm_pt_iter_populate(iter, addr, &next);
+		if (!hmm_pte)
+			return -ENOENT;
+
+		do {
+			dma_addr_t dma_addr, pte;
+			struct page *page;
+
+again:
+			pte = ACCESS_ONCE(hmm_pte[i]);
+			if (!hmm_pte_test_valid_pfn(&pte)) {
+				if (!hmm_pte_test_valid_dma(&pte)) {
+					ret = -ENOENT;
+					break;
+				}
+				continue;
+			}
+
+			page = pfn_to_page(hmm_pte_pfn(pte));
+			VM_BUG_ON(!page);
+			dma_addr = dma_map_page(dev, page, 0, PAGE_SIZE,
+						DMA_BIDIRECTIONAL);
+			if (dma_mapping_error(dev, dma_addr)) {
+				ret = -ENOMEM;
+				break;
+			}
+
+			hmm_pt_iter_directory_lock(iter);
+			/*
+			 * Make sure we transfer the dirty bit. Note that there
+			 * might still be a window for another thread to set
+			 * the dirty bit before we check for pte equality. This
+			 * will just lead to a useless retry so it is not the
+			 * end of the world here.
+			 */
+			if (hmm_pte_test_dirty(&hmm_pte[i]))
+				hmm_pte_set_dirty(&pte);
+			if (ACCESS_ONCE(hmm_pte[i]) != pte) {
+				hmm_pt_iter_directory_unlock(iter);
+				dma_unmap_page(dev, dma_addr, PAGE_SIZE,
+					       DMA_BIDIRECTIONAL);
+				if (hmm_pte_test_valid_pfn(&pte))
+					goto again;
+				if (!hmm_pte_test_valid_dma(&pte)) {
+					ret = -ENOENT;
+					break;
+				}
+			} else {
+				hmm_pte[i] = hmm_pte_from_dma_addr(dma_addr);
+				if (hmm_pte_test_write(&pte))
+					hmm_pte_set_write(&hmm_pte[i]);
+				if (hmm_pte_test_dirty(&pte))
+					hmm_pte_set_dirty(&hmm_pte[i]);
+				hmm_pt_iter_directory_unlock(iter);
+			}
+		} while (addr += PAGE_SIZE, i++, addr != next && !ret);
+	}
+
+	return ret;
+}
+
 static int hmm_mirror_handle_fault(struct hmm_mirror *mirror,
 				   struct hmm_event *event,
 				   struct vm_area_struct *vma,
@@ -770,7 +881,7 @@ static int hmm_mirror_handle_fault(struct hmm_mirror *mirror,
 	struct hmm_mirror_fault mirror_fault;
 	unsigned long addr = event->start;
 	struct mm_walk walk = {0};
-	int ret = 0;
+	int ret;
 
 	if ((event->etype == HMM_DEVICE_WFAULT) && !(vma->vm_flags & VM_WRITE))
 		return -EACCES;
@@ -779,32 +890,44 @@ static int hmm_mirror_handle_fault(struct hmm_mirror *mirror,
 	if (ret)
 		return ret;
 
-again:
-	if (event->backoff) {
-		ret = -EAGAIN;
-		goto out;
-	}
-	if (addr >= event->end)
-		goto out;
+	do {
+		if (event->backoff) {
+			ret = -EAGAIN;
+			break;
+		}
+		if (addr >= event->end)
+			break;
+
+		mirror_fault.event = event;
+		mirror_fault.mirror = mirror;
+		mirror_fault.vma = vma;
+		mirror_fault.addr = addr;
+		mirror_fault.iter = iter;
+		walk.mm = mirror->hmm->mm;
+		walk.private = &mirror_fault;
+		walk.pmd_entry = hmm_mirror_fault_pmd;
+		ret = walk_page_range(addr, event->end, &walk);
+		if (ret)
+			break;
+
+		if (event->backoff) {
+			ret = -EAGAIN;
+			break;
+		}
 
-	mirror_fault.event = event;
-	mirror_fault.mirror = mirror;
-	mirror_fault.vma = vma;
-	mirror_fault.addr = addr;
-	mirror_fault.iter = iter;
-	walk.mm = mirror->hmm->mm;
-	walk.private = &mirror_fault;
-	walk.pmd_entry = hmm_mirror_fault_pmd;
-	ret = walk_page_range(addr, event->end, &walk);
-	if (!ret) {
-		ret = mirror->device->ops->update(mirror, event);
-		if (!ret) {
-			addr = mirror_fault.addr;
-			goto again;
+		if (mirror->device->dev) {
+			ret = hmm_mirror_dma_map(mirror, iter,
+						 addr, event->end);
+			if (ret)
+				break;
 		}
-	}
 
-out:
+		ret = mirror->device->ops->update(mirror, event);
+		if (ret)
+			break;
+		addr = mirror_fault.addr;
+	} while (1);
+
 	hmm_device_fault_end(mirror->hmm, event);
 	if (ret == -ENOENT) {
 		ret = hmm_mm_fault(mirror->hmm, event, vma, addr);
@@ -948,7 +1071,8 @@ void hmm_mirror_range_dirty(struct hmm_mirror *mirror,
 
 		hmm_pte = hmm_pt_iter_walk(&iter, &addr, &next);
 		for (; hmm_pte && addr != next; hmm_pte++, addr += PAGE_SIZE) {
-			if (!hmm_pte_test_valid_pfn(hmm_pte) ||
+			if ((!hmm_pte_test_valid_pfn(hmm_pte) &&
+			     !hmm_pte_test_valid_dma(hmm_pte)) ||
 			    !hmm_pte_test_write(hmm_pte))
 				continue;
 			hmm_pte_set_dirty(hmm_pte);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
