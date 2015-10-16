Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9167B82F66
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 18:10:49 -0400 (EDT)
Received: by pabws5 with SMTP id ws5so1458002pab.1
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 15:10:49 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id tg7si32167201pbc.190.2015.10.16.15.10.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 15:10:48 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 0/3] hugetlbfs fallocate hole punch race with page faults
Date: Fri, 16 Oct 2015 15:08:27 -0700
Message-Id: <1445033310-13155-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

The hugetlbfs fallocate hole punch code can race with page faults.  The
result is that after a hole punch operation, pages may remain within the
hole.  No other side effects of this race were observed.

In preparation for adding userfaultfd support to hugetlbfs, it is desirable
to plug or significantly shrink this hole.  This patch set uses the same
mechanism employed in shmem (see commit f00cdc6df7).

hugetlb_fault_mutex_table is already used in hugetlbfs for fault
synchronization, and there is no swap for hugetlbfs. So, this code is
simpler than in shmem.  In fact, the hugetlb_fault_mutex_table could be
used for races with small hole punch operations.  However, we need something
that will work for large holes as well.

Mike Kravetz (3):
  mm/hugetlb: Define hugetlb_falloc structure for hole punch race
  mm/hugetlb: Setup hugetlb_falloc during fallocate hole punch
  mm/hugetlb: page faults check for fallocate hole punch in progress and
    wait

 fs/hugetlbfs/inode.c    | 26 +++++++++++++++++++++++---
 include/linux/hugetlb.h | 10 ++++++++++
 mm/hugetlb.c            | 37 +++++++++++++++++++++++++++++++++++++
 3 files changed, 70 insertions(+), 3 deletions(-)

-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
