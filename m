Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5620C6B0292
	for <linux-mm@kvack.org>; Mon, 22 May 2017 18:30:18 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id d142so175637706oib.7
        for <linux-mm@kvack.org>; Mon, 22 May 2017 15:30:18 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q94si52324ota.270.2017.05.22.15.30.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 15:30:17 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 00/11] x86 TLB flush cleanups, moving toward PCID support
Date: Mon, 22 May 2017 15:30:00 -0700
Message-Id: <cover.1495492063.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Andy Lutomirski <luto@kernel.org>

As I've been working on polishing my PCID code, a major problem I've
encountered is that there are too many x86 TLB flushing code paths and
that they have too many inconsequential differences.  The result was
that earlier versions of the PCID code were a colossal mess and very
difficult to understand.

This series goes a long way toward cleaning up the mess.  With all the
patches applied, there is a single function that contains the meat of
the code to flush the TLB on a given CPU, and all the tlb flushing
APIs call it for both local and remote CPUs.

This series should only adversely affect the kernel in a couple of
minor ways:

 - It makes smp_mb() unconditional when flushing TLBs.  We used to
   use the TLB flush itself to mostly avoid smp_mb() on the initiating
   CPU.

 - On UP kernels, we lose the dubious optimization of inlining nerfed
   variants of all the TLB flush APIs.  This bloats the kernel a tiny
   bit, although it should increase performance, since the SMP
   versions were better.

Patch 10 in here is a little bit off topic.  It's a cleanup that's
also needed before PCID can go in, but it's not directly about
TLB flushing.

Changes from RFC:
 - Fixed missing call to arch_tlbbatch_flush().
 - "Be more consistent wrt PAGE_SHIFT vs PAGE_SIZE in tlb flush code" is new
 - Misc typos fixed.
 - Actually compiles when UV is enabled.

Andy Lutomirski (11):
  x86/mm: Reimplement flush_tlb_page() using flush_tlb_mm_range()
  x86/mm: Reduce indentation in flush_tlb_func()
  x86/mm: Make the batched unmap TLB flush API more generic
  x86/mm: Pass flush_tlb_info to flush_tlb_others() etc
  x86/mm: Change the leave_mm() condition for local TLB flushes
  x86/mm: Refactor flush_tlb_mm_range() to merge local and remote cases
  x86/mm: Use new merged flush logic in arch_tlbbatch_flush()
  x86/mm: Remove the UP tlbflush code; always use the formerly SMP code
  x86/mm: Rework lazy TLB to track the actual loaded mm
  x86/mm: Be more consistent wrt PAGE_SHIFT vs PAGE_SIZE in tlb flush
    code
  x86,kvm: Teach KVM's VMX code that CR3 isn't a constant

 arch/x86/Kconfig                      |   2 +-
 arch/x86/events/core.c                |   3 +-
 arch/x86/include/asm/hardirq.h        |   2 +-
 arch/x86/include/asm/mmu.h            |   6 -
 arch/x86/include/asm/mmu_context.h    |  21 +-
 arch/x86/include/asm/paravirt.h       |   6 +-
 arch/x86/include/asm/paravirt_types.h |   5 +-
 arch/x86/include/asm/tlbbatch.h       |  14 ++
 arch/x86/include/asm/tlbflush.h       | 116 +++------
 arch/x86/include/asm/uv/uv.h          |   9 +-
 arch/x86/kernel/ldt.c                 |   7 +-
 arch/x86/kvm/vmx.c                    |  21 +-
 arch/x86/mm/init.c                    |   4 +-
 arch/x86/mm/tlb.c                     | 429 +++++++++++++++-------------------
 arch/x86/platform/uv/tlb_uv.c         |  10 +-
 arch/x86/xen/mmu.c                    |  61 +++--
 include/linux/mm_types_task.h         |  15 +-
 mm/rmap.c                             |  16 +-
 18 files changed, 336 insertions(+), 411 deletions(-)
 create mode 100644 arch/x86/include/asm/tlbbatch.h

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
