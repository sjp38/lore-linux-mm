Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2F1898E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 01:10:38 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id s1-v6so1508321pfm.22
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 22:10:38 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id o6-v6si1021552plk.31.2018.09.26.22.10.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 22:10:36 -0700 (PDT)
Subject: Re: Question about a pte with PTE_PROT_NONE and !PTE_VALID on
 !PROT_NONE vma
From: Chulmin Kim <cmlaika.kim@samsung.com>
Message-id: <c20ccba3-a0c8-66e3-c048-2e80e23bce9e@samsung.com>
Date: Thu, 27 Sep 2018 14:10:46 +0900
MIME-version: 1.0
In-reply-to: <20180924210850.GV28957@redhat.com>
Content-type: text/plain; charset="utf-8"; format="flowed"
Content-transfer-encoding: 7bit
Content-language: en-US
References: <CGME20180921150147epcas5p33964436b2e609016311e4f12b715779d@epcas5p3.samsung.com>
	<CANYKp7ufttxsNkewBqgYDexMAoyVnMxgoy-EydCqmHadxyn+QQ@mail.gmail.com>
	<10146a73-4788-ba89-001f-f928bbb314f5@samsung.com>
	<20180924210850.GV28957@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chulmin Kim <cmkim.laika@gmail.com>

Hello.

Thanks for the reply.

We are doing the test (a kind of aging test for 3 days) to prove this is 
the fix for the problem.

I will let you know when the test is done.



On 09/25/2018 06:08 AM, Andrea Arcangeli wrote:
> Hello,
>
> On Sat, Sep 22, 2018 at 01:38:07PM +0900, Chulmin Kim wrote:
>> Dear Arcangeli,
>>
>>
>> I think this problem is very much related with
>>
>> the race condition shown in the below commit.
>>
>> (e86f15ee64d8, mm: vma_merge: fix vm_page_prot SMP race condition
>> against rmap_walk)
>>
>>
>> I checked that
>>
>> the the thread and its child threads are doing mprotect(PROT_{NONE or
>> R|W}) things repeatedly
>>
>> while I didn't reproduce the problem yet.
>>
>>
>> Do you think this is one of the phenomenon you expected
>>
>> from the race condition shown in the above commit?
> Yes that commit will fix your problem in a v4.4 based tree that misses
> that fix. You just need to cherry-pick that commit to fix the problem.
>
> Page migrate sets the pte to PROT_NONE by mistake because it runs
> concurrently with the mprotect that transitions an adjacent vma from
> PROT_NONE to PROT_READ|WRITE. vma_merge (before the fix) temporarily
> shown an erratic PROT_NONE vma prot for the virtual range under page
> migration.
>
> With NUMA disabled, it's likely compaction that triggered page migrate
> for you. Disabling compaction at build time would have likely hidden
> the problem. Compaction uses migration and you most certainly have
> CONFIG_COMPACTION=y (rightfully so).
>
> On a side note, I suggest to cherry pick the last upstream commit of
> mm/vmacache.c too.
Sorry but I didn't get this line correctly.

Do you meanthe commit 7a9cdebdc (mm: get rid of vmacache_flush_all() 
entirely)?
Could you elaborate what is the point?
Are you saying there is another scenario that makes the problem I am seeing?

> Hope this helps,
> Andrea
>
>
>

Thanks.
Chulmin Kim
