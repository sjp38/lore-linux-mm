Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CF5256B0085
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 10:58:28 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from spt2.w1.samsung.com ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LC500IKW31DR120@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 19 Nov 2010 15:58:26 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LC5001VQ31BFX@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 19 Nov 2010 15:58:24 +0000 (GMT)
Date: Fri, 19 Nov 2010 16:58:02 +0100
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [RFCv6 04/13] mm: cma: Contiguous Memory Allocator added
In-reply-to: <cover.1290172312.git.m.nazarewicz@samsung.com>
Message-id: 
 <00538563eadd424c95d00c2f2f6d68c244c0f704.1290172312.git.m.nazarewicz@samsung.com>
References: <cover.1290172312.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: mina86@mina86.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Bryan Huntsman <bryanh@codeaurora.org>, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Johan Mossberg <johan.xx.mossberg@stericsson.com>, Jonathan Corbet <corbet@lwn.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Marcus LORENTZON <marcus.xm.lorentzon@stericsson.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <pawel@osciak.com>, Russell King <linux@arm.linux.org.uk>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, dipankar@in.ibm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The Contiguous Memory Allocator framework is a set of APIs for
allocating physically contiguous chunks of memory.

Various chips require contiguous blocks of memory to operate.  Those
chips include devices such as cameras, hardware video decoders and
encoders, etc.

The code is highly modular and customisable to suit the needs of
various users.  Set of regions reserved for CMA can be configured
per-platform and it is easy to add custom allocator algorithms if one
has such need.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 Documentation/00-INDEX              |    2 +
 Documentation/contiguous-memory.txt |  573 +++++++++++++++++++++
 include/linux/cma.h                 |  488 ++++++++++++++++++
 mm/Kconfig                          |   41 ++
 mm/Makefile                         |    1 +
 mm/cma.c                            |  933 +++++++++++++++++++++++++++++++++++
 6 files changed, 2038 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/contiguous-memory.txt
 create mode 100644 include/linux/cma.h
 create mode 100644 mm/cma.c

diff --git a/Documentation/00-INDEX b/Documentation/00-INDEX
index 8dfc670..f93e787 100644
--- a/Documentation/00-INDEX
+++ b/Documentation/00-INDEX
@@ -94,6 +94,8 @@ connector/
 	- docs on the netlink based userspace<->kernel space communication mod.
 console/
 	- documentation on Linux console drivers.
+contiguous-memory.txt
+	- documentation on physically-contiguous memory allocation framework.
 cpu-freq/
 	- info on CPU frequency and voltage scaling.
 cpu-hotplug.txt
