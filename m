Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 09C5B6B00A4
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 23:16:44 -0500 (EST)
From: KyongHo Cho <pullip.cho@samsung.com>
Subject: [RFCv2,1/8] mm: vcm: Virtual Contiguous Memory framework added
Date: Fri, 17 Dec 2010 12:56:20 +0900
Message-Id: <1292558187-17348-2-git-send-email-pullip.cho@samsung.com>
In-Reply-To: <1292558187-17348-1-git-send-email-pullip.cho@samsung.com>
References: <1292558187-17348-1-git-send-email-pullip.cho@samsung.com>
Sender: owner-linux-mm@kvack.org
To: KyongHo Cho <pullip.cho@samsung.com>
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Kukjin Kim <kgene.kim@samsung.com>, Inho Lee <ilho215.lee@samsung.com>, Inki Dae <inki.dae@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linux-samsung-soc@vger.kernel.org, Michal Nazarewicz <m.nazarewicz@samsung.com>
List-ID: <linux-mm.kvack.org>

From: Michal Nazarewicz <m.nazarewicz@samsung.com>

This commit adds the Virtual Contiguous Memory framework which
provides an abstraction for virtual address space provided by
various MMUs present on the platform.

The framework uses plugable MMU drivers for hardware MMUs and
if drivers obeys some limitations it can be also used on
platforms with no MMU.

For more information see
<Documentation/virtual-contiguous-memory.txt>.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 Documentation/00-INDEX                      |    2 +
 Documentation/virtual-contiguous-memory.txt |  720 +++++++++++++++++++++++++++
 include/linux/vcm-drv.h                     |  117 +++++
 include/linux/vcm.h                         |  275 ++++++++++
 mm/Kconfig                                  |   15 +
 mm/Makefile                                 |    1 +
 mm/vcm.c                                    |  304 +++++++++++
 7 files changed, 1434 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/virtual-contiguous-memory.txt
 create mode 100644 include/linux/vcm-drv.h
 create mode 100644 include/linux/vcm.h
 create mode 100644 mm/vcm.c

diff --git a/Documentation/00-INDEX b/Documentation/00-INDEX
index 8dfc670..7033c56 100644
--- a/Documentation/00-INDEX
+++ b/Documentation/00-INDEX
@@ -342,6 +342,8 @@ video-output.txt
 	- sysfs class driver interface to enable/disable a video output device.
 video4linux/
 	- directory with info regarding video/TV/radio cards and linux.
+virtual-contiguous-memory.txt
+	- documentation on virtual contiguous memory manager framework.
 vm/
 	- directory with info on the Linux vm code.
 volatile-considered-harmful.txt
