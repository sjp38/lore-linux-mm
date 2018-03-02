Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 117A96B002F
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 14:45:25 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id n14so1404097wmc.0
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 11:45:25 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w9sor3641555wre.19.2018.03.02.11.45.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Mar 2018 11:45:22 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [RFC PATCH 13/14] khwasan: update kasan documentation
Date: Fri,  2 Mar 2018 20:44:32 +0100
Message-Id: <befa404d3849e440d6dfe6cf9706468998dcfbe5.1520017438.git.andreyknvl@google.com>
In-Reply-To: <cover.1520017438.git.andreyknvl@google.com>
References: <cover.1520017438.git.andreyknvl@google.com>
In-Reply-To: <cover.1520017438.git.andreyknvl@google.com>
References: <cover.1520017438.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>

This patch updates KASAN documentation to reflect the addition of KHWASAN.
---
 Documentation/dev-tools/kasan.rst | 212 +++++++++++++++++-------------
 1 file changed, 122 insertions(+), 90 deletions(-)

diff --git a/Documentation/dev-tools/kasan.rst b/Documentation/dev-tools/kasan.rst
index f7a18f274357..a817f4c4285c 100644
--- a/Documentation/dev-tools/kasan.rst
+++ b/Documentation/dev-tools/kasan.rst
@@ -8,11 +8,18 @@ KernelAddressSANitizer (KASAN) is a dynamic memory error detector. It provides
 a fast and comprehensive solution for finding use-after-free and out-of-bounds
 bugs.
 
-KASAN uses compile-time instrumentation for checking every memory access,
-therefore you will need a GCC version 4.9.2 or later. GCC 5.0 or later is
-required for detection of out-of-bounds accesses to stack or global variables.
+KASAN has two modes: classic KASAN (a classic version, similar to user space
+ASan) and KHWASAN (a version based on memory tagging, similar to user space
+HWASan).
 
-Currently KASAN is supported only for the x86_64 and arm64 architectures.
+KASAN uses compile-time instrumentation to insert validity checks before every
+memory access, and therefore requires a compiler version that supports that.
+For classic KASAN you need GCC version 4.9.2 or later. GCC 5.0 or later is
+required for detection of out-of-bounds accesses on stack and global variables.
+TODO: compiler requirements for KHWASAN
+
+Currently classic KASAN is supported for the x86_64, arm64 and xtensa
+architectures, and KHWASAN is supported only for arm64.
 
 Usage
 -----
@@ -21,12 +28,14 @@ To enable KASAN configure kernel with::
 
 	  CONFIG_KASAN = y
 
-and choose between CONFIG_KASAN_OUTLINE and CONFIG_KASAN_INLINE. Outline and
-inline are compiler instrumentation types. The former produces smaller binary
-the latter is 1.1 - 2 times faster. Inline instrumentation requires a GCC
+and choose between CONFIG_KASAN_CLASSIC (to enable classic KASAN) and
+CONFIG_KASAN_TAGS (to enabled KHWASAN). You also need to choose choose between
+CONFIG_KASAN_OUTLINE and CONFIG_KASAN_INLINE. Outline and inline are compiler
+instrumentation types. The former produces smaller binary the latter is
+1.1 - 2 times faster. For classic KASAN inline instrumentation requires GCC
 version 5.0 or later.
 
-KASAN works with both SLUB and SLAB memory allocators.
+Both KASAN modes work with both SLUB and SLAB memory allocators.
 For better bug detection and nicer reporting, enable CONFIG_STACKTRACE.
 
 To disable instrumentation for specific files or directories, add a line
@@ -43,85 +52,80 @@ similar to the following to the respective kernel Makefile:
 Error reports
 ~~~~~~~~~~~~~
 
-A typical out of bounds access report looks like this::
+A typical out-of-bounds access classic KASAN report looks like this::
 
     ==================================================================
