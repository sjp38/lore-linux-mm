Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m6SJIm6u024292
	for <linux-mm@kvack.org>; Mon, 28 Jul 2008 15:18:48 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6SJHMql180000
	for <linux-mm@kvack.org>; Mon, 28 Jul 2008 15:17:22 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6SJHLjE004893
	for <linux-mm@kvack.org>; Mon, 28 Jul 2008 15:17:21 -0400
From: Eric Munson <ebmunson@us.ibm.com>
Subject: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
Date: Mon, 28 Jul 2008 12:17:10 -0700
Message-Id: <cover.1216928613.git.ebmunson@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net, Eric Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Certain workloads benefit if their data or text segments are backed by
huge pages. The stack is no exception to this rule but there is no
mechanism currently that allows the backing of a stack reliably with
huge pages.  Doing this from userspace is excessively messy and has some
awkward restrictions.  Particularly on POWER where 256MB of address space
gets wasted if the stack is setup there.

This patch stack introduces a personality flag that indicates the kernel
should setup the stack as a hugetlbfs-backed region. A userspace utility
may set this flag then exec a process whose stack is to be backed by
hugetlb pages.

Eric Munson (5):
  Align stack boundaries based on personality
  Add shared and reservation control to hugetlb_file_setup
  Split boundary checking from body of do_munmap
  Build hugetlb backed process stacks
  [PPC] Setup stack memory segment for hugetlb pages

 arch/powerpc/mm/hugetlbpage.c |    6 +
 arch/powerpc/mm/slice.c       |   11 ++
 fs/exec.c                     |  209 ++++++++++++++++++++++++++++++++++++++---
 fs/hugetlbfs/inode.c          |   52 +++++++----
 include/asm-powerpc/hugetlb.h |    3 +
 include/linux/hugetlb.h       |   22 ++++-
 include/linux/mm.h            |    1 +
 include/linux/personality.h   |    3 +
 ipc/shm.c                     |    2 +-
 mm/mmap.c                     |   11 ++-
 10 files changed, 284 insertions(+), 36 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
