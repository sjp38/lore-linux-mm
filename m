Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 194906B02E1
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 04:58:46 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n198so6397439wmg.9
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 01:58:46 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v23si29280607wra.229.2017.04.25.01.58.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 01:58:44 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3P8rocc033729
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 04:58:43 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2a1v50dx81-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 04:58:41 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 25 Apr 2017 18:58:20 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3P8wAbs4587904
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 18:58:18 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3P8veww002050
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 18:57:40 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: Freeing HugeTLB page into buddy allocator
Date: Tue, 25 Apr 2017 14:27:27 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <4f609205-fb69-4af5-3235-3abf05aa822a@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wujianguo@huawei.com
Cc: n-horiguchi@ah.jp.nec.com, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hello Jianguo,

In the commit a49ecbcd7b0d5a1cda, it talks about HugeTLB page being
freed into buddy allocator instead of hugepage_freelists. But if
I look the code closely for the function unmap_and_move_huge_page()
it only calls putback_active_hugepage() which puts the page into the
huge page active list to free up the source HugeTLB page after any
successful migration. I might be missing something here, so can you
please point me where we release the HugeTLB page into buddy allocator
directly during migration ?


commit a49ecbcd7b0d5a1cda7d60e03df402dd0ef76ac8
Author: Jianguo Wu <wujianguo@huawei.com>
Date:   Wed Dec 18 17:08:54 2013 -0800

    mm/memory-failure.c: recheck PageHuge() after hugetlb page migrate successfully
    
    After a successful hugetlb page migration by soft offline, the source
    page will either be freed into hugepage_freelists or buddy(over-commit
    page).  If page is in buddy, page_hstate(page) will be NULL.  It will
    hit a NULL pointer dereference in dequeue_hwpoisoned_huge_page().
    
      BUG: unable to handle kernel NULL pointer dereference at 0000000000000058
      IP: [<ffffffff81163761>] dequeue_hwpoisoned_huge_page+0x131/0x1d0
      PGD c23762067 PUD c24be2067 PMD 0
      Oops: 0000 [#1] SMP
    
    So check PageHuge(page) after call migrate_pages() successfully.
    
    Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
    Tested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
    Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
    Cc: <stable@vger.kernel.org>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index b7c1716..db08af9 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1505,10 +1505,16 @@ static int soft_offline_huge_page(struct page *page, int flags)
 		if (ret > 0)
 			ret = -EIO;
 	} else {
-		set_page_hwpoison_huge_page(hpage);
-		dequeue_hwpoisoned_huge_page(hpage);
-		atomic_long_add(1 << compound_order(hpage),
-				&num_poisoned_pages);
+		/* overcommit hugetlb page will be freed to buddy */
+		if (PageHuge(page)) {
+			set_page_hwpoison_huge_page(hpage);
+			dequeue_hwpoisoned_huge_page(hpage);
+			atomic_long_add(1 << compound_order(hpage),
+					&num_poisoned_pages);
+		} else {
+			SetPageHWPoison(page);
+			atomic_long_inc(&num_poisoned_pages);
+		}
 	}
 	return ret;
 }

Regards
Anshuman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
