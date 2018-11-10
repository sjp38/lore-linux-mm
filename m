Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id A41D36B0750
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 19:56:08 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id q124-v6so3653724ybg.18
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 16:56:08 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id u12-v6si6121566ybd.437.2018.11.09.16.56.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 16:56:07 -0800 (PST)
Subject: Re: [RFC PATCH] mm: thp: implement THP reservations for anonymous
 memory
References: <1541746138-6706-1-git-send-email-anthony.yznaga@oracle.com>
 <20181109121318.3f3ou56ceegrqhcp@kshutemo-mobl1>
 <20181109195150.GA24747@redhat.com>
From: anthony.yznaga@oracle.com
Message-ID: <4425914b-3082-e3fa-4562-de532fd8a3b2@oracle.com>
Date: Fri, 9 Nov 2018 16:55:40 -0800
MIME-Version: 1.0
In-Reply-To: <20181109195150.GA24747@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aneesh.kumar@linux.ibm.com, akpm@linux-foundation.org, jglisse@redhat.com, khandual@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, mgorman@techsingularity.net, mhocko@kernel.org, minchan@kernel.org, peterz@infradead.org, rientjes@google.com, vbabka@suse.cz, willy@infradead.org, ying.huang@intel.com, nitingupta910@gmail.com



On 11/09/2018 11:51 AM, Andrea Arcangeli wrote:
> Hello,
>
> On Fri, Nov 09, 2018 at 03:13:18PM +0300, Kirill A. Shutemov wrote:
>> On Thu, Nov 08, 2018 at 10:48:58PM -0800, Anthony Yznaga wrote:
>>> The basic idea as outlined by Mel Gorman in [2] is:
>>>
>>> 1) On first fault in a sufficiently sized range, allocate a huge page
>>>    sized and aligned block of base pages.  Map the base page
>>>    corresponding to the fault address and hold the rest of the pages in
>>>    reserve.
>>> 2) On subsequent faults in the range, map the pages from the reservation.
>>> 3) When enough pages have been mapped, promote the mapped pages and
>>>    remaining pages in the reservation to a huge page.
>>> 4) When there is memory pressure, release the unused pages from their
>>>    reservations.
>> I haven't yet read the patch in details, but I'm skeptical about the
>> approach in general for few reasons:
>>
>> - PTE page table retracting to replace it with huge PMD entry requires
>>   down_write(mmap_sem). It makes the approach not practical for many
>>   multi-threaded workloads.
>>
>>   I don't see a way to avoid exclusive lock here. I will be glad to
>>   be proved otherwise.
>>
>> - The promotion will also require TLB flush which might be prohibitively
>>   slow on big machines.
>>
>> - Short living processes will fail to benefit from THP with the policy,
>>   even with plenty of free memory in the system: no time to promote to THP
>>   or, with synchronous promotion, cost will overweight the benefit.
>>
>> The goal to reduce memory overhead of THP is admirable, but we need to be
>> careful not to kill THP benefit itself. The approach will reduce number of
>> THP mapped in the system and/or shift their allocation to later stage of
>> process lifetime.
>>
>> The only way I see it can be useful is if it will be possible to apply the
>> policy on per-VMA basis. It will be very useful for malloc()
>> implementations, for instance. But as a global policy it's no-go to me.
> I'm also skeptical about this: the current design is quite
> intentional. It's not a bug but a feature that we're not doing the
> promotion.
>
> Part of the tradeoff with THP is to use more RAM to save CPU, when you
> use less RAM you're inherently already wasting some CPU just for the
> reservation management and you don't get the immediate TLB benefit
> anymore either.
>
> And if you're in the camp that is concerned about the use of more RAM
> or/and about the higher latency of COW faults, I'm afraid the
> intermediate solution will be still slower than the already available
> MADV_NOHUGEPAGE or enabled=madvise.
>
> Apps like redis that will use more RAM during snapshot and that are
> slowed down with THP needs to simply use MADV_NOHUGEPAGE which already
> exists as an madvise from the very first kernel that supported
> THP-anon. Same thing for other apps that use more RAM with THP and
> that are on the losing end of the tradeoff.
>
> Now about the implementation: the whole point of the reservation
> complexity is to skip the khugepaged copy, so it can collapse in
> place. Is skipping the copy worth it? Isn't the big cost the IPI
> anyway to avoid leaving two simultaneous TLB mappings of different
> granularity?
Good questions.A  I'll take them into account when measuring performance.
I do wonder about other architectures (e.g. ARM) where the PMD
size may be significantly larger than 2MB.

>
> khugepaged is already tunable to specify a ratio of memory in use to
> avoid wasting memory
> /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none.
>
> If you set max_ptes_none to half the default value, it'll only promote
> pages that are half mapped, reducing the memory waste to 50% of what
> it is by default.
>
> So if you are ok to copy the memory that you promote to THP, you'd
> just need a global THP mode to avoid allocating THP even when they're
> available during the page fault (while still allowing khugepaged to
> collapse hugepages in the background), and then reduce max_ptes_none
> to get the desired promotion ratio.
>
> Doing the copy will avoid the reservation there will be also more THP
> available to use for those khugepaged users without losing them in
> reservations. You won't have to worry about what to do when there's
> memory pressure because you won't have to undo the reservation because
> there was no reservation in the first place. That problem also goes
> away with the copy.
>
> So it sounds like you could achieve a similar runtime behavior with
> much less complexity by reducing max_ptes_none and by doing the copy
> and dropping all reservation code.

These are compelling arguments.A  I will be sure to evaluate any
performance data against this alternate implementation/tuning.

Thank you for the comments.

Anthony

>
>> Prove me wrong with performance data. :)
> Same here.
>
> Thanks,
> Andrea
