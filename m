From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
Date: Tue, 20 Jul 2010 17:51:25 +0200
Message-ID: <adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com>
References: <cover.1279639238.git.m.nazarewicz@samsung.com>
 <d6d104950c1391eaf3614d56615617cee5722fb4.1279639238.git.m.nazarewicz@samsung.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <d6d104950c1391eaf3614d56615617cee5722fb4.1279639238.git.m.nazarewicz@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-mm@kvack.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Pawel Osciak <p.osciak@samsung.com>, Xiaolin Zhang <xiaolin.zhang@intel.com>, Hiremath Vaibhav <hvaibhav@ti.com>, Robert Fekete <robert.fekete@stericsson.com>, Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, Michal Nazarewicz <m.nazarewicz@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>
List-Id: linux-mm.kvack.org

The Contiguous Memory Allocator framework is a set of APIs for
allocating physically contiguous chunks of memory.

Various chips require contiguous blocks of memory to operate.  Those
chips include devices such as cameras, hardware video decoders and
encoders, etc.

The code is highly modular and customisable to suit the needs of
various users.  Set of regions reserved for CMA can be configured on
run-time and it is easy to add custom allocator algorithms if one
has such need.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
Reviewed-by: Pawel Osciak <p.osciak@samsung.com>
---
 Documentation/cma.txt               |  435 +++++++++++++++++++
 Documentation/kernel-parameters.txt |    7 +
 include/linux/cma-int.h             |  183 ++++++++
 include/linux/cma.h                 |   92 ++++
 mm/Kconfig                          |   41 ++
 mm/Makefile                         |    3 +
 mm/cma-allocators.h                 |   42 ++
 mm/cma-best-fit.c                   |  360 ++++++++++++++++
 mm/cma.c                            |  778 +++++++++++++++++++++++++++++++++++
 9 files changed, 1941 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/cma.txt
 create mode 100644 include/linux/cma-int.h
 create mode 100644 include/linux/cma.h
 create mode 100644 mm/cma-allocators.h
 create mode 100644 mm/cma-best-fit.c
 create mode 100644 mm/cma.c

