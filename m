Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id EE3E7828E1
	for <linux-mm@kvack.org>; Mon, 30 May 2016 05:15:24 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id o70so87952680lfg.1
        for <linux-mm@kvack.org>; Mon, 30 May 2016 02:15:24 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id v74si26983421wmv.34.2016.05.30.02.15.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 02:15:12 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id q62so20632635wmg.3
        for <linux-mm@kvack.org>; Mon, 30 May 2016 02:15:12 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 07/17] mips: get rid of superfluous __GFP_REPEAT
Date: Mon, 30 May 2016 11:14:49 +0200
Message-Id: <1464599699-30131-8-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464599699-30131-1-git-send-email-mhocko@kernel.org>
References: <1464599699-30131-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, John Crispin <blogic@openwrt.org>, linux-arch@vger.kernel.org

From: Michal Hocko <mhocko@suse.com>

__GFP_REPEAT has a rather weak semantic but since it has been introduced
around 2.6.12 it has been ignored for low order allocations.

pte_alloc_one{_kernel}, pmd_alloc_one allocate PTE_ORDER resp. PMD_ORDER
but both are not larger than 1. This means that this flag has never
been actually useful here because it has always been used only for
PAGE_ALLOC_COSTLY requests.

Cc: John Crispin <blogic@openwrt.org>
Cc: linux-arch@vger.kernel.org
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/mips/include/asm/pgalloc.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/mips/include/asm/pgalloc.h b/arch/mips/include/asm/pgalloc.h
index b336037e8768..93c079a1cfc8 100644
--- a/arch/mips/include/asm/pgalloc.h
+++ b/arch/mips/include/asm/pgalloc.h
@@ -69,7 +69,7 @@ static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 {
 	pte_t *pte;
 
-	pte = (pte_t *) __get_free_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, PTE_ORDER);
+	pte = (pte_t *) __get_free_pages(GFP_KERNEL|__GFP_ZERO, PTE_ORDER);
 
 	return pte;
 }
@@ -79,7 +79,7 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm,
 {
 	struct page *pte;
 
-	pte = alloc_pages(GFP_KERNEL | __GFP_REPEAT, PTE_ORDER);
+	pte = alloc_pages(GFP_KERNEL, PTE_ORDER);
 	if (!pte)
 		return NULL;
 	clear_highpage(pte);
@@ -113,7 +113,7 @@ static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	pmd_t *pmd;
 
-	pmd = (pmd_t *) __get_free_pages(GFP_KERNEL|__GFP_REPEAT, PMD_ORDER);
+	pmd = (pmd_t *) __get_free_pages(GFP_KERNEL, PMD_ORDER);
 	if (pmd)
 		pmd_init((unsigned long)pmd, (unsigned long)invalid_pte_table);
 	return pmd;
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
