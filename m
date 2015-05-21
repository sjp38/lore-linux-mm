Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 042016B01A5
	for <linux-mm@kvack.org>; Thu, 21 May 2015 16:24:09 -0400 (EDT)
Received: by qkx62 with SMTP id 62so18638780qkx.3
        for <linux-mm@kvack.org>; Thu, 21 May 2015 13:24:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f199si3355620qhc.20.2015.05.21.13.24.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 13:24:08 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 24/36] HMM: split DMA mapping function in two.
Date: Thu, 21 May 2015 16:23:00 -0400
Message-Id: <1432239792-5002-5-git-send-email-jglisse@redhat.com>
In-Reply-To: <1432239792-5002-1-git-send-email-jglisse@redhat.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
 <1432239792-5002-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

To be able to reuse the DMA mapping logic, split it in two functions.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 mm/hmm.c | 125 +++++++++++++++++++++++++++++++++------------------------------
 1 file changed, 66 insertions(+), 59 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 9dbb1e43..b8807b2 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -853,82 +853,89 @@ static int hmm_mirror_fault_pmd(pmd_t *pmdp,
 	return ret;
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
 
 static int hmm_mirror_dma_map(struct hmm_mirror *mirror,
 			      struct hmm_pt_iter *iter,
 			      unsigned long start,
 			      unsigned long end)
 {
-	struct device *dev = mirror->device->dev;
 	unsigned long addr;
 	int ret;
 
 	for (ret = 0, addr = start; !ret && addr < end;) {
-		unsigned long i = 0, hmm_end, next;
+		unsigned long next, npages;
 		dma_addr_t *hmm_pte;
+		spinlock_t *lock;
 
 		hmm_pte = hmm_pt_iter_fault(iter, &mirror->pt, addr);
 		if (!hmm_pte)
 			return -ENOENT;
 
-		hmm_end = hmm_pt_level_next(&mirror->pt, addr, end,
-					    mirror->pt.llevel - 1);
-		do {
-			dma_addr_t dma_addr, pte;
-			struct page *page;
-
-			next = hmm_pt_level_next(&mirror->pt, addr, hmm_end,
-						 mirror->pt.llevel);
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
+		next = hmm_pt_level_next(&mirror->pt, addr, end,
+					 mirror->pt.llevel - 1);
 
-			hmm_pt_iter_directory_lock(iter, &mirror->pt);
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
-				hmm_pt_iter_directory_unlock(iter,&mirror->pt);
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
-				hmm_pt_iter_directory_unlock(iter, &mirror->pt);
-			}
-		} while (addr = next, i++, addr != hmm_end && !ret);
+		npages = (next - addr) >> PAGE_SHIFT;
+		lock = hmm_pt_iter_directory_lock_ptr(iter, &mirror->pt);
+		ret = hmm_mirror_dma_map_range(mirror, hmm_pte, lock, npages);
+		addr = next;
 	}
 
 	return ret;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
