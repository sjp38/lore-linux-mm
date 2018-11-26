Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9586B42CE
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 12:35:00 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id n50so17351688qtb.9
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 09:35:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o56si775461qvh.84.2018.11.26.09.34.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 09:34:58 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/5] userfaultfd shmem updates
Date: Mon, 26 Nov 2018 12:34:47 -0500
Message-Id: <20181126173452.26955-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Jann Horn <jannh@google.com>, Peter Xu <peterx@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

Hello,

Jann found two bugs in the userfaultfd shmem MAP_SHARED backend: the
lack of the VM_MAYWRITE check and the lack of i_size checks.

Then looking into the above we also fixed the MAP_PRIVATE case.

Hugh by source review also found a data loss source if UFFDIO_COPY is
used on shmem MAP_SHARED PROT_READ mappings (the production usages
incidentally run with PROT_READ|PROT_WRITE, so the data loss couldn't
happen in those production usages like with QEMU).

The whole patchset is marked for stable.

We verified QEMU postcopy live migration with guest running on shmem
MAP_PRIVATE run as well as before after the fix of shmem
MAP_PRIVATE. Regardless if it's shmem or hugetlbfs or MAP_PRIVATE or
MAP_SHARED, QEMU unconditionally invokes a punch hole if the guest
mapping is filebacked and a MADV_DONTNEED too (needed to get rid of
the MAP_PRIVATE COWs and for the anon backend).

Thank you,
Andrea

Andrea Arcangeli (5):
  userfaultfd: use ENOENT instead of EFAULT if the atomic copy user
    fails
  userfaultfd: shmem: allocate anonymous memory for MAP_PRIVATE shmem
  userfaultfd: shmem/hugetlbfs: only allow to register VM_MAYWRITE vmas
  userfaultfd: shmem: add i_size checks
  userfaultfd: shmem: UFFDIO_COPY: set the page dirty if VM_WRITE is not
    set

 fs/userfaultfd.c | 15 ++++++++++++
 mm/hugetlb.c     |  2 +-
 mm/shmem.c       | 31 +++++++++++++++++++++---
 mm/userfaultfd.c | 62 +++++++++++++++++++++++++++++++++++-------------
 4 files changed, 90 insertions(+), 20 deletions(-)
