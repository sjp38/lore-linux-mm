Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 950146B520C
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 12:25:05 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id y135-v6so7833013oie.11
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 09:25:05 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h126-v6si5285418oia.375.2018.08.30.09.25.04
        for <linux-mm@kvack.org>;
        Thu, 30 Aug 2018 09:25:04 -0700 (PDT)
Subject: Re: A crash on ARM64 in move_freepages_block due to uninitialized
 pages in reserved memory
References: <alpine.LRH.2.02.1808171527220.2385@file01.intranet.prod.int.rdu2.redhat.com>
 <20180821104418.GA16611@dhcp22.suse.cz>
 <e35b7c14-c7ea-412d-2763-c961b74576f3@arm.com>
 <alpine.LRH.2.02.1808220808050.17906@file01.intranet.prod.int.rdu2.redhat.com>
 <c823eace-8710-9bf5-6e76-d01b139c0859@arm.com>
 <20180824114158.GJ29735@dhcp22.suse.cz>
 <541193a6-2bce-f042-5bb2-88913d5f1047@arm.com>
 <alpine.LRH.2.02.1808301148260.18300@file01.intranet.prod.int.rdu2.redhat.com>
From: James Morse <james.morse@arm.com>
Message-ID: <27f10f29-8e38-1f42-8431-9db66aed2d1e@arm.com>
Date: Thu, 30 Aug 2018 17:25:00 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.02.1808301148260.18300@file01.intranet.prod.int.rdu2.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Pavel Tatashin <Pavel.Tatashin@microsoft.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>

Hi Mikulas,

On 30/08/18 16:58, Mikulas Patocka wrote:
> On Wed, 29 Aug 2018, James Morse wrote:
>> On 24/08/18 12:41, Michal Hocko wrote:
>>> On Thu 23-08-18 15:06:08, James Morse wrote:
>>> [...]
>>>> My best-guess is that pfn_valid_within() shouldn't be optimised out if
>>> ARCH_HAS_HOLES_MEMORYMODEL, even if HOLES_IN_ZONE isn't set.
>>>>
>>>> Does something like this solve the problem?:
>>>> ============================%<============================
>>>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>>>> index 32699b2dc52a..5e27095a15f4 100644
>>>> --- a/include/linux/mmzone.h
>>>> +++ b/include/linux/mmzone.h
>>>> @@ -1295,7 +1295,7 @@ void memory_present(int nid, unsigned long start, unsigned
>>>> long end);
>>>>   * pfn_valid_within() should be used in this case; we optimise this away
>>>>   * when we have no holes within a MAX_ORDER_NR_PAGES block.
>>>>   */
>>>> -#ifdef CONFIG_HOLES_IN_ZONE
>>>> +#if defined(CONFIG_HOLES_IN_ZONE) || defined(CONFIG_ARCH_HAS_HOLES_MEMORYMODEL)
>>>>  #define pfn_valid_within(pfn) pfn_valid(pfn)
>>>>  #else
>>>>  #define pfn_valid_within(pfn) (1)
>>>> ============================%<============================
>>
>> After plenty of greping, git-archaeology and help from others, I think I've a
>> clearer picture of what these options do.
>>
>>
>> Please correct me if I've explained something wrong here:
>>
>>> This is the first time I hear about CONFIG_ARCH_HAS_HOLES_MEMORYMODEL.
>>
>> The comment in include/linux/mmzone.h describes this as relevant when parts the
>> memmap have been free()d. This would happen on systems where memory is smaller
>> than a sparsemem-section, and the extra struct pages are expensive.
>> pfn_valid() on these systems returns true for the whole sparsemem-section, so an
>> extra memmap_valid_within() check is needed.
>>
>> This is independent of nomap, and isn't relevant on arm64 as our pfn_valid()
>> always tests the page in memblock due to nomap pages, which can occur anywhere.
>> (I will propose a patch removing ARCH_HAS_HOLES_MEMORYMODEL for arm64.)
>>
>>
>> HOLES_IN_ZONE is similar, if some memory is smaller than MAX_ORDER_NR_PAGES,
>> possibly due to nomap holes.
>>
>> 6d526ee26ccd only enabled it for NUMA systems on arm64, because the NUMA code
>> was first to fall foul of this, but there is nothing NUMA specific about nomap
>> holes within a MAX_ORDER_NR_PAGES region.
>>
>> I'm convinced arm64 should always enable HOLES_IN_ZONE because nomap pages can
>> occur anywhere. I'll post a fix.
> 
> But x86 had the same bug -
> https://bugzilla.redhat.com/show_bug.cgi?id=1598462

(Context: e181ae0c5db "mm: zero unavailable pages before memmap init")

Its the same symptom, but not quite the same bug.


> And x86 fixed it without enabling HOLES_IN_ZONE. On x86, the BIOS can also 
> reserve any memory range - so you can have arbitrary holes there that are 
> not predictable when the kernel is compiled.

x86's pfn_valid() says the struct-page is accessible, the problem was it wasn't
initialized correctly.

On arm64 pfn_valid() says these struct-pages are not accessible. The problem was
the pfn_valid_within()->pfn_valid() calls being removed, causing the
uninitialized struct-page to be accessed.


> Currently HOLES_IN_ZONE is selected only for ia64, mips/octeon - so does 
> it mean that all the other architectures don't have holes in the memory 
> map?

I think there is just more than way of handling these, depending on whether
holes have struct-pages and what pfn_valid() reports for them.


> What should be architecture-independent way how to handle the holes?

We already diverge with e820/memblock. I'm not sure what the x86 holes
correspond to, but on arm64 these are holes in the linear-map because the
corresponding memory needs mapping with particular attributes, and we can't
mix-and-match.


Thanks,

James
