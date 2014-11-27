Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id A0DF66B0069
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 11:01:26 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id w10so5074542pde.5
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 08:01:26 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id rr2si12030953pbc.207.2014.11.27.08.01.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 27 Nov 2014 08:01:24 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NFP0032YGMTNP70@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 27 Nov 2014 16:04:05 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v8 00/12] Kernel address sanitizer - runtime memory debugger.
Date: Thu, 27 Nov 2014 19:00:44 +0300
Message-id: <1417104057-20335-1-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joe Perches <joe@perches.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org

KASan is a runtime memory debugger designed to find use-after-free
and out-of-bounds bugs.

Currently KASAN supported only for x86_64 architecture and requires kernel
to be build with SLUB allocator.
KASAN uses compile-time instrumentation for checking every memory access, therefore you
will need a fresh GCC >= v4.9.2

Patches are based should apply cleanly on top of 3.18-rc6 and mmotm-2014-11-26-15-45
Patches  available in git as well:

	git://github.com/aryabinin/linux --branch=kasan/kasan_v8

Changes since v7:
        - Fix build with CONFIG_KASAN_INLINE=y from Sasha.

        - Don't poison redzone on freeing, since it is poisoned already from Dmitry Chernenkov.

        - Fix altinstruction_entry for memcpy.

        - Move kasan_slab_free() call after debug_obj_free to prevent some false-positives
            with CONFIG_DEBUG_OBJECTS=y

        - Drop -pg flag for kasan internals to avoid recursion with function tracer
           enabled.

        - Added ack from Christoph.

Historical background of address sanitizer from Dmitry Vyukov <dvyukov@google.com>:
	"We've developed the set of tools, AddressSanitizer (Asan),
	ThreadSanitizer and MemorySanitizer, for user space. We actively use
	them for testing inside of Google (continuous testing, fuzzing,
	running prod services). To date the tools have found more than 10'000
	scary bugs in Chromium, Google internal codebase and various
	open-source projects (Firefox, OpenSSL, gcc, clang, ffmpeg, MySQL and
	lots of others):
	https://code.google.com/p/address-sanitizer/wiki/FoundBugs
	https://code.google.com/p/thread-sanitizer/wiki/FoundBugs
	https://code.google.com/p/memory-sanitizer/wiki/FoundBugs
	The tools are part of both gcc and clang compilers.

	We have not yet done massive testing under the Kernel AddressSanitizer
	(it's kind of chicken and egg problem, you need it to be upstream to
	start applying it extensively). To date it has found about 50 bugs.
	Bugs that we've found in upstream kernel are listed here:
	https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerForKernel#Trophies
	We've also found ~20 bugs in out internal version of the kernel. Also
	people from Samsung and Oracle have found some. It's somewhat expected
	that when we boot the kernel and run a trivial workload, we do not
	find hundreds of bugs -- most of the harmful bugs in kernel codebase
	were already fixed the hard way (the kernel is quite stable, right).
	Based on our experience with user-space version of the tool, most of
	the bugs will be discovered by continuously testing new code (new bugs
	discovered the easy way), running fuzzers (that can discover existing
	bugs that are not hit frequently enough) and running end-to-end tests
	of production systems.

	As others noted, the main feature of AddressSanitizer is its
	performance due to inline compiler instrumentation and simple linear
	shadow memory. User-space Asan has ~2x slowdown on computational
	programs and ~2x memory consumption increase. Taking into account that
	kernel usually consumes only small fraction of CPU and memory when
	running real user-space programs, I would expect that kernel Asan will
	have ~10-30% slowdown and similar memory consumption increase (when we
	finish all tuning).

	I agree that Asan can well replace kmemcheck. We have plans to start
	working on Kernel MemorySanitizer that finds uses of uninitialized
	memory. Asan+Msan will provide feature-parity with kmemcheck. As
	others noted, Asan will unlikely replace debug slab and pagealloc that
	can be enabled at runtime. Asan uses compiler instrumentation, so even
	if it is disabled, it still incurs visible overheads.

	Asan technology is easily portable to other architectures. Compiler
	instrumentation is fully portable. Runtime has some arch-dependent
	parts like shadow mapping and atomic operation interception. They are
	relatively easy to port.

	Thanks"


Comparison with other debugging features:
=======================================

