Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id EBCE76B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 00:14:34 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f188so1912273091pgc.1
        for <linux-mm@kvack.org>; Sun, 08 Jan 2017 21:14:34 -0800 (PST)
Received: from mail-pg0-x22b.google.com (mail-pg0-x22b.google.com. [2607:f8b0:400e:c05::22b])
        by mx.google.com with ESMTPS id z31si87650953plb.1.2017.01.08.21.14.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Jan 2017 21:14:34 -0800 (PST)
Received: by mail-pg0-x22b.google.com with SMTP id 14so26679057pgg.1
        for <linux-mm@kvack.org>; Sun, 08 Jan 2017 21:14:34 -0800 (PST)
Subject: Re: [PATCH v3] arm64: mm: Fix NOMAP page initialization
References: <20161216165437.21612-1-rrichter@cavium.com>
 <CAKv+Gu_SmTNguC=tSCwYOL2kx-DogLvSYRZc56eGP=JhdrUOsA@mail.gmail.com>
 <c74d6ec6-16ba-dccc-3b0d-a8bedcb46dc5@linaro.org>
 <cbbf14fd-a1cc-2463-ba67-acd6d61e9db1@linaro.org>
 <CAKv+Gu8-+0LUTN0+8OGWRhd22Ls5cMQqTJcjKQK_0N=Uc-0jog@mail.gmail.com>
From: Hanjun Guo <hanjun.guo@linaro.org>
Message-ID: <941987a6-e5f9-c131-010d-1d007b6c4b13@linaro.org>
Date: Mon, 9 Jan 2017 13:14:27 +0800
MIME-Version: 1.0
In-Reply-To: <CAKv+Gu8-+0LUTN0+8OGWRhd22Ls5cMQqTJcjKQK_0N=Uc-0jog@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Robert Richter <rrichter@cavium.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, David Daney <david.daney@cavium.com>, Mark Rutland <mark.rutland@arm.com>, James Morse <james.morse@arm.com>, Yisheng Xie <xieyisheng1@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 2017/1/6 16:37, Ard Biesheuvel wrote:
> On 6 January 2017 at 01:07, Hanjun Guo <hanjun.guo@linaro.org> wrote:
>> On 2017/1/5 10:03, Hanjun Guo wrote:
>>>
>>> On 2017/1/4 21:56, Ard Biesheuvel wrote:
>>>>
>>>> On 16 December 2016 at 16:54, Robert Richter <rrichter@cavium.com> wrote:
>>>>>
>>>>> On ThunderX systems with certain memory configurations we see the
>>>>> following BUG_ON():
>>>>>
>>>>>  kernel BUG at mm/page_alloc.c:1848!
>>>>>
>>>>> This happens for some configs with 64k page size enabled. The BUG_ON()
>>>>> checks if start and end page of a memmap range belongs to the same
>>>>> zone.
>>>>>
>>>>> The BUG_ON() check fails if a memory zone contains NOMAP regions. In
>>>>> this case the node information of those pages is not initialized. This
>>>>> causes an inconsistency of the page links with wrong zone and node
>>>>> information for that pages. NOMAP pages from node 1 still point to the
>>>>> mem zone from node 0 and have the wrong nid assigned.
>>>>>
>>>>> The reason for the mis-configuration is a change in pfn_valid() which
>>>>> reports pages marked NOMAP as invalid:
>>>>>
>>>>>  68709f45385a arm64: only consider memblocks with NOMAP cleared for
>>>>> linear mapping
>>>>>
>>>>> This causes pages marked as nomap being no longer reassigned to the
>>>>> new zone in memmap_init_zone() by calling __init_single_pfn().
>>>>>
>>>>> Fixing this by implementing an arm64 specific early_pfn_valid(). This
>>>>> causes all pages of sections with memory including NOMAP ranges to be
>>>>> initialized by __init_single_page() and ensures consistency of page
>>>>> links to zone, node and section.
>>>>>
>>>>
>>>> I like this solution a lot better than the first one, but I am still
>>>> somewhat uneasy about having the kernel reason about attributes of
>>>> pages it should not touch in the first place. But the fact that
>>>> early_pfn_valid() is only used a single time in the whole kernel does
>>>> give some confidence that we are not simply moving the problem
>>>> elsewhere.
>>>>
>>>> Given that you are touching arch/arm/ as well as arch/arm64, could you
>>>> explain why only arm64 needs this treatment? Is it simply because we
>>>> don't have NUMA support there?
>>>>
>>>> Considering that Hisilicon D05 suffered from the same issue, I would
>>>> like to get some coverage there as well. Hanjun, is this something you
>>>> can arrange? Thanks
>>>
>>>
>>> Sure, we will test this patch with LTP MM stress test (which triggers
>>> the bug on D05), and give the feedback.
>>
>>
>> a update here, tested on 4.9,
>>
>>  - Applied Ard's two patches only
>>  - Applied Robert's patch only
>>
>> Both of them can work fine on D05 with NUMA enabled, which means
>> boot ok and LTP MM stress test is passed.
>>
>
> Thanks a lot Hanjun.
>
> Any comments on the performance impact (including boot time) ?

Didn't collect the performance data yet, any recommended test
suite?  Is it sysbench ok? we can test it and collect the data.

Thanks
Hanjun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
