Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 85BB56B0268
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 09:24:26 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id s63so3573963wme.2
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 06:24:26 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 3si37175815wmf.111.2016.04.28.06.24.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 06:24:17 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id e201so23387968wme.2
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 06:24:17 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 06/20] arc: get rid of superfluous __GFP_REPEAT
Date: Thu, 28 Apr 2016 15:23:52 +0200
Message-Id: <1461849846-27209-7-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461849846-27209-1-git-send-email-mhocko@kernel.org>
References: <1461849846-27209-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, Vineet Gupta <vgupta@synopsys.com>

From: Michal Hocko <mhocko@suse.com>

__GFP_REPEAT has a rather weak semantic but since it has been introduced
around 2.6.12 it has been ignored for low order allocations.

pte_alloc_one_kernel uses __get_order_pte but this is obviously
always zero because BITS_FOR_PTE is not larger than 9 yet the page
size is always larger than 4K.  This means that this flag has never
been actually useful here because it has always been used only for
PAGE_ALLOC_COSTLY requests.

Cc: linux-arch@vger.kernel.org
Acked-by: Vineet Gupta <vgupta@synopsys.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/arc/include/asm/pgalloc.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arc/include/asm/pgalloc.h b/arch/arc/include/asm/pgalloc.h
index 86ed671286df..3749234b7419 100644
--- a/arch/arc/include/asm/pgalloc.h
+++ b/arch/arc/include/asm/pgalloc.h
@@ -95,7 +95,7 @@ static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 {
 	pte_t *pte;
 
-	pte = (pte_t *) __get_free_pages(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO,
+	pte = (pte_t *) __get_free_pages(GFP_KERNEL | __GFP_ZERO,
 					 __get_order_pte());
 
 	return pte;
@@ -107,7 +107,7 @@ pte_alloc_one(struct mm_struct *mm, unsigned long address)
 	pgtable_t pte_pg;
 	struct page *page;
 
-	pte_pg = (pgtable_t)__get_free_pages(GFP_KERNEL | __GFP_REPEAT, __get_order_pte());
+	pte_pg = (pgtable_t)__get_free_pages(GFP_KERNEL, __get_order_pte());
 	if (!pte_pg)
 		return 0;
 	memzero((void *)pte_pg, PTRS_PER_PTE * sizeof(pte_t));
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
