Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id F0DB56B0010
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 12:34:38 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r134-v6so4166156pgr.19
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 09:34:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l6-v6sor1788386pfl.6.2018.10.12.09.34.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Oct 2018 09:34:37 -0700 (PDT)
Date: Fri, 12 Oct 2018 09:34:33 -0700
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH v2 1/2] treewide: remove unused address argument from
 pte_alloc functions
Message-ID: <20181012163433.GA223066@joelaf.mtv.corp.google.com>
References: <20181012013756.11285-1-joel@joelfernandes.org>
 <594fc952-5e87-3162-b2f9-963479d16eb3@kot-begemot.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <594fc952-5e87-3162-b2f9-963479d16eb3@kot-begemot.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Ivanov <anton.ivanov@kot-begemot.co.uk>
Cc: linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, lokeshgidra@google.com, linux-riscv@lists.infradead.org, elfring@users.sourceforge.net, Jonas Bonn <jonas@southpole.se>, linux-s390@vger.kernel.org, dancol@google.com, Yoshinori Sato <ysato@users.sourceforge.jp>, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-hexagon@vger.kernel.org, Helge Deller <deller@gmx.de>, "maintainer:X86 ARCHITECTURE 32-BIT AND 64-BIT" <x86@kernel.org>, hughd@google.com, "James E.J. Bottomley" <jejb@parisc-linux.org>, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, Ingo Molnar <mingo@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-snps-arc@lists.infradead.org, kernel-team@android.com, Sam Creasey <sammy@sammy.net>, Fenghua Yu <fenghua.yu@intel.com>, Jeff Dike <jdike@addtoit.com>, linux-um@lists.infradead.org, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Julia Lawall <Julia.Lawall@lip6.fr>, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, nios2-dev@lists.rocketboards.org, kirill@shutemov.name, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Chris Zankel <chris@zankel.net>, Tony Luck <tony.luck@intel.com>, Richard Weinberger <richard@nod.at>, linux-parisc@vger.kernel.org, pantin@google.com, Max Filippov <jcmvbkbc@gmail.com>, minchan@kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-alpha@vger.kernel.org, Ley Foon Tan <lftan@altera.com>, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On Fri, Oct 12, 2018 at 02:56:19PM +0100, Anton Ivanov wrote:
> 
> On 10/12/18 2:37 AM, Joel Fernandes (Google) wrote:
> > This series speeds up mremap(2) syscall by copying page tables at the
> > PMD level even for non-THP systems. There is concern that the extra
> > 'address' argument that mremap passes to pte_alloc may do something
> > subtle architecture related in the future, that makes the scheme not
> > work.  Also we find that there is no point in passing the 'address' to
> > pte_alloc since its unused.
> > 
> > This patch therefore removes this argument tree-wide resulting in a nice
> > negative diff as well. Also ensuring along the way that the architecture
> > does not do anything funky with 'address' argument that goes unnoticed.
> > 
> > Build and boot tested on x86-64. Build tested on arm64.
> > 
> > The changes were obtained by applying the following Coccinelle script.
> > The pte_fragment_alloc was manually fixed up since it was only 2
> > occurences and could not be easily generalized (and thanks Julia for
> > answering all my silly and not-silly Coccinelle questions!).
> > 
> > // Options: --include-headers --no-includes
> > // Note: I split the 'identifier fn' line, so if you are manually
> > // running it, please unsplit it so it runs for you.
> > 
> > virtual patch
> > 
> > @pte_alloc_func_def depends on patch exists@
> > identifier E2;
> > identifier fn =~
> > "^(__pte_alloc|pte_alloc_one|pte_alloc|__pte_alloc_kernel|pte_alloc_one_kernel)$";
> > type T2;
> > @@
> > 
> >   fn(...
> > - , T2 E2
> >   )
> >   { ... }
> > 
> > @pte_alloc_func_proto depends on patch exists@
> > identifier E1, E2, E4;
> > type T1, T2, T3, T4;
> > identifier fn =~
> > "^(__pte_alloc|pte_alloc_one|pte_alloc|__pte_alloc_kernel|pte_alloc_one_kernel)$";
> > @@
> > 
> > (
> > - T3 fn(T1 E1, T2 E2);
> > + T3 fn(T1 E1);
> > |
> > - T3 fn(T1 E1, T2 E2, T4 E4);
> > + T3 fn(T1 E1, T2 E2);
> > )
> > 
> > @pte_alloc_func_call depends on patch exists@
> > expression E2;
> > identifier fn =~
> > "^(__pte_alloc|pte_alloc_one|pte_alloc|__pte_alloc_kernel|pte_alloc_one_kernel)$";
> > @@
> > 
> >   fn(...
> > -,  E2
> >   )
> > 
> > @pte_alloc_macro depends on patch exists@
> > identifier fn =~
> > "^(__pte_alloc|pte_alloc_one|pte_alloc|__pte_alloc_kernel|pte_alloc_one_kernel)$";
> > identifier a, b, c;
> > expression e;
> > position p;
> > @@
> > 
> > (
> > - #define fn(a, b, c)@p e
> > + #define fn(a, b) e
> > |
> > - #define fn(a, b)@p e
> > + #define fn(a) e
> > )
> > 
> > Suggested-by: Kirill A. Shutemov <kirill@shutemov.name>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Julia Lawall <Julia.Lawall@lip6.fr>
> > Cc: elfring@users.sourceforge.net
> > Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
> > ---
> >   arch/alpha/include/asm/pgalloc.h             |  6 +++---
> >   arch/arc/include/asm/pgalloc.h               |  5 ++---
> >   arch/arm/include/asm/pgalloc.h               |  4 ++--
> >   arch/arm64/include/asm/pgalloc.h             |  4 ++--
> >   arch/hexagon/include/asm/pgalloc.h           |  6 ++----
> >   arch/ia64/include/asm/pgalloc.h              |  5 ++---
> >   arch/m68k/include/asm/mcf_pgalloc.h          |  8 ++------
> >   arch/m68k/include/asm/motorola_pgalloc.h     |  4 ++--
> >   arch/m68k/include/asm/sun3_pgalloc.h         |  6 ++----
> >   arch/microblaze/include/asm/pgalloc.h        | 19 ++-----------------
> >   arch/microblaze/mm/pgtable.c                 |  3 +--
> >   arch/mips/include/asm/pgalloc.h              |  6 ++----
> >   arch/nds32/include/asm/pgalloc.h             |  5 ++---
> >   arch/nios2/include/asm/pgalloc.h             |  6 ++----
> >   arch/openrisc/include/asm/pgalloc.h          |  5 ++---
> >   arch/openrisc/mm/ioremap.c                   |  3 +--
> >   arch/parisc/include/asm/pgalloc.h            |  4 ++--
> >   arch/powerpc/include/asm/book3s/32/pgalloc.h |  4 ++--
> >   arch/powerpc/include/asm/book3s/64/pgalloc.h | 12 +++++-------
> >   arch/powerpc/include/asm/nohash/32/pgalloc.h |  4 ++--
> >   arch/powerpc/include/asm/nohash/64/pgalloc.h |  6 ++----
> >   arch/powerpc/mm/pgtable-book3s64.c           |  2 +-
> >   arch/powerpc/mm/pgtable_32.c                 |  4 ++--
> >   arch/riscv/include/asm/pgalloc.h             |  6 ++----
> >   arch/s390/include/asm/pgalloc.h              |  4 ++--
> >   arch/sh/include/asm/pgalloc.h                |  6 ++----
> >   arch/sparc/include/asm/pgalloc_32.h          |  5 ++---
> >   arch/sparc/include/asm/pgalloc_64.h          |  6 ++----
> >   arch/sparc/mm/init_64.c                      |  6 ++----
> >   arch/sparc/mm/srmmu.c                        |  4 ++--
> >   arch/um/kernel/mem.c                         |  4 ++--
> 
> There is a declaration of pte_alloc_one in arch/um/include/asm/pgalloc.h
> 
> This patch missed it.

Ah, true. Thanks. Couldn't test every arch obviously. The reason this was
missed is the script could not find matches with prototypes without named
parameters:

extern pgtable_t pte_alloc_one(struct mm_struct *, unsigned long);

I wrote something like this as below but it failed to compile, Julia any
suggestions on how to express this?

@pte_alloc_func_proto depends on patch exists@
type T1, T2, T3, T4;
identifier fn =~
"^(__pte_alloc|pte_alloc_one|pte_alloc|__pte_alloc_kernel|pte_alloc_one_kernel)$";
@@

(
- T3 fn(T1, T2);
+ T3 fn(T1);
|
- T3 fn(T1, T2, T4);
+ T3 fn(T1, T2);
)

thanks,

 - Joel
