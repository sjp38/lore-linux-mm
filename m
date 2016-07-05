Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C71576B025F
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 08:00:52 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a69so443882495pfa.1
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 05:00:52 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id hi6si3602617pac.108.2016.07.05.05.00.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 05:00:50 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u65BsAhV076847
	for <linux-mm@kvack.org>; Tue, 5 Jul 2016 08:00:49 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23x7xfgfqk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 05 Jul 2016 08:00:49 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Tue, 5 Jul 2016 13:00:46 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id C5F3917D8056
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 13:02:05 +0100 (BST)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u65C0gvR5177678
	for <linux-mm@kvack.org>; Tue, 5 Jul 2016 12:00:42 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u65C0gTv009361
	for <linux-mm@kvack.org>; Tue, 5 Jul 2016 06:00:42 -0600
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH 0/2][RFC] mm callback for batched pte updates
Date: Tue,  5 Jul 2016 14:00:38 +0200
Message-Id: <1467720040-4280-1-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>

Hello,

there is another peculiarity on s390 I would like to exploit, the
range option of the IPTE instruction. This is an extension that allows
to set the invalid bit and clear the associated TLB entry for multiple
page table entries with a single instruction instead of doing an IPTE
for each pte. Each IPTE or IPTE-range is a quiescing operation, basically
an IPI to all other CPUs to coordinate the pte invalidation.

The IPTE-range is useful in mulit-threaded programs for a fork or a
mprotect/munmap/mremap affecting large memory areas where s390 may not
just do the pte update and clear the TLBs later.

In order to add the IPTE range optimization another mm callback is
needed in copy_page_range, unmap_page_range, move_page_tables, and
change_protection_range. The name is 'ptep_prepare_range', suggestions
for a better name are welcome.

With the two patches the update for the ptes inside a single page table
is done in two steps. First the prep_prepare_range invalidates all ptes,
this makes the address range inaccessible for all CPUs. The pages are
still marked as present and could be revalidated again if the page table
lock is released, but this does not happen with the current code.
The second step is the usual update loop over all single ptes.

Given a multi-threaded program a fork or a mprotect/munmap/mremap of a
large address range now needs fewer IPTEs / IPIs by a factor up to 256.
My mprotect stress test runs faster by an order of magnitude.

Martin Schwidefsky (2):
  mm: add callback to prepare the update of multiple page table entries
  s390/mm: use ipte range to invalidate multiple page table entries

 arch/s390/include/asm/pgtable.h | 25 +++++++++++++++++++++++++
 arch/s390/include/asm/setup.h   |  2 ++
 arch/s390/kernel/early.c        |  2 ++
 arch/s390/mm/pageattr.c         |  2 +-
 arch/s390/mm/pgtable.c          | 17 +++++++++++++++++
 include/asm-generic/pgtable.h   |  4 ++++
 mm/memory.c                     |  2 ++
 mm/mprotect.c                   |  1 +
 mm/mremap.c                     |  1 +
 9 files changed, 55 insertions(+), 1 deletion(-)

-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
