Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DE6D36B008C
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 02:35:14 -0400 (EDT)
Received: from eu_spt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0L8B00JFLBMMJX@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Mon, 06 Sep 2010 07:35:11 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L8B004YWBMLY2@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 06 Sep 2010 07:35:10 +0100 (BST)
Date: Mon, 06 Sep 2010 08:33:57 +0200
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [RFCv5 7/9] mm: vcm: Virtual Contiguous Memory framework added
In-reply-to: <cover.1283749231.git.mina86@mina86.com>
Message-id: 
 <528bda37c43c55cde9f89d56882cea2113d8d7d4.1283749231.git.mina86@mina86.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <cover.1283749231.git.mina86@mina86.com>
Sender: owner-linux-mm@kvack.org
To: linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Jonathan Corbet <corbet@lwn.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Pawel Osciak <p.osciak@samsung.com>, Peter Zijlstra <peterz@infradead.org>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

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
 Documentation/virtual-contiguous-memory.txt |  853 ++++++++++++++++++++++++
 include/linux/vcm-drv.h                     |  299 +++++++++
 include/linux/vcm.h                         |  275 ++++++++
 mm/Kconfig                                  |   30 +
 mm/Makefile                                 |    1 +
 mm/vcm.c                                    |  932 +++++++++++++++++++++++++++
 7 files changed, 2392 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/virtual-contiguous-memory.txt
 create mode 100644 include/linux/vcm-drv.h
 create mode 100644 include/linux/vcm.h
 create mode 100644 mm/vcm.c

