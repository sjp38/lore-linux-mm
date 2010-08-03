Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4AB3F6008E4
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 03:14:19 -0400 (EDT)
From: Hans Verkuil <hverkuil@xs4all.nl>
Subject: Re: [PATCHv2 2/4] mm: cma: Contiguous Memory Allocator added
Date: Tue, 3 Aug 2010 09:19:36 +0200
References: <cover.1280151963.git.m.nazarewicz@samsung.com> <201008011526.13566.hverkuil@xs4all.nl> <op.vgticdzj7p4s8u@pikus>
In-Reply-To: <op.vgticdzj7p4s8u@pikus>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201008030919.36575.hverkuil@xs4all.nl>
Sender: owner-linux-mm@kvack.org
To: =?utf-8?q?Micha=C5=82_Nazarewicz?= <m.nazarewicz@samsung.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Jonathan Corbet' <corbet@lwn.net>, Pawel Osciak <p.osciak@samsung.com>, 'Mark Brown' <broonie@opensource.wolfsonmicro.com>, linux-kernel@vger.kernel.org, 'Hiremath Vaibhav' <hvaibhav@ti.com>, 'FUJITA Tomonori' <fujita.tomonori@lab.ntt.co.jp>, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Zach Pfeffer' <zpfeffer@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Monday 02 August 2010 17:51:39 Micha=C5=82 Nazarewicz wrote:

<snip>

> >> We don't want to allocate X buffers of Y MB memory each on boot. Inste=
ad we
> >> want to just reserve XX MB memory and then dynamically allocate buffer=
s from
> >> it. This enables us to perform the following 2 tasks:
> >> 1. movie decoding in HD-quality (only one instance)
> >> 2. two instances of SD-quality movie decoding and SD-quality move enco=
ding
> >>    (example: video conference)
> >>
> >> We know that these two use cases are exclusive, so they can use the sa=
me
> >> reserved memory.
>=20
> > When I said 'allocating X buffers of Y MB memory' I meant that you need=
 to
> > allocate a known amount of memory (X * Y MB in this case). So the boot =
args
> > say e.g. dma=3D40MB and the driver just allocates X buffers from that r=
egion.
>=20
> But the point is that driver does not allocate memory at boot time.  If v=
ideo
> codec would allocate memory at boot time no one else could use it even if=
 the
> codec is not used.  The idea is to make other devices use the memory when
> codec is idle.  For instance, one could work on huge JPEG images and need
> buffers for a hardware JPEG codec.
>=20
> Or have I misunderstood your point?

I think we are talking about the same thing. A region like dma=3D40MB would=
 be
shared by all drivers that want to allocate from it.
=20
> > Switching to SD quality requires releasing those buffers and instead al=
locating
> > a number of smaller buffers from the same region.
>=20
> Our intention is that driver would allocate buffers only when needed so t=
he buffers
> would be freed when video codec driver is released.  So when the device i=
s opened
> (whatever that would mean for a particular device) it would allocate enou=
gh memory
> for the requested task.

Right.

> > For these use-cases the allocator can be very simple and probably cover=
s most
> > use-cases.
>=20
> Yes, this is our experience.  The best-fit algorithm, even though simple,=
 seem to
> handle use cases tested on our system with little fragmentation.

That's what I expected as well.

> > Anyway, I'm no expert on memory allocators and people on the linux-mm l=
ist are
> > no doubt much more qualified to discuss this. My main concern is that of
> > trying to add too much for a first release. It is simply easier to star=
t simple
> > and extend as needed. That makes it easier to be accepted in the mainli=
ne.
>=20
> I'm trying to keep it as simple as possible :) still making it useful for=
 us.
