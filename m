Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 911526B025F
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:15:37 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id yy13so196753655pab.3
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:15:37 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id f7si7938955pfd.188.2016.01.08.15.15.36
        for <linux-mm@kvack.org>;
        Fri, 08 Jan 2016 15:15:36 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 00/13] x86/mm: PCID and INVPCID
Date: Fri,  8 Jan 2016 15:15:18 -0800
Message-Id: <cover.1452294700.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>

Here's my PCID and INVPCID work-in-progress.  It seems to work well
enough to play with it.  (That is, I'm not aware of anything wrong
with it, although it may eat your data.)

PCID and INVPCID use are orthogonal here.  INVPCID is a
straightforward speedup for global TLB flushes.  Other than that, I
don't use INVPCID at all, since it seems slower than just
manipulating CR3 carefully, at least on my Skylake laptop.

Please play around and suggest (and run?) good benchmarks.  It seems
to save around 100ns on cross-process context switches for me.
Unfortunately, we suck at context switches in general, so this is,
at best, a little over a 10% speedup.  Most of the time is spent in
the scheduler, not in arch code.

Andy Lutomirski (13):
  x86/paravirt: Turn KASAN off for parvirt.o
  x86/mm: Add INVPCID helpers
  x86/mm: Add a noinvpcid option to turn off INVPCID
  x86/mm: If INVPCID is available, use it to flush global mappings
  x86/mm: Add barriers and document switch_mm-vs-flush synchronization
  x86/mm: Disable PCID on 32-bit kernels
  x86/mm: Add nopcid to turn off PCID
  x86/mm: Teach CR3 readers about PCID
  x86/mm: Disable interrupts when flushing the TLB using CR3
  x86/mm: Factor out remote TLB flushing
  x86/mm: Build arch/x86/mm/tlb.c even on !SMP
  x86/mm: Uninline switch_mm
  x86/mm: Try to preserve old TLB entries using PCID

 Documentation/kernel-parameters.txt      |   4 +
 arch/x86/include/asm/disabled-features.h |   4 +-
 arch/x86/include/asm/mmu.h               |   7 +-
 arch/x86/include/asm/mmu_context.h       |  62 +-----
 arch/x86/include/asm/tlbflush.h          |  86 ++++++++
 arch/x86/kernel/Makefile                 |   1 +
 arch/x86/kernel/cpu/bugs.c               |   6 +
 arch/x86/kernel/cpu/common.c             |  38 ++++
 arch/x86/kernel/head64.c                 |   3 +-
 arch/x86/kernel/ldt.c                    |   2 +
 arch/x86/kernel/process_64.c             |   2 +
 arch/x86/mm/Makefile                     |   3 +-
 arch/x86/mm/fault.c                      |   8 +-
 arch/x86/mm/tlb.c                        | 324 +++++++++++++++++++++++++++++--
 14 files changed, 467 insertions(+), 83 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
