Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id EEEFC6B7F8C
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 13:47:56 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id r131-v6so17818343oie.14
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 10:47:56 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i11-v6si6056032oia.112.2018.09.07.10.47.55
        for <linux-mm@kvack.org>;
        Fri, 07 Sep 2018 10:47:55 -0700 (PDT)
Subject: Re: A crash on ARM64 in move_freepages_block due to uninitialized
 pages in reserved memory
References: <alpine.LRH.2.02.1808171527220.2385@file01.intranet.prod.int.rdu2.redhat.com>
 <20180821104418.GA16611@dhcp22.suse.cz>
 <e35b7c14-c7ea-412d-2763-c961b74576f3@arm.com>
 <alpine.LRH.2.02.1808220808050.17906@file01.intranet.prod.int.rdu2.redhat.com>
 <c823eace-8710-9bf5-6e76-d01b139c0859@arm.com>
 <20180824114158.GJ29735@dhcp22.suse.cz>
 <541193a6-2bce-f042-5bb2-88913d5f1047@arm.com>
 <20180903193322.GD14951@dhcp22.suse.cz>
From: James Morse <james.morse@arm.com>
Message-ID: <519d370a-837b-6492-d6a9-c818088a0a8e@arm.com>
Date: Fri, 7 Sep 2018 18:47:51 +0100
MIME-Version: 1.0
In-Reply-To: <20180903193322.GD14951@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Pavel Tatashin <Pavel.Tatashin@microsoft.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Russell King <linux@armlinux.org.uk>

Hi Michal,

(CC: +Russell, we're trying to work out if ARCH_HAS_HOLES_MEMORYMODEL is still
necessary)

On 03/09/18 20:33, Michal Hocko wrote:
> On Wed 29-08-18 18:37:55, James Morse wrote:
>> On 24/08/18 12:41, Michal Hocko wrote:
>>> On Thu 23-08-18 15:06:08, James Morse wrote:
>>> [...]
>>>> My best-guess is that pfn_valid_within() shouldn't be optimised out if
>>> ARCH_HAS_HOLES_MEMORYMODEL, even if HOLES_IN_ZONE isn't set.

>> After plenty of greping, git-archaeology and help from others, I think I've a
>> clearer picture of what these options do.
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
> 
> I have hard times to find an actual code that does this partial memmap
> initialization.

arch/arm64/mm/init.c:free_unused_memmap(), once it has walked all the memblocks
does this with the space after the last one:
|#ifdef CONFIG_SPARSEMEM
|	if (!IS_ALIGNED(prev_end, PAGES_PER_SECTION))
|		free_memmap(prev_end, ALIGN(prev_end, PAGES_PER_SECTION));
|#endif

prev_end is the pfn of the end of the last memblock, rounded up to
MAX_ORDER_NR_PAGES. If this isn't aligned to a section boundary, whole pages of
memmap between prev_end and the section boundary are freed.

(The memblock walker does something similar for the gaps between memblocks)


>> This is independent of nomap, and isn't relevant on arm64 as our pfn_valid()
>> always tests the page in memblock due to nomap pages, which can occur anywhere.
>> (I will propose a patch removing ARCH_HAS_HOLES_MEMORYMODEL for arm64.)
> 
> It seems ARCH_HAS_HOLES_MEMORYMODEL is only defined for arm and arm64.
> Is it really needed for arm?

I don't know much about arch/arm, but from grepping around: arch/arm does the
same thing as above with its free_unused_memmap(), so this partial memmap
initialisation can happen.

For 32bit ARCH_HAS_HOLES_MEMORYMODEL is something different boards/platforms
opt-into. But to match the partial memmap-initialisation case above it should be
selected if SPARSEMEM. Doing this would make HAVE_ARCH_PFN_VALID always true,
meaning the checks ARCH_HAS_HOLES_MEMORYMODEL enables never need running because
pfn_valid() already does them, at which point it can be removed.

The way it is makes sense if each board/platform knows where/how-much memory it
will have and can size FORCE_MAX_ZONEORDER so it doesn't get holes. But doesn't
this stuff all come from DT nowadays?

I think arch/arm should select ARCH_HAS_HOLES_MEMORYMODEL if USE_OF, but I don't
think this extra configurability is useful. Selecting it unconditionally would
let us remove it.


Digging through the history I think the original commit:
eb33575cf67d ("[ARM] Double check memmap is actually valid with a memmap has
unexpected holes V2")
Was working around the pfn_valid() behaviour that was changed with:
7b7bf499f79d (" ARM: 6913/1: sparsemem: allow pfn_valid to be overridden when
using SPARSEMEM")

The two users that describe their memory layout just want HAVE_ARCH_PFN_VALID:
59f181aa9d633 ("ARM: brcmstb: Enable ARCH_HAS_HOLES_MEMORYMODEL")
e511333212de4 ("ARM: highbank: select ARCH_HAS_HOLES_MEMORYMODEL")


Thanks,

James
