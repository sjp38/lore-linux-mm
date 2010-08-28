Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2B6796B01F0
	for <linux-mm@kvack.org>; Sat, 28 Aug 2010 08:37:52 -0400 (EDT)
From: Hans Verkuil <hverkuil@xs4all.nl>
Subject: Re: [PATCH/RFCv4 2/6] mm: cma: Contiguous Memory Allocator added
Date: Sat, 28 Aug 2010 14:37:11 +0200
References: <cover.1282286941.git.m.nazarewicz@samsung.com> <0b02e05fc21e70a3af39e65e628d117cd89d70a1.1282286941.git.m.nazarewicz@samsung.com> <343f4b0edf9b5eef598831700cb459cd428d3f2e.1282286941.git.m.nazarewicz@samsung.com>
In-Reply-To: <343f4b0edf9b5eef598831700cb459cd428d3f2e.1282286941.git.m.nazarewicz@samsung.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Message-Id: <201008281437.11830.hverkuil@xs4all.nl>
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <m.nazarewicz@samsung.com>
Cc: linux-mm@kvack.org, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Jonathan Corbet <corbet@lwn.net>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Pawel Osciak <p.osciak@samsung.com>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Friday, August 20, 2010 11:50:42 Michal Nazarewicz wrote:
> The Contiguous Memory Allocator framework is a set of APIs for
> allocating physically contiguous chunks of memory.
> 
> Various chips require contiguous blocks of memory to operate.  Those
> chips include devices such as cameras, hardware video decoders and
> encoders, etc.
> 
> The code is highly modular and customisable to suit the needs of
> various users.  Set of regions reserved for CMA can be configured
> per-platform and it is easy to add custom allocator algorithms if one
> has such need.
> 
> Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> Reviewed-by: Pawel Osciak <p.osciak@samsung.com>
> ---
>  Documentation/00-INDEX              |    2 +
>  Documentation/contiguous-memory.txt |  541 +++++++++++++++++++++
>  include/linux/cma.h                 |  431 +++++++++++++++++
>  mm/Kconfig                          |   34 ++
>  mm/Makefile                         |    2 +
>  mm/cma-best-fit.c                   |  407 ++++++++++++++++
>  mm/cma.c                            |  910 +++++++++++++++++++++++++++++++++++
>  7 files changed, 2327 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/contiguous-memory.txt
>  create mode 100644 include/linux/cma.h
>  create mode 100644 mm/cma-best-fit.c
>  create mode 100644 mm/cma.c
> 
> diff --git a/Documentation/00-INDEX b/Documentation/00-INDEX
> index 8dfc670..f93e787 100644
> --- a/Documentation/00-INDEX
> +++ b/Documentation/00-INDEX
> @@ -94,6 +94,8 @@ connector/
>  	- docs on the netlink based userspace<->kernel space communication mod.
>  console/
>  	- documentation on Linux console drivers.
> +contiguous-memory.txt
> +	- documentation on physically-contiguous memory allocation framework.
>  cpu-freq/
>  	- info on CPU frequency and voltage scaling.
>  cpu-hotplug.txt
> diff --git a/Documentation/contiguous-memory.txt b/Documentation/contiguous-memory.txt
> new file mode 100644
> index 0000000..8fc2400
> --- /dev/null
> +++ b/Documentation/contiguous-memory.txt
> @@ -0,0 +1,541 @@
> +                                                             -*- org -*-
> +
> +* Contiguous Memory Allocator
> +
> +   The Contiguous Memory Allocator (CMA) is a framework, which allows
> +   setting up a machine-specific configuration for physically-contiguous
> +   memory management. Memory for devices is then allocated according
> +   to that configuration.
> +
> +   The main role of the framework is not to allocate memory, but to
> +   parse and manage memory configurations, as well as to act as an
> +   in-between between device drivers and pluggable allocators. It is
> +   thus not tied to any memory allocation method or strategy.
> +
> +** Why is it needed?
> +
> +    Various devices on embedded systems have no scatter-getter and/or
> +    IO map support and as such require contiguous blocks of memory to
> +    operate.  They include devices such as cameras, hardware video
> +    decoders and encoders, etc.
> +
> +    Such devices often require big memory buffers (a full HD frame is,
> +    for instance, more then 2 mega pixels large, i.e. more than 6 MB
> +    of memory), which makes mechanisms such as kmalloc() ineffective.
> +
> +    Some embedded devices impose additional requirements on the
> +    buffers, e.g. they can operate only on buffers allocated in
> +    particular location/memory bank (if system has more than one
> +    memory bank) or buffers aligned to a particular memory boundary.
> +
> +    Development of embedded devices have seen a big rise recently
> +    (especially in the V4L area) and many such drivers include their
> +    own memory allocation code. Most of them use bootmem-based methods.
> +    CMA framework is an attempt to unify contiguous memory allocation
> +    mechanisms and provide a simple API for device drivers, while
> +    staying as customisable and modular as possible.
> +
> +** Design
> +
> +    The main design goal for the CMA was to provide a customisable and
> +    modular framework, which could be configured to suit the needs of
> +    individual systems.  Configuration specifies a list of memory
> +    regions, which then are assigned to devices.  Memory regions can
> +    be shared among many device drivers or assigned exclusively to
> +    one.  This has been achieved in the following ways:
> +
> +    1. The core of the CMA does not handle allocation of memory and
> +       management of free space.  Dedicated allocators are used for
> +       that purpose.
> +
> +       This way, if the provided solution does not match demands
> +       imposed on a given system, one can develop a new algorithm and
> +       easily plug it into the CMA framework.
> +
> +       The presented solution includes an implementation of a best-fit
> +       algorithm.
> +
> +    2. When requesting memory, devices have to introduce themselves.
> +       This way CMA knows who the memory is allocated for.  This
> +       allows for the system architect to specify which memory regions
> +       each device should use.
> +
> +    3. Memory regions are grouped in various "types".  When device
> +       requests a chunk of memory, it can specify what type of memory
> +       it needs.  If no type is specified, "common" is assumed.
> +
> +       This makes it possible to configure the system in such a way,
> +       that a single device may get memory from different memory
> +       regions, depending on the "type" of memory it requested.  For
> +       example, a video codec driver might want to allocate some
> +       shared buffers from the first memory bank and the other from
> +       the second to get the highest possible memory throughput.
> +
> +    4. For greater flexibility and extensibility, the framework allows
> +       device drivers to register private regions of reserved memory
> +       which then may be used only by them.
> +
> +       As an effect, if a driver would not use the rest of the CMA
> +       interface, it can still use CMA allocators and other
> +       mechanisms.
> +
> +       4a. Early in boot process, device drivers can also request the
> +           CMA framework to a reserve a region of memory for them
> +           which then will be used as a private region.
> +
> +           This way, drivers do not need to directly call bootmem,
> +           memblock or similar early allocator but merely register an
> +           early region and the framework will handle the rest
> +           including choosing the right early allocator.
> +
> +** Use cases
> +
> +    Let's analyse some imaginary system that uses the CMA to see how
> +    the framework can be used and configured.
> +
> +
> +    We have a platform with a hardware video decoder and a camera each
> +    needing 20 MiB of memory in the worst case.  Our system is written
> +    in such a way though that the two devices are never used at the
> +    same time and memory for them may be shared.  In such a system the
> +    following configuration would be used in the platform
> +    initialisation code:
> +
> +        static struct cma_region regions[] = {
> +                { .name = "region", .size = 20 << 20 },
> +                { }
> +        }
> +        static const char map[] __initconst = "video,camera=region";
> +
> +        cma_set_defaults(regions, map);
> +
> +    The regions array defines a single 20-MiB region named "region".
> +    The map says that drivers named "video" and "camera" are to be
> +    granted memory from the previously defined region.
> +
> +    A shorter map can be used as well:
> +
> +        static const char map[] __initconst = "*=region";
> +
> +    The asterisk ("*") matches all devices thus all devices will use
> +    the region named "region".
> +
> +    We can see, that because the devices share the same memory region,
> +    we save 20 MiB, compared to the situation when each of the devices
> +    would reserve 20 MiB of memory for itself.
> +
> +
> +    Now, let's say that we have also many other smaller devices and we
> +    want them to share some smaller pool of memory.  For instance 5
> +    MiB.  This can be achieved in the following way:
> +
> +        static struct cma_region regions[] = {
> +                { .name = "region", .size = 20 << 20 },
> +                { .name = "common", .size =  5 << 20 },
> +                { }
> +        }
> +        static const char map[] __initconst =
> +                "video,camera=region;*=common";
> +
> +        cma_set_defaults(regions, map);
> +
> +    This instructs CMA to reserve two regions and let video and camera
> +    use region "region" whereas all other devices should use region
> +    "common".
> +
> +
> +    Later on, after some development of the system, it can now run
> +    video decoder and camera at the same time.  The 20 MiB region is
> +    no longer enough for the two to share.  A quick fix can be made to
> +    grant each of those devices separate regions:
> +
> +        static struct cma_region regions[] = {
> +                { .name = "v", .size = 20 << 20 },
> +                { .name = "c", .size = 20 << 20 },
> +                { .name = "common", .size =  5 << 20 },
> +                { }
> +        }
> +        static const char map[] __initconst = "video=v;camera=c;*=common";
> +
> +        cma_set_defaults(regions, map);
> +
> +    This solution also shows how with CMA you can assign private pools
> +    of memory to each device if that is required.
> +
> +
> +    Allocation mechanisms can be replaced dynamically in a similar
> +    manner as well. Let's say that during testing, it has been
> +    discovered that, for a given shared region of 40 MiB,
> +    fragmentation has become a problem.  It has been observed that,
> +    after some time, it becomes impossible to allocate buffers of the
> +    required sizes. So to satisfy our requirements, we would have to
> +    reserve a larger shared region beforehand.
> +
> +    But fortunately, you have also managed to develop a new allocation
> +    algorithm -- Neat Allocation Algorithm or "na" for short -- which
> +    satisfies the needs for both devices even on a 30 MiB region.  The
> +    configuration can be then quickly changed to:
> +
> +        static struct cma_region regions[] = {
> +                { .name = "region", .size = 30 << 20, .alloc_name = "na" },
> +                { .name = "common", .size =  5 << 20 },
> +                { }
> +        }
> +        static const char map[] __initconst = "video,camera=region;*=common";
> +
> +        cma_set_defaults(regions, map);
> +
> +    This shows how you can develop your own allocation algorithms if
> +    the ones provided with CMA do not suit your needs and easily
> +    replace them, without the need to modify CMA core or even
> +    recompiling the kernel.
> +
> +** Technical Details
> +
> +*** The attributes
> +
> +    As shown above, CMA is configured by a two attributes: list
> +    regions and map.  The first one specifies regions that are to be
> +    reserved for CMA.  The second one specifies what regions each
> +    device is assigned to.
> +
> +**** Regions
> +
> +     Regions is a list of regions terminated by a region with size
> +     equal zero.  The following fields may be set:
> +
> +     - size       -- size of the region (required, must not be zero)
> +     - alignment  -- alignment of the region; must be power of two or
> +                     zero (optional)