diff --git a/Documentation/contiguous-memory.txt b/Documentation/contiguous-memory.txt
new file mode 100644
index 0000000..f1715ba
--- /dev/null
+++ b/Documentation/contiguous-memory.txt
@@ -0,0 +1,573 @@
+                                                             -*- org -*-
+
+* Contiguous Memory Allocator
+
+   The Contiguous Memory Allocator (CMA) is a framework, which allows
+   setting up a machine-specific configuration for physically-contiguous
+   memory management. Memory for devices is then allocated according
+   to that configuration.
+
+   The main role of the framework is not to allocate memory, but to
+   parse and manage memory configurations, as well as to act as an
+   in-between between device drivers and pluggable allocators. It is
+   thus not tied to any memory allocation method or strategy.
+
+** Why is it needed?
+
+    Various devices on embedded systems have no scatter-getter and/or
+    IO map support and as such require contiguous blocks of memory to
+    operate.  They include devices such as cameras, hardware video
+    decoders and encoders, etc.
+
+    Such devices often require big memory buffers (a full HD frame is,
+    for instance, more then 2 mega pixels large, i.e. more than 6 MB
+    of memory), which makes mechanisms such as kmalloc() ineffective.
+
+    Some embedded devices impose additional requirements on the
+    buffers, e.g. they can operate only on buffers allocated in
+    particular location/memory bank (if system has more than one
+    memory bank) or buffers aligned to a particular memory boundary.
+
+    Development of embedded devices have seen a big rise recently
+    (especially in the V4L area) and many such drivers include their
+    own memory allocation code. Most of them use bootmem-based methods.
+    CMA framework is an attempt to unify contiguous memory allocation
+    mechanisms and provide a simple API for device drivers, while
+    staying as customisable and modular as possible.
+
+** Design
+
+    The main design goal for the CMA was to provide a customisable and
+    modular framework, which could be configured to suit the needs of
+    individual systems.  Configuration specifies a list of memory
+    regions, which then are assigned to devices.  Memory regions can
+    be shared among many device drivers or assigned exclusively to
+    one.  This has been achieved in the following ways:
+
+    1. The core of the CMA does not handle allocation of memory and
+       management of free space.  Dedicated allocators are used for
+       that purpose.
+
+       This way, if the provided solution does not match demands
+       imposed on a given system, one can develop a new algorithm and
+       easily plug it into the CMA framework.
+
+    2. When requesting memory, devices have to introduce themselves.
+       This way CMA knows who the memory is allocated for.  This
+       allows for the system architect to specify which memory regions
+       each device should use.
+
+    3. Memory regions are grouped in various "types".  When device
+       requests a chunk of memory, it can specify what type of memory
+       it needs.  If no type is specified, "common" is assumed.
+
+       This makes it possible to configure the system in such a way,
+       that a single device may get memory from different memory
+       regions, depending on the "type" of memory it requested.  For
+       example, a video codec driver might want to allocate some
+       shared buffers from the first memory bank and the other from
+       the second to get the highest possible memory throughput.
+
+    4. For greater flexibility and extensibility, the framework allows
+       device drivers to register private regions of reserved memory
+       which then may be used only by them.
+
+       As an effect, if a driver would not use the rest of the CMA
+       interface, it can still use CMA allocators and other
+       mechanisms.
+
+       4a. Early in boot process, device drivers can also request the
+           CMA framework to a reserve a region of memory for them
+           which then will be used as a private region.
+
+           This way, drivers do not need to directly call bootmem,
+           memblock or similar early allocator but merely register an
+           early region and the framework will handle the rest
+           including choosing the right early allocator.
+
+    5. Even though memory region is allocated it can be moved around
+       unless driver pins it.  This makes it possible to develop
+       a defragmentation scheme which would move buffers around when
+       they are not used by hardware at given moment.
+
+** Use cases
+
+    Let's analyse some imaginary system that uses the CMA to see how
+    the framework can be used and configured.
+
+
+    We have a platform with a hardware video decoder and a camera each
+    needing 20 MiB of memory in the worst case.  Our system is written
+    in such a way though that the two devices are never used at the
+    same time and memory for them may be shared.  In such a system the
+    following configuration would be used in the platform
+    initialisation code:
+
+        static struct cma_region regions[] = {
+                CMA_REGION("region", 20 << 20, 0, 0),
+                { }
+        }
+        static const char map[] __initconst = "video,camera=region";
+
+        cma_set_defaults(regions, map);
+
+    The regions array defines a single 20-MiB region named "region".
+    The map says that drivers named "video" and "camera" are to be
+    granted memory from the previously defined region.
+
+    A shorter map can be used as well:
+
+        static const char map[] __initconst = "*=region";
+
+    The asterisk ("*") matches all devices thus all devices will use
+    the region named "region".
+
+    We can see, that because the devices share the same memory region,
+    we save 20 MiB, compared to the situation when each of the devices
+    would reserve 20 MiB of memory for itself.
+
+
+    Now, let's say that we have also many other smaller devices and we
+    want them to share some smaller pool of memory.  For instance 5
+    MiB.  This can be achieved in the following way:
+
+        static struct cma_region regions[] = {
+                CMA_REGION("region", 20 << 20, 0, 0),
+                CMA_REGION("common",  5 << 20, 0, 0),
+                { }
+        }
+        static const char map[] __initconst =
+                "video,camera=region;*=common";
+
+        cma_set_defaults(regions, map);
+
+    This instructs CMA to reserve two regions and let video and camera
+    use region "region" whereas all other devices should use region
+    "common".
+
+
+    Later on, after some development of the system, it can now run
+    video decoder and camera at the same time.  The 20 MiB region is
+    no longer enough for the two to share.  A quick fix can be made to
+    grant each of those devices separate regions:
+
+        static struct cma_region regions[] = {
+                CMA_REGION("v",      20 << 20, 0, 0),
+                CMA_REGION("c",      20 << 20, 0, 0),
+                CMA_REGION("common",  5 << 20, 0, 0),
+                { }
+        }
+        static const char map[] __initconst = "video=v;camera=c;*=common";
+
+        cma_set_defaults(regions, map);
+
+    This solution also shows how with CMA you can assign private pools
+    of memory to each device if that is required.
+
+
+    Allocation mechanisms can be replaced dynamically in a similar
+    manner as well. Let's say that during testing, it has been
+    discovered that, for a given shared region of 40 MiB,
+    fragmentation has become a problem.  It has been observed that,
+    after some time, it becomes impossible to allocate buffers of the
+    required sizes. So to satisfy our requirements, we would have to
+    reserve a larger shared region beforehand.
+
+    But fortunately, you have also managed to develop a new allocation
+    algorithm -- Neat Allocation Algorithm or "na" for short -- which
+    satisfies the needs for both devices even on a 30 MiB region.  The
+    configuration can be then quickly changed to:
+
+        static struct cma_region regions[] = {
+                CMA_REGION("region", 30 << 20, 0, 0, .alloc_name = "na"),
+                CMA_REGION("common",  5 << 20, 0, 0),
+                { }
+        }
+        static const char map[] __initconst = "video,camera=region;*=common";
+
+        cma_set_defaults(regions, map);
+
+    This shows how you can develop your own allocation algorithms if
+    the ones provided with CMA do not suit your needs and easily
+    replace them, without the need to modify CMA core or even
+    recompiling the kernel.
+
+** Technical Details
+
+*** The attributes
+
+    As shown above, CMA is configured by a two attributes: list
+    regions and map.  The first one specifies regions that are to be
+    reserved for CMA.  The second one specifies what regions each
+    device is assigned to.
+
+**** Regions
+
+     Regions is a list of regions terminated by a region with size
+     equal zero.  The following fields may be set:
+
+     - size       -- size of the region (required, must not be zero)
+     - alignment  -- alignment of the region; must be power of two or
+                     zero (optional)
+     - start      -- where the region has to start (optional)
+     - alloc_name -- the name of allocator to use (optional)
+     - alloc      -- allocator to use (optional; and besides
+                     alloc_name is probably is what you want)
+
+     size, alignment and start is specified in bytes.  Size will be
+     aligned up to a PAGE_SIZE.  If alignment is less then a PAGE_SIZE
+     it will be set to a PAGE_SIZE.  start will be aligned to
+     alignment.
+
+**** Map
+
+     The format of the "map" attribute is as follows:
+
+         map-attr      ::= [ rules [ ';' ] ]
+         rules         ::= rule [ ';' rules ]
+         rule          ::= patterns '=' regions
+
+         patterns      ::= pattern [ ',' patterns ]
+
+         regions       ::= REG-NAME [ ',' regions ]
+                       // list of regions to try to allocate memory
+                       // from
+
+         pattern       ::= dev-pattern [ '/' TYPE-NAME ] | '/' TYPE-NAME
+                       // pattern request must match for the rule to
+                       // apply; the first rule that matches is
+                       // applied; if dev-pattern part is omitted
+                       // value identical to the one used in previous
+                       // pattern is assumed.
+
+         dev-pattern   ::= PATTERN
+                       // pattern that device name must match for the
+                       // rule to apply; may contain question marks
+                       // which mach any characters and end with an
+                       // asterisk which match the rest of the string
+                       // (including nothing).
+
+     It is a sequence of rules which specify what regions should given
+     (device, type) pair use.  The first rule that matches is applied.
+
+     For rule to match, the pattern must match (dev, type) pair.
+     Pattern consist of the part before and after slash.  The first
+     part must match device name and the second part must match kind.
+
+     If the first part is empty, the device name is assumed to match
+     iff it matched in previous pattern.  If the second part is
+     omitted it will mach any type of memory requested by device.
+
+     Some examples (whitespace added for better readability):
+
+         cma_map = foo/quaz = r1;
+                       // device foo with type == "quaz" uses region r1
+
+                   foo/* = r2;     // OR:
+                   /* = r2;
+                       // device foo with any other kind uses region r2
+
+                   bar = r1,r2;
+                       // device bar uses region r1 or r2
+
+                   baz?/a , baz?/b = r3;
+                       // devices named baz? where ? is any character
+                       // with type being "a" or "b" use r3
+
+*** The device and types of memory
+
+    The name of the device is taken from the device structure.  It is
+    not possible to use CMA if driver does not register a device
+    (actually this can be overcome if a fake device structure is
+    provided with at least the name set).
+
+    The type of memory is an optional argument provided by the device
+    whenever it requests memory chunk.  In many cases this can be
+    ignored but sometimes it may be required for some devices.
+
+    For instance, let's say that there are two memory banks and for
+    performance reasons a device uses buffers in both of them.
+    Platform defines a memory types "a" and "b" for regions in both
+    banks.  The device driver would use those two types then to
+    request memory chunks from different banks.  CMA attributes could
+    look as follows:
+
+         static struct cma_region regions[] = {
+                 CMA_REGION("a", 32 << 20, 0, 0),
+                 CMA_REGION("b", 32 << 20, 0, 512 << 20),
+                 { }
+         }
+         static const char map[] __initconst = "foo/a=a;foo/b=b;*=a,b";
+
+    And whenever the driver allocated the memory it would specify the
+    kind of memory:
+
+        buffer1 = cma_alloc(dev, "a", 1 << 20, 0);
+        buffer2 = cma_alloc(dev, "b", 1 << 20, 0);
+
+    If it was needed to try to allocate from the other bank as well if
+    the dedicated one is full, the map attributes could be changed to:
+
+         static const char map[] __initconst = "foo/a=a,b;foo/b=b,a;*=a,b";
+
+    On the other hand, if the same driver was used on a system with
+    only one bank, the configuration could be changed just to:
+
+         static struct cma_region regions[] = {
+                 CMA_REGION("r", 64 << 20, 0, 0),
+                 { }
+         }
+         static const char map[] __initconst = "*=r";
+
+    without the need to change the driver at all.
+
+*** Device API
+
+    There are three basic calls provided by the CMA framework to
+    devices.  To allocate a chunk of memory cma_alloc() function needs
+    to be used:
+
+        const struct cma *
+        cma_alloc(const struct device *dev, const char *type,
+                  size_t size, unsigned long alignment);
+
+    If required, device may specify alignment in bytes that the chunk
+    need to satisfy.  It have to be a power of two or zero.  The
+    chunks are always aligned at least to a page.
+
+    The type specifies the type of memory as described to in the
+    previous subsection.  If device driver does not care about memory
+    type it can safely pass NULL as the type which is the same as
+    possing "common".
+
+    The basic usage of the function is just a:
+
+        chunk = cma_alloc(dev, NULL, size, 0);
+
+    The function returns a pointer to an opaque structure (not really
+    opaque, its definition is in the header, but from device's point
+    of view it is opaque, ie. device must never touch it's internals).
+    On error an error-pointer is returned, so the correct way for
+    checking for errors is:
+
+        const struct cma *chunk = cma_alloc(dev, NULL, size, 0);
+        if (IS_ERR(chunk))
+                /* Error */
+                return PTR_ERR(chunk);
+        /* Allocated */
+
+    (Make sure to include <linux/err.h> which contains the definition
+    of the IS_ERR() and PTR_ERR() macros.)
+
+
+    Allocated chunk is freed via a cma_free() function:
+
+        void cma_free(const struct cma *chunk);
+
+
+    To use the chunk device must first pin it with the call to
+    cma_pin() function:
+
+        void cma_pin(const struct cma *chunk);
+
+ .  Once chunk is pinned, its physical address may be queried with the
+    call to cma_phys() function:
+
+        phys_addr_t vcm_phys(const struct cma *chunk);
+
+    If device no longer needs the chunk to stay in the same place in
+    memory (but, obviously, requires its content not to be lost), it
+    should unpin the chunk with the call to cma_unpin():
+
+        void cma_unpin(const struct cma *chunk);
+
+    Unpinned chunks may be subject to defragmentation and they can be
+    moved around by the allocator as to join several small free areas
+    into one bigger (you know what defragmentation is about).
+
+
+    The last function is the cma_info() which returns information
+    about regions assigned to given (dev, type) pair.  Its syntax is:
+
+        int cma_info(struct cma_info *info,
+                     const struct device *dev,
+                     const char *type);
+
+    On successful exit it fills the info structure with lower and
+    upper bound of regions, total size and number of regions assigned
+    to given (dev, type) pair.
+
+**** Dynamic and private regions
+
+     In the basic setup, regions are provided and initialised by
+     platform initialisation code (which usually use
+     cma_set_defaults() for that purpose).
+
+     It is, however, possible to create and add regions dynamically
+     using cma_region_register() function.
+
+         int cma_region_register(struct cma_region *reg);
+
+     The region does not have to have name.  If it does not, it won't
+     be accessed via standard mapping (the one provided with map
+     attribute).  Such regions are private and to allocate chunk from
+     them, one needs to call:
+
+         const struct cma *
+         cma_alloc_from_region(struct cma_region *reg,
+                               size_t size, unsigned long alignment);
+
+     It is just like cma_alloc() expect one specifies what region to
+     allocate memory from.  The region must have been registered.
+
+**** Allocating from region specified by name
+
+     If a driver preferred allocating from a region or list of regions
+     it knows name of it can use a different call simmilar to the
+     previous:
+
+         const struct cma *
+         cma_alloc_from(const char *regions,
+                        size_t size, unsigned long alignment);
+
+     The first argument is a comma-separated list of regions the
+     driver desires CMA to try and allocate from.  The list is
+     terminated by a NUL byte or a semicolon.
+
+     Similarly, there is a call for requesting information about named
+     regions:
+
+        int cma_info_about(struct cma_info *info, const char *regions);
+
+     Generally, it should not be needed to use those interfaces but
+     they are provided nevertheless.
+
+**** Registering early regions
+
+     An early region is a region that is managed by CMA early during
+     boot process.  It's platforms responsibility to reserve memory
+     for early regions.  Later on, when CMA initialises, early regions
+     with reserved memory are registered as normal regions.
+     Registering an early region may be a way for a device to request
+     a private pool of memory without worrying about actually
+     reserving the memory:
+
+         int cma_early_region_register(struct cma_region *reg);
+
+     This needs to be done quite early on in boot process, before
+     platform traverses the cma_early_regions list to reserve memory.
+
+     When boot process ends, device driver may see whether the region
+     was reserved (by checking reg->reserved flag) and if so, whether
+     it was successfully registered as a normal region (by checking
+     the reg->registered flag).  If that is the case, device driver
+     can use normal API calls to use the region.
+
+*** Allocator operations
+
+    Creating an allocator for CMA needs four functions to be
+    implemented.
+
+
+    The first two are used to initialise an allocator for given driver
+    and clean up afterwards:
+
+        int  cma_foo_init(struct cma_region *reg);
+        void cma_foo_cleanup(struct cma_region *reg);
+
+    The first is called when allocator is attached to region.  When
+    the function is called, the cma_region structure is fully
+    initialised (ie. starting address and size have correct values).
+    As a meter of fact, allocator should never modify the cma_region
+    structure other then the private_data field which it may use to
+    point to it's private data.
+
+    The second call cleans up and frees all resources the allocator
+    has allocated for the region.  The function can assume that all
+    chunks allocated form this region have been freed thus the whole
+    region is free.
+
+
+    Two other calls are used for allocating and freeing chunks.  They
+    are:
+
+        struct cma *
+        cma_foo_alloc(struct cma_region *reg,
+                      size_t size, unsigned long alignment);
+        void cma_foo_free(struct cma *chunk);
+
+    As names imply the first allocates a chunk and the other frees
+    a chunk of memory.  The first one must also initialise size and
+    phys fields of the returned structure; On error, it must return an
+    error-pointer.
+
+
+    If allocator support pinning chunks, it needs to implement two
+    more functions:
+
+        void cma_foo_pin(struct cma *chunk);
+        void cma_foo_unpin(struct cma *chunk);
+
+    Among other things that depend on internal allocator pinning
+    implementation, the first function must also update the phys field
+    of the object pointed by chunk.
+
+
+    Any of the above four functions may assume that it is the only
+    thread accessing the region.  Therefore, allocator does not need
+    to worry about concurrency.  Moreover, all arguments are
+    guaranteed to be valid (i.e. page aligned size, a power of two
+    alignment no lower the a page size).
+
+
+    When allocator is ready, all that is left is to register it by
+    calling cma_allocator_register() function:
+
+            int cma_allocator_register(struct cma_allocator *alloc);
+
+    The argument is an structure with pointers to the above functions
+    and allocator's name.  The whole call may look something like
+    this:
+
+        static struct cma_allocator alloc = {
+                .name    = "foo",
+                .init    = cma_foo_init,
+                .cleanup = cma_foo_cleanup,
+                .alloc   = cma_foo_alloc,
+                .free    = cma_foo_free,
+                .pin     = cma_foo_pin,    /* optional */
+                .unpin   = cma_foo_unpin,  /* optional */
+        };
+        return cma_allocator_register(&alloc);
+
+    The name ("foo") will be used when a this particular allocator is
+    requested as an allocator for given region.
+
+*** Integration with platform
+
+    There is one function that needs to be called form platform
+    initialisation code.  That is the cma_early_regions_reserve()
+    function:
+
+        void cma_early_regions_reserve(int (*reserve)(struct cma_region *reg));
+
+    It traverses list of all of the early regions provided by platform
+    and registered by drivers and reserves memory for them.  The only
+    argument is a callback function used to reserve the region.
+    Passing NULL as the argument is the same as passing
+    cma_early_region_reserve() function which uses bootmem and
+    memblock for allocating.
+
+    Alternatively, platform code could traverse the cma_early_regions
+    list by itself but this should never be necessary.
+
+
+    Platform has also a way of providing default attributes for CMA,
+    cma_set_defaults() function is used for that purpose:
+
+        int cma_set_defaults(struct cma_region *regions, const char *map)
+
+    It needs to be called prior to reserving regions.  It let one
+    specify the list of regions defined by platform and the map
+    attribute.  The map may point to a string in __initdata.  See
+    above in this document for example usage of this function.
diff --git a/include/linux/cma.h b/include/linux/cma.h
new file mode 100644
index 0000000..a6031a7
--- /dev/null
+++ b/include/linux/cma.h
@@ -0,0 +1,488 @@
+#ifndef __LINUX_CMA_H
+#define __LINUX_CMA_H
+
+/*
+ * Contiguous Memory Allocator framework
+ * Copyright (c) 2010 by Samsung Electronics.
+ * Written by Michal Nazarewicz (m.nazarewicz@samsung.com)
+ */
+
+/*
+ * See Documentation/contiguous-memory.txt for details.
+ */
+
+/***************************** Kernel level API *****************************/
+
+#if defined __KERNEL__ && defined CONFIG_CMA
+
+#include <linux/rbtree.h>
+#include <linux/list.h>
+#include <linux/init.h>
+#include <linux/errno.h>
+#include <linux/err.h>
+
+
+struct device;
+struct cma_info;
+
+/**
+ * struct cma - an allocated contiguous chunk of memory.
+ * @phys:	Chunk's physical address in bytes.
+ * @size:	Chunk's size in bytes.
+ * @pinned:	Number of times chunk has been pinned.
+ * @reg:	Region this chunk belongs to.
+ *
+ * Fields of this structure should never be accessed directly by
+ * anything other than CMA core and allocators.
+ *
+ * Normal code should use cma_pin(), cma_unpin(), cma_phys(),
+ * cma_size() and cma_free() functions when dealing with struct cma.
+ *
+ * Allocator must fill the @size and @phys fields when chunk is
+ * created.  If driver support pinning, @phys may be initialised as
+ * zero and updated by pin operation; unpin may then again set it to
+ * zero.
+ */
+struct cma {
+	phys_addr_t phys;
+	size_t size;
+	unsigned pinned;
+	struct cma_region *reg;
+};
+
+/*
+ * Don't call it directly, use cma_alloc(), cma_alloc_from() or
+ * cma_alloc_from_region().
+ */
+const struct cma *__must_check
+__cma_alloc(const struct device *dev, const char *type,
+	    size_t size, unsigned long alignment);
+
+/* Don't call it directly, use cma_info() or cma_info_about(). */
+int
+__cma_info(struct cma_info *info, const struct device *dev, const char *type);
+
+
+/**
+ * cma_alloc() - allocates contiguous chunk of memory.
+ * @dev:	The device to perform allocation for.
+ * @type:	A type of memory to allocate.  Platform may define
+ *		several different types of memory and device drivers
+ *		can then request chunks of different types.  Usually it's
+ *		safe to pass NULL here which is the same as passing
+ *		"common".
+ * @size:	Size of the memory to allocate in bytes.
+ * @alignment:	Desired alignment in bytes.  Must be a power of two or
+ *		zero.  If alignment is less then a page size it will be
+ *		set to page size. If unsure, pass zero here.
+ *
+ * On error returns a pointer-error.  Otherwise struct cma is returned
+ * which can be used with other CMA functions.
+ */
+static inline const struct cma *__must_check
+cma_alloc(const struct device *dev, const char *type,
+	  size_t size, unsigned long alignment)
+{
+	return dev ? __cma_alloc(dev, type, size, alignment) : ERR_PTR(-EINVAL);
+}
+
+/**
+ * cma_free() - frees a chunk of memory.
+ * @chunk:	Chunk to free.  This must be a structure returned by
+ *		cma_alloc() (or family).  This may be NULL.
+ */
+void cma_free(const struct cma *chunk);
+
+/**
+ * cma_pin() - pins a chunk of memory.
+ * @chunk:	Chunk to pin.
+ *
+ * Pinned chunk is one that cannot move in memory.  Device drivers
+ * must pin chunk before they start using it.  If chunk is unpinned it
+ * can be subject to memory defragmentation which in effect means that
+ * the chunk will change its address.
+ *
+ * In particular, if a device driver unpins memory chunk it must assume
+ * that previously used memory address is no longer valid.
+ *
+ * To unpin a function driver shall use cma_unpin() function.
+ *
+ * Chunk may be pinned several times.  Each call to cma_pin() must be
+ * paired with a call to cma_unpin() and only the last one will really
+ * unpin the chunk.
+ *
+ * Returns chunk's physical address.
+ */
+phys_addr_t cma_pin(const struct cma *chunk);
+
+/**
+ * cma_unpin() - unpins a chunk of memory.
+ * @chunk:	Chunk to unpin.
+ *
+ * See cma_pin().
+ */
+void cma_unpin(const struct cma *chunk);
+
+/**
+ * cma_phys() - returns chunk's physical address in bytes.
+ * @chunk:	Chunk to query information about.
+ *
+ * Chunk must be pinned.  Chunk must be pinned.
+ */
+static inline phys_addr_t cma_phys(const struct cma *chunk) {
+#ifdef CONFIG_CMA_DEBUG
+	WARN_ON(!chunk->pinned);
+#endif
+	return chunk->phys;
+}
+
+/**
+ * cma_size() - returns chunk's size in bytes.
+ * @chunk:	Chunk to query information about.
+ */
+static inline size_t cma_size(const struct cma *chunk) {
+	return chunk->size;
+}
+
+/**
+ * struct cma_info - information about regions returned by cma_info().
+ * @lower_bound:	The smallest address that is possible to be
+ *			allocated for given (dev, type) pair.
+ * @upper_bound:	The one byte after the biggest address that is
+ *			possible to be allocated for given (dev, type)
+ *			pair.
+ * @total_size:	Total size of regions mapped to (dev, type) pair.
+ * @free_size:	Total free size in all of the regions mapped to (dev, type)
+ *		pair.  Because of possible race conditions, it is not
+ *		guaranteed that the value will be correct -- it gives only
+ *		an approximation.
+ * @count:	Number of regions mapped to (dev, type) pair.
+ */
+struct cma_info {
+	phys_addr_t lower_bound, upper_bound;
+	size_t total_size, free_size;
+	unsigned count;
+};
+
+/**
+ * cma_info - queries information about regions.
+ * @info:	Pointer to a structure where to save the information.
+ * @dev:	The device to query information for.
+ * @type:	A type of memory to query information for.
+ *		If unsure, pass NULL here which is equal to passing
+ *		"common".
+ *
+ * On error returns a negative error, zero otherwise.
+ */
+static inline int
+cma_info(struct cma_info *info, const struct device *dev, const char *type)
+{
+	return dev ? __cma_info(info, dev, type) : -EINVAL;
+}
+
+
+/****************************** Lower lever API *****************************/
+
+/**
+ * cma_alloc_from - allocates contiguous chunk of memory from named regions.
+ * @regions:	Comma separated list of region names.  Terminated by NUL
+ *		byte or a semicolon.
+ * @size:	Size of the memory to allocate in bytes.
+ * @alignment:	Desired alignment in bytes.  Must be a power of two or
+ *		zero.  If alignment is less then a page size it will be
+ *		set to page size. If unsure, pass zero here.
+ *
+ * On error returns a pointer-error.  Otherwise struct cma is returned
+ * holding information about allocated chunk.
+ */
+static inline const struct cma *__must_check
+cma_alloc_from(const char *regions, size_t size, unsigned long alignment)
+{
+	return __cma_alloc(NULL, regions, size, alignment);
+}
+
+/**
+ * cma_info_about - queries information about named regions.
+ * @info:	Pointer to a structure where to save the information.
+ * @regions:	Comma separated list of region names.  Terminated by NUL
+ *		byte or a semicolon.
+ *
+ * On error returns a negative error, zero otherwise.
+ */
+static inline int
+cma_info_about(struct cma_info *info, const const char *regions)
+{
+	return __cma_info(info, NULL, regions);
+}
+
+struct cma_allocator;
+
+/**
+ * struct cma_region - a region reserved for CMA allocations.
+ * @name:	Unique name of the region.  Read only.
+ * @start:	physical address of the region in bytes.
+ * @size:	size of the region in bytes.
+ * @free_space:	Free space in the region.  Read only.
+ * @alignment:	Desired alignment of the region in bytes.  A power of two,
+ *		always at least page size.  Early.
+ * @alloc:	Allocator used with this region.  On error an error-pointer
+ *		should be returned.  Private.
+ * @alloc_name:	Allocator name read from cmdline.  Private.  This may be
+ *		different from @alloc->name.
+ * @private_data:	Allocator's private data.
+ * @users:	Number of chunks allocated in this region.
+ * @list:	Entry in list of regions.  Private.
+ * @used:	Whether region was already used, ie. there was at least
+ *		one allocation request for.  Private.
+ * @registered:	Whether this region has been registered.  Read only.
+ * @reserved:	Whether this region has been reserved.  Early.  Read only.
+ * @copy_name:	Whether @name and @alloc_name needs to be copied when
+ *		this region is converted from early to normal.  Early.
+ *		Private.
+ * @free_alloc_name:	Whether @alloc_name was kmalloced().  Private.
+ * @use_isolate:	Whether to use MIGRATE_CMA. Private.
+ *
+ * Regions come in two types: an early region and normal region.  The
+ * former can be reserved or not-reserved.  Fields marked as "early"
+ * are only meaningful in early regions.
+ *
+ * Early regions are important only during initialisation.  The list
+ * of early regions is built from the "cma" command line argument or
+ * platform defaults.  Platform initialisation code is responsible for
+ * reserving space for unreserved regions that are placed on
+ * cma_early_regions list.
+ *
+ * Later, during CMA initialisation all reserved regions from the
+ * cma_early_regions list are registered as normal regions and can be
+ * used using standard mechanisms.
+ */
+struct cma_region {
+	const char *name;
+	phys_addr_t start;
+	size_t size;
+	union {
+		size_t free_space;		/* Normal region */
+		unsigned long alignment;	/* Early region */
+	};
+
+	struct cma_allocator *alloc;
+	const char *alloc_name;
+	void *private_data;
+
+#ifdef CONFIG_CMA_USE_MIGRATE_CMA
+	unsigned short *isolation_map;
+#endif
+
+	unsigned users;
+	struct list_head list;
+
+	unsigned used:1;
+	unsigned registered:1;
+	unsigned reserved:1;
+	unsigned copy_name:1;
+	unsigned free_alloc_name:1;
+	unsigned use_isolate:1;
+};
+
+/**
+ * CMA_REGION() - helper macro for defining struct cma_region objects.
+ * @name:	 name of te structure.
+ * @_size:	size of the structure in bytes.
+ * @_alignment:	desired alignment of the region in bytes, must be power
+ *		of two or zero.
+ * @_start:	desired starting address of the region, may be zero.
+ * @rest:	any additional initializers.
+ */
+#define CMA_REGION(name, _size, _alignment, _start, rest...) {	\
+		(name),						\
+		.start = (_start),				\
+		.size = (_size),				\
+		{ .alignment = (_alignment) },			\
+		rest						\
+	}
+
+/**
+ * cma_region_register() - registers a region.
+ * @reg:	Region to register.
+ *
+ * Region's start and size must be set.
+ *
+ * If name is set the region will be accessible using normal mechanism
+ * like mapping or cma_alloc_from() function otherwise it will be
+ * a private region and accessible only using the
+ * cma_alloc_from_region() function.
+ *
+ * If alloc is set function will try to initialise given allocator
+ * (and will return error if it failes).  Otherwise alloc_name may
+ * point to a name of an allocator to use (if not set, the default
+ * will be used).
+ *
+ * All other fields are ignored and/or overwritten.
+ *
+ * Returns zero or negative error.  In particular, -EADDRINUSE if
+ * region overlap with already existing region.
+ */
+int __must_check cma_region_register(struct cma_region *reg);
+
+/**
+ * cma_alloc_from_region() - allocates contiguous chunk of memory from region.
+ * @reg:	Region to allocate chunk from.
+ * @size:	Size of the memory to allocate in bytes.
+ * @alignment:	Desired alignment in bytes.  Must be a power of two or
+ *		zero.  If alignment is less then a page size it will be
+ *		set to page size. If unsure, pass zero here.
+ *
+ * On error returns a pointer-error.  Otherwise struct cma is returned
+ * holding information about allocated chunk.
+ */
+const struct cma *__must_check
+cma_alloc_from_region(struct cma_region *reg,
+		      size_t size, unsigned long alignment);
+
+
+
+/****************************** Allocators API ******************************/
+
+/**
+ * struct cma_allocator - a CMA allocator.
+ * @name:	Allocator's unique name
+ * @init:	Initialises an allocator on given region.
+ * @cleanup:	Cleans up after init.  May assume that there are no chunks
+ *		allocated in given region.
+ * @alloc:	Allocates a chunk of memory of given size in bytes and
+ *		with given alignment.  Alignment is a power of
+ *		two (thus non-zero) and callback does not need to check it.
+ *		May also assume that it is the only call that uses given
+ *		region (ie. access to the region is synchronised with
+ *		a mutex).  This has to allocate the chunk object (it may be
+ *		embeded in a bigger structure with allocator-specific data.
+ *		Required.
+ * @free:	Frees allocated chunk.  May also assume that it is the only
+ *		call that uses given region.  This has to free() the chunk
+ *		object as well.  Required.
+ * @pin:	Pins chunk.  Optional.
+ * @unpin:	Unpins chunk.  Optional.
+ * @list:	Entry in list of allocators.  Private.
+ *
+ * Allocator has to initialise the size fields of struct cma in alloc
+ * and correctly manage the its phys field.  size field may be more
+ * then requested in alloc call.  If allocator supports pinning alloc
+ * may initialise phys to zero but it then has to be updated when pin
+ * is called.
+ */
+struct cma_allocator {
+	const char *name;
+
+	int (*init)(struct cma_region *reg);
+	void (*cleanup)(struct cma_region *reg);
+	struct cma *(*alloc)(struct cma_region *reg, size_t size,
+			     unsigned long alignment);
+	void (*free)(struct cma *chunk);
+	void (*pin)(struct cma *chunk);
+	void (*unpin)(struct cma *chunk);
+
+	struct list_head list;
+};
+
+/**
+ * cma_allocator_register() - Registers an allocator.
+ * @alloc:	Allocator to register.
+ *
+ * Adds allocator to the list of allocators managed by CMA.
+ *
+ * All of the fields of cma_allocator structure must be set except for
+ * the optional name and the list's head which will be overriden
+ * anyway.
+ *
+ * Returns zero or negative error code.
+ */
+int cma_allocator_register(struct cma_allocator *alloc);
+
+
+/**************************** Initialisation API ****************************/
+
+/**
+ * cma_set_defaults() - specifies default command line parameters.
+ * @regions:	A zero-sized entry terminated list of early regions.
+ *		This array must not be placed in __initdata section.
+ * @map:	Map attribute.
+ *
+ * This function should be called prior to cma_early_regions_reserve()
+ * and after early parameters have been parsed.
+ *
+ * Returns zero or negative error.
+ */
+int __init cma_set_defaults(struct cma_region *regions, const char *map);
+
+/**
+ * cma_early_regions - a list of early regions.
+ *
+ * Platform needs to allocate space for each of the region before
+ * initcalls are executed.  If space is reserved, the reserved flag
+ * must be set.  Platform initialisation code may choose to use
+ * cma_early_regions_allocate().
+ *
+ * Later, during CMA initialisation all reserved regions from the
+ * cma_early_regions list are registered as normal regions and can be
+ * used using standard mechanisms.
+ */
+extern struct list_head cma_early_regions __initdata;
+
+/**
+ * cma_early_region_register() - registers an early region.
+ * @reg:	Region to add.
+ *
+ * Region's size, start and alignment must be set (however the last
+ * two can be zero).  If name is set the region will be accessible
+ * using normal mechanism like mapping or cma_alloc_from() function
+ * otherwise it will be a private region accessible only using the
+ * cma_alloc_from_region().
+ *
+ * During platform initialisation, space is reserved for early
+ * regions.  Later, when CMA initialises, the early regions are
+ * "converted" into normal regions.  If cma_region::alloc is set, CMA
+ * will then try to setup given allocator on the region.  Failure to
+ * do so will result in the region not being registered even though
+ * the space for it will still be reserved.  If cma_region::alloc is
+ * not set, allocator will be attached to the region on first use and
+ * the value of cma_region::alloc_name will be taken into account if
+ * set.
+ *
+ * All other fields are ignored and/or overwritten.
+ *
+ * Returns zero or negative error.  No checking if regions overlap is
+ * performed.
+ */
+int __init __must_check cma_early_region_register(struct cma_region *reg);
+
+/**
+ * cma_early_region_reserve() - reserves a physically contiguous memory region.
+ * @reg:	Early region to reserve memory for.
+ *
+ * If platform supports bootmem this is the first allocator this
+ * function tries to use.  If that failes (or bootmem is not
+ * supported) function tries to use memblec if it is available.
+ *
+ * On success sets reg->reserved flag.
+ *
+ * Returns zero or negative error.
+ */
+int __init cma_early_region_reserve(struct cma_region *reg);
+
+/**
+ * cma_early_regions_reserve() - helper function for reserving early regions.
+ * @reserve:	Callbac function used to reserve space for region.  Needs
+ *		to return non-negative if allocation succeeded, negative
+ *		error otherwise.  NULL means cma_early_region_alloc() will
+ *		be used.
+ *
+ * This function traverses the %cma_early_regions list and tries to
+ * reserve memory for each early region.  It uses the @reserve
+ * callback function for that purpose.  The reserved flag of each
+ * region is updated accordingly.
+ */
+void __init cma_early_regions_reserve(int (*reserve)(struct cma_region *reg));
+
+#endif
+
+#endif
diff --git a/mm/Kconfig b/mm/Kconfig
index b911ad3..c7eb1bc 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -331,3 +331,44 @@ config CLEANCACHE
 	  in a negligible performance hit.
 
 	  If unsure, say Y to enable cleancache
