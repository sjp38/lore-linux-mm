Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 777456B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 22:20:46 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id v18so8239222qtv.0
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 19:20:46 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTPS id u21si7852640qkl.71.2016.06.27.19.20.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 27 Jun 2016 19:20:45 -0700 (PDT)
Date: Tue, 28 Jun 2016 10:20:12 +0800
From: Dennis Chen <dennis.chen@arm.com>
Subject: Re: [PATCH v2 2/2] arm64:acpi Fix the acpi alignment exeception when
 'mem=' specified
Message-ID: <20160628022010.GA9594@arm.com>
References: <1466738027-15066-1-git-send-email-dennis.chen@arm.com>
 <1466738027-15066-2-git-send-email-dennis.chen@arm.com>
 <CAKv+Gu8ZyWG-OZ8=2u9jrdS-0j+qL1sstPQ0uX=j7wyj+ETo-w@mail.gmail.com>
 <20160624120058.GA19972@arm.com>
 <CAKv+Gu9XHYVEoL846WBx6PZqSnbBCjwup0CPkZ1JexJVkvds9A@mail.gmail.com>
 <20160627095318.GA1113@leverpostej>
MIME-Version: 1.0
In-Reply-To: <20160627095318.GA1113@leverpostej>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Steve Capper <steve.capper@arm.com>, Will Deacon <will.deacon@arm.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Matt Fleming <matt@codeblueprint.co.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>

On Mon, Jun 27, 2016 at 10:53:18AM +0100, Mark Rutland wrote:
> On Fri, Jun 24, 2016 at 04:12:02PM +0200, Ard Biesheuvel wrote:
> > On 24 June 2016 at 14:01, Dennis Chen <dennis.chen@arm.com> wrote:
> > > On Fri, Jun 24, 2016 at 12:43:52PM +0200, Ard Biesheuvel wrote:
> > >> On 24 June 2016 at 05:13, Dennis Chen <dennis.chen@arm.com> wrote:
> > >> >         /*
> > >> >          * Apply the memory limit if it was set. Since the kernel =
may be loaded
> > >> > -        * high up in memory, add back the kernel region that must=
 be accessible
> > >> > -        * via the linear mapping.
> > >> > +        * in the memory regions above the limit, so we need to cl=
ear the
> > >> > +        * MEMBLOCK_NOMAP flag of this region to make it can be ac=
cessible via
> > >> > +        * the linear mapping.
> > >> >          */
> > >> >         if (memory_limit !=3D (phys_addr_t)ULLONG_MAX) {
> > >> > -               memblock_enforce_memory_limit(memory_limit);
> > >> > -               memblock_add(__pa(_text), (u64)(_end - _text));
> > >> > +               memblock_mem_limit_mark_nomap(memory_limit);
> > >> > +               memblock_clear_nomap(__pa(_text), (u64)(_end - _te=
xt));
> > >>
> > >> Up until now, we have ignored the effect of having NOMAP memblocks o=
n
> > >> the return values of functions like memblock_phys_mem_size() and
> > >> memblock_mem_size(), since they could reasonably be expected to cove=
r
> > >> only a small slice of all available memory. However, after applying
> > >> this patch, it may well be the case that most of memory is marked
> > >> NOMAP, and these functions will cease to work as expected.
> > >>
> > > Hi Ard, I noticed these inconsistences as you mentioned, but seems th=
e
> > > available memory is limited correctly. For this case('mem=3D'), will =
it bring
> > > some substantive side effects except that some log messages maybe con=
fusing?
> >=20
> > That is exactly the question that needs answering before we can merge
> > these patches. I know we consider mem=3D a development hack, but the
> > intent is to make it appear to the kernel as if only a smaller amount
> > of memory is available to the kernel, and this is signficantly
> > different from having memblock_mem_size() et al return much larger
> > values than what is actually available. Perhaps this doesn't matter at
> > all, but it is something we must discuss before proceeding with these
> > changes.
>=20
> Yeah, I think we need to figure out precisely what the expected
> semantics are.
>=20
> From taking a look, memblock_mem_size() is only used by arch/x86. In
> reserve_initrd, it's used to determine the amount of *free* memory, but
> it counts reserved (and nomap) regions, so that doesn't feel right
> regardless. For reserve_crashkernel_low it's not immediately clear to me
> what it should do, as I've not gone digging.
>
After rough digging go, memblock_mem_size() used by arch/x86 to calculate
the size of a segment of direct mapping physical memory, it only counts on=
=20
memory memblock region regardless of the flag of that region, so from this
point, if we have a segment of memory marked as NOMAP, memblock_mem_size()
will still take its size into the total size and have it a direct mapped.
IMO memblock_mem_size() is not used to determine the amount of *free*, it
just to determine the amount of mem that can be mapped directly, so it's
reasonable to count reserved regions.
   =20
>=20
> There are many memblock_end_of_DRAM() users, mostly in arch code. We
> (arm64) use it to determine the size of the linear map, and effectively
> need it to be the limit for what should be mapped, which could/should
> exclude nomap. I've not yet dug into the rest, so I don't know whether
> that holds.
>
we will use memblock_end_of_DRAM() to get the top boundary of the linear ma=
pping,
given some memblock region is NOMAP, so some holes will be punched into the
linear mapping zone just as you mentioned those NOMAP should be excluded.
As my understanding, NOMAP regions only have possible potential side effect=
 to count
the mem size such as memblock_mem_size=20
>=20
> > >> This means NOMAP is really only suited to punch some holes into the
> > >> kernel direct mapping, and so implementing the memory limit by marki=
ng
> > >> everything NOMAP is not the way to go. Instead, we should probably
> > >> reorder the init sequence so that the regions that are reserved in t=
he
> > >> UEFI memory map are declared and marked NOMAP [again] after applying
> > >> the memory limit in the old way.
> > >>
> > > Before this patch, I have another one addressing the same issue [1], =
with
> > > that patch we'll not have these inconsistences, but it looks like a l=
ittle
> > > bit complicated, so it becomes current one. Any comments about that?
> > >
> > > [1]http://lists.infradead.org/pipermail/linux-arm-kernel/2016-June/43=
8443.html
> >=20
> > The problem caused by mem=3D is that it removes regions that are marked
> > NOMAP. So instead of marking everything above the limit NOMAP, I would
> > much rather see an alternative implementation of
> > memblock_enforce_memory_limit() that enforces the mem=3D limit by only
> > removing memblocks that have to NOMAP flag cleared, and leaving the
> > NOMAP ones where they are.
>=20
> That would work for me.
>=20
> Thanks,
> Mark.
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
