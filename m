Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D2A7F6B0321
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 23:24:39 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y73-v6so12643547pfi.16
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 20:24:39 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id f66-v6si26216343pfc.35.2018.10.30.20.24.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 20:24:38 -0700 (PDT)
Subject: [PATCH 0/8] Introduce a device-dax bus-based device-model
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 30 Oct 2018 20:12:49 -0700
Message-ID: <154095556915.3271337.12581429676272726902.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com

Prompted by the review of "[PATCH 0/9] Allow persistent memory to be
used like normal RAM" [1] introduce a new bus / device-driver-model
for device-dax.

Currently device-dax instances result from attaching an nvdimm namespace
device to the dax_pmem driver. These instances are registered with the
/sys/class/dax sub-system. With the expectation that platforms will
describe performance differentiated memory [2] for ranges other than
persistent memory (pmem) a new device-model is needed.

Arrange for dax_pmem to be one of potentially several drivers that know
how to discover differentiated memory and register a device instance on
the dax bus. The expectation is that, by default, this device is
consumed by the typical device-dax driver that will expose the range
through a /dev/daxX.Y character device. Optionally other drivers can
consume the dax device instance. For example, the kmem driver [1] can
attach to device-dax device instance to hot-add the related memory range
to the core page-allocator.

Going forward, provider drivers outside of dax_pmem can be created to
register other memories with unique performance properties.

Since /sys/class/dax is a released ABI, a compat driver is provided so
that distros can opt-in to the new bus based ABI. The /sys/class/dax
interface is then deprecated and scheduled to be removed.

[1]: https://lkml.org/lkml/2018/10/23/9
[2]: Section 5.2.27 Heterogeneous Memory Attribute Table (HMAT)
     http://www.uefi.org/sites/default/files/resources/ACPI%206_2_A_Sept29.pdf

---

Dan Williams (8):
      device-dax: Kill dax_region ida
      device-dax: Kill dax_region base
      device-dax: Remove multi-resource infrastructure
      device-dax: Start defining a dax bus model
      device-dax: Introduce bus + driver model
      device-dax: Move resource pinning+mapping into the common driver
      device-dax: Add support for a dax override driver
      device-dax: Add /sys/class/dax backwards compatibility


 Documentation/ABI/obsolete/sysfs-class-dax |   22 +
 drivers/dax/Kconfig                        |   12 +
 drivers/dax/Makefile                       |    5 
 drivers/dax/bus.c                          |  449 ++++++++++++++++++++++++++++
 drivers/dax/bus.h                          |   60 ++++
 drivers/dax/dax-private.h                  |   30 +-
 drivers/dax/dax.h                          |   18 -
 drivers/dax/device-dax.h                   |   25 --
 drivers/dax/device.c                       |  365 +++++------------------
 drivers/dax/pmem.c                         |  161 ----------
 drivers/dax/pmem/Makefile                  |    7 
 drivers/dax/pmem/compat.c                  |   73 +++++
 drivers/dax/pmem/core.c                    |   69 ++++
 drivers/dax/pmem/pmem.c                    |   40 ++
 drivers/dax/super.c                        |   41 ++-
 tools/testing/nvdimm/Kbuild                |    7 
 tools/testing/nvdimm/dax-dev.c             |   16 -
 17 files changed, 880 insertions(+), 520 deletions(-)
 create mode 100644 Documentation/ABI/obsolete/sysfs-class-dax
 create mode 100644 drivers/dax/bus.c
 create mode 100644 drivers/dax/bus.h
 delete mode 100644 drivers/dax/dax.h
 delete mode 100644 drivers/dax/device-dax.h
 delete mode 100644 drivers/dax/pmem.c
 create mode 100644 drivers/dax/pmem/Makefile
 create mode 100644 drivers/dax/pmem/compat.c
 create mode 100644 drivers/dax/pmem/core.c
 create mode 100644 drivers/dax/pmem/pmem.c