Just wondering: is alignment really needed since we already align to the
PAGE_SIZE? Do you know of hardware with alignment requirements > PAGE_SIZE?

> +     - start      -- where the region has to start (optional)
> +     - alloc_name -- the name of allocator to use (optional)
> +     - alloc      -- allocator to use (optional; and besides
> +                     alloc_name is probably is what you want)

I would make this field internal only. At least for now.

> +
> +     size, alignment and start is specified in bytes.  Size will be
> +     aligned up to a PAGE_SIZE.  If alignment is less then a PAGE_SIZE
> +     it will be set to a PAGE_SIZE.  start will be aligned to
> +     alignment.
> +
> +**** Map
> +
> +     The format of the "map" attribute is as follows:
> +
> +         map-attr      ::= [ rules [ ';' ] ]
> +         rules         ::= rule [ ';' rules ]
> +         rule          ::= patterns '=' regions
> +
> +         patterns      ::= pattern [ ',' patterns ]
> +
> +         regions       ::= REG-NAME [ ',' regions ]
> +                       // list of regions to try to allocate memory
> +                       // from
> +
> +         pattern       ::= dev-pattern [ '/' TYPE-NAME ] | '/' TYPE-NAME
> +                       // pattern request must match for the rule to
> +                       // apply; the first rule that matches is
> +                       // applied; if dev-pattern part is omitted
> +                       // value identical to the one used in previous
> +                       // pattern is assumed.
> +
> +         dev-pattern   ::= PATTERN
> +                       // pattern that device name must match for the
> +                       // rule to apply; may contain question marks
> +                       // which mach any characters and end with an
> +                       // asterisk which match the rest of the string
> +                       // (including nothing).
> +
> +     It is a sequence of rules which specify what regions should given
> +     (device, type) pair use.  The first rule that matches is applied.
> +
> +     For rule to match, the pattern must match (dev, type) pair.
> +     Pattern consist of the part before and after slash.  The first
> +     part must match device name and the second part must match kind.
> +
> +     If the first part is empty, the device name is assumed to match
> +     iff it matched in previous pattern.  If the second part is
> +     omitted it will mach any type of memory requested by device.
> +
> +     Some examples (whitespace added for better readability):
> +
> +         cma_map = foo/quaz = r1;
> +                       // device foo with type == "quaz" uses region r1
> +
> +                   foo/* = r2;     // OR:
> +                   /* = r2;
> +                       // device foo with any other kind uses region r2
> +
> +                   bar = r1,r2;
> +                       // device bar uses region r1 or r2
> +
> +                   baz?/a , baz?/b = r3;
> +                       // devices named baz? where ? is any character
> +                       // with type being "a" or "b" use r3
> +
> +*** The device and types of memory
> +
> +    The name of the device is taken from the device structure.  It is
> +    not possible to use CMA if driver does not register a device
> +    (actually this can be overcome if a fake device structure is
> +    provided with at least the name set).
> +
> +    The type of memory is an optional argument provided by the device
> +    whenever it requests memory chunk.  In many cases this can be
> +    ignored but sometimes it may be required for some devices.

This really should not be optional but compulsory. 'type' has the same function
as the GFP flags with kmalloc. They tell the kernel where the memory should be
allocated. Only if you do not care at all can you pass in NULL. But in almost
all cases the memory should be at least DMA-able (and yes, for a lot of SoCs that
is the same as any memory -- for now).

Memory types should be defined in the platform code. Some can be generic
like 'dma' (i.e. any DMAable memory), 'dma32' (32-bit DMA) and 'common' (any
memory). Others are platform specific like 'banka' and 'bankb'.

A memory type definition can either be a start address/size pair but it can
perhaps also be a GFP type (e.g. .name = "dma32", .gfp = GFP_DMA32).

Regions should be of a single memory type. So when you define the region it
should have a memory type field.

Drivers request memory of whatever type they require. The mapping just maps
one or more regions to the driver and the cma allocator will pick only those
regions with the required type and ignore those that do not match.

> +    For instance, let's say that there are two memory banks and for
> +    performance reasons a device uses buffers in both of them.
> +    Platform defines a memory types "a" and "b" for regions in both
> +    banks.  The device driver would use those two types then to
> +    request memory chunks from different banks.  CMA attributes could
> +    look as follows:
> +
> +         static struct cma_region regions[] = {
> +                 { .name = "a", .size = 32 << 20 },
> +                 { .name = "b", .size = 32 << 20, .start = 512 << 20 },
> +                 { }
> +         }
> +         static const char map[] __initconst = "foo/a=a;foo/b=b;*=a,b";

So this would become something like this:

         static struct cma_memtype types[] = {
                 { .name = "a", .size = 32 << 20 },
                 { .name = "b", .size = 32 << 20, .start = 512 << 20 },
                 // For example:
                 { .name = "dma", .gfp = GFP_DMA },
                 { }
         }
         static struct cma_region regions[] = {
                 // size may of course be smaller than the memtype size.
                 { .name = "a", type = "a", .size = 32 << 20 },
                 { .name = "b", type = "b", .size = 32 << 20 },
                 { }
         }
         static const char map[] __initconst = "*=a,b";

No need to do anything special for driver foo here: cma_alloc will pick the
correct region based on the memory type requested by the driver.

It is probably no longer needed to specify the memory type in the mapping when
this is in place.

> +
> +    And whenever the driver allocated the memory it would specify the
> +    kind of memory:
> +
> +        buffer1 = cma_alloc(dev, "a", 1 << 20, 0);
> +        buffer2 = cma_alloc(dev, "b", 1 << 20, 0);
> +
> +    If it was needed to try to allocate from the other bank as well if
> +    the dedicated one is full, the map attributes could be changed to:
> +
> +         static const char map[] __initconst = "foo/a=a,b;foo/b=b,a;*=a,b";

This would be something for the driver to decide. If the driver can handle
this, then the driver should just try memtype "a" first, and then "b".

> +    On the other hand, if the same driver was used on a system with
> +    only one bank, the configuration could be changed just to:
> +
> +         static struct cma_region regions[] = {
> +                 { .name = "r", .size = 64 << 20 },
> +                 { }
> +         }
> +         static const char map[] __initconst = "*=r";
> +
> +    without the need to change the driver at all.

The only change needed here is that the region gets a '.type = "dma"' specifier
as well.

I think I am otherwise quite happy with this code (as least from the PoV of
v4l). But that 'memory kind' handling never felt like it was handled at the
right level.

Regards,

	Hans

-- 
Hans Verkuil - video4linux developer - sponsored by TANDBERG, part of Cisco

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
