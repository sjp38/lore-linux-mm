Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id B63966B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 18:37:05 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id e1so96267953oig.12
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 15:37:05 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 62si10096175oto.331.2017.06.05.15.37.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 15:37:04 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 00/11] PCID and improved laziness
Date: Mon,  5 Jun 2017 15:36:24 -0700
Message-Id: <cover.1496701658.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Andy Lutomirski <luto@kernel.org>

I think that this is in good enough shape to review.  I'm hoping to get
it in for 4.13.

There are three performance benefits here:

1. TLB flushing is slow.  (I.e. the flush itself takes a while.)
   This avoids many of them when switching tasks by using PCID.  In
   a stupid little benchmark I did, it saves about 100ns on my laptop
   per context switch.  I'll try to improve that benchmark.

2. Mms that have been used recently on a given CPU might get to keep
   their TLB entries alive across process switches with this patch
   set.  TLB fills are pretty fast on modern CPUs, but they're even
   faster when they don't happen.

3. Lazy TLB is way better.  We used to do two stupid things when we
   ran kernel threads: we'd send IPIs to flush user contexts on their
   CPUs and then we'd write to CR3 for no particular reason as an excuse
   to stop further IPIs.  With this patch, we do neither.

This will, in general, perform suboptimally if paravirt TLB flushing
is in use (currently just Xen, I think, but Hyper-V is in the works).
The code is structured so we could fix it in one of two ways: we
could take a spinlock when touching the percpu state so we can update
it remotely after a paravirt flush, or we could be more careful about
our exactly how we access the state and use cmpxchg16b to do atomic
remote updates.  (On SMP systems without cmpxchg16b, we'd just skip
the optimization entirely.)

This code is running on my laptop right now and it hasn't blown up
yet, so it's obviously entirely bug-free. :)

What do you all think?

This is based on tip:x86/mm.  The branch is here if you want to play:
https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/log/?h=x86/pcid

Andy Lutomirski (11):
  x86/ldt: Simplify LDT switching logic
  x86/mm: Remove reset_lazy_tlbstate()
  x86/mm: Give each mm TLB flush generation a unique ID
  x86/mm: Track the TLB's tlb_gen and update the flushing algorithm
  x86/mm: Rework lazy TLB mode and TLB freshness tracking
  x86/mm: Stop calling leave_mm() in idle code
  x86/mm: Disable PCID on 32-bit kernels
  x86/mm: Add nopcid to turn off PCID
  x86/mm: Teach CR3 readers about PCID
  x86/mm: Enable CR4.PCIDE on supported systems
  x86/mm: Try to preserve old TLB entries using PCID

 Documentation/admin-guide/kernel-parameters.txt |   2 +
 arch/ia64/include/asm/acpi.h                    |   2 -
 arch/x86/boot/compressed/pagetable.c            |   2 +-
 arch/x86/include/asm/acpi.h                     |   2 -
 arch/x86/include/asm/disabled-features.h        |   4 +-
 arch/x86/include/asm/efi.h                      |   2 +-
 arch/x86/include/asm/mmu.h                      |  25 +-
 arch/x86/include/asm/mmu_context.h              |  41 ++-
 arch/x86/include/asm/paravirt.h                 |   2 +-
 arch/x86/include/asm/processor-flags.h          |  32 +++
 arch/x86/include/asm/processor.h                |   8 +
 arch/x86/include/asm/special_insns.h            |  10 +-
 arch/x86/include/asm/tlbflush.h                 |  91 +++++-
 arch/x86/kernel/cpu/bugs.c                      |   8 +
 arch/x86/kernel/cpu/common.c                    |  33 +++
 arch/x86/kernel/head64.c                        |   3 +-
 arch/x86/kernel/paravirt.c                      |   2 +-
 arch/x86/kernel/process_32.c                    |   2 +-
 arch/x86/kernel/process_64.c                    |   2 +-
 arch/x86/kernel/smpboot.c                       |   1 -
 arch/x86/kvm/vmx.c                              |   2 +-
 arch/x86/mm/fault.c                             |  10 +-
 arch/x86/mm/init.c                              |   2 +-
 arch/x86/mm/ioremap.c                           |   2 +-
 arch/x86/mm/tlb.c                               | 351 +++++++++++++++---------
 arch/x86/platform/efi/efi_64.c                  |   4 +-
 arch/x86/platform/olpc/olpc-xo1-pm.c            |   2 +-
 arch/x86/power/cpu.c                            |   2 +-
 arch/x86/power/hibernate_64.c                   |   3 +-
 arch/x86/xen/mmu_pv.c                           |   6 +-
 arch/x86/xen/setup.c                            |   6 +
 drivers/acpi/processor_idle.c                   |   2 -
 drivers/idle/intel_idle.c                       |   8 +-
 33 files changed, 483 insertions(+), 191 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
