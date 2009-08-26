Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 20A0E6B0136
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 06:51:55 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7QAojM9028935
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 06:50:45 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7QAixLo212520
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 06:47:49 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7QAixYG007939
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 06:44:59 -0400
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: [PATCH 0/3] Add pseudo-anonymous huge page mappings V4
Date: Wed, 26 Aug 2009 11:44:50 +0100
Message-Id: <cover.1251282769.git.ebmunson@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: linux-man@vger.kernel.org, mtk.manpages@gmail.com, randy.dunlap@oracle.com, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch set adds a flag to mmap that allows the user to request
a mapping to be backed with huge pages.  This mapping will borrow
functionality from the huge page shm code to create a file on the
kernel internal mount and use it to approximate an anonymous mapping.
The MAP_HUGETLB flag is a modifier to MAP_ANONYMOUS and will not work
without both flags being preset.

A new flag is necessary because there is no other way to hook into
huge pages without creating a file on a hugetlbfs mount which
wouldn't be MAP_ANONYMOUS.

To userspace, this mapping will behave just like an anonymous mapping
because the file is not accessible outside of the kernel.

This patch set is meant to simplify the programming model, presently
there is a large chunk of boiler plate code, contained in libhugetlbfs,
required to create private, hugepage backed mappings.  This patch set
would allow use of hugepages without linking to libhugetlbfs or having
hugetblfs mounted.

Unification of the VM code would provide these same benefits, but it
has been resisted each time that it has been suggested for several
reasons: it would break PAGE_SIZE assumptions across the kernel, it
makes page-table abstractions really expensive, and it does not
provide any benefit on architectures that do not support huge pages,
incurring fast path penalties without providing any benefit on these
architectures.

Eric B Munson (3):
  hugetlbfs: Allow the creation of files suitable for MAP_PRIVATE on
    the vfs internal mount
  Add MAP_HUGETLB for mmaping pseudo-anonymous huge page regions
  Add MAP_HUGETLB example

 Documentation/vm/00-INDEX         |    2 +
 Documentation/vm/hugetlbpage.txt  |   14 ++++---
 Documentation/vm/map_hugetlb.c    |   77 +++++++++++++++++++++++++++++++++++++
 fs/hugetlbfs/inode.c              |   21 ++++++++--
 include/asm-generic/mman-common.h |    1 +
 include/linux/hugetlb.h           |   19 ++++++++-
 ipc/shm.c                         |    2 +-
 mm/mmap.c                         |   19 +++++++++
 8 files changed, 142 insertions(+), 13 deletions(-)
 create mode 100644 Documentation/vm/map_hugetlb.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