diff --git a/Documentation/00-INDEX b/Documentation/00-INDEX
index f93e787..7c79ffa 100644
--- a/Documentation/00-INDEX
+++ b/Documentation/00-INDEX
@@ -344,6 +344,8 @@ video-output.txt
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
index 0000000..0c0e90c
--- /dev/null
+++ b/Documentation/virtual-contiguous-memory.txt
@@ -0,0 +1,853 @@
+                                                             -*- org -*-
+
+This document covers how to use the Virtual Contiguous Memory Manager
+(VCMM), how the implementation works, and how to implement MMU drivers
+that can be plugged into VCMM.  It also contains a rationale for VCMM.
+
+* The Virtual Contiguous Memory Manager
+
+The VCMM was built to solve the system-wide memory mapping issues that
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
+The VCMM API enables device independent IOMMU control, virtual memory
+manager (VMM) interoperation and non-IOMMU enabled device
+interoperation by treating devices with or without IOMMUs and all CPUs
+with or without MMUs, their mapping contexts and their mappings using
+common abstractions.  Physical hardware is given a generic device type
+and mapping contexts are abstracted into Virtual Contiguous Memory
+(VCM) regions.  Users "reserve" memory from VCMs and "bind" their
+reservations with physical memory.
+
+If drivers limit their use of VCM contexts to a some subset of VCMM
+functionality, they can work with no changes with or without MMU.
+
+** Why the VCMM is Needed
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
+The VCMM contains an IOMMU programming layer, but since its
+abstraction supports map management independent of device control, the
+layer is not used directly.  This higher-level view enables a new
+kernel service, not just an IOMMU interoperation layer.
+
+** The General Idea: Map Management using Graphs
+
+Looking at mapping from a system-wide perspective reveals a general
+graph problem.  The VCMM's API is built to manage the general mapping
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
+overlay allows VCMM-managed mappings to interoperate with the common
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
+If driver does not require more complicated VCMM functionality, it is
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
+** IOMMU, one-to-one and VMM contexts
+
+The following example demonstrates mapping IOMMU, one-to-one and VMM
+reservations to the same physical memory.  For readability, error
+handling is not shown on the listings.
+
+First, each contexts needs to be created.  A call used for creating
+context is dependent on the driver used.  The following is just an
+example of how this could look like:
+
+	struct vcm *vcm_vmm, *vcm_onetoone, *vcm_iommu;
+
+	vcm_vmm      = vcm_vmm_create();
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
+What's left is map the space in the other two contexts.  If the
+reservation in the other two contexts won't be used for any other
+purpose then to reference the memory allocated in above, it's best to
+use vcm_map():
+
+	struct vcm_res *res_vcm, *res_iommu;
+
+	res_vmm = vcm_map(vcm_vmm, res_onetoone->phys, 0);
+	res_iommu = vcm_map(vcm_iommu, res_onetoone->phys, 0);
+
+Once the bindings have been created, the contexts need to be activated
+to make sure that they are actually on the hardware. (In case of
+one-to-one mapping it's most likely a no-operation but it's still
+required by the VCMM API so it must not be omitted.)
+
+	vcm_activate(vcm_vmm);
+	vcm_activate(vcm_onetoone);
+	vcm_activate(vcm_iommu);
+
+At this point, all three reservations represent addresses in
+respective address space that is bound to a physical memory.  Not only
+CPU can access it now but also devices connected through the MMU, as
+well as devices connected directly to the memory banks.  The bus
+address for the devices and virtual address for the CPU is available
+through the 'start' member of the vcm_res structure (ie. res_* objects
+above).
+
+Once the mapping is no longer used and memory no longer needed it can
+be freed as follows:
+
+	vcm_unmap(res_vmm);
+	vcm_unmap(res_iommu);
+	vcm_destroy_binding(res_onetoone);
+
+If the contexts are not needed either, they can be disabled:
+
+	vcm_deactivate(vcm_vmm);
+	vcm_deactivate(vcm_iommu);
+	vcm_deactivate(vcm_onetoone);
+
+and than, even destroyed:
+
+	vcm_destroy(vcm_vmm);
+	vcm_destroy(vcm_iommu);
+	vcm_destroy(vcm_onetoone);
+
+* Available drivers
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
+under some conditions, vcm_map() may also work.
+
+There are no One-to-One drivers at this time.
+
+* Writing a VCM driver
+
+The core of VCMM does not handle communication with the MMU.  For this
+purpose a VCM driver is used.  Its purpose is to manage virtual
+address space reservations, physical allocations as well as updating
+mappings in the hardware MMU.
+
+API designed for VCM drivers is described in the
+[[file:../include/linux/vcm-drv.h][include/linux/vcm-drv.h]] file so it might be a good idea to take a look
+inside.
+
+VCMM provides API for three different kinds of drivers.  The most
+basic is a core VCM which VCMM use directly.  Other then that, VCMM
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
+structure -- all other fields are filled by the VCMM framework.
+
+The phys operation allocates physical space which can later be bound
+to the reservation.  Unless VCM driver needs some special handling of
+physical memory, the vcm_phys_alloc() function can be used:
+
+	struct vcm_phys *__must_check
+	vcm_phys_alloc(resource_size_t size, unsigned flags,
+		       const unsigned char *orders);
+
+The last argument of this function (orders) is an array of orders of
+page sizes that function should try to allocate.  This array must be
+sorted from highest order to lowest and the last entry must be zero.
+
+For instance, an array { 8, 4, 0 } means that the function should try
+and allocate 1MiB, 64KiB and 4KiB pages (this is assuming PAGE_SIZE is
+4KiB which is true for all supported architectures).  For example, if
+requested size is 2MiB and 68 KiB, the function will try to allocate
+two 1MiB pages, one 64KiB page and one 4KiB page.  This may be useful
+when the mapping is written to the MMU since the largest possible
+pages will be used reducing the number of entries.
+
+If phys or alloc callback chooses to allocate physical memory on its
+own, it must provide a free callback along with the vcm_phys
+structure.  The purpose of the callback is, as one may imagine, to
+free allocated space.
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
+a physical memory.  If unbind operation is not provided, VCMM assumes
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
+Neither of the operations are required and if missing, VCMM will
+assume they are a no-operation and no warning will be generated.
+
+** Writing a hardware MMU driver
+
+It may be undesirable to implement all of the operations that are
+required to create a usable driver.  In case of hardware MMUs a helper
+wrapper driver has been created to make writing real drivers as simple
+as possible.
+
+The wrapper implements most of the functionality of the driver leaving
+only implementation of the actual talking to the hardware MMU in hands
+of programmer.  Reservations managements as general housekeeping is
+already there.
+
+If you want to use this wrapper, you need to select VCM_MMU Kconfig
+option.
+
+*** Context creation
+
+Similarly to normal drivers, MMU driver needs to provide a context
+creation function.  Such a function must provide a vcm_mmu object and
+initialise vcm.start, vcm.size and driver fields of the structure.
+When this is done, vcm_mmu_init() should be called which will
+initialise the rest of the fields and validate entered values:
+
+	struct vcm *__must_check vcm_mmu_init(struct vcm_mmu *mmu);
+
+This is, in fact, very similar to the way standard driver is created.
+
+*** Orders
+
+One of the fields of the vcm_mmu_driver structure is orders.  This is
+an array of orders of pages supported by the hardware MMU.  It must be
+sorted from largest to smallest and zero terminated.
+
+The order is the logarithm with the base two of the size of supported
+page size divided by PAGE_SIZE.  For instance, { 8, 4, 0 } means that
+MMU supports 1MiB, 64KiB and 4KiB pages.
+
+*** Operations
+
+The three operations that MMU wrapper driver uses are:
+
+	void (*cleanup)(struct vcm *vcm);
+
+	int (*activate)(struct vcm_res *res, struct vcm_phys *phys);
+	void (*deactivate)(struct vcm_res *res, struct vcm_phys *phys);
+
+	int (*activate_page)(dma_addr_t vaddr, dma_addr_t paddr,
+			     unsigned order, void *vcm),
+	int (*deactivate_page)(dma_addr_t vaddr, dma_addr_t paddr,
+			       unsigned order, void *vcm),
+
+The first one frees all resources allocated by the context creation
+function (including the structure itself).  If this operation is not
+given, kfree() will be called on vcm_mmu structure.
+
+The activate and deactivate operations are required and they are used
+to update mappings in the MMU.  Whenever binding is activated or
+deactivated the respective operation is called.
+
+To divide mapping into physical pages, vcm_phys_walk() function can be
+used:
+
+	int vcm_phys_walk(dma_addr_t vaddr, const struct vcm_phys *phys,
+			  const unsigned char *orders,
+			  int (*callback)(dma_addr_t vaddr, dma_addr_t paddr,
+					  unsigned order, void *priv),
+			  int (*recovery)(dma_addr_t vaddr, dma_addr_t paddr,
+					  unsigned order, void *priv),
+			  void *priv);
+
+It start from given virtual address and tries to divide allocated
+physical memory to as few pages as possible where order of each page
+is one of the orders specified by orders argument.
+
+It may be easier to implement activate_page and deactivate_page
+operations instead thought.  They are called on each individual page
+rather then the whole mapping.  It basically incorporates call to the
+vcm_phys_walk() function so driver does not need to call it
+explicitly.
+
+** Writing a one-to-one VCM driver
+
+
+
+Similarly to a wrapper for a real hardware MMU a wrapper for
+one-to-one VCM contexts has been created.  It implements all of the
+houskeeping operations and leaves only contiguous memory management
+(that is allocating and freeing contiguous regions).
+
+*** Context creation
+
+As with other drivers, one-to-one driver needs to provide a context
+creation function.  It needs to allocate space for vcm_o2o structure
+and initialise its vcm.start, vcm.end and driver fields.  Calling
+vcm_o2o_init() will fill the other fields and validate entered values:
+
+	struct vcm *__must_check vcm_o2o_init(struct vcm_o2o *o2o);
+
+There are the following three operations used by the wrapper:
+
+	void (*cleanup)(struct vcm *vcm);
+	void *(*alloc)(struct vcm *vcm, struct vcm_phys_part *part,
+		       unsigned flags);
+	void (*free)(struct vcm_phys_part *part, void *priv);
+
+The cleanup operation cleans the context and frees all resources.  If
+not provided, kfree() is used.
+
+The alloc operation allocates physically contiguous memory.  The size
+of requested block is saved in the provided vcm_phys_part structure.
+Inside this structure, the operation must save the physical address of
+the allocated block if allocation succeeds.  On error, the operation
+must return an error-pointer (NULL is treated as success).
+
+The free operation frees the physically contiguous memory that has
+been allocated with alloc.  As arguments, it is given the same
+vcm_phy_part structure that alloc initialised as well as a priv
+argument which is the value returned by alloc operation.
+
+Both, alloc and free, operations are required.
+
+If you want to use this wrapper, you need to select VCM_O2O Kconfig
+option.
+
+* Epilogue
+
+The initial version of the VCMM framework was written by Zach Pfeffer
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
index 0000000..8c1862e
--- /dev/null
+++ b/include/linux/vcm-drv.h
@@ -0,0 +1,299 @@
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
+
+#include <asm/atomic.h>
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
+ * @res:	allocates a physical memory; XXX FIXME: document; if @alloc
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
+ *		(@parts->start) and its size in bytes (@parts->size); read
+ *		only.
+ */
+struct vcm_phys {
+	unsigned		count;
+	resource_size_t		size;
+
+	void (*free)(struct vcm_phys *phys);
+	atomic_t		bindings;
+
+	struct vcm_phys_part {
+		dma_addr_t	start;
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
+#ifdef CONFIG_VCM_MMU
+
+struct vcm_mmu;
+
+/**
+ * struct vcm_mmu_driver - a driver used for real MMUs.
+ * @orders:	array of orders of pages supported by the MMU sorted from
+ *		the largest to the smallest.  The last element is always
+ *		zero (which means 4K page).
+ * @cleanup:	Function called when the VCM context is destroyed;
+ *		optional, if not provided, kfree() is used.
+ * @activate:	callback function for activating a single mapping; it's
+ *		role is to set up the MMU so that reserved address space
+ *		donated by res will point to physical memory donated by
+ *		phys; required unless @activate_page and @deactivate_page
+ *		are both provided
+ * @deactivate:	this reverses the effect of @activate; required unless
+ *		@deactivate_page is provided.
+ * @activate_page:	callback function for activating a single page; it is
+ *			ignored if @activate is provided; it's given a single
+ *			page such that its order (given as third argument) is
+ *			one of the supported orders specified in @orders;
+ *			required unless @activate is provided.
+ * @deactivate_page:	this reverses the effect of the @activate_page
+ *			callback; required unless @activate and @deactivate
+ *			are both provided.
+ */
+struct vcm_mmu_driver {
+	const unsigned char	*orders;
+
+	void (*cleanup)(struct vcm *vcm);
+	int (*activate)(struct vcm_res *res, struct vcm_phys *phys);
+	void (*deactivate)(struct vcm_res *res, struct vcm_phys *phys);
+	int (*activate_page)(dma_addr_t vaddr, dma_addr_t paddr,
+			     unsigned order, void *vcm);
+	int (*deactivate_page)(dma_addr_t vaddr, dma_addr_t paddr,
+			       unsigned order, void *vcm);
+};
+
+/**
+ * struct vcm_mmu - VCM MMU context
+ * @vcm:	VCM context.
+ * @driver:	VCM MMU driver's operations.
+ * @pool:	virtual address space allocator; internal.
+ * @bound_res:	list of bound reservations; internal.
+ * @mutex:	mutext protecting @bound_res; internal.
+ * @activated:	whether VCM context has been activated; internal.
+ */
+struct vcm_mmu {
+	struct vcm			vcm;
+	const struct vcm_mmu_driver	*driver;
+	/* internal */
+	struct gen_pool			*pool;
+	struct list_head		bound_res;
+	/* The mutex protects operations on bound_res list and list. */
+	struct mutex			mutex;
+	int				activated;
+};
+
+/**
+ * vcm_mmu_init() - initialises a VCM context for a real MMU.
+ * @mmu:	the vcm_mmu context to initialise.
+ *
+ * This function initialises the vcm_mmu structure created by a MMU
+ * driver when setting things up.  It sets up all fields of the
+ * structure expect for @mmu->vcm.start, @mmu.vcm->size and
+ * @mmu->driver which are validated by this function.  If they have
+ * invalid value function produces warning and returns an
+ * error-pointer.  On any other error, an error-pointer is returned as
+ * well.  If everything is fine, address of @mmu->vcm is returned.
+ */
+struct vcm *__must_check vcm_mmu_init(struct vcm_mmu *mmu);
+
+#endif
+
+#ifdef CONFIG_VCM_O2O
+
+/**
+ * struct vcm_o2o_driver - VCM One-to-One driver
+ * @cleanup:	cleans up the VCM context; if not specified. kfree() is used.
+ * @alloc:	physically contiguous memory allocator; the size of the
+ *		block to allocate is specified by part->size; the physical
+ *		address of the block must be returned in part->start;
+ *		on error must return an error-pointer, otherwise some
+ *		other pointer which will be passed to @free as priv;
+ *		required.
+ * @free:	physical memory freeing function; required.
+ */
+struct vcm_o2o_driver {
+	void (*cleanup)(struct vcm *vcm);
+	void *(*alloc)(struct vcm *vcm, struct vcm_phys_part *part,
+		       unsigned flags);
+	void (*free)(struct vcm_phys_part *part, void *priv);
+};
+
+/**
+ * struct vcm_o2o - VCM One-to-One context
+ * @vcm:	VCM context.
+ * @driver:	VCM One-to-One driver's operations.
+ */
+struct vcm_o2o {
+	struct vcm			vcm;
+	const struct vcm_o2o_driver	*driver;
+};
+
+/**
+ * vcm_mmu_init() - initialises a VCM context for a one-to-one context.
+ * @o2o:	the vcm_o2o context to initialise.
+ *
+ * This function initialises the vcm_o2o structure created by a O2O
+ * driver when setting things up.  It sets up all fields of the
+ * structure expect for @o2o->vcm.start, @o2o->vcm.size and
+ * @o2o->driver which are validated by this function.  If they have
+ * invalid value function produces warning and returns an
+ * error-pointer.  On any other error, an error-pointer is returned as
+ * well.  If everything is fine, address of @o2o->vcm is returned.
+ */
+struct vcm *__must_check vcm_o2o_init(struct vcm_o2o *o2o);
+
+#endif
+
+#ifdef CONFIG_VCM_PHYS
+
+/**
+ * vcm_phys_alloc() - allocates physical discontiguous space
+ * @size:	size of the block to allocate.
+ * @flags:	additional allocation flags; XXX FIXME: document
+ * @orders:	array of orders of pages supported by the MMU sorted from
+ *		the largest to the smallest.  The last element is always
+ *		zero (which means 4K page).
+ *
+ * This function tries to allocate a physical discontiguous space in
+ * such a way that it allocates the largest possible blocks from the
+ * sizes donated by the @orders array.  So if @orders is { 8, 0 }
+ * (which means 1MiB and 4KiB pages are to be used) and requested
+ * @size is 2MiB and 12KiB the function will try to allocate two 1MiB
+ * pages and three 4KiB pages (in that order).  If big page cannot be
+ * allocated the function will still try to allocate more smaller
+ * pages.
+ */
+struct vcm_phys *__must_check
+vcm_phys_alloc(resource_size_t size, unsigned flags,
+	       const unsigned char *orders);
+
+/**
+ * vcm_phys_walk() - helper function for mapping physical pages
+ * @vaddr:	virtual address to map/unmap physical space to/from
+ * @phys:	physical space
+ * @orders:	array of orders of pages supported by the MMU sorted from
+ *		the largest to the smallest.  The last element is always
+ *		zero (which means 4K page).
+ * @callback:	function called for each page.
+ * @recover:	function called for each page when @callback returns
+ *		negative number; if it also returns negative number
+ *		function terminates; may be NULL.
+ * @priv:	private data for the callbacks.
+ *
+ * This function walks through @phys trying to mach largest possible
+ * page size donated by @orders.  For each such page @callback is
+ * called.  If @callback returns negative number the function calls
+ * @recover for each page @callback was called successfully.
+ *
+ * So, for instance, if we have a physical memory which consist of
+ * 1Mib part and 8KiB part and @orders is { 8, 0 } (which means 1MiB
+ * and 4KiB pages are to be used), @callback will be called first with
+ * 1MiB page and then two times with 4KiB page.  This is of course
+ * provided that @vaddr has correct alignment.
+ *
+ * The idea is for hardware MMU drivers to call this function and
+ * provide a callbacks for mapping/unmapping a single page.  The
+ * function divides the region into pages that the MMU can handle.
+ *
+ * If @callback at one point returns a negative number this is the
+ * return value of the function; otherwise zero is returned.
+ */
+int vcm_phys_walk(dma_addr_t vaddr, const struct vcm_phys *phys,
+		  const unsigned char *orders,
+		  int (*callback)(dma_addr_t vaddr, dma_addr_t paddr,
+				  unsigned order, void *priv),
+		  int (*recovery)(dma_addr_t vaddr, dma_addr_t paddr,
+				  unsigned order, void *priv),
+		  void *priv);
+
+#endif
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
index b410910..0445f68 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -371,3 +371,33 @@ config CMA_BEST_FIT
 	  the number of allocated regions and usually much smaller).  It
 	  allocates area from the smallest hole that is big enough for
 	  allocation in question.
+
+
+config VCM
+	bool "Virtual Contiguous Memory framework"
+	help
+	  This enables the Virtual Contiguous Memory framework which
+	  provides an abstraction for virtual address space provided by
+	  various MMUs present on the platform.
+
+	  The framework uses plugable MMU drivers for hardware MMUs and
+	  if drivers obeys some limitations it can be also used on
+	  platforms with no MMU.
+
+	  For more information see
+	  <Documentation/virtual-contiguous-memory.txt>.  If unsure, say
+	  "n".
+
+# Select it if you need vcm_mmu wrapper driver
+config VCM_MMU
+	select VCM_PHYS
+	select GENERIC_ALLOCATOR
+	bool
+
+# Select if you need vcm_o2o wrapper driver
+config VCM_O2O
+	bool
+
+# Select if you need vcm_phys_alloc() or vcm_phys_walk() functions
+config VCM_PHYS
+	bool
diff --git a/mm/Makefile b/mm/Makefile
index d8c717f..e908202 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -49,3 +49,4 @@ obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
 obj-$(CONFIG_CMA) += cma.o
 obj-$(CONFIG_CMA_BEST_FIT) += cma-best-fit.o
+obj-$(CONFIG_VCM) += vcm.o
diff --git a/mm/vcm.c b/mm/vcm.c
new file mode 100644
index 0000000..ef3d1a6
--- /dev/null
+++ b/mm/vcm.c
@@ -0,0 +1,932 @@
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
+#include <linux/genalloc.h>
+
+#include <asm/atomic.h>
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
+	int ret, alloc;
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
+			if (IS_ERR(*phys)) {
+				vcm_unreserve(*res);
+				ret = PTR_ERR(*phys);
+				goto error;
+			}
+		}
+		atomic_set(&(*phys)->bindings, 0);
+		WARN_ON(!(*phys)->free);
+	}
+
+	return;
+
+error:
+	if (phys)
+		*phys = ERR_PTR(ret);
+	if (res)
+		*res = ERR_PTR(ret);
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
+		res = vcm->driver->map(vcm, phys, res_flags);
+		if (IS_ERR(res))
+			phys->free(phys);
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
+	if (vcm->driver->map)
+		return vcm->driver->map(vcm, phys, flags);
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
+	if (!WARN_ON(!phys || atomic_read(&phys->bindings)) && phys->free)
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
+	if (res->vcm->driver->bind)
+		return -EOPNOTSUPP;
+
+	atomic_inc(&phys->bindings);
+	ret = res->vcm->driver->bind(res, phys);
+	if (ret)
+		res->bound_size = phys->size;
+	else
+		atomic_dec(&phys->bindings);
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
+		atomic_dec(&phys->bindings);
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
+
+
+/*************************** Hardware MMU wrapper ***************************/
+
+#ifdef CONFIG_VCM_MMU
+
+struct vcm_mmu_res {
+	struct vcm_res			res;
+	struct list_head		bound;
+};
+
+static void vcm_mmu_cleanup(struct vcm *vcm)
+{
+	struct vcm_mmu *mmu = container_of(vcm, struct vcm_mmu, vcm);
+	WARN_ON(mutex_is_locked(&mmu->mutex));
+	gen_pool_destroy(mmu->pool);
+	if (mmu->driver->cleanup)
+		mmu->driver->cleanup(vcm);
+	else
+		kfree(mmu);
+}
+
+static struct vcm_res *
+vcm_mmu_res(struct vcm *vcm, resource_size_t size, unsigned flags)
+{
+	struct vcm_mmu *mmu = container_of(vcm, struct vcm_mmu, vcm);
+	resource_size_t s, alignment;
+	struct vcm_mmu_res *res;
+	const unsigned char *orders;
+	dma_addr_t addr;
+
+	res = kzalloc(sizeof *res, GFP_KERNEL);
+	if (!res)
+		return ERR_PTR(-ENOMEM);
+
+	/*
+	 * Use the largest alignment that makes sense for given
+	 * reservation size.  For instance, if MMU supports 1M pages
+	 * and reservation is 1M it would be nice to be able to have
+	 * reservation aligned to 1M so that if the physical memory
+	 * will consist of a single 1M block (aligned to 1M) a single
+	 * map entry will suffice.
+	 */
+	s = size >> PAGE_SHIFT;
+	for (orders = mmu->driver->orders; !(s >> *orders); ++orders)
+		/* nop */;
+	alignment = (resource_size_t)1 << (*orders + PAGE_SHIFT);
+
+	/*
+	 * We are allocating a bit more so that if allocation is not
+	 * aligned we can shift inside allocated block to get
+	 * allocation we want.
+	 */
+	s = size + alignment - PAGE_SIZE;
+
+	mutex_lock(&mmu->mutex);
+
+	addr = gen_pool_alloc(mmu->pool, s);
+
+	if (!addr) {
+		kfree(res);
+		res = ERR_PTR(-ENOSPC);
+	} else if (alignment > PAGE_SIZE) {
+		/*
+		 * Align the reservation.  We can safely do this since
+		 * we have allocated more memory then we needed and we
+		 * can move reservation around.
+		 */
+		dma_addr_t start = ALIGN(addr, alignment);
+
+		/* Free unused memory. */
+		if (start != addr)
+			gen_pool_free(mmu->pool, addr, start - addr);
+		if (start + size != addr + s)
+			gen_pool_free(mmu->pool, start + size,
+				      addr + s - (start + size));
+		addr = start;
+	}
+
+	mutex_unlock(&mmu->mutex);
+
+	if (!IS_ERR(res)) {
+		INIT_LIST_HEAD(&res->bound);
+		res->res.start = addr;
+		res->res.res_size = size;
+	}
+
+	return &res->res;
+}
+
+static struct vcm_phys *
+vcm_mmu_phys(struct vcm *vcm, resource_size_t size, unsigned flags)
+{
+	return vcm_phys_alloc(size, flags,
+			      container_of(vcm, struct vcm_mmu,
+					   vcm)->driver->orders);
+}
+
+static int __must_check
+__vcm_mmu_activate(struct vcm_res *res, struct vcm_phys *phys)
+{
+	struct vcm_mmu *mmu = container_of(res->vcm, struct vcm_mmu, vcm);
+	if (mmu->driver->activate)
+		return mmu->driver->activate(res, phys);
+
+	return vcm_phys_walk(res->start, phys, mmu->driver->orders,
+			     mmu->driver->activate_page,
+			     mmu->driver->deactivate_page, res->vcm);
+}
+
+static void __vcm_mmu_deactivate(struct vcm_res *res, struct vcm_phys *phys)
+{
+	struct vcm_mmu *mmu = container_of(res->vcm, struct vcm_mmu, vcm);
+	if (mmu->driver->deactivate)
+		return mmu->driver->deactivate(res, phys);
+
+	vcm_phys_walk(res->start, phys, mmu->driver->orders,
+		      mmu->driver->deactivate_page, NULL, res->vcm);
+}
+
+static int vcm_mmu_bind(struct vcm_res *_res, struct vcm_phys *phys)
+{
+	struct vcm_mmu_res *res = container_of(_res, struct vcm_mmu_res, res);
+	struct vcm_mmu *mmu = container_of(_res->vcm, struct vcm_mmu, vcm);
+	int ret;
+
+	mutex_lock(&mmu->mutex);
+
+	if (mmu->activated) {
+		ret = __vcm_mmu_activate(_res, phys);
+		if (ret)
+			goto done;
+	}
+
+	list_add_tail(&res->bound, &mmu->bound_res);
+	ret = 0;
+
+done:
+	mutex_unlock(&mmu->mutex);
+
+	return ret;
+}
+
+static void vcm_mmu_unbind(struct vcm_res *_res)
+{
+	struct vcm_mmu_res *res = container_of(_res, struct vcm_mmu_res, res);
+	struct vcm_mmu *mmu = container_of(_res->vcm, struct vcm_mmu, vcm);
+
+	mutex_lock(&mmu->mutex);
+
+	if (mmu->activated)
+		__vcm_mmu_deactivate(_res, _res->phys);
+
+	list_del_init(&res->bound);
+
+	mutex_unlock(&mmu->mutex);
+}
+
+static void vcm_mmu_unreserve(struct vcm_res *res)
+{
+	struct vcm_mmu *mmu = container_of(res->vcm, struct vcm_mmu, vcm);
+	mutex_lock(&mmu->mutex);
+	gen_pool_free(mmu->pool, res->start, res->res_size);
+	mutex_unlock(&mmu->mutex);
+}
+
+static int vcm_mmu_activate(struct vcm *vcm)
+{
+	struct vcm_mmu *mmu = container_of(vcm, struct vcm_mmu, vcm);
+	struct vcm_mmu_res *r, *rr;
+	int ret;
+
+	mutex_lock(&mmu->mutex);
+
+	list_for_each_entry(r, &mmu->bound_res, bound) {
+		ret = __vcm_mmu_activate(&r->res, r->res.phys);
+		if (ret < 0)
+			continue;
+
+		list_for_each_entry(rr, &mmu->bound_res, bound) {
+			if (r == rr)
+				goto done;
+			__vcm_mmu_deactivate(&rr->res, rr->res.phys);
+		}
+	}
+
+	mmu->activated = 1;
+	ret = 0;
+
+done:
+	mutex_unlock(&mmu->mutex);
+
+	return ret;
+}
+
+static void vcm_mmu_deactivate(struct vcm *vcm)
+{
+	struct vcm_mmu *mmu = container_of(vcm, struct vcm_mmu, vcm);
+	struct vcm_mmu_res *r;
+
+	mutex_lock(&mmu->mutex);
+
+	mmu->activated = 0;
+
+	list_for_each_entry(r, &mmu->bound_res, bound)
+		mmu->driver->deactivate(&r->res, r->res.phys);
+
+	mutex_unlock(&mmu->mutex);
+}
+
+struct vcm *__must_check vcm_mmu_init(struct vcm_mmu *mmu)
+{
+	static const struct vcm_driver driver = {
+		.cleanup	= vcm_mmu_cleanup,
+		.res		= vcm_mmu_res,
+		.phys		= vcm_mmu_phys,
+		.bind		= vcm_mmu_bind,
+		.unbind		= vcm_mmu_unbind,
+		.unreserve	= vcm_mmu_unreserve,
+		.activate	= vcm_mmu_activate,
+		.deactivate	= vcm_mmu_deactivate,
+	};
+
+	struct vcm *vcm;
+	int ret;
+
+	if (WARN_ON(!mmu || !mmu->driver ||
+		    !(mmu->driver->activate ||
+		      (mmu->driver->activate_page &&
+		       mmu->driver->deactivate_page)) ||
+		    !(mmu->driver->deactivate ||
+		      mmu->driver->deactivate_page)))
+		return ERR_PTR(-EINVAL);
+
+	mmu->vcm.driver = &driver;
+	vcm = vcm_init(&mmu->vcm);
+	if (IS_ERR(vcm))
+		return vcm;
+
+	mmu->pool = gen_pool_create(PAGE_SHIFT, -1);
+	if (!mmu->pool)
+		return ERR_PTR(-ENOMEM);
+
+	ret = gen_pool_add(mmu->pool, mmu->vcm.start, mmu->vcm.size, -1);
+	if (ret) {
+		gen_pool_destroy(mmu->pool);
+		return ERR_PTR(ret);
+	}
+
+	vcm->driver     = &driver;
+	INIT_LIST_HEAD(&mmu->bound_res);
+	mutex_init(&mmu->mutex);
+
+	return &mmu->vcm;
+}
+EXPORT_SYMBOL_GPL(vcm_mmu_init);
+
+#endif
+
+/**************************** One-to-One wrapper ****************************/
+
+#ifdef CONFIG_VCM_O2O
+
+struct vcm_o2o_binding {
+	void			*priv;
+	unsigned long		dead[1];
+	struct vcm_res		res;
+	struct vcm_phys		phys;
+	/* vcm_phys is variable length, don't put anything at the end */
+};
+
+static void vcm_o2o_cleanup(struct vcm *vcm)
+{
+	struct vcm_o2o *o2o = container_of(vcm, struct vcm_o2o, vcm);
+	if (o2o->driver->cleanup)
+		o2o->driver->cleanup(vcm);
+	else
+		kfree(o2o);
+}
+
+static void vcm_o2o_free(struct vcm_phys *phys)
+{
+	struct vcm_o2o_binding *b =
+		container_of(phys, struct vcm_o2o_binding, phys);
+	struct vcm_o2o *o2o =
+		container_of(b->res.vcm, struct vcm_o2o, vcm);
+	o2o->driver->free(phys->parts, b->priv);
+	if (test_and_set_bit(0, b->dead))
+		kfree(b);
+}
+
+static void vcm_o2o_unreserve(struct vcm_res *res)
+{
+	struct vcm_o2o_binding *b =
+		container_of(res, struct vcm_o2o_binding, res);
+	if (test_and_set_bit(0, b->dead))
+		kfree(b);
+}
+
+static struct vcm_phys *
+vcm_o2o_phys(struct vcm *vcm, resource_size_t size, unsigned flags)
+{
+	struct vcm_o2o *o2o = container_of(vcm, struct vcm_o2o, vcm);
+	struct vcm_o2o_binding *b;
+	void *priv;
+
+	b = kmalloc(sizeof *b + sizeof *b->phys.parts, GFP_KERNEL);
+	if (!b)
+		return ERR_PTR(-ENOMEM);
+
+	b->phys.parts->start = 0;
+	b->phys.parts->size  = size;
+	priv = o2o->driver->alloc(vcm, b->phys.parts, flags);
+	if (IS_ERR(priv)) {
+		kfree(b);
+		return ERR_CAST(priv);
+	}
+
+	if (WARN_ON(!b->phys.parts->size ||
+		    (b->phys.parts->start | b->phys.parts->size)
+		  & ~PAGE_MASK)) {
+		o2o->driver->free(b->phys.parts, b->priv);
+		kfree(b);
+		return ERR_PTR(-EINVAL);
+	}
+
+	b->priv		= priv;
+	b->dead[0]	= ~0;
+	b->res.start	= b->phys.parts->start;
+	b->res.res_size	= b->phys.parts->size;
+	b->phys.size	= b->phys.parts->size;
+	b->phys.count	= 1;
+	b->phys.free	= vcm_o2o_free;
+
+	return &b->phys;
+}
+
+static struct vcm_res *
+vcm_o2o_map(struct vcm *vcm, struct vcm_phys *phys, unsigned flags)
+{
+	struct vcm_o2o_binding *b =
+		container_of(phys, struct vcm_o2o_binding, phys);
+
+	if (!test_and_clear_bit(0, b->dead))
+		return ERR_PTR(-EBUSY);
+
+	return &b->res;
+}
+
+static int vcm_o2o_bind(struct vcm_res *res, struct vcm_phys *phys)
+{
+	struct vcm_o2o_binding *b =
+		container_of(res, struct vcm_o2o_binding, res);
+
+	if (&b->phys != phys)
+		return -EOPNOTSUPP;
+
+	if (WARN_ON(test_bit(0, b->dead)))
+		return -EINVAL;
+
+	return 0;
+}
+
+struct vcm *__must_check vcm_o2o_init(struct vcm_o2o *o2o)
+{
+	static const struct vcm_driver driver = {
+		.cleanup	= vcm_o2o_cleanup,
+		.phys		= vcm_o2o_phys,
+		.map		= vcm_o2o_map,
+		.bind		= vcm_o2o_bind,
+		.unreserve	= vcm_o2o_unreserve,
+	};
+
+	if (WARN_ON(!o2o || !o2o->driver ||
+		    !o2o->driver->alloc || !o2o->driver->free))
+		return ERR_PTR(-EINVAL);
+
+	o2o->vcm.driver = &driver;
+	return vcm_init(&o2o->vcm);
+}
+EXPORT_SYMBOL_GPL(vcm_o2o_init);
+
+#endif
+
+/************************ Physical memory management ************************/
+
+#ifdef CONFIG_VCM_PHYS
+
+struct vcm_phys_list {
+	struct vcm_phys_list	*next;
+	unsigned		count;
+	struct vcm_phys_part	parts[31];
+};
+
+static struct vcm_phys_list *__must_check
+vcm_phys_alloc_list_order(struct vcm_phys_list *last, resource_size_t *pages,
+			  unsigned flags, unsigned order, unsigned *total)
+{
+	unsigned count;
+
+	count	= *pages >> order;
+
+	/* So, we need count order-order pages */
+	do {
+		struct page *p = alloc_pages(GFP_DMA, order);
+
+		if (!p)
+			/*
+			 * If allocation failed we may still
+			 * try to continua allocating smaller
+			 * pages.
+			 */
+			break;
+
+		if (last->count == ARRAY_SIZE(last->parts)) {
+			struct vcm_phys_list *l;
+			l = kmalloc(sizeof *l, GFP_KERNEL);
+			if (!l)
+				return NULL;
+
+			l->next = NULL;
+			l->count = 0;
+			last->next = l;
+			last = l;
+		}
+
+		last->parts[last->count].start =
+			page_to_pfn(p) << PAGE_SHIFT;
+		last->parts[last->count].size =
+			(resource_size_t)1 << (order + PAGE_SHIFT);
+		++last->count;
+		++*total;
+		*pages -= 1 << order;
+	} while (--count);
+
+	return last;
+}
+
+static unsigned __must_check
+vcm_phys_alloc_list(struct vcm_phys_list *first,
+		    resource_size_t size, unsigned flags,
+		    const unsigned char *orders)
+{
+	struct vcm_phys_list *last = first;
+	unsigned total_parts = 0;
+	resource_size_t pages;
+
+	/*
+	 * We are trying to allocate as large pages as possible but
+	 * not larger then pages that MMU driver that called us
+	 * supports (ie. the ones provided by page_sizes).  This makes
+	 * it possible to map the region using fewest possible number
+	 * of entries.
+	 */
+	pages = size >> PAGE_SHIFT;
+	do {
+		while (!(pages >> *orders))
+			++orders;
+
+		last = vcm_phys_alloc_list_order(last, &pages, flags, *orders,
+						 &total_parts);
+		if (!last)
+			return 0;
+
+	} while (*orders++ && pages);
+
+	if (pages)
+		return 0;
+
+	return total_parts;
+}
+
+static void vcm_phys_free_parts(struct vcm_phys_part *parts, unsigned count)
+{
+	do {
+		free_pages(parts->start, ffs(parts->size) - 1 - PAGE_SHIFT);
+		++parts;
+	} while (--count);
+}
+
+static void vcm_phys_alloc_cleanup(struct vcm_phys_list *lst)
+{
+	struct vcm_phys_list *first = lst;
+	do {
+		struct vcm_phys_list *l;
+
+		vcm_phys_free_parts(lst->parts, lst->count);
+
+		l = lst->next;
+		if (lst != first)
+			kfree(lst);
+		lst = l;
+	} while (lst);
+}
+
+static void vcm_phys_free(struct vcm_phys *phys)
+{
+	vcm_phys_free_parts(phys->parts, phys->count);
+}
+
+struct vcm_phys *__must_check
+vcm_phys_alloc(resource_size_t size, unsigned flags,
+	       const unsigned char *orders)
+{
+	struct vcm_phys_list first = { NULL, 0 }, *lst;
+	struct vcm_phys_part *out;
+	struct vcm_phys *phys;
+	unsigned count;
+
+	if (WARN_ON((size & (PAGE_SIZE - 1)) || !size || !orders))
+		return ERR_PTR(-EINVAL);
+
+	count = vcm_phys_alloc_list(&first, size, flags, orders);
+	if (!count)
+		goto error;
+
+	phys = kmalloc(sizeof *phys + count * sizeof *phys->parts, GFP_KERNEL);
+	if (!phys)
+		goto error;
+
+	phys->free = vcm_phys_free;
+	phys->count = count;
+	phys->size = size;
+
+	out = phys->parts;
+	lst = &first;
+	do {
+		struct vcm_phys_list *l;
+
+		memcpy(out, lst->parts, lst->count * sizeof *out);
+		out += lst->count;
+
+		l = lst->next;
+		if (lst != &first)
+			kfree(lst);
+		lst = l;
+	} while (lst);
+
+	return phys;
+
+error:
+	vcm_phys_alloc_cleanup(&first);
+	return ERR_PTR(-ENOMEM);
+}
+EXPORT_SYMBOL_GPL(vcm_phys_alloc);
+
+static inline bool is_of_order(dma_addr_t size, unsigned order)
+{
+	return !(size & (((dma_addr_t)PAGE_SIZE << order) - 1));
+}
+
+static int
+__vcm_phys_walk_part(dma_addr_t vaddr, const struct vcm_phys_part *part,
+		     const unsigned char *orders,
+		     int (*callback)(dma_addr_t vaddr, dma_addr_t paddr,
+				     unsigned order, void *priv), void *priv,
+		     unsigned *limit)
+{
+	resource_size_t size = part->size;
+	dma_addr_t paddr = part->start;
+	resource_size_t ps;
+
+	while (!is_of_order(vaddr, *orders))
+		++orders;
+	while (!is_of_order(paddr, *orders))
+		++orders;
+
+	ps = PAGE_SIZE << *orders;
+	for (; *limit && size; --*limit) {
+		int ret;
+
+		while (ps > size)
+			ps = PAGE_SIZE << *++orders;
+
+		ret = callback(vaddr, paddr, *orders, priv);
+		if (ret < 0)
+			return ret;
+
+		ps = PAGE_SIZE << *orders;
+		vaddr += ps;
+		paddr += ps;
+		size  -= ps;
+	}
+
+	return 0;
+}
+
+int vcm_phys_walk(dma_addr_t _vaddr, const struct vcm_phys *phys,
+		  const unsigned char *orders,
+		  int (*callback)(dma_addr_t vaddr, dma_addr_t paddr,
+				  unsigned order, void *arg),
+		  int (*recovery)(dma_addr_t vaddr, dma_addr_t paddr,
+				  unsigned order, void *arg),
+		  void *priv)
+{
+	unsigned limit = ~0;
+	int r = 0;
+
+	if (WARN_ON(!phys || ((_vaddr | phys->size) & (PAGE_SIZE - 1)) ||
+		    !phys->size || !orders || !callback))
+		return -EINVAL;
+
+	for (;;) {
+		const struct vcm_phys_part *part = phys->parts;
+		unsigned count = phys->count;
+		dma_addr_t vaddr = _vaddr;
+		int ret = 0;
+
+		for (; count && limit; --count, ++part) {
+			ret = __vcm_phys_walk_part(vaddr, part, orders,
+						   callback, priv, &limit);
+			if (ret)
+				break;
+
+			vaddr += part->size;
+		}
+
+		if (r)
+			/* We passed error recovery */
+			return r;
+
+		/*
+		 * Either operation suceeded or we were not provided
+		 * with a recovery callback -- return.
+		 */
+		if (!ret || !recovery)
+			return ret;
+
+		/* Switch to recovery */
+		limit = ~0 - limit;
+		callback = recovery;
+		r = ret;
+	}
+}
+EXPORT_SYMBOL_GPL(vcm_phys_walk);
+
+#endif
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
