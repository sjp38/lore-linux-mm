Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f174.google.com (mail-yw0-f174.google.com [209.85.161.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5BBE26B025E
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 14:11:30 -0400 (EDT)
Received: by mail-yw0-f174.google.com with SMTP id i84so214103886ywc.2
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 11:11:30 -0700 (PDT)
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com. [209.85.192.52])
        by mx.google.com with ESMTPS id e134si5726774ybh.194.2016.04.11.11.11.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 11:11:29 -0700 (PDT)
Received: by mail-qg0-f52.google.com with SMTP id f52so151310529qga.3
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 11:11:29 -0700 (PDT)
Subject: Re: [PATCH 1/2] arm64: mem-model: add flatmem model for arm64
References: <1459844572-53069-1-git-send-email-puck.chen@hisilicon.com>
 <20160407142148.GI5657@arm.com> <570B10B2.2000000@hisilicon.com>
 <CAKv+Gu8iQ0NzLFWHy9Ggyv+jL-BqJ3x-KaRD1SZ1mU6yU3c7UQ@mail.gmail.com>
 <570B5875.20804@hisilicon.com>
 <CAKv+Gu9aqR=E3TmbPDFEUC+Q13bAJTU5wVTTHkOr6aX6BZ1OVA@mail.gmail.com>
 <570B758E.7070005@hisilicon.com>
 <CAKv+Gu-cWWUi6fCiveqaZRVhGCpEasCLEs7wq6t+C-x65g4cgQ@mail.gmail.com>
 <20160411104013.GG15729@arm.com> <570B8310.40103@hisilicon.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <570BE8CC.4050905@redhat.com>
Date: Mon, 11 Apr 2016 11:11:24 -0700
MIME-Version: 1.0
In-Reply-To: <570B8310.40103@hisilicon.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Feng <puck.chen@hisilicon.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Mark Rutland <mark.rutland@arm.com>, mhocko@suse.com, Dan Zhao <dan.zhao@hisilicon.com>, Yiping Xu <xuyiping@hisilicon.com>, puck.chen@foxmail.com, albert.lubing@hisilicon.com, Catalin Marinas <catalin.marinas@arm.com>, suzhuangluan@hisilicon.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linuxarm@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com, David Rientjes <rientjes@google.com>, oliver.fu@hisilicon.com, Andrew Morton <akpm@linux-foundation.org>, robin.murphy@arm.com, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, saberlily.xia@hisilicon.com

On 04/11/2016 03:57 AM, Chen Feng wrote:
> Hi Will,
>
> On 2016/4/11 18:40, Will Deacon wrote:
>> On Mon, Apr 11, 2016 at 12:31:53PM +0200, Ard Biesheuvel wrote:
>>> On 11 April 2016 at 11:59, Chen Feng <puck.chen@hisilicon.com> wrote:
>>>> Please see the pg-tables below.
>>>>
>>>>
>>>> With sparse and vmemmap enable.
>>>>
>>>> ---[ vmemmap start ]---
>>>> 0xffffffbdc0200000-0xffffffbdc4800000          70M     RW NX SHD AF    UXN MEM/NORMAL
>>>> ---[ vmemmap end ]---
>>>>
>>>
>>> OK, I see what you mean now. Sorry for taking so long to catch up.
>>>
>>>> The board is 4GB, and the memap is 70MB
>>>> 1G memory --- 14MB mem_map array.
>>>
>>> No, this is incorrect. 1 GB corresponds with 16 MB worth of struct
>>> pages assuming sizeof(struct page) == 64
>>>
>>> So you are losing 6 MB to rounding here, which I agree is significant.
>>> I wonder if it makes sense to use a lower value for SECTION_SIZE_BITS
>>> on 4k pages kernels, but perhaps we're better off asking the opinion
>>> of the other cc'ees.
>>
>> You need to be really careful making SECTION_SIZE_BITS smaller because
>> it has a direct correlation on the use of page->flags and you can end up
>> running out of bits fairly easily.
>
> Yes, making SECTION_SIZE_BITS smaller can solve the current situation.
>
> But if the phys-addr is 64GB, but only 4GB ddr is the valid address. And the
>
> holes are not always 512MB.
>
> But, can you tell us why *smaller SIZE makes running out of bits fairly easily*?
>

Think about page tables and TLB pressure. A larger page size can cover the
same memory area with fewer page table entries. The same type of logic applies
to memory sections here as well. If the section size is smaller, you need
more bits to represent the number of sections used. page->flags is a long

In include/linux/mm.h

/* Page flags: | [SECTION] | [NODE] | ZONE | [LAST_CPUPID] | ... | FLAGS | */

and

#if SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > BITS_PER_LONG - NR_PAGEFLAGS
#error SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > BITS_PER_LONG - NR_PAGEFLAGS
#endif

So it's a trade off of what can be encoded in an unsigned long.

We're hitting the upper bound on zones as well (see 033fbae988fc 'mm:
ZONE_DEVICE for "device memory"')


> And how about the flat-mem model?
>
>>
>> Will
>>
>> .
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
