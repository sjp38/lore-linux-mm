Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 65D2D6B000A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 08:10:31 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id c23-v6so11797749oiy.3
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 05:10:31 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f88-v6si462443otf.158.2018.06.26.05.10.29
        for <linux-mm@kvack.org>;
        Tue, 26 Jun 2018 05:10:30 -0700 (PDT)
Date: Tue, 26 Jun 2018 13:10:26 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: Calling vmalloc_to_page() on ioremap memory?
Message-ID: <20180626121025.xo2pgskpry2fqrpa@lakrids.cambridge.arm.com>
References: <CAG_fn=Vc5134sX6JRUoGp=W0to6eg56DuW3YErqeWuR_W_O9gQ@mail.gmail.com>
 <20180625160040.di75264empbcf6xz@lakrids.cambridge.arm.com>
 <CAG_fn=XKo6nDphugt6wJSfA3qXGDkGDzd302kRSW6jdD4XNMvQ@mail.gmail.com>
 <20180625162728.qkkbzjgqebgh2fuu@lakrids.cambridge.arm.com>
 <CAG_fn=UzUTdAAKUWDtoM_OBzh_vk7NY+XB8eRsuzgcwioNg+Hw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=UzUTdAAKUWDtoM_OBzh_vk7NY+XB8eRsuzgcwioNg+Hw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Tue, Jun 26, 2018 at 12:00:00PM +0200, Alexander Potapenko wrote:
> On Mon, Jun 25, 2018 at 6:27 PM Mark Rutland <mark.rutland@arm.com> wrote:
> >
> > On Mon, Jun 25, 2018 at 06:24:57PM +0200, Alexander Potapenko wrote:
> > > On Mon, Jun 25, 2018 at 6:00 PM Mark Rutland <mark.rutland@arm.com> wrote:
> > > >
> > > > On Mon, Jun 25, 2018 at 04:59:23PM +0200, Alexander Potapenko wrote:
> > > > > Hi Ard, Mark, Andrew and others,
> > > > >
> > > > > AFAIU, commit 029c54b09599573015a5c18dbe59cbdf42742237 ("mm/vmalloc.c:
> > > > > huge-vmap: fail gracefully on unexpected huge vmap mappings") was
> > > > > supposed to make vmalloc_to_page() return NULL for pointers not
> > > > > returned by vmalloc().
> > > >
> > > > It's a little more subtle than that -- avoiding an edge case where we
> > > > unexpectedly hit huge mappings, rather than determining whether an
> > > > address same from vmalloc().
> > > Ok, but anyway, acpi_os_ioremap() creates a huge page mapping via
> > > __ioremap_caller() (see
> > > https://elixir.bootlin.com/linux/latest/source/arch/x86/mm/ioremap.c#L133)
> > > Shouldn't these checks detect that as well?
> >
> > It should catch such mappings, yes.
> >
> > > > > For memory error detection purposes I'm trying to map the addresses
> > > > > from the vmalloc range to valid struct pages, or at least make sure
> > > > > there's no struct page for a given address.
> > > > > Looking up the vmap_area_root rbtree isn't an option, as this must be
> > > > > done from instrumented code, including interrupt handlers.
> > > >
> > > > I'm not sure how you can do this without looking at VMAs.
> > > >
> > > > In general, the vmalloc area can contain addresses which are not memory,
> > > > and this cannot be detremined from the address alone.
> > > I thought this was exactly what vmalloc_to_page() did, but apparently no.
> > >
> > > > You *might* be able to get away with pfn_valid(vmalloc_to_pfn(x)), but
> > > > IIRC there's some disagreement on the precise meaning of pfn_valid(), so
> > > > that might just tell you that the address happens to fall close to some
> > > > valid memory.
> > > This appears to work, at least for ACPI mappings. I'll check other cases though.
> > > Thank you!
> pfn_valid(vmalloc_to_pfn(x)) works for me, so I'll stick to this
> solution for now. Thanks again!
> 
> But just to clarify, should vmalloc_to_page() return NULL for a huge
> mapping returned by __ioremap_caller()?

It will not always do so.

It *may* return NULL, or it may return a potentially invalid pointer to
struct page.

> Your answer and that of Ard seem to be contradictory.
> Maybe it's a good idea to add the pfn_valid() check to
> vmalloc_to_page() just to be sure?

Perhaps, though it really depends on the intended use case of
vmalloc_to_page().

Thanks,
Mark.
