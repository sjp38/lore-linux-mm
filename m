Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3223D6B02D7
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 23:04:44 -0400 (EDT)
Received: by iwn33 with SMTP id 33so1538177iwn.14
        for <linux-mm@kvack.org>; Wed, 25 Aug 2010 20:04:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTinPaq+0MbdW81uoc5_OZ=1Gy_mVYEBnwv8zgOBd@mail.gmail.com>
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
	<1282310110.2605.976.camel@laptop>
	<20100825155814.25c783c7.akpm@linux-foundation.org>
	<20100825173125.0855a6b0@bike.lwn.net>
	<AANLkTinPaq+0MbdW81uoc5_OZ=1Gy_mVYEBnwv8zgOBd@mail.gmail.com>
Date: Thu, 26 Aug 2010 12:04:42 +0900
Message-ID: <AANLkTimofo3WyaWyTCBegVqpzoDLq0NXxC7+JuVPMQGr@mail.gmail.com>
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Nazarewicz <m.nazarewicz@samsung.com>, linux-mm@kvack.org, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Pawel Osciak <p.osciak@samsung.com>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 26, 2010 at 11:49 AM, Minchan Kim <minchan.kim@gmail.com> wrote=
:
> On Thu, Aug 26, 2010 at 8:31 AM, Jonathan Corbet <corbet@lwn.net> wrote:
>> On Wed, 25 Aug 2010 15:58:14 -0700
>> Andrew Morton <akpm@linux-foundation.org> wrote:
>>
>>> > If you want guarantees you can free stuff, why not add constraints to
>>> > the page allocation type and only allow MIGRATE_MOVABLE pages inside =
a
>>> > certain region, those pages are easily freed/moved aside to satisfy
>>> > large contiguous allocations.
>>>
>>> That would be good. =A0Although I expect that the allocation would need
>>> to be 100% rock-solid reliable, otherwise the end user has a
>>> non-functioning device. =A0Could generic core VM provide the required l=
evel
>>> of service?
>>
>> The original OLPC has a camera controller which requires three contiguou=
s,
>> image-sized buffers in memory. =A0That system is a little memory constra=
ined
>> (OK, it's desperately short of memory), so, in the past, the chances of
>> being able to allocate those buffers anytime some kid decides to start
>> taking pictures was poor. =A0Thus, cafe_ccic.c has an option to snag the
>> memory at initialization time and never let go even if you threaten its
>> family. =A0Hell hath no fury like a little kid whose new toy^W education=
al
>> tool stops taking pictures.
>>
>> That, of course, is not a hugely efficient use of memory on a
>> memory-constrained system. =A0If the VM could reliably satisfy those
>> allocation requestss, life would be wonderful. =A0Seems difficult. =A0Bu=
t it
>> would be a nicer solution than CMA, which, to a great extent, is really
>> just a standardized mechanism for grabbing memory and never letting go.
>>
>>> It would help (a lot) if we could get more attention and buyin and
>>> fedback from the potential clients of this code. =A0rmk's feedback is
>>> valuable. =A0Have we heard from the linux-media people? =A0What other
>>> subsystems might use it? =A0ieee1394 perhaps? =A0Please help identify
>>> specific subsystems and I can perhaps help to wake people up.
>>
>> If this code had been present when I did the Cafe driver, I would have u=
sed
>> it. =A0I think it could be made useful to a number of low-end camera dri=
vers
>> if the videobuf layer were made to talk to it in a way which Just Works.
>>
>> With a bit of tweaking, I think it could be made useful in other
>> situations: the viafb driver, for example, really needs an allocator for
>> framebuffer memory and it seems silly to create one from scratch. =A0Of
>> course, there might be other possible solutions, like adding a "zones"
>> concept to LMB^W memblock.
>>
>> The problem which is being addressed here is real.
>>
>> That said, the complexity of the solution still bugs me a bit, and the c=
ore
>> idea is still to take big chunks of memory out of service for specific
>> needs. =A0It would be far better if the VM could just provide big chunks=
 on
>> demand. =A0Perhaps compaction and the pressures of making transparent hu=
ge
>> pages work will get us there, but I'm not sure we're there yet.
>>
>> jon
>
> I agree. compaction and movable zone will be one of good solutions.
>
> If some driver needs big contiguous chunk to work, it should make sure
> to be allowable to have memory size for it before going. To make sure
> it, we have to consider compaction of ZONE_MOVABLE zone. But one of
> problems is anonymous page which can be has a role of pinned page in
> non-swapsystem. Even most of embedded system has no swap.
> But it's not hard to solve it.
>
> We needs Mel's opinion, too.

I elaborates my statement for preventing confusing due to using _pinned pag=
e_.
I means that anon pages isn't not a fragment problem but space problem
for the devices.
It would be better to move the pages into !ZONE_MOVABLE zone.

>
> --
> Kind regards,
> Minchan Kim
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
