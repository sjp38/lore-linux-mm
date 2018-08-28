Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 208626B44FC
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 03:51:52 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id b8-v6so615637oib.4
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 00:51:52 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u84-v6si247896oie.30.2018.08.28.00.51.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 00:51:50 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w7S7mSHY022314
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 03:51:50 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2m5145kcc8-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 03:51:49 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 28 Aug 2018 08:51:47 +0100
Subject: Re: using range locks instead of mm_sem
References: <9ea84ad8-0404-077e-200d-14ad749cb784@oracle.com>
 <20180822144640.GB3677@linux-r8p5>
 <744f3cf3-d4ec-e3a6-e56d-8009dd8c5f14@linux.vnet.ibm.com>
 <09ab74a2-f996-de7c-b0b2-46d82c971976@oracle.com>
 <1AFAF0C5-0C8C-4CAD-9027-10C621B49C01@oracle.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 28 Aug 2018 09:51:42 +0200
MIME-Version: 1.0
In-Reply-To: <1AFAF0C5-0C8C-4CAD-9027-10C621B49C01@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Message-Id: <9b3202bd-3c91-4c40-6faa-e9d71eb6c018@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Kogan <alex.kogan@oracle.com>
Cc: Dave Dice <dave.dice@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, jack@suse.com, linux-mm@kvack.org, Shady Issa <shady.issa@oracle.com>

On 27/08/2018 21:41, Alex Kogan wrote:
> 
>> On Aug 24, 2018, at 6:39 PM, Shady Issa <shady.issa@oracle.com> wrote:
>>
>>
>>
>> On 08/24/2018 03:40 AM, Laurent Dufour wrote:
>>> On 22/08/2018 16:46, Davidlohr Bueso wrote:
>>>> On Wed, 22 Aug 2018, Shady Issa wrote:
>>>>
>>>>> Hi Davidlohr,
>>>>>
>>>>> I am interested in the idea of using range locks to replace mm_sem. I wanted to
>>>>> start trying out using more fine-grained ranges instead of the full range
>>>>> acquisitions
>>>>> that are used in this patch (https://urldefense.proofpoint.com/v2/url?u=https-3A__lkml.org_lkml_2018_2_4_235&d=DwICaQ&c=RoP1YumCXCgaWHvlZYR8PZh8Bv7qIrMUB65eapI_JnE&r=Q-zBmi7tP5HosTvB8kUZjTYqSFMRtxg-kOQa59-zx9I&m=ZCN6CnHZsYyZ_V0nWMSZgLmp-GobwtrhI3Wx8UAIQuY&s=LtbMxuR2njAX0dm3L2lNQKvztbnLTfKjBd-S20cDPbE&e=). However, it
>>>>> does not
>>>>> seem straight forward to me how this is possible.
>>>>>
>>>>> First, the ranges that can be defined before acquiring the range lock based
>>>>> on the
>>>>> caller's input(i.e. ranges supplied by mprotect, mmap, munmap, etc.) are
>>>>> oblivious of
>>>>> the underlying VMAs. Two non-overlapping ranges can fall within the same VMA and
>>>>> thus should not be allowed to run concurrently in case they are writes.
>>>> Yes. This is a _big_ issue with range locking the addr space. I have yet
>>>> to find a solution other than delaying vma modifying ops to avoid the races,
>>>> which is fragile. Obviously locking the full range in such scenarios cannot
>>>> be done either.
>>> I think the range locked should be aligned to the underlying VMA plus one page
>>> on each side to prevent that VMA to be merged.
> How would one find the underlying VMA for the range lock acquisition?
> Looks like that would require searching the rb-tree (currently protected by mm_sem), and that search has to be synchronized with concurrent tree modifications.

The rb-tree will need its own protection through a lock or a RCU like mechanism.

Laurent.



> Regards,
> a?? Alex
> 
>>> But this raises a concern with the VMA merging mechanism which tends to limit
>>> the number of VMAs and could lead to a unique VMA, limiting the advantage of a
>>> locking based on the VMA's boundaries.
>> To do so, the current merge implementation should be changed so that
>> it does not access VMAs beyond the locked range, right? Also, this will
>> not stop a merge from happening in case of a range spanning two VMAs
>> for example.
>>>
>>>>> Second, even if ranges from the caller function are aligned with VMAs, the
>>>>> extent of the
>>>>> effect of operation is unknown. It is probable that an operation touching one
>>>>> VMA will
>>>>> end up performing modifications to the VMAs rbtree structure due to splits,
>>>>> merges, etc.,
>>>>> which requires the full range acquisition and is unknown beforehand.
>>>> Yes, this is similar to the above as well.
>>>>
>>>>> I was wondering if I am missing something with this thought process, because
>>>>> with the
>>>>> current givings, it seems to me that range locks will boil down to just r/w
>>>>> semaphore.
>>>>> I would also be very grateful if you can point me to any more recent
>>>>> discussions regarding
>>>>> the use of range locks after this patch from February.
>>>> You're on the right page.
>>>>
>>>> Thanks,
>>>> Davidlohr
>>>>
>>
> 
