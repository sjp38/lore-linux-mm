Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4CBD66B0087
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 08:22:08 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8ICKJhe012055
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 06:20:19 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8ICMCoS218724
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 06:22:12 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8ICM8LS013633
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 06:22:12 -0600
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: [PATCH 0/7] Add pseudo-anonymous huge page mappings V3
Date: Fri, 18 Sep 2009 06:21:46 -0600
Message-Id: <cover.1253272709.git.ebmunson@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: rdunlap@xenotime.net, michael@ellerman.id.au, ralf@linux-mips.org, wli@holomorphy.com, mel@csn.ul.ie, dhowells@redhat.com, arnd@arndb.de, fengguang.wu@intel.com, shuber2@gmail.com, hugh.dickins@tiscali.co.uk, zohar@us.ibm.com, hugh@veritas.com, mtk.manpages@gmail.com, chris@zankel.net, linux-man@vger.kernel.org, linux-doc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, Eric B Munson <ebmunson@us.ibm.com>
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

This verion includes the fixes posted to linux-mm as well as additions
to mman.h for the four archtiectures that do not make use of
mman-common.h.  The addition of the MAP_HUGETLB flag to these four
(xtensa, parisc, alpha, and mips) is required because MAP_HUGETLB is
used in common vm code.

Eric B Munson (7):
  hugetlbfs: Allow the creation of files suitable for MAP_PRIVATE on
    the vfs internal mount
  Add MAP_HUGETLB for mmaping pseudo-anonymous huge page regions
  Add MAP_HUGETLB example
  Add MAP_HUGETLB flag to alpha mman.h
  Add MAP_HUGETLB flag to xtensa mman.h
  Add MAP_HUGETLB flag to parisc mman.h
  Add MAP_HUGETLB flag to mips mman.h

 Documentation/vm/00-INDEX         |    2 +
 Documentation/vm/hugetlbpage.txt  |   14 ++++---
 Documentation/vm/map_hugetlb.c    |   77 +++++++++++++++++++++++++++++++++++++
 arch/alpha/include/asm/mman.h     |    6 +++
 arch/mips/include/asm/mman.h      |    6 +++
 arch/parisc/include/asm/mman.h    |    7 +++
 arch/xtensa/include/asm/mman.h    |    6 +++
 fs/hugetlbfs/inode.c              |   13 +++++-
 include/asm-generic/mman-common.h |    1 +
 include/linux/hugetlb.h           |   19 ++++++++-
 ipc/shm.c                         |    2 +-
 mm/mmap.c                         |   19 +++++++++
 12 files changed, 160 insertions(+), 12 deletions(-)
 create mode 100644 Documentation/vm/map_hugetlb.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
