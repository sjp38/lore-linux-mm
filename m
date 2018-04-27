Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 19B076B0003
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 11:38:20 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id v31-v6so1476046otb.0
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 08:38:20 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p1-v6si564393ote.14.2018.04.27.08.38.18
        for <linux-mm@kvack.org>;
        Fri, 27 Apr 2018 08:38:18 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v3 00/12] APEI in_nmi() rework and arm64 SDEI wire-up
Date: Fri, 27 Apr 2018 16:34:58 +0100
Message-Id: <20180427153510.5799-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <cdall@kernel.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, James Morse <james.morse@arm.com>

The aim of this series is to wire arm64's SDEI into APEI.

Nothing much has changed since v2, patch 3 is new and the KVM IS_ENABLED()
stuff has been cleaned up. Otherwise things are noted in each patch.

This touches a few trees, so I'm not sure how best it should be merged.
Patches 11 and 12 are reducing a race that is made worse by patch 4, I'd
like them to arrive together, even though patch 11 doesn't depend on anything
else in the series. (patches 11&12 could be moved to after 8 if that makes
things easier)


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

What does this series do?
Patches 1-4 refactor APEIs 'estatus queue' so it can be used for all
NMI-like notifications. This defers the NMI work to irq_work, which will
happen when we next unmask interrupts.

Patches 5&6 move the arch and KVM code around so that NMI-like notifications
are always called in_nmi().

Patch 7 changes the 'irq or nmi?' path through ghes_copy_tofrom_phys()
to be per-ghes. When called in_nmi(), the struct ghes is expected to
provide a fixmap slot and lock that is safe to use. NMI-like notifications
that mask each other can share these resources. Those that interact should
have their own fixmap slot and lock.

Patch 8 renames NOTIFY_SEA's use of NOTIFY_NMI's infrastructure, as we're
about to have multiple NMI-like users that can't share resources.

Pathes 9&10 add the SDEI helper, and notify methods for APEI.

After this, adding further firmware-first pieces for arm64 is simple
(and safe), and all our NMI-like notifications behave the same as x86's
NOTIFY_NMI.

All of this makes the race between memory_failure_queue() and
ret_to_user worse, as there is now always irq_work involved.

Patch 11 makes the reschedule to memory_failure() run as soon as possible.
Patch 12 makes sure the arch code knows whether the irq_work has run by
the time do_sea() returns. We can skip the signalling step if it has as
APEI has done its work.


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


Thanks,

James

[0] http://infocenter.arm.com/help/topic/com.arm.doc.den0054a/ARM_DEN0054A_Software_Delegated_Exception_Interface.pdf


James Morse (12):
  ACPI / APEI: Move the estatus queue code up, and under its own ifdef
  ACPI / APEI: Generalise the estatus queue's add/remove and notify code
  ACPI / APEI: don't wait to serialise with oops messages when
    panic()ing
  ACPI / APEI: Switch NOTIFY_SEA to use the estatus queue
  KVM: arm/arm64: Add kvm_ras.h to collect kvm specific RAS plumbing
  arm64: KVM/mm: Move SEA handling behind a single 'claim' interface
  ACPI / APEI: Make the nmi_fixmap_idx per-ghes to allow multiple
    in_nmi() users
  ACPI / APEI: Split fixmap pages for arm64 NMI-like notifications
  firmware: arm_sdei: Add ACPI GHES registration helper
  ACPI / APEI: Add support for the SDEI GHES Notification type
  mm/memory-failure: increase queued recovery work's priority
  arm64: acpi: Make apei_claim_sea() synchronise with APEI's irq work

 arch/arm/include/asm/kvm_ras.h       |  14 +
 arch/arm/include/asm/system_misc.h   |   5 -
 arch/arm64/include/asm/acpi.h        |   5 +-
 arch/arm64/include/asm/daifflags.h   |   1 +
 arch/arm64/include/asm/fixmap.h      |   8 +-
 arch/arm64/include/asm/kvm_ras.h     |  24 ++
 arch/arm64/include/asm/system_misc.h |   2 -
 arch/arm64/kernel/acpi.c             |  49 ++++
 arch/arm64/mm/fault.c                |  30 +-
 drivers/acpi/apei/ghes.c             | 517 ++++++++++++++++++++---------------
 drivers/firmware/arm_sdei.c          |  77 ++++++
 include/acpi/ghes.h                  |   4 +
 include/linux/arm_sdei.h             |   8 +
 mm/memory-failure.c                  |  11 +-
 virt/kvm/arm/mmu.c                   |   4 +-
 15 files changed, 499 insertions(+), 260 deletions(-)
 create mode 100644 arch/arm/include/asm/kvm_ras.h
 create mode 100644 arch/arm64/include/asm/kvm_ras.h

-- 
2.16.2
