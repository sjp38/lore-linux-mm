Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id DE7148E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 12:47:35 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id a10so4563665plp.14
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 09:47:35 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id s4si15324322pfb.190.2019.01.09.09.47.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 09:47:34 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv3 00/13] Heterogeneuos memory node attributes
Date: Wed,  9 Jan 2019 10:43:28 -0700
Message-Id: <20190109174341.19818-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Verstion three adding heterogeneous memory attributes to existing node
sysfs subsystem.

== Background ==

Platforms may provide multiple types of cpu attached system memory. The
memory ranges for each type may have different characteristics that
applications may wish to know about when considering what node they want
their memory allocated from. 

It had previously been difficult to describe these setups as memory
rangers were generally lumped into the NUMA node of the CPUs. New
platform attributes have been created and in use today that describe
the more complex memory hierarchies that can be created.

This series' objective is to provide the attributes from such systems
that are useful for applications to know about, and readily usable with
existing tools and libraries.

== Changes since v2 ==

  Fixed the arch specific build breakage from modifying the acpi table
  parsing. This one has been in a public tree for 0-day and no failures
  reported after several weeks.

  The HMAT parsing rules is split in its own patch. This was originally
  intended to be a starting point to enable auto-detect a use for
  enabling memory randomization:

    https://lkml.org/lkml/2018/12/17/1116

  But will leave them split for separate consideration and bring
  randomization auto-enable back when these settle.

  The previous version's node interface allowed expressing the
  relationship only among the best locality nodes, called "primary"
  initiators and targets. Based on public and private feedback, the
  interface has been augmented to allow registering nodes under a "class"
  hierarchy. If a subsystem wishes to express node relationships beyond
  the best, they may create additional access classes. The HMAT subsystem
  this series only registers the best performing class, "class0".

  Various changelog and documentation updates and clarifications.

Keith Busch (13):
  acpi: Create subtable parsing infrastructure
  acpi: Add HMAT to generic parsing tables
  acpi/hmat: Parse and report heterogeneous memory
  node: Link memory nodes to their compute nodes
  Documentation/ABI: Add new node sysfs attributes
  acpi/hmat: Register processor domain to its memory
  node: Add heterogenous memory access attributes
  Documentation/ABI: Add node performance attributes
  acpi/hmat: Register performance attributes
  node: Add memory caching attributes
  Documentation/ABI: Add node cache attributes
  acpi/hmat: Register memory side cache attributes
  doc/mm: New documentation for memory performance

 Documentation/ABI/stable/sysfs-devices-node   |  87 +++++-
 Documentation/admin-guide/mm/numaperf.rst     | 184 +++++++++++++
 arch/arm64/kernel/acpi_numa.c                 |   2 +-
 arch/arm64/kernel/smp.c                       |   4 +-
 arch/ia64/kernel/acpi.c                       |  12 +-
 arch/x86/kernel/acpi/boot.c                   |  36 +--
 drivers/acpi/Kconfig                          |   9 +
 drivers/acpi/Makefile                         |   1 +
 drivers/acpi/hmat.c                           | 375 ++++++++++++++++++++++++++
 drivers/acpi/numa.c                           |  16 +-
 drivers/acpi/scan.c                           |   4 +-
 drivers/acpi/tables.c                         |  76 +++++-
 drivers/base/Kconfig                          |   8 +
 drivers/base/node.c                           | 317 +++++++++++++++++++++-
 drivers/irqchip/irq-gic-v2m.c                 |   2 +-
 drivers/irqchip/irq-gic-v3-its-pci-msi.c      |   2 +-
 drivers/irqchip/irq-gic-v3-its-platform-msi.c |   2 +-
 drivers/irqchip/irq-gic-v3-its.c              |   6 +-
 drivers/irqchip/irq-gic-v3.c                  |  10 +-
 drivers/irqchip/irq-gic.c                     |   4 +-
 drivers/mailbox/pcc.c                         |   2 +-
 include/linux/acpi.h                          |   6 +-
 include/linux/node.h                          |  70 ++++-
 23 files changed, 1170 insertions(+), 65 deletions(-)
 create mode 100644 Documentation/admin-guide/mm/numaperf.rst
 create mode 100644 drivers/acpi/hmat.c

-- 
2.14.4
