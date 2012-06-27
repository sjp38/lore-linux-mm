Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 08CD56B0075
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 17:41:47 -0400 (EDT)
Message-Id: <20120627211540.459910855@chello.nl>
Date: Wed, 27 Jun 2012 23:15:40 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 00/20] Unify TLB gather implementations -v3
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

Its been a while since I last send this out, but here goes..

There's no arch left over, I finally got s390 converted too.
The series is compile tested on:

 arm, powerpc64, sparc64, sparc32, s390x, arm, ia64, xtensa

I lack a working toolchain for: sh, avr32
Simply wouldn't build:          mips, parisc 
 
---
 arch/Kconfig                         |   16 ++
 arch/alpha/include/asm/tlb.h         |    2 -
 arch/arm/Kconfig                     |    1 +
 arch/arm/include/asm/tlb.h           |  183 ++--------------------
 arch/avr32/Kconfig                   |    1 +
 arch/avr32/include/asm/tlb.h         |   11 --
 arch/blackfin/include/asm/tlb.h      |    6 -
 arch/c6x/include/asm/tlb.h           |    2 -
 arch/cris/include/asm/tlb.h          |    1 -
 arch/frv/include/asm/tlb.h           |    5 -
 arch/h8300/include/asm/tlb.h         |   13 --
 arch/hexagon/include/asm/tlb.h       |    5 -
 arch/ia64/Kconfig                    |    1 +
 arch/ia64/include/asm/tlb.h          |  233 +---------------------------
 arch/ia64/include/asm/tlbflush.h     |   25 +++
 arch/ia64/mm/tlb.c                   |   24 +++-
 arch/m32r/include/asm/tlb.h          |    6 -
 arch/m68k/include/asm/tlb.h          |    6 -
 arch/microblaze/include/asm/tlb.h    |    2 -
 arch/mips/Kconfig                    |    1 +
 arch/mips/include/asm/tlb.h          |   15 --
 arch/mn10300/include/asm/tlb.h       |    5 -
 arch/openrisc/include/asm/tlb.h      |    1 -
 arch/parisc/Kconfig                  |    1 +
 arch/parisc/include/asm/tlb.h        |   15 --
 arch/powerpc/include/asm/tlb.h       |    2 -
 arch/powerpc/mm/hugetlbpage.c        |    4 +-
 arch/powerpc/mm/tlb_hash32.c         |   15 --
 arch/powerpc/mm/tlb_hash64.c         |   14 --
 arch/powerpc/mm/tlb_nohash.c         |    5 -
 arch/s390/Kconfig                    |    1 +
 arch/s390/include/asm/pgalloc.h      |    3 +
 arch/s390/include/asm/pgtable.h      |    1 +
 arch/s390/include/asm/tlb.h          |   71 ++-------
 arch/s390/mm/pgtable.c               |   63 +-------
 arch/score/include/asm/tlb.h         |    1 -
 arch/sh/Kconfig                      |    1 +
 arch/sh/include/asm/tlb.h            |   99 +-----------
 arch/sparc/Kconfig                   |    1 +
 arch/sparc/Makefile                  |    1 +
 arch/sparc/include/asm/tlb_32.h      |   15 --
 arch/sparc/include/asm/tlb_64.h      |    1 -
 arch/sparc/include/asm/tlbflush_64.h |   11 ++
 arch/tile/include/asm/tlb.h          |    1 -
 arch/um/Kconfig.common               |    1 +
 arch/um/include/asm/tlb.h            |  111 +-------------
 arch/um/kernel/tlb.c                 |   13 --
 arch/unicore32/include/asm/tlb.h     |    1 -
 arch/x86/include/asm/tlb.h           |    2 +-
 arch/x86/mm/pgtable.c                |    6 +-
 arch/xtensa/Kconfig                  |    1 +
 arch/xtensa/include/asm/tlb.h        |   24 ---
 arch/xtensa/mm/tlb.c                 |    2 +-
 include/asm-generic/4level-fixup.h   |    2 +-
 include/asm-generic/tlb.h            |  284 +++++++++++++++++++++++++++++-----
 mm/memory.c                          |   54 +++++--
 56 files changed, 415 insertions(+), 977 deletions(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
