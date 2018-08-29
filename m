Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id A65E76B4B76
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 07:35:30 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id u12-v6so3327890wrc.1
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 04:35:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 79-v6sor1136851wmf.13.2018.08.29.04.35.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Aug 2018 04:35:28 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v6 00/18] khwasan: kernel hardware assisted address sanitizer
Date: Wed, 29 Aug 2018 13:35:04 +0200
Message-Id: <cover.1535462971.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>, Andrey Konovalov <andreyknvl@google.com>

This patchset adds a new mode to KASAN [1], which is called KHWASAN
(Kernel HardWare assisted Address SANitizer).

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


====== Rationale

On mobile devices KASAN's memory usage is significant problem. One of the
main reasons to have KWHASAN is to be able to perform a similar set of
checks that KASAN does, but with lower memory requirements.

Comment from Vishwath Mohan <vishwath@google.com>:

I don't have data on-hand, but anecdotally both ASAN and KASAN have proven
problematic to enable for environments that don't tolerate the increased
memory pressure well. This includes,
(a) Low-memory form factors - Wear, TV, Things, lower-tier phones like Go,
(c) Connected components like Pixel's visual core [1].

These are both places I'd love to have a low(er) memory footprint option at
my disposal.

Comment from Evgenii Stepanov <eugenis@google.com>:

Looking at a live Android device under load, slab (according to
/proc/meminfo) + kernel stack take 8-10% available RAM (~350MB). KASAN's
overhead of 2x - 3x on top of it is not insignificant.

Not having this overhead enables near-production use - ex. running
KASAN/KHWASAN kernel on a personal, daily-use device to catch bugs that do
not reproduce in test configuration. These are the ones that often cost
the most engineering time to track down.

CPU overhead is bad, but generally tolerable. RAM is critical, in our
experience. Once it gets low enough, OOM-killer makes your life miserable.

[1] https://www.blog.google/products/pixel/pixel-visual-core-image-processing-and-machine-learning-pixel-2/


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

Despite that there's a particular type of bugs that KHWASAN can detect
compared to KASAN: use-after-free after the object has been allocated by
someone else.


====== Testing

Some kernel developers voiced a concern that changing the top byte of
kernel pointers may lead to subtle bugs that are difficult to discover.
To address this concern deliberate testing has been performed.

It doesn't seem feasible to do some kind of static checking to find
potential issues with pointer tagging, so a dynamic approach was taken.
All pointer comparisons/subtractions have been instrumented in an LLVM
compiler pass and a kernel module that would print a bug report whenever
two pointers with different tags are being compared/subtracted (ignoring
comparisons with NULL pointers and with pointers obtained by casting an
error code to a pointer type) has been used. Then the kernel has been
booted in QEMU and on an Odroid C2 board and syzkaller has been run.

This yielded the following results.

The two places that look interesting are:

is_vmalloc_addr in include/linux/mm.h
is_kernel_rodata in mm/util.c

Here we compare a pointer with some fixed untagged values to make sure
that the pointer lies in a particular part of the kernel address space.
Since KWHASAN doesn't add tags to pointers that belong to rodata or
vmalloc regions, this should work as is. To make sure debug checks to
those two functions that check that the result doesn't change whether
we operate on pointers with or without untagging has been added.

A few other cases that don't look that interesting:

Comparing pointers to achieve unique sorting order of pointee objects
(e.g. sorting locks addresses before performing a double lock):

tty_ldisc_lock_pair_timeout in drivers/tty/tty_ldisc.c
pipe_double_lock in fs/pipe.c
unix_state_double_lock in net/unix/af_unix.c
lock_two_nondirectories in fs/inode.c
mutex_lock_double in kernel/events/core.c

ep_cmp_ffd in fs/eventpoll.c
fsnotify_compare_groups fs/notify/mark.c

Nothing needs to be done here, since the tags embedded into pointers
don't change, so the sorting order would still be unique.

Checks that a pointer belongs to some particular allocation:

is_sibling_entry in lib/radix-tree.c
object_is_on_stack in include/linux/sched/task_stack.h