-    BUG: AddressSanitizer: out of bounds access in kmalloc_oob_right+0x65/0x75 [test_kasan] at addr ffff8800693bc5d3
-    Write of size 1 by task modprobe/1689
-    =============================================================================
-    BUG kmalloc-128 (Not tainted): kasan error
-    -----------------------------------------------------------------------------
-
-    Disabling lock debugging due to kernel taint
-    INFO: Allocated in kmalloc_oob_right+0x3d/0x75 [test_kasan] age=0 cpu=0 pid=1689
-     __slab_alloc+0x4b4/0x4f0
-     kmem_cache_alloc_trace+0x10b/0x190
-     kmalloc_oob_right+0x3d/0x75 [test_kasan]
-     init_module+0x9/0x47 [test_kasan]
-     do_one_initcall+0x99/0x200
-     load_module+0x2cb3/0x3b20
-     SyS_finit_module+0x76/0x80
-     system_call_fastpath+0x12/0x17
-    INFO: Slab 0xffffea0001a4ef00 objects=17 used=7 fp=0xffff8800693bd728 flags=0x100000000004080
-    INFO: Object 0xffff8800693bc558 @offset=1368 fp=0xffff8800693bc720
-
-    Bytes b4 ffff8800693bc548: 00 00 00 00 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ
-    Object ffff8800693bc558: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
-    Object ffff8800693bc568: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
-    Object ffff8800693bc578: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
-    Object ffff8800693bc588: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
-    Object ffff8800693bc598: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
-    Object ffff8800693bc5a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
-    Object ffff8800693bc5b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
-    Object ffff8800693bc5c8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
-    Redzone ffff8800693bc5d8: cc cc cc cc cc cc cc cc                          ........
-    Padding ffff8800693bc718: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
-    CPU: 0 PID: 1689 Comm: modprobe Tainted: G    B          3.18.0-rc1-mm1+ #98
-    Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.7.5-0-ge51488c-20140602_164612-nilsson.home.kraxel.org 04/01/2014
-     ffff8800693bc000 0000000000000000 ffff8800693bc558 ffff88006923bb78
-     ffffffff81cc68ae 00000000000000f3 ffff88006d407600 ffff88006923bba8
-     ffffffff811fd848 ffff88006d407600 ffffea0001a4ef00 ffff8800693bc558
+    BUG: KASAN: slab-out-of-bounds in kmalloc_oob_right+0xa8/0xbc [test_kasan]
+    Write of size 1 at addr ffff8800696f3d3b by task insmod/2734
+    
+    CPU: 0 PID: 2734 Comm: insmod Not tainted 4.15.0+ #98
+    Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
     Call Trace:
-     [<ffffffff81cc68ae>] dump_stack+0x46/0x58
-     [<ffffffff811fd848>] print_trailer+0xf8/0x160
-     [<ffffffffa00026a7>] ? kmem_cache_oob+0xc3/0xc3 [test_kasan]
-     [<ffffffff811ff0f5>] object_err+0x35/0x40
-     [<ffffffffa0002065>] ? kmalloc_oob_right+0x65/0x75 [test_kasan]
-     [<ffffffff8120b9fa>] kasan_report_error+0x38a/0x3f0
-     [<ffffffff8120a79f>] ? kasan_poison_shadow+0x2f/0x40
-     [<ffffffff8120b344>] ? kasan_unpoison_shadow+0x14/0x40
-     [<ffffffff8120a79f>] ? kasan_poison_shadow+0x2f/0x40
-     [<ffffffffa00026a7>] ? kmem_cache_oob+0xc3/0xc3 [test_kasan]
-     [<ffffffff8120a995>] __asan_store1+0x75/0xb0
-     [<ffffffffa0002601>] ? kmem_cache_oob+0x1d/0xc3 [test_kasan]
-     [<ffffffffa0002065>] ? kmalloc_oob_right+0x65/0x75 [test_kasan]
-     [<ffffffffa0002065>] kmalloc_oob_right+0x65/0x75 [test_kasan]
-     [<ffffffffa00026b0>] init_module+0x9/0x47 [test_kasan]
-     [<ffffffff810002d9>] do_one_initcall+0x99/0x200
-     [<ffffffff811e4e5c>] ? __vunmap+0xec/0x160
-     [<ffffffff81114f63>] load_module+0x2cb3/0x3b20
-     [<ffffffff8110fd70>] ? m_show+0x240/0x240
-     [<ffffffff81115f06>] SyS_finit_module+0x76/0x80
-     [<ffffffff81cd3129>] system_call_fastpath+0x12/0x17
+     __dump_stack lib/dump_stack.c:17
+     dump_stack+0x83/0xbc lib/dump_stack.c:53
+     print_address_description+0x73/0x280 mm/kasan/report.c:254
+     kasan_report_error mm/kasan/report.c:352
+     kasan_report+0x10e/0x220 mm/kasan/report.c:410
+     __asan_report_store1_noabort+0x17/0x20 mm/kasan/report.c:505
+     kmalloc_oob_right+0xa8/0xbc [test_kasan] lib/test_kasan.c:42
+     kmalloc_tests_init+0x16/0x769 [test_kasan]
+     do_one_initcall+0x9e/0x240 init/main.c:832
+     do_init_module+0x1b6/0x542 kernel/module.c:3462
+     load_module+0x6042/0x9030 kernel/module.c:3786
+     SYSC_init_module+0x18f/0x1c0 kernel/module.c:3858
+     SyS_init_module+0x9/0x10 kernel/module.c:3841
+     do_syscall_64+0x198/0x480 arch/x86/entry/common.c:287
+     entry_SYSCALL_64_after_hwframe+0x21/0x86 arch/x86/entry/entry_64.S:251
+    RIP: 0033:0x7fdd79df99da
+    RSP: 002b:00007fff2229bdf8 EFLAGS: 00000202 ORIG_RAX: 00000000000000af
+    RAX: ffffffffffffffda RBX: 000055c408121190 RCX: 00007fdd79df99da
+    RDX: 00007fdd7a0b8f88 RSI: 0000000000055670 RDI: 00007fdd7a47e000
+    RBP: 000055c4081200b0 R08: 0000000000000003 R09: 0000000000000000
+    R10: 00007fdd79df5d0a R11: 0000000000000202 R12: 00007fdd7a0b8f88
+    R13: 000055c408120090 R14: 0000000000000000 R15: 0000000000000000
+    
+    Allocated by task 2734:
+     save_stack+0x43/0xd0 mm/kasan/common.c:176
+     set_track+0x20/0x30 mm/kasan/common.c:188
+     kasan_kmalloc+0x9a/0xc0 mm/kasan/kasan.c:372
+     kmem_cache_alloc_trace+0xcd/0x1a0 mm/slub.c:2761
+     kmalloc ./include/linux/slab.h:512
+     kmalloc_oob_right+0x56/0xbc [test_kasan] lib/test_kasan.c:36
+     kmalloc_tests_init+0x16/0x769 [test_kasan]
+     do_one_initcall+0x9e/0x240 init/main.c:832
+     do_init_module+0x1b6/0x542 kernel/module.c:3462
+     load_module+0x6042/0x9030 kernel/module.c:3786
+     SYSC_init_module+0x18f/0x1c0 kernel/module.c:3858
+     SyS_init_module+0x9/0x10 kernel/module.c:3841
+     do_syscall_64+0x198/0x480 arch/x86/entry/common.c:287
+     entry_SYSCALL_64_after_hwframe+0x21/0x86 arch/x86/entry/entry_64.S:251
+    
+    The buggy address belongs to the object at ffff8800696f3cc0
+     which belongs to the cache kmalloc-128 of size 128
+    The buggy address is located 123 bytes inside of
+     128-byte region [ffff8800696f3cc0, ffff8800696f3d40)
+    The buggy address belongs to the page:
+    page:ffffea0001a5bcc0 count:1 mapcount:0 mapping:          (null) index:0x0
+    flags: 0x100000000000100(slab)
+    raw: 0100000000000100 0000000000000000 0000000000000000 0000000180150015
+    raw: ffffea0001a8ce40 0000000300000003 ffff88006d001640 0000000000000000
+    page dumped because: kasan: bad access detected
+    
     Memory state around the buggy address:
-     ffff8800693bc300: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
-     ffff8800693bc380: fc fc 00 00 00 00 00 00 00 00 00 00 00 00 00 fc
-     ffff8800693bc400: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
-     ffff8800693bc480: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
-     ffff8800693bc500: fc fc fc fc fc fc fc fc fc fc fc 00 00 00 00 00
-    >ffff8800693bc580: 00 00 00 00 00 00 00 00 00 00 03 fc fc fc fc fc
-                                                 ^
-     ffff8800693bc600: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
-     ffff8800693bc680: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
-     ffff8800693bc700: fc fc fc fc fb fb fb fb fb fb fb fb fb fb fb fb
-     ffff8800693bc780: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
-     ffff8800693bc800: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
+     ffff8800696f3c00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 fc
+     ffff8800696f3c80: fc fc fc fc fc fc fc fc 00 00 00 00 00 00 00 00
+    >ffff8800696f3d00: 00 00 00 00 00 00 00 03 fc fc fc fc fc fc fc fc
+                                            ^
+     ffff8800696f3d80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 fc fc
+     ffff8800696f3e00: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
     ==================================================================
 
