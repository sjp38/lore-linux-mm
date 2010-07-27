Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C06DB600365
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 05:56:26 -0400 (EDT)
Received: by gwj16 with SMTP id 16so524140gwj.14
        for <linux-mm@kvack.org>; Tue, 27 Jul 2010 02:56:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <pfn.valid.v4.reply.2@mdm.bga.com>
References: <1280159163-23386-1-git-send-email-minchan.kim@gmail.com>
	<alpine.DEB.2.00.1007261136160.5438@router.home>
	<pfn.valid.v4.reply.1@mdm.bga.com>
	<AANLkTimtTVvorrR9pDVTyPKj0HbYOYY3aR7B-QWGhTei@mail.gmail.com>
	<pfn.valid.v4.reply.2@mdm.bga.com>
Date: Tue, 27 Jul 2010 18:56:24 +0900
Message-ID: <AANLkTim7s4FH+hU19d53R3JLKm3pcDGV5cMMeST-Wyrz@mail.gmail.com>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Milton Miller <miltonm@bga.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 27, 2010 at 5:12 PM, Milton Miller <miltonm@bga.com> wrote:
>
> On Tue Jul 27 2010 about 02:11:22 Minchan Kim wrote:
>> > [Sorry if i missed or added anyone on cc, patchwork.kernel.org =A0LKML=
 is not
>> > working and I'm not subscribed to the list ]
>>
>> Readd them. :)
>
> Changed linux-mmc at vger to linxu-mm at kvack.org, from my poor use of g=
rep
> MAINTAINERS.
>
>> On Tue, Jul 27, 2010 at 2:55 PM, <miltonm@xxxxxxx> wrote:
>> > On Mon Jul 26 2010 about 12:47:37 EST, Christoph Lameter wrote:
>> > > On Tue, 27 Jul 2010, Minchan Kim wrote:
>> > >
>> > > > This patch registers address of mem_section to memmap itself's pag=
e struct's
>> > > > pg->private field. This means the page is used for memmap of the s=
ection.
>> > > > Otherwise, the page is used for other purpose and memmap has a hol=
e.
>> >
>> > >
>> > > > +void mark_valid_memmap(unsigned long start, unsigned long end);
>> > > > +
>> > > > +#ifdef CONFIG_ARCH_HAS_HOLES_MEMORYMODEL
>> > > > +static inline int memmap_valid(unsigned long pfn)
>> > > > +{
>> > > > + struct page *page =3D pfn_to_page(pfn);
>> > > > + struct page *__pg =3D virt_to_page(page);
>> > > > + return page_private(__pg) =3D=3D (unsigned long)__pg;
>> > >
>> > >
>> > > What if page->private just happens to be the value of the page struc=
t?
>> > > Even if that is not possible today, someday someone may add new
>> > > functionality to the kernel where page->pivage =3D=3D page is used f=
or some
>> > > reason.
>> > >
>> > > Checking for PG_reserved wont work?
>> >
>> > I had the same thought and suggest setting it to the memory section bl=
ock,
>> > since that is a uniquie value (unlike PG_reserved),
>>
>> You mean setting pg->private to mem_section address?
>> I hope I understand your point.
>>
>> Actually, KAMEZAWA tried it at first version but I changed it.
>> That's because I want to support this mechanism to ARM FLATMEM.
>> (It doesn't have mem_section)
>
>> >
>> > .. and we already have computed it when we use it so we could pass it =
as
>> > a parameter (to both _valid and mark_valid).
>>
>> I hope this can support FALTMEM which have holes(ex, ARM).
>>
>
> If we pass a void * to this helper we should be able to find another
> symbol. =A0Looking at the pfn_valid() in arch/arm/mm/init.c I would
> probably choose &meminfo as it is already used nearby, and using a single

If we uses pg itself and PG_reserved, we can remove &meminfo in FLATMEM.

> symbol in would avoid issues if a more specific symbol chosen (eg bank)
> were to change at a pfn boundary not PAGE_SIZE / sizeof(struct page).
> Similarly the asm-generic/page.h version could use &max_mapnr.

I don't consider NOMMU.
I am not sure NOMMU have a this problem.

>
> This function is a validation helper for pfn_valid not the only check.
>
> something like
>
> static inline int memmap_valid(unsigned long pfn, void *validate)
> {
> =A0 =A0 =A0 =A0struct page *page =3D pfn_to_page(pfn);
> =A0 =A0 =A0 =A0struct page *__pg =3D virt_to_page(page);
> =A0 =A0 =A0 =A0return page_private(__pg) =3D=3D validate;
> }

I am not sure what's benefit we have if we use validate argument.

>
> static inline int pfn_valid(unsigned long pfn)
> {
> =A0 =A0 =A0 =A0struct mem_section *ms;
> =A0 =A0 =A0 =A0if (pfn_to_section_nr(pfn) >=3D NR_MEM_SECTIONS)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
> =A0 =A0 =A0 =A0ms =3D __nr_to_section(pfn_to_section_nr(pfn));
> =A0 =A0 =A0 =A0return valid_section(ms) && memmap_valid(pfn, ms);
> }
>
>> > > > +/*
>> > > > + * Fill pg->private on valid mem_map with page itself.
>> > > > + * pfn_valid() will check this later. (see include/linux/mmzone.h=
)
>> > > > + * Every arch for supporting hole of mem_map should call
>> > > > + * mark_valid_memmap(start, end). please see usage in ARM.
>> > > > + */
>> > > > +void mark_valid_memmap(unsigned long start, unsigned long end)
>> > > > +{
>> > > > + =A0 =A0 =A0 struct mem_section *ms;
>> > > > + =A0 =A0 =A0 unsigned long pos, next;
>> > > > + =A0 =A0 =A0 struct page *pg;
>> > > > + =A0 =A0 =A0 void *memmap, *mapend;
>> > > > +
>> > > > + =A0 =A0 =A0 for (pos =3D start; pos < end; pos =3D next) {
>> > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 next =3D (pos + PAGES_PER_SECTION) &=
 PAGE_SECTION_MASK;
>> > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ms =3D __pfn_to_section(pos);
>> > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!valid_section(ms))
>> > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> > > > +
>> > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (memmap =3D (void*)pfn_to_page(p=
os),
>> > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 /* The last page in section */
>> > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 mapend =3D pfn_to_page(next-1);
>> > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memm=
ap < mapend; memmap +=3D PAGE_SIZE) {
>> > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pg =3D virt_to_page(=
memmap);
>> > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_page_private(pg,=
 (unsigned long)pg);
>> > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> > > > + =A0 =A0 =A0 }
>> > > > +}
>
> Hmm, this loop would need to change for sections. =A0 And sizeof(struct
> page) % PAGE_SIZE may not be 0, so we want a global symbol for sparsemem

I can't understand your point. What is problem of sizeof(struct page)%PAGE_=
SIZE?
AFAIK, I believe sizeof(struct page) is always 32 bit in 32 bit
machine and most of PAGE_SIZE is 4K. What's problem happen?

> too. =A0Perhaps the mem_section array. =A0Using a symbol that is part of
> the model pre-checks can remove a global symbol lookup and has the side
> effect of making sure our pfn_valid is for the right model.

global symbol lookup?
Hmm, Please let me know your approach's benefit for improving this patch. :=
)

Thanks for careful review, milton.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