>=20
> In particular we need a way to specify where different regions reside (di=
fferent
> memory banks, etc.) as well as specify which drivers should use which reg=
ions.
> What's more, we need the notion of a "kind" of memory as one driver may n=
eed
> memory buffers from different regions (ie. MFC needs to allocate buffers =
from
> both banks).
>=20
> >>>>>> +    2. CMA allows a run-time configuration of the memory regions =
it
> >>>>>> +       will use to allocate chunks of memory from.  The set of me=
mory
> >>>>>> +       regions is given on command line so it can be easily chang=
ed
> >>>>>> +       without the need for recompiling the kernel.
> >>>>>> +
> >>>>>> +       Each region has it's own size, alignment demand, a start
> >>>>>> +       address (physical address where it should be placed) and an
> >>>>>> +       allocator algorithm assigned to the region.
> >>>>>> +
> >>>>>> +       This means that there can be different algorithms running =
at
> >>>>>> +       the same time, if different devices on the platform have
> >>>>>> +       distinct memory usage characteristics and different algori=
thm
> >>>>>> +       match those the best way.
>=20
> >>>>> Seems overengineering to me. Just ensure that the code can be exten=
ded
> >>>>> later to such hypothetical scenarios. They are hypothetical, right?
>=20
> 1. Everyone seem to hate the command line interface that was present in t=
he
>     first and second version of the patch.  As such, I've made it optional
>     (via Kconfig option) in the third version (not posted yet), which
>     unfortunately makes platform initialisation code longer and more
>     complicated but hopefully more people will be happy. ;)

I strongly recommend that it is simple dropped from the first version. That
will increase the chances of getting it merged. And once merged, interfaces
like this can be discussed at leisure.
=20
> 2. We need to specify size, alignment and start address so those are not
>     hypothetical.

Agreed. But this is platform code, you should not have to pass this info
through boot args.
=20
> 3. The algorithms are somehow hypothetical (we haven't tried using a diff=
erent
>     allocator as of you) but I think it's much easier to design the whole=
 system
>     with them in mind and implement them in the first version then later =
add code
>     for them.

I agree with that as long as the extra code needed to do so it within limit=
s.
I've seen too often that people design for a future that never happens. That
leads to code that is never used and will make it hard to future generations
of developers to figure out what the purpose was of that code.

<snip>

> > Regarding regions and shared and per-driver buffers: I've been thinking=
 about
> > this a bit more and I have a proposal of my own.
> >
> > There are two different aspects to this: first there is the hardware as=
pect: if
> > the hardware needs memory from specific memory banks or with specific r=
equirements
> > (e.g. DMAable), then those regions should be setup in the platform code=
=2E There you
> > know the memory sizes/alignments/etc. since that is hw dependent. The o=
ther reason
> > is that drivers need to be able to tell CMA that they need to allocate =
from such
> > regions.  You can't have a driver refer to a region that is specified t=
hrough
> > kernel parameters, that would create a very ugly dependency.
> >
> > The other aspect is how to setup buffers. A global buffer is simply set=
up by
> > assigning a size to the region: "banka=3D20MB". Unless specified otherw=
ise any
> > driver that needs memory from banka will use that global banka buffer.
> >
> > Alternatively, you can set aside memory from a region specifically for =
drivers:
> > banka/foo=3D30MB. This allocated 30 MB from region banka specifically f=
or driver foo.
> >
> > You can also share that with another driver:
> >
> > banka/foo,bar=3D30MB
> >
> > Now this 30 MB buffer is shared between drivers foo and bar.
>=20
> Let me rephrase it to see if I got it correct:
>=20
> You propose that platform will define what types of memory it has.  For i=
nstance
> banka for a the first bank, bankb for the second memory bank, dma for DMA=
=2Dable
> memory, etc.  Those definitions would be merely informative and by themse=
lves
> they would not reserve any memory.

Right. It might be an option that they do reserve a minimal amount of memor=
y.
If you know that you always need at least X MB of memory to get the system
running, then that might be useful.
=20
> Later, it would be possible to specify regions of memory of those types. =
 For
> instance:
>=20
>    banka=3D20M; banka/foo,bar=3D30M
>=20
> would register two regions in the memory type "banka" such that the first=
 is 20 MiB
> and used by all drivers expect for driver foo and bar which would use the=
 second
> region of 30 MiB?

Right.
=20
> > The nice thing about this is that the driver will still only refer to r=
egion
> > banka as setup by the platform code.
>=20
> So the driver would request a memory type "banka" and then get a chunk fr=
om one of
> the abovementioned regions?

Right.
=20
> I somehow like the simplicity of that but I see some disadvantages:
>=20
> 1. Imagine a video decoder which for best performance should operate on s=
ome buffers
>     from the first and some buffers from the second bank.  However, if th=
e buffers are
>     from the incorrect bank it will still work, only slower.  In such sit=
uations you
>     cannot specify that when driver foo requests memory type "banka" then=
 it should
>     first try memory type "banka" but if allocation failed there try "ban=
kb".

Not quite sure I understand the problem here. Isn't that something for the =
driver to
decide? If it can only work with buffers from banka, then it will just fail=
 if it
