Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0F8778E0001
	for <linux-mm@kvack.org>; Sat, 22 Dec 2018 17:30:44 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id x64so4187815ywc.6
        for <linux-mm@kvack.org>; Sat, 22 Dec 2018 14:30:44 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id h97si5102508ybi.14.2018.12.22.14.30.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Dec 2018 14:30:42 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v3 0/2] hugetlbfs: use i_mmap_rwsem for better synchronization
Date: Sat, 22 Dec 2018 14:30:11 -0800
Message-Id: <20181222223013.22193-1-mike.kravetz@oracle.com>
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

v2 -> v3
  Incorporated suggestions from Kirill.  Code change to hold i_mmap_rwsem
  for duration of copy in copy_hugetlb_page_range.  Took i_mmap_rwsem in
  hugetlbfs_evict_inode to be consistent with other callers.  Other changes
  were to documentation/comments.
v1 -> v2
  Combined patches 2 and 3 of v1 series as suggested by Aneesh.  No other
  changes were made.
Patches are a follow up to the RFC,
  http://lkml.kernel.org/r/20181024045053.1467-1-mike.kravetz@oracle.com
  Comments made by Naoya were addressed.

Mike Kravetz (2):
  hugetlbfs: use i_mmap_rwsem for more pmd sharing synchronization
  hugetlbfs: Use i_mmap_rwsem to fix page fault/truncate race

 fs/hugetlbfs/inode.c | 61 +++++++++++++++-----------------
 mm/hugetlb.c         | 84 +++++++++++++++++++++++++++++++-------------
 mm/memory-failure.c  | 14 +++++++-
 mm/migrate.c         | 13 ++++++-
 mm/rmap.c            |  4 +++
 mm/userfaultfd.c     | 11 ++++--
 6 files changed, 125 insertions(+), 62 deletions(-)

-- 
2.17.2
