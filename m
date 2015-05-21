Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id D71DA82966
	for <linux-mm@kvack.org>; Thu, 21 May 2015 15:34:15 -0400 (EDT)
Received: by qget53 with SMTP id t53so47124055qge.3
        for <linux-mm@kvack.org>; Thu, 21 May 2015 12:34:15 -0700 (PDT)
Received: from mail-qg0-x236.google.com (mail-qg0-x236.google.com. [2607:f8b0:400d:c04::236])
        by mx.google.com with ESMTPS id e130si22153071qhc.7.2015.05.21.12.34.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 12:34:15 -0700 (PDT)
Received: by qgew3 with SMTP id w3so47136127qge.2
        for <linux-mm@kvack.org>; Thu, 21 May 2015 12:34:14 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [PATCH 17/36] HMM: add new HMM page table flag (valid device memory).
Date: Thu, 21 May 2015 15:31:26 -0400
Message-Id: <1432236705-4209-18-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

For memory migrated to device we need a new type of memory entry.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
---
 include/linux/hmm_pt.h | 24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

diff --git a/include/linux/hmm_pt.h b/include/linux/hmm_pt.h
index 78a9073..26cfe5e 100644
--- a/include/linux/hmm_pt.h
+++ b/include/linux/hmm_pt.h
@@ -74,10 +74,11 @@ static inline unsigned long hmm_pde_pfn(dma_addr_t pde)
  * In the first case the device driver must ignore any pfn entry as they might
  * show as transient state while HMM is mapping the page.
  */
-#define HMM_PTE_VALID_DMA_BIT	0
-#define HMM_PTE_VALID_PFN_BIT	1
-#define HMM_PTE_WRITE_BIT	2
-#define HMM_PTE_DIRTY_BIT	3
+#define HMM_PTE_VALID_DEV_BIT	0
+#define HMM_PTE_VALID_DMA_BIT	1
+#define HMM_PTE_VALID_PFN_BIT	2
+#define HMM_PTE_WRITE_BIT	3
+#define HMM_PTE_DIRTY_BIT	4
 /*
  * Reserve some bits for device driver private flags. Note that thus can only
  * be manipulated using the hmm_pte_*_bit() sets of helpers.
@@ -85,7 +86,7 @@ static inline unsigned long hmm_pde_pfn(dma_addr_t pde)
  * WARNING ONLY SET/CLEAR THOSE FLAG ON PTE ENTRY THAT HAVE THE VALID BIT SET
  * AS OTHERWISE ANY BIT SET BY THE DRIVER WILL BE OVERWRITTEN BY HMM.
  */
-#define HMM_PTE_HW_SHIFT	4
+#define HMM_PTE_HW_SHIFT	8
 
 #define HMM_PTE_PFN_MASK	(~((dma_addr_t)((1 << PAGE_SHIFT) - 1)))
 #define HMM_PTE_DMA_MASK	(~((dma_addr_t)((1 << PAGE_SHIFT) - 1)))
@@ -166,6 +167,7 @@ static inline bool hmm_pte_test_and_set_bit(dma_addr_t *ptep,
 	HMM_PTE_TEST_AND_CLEAR_BIT(name, bit)\
 	HMM_PTE_TEST_AND_SET_BIT(name, bit)
 
+HMM_PTE_BIT_HELPER(valid_dev, HMM_PTE_VALID_DEV_BIT)
 HMM_PTE_BIT_HELPER(valid_dma, HMM_PTE_VALID_DMA_BIT)
 HMM_PTE_BIT_HELPER(valid_pfn, HMM_PTE_VALID_PFN_BIT)
 HMM_PTE_BIT_HELPER(dirty, HMM_PTE_DIRTY_BIT)
@@ -176,11 +178,23 @@ static inline dma_addr_t hmm_pte_from_pfn(dma_addr_t pfn)
 	return (pfn << PAGE_SHIFT) | (1 << HMM_PTE_VALID_PFN_BIT);
 }
 
+static inline dma_addr_t hmm_pte_from_dev_addr(dma_addr_t dma_addr)
+{
+	return (dma_addr & HMM_PTE_DMA_MASK) | (1 << HMM_PTE_VALID_DEV_BIT);
+}
+
 static inline dma_addr_t hmm_pte_from_dma_addr(dma_addr_t dma_addr)
 {
 	return (dma_addr & HMM_PTE_DMA_MASK) | (1 << HMM_PTE_VALID_DMA_BIT);
 }
 
+static inline dma_addr_t hmm_pte_dev_addr(dma_addr_t pte)
+{
+	/* FIXME Use max dma addr instead of 0 ? */
+	return hmm_pte_test_valid_dev(&pte) ? (pte & HMM_PTE_DMA_MASK) :
+					      (dma_addr_t)-1UL;
+}
+
 static inline dma_addr_t hmm_pte_dma_addr(dma_addr_t pte)
 {
 	/* FIXME Use max dma addr instead of 0 ? */
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
