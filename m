Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF0C46B0005
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 12:18:52 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id c9-v6so12167023ioi.20
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 09:18:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w13-v6sor5323950iob.301.2018.06.25.09.18.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Jun 2018 09:18:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAG_fn=XHJ7QPEd6s=-pFKSS_O7z58==x0=hsofyTq9-s62XFhw@mail.gmail.com>
References: <CAG_fn=Vc5134sX6JRUoGp=W0to6eg56DuW3YErqeWuR_W_O9gQ@mail.gmail.com>
 <CAKv+Gu_Bghu11a+XMSFaE31QQxizsrG1UDi4-9vSke0Vso1MaA@mail.gmail.com> <CAG_fn=XHJ7QPEd6s=-pFKSS_O7z58==x0=hsofyTq9-s62XFhw@mail.gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Mon, 25 Jun 2018 18:18:50 +0200
Message-ID: <CAKv+Gu-+F2cyoQ5t4g42SKzbNxpebFwRitE0yzKKNkk7N8F7Mg@mail.gmail.com>
Subject: Re: Calling vmalloc_to_page() on ioremap memory?
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On 25 June 2018 at 18:07, Alexander Potapenko <glider@google.com> wrote:
> On Mon, Jun 25, 2018 at 5:37 PM Ard Biesheuvel
> <ard.biesheuvel@linaro.org> wrote:
>>
>> On 25 June 2018 at 16:59, Alexander Potapenko <glider@google.com> wrote:
>> > Hi Ard, Mark, Andrew and others,
>> >
>> > AFAIU, commit 029c54b09599573015a5c18dbe59cbdf42742237 ("mm/vmalloc.c:
>> > huge-vmap: fail gracefully on unexpected huge vmap mappings") was
>> > supposed to make vmalloc_to_page() return NULL for pointers not
>> > returned by vmalloc().
>> > But when I call vmalloc_to_page() for the pointer returned by
>> > acpi_os_ioremap() (see the patch below) I see that the resulting
>> > `struct page *` points to unmapped memory:
>> >
>>
>> Why do you assume it maps memory? It could map a device's MMIO
>> registers as well, which don't have struct pages associated with them.
> I might have been unclear. I'm just assuming that vmalloc_to_page()
> returns either a valid struct page or NULL for a valid pointer
> belonging to vmalloc area.
> In this case vmalloc_to_page() returns a wild pointer.
>

is_vmalloc_addr() only checks whether the mapping is within the
boundaries of the VMALLOC region, and does not check whether it is in
fact a VM_ALLOC or VM_MAP mapping, and vmalloc_to_page() should
probably only be called on mappings of that type. The reason it is
implemented like this may well be the issue that you highlight, i.e.,
that this cannot be done from every context.

As for the patch, it was intended to ensure that vmalloc_to_page()
does not blindly assume that VM_MAP regions are mapped down to pages,
which is not the case for mappings of the kernel image on arm64.



>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
>> > ACPI: Enabled 2 GPEs in block 00 to 0F
>> > phys: 00000000fed00000, vmalloc: ffffc9000019a000, page:
>>
>> Isn't that phys address something like the HPET on a x86 system?
> Yes, probably. I just came across it while trying to instrument every
> memory access with code doing something along the lines of:
>   if (is_vmalloc_addr(addr))
>     return vmalloc_to_page(addr)->metadata;
>   else
>     if (virt_to_page(addr))
>       return virt_to_page(addr)->metadata;
>
> , I don't think there's anything specific to that physical address.
>> > ffff8800fed00000 [ffffea0003fb4000]
>> > BUG: unable to handle kernel paging request at ffffea0003fb4000
>> > PGD 3f7d5067 P4D 3f7d5067 PUD 3f7d4067 PMD 0
>> > Oops: 0000 [#1] SMP PTI
>> > CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.18.0-rc2+ #1325
>> > Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 0=
4/01/=3D
>> > 2014
>> > RIP: 0010:acpi_os_map_iomem+0x1c5/0x210 ??:?
>> > Code: 00 88 ff ff 4d 89 f8 48 c1 f9 06 4c 89 f6 48 c7 c7 60 5f 01 82
>> > 48 c1 e1 0c 48 01 c1 e8 6d 42 70 ff 4d 85 ff 0f 84 14 ff ff ff <49> 8b
>> > 37 48 c7 c7 d2 61 01 82 e8 55 42 70 ff e9 00 ff ff ff 48 c7
>> > RSP: 0000:ffff88003e253840 EFLAGS: 00010286
>> > RAX: 000000000000005c RBX: ffff88003d857b80 RCX: ffffffff82245d38
>> > RDX: 0000000000000000 RSI: 0000000000000096 RDI: ffffffff8288e86c
>> > RBP: 00000000fed00000 R08: 00000000000000ae R09: 0000000000000007
>> > R10: 0000000000000000 R11: ffffffff828908ad R12: 0000000000001000
>> > R13: ffffc9000019a000 R14: 00000000fed00000 R15: ffffea0003fb4000
>> > FS:  0000000000000000(0000) GS:ffff88003fc00000(0000) knlGS:0000000000=
00000=3D
>> > 0
>> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> > CR2: ffffea0003fb4000 CR3: 000000000220a000 CR4: 00000000000006f0
>> > Call Trace:
>> >  acpi_ex_system_memory_space_handler+0xca/0x19f ??:?
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
>> >
>> > For memory error detection purposes I'm trying to map the addresses
>> > from the vmalloc range to valid struct pages, or at least make sure
>> > there's no struct page for a given address.
>> > Looking up the vmap_area_root rbtree isn't an option, as this must be
>> > done from instrumented code, including interrupt handlers.
>> > I've been trying to employ vmalloc_to_page(), but looks like it
>> > doesn't work for ioremapped addresses.
>> > Is this at all possible?
>> >
>> > Patch showing the problem follows. I'm building using GCC 7.1.1 on a
>> > defconfig for x86_64.
>> >
>> > --- a/drivers/acpi/osl.c
>> > +++ b/drivers/acpi/osl.c
>> > @@ -279,14 +279,23 @@ acpi_map_lookup_virt(void __iomem *virt, acpi_si=
ze si=3D
>> > ze)
>> >  static void __iomem *acpi_map(acpi_physical_address pg_off, unsigned
>> > long pg_sz)
>> >  {
>> >         unsigned long pfn;
>> > +       void __iomem *ret;
>> > +       struct page *page;
>> >
>> >         pfn =3D3D pg_off >> PAGE_SHIFT;
>> >         if (should_use_kmap(pfn)) {
>> >                 if (pg_sz > PAGE_SIZE)
>> >                         return NULL;
>> >                 return (void __iomem __force *)kmap(pfn_to_page(pfn));
>> > -       } else
>> > -               return acpi_os_ioremap(pg_off, pg_sz);
>> > +       } else {
>> > +               ret =3D3D acpi_os_ioremap(pg_off, pg_sz);
>> > +               BUG_ON(!is_vmalloc_addr(ret));
>> > +               page =3D3D vmalloc_to_page(ret);
>> > +               pr_err("phys: %px, vmalloc: %px, page: %px [%px]\n",
>> > pg_off, ret, page_address(page), page);
>> > +               if (page)
>> > +                       pr_err("flags: %d\n", page->flags);
>> > +               return ret;
>> > +       }
>> >  }
>> >
>> > Thanks,
>> > Alexander Potapenko
>> > Software Engineer
>> >
>> > Google Germany GmbH
>> > Erika-Mann-Stra=C3=9Fe, 33
>> > 80636 M=C3=BCnchen
>> >
>> > Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
>> > Registergericht und -nummer: Hamburg, HRB 86891
>> > Sitz der Gesellschaft: Hamburg
>
>
>
> --
> Alexander Potapenko
> Software Engineer
>
> Google Germany GmbH
> Erika-Mann-Stra=C3=9Fe, 33
> 80636 M=C3=BCnchen
>
> Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
> Registergericht und -nummer: Hamburg, HRB 86891
> Sitz der Gesellschaft: Hamburg
