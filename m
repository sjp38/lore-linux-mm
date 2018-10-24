Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 26A026B0003
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 00:51:10 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id d7-v6so3680210itf.7
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 21:51:10 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id j199-v6si2562591ita.114.2018.10.23.21.51.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 21:51:08 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH RFC v2 0/1] hugetlbfs: Use i_mmap_rwsem for pmd share and fault/trunc
Date: Tue, 23 Oct 2018 21:50:52 -0700
Message-Id: <20181024045053.1467-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>, Mike Kravetz <mike.kravetz@oracle.com>

This patch addresses issues with page fault/truncation synchronization.
The first issue was noticed as a negative hugetlb reserved page counts
during DB development testing.  Code inspection revealed that the most
likely cause were races with truncate and page faults.  In fact, I could
write a not too complicated program to cause the races and recreate the
issue.

A more dangerous issue exists when you introduce huge pmd sharing to
page fault/truncate races.  The fist thing that happens in huge page
fault processing is a call to huge_pte_alloc to get a ptep.  Suppose
that ptep points to a shared pmd.  Now, another thread could perform
a truncate and unmap everyone mapping the file.  huge_pmd_unshare can
be called for the mapping on which the first thread is operating.
huge_pmd_unshare can clear pud pointing to the pmd.  After this, the
ptep points to another task's page table or worse.  This leads to bad
things such as incorrect page map/reference counts or invaid memory
references.

Fix this all by modifying the usage of i_mmap_rwsem to cover
fault/truncate races as well as handling of shared pmds

Mike Kravetz (1):
  hugetlbfs: use i_mmap_rwsem for pmd sharing and truncate/fault sync

 fs/hugetlbfs/inode.c | 21 ++++++++++----
 mm/hugetlb.c         | 65 +++++++++++++++++++++++++++++++++-----------
 mm/rmap.c            | 10 +++++++
 mm/userfaultfd.c     | 11 ++++++--
 4 files changed, 84 insertions(+), 23 deletions(-)

-- 
2.17.2
