Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A6248E0072
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 03:26:10 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id f126-v6so11232717ywh.4
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 00:26:10 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id a140-v6si428178ywh.411.2018.09.25.00.26.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 00:26:09 -0700 (PDT)
From: Ashish Mhetre <amhetre@nvidia.com>
Subject: [PATCH] mm: Disable movable allocation for TRANSHUGE pages
Date: Tue, 25 Sep 2018 12:55:33 +0530
Message-ID: <1537860333-28416-1-git-send-email-amhetre@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: amhetre@nvidia.com, vdumpa@nvidia.com, Snikam@nvidia.com

TRANSHUGE pages have no migration support. Using CMA memory
for TRANSHUGE pages makes the memory reclaim not possible.
If TRANSHUGE pages are allocated as movable then the
allocations can come from CMA memory and make CMA reclaim fail.
To avoid this, disable movable page allocations for TRANSHUGE
pages.

Signed-off-by: Ashish Mhetre <amhetre@nvidia.com>
---
 mm/huge_memory.c | 29 ++++++++++++++++++-----------
 1 file changed, 18 insertions(+), 11 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 63edf18..bef509d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -631,19 +631,26 @@ static vm_fault_t __do_huge_pmd_anonymous_page(struct vm_fault *vmf,
  */
 static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
 {
+	gfp_t gfp = GFP_TRANSHUGE_LIGHT;
 	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
 
-	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
-	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM;
-	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
-							     __GFP_KSWAPD_RECLAIM);
-	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
-							     0);
-	return GFP_TRANSHUGE_LIGHT;
+	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG,
+				&transparent_hugepage_flags))
+		gfp = GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
+	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG,
+				&transparent_hugepage_flags))
+		gfp = GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM;
+	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG,
+					&transparent_hugepage_flags))
+		gfp = GFP_TRANSHUGE_LIGHT | (vma_madvised ?
+			__GFP_DIRECT_RECLAIM : __GFP_KSWAPD_RECLAIM);
+	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG,
+					&transparent_hugepage_flags))
+		gfp = GFP_TRANSHUGE_LIGHT | (vma_madvised ?
+					__GFP_DIRECT_RECLAIM : 0);
+	gfp &= ~__GFP_MOVABLE;
+
+	return gfp;
 }
 
 /* Caller must hold page table lock. */
-- 
2.1.4


-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------
