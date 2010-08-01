Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0212E6B02A6
	for <linux-mm@kvack.org>; Sun,  1 Aug 2010 09:26:39 -0400 (EDT)
From: Hans Verkuil <hverkuil@xs4all.nl>
Subject: Re: [PATCHv2 2/4] mm: cma: Contiguous Memory Allocator added
Date: Sun, 1 Aug 2010 15:26:13 +0200
References: <cover.1280151963.git.m.nazarewicz@samsung.com> <201007271827.02606.hverkuil@xs4all.nl> <005801cb2e33$f8dec570$ea9c5050$%szyprowski@samsung.com>
In-Reply-To: <005801cb2e33$f8dec570$ea9c5050$%szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201008011526.13566.hverkuil@xs4all.nl>
Sender: owner-linux-mm@kvack.org
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Michal Nazarewicz <m.nazarewicz@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, 'Hiremath Vaibhav' <hvaibhav@ti.com>, Pawel Osciak <p.osciak@samsung.com>, 'Mark Brown' <broonie@opensource.wolfsonmicro.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'FUJITA Tomonori' <fujita.tomonori@lab.ntt.co.jp>, 'Zach Pfeffer' <zpfeffer@codeaurora.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>
List-ID: <linux-mm.kvack.org>

Hi Marek,

On Wednesday 28 July 2010 11:04:56 Marek Szyprowski wrote:

<snip>

> > There are still desktops in the world, you know :-) It's nice if cma can
> > also be used there. Having a region called 'dma' or something like that
> > would be useful for drivers. And yes, for most embedded systems that would
> > be the equivalent of common memory.
> 
> I really see no problem using CMA on desktops, although in most cases only
> a few drivers will be able to make use of it.

As past maintainer of ivtv I can testify that I know at least one driver that
could definitely benefit from CMA.

> 
> > > > I think that the only thing that you want to set in the kernel params
> > is
> > > > the size of each region.
> > >
> > > Keeping it as a kernel parameter is very handy for development. But I
> > agree
> > > that we might make it dependent on some Kconfig entry. This way a
> > platform
> > > setup code would provide default region description just as an array of
> > the
> > > region structures and we will get rid of the parsing code in the release
> > > versions.
> > 
> > I think that would help, yes.
> > 
> > > > The same with assigning regions to drivers: why would you want to do
> > that?
> > > > The driver should know which regions it can use (with possible
> > fallbacks).
> > >
> > > I'm sorry, but this is again a little 'desktop-centric point-of-view'. On
> > > desktop it is perfectly acceptable to have a separate memory region for
> > each
> > > device. In embedded world memory is a precious resource. Of course we can
> > go
> > > the 'separate memory region for each device' way, but we observed that at
> > > least some memory can be recovered if we decide to share memory regions
> > for
> > > some of the devices.
> > >
> > > Assigning regions to the drivers is a way to describe how memory can be
> > > shared. This is something that is independent from the actual drivers.
> > > Device drivers cannot and mustn't have such knowledge.
> > 
> > You misunderstand me. I wasn't promoting separate memory regions for each
> > device.  Quite the opposite: initially I would make regions shared by default.
> > I actually do not see why device drivers can't have the knowledge to allocate
> > their memory from particular regions. We are talking about embedded systems 
> > where these types of memory allocations tend to be well defined. E.g. the
> > video capture driver needs to allocate X video buffers at boot time. For
> > most devices that will be the dma region, in the case of samsung devices
> > that will be regions for particular memory banks.
> 
> Let me introduce one more example. As you may know we have 3 video-processor
> capture devices (Samsung FIMC) and a hardware codec (like Samsung MFC). FIMC
> can capture video data from camera sensor and accelerate common video
> processing tasks (like up/down scaling and color space conversion). Two FIMC
> and MFC are require for things like HD video encoding or decoding with
> online display/preview. This task require huge video buffers that are
> usually allocated and freed at the same time. The third FIMC can be used for
> gfx acceleration (color space conversion and scaling are quite common tasks
> in GUI). This latter task usually introduces a lot of memory fragmentation,
> as gfx surfaces are usually quite small (definitely smaller than HD frames
> or 8MPix picture from camera). It would be really wise to get that third
> FIMC device to use memory buffer that will be shared with 3D accelerator
> (which has quite similar usage scenarios and suffers from similar memory
> fragmentation).

OK, I understand. And I assume both gfx and 3D acceleration need to use a
specific region? If they can use any type of memory, then this might be more
appropriate for kmalloc and friends.

