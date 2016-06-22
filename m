Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3CF996B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 12:26:47 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a69so115293254pfa.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 09:26:47 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t6si655309pfb.72.2016.06.22.09.26.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 09:26:46 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5MGOd7i084273
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 12:26:45 -0400
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com [195.75.94.104])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23qq3k0x7g-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 12:26:45 -0400
Received: from localhost
	by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Wed, 22 Jun 2016 17:26:43 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id D2573219005F
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 17:26:07 +0100 (BST)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u5MGQbbm5570896
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 16:26:37 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u5MGQZaM009914
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 10:26:36 -0600
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [PATCH] mm/hugetlb: clear compound_mapcount when freeing gigantic pages
Date: Wed, 22 Jun 2016 18:25:19 +0200
Message-Id: <1466612719-5642-1-git-send-email-gerald.schaefer@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

While working on s390 support for gigantic hugepages I ran into the following
"Bad page state" warning when freeing gigantic pages:

BUG: Bad page state in process bash  pfn:580001
page:000003d116000040 count:0 mapcount:0 mapping:ffffffff00000000 index:0x0
flags: 0x7fffc0000000000()
page dumped because: non-NULL mapping

This is because page->compound_mapcount, which is part of a union with
page->mapping, is initialized with -1 in prep_compound_gigantic_page(), and
not cleared again during destroy_compound_gigantic_page(). Fix this by
clearing the compound_mapcount in destroy_compound_gigantic_page() before
clearing compound_head.

Interestingly enough, the warning will not show up on x86_64, although this
should not be architecture specific. Apparently there is an endianness issue,
combined with the fact that the union contains both a 64 bit ->mapping
pointer and a 32 bit atomic_t ->compound_mapcount as members. The resulting
bogus page->mapping on x86_64 therefore contains 00000000ffffffff instead
of ffffffff00000000 on s390, which will falsely trigger the PageAnon() check
in free_pages_prepare() because page->mapping & PAGE_MAPPING_ANON is true
on little-endian architectures like x86_64 in this case (the page is not
compound anymore, ->compound_head was already cleared before). As a result,
page->mapping will be cleared before doing the checks in free_pages_check().

Not sure if the bogus "PageAnon() returning true" on x86_64 for the first
tail page of a gigantic page (at this stage) has other theoretical
implications, but they would also be fixed with this patch.

Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---
 mm/hugetlb.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e197cd7..b64f8b7 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1030,6 +1030,7 @@ static void destroy_compound_gigantic_page(struct page *page,
 	int nr_pages = 1 << order;
 	struct page *p = page + 1;
 
+	atomic_set(compound_mapcount_ptr(page), 0);
 	for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {
 		clear_compound_head(p);
 		set_page_refcounted(p);
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
