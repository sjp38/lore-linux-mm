Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EAC1A6B0071
	for <linux-mm@kvack.org>; Thu, 24 Jun 2010 00:52:14 -0400 (EDT)
From: Zach Pfeffer <zpfeffer@codeaurora.org>
Subject: [RFC] mm: iommu: An API to unify IOMMU, CPU and device memory management
Date: Wed, 23 Jun 2010 21:51:36 -0700
Message-Id: <1277355096-15596-1-git-send-email-zpfeffer@codeaurora.org>
Sender: owner-linux-mm@kvack.org
To: mel@csn.ul.ie
Cc: dwalker@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, Zach Pfeffer <zpfeffer@codeaurora.org>
List-ID: <linux-mm.kvack.org>

This patch contains the documentation for and the main header file of
the API, termed the Virtual Contiguous Memory Manager. Its use would
allow all of the IOMMU to VM, VM to device and device to IOMMU
interoperation code to be refactored into platform independent code.

Comments, suggestions and criticisms are welcome and wanted.

Signed-off-by: Zach Pfeffer <zpfeffer@codeaurora.org>
---
 Documentation/vcm.txt |  583 ++++++++++++++++++++++++++++
 include/linux/vcm.h   | 1017 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 1600 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/vcm.txt
 create mode 100644 include/linux/vcm.h

