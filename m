Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6103C6B2924
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 03:41:10 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id w12-v6so6946610oie.12
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 00:41:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e16-v6si5066099oih.276.2018.08.24.00.41.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 00:41:08 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w7O7dDtK097701
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 03:41:08 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2m29v0qqyy-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 03:41:06 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 24 Aug 2018 08:41:04 +0100
Subject: Re: using range locks instead of mm_sem
References: <9ea84ad8-0404-077e-200d-14ad749cb784@oracle.com>
 <20180822144640.GB3677@linux-r8p5>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Fri, 24 Aug 2018 09:40:59 +0200
MIME-Version: 1.0
In-Reply-To: <20180822144640.GB3677@linux-r8p5>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <744f3cf3-d4ec-e3a6-e56d-8009dd8c5f14@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shady Issa <shady.issa@oracle.com>, Alex Kogan <alex.kogan@oracle.com>, Dave Dice <dave.dice@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, jack@suse.com, linux-mm@kvack.org

On 22/08/2018 16:46, Davidlohr Bueso wrote:
> On Wed, 22 Aug 2018, Shady Issa wrote:
> 
>>
>> Hi Davidlohr,
>>
>> I am interested in the idea of using range locks to replace mm_sem. I wanted to
>> start trying out using more fine-grained ranges instead of the full range
>> acquisitions
>> that are used in this patch (https://lkml.org/lkml/2018/2/4/235). However, it
>> does not
>> seem straight forward to me how this is possible.
>>
>> First, the ranges that can be defined before acquiring the range lock based
>> on the
>> caller's input(i.e. ranges supplied by mprotect, mmap, munmap, etc.) are
>> oblivious of
>> the underlying VMAs. Two non-overlapping ranges can fall within the same VMA and
>> thus should not be allowed to run concurrently in case they are writes.
> 
> Yes. This is a _big_ issue with range locking the addr space. I have yet
> to find a solution other than delaying vma modifying ops to avoid the races,
> which is fragile. Obviously locking the full range in such scenarios cannot
> be done either.

I think the range locked should be aligned to the underlying VMA plus one page
on each side to prevent that VMA to be merged.
But this raises a concern with the VMA merging mechanism which tends to limit
the number of VMAs and could lead to a unique VMA, limiting the advantage of a
locking based on the VMA's boundaries.

>>
>> Second, even if ranges from the caller function are aligned with VMAs, the
>> extent of the
>> effect of operation is unknown. It is probable that an operation touching one
>> VMA will
>> end up performing modifications to the VMAs rbtree structure due to splits,
>> merges, etc.,
>> which requires the full range acquisition and is unknown beforehand.
> 
> Yes, this is similar to the above as well.
> 
>>
>> I was wondering if I am missing something with this thought process, because
>> with the
>> current givings, it seems to me that range locks will boil down to just r/w
>> semaphore.
>> I would also be very grateful if you can point me to any more recent
>> discussions regarding
>> the use of range locks after this patch from February.
> 
> You're on the right page.
> 
> Thanks,
> Davidlohr
> 
