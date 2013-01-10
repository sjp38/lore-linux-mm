Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 537B66B0070
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 18:50:36 -0500 (EST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH v2 00/12] System device hot-plug framework
Date: Thu, 10 Jan 2013 16:40:18 -0700
Message-Id: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, gregkh@linuxfoundation.org, akpm@linux-foundation.org
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com, Toshi Kani <toshi.kani@hp.com>

This patchset is a prototype of proposed system device hot-plug framework
for design review.  Unlike other hot-plug environments, such as USB and
PCI, there is no common framework for system device hot-plug [1].
Therefore, this patchset is designed to provide a common framework for
hot-plugging and online/offline operations of system devices, such as CPU,
Memory and Node.  While this patchset only supports ACPI-based hot-plug
operations, the framework itself is designed to be platform-neural and
can support other FW architectures as necessary.

This patchset is based on Linus's tree (3.8-rc3).

I have seen a few stability issues with 3.8-rc3 in my testing and will
look into their solutions.

[1] System device hot-plug frameworks for ppc and s390 are implemented
    for specific platforms and products.


Background: System Device Initialization
========================================
System devices, such as CPU and memory, must be initialized during early
boot sequence as they are the essential components to provide low-level
services, ex. scheduling, memory allocation and interrupts, which are
the foundations of the kernel services.  start_kernel() and kernel_init()
manage the boot-up sequence to initialize system devices and low-level
services in pre-defined order as shown below. 

  start_kernel()
    boot_cpu_init()          // init cpu0
    setup_arch()
      efi_init()             // init EFI memory map
      initmem_init()         // init NUMA
      x86_init.paging.pagetable_init() // init page table
      acpi_boot_init()       // parse ACPI MADT table
        :
  kernel_init()
    kernel_init_freeable()
      smp_init()             // init other CPUs
        :
      do_basic_setup()
        driver_init()
          cpu_dev_init()     // build system/cpu tree
          memory_dev_init()  // build system/memory tree
        do_initcalls()
          acpi_init()        // build ACPI device tree

Note that drivers are initialized at the end of the boot sequence as they
depend on the kernel services from system devices.  Hence, while system
devices may be exposed to sysfs with their pseudo drivers, their
initialization may not be fully integrated into the driver structures.  

Overview of the System Device Hot-plug Framework
================================================
Similar to the boot-up sequence, the system device hot-plug framework
provides a sequencer that calls all registered handlers in pre-defined
order for hot-add and hot-delete of system devices.  It allows any modules
initializing system devices in the boot-up sequence to participate in
the hot-plug operations as well.  In high-level, there are two types of
handlers, 1) FW-dependent (ex. ACPI) handlers that enumerate or eject
system devices, and 2) system device (ex. CPU, Memory) management handlers
that online or offline the enumerated system devices.  Online/offline
operations are sub-set of hot-add/delete operations.  The ordering of the
handlers are symmetric between hot-add (online) and hot-delete (offline)
operations.

        hot-add    online
           |    ^    :    ^
  HW Enum/ |    |    :    :
    Eject  |    |    :    :
           |    |    :    :
  Online/  |    |    |    |
  Offline  |    |    |    |
           V    |    V    |
             hot-del   offline

The handlers may not call other handlers directly to exceed their role.
Therefore, the role of the handlers in their modules remains consistent
with their role at the boot-up sequence.  For instance, the ACPI module
may not perform online or offline of system devices.

System Device Hot-plug Operation
================================

Serialized Startup
------------------
The framework provides an interface (hp_submit_req) to request a hot-plug
operation.  All requests are queued to and run on a single work queue.
The framework assures that there is only a single hot-plug or online/
offline operation running at a time.  A single request may however target
to multiple devices.  This makes the execution context of handlers to be
consistent with the boot-up sequence and enables code sharing.

Phased Execution
----------------
The framework proceeds hot-plug and online/offline operations in the 
following three phases.  The modules can register their handlers to each
phase.  The framework also initiates a roll-back operation if any hander
failed in the validate or execute phase.

