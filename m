Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD2376B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 07:59:51 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g13so147804616ioj.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 04:59:51 -0700 (PDT)
Received: from szxga01-in.huawei.com ([58.251.152.64])
        by mx.google.com with ESMTPS id l88si13698616otc.170.2016.06.17.04.59.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 04:59:50 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] mm: fix account pmd page to the process
Date: Fri, 17 Jun 2016 19:56:15 +0800
Message-ID: <1466164575-13578-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, mike.kravetz@oracle.com, akpm@linux-foundation.org, kirill@shutemov.name
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: zhong jiang <zhongjiang@huawei.com>

hen a process acquire a pmd table shared by other process, we
increase the account to current process. otherwise, a race result
in other tasks have set the pud entry. so it no need to increase it.

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
