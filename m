Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA3ED8E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 20:05:45 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 12so9409143plb.18
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 17:05:45 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i1si11402278pfj.276.2018.12.10.17.05.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 17:05:44 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv2 00/12] Heterogeneous memory node attributes
Date: Mon, 10 Dec 2018 18:02:58 -0700
Message-Id: <20181211010310.8551-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Here is the second version for adding heterogeneous memory attributes to
the existing node sysfs representation.

Background:

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

Changes since v1:

  Reordered the patches. The ACPI and bare-bones HMAT parsing come
  first. The kernel interfaces, documentation and in-kernel users follow.

  For correctness, have the new generic ACPI parsing and their callbacks
  use the acpi union header type instead of the common header.

  Added node masks in addition to the node symlinks for primary memory and
  cpu nodes.

  Altered the naming conventions to clearly indicate the attributes are
  for primary access and capture the relationship for the new access
  attributes to their primary nodes.

  Added Documentation/ABI.

  Used 'struct device' instead of kobject for memory side caches.

  Initialize HMAT with subsys_initcall instead of device_init.

  Combined the numa performance documentation into a single file and
  moved it to admin-guide/mm/.

  Changelogs updated with spelling/grammar/editorial fixes, and include
  additional examples.

Keith Busch (12):
  acpi: Create subtable parsing infrastructure
  acpi/hmat: Parse and report heterogeneous memory
  node: Link memory nodes to their compute nodes
  Documentation/ABI: Add new node sysfs attributes
  acpi/hmat: Register processor domain to its memory
  node: Add heterogenous memory performance
  Documentation/ABI: Add node performance attributes
  acpi/hmat: Register performance attributes
  node: Add memory caching attributes
  Documentation/ABI: Add node cache attributes
  acpi/hmat: Register memory side cache attributes
  doc/mm: New documentation for memory performance

 Documentation/ABI/stable/sysfs-devices-node |  96 ++++++-
 Documentation/admin-guide/mm/numaperf.rst   | 171 ++++++++++++
 arch/x86/kernel/acpi/boot.c                 |  36 +--
 drivers/acpi/Kconfig                        |   9 +
 drivers/acpi/Makefile                       |   1 +
 drivers/acpi/hmat.c                         | 393 ++++++++++++++++++++++++++++
 drivers/acpi/numa.c                         |  16 +-
 drivers/acpi/scan.c                         |   4 +-
 drivers/acpi/tables.c                       |  76 +++++-
 drivers/base/Kconfig                        |   8 +
 drivers/base/node.c                         | 269 +++++++++++++++++++
 drivers/irqchip/irq-gic-v3.c                |   2 +-
 drivers/mailbox/pcc.c                       |   2 +-
 include/linux/acpi.h                        |   6 +-
 include/linux/node.h                        |  49 ++++
 15 files changed, 1096 insertions(+), 42 deletions(-)
 create mode 100644 Documentation/admin-guide/mm/numaperf.rst
 create mode 100644 drivers/acpi/hmat.c

-- 
2.14.4