> > The only time reserving regions for specific devices might be necessary is
> > if you can get memory fragmentation if multiple drivers use the same region.
> > But if drivers just allocate the memory at boot, then shared regions work
> > fine.
> > >
> > > > And it can know that provided regions are setup by the platform code
> > and
> > > > not created dynamically. This will simplify things enormously.
> > > >
> > > > > +    1. The core of the CMA does not handle allocation of memory and
> > > > > +       management of free space.  Dedicated allocators are used for
> > > > > +       that purpose.
> > > > > +
> > > > > +       This way, if the provided solution does not match demands
> > > > > +       imposed on a given system, one can develop a new algorithm
> > and
> > > > > +       easily plug it into the CMA framework.
> > > > > +
> > > > > +       The presented solution includes an implementation of a best-
> > fit
> > > > > +       algorithm.
> > > >
> > > > Again, do we really need user-settable per-region allocators? Just
> > provide
> > > > one with the option to later choose others through the kernel Kconfig
> > files.
> > >
> > > From our experience, yes. Different allocators can cope with different
> > memory
> > > usage scenarios better or worse. This results in higher or lower memory
> > > fragmentation. System use cases are something that kernel or drivers are
> > > definitely not aware, so only user space can tune this parameter to get
> > the
> > > best possible system behavior.
> > 
> > Can you describe some of those usage scenarios? The cases I am familiar
> > with
> > are the standard: 'need to allocate X buffers of Y MB memory each on boot'
> > and these buffers are only freed when the module is unloaded. While you can
> > get fragmentation in that case if you creatively load and unload modules,
> > this is not the normal usage in a deployed system.
> 
> We don't want to allocate X buffers of Y MB memory each on boot. Instead we
> want to just reserve XX MB memory and then dynamically allocate buffers from
> it. This enables us to perform the following 2 tasks:
> 1. movie decoding in HD-quality (only one instance)
> 2. two instances of SD-quality movie decoding and SD-quality move encoding 
>    (example: video conference)
> 
> We know that these two use cases are exclusive, so they can use the same
> reserved memory.

When I said 'allocating X buffers of Y MB memory' I meant that you need to
allocate a known amount of memory (X * Y MB in this case). So the boot args
say e.g. dma=40MB and the driver just allocates X buffers from that region.

Switching to SD quality requires releasing those buffers and instead allocating
a number of smaller buffers from the same region.

For these use-cases the allocator can be very simple and probably covers most
use-cases.

Anyway, I'm no expert on memory allocators and people on the linux-mm list are
no doubt much more qualified to discuss this. My main concern is that of
trying to add too much for a first release. It is simply easier to start simple
and extend as needed. That makes it easier to be accepted in the mainline.