cannot allocate the required buffers. On the other hand, if it can also wor=
k with
buffers from bankb if banka is full, then it can just use bankb as fallback.

This type of behavior is very much driver specific and as such should be do=
ne by
the driver and not through user supplied kernel parameters IMHO.
=20
> 2. What if the device handled by the above driver were run on a platform =
with only
>     one memory bank?  The driver would still refer to "banka" and "bankb"=
 but there
>     would be no such types in the system.

=46irst of all, any driver that needs specific memory banks is highly platf=
orm
specific and is extremely unlikely to work anywhere else.

But this can also handled in the driver itself. Either through config #ifde=
fs or
by using e.g. a dma region as fallback.

> 3. What if there were one driver, initially written for platform X which =
used names
>     "banka" and "bankb", and another driver, initially written for platfo=
rm Y which
>     used names "bank1" and "bank2".  How would you make them work on a si=
ngle platform
>     with two memory banks?

Sorry, I don't understand the question. I think I would refer to my answer =
to the
previous question, but I'm not sure if that covers this.
=20
> 4. This is hypothetical, but the "kind" defined by CMA could be used to s=
pecify
>     characteristics that are not hardware dependent.  For instance some d=
river
>     could use kind "bulk" for some big, several MiB buffers and "control"=
 for
>     small less then MiB buffers.  Regions for those kinds could be of the=
 same
>     type of memory but it could be valuable splitting those to two region=
s to
>     minimise fragmentation.

That's actually a good point. I can imagine this.

I would not implement this for a first version. But one way this could be d=
one is
by something like this:

dma/foo(kind)=3D20MB where '(kind)' is optional. The big problem I have wit=
h this
is that this means that you need to know what 'kinds' of memory a particular
driver needs.

This can always be added later. For an initial release I wouldn't do this.
=20
> > And in the more general case you can have two standard regions: dma and=
 common.
> > So drivers can rely on the presence of a dma region when allocating buf=
fers.
>=20
> I think that driver should not care about or know region names at all.

A region is very similar to the last argument to kmalloc. And drivers most =
definitely
need to know about regions, just like they need to specify the correct GFP =
flags.

In fact, it's the only thing that need to know.
=20
> > What would make this even better is that CMA has the option to try and =
allocate
> > additional memory on the fly if its memory pool becomes empty. E.g. if =
the dma
> > pool is full, then it can try to do a kmalloc(..., GFP_KERNEL | __GFP_D=
MA).
>=20
> As I've said somewhere above, I was thinking about something like it.

Cool.
=20
> > This allows you to setup the dma and common regions with size 0. So all=
ocating
> > from the dma region would effectively be the same as doing a kmalloc. U=
nless
> > the user sets up a dma area in the kernel parameters.
> >
> > Obviously this is probably impossible if you need memory from specific =
memory
> > banks, so this is something that is not available for every region.
> >
> > The nice thing about this is that it is very flexible for end users. Fo=
r example,
> > most users of the ivtv driver wouldn't have to do anything since most o=
f the time
> > it is able to assign the necessary buffers. But some users have multipl=
e ivtv-based
> > capture boards in their PC, and then it can become harder to have ivtv =
obtain the
> > needed buffers. In that case they can preallocate the buffers by setting
> > dma/ivtv=3D500MB or something like that.
> >
> > That would be a really nice feature...
>=20
> I think the main difference between your proposal and what is in CMA is t=
hat you
> propose that platform define types of memory and later on user will be ab=
le to
> define regions of given type of memory.  This means that drivers would ha=
ve to
> be aware of the names of the types and specify the type name witch each a=
llocation.
>=20
> The CMA solution however, lets drivers define their own kinds of memory a=
nd later
> on platform initialisation code map drivers with their kinds to regions.
>=20
> Have I got it right?

I think so, yes. The disadvantage of the CMA solution is that if you have a=
 number
of drivers, each with their own kinds of memory, you get very complex mappi=
ngs. And
remember that these drivers are not limited to the hardware inside the SoC,=
 but can
also include e.g. USB drivers. You can't predict what USB device the end us=
er will
connect to the device, so you would have to be able to handle any mapping t=
hat any
USB driver might need.

I really think this is the wrong approach.

Regards,

	Hans

=2D-=20
Hans Verkuil - video4linux developer - sponsored by TANDBERG, part of Cisco

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
