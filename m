Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 960586B026D
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 12:27:33 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id n10-v6so1135713otl.2
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 09:27:33 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x124-v6si4437636oix.244.2018.06.25.09.27.32
        for <linux-mm@kvack.org>;
        Mon, 25 Jun 2018 09:27:32 -0700 (PDT)
Date: Mon, 25 Jun 2018 17:27:28 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: Calling vmalloc_to_page() on ioremap memory?
Message-ID: <20180625162728.qkkbzjgqebgh2fuu@lakrids.cambridge.arm.com>
References: <CAG_fn=Vc5134sX6JRUoGp=W0to6eg56DuW3YErqeWuR_W_O9gQ@mail.gmail.com>
 <20180625160040.di75264empbcf6xz@lakrids.cambridge.arm.com>
 <CAG_fn=XKo6nDphugt6wJSfA3qXGDkGDzd302kRSW6jdD4XNMvQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=XKo6nDphugt6wJSfA3qXGDkGDzd302kRSW6jdD4XNMvQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Jun 25, 2018 at 06:24:57PM +0200, Alexander Potapenko wrote:
> On Mon, Jun 25, 2018 at 6:00 PM Mark Rutland <mark.rutland@arm.com> wrote:
> >
> > On Mon, Jun 25, 2018 at 04:59:23PM +0200, Alexander Potapenko wrote:
> > > Hi Ard, Mark, Andrew and others,
> > >
> > > AFAIU, commit 029c54b09599573015a5c18dbe59cbdf42742237 ("mm/vmalloc.c:
> > > huge-vmap: fail gracefully on unexpected huge vmap mappings") was
> > > supposed to make vmalloc_to_page() return NULL for pointers not
> > > returned by vmalloc().
> >
> > It's a little more subtle than that -- avoiding an edge case where we
> > unexpectedly hit huge mappings, rather than determining whether an
> > address same from vmalloc().
> Ok, but anyway, acpi_os_ioremap() creates a huge page mapping via
> __ioremap_caller() (see
> https://elixir.bootlin.com/linux/latest/source/arch/x86/mm/ioremap.c#L133)
> Shouldn't these checks detect that as well?

It should catch such mappings, yes.

> > > For memory error detection purposes I'm trying to map the addresses
> > > from the vmalloc range to valid struct pages, or at least make sure
> > > there's no struct page for a given address.
> > > Looking up the vmap_area_root rbtree isn't an option, as this must be
> > > done from instrumented code, including interrupt handlers.
> >
> > I'm not sure how you can do this without looking at VMAs.
> >
> > In general, the vmalloc area can contain addresses which are not memory,
> > and this cannot be detremined from the address alone.
> I thought this was exactly what vmalloc_to_page() did, but apparently no.
> 
> > You *might* be able to get away with pfn_valid(vmalloc_to_pfn(x)), but
> > IIRC there's some disagreement on the precise meaning of pfn_valid(), so
> > that might just tell you that the address happens to fall close to some
> > valid memory.
> This appears to work, at least for ACPI mappings. I'll check other cases though.
> Thank you!

Great!

Thanks,
Mark.
