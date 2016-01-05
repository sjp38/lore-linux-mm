Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id CF3D76B0003
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 13:55:09 -0500 (EST)
Received: by mail-oi0-f41.google.com with SMTP id y66so280026814oig.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 10:55:09 -0800 (PST)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id m100si27021306oik.31.2016.01.05.10.55.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 10:55:08 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v3 00/17] Enhance iomem search interfaces and support EINJ to NVDIMM
Date: Tue,  5 Jan 2016 11:54:28 -0700
Message-Id: <1452020068-26492-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: torvalds@linux-foundation.org, rafael.j.wysocki@intel.com, dan.j.williams@intel.com, dyoung@redhat.com, x86@kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, kexec@lists.infradead.org, xen-devel@lists.xenproject.org, linux-samsung-soc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org

This patch-set enhances the iomem table and its search interfacs, and
then changes EINJ to support NVDIMM.

 - Patches 1-2 add a new System RAM type, IORESOURCE_SYSTEM_RAM, and
   make the iomem search interfaces work with resource flags with
   modifier bits set.  IORESOURCE_SYSTEM_RAM has IORESOURCE_MEM bit set
   for backward compatibility.

 - Patch 3 adds a new field, I/O resource descriptor, into struct resource.
   Drivers can assign their unique descritor to a range when they support
   the iomem search interfaces.

 - Patches 4-9 changes initializations of resource entries.  They set
   the System RAM type to System RAM ranges, set I/O resource descriptors
   to the regions targeted by the iomem search interfaces, and change
   to call kzalloc() where kmalloc() is used to allocate struct resource
   ranges.

 - Patches 10-14 extend the iomem interfaces to check System RAM ranges
   with the System RAM type and the I/O resource descriptor.

 - Patch 15-16 remove deprecated walk_iomem_res().

 - Patch 17 changes the EINJ driver to allow injecting a memory error
   to NVDIMM.

---
v3:
 - Remove the walk_iomem_res() call with "GART" in crash.c since it is
   no longer needed. Then kill walk_iomem_res(). (Borislav Petkov,
   Dave Young)
 - Change to use crashk_res.desc at the walk_iomem_res_desc() call in
   kexec_add_buffer(). (Minfei Huang)

v2:
 - Add 'desc' to struct resource, and add a new iomem interface to
   search with the desc. (Borislav Petkov)
 - Add a check to checkpatch.pl to warn on new use of walk_iomem_res().
   (Borislav Petkov)

v1:
 - Searching for System RAM in the resource table should not require
   strcmp(). (Borislav Petkov)
 - Add a new System RAM type as a modifier to IORESOURCE_MEM.
   (Linus Torvalds)
 - NVDIMM check needs to be able to distinguish legacy and NFIT pmem
   ranges. (Dan Williams)

---
Toshi Kani (17):
 01/17 resource: Add System RAM resource type
 02/17 resource: make resource flags handled properly
 03/17 resource: Add I/O resource descriptor
 04/17 x86/e820: Set System RAM type and descriptor
 05/17 ia64: Set System RAM type and descriptor
 06/17 arch: Set IORESOURCE_SYSTEM_RAM to System RAM
 07/17 kexec: Set IORESOURCE_SYSTEM_RAM to System RAM
 08/17 xen, mm: Set IORESOURCE_SYSTEM_RAM to System RAM
 09/17 drivers: Initialize resource entry to zero
 10/17 resource: Change walk_system_ram to use System RAM type
 11/17 arm/samsung: Change s3c_pm_run_res() to use System RAM type
 12/17 memremap: Change region_intersects() to take @flags and @desc
 13/17 resource: Add walk_iomem_res_desc()
 14/17 x86,nvdimm,kexec: Use walk_iomem_res_desc() for iomem search
 15/17 x86/kexec: Remove walk_iomem_res() call with GART
 16/17 resource: Kill walk_iomem_res()
 17/17 ACPI/EINJ: Allow memory error injection to NVDIMM

---
 arch/arm/kernel/setup.c            |  6 +--
 arch/arm/plat-samsung/pm-check.c   |  4 +-
 arch/arm64/kernel/setup.c          |  6 +--
 arch/avr32/kernel/setup.c          |  6 +--
 arch/ia64/kernel/efi.c             | 13 ++++--
 arch/ia64/kernel/setup.c           |  6 +--
 arch/m32r/kernel/setup.c           |  4 +-
 arch/mips/kernel/setup.c           | 10 +++--
 arch/parisc/mm/init.c              |  6 +--
 arch/powerpc/mm/mem.c              |  2 +-
 arch/s390/kernel/setup.c           |  8 ++--
 arch/score/kernel/setup.c          |  2 +-
 arch/sh/kernel/setup.c             |  8 ++--
 arch/sparc/mm/init_64.c            |  8 ++--
 arch/tile/kernel/setup.c           | 11 +++--
 arch/unicore32/kernel/setup.c      |  6 +--
 arch/x86/kernel/crash.c            | 41 ++-----------------
 arch/x86/kernel/e820.c             | 38 ++++++++++++++++-
 arch/x86/kernel/pmem.c             |  4 +-
 arch/x86/kernel/setup.c            |  6 +--
 drivers/acpi/acpi_platform.c       |  2 +-
 drivers/acpi/apei/einj.c           | 15 +++++--
 drivers/nvdimm/e820.c              |  2 +-
 drivers/parisc/eisa_enumerator.c   |  4 +-
 drivers/rapidio/rio.c              |  8 ++--
 drivers/sh/superhyway/superhyway.c |  2 +-
 drivers/xen/balloon.c              |  2 +-
 include/linux/ioport.h             | 33 ++++++++++++++-
 include/linux/mm.h                 |  3 +-
 kernel/kexec_core.c                |  8 ++--
 kernel/kexec_file.c                |  8 ++--
 kernel/memremap.c                  | 13 +++---
 kernel/resource.c                  | 83 ++++++++++++++++++++++----------------
 mm/memory_hotplug.c                |  2 +-
 34 files changed, 225 insertions(+), 155 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