KMEMCHECK:
	- KASan can do almost everything that kmemcheck can. KASan uses compile-time
	  instrumentation, which makes it significantly faster than kmemcheck.
	  The only advantage of kmemcheck over KASan is detection of uninitialized
	  memory reads.

	  Some brief performance testing showed that kasan could be x500-x600 times
	  faster than kmemcheck:

$ netperf -l 30
		MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost (127.0.0.1) port 0 AF_INET
		Recv   Send    Send
		Socket Socket  Message  Elapsed
		Size   Size    Size     Time     Throughput
		bytes  bytes   bytes    secs.    10^6bits/sec

 no debug:	87380  16384  16384    30.00    41624.72

 kasan inline:	87380  16384  16384    30.00    12870.54

 kasan outline:	87380  16384  16384    30.00    10586.39

 kmemcheck: 	87380  16384  16384    30.03      20.23

	- Also kmemcheck couldn't work on several CPUs. It always sets number of CPUs to 1.
	  KASan doesn't have such limitation.

DEBUG_PAGEALLOC:
	- KASan is slower than DEBUG_PAGEALLOC, but KASan works on sub-page
	  granularity level, so it able to find more bugs.

SLUB_DEBUG (poisoning, redzones):
	- SLUB_DEBUG has lower overhead than KASan.

	- SLUB_DEBUG in most cases are not able to detect bad reads,
	  KASan able to detect both reads and writes.

	- In some cases (e.g. redzone overwritten) SLUB_DEBUG detect
	  bugs only on allocation/freeing of object. KASan catch
	  bugs right before it will happen, so we always know exact
	  place of first bad read/write.

Basic idea:
===========

    The main idea of KASAN is to use shadow memory to record whether each byte of memory
    is safe to access or not, and use compiler's instrumentation to check the shadow memory
    on each memory access.

    Address sanitizer uses 1/8 of the memory addressable in kernel for shadow memory
    (on x86_64 16TB of virtual address space reserved for shadow to cover all 128TB)
    and uses direct mapping with a scale and offset to translate a memory
    address to its corresponding shadow address.

    Here is function to translate address to corresponding shadow address:

         unsigned long kasan_mem_to_shadow(unsigned long addr)
         {
                    return (addr >> KASAN_SHADOW_SCALE_SHIFT) + KASAN_SHADOW_OFFSET;
         }
    where KASAN_SHADOW_SCALE_SHIFT = 3.

    So for every 8 bytes there is one corresponding byte of shadow memory.
    The following encoding used for each shadow byte: 0 means that all 8 bytes of the
    corresponding memory region are valid for access; k (1 <= k <= 7) means that
    the first k bytes are valid for access, and other (8 - k) bytes are not;
    Any negative value indicates that the entire 8-bytes are inaccessible.
    Different negative values used to distinguish between different kinds of
    inaccessible memory (redzones, freed memory) (see mm/kasan/kasan.h).

    To be able to detect accesses to bad memory we need a special compiler.
    Such compiler inserts a specific function calls (__asan_load*(addr), __asan_store*(addr))
    before each memory access of size 1, 2, 4, 8 or 16.

    These functions check whether memory region is valid to access or not by checking
    corresponding shadow memory. If access is not valid an error printed.


Changelog for previous versions:
===============================

Changes since v6:
   - New patch 'x86_64: kasan: add interceptors for memset/memmove/memcpy functions'
        Recently instrumentation of builtin functions calls (memset/memmove/memcpy)
        was removed in GCC 5.0. So to check the memory accessed by such functions,
        we now need interceptors for them.

   - Added kasan's die notifier which prints a hint message before General protection fault,
       explaining that GPF could be caused by NULL-ptr dereference or user memory access.

   - Minor refactoring in 3/n patch. Rename kasan_map_shadow() to kasan_init() and call it
     from setup_arch() instead of zone_sizes_init().

   - Slightly tweak kasan's report layout.

   - Update changelog for 1/n patch.

