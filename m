Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE2FB6B0038
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 03:23:44 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h24so17116261pfh.0
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 00:23:44 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e1si43824523pfl.160.2016.10.20.00.23.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 00:23:43 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9K7IwMl021992
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 03:23:43 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 266rpxhwpc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 03:23:43 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 20 Oct 2016 08:23:40 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 4443F17D8068
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 08:25:51 +0100 (BST)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9K7Ndkx10551592
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 07:23:39 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9K6NeWi017651
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 00:23:40 -0600
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: Re: mmap_sem bottleneck
References: <ea12b8ee-1892-fda1-8a83-20fdfdfa39c4@linux.vnet.ibm.com>
 <20161017125717.GK23322@dhcp22.suse.cz>
Date: Thu, 20 Oct 2016 09:23:37 +0200
MIME-Version: 1.0
In-Reply-To: <20161017125717.GK23322@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <e1e865c5-51ab-fce1-0958-b5c668da4dac@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Linux MM <linux-mm@kvack.org>, Andi Kleen <ak@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>, Davidlohr Bueso <dbueso@suse.de>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On 17/10/2016 14:57, Michal Hocko wrote:
> On Mon 17-10-16 14:33:53, Laurent Dufour wrote:
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
> 
> Could you quantify how much overhead are we talking about here?

I recorded perf data using a sampler which recreates the bottleneck
issueby simulating the database initialization process which spawns a
thread per cpu in charge of allocating a piece of memory and request a
disk reading in it.

The perf data shows that 23% of the time is spent waiting for the
mm semaphore in do_page_fault(). This has been recording using a 4.8-rc8
kernel on pppc64le architecture.

>> For the record, the page fault are done while reading data from a file
>> system, and I/O are really impacted by this serialization when dealing
>> with a large number of parallel threads, in my case 192 threads (1 per
>> online CPU). But the source of the page fault doesn't really matter I guess.
> 
> But we are dropping the mmap_sem for the IO and retry the page fault.
> I am not sure I understood you correctly here though.
> 
>> I took time trying to figure out how to get rid of this bottleneck, but
>> this is definitively too complex for me.
>> I read this mailing history, and some LWN articles about that and my
>> feeling is that there is no clear way to limit the impact of this
>> semaphore. Last discussion on this topic seemed to happen last march
>> during the LSFMM submit (https://lwn.net/Articles/636334/). But this
>> doesn't seem to have lead to major changes, or may be I missed them.
> 
> At least mmap/munmap write lock contention could be reduced by the above
> proposed range locking. Jan Kara has implemented a prototype [1] of the
> lock for mapping which could be used for mmap_sem as well) but it had
> some perfomance implications AFAIR. There wasn't a strong usecase for
> this so far. If there is one, please describe it and we can think what
> to do about it.

When recreating the issue with a sampler there is no file system I/O in
the picture, just pure mmap/memcpy and a lot of threads (I need about
192 CPUs to recreate it).
But there is a real use case, beyond that. The SAP HANA database is
using all the available CPUs to read the database from the disk when
starting. When run on top flash storage and a large number of CPUs
(>192), we hit the mm semaphore bottleneck which impact the loading
performance by serializing the memory management.

I think there is a place for enhancements in the user space part (the
database loader), but the mm semaphore is still a bottleneck when a
massively multi-threaded process is dealing with its memory while page
faulting on it.
Unfortunately, this requires big system to recreate such an issue which
make it harder to track and investigate.


> There were also some attempts to replace mmap_sem by RCU AFAIR but my
> vague recollection is that they had some issues as well.
> 
> [1] http://linux-kernel.2935.n7.nabble.com/PATCH-0-6-RFC-Mapping-range-lock-td592872.html

I took a look to this series which is very interesting but it is
quite old now, and I'm wondering if it is still applicable.

Cheers,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
