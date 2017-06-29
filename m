Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1B8F46B02F3
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 11:53:31 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id p187so21964782oif.6
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 08:53:31 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n126si3286300oih.16.2017.06.29.08.53.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 08:53:29 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v4 00/10] PCID and improved laziness
Date: Thu, 29 Jun 2017 08:53:12 -0700
Message-Id: <cover.1498751203.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>

*** Ingo, even if this misses 4.13, please apply the first patch before
*** the merge window.

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

This is still missing a final comment-only patch to add overall
documentation for the whole thing, but I didn't want to block sending
the maybe-hopefully-final code on that.

This is based on tip:x86/mm.  The branch is here if you want to play:
https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/log/?h=x86/pcid

In general, performance seems to exceed my expectations.  Here are
some performance numbers copy-and-pasted from the changelogs for
"Rework lazy TLB mode and TLB freshness" and "Try to preserve old
TLB entries using PCID":

MADV_DONTNEED; touch the page; switch CPUs using sched_setaffinity.  In
an unpatched kernel, MADV_DONTNEED will send an IPI to the previous CPU.
This is intended to be a nearly worst-case test.
patched:         13.4Aus
unpatched:       21.6Aus

Vitaly's pthread_mmap microbenchmark with 8 threads (on four cores),
nrounds = 100, 256M data
patched:         1.1 seconds or so
unpatched:       1.9 seconds or so

ping-pong between two mms on the same CPU using eventfd:
  patched:         1.22Aus
  patched, nopcid: 1.33Aus
  unpatched:       1.34Aus

Same ping-pong, but now touch 512 pages (all zero-page to minimize
cache misses) each iteration.  dTLB misses are measured by
dtlb_load_misses.miss_causes_a_walk:
  patched:         1.8Aus  11M  dTLB misses
  patched, nopcid: 6.2Aus, 207M dTLB misses
  unpatched:       6.1Aus, 190M dTLB misses

MADV_DONTNEED; touch the page; switch CPUs using sched_setaffinity.  In
an unpatched kernel, MADV_DONTNEED will send an IPI to the previous CPU.
This is intended to be a nearly worst-case test.
  patched:         13.4Aus
  unpatched:       21.6Aus

Changes from v3:
 - Lots more acks.
 - Move comment deletion to the beginning.
 - Misc cleanups from lots of reviewers.

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

Andy Lutomirski (10):
  x86/mm: Don't reenter flush_tlb_func_common()
  x86/mm: Delete a big outdated comment about TLB flushing
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
 arch/x86/include/asm/mmu_context.h              |  15 +-
 arch/x86/include/asm/processor-flags.h          |   2 +
 arch/x86/include/asm/tlbflush.h                 |  87 +++++-
 arch/x86/kernel/cpu/bugs.c                      |   8 +
 arch/x86/kernel/cpu/common.c                    |  40 +++
 arch/x86/mm/init.c                              |   2 +-
 arch/x86/mm/tlb.c                               | 382 ++++++++++++++++--------
 arch/x86/xen/enlighten_pv.c                     |   6 +
 arch/x86/xen/mmu_pv.c                           |   5 +-
 drivers/acpi/processor_idle.c                   |   2 -
 drivers/idle/intel_idle.c                       |   9 +-
 16 files changed, 446 insertions(+), 147 deletions(-)

-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
