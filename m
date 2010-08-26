Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 09D706B01F0
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 02:26:05 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from eu_spt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L7Q00ED4XVE1E40@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 26 Aug 2010 07:26:03 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L7Q00GM9XVDR2@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 26 Aug 2010 07:26:02 +0100 (BST)
Date: Thu, 26 Aug 2010 08:25:03 +0200
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [PATCH/RFCv4.1 2/6] mm: cma: Contiguous Memory Allocator added
In-reply-to: 
 <343f4b0edf9b5eef598831700cb459cd428d3f2e.1282286941.git.m.nazarewicz@samsung.com>
Message-id: 
 <2a60bd15f88bbab99d22bd8b100acecefffaf08e.1282800620.git.mina86@mina86.com>
References: 
 <343f4b0edf9b5eef598831700cb459cd428d3f2e.1282286941.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>linux-mm@kvack.orgKonrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Pawel Osciak <p.osciak@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, linux-kernel@vger.kernel.org, Hans Verkuil <hverkuil@xs4all.nl>, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>
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
Reviewed-by: Pawel Osciak <p.osciak@samsung.com>
---

Just a quick bugfix (i n certain conditions, CMA went into infinite
loop) and update in response to Konrad's comments.

 Documentation/00-INDEX              |    2 +
 Documentation/contiguous-memory.txt |  544 +++++++++++++++++++++
 include/linux/cma.h                 |  432 +++++++++++++++++
 mm/Kconfig                          |   34 ++
 mm/Makefile                         |    2 +
 mm/cma-best-fit.c                   |  407 ++++++++++++++++
 mm/cma.c                            |  911 +++++++++++++++++++++++++++++++++++
 7 files changed, 2332 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/contiguous-memory.txt
 create mode 100644 include/linux/cma.h
 create mode 100644 mm/cma-best-fit.c
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
index 0000000..cc43440
--- /dev/null
+++ b/Documentation/contiguous-memory.txt
@@ -0,0 +1,544 @@
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
+       The presented solution includes an implementation of a best-fit
+       algorithm.
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
+                { .name = "region", .size = 20 << 20 },
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
+                { .name = "region", .size = 20 << 20 },
+                { .name = "common", .size =  5 << 20 },
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
+                { .name = "v", .size = 20 << 20 },
+                { .name = "c", .size = 20 << 20 },
+                { .name = "common", .size =  5 << 20 },
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
+                { .name = "region", .size = 30 << 20, .alloc_name = "na" },
+                { .name = "common", .size =  5 << 20 },
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
+                 { .name = "a", .size = 32 << 20 },
+                 { .name = "b", .size = 32 << 20, .start = 512 << 20 },
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
+                 { .name = "r", .size = 64 << 20 },
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
+        dma_addr_t cma_alloc(const struct device *dev, const char *type,
+                             size_t size, dma_addr_t alignment);
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
+        addr = cma_alloc(dev, NULL, size, 0);
+
+    The function returns bus address of allocated chunk or a value
+    that evaluates to true if checked with IS_ERR_VALUE(), so the
+    correct way for checking for errors is:
+
+        unsigned long addr = cma_alloc(dev, size);
+        if (IS_ERR_VALUE(addr))
+                /* Error */
+                return (int)addr;
+        /* Allocated */
+
+    (Make sure to include <linux/err.h> which contains the definition
+    of the IS_ERR_VALUE() macro.)
+
+
+    Allocated chunk is freed via a cma_free() function:
+
+        int cma_free(dma_addr_t addr);
+
+    It takes bus address of the chunk as an argument frees it.
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
+         dma_addr_t cma_alloc_from_region(struct cma_region *reg,
+                                          size_t size, dma_addr_t alignment);
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
+         dma_addr_t cma_alloc_from(const char *regions,
+                                   size_t size, dma_addr_t alignment);
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
+    The two other calls are used for allocating and freeing chunks.
+    They are:
+
+        struct cma_chunk *cma_foo_alloc(struct cma_region *reg,
+                                        size_t size, dma_addr_t alignment);
+        void cma_foo_free(struct cma_chunk *chunk);
+
+    As names imply the first allocates a chunk and the other frees
+    a chunk of memory.  It also manages a cma_chunk object
+    representing the chunk in physical memory.
+
+    Either of those function can assume that they are the only thread
+    accessing the region.  Therefore, allocator does not need to worry
+    about concurrency.  Moreover, all arguments are guaranteed to be
+    valid (i.e. page aligned size, a power of two alignment no lower
+    the a page size).
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
+
+** Future work
+
+    In the future, implementation of mechanisms that would allow the
+    free space inside the regions to be used as page cache, filesystem
+    buffers or swap devices is planned.  With such mechanisms, the
+    memory would not be wasted when not used.
+
+    Because all allocations and freeing of chunks pass the CMA
+    framework it can follow what parts of the reserved memory are
+    freed and what parts are allocated.  Tracking the unused memory
+    would let CMA use it for other purposes such as page cache, I/O
+    buffers, swap, etc.
diff --git a/include/linux/cma.h b/include/linux/cma.h
new file mode 100644
index 0000000..9f6ee57
--- /dev/null
+++ b/include/linux/cma.h
@@ -0,0 +1,432 @@
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
+/***************************** Kernel lever API *****************************/
+
+#ifdef __KERNEL__
+
+#include <linux/rbtree.h>
+#include <linux/list.h>
+
+
+struct device;
+struct cma_info;
+
+/*
+ * Don't call it directly, use cma_alloc(), cma_alloc_from() or
+ * cma_alloc_from_region().
+ */
+dma_addr_t __must_check
+__cma_alloc(const struct device *dev, const char *type,
+	    size_t size, dma_addr_t alignment);
+
+/* Don't call it directly, use cma_info() or cma_info_about(). */
+int
+__cma_info(struct cma_info *info, const struct device *dev, const char *type);
+
+
+/**
+ * cma_alloc - allocates contiguous chunk of memory.
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
+ * On error returns a negative error cast to dma_addr_t.  Use
+ * IS_ERR_VALUE() to check if returned value is indeed an error.
+ * Otherwise bus address of the chunk is returned.
+ */
+static inline dma_addr_t __must_check
+cma_alloc(const struct device *dev, const char *type,
+	  size_t size, dma_addr_t alignment)
+{
+	return dev ? __cma_alloc(dev, type, size, alignment) : -EINVAL;
+}
+
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
+	dma_addr_t lower_bound, upper_bound;
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
+/**
+ * cma_free - frees a chunk of memory.
+ * @addr:	Beginning of the chunk.
+ *
+ * Returns -ENOENT if there is no chunk at given location; otherwise
+ * zero.  In the former case issues a warning.
+ */
+int cma_free(dma_addr_t addr);
+
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
+ * On error returns a negative error cast to dma_addr_t.  Use
+ * IS_ERR_VALUE() to check if returned value is indeed an error.
+ * Otherwise bus address of the chunk is returned.
+ */
+static inline dma_addr_t __must_check
+cma_alloc_from(const char *regions, size_t size, dma_addr_t alignment)
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
+
+
+struct cma_allocator;
+
+/**
+ * struct cma_region - a region reserved for CMA allocations.
+ * @name:	Unique name of the region.  Read only.
+ * @start:	Bus address of the region in bytes.  Always aligned at
+ *		least to a full page.  Read only.
+ * @size:	Size of the region in bytes.  Multiply of a page size.
+ *		Read only.
+ * @free_space:	Free space in the region.  Read only.
+ * @alignment:	Desired alignment of the region in bytes.  A power of two,
+ *		always at least page size.  Early.
+ * @alloc:	Allocator used with this region.  NULL means allocator is
+ *		not attached.  Private.
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
+	dma_addr_t start;
+	size_t size;
+	union {
+		size_t free_space;	/* Normal region */
+		dma_addr_t alignment;	/* Early region */
+	};
+
+	struct cma_allocator *alloc;
+	const char *alloc_name;
+	void *private_data;
+
+	unsigned users;
+	struct list_head list;
+
+	unsigned used:1;
+	unsigned registered:1;
+	unsigned reserved:1;
+	unsigned copy_name:1;
+	unsigned free_alloc_name:1;
+};
+
+
+/**
+ * cma_region_register() - registers a region.
+ * @reg:	Region to region.
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
+ * cma_region_unregister() - unregisters a region.
+ * @reg:	Region to unregister.
+ *
+ * Region is unregistered only if there are no chunks allocated for
+ * it.  Otherwise, function returns -EBUSY.
+ *
+ * On success returs zero.
+ */
+int __must_check cma_region_unregister(struct cma_region *reg);
+
+
+/**
+ * cma_alloc_from_region() - allocates contiguous chunk of memory from region.
+ * @reg:	Region to allocate chunk from.
+ * @size:	Size of the memory to allocate in bytes.
+ * @alignment:	Desired alignment in bytes.  Must be a power of two or
+ *		zero.  If alignment is less then a page size it will be
+ *		set to page size. If unsure, pass zero here.
+ *
+ * On error returns a negative error cast to dma_addr_t.  Use
+ * IS_ERR_VALUE() to check if returned value is indeed an error.
+ * Otherwise bus address of the chunk is returned.
+ */
+dma_addr_t __must_check
+cma_alloc_from_region(struct cma_region *reg,
+		      size_t size, dma_addr_t alignment);
+
+
+
+/****************************** Allocators API ******************************/
+
+/**
+ * struct cma_chunk - an allocated contiguous chunk of memory.
+ * @start:	Bus address in bytes.
+ * @size:	Size in bytes.
+ * @free_space:	Free space in region in bytes.  Read only.
+ * @reg:	Region this chunk belongs to.
+ * @by_start:	A node in an red-black tree with all chunks sorted by
+ *		start address.
+ *
+ * The cma_allocator::alloc() operation need to set only the @start
+ * and @size fields.  The rest is handled by the caller (ie. CMA
+ * glue).
+ */
+struct cma_chunk {
+	dma_addr_t start;
+	size_t size;
+
+	struct cma_region *reg;
+	struct rb_node by_start;
+};
+
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
+ *		contained in a bigger structure with allocator-specific data.
+ *		Required.
+ * @free:	Frees allocated chunk.  May also assume that it is the only
+ *		call that uses given region.  This has to free() the chunk
+ *		object as well.  Required.
+ * @list:	Entry in list of allocators.  Private.
+ */
+struct cma_allocator {
+	const char *name;
+
+	int (*init)(struct cma_region *reg);
+	void (*cleanup)(struct cma_region *reg);
+	struct cma_chunk *(*alloc)(struct cma_region *reg, size_t size,
+				   dma_addr_t alignment);
+	void (*free)(struct cma_chunk *chunk);
+
+	struct list_head list;
+};
+
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
+ * cma_early_regions_reserver() - helper function for reserving early regions.
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
+#else
+
+#define cma_defaults(regions, map)         ((int)0)
+#define cma_early_regions_reserve(reserve) do { } while (0)
+
+#endif
+
+#endif
diff --git a/mm/Kconfig b/mm/Kconfig
index f4e516e..3e9317c 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -301,3 +301,37 @@ config NOMMU_INITIAL_TRIM_EXCESS
 	  of 1 says that all excess pages should be trimmed.
 
 	  See Documentation/nommu-mmap.txt for more information.
