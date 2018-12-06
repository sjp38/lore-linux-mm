Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3B1586B79EC
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 07:24:50 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id j6so91045wrw.1
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 04:24:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f5sor182480wrm.32.2018.12.06.04.24.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Dec 2018 04:24:47 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v13 00/25] kasan: add software tag-based mode for arm64
Date: Thu,  6 Dec 2018 13:24:18 +0100
Message-Id: <cover.1544099024.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>, Andrey Konovalov <andreyknvl@google.com>

This patchset adds a new software tag-based mode to KASAN [1].
(Initially this mode was called KHWASAN, but it got renamed,
 see the naming rationale at the end of this section).

The plan is to implement HWASan [2] for the kernel with the incentive,
that it's going to have comparable to KASAN performance, but in the same
time consume much less memory, trading that off for somewhat imprecise
bug detection and being supported only for arm64.

The underlying ideas of the approach used by software tag-based KASAN are:

1. By using the Top Byte Ignore (TBI) arm64 CPU feature, we can store
   pointer tags in the top byte of each kernel pointer.

2. Using shadow memory, we can store memory tags for each chunk of kernel
   memory.

3. On each memory allocation, we can generate a random tag, embed it into
   the returned pointer and set the memory tags that correspond to this
   chunk of memory to the same value.

4. By using compiler instrumentation, before each memory access we can add
   a check that the pointer tag matches the tag of the memory that is being
   accessed.

5. On a tag mismatch we report an error.

With this patchset the existing KASAN mode gets renamed to generic KASAN,
with the word "generic" meaning that the implementation can be supported
by any architecture as it is purely software.

The new mode this patchset adds is called software tag-based KASAN. The
word "tag-based" refers to the fact that this mode uses tags embedded into
the top byte of kernel pointers and the TBI arm64 CPU feature that allows
to dereference such pointers. The word "software" here means that shadow
memory manipulation and tag checking on pointer dereference is done in
software. As it is the only tag-based implementation right now, "software
tag-based" KASAN is sometimes referred to as simply "tag-based" in this
patchset.

A potential expansion of this mode is a hardware tag-based mode, which would
use hardware memory tagging support (announced by Arm [3]) instead of
compiler instrumentation and manual shadow memory manipulation.

Same as generic KASAN, software tag-based KASAN is strictly a debugging
feature.

[1] https://www.kernel.org/doc/html/latest/dev-tools/kasan.html

[2] http://clang.llvm.org/docs/HardwareAssistedAddressSanitizerDesign.html

[3] https://community.arm.com/processors/b/blog/posts/arm-a-profile-architecture-2018-developments-armv85a


====== Rationale

On mobile devices generic KASAN's memory usage is significant problem. One
of the main reasons to have tag-based KASAN is to be able to perform a
similar set of checks as the generic one does, but with lower memory
requirements.

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

Software tag-based KASAN mode is implemented in a very similar way to the
generic one. This patchset essentially does the following:

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
   KASAN simply prints a bug report. In case of inline instrumentation,
   clang inserts a brk instruction, and KASAN has it's own brk handler,
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

Despite that there's a particular type of bugs that tag-based KASAN can
detect compared to generic KASAN: use-after-free after the object has been
allocated by someone else.


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
Since tag-based KASAN doesn't add tags to pointers that belong to rodata
or vmalloc regions, this should work as is. To make sure debug checks to
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

Another point here is that tag-based KASAN is available under a separate
config option that needs to be deliberately enabled. Even though it might
be used in a "near-production" environment to find bugs that are not found
during fuzzing or running tests, it is still a debug tool.


====== Benchmarks

The following numbers were collected on Odroid C2 board. Both generic and
tag-based KASAN were used in inline instrumentation mode.

Boot time [1]:
* ~1.7 sec for clean kernel
* ~5.0 sec for generic KASAN
* ~5.0 sec for tag-based KASAN

Network performance [2]:
* 8.33 Gbits/sec for clean kernel
* 3.17 Gbits/sec for generic KASAN
* 2.85 Gbits/sec for tag-based KASAN

Slab memory usage after boot [3]:
* ~40 kb for clean kernel
* ~105 kb (~260% overhead) for generic KASAN
* ~47 kb (~20% overhead) for tag-based KASAN

KASAN memory overhead consists of three main parts:
1. Increased slab memory usage due to redzones.
2. Shadow memory (the whole reserved once during boot).
3. Quaratine (grows gradually until some preset limit; the more the limit,
   the more the chance to detect a use-after-free).