diff --git a/Documentation/cma.txt b/Documentation/cma.txt
new file mode 100644
index 0000000..7edc20a
--- /dev/null
+++ b/Documentation/cma.txt
@@ -0,0 +1,435 @@
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
+    2. CMA allows a run-time configuration of the memory regions it
+       will use to allocate chunks of memory from.  The set of memory
+       regions is given on command line so it can be easily changed
+       without the need for recompiling the kernel.
+
+       Each region has it's own size, alignment demand, a start
+       address (physical address where it should be placed) and an
+       allocator algorithm assigned to the region.
+
+       This means that there can be different algorithms running at
+       the same time, if different devices on the platform have
+       distinct memory usage characteristics and different algorithm
+       match those the best way.
+
+    3. When requesting memory, devices have to introduce themselves.
+       This way CMA knows who the memory is allocated for.  This
+       allows for the system architect to specify which memory regions
+       each device should use.
+
+       3a. Devices can also specify a "kind" of memory they want.
+           This makes it possible to configure the system in such
+           a way, that a single device may get memory from different
+           memory regions, depending on the "kind" of memory it
+           requested.  For example, a video codec driver might want to
+           allocate some shared buffers from the first memory bank and
+           the other from the second to get the highest possible
+           memory throughput.
+
+** Use cases
+
+    Lets analyse some imaginary system that uses the CMA to see how
+    the framework can be used and configured.
+
+
+    We have a platform with a hardware video decoder and a camera each
+    needing 20 MiB of memory in worst case.  Our system is written in
+    such a way though that the two devices are never used at the same
+    time and memory for them may be shared.  In such a system the
+    following two command line arguments would be used:
+
+        cma=r=20M cma_map=video,camera=r
+
+    The first instructs CMA to allocate a region of 20 MiB and use the
+    first available memory allocator on it.  The second, that drivers
+    named "video" and "camera" are to be granted memory from the
+    previously defined region.
+
+    We can see, that because the devices share the same region of
+    memory, we save 20 MiB of memory, compared to the situation when
+    each of the devices would reserve 20 MiB of memory for itself.
+
+
+    However, after some development of the system, it can now run
+    video decoder and camera at the same time.  The 20 MiB region is
+    no longer enough for the two to share.  A quick fix can be made to
+    grant each of those devices separate regions:
+
+        cma=v=20M,c=20M cma_map=video=v;camera=c
+
+    This solution also shows how with CMA you can assign private pools
+    of memory to each device if that is required.
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
+        cma=r=30M:na cma_map=video,camera=r
+
+    This shows how you can develop your own allocation algorithms if
+    the ones provided with CMA do not suit your needs and easily
+    replace them, without the need to modify CMA core or even
+    recompiling the kernel.
+
+** Technical Details
+
+*** The command line parameters
+
+    As shown above, CMA is configured from command line via two
+    arguments: "cma" and "cma_map".  The first one specifies regions
+    that are to be reserved for CMA.  The second one specifies what
+    regions each device is assigned to.
+
+    The format of the "cma" parameter is as follows:
+
+        cma          ::=  "cma=" regions [ ';' ]
+        regions      ::= region [ ';' regions ]
+
+        region       ::= reg-name
+                           '=' size
+                         [ '@' start ]
+                         [ '/' alignment ]
+                         [ ':' [ alloc-name ] [ '(' alloc-params ')' ] ]
+
+        reg-name     ::= a sequence of letters and digits
+                                   // name of the region
+
+        size         ::= memsize   // size of the region
+        start        ::= memsize   // desired start address of
+                                   // the region
+        alignment    ::= memsize   // alignment of the start
+                                   // address of the region
+
+        alloc-name   ::= a non-empty sequence of letters and digits
+                     // name of an allocator that will be used
+                     // with the region
+        alloc-params ::= a sequence of chars other then ')' and ';'
+                     // optional parameters for the allocator
+
+        memsize      ::= whatever memparse() accepts
+
+    The format of the "cma_map" parameter is as follows:
+
+        cma-map      ::=  "cma_map=" rules [ ';' ]
+        rules        ::= rule [ ';' rules ]
+        rule         ::= patterns '=' regions
+        patterns     ::= pattern [ ',' patterns ]
+
+        regions      ::= reg-name [ ',' regions ]
+                     // list of regions to try to allocate memory
+                     // from for devices that match pattern
+
+        pattern      ::= dev-pattern [ '/' kind-pattern ]
+                       | '/' kind-pattern
+                     // pattern request must match for this rule to
+                     // apply to it; the first rule that matches is
+                     // applied; if dev-pattern part is omitted
+                     // value identical to the one used in previous
+                     // pattern is assumed
+
+        dev-pattern  ::= pattern-str
+                     // pattern that device name must match for the
+                     // rule to apply.
+        kind-pattern ::= pattern-str
+                     // pattern that "kind" of memory (provided by
+                     // device) must match for the rule to apply.
+
+        pattern-str  ::= a non-empty sequence of characters with '?'
+                         meaning any character and possible '*' at
+                         the end meaning to match the rest of the
+                         string
+
+    Some examples (whitespace added for better readability):
+
+        cma = r1 = 64M       // 64M region
+                   @512M       // starting at address 512M
+                               // (or at least as near as possible)
+                   /1M         // make sure it's aligned to 1M
+                   :foo(bar);  // uses allocator "foo" with "bar"
+                               // as parameters for it
+              r2 = 64M       // 64M region
+                   /1M;        // make sure it's aligned to 1M
+                               // uses the first available allocator
+              r3 = 64M       // 64M region
+                   @512M       // starting at address 512M
+                   :foo;       // uses allocator "foo" with no parameters
+
+        cma_map = foo = r1;
+                      // device foo with kind==NULL uses region r1
+
+                  foo/quaz = r2;  // OR:
+                  /quaz = r2;
+                      // device foo with kind == "quaz" uses region r2
+
+                  foo/* = r3;     // OR:
+                  /* = r3;
+                      // device foo with any other kind uses region r3
+
+                  bar/* = r1,r2;
+                      // device bar with any kind uses region r1 or r2
+
+                  baz?/a* , baz?/b* = r3;
+                      // devices named baz? where ? is any character
+                      // with kind being a string starting with "a" or
+                      // "b" use r3
+
+
+*** The device and kind of memory
+
+    The name of the device is taken form the device structure.  It is
+    not possible to use CMA if driver does not register a device
+    (actually this can be overcome if a fake device structure is
+    provided with at least the name set).
+
+    The kind of memory is an optional argument provided by the device
+    whenever it requests memory chunk.  In many cases this can be
+    ignored but sometimes it may be required for some devices.
+
+    For instance, let say that there are two memory banks and for
+    performance reasons a device uses buffers in both of them.  In
+    such case, the device driver would define two kinds and use it for
+    different buffers.  Command line arguments could look as follows:
+
+            cma=a=32M@0,b=32M@512M cma_map=foo/a=a;foo/b=b
+
+    And whenever the driver allocated the memory it would specify the
+    kind of memory:
+
+            buffer1 = cma_alloc(dev, 1 << 20, 0, "a");
+            buffer2 = cma_alloc(dev, 1 << 20, 0, "b");
+
+    If it was needed to try to allocate from the other bank as well if
+    the dedicated one is full command line arguments could be changed
+    to:
+
+            cma=a=32M@0,b=32M@512M cma_map=foo/a=a,b;foo/b=b,a
+
+    On the other hand, if the same driver was used on a system with
+    only one bank, the command line could be changed to:
+
+            cma=r=64M cma_map=foo/*=r
+
+    without the need to change the driver at all.
+
+*** API
+
+    There are four calls provided by the CMA framework to devices.  To
+    allocate a chunk of memory cma_alloc() function needs to be used:
+
+            unsigned long cma_alloc(const struct device *dev,
+                                    const char *kind,
+                                    unsigned long size,
+                                    unsigned long alignment);
+
+    If required, device may specify alignment that the chunk need to
+    satisfy.  It have to be a power of two or zero.  The chunks are
+    always aligned at least to a page.
+
+    The kind specifies the kind of memory as described to in the
+    previous subsection.  If device driver does not use notion of
+    memory kinds it's safe to pass NULL as the kind.
+
+    The basic usage of the function is just a:
+
+            addr = cma_alloc(dev, NULL, size, 0);
+
+    The function returns physical address of allocated chunk or
+    a value that evaluated true if checked with IS_ERR_VALUE(), so the
+    correct way for checking for errors is:
+
+            unsigned long addr = cma_alloc(dev, size);
+            if (IS_ERR_VALUE(addr))
+                    return (int)addr;
+            /* Allocated */
+
+    (Make sure to include <linux/err.h> which contains the definition
+    of the IS_ERR_VALUE() macro.)
+
+
+    Allocated chunk is freed via a cma_put() function:
+
+            int cma_put(unsigned long addr);
+
+    It takes physical address of the chunk as an argument and
+    decreases it's reference counter.  If the counter reaches zero the
+    chunk is freed.  Most of the time users do not need to think about
+    reference counter and simply use the cma_put() as a free call.
+
+    If one, however, were to share a chunk with others built in
+    reference counter may turn out to be handy.  To increment it, one
+    needs to use cma_get() function:
+
+            int cma_put(unsigned long addr);
+
+
+    The last function is the cma_info() which returns information
+    about regions assigned to given (dev, kind) pair.  Its syntax is:
+
+            int cma_info(struct cma_info *info,
+                         const struct device *dev,
+                         const char *kind);
+
+    On successful exit it fills the info structure with lower and
+    upper bound of regions, total size and number of regions assigned
+    to given (dev, kind) pair.
+
+*** Allocator operations
+
+    Creating an allocator for CMA needs four functions to be
+    implemented.
+
+
+    The first two are used to initialise an allocator far given driver
+    and clean up afterwards:
+
+            int  cma_foo_init(struct cma_region *reg);
+            void cma_foo_done(struct cma_region *reg);
+
+    The first is called during platform initialisation.  The
+    cma_region structure has saved starting address of the region as
+    well as its size.  It has also alloc_params field with optional
+    parameters passed via command line (allocator is free to interpret
+    those in any way it pleases).  Any data that allocate associated
+    with the region can be saved in private_data field.
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
+            struct cma_chunk *cma_foo_alloc(struct cma_region *reg,
+                                            unsigned long size,
+                                            unsigned long alignment);
+            void cma_foo_free(struct cma_chunk *chunk);
+
+    As names imply the first allocates a chunk and the other frees
+    a chunk of memory.  It also manages a cma_chunk object
+    representing the chunk in physical memory.
+
+    Either of those function can assume that they are the only thread
+    accessing the region.  Therefore, allocator does not need to worry
+    about concurrency.
+
+
+    When allocator is ready, all that is left is register it by adding
+    a line to "mm/cma-allocators.h" file:
+
+            CMA_ALLOCATOR("foo", foo)
+
+    The first "foo" is a named that will be available to use with
+    command line argument.  The second is the part used in function
+    names.
+
+*** Integration with platform
+
+    There is one function that needs to be called form platform
+    initialisation code.  That is the cma_regions_allocate() function:
+
+            void cma_regions_allocate(int (*alloc)(struct cma_region *reg));
+
+    It traverses list of all of the regions given on command line and
+    reserves memory for them.  The only argument is a callback
+    function used to reserve the region.  Passing NULL as the argument
+    makes the function use cma_region_alloc() function which uses
+    bootmem for allocating.
+
+    Alternatively, platform code could traverse the cma_regions array
+    by itself but this should not be necessary.
+
+    The If cma_region_alloc() allocator is used, the
+    cma_regions_allocate() function needs to be allocated when bootmem
+    is active.
+
+
+    Platform has also a way of providing default cma and cma_map
+    parameters.  cma_defaults() function is used for that purpose:
+
+            int cma_defaults(const char *cma, const char *cma_map)
+
+    It needs to be called after early params have been parsed but
+    prior to allocating regions.  Arguments of this function are used
+    only if they are not-NULL and respective command line argument was
+    not provided.
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
diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index a6a3fcb..de1a522 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -43,6 +43,7 @@ parameter is applicable:
 	AVR32	AVR32 architecture is enabled.
 	AX25	Appropriate AX.25 support is enabled.
 	BLACKFIN Blackfin architecture is enabled.
