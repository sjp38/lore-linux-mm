Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id C49FE6B0031
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 07:10:18 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id ft15so8846030pdb.21
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 04:10:18 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id bh2si7212977pdb.343.2014.07.09.04.10.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 09 Jul 2014 04:10:17 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8F00CFMZ0MY450@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 09 Jul 2014 12:09:58 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [RFC/PATCH -next 00/21] Address sanitizer for kernel (kasan) - dynamic
 memory error detector.
Date: Wed, 09 Jul 2014 15:00:57 +0400
Message-id: <1404903678-8257-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

Hi all.

This patch set introduces address sanitizer for linux kernel (kasan).
Address sanitizer is dynamic memory error detector. It detects:
 - Use after free bugs.
 - Out of bounds reads/writes in kmalloc

It is possible, but not implemented yet or not included into this patch series:
 - Global buffer overflow
 - Stack buffer overflow
 - Use after return

In this patches contains kasan for x86/x86_64/arm architectures, for buddy and SLUB allocator.

Patches are base on next-20140704 and also available in git:
	git://github.com/aryabinin/linux.git --branch=kasan/kasan_v1

The main idea was borrowed from https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerForKernel.
The original implementation (only x88_64 and only for SLAB) by Andrey Konovalov could be
found here http://github.com/xairy/linux. Some of code in this patches was stolen from there.

To use this feature you need pretty fresh GCC (revision r211699 from 2014-06-16 or
above).

To enable kasan configure kernel with:
     CONFIG_KASAN = y
and
     CONFIG_KASAN_SANTIZE_ALL = y

Currently KASAN works only with SLUB allocator. It is highly recommended to run KASAN with
CONFIG_SLUB_DEBUG=y and use 'slub_debug=U' in boot cmdline to enable user tracking
(free and alloc stacktraces).

Basic concept of kasan:

The main idea of KASAN is to use shadow memory to record whether each byte of memory
is safe to access or not, and use compiler's instrumentation to check the shadow memory
on each memory access.

Address sanitizer dedicates 1/8 of the low memory to the shadow memory and uses direct
mapping with a scale and offset to translate a memory address to its corresponding
shadow address.

Here is function to translate address to corresponding shadow address:

     unsigned long kasan_mem_to_shadow(unsigned long addr)
     {
		return ((addr) >> KASAN_SHADOW_SCALE_SHIFT)
       	             + kasan_shadow_start - (PAGE_OFFSET >> KASAN_SHADOW_SCALE_SHIFT);
     }

where KASAN_SHADOW_SCALE_SHIFT = 3.

So for every 8 bytes of lowmemory there is one corresponding byte of shadow memory.
The following encoding used for each shadow byte: 0 means that all 8 bytes of the
corresponding memory region are valid for access; k (1 <= k <= 7) means that
the first k bytes are valid for access, and other (8 - k) bytes are not;
Any negative value indicates that the entire 8-bytes are unaccessible.
Different negative values used to distinguish between different kinds of
unaccessible memory (redzones, freed memory) (see mm/kasan/kasan.h).

To be able to detect accesses to bad memory we need a special compiler.
Such compiler inserts a specific function calls (__asan_load*(addr), __asan_store*(addr))
before each memory access of size 1, 2, 4, 8 or 16.

These functions check whether memory region is valid to access or not by checking
corresponding shadow memory. If access is not valid an error printed.


TODO:
 - Optimizations: __asan_load*/__asan_store* are called for every memory access, so it's
        important to make them as fast as possible.
        In this patch set introduced only reference design of memory checking algorithm. It's
        slow but very simple, so anyone could easily understand basic concept.
        In future versions I'll try bring optimized versions with some numbers.

 - It seems like guard page introduced in c0a32f (mm: more intensive memory corruption debugging)
       could be easily reused for kasan as well.

 - get rid of kasan_disable_local()/kasan_enable_local() functions. kasan_enable/kasan_disable are
       used in some rare cases when we need validly access poisoned areas. This functions might be a
       stopping gap for inline instrumentation (see below).

