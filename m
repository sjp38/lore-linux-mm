Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5F0746B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 18:37:31 -0500 (EST)
Received: by oian133 with SMTP id n133so24334679oia.3
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 15:37:31 -0800 (PST)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id p125si30680843oih.81.2015.12.14.15.37.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 15:37:30 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH 00/11] Support System RAM resource type and EINJ to NVDIMM
Date: Mon, 14 Dec 2015 16:37:15 -0700
Message-Id: <1450136235-17012-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: torvalds@linux-foundation.org, rafael.j.wysocki@intel.com, dan.j.williams@intel.com, x86@kernel.org, konrad.wilk@oracle.com, xen-devel@lists.xenproject.org, dyoung@redhat.com, vgoyal@redhat.com, tangchen@cn.fujitsu.com, kgene@kernel.org, k.kozlowski@samsung.com, linux-samsung-soc@vger.kernel.org, vishal.l.verma@intel.com, tony.luck@intel.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org

This patch-set introduces a new I/O resource type, IORESOURCE_SYSTEM_RAM,
for System RAM while keeping the current IORESOURCE_MEM type bit set for
all memory-mapped ranges (including System RAM) for backward compatibility.
With the new System RAM type, walking through the iomem resource table
no longer requires to test with strcmp() against "System RAM".  After this
infrastructure update, this patch changes EINJ to support NVDIMM.

Patches 1-2 add a new System RAM type, and make resource interfaces work
with resource flags with modifier bits set.

Patches 3-7 set the System RAM type to System RAM ranges.

Patches 8-10 extend resource interfaces to check System RAM ranges with
the System RAM type.

Patch 11 changes the EINJ driver to allow injecting a memory error to
NVDIMM.

---
v1:
 - Searching for System RAM in the resource table should not require
   strcmp(). (Borislav Petkov)
 - Add a new System RAM type as a modifier to IORESOURCE_MEM.
   (Linus Torvalds)
 - NVDIMM check should remain with strcmp() against "Persistent Memory".
   (Dan Williams)
 - Reset patch version.

prev-v3:
 - Check the param2 value before target memory type. (Tony Luck)
 - Add a blank line before if-statement. Remove an unnecessary brakets.
   (Borislav Petkov)

prev-v2:
 - Change the EINJ driver to call region_intersects_ram() for checking
   RAM with a specified size. (Dan Williams)

---
Toshi Kani (11):
 01/11 resource: Add System RAM resource type
 02/11 resource: make resource flags handled properly
 03/11 x86/e820: Set IORESOURCE_SYSTEM_RAM to System RAM
 04/11 arch: Set IORESOURCE_SYSTEM_RAM to System RAM
 05/11 xen: Set IORESOURCE_SYSTEM_RAM to System RAM
 06/11 kexec: Set IORESOURCE_SYSTEM_RAM to System RAM
 07/11 memory-hotplug: Set IORESOURCE_SYSTEM_RAM to System RAM
 08/11 memremap: Change region_intersects() to use System RAM type
 09/11 resource: Change walk_system_ram to use System RAM type
 10/11 arm/samsung: Change s3c_pm_run_res() to use System RAM type
 11/11 ACPI/EINJ: Allow memory error injection to NVDIMM

---
 arch/arm/kernel/setup.c          |  6 ++---
 arch/arm/plat-samsung/pm-check.c |  4 +--
 arch/arm64/kernel/setup.c        |  6 ++---
 arch/avr32/kernel/setup.c        |  6 ++---
 arch/ia64/kernel/efi.c           |  6 +++--
 arch/ia64/kernel/setup.c         |  6 ++---
 arch/m32r/kernel/setup.c         |  4 +--
 arch/mips/kernel/setup.c         | 10 +++++---
 arch/parisc/mm/init.c            |  6 ++---
 arch/powerpc/mm/mem.c            |  2 +-
 arch/s390/kernel/setup.c         |  8 +++---
 arch/score/kernel/setup.c        |  2 +-
 arch/sh/kernel/setup.c           |  8 +++---
 arch/sparc/mm/init_64.c          |  8 +++---
 arch/tile/kernel/setup.c         | 11 +++++---
 arch/unicore32/kernel/setup.c    |  6 ++---
 arch/x86/kernel/e820.c           | 18 +++++++++++++-
 arch/x86/kernel/setup.c          |  6 ++---
 drivers/acpi/apei/einj.c         | 15 ++++++++---
 drivers/xen/balloon.c            |  2 +-
 include/linux/ioport.h           | 11 ++++++++
 include/linux/mm.h               |  3 ++-
 kernel/kexec_core.c              |  6 ++---
 kernel/kexec_file.c              |  2 +-
 kernel/memremap.c                | 13 +++++-----
 kernel/resource.c                | 54 +++++++++++++++++++++-------------------
 mm/memory_hotplug.c              |  2 +-
 27 files changed, 140 insertions(+), 91 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
