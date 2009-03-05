Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D02206B00B3
	for <linux-mm@kvack.org>; Wed,  4 Mar 2009 19:30:22 -0500 (EST)
Received: by rv-out-0506.google.com with SMTP id g9so1116383rvb.6
        for <linux-mm@kvack.org>; Wed, 04 Mar 2009 16:30:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090305092534.740ee3c9.minchan.kim@barrios-desktop>
References: <alpine.LFD.2.00.0903040014140.5511@xanadu.home>
	 <20090304171429.c013013c.minchan.kim@barrios-desktop>
	 <alpine.LFD.2.00.0903041101170.5511@xanadu.home>
	 <20090305080717.f7832c63.minchan.kim@barrios-desktop>
	 <20090304234633.GD14744@n2100.arm.linux.org.uk>
	 <20090305092534.740ee3c9.minchan.kim@barrios-desktop>
Date: Thu, 5 Mar 2009 09:30:21 +0900
Message-ID: <28c262360903041630u44bd8993ve7c0ea97c5c82e2e@mail.gmail.com>
Subject: Re: [RFC] atomic highmem kmap page pinning
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Minchan Kim <minchan.kim@gmail.com>, Nicolas Pitre <nico@cam.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrea Arcangeli <andrea@cpushare.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

It seems Andrea's mail address is changed.
I will resend new Andrea's mail address.

On Thu, Mar 5, 2009 at 9:25 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> - Show quoted text -
> On Wed, 4 Mar 2009 23:46:33 +0000
> Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:
>
>> On Thu, Mar 05, 2009 at 08:07:17AM +0900, Minchan Kim wrote:
>> > On Wed, 04 Mar 2009 12:26:00 -0500 (EST)
>> > Nicolas Pitre <nico@cam.org> wrote:
>> >
>> > > On Wed, 4 Mar 2009, Minchan Kim wrote:
>> > >
>> > > > On Wed, 04 Mar 2009 00:58:13 -0500 (EST)
>> > > > Nicolas Pitre <nico@cam.org> wrote:
>> > > >
>> > > > > I've implemented highmem for ARM. =C2=A0Yes, some ARM machines d=
o have lots
>> > > > > of memory...
>> > > > >
>> > > > > The problem is that most ARM machines have a non IO coherent cac=
he,
>> > > > > meaning that the dma_map_* set of functions must clean and/or in=
validate
>> > > > > the affected memory manually. =C2=A0And because the majority of =
those
>> > > > > machines have a VIVT cache, the cache maintenance operations mus=
t be
>> > > > > performed using virtual addresses.
>> > > > >
>> > > > > In dma_map_page(), an highmem pages could still be mapped and ca=
ched
>> > > > > even after kunmap() was called on it. =C2=A0As long as highmem p=
ages are
>> > > > > mapped, page_address(page) is non null and we can use that to
>> > > > > synchronize the cache.
>> > > > > It is unlikely but still possible for kmap() to race and recycle=
 the
>> > > > > obtained virtual address above, and use it for another page thou=
gh. =C2=A0In
>> > > > > that case, the new mapping could end up with dirty cache lines f=
or
>> > > > > another page, and the unsuspecting cache invalidation loop in
>> > > > > dma_map_page() won't notice resulting in data loss. =C2=A0Hence =
the need for
>> > > > > some kind of kmap page pinning which can be used in any context,
>> > > > > including IRQ context.
>> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^=
^^^^^
>>
>> > > > > This is a RFC patch implementing the necessary part in the core =
code, as
>> > > > > suggested by RMK. Please comment.
>> > > >
>> > > > I am not sure if i understand your concern totally.
>> > > > I can understand it can be recycled. but Why is it racing ?
>> > >
>> > > Suppose this sequence of events:
>> > >
>> > > =C2=A0 - dma_map_page(..., DMA_FROM_DEVICE) is called on a highmem p=
age.
>> > >
>> > > =C2=A0 --> =C2=A0 =C2=A0 - vaddr =3D page_address(page) is non null.=
 In this case
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 it is likely that the page=
 has valid cache lines
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 associated with vaddr. Rem=
ember that the cache is VIVT.
>> > >
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 --> =C2=A0 =C2=A0 - for (i =3D va=
ddr; i < vaddr + PAGE_SIZE; i +=3D 32)
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 invalidate_cache_line(i);
>> > >
>> > > =C2=A0 *** preemption occurs in the middle of the loop above ***
>> > >
>> > > =C2=A0 - kmap_high() is called for a different page.
>> > >
>> > > =C2=A0 --> =C2=A0 =C2=A0 - last_pkmap_nr wraps to zero and flush_all=
_zero_pkmaps()
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 is called. =C2=A0The pkmap=
_count value for the page passed
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 to dma_map_page() above ha=
ppens to be 1, so it is
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unmapped. =C2=A0But prior =
to that, flush_cache_kmaps()
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cleared the cache for it. =
=C2=A0So far so good.
>> >
>> > Thanks for kind explanation.:)
>> >
>> > I thought kmap and dma_map_page usage was following.
>> >
>> > kmap(page);
>> > ...
>> > dma_map_page(...)
>> > =C2=A0 invalidate_cache_line
>> >
>> > kunmap(page);
>>
>> No, that's not the usage at all. =C2=A0kmap() can't be called from the
>> contexts which dma_map_page() is called from (iow, IRQ contexts as
>> pointed out in the paragraph I underlined above.)
>>
>> We're talking about dma_map_page() _internally_ calling kmap_get_page()
>> to _atomically_ and _safely_ check whether the page was kmapped. =C2=A0I=
f
>> it was kmapped, we need to pin the page and return its currently mapped
>> address for cache handling and then release that reference.
>
> Thanks, Russel.
> I see. That was thing I missed. :)
>
>> None of the existing kmap support comes anywhere near to providing a
>> mechanism for this because it can't be used in the contexts under which
>> dma_map_page() is called.
>
> Right.
>
>> If we could do it with existing interfaces, we wouldn't need a new
>> interface would we?
>
> OK.
> As previous said, I don't like kmap_high's irq disable.
> It's already used in many place. so irq'disable effect might be rather bi=
g.
>
> How about new interface which is like KM_IRQ's kmap_atomic slot
> =C2=A0with serializing kmap_atomic_lock?
>
> Let's Cced other experts.
>
> --
> Kinds Regards
> Minchan Kim
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
