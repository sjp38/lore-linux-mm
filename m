Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A1F56B0006
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:58:47 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id l17so337976otf.12
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 10:58:47 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j10si5257492oia.106.2018.02.15.10.58.45
        for <linux-mm@kvack.org>;
        Thu, 15 Feb 2018 10:58:46 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: [PATCH 00/11] APEI in_nmi() rework and arm64 SDEI wire-up
Date: Thu, 15 Feb 2018 18:55:55 +0000
Message-Id: <20180215185606.26736-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, James Morse <james.morse@arm.com>

Hello!

The aim of this series is to wire arm64's SDEI into APEI.

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
Patches 1-3 refactor APEIs 'estatus queue' so it can be used for all
NMI-like notifications. This defers the NMI work to irq_work, which will
happen when we next unmask interrupts.

Patches 4&5 move the arch and KVM code around so that NMI-like notifications
are always called in_nmi().

Patch 6 splits the 'irq or nmi?' path through ghes_copy_tofrom_phys()
up to be per-ghes. This lets each ghes specify which other error-sources
it can share a fixmap-slot and lock with.

Patch 7 renames NOTIFY_SEA's use of NOTIFY_NMI's infrastructure, as we're
about to have multiple NMI-like users that can't share resources.

Pathes 8&9 add the SDEI helper, and notify methods for APEI.

After this, adding the last firmware-first piece for arm64 is simple
(and safe), and all our NMI-like notifications behave the same as x86's
NOTIFY_NMI.


All of this makes the race between memory_failure_queue() and
ret_to_user worse, as there is now always irq_work involved.

Patch 10 makes the reschedule to memory_failure() run as soon as possible.
Patch 11 makes sure the arch code knows whether the irq_work has run by
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
KVM. I've only build tested this on x86.

Trees... The changes outside APEI are tiny, but there will be some changes
to how arch/arm64/mm/fault.c generates signals, affecting do_sea() that will
cause conflicts with patch 5.


Thanks,

James

[0] http://infocenter.arm.com/help/topic/com.arm.doc.den0054a/ARM_DEN0054A_Software_Delegated_Exception_Interface.pdf

James Morse (11):
  ACPI / APEI: Move the estatus queue code up, and under its own ifdef
  ACPI / APEI: Generalise the estatus queue's add/remove and notify code
  ACPI / APEI: Switch NOTIFY_SEA to use the estatus queue
  KVM: arm/arm64: Add kvm_ras.h to collect kvm specific RAS plumbing
  arm64: KVM/mm: Move SEA handling behind a single 'claim' interface
  ACPI / APEI: Make the fixmap_idx per-ghes to allow multiple in_nmi()
    users
  ACPI / APEI: Split fixmap pages for arm64 NMI-like notifications
  firmware: arm_sdei: Add ACPI GHES registration helper
  ACPI / APEI: Add support for the SDEI GHES Notification type
  mm/memory-failure: increase queued recovery work's priority
  arm64: acpi: Make apei_claim_sea() synchronise with APEI's irq work

 arch/arm/include/asm/kvm_ras.h       |  14 +
 arch/arm/include/asm/system_misc.h   |   5 -
 arch/arm64/include/asm/acpi.h        |   3 +
 arch/arm64/include/asm/daifflags.h   |   1 +
 arch/arm64/include/asm/fixmap.h      |   8 +-
 arch/arm64/include/asm/kvm_ras.h     |  29 ++
 arch/arm64/include/asm/system_misc.h |   2 -
 arch/arm64/kernel/acpi.c             |  49 ++++
 arch/arm64/mm/fault.c                |  30 +-
 drivers/acpi/apei/ghes.c             | 533 ++++++++++++++++++++---------------
 drivers/firmware/arm_sdei.c          |  75 +++++
 include/acpi/ghes.h                  |   5 +
 include/linux/arm_sdei.h             |   8 +
 mm/memory-failure.c                  |  11 +-
 virt/kvm/arm/mmu.c                   |   4 +-
 15 files changed, 517 insertions(+), 260 deletions(-)
 create mode 100644 arch/arm/include/asm/kvm_ras.h
 create mode 100644 arch/arm64/include/asm/kvm_ras.h

-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
