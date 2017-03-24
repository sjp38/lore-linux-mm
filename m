Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id E5E986B0343
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 04:57:10 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id p66so11021713vkd.5
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 01:57:10 -0700 (PDT)
Received: from mail-vk0-x22f.google.com (mail-vk0-x22f.google.com. [2607:f8b0:400c:c05::22f])
        by mx.google.com with ESMTPS id b63si626074uab.101.2017.03.24.01.57.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 01:57:10 -0700 (PDT)
Received: by mail-vk0-x22f.google.com with SMTP id z204so8355843vkd.1
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 01:57:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <888af92c-1d20-d9f4-a425-c720d1179756@oracle.com>
References: <CACT4Y+Z-trVe0Oqzs8c+mTG6_iL7hPBBFgOm0p0iQsCz9Q2qiw@mail.gmail.com>
 <a10eb28c-305d-3547-8df1-7a2216473e09@oracle.com> <888af92c-1d20-d9f4-a425-c720d1179756@oracle.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 24 Mar 2017 09:56:49 +0100
Message-ID: <CACT4Y+YKEDKGwNFeBJ84K_xNWogPZnUUMBrcgLXYSjBUaoM=-Q@mail.gmail.com>
Subject: Re: mm: BUG in resv_map_release
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: nyc@holomorphy.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>

On Thu, Mar 23, 2017 at 7:02 PM, Mike Kravetz <mike.kravetz@oracle.com> wrote:
> On 03/23/2017 10:25 AM, Mike Kravetz wrote:
>> On 03/23/2017 03:19 AM, Dmitry Vyukov wrote:
>>> Hello,
>>>
>>> I've got the following BUG while running syzkaller fuzzer.
>>> Note the injected kmalloc failure, most likely it's the root cause.
>>
>> Thanks  Dmitry,
>>
>> The BUG indicates someone called region_chg() in the process of adding
>> a hugetlbfs page reservation, but did not complete this 'two step'
>> process with a call to region_add() or region_abort().  Most likely a
>> missed call in an error path somewhere.  :(
>>
>> I'll try to track this down.  The hint of 'injected kmalloc failure'
>> should help.
>
> Actually, in this case I believe the bug is in hugetlb_reserve_pages.
> It calls region_chg(), but gets an error due to the injected kmalloc
> failure.  At this point, the resv_map->adds_in_progress is 0 as it
> should be.  However, the error path for hugetlb_reserve_pages calls
> region_abort() which will unconditionally decrement adds_in_progress.
> So, adds_in_progress goes negative and we eventually BUG.  :(
>
> I'll look for other misuses of region_chg()/region_add()/region_abort()
> and put together a patch.
>
> Dmitry, is there some way to run the fuzzer with kmalloc failure injection
> and target the hugetlbfs code?  I'm suspect we could flush out other bugs.
> I noticed one other you discovered, and will look at that next.

syzkaller systematically targets all of the kernel code. So far I've
seen only these 2 involving hugetlbfs code. I don't think we need to
do anything special for hugetlbfs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
