Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 87B976B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 09:09:45 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id u25so39259774ioi.1
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 06:09:45 -0700 (PDT)
Received: from szxga02-in.huawei.com ([119.145.14.65])
        by mx.google.com with ESMTPS id e24si3030570otc.213.2016.07.19.06.09.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jul 2016 06:09:44 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH v2] mm/hugetlb: fix race when migrate pages
Date: Tue, 19 Jul 2016 21:04:07 +0800
Message-ID: <1468933447-19100-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, vbabka@suse.cz, qiuxishi@huawei.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

I hit the following code in huge_pte_alloc when run the database and
online-offline memory in the system.

BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));

when pmd share function enable, we may be obtain a shared pmd entry.
due to ongoing offline memory , the pmd entry points to the page will
turn into migrate condition. therefore, the bug will come up.

The patch fix it by checking the pmd entry when we obtain the lock.
if the shared pmd entry points to page is under migration. we should
allocate a new pmd entry.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/hugetlb.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6384dfd..3454051 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4213,7 +4213,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	struct vm_area_struct *svma;
 	unsigned long saddr;
 	pte_t *spte = NULL;
-	pte_t *pte;
+	pte_t *pte, entry;
 	spinlock_t *ptl;
 
 	if (!vma_shareable(vma, addr))
@@ -4240,6 +4240,11 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 
 	ptl = huge_pte_lockptr(hstate_vma(vma), mm, spte);
 	spin_lock(ptl);
+	entry = huge_ptep_get(spte);
+ 	if (is_hugetlb_entry_migration(entry) || 
+			is_hugetlb_entry_hwpoisoned(entry)) {
+		goto out_unlock;
+	}	
 	if (pud_none(*pud)) {
 		pud_populate(mm, pud,
 				(pmd_t *)((unsigned long)spte & PAGE_MASK));
@@ -4247,6 +4252,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 		put_page(virt_to_page(spte));
 		mm_dec_nr_pmds(mm);
 	}
+out_unlock:
 	spin_unlock(ptl);
 out:
 	pte = (pte_t *)pmd_alloc(mm, pud, addr);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
