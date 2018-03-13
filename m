Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 936A06B0006
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 18:47:20 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id x21so715353oie.5
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 15:47:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q57sor524965otq.33.2018.03.13.15.47.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Mar 2018 15:47:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+G9fYth0DVemSK3Sp8aRc9mzDAq0==WW08Gq1L5JjxWg-a+Gw@mail.gmail.com>
References: <1519908465-12328-1-git-send-email-neelx@redhat.com>
 <cover.1520011944.git.neelx@redhat.com> <0485727b2e82da7efbce5f6ba42524b429d0391a.1520011945.git.neelx@redhat.com>
 <20180302164052.5eea1b896e3a7125d1e1f23a@linux-foundation.org>
 <CACjP9X_tpVVDPUvyc-B2QU=2J5MXbuFsDcG90d7L0KuwEEuR-g@mail.gmail.com>
 <CAPKp9ubzXBMeV6Oi=KW1HaPOrv_P78HOXcdQeZ5e1=bqY97tkA@mail.gmail.com>
 <CA+G9fYvWm5NYX64POULrdGB1c3Ar3WfZAsBTEKw4+NYQ_mmddA@mail.gmail.com>
 <CACjP9X96_Wtj3WOXgkjfijN-ZXB9pS=K547-JerRq4QKkrYkfQ@mail.gmail.com> <CA+G9fYth0DVemSK3Sp8aRc9mzDAq0==WW08Gq1L5JjxWg-a+Gw@mail.gmail.com>
From: Daniel Vacek <neelx@redhat.com>
Date: Tue, 13 Mar 2018 23:47:18 +0100
Message-ID: <CACjP9X_DjH4hVrUOOLok+ht5NO52TuV0mS4yZs5RCGjF0hi6LQ@mail.gmail.com>
Subject: Re: [PATCH v3 2/2] mm/page_alloc: fix memmap_init_zone pageblock alignment
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naresh Kamboju <naresh.kamboju@linaro.org>
Cc: Sudeep Holla <sudeep.holla@arm.com>, Andrew Morton <akpm@linux-foundation.org>, open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, Paul Burton <paul.burton@imgtec.com>, linux- stable <stable@vger.kernel.org>

On Tue, Mar 13, 2018 at 7:34 AM, Naresh Kamboju
<naresh.kamboju@linaro.org> wrote:
> On 12 March 2018 at 22:21, Daniel Vacek <neelx@redhat.com> wrote:
>> On Mon, Mar 12, 2018 at 3:49 PM, Naresh Kamboju
>> <naresh.kamboju@linaro.org> wrote:
>>> On 12 March 2018 at 17:56, Sudeep Holla <sudeep.holla@arm.com> wrote:
>>>> Hi,
>>>>
>>>> I couldn't find the exact mail corresponding to the patch merged in v4.16-rc5
>>>> but commit 864b75f9d6b01 "mm/page_alloc: fix memmap_init_zone
>>>> pageblock alignment"
>>>> cause boot hang on my ARM64 platform.
>>>
>>> I have also noticed this problem on hi6220 Hikey - arm64.
>>>
>>> LKFT: linux-next: Hikey boot failed linux-next-20180308
>>> https://bugs.linaro.org/show_bug.cgi?id=3676
>>>
>>> - Naresh
>>>
>>>>
>>>> Log:
>>>> [    0.000000] NUMA: No NUMA configuration found
>>>> [    0.000000] NUMA: Faking a node at [mem
>>>> 0x0000000000000000-0x00000009ffffffff]
>>>> [    0.000000] NUMA: NODE_DATA [mem 0x9fffcb480-0x9fffccf7f]
>>>> [    0.000000] Zone ranges:
>>>> [    0.000000]   DMA32    [mem 0x0000000080000000-0x00000000ffffffff]
>>>> [    0.000000]   Normal   [mem 0x0000000100000000-0x00000009ffffffff]
>>>> [    0.000000] Movable zone start for each node
>>>> [    0.000000] Early memory node ranges
>>>> [    0.000000]   node   0: [mem 0x0000000080000000-0x00000000f8f9afff]
>>>> [    0.000000]   node   0: [mem 0x00000000f8f9b000-0x00000000f908ffff]
>>>> [    0.000000]   node   0: [mem 0x00000000f9090000-0x00000000f914ffff]
>>>> [    0.000000]   node   0: [mem 0x00000000f9150000-0x00000000f920ffff]
>>>> [    0.000000]   node   0: [mem 0x00000000f9210000-0x00000000f922ffff]
>>>> [    0.000000]   node   0: [mem 0x00000000f9230000-0x00000000f95bffff]
>>>> [    0.000000]   node   0: [mem 0x00000000f95c0000-0x00000000fe58ffff]
>>>> [    0.000000]   node   0: [mem 0x00000000fe590000-0x00000000fe5cffff]
>>>> [    0.000000]   node   0: [mem 0x00000000fe5d0000-0x00000000fe5dffff]
>>>> [    0.000000]   node   0: [mem 0x00000000fe5e0000-0x00000000fe62ffff]
>>>> [    0.000000]   node   0: [mem 0x00000000fe630000-0x00000000feffffff]
>>>> [    0.000000]   node   0: [mem 0x0000000880000000-0x00000009ffffffff]
>>>> [    0.000000]  Initmem setup node 0 [mem 0x0000000080000000-0x00000009ffffffff]
>>>>
>>>> On Sat, Mar 3, 2018 at 1:08 AM, Daniel Vacek <neelx@redhat.com> wrote:
>>>>> On Sat, Mar 3, 2018 at 1:40 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
>>>>>>
>>>>>> This makes me wonder whether a -stable backport is really needed...
>>>>>
>>>>> For some machines it definitely is. Won't hurt either, IMHO.
>>>>>
>>>>> --nX
>>
>> Hmm, does it step back perhaps?
>>
>> Can you check if below cures the boot hang?
>>
>> --nX
>>
>> ~~~~
>> neelx@metal:~/nX/src/linux$ git diff
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 3d974cb2a1a1..415571120bbd 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5365,8 +5365,10 @@ void __meminit memmap_init_zone(unsigned long
>> size, int nid, unsigned long zone,
>>                          * the valid region but still depends on correct page
>>                          * metadata.
>>                          */
>> -                       pfn = (memblock_next_valid_pfn(pfn, end_pfn) &
>> +                       unsigned long next_pfn;
>> +                       next_pfn = (memblock_next_valid_pfn(pfn, end_pfn) &
>>                                         ~(pageblock_nr_pages-1)) - 1;
>> +                       pfn = max(next_pfn, pfn);
>>  #endif
>>                         continue;
>>                 }
>
> After applying this patch on linux-next the boot hang problem resolved.
> Now the hi6220-hikey is booting successfully.
> Thank you.

Thank you and Sudeep for testing. I've just sent Andrew a formal patch.

>
> - Naresh
>
>> ~~~~