Nothing needs to be done here either, since two pointers can only belong
to the same allocation if they have the same tag.

Overall, since the kernel boots and works, there are no critical bugs.
As for the rest, the traditional kernel testing way (use until fails) is
the only one that looks feasible.

Another point here is that KWHASAN is available under a separate config
option that needs to be deliberately enabled. Even though it might be used
in a "near-production" environment to find bugs that are not found during
fuzzing or running tests, it is still a debug tool.


====== Benchmarks

The following numbers were collected on Odroid C2 board. Both KASAN and
KHWASAN were used in inline instrumentation mode.

Boot time [1]:
* ~1.7 sec for clean kernel
* ~5.0 sec for KASAN
* ~5.0 sec for KHWASAN

Network performance [2]:
* 8.33 Gbits/sec for clean kernel
* 3.17 Gbits/sec for KASAN
* 2.85 Gbits/sec for KHWASAN

Slab memory usage after boot [3]:
* ~40 kb for clean kernel
* ~105 kb (~260% overhead) for KASAN
* ~47 kb (~20% overhead) for KHWASAN

KASAN memory overhead consists of three main parts:
1. Increased slab memory usage due to redzones.
2. Shadow memory (the whole reserved once during boot).
3. Quaratine (grows gradually until some preset limit; the more the limit,
   the more the chance to detect a use-after-free).

Comparing KWHASAN vs KASAN for each of these points:
1. 20% vs 260% overhead.
2. 1/16th vs 1/8th of physical memory.
3. KHWASAN doesn't require quarantine.

[1] Time before the ext4 driver is initialized.
[2] Measured as `iperf -s & iperf -c 127.0.0.1 -t 30`.
[3] Measured as `cat /proc/meminfo | grep Slab`.


====== Some notes

A few notes:

1. The patchset can be found here:
   https://github.com/xairy/kasan-prototype/tree/khwasan

2. Building requires a recent LLVM version (r330044 or later).

3. Stack instrumentation is not supported yet and will be added later.


====== Changes

Changes in v6:
- Rebased onto 050cdc6c (4.19-rc1+).
- Added notes regarding patchset testing into the cover letter.

Changes in v5:
- Rebased onto 1ffaddd029 (4.18-rc8).
- Preassign tags for objects from caches with constructors and
  SLAB_TYPESAFE_BY_RCU caches.
- Fix SLAB allocator support by untagging page->s_mem in
  kasan_poison_slab().
- Performed dynamic testing to find potential places where pointer tagging
  might result in bugs [1].
- Clarified and fixed memory usage benchmarks in the cover letter.
- Added a rationale for having KHWASAN to the cover letter.

Changes in v4:
- Fixed SPDX comment style in mm/kasan/kasan.h.
- Fixed mm/kasan/kasan.h changes being included in a wrong patch.
- Swapped "khwasan, arm64: fix up fault handling logic" and "khwasan: add
  tag related helper functions" patches order.
- Rebased onto 6f0d349d (4.18-rc2+).

Changes in v3:
- Minor documentation fixes.
- Fixed CFLAGS variable name in KASAN makefile.
- Added a "SPDX-License-Identifier: GPL-2.0" line to all source files
  under mm/kasan.
- Rebased onto 81e97f013 (4.18-rc1+).

Changes in v2:
- Changed kmalloc_large_node_hook to return tagged pointer instead of
  using an output argument.
- Fix checking whether -fsanitize=hwaddress is supported by the compiler.
- Removed duplication of -fno-builtin for KASAN and KHWASAN.
- Removed {} block for one line for_each_possible_cpu loop.
- Made set_track() static inline as it is used only in common.c.
- Moved optimal_redzone() to common.c.
- Fixed using tagged pointer for shadow calculation in
  kasan_unpoison_shadow().
- Restored setting cache->align in kasan_cache_create(), which was
  accidentally lost.
- Simplified __kasan_slab_free(), kasan_alloc_pages() and kasan_kmalloc().
- Removed tagging from kasan_kmalloc_large().
- Added page_kasan_tag_reset() to kasan_poison_slab() and removed
  !PageSlab() check from page_to_virt.
