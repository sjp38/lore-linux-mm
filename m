Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 31EB76B005A
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 18:26:49 -0500 (EST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH 00/11] Hot-plug and Online/Offline framework
Date: Wed, 12 Dec 2012 16:17:12 -0700
Message-Id: <1355354243-18657-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, gregkh@linuxfoundation.org, akpm@linux-foundation.org
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com, Toshi Kani <toshi.kani@hp.com>

This patchset is an initial prototype of proposed hot-plug framework
for design review.  The hot-plug framework is designed to provide 
the common framework for hot-plugging and online/offline operations
of system devices, such as CPU, Memory and Node.  While this patchset
only supports ACPI-based hot-plug operations, the framework itself is
designed to be platform-neural and can support other FW architectures
as necessary.

The patchset has not been fully tested yet, esp. for memory hot-plug.
Any help for testing will be very appreciated since my test setup
is limited.

The patchset is based on the linux-next branch of linux-pm.git tree.

Overview of the Framework
=========================
High-level overview of the framework is shown below.  Hot-plug and
online/offline operations are supported by two types of modules - 
FW-dependent modules and resource management modules.  The FW-dependent
modules are FW architecture-specific, such as ACPI, and enumerate HW
devices for hot-plug operations.  The resource management modules,
such as CPU and memory management, generally have platform-neutral
entry points and online or offline the enumerated HW resources for
both online/offline and hot-plug operations.

              -----------> sysfs online
              <----------- sysfs offline
  -----------------------> hot-add
  <----------------------- hot-delete, sysfs eject

  FW-dep      Resource Mgmt
  (HW enum)   (online/offline)
  +-----------+-----------+
  |   ACPI    |   CPU     |
  |-----------|   Memory  |
  | Other FW  |   etc.    |
  +-----------+-----------+

The framework calls the FW-dependent and resource management modules
in pre-defined order, which is analogous to the boot-up sequence,
during the operations.  The ordering of the modules is symmetric
between online/hot-add operations and offline/hot-remove operations.
The modules may not call other modules directly to exceed their role.
Therefore, the role of the modules during the operations remains
consistent with their role at the boot-up sequence.  For instance,
the ACPI module may not initiate online or offline of enumerated
devices.

Hot-plug Operation
==================

Serialized Startup
------------------
The framework provides an interface (hp_submit_req) to request a 
hot-plug or online/offline operation.  All requests are queued to
and run on a single work queue.  The framework assures that there is
only a single hot-plug or online/offline operation running at a time.
A single request may however target to multiple devices. 

Phased Execution
----------------
The framework proceeds hot-plug and online/offline operations in
the following three phases.  The modules can register their handlers
to each phase.  The framework also initiates a roll-back operation
if any hander failed in the validate or execute phase.

1) Validate Phase - Handlers validate if they support a given request
without making any changes to target device(s).  Any known restrictions
and/or prerequisite conditions are checked in this phase, so that an
unsupported request can be failed before making any changes.  For
instance, the memory module may check if a hot-remove request is
targeted to movable ranges.

2) Execute Phase - Handlers make requested changes within the scope
that roll-back is possible in case of a failure.  Execute handlers
must implement their roll-back procedures.

3) Commit Phase - Handlers make the final changes that cannot be
rolled-back.  For instance, the ACPI module invokes _EJ0 for a 
hot-remove operation.

Resource Management Modules
===========================

CPU Handlers
------------
CPU handlers are provided by the CPU driver in drivers/base/cpu.c,
and perform CPU online/offline procedures when CPU device(s) is added
or deleted during an operation.

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
drivers/acpi/hp_resource.c, and set device resource information to a
request during a hot-plug operation.  This device resource information
is then consumed by the resource management modules for their online/
offline procedure.

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

.resource - Set device-specific resource information to a given hot-pug
request.  Called at hot-add and hot-remove.

---
Toshi Kani (11):
 Add hotplug.h for hotplug framework
 drivers/base: Add hotplug framework code
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
 drivers/acpi/acpi_memhotplug.c  | 290 +++++++++++++---------------------------
 drivers/acpi/bus.c              | 134 +++++++++++++++++++
 drivers/acpi/container.c        |  95 +++++--------
 drivers/acpi/hp_resource.c      |  86 ++++++++++++
 drivers/acpi/internal.h         |   1 +
 drivers/acpi/processor_driver.c | 150 ++++++++++-----------
 drivers/acpi/scan.c             | 122 +++--------------
 drivers/base/Makefile           |   1 +
 drivers/base/cpu.c              | 135 +++++++++++++++++--
 drivers/base/hotplug.c          | 283 +++++++++++++++++++++++++++++++++++++++
 include/acpi/acpi_bus.h         |   8 +-
 include/linux/hotplug.h         | 187 ++++++++++++++++++++++++++
 mm/memory_hotplug.c             |  97 ++++++++++++++
 14 files changed, 1137 insertions(+), 453 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
