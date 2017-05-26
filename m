Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id D1C0D6B0292
	for <linux-mm@kvack.org>; Thu, 25 May 2017 20:47:55 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id o65so256158709oif.15
        for <linux-mm@kvack.org>; Thu, 25 May 2017 17:47:55 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l191si11936081oih.255.2017.05.25.17.47.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 17:47:54 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v3 0/8] x86 TLB flush cleanups, moving toward PCID support
Date: Thu, 25 May 2017 17:47:44 -0700
Message-Id: <cover.1495759610.git.luto@kernel.org>
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

Patch 8 in here is a little bit off topic.  It's a cleanup that's
also needed before PCID can go in, but it's not directly about
TLB flushing.

Changes from v1:
 - Rebased onto tip:x86/mm to pick up UV and Xen changes.
 - Drop the patches that Ingo already applied.

Changes from RFC:
 - Fixed missing call to arch_tlbbatch_flush().
 - "Be more consistent wrt PAGE_SHIFT vs PAGE_SIZE in tlb flush code" is new
 - Misc typos fixed.
 - Actually compiles when UV is enabled.

Andy Lutomirski (8):
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
 arch/x86/include/asm/tlbbatch.h       |   2 -
 arch/x86/include/asm/tlbflush.h       | 104 ++-------
 arch/x86/include/asm/uv/uv.h          |   9 +-
 arch/x86/kernel/ldt.c                 |   7 +-
 arch/x86/kvm/vmx.c                    |  21 +-
 arch/x86/mm/init.c                    |   4 +-
 arch/x86/mm/tlb.c                     | 389 ++++++++++++++++------------------
 arch/x86/platform/uv/tlb_uv.c         |  10 +-
 arch/x86/xen/mmu_pv.c                 |  61 +++---
 16 files changed, 281 insertions(+), 371 deletions(-)

-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
