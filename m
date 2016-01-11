Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 118F5828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 05:07:04 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id n128so42648542pfn.3
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 02:07:04 -0800 (PST)
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com. [202.81.31.147])
        by mx.google.com with ESMTPS id 88si27535830pfq.240.2016.01.11.02.07.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Jan 2016 02:07:03 -0800 (PST)
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 11 Jan 2016 20:06:57 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id F3CB93578052
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 21:06:55 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0BA6lDg60030990
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 21:06:55 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0BA6MqT010132
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 21:06:22 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] mm/powerpc: Fix _PAGE_PTE breaking swapoff
Date: Mon, 11 Jan 2016 15:35:50 +0530
Message-Id: <1452506750-2355-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

When converting a swp_entry_t to pte, we need to add _PAGE_PTE,
because we later compare the pte with linux page table entries to
find a matching pte. We do set _PAGE_PTE on pte entries on linux page
table even if it is a swap entry. So add them when converting
swp_entry_t to pte_t

The stack trace can be anywhere below try_to_unuse() in mm/swapfile.c,
since swapoff is circling around and around that function, reading from
each used swap block into a page, then trying to find where that page
belongs, looking at every non-file pte of every mm that ever swapped.

Reported-by: Hugh Dickins <hughd@google.com>
Suggested-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 03c1a5a21c0c..48edcd8fbc4f 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -158,9 +158,14 @@ static inline void pgd_set(pgd_t *pgdp, unsigned long val)
 #define __swp_entry(type, offset)	((swp_entry_t) { \
 					((type) << _PAGE_BIT_SWAP_TYPE) \
 					| ((offset) << PTE_RPN_SHIFT) })
-
-#define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val((pte)) })
-#define __swp_entry_to_pte(x)		__pte((x).val)
+/*
+ * swp_entry_t should be arch independent. We build a swp_entry_t from
+ * swap type and offset we get from swap and convert that to pte to
+ * find a matching pte in linux page table.
+ * Clear bits not found in swap entries here
+ */
+#define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val((pte)) & ~_PAGE_PTE })
+#define __swp_entry_to_pte(x)	__pte((x).val | _PAGE_PTE)
 
 #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
 #define _PAGE_SWP_SOFT_DIRTY   (1UL << (SWP_TYPE_BITS + _PAGE_BIT_SWAP_TYPE))
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
