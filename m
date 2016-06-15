Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id EC51A6B0261
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 10:54:53 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id s63so30113070ioi.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 07:54:53 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTP id x133si18235487oif.110.2016.06.15.07.54.52
        for <linux-mm@kvack.org>;
        Wed, 15 Jun 2016 07:54:53 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] mm: fix account pmd page to the process
Date: Wed, 15 Jun 2016 22:48:56 +0800
Message-ID: <1466002136-43295-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill.shutemov@linux.intel.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

when a process acquire a pmd table shared by other process, we
increase the account to current process. otherwise, a race result
in other tasks have set the pud entry. so it no need to increase it.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/hugetlb.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 19d0d08..3b025c5 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4189,10 +4189,9 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	if (pud_none(*pud)) {
 		pud_populate(mm, pud,
 				(pmd_t *)((unsigned long)spte & PAGE_MASK));
-	} else {
+	} else 
 		put_page(virt_to_page(spte));
-		mm_inc_nr_pmds(mm);
-	}
+
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