Changes since v5:
    - Added  __printf(3, 4) to slab_err to catch format mismatches (Joe Perches)

    - Changed in Documentation/kasan.txt per Jonathan.

    - Patch for inline instrumentation support merged to the first patch.
        GCC 5.0 finally has support for this.
    - Patch 'kasan: Add support for upcoming GCC 5.0 asan ABI changes' also merged into the first.
         Those GCC ABI changes are in GCC's master branch now.

    - Added information about instrumentation types to documentation.

    - Added -fno-conserve-stack to CFLAGS for mm/kasan/kasan.c file, because -fconserve-stack is bogus
      and it causing unnecessary split in __asan_load1/__asan_store1. Because of this split
      kasan_report() is actually not inlined (even though it __always_inline) and _RET_IP_ gives
      unexpected value. GCC bugzilla entry: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=63533

Changes since v4:
    - rebased on top of mmotm-2014-10-23-16-26

    - merge patch 'efi: libstub: disable KASAN for efistub in' into the first patch.
        No reason to keep it separate.

    - Added support for upcoming asan ABI changes in GCC 5.0 (second patch).
        GCC patch has not been published/upstreamed yet, but to will be soon. I'm adding this in advance
        in order to avoid breaking kasan with future GCC update.
        Details about gcc ABI changes in this thread: https://gcc.gnu.org/ml/gcc-patches/2014-10/msg02510.html

    - Updated GCC version requirements in doc (GCC kasan patches were backported into 4.9 branch)

    - Dropped last patch with inline instrumentation support. At first let's wait for merging GCC patches.

Changes since v3:

    - rebased on last mm
    - Added comment about rcu slabs.
    - Removed useless kasan_free_slab_pages().
    - Removed __asan_init_v*() stub. GCC doesn't generate this call anymore:
       https://gcc.gnu.org/ml/gcc-patches/2014-10/msg00269.html
    - Replaced CALL_KASAN_REPORT define with inline function

Changes since v2:

    - Shadow moved to vmalloc area.
    - Added posion page. This page mapped to shadow correspondig to
      shadow region itself:
       [kasan_mem_to_shadow(KASAN_SHADOW_START) - kasan_mem_to_shadow(KASAN_SHADOW_END)]
      It used to catch memory access to shadow outside mm/kasan/.

    - Fixed boot with CONFIG_DEBUG_VIRTUAL=y
    - Fixed boot with KASan and stack protector enabled
         (patch "x86_64: load_percpu_segment: read irq_stack_union.gs_base before load_segment")

    - Fixed build with CONFIG_EFI_STUB=y
    - Some slub specific stuf moved from mm/slab.h to include/linux/slub_def.h
    - Fixed Kconfig dependency. CONFIG_KASAN depends on CONFIG_SLUB_DEBUG.
    - Optimizations of __asan_load/__asan_store.
    - Spelling fixes from Randy.
    - Misc minor cleanups in different places.


    - Added inline instrumentation in last patch. This will require two not
         yet-in-trunk-patches for GCC:
             https://gcc.gnu.org/ml/gcc-patches/2014-09/msg00452.html
             https://gcc.gnu.org/ml/gcc-patches/2014-09/msg00605.html

Changes since v1:

    - The main change is in shadow memory laoyut.
      Now for shadow memory we reserve 1/8 of all virtual addresses available for kernel.
      16TB on x86_64 to cover all 128TB of kernel's address space.
      At early stage we map whole shadow region with zero page.
      Latter, after physical memory mapped to direct mapping address range
      we unmap zero pages from corresponding shadow and allocate and map a real
      memory.

     - Since per-arch work is much bigger now, support for arm/x86_32 platforms was dropped.

     - CFLAGS was change from -fsanitize=address with different --params to -fsanitize=kernel-address

     - If compiler doesn't support -fsanitize=kernel-address warning printed and build continues without -fsanitize

     - Removed kasan_memset/kasan_memcpy/kasan_memmove hooks. It turned out that this hooks are not needed. Compiler
       already instrument memset/memcpy/memmove (inserts __asan_load/__asan_store call before mem*() calls).

     - branch profiling disabled for mm/kasan/kasan.c to avoid recursion (__asan_load -> ftrace_likely_update -> __asan_load -> ...)

     - kasan hooks for buddy allocator moved to right places


