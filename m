Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE5B66B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 13:55:36 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id n6so116799728qtd.4
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:55:36 -0800 (PST)
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com. [209.85.220.178])
        by mx.google.com with ESMTPS id q4si28239189qtd.315.2016.11.29.10.55.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 10:55:36 -0800 (PST)
Received: by mail-qk0-f178.google.com with SMTP id q130so184703849qke.1
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:55:35 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv4 00/10] CONFIG_DEBUG_VIRTUAL for arm64
Date: Tue, 29 Nov 2016 10:55:19 -0800
Message-Id: <1480445729-27130-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Laura Abbott <labbott@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>, Juergen Gross <jgross@suse.com>, Eric Biederman <ebiederm@xmission.com>, kexec@lists.infradead.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, Andrey Ryabinin <aryabinin@virtuozzo.com>, Kees Cook <keescook@chromium.org>


Hi,

This is v4 of the series to add CONFIG_DEBUG_VIRTUAL for arm64. This mostly
expanded on __pa_symbol conversion with a few new sites found. There's also
some reworking done to avoid calling __va too early. __va relies on having
memstart_addr set so very early code in early_fixmap_init and early KASAN
initialization can't just call __va(__Ipa_symbol(...)) to get the linear map
alias. I found this while testing with DEBUG_VM.

All of this could use probably use more testing under more configurations.
KVM, Xen, kexec, hibernate should all be tested.

Thanks,
Laura

Laura Abbott (10):
  lib/Kconfig.debug: Add ARCH_HAS_DEBUG_VIRTUAL
  mm/cma: Cleanup highmem check
  arm64: Move some macros under #ifndef __ASSEMBLY__
  arm64: Add cast for virt_to_pfn
  arm64: Use __pa_symbol for kernel symbols
  xen: Switch to using __pa_symbol
  kexec: Switch to __pa_symbol
  mm/kasan: Switch to using __pa_symbol and lm_alias
  mm/usercopy: Switch to using lm_alias
  arm64: Add support for CONFIG_DEBUG_VIRTUAL

 arch/arm64/Kconfig                        |  1 +
 arch/arm64/include/asm/kvm_mmu.h          |  4 +-
 arch/arm64/include/asm/memory.h           | 67 ++++++++++++++++++++++---------
 arch/arm64/include/asm/mmu_context.h      |  6 +--
 arch/arm64/include/asm/pgtable.h          |  2 +-
 arch/arm64/kernel/acpi_parking_protocol.c |  2 +-
 arch/arm64/kernel/cpu-reset.h             |  2 +-
 arch/arm64/kernel/cpufeature.c            |  2 +-
 arch/arm64/kernel/hibernate.c             | 13 +++---
 arch/arm64/kernel/insn.c                  |  2 +-
 arch/arm64/kernel/psci.c                  |  2 +-
 arch/arm64/kernel/setup.c                 |  8 ++--
 arch/arm64/kernel/smp_spin_table.c        |  2 +-
 arch/arm64/kernel/vdso.c                  |  4 +-
 arch/arm64/mm/Makefile                    |  2 +
 arch/arm64/mm/init.c                      | 11 ++---
 arch/arm64/mm/kasan_init.c                | 21 ++++++----
 arch/arm64/mm/mmu.c                       | 32 +++++++++------
 arch/arm64/mm/physaddr.c                  | 28 +++++++++++++
 arch/x86/Kconfig                          |  1 +
 drivers/firmware/psci.c                   |  2 +-
 drivers/xen/xenbus/xenbus_dev_backend.c   |  2 +-
 drivers/xen/xenfs/xenstored.c             |  2 +-
 include/linux/mm.h                        |  4 ++
 kernel/kexec_core.c                       |  2 +-
 lib/Kconfig.debug                         |  5 ++-
 mm/cma.c                                  | 15 +++----
 mm/kasan/kasan_init.c                     | 12 +++---
 mm/usercopy.c                             |  4 +-
 29 files changed, 167 insertions(+), 93 deletions(-)
 create mode 100644 arch/arm64/mm/physaddr.c

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
