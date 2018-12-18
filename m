Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id F04218E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 17:36:13 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id f24so16769970ioh.21
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 14:36:13 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id m14si1878363itl.54.2018.12.18.14.36.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 14:36:12 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2 0/2] hugetlbfs: use i_mmap_rwsem for better synchronization
Date: Tue, 18 Dec 2018 14:35:55 -0800
Message-Id: <20181218223557.5202-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

There are two primary issues addressed here:
1) For shared pmds, huge PTE pointers returned by huge_pte_alloc can become
   invalid via a call to huge_pmd_unshare by another thread.
2) hugetlbfs page faults can race with truncation causing invalid global
   reserve counts and state.
Both issues are addressed by expanding the use of i_mmap_rwsem.

These issues have existed for a long time.  They can be recreated with a
test program that causes page fault/truncation races.  For simple mappings,
this results in a negative HugePages_Rsvd count.  If racing with mappings
that contain shared pmds, we can hit "BUG at fs/hugetlbfs/inode.c:444!" or
Oops! as the result of an invalid memory reference.

v1 -> v2
  Combined patches 2 and 3 of v1 series as suggested by Aneesh.  No other
  changes were made.
Patches are a follow up to the RFC,
  http://lkml.kernel.org/r/20181024045053.1467-1-mike.kravetz@oracle.com
  Comments made by Naoya were addressed.

Mike Kravetz (2):
  hugetlbfs: use i_mmap_rwsem for more pmd sharing synchronization
  hugetlbfs: Use i_mmap_rwsem to fix page fault/truncate race

 fs/hugetlbfs/inode.c | 50 +++++++++----------------
 mm/hugetlb.c         | 87 +++++++++++++++++++++++++++++++-------------
 mm/memory-failure.c  | 14 ++++++-
 mm/migrate.c         | 13 ++++++-
 mm/rmap.c            |  3 ++
 mm/userfaultfd.c     | 11 +++++-
 6 files changed, 116 insertions(+), 62 deletions(-)

-- 
2.17.2
