Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 971496B0006
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 06:00:14 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id q184-v6so534076vke.23
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 03:00:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 200-v6sor394112vkh.248.2018.06.26.03.00.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Jun 2018 03:00:13 -0700 (PDT)
MIME-Version: 1.0
References: <CAG_fn=Vc5134sX6JRUoGp=W0to6eg56DuW3YErqeWuR_W_O9gQ@mail.gmail.com>
 <20180625160040.di75264empbcf6xz@lakrids.cambridge.arm.com>
 <CAG_fn=XKo6nDphugt6wJSfA3qXGDkGDzd302kRSW6jdD4XNMvQ@mail.gmail.com> <20180625162728.qkkbzjgqebgh2fuu@lakrids.cambridge.arm.com>
In-Reply-To: <20180625162728.qkkbzjgqebgh2fuu@lakrids.cambridge.arm.com>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 26 Jun 2018 12:00:00 +0200
Message-ID: <CAG_fn=UzUTdAAKUWDtoM_OBzh_vk7NY+XB8eRsuzgcwioNg+Hw@mail.gmail.com>
Subject: Re: Calling vmalloc_to_page() on ioremap memory?
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Jun 25, 2018 at 6:27 PM Mark Rutland <mark.rutland@arm.com> wrote:
>
> On Mon, Jun 25, 2018 at 06:24:57PM +0200, Alexander Potapenko wrote:
> > On Mon, Jun 25, 2018 at 6:00 PM Mark Rutland <mark.rutland@arm.com> wro=
te:
> > >
> > > On Mon, Jun 25, 2018 at 04:59:23PM +0200, Alexander Potapenko wrote:
> > > > Hi Ard, Mark, Andrew and others,
> > > >
> > > > AFAIU, commit 029c54b09599573015a5c18dbe59cbdf42742237 ("mm/vmalloc=
.c:
> > > > huge-vmap: fail gracefully on unexpected huge vmap mappings") was
> > > > supposed to make vmalloc_to_page() return NULL for pointers not
> > > > returned by vmalloc().
> > >
> > > It's a little more subtle than that -- avoiding an edge case where we
> > > unexpectedly hit huge mappings, rather than determining whether an
> > > address same from vmalloc().
> > Ok, but anyway, acpi_os_ioremap() creates a huge page mapping via
> > __ioremap_caller() (see
> > https://elixir.bootlin.com/linux/latest/source/arch/x86/mm/ioremap.c#L1=
33)
> > Shouldn't these checks detect that as well?
>
> It should catch such mappings, yes.
>
> > > > For memory error detection purposes I'm trying to map the addresses
> > > > from the vmalloc range to valid struct pages, or at least make sure
> > > > there's no struct page for a given address.
> > > > Looking up the vmap_area_root rbtree isn't an option, as this must =
be
> > > > done from instrumented code, including interrupt handlers.
> > >
> > > I'm not sure how you can do this without looking at VMAs.
> > >
> > > In general, the vmalloc area can contain addresses which are not memo=
ry,
> > > and this cannot be detremined from the address alone.
> > I thought this was exactly what vmalloc_to_page() did, but apparently n=
o.
> >
> > > You *might* be able to get away with pfn_valid(vmalloc_to_pfn(x)), bu=
t
> > > IIRC there's some disagreement on the precise meaning of pfn_valid(),=
 so
> > > that might just tell you that the address happens to fall close to so=
me
> > > valid memory.
> > This appears to work, at least for ACPI mappings. I'll check other case=
s though.
> > Thank you!
pfn_valid(vmalloc_to_pfn(x)) works for me, so I'll stick to this
solution for now. Thanks again!

But just to clarify, should vmalloc_to_page() return NULL for a huge
mapping returned by __ioremap_caller()?
Your answer and that of Ard seem to be contradictory.
Maybe it's a good idea to add the pfn_valid() check to
vmalloc_to_page() just to be sure?
> Great!
>
> Thanks,
> Mark.



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
