Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C3426B02B4
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 01:22:21 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id 63so60378918otc.5
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 22:22:21 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c128si4436731oig.256.2017.06.20.22.22.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 22:22:20 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v3 00/11] PCID and improved laziness
Date: Tue, 20 Jun 2017 22:22:06 -0700
Message-Id: <cover.1498022414.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>

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

This is based on tip:x86/mm.  The branch is here if you want to play:
https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/log/?h=x86/pcid

Changes from v2:
 - Add some Acks
 - Move the reentrancy issue to the beginning.
   (I also sent the same patch as a standalone fix -- it's just in here
    so that this series applies to x86/mm.)
 - Fix some comments.

Changes from RFC:
 - flush_tlb_func_common() no longer gets reentered (Nadav)
 - Fix ASID corruption on unlazying (kbuild bot)
 - Move Xen init to the right place
 - Misc cleanups

Andy Lutomirski (11):
  x86/mm: Don't reenter flush_tlb_func_common()
  x86/ldt: Simplify LDT switching logic
  x86/mm: Remove reset_lazy_tlbstate()
  x86/mm: Give each mm TLB flush generation a unique ID
  x86/mm: Track the TLB's tlb_gen and update the flushing algorithm
  x86/mm: Rework lazy TLB mode and TLB freshness tracking
  x86/mm: Stop calling leave_mm() in idle code
  x86/mm: Disable PCID on 32-bit kernels
  x86/mm: Add nopcid to turn off PCID
  x86/mm: Enable CR4.PCIDE on supported systems
  x86/mm: Try to preserve old TLB entries using PCID

 Documentation/admin-guide/kernel-parameters.txt |   2 +
 arch/ia64/include/asm/acpi.h                    |   2 -
 arch/x86/include/asm/acpi.h                     |   2 -
 arch/x86/include/asm/disabled-features.h        |   4 +-
 arch/x86/include/asm/mmu.h                      |  25 +-
 arch/x86/include/asm/mmu_context.h              |  40 ++-
 arch/x86/include/asm/processor-flags.h          |   2 +
 arch/x86/include/asm/tlbflush.h                 |  89 +++++-
 arch/x86/kernel/cpu/bugs.c                      |   8 +
 arch/x86/kernel/cpu/common.c                    |  33 +++
 arch/x86/kernel/smpboot.c                       |   1 -
 arch/x86/mm/init.c                              |   2 +-
 arch/x86/mm/tlb.c                               | 368 +++++++++++++++---------
 arch/x86/xen/enlighten_pv.c                     |   6 +
 arch/x86/xen/mmu_pv.c                           |   3 +-
 drivers/acpi/processor_idle.c                   |   2 -
 drivers/idle/intel_idle.c                       |   9 +-
 17 files changed, 430 insertions(+), 168 deletions(-)

-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
