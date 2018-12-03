Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id A415D6B6A6C
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 13:06:27 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id o13so5931568otl.20
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 10:06:27 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d134si6897499oib.261.2018.12.03.10.06.25
        for <linux-mm@kvack.org>;
        Mon, 03 Dec 2018 10:06:25 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v7 00/25] APEI in_nmi() rework and SDEI wire-up
Date: Mon,  3 Dec 2018 18:05:48 +0000
Message-Id: <20181203180613.228133-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>, James Morse <james.morse@arm.com>

Hello,

This series aims to wire-up arm64's fancy new software-NMI notifications
for firmware-first RAS. These need to use the estatus-queue, which is
also needed for notifications via emulated-SError. All of these
things take the 'in_nmi()' path through ghes_copy_tofrom_phys(), and
so will deadlock if they can interact, which they might.

To that end, this series removes the in_nmi() stuff from ghes.c.
Locks are pushed out to the notification helpers, and fixmap entries
are passed in to the code that needs them. This means the estatus-queue
users can interrupt each other however they like.

While doing this there is a fair amount of cleanup, which is (now) at the
beginning of the series. NMIlike notifications interrupting
ghes_probe() can go wrong for three different reasons. CPER record
blocks greater than PAGE_SIZE dont' work.
The estatus-pool allocation is simplified and the silent-flag/oops-begin
is removed.

Nothing in this series is intended as fixes, as its all cleanup or
never-worked.


----------%<----------
The earlier boiler-plate:

What's SDEI? Its ARM's "Software Delegated Exception Interface" [0]. It's
used by firmware to tell the OS about firmware-first RAS events.

These Software exceptions can interrupt anything, so I describe them as
NMI-like. They aren't the only NMI-like way to notify the OS about
firmware-first RAS events, the ACPI spec also defines 'NOTFIY_SEA' and
'NOTIFY_SEI'.

(Acronyms: SEA, Synchronous External Abort. The CPU requested some memory,
but the owner of that memory said no. These are always synchronous with the
instruction that caused them. SEI, System-Error Interrupt, commonly called
SError. This is an asynchronous external abort, the memory-owner didn't say no
at the right point. Collectively these things are called external-aborts
How is firmware involved? It traps these and re-injects them into the kernel
once its written the CPER records).

APEI's GHES code only expects one source of NMI. If a platform implements
more than one of these mechanisms, APEI needs to handle the interaction.
'SEA' and 'SEI' can interact as 'SEI' is asynchronous. SDEI can interact
with itself: its exceptions can be 'normal' or 'critical', and firmware
could use both types for RAS. (errors using normal, 'panic-now' using
critical).
----------%<----------


Known issue:
 * ghes_copy_tofrom_phys() already takes a lock in NMI context, this
   series moves that around, and makes sure we never try to take the
   same lock from different NMIlike notifications. Since the switch to
   queued spinlocks it looks like the kernel can only be 4 context's
   deep in spinlock, which arm64 could exceed as it doesn't have a
   single architected NMI. It either needs an additional
   idx-bit in the qspinlock, or for ghes.c to switch to using a
   different type of lock for NMIlike notifications.

Changes since v6:
 * Changed the order of the series.
 * Made hest.c own the estatus pool, which is now vmalloc()d.
 * Culled #ifdef, hopefully without generating too much noise.
 * Added GHESv2 'ack' support to NMI-like notifications
 * Use task-work to kick the memory_failure_queue()

Specific changes are noted in each patch.

[v6] https://www.spinics.net/lists/linux-acpi/msg84228.html
[v5] https://www.spinics.net/lists/linux-acpi/msg82993.html
[v4] https://www.spinics.net/lists/arm-kernel/msg653078.html
[v3] https://www.spinics.net/lists/arm-kernel/msg649230.html

[0] https://static.docs.arm.com/den0054/a/ARM_DEN0054A_Software_Delegated_Exception_Interface.pdf


Feedback welcome,

Thanks

James Morse (25):
  ACPI / APEI: Don't wait to serialise with oops messages when
    panic()ing
  ACPI / APEI: Remove silent flag from ghes_read_estatus()
  ACPI / APEI: Switch estatus pool to use vmalloc memory
  ACPI / APEI: Make hest.c manage the estatus memory pool
  ACPI / APEI: Make estatus pool allocation a static size
  ACPI / APEI: Don't store CPER records physical address in struct ghes
  ACPI / APEI: Remove spurious GHES_TO_CLEAR check
  ACPI / APEI: Don't update struct ghes' flags in read/clear estatus
  ACPI / APEI: Generalise the estatus queue's notify code
  ACPI / APEI: Tell firmware the estatus queue consumed the records
  ACPI / APEI: Move NOTIFY_SEA between the estatus-queue and NOTIFY_NMI
  ACPI / APEI: Switch NOTIFY_SEA to use the estatus queue
  KVM: arm/arm64: Add kvm_ras.h to collect kvm specific RAS plumbing
  arm64: KVM/mm: Move SEA handling behind a single 'claim' interface
  ACPI / APEI: Move locking to the notification helper
  ACPI / APEI: Let the notification helper specify the fixmap slot
  ACPI / APEI: Pass ghes and estatus separately to avoid a later copy
  ACPI / APEI: Split ghes_read_estatus() to allow a peek at the CPER
    length
  ACPI / APEI: Only use queued estatus entry during _in_nmi_notify_one()
  ACPI / APEI: Use separate fixmap pages for arm64 NMI-like
    notifications
  mm/memory-failure: Add memory_failure_queue_kick()
  ACPI / APEI: Kick the memory_failure() queue for synchronous errors
  arm64: acpi: Make apei_claim_sea() synchronise with APEI's irq work
  firmware: arm_sdei: Add ACPI GHES registration helper
  ACPI / APEI: Add support for the SDEI GHES Notification type

 arch/arm/include/asm/kvm_ras.h       |  14 +
 arch/arm/include/asm/system_misc.h   |   5 -
 arch/arm64/include/asm/acpi.h        |   4 +-
 arch/arm64/include/asm/daifflags.h   |   1 +
 arch/arm64/include/asm/fixmap.h      |   6 +-
 arch/arm64/include/asm/kvm_ras.h     |  25 +
 arch/arm64/include/asm/system_misc.h |   2 -
 arch/arm64/kernel/acpi.c             |  51 +++
 arch/arm64/mm/fault.c                |  25 +-
 drivers/acpi/apei/Kconfig            |  12 +-
 drivers/acpi/apei/ghes.c             | 652 ++++++++++++++++-----------
 drivers/acpi/apei/hest.c             |   5 +
 drivers/firmware/arm_sdei.c          |  70 +++
 include/acpi/ghes.h                  |   4 +-
 include/linux/arm_sdei.h             |   9 +
 include/linux/mm.h                   |   1 +
 mm/memory-failure.c                  |  15 +-
 virt/kvm/arm/mmu.c                   |   4 +-
 18 files changed, 606 insertions(+), 299 deletions(-)
 create mode 100644 arch/arm/include/asm/kvm_ras.h
 create mode 100644 arch/arm64/include/asm/kvm_ras.h

-- 
2.19.2
