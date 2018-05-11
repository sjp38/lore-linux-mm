Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 179E16B067F
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:07:34 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id x195-v6so3420497oix.18
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:07:34 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l127-v6si1184682oib.332.2018.05.11.12.07.32
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:07:32 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 00/40] Shared Virtual Addressing for the IOMMU
Date: Fri, 11 May 2018 20:06:01 +0100
Message-Id: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

This is version 2 of the Shared Virtual Addressing (SVA) series, which
adds process address space management (1-6) and I/O page faults (7-9) to
the IOMMU core. It also includes two example users of the API: VFIO as
device driver (10-13), and Arm SMMUv3 as IOMMU driver (14-40).

The series is getting bulky and although it will remove lots of context,
I'll probably split next version into IOMMU, VFIO and SMMU changes. This
time around I also Cc'd the mm list even though get_maintainers doesn't
pick it up, because I'd like to export a few symbols in patches 10-12
and because of the recent interest in sharing mm with devices [1], which
seems somewhat related.

Major changes since v1 [2]:

* Removed bind_group(). Only bind_device() is supported. Supporting
  multi-device groups is difficult and unnecessary at the moment.

* Reworked the I/O Page Fault code to support multiple queues. IOMMU
  driver now registers IOPF queues as needed (for example one per IOMMU
  device), then attach devices that require IOPF (for example, in
  sva_device_init)

* mm_exit callback is allowed to sleep. It is now registered with
  init_sva_device_init() instead of a separate function.

* Remove IOMMU_SVA_FEAT_PASID, making PASID support mandatory for now.
  If a future series implements !PASID, it will have to introduce flag
  IOMMU_SVA_FEAT_NO_PASID.

* Removed the atomic/blocking handler distinction for now. It is a bit
  irrelevant here and can be added back later.

* Tried to address all comments. Please let me know if I missed
  something.

The series relies on Jacob Pan's fault reporting work, currently under
discussion [3].

You can pull everything from:
     git://linux-arm.org/linux-jpb.git sva/v2
Branch sva/debug contains tracepoints and other tools that I found
useful for validation.

[1] https://lwn.net/Articles/753481/
[2] https://www.mail-archive.com/iommu@lists.linux-foundation.org/msg21813.html
[3] IOMMU and VT-d driver support for Shared Virtual Address (SVA)
    https://www.mail-archive.com/iommu@lists.linux-foundation.org/msg22640.html
                                ---

If you're unfamiliar with SVM/SVA, a wordy description copied from
previous version follows.

Shared Virtual Addressing (SVA) is the ability to share process address
spaces with devices. It is called "SVM" (Shared Virtual Memory) by OpenCL
and some IOMMU architectures, but since that abbreviation is already used
for AMD virtualisation in Linux (Secure Virtual Machine), we prefer the
less ambiguous "SVA".

Sharing process address spaces with devices allows to rely on core kernel
memory management for DMA, removing some complexity from application and
device drivers. After binding to a device, applications can instruct it to
perform DMA on buffers obtained with malloc.

The device, bus and IOMMU must support the following features:

* Multiple address spaces per device, for example using the PCI PASID
  (Process Address Space ID) extension. The IOMMU driver allocates a
  PASID and the device uses it in DMA transactions.

* I/O Page Faults (IOPF), for example PCI PRI (Page Request Interface) or
  Arm SMMU stall. The core mm handles translation faults from the IOMMU.

* MMU and IOMMU implement compatible page table formats.

This series requires to support all three features. Upcoming patches will
enable private PASID management, which doesn't share page tables and
augments the map/unmap API with PASIDs.

Although we don't have any performance measurement at the moment, SVA will
likely be slower than classical DMA since it relies on page faults,
whereas classical DMA pins all pages in memory. SVA mostly aims at
simplifying DMA management, but also improves security by isolating
address spaces in devices.

