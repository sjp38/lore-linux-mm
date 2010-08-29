Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3FB076B01F1
	for <linux-mm@kvack.org>; Sat, 28 Aug 2010 21:49:20 -0400 (EDT)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Received: from eu_spt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L7W00EM25243Q70@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Sun, 29 Aug 2010 02:49:16 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L7W00BR9523DT@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Sun, 29 Aug 2010 02:49:16 +0100 (BST)
Date: Sun, 29 Aug 2010 03:48:16 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH/RFCv4 2/6] mm: cma: Contiguous Memory Allocator added
In-reply-to: <201008281437.11830.hverkuil@xs4all.nl>
Message-id: <op.vh6faqnl7p4s8u@localhost>
Content-transfer-encoding: Quoted-Printable
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
 <0b02e05fc21e70a3af39e65e628d117cd89d70a1.1282286941.git.m.nazarewicz@samsung.com>
 <343f4b0edf9b5eef598831700cb459cd428d3f2e.1282286941.git.m.nazarewicz@samsung.com>
 <201008281437.11830.hverkuil@xs4all.nl>
Sender: owner-linux-mm@kvack.org
To: Hans Verkuil <hverkuil@xs4all.nl>
Cc: linux-mm@kvack.org, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Jonathan Corbet <corbet@lwn.net>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Pawel Osciak <p.osciak@samsung.com>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Friday, August 20, 2010 11:50:42 Michal Nazarewicz wrote:
>> +**** Regions
>> +
>> +     Regions is a list of regions terminated by a region with size
>> +     equal zero.  The following fields may be set:
>> +
>> +     - size       -- size of the region (required, must not be zero)=

>> +     - alignment  -- alignment of the region; must be power of two o=
r
>> +                     zero (optional)

On Sat, 28 Aug 2010 14:37:11 +0200, Hans Verkuil <hverkuil@xs4all.nl> wr=
ote:
> Just wondering: is alignment really needed since we already align to t=
he
> PAGE_SIZE? Do you know of hardware with alignment requirements > PAGE_=
SIZE?

Our video coder needs its firmware aligned to 128K plus it has to be loc=
ated
before any other buffers allocated for the chip.  Because of those, we h=
ave
defined a separate region just for the coder's firmware which is small (=
256K
IIRC) and aligned to 128K.

>> +     - start      -- where the region has to start (optional)
>> +     - alloc_name -- the name of allocator to use (optional)
>> +     - alloc      -- allocator to use (optional; and besides
>> +                     alloc_name is probably is what you want)

> I would make this field internal only. At least for now.

OK.

>> +*** The device and types of memory
>> +
>> +    The name of the device is taken from the device structure.  It i=
s
>> +    not possible to use CMA if driver does not register a device
>> +    (actually this can be overcome if a fake device structure is
>> +    provided with at least the name set).
>> +
>> +    The type of memory is an optional argument provided by the devic=
e
>> +    whenever it requests memory chunk.  In many cases this can be
>> +    ignored but sometimes it may be required for some devices.
>
> This really should not be optional but compulsory. 'type' has the same=
 function
> as the GFP flags with kmalloc. They tell the kernel where the memory s=
hould be
> allocated. Only if you do not care at all can you pass in NULL. But in=
 almost
> all cases the memory should be at least DMA-able (and yes, for a lot o=
f SoCs that
> is the same as any memory -- for now).

At this moment, if type is NULL "common" is assumed.

> Memory types should be defined in the platform code. Some can be gener=
ic
> like 'dma' (i.e. any DMAable memory), 'dma32' (32-bit DMA) and 'common=
' (any
> memory). Others are platform specific like 'banka' and 'bankb'.

Yes, that's the idea.

> A memory type definition can either be a start address/size pair but i=
t can
> perhaps also be a GFP type (e.g. .name =3D "dma32", .gfp =3D GFP_DMA32=
).
>
> Regions should be of a single memory type. So when you define the regi=
on it
> should have a memory type field.
>
> Drivers request memory of whatever type they require. The mapping just=
 maps
> one or more regions to the driver and the cma allocator will pick only=
 those
> regions with the required type and ignore those that do not match.
>
>> +    For instance, let's say that there are two memory banks and for
>> +    performance reasons a device uses buffers in both of them.
>> +    Platform defines a memory types "a" and "b" for regions in both
>> +    banks.  The device driver would use those two types then to
>> +    request memory chunks from different banks.  CMA attributes coul=
d
>> +    look as follows:
>> +
>> +         static struct cma_region regions[] =3D {
>> +                 { .name =3D "a", .size =3D 32 << 20 },
>> +                 { .name =3D "b", .size =3D 32 << 20, .start =3D 512=
 << 20 },
>> +                 { }
>> +         }
>> +         static const char map[] __initconst =3D "foo/a=3Da;foo/b=3D=
b;*=3Da,b";
>
> So this would become something like this:
>
>          static struct cma_memtype types[] =3D {
>                  { .name =3D "a", .size =3D 32 << 20 },
>                  { .name =3D "b", .size =3D 32 << 20, .start =3D 512 <=
< 20 },
>                  // For example:
>                  { .name =3D "dma", .gfp =3D GFP_DMA },
>                  { }
>          }
>          static struct cma_region regions[] =3D {
>                  // size may of course be smaller than the memtype siz=
e.
>                  { .name =3D "a", type =3D "a", .size =3D 32 << 20 },
>                  { .name =3D "b", type =3D "b", .size =3D 32 << 20 },
>                  { }
>          }
>          static const char map[] __initconst =3D "*=3Da,b";
>
> No need to do anything special for driver foo here: cma_alloc will pic=
k the
> correct region based on the memory type requested by the driver.
>
> It is probably no longer needed to specify the memory type in the mapp=
ing when
> this is in place.

I'm not entirely happy with such scheme.

For one, types may overlap: ie. the whole "banka" may be "dma" as well.
This means that a single region could be of several different types.

Moreover, as I've mentioned the video coder needs to allocate buffers fr=
om
different banks.  However, on never platform there's only one bank (actu=
ally
two but they are interlaced) so allocations from different banks no long=
er
make sense.  Instead of changing the driver though I'd prefer to only ch=
ange
the mapping in the platform.

-- =

Best regards,                                        _     _
| Humble Liege of Serenely Enlightened Majesty of  o' \,=3D./ `o
| Computer Science,  Micha=C5=82 "mina86" Nazarewicz       (o o)
+----[mina86*mina86.com]---[mina86*jabber.org]----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