+	CMA	Contiguous Memory Allocator is enabled.
 	DRM	Direct Rendering Management support is enabled.
 	EDD	BIOS Enhanced Disk Drive Services (EDD) is enabled
 	EFI	EFI Partitioning (GPT) is enabled
@@ -476,6 +477,12 @@ and is between 256 and 4096 characters. It is defined in the file
 			Also note the kernel might malfunction if you disable
 			some critical bits.
 
+	cma=		[CMA] List of CMA regions.
+			See Documentation/cma.txt for details.
+
+	cma_map=	[CMA] List of CMA mapping rules.
+			See Documentation/cma.txt for details.
+
 	cmo_free_hint=	[PPC] Format: { yes | no }
 			Specify whether pages are marked as being inactive
 			when they are freed.  This is used in CMO environments
diff --git a/include/linux/cma-int.h b/include/linux/cma-int.h
new file mode 100644
index 0000000..b588e9b
--- /dev/null
+++ b/include/linux/cma-int.h
@@ -0,0 +1,183 @@
+#ifndef __LINUX_CMA_INT_H
+#define __LINUX_CMA_INT_H
+
+#ifdef CONFIG_CMA
+
+/*
+ * Contiguous Memory Allocator framework: internal header
+ * Copyright (c) 2010 by Samsung Electronics.
+ * Written by Michal Nazarewicz (m.nazarewicz@samsung.com)
+ */
+
+/*
+ * See Documentation/cma.txt for documentation.
+ */
+
+#include <linux/kref.h>
+#include <linux/mutex.h>
+#include <linux/rbtree.h>
+
+struct cma_allocator;
+
+/**
+ * struct cma_region - a region reserved for CMA allocations.
+ * @name:	Unique name of the region.  Passed with cmdline.  Read only.
+ * @start:	Physical starting address of the region in bytes.  Always
+ * 		aligned to the value specified by @alignment.  Initialised
+ * 		from value read from cmdline.  Read only for allocators.
+ * 		Read write for platform-specific region allocation code.
+ * @size:	Physical size of the region in bytes.  At least page
+ * 		aligned.  Initialised with value read from cmdline.  Read
+ * 		only for allocators.  Read write for platform-specific region
+ * 		allocation code.
+ * @alignment:	Desired alignment of the region.  A power of two, greater or\
+ * 		equal PAGE_SIZE.  Initialised from value read from cmdline.
+ * 		Read only.
+ * @alloc:	Allocator used with this region.  NULL means region is not
+ * 		allocated.  Read only.
+ * @alloc_name:	Allocator name read from cmdline.  Private.
+ * @alloc_params:	Allocator-specific parameters read from cmdline.
+ * 			Read only for allocator.
+ * @private_data:	Allocator's private data.
+ * @users:	Number of chunks allocated in this region.
+ * @mutex:	Guarantees that only one allocation/deallocation on given
+ * 		region is performed.
+ */
+struct cma_region {
+	const char *name;
+	unsigned long start;
+	unsigned long size, free_space;
+	unsigned long alignment;
+
+	struct cma_allocator *alloc;
+	const char *alloc_name;
+	const char *alloc_params;
+	void *private_data;
+
+	unsigned users;
+	/*
+	 * Protects the "users" and "free_space" fields and any calls
+	 * to allocator on this region thus guarantees only one call
+	 * to allocator will operate on this region..
+	 */
+	struct mutex mutex;
+};
+
+/**
+ * struct cma_chunk - an allocated contiguous chunk of memory.
+ * @start:	Physical address in bytes.
+ * @size:	Size in bytes.
+ * @free_space:	Free space in region in bytes.  Read only.
+ * @reg:	Region this chunk belongs to.
+ * @kref:	Number of references.  Private.
+ * @by_start:	A node in an red-black tree with all chunks sorted by
+ * 		start address.
+ *
+ * The cma_allocator::alloc() operation need to set only the @start
+ * and @size fields.  The rest is handled by the caller (ie. CMA
+ * glue).
+ */
+struct cma_chunk {
+	unsigned long start;
+	unsigned long size;
+
+	struct cma_region *reg;
+	struct kref ref;
+	struct rb_node by_start;
+};
+
+
+/**
+ * struct cma_allocator - a CMA allocator.
+ * @name:	Allocator's unique name
+ * @init:	Initialises a allocator on given region.  May not sleep.
+ * @cleanup:	Cleans up after init.  May assume that there are no chunks
+ * 		allocated in given region.  May not sleep.
+ * @alloc:	Allocates a chunk of memory of given size in bytes and
+ * 		with given alignment.  Alignment is a power of
+ * 		two (thus non-zero) and callback does not need to check it.
+ * 		May also assume that it is the only call that uses given
+ * 		region (ie. access to the region is synchronised with
+ * 		a mutex).  This has to allocate the chunk object (it may be
+ * 		contained in a bigger structure with allocator-specific data.
+ * 		May sleep.
+ * @free:	Frees allocated chunk.  May also assume that it is the only
+ * 		call that uses given region.  This has to kfree() the chunk
+ * 		object as well.  May sleep.
+ */
+struct cma_allocator {
+	const char *name;
+	int (*init)(struct cma_region *reg);
+	void (*cleanup)(struct cma_region *reg);
+	struct cma_chunk *(*alloc)(struct cma_region *reg, unsigned long size,
+				   unsigned long alignment);
+	void (*free)(struct cma_chunk *chunk);
+};
+
+
+/**
+ * cma_region - a list of regions filled when parameters are parsed.
+ *
+ * This is terminated by an zero-sized entry (ie. an entry which size
+ * field is zero).  Platform needs to allocate space for each of the
+ * region before initcalls are executed.
+ */
+extern struct cma_region cma_regions[];
+
+
+/**
+ * cma_defaults() - specifies default command line parameters.
+ * @cma:	Default cma parameter if one was not specified via command
+ * 		line.
+ * @cma_map:	Default cma_map parameter if one was not specified via
+ * 		command line.
+ *
+ * This function should be called prior to cma_regions_allocate() and
+ * after early parameters have been parsed.  The @cma argument is only
+ * used if there was no cma argument passed on command line.  The same
+ * goes for @cma_map which is used only if cma_map was not passed on
+ * command line.
+ *
+ * Either of the argument may be NULL.
+ *
+ * Returns negative error code if there was an error parsing either of
+ * the parameters or zero.
+ */
+int __init cma_defaults(const char *cma, const char *cma_map);
+
+
+/**
+ * cma_region_alloc() - allocates a physically contiguous memory region.
+ * @reg:	Region to allocate memory for.
+ *
+ * If platform supports bootmem this is the first allocator this
+ * function tries to use.  If that failes (or bootmem is not
+ * supported) function tries to use memblec if it is available.
+ *
+ * Returns zero or negative error.
+ */
+int __init cma_region_alloc(struct cma_region *reg);
+
+/**
+ * cma_regions_allocate() - helper function for allocating regions.
+ * @alloc:	Region allocator.  Needs to return non-negative if
+ * 		allocation succeeded, negative error otherwise.  NULL
+ * 		means cma_region_alloc() should be used.
+ *
+ * This function traverses the cma_regions array and tries to reserve
+ * memory for each region.  It uses the @alloc callback function for
+ * that purpose.  If allocation failes for a given region, it is
+ * removed from the array (by shifting all the elements after it).
+ *
+ * Returns number of reserved regions.
+ */
+int __init cma_regions_allocate(int (*alloc)(struct cma_region *reg));
+
+#else
+
+#define cma_regions_allocate(alloc) ((int)0)
+
+#endif
+
+
+#endif
diff --git a/include/linux/cma.h b/include/linux/cma.h
new file mode 100644
index 0000000..aef8347
--- /dev/null
+++ b/include/linux/cma.h
@@ -0,0 +1,92 @@
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
+ * See Documentation/cma.txt for documentation.
+ */
+
+#ifdef __KERNEL__
+
+struct device;
+
+/**
+ * cma_alloc() - allocates contiguous chunk of memory.
+ * @dev:	The device to perform allocation for.
+ * @kind:	A kind of memory to allocate.  A device may use several
+ * 		different kinds of memory which are configured
+ * 		separately.  Usually it's safe to pass NULL here.
+ * @size:	Size of the memory to allocate in bytes.
+ * @alignment:	Desired alignment.  Must be a power of two or zero.  If
+ * 		alignment is less then a page size it will be set to
+ * 		page size. If unsure, pass zero here.
+ *
+ * On error returns a negative error cast to unsigned long.  Use
+ * IS_ERR_VALUE() to check if returned value is indeed an error.
+ * Otherwise physical address of the chunk is returned.
+ */
+unsigned long __must_check
+cma_alloc(const struct device *dev, const char *kind,
+	  unsigned long size, unsigned long alignment);
+
+
+/**
+ * struct cma_info - information about regions returned by cma_info().
+ * @lower_bound:	The smallest address that is possible to be
+ * 			allocated for given (dev, kind) pair.
+ * @upper_bound:	The one byte after the biggest address that is
+ * 			possible to be allocated for given (dev, kind)
+ * 			pair.
+ * @total_size:	Total size of regions mapped to (dev, kind) pair.
+ * @count:	Number of regions mapped to (dev, kind) pair.
+ */
+struct cma_info {
+	unsigned long lower_bound, upper_bound;
+	unsigned long total_size;
+	unsigned count;
+};
+
+/**
+ * cma_info() - queries information about regions.
+ * @info:	Pointer to a structure where to save the information.
+ * @dev:	The device to query information for.
+ * @kind:	A kind of memory to query information for.
+ * 		If unsure, pass NULL here.
+ *
+ * On error returns a negative error, zero otherwise.
+ */
+int __must_check
+cma_info(struct cma_info *info, const struct device *dev, const char *kind);
+
+
+/**
+ * cma_get() - increases reference counter of a chunk.
+ * @addr:	Beginning of the chunk.
+ *
+ * Returns zero on success or -ENOENT if there is no chunk at given
+ * location.  In the latter case issues a warning and a stacktrace.
+ */
+int cma_get(unsigned long addr);
+
+/**
+ * cma_put() - decreases reference counter of a chunk.
+ * @addr:	Beginning of the chunk.
+ *
+ * Returns one if the chunk has been freed, zero if it hasn't, and
+ * -ENOENT if there is no chunk at given location.  In the latter case
+ * issues a warning and a stacktrace.
+ *
+ * If this function returns zero, you still can not count on the area
+ * remaining in memory.  Only use the return value if you want to see
+ * if the area is now gone, not present.
+ */
+int cma_put(unsigned long addr);
+
+#endif
+
+#endif
diff --git a/mm/Kconfig b/mm/Kconfig
index f4e516e..7841f77 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -301,3 +301,44 @@ config NOMMU_INITIAL_TRIM_EXCESS
 	  of 1 says that all excess pages should be trimmed.
 
 	  See Documentation/nommu-mmap.txt for more information.
