Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E36286B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 11:50:57 -0400 (EDT)
Received: from eu_spt2 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0L5V00DNM5CP4H@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Tue, 20 Jul 2010 16:50:49 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L5V00HON5COIO@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 20 Jul 2010 16:50:48 +0100 (BST)
Date: Tue, 20 Jul 2010 17:51:23 +0200
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [PATCH 0/4] The Contiguous Memory Allocator
Message-id: <cover.1279639238.git.m.nazarewicz@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Pawel Osciak <p.osciak@samsung.com>, Xiaolin Zhang <xiaolin.zhang@intel.com>, Hiremath Vaibhav <hvaibhav@ti.com>, Robert Fekete <robert.fekete@stericsson.com>, Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, Michal Nazarewicz <m.nazarewicz@samsung.com>
List-ID: <linux-mm.kvack.org>

Hello everyone,

The following patchset implement a Contiguous Memory Allocator.  Here
is an excerpt from the documentation which describes what it is and
why is it needed:

   The Contiguous Memory Allocator (CMA) is a framework, which allows
   setting up a machine-specific configuration for physically-contiguous
   memory management. Memory for devices is then allocated according
   to that configuration.

   The main role of the framework is not to allocate memory, but to
   parse and manage memory configurations, as well as to act as an
   in-between between device drivers and pluggable allocators. It is
   thus not tied to any memory allocation method or strategy.

** Why is it needed?

    Various devices on embedded systems have no scatter-getter and/or
    IO map support and as such require contiguous blocks of memory to
    operate.  They include devices such as cameras, hardware video
    decoders and encoders, etc.

    Such devices often require big memory buffers (a full HD frame is,
    for instance, more then 2 mega pixels large, i.e. more than 6 MB
    of memory), which makes mechanisms such as kmalloc() ineffective.

    Some embedded devices impose additional requirements on the
    buffers, e.g. they can operate only on buffers allocated in
    particular location/memory bank (if system has more than one
    memory bank) or buffers aligned to a particular memory boundary.

    Development of embedded devices have seen a big rise recently
    (especially in the V4L area) and many such drivers include their
    own memory allocation code. Most of them use bootmem-based methods.
    CMA framework is an attempt to unify contiguous memory allocation
    mechanisms and provide a simple API for device drivers, while
    staying as customisable and modular as possible.

** Design

    The main design goal for the CMA was to provide a customisable and
    modular framework, which could be configured to suit the needs of
    individual systems.  Configuration specifies a list of memory
    regions, which then are assigned to devices.  Memory regions can
    be shared among many device drivers or assigned exclusively to
    one.  This has been achieved in the following ways:

    1. The core of the CMA does not handle allocation of memory and
       management of free space.  Dedicated allocators are used for
       that purpose.

       This way, if the provided solution does not match demands
       imposed on a given system, one can develop a new algorithm and
       easily plug it into the CMA framework.

       The presented solution includes an implementation of a best-fit
       algorithm.

    2. CMA allows a run-time configuration of the memory regions it
       will use to allocate chunks of memory from.  The set of memory
       regions is given on command line so it can be easily changed
       without the need for recompiling the kernel.

       Each region has it's own size, alignment demand, a start
       address (physical address where it should be placed) and an
       allocator algorithm assigned to the region.

       This means that there can be different algorithms running at
       the same time, if different devices on the platform have
       distinct memory usage characteristics and different algorithm
       match those the best way.

    3. When requesting memory, devices have to introduce themselves.
       This way CMA knows who the memory is allocated for.  This
       allows for the system architect to specify which memory regions
       each device should use.

       3a. Devices can also specify a "kind" of memory they want.
           This makes it possible to configure the system in such
           a way, that a single device may get memory from different
           memory regions, depending on the "kind" of memory it
           requested.  For example, a video codec driver might want to
           allocate some shared buffers from the first memory bank and
           the other from the second to get the highest possible
           memory throughput.

For more information please refer to the second patch from the
patchset which contains the documentation.


The patches in the patchset include:

Michal Nazarewicz (4):
  lib: rbtree: rb_root_init() function added

    The rb_root_init() function initialises an RB tree with a single
    node placed in the root.  This is more convenient then
    initialising an empty tree and then adding an element.

  mm: cma: Contiguous Memory Allocator added

    This patch is the main patchset that implements the CMA framework
    including the best-fit allocator.  It also adds a documentation.

  mm: cma: Test device and application added

    This patch adds a misc device that works as a proxy to the CMA
    framework and a simple testing application.  This lets one test
    the whole framework from user space as well as reply an recorded
    allocate/free sequence.

  arm: Added CMA to Aquila and Goni

    This patch adds the CMA platform initialisation code to two ARM
    platforms.  It serves as an example of how this is achieved.

 Documentation/cma.txt               |  435 +++++++++++++++++++
 Documentation/kernel-parameters.txt |    7 +
 arch/arm/Kconfig                    |    1 +
 arch/arm/mach-s5pv210/Kconfig       |    1 +
 arch/arm/mach-s5pv210/mach-aquila.c |    7 +
 arch/arm/mach-s5pv210/mach-goni.c   |    7 +
 drivers/misc/Kconfig                |    8 +
 drivers/misc/Makefile               |    1 +
 drivers/misc/cma-dev.c              |  183 ++++++++
 include/linux/cma-int.h             |  183 ++++++++
 include/linux/cma.h                 |  122 ++++++
 include/linux/rbtree.h              |   11 +
 mm/Kconfig                          |   41 ++
 mm/Makefile                         |    3 +
 mm/cma-allocators.h                 |   42 ++
 mm/cma-best-fit.c                   |  360 ++++++++++++++++
 mm/cma.c                            |  778 +++++++++++++++++++++++++++++++++++
 tools/cma/cma-test.c                |  373 +++++++++++++++++
 18 files changed, 2563 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/cma.txt
 create mode 100644 drivers/misc/cma-dev.c
 create mode 100644 include/linux/cma-int.h
 create mode 100644 include/linux/cma.h
 create mode 100644 mm/cma-allocators.h
 create mode 100644 mm/cma-best-fit.c
 create mode 100644 mm/cma.c
 create mode 100644 tools/cma/cma-test.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
