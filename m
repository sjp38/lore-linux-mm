Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9E4466B0008
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 21:32:19 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id r67-v6so13644069pfd.21
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 18:32:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n186-v6sor2681479pgn.61.2018.10.12.18.32.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Oct 2018 18:32:18 -0700 (PDT)
From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Subject: [PATCH 0/4] Add support for fast mremap
Date: Fri, 12 Oct 2018 18:31:56 -0700
Message-Id: <20181013013200.206928-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: kernel-team@android.com, "Joel Fernandes (Google)" <joel@joelfernandes.org>, akpm@linux-foundation.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, anton.ivanov@kot-begemot.co.uk, Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, dancol@google.com, Dave Hansen <dave.hansen@linux.intel.com>, "David S. Miller" <davem@davemloft.net>, elfring@users.sourceforge.net, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Guan Xuetao <gxt@pku.edu.cn>, Helge Deller <deller@gmx.de>, hughd@google.com, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jeff Dike <jdike@addtoit.com>, Jonas Bonn <jonas@southpole.se>, Julia Lawall <Julia.Lawall@lip6.fr>, kasan-dev@googlegroups.com, "Kirill A. Shutemov" <kirill@shutemov.name>, kvmarm@lists.cs.columbia.edu, Ley Foon Tan <lftan@altera.com>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, lokeshgidra@google.com, Max Filippov <jcmvbkbc@gmail.com>, mhocko@kernel.org, minchan@kernel.org, nios2-dev@lists.rocketboards.org, pantin@google.com, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Sam Creasey <sammy@sammy.net>, sparclinux@vger.kernel.org, Stafford Horne <shorne@gmail.com>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, "maintainer:X86 ARCHITECTURE 32-BIT AND 64-BIT" <x86@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>

Hi,
Here is the latest "fast mremap" series. The main change in this submission is
to enable the fast mremap optimization on a per-architecture basis to prevent
possible issues with architectures that may not behave well with such change.

x86: select HAVE_MOVE_PMD for faster mremap (v1)

arm64: select HAVE_MOVE_PMD for faster mremap (v1)

mm: speed up mremap by 500x on large regions (v2)
v1->v2: Added support for per-arch enablement (Kirill Shutemov)

treewide: remove unused address argument from pte_alloc functions (v2)
v1->v2: fix arch/um/ prototype which was missed in v1 (Anton Ivanov)
        update changelog with manual fixups for m68k and microblaze.

Joel Fernandes (Google) (4):
  treewide: remove unused address argument from pte_alloc functions (v2)
  mm: speed up mremap by 500x on large regions (v2)
  arm64: select HAVE_MOVE_PMD for faster mremap (v1)
  x86: select HAVE_MOVE_PMD for faster mremap (v1)

 arch/Kconfig                                 |  5 ++
 arch/alpha/include/asm/pgalloc.h             |  6 +-
 arch/arc/include/asm/pgalloc.h               |  5 +-
 arch/arm/include/asm/pgalloc.h               |  4 +-
 arch/arm64/Kconfig                           |  1 +
 arch/arm64/include/asm/pgalloc.h             |  4 +-
 arch/hexagon/include/asm/pgalloc.h           |  6 +-
 arch/ia64/include/asm/pgalloc.h              |  5 +-
 arch/m68k/include/asm/mcf_pgalloc.h          |  8 +--
 arch/m68k/include/asm/motorola_pgalloc.h     |  4 +-
 arch/m68k/include/asm/sun3_pgalloc.h         |  6 +-
 arch/microblaze/include/asm/pgalloc.h        | 19 +-----
 arch/microblaze/mm/pgtable.c                 |  3 +-
 arch/mips/include/asm/pgalloc.h              |  6 +-
 arch/nds32/include/asm/pgalloc.h             |  5 +-
 arch/nios2/include/asm/pgalloc.h             |  6 +-
 arch/openrisc/include/asm/pgalloc.h          |  5 +-
 arch/openrisc/mm/ioremap.c                   |  3 +-
 arch/parisc/include/asm/pgalloc.h            |  4 +-
 arch/powerpc/include/asm/book3s/32/pgalloc.h |  4 +-
 arch/powerpc/include/asm/book3s/64/pgalloc.h | 12 ++--
 arch/powerpc/include/asm/nohash/32/pgalloc.h |  4 +-
 arch/powerpc/include/asm/nohash/64/pgalloc.h |  6 +-
 arch/powerpc/mm/pgtable-book3s64.c           |  2 +-
 arch/powerpc/mm/pgtable_32.c                 |  4 +-
 arch/riscv/include/asm/pgalloc.h             |  6 +-
 arch/s390/include/asm/pgalloc.h              |  4 +-
 arch/sh/include/asm/pgalloc.h                |  6 +-
 arch/sparc/include/asm/pgalloc_32.h          |  5 +-
 arch/sparc/include/asm/pgalloc_64.h          |  6 +-
 arch/sparc/mm/init_64.c                      |  6 +-
 arch/sparc/mm/srmmu.c                        |  4 +-
 arch/um/include/asm/pgalloc.h                |  4 +-
 arch/um/kernel/mem.c                         |  4 +-
 arch/unicore32/include/asm/pgalloc.h         |  4 +-
 arch/x86/Kconfig                             |  1 +
 arch/x86/include/asm/pgalloc.h               |  4 +-
 arch/x86/mm/pgtable.c                        |  4 +-
 arch/xtensa/include/asm/pgalloc.h            |  8 +--
 include/linux/mm.h                           | 13 ++--
 mm/huge_memory.c                             |  8 +--
 mm/kasan/kasan_init.c                        |  2 +-
 mm/memory.c                                  | 17 +++--
 mm/migrate.c                                 |  2 +-
 mm/mremap.c                                  | 67 +++++++++++++++++++-
 mm/userfaultfd.c                             |  2 +-
 virt/kvm/arm/mmu.c                           |  2 +-
 47 files changed, 169 insertions(+), 147 deletions(-)

-- 
2.19.0.605.g01d371f741-goog