diff --git a/Documentation/vcm.txt b/Documentation/vcm.txt
new file mode 100644
index 0000000..d29c757
--- /dev/null
+++ b/Documentation/vcm.txt
@@ -0,0 +1,583 @@
+What is this document about?
+============================
+
+This document covers how to use the Virtual Contiguous Memory Manager
+(VCMM), how the first implmentation works with a specific low-level
+Input/Output Memory Management Unit (IOMMU) and the way the VCMM is used
+from user-space. It also contains a section that describes why something
+like the VCMM is needed in the kernel.
+
+If anything in this document is wrong please send patches to the
+maintainer of this file, listed at the bottom of the document.
+
+
+The Virtual Contiguous Memory Manager
+=====================================
+
+The VCMM was built to solve the system-wide memory mapping issues that
+occur when many bus-masters have IOMMUs.
+
+An IOMMU maps device addresses to physical addresses. It also insulates
+the system from spurious or malicious device bus transactions and allows
+fine-grained mapping attribute control. The Linux kernel core does not
+contain a generic API to handle IOMMU mapped memory; device driver writers
+must implement device specific code to interoperate with the Linux kernel
+core. As the number of IOMMUs increases, coordinating the many address
+spaces mapped by all discrete IOMMUs becomes difficult without in-kernel
+support.
+
+The VCMM API enables device independent IOMMU control, virtual memory
+manager (VMM) interoperation and non-IOMMU enabled device interoperation
+by treating devices with or without IOMMUs and all CPUs with or without
+MMUs, their mapping contexts and their mappings using common
+abstractions. Physical hardware is given a generic device type and mapping
+contexts are abstracted into Virtual Contiguous Memory (VCM)
+regions. Users "reserve" memory from VCMs and "back" their reservations
+with physical memory.
+
+Why the VCMM is Needed
+----------------------
+
+Driver writers who control devices with IOMMUs must contend with device
+control and memory management. Driver writers have a large device driver
+API that they can leverage to control their devices, but they are lacking
+a unified API to help them program mappings into IOMMUs and share those
+mappings with other devices and CPUs in the system.
+
+Sharing is complicated by Linux's CPU centric VMM. The CPU centric model
+generally makes sense because average hardware only contains a MMU for the
+CPU and possibly a graphics MMU. If every device in the system has one or
+more MMUs the CPU centric memory management (MM) programming model breaks
+down.
+
+Abstracting IOMMU device programming into a common API has already begun
+in the Linux kernel. It was built to abstract the difference between AMDs
+and Intels IOMMUs to support x86 virtualization on both platforms. The
+interface is listed in kernel/include/linux/iommu.h. It contains
+interfaces for mapping and unmapping as well as domain management. This
+interface has not gained widespread use outside the x86; PA-RISC, Alpha
+and SPARC architectures and ARM and PowerPC platforms all use their own
+mapping modules to control their IOMMUs. The VCMM contains an IOMMU
+programming layer, but since its abstraction supports map management
+independent of device control, the layer is not used directly. This
+higher-level view enables a new kernel service, not just an IOMMU
+interoperation layer.
+
+The General Idea: Map Management using Graphs
+---------------------------------------------
+
+Looking at mapping from a system-wide perspective reveals a general graph
+problem. The VCMMs API is built to manage the general mapping graph. Each
+node that talks to memory, either through an MMU or directly (physically
+mapped) can be thought of as the device-end of a mapping edge. The other
+edge is the physical memory (or intermediate virtual space) that is
+mapped.
+
+In the direct mapped case the device is assigned a one-to-one MMU. This
+scheme allows direct mapped devices to participate in general graph
+management.
+
+The CPU nodes can also be brought under the same mapping abstraction with
+the use of a light overlay on the existing VMM. This light overlay allows
+VMM managed mappings to interoperate with the common API. The light
+overlay enables this without substantial modifications to the existing
+VMM.
+
+In addition to CPU nodes that are running Linux (and the VMM), remote CPU
+nodes that may be running other operating systems can be brought into the
+general abstraction. Routing all memory management requests from a remote
+node through the central memory management framework enables new features
+like system-wide memory migration. This feature may only be feasible for
+large buffers that are managed outside of the fast-path, but having remote
+allocation in a system enables features that are impossible to build
+without it.
+
+The fundamental objects that support graph-based map management are:
+
+1) Virtual Contiguous Memory Regions
+
+2) Reservations
+
+3) Associated Virtual Contiguous Memory Regions
+
+4) Memory Targets
+
+5) Physical Memory Allocations
+
+Usage Overview
+--------------
+
+In a nut-shell, users allocate Virtual Contiguous Memory Regions and
+associate those regions with one or more devices by creating an Associated
+Virtual Contiguous Memory Region. Users then create Reservations from the
+Virtual Contiguous Memory Region. At this point no physical memory has
+been committed to the reservation. To associate physical memory with a
+reservation a Physical Memory Allocation is created and the Reservation is
+backed with this allocation.
+
+include/linux/vcm.h includes comments documenting each API.
+
+Virtual Contiguous Memory Regions
+---------------------------------
+
+A Virtual Contiguous Memory Region (VCM) abstracts the memory space a
+device sees. The addresses of the region are only used by the devices
+which are associated with the region. This address space would normally be
+implemented as a device page-table.
+
+A VCM is created and destroyed with three functions:
+
+    struct vcm *vcm_create(size_t start_addr, size_t len);
+
+    struct vcm *vcm_create_from_prebuilt(size_t ext_vcm_id);
+
+    int vcm_free(struct vcm *vcm);
+
+start_addr is an offset into the address space where allocations will
+start from. len is the length from start_addr of the VCM. Both functions
+generate an instance of a VCM.
+
+ext_vcm_id is used to pass a request to the VMM to generate a VCM
+instance. In the current implementation the call simply makes a note that
+the VCM instance is a VMM VCM instance for other interfaces usage. This
+muxing is seen throughout the implementation.
+
+vcm_create() and vcm_create_from_prebuilt() produce VCM instances for
+virtually mapped devices (IOMMUs and CPUs). To create a one-to-one mapped
+VCM users pass the start_addr and len of the physical region. The VCMM
+matches this and records that the VCM instance is a one-to-one VCM.
+
+The newly created VCM instance can be passed to any function that needs to
+operate on or with a virtual contiguous memory region. Its main attributes
+are a start_addr and a len as well as an internal setting that allows the
+implementation to mux between true virtual spaces, one-to-one mapped
+spaces and VMM managed spaces.
+
+The current implementation uses the genalloc library to manage the VCM for
+IOMMU devices. Return values and more in-depth per-function documentation
+for these and the ones listed below are in include/linux/vcm.h.
+
+Reservations
+------------
+
+A Reservation is a contiguous region allocated from a VCM. There is no
+physical memory associated with it.
+
+A Reservation is created and destroyed with:
+
+    struct res *vcm_reserve(struct vcm *vcm, size_t len, uint32_t attr);
+
+    int vcm_unreserve(struct res *res);
+
+A vcm is a VCM created above. len is the length of the request. It can be
+up to the length of the VCM region the reservation is being created
+from. attr are mapping attributes: read, write, execute, user, supervisor,
+secure, not-cached, write-back/write-allocate, write-back/no
+write-allocate, write-through. These attrs are appropriate for ARM but can
+be changed to match to any architecture.
+
+The implementation calls gen_pool_alloc() for IOMMU devices,
+alloc_vm_area() for VMM areas and is a pass through for one-to-one mapped
+areas.
+
+Associated Virtual Contiguous Memory Regions and Activation
+-----------------------------------------------------------
+
+An Associated Virtual Contiguous Memory Region (AVCM) is a mapping of a
+VCM to a device. The mapping can be active or inactive.
+
+An AVCM is managed with:
+
+struct avcm *vcm_assoc(struct vcm *vcm, size_t dev, uint32_t attr);
+
+    int vcm_deassoc(struct avcm *avcm);
+
+    int vcm_activate(struct avcm *avcm);
+
+    int vcm_deactivate(struct avcm *avcm);
+
+A VCM instance is a VCM created above. A dev is an opaque device handle
+thats passed down to the device driver the VCMM muxes in to handle a
+request. attr are association attributes: split, use-high or
+use-low. split controls which transactions hit a high-address page-table
+and which transactions hit a low-address page-table. For instance, all
+transactions whose most significant address bit is one would use the
+high-address page-table, any other transaction would use the low address
+page-table. This scheme is ARM specific and could be changed in other
+architectures. One VCM instance can be associated with many devices and
+many VCM instances can be associated with one device.
+
+An AVCM is only a link. To program and deprogram a device with a VCM the
+user calls vcm_activate() and vcm_deactivate().For IOMMU devices,
+activating a mapping programs the base address of a page-table into an
+IOMMU. For VMM and one-to-one based devices, mappings are active
+immediately but the API does require an activation call for them for
+internal reference counting.
+
+Memory Targets
+--------------
+
+A Memory Target is a platform independent way of specifying a physical
+pool; it abstracts a pool of physical memory. The physical memory pool may
+be physically discontiguous, need to be allocated from in a unique way or
+have other user-defined attributes.
+
+Physical Memory Allocation and Reservation Backing
+--------------------------------------------------
+
+Physical memory is allocated as a separate step from reserving
+memory. This allows multiple reservations to back the same physical
+memory.
+
+A Physical Memory Allocation is managed using the following functions:
+
+    struct physmem *vcm_phys_alloc(enum memtype_t memtype, size_t len,
+                                   uint32_t attr);
+
+    int vcm_phys_free(struct physmem *physmem);
+
+    int vcm_back(struct res *res, struct physmem *physmem);
+
+    int vcm_unback(struct res *res);
+
+attr can include an alignment request, a specification to map memory using
+various block sizes and/or to use physically contiguous memory. memtype is
+one of the memory types listed in Memory Targets.
+
+The current implementation manages two pools of memory. One pool is a
+contiguous block of memory and the other is a set of contiguous block
+pools. In the current implementation the block pools contain 4K, 64K and
+1M blocks. The physical allocator does not try to split blocks from the
+contiguous block pools to satisfy requests.
+
+The use of 4K, 64K and 1M blocks solves a problem with some IOMMU
+hardware. IOMMUs are placed in front of multimedia engines to provide a
+contiguous address space to the device. Multimedia devices need large
+buffers and large buffers may map to a large number of physical
+blocks. IOMMUs tend to have small translation lookaside buffers
+(TLBs). Since the TLB is small the number of physical blocks that map a
+given range needs to be small or else the IOMMU will continually fetch new
+translations during a typical streamed multimedia flow. By using a 1 MB
+mapping (or 64K mapping) instead of a 4K mapping the number of misses can
+be minimized, allowing the multimedia block to meet its performance goals.
+
+Low Level Control
+-----------------
+
+It is necessary in some instances to access attributes and provide
+higher-level control of the low-level hardware abstraction. The API
+contains many functions for this task but the two that are typically used
+are:
+
+    size_t vcm_get_dev_addr(struct res *res);
+
+    int vcm_hook(size_t dev, vcm_handler handler, void *data);
+
+The first function, vcm_get_dev_addr() returns a device address given a
+reservation. This device address is a virtual IOMMU address for
+reservations on IOMMU VCMs, a virtual VMM address for reservations on VMM
+VCMs and a virtual (really physical since its one-to-one mapped) address
+for one-to-one devices.
+
+The second function, vcm_hook allows a caller in the kernel to register a
+user_handler. The handler is passed the data member passed to vcm_hook
+during a fault. The user can return 1 to indicate that the underlying
+driver should handle the fault and retry the transaction or they can
+return 0 to halt the transaction. If the user doesn't register a handler
+the low-level driver will print a warning and terminate the transaction.
+
+A Detailed Walk Through
+-----------------------
+
+The following call sequence walks through a typical allocation
+sequence. In the first stage the memory for a device is reserved and
+backed. This occurs without mapping the memory into a VMM VCM region. The
+second stage maps the first VCM region into a VMM VCM region so the kernel
+can read or write it. The second stage is not necessary if the VMM does
+not need to read or modify the contents of the original mapping.
+
+    Stage 1: Map and Allocate Memory for a Device
+
+    The call sequence starts by creating a VCM region:
+
+        vcm = vcm_create(start_addr, len);
+
+    The next call associates a VCM region with a device:
+
+        avcm = vcm_assoc(vcm, dev, attr);
+
+    To activate the association users call vcm_activate() on the avcm from
+    the associate call. This programs the underlining device with the
+    mappings.
+
+        ret = vcm_activate(avcm);
+
+    Once a VCM region is created and associated it can be reserved from
+    with:
+
+        res = vcm_reserve(vcm, res_len, res_attr);
+
+    A user then allocates physical memory with:
+
+        physmem = vcm_phys_alloc(memtype, len, phys_attr);
+
+    To back the reservation with the physical memory allocation the user
+    calls:
+
+        vcm_back(res, physmem);
+
+
+    Stage 2: Map the Device's Memory into the VMM's VCM region
+
+    If the VMM needs to read and/or write the region that was just created
+    the following calls are made.
+
+    The first call creates a prebuilt VCM with:
+
+        vcm_vmm = vcm_from_prebuilt(ext_vcm_id);
+
+    The prebuilt VCM is associated with the CPU device and activated with:
+
+        avcm_vmm = vcm_assoc(vcm_vmm, dev_cpu, attr);
+        vcm_activate(avcm_vmm);
+
+    A reservation is made on the VMM VCM with:
+
+        res_vmm = vcm_reserve(vcm_vmm, res_len, attr);
+
+    Finally, once the topology has been set up a vcm_back() allows the VMM
+    to read the memory using the physmem generated in stage 1:
+
+        vcm_back(res_vmm, physmem);
+
+Mapping IOMMU, one-to-one and VMM Reservations
+----------------------------------------------
+
+The following example demonstrates mapping IOMMU, one-to-one and VMM
+reservations to the same physical memory. It shows the use of phys_addr
+and phys_size to create a contiguous VCM for one-to-one mapped devices.
+
+    The user allocates physical memory:
+
+        physmem = vcm_phys_alloc(memtype, SZ_2MB + SZ_4K, CONTIGUOUS);
+
+    Creates an IOMMU VCM:
+
+        vcm_iommu = vcm_create(SZ_1K, SZ_16M);
+
+    Creates an one-to-one VCM:
+
+        vcm_onetoone = vcm_create(phys_addr, phys_size);
+
+    Creates a Prebuit VCM:
+
+        vcm_vmm = vcm_from_prebuit(ext_vcm_id);
+
+    Associate and activate all three to their respective devices:
+
+        avcm_iommu = vcm_assoc(vcm_iommu, dev_iommu, attr0);
+        avcm_onetoone = vcm_assoc(vcm_onetoone, dev_onetoone, attr1);
+        avcm_vmm = vcm_assoc(vcm_vmm, dev_cpu, attr2);
+        vcm_activate(avcm_iommu);
+        vcm_activate(avcm_onetoone);
+        vcm_activate(avcm_vmm);
+
+    And finally, creates and backs reservations on all 3 such that they
+    all point to the same memory:
+
+        res_iommu = vcm_reserve(vcm_iommu, SZ_2MB + SZ_4K, attr);
+        res_onetoone = vcm_reserve(vcm_onetoone, SZ_2MB + SZ_4K, attr);
+        res_vmm = vcm_reserve(vcm_vmm, SZ_2MB + SZ_4K, attr);
+        vcm_back(res_iommu, physmem);
+        vcm_back(res_onetoone, physmem);
+        vcm_back(res_vmm, physmem);
+
+VCM Summary
+-----------
+
+The VCMM is an attempt to abstract attributes of three distinct classes of
+mappings into one API. The VCMM allows users to reason about mappings as
+first class objects. It also allows memory mappings to flow from the
+traditional 4K mappings prevalent on systems today to more efficient block
+sizes. Finally, it allows users to manage mapping interoperation without
+becoming VMM experts. These features will allow future systems with many
+MMU mapped devices to interoperate simply and therefore correctly.
+
+
+IOMMU Hardware Control
+======================
+
+The VCM currently supports a single type of IOMMU, a Qualcomm System MMU
+(SMMU). The SMMU interface contains functions to map and unmap virtual
+addresses, perform address translations and initialize hardware. A
+Qualcomm SMMU can contain multiple MMU contexts. Each context can
+translate in parallel. All contexts in a SMMU share one global translation
+look-aside buffer (TLB).
+
+To support context muxing the SMMU module creates and manages device
+independent virtual contexts. These context abstractions are bound to
+actual contexts at run-time. Once bound, a context can be activated. This
+activation programs the underlying context with the virtual context
+affecting a context switch.
+
+The following functions are all documented in:
+
+    arch/arm/mach-msm/include/mach/smmu_driver.h.
+
+Mapping
+-------
+
+To map and unmap a virtual page into physical space the VCM calls:
+
+    int smmu_map(struct smmu_dev *dev, unsigned long pa,
+                 unsigned long va, unsigned long len, unsigned int attr);
+
+    int smmu_unmap(struct smmu_dev *dev, unsigned long va,
+                   unsigned long len);
+
+    int smmu_update_start(struct smmu_dev *dev);
+
+    int smmu_update_done(struct smmu_dev *dev);
+
+The size given to map must be 4K, 64K, 1M or 16M and the VA and PA must be
+aligned to the given size. smmu_update_start() and smmu_update_done()
+should be called before and after each map or unmap.
+
+Translation
+-----------
+
+To request a hardware VA to PA translation on a single address the VCM
+calls:
+
+    unsigned long smmu_translate(struct smmu_dev *dev,
+                                 unsigned long va);
+
+Fault Handling
+--------------
+
+To register an interrupt handler for a context the VCM calls:
+
+    int smmu_hook_irpt(struct smmu_dev *dev, vcm_handler handler,
+                       void *data);
+
+The registered interrupt handler should return 1 if it wants the SMMU
+driver to retry the transaction again and 0 if it wants the SMMU driver to
+terminate the transaction.
+
+Managing SMMU Initialization and Contexts
+-----------------------------------------
+
+SMMU hardware initialization and management happens in 2 steps. The first
+step initializes global SMMU devices and abstract device contexts. The
+second step binds contexts and devices.
+
+A SMMU hardware instance is built with:
+
+    int smmu_drvdata_init(struct smmu_driver *drv, unsigned long base,
+                          int irq);
+
+A SMMU context is Initialized and deinitialized with:
+
+    struct smmu_dev *smmu_ctx_init(int ctx);
+    int smmu_ctx_deinit(struct smmu_dev *dev);
+
+An abstract SMMU context is bound to a particular SMMU with:
+
+    int smmu_ctx_bind(struct smmu_dev *ctx, struct smmu_driver *drv);
+
+Activation
+----------
+
+Activation affects a context switch.
+
+Activation, deactivation and activation state testing are done with:
+
+    int smmu_activate(struct smmu_dev *dev);
+    int smmu_deactivate(struct smmu_dev *dev);
+    int smmu_is_active(struct smmu_dev *dev);
+
+
+Userspace Access to Devices with IOMMUs
+=======================================
+
+A device that issues transactions through an IOMMU must work with two
+APIs. The first API is the VCM. The VCM API is device independent. Users
+pass the VCM a dev_id and the VCM makes calls on the hardware device it
+has been configured with using this dev_id. The second API is whatever
+device topology has been created to organize the particular IOMMUs in a
+system. The only constraint on this second API is that it must give the
+user a single dev_id that it can pass through the VCM.
+
+For the Qualcomm SMMUs the second API consists of a tree of platform
+devices and two platform drivers as well as a context lookup function that
+traverses the device tree and returns a dev_id given a context name.
+
+Qualcomm SMMU Device Tree
+-------------------------
+
+The current tree organizes the devices into a tree that looks like the
+following:
+
+smmu/
+               smmu0/
+                                ctx0
+                                ctx1
+                                ctx2
+               smmu1/
+                                ctx3
+
+
+Each context, ctx[n] and each smmu, smmu[n] is given a name. Since users
+are interested in contexts not smmus, the contexts name is passed to a
+function to find the dev_id associated with that name. The functions to
+find, free and get the base address (since the device probe function calls
+ioremap to map the SMMUs configuration registers into the kernel) are
+listed here:
+
+    struct smmu_dev *smmu_get_ctx_instance(char *ctx_name);
+    int smmu_free_ctx_instance(struct smmu_dev *dev);
+    unsigned long smmu_get_base_addr(struct smmu_dev *dev);
+
+Documentation for these functions is in:
+
+    arch/arm/mach-msm/include/mach/smmu_device.h
+
+Each context is given a dev node named after the context. For example:
+
+    /dev/vcodec_a_mm1
+    /dev/vcodec_b_mm2
+    /dev/vcodec_stream
+    etc...
+
+Users open, close and mmap these nodes to access VCM buffers from
+userspace in the same way that they used to open, close and mmap /dev
+nodes that represented large physically contiguous buffers (called PMEM
+buffers on Android).
+
+Example
+-------
+
+An abbreviated example is shown here:
+
+Users get the dev_id associated with their target context, create a VCM
+topology appropriate for their device and finally associate the VCMs of
+the topology with the contexts that will take the VCMs:
+
+    dev_id = smmu_get_ctx_instance(vcodec_a_stream);
+
+create vcm and needed topology
+
+    avcm = vcm_assoc(vcm, dev_id, attr);
+
+Tying it all Together
+---------------------
+
+VCMs, IOMMUs and the device tree all work to support system-wide memory
+mappings. The use of each API in this system allows users to concentrate
+on the relevant details without needing to worry about low-level
+details. The APIs clear separation of memory spaces and the devices that
+support those memory spaces continues Linuxs tradition of abstracting the
+what from the how.
+
+
+Maintainer: Zach Pfeffer <zpfeffer@codeaurora.org>
diff --git a/include/linux/vcm.h b/include/linux/vcm.h
new file mode 100644
index 0000000..411db9c
--- /dev/null
+++ b/include/linux/vcm.h
@@ -0,0 +1,1017 @@
+/* Copyright (c) 2010, Code Aurora Forum. All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are
+ * met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above
+ *       copyright notice, this list of conditions and the following
+ *       disclaimer in the documentation and/or other materials provided
+ *       with the distribution.
+ *     * Neither the name of Code Aurora Forum, Inc. nor the names of its
+ *       contributors may be used to endorse or promote products derived
+ *       from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
+ * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
+ * ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
+ * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ */
+
+#ifndef _VCM_H_
+#define _VCM_H_
+
+/* All undefined types must be defined using platform specific headers */
+
+#include <linux/types.h>
+#include <linux/mutex.h>
+#include <linux/spinlock.h>
+#include <linux/genalloc.h>
+#include <linux/vcm_alloc.h>
+#include <linux/list.h>
+
+
+/*
+ * Reservation Attributes
+ *
+ * Used in vcm_reserve(), vcm_reserve_at(), vcm_set_res_attr() and
+ * vcm_reserve_bound().
+ *
+ *	VCM_READ	Specifies that the reservation can be read.
+ *	VCM_WRITE	Specifies that the reservation can be written.
+ *	VCM_EXECUTE	Specifies that the reservation can be executed.
+ *	VCM_USER	Specifies that this reservation is used for
+ *			userspace access.
+ *	VCM_SUPERVISOR	Specifies that this reservation is used for
+ *				supervisor access.
+ *	VCM_SECURE	Specifies that the target of the reservation is
+ *			secure. The usage of this setting is TBD.
+ *
+ *	Caching behavior as a 4 bit field:
+ *		VCM_NOTCACHED		The VCM region is not cached.
+ *		VCM_INNER_WB_WA		The VCM region is inner cached
+ *					and is write-back and write-allocate.
+ *		VCM_INNER_WT_NWA	The VCM region is inner cached and is
+ *					write-through and no-write-allocate.
+ *		VCM_INNER_WB_NWA	The VCM region is inner cached and is
+ *					write-back and no-write-allocate.
+ *		VCM_OUTER_WB_WA		The VCM region is outer cached and is
+ *					write-back and write-allocate.
+ *		VCM_OUTER_WT_NWA	The VCM region is outer cached and is
+ *					write-through and no-write-allocate.
+ *		VCM_OUTER_WB_NWA	The VCM region is outer cached and is
+ *					write-back and no-write-allocate.
+ *		VCM_WB_WA		The VCM region is cached and is write
+ *					-back and write-allocate.
+ *		VCM_WT_NWA		The VCM region is cached and is write
+ *					-through and no-write-allocate.
+ *		VCM_WB_NWA		The VCM region is cached and is write
+ *					-back and no-write-allocate.
+ */
+
+/* Order of alignment (power of 2). Ie, 12 = 4k, 13 = 8k, 14 = 16k
+ * Alignments of less than 1MB on buffers of size 1MB or greater should be
+ * avoided. Alignments of less than 64KB on buffers of size 64KB or greater
+ * should be avoided. Strictly speaking, it will work, but will result in
+ * suboptimal performance, and a warning will be printed to that effect if
+ * VCM_PERF_WARN is enabled.
+ */
+#define VCM_ALIGN_SHIFT		10
+#define VCM_ALIGN_MASK		0x1F
+#define VCM_ALIGN_ATTR(order) 	(((order) & VCM_ALIGN_MASK) << VCM_ALIGN_SHIFT)
+
+#define VCM_ALIGN_DEFAULT	0
+#define VCM_ALIGN_4K		(VCM_ALIGN_ATTR(12))
+#define VCM_ALIGN_8K		(VCM_ALIGN_ATTR(13))
+#define VCM_ALIGN_16K		(VCM_ALIGN_ATTR(14))
+#define VCM_ALIGN_32K		(VCM_ALIGN_ATTR(15))
+#define VCM_ALIGN_64K		(VCM_ALIGN_ATTR(16))
+#define VCM_ALIGN_128K		(VCM_ALIGN_ATTR(17))
+#define VCM_ALIGN_256K		(VCM_ALIGN_ATTR(18))
+#define VCM_ALIGN_512K		(VCM_ALIGN_ATTR(19))
+#define VCM_ALIGN_1M		(VCM_ALIGN_ATTR(20))
+#define VCM_ALIGN_2M		(VCM_ALIGN_ATTR(21))
+#define VCM_ALIGN_4M		(VCM_ALIGN_ATTR(22))
+#define VCM_ALIGN_8M		(VCM_ALIGN_ATTR(23))
+#define VCM_ALIGN_16M		(VCM_ALIGN_ATTR(24))
+#define VCM_ALIGN_32M		(VCM_ALIGN_ATTR(25))
+#define VCM_ALIGN_64M		(VCM_ALIGN_ATTR(26))
+#define VCM_ALIGN_128M		(VCM_ALIGN_ATTR(27))
+#define VCM_ALIGN_256M		(VCM_ALIGN_ATTR(28))
+#define VCM_ALIGN_512M		(VCM_ALIGN_ATTR(29))
+#define VCM_ALIGN_1GB		(VCM_ALIGN_ATTR(30))
+
+
+#define VCM_CACHE_POLICY	(0xF << 0)
+#define VCM_READ		(1UL << 9)
+#define VCM_WRITE		(1UL << 8)
+#define VCM_EXECUTE		(1UL << 7)
+#define VCM_USER		(1UL << 6)
+#define VCM_SUPERVISOR		(1UL << 5)
+#define VCM_SECURE		(1UL << 4)
+#define VCM_NOTCACHED		(0UL << 0)
+#define VCM_WB_WA		(1UL << 0)
+#define VCM_WB_NWA		(2UL << 0)
+#define VCM_WT			(3UL << 0)
+
+
+/*
+ * Physical Allocation Attributes
+ *
+ * Used in vcm_phys_alloc().
+ *
+ *	Alignment as a power of 2 starting at 4 KB. 5 bit field.
+ *	1 = 4KB, 2 = 8KB, etc.
+ *
+ *			Specifies that the reservation should have the
+ *			alignment specified.
+ *
+ *	VCM_4KB		Specifies that the reservation should use 4KB pages.
+ *	VCM_64KB	Specifies that the reservation should use 64KB pages.
+ *	VCM_1MB		specifies that the reservation should use 1MB pages.
+ *	VCM_ALL		Specifies that the reservation should use all
+ *			available page sizes.
+ *	VCM_PHYS_CONT	Specifies that a reservation should be backed with
+ *			physically contiguous memory.
+ *	VCM_COHERENT	Specifies that the reservation must be kept coherent
+ *			because it's shared.
+ */
+
+#define VCM_4KB			(1UL << 5)
+#define VCM_64KB		(1UL << 4)
+#define VCM_1MB			(1UL << 3)
+#define VCM_ALL			(1UL << 2)
+#define VCM_PAGE_SEL_MASK       (0xFUL << 2)
+#define VCM_PHYS_CONT		(1UL << 1)
+#define VCM_COHERENT		(1UL << 0)
+
+
+#define SHIFT_4KB               (12)
+
+#define ALIGN_REQ_BYTES(attr) (1UL << (((attr & VCM_ALIGNMENT_MASK) >> 6) + 12))
+/* set the alignment in pow 2, 0 = 4KB */
+#define SET_ALIGN_REQ_BYTES(attr, align) \
+	((attr & ~VCM_ALIGNMENT_MASK) | ((align << 6) & VCM_ALIGNMENT_MASK))
+
+/*
+ * Association Attributes
+ *
+ * Used in vcm_assoc(), vcm_set_assoc_attr().
+ *
+ * 	VCM_USE_LOW_BASE	Use the low base register.
+ *	VCM_USE_HIGH_BASE	Use the high base register.
+ *
+ *	VCM_SPLIT		A 5 bit field that defines the
+ *				high/low split.  This value defines
+ *				the number of 0's left-filled into the
+ *				split register. Addresses that match
+ *				this will use VCM_USE_LOW_BASE
+ *				otherwise they'll use
+ *				VCM_USE_HIGH_BASE. An all 0's value
+ *				directs all translations to
+ *				VCM_USE_LOW_BASE.
+ */
+
+#define VCM_SPLIT		(1UL << 3)
+#define VCM_USE_LOW_BASE	(1UL << 2)
+#define VCM_USE_HIGH_BASE	(1UL << 1)
+
+
+/*
+ * External VCMs
+ *
+ * Used in vcm_create_from_prebuilt()
+ *
+ * Externally created VCM IDs for creating kernel and user space
+ * mappings to VCMs and kernel and user space buffers out of
+ * VCM_MEMTYPE_0,1,2, etc.
+ *
+ */
+#define VCM_PREBUILT_KERNEL		1
+#define VCM_PREBUILT_USER		2
+
+/**
+ * enum memtarget_t - A logical location in a VCM.
+ *
+ * VCM_START	Indicates the start of a VCM_REGION.
+ */
+enum memtarget_t {
+	VCM_START
+};
+
+
+/**
+ * enum memtype_t - A logical location in a VCM.
+ *
+ * VCM_MEMTYPE_0	Generic memory type 0
+ * VCM_MEMTYPE_1	Generic memory type 1
+ * VCM_MEMTYPE_2	Generic memory type 2
+ *
+ * A memtype encapsulates a platform specific memory arrangement. The
+ * memtype needn't refer to a single type of memory, it can refer to a
+ * set of memories that can back a reservation.
+ *
+ */
+enum memtype_t {
+	VCM_INVALID,
+	VCM_MEMTYPE_0,
+	VCM_MEMTYPE_1,
+	VCM_MEMTYPE_2,
+};
+
+
+/**
+ * vcm_handler - The signature of the fault hook.
+ * @dev_id	The device id of the faulting device.
+ * @data	The generic data pointer.
+ * @fault_data	System specific common fault data.
+ *
+ * The handler should return 0 for success. This indicates that the
+ * fault was handled. A non-zero return value is an error and will be
+ * propagated up the stack.
+ */
+typedef int (*vcm_handler)(size_t dev_id, void *data, void *fault_data);
+
+
+enum vcm_type {
+	VCM_DEVICE,
+	VCM_EXT_KERNEL,
+	VCM_EXT_USER,
+	VCM_ONE_TO_ONE,
+};
+
+
+/**
+ * vcm - A Virtually Contiguous Memory region.
+ * @start_addr	The starting address of the VCM region.
+ * @len 	The len of the VCM region. This must be at least
+ *		vcm_min() bytes.
+ */
+struct vcm {
+	enum vcm_type type;
+
+	size_t start_addr;
+	size_t len;
+
+	size_t dev_id; /* opaque device control */
+
+	/* allocator dependent */
+	struct gen_pool *pool;
+
+	struct list_head res_head;
+
+	/* this will be a very short list */
+	struct list_head assoc_head;
+};
+
+/**
+ * avcm - A VCM to device association
+ * @vcm		The VCM region of interest.
+ * @dev_id	The device to associate the VCM with.
+ * @attr	See 'Association Attributes'.
+ */
+struct avcm {
+	struct vcm *vcm_id;
+	size_t dev_id;
+	uint32_t attr;
+
+	struct list_head assoc_elm;
+
+	int is_active; /* is this particular association active */
+};
+
+/**
+ * bound - A boundary to reserve from in a VCM region.
+ * @vcm		The VCM that needs a bound.
+ * @len		The len of the bound.
+ */
+struct bound {
+	struct vcm *vcm_id;
+	size_t len;
+};
+
+
+/**
+ * physmem - A physical memory allocation.
+ * @memtype	The memory type of the VCM region.
+ * @len		The len of the physical memory allocation.
+ * @attr 	See 'Physical Allocation Attributes'.
+ *
+ */
+
+struct physmem {
+	enum memtype_t memtype;
+	size_t len;
+	uint32_t attr;
+
+	struct phys_chunk alloc_head;
+
+	/* if the physmem is cont then use the built in VCM */
+	int is_cont;
+	struct res *res;
+};
+
+/**
+ * res - A reservation in a VCM region.
+ * @vcm		The VCM region to reserve from.
+ * @len		The length of the reservation. Must be at least vcm_min()
+ *		bytes.
+ * @attr	See 'Reservation Attributes'.
+ */
+struct res {
+	struct vcm *vcm_id;
+	struct physmem *physmem_id;
+	size_t len;
+	uint32_t attr;
+
+	/* allocator dependent */
+	size_t alignment_req;
+	size_t aligned_len;
+	unsigned long ptr;
+	size_t aligned_ptr;
+
+	struct list_head res_elm;
+
+
+	/* type VCM_EXT_KERNEL */
+	struct vm_struct *vm_area;
+	int mapped;
+};
+
+extern int chunk_sizes[NUM_CHUNK_SIZES];
+
+
+/*
+ * Virtual contiguous memory (VCM) region primitives.
+ *
+ * Current memory mapping software uses a CPU centric management
+ * model. This makes sense in general, average hardware only contains an
+ * CPU MMU and possibly a graphics MMU. If every device in the system
+ * has one or more MMUs a CPU centric MM programming model breaks down.
+ *
+ * Looking at mapping from a system-wide perspective reveals a general
+ * graph problem. Each node that talks to memory, either through an MMU
+ * or directly (via physical memory) can be thought of as the device end
+ * of a mapping edge. The other edge is the physical memory that is
+ * mapped.
+ *
+ * In the direct mapped case, it is useful to give the device an
+ * MMU. This one-to-one MMU allows direct mapped devices to
+ * participate in graph management, they simply see memory through a
+ * one-to-one mapping.
+ *
+ * The CPU nodes can also be brought under the same mapping
+ * abstraction with the use of a light overlay on the existing
+ * VMM. This light overlay brings the VMM's page table abstraction for
+ * each process and the kernel into the graph management API.
+ *
+ * Taken together this system wide approach provides a capability that
+ * is greater than the sum of its parts by allowing users to reason
+ * about system wide mapping issues without getting bogged down in CPU
+ * centric device page table management issues.
+ */
+
+
+/*
+ * Creating, freeing and managing VCMs.
+ *
+ * A VCM region is a virtual space that can be reserved from and
+ * associated with one or more devices. At creation the user can
+ * specify an offset to start addresses and a length of the entire VCM
+ * region. Reservations out of a VCM region are always contiguous.
+ */
+
+/**
+ * vcm_create() - Create a VCM region
+ * @start_addr	The starting address of the VCM region.
+ * @len		The len of the VCM region. This must be at least
+ *		vcm_get_min_page_size() bytes.
+ *
+ * A VCM typically abstracts a page table.
+ *
+ * All functions in this API are passed and return opaque things
+ * because the underlying implementations will vary. The goal
+ * is really graph management. vcm_create() creates the "device end"
+ * of an edge in the mapping graph.
+ *
+ * The return value is non-zero if a VCM has successfully been
+ * created. It will return zero if a VCM region cannot be created or
+ * len is invalid.
+ */
+struct vcm *vcm_create(size_t start_addr, size_t len);
+
+
+/**
+ * vcm_create_from_prebuilt() - Create a VCM region from an existing region
+ * @ext_vcm_id	An external opaque value that allows the
+ *		implementation to reference an already built table.
+ *
+ * The ext_vcm_id will probably reference a page table that's been built
+ * by the VM.
+ *
+ * The platform specific implementation will provide this.
+ *
+ * The return value is non-zero if a VCM has successfully been created.
+ */
+struct vcm *vcm_create_from_prebuilt(size_t ext_vcm_id);
+
+
+/**
+ * vcm_clone() - Clone a VCM
+ * @vcm_id	A VCM to clone from.
+ *
+ * Perform a VCM "deep copy." The resulting VCM will match the original at
+ * the point of cloning. Subsequent updates to either VCM will only be
+ * seen by that VCM.
+ *
+ * The return value is non-zero if a VCM has been successfully cloned.
+ */
+struct vcm *vcm_clone(struct vcm *vcm_id);
+
+
+/**
+ * vcm_get_start_addr() - Get the starting address of the VCM region.
+ * @vcm_id	The VCM we're interested in getting the starting address of.
+ *
+ * The return value will be 1 if an error has occurred.
+ */
+size_t vcm_get_start_addr(struct vcm *vcm_id);
+
+
+/**
+ * vcm_get_len() - Get the length of the VCM region.
+ * @vcm_id	The VCM we're interested in reading the length from.
+ *
+ * The return value will be non-zero for a valid VCM. VCM regions
+ * cannot have 0 len.
+ */
+size_t vcm_get_len(struct vcm *vcm_id);
+
+
+/**
+ * vcm_free() - Free a VCM.
+ * @vcm_id	The VCM we're interested in freeing.
+ *
+ * The return value is 0 if the VCM has been freed or:
+ * -EBUSY	The VCM region contains reservations or has been associated
+ *		(active or not) and cannot be freed.
+ * -EINVAL	The vcm argument is invalid.
+ */
+int vcm_free(struct vcm *vcm_id);
+
+
+/*
+ * Creating, freeing and managing reservations out of a VCM.
+ *
+ */
+
+/**
+ * vcm_reserve() - Create a reservation from a VCM region.
+ * @vcm_id	The VCM region to reserve from.
+ * @len		The length of the reservation. Must be at least
+ * 		vcm_get_min_page_size() bytes.
+ * @attr	See 'Reservation Attributes'.
+ *
+ * A reservation, res_t, is a contiguous range from a VCM region.
+ *
+ * The return value is non-zero if a reservation has been successfully
+ * created. It is 0 if any of the parameters are invalid.
+ */
+struct res *vcm_reserve(struct vcm *vcm_id, size_t len, uint32_t attr);
+
+
+/**
+ * vcm_reserve_at() - Make a reservation at a given logical location.
+ * @memtarget	A logical location to start the reservation from.
+ * @vcm_id	The VCM region to start the reservation from.
+ * @len		The length of the reservation.
+ * @attr	See 'Reservation Attributes'.
+ *
+ * The return value is non-zero if a reservation has been successfully
+ * created.
+ */
+struct res *vcm_reserve_at(enum memtarget_t memtarget, struct vcm *vcm_id,
+		     size_t len, uint32_t attr);
+
+
+/**
+ * vcm_get_vcm_from_res() - Return the VCM region of a reservation.
+ * @res_id	The reservation to return the VCM region of.
+ *
+ * Te return value will be non-zero if the reservation is valid. A valid
+ * reservation is always associated with a VCM region; there is no such
+ * thing as an orphan reservation.
+ */
+struct vcm *vcm_get_vcm_from_res(struct res *res_id);
+
+
+/**
+ * vcm_unreserve() - Unreserve the reservation.
+ * @res_id	The reservation to unreserve.
+ *
+ * The return value will be 0 if the reservation was successfully
+ * unreserved and:
+ * -EBUSY	The reservation is still backed,
+ * -EINVAL	The vcm argument is invalid.
+ */
+int vcm_unreserve(struct res *res_id);
+
+
+/**
+ * vcm_get_res_len() - Return a reservations contiguous length.
+ * @res_id	The reservation of interest.
+ *
+ * The return value will be 0 if res is invalid; reservations cannot
+ * have 0 length so there's no error return value ambiguity.
+ */
+size_t vcm_get_res_len(struct res *res_id);
+
+
+/**
+ * vcm_set_res_attr() - Set attributes of an existing reservation.
+ * @res_id	An existing reservation of interest.
+ * @attr	See 'Reservation Attributes'.
+ *
+ * This function can only be used on an existing reservation; there
+ * are no orphan reservations. All attributes can be set on a existing
+ * reservation.
+ *
+ * The return value will be 0 for a success, otherwise it will be:
+ * -EINVAL	res or attr are invalid.
+ */
+int vcm_set_res_attr(struct res *res_id, uint32_t attr);
+
+
+/**
+ * vcm_get_res_attr() - Return a reservation's attributes.
+ * @res_id	An existing reservation of interest.
+ *
+ * The return value will be 0 if res is invalid.
+ */
+uint32_t vcm_get_res_attr(struct res *res_id);
+
+
+/**
+ * vcm_get_num_res() - Return the number of reservations in a VCM region.
+ * @vcm_id	The VCM region of interest.
+ */
+size_t vcm_get_num_res(struct vcm *vcm_id);
+
+
+/**
+ * vcm_get_next_res() - Read each reservation one at a time.
+ * @vcm_id	The VCM region of interest.
+ * @res_id	Contains the last reservation. Pass NULL on the first call.
+ *
+ * This function works like a foreach reservation in a VCM region.
+ *
+ * The return value will be non-zero for each reservation in a VCM. A
+ * zero indicates no further reservations.
+ */
+struct res *vcm_get_next_res(struct vcm *vcm_id, struct res *res_id);
+
+
+/**
+ * vcm_res_copy() - Copy len bytes from one reservation to another.
+ * @to		The reservation to copy to.
+ * @from	The reservation to copy from.
+ * @len		The length of bytes to copy.
+ *
+ * The return value is the number of bytes copied.
+ */
+size_t vcm_res_copy(struct res *to, size_t to_off, struct res *from, size_t
+		    from_off, size_t len);
+
+
+/**
+ * vcm_get_min_page_size() - Return the minimum page size supported by
+ * 			     the architecture.
+ */
+size_t vcm_get_min_page_size(void);
+
+
+/**
+ * vcm_back() - Physically back a reservation.
+ * @res_id	The reservation containing the virtual contiguous region to
+ * 		back.
+ * @physmem_id	The physical memory that will back the virtual contiguous
+ * 		memory region.
+ *
+ * One VCM can be associated with multiple devices. When you vcm_back()
+ * each association must be active. This is not strictly necessary. It may
+ * be changed in the future.
+ *
+ * This function returns 0 on a successful physical backing. Otherwise
+ * it returns:
+ * -EINVAL	res or physmem is invalid or res's len
+ *		is different from physmem's len.
+ * -EAGAIN	try again, one of the devices hasn't been activated.
+ */
+int vcm_back(struct res *res_id, struct physmem *physmem_id);
+
+
+/**
+ * vcm_unback() - Unback a reservation.
+ * @res_id	The reservation to unback.
+ *
+ * One VCM can be associated with multiple devices. When you vcm_unback()
+ * each association must be active.
+ *
+ * This function returns 0 on a successful unbacking. Otherwise
+ * it returns:
+ * -EINVAL	res is invalid.
+ * -EAGAIN	try again, one of the devices hasn't been activated.
+ */
+int vcm_unback(struct res *res_id);
+
+
+/**
+ * vcm_phys_alloc() - Allocate physical memory for the VCM region.
+ * @memtype	The memory type to allocate.
+ * @len		The length of the allocation.
+ * @attr	See 'Physical Allocation Attributes'.
+ *
+ * This function will allocate chunks of memory according to the attr
+ * it is passed.
+ *
+ * The return value is non-zero if physical memory has been
+ * successfully allocated.
+ */
+struct physmem *vcm_phys_alloc(enum memtype_t memtype, size_t len,
+			       uint32_t attr);
+
+
+/**
+ * vcm_phys_free() - Free a physical allocation.
+ * @physmem_id	The physical allocation to free.
+ *
+ * The return value is 0 if the physical allocation has been freed or:
+ * -EBUSY	Their are reservation mapping the physical memory.
+ * -EINVAL	The physmem argument is invalid.
+ */
+int vcm_phys_free(struct physmem *physmem_id);
+
+
+/**
+ * vcm_get_physmem_from_res() - Return a reservation's physmem_id
+ * @ res_id	An existing reservation of interest.
+ *
+ * The return value will be non-zero on success, otherwise it will be:
+ * -EINVAL	res is invalid
+ * -ENOMEM	res is unbacked
+ */
+struct physmem *vcm_get_physmem_from_res(struct res *res_id);
+
+
+/**
+ * vcm_get_memtype_of_physalloc() - Return the memtype of a reservation.
+ * @physmem_id	The physical allocation of interest.
+ *
+ * This function returns the memtype of a reservation or VCM_INVALID
+ * if res is invalid.
+ */
+enum memtype_t vcm_get_memtype_of_physalloc(struct physmem *physmem_id);
+
+
+/*
+ * Associate a VCM with a device, activate that association and remove it.
+ *
+ */
+
+/**
+ * vcm_assoc() - Associate a VCM with a device.
+ * @vcm_id	The VCM region of interest.
+ * @dev_id	The device to associate the VCM with.
+ * @attr	See 'Association Attributes'.
+ *
+ * This function returns non-zero if a association is made. It returns 0
+ * if any of its parameters are invalid or VCM_ATTR_VALID is not present.
+ */
+struct avcm *vcm_assoc(struct vcm *vcm_id, size_t dev_id, uint32_t attr);
+
+
+/**
+ * vcm_deassoc() - Deassociate a VCM from a device.
+ * @avcm_id	The association we want to break.
+ *
+ * The function returns 0 on success or:
+ * -EBUSY	The association is currently activated.
+ * -EINVAL	The avcm parameter is invalid.
+ */
+int vcm_deassoc(struct avcm *avcm_id);
+
+
+/**
+ * vcm_set_assoc_attr() - Set an AVCM's attributes.
+ * @avcm_id	The AVCM of interest.
+ * @attr	The new attr. See 'Association Attributes'.
+ *
+ * Every attribute can be set at runtime if an association isn't activated.
+ *
+ * This function returns 0 on success or:
+ * -EBUSY	The association is currently activated.
+ * -EINVAL	The avcm parameter is invalid.
+ */
+int vcm_set_assoc_attr(struct avcm *avcm_id, uint32_t attr);
+
+
+/**
+ * vcm_get_assoc_attr() - Return an AVCM's attributes.
+ * @avcm_id	The AVCM of interest.
+ *
+ * This function returns 0 on error.
+ */
+uint32_t vcm_get_assoc_attr(struct avcm *avcm_id);
+
+
+/**
+ * vcm_activate() - Activate an AVCM.
+ * @avcm_id	The AVCM to activate.
+ *
+ * You have to deactivate, before you activate.
+ *
+ * This function returns 0 on success or:
+ * -EINVAL   	avcm is invalid
+ * -ENODEV	no device
+ * -EBUSY	device is already active
+ * -1		hardware failure
+ */
+int vcm_activate(struct avcm *avcm_id);
+
+
+/**
+ * vcm_deactivate() - Deactivate an association.
+ * @avcm_id	The AVCM to deactivate.
+ *
+ * This function returns 0 on success or:
+ * -ENOENT     	avcm is not activate
+ * -EINVAL	avcm is invalid
+ * -1		hardware failure
+ */
+int vcm_deactivate(struct avcm *avcm_id);
+
+
+/**
+ * vcm_is_active() - Query if an AVCM is active.
+ * @avcm_id	The AVCM of interest.
+ *
+ * returns 0 for not active, 1 for active or -EINVAL for error.
+ *
+ */
+int vcm_is_active(struct avcm *avcm_id);
+
+
+
+/*
+ * Create, manage and remove a boundary in a VCM.
+ */
+
+/**
+ * vcm_create_bound() - Create a bound in a VCM.
+ * @vcm_id 	The VCM that needs a bound.
+ * @len		The len of the bound.
+ *
+ * The allocator picks the virtual addresses of the bound.
+ *
+ * This function returns non-zero if a bound was created.
+ */
+struct bound *vcm_create_bound(struct vcm *vcm_id, size_t len);
+
+
+/**
+ * vcm_free_bound() - Free a bound.
+ * @bound_id	The bound to remove.
+ *
+ * This function returns 0 if bound has been removed or:
+ * -EBUSY	The bound contains reservations and cannot be removed.
+ * -EINVAL	The bound is invalid.
+ */
+int vcm_free_bound(struct bound *bound_id);
+
+
+/**
+ * vcm_reserve_from_bound() - Make a reservation from a bounded area.
+ * @bound_id	The bound to reserve from.
+ * @len		The len of the reservation.
+ * @attr	See 'Reservation Attributes'.
+ *
+ * The return value is non-zero on success. It is 0 if any parameter
+ * is invalid.
+ */
+struct res *vcm_reserve_from_bound(struct bound *bound_id, size_t len,
+				   uint32_t attr);
+
+
+/**
+ * vcm_get_bound_start_addr() - Return the starting device address of the bound.
+ * @bound_id	The bound of interest.
+ *
+ * On success this function returns the starting addres of the bound. On error
+ * it returns:
+ * 1	bound_id is invalid.
+ */
+size_t vcm_get_bound_start_addr(struct bound *bound_id);
+
+
+/**
+ * vcm_get_bound_len() - Return the len of a bound.
+ * @bound_id	The bound of interest.
+ *
+ * This function return non-zero on success, 0 on failure.
+ */
+size_t vcm_get_bound_len(struct bound *bound_id);
+
+
+
+/*
+ * Perform low-level control over VCM regions and reservations.
+ */
+
+/**
+ * vcm_map_phys_addr() - Produce a physmem_id from a contiguous
+ *                       physical address
+ *
+ * @phys	The physical address of the contiguous range.
+ * @len		The len of the contiguous address range.
+ *
+ * Returns non-zero on success, 0 on failure.
+ */
+struct physmem *vcm_map_phys_addr(size_t phys, size_t len);
+
+
+/**
+ * vcm_get_next_phys_addr() - Get the next physical addr and len of a
+ * 			      physmem_id.
+ * @res_id	The physmem_id of interest.
+ * @phys	The current physical address. Set this to NULL to start the
+ *		iteration.
+ * @len		An output: the len of the next physical segment.
+ *
+ * physmem_id's may contain physically discontiguous sections. This
+ * function returns the next physical address and len. Pass NULL to
+ * phys to get the first physical address. The len of the physical
+ * segment is returned in *len.
+ *
+ * Returns 0 if there is no next physical address.
+ */
+size_t vcm_get_next_phys_addr(struct physmem *physmem_id, size_t phys,
+			      size_t *len);
+
+
+/**
+ * vcm_get_dev_addr() - Return the device address of a reservation.
+ * @res_id	The reservation of interest.
+ *
+ *
+ * On success this function returns the device address of a reservation. On
+ * error it returns:
+ * 1	res_id is invalid.
+ *
+ * Note: This may return a kernel address if the reservation was
+ * created from vcm_create_from_prebuilt() and the prebuilt ext_vcm_id
+ * references a VM page table.
+ */
+size_t vcm_get_dev_addr(struct res *res_id);
+
+
+/**
+ * vcm_get_res() - Return the reservation from a device address and a VCM
+ * @dev_addr	The device address of interest.
+ * @vcm_id	The VCM that contains the reservation
+ *
+ * This function returns 0 if there is no reservation whose device
+ * address is dev_addr.
+ */
+struct res *vcm_get_res(size_t dev_addr, struct vcm *vcm_id);
+
+
+/**
+ * vcm_translate() - Translate from one device address to another.
+ * @src_dev_id	The source device address.
+ * @src_vcm_id	The source VCM region.
+ * @dst_vcm_id	The destination VCM region.
+ *
+ * Derive the device address from a VCM region that maps the same physical
+ * memory as a device address from another VCM region.
+ *
+ * On success this function returns the device address of a translation. On
+ * error it returns:
+ * 1	res_id is invalid.
+ */
+size_t vcm_translate(size_t src_dev_id, struct vcm *src_vcm_id,
+		     struct vcm *dst_vcm_id);
+
+
+/**
+ * vcm_get_phys_num_res() - Return the number of reservations mapping a
+ *           		    physical address.
+ * @phys	The physical address to read.
+ */
+size_t vcm_get_phys_num_res(size_t phys);
+
+
+/**
+ * vcm_get_next_phys_res() - Return the next reservation mapped to a physical
+ *			     address.
+ * @phys	The physical address to map.
+ * @res_id	The starting reservation. Set this to NULL for the first
+ *		reservation.
+ * @len		The virtual length of the reservation
+ *
+ * This function returns 0 for the last reservation or no reservation.
+ */
+struct res *vcm_get_next_phys_res(size_t phys, struct res *res_id, size_t *len);
+
+
+/**
+ * vcm_get_pgtbl_pa() - Return the physcial address of a VCM's page table.
+ * @vcm_id	The VCM region of interest.
+ *
+ * This function returns non-zero on success.
+ */
+size_t vcm_get_pgtbl_pa(struct vcm *vcm_id);
+
+
+/**
+ * vcm_get_cont_memtype_pa() - Return the phys base addr of a memtype's
+ * 			       first contiguous region.
+ * @memtype	The memtype of interest.
+ *
+ * This function returns non-zero on success. A zero return indicates that
+ * the given memtype does not have a contiguous region or that the memtype
+ * is invalid.
+ */
+size_t vcm_get_cont_memtype_pa(enum memtype_t memtype);
+
+
+/**
+ * vcm_get_cont_memtype_len() - Return the len of a memtype's
+ * 			       	first contiguous region.
+ * @memtype	The memtype of interest.
+ *
+ * This function returns non-zero on success. A zero return indicates that
+ * the given memtype does not have a contiguous region or that the memtype
+ * is invalid.
+ */
+size_t vcm_get_cont_memtype_len(enum memtype_t memtype);
+
+
+/**
+ * vcm_dev_addr_to_phys_addr() - Perform a device address page-table lookup.
+ * @dev_id	The device that has the table.
+ * @dev_addr	The device address to map.
+ *
+ * This function returns the pa of a va from a device's page-table. It will
+ * fault if the dev_addr is not mapped.
+ */
+size_t vcm_dev_addr_to_phys_addr(size_t dev_id, size_t dev_addr);
+
+
+/*
+ * Fault Hooks
+ *
+ * vcm_hook()
+ */
+
+/**
+ * vcm_hook() - Add a fault handler.
+ * @dev_id	The device.
+ * @handler	The handler.
+ * @data	A private piece of data that will get passed to the handler.
+ *
+ * This function returns 0 for a successful registration or:
+ * -EINVAL	The arguments are invalid.
+ */
+int vcm_hook(size_t dev_id, vcm_handler handler, void *data);
+
+
+
+/*
+ * Low level, platform agnostic, HW control.
+ *
+ * vcm_hw_ver()
+ */
+
+/**
+ * vcm_hw_ver() - Return the hardware version of a device, if it has one.
+ * @dev_id	The device.
+ */
+size_t vcm_hw_ver(size_t dev_id);
+
+
+
+/* bring-up init, destroy */
+int vcm_sys_init(void);
+int vcm_sys_destroy(void);
+
+#endif /* _VCM_H_ */
+
-- 
1.7.0.2

--
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
