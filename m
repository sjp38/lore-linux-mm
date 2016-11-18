Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 985746B0401
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 06:10:32 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x23so249465988pgx.6
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 03:10:32 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t27si7750386pfj.212.2016.11.18.03.10.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 03:10:29 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAIB8vZG057692
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 06:10:28 -0500
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com [195.75.94.104])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26sw2ea4qx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 06:10:28 -0500
Received: from localhost
	by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 18 Nov 2016 11:08:56 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id F1C47219006A
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 11:08:05 +0000 (GMT)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAIB8qco32899110
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 11:08:52 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAIB8qvU020836
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 04:08:52 -0700
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 0/7] Speculative page faults 
Date: Fri, 18 Nov 2016 12:08:44 +0100
In-Reply-To: <20161018150243.GZ3117@twins.programming.kicks-ass.net>
References: <20161018150243.GZ3117@twins.programming.kicks-ass.net>
Message-Id: <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A . Shutemov" <kirill@shutemov.name>, Peter Zijlstra <peterz@infradead.org>
Cc: Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>

This is a port on kernel 4.8 of the work done by Peter Zijlstra to
handle page fault without holding the mm semaphore.

http://linux-kernel.2935.n7.nabble.com/RFC-PATCH-0-6-Another-go-at-speculative-page-faults-tt965642.html#none

This series is not yet functional, I'm sending it to get feedback
before going forward in the wrong direction. It's building on top of
the 4.8 kernel but some task remain stuck at runtime, so there is
still need for additional work. 

According to the review made by Kirill A. Shutemov on the Peter's
work, there are still pending issues around the VMA sequence count
management. I'll look at it right now.

Kirill, Peter, if you have any tips on the place where VMA sequence
count should be handled, please advise.

Laurent Dufour (1):
  mm: Introduce pte_spinlock

Peter Zijlstra (6):
  mm: Dont assume page-table invariance during faults
  mm: Prepare for FAULT_FLAG_SPECULATIVE
  mm: VMA sequence count
  SRCU free VMAs
  mm: Provide speculative fault infrastructure
  mm,x86: Add speculative pagefault handling

 arch/x86/mm/fault.c      |  18 ++++
 include/linux/mm.h       |   4 +
 include/linux/mm_types.h |   3 +
 kernel/fork.c            |   1 +
 mm/init-mm.c             |   1 +
 mm/internal.h            |  18 ++++
 mm/memory.c              | 257 +++++++++++++++++++++++++++++++++++++----------
 mm/mmap.c                |  99 ++++++++++++++----
 8 files changed, 330 insertions(+), 71 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