> 
> > We already have several 'normal' memory allocators (slab, slub, slob, sleb,
> > whatever. I've lost track there.) and I'm not very enthusiastic about the
> > idea of adding another bunch of them. Especially not in a first release.
> >
> > Keep it simple. Just fix the core problem first, even if you are not yet
> > able to squeeze the last byte of memory from your system. Later you can 
> > always add features as needed and optimize it further.
> 
> We are trying to keep it as simple as possible :)
>  
> > > > We can always add more complex scenarios later, but for an initial
> > version
> > > > I'd keep it simple.
> > > >
> > > > > +
> > > > > +    2. CMA allows a run-time configuration of the memory regions it
> > > > > +       will use to allocate chunks of memory from.  The set of
> > memory
> > > > > +       regions is given on command line so it can be easily changed
> > > > > +       without the need for recompiling the kernel.
> > > > > +
> > > > > +       Each region has it's own size, alignment demand, a start
> > > > > +       address (physical address where it should be placed) and an
> > > > > +       allocator algorithm assigned to the region.
> > > > > +
> > > > > +       This means that there can be different algorithms running at
> > > > > +       the same time, if different devices on the platform have
> > > > > +       distinct memory usage characteristics and different algorithm
> > > > > +       match those the best way.
> > > >
> > > > Seems overengineering to me. Just ensure that the code can be extended
> > > > later to such hypothetical scenarios. They are hypothetical, right?
> > >
> > > Not really. Having the possibility to reconfigure memory configuration
> > > without kernel recompilation is very handy when one is tuning the
> > > configuration for the specific use case.
> > >
> > > > > +    3. When requesting memory, devices have to introduce themselves.
> > > > > +       This way CMA knows who the memory is allocated for.  This
> > > > > +       allows for the system architect to specify which memory
> > regions
> > > > > +       each device should use.
> > > > > +
> > > > > +       3a. Devices can also specify a "kind" of memory they want.
> > > > > +           This makes it possible to configure the system in such
> > > > > +           a way, that a single device may get memory from different
> > > > > +           memory regions, depending on the "kind" of memory it
> > > > > +           requested.  For example, a video codec driver might want
> > to
> > > > > +           allocate some shared buffers from the first memory bank
> > and
> > > > > +           the other from the second to get the highest possible
> > > > > +           memory throughput.
> > > >
> > > > Not sure I understand this. Isn't this just two regions, one for each
> > > > memory bank,
> > > > and the driver requests some buffers from one region and some from the
> > > > other?
> > >
> > > Right.
> > >
> > > > Not sure how a 'kind of memory' features in this.
> > >
> > > This 'kind' is a just cookie or a label used by the driver to distinguish
> > > requests for both memory banks. This functionality is essential for our
> > > hardware (just for hardware video codec we have 3 'kinds' of memory:
> > memory
> > > bank A, memory bank B and special region for the firmware).
> > 
> > Let me see if I understand: driver D needs memory from bank A, so it
> > specifies
> > e.g. label "a" when requesting memory. And the kernel parameters are then
> > supposed
> > to define a region for memory bank A (say region "bank-a" and tell the cma
> > that
> > requests from driver D for memory of kind "a" should go to region "bank-a".
> > 
> > Of course, the driver can also just request memory from the platform-
> > defined
> > region "bank-a" directly rather than having to rely on userspace provided
> > parameters.
> 
> Right. Regions provided by kernel command line are considered to be alternative
> to the default configuration for tuning/debugging purposes.
> 
> > > > > +    4. For greater flexibility and extensibility, the framework
> > allows
> > > > > +       device drivers to register private regions of reserved memory
> > > > > +       which then may be used only by them.
> > > > > +
> > > > > +       As an effect, if a driver would not use the rest of the CMA
> > > > > +       interface, it can still use CMA allocators and other
> > > > > +       mechanisms.
> > > >
> > > > Why would you? Is there an actual driver that will need this?
> > >
> > > This feature has been added after posting v1 of this rfc/patch. Jonathan
> > > Corbet suggested in
> > <http://article.gmane.org/gmane.linux.kernel.mm/50689>
> > > that viafb driver might register its own private memory and use cma just
> > > as an allocator. IMHO this is a good idea, this way we might remove a
> > bunch
> > > of custom allocators from the drivers (yes, there are such all over the
> > > kernel).
> > 
> > It goes back to whether we want per-device (or per-driver) regions or just
> > have global regions.
> 
> IMHO both types of regions can coexist and we can make use of their
> advantages. I see no point in limiting CMA only to one type of the regions.
> 
> > What I have seen in practice is that these drivers just
> > need X amount of contiguous memory on boot. Having just a single region (as
> > it will be for most systems) to carve the buffers from is just as efficient
> > if not more than creating separate regions for each driver. Only if you
> > start freeing and reallocating memory later on will you get into trouble.
> 
> > But if you do that, then you are trying to duplicate the behavior of the
> > normal allocators in my opinion. I really don't think we want to go there.
> 
> Well, then why some drivers like viafb or omapfb have custom memory
> allocators? This case shows that there is still a need for another one.

I have no idea why they have allocators. Someone would have to analyze that
code. Just because they use allocators doesn't necessarily mean that they
really need them :-)