diff --git a/Documentation/virtual-contiguous-memory.txt b/Documentation/virtual-contiguous-memory.txt
new file mode 100644
index 0000000..9793a86
--- /dev/null
+++ b/Documentation/virtual-contiguous-memory.txt
@@ -0,0 +1,720 @@
+                                                             -*- org -*-
+
+This document covers how to use the Virtual Contiguous Memory framework
+(VCM), how the implementation works, and how to implement MMU drivers
+that can be plugged into VCM.  It also contains a rationale for VCM.
+
+* The Virtual Contiguous Memory Manager
+
+The VCM was built to solve the system-wide memory mapping issues that
+occur when many bus-masters have IOMMUs.
+
+An IOMMU maps device addresses to physical addresses.  It also
+insulates the system from spurious or malicious device bus
+transactions and allows fine-grained mapping attribute control.  The
+Linux kernel core does not contain a generic API to handle IOMMU
+mapped memory; device driver writers must implement device specific
+code to interoperate with the Linux kernel core.  As the number of
+IOMMUs increases, coordinating the many address spaces mapped by all
+discrete IOMMUs becomes difficult without in-kernel support.
+
+The VCM API enables device independent IOMMU control, virtual memory
+manager (VMM) interoperation and non-IOMMU enabled device
+interoperation by treating devices with or without IOMMUs and all CPUs
+with or without MMUs, their mapping contexts and their mappings using
+common abstractions.  Physical hardware is given a generic device type
+and mapping contexts are abstracted into Virtual Contiguous Memory
+(VCM) regions.  Users "reserve" memory from VCMs and "bind" their
+reservations with physical memory.
+
+If drivers limit their use of VCM contexts to a some subset of VCM
+functionality, they can work with no changes with or without MMU.
+
+** Why the VCM is Needed
+
+Driver writers who control devices with IOMMUs must contend with
+device control and memory management.  Driver writers have a large
+device driver API that they can leverage to control their devices, but
+they are lacking a unified API to help them program mappings into
+IOMMUs and share those mappings with other devices and CPUs in the
+system.
+
+Sharing is complicated by Linux's CPU-centric VMM.  The CPU-centric
+model generally makes sense because average hardware only contains
+a MMU for the CPU and possibly a graphics MMU.  If every device in the
+system has one or more MMUs the CPU-centric memory management (MM)
+programming model breaks down.
+
+Abstracting IOMMU device programming into a common API has already
+begun in the Linux kernel.  It was built to abstract the difference
+between AMD and Intel IOMMUs to support x86 virtualization on both
+platforms.  The interface is listed in include/linux/iommu.h.  It
+contains interfaces for mapping and unmapping as well as domain
+management.  This interface has not gained widespread use outside the
+x86; PA-RISC, Alpha and SPARC architectures and ARM and PowerPC
+platforms all use their own mapping modules to control their IOMMUs.
+The VCM contains an IOMMU programming layer, but since its
+abstraction supports map management independent of device control, the
+layer is not used directly.  This higher-level view enables a new
+kernel service, not just an IOMMU interoperation layer.
+
+** The General Idea: Map Management using Graphs
+
+Looking at mapping from a system-wide perspective reveals a general
+graph problem.  The VCM's API is built to manage the general mapping
+graph.  Each node that talks to memory, either through an MMU or
+directly (physically mapped) can be thought of as the device-end of
+a mapping edge.  The other edge is the physical memory (or
+intermediate virtual space) that is mapped.  The figure below shows
+an example three with CPU and a few devices connected to the memory
+directly or through a MMU.
+
++--------------------------------------------------------------------+
+|                               Memory                               |
++--------------------------------------------------------------------+
+                                  |
+   +------------------+-----------+-------+----------+-----------+
+   |                  |                   |          |           |
++-----+            +-----+             +-----+  +--------+  +--------+
+| MMU |            | MMU |             | MMU |  | Device |  | Device |
++-----+            +-----+             +-----+  +--------+  +--------+
+   |                  |                   |
++-----+       +-------+---+-----....   +-----+
+| CPU |       |           |            | GPU |
++-----+  +--------+  +--------+        +-----+
+         | Device |  | Device |  ...
+         +--------+  +--------+
+
+For each MMU in the system a VCM context is created through an through
+which drivers can make reservations and bind virtual addresses to
+physical space.  In the direct-mapped case the device is assigned
+a one-to-one MMU (as shown on the figure below). This scheme allows
+direct mapped devices to participate in general graph management.
+
++--------------------------------------------------------------------+
+|                               Memory                               |
++--------------------------------------------------------------------+
+                                  |
+   +------------------+-----------+-------+----------------+
+   |                  |                   |                |
++-----+            +-----+             +-----+      +------------+
+| MMU |            | MMU |             | MMU |      | One-to-One |
++-----+            +-----+             +-----+      +------------+
+   |                  |                   |                |
++-----+       +-------+---+-----....   +-----+       +-----+-----+
+| CPU |       |           |            | GPU |       |           |
++-----+  +--------+  +--------+        +-----+  +--------+  +--------+
+         | Device |  | Device |  ...            | Device |  | Device |
+         +--------+  +--------+                 +--------+  +--------+
+
+The CPU nodes can also be brought under the same mapping abstraction
+with the use of a light overlay on the existing VMM. This light
+overlay allows VCM-managed mappings to interoperate with the common
+API.  The light overlay enables this without substantial modifications
+to the existing VMM.
+
+In addition to CPU nodes that are running Linux (and the VMM), remote
+CPU nodes that may be running other operating systems can be brought
+into the general abstraction.  Routing all memory management requests
+from a remote node through the central memory management framework
+enables new features like system-wide memory migration.  This feature
+may only be feasible for large buffers that are managed outside of the
+fast-path, but having remote allocation in a system enables features
+that are impossible to build without it.
+
+The fundamental objects that support graph-based map management are:
+Virtual Contiguous Memory contexts, reservations, and physical memory
+allocations.
+
+* Usage Overview
+
+In a nutshell, platform initialises VCM context for each MMU on the
+system and possibly one-to-one VCM contexts which are passed to device
+drivers.  Later on, drivers make reservation of virtual address space
+from the VCM context.  At this point no physical memory has been
+committed to the reservation.  To bind physical memory with a
+reservation, physical memory is allocated (possibly discontiguous) and
+then bound to the reservation.
+
+Single physical allocation can be bound to several different
+reservations also from different VCM contexts.  This allows for
+devices connected through different MMUs (or directly) to the memory
+banks to share physical memory buffers; this also lets it possible to
+map such memory into CPU's address space (be it kernel or user space)
+so that the same data can be accessed by the CPU.
+
+[[file:../include/linux/vcm.h][include/linux/vcm.h]] includes comments documenting each API.
+
+** Virtual Contiguous Memory context
+
+A Virtual Contiguous Memory context (VCM) abstracts an address space
+a device sees.  A VCM is created with a VCM driver dependent call.  It
+is destroyed with a call to:
+
+        void vcm_destroy(struct vcm *vcm);
+
+The newly created VCM instance can be passed to any function that needs to
+operate on or with a virtual contiguous memory region.  All internals
+of the VCM driver and how the mappings are handled is hidden and VCM
+driver dependent.
+
+** Bindings
+
+If all that driver needs is allocate some physical space and map it
+into its address space, a vcm_make_binding() call can be used:
+
+	struct vcm_res	*__must_check
+	vcm_make_binding(struct vcm *vcm, resource_size_t size,
+			 unsigned alloc_flags, unsigned res_flags);
+
+This call allocates physical memory, reserves virtual address space
+and binds those together.  If all those succeeds a reservation is
+returned which has physical memory associated with it.
+
+If driver does not require more complicated VCM functionality, it is
+desirable to use this function since it will work on both real MMUs
+and one-to-one mappings.
+
+To destroy created binding, vcm_destroy_binding() can be used:
+
+        void vcm_destroy_binding(struct vcm_res *res);
+
+** Physical memory
+
+Physical memory allocations are handled using the following functions:
+
+	struct vcm_phys *__must_check
+	vcm_alloc(struct vcm *vcm, resource_size_t size, unsigned flags);
+
+	void vcm_free(struct vcm_phys *phys);
+
+It is noteworthy that physical space allocation is done in the context
+of a VCM.  This is especially important in case of one-to-one VCM
+contexts which cannot handle discontiguous physical memory.
+
+Also, depending on VCM context, the physical space may be allocated in
+parts of different sizes.  For instance, if a given MMU supports
+16MiB, 1MiB, 64KiB and 4KiB pages, it is likely that vcm_alloc() in
+context of this MMU's driver will try to split into as few as possible
+parts of those sizes.
+
+In case of one-to-one VCM contexts, a physical memory allocated with
+the call to vcm_alloc() may be usable only with vcm_map() function.
+
+** Mappings
+
+The easiest way to map a physical space into virtual address space
+represented by VCM context is to use the vcm_map() function:
+
+	struct vcm_res *__must_check
+	vcm_map(struct vcm *vcm, struct vcm_phys *phys, unsigned flags);
+
+This functions reserves address space from VCM context and binds
+physical space to it.  To reverse the process vcm_unmap() can be used:
+
+	void vcm_unmap(struct vcm_res *res);
+
+Similarly to vcm_make_binding(), Usage vcm_map() may be advantageous
+over the use of vcm_reserve() followed by vcm_bind().  This is not
+only true for one-to-one mapping but if it so happens that the call to
+vcm_map() request mapping of a physically contiguous space into kernel
+space, a direct mapping can be returned instead of creating a new one.
+
+In some cases, a reservation created with vcm_map() can be used only
+with the physical memory passed as the argument to vcm_map() (so if
+user chooses to call vcm_unbind() and then vcm_bind() on a different
+physical memory, the call may fail).
+
+** Reservations
+
+A reservation is a contiguous region allocated from a virtual address
+space represented by VCM context.  Just after reservation is created,
+no physical memory needs to be is bound to it.  To manage reservations
+following two functions are provided:
+
+	struct vcm_res *__must_check
+	vcm_reserve(struct vcm *vcm, resource_size_t size,
+		    unsigned flags);
+
+	void vcm_unreserve(struct vcm_res *res);
+
+The first one creates a reservation of desired size, and the second
+one destroys it.
+
+** Binding memory
+
+To bind a physical memory into a reservation vcm_bind() function is
+used:
+
+	int __must_check vcm_bind(struct vcm_res *res,
+				  struct vcm_phys *phys);
+
+When the binding is no longer needed, vcm_unbind() destroys the
+connection:
+
+	struct vcm_phys *vcm_unbind(struct vcm_res *res);
+
+** Activating mappings
+
+Unless a VCM context is activated, none of the bindings are actually
+guaranteed to be available.  When device driver needs the mappings
+it need to call vcm_activate() function to guarantee that the mappings
+are sent to hardware MMU.
+
+	int  __must_check vcm_activate(struct vcm *vcm);
+
+After VCM context is activated all further bindings (made with
+vcm_make_binding(), vcm_map() or vcm_bind()) will be updated so there
+is no need to call vcm_activate() after each binding is done or
+undone.
+
+To deactivate the VCM context vcm_deactivate() function is used:
+
+	void vcm_deactivate(struct vcm *vcm);
+
+Both of those functions can be called several times if all calls to
+vcm_activate() are paired with a later call to vcm_deactivate().
+
+** Device driver example
+
+The following is a simple, untested example of how platform and
+devices work together to use the VCM framework.  Platform initialises
+contexts for each MMU in the systems, and through platform device data
+passes them to correct drivers.
+
+Device driver header file:
+
+	struct foo_platform_data {
+		/* ... */
+		struct vcm	*vcm;
+		/* ... */
+	};
+
+Platform code:
+
+	static int plat_bar_vcm_init(void)
+	{
+		struct foo_platform_data *fpdata;
+		struct vcm *vcm;
+
+		vcm = vcm_baz_create(...);
+		if (IS_ERR(vcm))
+			return PTR_ERR(vcm);
+
+		fpdata = dev_get_platdata(&foo_device.dev);
+		fpdata->vcm = vcm;
+
+		/* ... */
+
+		return 0;
+	}
+
+Device driver implementation:
+
+	struct foo_private {
+		/* ... */
+		struct vcm_res	*fw;
+		/* ... */
+	};
+
+	static inline struct vcm_res *__must_check
+	__foo_alloc(struct device *dev, size_t size)
+	{
+		struct foo_platform_data *pdata =
+			dev_get_platdata(dev);
+		return vcm_make_binding(pdata->vcm, size, 0, 0);
+	}
+
+	static inline void __foo_free(struct vcm_res *res)
+	{
+		vcm_destroy_binding(res);
+	}
+
+	static int foo_probe(struct device *dev)
+	{
+		struct foo_platform_data *pdata =
+			dev_get_platdata(dev);
+		struct foo_private *priv;
+
+		if (IS_ERR_OR_NULL(pdata->vcm))
+			return pdata->vcm ? PTR_ERR(pdata->vcm) : -EINVAL;
+
+		priv = kzalloc(sizeof *priv, GFP_KERNEL);
+		if (!priv)
+			return -ENOMEM;
+
+		/* ... */
+
+		priv->fw = __foo_alloc(dev, 1 << 20);
+		if (IS_ERR(priv->fw)) {
+			kfree(priv);
+			return PTR_ERR(priv->fw);
+		}
+		/* copy firmware to fw */
+
+		vcm_activate(pdata->vcm);
+
+		dev->p = priv;
+
+		return 0;
+	}
+
+	static int foo_remove(struct device *dev)
+	{
+		struct foo_platform_data *pdata =
+			dev_get_platdata(dev);
+		struct foo_private *priv = dev->p;
+
+		/* ... */
+
+		vcm_deactivate(pdata->vcm);
+		__foo_free(priv->fw);
+
+		kfree(priv);
+
+		return 0;
+	}
+
+	static int foo_do_something(struct device *dev, /* ... */)
+	{
+		struct foo_platform_data *pdata =
+			dev_get_platdata(dev);
+		struct vcm_res *buf;
+		int ret;
+
+		buf = __foo_alloc(/* ... size ...*/);
+		if (IS_ERR(buf))
+			return ERR_PTR(buf);
+
+		/*
+		 * buf->start is address visible from device's
+		 * perspective.
+		 */
+
+		/* ... set hardware up ... */
+
+		/* ... wait for completion ... */
+
+		__foo_free(buf);
+
+		return ret;
+	}
+
+In the above example only vcm_make_binding() function is used so that
+the above scheme will work not only for systems with MMU but also in
+case of one-to-one VCM context.
+
+** IOMMU and one-to-one contexts
+
+The following example demonstrates mapping IOMMU and one-to-one
+reservations to the same physical memory.  For readability, error
+handling is not shown on the listings.
+
+First, each contexts needs to be created.  A call used for creating
+context is dependent on the driver used.  The following is just an
+example of how this could look like:
+
+	struct vcm *vcm_onetoone, *vcm_iommu;
+
+	vcm_onetoone = vcm_onetoone_create();
+	vcm_iommu    = vcm_foo_mmu_create();
+
+Once contexts are created, physical space needs to be allocated,
+reservations made on each context and physical memory mapped to those
+reservations.  Because there is a one-to-one context, the memory has
+to be allocated from its context.  It's also best to map the memory in
+the single call using vcm_make_binding():
+
+	struct vcm_res *res_onetoone;
+
+	res_onetoone = vcm_make_binding(vcm_o2o, SZ_2MB | SZ_4K, 0, 0);
+
+What's left is map the space in the other context.  If the reservation
+in the other two contexts won't be used for any other purpose then to
+reference the memory allocated in above, it's best to use vcm_map():
+
+	struct vcm_res *res_iommu;
+
+	res_iommu = vcm_map(vcm_iommu, res_onetoone->phys, 0);
+
+Once the bindings have been created, the contexts need to be activated
+to make sure that they are actually on the hardware. (In case of
+one-to-one mapping it's most likely a no-operation but it's still
+required by the VCM API so it must not be omitted.)
+
+	vcm_activate(vcm_onetoone);
+	vcm_activate(vcm_iommu);
+
+At this point, both reservations represent addresses in respective
+address space that is bound to the same physical memory.  Devices
+connected through the MMU can access it, as well as devices connected
+directly to the memory banks.  The bus address for the devices and
+virtual address for the CPU is available through the 'start' member of
+the vcm_res structure (ie. res_* objects above).
+
+Once the mapping is no longer used and memory no longer needed it can
+be freed as follows:
+
+	vcm_unmap(res_iommu);
+	vcm_destroy_binding(res_onetoone);
+
+If the contexts are not needed either, they can be disabled:
+
+	vcm_deactivate(vcm_iommu);
+	vcm_deactivate(vcm_onetoone);
+
+and than, even destroyed:
+
+	vcm_destroy(vcm_iommu);
+	vcm_destroy(vcm_onetoone);
+
+* Available drivers
+
+Not all drivers support all of the VCM functionality.  What is always
+supported is:
+
+	vcm_free()
+	vcm_unbind()
+	vcm_unreserve()
+
+Even though, vcm_unbind() may leave virtual reservation in unusable
+state.
+
+The following VCM drivers are provided:
+
+** Real hardware drivers
+
+There are no real hardware drivers at this time.
+
+** One-to-One drivers
+
+As it has been noted, one-to-One drivers are limited in the sense that
+certain operations are very unlikely to succeed.  In fact, it is often
+certain that some operations will fail.  If your driver needs to be
+able to run with One-to-One driver you should limit operations to:
+
+	vcm_make_binding()
+	vcm_destroy_binding()
+
+unless the above are not enough, then the following two may be used as
+well:
+
+	vcm_map()
+	vcm_unmap()
+
+If one uses vcm_unbind() then vcm_bind() on the same reservation,
+physical memory pair should also work.
+
+There are no One-to-One drivers at this time.
+
+* Writing a VCM driver
+
+The core of VCM does not handle communication with the MMU.  For this
+purpose a VCM driver is used.  Its purpose is to manage virtual
+address space reservations, physical allocations as well as updating
+mappings in the hardware MMU.
+
+API designed for VCM drivers is described in the
+[[file:../include/linux/vcm-drv.h][include/linux/vcm-drv.h]] file so it might be a good idea to take a look
+inside.
+
+VCM provides API for three different kinds of drivers.  The most
+basic is a core VCM which VCM use directly.  Other then that, VCM
+provides two wrappers -- VCM MMU and VCM One-to-One -- which can be
+used to create drivers for real hardware VCM contexts and for
+One-to-One contexts.
+
+All of the drivers need to provide a context creation functions which
+will allocate memory, fill start address, size and pointer to driver
+operations, and then call an init function which fills rest of the
+fields and validates entered values.
+
+** Writing a core VCM driver
+
+The core driver needs to provide a context creation function as well
+as at least some of the following operations:
+
+	void (*cleanup)(struct vcm *vcm);
+
+	int (*alloc)(struct vcm *vcm, resource_size_t size,
+		     struct vcm_phys **phys, unsigned alloc_flags,
+		     struct vcm_res **res, unsigned res_flags);
+	struct vcm_res *(*res)(struct vcm *vcm, resource_size_t size,
+			       unsigned flags);
+	struct vcm_phys *(*phys)(struct vcm *vcm, resource_size_t size,
+				 unsigned flags);
+
+	void (*unreserve)(struct vcm_res *res);
+
+	struct vcm_res *(*map)(struct vcm *vcm, struct vcm_phys *phys,
+			       unsigned flags);
+	int (*bind)(struct vcm_res *res, struct vcm_phys *phys);
+	void (*unbind)(struct vcm_res *res);
+
+	int (*activate)(struct vcm *vcm);
+	void (*deactivate)(struct vcm *vcm);
+
+All of the operations (expect for the alloc) may assume that all
+pointer arguments are not-NULL.  (In case of alloc, if any argument is
+NULL it is either phys or res (never both).)
+
+*** Context creation
+
+To use a VCM driver a VCM context has to be provided which is bound to
+the driver.  This is done by a driver-dependent call defined in it's
+header file.  Such a call may take varyous arguments to configure the
+context of the MMU.  Its prototype may look as follows:
+
+	struct vcm *__must_check vcm_samp_create(/* ... */);
+
+The driver will most likely define a structure encapsulating the vcm
+structure (in the usual way).  The context creation function must
+allocate space for such a structure and initialise it correctly
+including all members of the vcm structure expect for activations.
+The activations member is initialised by calling:
+
+	struct vcm *__must_check vcm_init(struct vcm *vcm);
+
+This function also validates that all fields are set correctly.
+
+The driver field of the vcm structure must point to a structure with
+all operations supported by the driver.
+
+If everything succeeds, the function has to return pointer to the vcm
+structure inside the encapsulating structure.  It is the pointer that
+will be passed to all of the driver's operations.  On error,
+a pointer-error must be returned (ie. not NULL).
+
+The function might look something like the following:
+
+	struct vcm *__must_check vcm_foo_create(/* ... */)
+	{
+		struct vcm_foo *foo;
+		struct vcm *vcm;
+
+		foo = kzalloc(sizeof *foo, GFP_KERNEL);
+		if (!foo)
+			return ERR_PTR(-ENOMEM);
+
+		/* ... do stuff ... */
+
+		foo->vcm.start  = /* ... */;
+		foo->vcm.size   = /* ... */;
+		foo->vcm.driver = &vcm_foo_driver;
+
+		vcm = vcm_init(&foo->vcm);
+		if (IS_ERR(vcm)) {
+			/* ... error recovery ... */
+			kfree(foo);
+		}
+		return vcm;
+	}
+
+*** Cleaning up
+
+The cleanup operation is called when the VCM context is destroyed.
+Its purpose is to free all resources acquired when VCM context was
+created including the space for the context structure.  If it is not
+given, the memory is freed using the kfree() function.
+
+*** Allocation and reservations
+
+If alloc operation is specified, res and phys operations are ignored.
+The observable behaviour of the alloc operation should mimic as
+closely as possible res and phys operations called one after the
+other.
+
+The reason for this operation is that in case of one-to-one VCM
+contexts, the driver may not be able to bind together arbitrary
+reservation with an arbitrary physical space.  In one-to-one contexts,
+reservations and physical memory are tight together and need to be
+made at the same time to make binding possible.
+
+The alloc operation may be called with both, res and phys being set,
+or at most one of them being NULL.
+
+The res operation reserves virtual address space in the VCM context.
+The function must set the start and res_size members of the vcm_res
+structure -- all other fields are filled by the VCM framework.
+
+The phys operation allocates physical space which can later be bound
+to the reservation.
+
+Both phys and alloc callbacks need to provide a free callbakc along
+with the vc_phys structure, which will, as one may imagine, free
+allocated space when user calls vcm_free().
+
+All those operations may assume that size is a non-zero and divisible
+by PAGE_SIZE.
+
+*** Binding
+
+The map operation is optional and it joins res and bind operations
+together.  Like alloc operation, this is provided because in case of
+one-to-one mappings, the VCM driver may be unable to bind together
+physical space with an arbitrary reservation.
+
+Moreover, in case of some VCM drivers, a mapping for given physical
+memory can already be present (ie. in case of using VMM).
+
+Reservation created with map operation does not have to be usable
+with any other physical space then the one provided when reservation
+was created.
+
+The bind operation binds given reservation with a given physical
+memory.  The operation may assume that reservation given as an
+argument is not bound to any physical memory.
+
+Whichever of the two operation is used, the binding must be reflected
+on the hardware if the VCM context has been activated.  If VCM context
+has not been activated this is not required.
+
+The vcm_map() function uses map operation if one is provided.
+Otherwise, it falls back to alloc or res operation followed by bind
+operation.  If this is also not possible, -EOPNOTSUPP is returned.
+Similarly, vcm_bind() function uses the bind operation unless it is
+not provided in which case -EOPNOTSUPP is returned.
+
+Also, if alloc operation is not provided but map is, the
+vcm_make_binding() function will use phys and map operations.
+
+*** Freeing resources
+
+The unbind callback removes the binding between reservation and
+a physical memory.  If unbind operation is not provided, VCM assumes
+that it is a no-operation.
+
+The unreserve callback releases a reservation as well as free
+allocated space for the vcm_res structure.  It is required and if it
+is not provided vcm_unreserve() will generate a warning.
+
+*** Activation
+
+When VCM context is activated, the activate callback is called.  It is
+called only once even if vcm_activate() is called several times on the
+same context.
+
+When VCM context is deactivated (that is, if for each call to
+vcm_activate(), vcm_deactivate() was called) the deactivate callback
+is called.
+
+When VCM context is activated, all bound reservations must be
+reflected on the hardware MMU (if any).  Also, ofter activation, all
+calls to vcm_bind(), vcm_map() or vcm_make_binding() must
+automatically reflect new mappings on the hardware MMU.
+
+Neither of the operations are required and if missing, VCM will
+assume they are a no-operation and no warning will be generated.
+
+* Epilogue
+
+The initial version of the VCM framework was written by Zach Pfeffer
+<zpfeffer@codeaurora.org>.  It was then redesigned and mostly
+rewritten by Michal Nazarewicz <m.nazarewicz@samsung.com>.
+
+The new version is still lacking a few important features.  Most
+notably, no real hardware MMU has been implemented yet.  This may be
+ported from original Zach's proposal.
+
+Also, support for VMM is lacking.  This is another thing that can be
+ported from Zach's proposal.
diff --git a/include/linux/vcm-drv.h b/include/linux/vcm-drv.h
new file mode 100644
index 0000000..d7ae660
--- /dev/null
+++ b/include/linux/vcm-drv.h
@@ -0,0 +1,117 @@
+/*
+ * Virtual Contiguous Memory driver API header
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
+ * See Documentation/virtual-contiguous-memory.txt for details.
+ */
+
+#ifndef __LINUX_VCM_DRV_H
+#define __LINUX_VCM_DRV_H
+
+#include <linux/vcm.h>
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/gfp.h>
+
+#include <linux/atomic.h>
+
+/**
+ * struct vcm_driver - the MMU driver operations.
+ * @cleanup:	called when vcm objects is destroyed; if omitted,
+ *		kfree() will be used.
+ * @alloc:	callback function for allocating physical memory and
+ *		reserving virtual address space; XXX FIXME: document;
+ *		if set, @res and @alloc are ignored.
+ * @res:	creates a reservation of virtual address space; XXX FIXME:
+ *		document; if @alloc is provided this is ignored.
+ * @phys:	allocates a physical memory; XXX FIXME: document; if @alloc
+ *		is provided this is ignored.
+ * @unreserve:	destroys a virtual address space reservation created by @alloc;
+ *		required.
+ * @map:	reserves address space and binds a physical memory to it.
+ * @bind:	binds a physical memory to a reserved address space.
+ * @unbind:	unbinds a physical memory from reserved address space.
+ * @activate:	activates the context making all bindings active; once
+ *		the context has been activated, this callback is not
+ *		called again until context is deactivated and
+ *		activated again (so if user calls vcm_activate()
+ *		several times only the first call in sequence will
+ *		invoke this callback).
+ * @deactivate:	deactivates the context making all bindings inactive;
+ *		call this callback always accompanies call to the
+ *		@activate callback.
+ */
+struct vcm_driver {
+	void (*cleanup)(struct vcm *vcm);
+
+	int (*alloc)(struct vcm *vcm, resource_size_t size,
+		     struct vcm_phys **phys, unsigned alloc_flags,
+		     struct vcm_res **res, unsigned res_flags);
+	struct vcm_res *(*res)(struct vcm *vcm, resource_size_t size,
+			       unsigned flags);
+	struct vcm_phys *(*phys)(struct vcm *vcm, resource_size_t size,
+				 unsigned flags);
+
+	void (*unreserve)(struct vcm_res *res);
+
+	struct vcm_res *(*map)(struct vcm *vcm, struct vcm_phys *phys,
+			       unsigned flags);
+	int (*bind)(struct vcm_res *res, struct vcm_phys *phys);
+	void (*unbind)(struct vcm_res *res);
+
+	int (*activate)(struct vcm *vcm);
+	void (*deactivate)(struct vcm *vcm);
+};
+
+/**
+ * struct vcm_phys - representation of allocated physical memory.
+ * @count:	number of contiguous parts the memory consists of; if this
+ *		equals one the whole memory block is physically contiguous;
+ *		read only.
+ * @size:	total size of the allocated memory; read only.
+ * @free:	callback function called when memory is freed; internal.
+ * @bindings:	how many virtual address space reservations this memory has
+ *		been bound to; internal.
+ * @parts:	array of @count parts describing each physically contiguous
+ *		memory block that the whole area consists of; each element
+ *		describes part's physical starting address in bytes
+ *		(@parts->start), its size in bytes (@parts->size) and
+ *              (optionally) pointer to first struct poge (@parts->page);
+ *		read only.
+ */
+struct vcm_phys {
+	unsigned		count;
+	resource_size_t		size;
+
+	void (*free)(struct vcm_phys *phys);
+	atomic_t		bindings;
+
+	struct vcm_phys_part {
+		phys_addr_t	start;
+		struct page	*page;
+		resource_size_t	size;
+	} parts[0];
+};
+
+/**
+ * vcm_init() - initialises VCM context structure.
+ * @vcm:	the VCM context to initialise.
+ *
+ * This function initialises the vcm structure created by a MMU driver
+ * when setting things up.  It sets up all fields of the vcm structure
+ * expect for @vcm->start, @vcm->size and @vcm->driver which are
+ * validated by this function.  If they have invalid value function
+ * produces warning and returns an error-pointer.  If everything is
+ * fine, @vcm is returned.
+ */
+struct vcm *__must_check vcm_init(struct vcm *vcm);
+
+#endif
diff --git a/include/linux/vcm.h b/include/linux/vcm.h
new file mode 100644
index 0000000..965dc9b
--- /dev/null
+++ b/include/linux/vcm.h
@@ -0,0 +1,275 @@
+/*
+ * Virtual Contiguous Memory header
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
+ * See Documentation/virtual-contiguous-memory.txt for details.
+ */
+
+#ifndef __LINUX_VCM_H
+#define __LINUX_VCM_H
+
+#include <linux/kref.h>
+#include <linux/compiler.h>
+
+struct vcm_driver;
+struct vcm_phys;
+
+/**
+ * struct vcm - A virtually contiguous memory context.
+ * @start:	the smallest possible address available in this context.
+ * @size:	size of available address space in bytes; internal, read
+ *		only for MMU drivers.
+ * @activations:	How many times context was activated; internal,
+ *			read only for MMU drivers.
+ * @driver:	driver handling this driver; internal.
+ *
+ * This structure represents a context of virtually contiguous memory
+ * managed by a MMU pointed by the @mmu pointer.  This is the main
+ * structure used to interact with the VCM framework.
+ *
+ * Whenever driver wants to reserve virtual address space or allocate
+ * backing storage this pointer to this structure must be passed.
+ *
+ */
+struct vcm {
+	dma_addr_t		start;
+	resource_size_t		size;
+	atomic_t		activations;
+	const struct vcm_driver	*driver;
+};
+
+/**
+ * struct vcm_res - A reserved virtually contiguous address space.
+ * @start:	bus address of the region in bytes; read only.
+ * @bound_size:	number of bytes actually bound to the virtual address;
+ *		read only.
+ * @res_size:	size of the reserved address space in bytes; read only.
+ * @vcm:	VCM context; internal, read only for MMU drivers.
+ * @phys:	pointer to physical memory bound to this reservation; NULL
+ *		if no physical memory is bound; read only.
+ *
+ * This structure represents a portion virtually contiguous address
+ * space reserved for use with the driver.  Once address space is
+ * reserved a physical memory can be bound to it so that it will paint
+ * to real memory.
+ */
+struct vcm_res {
+	dma_addr_t		start;
+	resource_size_t		bound_size;
+	resource_size_t		res_size;
+
+	struct vcm		*vcm;
+	struct vcm_phys		*phys;
+};
+
+
+/**
+ * vcm_destroy() - destroys a VCM context.
+ * @vcm:	VCM to destroy.
+ */
+void vcm_destroy(struct vcm *vcm);
+
+/**
+ * vcm_make_binding() - allocates memory and binds it to virtual address space
+ * @vcm:	VCM context to reserve virtual address space in
+ * @size:	number of bytes to allocate; aligned up to a PAGE_SIZE
+ * @alloc_flags:	additional allocator flags; see vcm_alloc() for
+ *			description of those.
+ * @res_flags:	additional reservation flags; see vcm_reserve() for
+ *		description of those.
+ *
+ * This is a call that binds together three other calls:
+ * vcm_reserve(), vcm_alloc() and vcm_bind().  The purpose of this
+ * function is that on systems with no IO MMU separate calls to
+ * vcm_alloc() and vcm_reserve() may fail whereas when called together
+ * they may work correctly.
+ *
+ * This is a consequence of the fact that with no IO MMU the simulated
+ * virtual address must be the same as physical address, thus if first
+ * virtual address space were to be reserved and then physical memory
+ * allocated, both addresses may not match.
+ *
+ * With this call, a driver that simulates IO MMU may simply allocate
+ * a physical memory and when this succeeds create correct reservation.
+ *
+ * In short, if device drivers do not need more advanced MMU
+ * functionolities, they should limit themselves to this function
+ * since then the drivers may be easily ported to systems without IO
+ * MMU.
+ *
+ * To access the vcm_phys structure created by this call a phys field
+ * of returned vcm_res structure should be used.
+ *
+ * On error returns a pointer which yields true when tested with
+ * IS_ERR().
+ */
+struct vcm_res  *__must_check
+vcm_make_binding(struct vcm *vcm, resource_size_t size,
+		 unsigned alloc_flags, unsigned res_flags);
+
+/**
+ * vcm_map() - makes a reservation and binds physical memory to it
+ * @vcm:	VCM context
+ * @phys:	physical memory to bind.
+ * @flags:	additional flags; see vcm_reserve() for	description of
+ *		those.
+ *
+ * This is a call that binds together two other calls: vcm_reserve()
+ * and vcm_bind().  If all you need is reserve address space and
+ * bind physical memory it's better to use this call since it may
+ * create better mappings in some situations.
+ *
+ * Drivers may be optimised in such a way that it won't be possible to
+ * use reservation with a different physical memory.
+ *
+ * On error returns a pointer which yields true when tested with
+ * IS_ERR().
+ */
+struct vcm_res *__must_check
+vcm_map(struct vcm *vcm, struct vcm_phys *phys, unsigned flags);
+
+/**
+ * vcm_alloc() - allocates a physical memory for use with vcm_res.
+ * @vcm:	VCM context allocation is performed in.
+ * @size:	number of bytes to allocate; aligned up to a PAGE_SIZE
+ * @flags:	additional allocator flags; XXX FIXME: describe
+ *
+ * In case of some MMU drivers, the @vcm may be important and later
+ * binding (vcm_bind()) may fail if done on another @vcm.
+ *
+ * On success returns a vcm_phys structure representing an allocated
+ * physical memory that can be bound to reserved virtual address
+ * space.  On error returns a pointer which yields true when tested with
+ * IS_ERR().
+ */
+struct vcm_phys *__must_check
+vcm_alloc(struct vcm *vcm, resource_size_t size, unsigned flags);
+
+/**
+ * vcm_free() - frees an allocated physical memory
+ * @phys:	physical memory to free.
+ *
+ * If the physical memory is bound to any reserved address space it
+ * must be unbound first.  Otherwise a warning will be issued and
+ * the memory won't be freed causing memory leaks.
+ */
+void vcm_free(struct vcm_phys *phys);
+
+/**
+ * vcm_reserve() - reserves a portion of virtual address space.
+ * @vcm:	VCM context reservation is performed in.
+ * @size:	number of bytes to allocate; aligned up to a PAGE_SIZE
+ * @flags:	additional reservation flags; XXX FIXME: describe
+ * @alignment:	required alignment of the reserved space; must be
+ *		a power of two or zero.
+ *
+ * On success returns a vcm_res structure representing a reserved
+ * (contiguous) virtual address space that physical memory can be
+ * bound to (using vcm_bind()).  On error returns a pointer which
+ * yields true when tested with IS_ERR().
+ */
+struct vcm_res *__must_check
+vcm_reserve(struct vcm *vcm, resource_size_t size, unsigned flags);
+
+/**
+ * vcm_unreserve() - destroyers a virtual address space reservation
+ * @res:	reservation to destroy.
+ *
+ * If any physical memory is bound to the reserved address space it
+ * must be unbound first.  Otherwise it will be unbound and warning
+ * will be issued.
+ */
+void vcm_unreserve(struct vcm_res *res);
+
+/**
+ * vcm_bind() - binds a physical memory to virtual address space
+ * @res:	virtual address space to bind the physical memory.
+ * @phys:	physical memory to bind to the virtual addresses.
+ *
+ * The mapping won't be active unless vcm_activate() on the VCM @res
+ * was created in context of was called.
+ *
+ * If @phys is already bound to @res this function returns -EALREADY.
+ * If some other physical memory is bound to @res -EADDRINUSE is
+ * returned.  If size of the physical memory is larger then the
+ * virtual space -ENOSPC is returned.  In all other cases the physical
+ * memory is bound to the virtual address and on success zero is
+ * returned, on error a negative number.
+ */
+int  __must_check vcm_bind(struct vcm_res *res, struct vcm_phys *phys);
+
+/**
+ * vcm_unbind() - unbinds a physical memory from virtual address space
+ * @res:	virtual address space to unbind the physical memory from.
+ *
+ * This reverses the effect of the vcm_bind() function.  Function
+ * returns physical space that was bound to the reservation (or NULL
+ * if no space was bound in which case also a warning is issued).
+ */
+struct vcm_phys *vcm_unbind(struct vcm_res *res);
+
+/**
+ * vcm_destroy_binding() - destroys the binding
+ * @res:	a bound reserved address space to destroy.
+ *
+ * This function incorporates three functions: vcm_unbind(),
+ * vcm_free() and vcm_unreserve() (in that order) in one call.
+ */
+void vcm_destroy_binding(struct vcm_res *res);
+
+/**
+ * vcm_unmap() - unbinds physical memory and unreserves address space
+ * @res:	reservation to destroy
+ *
+ * This is a call that binds together two other calls: vcm_unbind()
+ * and vcm_unreserve().
+ */
+static inline void vcm_unmap(struct vcm_res *res)
+{
+	vcm_unbind(res);
+	vcm_unreserve(res);
+}
+
+/**
+ * vcm_activate() - activates bindings in VCM.
+ * @vcm:	VCM to activate bindings in.
+ *
+ * All of the bindings on the @vcm done before this function is called
+ * are inactive and do not take effect.  The call to this function
+ * guarantees that all bindings are sent to the hardware MMU (if any).
+ *
+ * After VCM is activated all bindings will be automatically updated
+ * on the hardware MMU, so there is no need to call this function
+ * after each vcm_bind()/vcm_unbind().
+ *
+ * Each call to vcm_activate() should be later accompanied by a call
+ * to vcm_deactivate().  Otherwise a warning will be issued when VCM
+ * context is destroyed (vcm_destroy()).  This function can be called
+ * several times.
+ *
+ * On success returns zero, on error a negative error code.
+ */
+int  __must_check vcm_activate(struct vcm *vcm);
+
+/**
+ * vcm_deactivate() - deactivates bindings in VCM.
+ * @vcm:	VCM to deactivate bindings in.
+ *
+ * This function reverts effect of the vcm_activate() function.  After
+ * calling this function caller has no guarantee that bindings defined
+ * in VCM are active.
+ *
+ * If this is called without calling the vcm_activate() warning is
+ * issued.
+ */
+void vcm_deactivate(struct vcm *vcm);
+
+#endif
diff --git a/mm/Kconfig b/mm/Kconfig
index ae35744..7f0e4b1 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -338,6 +338,21 @@ config CMA_DEBUG
  
  	  This is mostly used during development.  If unsure, say "n".
 
