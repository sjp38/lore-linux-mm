Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2455D6B0006
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 04:03:59 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id h6so652120qkj.11
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 01:03:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p14si250696qtj.447.2018.04.11.01.03.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Apr 2018 01:03:57 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3B83i4p010590
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 04:03:56 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h9agy9kb1-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 04:03:55 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 11 Apr 2018 09:03:48 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v3 0/2] move __HAVE_ARCH_PTE_SPECIAL in Kconfig
Date: Wed, 11 Apr 2018 10:03:34 +0200
Message-Id: <1523433816-14460-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>, mhocko@kernel.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Vineet Gupta <vgupta@synopsys.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, David Rientjes <rientjes@google.com>, Robin Murphy <robin.murphy@arm.com>

The per architecture __HAVE_ARCH_PTE_SPECIAL is defined statically in the
per architecture header files. This doesn't allow to make other
configuration dependent on it.

The first patch of this series is replacing __HAVE_ARCH_PTE_SPECIAL by
CONFIG_ARCH_HAS_PTE_SPECIAL defined into the Kconfig files,
setting it automatically when architectures was already setting it in
header file.

The second patch is removing the odd define HAVE_PTE_SPECIAL which is a
duplicate of CONFIG_ARCH_HAS_PTE_SPECIAL.

There is no functional change introduced by this series.

--
Changes since v2:
 * remove __HAVE_ARCH_PTE_SPECIAL in arch/riscv/include/asm/pgtable-bits.h
 * use IS_ENABLED() instead of #ifdef blocks in patch 2

Laurent Dufour (2):
  mm: introduce ARCH_HAS_PTE_SPECIAL
  mm: remove odd HAVE_PTE_SPECIAL

 .../features/vm/pte_special/arch-support.txt          |  2 +-
 arch/arc/Kconfig                                      |  1 +
 arch/arc/include/asm/pgtable.h                        |  2 --
 arch/arm/Kconfig                                      |  1 +
 arch/arm/include/asm/pgtable-3level.h                 |  1 -
 arch/arm64/Kconfig                                    |  1 +
 arch/arm64/include/asm/pgtable.h                      |  2 --
 arch/powerpc/Kconfig                                  |  1 +
 arch/powerpc/include/asm/book3s/64/pgtable.h          |  3 ---
 arch/powerpc/include/asm/pte-common.h                 |  3 ---
 arch/riscv/Kconfig                                    |  1 +
 arch/riscv/include/asm/pgtable-bits.h                 |  3 ---
 arch/s390/Kconfig                                     |  1 +
 arch/s390/include/asm/pgtable.h                       |  1 -
 arch/sh/Kconfig                                       |  1 +
 arch/sh/include/asm/pgtable.h                         |  2 --
 arch/sparc/Kconfig                                    |  1 +
 arch/sparc/include/asm/pgtable_64.h                   |  3 ---
 arch/x86/Kconfig                                      |  1 +
 arch/x86/include/asm/pgtable_types.h                  |  1 -
 include/linux/pfn_t.h                                 |  4 ++--
 mm/Kconfig                                            |  3 +++
 mm/gup.c                                              |  4 ++--
 mm/memory.c                                           | 19 ++++++++-----------
 24 files changed, 25 insertions(+), 37 deletions(-)

-- 
2.7.4
