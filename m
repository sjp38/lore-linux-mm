Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0574F6B000A
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 10:56:43 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id s3-v6so17448333plp.21
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 07:56:42 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id w20-v6si13074887pgf.434.2018.07.12.07.56.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 07:56:41 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 0/2] Fix crash due to vma_is_anonymous() false-positives
Date: Thu, 12 Jul 2018 17:56:24 +0300
Message-Id: <20180712145626.41665-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>


Fix crash found by syzkaller.

The fix allows to remove ->vm_ops checks.

v2:
 - Catch few more cases where we need to initialize ->vm_ops:
   + nommu;
   + ia64;
 - Make sure that we initialize ->vm_ops even if ->mmap failed.
   We need ->vm_ops in error path too.

Kirill A. Shutemov (2):
  mm: Fix vma_is_anonymous() false-positives
  mm: Drop unneeded ->vm_ops checks

 arch/ia64/kernel/perfmon.c |  1 +
 arch/ia64/mm/init.c        |  2 ++
 drivers/char/mem.c         |  1 +
 fs/binfmt_elf.c            |  2 +-
 fs/exec.c                  |  1 +
 fs/hugetlbfs/inode.c       |  1 +
 fs/kernfs/file.c           | 20 +-------------------
 fs/proc/task_mmu.c         |  2 +-
 include/linux/mm.h         |  5 ++++-
 kernel/events/core.c       |  2 +-
 kernel/fork.c              |  2 +-
 mm/gup.c                   |  2 +-
 mm/hugetlb.c               |  2 +-
 mm/khugepaged.c            |  4 ++--
 mm/memory.c                | 12 ++++++------
 mm/mempolicy.c             | 10 +++++-----
 mm/mmap.c                  | 25 ++++++++++++++++++-------
 mm/mremap.c                |  2 +-
 mm/nommu.c                 | 13 ++++++++++---
 mm/shmem.c                 |  1 +
 mm/util.c                  | 12 ++++++++++++
 21 files changed, 72 insertions(+), 50 deletions(-)

-- 
2.18.0