+config VCM
+ 	bool "Virtual Contiguous Memory framework"
+ 	help
+ 	  This enables the Virtual Contiguous Memory framework which
+ 	  provides an abstraction for virtual address space provided by
+ 	  various MMUs present on the platform.
+
+ 	  The framework uses plugable MMU drivers for hardware MMUs and
+ 	  if drivers obeys some limitations it can be also used on
+ 	  platforms with no MMU.
+
+ 	  For more information see
+ 	  <Documentation/virtual-contiguous-memory.txt>.  If unsure, say
+ 	  "n".
+
 #
 # UP and nommu archs use km based percpu allocator
 #
diff --git a/mm/Makefile b/mm/Makefile
index 9bd9f8f..b96a6cb 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -43,3 +43,4 @@ obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
 obj-$(CONFIG_CMA) += cma.o
+obj-$(CONFIG_VCM) += vcm.o
diff --git a/mm/vcm.c b/mm/vcm.c
new file mode 100644
index 0000000..1389ee6
--- /dev/null
+++ b/mm/vcm.c
@@ -0,0 +1,304 @@
+/*
+ * Virtual Contiguous Memory core
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
+ * See Documentation/virtual-contiguous-memory.txt for details.
+ */
+
+#include <linux/vcm-drv.h>
+#include <linux/module.h>
+#include <linux/mm.h>
+#include <linux/err.h>
+#include <linux/slab.h>
+
+/******************************** Devices API *******************************/
+
+void vcm_destroy(struct vcm *vcm)
+{
+	if (WARN_ON(atomic_read(&vcm->activations)))
+		vcm->driver->deactivate(vcm);
+
+	if (vcm->driver->cleanup)
+		vcm->driver->cleanup(vcm);
+	else
+		kfree(vcm);
+}
+EXPORT_SYMBOL_GPL(vcm_destroy);
+
+static void
+__vcm_alloc_and_reserve(struct vcm *vcm, resource_size_t size,
+			struct vcm_phys **phys, unsigned alloc_flags,
+			struct vcm_res **res, unsigned res_flags)
+{
+	int ret, alloc = 0;
+
+	if (WARN_ON(!vcm) || !size) {
+		ret = -EINVAL;
+		goto error;
+	}
+
+	size = PAGE_ALIGN(size);
+
+	if (vcm->driver->alloc) {
+		ret = vcm->driver->alloc(vcm, size,
+					 phys, alloc_flags, res, res_flags);
+		if (ret)
+			goto error;
+		alloc = 1;
+	} else if ((res && !vcm->driver->res) || (phys && !vcm->driver->phys)) {
+		ret = -EOPNOTSUPP;
+		goto error;
+	}
+
+	if (res) {
+		if (!alloc) {
+			*res = vcm->driver->res(vcm, size, res_flags);
+			if (IS_ERR(*res)) {
+				ret = PTR_ERR(*res);
+				goto error;
+			}
+		}
+		(*res)->bound_size = 0;
+		(*res)->vcm = vcm;
+		(*res)->phys = NULL;
+	}
+
+	if (phys) {
+		if (!alloc) {
+			*phys = vcm->driver->phys(vcm, size, alloc_flags);
+			if (WARN_ON(!(*phys)->free))
+				phys = ERR_PTR(-EINVAL);
+			if (IS_ERR(*phys)) {
+				ret = PTR_ERR(*phys);
+				goto error;
+			}
+		}
+		atomic_set(&(*phys)->bindings, 0);
+	}
+
+	return;
+
+error:
+	if (phys)
+		*phys = ERR_PTR(ret);
+	if (res) {
+		if (*res)
+			vcm_unreserve(*res);
+		*res = ERR_PTR(ret);
+	}
+}
+
+struct vcm_res *__must_check
+vcm_make_binding(struct vcm *vcm, resource_size_t size,
+		 unsigned alloc_flags, unsigned res_flags)
+{
+	struct vcm_phys *phys;
+	struct vcm_res *res;
+
+	if (WARN_ON(!vcm || !size || (size & (PAGE_SIZE - 1))))
+		return ERR_PTR(-EINVAL);
+	else if (vcm->driver->alloc || !vcm->driver->map) {
+		int ret;
+
+		__vcm_alloc_and_reserve(vcm, size, &phys, alloc_flags,
+					&res, res_flags);
+
+		if (IS_ERR(res))
+			return res;
+
+		ret = vcm_bind(res, phys);
+		if (!ret)
+			return res;
+
+		if (vcm->driver->unreserve)
+			vcm->driver->unreserve(res);
+		phys->free(phys);
+		return ERR_PTR(ret);
+	} else {
+		__vcm_alloc_and_reserve(vcm, size, &phys, alloc_flags,
+					NULL, 0);
+
+		if (IS_ERR(phys))
+			return ERR_CAST(res);
+
+		res = vcm_map(vcm, phys, res_flags);
+		if (IS_ERR(res))
+			phys->free(phys);
+
+		return res;
+	}
+}
+EXPORT_SYMBOL_GPL(vcm_make_binding);
+
+struct vcm_phys *__must_check
+vcm_alloc(struct vcm *vcm, resource_size_t size, unsigned flags)
+{
+	struct vcm_phys *phys;
+
+	__vcm_alloc_and_reserve(vcm, size, &phys, flags, NULL, 0);
+
+	return phys;
+}
+EXPORT_SYMBOL_GPL(vcm_alloc);
+
+struct vcm_res *__must_check
+vcm_reserve(struct vcm *vcm, resource_size_t size, unsigned flags)
+{
+	struct vcm_res *res;
+
+	__vcm_alloc_and_reserve(vcm, size, NULL, 0, &res, flags);
+
+	return res;
+}
+EXPORT_SYMBOL_GPL(vcm_reserve);
+
+struct vcm_res *__must_check
+vcm_map(struct vcm *vcm, struct vcm_phys *phys, unsigned flags)
+{
+	struct vcm_res *res;
+	int ret;
+
+	if (WARN_ON(!vcm))
+		return ERR_PTR(-EINVAL);
+
+	if (vcm->driver->map) {
+		res = vcm->driver->map(vcm, phys, flags);
+		if (!IS_ERR(res)) {
+			atomic_inc(&phys->bindings);
+			res->phys       = phys;
+			res->bound_size = phys->size;
+			res->vcm        = vcm;
+		}
+		return res;
+	}
+
+	res = vcm_reserve(vcm, phys->size, flags);
+	if (IS_ERR(res))
+		return res;
+
+	ret = vcm_bind(res, phys);
+	if (!ret)
+		return res;
+
+	vcm_unreserve(res);
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL_GPL(vcm_map);
+
+void vcm_unreserve(struct vcm_res *res)
+{
+	if (!WARN_ON(!res)) {
+		if (WARN_ON(res->phys))
+			vcm_unbind(res);
+		if (!WARN_ON_ONCE(!res->vcm->driver->unreserve))
+			res->vcm->driver->unreserve(res);
+	}
+}
+EXPORT_SYMBOL_GPL(vcm_unreserve);
+
+void vcm_free(struct vcm_phys *phys)
+{
+	if (!WARN_ON(!phys || atomic_read(&phys->bindings)))
+		phys->free(phys);
+}
+EXPORT_SYMBOL_GPL(vcm_free);
+
+int  __must_check vcm_bind(struct vcm_res *res, struct vcm_phys *phys)
+{
+	int ret;
+
+	if (WARN_ON(!res || !phys))
+		return -EINVAL;
+
+	if (res->phys == phys)
+		return -EALREADY;
+
+	if (res->phys)
+		return -EADDRINUSE;
+
+	if (phys->size > res->res_size)
+		return -ENOSPC;
+
+	if (!res->vcm->driver->bind)
+		return -EOPNOTSUPP;
+
+	ret = res->vcm->driver->bind(res, phys);
+	if (ret >= 0) {
+		atomic_inc(&phys->bindings);
+		res->phys = phys;
+		res->bound_size = phys->size;
+	}
+	return ret;
+}
+EXPORT_SYMBOL_GPL(vcm_bind);
+
+struct vcm_phys *vcm_unbind(struct vcm_res *res)
+{
+	struct vcm_phys *phys = NULL;
+	if (!WARN_ON(!res || !res->phys)) {
+		phys = res->phys;
+		if (res->vcm->driver->unbind)
+			res->vcm->driver->unbind(res);
+		WARN_ON(!atomic_add_unless(&phys->bindings, -1, 0));
+		res->phys = NULL;
+		res->bound_size = 0;
+	}
+	return phys;
+}
+EXPORT_SYMBOL_GPL(vcm_unbind);
+
+void vcm_destroy_binding(struct vcm_res *res)
+{
+	if (!WARN_ON(!res)) {
+		struct vcm_phys *phys = vcm_unbind(res);
+		if (phys)
+			vcm_free(phys);
+		vcm_unreserve(res);
+	}
+}
+EXPORT_SYMBOL_GPL(vcm_destroy_binding);
+
+int  __must_check vcm_activate(struct vcm *vcm)
+{
+	if (WARN_ON(!vcm))
+		return -EINVAL;
+	else if (atomic_inc_return(&vcm->activations) != 1
+	      || !vcm->driver->activate)
+		return 0;
+	else
+		return vcm->driver->activate(vcm);
+}
+EXPORT_SYMBOL_GPL(vcm_activate);
+
+void vcm_deactivate(struct vcm *vcm)
+{
+	if (!WARN_ON(!vcm || !atomic_read(&vcm->activations))
+	 && atomic_dec_and_test(&vcm->activations)
+	 && vcm->driver->deactivate)
+		vcm->driver->deactivate(vcm);
+}
+EXPORT_SYMBOL_GPL(vcm_deactivate);
+
+
+/****************************** VCM Drivers API *****************************/
+
+struct vcm *__must_check vcm_init(struct vcm *vcm)
+{
+	if (WARN_ON(!vcm || !vcm->size
+		 || ((vcm->start | vcm->size) & ~PAGE_MASK)
+		 || !vcm->driver || !vcm->driver->unreserve))
+		return ERR_PTR(-EINVAL);
+
+	atomic_set(&vcm->activations, 0);
+
+	return vcm;
+}
+EXPORT_SYMBOL_GPL(vcm_init);
-- 
1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