+
+
+config CMA
+	bool "Contiguous Memory Allocator framework"
+	# Currently there is only one allocator so force it on
+	select CMA_BEST_FIT
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
+config CMA_DEBUG
+	bool "CMA debug messages (DEVELOPEMENT)"
+	depends on CMA
+	help
+	  Enable debug messages in CMA code.
+
+config CMA_BEST_FIT
+	bool "CMA best-fit allocator"
+	depends on CMA
+	default y
+	help
+	  This is a best-fit algorithm running in O(n log n) time where
+	  n is the number of existing holes (which is never greater then
+	  the number of allocated regions and usually much smaller).  It
+	  allocates area from the smallest hole that is big enough for
+	  allocation in question.
diff --git a/mm/Makefile b/mm/Makefile
index 34b2546..d8c717f 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -47,3 +47,5 @@ obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
 obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
+obj-$(CONFIG_CMA) += cma.o
+obj-$(CONFIG_CMA_BEST_FIT) += cma-best-fit.o
diff --git a/mm/cma-best-fit.c b/mm/cma-best-fit.c
new file mode 100644
index 0000000..97f8d61
--- /dev/null
+++ b/mm/cma-best-fit.c
@@ -0,0 +1,407 @@
+/*
+ * Contiguous Memory Allocator framework: Best Fit allocator
+ * Copyright (c) 2010 by Samsung Electronics.
+ * Written by Michal Nazarewicz (m.nazarewicz@samsung.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of the
+ * License or (at your optional) any later version of the license.
+ */
+
+#define pr_fmt(fmt) "cma: bf: " fmt
+
+#ifdef CONFIG_CMA_DEBUG
+#  define DEBUG
+#endif
+
+#include <linux/errno.h>       /* Error numbers */
+#include <linux/slab.h>        /* kmalloc() */
+
+#include <linux/cma.h>         /* CMA structures */
+
+
+/************************* Data Types *************************/
+
+struct cma_bf_item {
+	struct cma_chunk ch;
+	struct rb_node by_size;
+};
+
+struct cma_bf_private {
+	struct rb_root by_start_root;
+	struct rb_root by_size_root;
+};
+
+
+/************************* Prototypes *************************/
+
+/*
+ * Those are only for holes.  They must be called whenever hole's
+ * properties change but also whenever chunk becomes a hole or hole
+ * becames a chunk.
+ */
+static void __cma_bf_hole_insert_by_size(struct cma_bf_item *item);
+static void __cma_bf_hole_erase_by_size(struct cma_bf_item *item);
+static int  __must_check
+__cma_bf_hole_insert_by_start(struct cma_bf_item *item);
+static void __cma_bf_hole_erase_by_start(struct cma_bf_item *item);
+
+/**
+ * __cma_bf_hole_take - takes a chunk of memory out of a hole.
+ * @hole:	hole to take chunk from
+ * @size:	chunk's size
+ * @alignment:	chunk's starting address alignment (must be power of two)
+ *
+ * Takes a @size bytes large chunk from hole @hole which must be able
+ * to hold the chunk.  The "must be able" includes also alignment
+ * constraint.
+ *
+ * Returns allocated item or NULL on error (if kmalloc() failed).
+ */
+static struct cma_bf_item *__must_check
+__cma_bf_hole_take(struct cma_bf_item *hole, size_t size, dma_addr_t alignment);
+
+/**
+ * __cma_bf_hole_merge_maybe - tries to merge hole with neighbours.
+ * @item: hole to try and merge
+ *
+ * Which items are preserved is undefined so you may not rely on it.
+ */
+static void __cma_bf_hole_merge_maybe(struct cma_bf_item *item);
+
+
+/************************* Device API *************************/
+
+int cma_bf_init(struct cma_region *reg)
+{
+	struct cma_bf_private *prv;
+	struct cma_bf_item *item;
+
+	prv = kzalloc(sizeof *prv, GFP_KERNEL);
+	if (unlikely(!prv))
+		return -ENOMEM;
+
+	item = kzalloc(sizeof *item, GFP_KERNEL);
+	if (unlikely(!item)) {
+		kfree(prv);
+		return -ENOMEM;
+	}
+
+	item->ch.start = reg->start;
+	item->ch.size  = reg->size;
+	item->ch.reg   = reg;
+
+	rb_root_init(&prv->by_start_root, &item->ch.by_start);
+	rb_root_init(&prv->by_size_root, &item->by_size);
+
+	reg->private_data = prv;
+	return 0;
+}
+
+void cma_bf_cleanup(struct cma_region *reg)
+{
+	struct cma_bf_private *prv = reg->private_data;
+	struct cma_bf_item *item =
+		rb_entry(prv->by_size_root.rb_node,
+			 struct cma_bf_item, by_size);
+
+	/* We can assume there is only a single hole in the tree. */
+	WARN_ON(item->by_size.rb_left || item->by_size.rb_right ||
+		item->ch.by_start.rb_left || item->ch.by_start.rb_right);
+
+	kfree(item);
+	kfree(prv);
+}
+
+struct cma_chunk *cma_bf_alloc(struct cma_region *reg,
+			       size_t size, dma_addr_t alignment)
+{
+	struct cma_bf_private *prv = reg->private_data;
+	struct rb_node *node = prv->by_size_root.rb_node;
+	struct cma_bf_item *item = NULL;
+
+	/* First find hole that is large enough */
+	while (node) {
+		struct cma_bf_item *i =
+			rb_entry(node, struct cma_bf_item, by_size);
+
+		if (i->ch.size < size) {
+			node = node->rb_right;
+		} else if (i->ch.size >= size) {
+			node = node->rb_left;
+			item = i;
+		}
+	}
+	if (!item)
+		return NULL;
+
+	/* Now look for items which can satisfy alignment requirements */
+	for (;;) {
+		dma_addr_t start = ALIGN(item->ch.start, alignment);
+		dma_addr_t end   = item->ch.start + item->ch.size;
+		if (start < end && end - start >= size) {
+			item = __cma_bf_hole_take(item, size, alignment);
+			return likely(item) ? &item->ch : NULL;
+		}
+
+		node = rb_next(node);
+		if (!node)
+			return NULL;
+
+		item  = rb_entry(node, struct cma_bf_item, by_size);
+	}
+}
+
+void cma_bf_free(struct cma_chunk *chunk)
+{
+	struct cma_bf_item *item = container_of(chunk, struct cma_bf_item, ch);
+
+	/* Add new hole */
+	if (unlikely(__cma_bf_hole_insert_by_start(item))) {
+		/*
+		 * We're screwed...  Just free the item and forget
+		 * about it.  Things are broken beyond repair so no
+		 * sense in trying to recover.
+		 */
+		kfree(item);
+	} else {
+		__cma_bf_hole_insert_by_size(item);
+
+		/* Merge with prev and next sibling */
+		__cma_bf_hole_merge_maybe(item);
+	}
+}
+
+
+/************************* Basic Tree Manipulation *************************/
+
+static void __cma_bf_hole_insert_by_size(struct cma_bf_item *item)
+{
+	struct cma_bf_private *prv = item->ch.reg->private_data;
+	struct rb_node **link = &prv->by_size_root.rb_node, *parent = NULL;
+	const typeof(item->ch.size) value = item->ch.size;
+
+	while (*link) {
+		struct cma_bf_item *i;
+		parent = *link;
+		i = rb_entry(parent, struct cma_bf_item, by_size);
+		link = value <= i->ch.size
+			? &parent->rb_left
+			: &parent->rb_right;
+	}
+
+	rb_link_node(&item->by_size, parent, link);
+	rb_insert_color(&item->by_size, &prv->by_size_root);
+}
+
+static void __cma_bf_hole_erase_by_size(struct cma_bf_item *item)
+{
+	struct cma_bf_private *prv = item->ch.reg->private_data;
+	rb_erase(&item->by_size, &prv->by_size_root);
+}
+
+static int  __must_check
+__cma_bf_hole_insert_by_start(struct cma_bf_item *item)
+{
+	struct cma_bf_private *prv = item->ch.reg->private_data;
+	struct rb_node **link = &prv->by_start_root.rb_node, *parent = NULL;
+	const typeof(item->ch.start) value = item->ch.start;
+
+	while (*link) {
+		struct cma_bf_item *i;
+		parent = *link;
+		i = rb_entry(parent, struct cma_bf_item, ch.by_start);
+
+		if (WARN_ON(value == i->ch.start))
+			/*
+			 * This should *never* happen.  And I mean
+			 * *never*.  We could even BUG on it but
+			 * hopefully things are only a bit broken,
+			 * ie. system can still run.  We produce
+			 * a warning and return an error.
+			 */
+			return -EBUSY;
+
+		link = value <= i->ch.start
+			? &parent->rb_left
+			: &parent->rb_right;
+	}
+
+	rb_link_node(&item->ch.by_start, parent, link);
+	rb_insert_color(&item->ch.by_start, &prv->by_start_root);
+	return 0;
+}
+
+static void __cma_bf_hole_erase_by_start(struct cma_bf_item *item)
+{
+	struct cma_bf_private *prv = item->ch.reg->private_data;
+	rb_erase(&item->ch.by_start, &prv->by_start_root);
+}
+
+
+/************************* More Tree Manipulation *************************/
+
+static struct cma_bf_item *__must_check
+__cma_bf_hole_take(struct cma_bf_item *hole, size_t size, size_t alignment)
+{
+	struct cma_bf_item *item;
+
+	/*
+	 * There are three cases:
+	 * 1. the chunk takes the whole hole,
+	 * 2. the chunk is at the beginning or at the end of the hole, or
+	 * 3. the chunk is in the middle of the hole.
+	 */
+
+
+	/* Case 1, the whole hole */
+	if (size == hole->ch.size) {
+		__cma_bf_hole_erase_by_size(hole);
+		__cma_bf_hole_erase_by_start(hole);
+		return hole;
+	}
+
+
+	/* Allocate */
+	item = kmalloc(sizeof *item, GFP_KERNEL);
+	if (unlikely(!item))
+		return NULL;
+
+	item->ch.start = ALIGN(hole->ch.start, alignment);
+	item->ch.size  = size;
+
+	/* Case 3, in the middle */
+	if (item->ch.start != hole->ch.start
+	 && item->ch.start + item->ch.size !=
+	    hole->ch.start + hole->ch.size) {
+		struct cma_bf_item *tail;
+
+		/*
+		 * Space between the end of the chunk and the end of
+		 * the region, ie. space left after the end of the
+		 * chunk.  If this is dividable by alignment we can
+		 * move the chunk to the end of the hole.
+		 */
+		size_t left =
+			hole->ch.start + hole->ch.size -
+			(item->ch.start + item->ch.size);
+		if (left % alignment == 0) {
+			item->ch.start += left;
+			goto case_2;
+		}
+
+		/*
+		 * We are going to add a hole at the end.  This way,
+		 * we will reduce the problem to case 2 -- the chunk
+		 * will be at the end of the hole.
+		 */
+		tail = kmalloc(sizeof *tail, GFP_KERNEL);
+		if (unlikely(!tail)) {
+			kfree(item);
+			return NULL;
+		}
+
+		tail->ch.start = item->ch.start + item->ch.size;
+		tail->ch.size  =
+			hole->ch.start + hole->ch.size - tail->ch.start;
+		tail->ch.reg   = hole->ch.reg;
+
+		if (unlikely(__cma_bf_hole_insert_by_start(tail))) {
+			/*
+			 * Things are broken beyond repair...  Abort
+			 * inserting the hole but still continue with
+			 * allocation (seems like the best we can do).
+			 */
+
+			hole->ch.size = tail->ch.start - hole->ch.start;
+			kfree(tail);
+		} else {
+			__cma_bf_hole_insert_by_size(tail);
+			/*
+			 * It's important that we first insert the new
+			 * hole in the tree sorted by size and later
+			 * reduce the size of the old hole.  We will
+			 * update the position of the old hole in the
+			 * rb tree in code that handles case 2.
+			 */
+			hole->ch.size = tail->ch.start - hole->ch.start;
+		}
+
+		/* Go to case 2 */
+	}
+
+
+	/* Case 2, at the beginning or at the end */
+case_2:
+	/* No need to update the tree; order preserved. */
+	if (item->ch.start == hole->ch.start)
+		hole->ch.start += item->ch.size;
+
+	/* Alter hole's size */
+	hole->ch.size -= size;
+	__cma_bf_hole_erase_by_size(hole);
+	__cma_bf_hole_insert_by_size(hole);
+
+	return item;
+}
+
+
+static void __cma_bf_hole_merge_maybe(struct cma_bf_item *item)
+{
+	struct cma_bf_item *prev;
+	struct rb_node *node;
+	int twice = 2;
+
+	node = rb_prev(&item->ch.by_start);
+	if (unlikely(!node))
+		goto next;
+	prev = rb_entry(node, struct cma_bf_item, ch.by_start);
+
+	for (;;) {
+		if (prev->ch.start + prev->ch.size == item->ch.start) {
+			/* Remove previous hole from trees */
+			__cma_bf_hole_erase_by_size(prev);
+			__cma_bf_hole_erase_by_start(prev);
+
+			/* Alter this hole */
+			item->ch.size += prev->ch.size;
+			item->ch.start = prev->ch.start;
+			__cma_bf_hole_erase_by_size(item);
+			__cma_bf_hole_insert_by_size(item);
+			/*
+			 * No need to update by start trees as we do
+			 * not break sequence order
+			 */
+
+			/* Free prev hole */
+			kfree(prev);
+		}
+
+next:
+		if (!--twice)
+			break;
+
+		node = rb_next(&item->ch.by_start);
+		if (unlikely(!node))
+			break;
+		prev = item;
+		item = rb_entry(node, struct cma_bf_item, ch.by_start);
+	}
+}
+
+
+
+/************************* Register *************************/
+static int cma_bf_module_init(void)
+{
+	static struct cma_allocator alloc = {
+		.name    = "bf",
+		.init    = cma_bf_init,
+		.cleanup = cma_bf_cleanup,
+		.alloc   = cma_bf_alloc,
+		.free    = cma_bf_free,
+	};
+	return cma_allocator_register(&alloc);
+}
+module_init(cma_bf_module_init);
diff --git a/mm/cma.c b/mm/cma.c
new file mode 100644
index 0000000..ba9adb7
--- /dev/null
+++ b/mm/cma.c
@@ -0,0 +1,911 @@
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
+
+#include <linux/cma.h>
+
+
+/*
+ * Protects cma_regions, cma_allocators, cma_map, cma_map_length, and
+ * cma_chunks_by_start.
+ */
+static DEFINE_MUTEX(cma_mutex);
+
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
+
+/************************* Early regions *************************/
+
+struct list_head cma_early_regions __initdata =
+	LIST_HEAD_INIT(cma_early_regions);
+
+
+int __init __must_check cma_early_region_register(struct cma_region *reg)
+{
+	dma_addr_t start, alignment;
+	size_t size;
+
+	if (reg->alignment & (reg->alignment - 1))
+		return -EINVAL;
+
+	alignment = max(reg->alignment, (dma_addr_t)PAGE_SIZE);
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
+	/* alloc->users = 0; */
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
+
+int __init cma_early_region_reserve(struct cma_region *reg)
+{
+	int tried = 0;
+
+	if (!reg->size || (reg->alignment & (reg->alignment - 1)) ||
+	    reg->reserved)
+		return -EINVAL;
+
+#ifndef CONFIG_NO_BOOTMEM
+
+	tried = 1;
+
+	{
+		void *ptr = __alloc_bootmem_nopanic(reg->size, reg->alignment,
+						    reg->start);
+		if (ptr) {
+			reg->start = virt_to_phys(ptr);
+			reg->reserved = 1;
+			return 0;
+		}
+	}
+
+#endif
+
+#ifdef CONFIG_HAVE_MEMBLOCK
+
+	tried = 1;
+
+	if (reg->start) {
+		if (memblock_is_region_reserved(reg->start, reg->size) < 0 &&
+		    memblock_reserve(reg->start, reg->size) >= 0) {
+			reg->reserved = 1;
+			return 0;
+		}
+	} else {
+		/*
+		 * Use __memblock_alloc_base() since
+		 * memblock_alloc_base() panic()s.
+		 */
+		u64 ret = __memblock_alloc_base(reg->size, reg->alignment, 0);
+		if (ret &&
+		    ret < ~(dma_addr_t)0 &&
+		    ret + reg->size < ~(dma_addr_t)0 &&
+		    ret + reg->size > ret) {
+			reg->start = ret;
+			reg->reserved = 1;
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
+				 (void *)reg->size, (void *)reg->start);
+			reg->reserved = 1;
+		} else {
+			pr_warn("init: %s: unable to reserve %p@%p/%p\n",
+				reg->name ?: "(private)",
+				(void *)reg->size, (void *)reg->start,
+				(void *)reg->alignment);
+		}
+	}
+}
+
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
+
+/************************* Chunks *************************/
+
+/* All chunks sorted by start address. */
+static struct rb_root cma_chunks_by_start;
+
+static struct cma_chunk *__must_check __cma_chunk_find(dma_addr_t addr)
+{
+	struct cma_chunk *chunk;
+	struct rb_node *n;
+
+	for (n = cma_chunks_by_start.rb_node; n; ) {
+		chunk = rb_entry(n, struct cma_chunk, by_start);
+		if (addr < chunk->start)
+			n = n->rb_left;
+		else if (addr > chunk->start)
+			n = n->rb_right;
+		else
+			return chunk;
+	}
+	WARN(1, KERN_WARNING "no chunk starting at %p\n", (void *)addr);
+	return NULL;
+}
+
+static int __must_check __cma_chunk_insert(struct cma_chunk *chunk)
+{
+	struct rb_node **new, *parent = NULL;
+	typeof(chunk->start) addr = chunk->start;
+
+	for (new = &cma_chunks_by_start.rb_node; *new; ) {
+		struct cma_chunk *c =
+			container_of(*new, struct cma_chunk, by_start);
+
+		parent = *new;
+		if (addr < c->start) {
+			new = &(*new)->rb_left;
+		} else if (addr > c->start) {
+			new = &(*new)->rb_right;
+		} else {
+			/*
+			 * We should never be here.  If we are it
+			 * means allocator gave us an invalid chunk
+			 * (one that has already been allocated) so we
+			 * refuse to accept it.  Our caller will
+			 * recover by freeing the chunk.
+			 */
+			WARN_ON(1);
+			return -EADDRINUSE;
+		}
+	}
+
+	rb_link_node(&chunk->by_start, parent, new);
+	rb_insert_color(&chunk->by_start, &cma_chunks_by_start);
+
+	return 0;
+}
+
+static void __cma_chunk_free(struct cma_chunk *chunk)
+{
+	rb_erase(&chunk->by_start, &cma_chunks_by_start);
+
+	chunk->reg->alloc->free(chunk);
+	--chunk->reg->users;
+	chunk->reg->free_space += chunk->size;
+}
+
+
+/************************* The Device API *************************/
+
+static const char *__must_check
+__cma_where_from(const struct device *dev, const char *type);
+
+
+/* Allocate. */
+
+static dma_addr_t __must_check
+__cma_alloc_from_region(struct cma_region *reg,
+			size_t size, dma_addr_t alignment)
+{
+	struct cma_chunk *chunk;
+
+	pr_debug("allocate %p/%p from %s\n",
+		 (void *)size, (void *)alignment,
+		 reg ? reg->name ?: "(private)" : "(null)");
+
+	if (!reg || reg->free_space < size)
+		return -ENOMEM;
+
+	if (!reg->alloc) {
+		if (!reg->used)
+			__cma_region_attach_alloc(reg);
+		if (!reg->alloc)
+			return -ENOMEM;
+	}
+
+	chunk = reg->alloc->alloc(reg, size, alignment);
+	if (!chunk)
+		return -ENOMEM;
+
+	if (unlikely(__cma_chunk_insert(chunk) < 0)) {
+		/* We should *never* be here. */
+		chunk->reg->alloc->free(chunk);
+		kfree(chunk);
+		return -EADDRINUSE;
+	}
+
+	chunk->reg = reg;
+	++reg->users;
+	reg->free_space -= chunk->size;
+	pr_debug("allocated at %p\n", (void *)chunk->start);
+	return chunk->start;
+}
+
+dma_addr_t __must_check
+cma_alloc_from_region(struct cma_region *reg,
+		      size_t size, dma_addr_t alignment)
+{
+	dma_addr_t addr;
+
+	pr_debug("allocate %p/%p from %s\n",
+		 (void *)size, (void *)alignment,
+		 reg ? reg->name ?: "(private)" : "(null)");
+
+	if (!size || alignment & (alignment - 1) || !reg)
+		return -EINVAL;
+
+	mutex_lock(&cma_mutex);
+
+	addr = reg->registered ?
+		__cma_alloc_from_region(reg, PAGE_ALIGN(size),
+					max(alignment, (dma_addr_t)PAGE_SIZE)) :
+		-EINVAL;
+
+	mutex_unlock(&cma_mutex);
+
+	return addr;
+}
+EXPORT_SYMBOL_GPL(cma_alloc_from_region);
+
+dma_addr_t __must_check
+__cma_alloc(const struct device *dev, const char *type,
+	    dma_addr_t size, dma_addr_t alignment)
+{
+	struct cma_region *reg;
+	const char *from;
+	dma_addr_t addr;
+
+	if (dev)
+		pr_debug("allocate %p/%p for %s/%s\n",
+			 (void *)size, (void *)alignment,
+			 dev_name(dev), type ?: "");
+
+	if (!size || alignment & (alignment - 1))
+		return -EINVAL;
+
+	size = PAGE_ALIGN(size);
+	if (alignment < PAGE_SIZE)
+		alignment = PAGE_SIZE;
+
+	mutex_lock(&cma_mutex);
+
+	from = __cma_where_from(dev, type);
+	if (unlikely(IS_ERR(from))) {
+		addr = PTR_ERR(from);
+		goto done;
+	}
+
+	pr_debug("allocate %p/%p from one of %s\n",
+		 (void *)size, (void *)alignment, from);
+
+	while (*from && *from != ';') {
+		reg = __cma_region_find(&from);
+		addr = __cma_alloc_from_region(reg, size, alignment);
+		if (!IS_ERR_VALUE(addr))
+			goto done;
+	}
+
+	pr_debug("not enough memory\n");
+	addr = -ENOMEM;
+
+done:
+	mutex_unlock(&cma_mutex);
+
+	return addr;
+}
+EXPORT_SYMBOL_GPL(__cma_alloc);
+
+
+/* Query information about regions. */
+static void __cma_info_add(struct cma_info *infop, struct cma_region *reg)
+{
+	infop->total_size += reg->size;
+	infop->free_size += reg->free_space;
+	if (infop->lower_bound > reg->start)
+		infop->lower_bound = reg->start;
+	if (infop->upper_bound < reg->start + reg->size)
+		infop->upper_bound = reg->start + reg->size;
+	++infop->count;
+}
+
+int
+__cma_info(struct cma_info *infop, const struct device *dev, const char *type)
+{
+	struct cma_info info = { ~(dma_addr_t)0, 0, 0, 0, 0 };
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
+		if (reg)
+			__cma_info_add(&info, reg);
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
+
+/* Freeing. */
+int cma_free(dma_addr_t addr)
+{
+	struct cma_chunk *c;
+	int ret;
+
+	mutex_lock(&cma_mutex);
+
+	c = __cma_chunk_find(addr);
+
+	if (c) {
+		__cma_chunk_free(c);
+		ret = 0;
+	} else {
+		ret = -ENOENT;
+	}
+
+	mutex_unlock(&cma_mutex);
+
+	pr_debug("free(%p): %s\n", (void *)addr, c ? "freed" : "not found");
+	return ret;
+}
+EXPORT_SYMBOL_GPL(cma_free);
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
+		/* ++alloc->users; */
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
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