Jean-Philippe Brucker (40):
  iommu: Introduce Shared Virtual Addressing API
  iommu/sva: Bind process address spaces to devices
  iommu/sva: Manage process address spaces
  iommu/sva: Add a mm_exit callback for device drivers
  iommu/sva: Track mm changes with an MMU notifier
  iommu/sva: Search mm by PASID
  iommu: Add a page fault handler
  iommu/iopf: Handle mm faults
  iommu/sva: Register page fault handler
  mm: export symbol mm_access
  mm: export symbol find_get_task_by_vpid
  mm: export symbol mmput_async
  vfio: Add support for Shared Virtual Addressing
  dt-bindings: document stall and PASID properties for IOMMU masters
  iommu/of: Add stall and pasid properties to iommu_fwspec
  arm64: mm: Pin down ASIDs for sharing mm with devices
  iommu/arm-smmu-v3: Link domains and devices
  iommu/io-pgtable-arm: Factor out ARM LPAE register defines
  iommu: Add generic PASID table library
  iommu/arm-smmu-v3: Move context descriptor code
  iommu/arm-smmu-v3: Add support for Substream IDs
  iommu/arm-smmu-v3: Add second level of context descriptor table
  iommu/arm-smmu-v3: Share process page tables
  iommu/arm-smmu-v3: Seize private ASID
  iommu/arm-smmu-v3: Add support for VHE
  iommu/arm-smmu-v3: Enable broadcast TLB maintenance
  iommu/arm-smmu-v3: Add SVA feature checking
  iommu/arm-smmu-v3: Implement mm operations
  iommu/arm-smmu-v3: Add support for Hardware Translation Table Update
  iommu/arm-smmu-v3: Register I/O Page Fault queue
  iommu/arm-smmu-v3: Improve add_device error handling
  iommu/arm-smmu-v3: Maintain a SID->device structure
  iommu/arm-smmu-v3: Add stall support for platform devices
  ACPI/IORT: Check ATS capability in root complex nodes
  iommu/arm-smmu-v3: Add support for PCI ATS
  iommu/arm-smmu-v3: Hook up ATC invalidation to mm ops
  iommu/arm-smmu-v3: Disable tagged pointers
  PCI: Make "PRG Response PASID Required" handling common
  iommu/arm-smmu-v3: Add support for PRI
  iommu/arm-smmu-v3: Add support for PCI PASID

 .../devicetree/bindings/iommu/iommu.txt       |   24 +
 MAINTAINERS                                   |    6 +-
 arch/arm64/include/asm/mmu.h                  |    1 +
 arch/arm64/include/asm/mmu_context.h          |   11 +-
 arch/arm64/mm/context.c                       |   92 +-
 drivers/acpi/arm64/iort.c                     |   11 +
 drivers/iommu/Kconfig                         |   29 +
 drivers/iommu/Makefile                        |    4 +
 drivers/iommu/amd_iommu.c                     |   19 +-
 drivers/iommu/arm-smmu-v3-context.c           |  700 ++++++++
 drivers/iommu/arm-smmu-v3.c                   | 1438 ++++++++++++++---
 drivers/iommu/io-pgfault.c                    |  445 +++++
 drivers/iommu/io-pgtable-arm.c                |   49 +-
 drivers/iommu/io-pgtable-arm.h                |   54 +
 drivers/iommu/iommu-pasid-table.c             |   52 +
 drivers/iommu/iommu-pasid-table.h             |  177 ++
 drivers/iommu/iommu-sva.c                     |  792 +++++++++
 drivers/iommu/iommu.c                         |   84 +
 drivers/iommu/of_iommu.c                      |   12 +
 drivers/pci/ats.c                             |   17 +
 drivers/vfio/vfio_iommu_type1.c               |  449 ++++-
 include/linux/iommu.h                         |  184 +++
 include/linux/pci-ats.h                       |    8 +
 include/uapi/linux/pci_regs.h                 |    1 +
 include/uapi/linux/vfio.h                     |   76 +
 kernel/fork.c                                 |   15 +
 kernel/pid.c                                  |    1 +
 27 files changed, 4469 insertions(+), 282 deletions(-)
 create mode 100644 drivers/iommu/arm-smmu-v3-context.c
 create mode 100644 drivers/iommu/io-pgfault.c
 create mode 100644 drivers/iommu/io-pgtable-arm.h
 create mode 100644 drivers/iommu/iommu-pasid-table.c
 create mode 100644 drivers/iommu/iommu-pasid-table.h
 create mode 100644 drivers/iommu/iommu-sva.c

-- 
2.17.0