Comparing tag-based vs generic KASAN for each of these points:
1. 20% vs 260% overhead.
2. 1/16th vs 1/8th of physical memory.
3. Tag-based KASAN doesn't require quarantine.

[1] Time before the ext4 driver is initialized.
[2] Measured as `iperf -s & iperf -c 127.0.0.1 -t 30`.
[3] Measured as `cat /proc/meminfo | grep Slab`.


====== Some notes

A few notes:

1. The patchset can be found here:
   https://github.com/xairy/kasan-prototype/tree/khwasan

2. Building requires a recent Clang version (7.0.0 or later).

3. Stack instrumentation is not supported yet and will be added later.


====== Changes

Changes in v13:
- Fixed Kconfig KASAN options dependencies to forbid enabling CONFIG_KASAN
  without one of the modes.
- Select HAVE_ARCH_KASAN_SW_TAGS if HAVE_ARCH_KASAN in arm64 Kconfig.
- Reverted adding __arm64_skip_faulting_instruction.
- Rebased onto 4.20-rc4+ (cf76c364).

Changes in v12:
- Rebased onto ef78e5ec (4.20-rc4+).
- Used u64 instead of __u64 in arch/arm64/include/asm/memory.h as it isn't
  a UAPI header.
- Moved the untagged_addr() macro down into the #ifndef __ASSEMBLY__
  block, after we include <linux/bitops.h>, which is necessary for
  sign_extend64().
- New patch: "kasan, arm64: select HAVE_ARCH_KASAN_SW_TAGS", that selects
  HAVE_ARCH_KASAN_SW_TAGS for arm64 after all the necessary infrastructure
  code is added.
- Minor style fixes.

Changes in v11:
- Rebased onto 9ff01193 (4.20-rc3).
- Moved KASAN_SHADOW_SCALE_SHIFT definition to arch/arm64/Makefile.
- Added and used CC_HAS_KASAN_GENERIC and CC_HAS_KASAN_SW_TAGS configs to
  detect compiler support.
- New patch: "kasan: rename kasan_zero_page to kasan_early_shadow_page".
- New patch: "arm64: move untagged_addr macro from uaccess.h to memory.h".
- Renamed KASAN_SET_TAG/... macros in arch/arm64/include/asm/memory.h to
  __tag_set/... and reused them later in KASAN core code instead of
  redefining.
- Removed tag reset from the __kimg_to_phys() macro.
- Fixed tagged pointer handling in arm64 fault handling logic.

Changes in v10:
- Rebased onto 65102238 (4.20-rc1).
- Don't ignore kasan_kmalloc() return valued in kmem_cache_alloc_trace()
  and kmem_cache_alloc_node_trace() in include/linux/slab.h.
- New patch: don't ignore kasan_kmalloc return value in
  early_kmem_cache_node_alloc.
- New patch: added __must_check annotations to KASAN hooks that assign
  tags.
- Changed KASAN clang version requirement to 7.0.0 (as we need rL329612).
- Moved __no_sanitize_address definition from compiler_attributes.h to
  compiler-gcc.h and compiler-clang.h.

Changes in v9:
- Fixed kasan_init_slab_obj() hook when KASAN is disabled.
- Added assign_tag() function that preassigns tags for caches with
  constructors.
- Fixed KASAN_TAG_MASK redefinition in include/linux/mm.h vs
  mm/kasan/kasan.h.

Changes in v8:
- Rebased onto 7876320f (4.19-rc4).
- Renamed KHWASAN to software tag-based KASAN (see the top of the cover
  letter for details).
- Explicitly called tag-based KASAN a debug tool.
- Reused kasan_init_slab_obj() callback to preassign tags to caches
  without constructors, remove khwasan_preset_sl(u/a)b_tag().
- Moved move obj_to_index to include/linux/slab_def.h from mm/slab.c.
- Moved cache->s_mem untagging to alloc_slabmgmt() for SLAB.
- Fixed check_memory_region() to correctly handle user memory accesses and
  size == 0 case.
- Merged __no_sanitize_hwaddress into __no_sanitize_address.
- Defined KASAN_SET_TAG and KASAN_RESET_TAG macros for non KASAN builds to
  avoid duplication of __kimg_to_phys, _virt_addr_is_linear and
  page_to_virt macros.
- Fixed and simplified find_first_bad_addr for generic KASAN.
- Use non symbolized example KASAN report in documentation.
- Mention clang version requirements for both KASAN modes in the Kconfig
  options and in the documentation.
- Various small fixes.

