Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D66356B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 05:26:28 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l68so25415603wml.3
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 02:26:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z186si19868027wmg.93.2016.09.13.02.26.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Sep 2016 02:26:27 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8D9Ob09145308
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 05:26:26 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25dyk82f09-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 05:26:26 -0400
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rui.teng@linux.vnet.ibm.com>;
	Tue, 13 Sep 2016 03:26:25 -0600
From: Rui Teng <rui.teng@linux.vnet.ibm.com>
Subject: [RFC] mm: Change the data type of huge page size from unsigned long to u64
Date: Tue, 13 Sep 2016 17:26:05 +0800
Message-Id: <1473758765-13673-1-git-send-email-rui.teng@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Chen Gang <chengang@emindsoft.com.cn>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, hejianet@linux.vnet.ibm.com, Rui Teng <rui.teng@linux.vnet.ibm.com>

The huge page size could be 16G(0x400000000) on ppc64 architecture, and it will
cause an overflow on unsigned long data type(0xFFFFFFFF).

For example, huge_page_size() will return 0, if the PAGE_SIZE is 65536 and
h->order is 18, which is the result on ppc64 with 16G huge page enabled.

I think it needs to change the data type from unsigned long to u64. But it will
cause a lot of functions and data structures changed. Any comments and
suggestions?

Thanks!

Signed-off-by: Rui Teng <rui.teng@linux.vnet.ibm.com>
---
 include/linux/hugetlb.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index c26d463..efbe5cf 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -374,9 +374,9 @@ static inline struct hstate *hstate_vma(struct vm_area_struct *vma)
 	return hstate_file(vma->vm_file);
 }
 
-static inline unsigned long huge_page_size(struct hstate *h)
+static inline u64 huge_page_size(struct hstate *h)
 {
-	return (unsigned long)PAGE_SIZE << h->order;
+	return (u64)PAGE_SIZE << h->order;
 }
 
 extern unsigned long vma_kernel_pagesize(struct vm_area_struct *vma);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
