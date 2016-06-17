Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6289A6B0253
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 09:14:33 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id z189so174888152itg.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 06:14:33 -0700 (PDT)
Received: from szxga01-in.huawei.com ([58.251.152.64])
        by mx.google.com with ESMTPS id b41si10327064otd.228.2016.06.17.06.14.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 06:14:29 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH v2] mm: fix account pmd page to the process
Date: Fri, 17 Jun 2016 21:13:12 +0800
Message-ID: <1466169192-18343-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, mike.kravetz@oracle.com, kirill@shutemov.name
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: zhong jiang <zhongjiang@huawei.com>

huge_pmd_share accounts the number of pmds incorrectly when it races
with a parallel pud instantiation. vma_interval_tree_foreach will
increase the counter but then has to recheck the pud with the pte lock
held and the back off path should drop the increment. The previous
code would lead to an elevated pmd count which shouldn't be very
harmful (check_mm() might complain and oom_badness() might be marginally
confused) but this is worth fixing.

Suggested-off-by: Michal Hocko <mhocko@kernel.org>
Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/hugetlb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 19d0d08..3072857 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4191,7 +4191,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 				(pmd_t *)((unsigned long)spte & PAGE_MASK));
 	} else {
 		put_page(virt_to_page(spte));
-		mm_inc_nr_pmds(mm);
+		mm_dec_nr_pmds(mm);
 	}
 	spin_unlock(ptl);
 out:
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
