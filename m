Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9D6D4280274
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 13:28:29 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id s64so100562343lfs.1
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 10:28:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o184si9408112wma.87.2016.09.26.10.28.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 10:28:28 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8QHMSFS098272
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 13:28:27 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25q5duyq0w-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 13:28:26 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Mon, 26 Sep 2016 18:28:24 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 4F5AC219005E
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 18:27:40 +0100 (BST)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8QHSKiJ5570966
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 17:28:20 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8QHSKwD008352
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 11:28:20 -0600
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [PATCH v4 0/3] mm/hugetlb: memory offline issues with hugepages
Date: Mon, 26 Sep 2016 19:28:08 +0200
Message-Id: <20160926172811.94033-1-gerald.schaefer@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>

This addresses several issues with hugepages and memory offline. While
the first patch fixes a panic, and is therefore rather important, the
last patch is just a performance optimization.

The second patch fixes a theoretical issue with reserved hugepages,
while still leaving some ugly usability issue, see description.

Changes in v4:
- Add check for free vs. reserved hugepages
- Revalidate checks in dissolve_free_huge_page() after taking the lock
- Split up into 3 patches

Changes in v3:
- Add Fixes: c8721bbb
- Add Cc: stable
- Elaborate on losing the gigantic page vs. failing memory offline
- Move page_count() check out of dissolve_free_huge_page()

Changes in v2:
- Update comment in dissolve_free_huge_pages()
- Change locking in dissolve_free_huge_page()

Gerald Schaefer (3):
  mm/hugetlb: fix memory offline with hugepage size > memory block size
  mm/hugetlb: check for reserved hugepages during memory offline
  mm/hugetlb: improve locking in dissolve_free_huge_pages()

 include/linux/hugetlb.h |  6 +++---
 mm/hugetlb.c            | 47 +++++++++++++++++++++++++++++++++++------------
 mm/memory_hotplug.c     |  4 +++-
 3 files changed, 41 insertions(+), 16 deletions(-)

-- 
2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
