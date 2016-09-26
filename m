Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 45F68280273
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 13:28:34 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id n4so101426592lfb.3
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 10:28:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id fm7si20395850wjc.6.2016.09.26.10.28.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 10:28:31 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8QHMSHD098310
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 13:28:30 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25q5duyq4f-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 13:28:29 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Mon, 26 Sep 2016 18:28:28 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 527B91B08061
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 18:30:19 +0100 (BST)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8QHSPRx11010546
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 17:28:25 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8QHSOkO008450
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 11:28:25 -0600
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [PATCH v4 3/3] mm/hugetlb: improve locking in dissolve_free_huge_pages()
Date: Mon, 26 Sep 2016 19:28:11 +0200
In-Reply-To: <20160926172811.94033-1-gerald.schaefer@de.ibm.com>
References: <20160926172811.94033-1-gerald.schaefer@de.ibm.com>
Message-Id: <20160926172811.94033-4-gerald.schaefer@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>

For every pfn aligned to minimum_order, dissolve_free_huge_pages() will
call dissolve_free_huge_page() which takes the hugetlb spinlock, even if
the page is not huge at all or a hugepage that is in-use.

Improve this by doing the PageHuge() and page_count() checks already in
dissolve_free_huge_pages() before calling dissolve_free_huge_page(). In
dissolve_free_huge_page(), when holding the spinlock, those checks need
to be revalidated.

Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---
 mm/hugetlb.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 91ae1f5..770d83e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1476,14 +1476,20 @@ static int dissolve_free_huge_page(struct page *page)
 int dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
 {
 	unsigned long pfn;
+	struct page *page;
 	int rc = 0;
 
 	if (!hugepages_supported())
 		return rc;
 
-	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << minimum_order)
-		if (rc = dissolve_free_huge_page(pfn_to_page(pfn)))
-			break;
+	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << minimum_order) {
+		page = pfn_to_page(pfn);
+		if (PageHuge(page) && !page_count(page)) {
+			rc = dissolve_free_huge_page(page);
+			if (rc)
+				break;
+		}
+	}
 
 	return rc;
 }
-- 
2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
