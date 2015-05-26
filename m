Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 534236B0158
	for <linux-mm@kvack.org>; Tue, 26 May 2015 09:35:05 -0400 (EDT)
Received: by obbea2 with SMTP id ea2so74203073obb.3
        for <linux-mm@kvack.org>; Tue, 26 May 2015 06:35:05 -0700 (PDT)
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com. [209.85.218.41])
        by mx.google.com with ESMTPS id q184si8764561oih.2.2015.05.26.06.35.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 06:35:04 -0700 (PDT)
Received: by oiww2 with SMTP id w2so77722263oiw.0
        for <linux-mm@kvack.org>; Tue, 26 May 2015 06:35:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
	<1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
Date: Tue, 26 May 2015 15:35:03 +0200
Message-ID: <CACRpkda3Pe9L14_iyKEfeCx1F3XJSLbz_OVHLxX0Lzy9Gt9t9Q@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
From: Linus Walleij <linus.walleij@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org

On Fri, May 15, 2015 at 3:59 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:

> This patch adds arch specific code for kernel address sanitizer
> (see Documentation/kasan.txt).

I'm trying to test this on the Juno hardware (39 VA bits).

I get this at boot:

Virtual kernel memory layout:
    kasan   : 0xffffff8000000000 - 0xffffff9000000000   (    64 MB)
    vmalloc : 0xffffff9000000000 - 0xffffffbdbfff0000   (   182 GB)

Nice, kasan is shadowing vmem perfectly. Also
shadowing itself it appears, well whatever.

I enable CONFIG_KASAN, CONFIG_KASAN_OUTLINE,
CONFIG_STACKTRACE, CONFIG_SLUB_DEBUG_ON,  and
CONFIG_TEST_KASAN.

I patch the test like this because I'm not using any loadable
modules:

diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index 39f24d6721e5..b3353dbe5f58 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -45,7 +45,7 @@ endchoice

 config TEST_KASAN
        tristate "Module for testing kasan for bug detection"
-       depends on m && KASAN
+       depends on KASAN
        help
          This is a test module doing various nasty things like
          out of bounds accesses, use after free. It is useful for testing
diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index 098c08eddfab..fb54486eacd6 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -273,5 +273,5 @@ static int __init kmalloc_tests_init(void)
        return -EAGAIN;
 }

-module_init(kmalloc_tests_init);
+late_initcall(kmalloc_tests_init);
 MODULE_LICENSE("GPL");

And then at boot I just get this:

kasan test: kmalloc_oob_right out-of-bounds to right
kasan test: kmalloc_oob_left out-of-bounds to left
kasan test: kmalloc_node_oob_right kmalloc_node(): out-of-bounds to right
kasan test: kmalloc_large_oob_rigth kmalloc large allocation:
out-of-bounds to right
kasan test: kmalloc_oob_krealloc_more out-of-bounds after krealloc more
kasan test: kmalloc_oob_krealloc_less out-of-bounds after krealloc less
kasan test: kmalloc_oob_16 kmalloc out-of-bounds for 16-bytes access
kasan test: kmalloc_oob_in_memset out-of-bounds in memset
kasan test: kmalloc_uaf use-after-free
kasan test: kmalloc_uaf_memset use-after-free in memset
kasan test: kmalloc_uaf2 use-after-free after another kmalloc
kasan test: kmem_cache_oob out-of-bounds in kmem_cache_alloc
kasan test: kasan_stack_oob out-of-bounds on stack
kasan test: kasan_global_oob out-of-bounds global variable

W00t no nice KASan warnings (which is what I expect).

This is my compiler by the way:
$ arm-linux-gnueabihf-gcc --version
arm-linux-gnueabihf-gcc (crosstool-NG linaro-1.13.1-4.9-2014.09 -
Linaro GCC 4.9-2014.09) 4.9.2 20140904 (prerelease)

I did the same exercise on the foundation model (FVP) and I guess
that is what you developed the patch set on because there I got
nice KASan dumps:

Virtual kernel memory layout:
    kasan   : 0xffffff8000000000 - 0xffffff9000000000   (    64 MB)
    vmalloc : 0xffffff9000000000 - 0xffffffbdbfff0000   (   182 GB)
(...)
kasan test: kmalloc_oob_right out-of-bounds to right
kasan test: kmalloc_oob_left out-of-bounds to left
kasan test: kmalloc_node_oob_right kmalloc_node(): out-of-bounds to right
=============================================================================
BUG kmalloc-4096 (Tainted: G S             ): Redzone overwritten
-----------------------------------------------------------------------------

