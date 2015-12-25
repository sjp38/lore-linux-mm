Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 13B8B82FCB
	for <linux-mm@kvack.org>; Fri, 25 Dec 2015 17:09:34 -0500 (EST)
Received: by mail-oi0-f49.google.com with SMTP id l9so123276590oia.2
        for <linux-mm@kvack.org>; Fri, 25 Dec 2015 14:09:34 -0800 (PST)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id tp11si22341229oec.74.2015.12.25.14.09.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Dec 2015 14:09:33 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v2 00/16] Enhance iomem search interfaces and support EINJ to NVDIMM
Date: Fri, 25 Dec 2015 15:09:04 -0700
Message-Id: <1451081344-15145-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: torvalds@linux-foundation.org, rafael.j.wysocki@intel.com, dan.j.williams@intel.com, x86@kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, konrad.wilk@oracle.com, xen-devel@lists.xenproject.org, dyoung@redhat.com, k.kozlowski@samsung.com, linux-samsung-soc@vger.kernel.org, vishal.l.verma@intel.com, tony.luck@intel.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org

This patch-set enhances the iomem table and its search interfacs, and
then changes EINJ to support NVDIMM.

 - Patches 1-2 add a new System RAM type, IORESOURCE_SYSTEM_RAM, and
   make the iomem search interfaces work with resource flags with
   modifier bits set.  IORESOURCE_SYSTEM_RAM has IORESOURCE_MEM bit set
   for backward compatibility.

 - Patch 3 adds a new field, I/O resource descriptor, in struct resource.
   Drivers can assign their unique descritor to a range when they
   support the iomem search interfaces.

 - Patches 4-9 changes initializations of resource entries.  They set
   the System RAM type to System RAM ranges, set I/O resource descriptors
   to the regions targeted by the iomem search interfaces, and change
   to call kzalloc() where kmalloc() is used to allocate struct resource
   ranges.

 - Patches 10-14 extend the iomem interfaces to check System RAM ranges
   with the System RAM type and the I/O resource descriptor.

 - Patch 15 adds a check to checkpatch.pl to warn on new use of
   walk_iomem_res().

 - Patch 16 changes the EINJ driver to allow injecting a memory error
   to NVDIMM.

---
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
Toshi Kani (16):
 01/16 resource: Add System RAM resource type
 02/16 resource: make resource flags handled properly
 03/16 resource: Add I/O resource descriptor
 04/16 x86/e820: Set System RAM type and descriptor
 05/16 ia64: Set System RAM type and descriptor
 06/16 arch: Set IORESOURCE_SYSTEM_RAM to System RAM
 07/16 kexec: Set IORESOURCE_SYSTEM_RAM to System RAM
 08/16 xen, mm: Set IORESOURCE_SYSTEM_RAM to System RAM
 09/16 drivers: Initialize resource entry to zero
 10/16 resource: Change walk_system_ram to use System RAM type
 11/16 arm/samsung: Change s3c_pm_run_res() to use System RAM type
 12/16 memremap: Change region_intersects() to take @flags and @desc
 13/16 resource: Add walk_iomem_res_desc()
 14/16 x86,nvdimm,kexec: Use walk_iomem_res_desc() for iomem search
 15/16 checkpatch: Add warning on deprecated walk_iomem_res
 16/16 ACPI/EINJ: Allow memory error injection to NVDIMM

---
 arch/arm/kernel/setup.c            |   6 +-
 arch/arm/plat-samsung/pm-check.c   |   4 +-
 arch/arm64/kernel/setup.c          |   6 +-
 arch/avr32/kernel/setup.c          |   6 +-
 arch/ia64/kernel/efi.c             |  13 ++++-
 arch/ia64/kernel/setup.c           |   6 +-
 arch/m32r/kernel/setup.c           |   4 +-
 arch/mips/kernel/setup.c           |  10 ++--
 arch/parisc/mm/init.c              |   6 +-
 arch/powerpc/mm/mem.c              |   2 +-
 arch/s390/kernel/setup.c           |   8 +--
 arch/score/kernel/setup.c          |   2 +-
 arch/sh/kernel/setup.c             |   8 +--
 arch/sparc/mm/init_64.c            |   8 +--
 arch/tile/kernel/setup.c           |  11 +++-
 arch/unicore32/kernel/setup.c      |   6 +-
 arch/x86/kernel/crash.c            |   4 +-
 arch/x86/kernel/e820.c             |  38 ++++++++++++-
 arch/x86/kernel/pmem.c             |   4 +-
 arch/x86/kernel/setup.c            |   6 +-
 drivers/acpi/acpi_platform.c       |   2 +-
 drivers/acpi/apei/einj.c           |  15 +++--
 drivers/nvdimm/e820.c              |   2 +-
 drivers/parisc/eisa_enumerator.c   |   4 +-
 drivers/rapidio/rio.c              |   8 +--
 drivers/sh/superhyway/superhyway.c |   2 +-
 drivers/xen/balloon.c              |   2 +-
 include/linux/ioport.h             |  33 +++++++++++
 include/linux/mm.h                 |   3 +-
 kernel/kexec_core.c                |   8 ++-
 kernel/kexec_file.c                |   8 +--
 kernel/memremap.c                  |  13 +++--
 kernel/resource.c                  | 110 +++++++++++++++++++++++++++----------
 mm/memory_hotplug.c                |   2 +-
 scripts/checkpatch.pl              |   6 ++
 35 files changed, 265 insertions(+), 111 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