> 
> > > > > +       4a. Early in boot process, device drivers can also request
> > the
> > > > > +           CMA framework to a reserve a region of memory for them
> > > > > +           which then will be used as a private region.
> > > > > +
> > > > > +           This way, drivers do not need to directly call bootmem,
> > > > > +           memblock or similar early allocator but merely register
> > an
> > > > > +           early region and the framework will handle the rest
> > > > > +           including choosing the right early allocator.
> > > >
> > > > The whole concept of private regions seems unnecessary to me.
> > > >
> > > > <big snip>
> > > >
> > > > It looks to me as if you tried to think of all possible hypothetical
> > > > situations
> > > > and write a framework for that. Of course, you may know more than I do,
> > > > and some of these situations actually happen.
> > >
> > > Not exactly. We tried to design a solution that would cover all
> > requirements
> > > for OUR (quite specific) embedded hardware. However we didn't want to tie
> > it
> > > only to our platform. We just generalized most of our requirements so
> > they can
> > > be reused for other systems.
> > >
> > > > The basic design ideas are solid, I think. But you should get rid of
> > all
> > > > the fancy features and go back to basics. We can always add those
> > features
> > > > later should that become necessary. But removing features is much, much
> > > harder.
> > >
> > > Well, please keep in mind that we cannot remove features that are
> > essential
> > > for our solution. We know that a simple framework have some advantages
> > > (well, the most important one is the fact that it is easy to understand),
> > > but making it too simple would render it useless from our point of view
> > > (if it would not provide functionality required by our drivers and
> > hardware).
> > 
> > Why not give a list of the requirements that your hardware has? The only
> > requirement unique to your hardware that I am aware of is the need for
> > buffers in specific memory banks (and apparently a special memory area for
> > firmware).
> 
> Yes, this is a real hardware requirement that cannot be dropped. Other
> requirements come from the system design (software).
> 
> > So besides a 'dma' region (which is probably sufficient for most systems)
> > you would also have a 'banka' and 'bankb' region and perhaps a 'fw' region.
> 
> Actually this DMA region is either just a 'banka' or 'bankb'. There is no
> special requirements for the common dma memory and no need for the separate
> 'dma' region in our case. We just want to make it shared with at least camera
> capture buffers.
> 
> > In the kernel parameters the user can specify the sizes for these regions
> > that are reserved at boot time and drivers will use cma to get their memory
> > from the relevant region using a simple allocator.
> > 
> > If there are other requirements in your hardware (or other hardware) that
> > should be taken into account for an initial version of the cma, then I'm
> > interested in hearing about it.
> 
> We will try to summarize our requirements again and repost them soon.
>  
> > One note: since the first version of the patch wasn't posted to linux-media
> > I didn't follow the replies to that. If there are things in that thread
> > that I should read, then just mail me some links.
> 
> I'm very sorry that the first version has been posted only to linux-mm.
> The discussion was mainly about the way how the memory configuration and
> device mapping should be provided (first version used only kernel parameters
> for that). We should probably also CC a few more kernel subsystems that might
> benefit from a common memory allocator, but we already were a bit scared by
> the number of people and lists in this series. We really don't want to get
> a 'spammer' label ;)

You probably got the main interested parties now.

Regarding regions and shared and per-driver buffers: I've been thinking about this
a bit more and I have a proposal of my own.

There are two different aspects to this: first there is the hardware aspect: if
the hardware needs memory from specific memory banks or with specific requirements
(e.g. DMAable), then those regions should be setup in the platform code. There you
know the memory sizes/alignments/etc. since that is hw dependent. The other reason
is that drivers need to be able to tell CMA that they need to allocate from such
regions. You can't have a driver refer to a region that is specified through
kernel parameters, that would create a very ugly dependency.

The other aspect is how to setup buffers. A global buffer is simply setup by
assigning a size to the region: "banka=20MB". Unless specified otherwise any
driver that needs memory from banka will use that global banka buffer.

Alternatively, you can set aside memory from a region specifically for drivers:
banka/foo=30MB. This allocated 30 MB from region banka specifically for driver foo.

You can also share that with another driver:

banka/foo,bar=30MB

Now this 30 MB buffer is shared between drivers foo and bar.

The nice thing about this is that the driver will still only refer to region
banka as setup by the platform code.

And in the more general case you can have two standard regions: dma and common.
So drivers can rely on the presence of a dma region when allocating buffers.

What would make this even better is that CMA has the option to try and allocate
additional memory on the fly if its memory pool becomes empty. E.g. if the dma
pool is full, then it can try to do a kmalloc(..., GFP_KERNEL | __GFP_DMA).

This allows you to setup the dma and common regions with size 0. So allocating
from the dma region would effectively be the same as doing a kmalloc. Unless
the user sets up a dma area in the kernel parameters.

Obviously this is probably impossible if you need memory from specific memory
banks, so this is something that is not available for every region.

The nice thing about this is that it is very flexible for end users. For example,
most users of the ivtv driver wouldn't have to do anything since most of the time
it is able to assign the necessary buffers. But some users have multiple ivtv-based
capture boards in their PC, and then it can become harder to have ivtv obtain the
needed buffers. In that case they can preallocate the buffers by setting
dma/ivtv=500MB or something like that.

That would be a really nice feature...

Regards,

	Hans

-- 
Hans Verkuil - video4linux developer - sponsored by TANDBERG, part of Cisco

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