Disabling lock debugging due to kernel taint
INFO: 0xffffffc0676bc480-0xffffffc0676bc480. First byte 0x0 instead of 0xcc
INFO: Allocated in kmalloc_node_oob_right+0x40/0x8c age=0 cpu=1 pid=1
        alloc_debug_processing+0x170/0x17c
        __slab_alloc.isra.59.constprop.61+0x354/0x374
        kmem_cache_alloc+0x1a4/0x1e0
        kmalloc_node_oob_right+0x3c/0x8c
        kmalloc_tests_init+0x10/0x4c
        do_one_initcall+0x88/0x1a0
        kernel_init_freeable+0x16c/0x210
        kernel_init+0xc/0xd8
        ret_from_fork+0xc/0x50
INFO: Freed in cleanup_uevent_env+0x10/0x18 age=0 cpu=3 pid=724
        free_debug_processing+0x214/0x30c
        __slab_free+0x2b0/0x3f8
        kfree+0x1a4/0x1dc
        cleanup_uevent_env+0xc/0x18
        call_usermodehelper_freeinfo+0x18/0x30
        umh_complete+0x34/0x40
        ____call_usermodehelper+0x170/0x18c
        ret_from_fork+0xc/0x50
INFO: Slab 0xffffffbdc39dae00 objects=7 used=1 fp=0xffffffc0676b9180
flags=0x4081
INFO: Object 0xffffffc0676bb480 @offset=13440 fp=0xffffffc0676b8000

Bytes b4 ffffffc0676bb470: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a  ZZZZZZZZZZZZZZZZ
Object ffffffc0676bb480: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b  kkkkkkkkkkkkkkkk
Object ffffffc0676bb490: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b  kkkkkkkkkkkkkkkk
Object ffffffc0676bb4a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b  kkkkkkkkkkkkkkkk
Object ffffffc0676bb4b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b  kkkkkkkkkkkkkkkk
(...)
kasan test: kmalloc_large_oob_rigth kmalloc large allocation:
out-of-bounds to right
kasan test: kmalloc_oob_krealloc_more out-of-bounds after krealloc more
kasan test: kmalloc_oob_krealloc_less out-of-bounds after krealloc less
kasan test: kmalloc_oob_16 kmalloc out-of-bounds for 16-bytes access
kasan test: kmalloc_oob_in_memset out-of-bounds in memset
kasan test: kmalloc_uaf use-after-free
kasan test: kmalloc_uaf_memset use-after-free in memset
=============================================================================
BUG kmalloc-64 (Tainted: G S  B          ): Poison overwritten
-----------------------------------------------------------------------------

INFO: 0xffffffc0666e3c08-0xffffffc0666e3c08. First byte 0x78 instead of 0x6b
INFO: Allocated in kmalloc_uaf+0x40/0x8c age=0 cpu=1 pid=1
        alloc_debug_processing+0x170/0x17c
        __slab_alloc.isra.59.constprop.61+0x354/0x374
        kmem_cache_alloc+0x1a4/0x1e0
        kmalloc_uaf+0x3c/0x8c
        kmalloc_tests_init+0x28/0x4c
        do_one_initcall+0x88/0x1a0
        kernel_init_freeable+0x16c/0x210
        kernel_init+0xc/0xd8
        ret_from_fork+0xc/0x50
INFO: Freed in kmalloc_uaf+0x74/0x8c age=0 cpu=1 pid=1
        free_debug_processing+0x214/0x30c
        __slab_free+0x2b0/0x3f8
        kfree+0x1a4/0x1dc
        kmalloc_uaf+0x70/0x8c
        kmalloc_tests_init+0x28/0x4c
        do_one_initcall+0x88/0x1a0
        kernel_init_freeable+0x16c/0x210
        kernel_init+0xc/0xd8
        ret_from_fork+0xc/0x50
INFO: Slab 0xffffffbdc399b880 objects=18 used=18 fp=0x          (null)
flags=0x4080
INFO: Object 0xffffffc0666e3c00 @offset=7168 fp=0xffffffc0666e3a40

Bytes b4 ffffffc0666e3bf0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a  ZZZZZZZZZZZZZZZZ
Object ffffffc0666e3c00: 6b 6b 6b 6b 6b 6b 6b 6b 78 6b 6b 6b 6b 6b 6b
6b  kkkkkkkkxkkkkkkk
Object ffffffc0666e3c10: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b  kkkkkkkkkkkkkkkk
Object ffffffc0666e3c20: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b  kkkkkkkkkkkkkkkk
Object ffffffc0666e3c30: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
a5  kkkkkkkkkkkkkkk.
Redzone ffffffc0666e3c40: bb bb bb bb bb bb bb bb
    ........
Padding ffffffc0666e3d80: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a  ZZZZZZZZZZZZZZZZ
Padding ffffffc0666e3d90: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a  ZZZZZZZZZZZZZZZZ
Padding ffffffc0666e3da0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a  ZZZZZZZZZZZZZZZZ
Padding ffffffc0666e3db0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a  ZZZZZZZZZZZZZZZZ
(...)

So it works nicely on emulated hardware it seems.

I wonder were the problem lies, any hints where to start looking
to fix this?

Yours,
Linus Walleij

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
