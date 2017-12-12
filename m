Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5A4CC6B0069
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 12:34:47 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id f132so36690wmf.6
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 09:34:47 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id h72si54469wme.34.2017.12.12.09.34.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 12 Dec 2017 09:34:45 -0800 (PST)
Message-Id: <20171212173221.496222173@linutronix.de>
Date: Tue, 12 Dec 2017 18:32:21 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 00/16] x86/ldt: Use a VMA based read only mapping
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org

Peter and myself spent quite some time to figure out how to make CPUs cope
with a RO mapped LDT.

While the initial trick of writing the ACCESS bit in a special fault
handler covers most cases, the tricky problem of CS/SS in return to user
space (IRET ...) was giving us quite some headache.

Peter finally found a way to do so. Touching the CS/SS selectors with LAR
on the way out to user space makes it work w/o trouble.

Contrary to the approach Andy was taking with storing the LDT in a special
map area, the following series uses a special mapping which is mapped
without the user bit and read only. This just ties the LDT to the process
which is the most natural way to do it, removes the requirement for special
pagetable code and works independent of pagetable isolation.

This was tested on quite a range of Intel and AMD machines, but the test
coverage on 32bit is quite meager. I'll resurrect a few dust bricks
tomorrow.

The patch series also includes an updated version of the: do not inherit
LDT on exec changes.

There are some extensions to the VMA code, which need scrunity of the mm
folks.

Thanks,

	tglx
---
 arch/powerpc/include/asm/mmu_context.h     |    5 
 arch/powerpc/platforms/Kconfig.cputype     |    1 
 arch/s390/Kconfig                          |    1 
 arch/x86/entry/common.c                    |    8 
 arch/x86/include/asm/desc.h                |    2 
 arch/x86/include/asm/mmu.h                 |    7 
 arch/x86/include/asm/thread_info.h         |    4 
 arch/x86/include/uapi/asm/mman.h           |    4 
 arch/x86/kernel/cpu/common.c               |    4 
 arch/x86/kernel/ldt.c                      |  573 ++++++++++++++++++++++-------
 arch/x86/mm/fault.c                        |   19 
 arch/x86/mm/tlb.c                          |    2 
 arch/x86/power/cpu.c                       |    2 
 b/arch/um/include/asm/mmu_context.h        |    3 
 b/arch/unicore32/include/asm/mmu_context.h |    5 
 b/arch/x86/include/asm/mmu_context.h       |   93 +++-
 b/include/linux/mman.h                     |    4 
 include/asm-generic/mm_hooks.h             |    5 
 include/linux/mm.h                         |   21 -
 include/linux/mm_types.h                   |    3 
 kernel/fork.c                              |    3 
 mm/internal.h                              |    2 
 mm/mmap.c                                  |   16 
 tools/testing/selftests/x86/ldt_gdt.c      |   83 +++-
 24 files changed, 673 insertions(+), 197 deletions(-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
