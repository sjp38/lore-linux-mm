Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 22B0B6B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 08:34:04 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id d186so100130254lfg.7
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 05:34:04 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v72si18689360lfi.79.2016.10.17.05.34.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 05:34:02 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9HCTdX1144068
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 08:34:01 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 264tfsm404-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 08:34:00 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 17 Oct 2016 13:33:59 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 045B817D8056
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 13:36:07 +0100 (BST)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9HCXu6K9109698
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 12:33:56 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9HCXsKD032694
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 06:33:55 -0600
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: mmap_sem bottleneck
Date: Mon, 17 Oct 2016 14:33:53 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <ea12b8ee-1892-fda1-8a83-20fdfdfa39c4@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, Andi Kleen <ak@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Davidlohr Bueso <dbueso@suse.de>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Hi all,

I'm sorry to resurrect this topic, but with the increasing number of
CPUs, this becomes more frequent that the mmap_sem is a bottleneck
especially between the page fault handling and the other threads memory
management calls.

In the case I'm seeing, there is a lot of page fault occurring while
other threads are trying to manipulate the process memory layout through
mmap/munmap.

There is no *real* conflict between these operations, the page fault are
done a different page and areas that the one addressed by the mmap/unmap
operations. Thus threads are dealing with different part of the
process's memory space. However since page fault handlers and mmap/unmap
operations grab the mmap_sem, the page fault handling are serialized
with the mmap operations, which impact the performance on large system.

For the record, the page fault are done while reading data from a file
system, and I/O are really impacted by this serialization when dealing
with a large number of parallel threads, in my case 192 threads (1 per
online CPU). But the source of the page fault doesn't really matter I guess.

I took time trying to figure out how to get rid of this bottleneck, but
this is definitively too complex for me.
I read this mailing history, and some LWN articles about that and my
feeling is that there is no clear way to limit the impact of this
semaphore. Last discussion on this topic seemed to happen last march
during the LSFMM submit (https://lwn.net/Articles/636334/). But this
doesn't seem to have lead to major changes, or may be I missed them.

I'm now seeing that this is a big thing and that it would be hard and
potentially massively intrusive to get rid of this bottleneck, and I'm
wondering what could be to best approach here, RCU, range locks, etc..

Does anyone have an idea ?

Thanks,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
