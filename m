Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4060C8E0011
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id a2so15212800pgt.11
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:08 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id p11si31508288plk.191.2018.12.26.05.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Message-Id: <20181226131446.330864849@intel.com>
Date: Wed, 26 Dec 2018 21:14:46 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness accounting/migration
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Fengguang Wu <fengguang.wu@intel.com>

This is an attempt to use NVDIMM/PMEM as volatile NUMA memory that's
transparent to normal applications and virtual machines.

The code is still in active development. It's provided for early design review.

Key functionalities:

1) create and describe PMEM NUMA node for NVDIMM memory
2) dumb /proc/PID/idle_pages interface, for user space driven hot page accounting
3) passive kernel cold page migration in page reclaim path
4) improved move_pages() for active user space hot/cold page migration

(1) is foundation for transparent usage of NVDIMM for normal apps and virtual
machines. (2-4) enable auto placing hot pages in DRAM for better performance.
A user space migration daemon is being built based on this kernel patchset to
make the full vertical solution.

Base kernel is v4.20 . The patches are not suitable for upstreaming in near
future -- some are quick hacks, some others need more works. However they are
complete enough to demo the necessary kernel changes for the proposed app&VM
transparent NVDIMM volatile use model.

The interfaces are far from finalized. They kind of illustrate what would be
necessary for creating a user space driven solution. The exact forms will ask
for more thoughts and inputs. We may adopt HMAT based solution for NUMA node
related interface when they are ready. The /proc/PID/idle_pages interface is
standalone but non-trivial. Before upstreaming some day, it's expected to take
long time to collect various real use cases and feedbacks, so as to refine and
stabilize the format.

Create PMEM numa node

	[PATCH 01/21] e820: cheat PMEM as DRAM

Mark numa node as DRAM/PMEM

	[PATCH 02/21] acpi/numa: memorize NUMA node type from SRAT table
	[PATCH 03/21] x86/numa_emulation: fix fake NUMA in uniform case
	[PATCH 04/21] x86/numa_emulation: pass numa node type to fake nodes
	[PATCH 05/21] mmzone: new pgdat flags for DRAM and PMEM
	[PATCH 06/21] x86,numa: update numa node type
	[PATCH 07/21] mm: export node type {pmem|dram} under /sys/bus/node

Point neighbor DRAM/PMEM to each other

	[PATCH 08/21] mm: introduce and export pgdat peer_node
	[PATCH 09/21] mm: avoid duplicate peer target node

Standalone zonelist for DRAM and PMEM nodes

	[PATCH 10/21] mm: build separate zonelist for PMEM and DRAM node

Keep page table pages in DRAM

	[PATCH 11/21] kvm: allocate page table pages from DRAM
	[PATCH 12/21] x86/pgtable: allocate page table pages from DRAM

/proc/PID/idle_pages interface for virtual machine and normal tasks

	[PATCH 13/21] x86/pgtable: dont check PMD accessed bit
	[PATCH 14/21] kvm: register in mm_struct
	[PATCH 15/21] ept-idle: EPT walk for virtual machine
	[PATCH 16/21] mm-idle: mm_walk for normal task
	[PATCH 17/21] proc: introduce /proc/PID/idle_pages
	[PATCH 18/21] kvm-ept-idle: enable module

Mark hot pages

	[PATCH 19/21] mm/migrate.c: add move_pages(MPOL_MF_SW_YOUNG) flag

Kernel DRAM=>PMEM migration

	[PATCH 20/21] mm/vmscan.c: migrate anon DRAM pages to PMEM node
	[PATCH 21/21] mm/vmscan.c: shrink anon list if can migrate to PMEM

 arch/x86/include/asm/numa.h    |    2 
 arch/x86/include/asm/pgalloc.h |   10 
 arch/x86/include/asm/pgtable.h |    3 
 arch/x86/kernel/e820.c         |    3 
 arch/x86/kvm/Kconfig           |   11 
 arch/x86/kvm/Makefile          |    4 
 arch/x86/kvm/ept_idle.c        |  841 +++++++++++++++++++++++++++++++
 arch/x86/kvm/ept_idle.h        |  116 ++++
 arch/x86/kvm/mmu.c             |   12 
 arch/x86/mm/numa.c             |    3 
 arch/x86/mm/numa_emulation.c   |   30 +
 arch/x86/mm/pgtable.c          |   22 
 drivers/acpi/numa.c            |    5 
 drivers/base/node.c            |   21 
 fs/proc/base.c                 |    2 
 fs/proc/internal.h             |    1 
 fs/proc/task_mmu.c             |   54 +
 include/linux/mm_types.h       |   11 
 include/linux/mmzone.h         |   38 +
 mm/mempolicy.c                 |   14 
 mm/migrate.c                   |   13 
 mm/page_alloc.c                |   77 ++
 mm/pagewalk.c                  |    1 
 mm/vmscan.c                    |   38 +
 virt/kvm/kvm_main.c            |    3 
 25 files changed, 1306 insertions(+), 29 deletions(-)

V1 patches: https://lkml.org/lkml/2018/9/2/13

Regards,
Fengguang
