Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 921AB6B04BB
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 01:01:58 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id r7so37402013wrb.0
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 22:01:58 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d26si16557911wra.489.2017.07.27.22.01.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 22:01:56 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6S4wjLE135038
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 01:01:55 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2byqnv6xg4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 01:01:55 -0400
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 28 Jul 2017 01:01:54 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH v4 1/3] mm/hugetlb: Allow arch to override and call the weak function
Date: Fri, 28 Jul 2017 10:31:25 +0530
Message-Id: <20170728050127.28338-1-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

When running in guest mode ppc64 supports a different mechanism for hugetlb
allocation/reservation. The LPAR management application called HMC can
be used to reserve a set of hugepages and we pass the details of
reserved pages via device tree to the guest. (more details in
htab_dt_scan_hugepage_blocks()) . We do the memblock_reserve of the range
and later in the boot sequence, we add the reserved range to huge_boot_pages.

But to enable 16G hugetlb on baremetal config (when we are not running as guest)
we want to do memblock reservation during boot. Generic code already does this

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/hugetlb.h | 1 +
 mm/hugetlb.c            | 4 +++-
 2 files changed, 4 insertions(+), 1 deletion(-)

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
index bc48ee783dd9..b97e6494d74d 100644
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
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
