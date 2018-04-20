Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7B9DE6B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 10:47:00 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 31-v6so9120369wrr.2
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 07:47:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v184sor464074wmd.3.2018.04.20.07.46.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Apr 2018 07:46:58 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [RFC PATCH v3 00/15] khwasan: kernel hardware assisted address sanitizer
Date: Fri, 20 Apr 2018 16:46:38 +0200
Message-Id: <cover.1524235387.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, "GitAuthor : Andrey Konovalov" <andreyknvl@google.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, Michael Weiser <michael.weiser@gmx.de>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Steve Capper <steve.capper@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Woodhouse <dwmw@amazon.co.uk>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Herbert Xu <herbert@gondor.apana.org.au>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvmarm@lists.cs.columbia.edu, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

Hi! This is the 3rd RFC version of the patchset.

This patchset adds a new mode to KASAN [1], which is called KHWASAN
(Kernel HardWare assisted Address SANitizer). There's still some work to
do and there are a few TODOs in the code, so I'm publishing this as an RFC
to collect some initial feedback.

The plan is to implement HWASan [2] for the kernel with the incentive,
that it's going to have comparable to KASAN performance, but in the same
time consume much less memory, trading that off for somewhat imprecise
bug detection and being supported only for arm64.

The overall idea of the approach used by KHWASAN is the following:

1. By using the Top Byte Ignore arm64 CPU feature, we can store pointer
   tags in the top byte of each kernel pointer.

2. Using shadow memory, we can store memory tags for each chunk of kernel
   memory.

3. On each memory allocation, we can generate a random tag, embed it into
   the returned pointer and set the memory tags that correspond to this
   chunk of memory to the same value.

4. By using compiler instrumentation, before each memory access we can add
   a check that the pointer tag matches the tag of the memory that is being
   accessed.

5. On a tag mismatch we report an error.

[1] https://www.kernel.org/doc/html/latest/dev-tools/kasan.html

[2] http://clang.llvm.org/docs/HardwareAssistedAddressSanitizerDesign.html


====== Technical details

KHWASAN is implemented in a very similar way to KASAN. This patchset
essentially does the following:

1. TCR_TBI1 is set to enable Top Byte Ignore.

2. Shadow memory is used (with a different scale, 1:16, so each shadow
   byte corresponds to 16 bytes of kernel memory) to store memory tags.

3. All slab objects are aligned to shadow scale, which is 16 bytes.

4. All pointers returned from the slab allocator are tagged with a random
   tag and the corresponding shadow memory is poisoned with the same value.

5. Compiler instrumentation is used to insert tag checks. Either by
   calling callbacks or by inlining them (CONFIG_KASAN_OUTLINE and
   CONFIG_KASAN_INLINE flags are reused).

6. When a tag mismatch is detected in callback instrumentation mode
   KHWASAN simply prints a bug report. In case of inline instrumentation,
   clang inserts a brk instruction, and KHWASAN has it's own brk handler,
   which reports the bug.

7. The memory in between slab objects is marked with a reserved tag, and
   acts as a redzone.

8. When a slab object is freed it's marked with a reserved tag.

Bug detection is imprecise for two reasons:

1. We won't catch some small out-of-bounds accesses, that fall into the
   same shadow cell, as the last byte of a slab object.

2. We only have 1 byte to store tags, which means we have a 1/256
   probability of a tag match for an incorrect access (actually even
   slightly less due to reserved tag values).


====== Benchmarks

The following numbers were collected on Odroid C2 board. Both KASAN and
KHWASAN were used in inline instrumentation mode. These are the numbers
I got with the current prototype and they might change.

Boot time [1]:
* ~4.5 sec for clean kernel
* ~5.0 sec for KASAN
* ~5.1 sec for KHWASAN

Slab memory usage after boot [2]:
* ~32 kb for clean kernel
* ~95 kb + 1/8th shadow ~= 107 kb for KASAN
* ~38 kb + 1/16th shadow ~= 40 kb for KHWASAN

Network performance [3]:
* 11.9 Gbits/sec for clean kernel
* 3.08 Gbits/sec for KASAN
* 3.02 Gbits/sec for KHWASAN

Note, that KHWASAN (compared to KASAN) doesn't require quarantine.

[1] Time before the ext4 driver is initialized.
[2] Measured as `cat /proc/meminfo | grep Slab`.
[3] Measured as `iperf -s & iperf -c 127.0.0.1 -t 30`.


====== Some notes

A few notes:

1. The patchset can be found here:
   https://github.com/xairy/kasan-prototype/tree/khwasan

2. Building requires a recent LLVM version (r330044 or later).

3. Stack instrumentation is not supported yet (in progress).

4. There are still a few TODOs in the code, that need to be addressed.


====== Changes

