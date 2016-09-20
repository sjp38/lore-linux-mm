Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C30A16B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 11:54:24 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w84so20257752wmg.1
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 08:54:24 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b83si27802939wmi.3.2016.09.20.08.54.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 08:54:23 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8KFsCcR119297
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 11:54:22 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25jmr0uvn7-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 11:54:22 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Tue, 20 Sep 2016 16:54:20 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 86CA32190066
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 16:53:38 +0100 (BST)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8KFsILj18284884
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 15:54:18 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8KFsHjb032339
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 09:54:18 -0600
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [PATCH 0/1] memory offline issues with hugepage size > memory block size
Date: Tue, 20 Sep 2016 17:53:53 +0200
Message-Id: <20160920155354.54403-1-gerald.schaefer@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

dissolve_free_huge_pages() will either run into the VM_BUG_ON() or a
list corruption and addressing exception when trying to set a memory
block offline that is part (but not the first part) of a gigantic
hugetlb page with a size > memory block size.

When no other smaller hugepage sizes are present, the VM_BUG_ON() will
trigger directly. In the other case we will run into an addressing
exception later, because dissolve_free_huge_page() will not use the head
page of the compound hugetlb page which will result in a NULL hstate
from page_hstate(). list_del() would also not work well on a tail page.

To fix this, first remove the VM_BUG_ON() because it is wrong, and then
use the compound head page in dissolve_free_huge_page().

However, this all assumes that it is the desired behaviour to remove
a (gigantic) unused hugetlb page from the pool, just because a small
(in relation to the  hugepage size) memory block is going offline. Not
sure if this is the right thing, and it doesn't look very consistent
given that in this scenario it is _not_ possible to migrate
such a (gigantic) hugepage if it is in use. OTOH, has_unmovable_pages()
will return false in both cases, i.e. the memory block will be reported
as removable, no matter if the hugepage that it is part of is unused or
in use.

This patch is assuming that it would be OK to remove the hugepage,
i.e. memory offline beats pre-allocated unused (gigantic) hugepages.

Any thoughts?


Gerald Schaefer (1):
  mm/hugetlb: fix memory offline with hugepage size > memory block size

 mm/hugetlb.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

-- 
2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
