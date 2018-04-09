Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 01FBB6B0009
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 09:57:34 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u8so6047939qkg.15
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 06:57:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o4si449524qta.101.2018.04.09.06.57.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 06:57:32 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w39Du1E6045325
	for <linux-mm@kvack.org>; Mon, 9 Apr 2018 09:57:31 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h88dubg9r-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 09 Apr 2018 09:57:30 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 9 Apr 2018 14:57:23 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH 1/3] mm: introduce ARCH_HAS_PTE_SPECIAL
Date: Mon,  9 Apr 2018 15:57:07 +0200
In-Reply-To: <1523282229-20731-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1523282229-20731-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1523282229-20731-2-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>, mhocko@kernel.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Vineet Gupta <vgupta@synopsys.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

Currently the PTE special supports is turned on in per architecture header
files. Most of the time, it is defined in arch/*/include/asm/pgtable.h
depending or not on some other per architecture static definition.

This patch introduce a new configuration variable to manage this directly
in the Kconfig files. It would later replace __HAVE_ARCH_PTE_SPECIAL.

Here notes for some architecture where the definition of
__HAVE_ARCH_PTE_SPECIAL is not obvious:

arm
 __HAVE_ARCH_PTE_SPECIAL which is currently defined in
arch/arm/include/asm/pgtable-3level.h which is included by
arch/arm/include/asm/pgtable.h when CONFIG_ARM_LPAE is set.
So select ARCH_HAS_PTE_SPECIAL if ARM_LPAE.

powerpc
__HAVE_ARCH_PTE_SPECIAL is defined in 2 files:
 - arch/powerpc/include/asm/book3s/64/pgtable.h
 - arch/powerpc/include/asm/pte-common.h
The first one is included if (PPC_BOOK3S & PPC64) while the second is
included in all the other cases.
So select ARCH_HAS_PTE_SPECIAL all the time.

sparc:
__HAVE_ARCH_PTE_SPECIAL is defined if defined(__sparc__) &&
defined(__arch64__) which are defined through the compiler in
sparc/Makefile if !SPARC32 which I assume to be if SPARC64.
So select ARCH_HAS_PTE_SPECIAL if SPARC64

Suggested-by: Jerome Glisse <jglisse@redhat.com>
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/arc/Kconfig     | 1 +
 arch/arm/Kconfig     | 1 +
 arch/arm64/Kconfig   | 1 +
 arch/powerpc/Kconfig | 1 +
 arch/riscv/Kconfig   | 1 +
 arch/s390/Kconfig    | 1 +
 arch/sh/Kconfig      | 1 +
 arch/sparc/Kconfig   | 1 +
 arch/x86/Kconfig     | 1 +
 mm/Kconfig           | 3 +++
 10 files changed, 12 insertions(+)

diff --git a/arch/arc/Kconfig b/arch/arc/Kconfig
index d76bf4a83740..8516e2b0239a 100644
--- a/arch/arc/Kconfig
+++ b/arch/arc/Kconfig
@@ -44,6 +44,7 @@ config ARC
 	select HAVE_GENERIC_DMA_COHERENT
 	select HAVE_KERNEL_GZIP
 	select HAVE_KERNEL_LZMA
+	select ARCH_HAS_PTE_SPECIAL
 
 config MIGHT_HAVE_PCI
 	bool
diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 1878083771af..a67973cb041c 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -7,6 +7,7 @@ config ARM
 	select ARCH_HAS_DEBUG_VIRTUAL if MMU
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
 	select ARCH_HAS_ELF_RANDOMIZE
+	select ARCH_HAS_PTE_SPECIAL if ARM_LPAE
 	select ARCH_HAS_SET_MEMORY
 	select ARCH_HAS_PHYS_TO_DMA
 	select ARCH_HAS_STRICT_KERNEL_RWX if MMU && !XIP_KERNEL
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 276e96ceaf27..7ae3c09921fb 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -17,6 +17,7 @@ config ARM64
 	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
 	select ARCH_HAS_KCOV
 	select ARCH_HAS_MEMBARRIER_SYNC_CORE
+	select ARCH_HAS_PTE_SPECIAL
 	select ARCH_HAS_SET_MEMORY
 	select ARCH_HAS_SG_CHAIN
 	select ARCH_HAS_STRICT_KERNEL_RWX
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index c32a181a7cbb..f7415fe25c07 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -141,6 +141,7 @@ config PPC
 	select ARCH_HAS_GCOV_PROFILE_ALL
 	select ARCH_HAS_PHYS_TO_DMA
 	select ARCH_HAS_PMEM_API                if PPC64
+	select ARCH_HAS_PTE_SPECIAL
 	select ARCH_HAS_MEMBARRIER_CALLBACKS
 	select ARCH_HAS_SCALED_CPUTIME		if VIRT_CPU_ACCOUNTING_NATIVE
 	select ARCH_HAS_SG_CHAIN
diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
index 148865de1692..b0a8404bf684 100644
--- a/arch/riscv/Kconfig
+++ b/arch/riscv/Kconfig
@@ -34,6 +34,7 @@ config RISCV
 	select THREAD_INFO_IN_TASK
 	select RISCV_TIMER
 	select GENERIC_IRQ_MULTI_HANDLER
+	select ARCH_HAS_PTE_SPECIAL
 
 config MMU
 	def_bool y
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 32a0d5b958bf..5f1f4997e7e9 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -72,6 +72,7 @@ config S390
 	select ARCH_HAS_GCOV_PROFILE_ALL
 	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
 	select ARCH_HAS_KCOV
+	select ARCH_HAS_PTE_SPECIAL
 	select ARCH_HAS_SET_MEMORY
 	select ARCH_HAS_SG_CHAIN
 	select ARCH_HAS_STRICT_KERNEL_RWX
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index 97fe29316476..a6c75b6806d2 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -50,6 +50,7 @@ config SUPERH
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_FUTEX_CMPXCHG if FUTEX
 	select HAVE_NMI
+	select ARCH_HAS_PTE_SPECIAL
 	help
 	  The SuperH is a RISC processor targeted for use in embedded systems
 	  and consumer electronics; it was also used in the Sega Dreamcast
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 8767e45f1b2b..6b5a4f05dcb2 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -86,6 +86,7 @@ config SPARC64
 	select ARCH_USE_QUEUED_SPINLOCKS
 	select GENERIC_TIME_VSYSCALL
 	select ARCH_CLOCKSOURCE_DATA
+	select ARCH_HAS_PTE_SPECIAL
 
 config ARCH_DEFCONFIG
 	string
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index bf4ddea48e61..3f5fb25486bf 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -56,6 +56,7 @@ config X86
 	select ARCH_HAS_KCOV			if X86_64
 	select ARCH_HAS_MEMBARRIER_SYNC_CORE
 	select ARCH_HAS_PMEM_API		if X86_64
+	select ARCH_HAS_PTE_SPECIAL
 	select ARCH_HAS_REFCOUNT
 	select ARCH_HAS_UACCESS_FLUSHCACHE	if X86_64
 	select ARCH_HAS_SET_MEMORY
diff --git a/mm/Kconfig b/mm/Kconfig
index bf9d6366bced..60ae67b83e62 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -757,3 +757,6 @@ config GUP_BENCHMARK
 	  performance of get_user_pages_fast().
 
 	  See tools/testing/selftests/vm/gup_benchmark.c
+
+config ARCH_HAS_PTE_SPECIAL
+	bool
-- 
2.7.4
