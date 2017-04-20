Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6721A6B03C6
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 07:08:06 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 194so67917702iof.21
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 04:08:06 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u13si6131564pfg.6.2017.04.20.04.08.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 04:08:05 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3KB4KMD141594
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 07:08:04 -0400
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29x754cyn8-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 07:08:00 -0400
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 20 Apr 2017 21:07:24 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3KB7Etd000464
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 21:07:22 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3KB6j43006374
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 21:06:45 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH] mm/madvise: Dont poison entire HugeTLB page for single page errors
Date: Thu, 20 Apr 2017 16:36:27 +0530
In-Reply-To: <893ecbd7-e9fa-7a54-fc62-43f8a5b8107f@linux.vnet.ibm.com>
References: <893ecbd7-e9fa-7a54-fc62-43f8a5b8107f@linux.vnet.ibm.com>
Message-Id: <20170420110627.12307-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com

Currently soft_offline_page() migrates the entire HugeTLB page, then
dequeues it from the active list by making it a dangling HugeTLB page
which ofcourse can not be used further and marks the entire HugeTLB
page as poisoned. This might be a costly waste of memory if the error
involved affects only small section of the entire page.

This changes the behaviour so that only the affected page is marked
poisoned and then the HugeTLB page is released back to buddy system.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
The number of poisoned pages on the system has reduced as seen from
dmesg triggered with 'echo m > /proc/sysrq-enter' on powerpc.

 include/linux/hugetlb.h | 1 +
 mm/hugetlb.c            | 2 +-
 mm/memory-failure.c     | 9 ++++-----
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 7a5917d..f6b80a4 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -470,6 +470,7 @@ static inline pgoff_t basepage_index(struct page *page)
 	return __basepage_index(page);
 }
 
+extern int dissolve_free_huge_page(struct page *page);
 extern int dissolve_free_huge_pages(unsigned long start_pfn,
 				    unsigned long end_pfn);
 static inline bool hugepage_migration_supported(struct hstate *h)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 1edfdb8..2fb9ba3 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1444,7 +1444,7 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
  * number of free hugepages would be reduced below the number of reserved
  * hugepages.
  */
-static int dissolve_free_huge_page(struct page *page)
+int dissolve_free_huge_page(struct page *page)
 {
 	int rc = 0;
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 27f7210..1e377fd 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1597,13 +1597,12 @@ static int soft_offline_huge_page(struct page *page, int flags)
 			ret = -EIO;
 	} else {
 		/* overcommit hugetlb page will be freed to buddy */
+		SetPageHWPoison(page);
+		num_poisoned_pages_inc();
+
 		if (PageHuge(page)) {
-			set_page_hwpoison_huge_page(hpage);
 			dequeue_hwpoisoned_huge_page(hpage);
-			num_poisoned_pages_add(1 << compound_order(hpage));
-		} else {
-			SetPageHWPoison(page);
-			num_poisoned_pages_inc();
+			dissolve_free_huge_page(hpage);
 		}
 	}
 	return ret;
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