Version v7 got accidentally skipped.

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
- Removed khwasan_enabled flag (it's not needed since KHWASAN is
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

Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Andrey Konovalov (25):
  kasan, mm: change hooks signatures
  kasan, slub: handle pointer tags in early_kmem_cache_node_alloc
  kasan: move common generic and tag-based code to common.c
  kasan: rename source files to reflect the new naming scheme
  kasan: add CONFIG_KASAN_GENERIC and CONFIG_KASAN_SW_TAGS
  kasan, arm64: adjust shadow size for tag-based mode
  kasan: rename kasan_zero_page to kasan_early_shadow_page
  kasan: initialize shadow to 0xff for tag-based mode
  arm64: move untagged_addr macro from uaccess.h to memory.h
  kasan: add tag related helper functions
  kasan, arm64: untag address in _virt_addr_is_linear
  kasan: preassign tags to objects with ctors or SLAB_TYPESAFE_BY_RCU
  kasan, arm64: fix up fault handling logic
  kasan, arm64: enable top byte ignore for the kernel
  kasan, mm: perform untagged pointers comparison in krealloc
  kasan: split out generic_report.c from report.c
  kasan: add bug reporting routines for tag-based mode
  mm: move obj_to_index to include/linux/slab_def.h
  kasan: add hooks implementation for tag-based mode
  kasan, arm64: add brk handler for inline instrumentation
  kasan, mm, arm64: tag non slab memory allocated via pagealloc
  kasan: add __must_check annotations to kasan hooks
  kasan, arm64: select HAVE_ARCH_KASAN_SW_TAGS
  kasan: update documentation
  kasan: add SPDX-License-Identifier mark to source files

 Documentation/dev-tools/kasan.rst      | 232 +++++----
 arch/arm64/Kconfig                     |   1 +
 arch/arm64/Makefile                    |  11 +-
 arch/arm64/include/asm/brk-imm.h       |   2 +
 arch/arm64/include/asm/kasan.h         |   8 +-
 arch/arm64/include/asm/memory.h        |  42 +-
 arch/arm64/include/asm/pgtable-hwdef.h |   1 +
 arch/arm64/include/asm/uaccess.h       |   7 -
 arch/arm64/kernel/traps.c              |  60 +++
 arch/arm64/mm/fault.c                  |  31 +-
 arch/arm64/mm/kasan_init.c             |  56 ++-
 arch/arm64/mm/proc.S                   |   8 +-
 arch/s390/mm/dump_pagetables.c         |  17 +-
 arch/s390/mm/kasan_init.c              |  33 +-
 arch/x86/mm/dump_pagetables.c          |  11 +-
 arch/x86/mm/kasan_init_64.c            |  55 ++-
 arch/xtensa/mm/kasan_init.c            |  18 +-
 include/linux/compiler-clang.h         |   6 +-
 include/linux/compiler-gcc.h           |   6 +
 include/linux/compiler_attributes.h    |  13 -
 include/linux/kasan.h                  | 101 +++-
 include/linux/mm.h                     |  29 ++
 include/linux/page-flags-layout.h      |  10 +
 include/linux/slab.h                   |   4 +-
 include/linux/slab_def.h               |  13 +
 lib/Kconfig.kasan                      |  98 +++-
 mm/cma.c                               |  11 +
 mm/kasan/Makefile                      |  15 +-
 mm/kasan/{kasan.c => common.c}         | 656 +++++++++----------------
 mm/kasan/generic.c                     | 344 +++++++++++++
 mm/kasan/generic_report.c              | 153 ++++++
 mm/kasan/{kasan_init.c => init.c}      |  71 +--
 mm/kasan/kasan.h                       |  59 ++-
 mm/kasan/quarantine.c                  |   1 +
 mm/kasan/report.c                      | 272 +++-------
 mm/kasan/tags.c                        | 161 ++++++
 mm/kasan/tags_report.c                 |  58 +++
 mm/page_alloc.c                        |   1 +
 mm/slab.c                              |  29 +-
 mm/slab.h                              |   2 +-
 mm/slab_common.c                       |   6 +-
 mm/slub.c                              |  51 +-
 scripts/Makefile.kasan                 |  53 +-
 43 files changed, 1817 insertions(+), 999 deletions(-)
 rename mm/kasan/{kasan.c => common.c} (59%)
 create mode 100644 mm/kasan/generic.c
 create mode 100644 mm/kasan/generic_report.c
 rename mm/kasan/{kasan_init.c => init.c} (82%)
 create mode 100644 mm/kasan/tags.c
 create mode 100644 mm/kasan/tags_report.c

-- 
2.20.0.rc1.387.gf8505762e3-goog