1) Validate Phase - Handlers validate if they support a given request
without making any changes to target device(s).  They check any known
restrictions and/or prerequisite conditions to their modules, and fail
an unsupported request before making any changes.  For instance, the
memory module may check if a hot-remove request is targeted to movable
ranges.

2) Execute Phase - Handlers make requested change within the scope that
its roll-back is possible in case of a failure.  Execute handlers must
implement their roll-back procedures.

3) Commit Phase - Handlers make the final change that cannot be rolled-back.
For instance, the ACPI module invokes _EJ0 for a hot-remove operation.

System Device Management Modules
================================

CPU Handlers
------------
CPU handlers are provided by the CPU driver in drivers/base/cpu.c, and
perform CPU online/offline procedures when CPU device(s) is added or
deleted during an operation.

Memory Handlers
---------------
Memory handlers are provided by the memory module in mm/memory_hotplug.c,
and perform Memory online/offline procedure when memory device(s) is
added or deleted during an operation.

FW-dependent Modules
====================

ACPI Bus Handlers
-----------------
ACPI bus handlers are provided by the ACPI core in drivers/acpi/bus.c,
and construct/destruct acpi_device object(s) during a hot-plug operation.

ACPI Resource Handlers
----------------------
ACPI resource handlers are provided by the ACPI core in
drivers/acpi/hp_resource.c, and set device resource information to
a request during a hot-plug operation.  This device resource information
is then consumed by the system device management modules for their
online/offline procedure.

ACPI Drivers
------------
ACPI drivers are called from the ACPI core during a hot-plug operation
through the following interfaces.  ACPI drivers are not called from the
framework directly, and remain internal to the ACPI core.  ACPI drivers
may not initiate online/offline of a device.

.add - Construct device-specific information to a given acpi_device.
Called at boot, hot-add and sysfs bind.

.remove - Destruct device-specific information to a given acpi_device.
Called at hot-remove and sysfs unbind.

.resource - Set device-specific resource information to a given hot-plug
request.  Called at hot-add and hot-remove.

---
v2:
 - Documented that system devices may not be initialized through the driver
   structures.
 - Clarified that the framework is for "system device" hotplug by changing
   file name, prefix and documentation.
 - Removed the use of CONFIG_HOTPLUG.
 - Moved ACPI specific definitions to include/acpi/sys_hotplug.h.
 - Implemented shp_unregister_handler() and added locking.
 - Added module parameters, shp_trace and del_movable_only.

---
Toshi Kani (12):
 Add sys_hotplug.h for system device hotplug framework
 ACPI: Add sys_hotplug.h for system device hotplug framework
 drivers/base: Add system device hotplug framework 
 cpu: Add cpu hotplug handlers
 mm: Add memory hotplug handlers
 ACPI: Add ACPI bus hotplug handlers
 ACPI: Add ACPI resource hotplug handler
 ACPI: Update processor driver for hotplug framework
 ACPI: Update memory driver for hotplug framework
 ACPI: Update container driver for hotplug framework
 cpu: Update sysfs cpu/online for hotplug framework
 ACPI: Update sysfs eject for hotplug framework

---
 drivers/acpi/Makefile           |   1 +
 drivers/acpi/acpi_memhotplug.c  | 271 ++++++++++++----------------------
 drivers/acpi/bus.c              | 134 +++++++++++++++++
 drivers/acpi/container.c        |  95 +++++-------
 drivers/acpi/internal.h         |   1 +
 drivers/acpi/processor_driver.c | 150 +++++++++----------
 drivers/acpi/scan.c             | 122 +++-------------
 drivers/acpi/shp_resource.c     |  86 +++++++++++
 drivers/base/Makefile           |   1 +
 drivers/base/cpu.c              | 147 +++++++++++++++++--
 drivers/base/sys_hotplug.c      | 313 ++++++++++++++++++++++++++++++++++++++++
 include/acpi/acpi_bus.h         |   8 +-
 include/acpi/sys_hotplug.h      |  48 ++++++
 include/linux/sys_hotplug.h     | 181 +++++++++++++++++++++++
 mm/memory_hotplug.c             | 101 +++++++++++++
 15 files changed, 1224 insertions(+), 435 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
