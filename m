Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9450E6B000C
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 13:01:33 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id y123-v6so12374774oie.5
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:01:33 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x133-v6si663042oif.346.2018.06.26.10.01.30
        for <linux-mm@kvack.org>;
        Tue, 26 Jun 2018 10:01:30 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v5 00/20] APEI in_nmi() rework and arm64 SDEI wire-up
Date: Tue, 26 Jun 2018 18:00:56 +0100
Message-Id: <20180626170116.25825-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, James Morse <james.morse@arm.com>

The aim of this series is to wire arm64's SDEI into APEI.

On arm64 we have three APEI notifications that are NMI-like, and
in the unlikely event that all three are supported by a platform,
they can interrupt each other.
The GHES driver shouldn't have to deal with this, so this series aims
to make it re-entrant.

To do that, we refactor the estatus queue to allow multiple notifications
to use it, then convert NOTIFY_SEA to always be described as NMI-like,
and to use the estatus queue.

>From here we push the locking and fixmap choices out to the notification
functions, and remove the use of per-ghes estatus and flags. This removes
the in_nmi() 'timebomb' in ghes_copy_tofrom_phys().

Things get sticky when an NMI notification needs to know how big the
CPER records might be, before reading it. This series splits
ghes_estatus_read() to let us peek at the buffer. A side effect of this
is the 20byte header will get read twice. (how does it work today? it
reads the records into a per-ghes worst-case sized buffer, allocates
the correct size and copies the records. in_nmi() use of this per-ghes
buffer needs eliminating).

One alternative was to trust firmware's 'max raw data length' and use
that to allocate 'enough' memory. We don't use this value today, so its
probably wrong on some sytem somewhere.

Since v4 patches 5,8-15 are new, otherwise changes are noted in the patch.


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


ghes.c became clearer to me when I worked out that it has three sets of
functions with 'estatus' in the name. One is a pool of memory that can be
allocated-from atomically. This is grown/shrunk when new NMI users are
allocated.
The second is the estatus-cache, which holds recent notifications so it
can suppress notifications we've already handled.
The last it the estatus-queue, which holds data from NMI-like notifications
(in pool memory) to be processed from irq_work.


Testing?
Tested with the SDEI FVP based software model and a mocked up NOTFIY_SEA using
KVM. I've added a case where 'corrected errors' are discovered at probe time
to exercise ghes_probe() during boot. I've only build tested this on x86.

This series based on v4.18-rc2 can be retrieved from:
git://linux-arm.org/linux-jm.git -b apei_sdei/v5


Thanks,

James

[0] http://infocenter.arm.com/help/topic/com.arm.doc.den0054a/ARM_DEN0054A_Software_Delegated_Exception_Interface.pdf

James Morse (20):
  ACPI / APEI: Move the estatus queue code up, and under its own ifdef
  ACPI / APEI: Generalise the estatus queue's add/remove and notify code
  ACPI / APEI: don't wait to serialise with oops messages when
    panic()ing
  ACPI / APEI: Switch NOTIFY_SEA to use the estatus queue
  ACPI / APEI: Make estatus queue a Kconfig symbol
  KVM: arm/arm64: Add kvm_ras.h to collect kvm specific RAS plumbing
  arm64: KVM/mm: Move SEA handling behind a single 'claim' interface
  ACPI / APEI: Move locking to the notification helper
  ACPI / APEI: Let the notification helper specify the fixmap slot
  ACPI / APEI: preparatory split of ghes->estatus
  ACPI / APEI: Remove silent flag from ghes_read_estatus()
  ACPI / APEI: Don't store CPER records physical address in struct ghes
  ACPI / APEI: Don't update struct ghes' flags in read/clear estatus
  ACPI / APEI: Split ghes_read_estatus() to read CPER length
  ACPI / APEI: Only use queued estatus entry during _in_nmi_notify_one()
  ACPI / APEI: Split fixmap pages for arm64 NMI-like notifications
  firmware: arm_sdei: Add ACPI GHES registration helper
  ACPI / APEI: Add support for the SDEI GHES Notification type
  mm/memory-failure: increase queued recovery work's priority
  arm64: acpi: Make apei_claim_sea() synchronise with APEI's irq work

 arch/arm/include/asm/kvm_ras.h       |  14 +
 arch/arm/include/asm/system_misc.h   |   5 -
 arch/arm64/include/asm/acpi.h        |   4 +
 arch/arm64/include/asm/daifflags.h   |   1 +
 arch/arm64/include/asm/fixmap.h      |   8 +-
 arch/arm64/include/asm/kvm_ras.h     |  25 ++
 arch/arm64/include/asm/system_misc.h |   2 -
 arch/arm64/kernel/acpi.c             |  49 ++
 arch/arm64/mm/fault.c                |  30 +-
 drivers/acpi/apei/Kconfig            |  11 +
 drivers/acpi/apei/ghes.c             | 649 ++++++++++++++++-----------
 drivers/firmware/Kconfig             |   1 +
 drivers/firmware/arm_sdei.c          |  66 +++
 include/acpi/ghes.h                  |   2 -
 include/linux/arm_sdei.h             |   9 +
 mm/memory-failure.c                  |  11 +-
 virt/kvm/arm/mmu.c                   |   4 +-
 17 files changed, 591 insertions(+), 300 deletions(-)
 create mode 100644 arch/arm/include/asm/kvm_ras.h
 create mode 100644 arch/arm64/include/asm/kvm_ras.h

-- 
2.17.1