+
+config CMA
+	bool "Contiguous Memory Allocator framework"
+	# Currently there is only one allocator so force it on
+	select CMA_GENERIC_ALLOCATOR
+	help
+	  This enables the Contiguous Memory Allocator framework which
+	  allows drivers to allocate big physically-contiguous blocks of
+	  memory for use with hardware components that do not support I/O
+	  map nor scatter-gather.
+
+	  If you select this option you will also have to select at least
+	  one allocator algorithm below.
+
+	  To make use of CMA you need to specify the regions and
+	  driver->region mapping on command line when booting the kernel.
+
+	  For more information see <Documentation/contiguous-memory.txt>.
+	  If unsure, say "n".
+
+config CMA_DEBUG
+	bool "CMA debug messages (DEVELOPEMENT)"
+	depends on CMA
+	help
+	  Turns on debug messages in CMA.  This produces KERN_DEBUG
+	  messages for every CMA call as well as various messages while
+	  processing calls such as cma_alloc().  This option does not
+	  affect warning and error messages.
+
+	  This is mostly used during development.  If unsure, say "n".
+
+config CMA_GENERIC_ALLOCATOR
+	bool "CMA generic allocator"
+	depends on CMA
+	select GENERIC_ALLOCATOR
+	help
+	  This is an allocator that uses a generic allocator API provided
+	  by kernel.  The generic allocator can use either of two
+	  implementations: the first-fit, bitmap-based algorithm or
+	  a best-fit, red-black tree-based algorithm.  The algorithm can
+	  be changed under "Library routines".
diff --git a/mm/Makefile b/mm/Makefile
index 0b08d1c..c6a84f1 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -43,3 +43,4 @@ obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
 obj-$(CONFIG_CLEANCACHE) += cleancache.o
