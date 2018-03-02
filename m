Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7D83E6B0006
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 14:44:55 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id a3so1473307wme.1
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 11:44:55 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a23sor650616wmg.19.2018.03.02.11.44.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Mar 2018 11:44:53 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [RFC PATCH 00/14] khwasan: kernel hardware assisted address sanitizer
Date: Fri,  2 Mar 2018 20:44:19 +0100
Message-Id: <cover.1520017438.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>

This patchset adds a new mode to KASAN, which is called KHWASAN (Kernel
HardWare assisted Address SANitizer). There's still some work to do and
there are a few TODOs in the code, so I'm publishing this as a RFC to
collect some initial feedback.

The plan is to implement HWASan [1] for the kernel with the incentive,
that it's going to have comparable performance, but in the same time
consume much less memory, trading that off for somewhat imprecise bug
detection and being supported only for arm64.

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

[1] http://clang.llvm.org/docs/HardwareAssistedAddressSanitizerDesign.html


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

7. The memory in between slab objects is marked with a random tag, and
   acts as a redzone.

Bug detection is imprecise for two reasons:

1. We won't catch some small out-of-bounds accesses, that fall into the
   same shadow cell.

2. We only have 1 byte to store tags, which means we have a 1/256
   probability of a tag match for an incorrect access.


====== Benchmarks

As of now I've only did a few simple tests of KHWASAN on arm64 in QEMU
emulation mode. I'm yet to perform proper benchmarks on actual hardware.

These are the numbers I got with the current prototype and they are likely
to change.

Boot time:
* ~3.5 sec for clean kernel
* ~5.6 sec for KASAN
* ~8.9 sec for KHWASAN

The difference in KASAN and KHWASAN performance here can be explained by
QEMU performance drop when it needs to emulate Top Byte Ignore. I don't
think there's any reason to belive that the final implementation will
cause significant performance drop compared to KASAN on actual hardware.

Slab memory usage after boot:
* ~15 kb for clean kernel
* ~60 kb for KASAN
* ~16 kb for KHWASAN

Note, that KHWASAN (compared to KASAN) doesn't require quarantine and uses
twice as less shadow memory (1/16th vs 1/8th).


====== Some notes

A few notes:

1. The patchset can be found here:
   https://github.com/xairy/kasan-prototype/tree/khwasan

2. Building requires a recent LLVM version (r325711 or later).

3. Stack instrumentation is not supported yet (in progress).

4. There's at least one issue with using the top byte of kernel pointers,
   see the jbd2 commit for details.

5. There's still a few TODOs in the code, that need to be addressed.


Andrey Konovalov (14):
  khwasan: change kasan hooks signatures
  khwasan: move common kasan and khwasan code to common.c
  khwasan: add CONFIG_KASAN_CLASSIC and CONFIG_KASAN_TAGS
  khwasan: adjust shadow size for CONFIG_KASAN_TAGS
  khwasan: initialize shadow to 0xff
  khwasan: enable top byte ignore for the kernel
  khwasan: add tag related helper functions
  khwasan: perform untagged pointers comparison in krealloc
  khwasan: add hooks implementation
  khwasan: add bug reporting routines
  khwasan: add brk handler for inline instrumentation
  khwasan, jbd2: add khwasan annotations
  khwasan: update kasan documentation
  khwasan: default the instrumentation mode to inline

 Documentation/dev-tools/kasan.rst      | 212 +++++++++-------
 arch/arm64/Kconfig                     |   1 +
 arch/arm64/Makefile                    |   2 +-
 arch/arm64/include/asm/brk-imm.h       |   2 +
 arch/arm64/include/asm/memory.h        |  13 +-
 arch/arm64/include/asm/pgtable-hwdef.h |   1 +
 arch/arm64/kernel/traps.c              |  40 +++
 arch/arm64/mm/kasan_init.c             |  13 +-
 arch/arm64/mm/proc.S                   |   8 +-
 fs/jbd2/journal.c                      |   6 +
 include/linux/compiler-clang.h         |   7 +-
 include/linux/compiler-gcc.h           |   4 +
 include/linux/compiler.h               |   3 +-
 include/linux/kasan.h                  |  84 ++++--
 lib/Kconfig.kasan                      |  70 +++--
 mm/kasan/Makefile                      |   9 +-
 mm/kasan/common.c                      | 325 ++++++++++++++++++++++++
 mm/kasan/kasan.c                       | 302 +---------------------
 mm/kasan/kasan.h                       |  29 +++
 mm/kasan/khwasan.c                     | 338 +++++++++++++++++++++++++
 mm/kasan/report.c                      |  88 ++++++-
 mm/slab.c                              |  12 +-
 mm/slab.h                              |   2 +-
 mm/slab_common.c                       |   6 +-
 mm/slub.c                              |  18 +-
 scripts/Makefile.kasan                 |  32 ++-
 26 files changed, 1177 insertions(+), 450 deletions(-)
 create mode 100644 mm/kasan/common.c
 create mode 100644 mm/kasan/khwasan.c

-- 
2.16.2.395.g2e18187dfd-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
