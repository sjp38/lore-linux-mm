Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 92BFF6B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 04:55:27 -0400 (EDT)
Received: by laeb10 with SMTP id b10so2429038lae.1
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 01:55:26 -0700 (PDT)
Received: from mail-lb0-x22a.google.com (mail-lb0-x22a.google.com. [2a00:1450:4010:c04::22a])
        by mx.google.com with ESMTPS id w4si848647lad.89.2015.09.02.01.55.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 01:55:25 -0700 (PDT)
Received: by lbcjc2 with SMTP id jc2so2074275lbc.0
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 01:55:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1509011522470.11913@chino.kir.corp.google.com>
References: <BLUPR02MB1698DD8F0D1550366489DF8CCD620@BLUPR02MB1698.namprd02.prod.outlook.com>
	<CALYGNiOg_Zq8Fz-VWskH7LVGdExuq=03+56dpCsDiZ6eAq2A4Q@mail.gmail.com>
	<55DC3BD4.6020602@suse.cz>
	<alpine.DEB.2.10.1509011522470.11913@chino.kir.corp.google.com>
Date: Wed, 2 Sep 2015 11:55:24 +0300
Message-ID: <CALYGNiNQBbV8BOVyBUFYHO8i2Hx15T_Zbb+efKMLH5KR93ZQMw@mail.gmail.com>
Subject: Re: Can we disable transparent hugepages for lack of a legitimate use
 case please?
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, James Hartshorn <jhartshorn@connexity.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

On Wed, Sep 2, 2015 at 1:26 AM, David Rientjes <rientjes@google.com> wrote:
> On Tue, 25 Aug 2015, Vlastimil Babka wrote:
>
>> > THP works very well when system has a lot of free memory.
>> > Probably default should be weakened to "only if we have tons of free
>> > memory".
>> > For example allocate THP pages atomically, only if buddy allocator already
>> > has huge pages. Also them could be pre-zeroed in background.
>>
>> I've been proposing series that try to move more THP allocation activity from
>> the page faults into khugepaged, but no success yet.
>>
>> Maybe we should just start with changing the default of
>> /sys/kernel/mm/transparent_hugepage/defrag to "madvise".
>
> I would need to revert this internally to avoid performance degradation, I
> believe others would report the same.

What about adding new mode "guess" -- something between always and madvise?

In this mode kernel tries to avoid performance impact for non-madvised vmas and
allocates 0-order pages if hugepages are not available right now.
(for example do allocations with GFP_NOWAIT)
I think we'll get all benefits without losing performance.

>
>> This would remove the
>> reclaim and compaction for page faults and quickly fallback to order-0 pages.
>> The compaction is already crippled enough there with the GFP_TRANSHUGE
>> specific decisions in __alloc_pages_slowpath(). I've noticed it failing
>> miserably in the transhuge-stress recently, so it seems it's not worth to try
>> at all. With changing the default we can kill those GFP_TRANSHUGE checks and
>> assume that whoever uses the madvise does actually want to try harder.
>>
>
> I think the work that is being done on moving compaction to khugepaged as
> well as periodic synchronous compaction of all memory is the way to go to
> avoid lengthy stalls during fault.
>
>> Of course that does nothing about zeroing. I don't know how huge issue is that
>> one?
>>
>
> I don't believe it is an issue that cannot be worked around in userspace
> either with MADV_NOHUGEPAGE or PR_SET_THP_DISABLE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
