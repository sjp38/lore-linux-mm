Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 02BBD6B4965
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 11:56:37 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id j6so18248168wrw.1
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:56:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r5sor3142438wrw.12.2018.11.27.08.56.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Nov 2018 08:56:34 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v12 24/25] kasan: update documentation
Date: Tue, 27 Nov 2018 17:55:42 +0100
Message-Id: <1ace22e3a154ce363661bda6328f8c5eb05a091c.1543337629.git.andreyknvl@google.com>
In-Reply-To: <cover.1543337629.git.andreyknvl@google.com>
References: <cover.1543337629.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>, Andrey Konovalov <andreyknvl@google.com>

This patch updates KASAN documentation to reflect the addition of the new
tag-based mode.

Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 Documentation/dev-tools/kasan.rst | 232 ++++++++++++++++++------------
 1 file changed, 138 insertions(+), 94 deletions(-)

diff --git a/Documentation/dev-tools/kasan.rst b/Documentation/dev-tools/kasan.rst
index aabc8738b3d8..8e956e0588fc 100644
--- a/Documentation/dev-tools/kasan.rst
+++ b/Documentation/dev-tools/kasan.rst
@@ -4,15 +4,25 @@ The Kernel Address Sanitizer (KASAN)
 Overview
 --------
 
-KernelAddressSANitizer (KASAN) is a dynamic memory error detector. It provides
-a fast and comprehensive solution for finding use-after-free and out-of-bounds
-bugs.
+KernelAddressSANitizer (KASAN) is a dynamic memory error detector designed to
+find out-of-bound and use-after-free bugs. KASAN has two modes: generic KASAN
+(similar to userspace ASan) and software tag-based KASAN (similar to userspace
+HWASan).
 
-KASAN uses compile-time instrumentation for checking every memory access,
-therefore you will need a GCC version 4.9.2 or later. GCC 5.0 or later is
-required for detection of out-of-bounds accesses to stack or global variables.
+KASAN uses compile-time instrumentation to insert validity checks before every
+memory access, and therefore requires a compiler version that supports that.
 
-Currently KASAN is supported only for the x86_64 and arm64 architectures.
+Generic KASAN is supported in both GCC and Clang. With GCC it requires version
+4.9.2 or later for basic support and version 5.0 or later for detection of
+out-of-bounds accesses for stack and global variables and for inline
+instrumentation mode (see the Usage section). With Clang it requires version
+7.0.0 or later and it doesn't support detection of out-of-bounds accesses for
+global variables yet.
+
+Tag-based KASAN is only supported in Clang and requires version 7.0.0 or later.
+
+Currently generic KASAN is supported for the x86_64, arm64, xtensa and s390
+architectures, and tag-based KASAN is supported only for arm64.
 
 Usage
 -----
@@ -21,12 +31,14 @@ To enable KASAN configure kernel with::
 
 	  CONFIG_KASAN = y
 
-and choose between CONFIG_KASAN_OUTLINE and CONFIG_KASAN_INLINE. Outline and
-inline are compiler instrumentation types. The former produces smaller binary
-the latter is 1.1 - 2 times faster. Inline instrumentation requires a GCC
-version 5.0 or later.
+and choose between CONFIG_KASAN_GENERIC (to enable generic KASAN) and
+CONFIG_KASAN_SW_TAGS (to enable software tag-based KASAN).
 
-KASAN works with both SLUB and SLAB memory allocators.
+You also need to choose between CONFIG_KASAN_OUTLINE and CONFIG_KASAN_INLINE.
+Outline and inline are compiler instrumentation types. The former produces
+smaller binary while the latter is 1.1 - 2 times faster.
+
+Both KASAN modes work with both SLUB and SLAB memory allocators.
 For better bug detection and nicer reporting, enable CONFIG_STACKTRACE.
 
 To disable instrumentation for specific files or directories, add a line
@@ -43,85 +55,85 @@ similar to the following to the respective kernel Makefile:
 Error reports
 ~~~~~~~~~~~~~
 
