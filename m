Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8D13082F61
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 15:38:17 -0400 (EDT)
Received: by qged69 with SMTP id d69so38163302qge.0
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 12:38:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 107si5431365qge.122.2015.08.13.12.38.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 12:38:16 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 11/15] HMM: add helpers for migration back to system memory v3.
Date: Thu, 13 Aug 2015 15:37:27 -0400
Message-Id: <1439494651-1255-12-git-send-email-jglisse@redhat.com>
In-Reply-To: <1439494651-1255-1-git-send-email-jglisse@redhat.com>
References: <1439494651-1255-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

This patch add all necessary functions and helpers for migration
from device memory back to system memory. They are 3 differents
case that would use that code :
  - CPU page fault
  - fork
  - device driver request

Note that this patch use regular memory accounting this means that
migration can fail as a result of memory cgroup resource exhaustion.
Latter patches will modify memcg to allow to keep remote memory
accounted as regular memory thus removing this point of failure.

Changed since v1:
  - Fixed logic in dma unmap code path on migration error.

Changed since v2:
  - Adapt to HMM page table changes.
  - Fix bug in migration failure code path.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
---
 mm/hmm.c | 151 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 151 insertions(+)

diff --git a/mm/hmm.c b/mm/hmm.c
index 72187ca..5400dfb 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -47,6 +47,12 @@
 
 static struct mmu_notifier_ops hmm_notifier_ops;
 static void hmm_mirror_kill(struct hmm_mirror *mirror);
+static int hmm_mirror_migrate_back(struct hmm_mirror *mirror,
+				   struct hmm_event *event,
+				   pte_t *new_pte,
+				   dma_addr_t *dst,
+				   unsigned long start,
+				   unsigned long end);
 static inline int hmm_mirror_update(struct hmm_mirror *mirror,
 				    struct hmm_event *event,
 				    struct page *page);
@@ -418,6 +424,46 @@ static struct mmu_notifier_ops hmm_notifier_ops = {
 };
 
 
+static int hmm_migrate_back(struct hmm *hmm,
+			    struct hmm_event *event,
+			    struct mm_struct *mm,
+			    struct vm_area_struct *vma,
+			    pte_t *new_pte,
+			    dma_addr_t *dst,
+			    unsigned long start,
+			    unsigned long end)
+{
+	struct hmm_mirror *mirror;
+	int r, ret;
+
+	/*
+	 * Do not return right away on error, as there might be valid page we
+	 * can migrate.
+	 */
+	ret = mm_hmm_migrate_back(mm, vma, new_pte, start, end);
+
+again:
+	down_read(&hmm->rwsem);
+	hlist_for_each_entry(mirror, &hmm->mirrors, mlist) {
+		r = hmm_mirror_migrate_back(mirror, event, new_pte,
+					    dst, start, end);
+		if (r) {
+			ret = ret ? ret : r;
+			mirror = hmm_mirror_ref(mirror);
+			BUG_ON(!mirror);
+			up_read(&hmm->rwsem);
+			hmm_mirror_kill(mirror);
+			hmm_mirror_unref(&mirror);
+			goto again;
+		}
+	}
+	up_read(&hmm->rwsem);
+
+	mm_hmm_migrate_back_cleanup(mm, vma, new_pte, dst, start, end);
+
+	return ret;
+}
+
 int hmm_handle_cpu_fault(struct mm_struct *mm,
 			struct vm_area_struct *vma,
 			pmd_t *pmdp, unsigned long addr,
@@ -1068,6 +1114,111 @@ out:
 }
 EXPORT_SYMBOL(hmm_mirror_fault);
 
+static int hmm_mirror_migrate_back(struct hmm_mirror *mirror,
+				   struct hmm_event *event,
+				   pte_t *new_pte,
+				   dma_addr_t *dst,
+				   unsigned long start,
+				   unsigned long end)
+{
+	unsigned long addr, i, npages = (end - start) >> PAGE_SHIFT;
+	struct hmm_device *device = mirror->device;
+	struct device *dev = mirror->device->dev;
+	struct hmm_pt_iter iter;
+	int r, ret = 0;
+
+	hmm_pt_iter_init(&iter, &mirror->pt);
+	for (addr = start, i = 0; addr < end; addr += PAGE_SIZE, ++i) {
+		unsigned long next = end;
+		dma_addr_t *hmm_pte;
+
+		hmm_pte_clear_select(&dst[i]);
+
+		if (!pte_present(new_pte[i]))
+			continue;
+		hmm_pte = hmm_pt_iter_lookup(&iter, addr, &next);
+		if (!hmm_pte)
+			continue;
+
+		if (!hmm_pte_test_valid_dev(hmm_pte))
+			continue;
+
+		dst[i] = hmm_pte_from_pfn(pte_pfn(new_pte[i]));
+		hmm_pte_set_select(&dst[i]);
+		hmm_pte_set_write(&dst[i]);
+	}
+
+	if (dev) {
+		ret = hmm_mirror_dma_map_range(mirror, dst, NULL, npages);
+		if (ret) {
+			for (i = 0; i < npages; ++i) {
+				if (!hmm_pte_test_select(&dst[i]))
+					continue;
+				if (hmm_pte_test_valid_dma(&dst[i]))
+					continue;
+				dst[i] = 0;
+			}
+		}
+	}
+
+	r = device->ops->copy_from_device(mirror, event, dst, start, end);
+
+	/* Update mirror page table with successfully migrated entry. */
+	for (addr = start; addr < end;) {
+		unsigned long idx, next = end, npages;
+		dma_addr_t *hmm_pte;
+
+		hmm_pte = hmm_pt_iter_walk(&iter, &addr, &next);
+		if (!hmm_pte)
+			continue;
+		idx = (addr - event->start) >> PAGE_SHIFT;
+		npages = (next - addr) >> PAGE_SHIFT;
+		hmm_pt_iter_directory_lock(&iter);
+		for (i = 0; i < npages; i++, idx++) {
+			if (!hmm_pte_test_valid_pfn(&dst[idx]) &&
+			    !hmm_pte_test_valid_dma(&dst[idx])) {
+				if (hmm_pte_test_valid_dev(&hmm_pte[i])) {
+					hmm_pte[i] = 0;
+					hmm_pt_iter_directory_unref(&iter);
+				}
+				continue;
+			}
+
+			VM_BUG_ON(!hmm_pte_test_select(&dst[idx]));
+			VM_BUG_ON(!hmm_pte_test_valid_dev(&hmm_pte[i]));
+			hmm_pte[i] = dst[idx];
+		}
+		hmm_pt_iter_directory_unlock(&iter);
+
+		/* DMA unmap failed migrate entry. */
+		if (dev) {
+			idx = (addr - event->start) >> PAGE_SHIFT;
+			for (i = 0; i < npages; i++, idx++) {
+				dma_addr_t dma_addr;
+
+				/*
+				 * Failed entry have the valid bit clear but
+				 * the select bit remain set.
+				 */
+				if (!hmm_pte_test_select(&dst[idx]) ||
+				    hmm_pte_test_valid_dma(&dst[i]))
+					continue;
+
+				hmm_pte_set_valid_dma(&dst[idx]);
+				dma_addr = hmm_pte_dma_addr(dst[idx]);
+				dma_unmap_page(dev, dma_addr, PAGE_SIZE,
+					       DMA_BIDIRECTIONAL);
+				dst[idx] = 0;
+			}
+		}
+
+		addr = next;
+	}
+	hmm_pt_iter_fini(&iter);
+
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
