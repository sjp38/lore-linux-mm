Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 04E506B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 05:53:30 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 143so390574833pfx.0
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 02:53:29 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id xr8si25785058pab.95.2016.06.27.02.53.29
        for <linux-mm@kvack.org>;
        Mon, 27 Jun 2016 02:53:29 -0700 (PDT)
Date: Mon, 27 Jun 2016 10:53:18 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v2 2/2] arm64:acpi Fix the acpi alignment exeception when
 'mem=' specified
Message-ID: <20160627095318.GA1113@leverpostej>
References: <1466738027-15066-1-git-send-email-dennis.chen@arm.com>
 <1466738027-15066-2-git-send-email-dennis.chen@arm.com>
 <CAKv+Gu8ZyWG-OZ8=2u9jrdS-0j+qL1sstPQ0uX=j7wyj+ETo-w@mail.gmail.com>
 <20160624120058.GA19972@arm.com>
 <CAKv+Gu9XHYVEoL846WBx6PZqSnbBCjwup0CPkZ1JexJVkvds9A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu9XHYVEoL846WBx6PZqSnbBCjwup0CPkZ1JexJVkvds9A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Dennis Chen <dennis.chen@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, nd@arm.com, Catalin Marinas <catalin.marinas@arm.com>, Steve Capper <steve.capper@arm.com>, Will Deacon <will.deacon@arm.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Matt Fleming <matt@codeblueprint.co.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>

On Fri, Jun 24, 2016 at 04:12:02PM +0200, Ard Biesheuvel wrote:
> On 24 June 2016 at 14:01, Dennis Chen <dennis.chen@arm.com> wrote:
> > On Fri, Jun 24, 2016 at 12:43:52PM +0200, Ard Biesheuvel wrote:
> >> On 24 June 2016 at 05:13, Dennis Chen <dennis.chen@arm.com> wrote:
> >> >         /*
> >> >          * Apply the memory limit if it was set. Since the kernel may be loaded
> >> > -        * high up in memory, add back the kernel region that must be accessible
> >> > -        * via the linear mapping.
> >> > +        * in the memory regions above the limit, so we need to clear the
> >> > +        * MEMBLOCK_NOMAP flag of this region to make it can be accessible via
> >> > +        * the linear mapping.
> >> >          */
> >> >         if (memory_limit != (phys_addr_t)ULLONG_MAX) {
> >> > -               memblock_enforce_memory_limit(memory_limit);
> >> > -               memblock_add(__pa(_text), (u64)(_end - _text));
> >> > +               memblock_mem_limit_mark_nomap(memory_limit);
> >> > +               memblock_clear_nomap(__pa(_text), (u64)(_end - _text));
> >>
> >> Up until now, we have ignored the effect of having NOMAP memblocks on
> >> the return values of functions like memblock_phys_mem_size() and
> >> memblock_mem_size(), since they could reasonably be expected to cover
> >> only a small slice of all available memory. However, after applying
> >> this patch, it may well be the case that most of memory is marked
> >> NOMAP, and these functions will cease to work as expected.
> >>
> > Hi Ard, I noticed these inconsistences as you mentioned, but seems the
> > available memory is limited correctly. For this case('mem='), will it bring
> > some substantive side effects except that some log messages maybe confusing?
> 
> That is exactly the question that needs answering before we can merge
> these patches. I know we consider mem= a development hack, but the
> intent is to make it appear to the kernel as if only a smaller amount
> of memory is available to the kernel, and this is signficantly
> different from having memblock_mem_size() et al return much larger
> values than what is actually available. Perhaps this doesn't matter at
> all, but it is something we must discuss before proceeding with these
> changes.

Yeah, I think we need to figure out precisely what the expected
semantics are.

>From taking a look, memblock_mem_size() is only used by arch/x86. In
reserve_initrd, it's used to determine the amount of *free* memory, but
it counts reserved (and nomap) regions, so that doesn't feel right
regardless. For reserve_crashkernel_low it's not immediately clear to me
what it should do, as I've not gone digging.

There are many memblock_end_of_DRAM() users, mostly in arch code. We
(arm64) use it to determine the size of the linear map, and effectively
need it to be the limit for what should be mapped, which could/should
exclude nomap. I've not yet dug into the rest, so I don't know whether
that holds.

> >> This means NOMAP is really only suited to punch some holes into the
> >> kernel direct mapping, and so implementing the memory limit by marking
> >> everything NOMAP is not the way to go. Instead, we should probably
> >> reorder the init sequence so that the regions that are reserved in the
> >> UEFI memory map are declared and marked NOMAP [again] after applying
> >> the memory limit in the old way.
> >>
> > Before this patch, I have another one addressing the same issue [1], with
> > that patch we'll not have these inconsistences, but it looks like a little
> > bit complicated, so it becomes current one. Any comments about that?
> >
> > [1]http://lists.infradead.org/pipermail/linux-arm-kernel/2016-June/438443.html
> 
> The problem caused by mem= is that it removes regions that are marked
> NOMAP. So instead of marking everything above the limit NOMAP, I would
> much rather see an alternative implementation of
> memblock_enforce_memory_limit() that enforces the mem= limit by only
> removing memblocks that have to NOMAP flag cleared, and leaving the
> NOMAP ones where they are.

That would work for me.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
