Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id A42B36B0005
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 10:46:16 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id r72so102911090wmg.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 07:46:16 -0700 (PDT)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id bm4si5625604wjc.169.2016.03.30.07.46.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Mar 2016 07:46:15 -0700 (PDT)
Received: by mail-wm0-x22d.google.com with SMTP id 20so74629256wmh.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 07:46:14 -0700 (PDT)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2 0/9] arm64: optimize virt_to_page and page_address
Date: Wed, 30 Mar 2016 16:45:55 +0200
Message-Id: <1459349164-27175-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, linux-mm@kvack.org, akpm@linux-foundation.org, nios2-dev@lists.rocketboards.org, lftan@altera.com, jonas@southpole.se, linux@lists.openrisc.net
Cc: mark.rutland@arm.com, steve.capper@linaro.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>

Apologies for the wall of text. This is a followup to 'restrict virt_to_page
to linear region (instead of __pa)' [1], posted on the 24th of February.
This v2 series applies onto v4.6-rc1 with the series 'arm64: memstart_addr
alignment and vmemmap offset fixes' [2] applied on top.

Only minor changes since v1, primarily replacing 'x >> PAGE_SHIFT' instances
with PHYS_PFN, and rebasing onto the latest upstream.

When building the arm64 defconfig kernel, which has CONFIG_SPARSEMEM_VMEMMAP
enabled, the implementations of virt_to_page and its converse
[lowmem_]page_address resolve to

   virt_to_page
     6f8:   b6300180        tbz     x0, #38, 728 <bar+0x30>
     6fc:   90000001        adrp    x1, 0 <memstart_addr>
     700:   92409400        and     x0, x0, #0x3fffffffff
     704:   f9400021        ldr     x1, [x1]
     708:   8b000020        add     x0, x1, x0
     70c:   37000261        tbnz    w1, #0, 758 <bar+0x60>
     710:   d34cfc00        lsr     x0, x0, #12
     714:   d2dff7c2        mov     x2, #0xffbe00000000
     718:   cb813000        sub     x0, x0, x1, asr #12
     71c:   f2ffffe2        movk    x2, #0xffff, lsl #48
     720:   8b001840        add     x0, x2, x0, lsl #6
     724:   d65f03c0        ret
     728:   90000002        adrp    x2, 0 <init_pgd>
     72c:   90000001        adrp    x1, 0 <memstart_addr>
     730:   f9400042        ldr     x2, [x2]
     734:   f9400021        ldr     x1, [x1]
     738:   cb020000        sub     x0, x0, x2
     73c:   d2dff7c2        mov     x2, #0xffbe00000000
     740:   d34cfc00        lsr     x0, x0, #12
     744:   f2ffffe2        movk    x2, #0xffff, lsl #48
     748:   cb813000        sub     x0, x0, x1, asr #12
     74c:   8b001840        add     x0, x2, x0, lsl #6
     750:   d65f03c0        ret
     754:   d503201f        nop
     758:   d4210000        brk     #0x800

   page_address:
     6c0:   90000002        adrp    x2, 0 <memstart_addr>
     6c4:   d2c00841        mov     x1, #0x4200000000
     6c8:   f9400043        ldr     x3, [x2]
     6cc:   934cfc62        asr     x2, x3, #12
     6d0:   8b021800        add     x0, x0, x2, lsl #6
     6d4:   8b010001        add     x1, x0, x1
     6d8:   9346fc21        asr     x1, x1, #6
     6dc:   d374cc21        lsl     x1, x1, #12
     6e0:   37000083        tbnz    w3, #0, 6f0 <foo+0x30>
     6e4:   cb030020        sub     x0, x1, x3
     6e8:   b25a6400        orr     x0, x0, #0xffffffc000000000
     6ec:   d65f03c0        ret
     6f0:   d4210000        brk     #0x800

Disappointingly, even though this translation is independent of the physical
start of RAM since commit dfd55ad85e ("arm64: vmemmap: use virtual projection
of linear region"), the expression is evaluated in a way that does not allow
the compiler to eliminate the read of memstart_addr, presumably since it is
unaware that its value is aligned to PAGE_SIZE, and that shifting it down and
up again by PAGE_SHIFT bits produces the exact same value.

So let's give the compiler a hand here. First of all, let's reimplement
virt_to_page() (patch #6) so that it explicitly translates without taking
the physical placement into account. This results in the virt_to_page()
translation to only work correctly for addresses above PAGE_OFFSET, but
this is a reasonable restriction to impose, even if it means a couple of
incorrect uses need to be fixed (patches #1 to #4). If we also, in patch #5,
move the vmemmap region right below the linear region (which guarantees that
the region is always aligned to a power-of-2 upper bound of its size, which
means we can treat VMEMMAP_START as a bitmask rather than an offset), we end
up with

   virt_to_page
     6d0:   d34c9400        ubfx    x0, x0, #12, #26
     6d4:   d2dff7c1        mov     x1, #0xffbe00000000
     6d8:   f2ffffe1        movk    x1, #0xffff, lsl #48
     6dc:   aa001820        orr     x0, x1, x0, lsl #6
     6e0:   d65f03c0        ret

In the same way, we can get page_address to look like this

   page_address:
     6c0:   d37a7c00        ubfiz   x0, x0, #6, #32
     6c4:   b25a6400        orr     x0, x0, #0xffffffc000000000
     6c8:   d65f03c0        ret

However, in this case, we need to slightly refactor the implementation of
lowmem_page_paddress(), since it performs an explicit page-to-pa-to-va
translation, rather than going through an opaque arch-defined definition
of page_to_virt. (patches #7 to #9)

[1] http://thread.gmane.org/gmane.linux.ports.arm.kernel/481327
[2] http://thread.gmane.org/gmane.linux.ports.arm.kernel/488876

Ard Biesheuvel (9):
  arm64: vdso: avoid virt_to_page() translations on kernel symbols
  arm64: mm: free __init memory via the linear mapping
  arm64: mm: avoid virt_to_page() translation for the zero page
  arm64: insn: avoid virt_to_page() translations on core kernel symbols
  arm64: mm: move vmemmap region right below the linear region
  arm64: mm: restrict virt_to_page() to the linear mapping
  nios2: use correct void* return type for page_to_virt()
  openrisc: drop wrongly typed definition of page_to_virt()
  mm: replace open coded page to virt conversion with page_to_virt()

 arch/arm64/include/asm/memory.h  | 30 ++++++++++++++++++--
 arch/arm64/include/asm/pgtable.h | 13 +++------
 arch/arm64/kernel/insn.c         |  2 +-
 arch/arm64/kernel/vdso.c         |  4 +--
 arch/arm64/mm/dump.c             | 16 +++++------
 arch/arm64/mm/init.c             | 17 +++++++----
 arch/nios2/include/asm/io.h      |  1 -
 arch/nios2/include/asm/page.h    |  2 +-
 arch/nios2/include/asm/pgtable.h |  2 +-
 arch/openrisc/include/asm/page.h |  2 --
 include/linux/mm.h               |  6 +++-
 11 files changed, 62 insertions(+), 33 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
