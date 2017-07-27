Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E2A876B025F
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 02:18:48 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e3so204212829pfc.4
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 23:18:48 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q123si10506979pfb.349.2017.07.26.23.18.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 23:18:47 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6R6GusA025100
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 02:18:46 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2by87epcs5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 02:18:46 -0400
Received: from localhost
	by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 27 Jul 2017 02:18:45 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH v3 1/3] mm/hugetlb: Allow arch to override and call the weak function
Date: Thu, 27 Jul 2017 11:48:26 +0530
Message-Id: <20170727061828.11406-1-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

For ppc64, we want to call this function when we are not running as guest.
Also, if we failed to allocate hugepages, let the user know.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/hugetlb.h | 1 +
 mm/hugetlb.c            | 5 ++++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 0ed8e41aaf11..8bbbd37ab105 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -358,6 +358,7 @@ int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
 			pgoff_t idx);
 
 /* arch callback */
+int __init __alloc_bootmem_huge_page(struct hstate *h);
 int __init alloc_bootmem_huge_page(struct hstate *h);
 
 void __init hugetlb_bad_size(void);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bc48ee783dd9..a3a7a7e6339e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2083,7 +2083,9 @@ struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
 	return page;
 }
 
-int __weak alloc_bootmem_huge_page(struct hstate *h)
+int alloc_bootmem_huge_page(struct hstate *h)
+	__attribute__ ((weak, alias("__alloc_bootmem_huge_page")));
+int __alloc_bootmem_huge_page(struct hstate *h)
 {
 	struct huge_bootmem_page *m;
 	int nr_nodes, node;
@@ -2104,6 +2106,7 @@ int __weak alloc_bootmem_huge_page(struct hstate *h)
 			goto found;
 		}
 	}
+	pr_info("Failed to allocate hugepage of size %ld\n", huge_page_size(h));
 	return 0;
 
 found:
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
