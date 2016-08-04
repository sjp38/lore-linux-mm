Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1396B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 04:14:29 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h186so443707524pfg.2
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 01:14:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r27si13474770pfi.37.2016.08.04.01.14.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 01:14:28 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u748DrxY130316
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 04:14:28 -0400
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com [195.75.94.104])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24kngchkth-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Aug 2016 04:14:27 -0400
Received: from localhost
	by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 4 Aug 2016 09:14:25 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 7CFBF17D805A
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 09:16:00 +0100 (BST)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u748ENdx14352396
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 08:14:23 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u748ENkT031795
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 02:14:23 -0600
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 0/7]  userfaultfd: add support for shared memory
Date: Thu,  4 Aug 2016 11:14:11 +0300
Message-Id: <1470298458-9925-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

These patches enable userfaultfd support for shared memory mappings. The
VMAs backed with shmem/tmpfs can be registered with userfaultfd which
allows management of page faults in these areas by userland.

This patch set adds implementation of shmem_mcopy_atomic_pte for proper
handling of UFFDIO_COPY command. A callback to handle_userfault is added
to shmem page fault handling path. The userfaultfd register/unregister
methods are extended to allow shmem VMAs.

The UFFDIO_ZEROPAGE and UFFDIO_REGISTER_MODE_WP are not implemented which
is reflected by userfaultfd API handshake methods.

The patches are based on current Andrea's tree:
https://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git

Mike Rapoport (7):
  userfaultfd: introduce vma_can_userfault
  userfaultfd: shmem: add shmem_mcopy_atomic_pte for userfaultfd support
  userfaultfd: shmem: introduce vma_is_shmem
  userfaultfd: shmem: use shmem_mcopy_atomic_pte for shared memory
  userfaultfd: shmem: add userfaultfd hook for shared memory faults
  userfaultfd: shmem: allow registration of shared memory ranges
  userfaultfd: shmem: add userfaultfd_shmem test

 fs/userfaultfd.c                         |  32 ++++---
 include/linux/mm.h                       |  10 +++
 include/linux/shmem_fs.h                 |  11 +++
 include/uapi/linux/userfaultfd.h         |   2 +-
 mm/shmem.c                               | 139 +++++++++++++++++++++++++++++--
 mm/userfaultfd.c                         |  31 ++++---
 tools/testing/selftests/vm/Makefile      |   3 +
 tools/testing/selftests/vm/run_vmtests   |  11 +++
 tools/testing/selftests/vm/userfaultfd.c |  39 ++++++++-
 9 files changed, 237 insertions(+), 41 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
