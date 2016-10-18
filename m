Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9DAB16B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 10:50:19 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e6so224628033pfk.2
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 07:50:19 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id ti10si30125967pab.186.2016.10.18.07.50.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 07:50:18 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9IEnNLD130266
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 10:50:18 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 265kn29ehc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 10:50:18 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 18 Oct 2016 15:50:15 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id E086017D8068
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 15:52:22 +0100 (BST)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9IEoBJd7995870
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 14:50:11 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9IEoBSq031155
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 08:50:11 -0600
Subject: Re: mmap_sem bottleneck
References: <ea12b8ee-1892-fda1-8a83-20fdfdfa39c4@linux.vnet.ibm.com>
 <20161017125130.GU3142@twins.programming.kicks-ass.net>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 18 Oct 2016 16:50:10 +0200
MIME-Version: 1.0
In-Reply-To: <20161017125130.GU3142@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <4661f9fd-a239-ee82-476e-a5d039d8abee@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linux MM <linux-mm@kvack.org>, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Davidlohr Bueso <dbueso@suse.de>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 17/10/2016 14:51, Peter Zijlstra wrote:
> On Mon, Oct 17, 2016 at 02:33:53PM +0200, Laurent Dufour wrote:
>> Hi all,
>>
>> I'm sorry to resurrect this topic, but with the increasing number of
>> CPUs, this becomes more frequent that the mmap_sem is a bottleneck
>> especially between the page fault handling and the other threads memory
>> management calls.
>>
>> In the case I'm seeing, there is a lot of page fault occurring while
>> other threads are trying to manipulate the process memory layout through
>> mmap/munmap.
>>
>> There is no *real* conflict between these operations, the page fault are
>> done a different page and areas that the one addressed by the mmap/unmap
>> operations. Thus threads are dealing with different part of the
>> process's memory space. However since page fault handlers and mmap/unmap
>> operations grab the mmap_sem, the page fault handling are serialized
>> with the mmap operations, which impact the performance on large system.
>>
>> For the record, the page fault are done while reading data from a file
>> system, and I/O are really impacted by this serialization when dealing
>> with a large number of parallel threads, in my case 192 threads (1 per
>> online CPU). But the source of the page fault doesn't really matter I guess.
>>
>> I took time trying to figure out how to get rid of this bottleneck, but
>> this is definitively too complex for me.
>> I read this mailing history, and some LWN articles about that and my
>> feeling is that there is no clear way to limit the impact of this
>> semaphore. Last discussion on this topic seemed to happen last march
>> during the LSFMM submit (https://lwn.net/Articles/636334/). But this
>> doesn't seem to have lead to major changes, or may be I missed them.
>>
>> I'm now seeing that this is a big thing and that it would be hard and
>> potentially massively intrusive to get rid of this bottleneck, and I'm
>> wondering what could be to best approach here, RCU, range locks, etc..
>>
>> Does anyone have an idea ?
> 
> If its really just the pagefaults you care about you can have a look at
> my speculative page fault stuff that I don't ever seem to get around to
> updating :/
> 
> Latest version is here:
> 
>   https://lkml.kernel.org/r/20141020215633.717315139@infradead.org
> 
> Plenty of bits left to sort with that, but the general idea is to use
> the split page-table locks (PTLs) as range lock for the mmap_sem.

Thanks Peter for the pointer,

It sounds that some parts of this series are already upstream, like the
use of the fault_env structure, but the rest of the code need some
refresh to apply on the latest kernel. I'll try to update your series
and will give it a try asap.

This being said, I'm wondering if the concern Kirill raised about the
VMA sequence count handling are still valid...

By the way I'm adding Kirill in the loop since I miserably forgot to
include him when sending my initial request. My appologizes, Kirill.

Cheers,
Laurent.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
