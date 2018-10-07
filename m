Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6B96B000D
	for <linux-mm@kvack.org>; Sun,  7 Oct 2018 19:39:17 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id x5-v6so5288279ywd.19
        for <linux-mm@kvack.org>; Sun, 07 Oct 2018 16:39:17 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id p67-v6si3733213ybp.473.2018.10.07.16.39.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Oct 2018 16:39:16 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH RFC 0/1] hugetlbfs: fix truncate/fault races
Date: Sun,  7 Oct 2018 16:38:47 -0700
Message-Id: <20181007233848.13397-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Mike Kravetz <mike.kravetz@oracle.com>

Our DB team noticed negative hugetlb reserved page counts during development
testing.  Related meminfo fields were as follows on one system:

HugePages_Total:   47143
HugePages_Free:    45610
HugePages_Rsvd:    18446744073709551613
HugePages_Surp:        0
Hugepagesize:       2048 kB 

Code inspection revealed that the most likely cause were races with truncate
and page faults.  In fact, I could write a not too complicated program to
cause the races and recreate the issue.

Way back in 2006, Hugh Dickins created a patch (ebed4bfc8da8) with this
message:

"[PATCH] hugetlb: fix absurd HugePages_Rsvd
    
 If you truncated an mmap'ed hugetlbfs file, then faulted on the truncated
 area, /proc/meminfo's HugePages_Rsvd wrapped hugely "negative".  Reinstate my
 preliminary i_size check before attempting to allocate the page (though this
 only fixes the most obvious case: more work will be needed here)."

Looks like we need to do more work.

While looking at the code, there were many issues to correctly handle racing
and back out changes partially made.  Instead, why not just introduce a
rw mutex to prevent the races.  Page faults would take the mutex in read mode
to allow multiple faults in parallel as it works today.  Truncate code would
take the mutex in write mode and prevent faults for the duration of truncate
processing.  This seems almost too obvious.  Something must be wrong with this
approach, or others would have employed it earlier.

The following patch describes the current race in detail and adds the mutex
to prevent truncate/fault races.

Mike Kravetz (1):
  hugetlbfs: introduce truncation/fault mutex to avoid races

 fs/hugetlbfs/inode.c    | 24 ++++++++++++++++++++----
 include/linux/hugetlb.h |  1 +
 mm/hugetlb.c            | 25 +++++++++++++++++++------
 mm/userfaultfd.c        |  8 +++++++-
 4 files changed, 47 insertions(+), 11 deletions(-)

-- 
2.17.1
