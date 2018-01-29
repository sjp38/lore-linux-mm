Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E50C6B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 09:29:50 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id j41so4350976qkh.3
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 06:29:50 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y48si4004322qty.366.2018.01.29.06.29.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jan 2018 06:29:49 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0TEO2Vh120136
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 09:29:49 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ft56h8p1r-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 09:29:48 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 29 Jan 2018 14:29:46 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [LSF/MM TOPIC] Addressing mmap_sem contention
Date: Mon, 29 Jan 2018 15:29:41 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <4c20d397-1268-ca0f-4986-af59bb31022c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: Linux MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Davidlohr Bueso <dave@stgolabs.net>, Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, Peter Zijlstra <peterz@infradead.org>

Hi,

I would like to talk about the way to remove the mmap_sem contention we
could see on large threaded systems.

I already resurrected the Speculative Page Fault patchset from Peter
Zijlstra [1]. This series allows concurrency between page fault handler and
the other thread's activity. Running a massively threaded benchmark like
ebizzy [2] on top of this kernel shows that there is an opportunity to
scale far better on large systems (x2). But the SPF series is addressing
only one part of the issue, and there is a need to address the other part
of picture.

There have been some discussions last year about the range locking but this
has been put in hold, especially because this implies huge change in the
kernel as the mmap_sem is used to protect so many resources (should we need
to protect the process command line with the mmap_sem ?), and sometimes the
assumption is made that the mmap_sem is protecting code against concurrency
while it is not dealing clearly with the mmap_sem.

This will be a massive change and rebasing such a series will be hard, so
it may be far better to first agreed on best options to improve mmap_sem's
performance and scalability. There are several additional options on the
table, including range locking,    multiple fine-grained locks, etc...
In addition, I would like to discuss the options and the best way to make
the move smooth in breaking or replacing the mmap_sem.

Peoples (sorry if I missed someone) :
    Andrea Arcangeli
    Davidlohr Bueso
    Michal Hocko
    Anshuman Khandual
    Andi Kleen
    Andrew Morton
    Matthew Wilcox
    Peter Zijlstra

Thanks,
Laurent
[1] https://lkml.org/lkml/2018/1/12/515
[2] http://ebizzy.sourceforge.net/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
