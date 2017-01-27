Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A82C6B0038
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:44:58 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id ez4so48881119wjd.2
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 10:44:58 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 204si3755589wmh.92.2017.01.27.10.44.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 10:44:56 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0RIcgFT089973
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:44:55 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2884ka9abn-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:44:54 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 27 Jan 2017 18:44:53 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2 0/5] userfaultfd: non-cooperative: better tracking for mapping changes
Date: Fri, 27 Jan 2017 20:44:28 +0200
Message-Id: <1485542673-24387-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

These patches try to address issues I've encountered during integration of
userfaultfd with CRIU.
Previously added userfaultfd events for fork(), madvise() and mremap()
unfortunately do not cover all possible changes to a process virtual memory
layout required for uffd monitor.
When one or more VMAs is removed from the process mm, the external uffd
monitor has no way to detect those changes and will attempt to fill the
removed regions with userfaultfd_copy.
Another problematic event is the exit() of the process. Here again, the
external uffd monitor will try to use userfaultfd_copy, although mm owning
the memory has already gone.

The first patch in the series is a minor cleanup and it's not strictly
related to the rest of the series.
 
The patches 2 and 3 below add UFFD_EVENT_UNMAP and UFFD_EVENT_EXIT to allow
the uffd monitor track changes in the memory layout of a process.

The patches 4 and 5 amend error codes returned by userfaultfd_copy to make
the uffd monitor able to cope with races that might occur between delivery
of unmap and exit events and outstanding userfaultfd_copy's.

The patches are agains current -mm tree.

v2: fix several do_munmap call sites I've missed in v1

Mike Rapoport (5):
  mm: call vm_munmap in munmap syscall instead of using open coded
    version
  userfaultfd: non-cooperative: add event for memory unmaps
  userfaultfd: non-cooperative: add event for exit() notification
  userfaultfd: mcopy_atomic: return -ENOENT when no compatible VMA found
  userfaultfd_copy: return -ENOSPC in case mm has gone

 arch/mips/kernel/vdso.c          |  2 +-
 arch/tile/mm/elf.c               |  2 +-
 arch/x86/entry/vdso/vma.c        |  2 +-
 arch/x86/mm/mpx.c                |  4 +-
 fs/aio.c                         |  2 +-
 fs/proc/vmcore.c                 |  4 +-
 fs/userfaultfd.c                 | 91 ++++++++++++++++++++++++++++++++++++++++
 include/linux/mm.h               | 14 ++++---
 include/linux/userfaultfd_k.h    | 25 +++++++++++
 include/uapi/linux/userfaultfd.h |  8 +++-
 ipc/shm.c                        |  6 +--
 kernel/exit.c                    |  2 +
 mm/mmap.c                        | 55 ++++++++++++++----------
 mm/mremap.c                      | 23 ++++++----
 mm/userfaultfd.c                 | 42 ++++++++++---------
 mm/util.c                        |  5 ++-
 16 files changed, 217 insertions(+), 70 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