-A typical out of bounds access report looks like this::
+A typical out-of-bounds access generic KASAN report looks like this::
 
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
+    Write of size 1 at addr ffff8801f44ec37b by task insmod/2760
+    
+    CPU: 1 PID: 2760 Comm: insmod Not tainted 4.19.0-rc3+ #698
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
+     dump_stack+0x94/0xd8
+     print_address_description+0x73/0x280
+     kasan_report+0x144/0x187
+     __asan_report_store1_noabort+0x17/0x20
+     kmalloc_oob_right+0xa8/0xbc [test_kasan]
+     kmalloc_tests_init+0x16/0x700 [test_kasan]
+     do_one_initcall+0xa5/0x3ae
+     do_init_module+0x1b6/0x547
+     load_module+0x75df/0x8070
+     __do_sys_init_module+0x1c6/0x200
+     __x64_sys_init_module+0x6e/0xb0
+     do_syscall_64+0x9f/0x2c0
+     entry_SYSCALL_64_after_hwframe+0x44/0xa9
+    RIP: 0033:0x7f96443109da
+    RSP: 002b:00007ffcf0b51b08 EFLAGS: 00000202 ORIG_RAX: 00000000000000af
+    RAX: ffffffffffffffda RBX: 000055dc3ee521a0 RCX: 00007f96443109da
+    RDX: 00007f96445cff88 RSI: 0000000000057a50 RDI: 00007f9644992000
+    RBP: 000055dc3ee510b0 R08: 0000000000000003 R09: 0000000000000000
+    R10: 00007f964430cd0a R11: 0000000000000202 R12: 00007f96445cff88
+    R13: 000055dc3ee51090 R14: 0000000000000000 R15: 0000000000000000
+    
+    Allocated by task 2760:
+     save_stack+0x43/0xd0
+     kasan_kmalloc+0xa7/0xd0
+     kmem_cache_alloc_trace+0xe1/0x1b0
+     kmalloc_oob_right+0x56/0xbc [test_kasan]
+     kmalloc_tests_init+0x16/0x700 [test_kasan]
+     do_one_initcall+0xa5/0x3ae
+     do_init_module+0x1b6/0x547
+     load_module+0x75df/0x8070
+     __do_sys_init_module+0x1c6/0x200
+     __x64_sys_init_module+0x6e/0xb0
+     do_syscall_64+0x9f/0x2c0
+     entry_SYSCALL_64_after_hwframe+0x44/0xa9
+    
+    Freed by task 815:
+     save_stack+0x43/0xd0
+     __kasan_slab_free+0x135/0x190
+     kasan_slab_free+0xe/0x10
+     kfree+0x93/0x1a0
+     umh_complete+0x6a/0xa0
+     call_usermodehelper_exec_async+0x4c3/0x640
+     ret_from_fork+0x35/0x40
+    
+    The buggy address belongs to the object at ffff8801f44ec300
+     which belongs to the cache kmalloc-128 of size 128
+    The buggy address is located 123 bytes inside of
+     128-byte region [ffff8801f44ec300, ffff8801f44ec380)
+    The buggy address belongs to the page:
+    page:ffffea0007d13b00 count:1 mapcount:0 mapping:ffff8801f7001640 index:0x0
+    flags: 0x200000000000100(slab)
+    raw: 0200000000000100 ffffea0007d11dc0 0000001a0000001a ffff8801f7001640
+    raw: 0000000000000000 0000000080150015 00000001ffffffff 0000000000000000
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
+     ffff8801f44ec200: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
+     ffff8801f44ec280: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
+    >ffff8801f44ec300: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03
+                                                                    ^
+     ffff8801f44ec380: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
+     ffff8801f44ec400: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
     ==================================================================
 
-The header of the report discribe what kind of bug happened and what kind of
-access caused it. It's followed by the description of the accessed slub object
-(see 'SLUB Debug output' section in Documentation/vm/slub.rst for details) and
-the description of the accessed memory page.
+The header of the report provides a short summary of what kind of bug happened
+and what kind of access caused it. It's followed by a stack trace of the bad
+access, a stack trace of where the accessed memory was allocated (in case bad
+access happens on a slab object), and a stack trace of where the object was
+freed (in case of a use-after-free bug report). Next comes a description of
+the accessed slab object and information about the accessed memory page.
 
 In the last section the report shows memory state around the accessed address.
 Reading this part requires some understanding of how KASAN works.
@@ -138,18 +150,24 @@ inaccessible memory like redzones or freed memory (see mm/kasan/kasan.h).
 In the report above the arrows point to the shadow byte 03, which means that
 the accessed address is partially accessible.
 
+For tag-based KASAN this last report section shows the memory tags around the
+accessed address (see Implementation details section).
+
 
 Implementation details
 ----------------------
 
+Generic KASAN
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
+Generic KASAN dedicates 1/8th of kernel memory to its shadow memory (e.g. 16TB
+to cover 128TB on x86_64) and uses direct mapping with a scale and offset to
+translate a memory address to its corresponding shadow address.
 
 Here is the function which translates an address to its corresponding shadow
 address::
@@ -162,12 +180,38 @@ address::
 
 where ``KASAN_SHADOW_SCALE_SHIFT = 3``.
 
-Compile-time instrumentation used for checking memory accesses. Compiler inserts
-function calls (__asan_load*(addr), __asan_store*(addr)) before each memory
-access of size 1, 2, 4, 8 or 16. These functions check whether memory access is
-valid or not by checking corresponding shadow memory.
+Compile-time instrumentation is used to insert memory access checks. Compiler
+inserts function calls (__asan_load*(addr), __asan_store*(addr)) before each
+memory access of size 1, 2, 4, 8 or 16. These functions check whether memory
+access is valid or not by checking corresponding shadow memory.
 
 GCC 5.0 has possibility to perform inline instrumentation. Instead of making
 function calls GCC directly inserts the code to check the shadow memory.
 This option significantly enlarges kernel but it gives x1.1-x2 performance
 boost over outline instrumented kernel.
+
+Software tag-based KASAN
+~~~~~~~~~~~~~~~~~~~~~~~~
+
+Tag-based KASAN uses the Top Byte Ignore (TBI) feature of modern arm64 CPUs to
+store a pointer tag in the top byte of kernel pointers. Like generic KASAN it
+uses shadow memory to store memory tags associated with each 16-byte memory
+cell (therefore it dedicates 1/16th of the kernel memory for shadow memory).
+
+On each memory allocation tag-based KASAN generates a random tag, tags the
+allocated memory with this tag, and embeds this tag into the returned pointer.
+Software tag-based KASAN uses compile-time instrumentation to insert checks
+before each memory access. These checks make sure that tag of the memory that
+is being accessed is equal to tag of the pointer that is used to access this
+memory. In case of a tag mismatch tag-based KASAN prints a bug report.
+
+Software tag-based KASAN also has two instrumentation modes (outline, that
+emits callbacks to check memory accesses; and inline, that performs the shadow
+memory checks inline). With outline instrumentation mode, a bug report is
+simply printed from the function that performs the access check. With inline
+instrumentation a brk instruction is emitted by the compiler, and a dedicated
+brk handler is used to print bug reports.
+
+A potential expansion of this mode is a hardware tag-based mode, which would
+use hardware memory tagging support instead of compiler instrumentation and
+manual shadow memory manipulation.
-- 
2.20.0.rc0.387.gc7a69e6b6c-goog
