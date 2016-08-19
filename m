Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id CB6FF6B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 08:41:58 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id j124so83211880ith.1
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 05:41:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z133si3889844itf.70.2016.08.19.05.41.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 05:41:58 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/1] soft_dirty: fix soft_dirty during THP split
Date: Fri, 19 Aug 2016 14:41:55 +0200
Message-Id: <1471610515-30229-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1471610515-30229-1-git-send-email-aarcange@redhat.com>
References: <1471610515-30229-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

Transfer the soft_dirty from pmd to pte during THP splits.

This fix avoids losing the soft_dirty bit and avoids userland memory
corruption in the checkpoint.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b9570b5..cb95a83 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1512,7 +1512,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	struct page *page;
 	pgtable_t pgtable;
 	pmd_t _pmd;
-	bool young, write, dirty;
+	bool young, write, dirty, soft_dirty;
 	unsigned long addr;
 	int i;
 
@@ -1546,6 +1546,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	write = pmd_write(*pmd);
 	young = pmd_young(*pmd);
 	dirty = pmd_dirty(*pmd);
+	soft_dirty = pmd_soft_dirty(*pmd);
 
 	pmdp_huge_split_prepare(vma, haddr, pmd);
 	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
@@ -1562,6 +1563,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 			swp_entry_t swp_entry;
 			swp_entry = make_migration_entry(page + i, write);
 			entry = swp_entry_to_pte(swp_entry);
+			if (soft_dirty)
+				entry = pte_swp_mksoft_dirty(entry);
 		} else {
 			entry = mk_pte(page + i, vma->vm_page_prot);
 			entry = maybe_mkwrite(entry, vma);
@@ -1569,6 +1572,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 				entry = pte_wrprotect(entry);
 			if (!young)
 				entry = pte_mkold(entry);
+			if (soft_dirty)
+				entry = pte_mksoft_dirty(entry);
 		}
 		if (dirty)
 			SetPageDirty(page + i);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
