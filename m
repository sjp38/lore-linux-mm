Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 126E5829A8
	for <linux-mm@kvack.org>; Sat, 23 May 2015 00:00:14 -0400 (EDT)
Received: by obbnx5 with SMTP id nx5so25461668obb.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 21:00:13 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id s204si2536055oia.32.2015.05.22.21.00.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 21:00:13 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2 0/2] alloc_huge_page/hugetlb_reserve_pages race
Date: Fri, 22 May 2015 20:55:02 -0700
Message-Id: <1432353304-12767-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

This updated patch set includes new documentation for the region/
reserve map routines.  Since I am not the original author of this
code, comments would be appreciated.

While working on hugetlbfs fallocate support, I noticed the following
race in the existing code.  It is unlikely that this race is hit very
often in the current code.  However, if more functionality to add and
remove pages to hugetlbfs mappings (such as fallocate) is added the
likelihood of hitting this race will increase.

alloc_huge_page and hugetlb_reserve_pages use information from the
reserve map to determine if there are enough available huge pages to
complete the operation, as well as adjust global reserve and subpool
usage counts.  The order of operations is as follows:
- call region_chg() to determine the expected change based on reserve map
- determine if enough resources are available for this operation
- adjust global counts based on the expected change
- call region_add() to update the reserve map
The issue is that reserve map could change between the call to region_chg
and region_add.  In this case, the counters which were adjusted based on
the output of region_chg will not be correct.

In order to hit this race today, there must be an existing shared hugetlb
mmap created with the MAP_NORESERVE flag.  A page fault to allocate a huge
page via this mapping must occur at the same another task is mapping the
same region without the MAP_NORESERVE flag.

The patch set does not prevent the race from happening.  Rather, it adds
simple functionality to detect when the race has occurred.  If a race is
detected, then the incorrect counts are adjusted.

v2:
  Added documentation for the region/reserve map routines
  Created common routine for vma_commit_reservation and
    vma_commit_reservation to help prevent them from drifting
    apart in the future.

Mike Kravetz (2):
  mm/hugetlb: compute/return the number of regions added by region_add()
  mm/hugetlb: handle races in alloc_huge_page and hugetlb_reserve_pages

 mm/hugetlb.c | 154 +++++++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 124 insertions(+), 30 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
