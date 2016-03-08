Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 155A0828E6
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 14:47:49 -0500 (EST)
Received: by mail-qg0-f53.google.com with SMTP id w104so22055552qge.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 11:47:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p37si4500807qgd.100.2016.03.08.11.47.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 11:47:48 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH v12 25/29] HMM: split DMA mapping function in two.
Date: Tue,  8 Mar 2016 15:43:18 -0500
Message-Id: <1457469802-11850-26-git-send-email-jglisse@redhat.com>
In-Reply-To: <1457469802-11850-1-git-send-email-jglisse@redhat.com>
References: <1457469802-11850-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

To be able to reuse the DMA mapping logic, split it in two functions.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 mm/hmm.c | 120 ++++++++++++++++++++++++++++++++++-----------------------------
 1 file changed, 65 insertions(+), 55 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index d26abe4..07f1ab6 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -910,76 +910,86 @@ static int hmm_mirror_fault_hugetlb_entry(pte_t *ptep,
 	return 0;
 }
 
+static int hmm_mirror_dma_map_range(struct hmm_mirror *mirror,
+				    dma_addr_t *hmm_pte,
+				    spinlock_t *lock,
+				    unsigned long npages)
+{
+	struct device *dev = mirror->device->dev;
+	unsigned long i;
+	int ret = 0;
+
+	for (i = 0; i < npages; i++) {
+		dma_addr_t dma_addr, pte;
+		struct page *page;
+
+again:
+		pte = ACCESS_ONCE(hmm_pte[i]);
+		if (!hmm_pte_test_valid_pfn(&pte) || !hmm_pte_test_select(&pte))
+			continue;
+
+		page = pfn_to_page(hmm_pte_pfn(pte));
+		VM_BUG_ON(!page);
+		dma_addr = dma_map_page(dev, page, 0, PAGE_SIZE,
+					DMA_BIDIRECTIONAL);
+		if (dma_mapping_error(dev, dma_addr)) {
+			ret = -ENOMEM;
+			break;
+		}
+
+		/*
+		 * Make sure we transfer the dirty bit. Note that there
+		 * might still be a window for another thread to set
+		 * the dirty bit before we check for pte equality. This
+		 * will just lead to a useless retry so it is not the
+		 * end of the world here.
+		 */
+		if (lock)
+			spin_lock(lock);
+		if (hmm_pte_test_dirty(&hmm_pte[i]))
+			hmm_pte_set_dirty(&pte);
+		if (ACCESS_ONCE(hmm_pte[i]) != pte) {
+				if (lock)
+					spin_unlock(lock);
+				dma_unmap_page(dev, dma_addr, PAGE_SIZE,
+					       DMA_BIDIRECTIONAL);
+				if (hmm_pte_test_valid_pfn(&hmm_pte[i]))
+					goto again;
+				continue;
+		}
+		hmm_pte[i] = hmm_pte_from_dma_addr(dma_addr);
+		if (hmm_pte_test_write(&pte))
+			hmm_pte_set_write(&hmm_pte[i]);
+		if (hmm_pte_test_dirty(&pte))
+			hmm_pte_set_dirty(&hmm_pte[i]);
+		if (lock)
+			spin_unlock(lock);
+	}
+
+	return ret;
+}
+
 static int hmm_mirror_dma_map(struct hmm_mirror *mirror,
 			      struct hmm_pt_iter *iter,
 			      unsigned long start,
 			      unsigned long end)
 {
-	struct device *dev = mirror->device->dev;
 	unsigned long addr;
 	int ret;
 
 	for (ret = 0, addr = start; !ret && addr < end;) {
-		unsigned long i = 0, next = end;
+		unsigned long next = end, npages;
 		dma_addr_t *hmm_pte;
+		spinlock_t *lock;
 
 		hmm_pte = hmm_pt_iter_populate(iter, addr, &next);
 		if (!hmm_pte)
 			return -ENOENT;
 
-		do {
-			dma_addr_t dma_addr, pte;
-			struct page *page;
-
-again:
-			pte = ACCESS_ONCE(hmm_pte[i]);
-			if (!hmm_pte_test_valid_pfn(&pte) ||
-			    !hmm_pte_test_select(&pte)) {
-				if (!hmm_pte_test_valid_dma(&pte)) {
-					ret = -ENOENT;
-					break;
-				}
-				continue;
-			}
-
-			page = pfn_to_page(hmm_pte_pfn(pte));
-			VM_BUG_ON(!page);
-			dma_addr = dma_map_page(dev, page, 0, PAGE_SIZE,
-						DMA_BIDIRECTIONAL);
-			if (dma_mapping_error(dev, dma_addr)) {
-				ret = -ENOMEM;
-				break;
-			}
-
-			hmm_pt_iter_directory_lock(iter);
-			/*
-			 * Make sure we transfer the dirty bit. Note that there
-			 * might still be a window for another thread to set
-			 * the dirty bit before we check for pte equality. This
-			 * will just lead to a useless retry so it is not the
-			 * end of the world here.
-			 */
-			if (hmm_pte_test_dirty(&hmm_pte[i]))
-				hmm_pte_set_dirty(&pte);
-			if (ACCESS_ONCE(hmm_pte[i]) != pte) {
-				hmm_pt_iter_directory_unlock(iter);
-				dma_unmap_page(dev, dma_addr, PAGE_SIZE,
-					       DMA_BIDIRECTIONAL);
-				if (hmm_pte_test_valid_pfn(&pte))
-					goto again;
-				if (!hmm_pte_test_valid_dma(&pte)) {
-					ret = -ENOENT;
-					break;
-				}
-			} else {
-				hmm_pte[i] = hmm_pte_from_dma_addr(dma_addr);
-				if (hmm_pte_test_write(&pte))
-					hmm_pte_set_write(&hmm_pte[i]);
-				if (hmm_pte_test_dirty(&pte))
-					hmm_pte_set_dirty(&hmm_pte[i]);
-				hmm_pt_iter_directory_unlock(iter);
-			}
-		} while (addr += PAGE_SIZE, i++, addr != next && !ret);
+		npages = (next - addr) >> PAGE_SHIFT;
+		lock = hmm_pt_iter_directory_lock_ptr(iter);
+		ret = hmm_mirror_dma_map_range(mirror, hmm_pte, lock, npages);
+		addr = next;
 	}
 
 	return ret;
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
