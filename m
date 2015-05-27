Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 590E06B006E
	for <linux-mm@kvack.org>; Wed, 27 May 2015 13:59:19 -0400 (EDT)
Received: by oiww2 with SMTP id w2so13681204oiw.0
        for <linux-mm@kvack.org>; Wed, 27 May 2015 10:59:19 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id tj5si11425164obc.104.2015.05.27.10.59.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 10:59:18 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v3 0/3] alloc_huge_page/hugetlb_reserve_pages race
Date: Wed, 27 May 2015 10:56:08 -0700
Message-Id: <1432749371-32220-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

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

Review comments pointed out the need for documentation of the existing
region/reserve map routines.  This patch set also adds documentation
in this area.

v3:
  Created separate patch for new documentation created in v2
  Added VM_BUG_ON() to region add at suggestion of Naoya Horiguchi
  __vma_reservation_common keys off parameter commit for easier reading
v2:
  Added documentation for the region/reserve map routines
  Created common routine for vma_commit_reservation and
    vma_commit_reservation to help prevent them from drifting
    apart in the future.

Mike Kravetz (3):
  mm/hugetlb: document the reserve map/region tracking routines
  mm/hugetlb: compute/return the number of regions added by region_add()
  mm/hugetlb: handle races in alloc_huge_page and hugetlb_reserve_pages

 mm/hugetlb.c | 158 +++++++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 128 insertions(+), 30 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