+obj-$(CONFIG_CMA) += cma.o
diff --git a/mm/cma.c b/mm/cma.c
new file mode 100644
index 0000000..17276b3
--- /dev/null
+++ b/mm/cma.c
@@ -0,0 +1,933 @@
+/*
+ * Contiguous Memory Allocator framework
+ * Copyright (c) 2010 by Samsung Electronics.
+ * Written by Michal Nazarewicz (m.nazarewicz@samsung.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of the
+ * License or (at your optional) any later version of the license.
+ */
+
+/*
+ * See Documentation/contiguous-memory.txt for details.
+ */
+
+#define pr_fmt(fmt) "cma: " fmt
+
+#ifdef CONFIG_CMA_DEBUG
+#  define DEBUG
+#endif
+
+#ifndef CONFIG_NO_BOOTMEM
+#  include <linux/bootmem.h>   /* alloc_bootmem_pages_nopanic() */
+#endif
+#ifdef CONFIG_HAVE_MEMBLOCK
+#  include <linux/memblock.h>  /* memblock*() */
+#endif
+#include <linux/device.h>      /* struct device, dev_name() */
+#include <linux/errno.h>       /* Error numbers */
+#include <linux/err.h>         /* IS_ERR, PTR_ERR, etc. */
+#include <linux/mm.h>          /* PAGE_ALIGN() */
+#include <linux/module.h>      /* EXPORT_SYMBOL_GPL() */
+#include <linux/mutex.h>       /* mutex */
+#include <linux/slab.h>        /* kmalloc() */
+#include <linux/string.h>      /* str*() */
+#include <linux/genalloc.h>    /* gen_pool_*() */
+
+#include <linux/cma.h>
+
+
+/* Protects cma_regions, cma_allocators, cma_map and cma_map_length. */
+static DEFINE_MUTEX(cma_mutex);
+
+
+/************************* Map attribute *************************/
+
+static const char *cma_map;
+static size_t cma_map_length;
+
+/*
+ * map-attr      ::= [ rules [ ';' ] ]
+ * rules         ::= rule [ ';' rules ]
+ * rule          ::= patterns '=' regions
+ * patterns      ::= pattern [ ',' patterns ]
+ * regions       ::= REG-NAME [ ',' regions ]
+ * pattern       ::= dev-pattern [ '/' TYPE-NAME ] | '/' TYPE-NAME
+ *
+ * See Documentation/contiguous-memory.txt for details.
+ */
+static ssize_t cma_map_validate(const char *param)
+{
+	const char *ch = param;
+
+	if (*ch == '\0' || *ch == '\n')
+		return 0;
+
+	for (;;) {
+		const char *start = ch;
+
+		while (*ch && *ch != '\n' && *ch != ';' && *ch != '=')
+			++ch;
+
+		if (*ch != '=' || start == ch) {
+			pr_err("map: expecting \"<patterns>=<regions>\" near %s\n",
+			       start);
+			return -EINVAL;
+		}
+
+		while (*++ch != ';')
+			if (*ch == '\0' || *ch == '\n')
+				return ch - param;
+		if (ch[1] == '\0' || ch[1] == '\n')
+			return ch - param;
+		++ch;
+	}
+}
+
+static int __init cma_map_param(char *param)
+{
+	ssize_t len;
+
+	pr_debug("param: map: %s\n", param);
+
+	len = cma_map_validate(param);
+	if (len < 0)
+		return len;
+
+	cma_map = param;
+	cma_map_length = len;
+	return 0;
+}
+
+
+/************************* Early regions *************************/
+
+struct list_head cma_early_regions __initdata =
+	LIST_HEAD_INIT(cma_early_regions);
+
+
+int __init __must_check cma_early_region_register(struct cma_region *reg)
+{
+	unsigned long alignment;
+	phys_addr_t start;
+	size_t size;
+
+	if (reg->alignment & (reg->alignment - 1))
+		return -EINVAL;
+
+	alignment = max(reg->alignment, (unsigned long)PAGE_SIZE);
+	start     = ALIGN(reg->start, alignment);
+	size      = PAGE_ALIGN(reg->size);
+
+	if (start + size < start)
+		return -EINVAL;
+
+	reg->size      = size;
+	reg->start     = start;
+	reg->alignment = alignment;
+
+	list_add_tail(&reg->list, &cma_early_regions);
+
+	pr_debug("param: registering early region %s (%p@%p/%p)\n",
+		 reg->name, (void *)reg->size, (void *)reg->start,
+		 (void *)reg->alignment);
+
+	return 0;
+}
+
+
+/************************* Regions & Allocators *************************/
+
+static int __cma_region_attach_alloc(struct cma_region *reg);
+
+/* List of all regions.  Named regions are kept before unnamed. */
+static LIST_HEAD(cma_regions);
+
+#define cma_foreach_region(reg) \
+	list_for_each_entry(reg, &cma_regions, list)
+
+int __must_check cma_region_register(struct cma_region *reg)
+{
+	const char *name, *alloc_name;
+	struct cma_region *r;
+	char *ch = NULL;
+	int ret = 0;
+
+	if (!reg->size || reg->start + reg->size < reg->start)
+		return -EINVAL;
+
+	reg->users = 0;
+	reg->used = 0;
+	reg->private_data = NULL;
+	reg->registered = 0;
+	reg->free_space = reg->size;
+
+	/* Copy name and alloc_name */
+	name = reg->name;
+	alloc_name = reg->alloc_name;
+	if (reg->copy_name && (reg->name || reg->alloc_name)) {
+		size_t name_size, alloc_size;
+
+		name_size  = reg->name       ? strlen(reg->name) + 1       : 0;
+		alloc_size = reg->alloc_name ? strlen(reg->alloc_name) + 1 : 0;
+
+		ch = kmalloc(name_size + alloc_size, GFP_KERNEL);
+		if (!ch) {
+			pr_err("%s: not enough memory to allocate name\n",
+			       reg->name ?: "(private)");
+			return -ENOMEM;
+		}
+
+		if (name_size) {
+			memcpy(ch, reg->name, name_size);
+			name = ch;
+			ch += name_size;
+		}
+
+		if (alloc_size) {
+			memcpy(ch, reg->alloc_name, alloc_size);
+			alloc_name = ch;
+		}
+	}
+
+	mutex_lock(&cma_mutex);
+
+	/* Don't let regions overlap */
+	cma_foreach_region(r)
+		if (r->start + r->size > reg->start &&
+		    r->start < reg->start + reg->size) {
+			ret = -EADDRINUSE;
+			goto done;
+		}
+
+	if (reg->alloc) {
+		ret = __cma_region_attach_alloc(reg);
+		if (unlikely(ret < 0))
+			goto done;
+	}
+
+	reg->name = name;
+	reg->alloc_name = alloc_name;
+	reg->registered = 1;
+	ch = NULL;
+
+	/*
+	 * Keep named at the beginning and unnamed (private) at the
+	 * end.  This helps in traversal when named region is looked
+	 * for.
+	 */
+	if (name)
+		list_add(&reg->list, &cma_regions);
+	else
+		list_add_tail(&reg->list, &cma_regions);
+
+done:
+	mutex_unlock(&cma_mutex);
+
+	pr_debug("%s: region %sregistered\n",
+		 reg->name ?: "(private)", ret ? "not " : "");
+	kfree(ch);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(cma_region_register);
+
+static struct cma_region *__must_check
+__cma_region_find(const char **namep)
+{
+	struct cma_region *reg;
+	const char *ch, *name;
+	size_t n;
+
+	ch = *namep;
+	while (*ch && *ch != ',' && *ch != ';')
+		++ch;
+	name = *namep;
+	*namep = *ch == ',' ? ch + 1 : ch;
+	n = ch - name;
+
+	/*
+	 * Named regions are kept in front of unnamed so if we
+	 * encounter unnamed region we can stop.
+	 */
+	cma_foreach_region(reg)
+		if (!reg->name)
+			break;
+		else if (!strncmp(name, reg->name, n) && !reg->name[n])
+			return reg;
+
+	return NULL;
+}
+
+/* List of all allocators. */
+static LIST_HEAD(cma_allocators);
+
+#define cma_foreach_allocator(alloc) \
+	list_for_each_entry(alloc, &cma_allocators, list)
+
+int cma_allocator_register(struct cma_allocator *alloc)
+{
+	struct cma_region *reg;
+	int first;
+
+	if (!alloc->alloc || !alloc->free)
+		return -EINVAL;
+
+	mutex_lock(&cma_mutex);
+
+	first = list_empty(&cma_allocators);
+
+	list_add_tail(&alloc->list, &cma_allocators);
+
+	/*
+	 * Attach this allocator to all allocator-less regions that
+	 * request this particular allocator (reg->alloc_name equals
+	 * alloc->name) or if region wants the first available
+	 * allocator and we are the first.
+	 */
+	cma_foreach_region(reg) {
+		if (reg->alloc)
+			continue;
+		if (reg->alloc_name
+		  ? alloc->name && !strcmp(alloc->name, reg->alloc_name)
+		  : (!reg->used && first))
+			continue;
+
+		reg->alloc = alloc;
+		__cma_region_attach_alloc(reg);
+	}
+
+	mutex_unlock(&cma_mutex);
+
+	pr_debug("%s: allocator registered\n", alloc->name ?: "(unnamed)");
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(cma_allocator_register);
+
+static struct cma_allocator *__must_check
+__cma_allocator_find(const char *name)
+{
+	struct cma_allocator *alloc;
+
+	if (!name)
+		return list_empty(&cma_allocators)
+			? NULL
+			: list_entry(cma_allocators.next,
+				     struct cma_allocator, list);
+
+	cma_foreach_allocator(alloc)
+		if (alloc->name && !strcmp(name, alloc->name))
+			return alloc;
+
+	return NULL;
+}
+
+
+/************************* Initialise CMA *************************/
+
+int __init cma_set_defaults(struct cma_region *regions, const char *map)
+{
+	if (map) {
+		int ret = cma_map_param((char *)map);
+		if (unlikely(ret < 0))
+			return ret;
+	}
+
+	if (!regions)
+		return 0;
+
+	for (; regions->size; ++regions) {
+		int ret = cma_early_region_register(regions);
+		if (unlikely(ret < 0))
+			return ret;
+	}
+
+	return 0;
+}
+
+static int __init
+__cma_early_reserve(struct cma_region *reg)
+{
+	bool tried = false;
+
+#ifndef CONFIG_NO_BOOTMEM
+
+	tried = true;
+
+	{
+		void *ptr = __alloc_bootmem_nopanic(reg->size, reg->alignment,
+						    reg->start);
+		if (ptr) {
+			reg->start = virt_to_phys(ptr);
+			return 0;
+		}
+	}
+
+#endif
+
+#ifdef CONFIG_HAVE_MEMBLOCK
+
+	tried = true;
+
+	if (reg->start) {
+		if (!memblock_is_region_reserved(reg->start, reg->size) &&
+		    memblock_reserve(reg->start, reg->size) >= 0)
+			return 0;
+	} else {
+		/*
+		 * Use __memblock_alloc_base() since
+		 * memblock_alloc_base() panic()s.
+		 */
+		u64 ret = __memblock_alloc_base(reg->size, reg->alignment, 0);
+		if (ret && ret + reg->size < ~(phys_addr_t)0) {
+			reg->start = ret;
+			return 0;
+		}
+
+		if (ret)
+			memblock_free(ret, reg->size);
+	}
+
+#endif
+
+	return tried ? -ENOMEM : -EOPNOTSUPP;
+}
+
+int __init cma_early_region_reserve(struct cma_region *reg)
+{
+	int ret;
+
+	pr_debug("%s\n", __func__);
+
+	if (!reg->size || (reg->alignment & (reg->alignment - 1)) ||
+	    reg->reserved)
+		return -EINVAL;
+
+	ret = __cma_early_reserve(reg);
+	if (!ret)
+		reg->reserved = 1;
+	return 0;
+}
+
+void __init cma_early_regions_reserve(int (*reserve)(struct cma_region *reg))
+{
+	struct cma_region *reg;
+
+	pr_debug("init: reserving early regions\n");
+
+	if (!reserve)
+		reserve = cma_early_region_reserve;
+
+	list_for_each_entry(reg, &cma_early_regions, list) {
+		if (reg->reserved) {
+			/* nothing */
+		} else if (reserve(reg) >= 0) {
+			pr_debug("init: %s: reserved %p@%p\n",
+				 reg->name ?: "(private)",
+				 (void *)reg->size,
+				 (void *)reg->start);
+			reg->reserved = 1;
+		} else {
+			pr_warn("init: %s: unable to reserve %p@%p/%p\n",
+				reg->name ?: "(private)",
+				(void *)reg->size,
+				(void *)reg->start,
+				(void *)reg->alignment);
+		}
+	}
+}
+
+static int __init cma_init(void)
+{
+	struct cma_region *reg, *n;
+
+	pr_debug("init: initialising\n");
+
+	if (cma_map) {
+		char *val = kmemdup(cma_map, cma_map_length + 1, GFP_KERNEL);
+		cma_map = val;
+		if (!val)
+			return -ENOMEM;
+		val[cma_map_length] = '\0';
+	}
+
+	list_for_each_entry_safe(reg, n, &cma_early_regions, list) {
+		INIT_LIST_HEAD(&reg->list);
+		/*
+		 * We don't care if there was an error.  It's a pity
+		 * but there's not much we can do about it any way.
+		 * If the error is on a region that was parsed from
+		 * command line then it will stay and waste a bit of
+		 * space; if it was registered using
+		 * cma_early_region_register() it's caller's
+		 * responsibility to do something about it.
+		 */
+		if (reg->reserved && cma_region_register(reg) < 0)
+			/* ignore error */;
+	}
+
+	INIT_LIST_HEAD(&cma_early_regions);
+
+	return 0;
+}
+/*
+ * We want to be initialised earlier than module_init/__initcall so
+ * that drivers that want to grab memory at boot time will get CMA
+ * ready.  subsys_initcall() seems early enough and not too early at
+ * the same time.
+ */
+subsys_initcall(cma_init);
+
+
+/************************* The Device API *************************/
+
+static const char *__must_check
+__cma_where_from(const struct device *dev, const char *type);
+
+/* Allocate. */
+static const struct cma *__must_check
+__cma_alloc_from_region(struct cma_region *reg,
+			size_t size, unsigned long alignment)
+{
+	struct cma *chunk;
+
+	pr_debug("allocate %p/%p from %s\n",
+		 (void *)size, (void *)alignment,
+		 reg ? reg->name ?: "(private)" : "(null)");
+
+	if (!reg || reg->free_space < size)
+		return ERR_PTR(-ENOSPC);
+
+	if (!reg->alloc) {
+		if (!reg->used)
+			__cma_region_attach_alloc(reg);
+		if (!reg->alloc)
+			return ERR_PTR(-ENOMEM);
+	}
+
+	chunk = reg->alloc->alloc(reg, size, alignment);
+	if (IS_ERR_OR_NULL(chunk))
+		return chunk ? ERR_CAST(chunk) : ERR_PTR(-ENOMEM);
+
+	chunk->pinned = 0;
+	chunk->reg = reg;
+	++reg->users;
+	reg->free_space -= chunk->size;
+	pr_debug("allocated (at %p)\n", (void *)chunk->phys);
+	return chunk;
+}
+
+const struct cma *__must_check
+cma_alloc_from_region(struct cma_region *reg,
+		      size_t size, unsigned long alignment)
+{
+	const struct cma *chunk;
+
+	pr_debug("allocate %p/%p from %s\n",
+		 (void *)size, (void *)alignment,
+		 reg ? reg->name ?: "(private)" : "(null)");
+
+	if (!size || alignment & (alignment - 1) || !reg)
+		return ERR_PTR(-EINVAL);
+
+	mutex_lock(&cma_mutex);
+
+	if (reg->registered) {
+		if (alignment < PAGE_SIZE)
+			alignment = PAGE_SIZE;
+		chunk = __cma_alloc_from_region(reg, PAGE_ALIGN(size), alignment);
+	} else {
+		chunk = ERR_PTR(-EINVAL);
+	}
+
+	mutex_unlock(&cma_mutex);
+
+	return chunk;
+}
+EXPORT_SYMBOL_GPL(cma_alloc_from_region);
+
+const struct cma *__must_check
+__cma_alloc(const struct device *dev, const char *type,
+	    size_t size, unsigned long alignment)
+{
+	struct cma_region *reg;
+	const struct cma *chunk;
+	const char *from;
+
+	if (dev)
+		pr_debug("allocate %p/%p for %s/%s\n",
+			 (void *)size, (void *)alignment,
+			 dev_name(dev), type ?: "");
+
+	if (!size || alignment & (alignment - 1))
+		return ERR_PTR(-EINVAL);
+
+	size = PAGE_ALIGN(size);
+	if (alignment < PAGE_SIZE)
+		alignment = PAGE_SIZE;
+
+	mutex_lock(&cma_mutex);
+
+	from = __cma_where_from(dev, type);
+	if (unlikely(IS_ERR(from))) {
+		chunk = ERR_CAST(from);
+		goto done;
+	}
+
+	pr_debug("allocate %p/%p from one of %s\n",
+		 (void *)size, (void *)alignment, from);
+
+	while (*from && *from != ';') {
+		reg = __cma_region_find(&from);
+		chunk = __cma_alloc_from_region(reg, size, alignment);
+		if (!IS_ERR(chunk))
+			goto done;
+	}
+
+	pr_debug("not enough memory\n");
+	chunk = ERR_PTR(-ENOMEM);
+
+done:
+	mutex_unlock(&cma_mutex);
+
+	return chunk;
+}
+EXPORT_SYMBOL_GPL(__cma_alloc);
+
+/* Query information about regions. */
+int
+__cma_info(struct cma_info *infop, const struct device *dev, const char *type)
+{
+	struct cma_info info = { ~(phys_addr_t)0, 0, 0, 0, 0 };
+	struct cma_region *reg;
+	const char *from;
+	int ret;
+
+	if (unlikely(!infop))
+		return -EINVAL;
+
+	mutex_lock(&cma_mutex);
+
+	from = __cma_where_from(dev, type);
+	if (IS_ERR(from)) {
+		ret = PTR_ERR(from);
+		info.lower_bound = 0;
+		goto done;
+	}
+
+	while (*from && *from != ';') {
+		reg = __cma_region_find(&from);
+		if (reg) {
+			info.total_size += reg->size;
+			info.free_size += reg->free_space;
+			if (info.lower_bound > reg->start)
+				info.lower_bound = reg->start;
+			if (info.upper_bound < reg->start + reg->size)
+				info.upper_bound = reg->start + reg->size;
+			++info.count;
+		}
+	}
+
+	ret = 0;
+done:
+	mutex_unlock(&cma_mutex);
+
+	memcpy(infop, &info, sizeof info);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(__cma_info);
+
+/* Freeing. */
+void cma_free(const struct cma *_chunk)
+{
+	pr_debug("cma_free([%p])\n", (void *)_chunk);
+
+	if (_chunk) {
+		struct cma *chunk = (struct cma *)_chunk;
+
+		mutex_lock(&cma_mutex);
+
+		if (WARN_ON(chunk->pinned) && chunk->reg->alloc->unpin)
+			chunk->reg->alloc->unpin(chunk);
+
+		--chunk->reg->users;
+		chunk->reg->free_space += chunk->size;
+		chunk->reg->alloc->free(chunk);
+
+		mutex_unlock(&cma_mutex);
+	}
+}
+EXPORT_SYMBOL_GPL(cma_free);
+
+/* Pinning */
+phys_addr_t cma_pin(const struct cma *_chunk)
+{
+	struct cma *chunk = (struct cma *)_chunk;
+
+	pr_debug("cma_pin([%p])\n", (void *)chunk);
+
+	mutex_lock(&cma_mutex);
+
+	if (++chunk->pinned == 1 && chunk->reg->alloc->pin)
+		chunk->reg->alloc->pin(chunk);
+
+	mutex_unlock(&cma_mutex);
+
+	return chunk->phys;
+}
+EXPORT_SYMBOL_GPL(cma_pin);
+
+void cma_unpin(const struct cma *_chunk)
+{
+	struct cma *chunk = (struct cma *)_chunk;
+
+	pr_debug("cma_unpin([%p])\n", (void *)chunk);
+
+	mutex_lock(&cma_mutex);
+
+	if (!--chunk->pinned && chunk->reg->alloc->unpin)
+		chunk->reg->alloc->unpin(chunk);
+
+	mutex_unlock(&cma_mutex);
+}
+EXPORT_SYMBOL_GPL(cma_unpin);
+
+
+/************************* Miscellaneous *************************/
+
+static int __cma_region_attach_alloc(struct cma_region *reg)
+{
+	struct cma_allocator *alloc;
+	int ret;
+
+	/*
+	 * If reg->alloc is set then caller wants us to use this
+	 * allocator.  Otherwise we need to find one by name.
+	 */
+	if (reg->alloc) {
+		alloc = reg->alloc;
+	} else {
+		alloc = __cma_allocator_find(reg->alloc_name);
+		if (!alloc) {
+			pr_warn("init: %s: %s: no such allocator\n",
+				reg->name ?: "(private)",
+				reg->alloc_name ?: "(default)");
+			reg->used = 1;
+			return -ENOENT;
+		}
+	}
+
+	/* Try to initialise the allocator. */
+	reg->private_data = NULL;
+	ret = alloc->init ? alloc->init(reg) : 0;
+	if (unlikely(ret < 0)) {
+		pr_err("init: %s: %s: unable to initialise allocator\n",
+		       reg->name ?: "(private)", alloc->name ?: "(unnamed)");
+		reg->alloc = NULL;
+		reg->used = 1;
+	} else {
+		reg->alloc = alloc;
+		pr_debug("init: %s: %s: initialised allocator\n",
+			 reg->name ?: "(private)", alloc->name ?: "(unnamed)");
+	}
+	return ret;
+}
+
+
+/*
+ * s            ::= rules
+ * rules        ::= rule [ ';' rules ]
+ * rule         ::= patterns '=' regions
+ * patterns     ::= pattern [ ',' patterns ]
+ * regions      ::= REG-NAME [ ',' regions ]
+ * pattern      ::= dev-pattern [ '/' TYPE-NAME ] | '/' TYPE-NAME
+ */
+static const char *__must_check
+__cma_where_from(const struct device *dev, const char *type)
+{
+	/*
+	 * This function matches the pattern from the map attribute
+	 * agains given device name and type.  Type may be of course
+	 * NULL or an emtpy string.
+	 */
+
+	const char *s, *name;
+	int name_matched = 0;
+
+	/*
+	 * If dev is NULL we were called in alternative form where
+	 * type is the from string.  All we have to do is return it.
+	 */
+	if (!dev)
+		return type ?: ERR_PTR(-EINVAL);
+
+	if (!cma_map)
+		return ERR_PTR(-ENOENT);
+
+	name = dev_name(dev);
+	if (WARN_ON(!name || !*name))
+		return ERR_PTR(-EINVAL);
+
+	if (!type)
+		type = "common";
+
+	/*
+	 * Now we go throught the cma_map attribute.
+	 */
+	for (s = cma_map; *s; ++s) {
+		const char *c;
+
+		/*
+		 * If the pattern starts with a slash, the device part of the
+		 * pattern matches if it matched previously.
+		 */
+		if (*s == '/') {
+			if (!name_matched)
+				goto look_for_next;
+			goto match_type;
+		}
+
+		/*
+		 * We are now trying to match the device name.  This also
+		 * updates the name_matched variable.  If, while reading the
+		 * spec, we ecnounter comma it means that the pattern does not
+		 * match and we need to start over with another pattern (the
+		 * one afther the comma).  If we encounter equal sign we need
+		 * to start over with another rule.  If there is a character
+		 * that does not match, we neet to look for a comma (to get
+		 * another pattern) or semicolon (to get another rule) and try
+		 * again if there is one somewhere.
+		 */
+
+		name_matched = 0;
+
+		for (c = name; *s != '*' && *c; ++c, ++s)
+			if (*s == '=')
+				goto next_rule;
+			else if (*s == ',')
+				goto next_pattern;
+			else if (*s != '?' && *c != *s)
+				goto look_for_next;
+		if (*s == '*')
+			++s;
+
+		name_matched = 1;
+
+		/*
+		 * Now we need to match the type part of the pattern.  If the
+		 * pattern is missing it we match only if type points to an
+		 * empty string.  Otherwise wy try to match it just like name.
+		 */
+		if (*s == '/') {
+match_type:		/* s points to '/' */
+			++s;
+
+			for (c = type; *s && *c; ++c, ++s)
+				if (*s == '=')
+					goto next_rule;
+				else if (*s == ',')
+					goto next_pattern;
+				else if (*c != *s)
+					goto look_for_next;
+		}
+
+		/* Return the string behind the '=' sign of the rule. */
+		if (*s == '=')
+			return s + 1;
+		else if (*s == ',')
+			return strchr(s, '=') + 1;
+
+		/* Pattern did not match */
+
+look_for_next:
+		do {
+			++s;
+		} while (*s != ',' && *s != '=');
+		if (*s == ',')
+			continue;
+
+next_rule:	/* s points to '=' */
+		s = strchr(s, ';');
+		if (!s)
+			break;
+
+next_pattern:
+		continue;
+	}
+
+	return ERR_PTR(-ENOENT);
+}
+
+
+/************************* Generic allocator *************************/
+
+#ifdef CONFIG_CMA_GENERIC_ALLOCATOR
+
+static int cma_gen_init(struct cma_region *reg)
+{
+	struct gen_pool *pool;
+	int ret;
+
+	pool = gen_pool_create(PAGE_SHIFT, -1);
+	if (unlikely(!pool))
+		return -ENOMEM;
+
+	ret = gen_pool_add(pool, reg->start, reg->size, -1);
+	if (unlikely(ret)) {
+		gen_pool_destroy(pool);
+		return ret;
+	}
+
+	reg->private_data = pool;
+	return 0;
+}
+
+static void cma_gen_cleanup(struct cma_region *reg)
+{
+	gen_pool_destroy(reg->private_data);
+}
+
+struct cma *cma_gen_alloc(struct cma_region *reg,
+			  size_t size, unsigned long alignment)
+{
+	unsigned long start;
+	struct cma *chunk;
+
+	chunk = kmalloc(sizeof *chunk, GFP_KERNEL);
+	if (unlikely(!chunk))
+		return ERR_PTR(-ENOMEM);
+
+	start = gen_pool_alloc_aligned(reg->private_data, size,
+				       alignment ? ffs(alignment) - 1 : 0);
+	if (!start) {
+		kfree(chunk);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	chunk->phys = start;
+	chunk->size = size;
+	return chunk;
+}
+
+static void cma_gen_free(struct cma *chunk)
+{
+	gen_pool_free(chunk->reg->private_data, chunk->phys, chunk->size);
+	kfree(chunk);
+}
+
+static int cma_gen_module_init(void)
+{
+	static struct cma_allocator alloc = {
+		.name    = "gen",
+		.init    = cma_gen_init,
+		.cleanup = cma_gen_cleanup,
+		.alloc   = cma_gen_alloc,
+		.free    = cma_gen_free,
+	};
+	return cma_allocator_register(&alloc);
+}
+module_init(cma_gen_module_init);
+
+#endif
-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