+
+
+config ARCH_CMA_POSSIBLE
+	bool
+
+config ARCH_NEED_CMA_REGION_ALLOC
+	bool
+
+config CMA
+	bool "Contiguous Memory Allocator framework"
+	depends on ARCH_CMA_POSSIBLE
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
+	bool "CMA debug messages"
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
index 34b2546..54b0e99 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -47,3 +47,6 @@ obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
 obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
+
+obj-$(CONFIG_CMA) += cma.o
+obj-$(CONFIG_CMA_BEST_FIT) += cma-best-fit.o
diff --git a/mm/cma-allocators.h b/mm/cma-allocators.h
new file mode 100644
index 0000000..564f705
--- /dev/null
+++ b/mm/cma-allocators.h
@@ -0,0 +1,42 @@
+#ifdef __CMA_ALLOCATORS_H
+
+/* List all existing allocators here using CMA_ALLOCATOR macro. */
+
+#ifdef CONFIG_CMA_BEST_FIT
+CMA_ALLOCATOR("bf", bf)
+#endif
+
+
+#  undef CMA_ALLOCATOR
+#else
+#  define __CMA_ALLOCATORS_H
+
+/* Function prototypes */
+#  ifndef __LINUX_CMA_ALLOCATORS_H
+#    define __LINUX_CMA_ALLOCATORS_H
+#    define CMA_ALLOCATOR(name, infix)					\
+	extern int cma_ ## infix ## _init(struct cma_region *);		\
+	extern void cma_ ## infix ## _cleanup(struct cma_region *);	\
+	extern struct cma_chunk *					\
+	cma_ ## infix ## _alloc(struct cma_region *,			\
+			      unsigned long, unsigned long);		\
+	extern void cma_ ## infix ## _free(struct cma_chunk *);
+#    include "cma-allocators.h"
+#  endif
+
+/* The cma_allocators array */
+#  ifdef CMA_ALLOCATORS_LIST
+#    define CMA_ALLOCATOR(_name, infix) {		\
+		.name    = _name,			\
+		.init    = cma_ ## infix ## _init,	\
+		.cleanup = cma_ ## infix ## _cleanup,	\
+		.alloc   = cma_ ## infix ## _alloc,	\
+		.free    = cma_ ## infix ## _free,	\
+	},
+static struct cma_allocator cma_allocators[] = {
+#    include "cma-allocators.h"
+};
+#    undef CMA_ALLOCATOR_LIST
+#  endif
+#  undef __CMA_ALLOCATORS_H
+#endif
diff --git a/mm/cma-best-fit.c b/mm/cma-best-fit.c
new file mode 100644
index 0000000..0862a8d
--- /dev/null
+++ b/mm/cma-best-fit.c
@@ -0,0 +1,360 @@
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
+#include <linux/cma-int.h>     /* CMA structures */
+
+#include "cma-allocators.h"    /* Prototypes */
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
+static void __cma_bf_hole_insert_by_start(struct cma_bf_item *item);
+static void __cma_bf_hole_erase_by_start(struct cma_bf_item *item);
+
+/**
+ * __cma_bf_hole_take() - takes a chunk of memory out of a hole.
+ * @hole:	hole to take chunk from
+ * @size	chunk's size
+ * @alignment:	chunk's starting address alignment (must be power of two)
+ *
+ * Takes a @size bytes large chunk from hole @hole which must be able
+ * to hold the chunk.  The "must be able" includes also alignment
+ * constraint.
+ *
+ * Returns allocated item or NULL on error (if kmalloc() failed).
+ */
+static struct cma_bf_item *__must_check
+__cma_bf_hole_take(struct cma_bf_item *hole, size_t size, size_t alignment);
+
+/**
+ * __cma_bf_hole_merge_maybe() - tries to merge hole with neighbours.
+ *
+ * @item hole to try and merge
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
+	prv = kzalloc(sizeof *prv, GFP_NOWAIT);
+	if (unlikely(!prv))
+		return -ENOMEM;
+
+	item = kzalloc(sizeof *item, GFP_NOWAIT);
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
+			       unsigned long size, unsigned long alignment)
+{
+	struct cma_bf_private *prv = reg->private_data;
+	struct rb_node *node = prv->by_size_root.rb_node;
+	struct cma_bf_item *item = NULL;
+	unsigned long start, end;
+
+	/* First first item that is large enough */
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
+	if (unlikely(!item))
+		return NULL;
+
+	/* Now look for items which can satisfy alignment requirements */
+	for (;;) {
+		start = ALIGN(item->ch.start, alignment);
+		end   = item->ch.start + item->ch.size;
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
+	__cma_bf_hole_insert_by_size(item);
+	__cma_bf_hole_insert_by_start(item);
+
+	/* Merge with prev and next sibling */
+	__cma_bf_hole_merge_maybe(item);
+}
+
+
+/************************* Basic Tree Manipulation *************************/
+
+#define __CMA_BF_HOLE_INSERT(root, node, field) ({			\
+	bool equal = false;						\
+	struct rb_node **link = &(root).rb_node, *parent = NULL;	\
+	const unsigned long value = item->field;			\
+	while (*link) {							\
+		struct cma_bf_item *i;					\
+		parent = *link;						\
+		i = rb_entry(parent, struct cma_bf_item, node);		\
+		link = value <= i->field				\
+			? &parent->rb_left				\
+			: &parent->rb_right;				\
+		equal = equal || value == i->field;			\
+	}								\
+	rb_link_node(&item->node, parent, link);			\
+	rb_insert_color(&item->node, &root);				\
+	equal;								\
+})
+
+static void __cma_bf_hole_insert_by_size(struct cma_bf_item *item)
+{
+	struct cma_bf_private *prv = item->ch.reg->private_data;
+	(void)__CMA_BF_HOLE_INSERT(prv->by_size_root, by_size, ch.size);
+}
+
+static void __cma_bf_hole_erase_by_size(struct cma_bf_item *item)
+{
+	struct cma_bf_private *prv = item->ch.reg->private_data;
+	rb_erase(&item->by_size, &prv->by_size_root);
+}
+
+static void __cma_bf_hole_insert_by_start(struct cma_bf_item *item)
+{
+	struct cma_bf_private *prv = item->ch.reg->private_data;
+	/*
+	 * __CMA_BF_HOLE_INSERT returns true if there was another node
+	 * with the same value encountered.  This should never happen
+	 * for start address and so we produce a warning.
+	 *
+	 * It's really some kind of bug if we got to such situation
+	 * and things may start working incorrectly.  Nonetheless,
+	 * there is not much we can do other then screaming as loud as
+	 * we can hoping someone will notice the bug and fix it.
+	 */
+	WARN_ON(__CMA_BF_HOLE_INSERT(prv->by_start_root, ch.by_start,
+				     ch.start));
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
+		struct cma_bf_item *next;
+
+		/*
+		 * Space between the end of the chunk and the end of
+		 * the region, ie. space left after the end of the
+		 * chunk.  If this is dividable by alignment we can
+		 * move the chunk to the end of the hole.
+		 */
+		unsigned long left =
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
+		next = kmalloc(sizeof *next, GFP_KERNEL);
+
+		if (unlikely(!next)) {
+			kfree(item);
+			return NULL;
+		}
+
+		next->ch.start = item->ch.start + item->ch.size;
+		next->ch.size  =
+			hole->ch.start + hole->ch.size - next->ch.start;
+		next->ch.reg   = hole->ch.reg;
+
+		__cma_bf_hole_insert_by_size(next);
+		__cma_bf_hole_insert_by_start(next);
+
+		hole->ch.size = next->ch.start - hole->ch.start;
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
diff --git a/mm/cma.c b/mm/cma.c
new file mode 100644
index 0000000..6a0942f
--- /dev/null
+++ b/mm/cma.c
@@ -0,0 +1,778 @@
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
+ * See Documentation/cma.txt for documentation.
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
+#include <linux/slab.h>        /* kmalloc() */
+#include <linux/string.h>      /* str*() */
+
+#include <linux/cma-int.h>     /* CMA structures */
+#include <linux/cma.h>         /* CMA Device API */
+
+
+#define CMA_MAX_REGIONS      16
+#define CMA_MAX_MAPPINGS     64
+#define CMA_MAX_PARAM_LEN   512
+
+
+/************************* Parse region list *************************/
+
+struct cma_region cma_regions[CMA_MAX_REGIONS + 1 /* 1 for zero-sized */];
+
+static char *__must_check __init
+cma_param_parse_entry(char *param, struct cma_region *reg)
+{
+	const char *name, *alloc = NULL, *alloc_params = NULL, *ch;
+	unsigned long long size, start = 0, alignment = 0;
+
+	/* Parse */
+	name = param;
+	param = strchr(param, '=');
+	if (!param) {
+		pr_err("param: expecting '=' near %s\n", name);
+		return NULL;
+	} else if (param == name) {
+		pr_err("param: empty region name near %s\n", name);
+		return NULL;
+	}
+	*param = '\0';
+	++param;
+
+	ch = param;
+	size = memparse(param, &param);
+	if (unlikely(!size || size > ULONG_MAX)) {
+		pr_err("param: invalid size near %s\n", ch);
+		return NULL;
+	}
+
+
+	if (*param == '@') {
+		ch = param;
+		start = memparse(param + 1, &param);
+		if (unlikely(start > ULONG_MAX)) {
+			pr_err("param: invalid start near %s\n", ch);
+			return NULL;
+		}
+	}
+
+	if (*param == '/') {
+		ch = param;
+		alignment = memparse(param + 1, &param);
+		if (unlikely(alignment > ULONG_MAX ||
+			     (alignment & (alignment - 1)))) {
+			pr_err("param: invalid alignment near %s\n", ch);
+			return NULL;
+		}
+	}
+
+	if (*param == ':') {
+		alloc = ++param;
+		while (*param && *param != '(' && *param != ';')
+			++param;
+
+		if (*param == '(') {
+			*param = '\0';
+			alloc_params = ++param;
+			param = strchr(param, ')');
+			if (!param) {
+				pr_err("param: expecting ')' near %s\n", param);
+				return NULL;
+			}
+			*param++ = '\0';
+		}
+	}
+
+	if (*param == ';') {
+		*param = '\0';
+		++param;
+	} else if (*param) {
+		pr_err("param: expecting ';' or end of parameter near %s\n",
+		       param);
+		return NULL;
+	}
+
+	/* Save */
+	alignment         = alignment ? PAGE_ALIGN(alignment) : PAGE_SIZE;
+	start             = ALIGN(start, alignment);
+	size              = PAGE_ALIGN(size);
+	reg->name         = name;
+	reg->start        = start;
+	reg->size         = size;
+	reg->free_space   = size;
+	reg->alignment    = alignment;
+	reg->alloc_name   = alloc && *alloc ? alloc : NULL;
+	reg->alloc_params = alloc_params;
+
+	return param;
+}
+
+/*
+ * cma          ::=  "cma=" regions [ ';' ]
+ * regions      ::= region [ ';' regions ]
+ *
+ * region       ::= reg-name
+ *                    '=' size
+ *                  [ '@' start ]
+ *                  [ '/' alignment ]
+ *                  [ ':' [ alloc-name ] [ '(' alloc-params ')' ] ]
+ *
+ * See Documentation/cma.txt for details.
+ *
+ * Example:
+ * cma=reg1=64M:bf;reg2=32M@0x100000:bf;reg3=64M/1M:bf
+ *
+ * If allocator is ommited the first available allocater will be used.
+ */
+
+static int __init cma_param_parse(char *param)
+{
+	static char buffer[CMA_MAX_PARAM_LEN];
+
+	unsigned left = ARRAY_SIZE(cma_regions);
+	struct cma_region *reg = cma_regions;
+
+	pr_debug("param: %s\n", param);
+
+	strlcpy(buffer, param, sizeof buffer);
+	for (param = buffer; *param; ++reg) {
+		if (unlikely(!--left)) {
+			pr_err("param: too many regions\n");
+			return -ENOSPC;
+		}
+
+		param = cma_param_parse_entry(param, reg);
+		if (unlikely(!param))
+			return -EINVAL;
+
+		pr_debug("param: adding region %s (%p@%p)\n",
+			 reg->name, (void *)reg->size, (void *)reg->start);
+	}
+	return 0;
+}
+early_param("cma", cma_param_parse);
+
+
+/************************* Parse dev->regions map *************************/
+
+static const char *cma_map[CMA_MAX_MAPPINGS + 1 /* 1 for NULL */];
+
+/*
+ * cma-map      ::=  "cma_map=" rules [ ';' ]
+ * rules        ::= rule [ ';' rules ]
+ * rule         ::= patterns '=' regions
+ * patterns     ::= pattern [ ',' patterns ]
+ *
+ * regions      ::= reg-name [ ',' regions ]
+ *              // list of regions to try to allocate memory
+ *              // from for devices that match pattern
+ *
+ * pattern      ::= dev-pattern [ '/' kind-pattern ]
+ *                | '/' kind-pattern
+ *              // pattern request must match for this rule to
+ *              // apply to it; the first rule that matches is
+ *              // applied; if dev-pattern part is omitted
+ *              // value identical to the one used in previous
+ *              // rule is assumed
+ *
+ * See Documentation/cma.txt for details.
+ *
+ * Example (white space added for convenience, forbidden in real string):
+ * cma_map = foo-dev = reg1;             -- foo-dev with no kind
+ *           bar-dev / firmware = reg3;  -- bar-dev's firmware
+ *           / * = reg2;                 -- bar-dev's all other kinds
+ *           baz-dev / * = reg1,reg2;    -- any kind of baz-dev
+ *           * / * = reg2,reg1;          -- any other allocations
+ */
+static int __init cma_map_param_parse(char *param)
+{
+	static char buffer[CMA_MAX_PARAM_LEN];
+
+	unsigned left = ARRAY_SIZE(cma_map) - 1;
+	const char **spec = cma_map;
+
+	pr_debug("map: %s\n", param);
+
+	strlcpy(buffer, param, sizeof buffer);
+	for (param = buffer; *param; ++spec) {
+		char *eq, *e;
+
+		if (!left--) {
+			pr_err("map: too many mappings\n");
+			return -ENOSPC;
+		}
+
+		e = strchr(param, ';');
+		if (e)
+			*e = '\0';
+
+		eq = strchr(param, '=');
+		if (unlikely(!eq)) {
+			pr_err("map: expecting '='\n");
+			cma_map[0] = NULL;
+			return -EINVAL;
+		}
+
+		*eq = '\0';
+		*spec = param;
+
+		pr_debug("map: adding: '%s' -> '%s'\n", param, eq + 1);
+
+		if (!e)
+			break;
+		param = e + 1;
+	}
+
+	return 0;
+}
+early_param("cma_map", cma_map_param_parse);
+
+
+/************************* Initialise CMA *************************/
+
+#define CMA_ALLOCATORS_LIST
+#include "cma-allocators.h"
+
+static struct cma_allocator *__must_check __init
+__cma_allocator_find(const char *name)
+{
+	size_t i = ARRAY_SIZE(cma_allocators);
+
+	if (i) {
+		struct cma_allocator *alloc = cma_allocators;
+
+		if (!name)
+			return alloc;
+
+		do {
+			if (!strcmp(alloc->name, name))
+				return alloc;
+			++alloc;
+		} while (--i);
+	}
+
+	return NULL;
+}
+
+
+int __init cma_defaults(const char *cma_str, const char *cma_map_str)
+{
+	int ret;
+
+	if (cma_str && !cma_regions->size) {
+		ret = cma_param_parse((char *)cma_str);
+		if (unlikely(ret))
+			return ret;
+	}
+
+	if (cma_map_str && !*cma_map) {
+		ret = cma_map_param_parse((char *)cma_map_str);
+		if (unlikely(ret))
+			return ret;
+	}
+
+	return 0;
+}
+
+
+int __init cma_region_alloc(struct cma_region *reg)
+{
+
+#ifndef CONFIG_NO_BOOTMEM
+
+	void *ptr;
+
+	ptr = __alloc_bootmem_nopanic(reg->size, reg->alignment, reg->start);
+	if (likely(ptr)) {
+		reg->start = virt_to_phys(ptr);
+		return 0;
+	}
+
+#endif
+
+#ifdef CONFIG_HAVE_MEMBLOCK
+
+	if (reg->start) {
+		if (memblock_is_region_reserved(reg->start, reg->size) < 0 &&
+		    memblock_reserve(reg->start, reg->size) >= 0)
+			return 0;
+	} else {
+		/*
+		 * Use __memblock_alloc_base() since
+		 * memblock_alloc_base() panic()s.
+		 */
+		u64 ret = __memblock_alloc_base(reg->size, reg->alignment, 0);
+		if (ret && ret < ULONG_MAX && ret + reg->size < ULONG_MAX) {
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
+	return -ENOMEM;
+}
+
+int __init cma_regions_allocate(int (*alloc)(struct cma_region *reg))
+{
+	struct cma_region *reg = cma_regions, *out = cma_regions;
+
+	pr_debug("allocating\n");
+
+	if (!alloc)
+		alloc = cma_region_alloc;
+
+	for (; reg->size; ++reg) {
+		if (likely(alloc(reg) >= 0)) {
+			pr_debug("init: %s: allocated %p@%p\n",
+				 reg->name,
+				 (void *)reg->size, (void *)reg->start);
+			if (out != reg)
+				memcpy(out, reg, sizeof *out);
+			++out;
+		} else {
+			pr_warn("init: %s: unable to allocate %p@%p\n",
+				reg->name,
+				(void *)reg->size, (void *)reg->start);
+		}
+	}
+	out->size = 0; /* Zero size termination */
+
+	return cma_regions - out;
+}
+
+static int __init cma_init(void)
+{
+	struct cma_allocator *alloc;
+	struct cma_region *reg;
+
+	pr_debug("initialising\n");
+
+	for (reg = cma_regions; reg->size; ++reg) {
+		mutex_init(&reg->mutex);
+
+		alloc = __cma_allocator_find(reg->alloc_name);
+		if (unlikely(!alloc)) {
+			pr_warn("init: %s: %s: no such allocator\n",
+				reg->name, reg->alloc_name ?: "(default)");
+			continue;
+		}
+
+		if (unlikely(alloc->init(reg))) {
+			pr_err("init: %s: %s: unable to initialise allocator\n",
+			       reg->name, alloc->name);
+			continue;
+		}
+
+		reg->alloc      = alloc;
+		reg->alloc_name = alloc->name; /* it may have been NULL */
+		pr_debug("init: %s: %s: initialised allocator\n",
+			 reg->name, reg->alloc_name);
+	}
+
+	return 0;
+}
+subsys_initcall(cma_init);
+
+
+/************************* Various prototypes *************************/
+
+static struct cma_chunk *__must_check __cma_chunk_find(unsigned long addr);
+static int __must_check __cma_chunk_insert(struct cma_chunk *chunk);
+static void __cma_chunk_release(struct kref *ref);
+
+static struct cma_region *__must_check
+__cma_region_find(const char *name, unsigned n);
+
+static const char *__must_check
+__cma_where_from(const struct device *dev, const char *kind);
+static struct cma_chunk *__must_check
+__cma_alloc_do(const char *from, unsigned long size, unsigned long alignment);
+
+
+
+/************************* The Device API *************************/
+
+unsigned long __must_check
+cma_alloc(const struct device *dev, const char *kind,
+	  unsigned long size, unsigned long alignment)
+{
+	struct cma_chunk *chunk;
+	const char *from;
+
+	pr_debug("allocate %p/%p for %s/%s\n",
+		 (void *)size, (void *)alignment, dev_name(dev), kind ?: "");
+
+	if (unlikely(alignment & (alignment - 1) || !size))
+		return -EINVAL;
+
+	from = __cma_where_from(dev, kind);
+	if (unlikely(IS_ERR(from)))
+		return PTR_ERR(from);
+
+	chunk = __cma_alloc_do(from, size, alignment ?: 1);
+	if (chunk)
+		pr_debug("allocated at %p\n", (void *)chunk->start);
+	else
+		pr_debug("not enough memory\n");
+
+	return chunk ? chunk->start : -ENOMEM;
+}
+EXPORT_SYMBOL_GPL(cma_alloc);
+
+
+int __must_check
+cma_info(struct cma_info *info, const struct device *dev, const char *kind)
+{
+	struct cma_info ret = { ~0, 0, 0, 0 };
+	const char *from;
+
+	if (unlikely(!info))
+		return -EINVAL;
+
+	from = __cma_where_from(dev, kind);
+	if (unlikely(IS_ERR(from)))
+		return PTR_ERR(from);
+
+	while (*from) {
+		const char *end = strchr(from, ',');
+		struct cma_region *reg =
+			__cma_region_find(from, end ? end - from : strlen(from));
+		if (reg) {
+			ret.total_size += reg->size;
+			if (ret.lower_bound > reg->start)
+				ret.lower_bound = reg->start;
+			if (ret.upper_bound < reg->start + reg->size)
+				ret.upper_bound = reg->start + reg->size;
+			++ret.count;
+		}
+		if (!end)
+			break;
+		from = end + 1;
+	}
+
+	memcpy(info, &ret, sizeof ret);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(cma_info);
+
+
+int cma_get(unsigned long addr)
+{
+	struct cma_chunk *c = __cma_chunk_find(addr);
+
+	pr_debug("get(%p): %sfound\n", (void *)addr, c ? "" : "not ");
+
+	if (unlikely(!c))
+		return -ENOENT;
+	kref_get(&c->ref);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(cma_get);
+
+int cma_put(unsigned long addr)
+{
+	struct cma_chunk *c = __cma_chunk_find(addr);
+	int ret;
+
+	pr_debug("put(%p): %sfound\n", (void *)addr, c ? "" : "not ");
+
+	if (unlikely(!c))
+		return -ENOENT;
+
+	ret = kref_put(&c->ref, __cma_chunk_release);
+	if (ret)
+		pr_debug("put(%p): destroyed\n", (void *)addr);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(cma_put);
+
+
+/************************* Implementation *************************/
+
+static struct rb_root cma_chunks_by_start;;
+static DEFINE_MUTEX(cma_chunks_mutex);
+
+static struct cma_chunk *__must_check __cma_chunk_find(unsigned long addr)
+{
+	struct cma_chunk *chunk;
+	struct rb_node *n;
+
+	mutex_lock(&cma_chunks_mutex);
+
+	for (n = cma_chunks_by_start.rb_node; n; ) {
+		chunk = rb_entry(n, struct cma_chunk, by_start);
+		if (addr < chunk->start)
+			n = n->rb_left;
+		else if (addr > chunk->start)
+			n = n->rb_right;
+		else
+			goto found;
+	}
+	WARN("no chunk starting at %p\n", (void *)addr);
+	chunk = NULL;
+
+found:
+	mutex_unlock(&cma_chunks_mutex);
+
+	return chunk;
+}
+
+static int __must_check __cma_chunk_insert(struct cma_chunk *chunk)
+{
+	struct rb_node **new, *parent = NULL;
+	unsigned long addr = chunk->start;
+
+	mutex_lock(&cma_chunks_mutex);
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
+			return -EBUSY;
+		}
+	}
+
+	rb_link_node(&chunk->by_start, parent, new);
+	rb_insert_color(&chunk->by_start, &cma_chunks_by_start);
+
+	mutex_unlock(&cma_chunks_mutex);
+
+	return 0;
+}
+
+static void __cma_chunk_release(struct kref *ref)
+{
+	struct cma_chunk *chunk = container_of(ref, struct cma_chunk, ref);
+
+	mutex_lock(&cma_chunks_mutex);
+	rb_erase(&chunk->by_start, &cma_chunks_by_start);
+	mutex_unlock(&cma_chunks_mutex);
+
+	mutex_lock(&chunk->reg->mutex);
+	chunk->reg->alloc->free(chunk);
+	--chunk->reg->users;
+	chunk->reg->free_space += chunk->size;
+	mutex_unlock(&chunk->reg->mutex);
+}
+
+
+static struct cma_region *__must_check
+__cma_region_find(const char *name, unsigned n)
+{
+	struct cma_region *reg = cma_regions;
+
+	for (; reg->start; ++reg) {
+		if (!strncmp(name, reg->name, n) && !reg->name[n])
+			return reg;
+	}
+
+	return NULL;
+}
+
+
+static const char *__must_check
+__cma_where_from(const struct device *dev, const char *kind)
+{
+	/*
+	 * This function matches the pattern given at command line
+	 * parameter agains given device name and kind.  Kind may be
+	 * of course NULL or an emtpy string.
+	 */
+
+	const char **spec, *name;
+	int name_matched = 0;
+
+	/* Make sure dev was given and has name */
+	if (unlikely(!dev))
+		return ERR_PTR(-EINVAL);
+
+	name = dev_name(dev);
+	if (WARN_ON(!name || !*name))
+		return ERR_PTR(-EINVAL);
+
+	/* kind == NULL is just like an empty kind */
+	if (!kind)
+		kind = "";
+
+	/*
+	 * Now we go throught the cma_map array.  It is an array of
+	 * pointers to chars (ie. array of strings) so in each
+	 * iteration we take each of the string.  The strings is
+	 * basically what user provided at the command line separated
+	 * by semicolons.
+	 */
+	for (spec = cma_map; *spec; ++spec) {
+		/*
+		 * This macro tries to match pattern pointed by s to
+		 * @what.  If, while reading the spec, we ecnounter
+		 * comma it means that the pattern does not match and
+		 * we need to start over with another spec.  If there
+		 * is a character that does not match, we neet to try
+		 * again looking if there is another spec.
+		 */
+#define TRY_MATCH(what) do {				\
+		const char *c = what;			\
+		for (; *s != '*' && *c; ++c, ++s)	\
+			if (*s == ',')			\
+				goto again;		\
+			else if (*s != '?' && *c != *s)	\
+				goto again_maybe;	\
+		if (*s == '*')				\
+			++s;				\
+	} while (0)
+
+		const char *s = *spec - 1;
+again:
+		++s;
+
+		/*
+		 * If the pattern is spec starts with a slash, this
+		 * means that the device part of the pattern matches
+		 * if it matched previously.
+		 */
+		if (*s == '/') {
+			if (!name_matched)
+				goto again_maybe;
+			goto kind;
+		}
+
+		/*
+		 * We are now trying to match the device name.  This
+		 * also updates the name_matched variable.  If the
+		 * name does not match we will jump to again or
+		 * again_maybe out of the TRY_MATCH() macro.
+		 */
+		name_matched = 0;
+		TRY_MATCH(name);
+		name_matched = 1;
+
+		/*
+		 * Now we need to match the kind part of the pattern.
+		 * If the pattern is missing it we match only if kind
+		 * points to an empty string.  Otherwise wy try to
+		 * match it just like name.
+		 */
+		if (*s != '/') {
+			if (*kind)
+				goto again_maybe;
+		} else {
+kind:
+			++s;
+			TRY_MATCH(kind);
+		}
+
+		/*
+		 * Patterns end either when the string ends or on
+		 * a comma.  Returned value is the part of the rule
+		 * with list of region names.  This works because when
+		 * we parse the cma_map parameter the equel sign in
+		 * rules is replaced by a NUL byte.
+		 */
+		if (!*s || *s == ',')
+			return s + strlen(s) + 1;
+
+again_maybe:
+		s = strchr(s, ',');
+		if (s)
+			goto again;
+
+#undef TRY_MATCH
+	}
+
+	return ERR_PTR(-ENOENT);
+}
+
+
+static struct cma_chunk *__must_check
+__cma_alloc_do(const char *from, unsigned long size, unsigned long alignment)
+{
+	struct cma_chunk *chunk;
+	struct cma_region *reg;
+
+	pr_debug("alloc_do(%p/%p from %s)\n",
+		 (void *)size, (void *)alignment, from);
+
+	while (*from) {
+		const char *end = strchr(from, ',');
+		reg = __cma_region_find(from, end ? end - from : strlen(from));
+		if (unlikely(!reg || !reg->alloc))
+			goto skip;
+
+		if (reg->free_space < size)
+			goto skip;
+
+		mutex_lock(&reg->mutex);
+		chunk = reg->alloc->alloc(reg, size, alignment);
+		if (chunk) {
+			++reg->users;
+			reg->free_space -= chunk->size;
+		}
+		mutex_unlock(&reg->mutex);
+		if (chunk)
+			goto got;
+
+skip:
+		if (!end)
+			break;
+		from = end + 1;
+	}
+	return NULL;
+
+got:
+	chunk->reg = reg;
+	kref_init(&chunk->ref);
+
+	if (likely(!__cma_chunk_insert(chunk)))
+		return chunk;
+
+	mutex_lock(&reg->mutex);
+	--reg->users;
+	reg->free_space += chunk->size;
+	chunk->reg->alloc->free(chunk);
+	mutex_unlock(&reg->mutex);
+	return NULL;
+}
-- 
1.7.1
