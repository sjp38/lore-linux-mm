Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id F40136B0038
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 19:55:47 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so35480908pad.1
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 16:55:47 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id he2si8744224pbc.153.2015.10.20.16.55.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Oct 2015 16:55:46 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2 0/4] hugetlbfs fallocate hole punch race with page faults
Date: Tue, 20 Oct 2015 16:52:18 -0700
Message-Id: <1445385142-29936-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

The hugetlbfs fallocate hole punch code can race with page faults.  The
result is that after a hole punch operation, pages may remain within the
hole.  No other side effects of this race were observed.

In preparation for adding userfaultfd support to hugetlbfs, it is desirable
to close the window of this race.  This patch set starts by using the same
mechanism employed in shmem (see commit f00cdc6df7).  This greatly reduces
the race window.  However, it is still possible for the race to occur.

The current hugetlbfs code to remove pages did not deal with pages that
were mapped (because of such a race).  This patch set also adds code to
unmap pages in this rare case.  This unmapping of a single page happens
under the hugetlb_fault_mutex, so it can not be faulted again until the
end of the operation.

v2:
  Incorporated Andrew Morton's cleanups and added suggested comments
  Added patch 4/4 to unmap single pages in remove_inode_hugepages

Mike Kravetz (4):
  mm/hugetlb: Define hugetlb_falloc structure for hole punch race
  mm/hugetlb: Setup hugetlb_falloc during fallocate hole punch
  mm/hugetlb: page faults check for fallocate hole punch in progress and
    wait
  mm/hugetlb: Unmap pages to remove if page fault raced with hole punch

 fs/hugetlbfs/inode.c    | 155 ++++++++++++++++++++++++++++--------------------
 include/linux/hugetlb.h |  10 ++++
 mm/hugetlb.c            |  39 ++++++++++++
 3 files changed, 141 insertions(+), 63 deletions(-)

-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