- Reset pointer tag in _virt_addr_is_linear.
- Set page tag for each page when multiple pages are allocated or freed.
- Added a comment as to why we ignore cma allocated pages.

Changes in v1:
- Rebased onto 4.17-rc4.
- Updated benchmarking stats.
- Documented compiler version requirements, memory usage and slowdown.
- Dropped kvm patches, as clang + arm64 + kvm is completely broken [1].

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
  combo is broken right now [2]).

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

[1] https://lkml.org/lkml/2018/7/18/765
[2] https://lkml.org/lkml/2018/4/19/775

Andrey Konovalov (18):
  khwasan, mm: change kasan hooks signatures
  khwasan: move common kasan and khwasan code to common.c
  khwasan: add CONFIG_KASAN_GENERIC and CONFIG_KASAN_HW
  khwasan, arm64: adjust shadow size for CONFIG_KASAN_HW
  khwasan: initialize shadow to 0xff
  khwasan, arm64: untag virt address in __kimg_to_phys and
    _virt_addr_is_linear
  khwasan: add tag related helper functions
  khwasan: preassign tags to objects with ctors or SLAB_TYPESAFE_BY_RCU
  khwasan, arm64: fix up fault handling logic
  khwasan, arm64: enable top byte ignore for the kernel
  khwasan, mm: perform untagged pointers comparison in krealloc
  khwasan: split out kasan_report.c from report.c
  khwasan: add bug reporting routines
  khwasan: add hooks implementation
  khwasan, arm64: add brk handler for inline instrumentation
  khwasan, mm, arm64: tag non slab memory allocated via pagealloc
  khwasan: update kasan documentation
  kasan: add SPDX-License-Identifier mark to source files

 Documentation/dev-tools/kasan.rst      | 213 ++++----
 arch/arm64/Kconfig                     |   1 +
 arch/arm64/Makefile                    |   2 +-
 arch/arm64/include/asm/brk-imm.h       |   2 +
 arch/arm64/include/asm/memory.h        |  41 +-
 arch/arm64/include/asm/pgtable-hwdef.h |   1 +
 arch/arm64/kernel/traps.c              |  69 ++-
 arch/arm64/mm/fault.c                  |   3 +
 arch/arm64/mm/kasan_init.c             |  18 +-
 arch/arm64/mm/proc.S                   |   8 +-
 include/linux/compiler-clang.h         |   3 +-
 include/linux/compiler-gcc.h           |   4 +
 include/linux/compiler.h               |   3 +-
 include/linux/kasan.h                  |  90 +++-
 include/linux/mm.h                     |  29 ++
 include/linux/page-flags-layout.h      |  10 +
 lib/Kconfig.kasan                      |  77 ++-
 mm/cma.c                               |  11 +
 mm/kasan/Makefile                      |   9 +-
 mm/kasan/common.c                      | 663 +++++++++++++++++++++++++
 mm/kasan/kasan.c                       | 565 +--------------------
 mm/kasan/kasan.h                       |  85 +++-
 mm/kasan/kasan_init.c                  |   1 +
 mm/kasan/kasan_report.c                | 156 ++++++
 mm/kasan/khwasan.c                     | 181 +++++++
 mm/kasan/khwasan_report.c              |  61 +++
 mm/kasan/quarantine.c                  |   1 +
 mm/kasan/report.c                      | 272 +++-------
 mm/page_alloc.c                        |   1 +
 mm/slab.c                              |  18 +-
 mm/slab.h                              |   2 +-
 mm/slab_common.c                       |   6 +-
 mm/slub.c                              |  21 +-
 scripts/Makefile.kasan                 |  27 +-
 34 files changed, 1734 insertions(+), 920 deletions(-)
 create mode 100644 mm/kasan/common.c
 create mode 100644 mm/kasan/kasan_report.c
 create mode 100644 mm/kasan/khwasan.c
 create mode 100644 mm/kasan/khwasan_report.c

-- 
2.19.0.rc0.228.g281dcd1b4d0-goog
