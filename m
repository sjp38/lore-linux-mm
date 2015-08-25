Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id D34566B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 05:56:39 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so9760470wic.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 02:56:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ga1si2256860wib.101.2015.08.25.02.56.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Aug 2015 02:56:38 -0700 (PDT)
Subject: Re: Can we disable transparent hugepages for lack of a legitimate use
 case please?
References: <BLUPR02MB1698DD8F0D1550366489DF8CCD620@BLUPR02MB1698.namprd02.prod.outlook.com>
 <CALYGNiOg_Zq8Fz-VWskH7LVGdExuq=03+56dpCsDiZ6eAq2A4Q@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DC3BD4.6020602@suse.cz>
Date: Tue, 25 Aug 2015 11:56:36 +0200
MIME-Version: 1.0
In-Reply-To: <CALYGNiOg_Zq8Fz-VWskH7LVGdExuq=03+56dpCsDiZ6eAq2A4Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, James Hartshorn <jhartshorn@connexity.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>

On 08/25/2015 11:25 AM, Konstantin Khlebnikov wrote:
> On Mon, Aug 24, 2015 at 11:12 PM, James Hartshorn
> <jhartshorn@connexity.com> wrote:
>> Hi,
>>
>>
>> I've been struggling with transparent hugepage performance issues, and can't
>> seem to find anyone who actually uses it intentionally.  Virtually every
>> database that runs on linux however recommends disabling it or setting it to
>> madvise.  I'm referring to:
>>
>>
>> /sys/kernel/mm/transparent_hugepage/enabled
>>
>>
>> I asked on the internet
>> http://unix.stackexchange.com/questions/201906/does-anyone-actually-use-and-benefit-from-transparent-huge-pages
>> and got no responses there.
>>
>>
>>
>> Independently I noticed
>>
>>
>> "sysctl: The scan_unevictable_pages sysctl/node-interface has been disabled
>> for lack of a legitimate use case.  If you have one, please send an email to
>> linux-mm@kvack.org."
>>
>>
>> And thought wow that's exactly what should be done to transparent hugepages.
>>
>>
>> Thoughts?

[+ Cc's]

> THP works very well when system has a lot of free memory.
> Probably default should be weakened to "only if we have tons of free memory".
> For example allocate THP pages atomically, only if buddy allocator already
> has huge pages. Also them could be pre-zeroed in background.

I've been proposing series that try to move more THP allocation activity 
from the page faults into khugepaged, but no success yet.

Maybe we should just start with changing the default of
/sys/kernel/mm/transparent_hugepage/defrag to "madvise". This would 
remove the reclaim and compaction for page faults and quickly fallback 
to order-0 pages. The compaction is already crippled enough there with 
the GFP_TRANSHUGE specific decisions in __alloc_pages_slowpath(). I've 
noticed it failing miserably in the transhuge-stress recently, so it 
seems it's not worth to try at all. With changing the default we can 
kill those GFP_TRANSHUGE checks and assume that whoever uses the madvise 
does actually want to try harder.

Of course that does nothing about zeroing. I don't know how huge issue 
is that one?

>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