-The header of the report discribe what kind of bug happened and what kind of
-access caused it. It's followed by the description of the accessed slub object
-(see 'SLUB Debug output' section in Documentation/vm/slub.txt for details) and
-the description of the accessed memory page.
+The header of the report provides a short summary of what kind of bug happened
+and what kind of access caused it. It's followed by a stack trace of the bad
+access, a stack trace of where the accessed memory was allocated (in case bad
+access happens on a slab object), and a stack trace of where the object was
+freed (in case of a use-after-free bug report). Next comes a description of
+the accessed slab object and information about the accessed memory page.
 
 In the last section the report shows memory state around the accessed address.
 Reading this part requires some understanding of how KASAN works.
@@ -138,18 +142,24 @@ inaccessible memory like redzones or freed memory (see mm/kasan/kasan.h).
 In the report above the arrows point to the shadow byte 03, which means that
 the accessed address is partially accessible.
 
+For KHWASAN this last report section shows the memory tags around the accessed
+address (see Implementation details section).
+
 
 Implementation details
 ----------------------
 
+Classic KASAN
+~~~~~~~~~~~~~
+
 From a high level, our approach to memory error detection is similar to that
 of kmemcheck: use shadow memory to record whether each byte of memory is safe
-to access, and use compile-time instrumentation to check shadow memory on each
-memory access.
+to access, and use compile-time instrumentation to insert checks of shadow
+memory on each memory access.
 
-AddressSanitizer dedicates 1/8 of kernel memory to its shadow memory
-(e.g. 16TB to cover 128TB on x86_64) and uses direct mapping with a scale and
-offset to translate a memory address to its corresponding shadow address.
+Classic KASAN dedicates 1/8th of kernel memory to its shadow memory (e.g. 16TB
+to cover 128TB on x86_64) and uses direct mapping with a scale and offset to
+translate a memory address to its corresponding shadow address.
 
 Here is the function which translates an address to its corresponding shadow
 address::
@@ -162,12 +172,34 @@ address::
 
 where ``KASAN_SHADOW_SCALE_SHIFT = 3``.
 
-Compile-time instrumentation used for checking memory accesses. Compiler inserts
-function calls (__asan_load*(addr), __asan_store*(addr)) before each memory
-access of size 1, 2, 4, 8 or 16. These functions check whether memory access is
-valid or not by checking corresponding shadow memory.
+Compile-time instrumentation is used to insert memory accesses checks. Compiler
+inserts function calls (__asan_load*(addr), __asan_store*(addr)) before each
+memory access of size 1, 2, 4, 8 or 16. These functions check whether memory
+access is valid or not by checking corresponding shadow memory.
 
 GCC 5.0 has possibility to perform inline instrumentation. Instead of making
 function calls GCC directly inserts the code to check the shadow memory.
 This option significantly enlarges kernel but it gives x1.1-x2 performance
 boost over outline instrumented kernel.
+
+KHWASAN
+~~~~~~~
+
+KHWASAN uses the Top Byte Ignore (TBI) feature of modern arm64 CPUs to store
+a pointer tag in the top byte of kernel pointers. KHWASAN also uses shadow
+memory to store memory tags associated with each 16-byte memory cell (therefore
+it dedicates 1/16th of the kernel memory for shadow memory).
+
+On each memory allocation KHWASAN generates a random tag, tags allocated memory
+with this tag, and embeds this tag into the returned pointer. KHWASAN uses
+compile-time instrumentation to insert checks before each memory access. These
+checks make sure that tag of the memory that is being accessed is equal to tag
+ofthe pointer that is used to access this memory. In case of a tag mismatch
+KHWASAN prints a bug report.
+
+KHWASAN also has two instrumentation modes (outline, that emits callbacks to
+check memory accesses; and inline, that performs the shadow memory checks
+inline). With outline instrumentation mode, a bug report is simply printed
+from the function that performs the access check. With inline instrumentation
+a brk instruction is emitted by the compiler, and a dedicated brk handler is
+used to print KHWASAN reports.
-- 
2.16.2.395.g2e18187dfd-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
