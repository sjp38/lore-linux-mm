Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 24DB182966
	for <linux-mm@kvack.org>; Thu, 21 May 2015 15:34:19 -0400 (EDT)
Received: by qkdn188 with SMTP id n188so59402428qkd.2
        for <linux-mm@kvack.org>; Thu, 21 May 2015 12:34:18 -0700 (PDT)
Received: from mail-qk0-x232.google.com (mail-qk0-x232.google.com. [2607:f8b0:400d:c09::232])
        by mx.google.com with ESMTPS id o5si1113751qko.11.2015.05.21.12.34.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 12:34:18 -0700 (PDT)
Received: by qkdn188 with SMTP id n188so59402077qkd.2
        for <linux-mm@kvack.org>; Thu, 21 May 2015 12:34:18 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [PATCH 18/36] HMM: add new HMM page table flag (select flag).
Date: Thu, 21 May 2015 15:31:27 -0400
Message-Id: <1432236705-4209-19-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

When migrating memory the same array for HMM page table entry might be
use with several different devices. Add a new select flag so current
device driver callback can know which entry are selected for the device.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/hmm_pt.h | 6 ++++--
 mm/hmm.c               | 5 ++++-
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/linux/hmm_pt.h b/include/linux/hmm_pt.h
index 26cfe5e..36f7e00 100644
--- a/include/linux/hmm_pt.h
+++ b/include/linux/hmm_pt.h
@@ -77,8 +77,9 @@ static inline unsigned long hmm_pde_pfn(dma_addr_t pde)
 #define HMM_PTE_VALID_DEV_BIT	0
 #define HMM_PTE_VALID_DMA_BIT	1
 #define HMM_PTE_VALID_PFN_BIT	2
-#define HMM_PTE_WRITE_BIT	3
-#define HMM_PTE_DIRTY_BIT	4
+#define HMM_PTE_SELECT		3
+#define HMM_PTE_WRITE_BIT	4
+#define HMM_PTE_DIRTY_BIT	5
 /*
  * Reserve some bits for device driver private flags. Note that thus can only
  * be manipulated using the hmm_pte_*_bit() sets of helpers.
@@ -170,6 +171,7 @@ static inline bool hmm_pte_test_and_set_bit(dma_addr_t *ptep,
 HMM_PTE_BIT_HELPER(valid_dev, HMM_PTE_VALID_DEV_BIT)
 HMM_PTE_BIT_HELPER(valid_dma, HMM_PTE_VALID_DMA_BIT)
 HMM_PTE_BIT_HELPER(valid_pfn, HMM_PTE_VALID_PFN_BIT)
+HMM_PTE_BIT_HELPER(select, HMM_PTE_SELECT)
 HMM_PTE_BIT_HELPER(dirty, HMM_PTE_DIRTY_BIT)
 HMM_PTE_BIT_HELPER(write, HMM_PTE_WRITE_BIT)
 
diff --git a/mm/hmm.c b/mm/hmm.c
index 2143a58..761905a 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -757,6 +757,7 @@ static int hmm_mirror_fault_hpmd(struct hmm_mirror *mirror,
 			hmm_pte[i] = hmm_pte_from_pfn(pfn);
 			if (pmd_write(*pmdp))
 				hmm_pte_set_write(&hmm_pte[i]);
+			hmm_pte_set_select(&hmm_pte[i]);
 		} while (addr = next, pfn++, i++, addr != hmm_end);
 		hmm_pt_iter_directory_unlock(iter, &mirror->pt);
 		mirror_fault->addr = addr;
@@ -826,6 +827,7 @@ static int hmm_mirror_fault_pmd(pmd_t *pmdp,
 			hmm_pte[i] = hmm_pte_from_pfn(pte_pfn(*ptep));
 			if (pte_write(*ptep))
 				hmm_pte_set_write(&hmm_pte[i]);
+			hmm_pte_set_select(&hmm_pte[i]);
 		} while (addr = next, ptep++, i++, addr != hmm_end);
 		hmm_pt_iter_directory_unlock(iter, &mirror->pt);
 		pte_unmap(ptep - 1);
@@ -864,7 +866,8 @@ static int hmm_mirror_dma_map(struct hmm_mirror *mirror,
 
 again:
 			pte = ACCESS_ONCE(hmm_pte[i]);
-			if (!hmm_pte_test_valid_pfn(&pte)) {
+			if (!hmm_pte_test_valid_pfn(&pte) ||
+			    !hmm_pte_test_select(&pte)) {
 				if (!hmm_pte_test_valid_dma(&pte)) {
 					ret = -ENOENT;
 					break;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
