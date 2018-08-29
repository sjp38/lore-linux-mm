Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 496186B4CE6
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 13:38:01 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id r131-v6so4987980oie.14
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 10:38:01 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b188-v6si2999924oif.246.2018.08.29.10.37.59
        for <linux-mm@kvack.org>;
        Wed, 29 Aug 2018 10:37:59 -0700 (PDT)
Subject: Re: A crash on ARM64 in move_freepages_block due to uninitialized
 pages in reserved memory
References: <alpine.LRH.2.02.1808171527220.2385@file01.intranet.prod.int.rdu2.redhat.com>
 <20180821104418.GA16611@dhcp22.suse.cz>
 <e35b7c14-c7ea-412d-2763-c961b74576f3@arm.com>
 <alpine.LRH.2.02.1808220808050.17906@file01.intranet.prod.int.rdu2.redhat.com>
 <c823eace-8710-9bf5-6e76-d01b139c0859@arm.com>
 <20180824114158.GJ29735@dhcp22.suse.cz>
From: James Morse <james.morse@arm.com>
Message-ID: <541193a6-2bce-f042-5bb2-88913d5f1047@arm.com>
Date: Wed, 29 Aug 2018 18:37:55 +0100
MIME-Version: 1.0
In-Reply-To: <20180824114158.GJ29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Pavel Tatashin <Pavel.Tatashin@microsoft.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>

Hi Michal,

(CC: +Ard)

On 24/08/18 12:41, Michal Hocko wrote:
> On Thu 23-08-18 15:06:08, James Morse wrote:
> [...]
>> My best-guess is that pfn_valid_within() shouldn't be optimised out if
> ARCH_HAS_HOLES_MEMORYMODEL, even if HOLES_IN_ZONE isn't set.
>>
>> Does something like this solve the problem?:
>> ============================%<============================
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index 32699b2dc52a..5e27095a15f4 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -1295,7 +1295,7 @@ void memory_present(int nid, unsigned long start, unsigned
>> long end);
>>   * pfn_valid_within() should be used in this case; we optimise this away
>>   * when we have no holes within a MAX_ORDER_NR_PAGES block.
>>   */
>> -#ifdef CONFIG_HOLES_IN_ZONE
>> +#if defined(CONFIG_HOLES_IN_ZONE) || defined(CONFIG_ARCH_HAS_HOLES_MEMORYMODEL)
>>  #define pfn_valid_within(pfn) pfn_valid(pfn)
>>  #else
>>  #define pfn_valid_within(pfn) (1)
>> ============================%<============================

After plenty of greping, git-archaeology and help from others, I think I've a
clearer picture of what these options do.


Please correct me if I've explained something wrong here:

> This is the first time I hear about CONFIG_ARCH_HAS_HOLES_MEMORYMODEL.

The comment in include/linux/mmzone.h describes this as relevant when parts the
memmap have been free()d. This would happen on systems where memory is smaller
than a sparsemem-section, and the extra struct pages are expensive.
pfn_valid() on these systems returns true for the whole sparsemem-section, so an
extra memmap_valid_within() check is needed.

This is independent of nomap, and isn't relevant on arm64 as our pfn_valid()
always tests the page in memblock due to nomap pages, which can occur anywhere.
(I will propose a patch removing ARCH_HAS_HOLES_MEMORYMODEL for arm64.)


HOLES_IN_ZONE is similar, if some memory is smaller than MAX_ORDER_NR_PAGES,
possibly due to nomap holes.

6d526ee26ccd only enabled it for NUMA systems on arm64, because the NUMA code
was first to fall foul of this, but there is nothing NUMA specific about nomap
holes within a MAX_ORDER_NR_PAGES region.

I'm convinced arm64 should always enable HOLES_IN_ZONE because nomap pages can
occur anywhere. I'll post a fix.


Is it valid to have HOLES_IN_ZONE and !HAVE_ARCH_PFN_VALID?
This would mean pfn_valid_within() is necessary, but pfn_valid() is only looking
at sparse-sections. It looks like ia64 and mips:CAVIUM_OCTEON_SOC are both
configured like this...


> Why it doesn't imply CONFIG_HOLES_IN_ZONE?

I guess the size values for sparsemem-section and MAX_ORDER_NR_PAGES may support
HAS_HOLES_MEMORYMODEL but not HOLES_IN_ZONE. e.g. if only 128Mb of memory
existed in a 256Mb sparsemem-section, but the 4Mb MAX_ORDER_NR_PAGES are always
present if any of their pages are present.


>>> I analyzed the assembler:
>>> PageBuddy in move_freepages returns false
>>> Then we call PageLRU, the macro calls PF_HEAD which is compound_page()
>>> compound_page reads page->compound_head, it is 0xffffffffffffffff, so it
>>> resturns 0xfffffffffffffffe - and accessing this address causes crash
>>
>> Thanks!
>> That wasn't straightforward to work out without the vmlinux.
>>
>> Because you see all-ones, even in KVM, it looks like the struct page is being
>> initialized like that deliberately... I haven't found where this might be happening.
> 
> It should be
> 
> sparse_add_one_section
> #ifdef CONFIG_DEBUG_VM
> 	/*
> 	 * Poison uninitialized struct pages in order to catch invalid flags
> 	 * combinations.
> 	 */
> 	memset(memmap, PAGE_POISON_PATTERN, sizeof(struct page) * PAGES_PER_SECTION);
> #endif

Aha, thanks. (I expected KVMs uninitialized memory to always be zero).


Thanks!

James