Changes in RFC v3:
- Renamed CONFIG_KASAN_CLASSIC and CONFIG_KASAN_TAGS to
  CONFIG_KASAN_GENERIC and CONFIG_KASAN_HW respectively.
- Switch to -fsanitize=kernel-hwaddress instead of -fsanitize=hwaddress.
- Removed unnecessary excessive shadow initialization.
- Removed khwasan_enabled flag (ita??s not needed since KHWASAN is
  initialized before any slab caches are used).
- Split out kasan_report.c and khwasan_report.c from report.c.
- Moved more common KASAN and KHWASAN functions to common.c.
- Added tagging to pagealloc.
- Rebased onto 4.17-rc1.
- Temporarily dropped patch that adds kvm support (arm64 + kvm + clang
  combo is broken right now (https://lkml.org/lkml/2018/4/19/775)).

Changes in RFC v2:
- Removed explicit casts to u8 * for kasan_mem_to_shadow() calls.
- Introduced KASAN_TCR_FLAGS for setting the TCR_TBI1 flag.
- Added a comment regarding the non-atomic RMW sequence in
  khwasan_random_tag().
- Made all tag related functions accept const void *.
- Untagged pointers in __kimg_to_phys, which is used by virt_to_phys.
- Untagged pointers in show_ptr in fault handling logic.
- Untagged pointers passed to KVM.
- Added two reserved tag values: 0xFF and 0xFE.
- Used the reserved tag 0xFF to disable validity checking (to resolve the
  issue with pointer tag being lost after page_address + kmap usage).
- Used the reserved tag 0xFE to mark redzones and freed objects.
- Added mnemonics for esr manipulation in KHWASAN brk handler.
- Added a comment about the -recover flag.
- Some minor cleanups and fixes.
- Rebased onto 3215b9d5 (4.16-rc6+).
- Tested on real hardware (Odroid C2 board).
- Added better benchmarks.

Andrey Konovalov (15):
  khwasan: move common kasan and khwasan code to common.c
  khwasan: add CONFIG_KASAN_GENERIC and CONFIG_KASAN_HW
  khwasan, arm64: adjust shadow size for CONFIG_KASAN_HW
  khwasan: initialize shadow to 0xff
  khwasan, arm64: untag virt address in __kimg_to_phys
  khwasan, arm64: fix up fault handling logic
  khwasan: add tag related helper functions
  khwasan, arm64: enable top byte ignore for the kernel
  khwasan, mm: perform untagged pointers comparison in krealloc
  khwasan: split out kasan_report.c from report.c
  khwasan: add bug reporting routines
  khwasan: add hooks implementation
  khwasan, arm64: add brk handler for inline instrumentation
  khwasan, mm, arm64: tag non slab memory allocated via pagealloc
  khwasan: update kasan documentation

 Documentation/dev-tools/kasan.rst      | 212 +++++----
 arch/arm64/Kconfig                     |   1 +
 arch/arm64/Makefile                    |   2 +-
 arch/arm64/include/asm/brk-imm.h       |   2 +
 arch/arm64/include/asm/memory.h        |  35 +-
 arch/arm64/include/asm/pgtable-hwdef.h |   1 +
 arch/arm64/kernel/traps.c              |  69 ++-
 arch/arm64/mm/fault.c                  |   3 +
 arch/arm64/mm/kasan_init.c             |  18 +-
 arch/arm64/mm/proc.S                   |   8 +-
 include/linux/compiler-clang.h         |   5 +-
 include/linux/compiler-gcc.h           |   4 +
 include/linux/compiler.h               |   3 +-
 include/linux/kasan.h                  |  50 ++-
 include/linux/mm.h                     |  29 ++
 include/linux/page-flags-layout.h      |  10 +
 lib/Kconfig.kasan                      |  68 ++-
 mm/cma.c                               |   1 +
 mm/kasan/Makefile                      |   9 +-
 mm/kasan/common.c                      | 576 +++++++++++++++++++++++++
 mm/kasan/kasan.c                       | 493 +--------------------
 mm/kasan/kasan.h                       |  94 +++-
 mm/kasan/kasan_report.c                | 155 +++++++
 mm/kasan/khwasan.c                     | 163 +++++++
 mm/kasan/khwasan_report.c              |  60 +++
 mm/kasan/report.c                      | 271 ++++--------
 mm/page_alloc.c                        |   1 +
 mm/slab_common.c                       |   2 +-
 mm/slub.c                              |   2 +-
 scripts/Makefile.kasan                 |  27 +-
 30 files changed, 1558 insertions(+), 816 deletions(-)
 create mode 100644 mm/kasan/common.c
 create mode 100644 mm/kasan/kasan_report.c
 create mode 100644 mm/kasan/khwasan.c
 create mode 100644 mm/kasan/khwasan_report.c

-- 
2.17.0.484.g0c8726318c-goog
