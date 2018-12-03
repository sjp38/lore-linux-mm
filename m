Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B04E6B6AD9
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 15:09:09 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id v74so14171331qkb.21
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 12:09:09 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id x189si183100qke.171.2018.12.03.12.09.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 12:09:08 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 0/3] hugetlbfs: use i_mmap_rwsem for better synchronization
Date: Mon,  3 Dec 2018 12:08:47 -0800
Message-Id: <20181203200850.6460-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

These patches are a follow up to the RFC,
http://lkml.kernel.org/r/20181024045053.1467-1-mike.kravetz@oracle.com
Comments made by Naoya were addressed.

There are two primary issues addressed here:
1) For shared pmds, huge PE pointers returned by huge_pte_alloc can become
   invalid via a call to huge_pmd_unshare by another thread.
2) hugetlbfs page faults can race with truncation causing invalid global
   reserve counts and state.
Both issues are addressed by expanding the use of i_mmap_rwsem.

These issues have existed for a long time.  They can be recreated with a
test program that causes page fault/truncation races.  For simple mappings,
this results in a negative HugePages_Rsvd count.  If racing with mappings
that contain shared pmds, we can hit "BUG at fs/hugetlbfs/inode.c:444!" or
Oops! as the result of an invalid memory reference.

I broke up the larger RFC into separate patches addressing each issue.
Hopefully, this is easier to understand/review.

Mike Kravetz (3):
  hugetlbfs: use i_mmap_rwsem for more pmd sharing synchronization
  hugetlbfs: Use i_mmap_rwsem to fix page fault/truncate race
  hugetlbfs: remove unnecessary code after i_mmap_rwsem synchronization

 fs/hugetlbfs/inode.c | 50 +++++++++----------------
 mm/hugetlb.c         | 87 +++++++++++++++++++++++++++++++-------------
 mm/memory-failure.c  | 14 ++++++-
 mm/migrate.c         | 13 ++++++-
 mm/rmap.c            |  3 ++
 mm/userfaultfd.c     | 11 +++++-
 6 files changed, 116 insertions(+), 62 deletions(-)

-- 
2.17.2
