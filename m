Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 778226B0008
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 10:28:53 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z7-v6so26669263wrg.11
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 07:28:53 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id t26si2256349edf.182.2018.04.26.07.28.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 07:28:51 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 0/9] Enable THP migration for all possible architectures
Date: Thu, 26 Apr 2018 10:27:55 -0400
Message-Id: <20180426142804.180152-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Vineet Gupta <vgupta@synopsys.com>, linux-snps-arc@lists.infradead.org, Russell King <linux@armlinux.org.uk>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steve Capper <steve.capper@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Dan Williams <dan.j.williams@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michal Hocko <mhocko@suse.com>, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ram Pai <linuxram@us.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linuxppc-dev@lists.ozlabs.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Janosch Frank <frankja@linux.vnet.ibm.com>, linux-s390@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, "Huang, Ying" <ying.huang@intel.com>

From: Zi Yan <zi.yan@cs.rutgers.edu>

Hi all,

THP migration is only enabled on x86_64 with a special
ARCH_ENABLE_THP_MIGRATION macro. This patchset enables THP migration for
all architectures that uses transparent hugepage, so that special macro can
be dropped. Instead, THP migration is enabled/disabled via
/sys/kernel/mm/transparent_hugepage/enable_thp_migration.

I grepped for TRANSPARENT_HUGEPAGE in arch folder and got 9 architectures that
are supporting transparent hugepage. I mechanically add __pmd_to_swp_entry() and
__swp_entry_to_pmd() based on existing __pte_to_swp_entry() and
__swp_entry_to_pte() for all these architectures, except tile which is going to
be dropped.

I have successfully compiled all these architectures, but have NOT tested them
due to lack of real hardware. I appreciate your help, if the maintainers of
these architectures can do a quick test with the code from
https://github.com/x-y-z/thp-migration-bench . Please apply patch 9 as well
to enable THP migration.

By enabling THP migration, migrating a 2MB THP on x86_64 machines takes only 1/3
time of migrating equivalent 512 4KB pages.

Hi Naoya, I also add soft dirty support for powerpc and s390. It would be great
if you can take a look at patch 6 & 7.

Feel free to give comments. Thanks.

Cc: linux-mm@kvack.org
Cc: Vineet Gupta <vgupta@synopsys.com>
Cc: linux-snps-arc@lists.infradead.org
Cc: Russell King <linux@armlinux.org.uk>
Cc: Christoffer Dall <christoffer.dall@linaro.org>
Cc: Marc Zyngier <marc.zyngier@arm.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Steve Capper <steve.capper@arm.com>
Cc: Kristina Martsenko <kristina.martsenko@arm.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: x86@kernel.org
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: James Hogan <jhogan@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: linux-mips@linux-mips.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Ram Pai <linuxram@us.ibm.com>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Janosch Frank <frankja@linux.vnet.ibm.com>
Cc: linux-s390@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>
Cc: sparclinux@vger.kernel.org
Cc: "Huang, Ying" <ying.huang@intel.com>


Zi Yan (9):
  arc: mm: migrate: add pmd swap entry to support thp migration.
  arm: mm: migrate: add pmd swap entry to support thp migration.
  arm64: mm: migrate: add pmd swap entry to support thp migration.
  i386: mm: migrate: add pmd swap entry to support thp migration.
  mips: mm: migrate: add pmd swap entry to support thp migration.
  powerpc: mm: migrate: add pmd swap entry to support thp migration.
  s390: mm: migrate: add pmd swap entry to support thp migration.
  sparc: mm: migrate: add pmd swap entry to support thp migration.
  mm: migrate: enable thp migration for all possible architectures.

 arch/arc/include/asm/pgtable.h               |  2 ++
 arch/arm/include/asm/pgtable.h               |  2 ++
 arch/arm64/include/asm/pgtable.h             |  2 ++
 arch/mips/include/asm/pgtable-64.h           |  2 ++
 arch/powerpc/include/asm/book3s/32/pgtable.h |  2 ++
 arch/powerpc/include/asm/book3s/64/pgtable.h | 17 ++++++++++++
 arch/powerpc/include/asm/nohash/32/pgtable.h |  2 ++
 arch/powerpc/include/asm/nohash/64/pgtable.h |  2 ++
 arch/s390/include/asm/pgtable.h              |  5 ++++
 arch/sparc/include/asm/pgtable_32.h          |  2 ++
 arch/sparc/include/asm/pgtable_64.h          |  2 ++
 arch/x86/Kconfig                             |  4 ---
 arch/x86/include/asm/pgtable-2level.h        |  2 ++
 arch/x86/include/asm/pgtable-3level.h        |  2 ++
 arch/x86/include/asm/pgtable.h               |  2 --
 fs/proc/task_mmu.c                           |  2 --
 include/asm-generic/pgtable.h                | 21 ++-------------
 include/linux/huge_mm.h                      |  9 +++----
 include/linux/swapops.h                      |  4 +--
 mm/Kconfig                                   |  3 ---
 mm/huge_memory.c                             | 27 +++++++++++++-------
 mm/migrate.c                                 |  6 ++---
 mm/rmap.c                                    |  5 ++--
 23 files changed, 73 insertions(+), 54 deletions(-)

-- 
2.17.0