Andrey Ryabinin (12):
  Add kernel address sanitizer infrastructure.
  x86_64: load_percpu_segment: read irq_stack_union.gs_base before
    load_segment
  x86_64: add KASan support
  mm: page_alloc: add kasan hooks on alloc and free paths
  mm: slub: introduce virt_to_obj function.
  mm: slub: share slab_err and object_err functions
  mm: slub: introduce metadata_access_enable()/metadata_access_disable()
  mm: slub: add kernel address sanitizer support for slub allocator
  fs: dcache: manually unpoison dname after allocation to shut up
    kasan's reports
  kmemleak: disable kasan instrumentation for kmemleak
  lib: add kasan test module
  x86_64: kasan: add interceptors for memset/memmove/memcpy functions

 Documentation/kasan.txt                | 169 +++++++++++
 Makefile                               |  23 +-
 arch/x86/Kconfig                       |   1 +
 arch/x86/boot/Makefile                 |   2 +
 arch/x86/boot/compressed/Makefile      |   2 +
 arch/x86/boot/compressed/eboot.c       |   3 +-
 arch/x86/boot/compressed/misc.h        |   1 +
 arch/x86/include/asm/kasan.h           |  27 ++
 arch/x86/include/asm/string_64.h       |  18 +-
 arch/x86/kernel/Makefile               |   2 +
 arch/x86/kernel/cpu/common.c           |   4 +-
 arch/x86/kernel/dumpstack.c            |   5 +-
 arch/x86/kernel/head64.c               |   9 +-
 arch/x86/kernel/head_64.S              |  28 ++
 arch/x86/kernel/setup.c                |   3 +
 arch/x86/kernel/x8664_ksyms_64.c       |  10 +-
 arch/x86/lib/memcpy_64.S               |   6 +-
 arch/x86/lib/memmove_64.S              |   4 +
 arch/x86/lib/memset_64.S               |  10 +-
 arch/x86/mm/Makefile                   |   3 +
 arch/x86/mm/kasan_init_64.c            | 108 +++++++
 arch/x86/realmode/Makefile             |   2 +-
 arch/x86/realmode/rm/Makefile          |   1 +
 arch/x86/vdso/Makefile                 |   1 +
 drivers/firmware/efi/libstub/Makefile  |   1 +
 drivers/firmware/efi/libstub/efistub.h |   4 +
 fs/dcache.c                            |   6 +
 include/linux/kasan.h                  |  69 +++++
 include/linux/sched.h                  |   3 +
 include/linux/slab.h                   |  11 +-
 include/linux/slub_def.h               |  10 +
 lib/Kconfig.debug                      |   2 +
 lib/Kconfig.kasan                      |  54 ++++
 lib/Makefile                           |   1 +
 lib/test_kasan.c                       | 254 ++++++++++++++++
 mm/Makefile                            |   4 +
 mm/compaction.c                        |   2 +
 mm/kasan/Makefile                      |   8 +
 mm/kasan/kasan.c                       | 509 +++++++++++++++++++++++++++++++++
 mm/kasan/kasan.h                       |  54 ++++
 mm/kasan/report.c                      | 237 +++++++++++++++
 mm/kmemleak.c                          |   6 +
 mm/page_alloc.c                        |   3 +
 mm/slab_common.c                       |   5 +-
 mm/slub.c                              |  56 +++-
 scripts/Makefile.lib                   |  10 +
 46 files changed, 1725 insertions(+), 26 deletions(-)
 create mode 100644 Documentation/kasan.txt
 create mode 100644 arch/x86/include/asm/kasan.h
 create mode 100644 arch/x86/mm/kasan_init_64.c
 create mode 100644 include/linux/kasan.h
 create mode 100644 lib/Kconfig.kasan
 create mode 100644 lib/test_kasan.c
 create mode 100644 mm/kasan/Makefile
 create mode 100644 mm/kasan/kasan.c
 create mode 100644 mm/kasan/kasan.h
 create mode 100644 mm/kasan/report.c

-- 
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Konstantin Serebryany <kcc@google.com>
Cc: Dmitry Chernenkov <dmitryc@google.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>
Cc: Yuri Gribov <tetra2005@gmail.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: Michal Marek <mmarek@suse.cz>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Vegard Nossum <vegard.nossum@gmail.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: <x86@kernel.org>
Cc: <linux-mm@kvack.org>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Michal Marek <mmarek@suse.cz>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Dave Jones <davej@redhat.com>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Joe Perches <joe@perches.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