TODO probably not for these series:
 - Quarantine for slub. For more strong use after free detection we need to delay reusing of freed
      slabs. So we need a something similar to guard pages in buddy allocator. Such quarantine might
      be useful even without kasan.

 - Inline instrumentation. Inline instrumentation means that fast patch of __asan_load* __asan_store* calls
    will be implemented in compiler, and instead of inserting function calls compiler will actually insert
    this fast path. To be able to do this we need (at least):
       a) get rid of kasan_disable()/kasan_enable() (see above)
       b) get rid of kasan_initialized flag. The main reason why we have this flag now is because we don't
       	  have any shadow on early stages of boot.

	  Konstantin Khlebnikov suggested a way to solve this issue:
               We could reserve virtual address space for shadow and map pages on very early stage of
               boot process (for x86_64 I think it should be done somewhere in x86_64_start_kernel).
               So we will have shadow all the time an flag kasan_initialized will no longer required.

 - Stack instrumentation (currently doesn't supported in mainline GCC though it is possible)
 - Global variables instrumentation
 - Use after return



[1] https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerForKernel

List of already fixed bugs found by address sanitizer:

aab515d (fib_trie: remove potential out of bound access)
984f173 ([SCSI] sd: Fix potential out-of-bounds access)
5e9ae2e (aio: fix use-after-free in aio_migratepage)
2811eba (ipv6: udp packets following an UFO enqueued packet need also be handled by UFO)
057db84 (tracing: Fix potential out-of-bounds in trace_get_user())
9709674 (ipv4: fix a race in ip4_datagram_release_cb())
4e8d213 (ext4: fix use-after-free in ext4_mb_new_blocks)
624483f (mm: rmap: fix use-after-free in __put_anon_vma)

Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Konstantin Serebryany <kcc@google.com>
Cc: Alexey Preobrazhensky <preobr@google.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>
Cc: Yuri Gribov <tetra2005@gmail.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: Michal Marek <mmarek@suse.cz>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: <linux-kbuild@vger.kernel.org>
Cc: <linux-arm-kernel@lists.infradead.org>
Cc: <x86@kernel.org>
Cc: <linux-mm@kvack.org>

Andrey Ryabinin (21):
  Add kernel address sanitizer infrastructure.
  init: main: initialize kasan's shadow area on boot
  x86: add kasan hooks fort memcpy/memmove/memset functions
  x86: boot: vdso: disable instrumentation for code not linked with
    kernel
  x86: cpu: don't sanitize early stages of a secondary CPU boot
  x86: mm: init: allocate shadow memory for kasan
  x86: Kconfig: enable kernel address sanitizer
  mm: page_alloc: add kasan hooks on alloc and free pathes
  mm: Makefile: kasan: don't instrument slub.c and slab_common.c files
  mm: slab: share virt_to_cache() between slab and slub
  mm: slub: share slab_err and object_err functions
  mm: util: move krealloc/kzfree to slab_common.c
  mm: slub: add allocation size field to struct kmem_cache
  mm: slub: kasan: disable kasan when touching unaccessible memory
  mm: slub: add kernel address sanitizer hooks to slub allocator
  arm: boot: compressed: disable kasan's instrumentation
  arm: add kasan hooks fort memcpy/memmove/memset functions
  arm: mm: reserve shadow memory for kasan
  arm: Kconfig: enable kernel address sanitizer
  fs: dcache: manually unpoison dname after allocation to shut up
    kasan's reports
  lib: add kmalloc_bug_test module

 Documentation/kasan.txt           | 224 ++++++++++++++++++++
 Makefile                          |   8 +-
 arch/arm/Kconfig                  |   1 +
 arch/arm/boot/compressed/Makefile |   2 +
 arch/arm/include/asm/string.h     |  30 +++
 arch/arm/mm/init.c                |   3 +
 arch/x86/Kconfig                  |   1 +
 arch/x86/boot/Makefile            |   2 +
 arch/x86/boot/compressed/Makefile |   2 +
 arch/x86/include/asm/string_32.h  |  28 +++
 arch/x86/include/asm/string_64.h  |  24 +++
 arch/x86/kernel/cpu/Makefile      |   3 +
 arch/x86/lib/Makefile             |   2 +
 arch/x86/mm/init.c                |   3 +
 arch/x86/realmode/Makefile        |   2 +-
 arch/x86/realmode/rm/Makefile     |   1 +
 arch/x86/vdso/Makefile            |   1 +
 commit                            |   3 +
 fs/dcache.c                       |   3 +
 include/linux/kasan.h             |  61 ++++++
 include/linux/sched.h             |   4 +
 include/linux/slab.h              |  19 +-
 include/linux/slub_def.h          |   5 +
 init/main.c                       |   3 +-
 lib/Kconfig.debug                 |  10 +
 lib/Kconfig.kasan                 |  22 ++
 lib/Makefile                      |   1 +
 lib/test_kmalloc_bugs.c           | 254 +++++++++++++++++++++++
 mm/Makefile                       |   5 +
 mm/kasan/Makefile                 |   3 +
 mm/kasan/kasan.c                  | 420 ++++++++++++++++++++++++++++++++++++++
 mm/kasan/kasan.h                  |  42 ++++
 mm/kasan/report.c                 | 187 +++++++++++++++++
 mm/page_alloc.c                   |   4 +
 mm/slab.c                         |   6 -
 mm/slab.h                         |  25 ++-
 mm/slab_common.c                  |  96 +++++++++
 mm/slub.c                         |  50 ++++-
 mm/util.c                         |  91 ---------
 scripts/Makefile.lib              |  10 +
 40 files changed, 1550 insertions(+), 111 deletions(-)
 create mode 100644 Documentation/kasan.txt
 create mode 100644 commit
 create mode 100644 include/linux/kasan.h
 create mode 100644 lib/Kconfig.kasan
 create mode 100644 lib/test_kmalloc_bugs.c
 create mode 100644 mm/kasan/Makefile
 create mode 100644 mm/kasan/kasan.c
 create mode 100644 mm/kasan/kasan.h
 create mode 100644 mm/kasan/report.c

-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
