Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E51146B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 17:36:49 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id c36so7509727qtc.12
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 14:36:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j18sor2701230qtc.98.2017.10.11.14.36.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Oct 2017 14:36:48 -0700 (PDT)
Subject: Re: [PATCH 00/11] KASan for arm
From: Florian Fainelli <f.fainelli@gmail.com>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <26660524-3b0a-c634-e8ce-4ba7e10c055d@gmail.com>
 <bb809843-4fb8-0827-170e-26efde0eb37f@gmail.com>
Message-ID: <44c86924-930b-3eff-55b8-b02c9060ebe3@gmail.com>
Date: Wed, 11 Oct 2017 14:36:41 -0700
MIME-Version: 1.0
In-Reply-To: <bb809843-4fb8-0827-170e-26efde0eb37f@gmail.com>
Content-Type: multipart/mixed;
 boundary="------------51DFA7131273B4173E983701"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Abbott Liu <liuwenliang@huawei.com>, linux@armlinux.org.uk, aryabinin@virtuozzo.com, afzal.mohd.ma@gmail.com, labbott@redhat.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, cdall@linaro.org, marc.zyngier@arm.com, catalin.marinas@arm.com, akpm@linux-foundation.org, mawilcox@microsoft.com, tglx@linutronix.de, thgarnie@google.com, keescook@chromium.org, arnd@arndb.de, vladimir.murzin@arm.com, tixy@linaro.org, ard.biesheuvel@linaro.org, robin.murphy@arm.com, mingo@kernel.org, grygorii.strashko@linaro.org
Cc: glider@google.com, dvyukov@google.com, opendmb@gmail.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, jiazhenghua@huawei.com, dylix.dailei@huawei.com, zengweilin@huawei.com, heshaoliang@huawei.com

This is a multi-part message in MIME format.
--------------51DFA7131273B4173E983701
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

On 10/11/2017 12:50 PM, Florian Fainelli wrote:
> On 10/11/2017 12:13 PM, Florian Fainelli wrote:
>> Hi Abbott,
>>
>> On 10/11/2017 01:22 AM, Abbott Liu wrote:
>>> Hi,all:
>>>    These patches add arch specific code for kernel address sanitizer 
>>> (see Documentation/kasan.txt). 
>>>
>>>    1/8 of kernel addresses reserved for shadow memory. There was no 
>>> big enough hole for this, so virtual addresses for shadow were 
>>> stolen from user space.
>>>    
>>>    At early boot stage the whole shadow region populated with just 
>>> one physical page (kasan_zero_page). Later, this page reused 
>>> as readonly zero shadow for some memory that KASan currently 
>>> don't track (vmalloc). 
>>>
>>>   After mapping the physical memory, pages for shadow memory are 
>>> allocated and mapped. 
>>>
>>>   KASan's stack instrumentation significantly increases stack's 
>>> consumption, so CONFIG_KASAN doubles THREAD_SIZE.
>>>   
>>>   Functions like memset/memmove/memcpy do a lot of memory accesses. 
>>> If bad pointer passed to one of these function it is important 
>>> to catch this. Compiler's instrumentation cannot do this since 
>>> these functions are written in assembly. 
>>>
>>>   KASan replaces memory functions with manually instrumented variants. 
>>> Original functions declared as weak symbols so strong definitions 
>>> in mm/kasan/kasan.c could replace them. Original functions have aliases 
>>> with '__' prefix in name, so we could call non-instrumented variant 
>>> if needed. 
>>>
>>>   Some files built without kasan instrumentation (e.g. mm/slub.c). 
>>> Original mem* function replaced (via #define) with prefixed variants 
>>> to disable memory access checks for such files. 
>>>
>>>   On arm LPAE architecture,  the mapping table of KASan shadow memory(if 
>>> PAGE_OFFSET is 0xc0000000, the KASan shadow memory's virtual space is 
>>> 0xb6e000000~0xbf000000) can't be filled in do_translation_fault function, 
>>> because kasan instrumentation maybe cause do_translation_fault function 
>>> accessing KASan shadow memory. The accessing of KASan shadow memory in 
>>> do_translation_fault function maybe cause dead circle. So the mapping table 
>>> of KASan shadow memory need be copyed in pgd_alloc function.
>>>
>>>
>>> Most of the code comes from:
>>> https://github.com/aryabinin/linux/commit/0b54f17e70ff50a902c4af05bb92716eb95acefe.
>>
>> Thanks for putting these patches together, I can't get a kernel to build
>> with ARM_LPAE=y or ARM_LPAE=n that does not result in the following:
>>
>>   AS      arch/arm/kernel/entry-common.o
>> arch/arm/kernel/entry-common.S: Assembler messages:
>> arch/arm/kernel/entry-common.S:53: Error: invalid constant
>> (ffffffffb6e00000) after fixup
>> arch/arm/kernel/entry-common.S:118: Error: invalid constant
>> (ffffffffb6e00000) after fixup
>> scripts/Makefile.build:412: recipe for target
>> 'arch/arm/kernel/entry-common.o' failed
>> make[3]: *** [arch/arm/kernel/entry-common.o] Error 1
>> Makefile:1019: recipe for target 'arch/arm/kernel' failed
>> make[2]: *** [arch/arm/kernel] Error 2
>> make[2]: *** Waiting for unfinished jobs....
>>
>> This is coming from the increase in TASK_SIZE it seems.
>>
>> This is on top of v4.14-rc4-84-gff5abbe799e2
> 
> Seems like we can use the following to get through that build failure:
> 
> diff --git a/arch/arm/kernel/entry-common.S b/arch/arm/kernel/entry-common.S
> index 99c908226065..0de1160d136e 100644
> --- a/arch/arm/kernel/entry-common.S
> +++ b/arch/arm/kernel/entry-common.S
> @@ -50,7 +50,13 @@ ret_fast_syscall:
>   UNWIND(.cantunwind    )
>         disable_irq_notrace                     @ disable interrupts
>         ldr     r2, [tsk, #TI_ADDR_LIMIT]
> +#ifdef CONFIG_KASAN
> +       movw    r1, #:lower16:TASK_SIZE
> +       movt    r1, #:upper16:TASK_SIZE
> +       cmp     r2, r1
> +#else
>         cmp     r2, #TASK_SIZE
> +#endif
>         blne    addr_limit_check_failed
>         ldr     r1, [tsk, #TI_FLAGS]            @ re-check for syscall
> tracing
>         tst     r1, #_TIF_SYSCALL_WORK | _TIF_WORK_MASK
> @@ -115,7 +121,13 @@ ret_slow_syscall:
>         disable_irq_notrace                     @ disable interrupts
>  ENTRY(ret_to_user_from_irq)
>         ldr     r2, [tsk, #TI_ADDR_LIMIT]
> +#ifdef CONFIG_KASAN
> +       movw    r1, #:lower16:TASK_SIZE
> +       movt    r1, #:upper16:TASK_SIZE
> +       cmp     r2, r1
> +#else
>         cmp     r2, #TASK_SIZE
> +#endif
>         blne    addr_limit_check_failed
>         ldr     r1, [tsk, #TI_FLAGS]
>         tst     r1, #_TIF_WORK_MASK
> 
> 
> 
> but then we will see another set of build failures with the decompressor
> code:
> 
> WARNING: modpost: Found 2 section mismatch(es).
> To see full details build your kernel with:
> 'make CONFIG_DEBUG_SECTION_MISMATCH=y'
>   KSYM    .tmp_kallsyms1.o
>   KSYM    .tmp_kallsyms2.o
>   LD      vmlinux
>   SORTEX  vmlinux
>   SYSMAP  System.map
>   OBJCOPY arch/arm/boot/Image
>   Kernel: arch/arm/boot/Image is ready
>   LDS     arch/arm/boot/compressed/vmlinux.lds
>   AS      arch/arm/boot/compressed/head.o
>   XZKERN  arch/arm/boot/compressed/piggy_data
>   CC      arch/arm/boot/compressed/misc.o
>   CC      arch/arm/boot/compressed/decompress.o
>   CC      arch/arm/boot/compressed/string.o
> arch/arm/boot/compressed/decompress.c:51:0: warning: "memmove" redefined
>  #define memmove memmove
> 
> In file included from arch/arm/boot/compressed/decompress.c:7:0:
> ./arch/arm/include/asm/string.h:67:0: note: this is the location of the
> previous definition
>  #define memmove(dst, src, len) __memmove(dst, src, len)
> 
> arch/arm/boot/compressed/decompress.c:52:0: warning: "memcpy" redefined
>  #define memcpy memcpy
> 
> In file included from arch/arm/boot/compressed/decompress.c:7:0:
> ./arch/arm/include/asm/string.h:66:0: note: this is the location of the
> previous definition
>  #define memcpy(dst, src, len) __memcpy(dst, src, len)
> 
>   SHIPPED arch/arm/boot/compressed/hyp-stub.S
>   SHIPPED arch/arm/boot/compressed/fdt_rw.c
>   SHIPPED arch/arm/boot/compressed/fdt.h
>   SHIPPED arch/arm/boot/compressed/libfdt.h
>   SHIPPED arch/arm/boot/compressed/libfdt_internal.h
>   SHIPPED arch/arm/boot/compressed/fdt_ro.c
>   SHIPPED arch/arm/boot/compressed/fdt_wip.c
>   SHIPPED arch/arm/boot/compressed/fdt.c
>   CC      arch/arm/boot/compressed/atags_to_fdt.o
>   SHIPPED arch/arm/boot/compressed/lib1funcs.S
>   SHIPPED arch/arm/boot/compressed/ashldi3.S
>   SHIPPED arch/arm/boot/compressed/bswapsdi2.S
>   AS      arch/arm/boot/compressed/hyp-stub.o
>   CC      arch/arm/boot/compressed/fdt_rw.o
>   CC      arch/arm/boot/compressed/fdt_ro.o
>   CC      arch/arm/boot/compressed/fdt_wip.o
>   CC      arch/arm/boot/compressed/fdt.o
>   AS      arch/arm/boot/compressed/lib1funcs.o
>   AS      arch/arm/boot/compressed/ashldi3.o
>   AS      arch/arm/boot/compressed/bswapsdi2.o
>   AS      arch/arm/boot/compressed/piggy.o
>   LD      arch/arm/boot/compressed/vmlinux
> arch/arm/boot/compressed/decompress.o: In function `fill_temp':
> /home/fainelli/dev/linux/arch/arm/boot/compressed/../../../../lib/xz/xz_dec_stream.c:162:
> undefined reference to `memcpy'
> arch/arm/boot/compressed/decompress.o: In function `bcj_flush':
> /home/fainelli/dev/linux/arch/arm/boot/compressed/../../../../lib/xz/xz_dec_bcj.c:404:
> undefined reference to `memcpy'
> /home/fainelli/dev/linux/arch/arm/boot/compressed/../../../../lib/xz/xz_dec_bcj.c:409:
> undefined reference to `memmove'
> arch/arm/boot/compressed/decompress.o: In function `lzma2_lzma':
> /home/fainelli/dev/linux/arch/arm/boot/compressed/../../../../lib/xz/xz_dec_lzma2.c:919:
> undefined reference to `memcpy'
> arch/arm/boot/compressed/decompress.o: In function `dict_flush':
> /home/fainelli/dev/linux/arch/arm/boot/compressed/../../../../lib/xz/xz_dec_lzma2.c:424:
> undefined reference to `memcpy'
> arch/arm/boot/compressed/decompress.o: In function `dict_uncompressed':
> /home/fainelli/dev/linux/arch/arm/boot/compressed/../../../../lib/xz/xz_dec_lzma2.c:390:
> undefined reference to `memcpy'
> /home/fainelli/dev/linux/arch/arm/boot/compressed/../../../../lib/xz/xz_dec_lzma2.c:400:
> undefined reference to `memcpy'
> arch/arm/boot/compressed/decompress.o: In function `lzma2_lzma':
> /home/fainelli/dev/linux/arch/arm/boot/compressed/../../../../lib/xz/xz_dec_lzma2.c:859:
> undefined reference to `memcpy'
> /home/fainelli/dev/linux/arch/arm/boot/compressed/../../../../lib/xz/xz_dec_lzma2.c:884:
> undefined reference to `memmove'
> arch/arm/boot/compressed/decompress.o: In function `xz_dec_bcj_run':
> /home/fainelli/dev/linux/arch/arm/boot/compressed/../../../../lib/xz/xz_dec_bcj.c:451:
> undefined reference to `memcpy'
> /home/fainelli/dev/linux/arch/arm/boot/compressed/../../../../lib/xz/xz_dec_bcj.c:471:
> undefined reference to `memcpy'
> arch/arm/boot/compressed/fdt_rw.o: In function `fdt_add_subnode_namelen':
> /home/fainelli/dev/linux/arch/arm/boot/compressed/fdt_rw.c:366:
> undefined reference to `__memset'
> arch/arm/boot/compressed/Makefile:182: recipe for target
> 'arch/arm/boot/compressed/vmlinux' failed
> make[4]: *** [arch/arm/boot/compressed/vmlinux] Error 1
> arch/arm/boot/Makefile:53: recipe for target
> 'arch/arm/boot/compressed/vmlinux' failed
> make[3]: *** [arch/arm/boot/compressed/vmlinux] Error 2

I ended up fixing the redefinition warnings/build failures this way, but
I am not 100% confident this is the right fix:

diff --git a/arch/arm/boot/compressed/decompress.c
b/arch/arm/boot/compressed/decompress.c
index f3a4bedd1afc..7d4a47752760 100644
--- a/arch/arm/boot/compressed/decompress.c
+++ b/arch/arm/boot/compressed/decompress.c
@@ -48,8 +48,10 @@ extern int memcmp(const void *cs, const void *ct,
size_t count);
 #endif

 #ifdef CONFIG_KERNEL_XZ
+#ifndef CONFIG_KASAN
 #define memmove memmove
 #define memcpy memcpy
+#endif
 #include "../../../../lib/decompress_unxz.c"
 #endif

Was not able yet to track down why __memset is not being resolved, but
since I don't need them, disabled CONFIG_ATAGS and
CONFIG_ARM_ATAG_DTB_COMPAT and this allowed me to get a build working.

This brought me all the way to a prompt and please find attached the
results of insmod test_kasan.ko for CONFIG_ARM_LPAE=y and
CONFIG_ARM_LPAE=n. Your patches actually spotted a genuine use after
free in one of our drivers (spi-bcm-qspi) so with this:

Tested-by: Florian Fainelli <f.fainelli@gmail.com>

Great job thanks!
-- 
Florian

--------------51DFA7131273B4173E983701
Content-Type: text/x-log;
 name="no-lpae.log"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="no-lpae.log"

# insmod test_kasan.ko=20
[   90.732418] kasan test: kmalloc_oob_right out-of-bounds to right
[   90.739598] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   90.747735] BUG: KASAN: slab-out-of-bounds in kmalloc_oob_right+0x54/0=
x6c [test_kasan]
[   90.756194] Write of size 1 at addr cb32df7b by task insmod/1456
[   90.762532]=20
[   90.764350] CPU: 0 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   90.774742] Hardware name: Broadcom STB (Flattened Device Tree)
[   90.781235] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   90.789608] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   90.797493] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   90.806809] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   90.816763] [<c02a7ab8>] (kasan_report) from [<bf0041bc>] (kmalloc_oob=
_right+0x54/0x6c [test_kasan])
[   90.827327] [<bf0041bc>] (kmalloc_oob_right [test_kasan]) from [<bf004=
da0>] (kmalloc_tests_init+0x10/0x270 [test_kasan])
[   90.839327] [<bf004da0>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   90.849645] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   90.858458] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   90.867177] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   90.875827] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   90.884407]=20
[   90.886124] Allocated by task 1456:
[   90.890022]  kmem_cache_alloc_trace+0xb4/0x170
[   90.895194]  kmalloc_oob_right+0x30/0x6c [test_kasan]
[   90.901002]  kmalloc_tests_init+0x10/0x270 [test_kasan]
[   90.906625]  do_one_initcall+0x60/0x1b0
[   90.910831]  do_init_module+0xd4/0x2cc
[   90.914949]  load_module+0x3110/0x3af0
[   90.919071]  SyS_init_module+0x19c/0x1d4
[   90.923385]  ret_fast_syscall+0x0/0x50
[   90.927396]=20
[   90.929103] Freed by task 0:
[   90.932240] (stack is not available)
[   90.936080]=20
[   90.937846] The buggy address belongs to the object at cb32df00
[   90.937846]  which belongs to the cache kmalloc-128 of size 128
[   90.950387] The buggy address is located 123 bytes inside of
[   90.950387]  128-byte region [cb32df00, cb32df80)
[   90.961330] The buggy address belongs to the page:
[   90.966480] page:ee95e5a0 count:1 mapcount:0 mapping:cb32d000 index:0x=
0
[   90.973499] flags: 0x100(slab)
[   90.977019] raw: 00000100 cb32d000 00000000 00000015 00000001 ee837f34=
 ee965014 d00000c0
[   90.985610] page dumped because: kasan: bad access detected
[   90.991497]=20
[   90.993201] Memory state around the buggy address:
[   90.998387]  cb32de00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   91.005363]  cb32de80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   91.012342] >cb32df00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03=

[   91.019248]                                                         ^
[   91.026142]  cb32df80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   91.033126]  cb32e000: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff=

[   91.040032] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   91.048462] kasan test: kmalloc_oob_left out-of-bounds to left
[   91.055542] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   91.063691] BUG: KASAN: slab-out-of-bounds in kmalloc_oob_left+0x54/0x=
74 [test_kasan]
[   91.072056] Read of size 1 at addr cb32c3ff by task insmod/1456
[   91.078302]=20
[   91.080116] CPU: 0 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   91.090505] Hardware name: Broadcom STB (Flattened Device Tree)
[   91.097004] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   91.105390] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   91.113278] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   91.122595] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   91.132521] [<c02a7ab8>] (kasan_report) from [<bf004228>] (kmalloc_oob=
_left+0x54/0x74 [test_kasan])
[   91.143025] [<bf004228>] (kmalloc_oob_left [test_kasan]) from [<bf004d=
a4>] (kmalloc_tests_init+0x14/0x270 [test_kasan])
[   91.154958] [<bf004da4>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   91.165284] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   91.174106] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   91.182824] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   91.191495] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   91.200072]=20
[   91.201782] Allocated by task 0:
[   91.205273] (stack is not available)
[   91.209111]=20
[   91.210818] Freed by task 0:
[   91.213965] (stack is not available)
[   91.217804]=20
[   91.219577] The buggy address belongs to the object at cb32c380
[   91.219577]  which belongs to the cache kmalloc-64 of size 64
[   91.231940] The buggy address is located 63 bytes to the right of
[   91.231940]  64-byte region [cb32c380, cb32c3c0)
[   91.243258] The buggy address belongs to the page:
[   91.248411] page:ee95e580 count:1 mapcount:0 mapping:cb32c000 index:0x=
0
[   91.255439] flags: 0x100(slab)
[   91.258968] raw: 00000100 cb32c000 00000000 00000020 00000001 ee81ea94=
 ee962934 d0000000
[   91.267561] page dumped because: kasan: bad access detected
[   91.273450]=20
[   91.275152] Memory state around the buggy address:
[   91.280338]  cb32c280: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   91.287320]  cb32c300: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   91.294302] >cb32c380: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   91.301207]                                                         ^
[   91.308101]  cb32c400: 00 07 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   91.315083]  cb32c480: 00 04 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   91.321995] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   91.330451] kasan test: kmalloc_node_oob_right kmalloc_node(): out-of-=
bounds to right
[   91.339664] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   91.347813] BUG: KASAN: slab-out-of-bounds in kmalloc_node_oob_right+0=
x58/0x70 [test_kasan]
[   91.356716] Write of size 1 at addr cb38d200 by task insmod/1456
[   91.363060]=20
[   91.364877] CPU: 0 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   91.375280] Hardware name: Broadcom STB (Flattened Device Tree)
[   91.381764] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   91.390148] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   91.398040] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   91.407367] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   91.417314] [<c02a7ab8>] (kasan_report) from [<bf0042a0>] (kmalloc_nod=
e_oob_right+0x58/0x70 [test_kasan])
[   91.428358] [<bf0042a0>] (kmalloc_node_oob_right [test_kasan]) from [<=
bf004da8>] (kmalloc_tests_init+0x18/0x270 [test_kasan])
[   91.440820] [<bf004da8>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   91.451152] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   91.459969] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   91.468684] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   91.477343] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   91.485918]=20
[   91.487638] Allocated by task 1456:
[   91.491537]  kmem_cache_alloc_trace+0xb4/0x170
[   91.496720]  kmalloc_node_oob_right+0x30/0x70 [test_kasan]
[   91.502987]  kmalloc_tests_init+0x18/0x270 [test_kasan]
[   91.508614]  do_one_initcall+0x60/0x1b0
[   91.512828]  do_init_module+0xd4/0x2cc
[   91.516964]  load_module+0x3110/0x3af0
[   91.521097]  SyS_init_module+0x19c/0x1d4
[   91.525425]  ret_fast_syscall+0x0/0x50
[   91.529435]=20
[   91.531141] Freed by task 0:
[   91.534268] (stack is not available)
[   91.538103]=20
[   91.539868] The buggy address belongs to the object at cb38c200
[   91.539868]  which belongs to the cache kmalloc-4096 of size 4096
[   91.552587] The buggy address is located 0 bytes to the right of
[   91.552587]  4096-byte region [cb38c200, cb38d200)
[   91.563981] The buggy address belongs to the page:
[   91.569141] page:ee95f180 count:1 mapcount:0 mapping:cb38c200 index:0x=
0 compound_mapcount: 0
[   91.578155] flags: 0x8100(slab|head)
[   91.582207] raw: 00008100 cb38c200 00000000 00000001 00000001 ee95f094=
 d000140c d0000540
[   91.590792] page dumped because: kasan: bad access detected
[   91.596678]=20
[   91.598373] Memory state around the buggy address:
[   91.603551]  cb38d100: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00=

[   91.610518]  cb38d180: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00=

[   91.617485] >cb38d200: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   91.624360]            ^
[   91.627217]  cb38d280: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   91.634196]  cb38d300: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   91.641103] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   91.649357] kasan test: kmalloc_large_oob_right kmalloc large allocati=
on: out-of-bounds to right
[   91.686569] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   91.694713] BUG: KASAN: slab-out-of-bounds in kmalloc_large_oob_right+=
0x60/0x78 [test_kasan]
[   91.703685] Write of size 1 at addr cabfff00 by task insmod/1456
[   91.710024]=20
[   91.711823] CPU: 0 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   91.722227] Hardware name: Broadcom STB (Flattened Device Tree)
[   91.728695] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   91.737073] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   91.744957] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   91.754277] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   91.764205] [<c02a7ab8>] (kasan_report) from [<bf004318>] (kmalloc_lar=
ge_oob_right+0x60/0x78 [test_kasan])
[   91.775315] [<bf004318>] (kmalloc_large_oob_right [test_kasan]) from [=
<bf004dac>] (kmalloc_tests_init+0x1c/0x270 [test_kasan])
[   91.787851] [<bf004dac>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   91.798174] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   91.806980] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   91.815681] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   91.824328] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   91.832894]=20
[   91.834662] The buggy address belongs to the object at ca800000
[   91.834662]  which belongs to the cache kmalloc-4194304 of size 419430=
4
[   91.847908] The buggy address is located 4194048 bytes inside of
[   91.847908]  4194304-byte region [ca800000, cac00000)
[   91.859557] The buggy address belongs to the page:
[   91.864697] page:ee948000 count:1 mapcount:0 mapping:ca800000 index:0x=
0 compound_mapcount: 0
[   91.873697] flags: 0x8100(slab|head)
[   91.877735] raw: 00008100 ca800000 00000000 00000001 00000001 d000190c=
 d000190c d0000cc0
[   91.886325] page dumped because: kasan: bad access detected
[   91.892207]=20
[   91.893912] Memory state around the buggy address:
[   91.899108]  cabffe00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00=

[   91.906084]  cabffe80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00=

[   91.913063] >cabfff00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   91.919949]            ^
[   91.922804]  cabfff80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   91.929778]  cac00000: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   91.936676] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   91.950255] kasan test: kmalloc_oob_krealloc_more out-of-bounds after =
krealloc more
[   91.959414] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   91.967560] BUG: KASAN: slab-out-of-bounds in kmalloc_oob_krealloc_mor=
e+0x78/0x90 [test_kasan]
[   91.976714] Write of size 1 at addr cb32c393 by task insmod/1456
[   91.983052]=20
[   91.984852] CPU: 0 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   91.995253] Hardware name: Broadcom STB (Flattened Device Tree)
[   92.001723] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   92.010095] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   92.017977] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   92.027295] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   92.037226] [<c02a7ab8>] (kasan_report) from [<bf004558>] (kmalloc_oob=
_krealloc_more+0x78/0x90 [test_kasan])
[   92.048509] [<bf004558>] (kmalloc_oob_krealloc_more [test_kasan]) from=
 [<bf004db0>] (kmalloc_tests_init+0x20/0x270 [test_kasan])
[   92.061216] [<bf004db0>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   92.071531] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   92.080337] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   92.089050] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   92.097685] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   92.106254]=20
[   92.107973] Allocated by task 1456:
[   92.111809]  krealloc+0x44/0xc8
[   92.115649]  kmalloc_oob_krealloc_more+0x44/0x90 [test_kasan]
[   92.122170]  kmalloc_tests_init+0x20/0x270 [test_kasan]
[   92.127788]  do_one_initcall+0x60/0x1b0
[   92.132007]  do_init_module+0xd4/0x2cc
[   92.136129]  load_module+0x3110/0x3af0
[   92.140246]  SyS_init_module+0x19c/0x1d4
[   92.144551]  ret_fast_syscall+0x0/0x50
[   92.148554]=20
[   92.150253] Freed by task 0:
[   92.153373] (stack is not available)
[   92.157198]=20
[   92.158965] The buggy address belongs to the object at cb32c380
[   92.158965]  which belongs to the cache kmalloc-64 of size 64
[   92.171311] The buggy address is located 19 bytes inside of
[   92.171311]  64-byte region [cb32c380, cb32c3c0)
[   92.182073] The buggy address belongs to the page:
[   92.187218] page:ee95e580 count:1 mapcount:0 mapping:cb32c000 index:0x=
0
[   92.194233] flags: 0x100(slab)
[   92.197736] raw: 00000100 cb32c000 00000000 00000020 00000001 ee81ea94=
 ee962934 d0000000
[   92.206328] page dumped because: kasan: bad access detected
[   92.212210]=20
[   92.213917] Memory state around the buggy address:
[   92.219113]  cb32c280: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   92.226092]  cb32c300: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   92.233071] >cb32c380: 00 00 03 fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   92.239961]                  ^
[   92.243351]  cb32c400: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[   92.250319]  cb32c480: 00 04 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   92.257218] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   92.265303] kasan test: kmalloc_oob_krealloc_less out-of-bounds after =
krealloc less
[   92.274463] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   92.282607] BUG: KASAN: slab-out-of-bounds in kmalloc_oob_krealloc_les=
s+0x78/0x90 [test_kasan]
[   92.291759] Write of size 1 at addr cb32c30f by task insmod/1456
[   92.298099]=20
[   92.299905] CPU: 0 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   92.310306] Hardware name: Broadcom STB (Flattened Device Tree)
[   92.316774] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   92.325148] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   92.333030] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   92.342351] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   92.352280] [<c02a7ab8>] (kasan_report) from [<bf0045e8>] (kmalloc_oob=
_krealloc_less+0x78/0x90 [test_kasan])
[   92.363564] [<bf0045e8>] (kmalloc_oob_krealloc_less [test_kasan]) from=
 [<bf004db4>] (kmalloc_tests_init+0x24/0x270 [test_kasan])
[   92.376275] [<bf004db4>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   92.386583] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   92.395387] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   92.404104] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   92.412742] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   92.421308]=20
[   92.423024] Allocated by task 1456:
[   92.426863]  krealloc+0x44/0xc8
[   92.430706]  kmalloc_oob_krealloc_less+0x44/0x90 [test_kasan]
[   92.437229]  kmalloc_tests_init+0x24/0x270 [test_kasan]
[   92.442848]  do_one_initcall+0x60/0x1b0
[   92.447072]  do_init_module+0xd4/0x2cc
[   92.451189]  load_module+0x3110/0x3af0
[   92.455303]  SyS_init_module+0x19c/0x1d4
[   92.459609]  ret_fast_syscall+0x0/0x50
[   92.463612]=20
[   92.465311] Freed by task 0:
[   92.468431] (stack is not available)
[   92.472256]=20
[   92.474025] The buggy address belongs to the object at cb32c300
[   92.474025]  which belongs to the cache kmalloc-64 of size 64
[   92.486371] The buggy address is located 15 bytes inside of
[   92.486371]  64-byte region [cb32c300, cb32c340)
[   92.497131] The buggy address belongs to the page:
[   92.502272] page:ee95e580 count:1 mapcount:0 mapping:cb32c000 index:0x=
0
[   92.509280] flags: 0x100(slab)
[   92.512782] raw: 00000100 cb32c000 00000000 00000020 00000001 ee81ea94=
 ee962934 d0000000
[   92.521376] page dumped because: kasan: bad access detected
[   92.527257]=20
[   92.528968] Memory state around the buggy address:
[   92.534159]  cb32c200: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   92.541139]  cb32c280: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   92.548118] >cb32c300: 00 07 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   92.555005]               ^
[   92.558136]  cb32c380: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[   92.565114]  cb32c400: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[   92.572017] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   92.580279] kasan test: kmalloc_oob_16 kmalloc out-of-bounds for 16-by=
tes access
[   92.589445] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   92.597580] BUG: KASAN: slab-out-of-bounds in kmalloc_oob_16+0x78/0xa4=
 [test_kasan]
[   92.605751] Write of size 16 at addr cb32c280 by task insmod/1456
[   92.612175]=20
[   92.613992] CPU: 0 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   92.624380] Hardware name: Broadcom STB (Flattened Device Tree)
[   92.630852] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   92.639233] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   92.647117] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   92.656435] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   92.666355] [<c02a7ab8>] (kasan_report) from [<bf0043a8>] (kmalloc_oob=
_16+0x78/0xa4 [test_kasan])
[   92.676644] [<bf0043a8>] (kmalloc_oob_16 [test_kasan]) from [<bf004db8=
>] (kmalloc_tests_init+0x28/0x270 [test_kasan])
[   92.688369] [<bf004db8>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   92.698671] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   92.707478] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   92.716194] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   92.724832] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   92.733398]=20
[   92.735106] Allocated by task 1456:
[   92.739006]  kmem_cache_alloc_trace+0xb4/0x170
[   92.744178]  kmalloc_oob_16+0x30/0xa4 [test_kasan]
[   92.749706]  kmalloc_tests_init+0x28/0x270 [test_kasan]
[   92.755323]  do_one_initcall+0x60/0x1b0
[   92.759523]  do_init_module+0xd4/0x2cc
[   92.763632]  load_module+0x3110/0x3af0
[   92.767746]  SyS_init_module+0x19c/0x1d4
[   92.772066]  ret_fast_syscall+0x0/0x50
[   92.776078]=20
[   92.777778] Freed by task 0:
[   92.780912] (stack is not available)
[   92.784744]=20
[   92.786496] The buggy address belongs to the object at cb32c280
[   92.786496]  which belongs to the cache kmalloc-64 of size 64
[   92.798829] The buggy address is located 0 bytes inside of
[   92.798829]  64-byte region [cb32c280, cb32c2c0)
[   92.809505] The buggy address belongs to the page:
[   92.814646] page:ee95e580 count:1 mapcount:0 mapping:cb32c000 index:0x=
0
[   92.821657] flags: 0x100(slab)
[   92.825173] raw: 00000100 cb32c000 00000000 00000020 00000001 ee81ea94=
 ee962934 d0000000
[   92.833758] page dumped because: kasan: bad access detected
[   92.839637]=20
[   92.841334] Memory state around the buggy address:
[   92.846511]  cb32c180: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   92.853479]  cb32c200: 00 00 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   92.860447] >cb32c280: 00 05 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   92.867322]               ^
[   92.870447]  cb32c300: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[   92.877413]  cb32c380: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[   92.884307] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   92.892598] kasan test: kmalloc_oob_in_memset out-of-bounds in memset
[   92.900248] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   92.908420] BUG: KASAN: slab-out-of-bounds in kmalloc_oob_in_memset+0x=
58/0x68 [test_kasan]
[   92.917228] Write of size 671 at addr cad89b40 by task insmod/1456
[   92.923733]=20
[   92.925532] CPU: 0 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   92.935922] Hardware name: Broadcom STB (Flattened Device Tree)
[   92.942404] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   92.950765] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   92.958639] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   92.967958] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   92.977571] [<c02a7ab8>] (kasan_report) from [<c02a6b5c>] (memset+0x20=
/0x34)
[   92.985592] [<c02a6b5c>] (memset) from [<bf004658>] (kmalloc_oob_in_me=
mset+0x58/0x68 [test_kasan])
[   92.995990] [<bf004658>] (kmalloc_oob_in_memset [test_kasan]) from [<b=
f004dbc>] (kmalloc_tests_init+0x2c/0x270 [test_kasan])
[   93.008345] [<bf004dbc>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   93.018648] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   93.027455] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   93.036169] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   93.044805] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   93.053371]=20
[   93.055081] Allocated by task 1456:
[   93.058980]  kmem_cache_alloc_trace+0xb4/0x170
[   93.064158]  kmalloc_oob_in_memset+0x30/0x68 [test_kasan]
[   93.070325]  kmalloc_tests_init+0x2c/0x270 [test_kasan]
[   93.075957]  do_one_initcall+0x60/0x1b0
[   93.080169]  do_init_module+0xd4/0x2cc
[   93.084277]  load_module+0x3110/0x3af0
[   93.088391]  SyS_init_module+0x19c/0x1d4
[   93.092697]  ret_fast_syscall+0x0/0x50
[   93.096701]=20
[   93.098398] Freed by task 0:
[   93.101517] (stack is not available)
[   93.105339]=20
[   93.107104] The buggy address belongs to the object at cad89b40
[   93.107104]  which belongs to the cache kmalloc-1024 of size 1024
[   93.119796] The buggy address is located 0 bytes inside of
[   93.119796]  1024-byte region [cad89b40, cad89f40)
[   93.130644] The buggy address belongs to the page:
[   93.135786] page:ee953100 count:1 mapcount:0 mapping:cad88040 index:0x=
0 compound_mapcount: 0
[   93.144802] flags: 0x8100(slab|head)
[   93.148850] raw: 00008100 cad88040 00000000 00000007 00000001 ee9596d4=
 d000130c d00003c0
[   93.157444] page dumped because: kasan: bad access detected
[   93.163324]=20
[   93.165029] Memory state around the buggy address:
[   93.170218]  cad89c80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00=

[   93.177197]  cad89d00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00=

[   93.184180] >cad89d80: 00 00 00 00 00 00 00 00 00 00 00 02 fc fc fc fc=

[   93.191080]                                             ^
[   93.196890]  cad89e00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   93.203868]  cad89e80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   93.210773] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   93.218837] kasan test: kmalloc_oob_memset_2 out-of-bounds in memset2
[   93.226573] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   93.234711] BUG: KASAN: slab-out-of-bounds in kmalloc_oob_memset_2+0x5=
c/0x6c [test_kasan]
[   93.243416] Write of size 2 at addr cb32c187 by task insmod/1456
[   93.249743]=20
[   93.251541] CPU: 0 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   93.261933] Hardware name: Broadcom STB (Flattened Device Tree)
[   93.268413] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   93.276773] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   93.284645] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   93.293964] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   93.303573] [<c02a7ab8>] (kasan_report) from [<c02a6b5c>] (memset+0x20=
/0x34)
[   93.311591] [<c02a6b5c>] (memset) from [<bf0046c4>] (kmalloc_oob_memse=
t_2+0x5c/0x6c [test_kasan])
[   93.321894] [<bf0046c4>] (kmalloc_oob_memset_2 [test_kasan]) from [<bf=
004dc0>] (kmalloc_tests_init+0x30/0x270 [test_kasan])
[   93.334164] [<bf004dc0>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   93.344478] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   93.353283] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   93.361998] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   93.370635] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   93.379203]=20
[   93.380918] Allocated by task 1456:
[   93.384808]  kmem_cache_alloc_trace+0xb4/0x170
[   93.389993]  kmalloc_oob_memset_2+0x30/0x6c [test_kasan]
[   93.396068]  kmalloc_tests_init+0x30/0x270 [test_kasan]
[   93.401684]  do_one_initcall+0x60/0x1b0
[   93.405891]  do_init_module+0xd4/0x2cc
[   93.410019]  load_module+0x3110/0x3af0
[   93.414145]  SyS_init_module+0x19c/0x1d4
[   93.418452]  ret_fast_syscall+0x0/0x50
[   93.422456]=20
[   93.424153] Freed by task 0:
[   93.427271] (stack is not available)
[   93.431102]=20
[   93.432855] The buggy address belongs to the object at cb32c180
[   93.432855]  which belongs to the cache kmalloc-64 of size 64
[   93.445210] The buggy address is located 7 bytes inside of
[   93.445210]  64-byte region [cb32c180, cb32c1c0)
[   93.455875] The buggy address belongs to the page:
[   93.461038] page:ee95e580 count:1 mapcount:0 mapping:cb32c000 index:0x=
0
[   93.468058] flags: 0x100(slab)
[   93.471561] raw: 00000100 cb32c000 00000000 00000020 00000001 ee81ea94=
 ee962934 d0000000
[   93.480154] page dumped because: kasan: bad access detected
[   93.486049]=20
[   93.487745] Memory state around the buggy address:
[   93.492938]  cb32c080: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   93.499919]  cb32c100: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   93.506902] >cb32c180: 00 fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   93.513786]               ^
[   93.516926]  cb32c200: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[   93.523907]  cb32c280: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[   93.530807] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   93.539046] kasan test: kmalloc_oob_memset_4 out-of-bounds in memset4
[   93.546514] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   93.554656] BUG: KASAN: slab-out-of-bounds in kmalloc_oob_memset_4+0x5=
c/0x6c [test_kasan]
[   93.563367] Write of size 4 at addr cb32c105 by task insmod/1456
[   93.569692]=20
[   93.571492] CPU: 0 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   93.581880] Hardware name: Broadcom STB (Flattened Device Tree)
[   93.588371] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   93.596730] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   93.604601] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   93.613918] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   93.623533] [<c02a7ab8>] (kasan_report) from [<c02a6b5c>] (memset+0x20=
/0x34)
[   93.631557] [<c02a6b5c>] (memset) from [<bf004730>] (kmalloc_oob_memse=
t_4+0x5c/0x6c [test_kasan])
[   93.641857] [<bf004730>] (kmalloc_oob_memset_4 [test_kasan]) from [<bf=
004dc4>] (kmalloc_tests_init+0x34/0x270 [test_kasan])
[   93.654131] [<bf004dc4>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   93.664446] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   93.673247] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   93.681962] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   93.690601] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   93.699172]=20
[   93.700887] Allocated by task 1456:
[   93.704782]  kmem_cache_alloc_trace+0xb4/0x170
[   93.709967]  kmalloc_oob_memset_4+0x30/0x6c [test_kasan]
[   93.716042]  kmalloc_tests_init+0x34/0x270 [test_kasan]
[   93.721657]  do_one_initcall+0x60/0x1b0
[   93.725862]  do_init_module+0xd4/0x2cc
[   93.729995]  load_module+0x3110/0x3af0
[   93.734121]  SyS_init_module+0x19c/0x1d4
[   93.738427]  ret_fast_syscall+0x0/0x50
[   93.742431]=20
[   93.744130] Freed by task 0:
[   93.747249] (stack is not available)
[   93.751084]=20
[   93.752837] The buggy address belongs to the object at cb32c100
[   93.752837]  which belongs to the cache kmalloc-64 of size 64
[   93.765193] The buggy address is located 5 bytes inside of
[   93.765193]  64-byte region [cb32c100, cb32c140)
[   93.775856] The buggy address belongs to the page:
[   93.781022] page:ee95e580 count:1 mapcount:0 mapping:cb32c000 index:0x=
0
[   93.788043] flags: 0x100(slab)
[   93.791546] raw: 00000100 cb32c000 00000000 00000020 00000001 ee81ea94=
 ee962934 d0000000
[   93.800140] page dumped because: kasan: bad access detected
[   93.806031]=20
[   93.807727] Memory state around the buggy address:
[   93.812915]  cb32c000: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   93.819896]  cb32c080: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   93.826880] >cb32c100: 00 fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   93.833768]               ^
[   93.836900]  cb32c180: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[   93.843883]  cb32c200: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[   93.850787] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   93.858849] kasan test: kmalloc_oob_memset_8 out-of-bounds in memset8
[   93.866585] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   93.874723] BUG: KASAN: slab-out-of-bounds in kmalloc_oob_memset_8+0x5=
c/0x6c [test_kasan]
[   93.883428] Write of size 8 at addr cb32c081 by task insmod/1456
[   93.889754]=20
[   93.891554] CPU: 0 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   93.901950] Hardware name: Broadcom STB (Flattened Device Tree)
[   93.908424] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   93.916784] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   93.924657] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   93.933976] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   93.943582] [<c02a7ab8>] (kasan_report) from [<c02a6b5c>] (memset+0x20=
/0x34)
[   93.951602] [<c02a6b5c>] (memset) from [<bf00479c>] (kmalloc_oob_memse=
t_8+0x5c/0x6c [test_kasan])
[   93.961907] [<bf00479c>] (kmalloc_oob_memset_8 [test_kasan]) from [<bf=
004dc8>] (kmalloc_tests_init+0x38/0x270 [test_kasan])
[   93.974177] [<bf004dc8>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   93.984490] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   93.993293] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   94.002010] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   94.010643] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   94.019213]=20
[   94.020928] Allocated by task 1456:
[   94.024816]  kmem_cache_alloc_trace+0xb4/0x170
[   94.030005]  kmalloc_oob_memset_8+0x30/0x6c [test_kasan]
[   94.036080]  kmalloc_tests_init+0x38/0x270 [test_kasan]
[   94.041696]  do_one_initcall+0x60/0x1b0
[   94.045906]  do_init_module+0xd4/0x2cc
[   94.050036]  load_module+0x3110/0x3af0
[   94.054161]  SyS_init_module+0x19c/0x1d4
[   94.058467]  ret_fast_syscall+0x0/0x50
[   94.062470]=20
[   94.064166] Freed by task 0:
[   94.067285] (stack is not available)
[   94.071114]=20
[   94.072869] The buggy address belongs to the object at cb32c080
[   94.072869]  which belongs to the cache kmalloc-64 of size 64
[   94.085222] The buggy address is located 1 bytes inside of
[   94.085222]  64-byte region [cb32c080, cb32c0c0)
[   94.095889] The buggy address belongs to the page:
[   94.101050] page:ee95e580 count:1 mapcount:0 mapping:cb32c000 index:0x=
0
[   94.108074] flags: 0x100(slab)
[   94.111577] raw: 00000100 cb32c000 00000000 00000020 00000001 ee81ea94=
 ee962934 d0000000
[   94.120172] page dumped because: kasan: bad access detected
[   94.126067]=20
[   94.127761] Memory state around the buggy address:
[   94.132954]  cb32bf80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00=

[   94.139935]  cb32c000: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   94.146916] >cb32c080: 00 fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   94.153798]               ^
[   94.156938]  cb32c100: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[   94.163918]  cb32c180: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[   94.170817] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   94.179061] kasan test: kmalloc_oob_memset_16 out-of-bounds in memset1=
6
[   94.186673] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   94.194807] BUG: KASAN: slab-out-of-bounds in kmalloc_oob_memset_16+0x=
5c/0x6c [test_kasan]
[   94.203608] Write of size 16 at addr cb32c001 by task insmod/1456
[   94.210036]=20
[   94.211836] CPU: 0 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   94.222240] Hardware name: Broadcom STB (Flattened Device Tree)
[   94.228707] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   94.237084] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   94.244968] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   94.254286] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   94.263895] [<c02a7ab8>] (kasan_report) from [<c02a6b5c>] (memset+0x20=
/0x34)
[   94.271928] [<c02a6b5c>] (memset) from [<bf004808>] (kmalloc_oob_memse=
t_16+0x5c/0x6c [test_kasan])
[   94.282322] [<bf004808>] (kmalloc_oob_memset_16 [test_kasan]) from [<b=
f004dcc>] (kmalloc_tests_init+0x3c/0x270 [test_kasan])
[   94.294672] [<bf004dcc>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   94.304988] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   94.313780] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   94.322498] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   94.331148] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   94.339705]=20
[   94.341409] Allocated by task 1456:
[   94.345293]  kmem_cache_alloc_trace+0xb4/0x170
[   94.350477]  kmalloc_oob_memset_16+0x30/0x6c [test_kasan]
[   94.356633]  kmalloc_tests_init+0x3c/0x270 [test_kasan]
[   94.362255]  do_one_initcall+0x60/0x1b0
[   94.366456]  do_init_module+0xd4/0x2cc
[   94.370563]  load_module+0x3110/0x3af0
[   94.374679]  SyS_init_module+0x19c/0x1d4
[   94.379000]  ret_fast_syscall+0x0/0x50
[   94.383015]=20
[   94.384715] Freed by task 0:
[   94.387837] (stack is not available)
[   94.391668]=20
[   94.393418] The buggy address belongs to the object at cb32c000
[   94.393418]  which belongs to the cache kmalloc-64 of size 64
[   94.405751] The buggy address is located 1 bytes inside of
[   94.405751]  64-byte region [cb32c000, cb32c040)
[   94.416414] The buggy address belongs to the page:
[   94.421557] page:ee95e580 count:1 mapcount:0 mapping:cb32c000 index:0x=
0
[   94.428567] flags: 0x100(slab)
[   94.432083] raw: 00000100 cb32c000 00000000 00000020 00000001 ee81ea94=
 ee962934 d0000000
[   94.440668] page dumped because: kasan: bad access detected
[   94.446547]=20
[   94.448242] Memory state around the buggy address:
[   94.453420]  cb32bf00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00=

[   94.460386]  cb32bf80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00=

[   94.467353] >cb32c000: 00 00 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   94.474234]                  ^
[   94.477624]  cb32c080: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[   94.484590]  cb32c100: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[   94.491485] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   94.499541] kasan test: kmalloc_uaf use-after-free
[   94.505668] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   94.513786] BUG: KASAN: use-after-free in kmalloc_uaf+0x58/0x68 [test_=
kasan]
[   94.521264] Write of size 1 at addr cb681f88 by task insmod/1456
[   94.527589]=20
[   94.529387] CPU: 0 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   94.539768] Hardware name: Broadcom STB (Flattened Device Tree)
[   94.546253] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   94.554614] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   94.562491] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   94.571796] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   94.581720] [<c02a7ab8>] (kasan_report) from [<bf00442c>] (kmalloc_uaf=
+0x58/0x68 [test_kasan])
[   94.591738] [<bf00442c>] (kmalloc_uaf [test_kasan]) from [<bf004dd0>] =
(kmalloc_tests_init+0x40/0x270 [test_kasan])
[   94.603200] [<bf004dd0>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   94.613514] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   94.622318] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   94.631031] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   94.639669] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   94.648238]=20
[   94.649957] Allocated by task 1456:
[   94.653847]  kmem_cache_alloc_trace+0xb4/0x170
[   94.659028]  kmalloc_uaf+0x30/0x68 [test_kasan]
[   94.664303]  kmalloc_tests_init+0x40/0x270 [test_kasan]
[   94.669928]  do_one_initcall+0x60/0x1b0
[   94.674144]  do_init_module+0xd4/0x2cc
[   94.678255]  load_module+0x3110/0x3af0
[   94.682370]  SyS_init_module+0x19c/0x1d4
[   94.686677]  ret_fast_syscall+0x0/0x50
[   94.690679]=20
[   94.692383] Freed by task 1456:
[   94.695888]  kfree+0x64/0x100
[   94.699541]  kmalloc_uaf+0x50/0x68 [test_kasan]
[   94.704802]  kmalloc_tests_init+0x40/0x270 [test_kasan]
[   94.710425]  do_one_initcall+0x60/0x1b0
[   94.714626]  do_init_module+0xd4/0x2cc
[   94.718734]  load_module+0x3110/0x3af0
[   94.722850]  SyS_init_module+0x19c/0x1d4
[   94.727177]  ret_fast_syscall+0x0/0x50
[   94.731181]=20
[   94.732949] The buggy address belongs to the object at cb681f80
[   94.732949]  which belongs to the cache kmalloc-64 of size 64
[   94.745294] The buggy address is located 8 bytes inside of
[   94.745294]  64-byte region [cb681f80, cb681fc0)
[   94.755966] The buggy address belongs to the page:
[   94.761122] page:ee965020 count:1 mapcount:0 mapping:cb681000 index:0x=
0
[   94.768145] flags: 0x100(slab)
[   94.771647] raw: 00000100 cb681000 00000000 00000020 00000001 ee962934=
 d000108c d0000000
[   94.780245] page dumped because: kasan: bad access detected
[   94.786135]=20
[   94.787832] Memory state around the buggy address:
[   94.793035]  cb681e80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   94.800014]  cb681f00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   94.806997] >cb681f80: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[   94.813881]               ^
[   94.817028]  cb682000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00=

[   94.824009]  cb682080: 00 00 00 00 00 00 fc fc fc fc fc fc fc fc fc fc=

[   94.830913] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   94.838770] kasan test: kmalloc_uaf_memset use-after-free in memset
[   94.846416] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   94.854558] BUG: KASAN: use-after-free in kmalloc_tests_init+0x44/0x27=
0 [test_kasan]
[   94.862819] Write of size 33 at addr cb681f00 by task insmod/1456
[   94.869245]=20
[   94.871058] CPU: 0 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   94.881438] Hardware name: Broadcom STB (Flattened Device Tree)
[   94.887914] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   94.896292] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   94.904173] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   94.913492] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   94.923111] [<c02a7ab8>] (kasan_report) from [<c02a6b5c>] (memset+0x20=
/0x34)
[   94.931134] [<c02a6b5c>] (memset) from [<bf004dd4>] (kmalloc_tests_ini=
t+0x44/0x270 [test_kasan])
[   94.940986] [<bf004dd4>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   94.951300] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   94.960109] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   94.968810] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   94.977464] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   94.986029]=20
[   94.987733] Allocated by task 1456:
[   94.991619]  kmem_cache_alloc_trace+0xb4/0x170
[   94.996786]  kmalloc_uaf_memset+0x30/0x68 [test_kasan]
[   95.002677]  kmalloc_tests_init+0x44/0x270 [test_kasan]
[   95.008292]  do_one_initcall+0x60/0x1b0
[   95.012491]  do_init_module+0xd4/0x2cc
[   95.016599]  load_module+0x3110/0x3af0
[   95.020712]  SyS_init_module+0x19c/0x1d4
[   95.025029]  ret_fast_syscall+0x0/0x50
[   95.029043]=20
[   95.030746] Freed by task 1456:
[   95.034246]  kfree+0x64/0x100
[   95.037900]  kmalloc_uaf_memset+0x50/0x68 [test_kasan]
[   95.043794]  kmalloc_tests_init+0x44/0x270 [test_kasan]
[   95.049416]  do_one_initcall+0x60/0x1b0
[   95.053614]  do_init_module+0xd4/0x2cc
[   95.057722]  load_module+0x3110/0x3af0
[   95.061837]  SyS_init_module+0x19c/0x1d4
[   95.066168]  ret_fast_syscall+0x0/0x50
[   95.070172]=20
[   95.071940] The buggy address belongs to the object at cb681f00
[   95.071940]  which belongs to the cache kmalloc-64 of size 64
[   95.084288] The buggy address is located 0 bytes inside of
[   95.084288]  64-byte region [cb681f00, cb681f40)
[   95.094960] The buggy address belongs to the page:
[   95.100113] page:ee965020 count:1 mapcount:0 mapping:cb681000 index:0x=
0
[   95.107135] flags: 0x100(slab)
[   95.110640] raw: 00000100 cb681000 00000000 00000020 00000001 ee962934=
 d000108c d0000000
[   95.119236] page dumped because: kasan: bad access detected
[   95.125126]=20
[   95.126823] Memory state around the buggy address:
[   95.132028]  cb681e00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   95.139010]  cb681e80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   95.145990] >cb681f00: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[   95.152873]            ^
[   95.155737]  cb681f80: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[   95.162704]  cb682000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00=

[   95.169596] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   95.177458] kasan test: kmalloc_uaf2 use-after-free after another kmal=
loc
[   95.186287] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   95.194418] BUG: KASAN: use-after-free in kmalloc_uaf2+0x74/0xa4 [test=
_kasan]
[   95.201989] Write of size 1 at addr cb681ea8 by task insmod/1456
[   95.208316]=20
[   95.210127] CPU: 0 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   95.220509] Hardware name: Broadcom STB (Flattened Device Tree)
[   95.226993] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   95.235366] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   95.243249] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   95.252562] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   95.262483] [<c02a7ab8>] (kasan_report) from [<bf0044b0>] (kmalloc_uaf=
2+0x74/0xa4 [test_kasan])
[   95.272593] [<bf0044b0>] (kmalloc_uaf2 [test_kasan]) from [<bf004dd8>]=
 (kmalloc_tests_init+0x48/0x270 [test_kasan])
[   95.284141] [<bf004dd8>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   95.294459] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   95.303262] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   95.311979] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   95.320616] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   95.329186]=20
[   95.330902] Allocated by task 1456:
[   95.334796]  kmem_cache_alloc_trace+0xb4/0x170
[   95.339974]  kmalloc_uaf2+0x30/0xa4 [test_kasan]
[   95.345338]  kmalloc_tests_init+0x48/0x270 [test_kasan]
[   95.350971]  do_one_initcall+0x60/0x1b0
[   95.355182]  do_init_module+0xd4/0x2cc
[   95.359292]  load_module+0x3110/0x3af0
[   95.363406]  SyS_init_module+0x19c/0x1d4
[   95.367714]  ret_fast_syscall+0x0/0x50
[   95.371717]=20
[   95.373420] Freed by task 1456:
[   95.376926]  kfree+0x64/0x100
[   95.380571]  kmalloc_uaf2+0x50/0xa4 [test_kasan]
[   95.385929]  kmalloc_tests_init+0x48/0x270 [test_kasan]
[   95.391551]  do_one_initcall+0x60/0x1b0
[   95.395751]  do_init_module+0xd4/0x2cc
[   95.399864]  load_module+0x3110/0x3af0
[   95.404003]  SyS_init_module+0x19c/0x1d4
[   95.408310]  ret_fast_syscall+0x0/0x50
[   95.412312]=20
[   95.414073] The buggy address belongs to the object at cb681e80
[   95.414073]  which belongs to the cache kmalloc-64 of size 64
[   95.426418] The buggy address is located 40 bytes inside of
[   95.426418]  64-byte region [cb681e80, cb681ec0)
[   95.437177] The buggy address belongs to the page:
[   95.442318] page:ee965020 count:1 mapcount:0 mapping:cb681000 index:0x=
0
[   95.449329] flags: 0x100(slab)
[   95.452831] raw: 00000100 cb681000 00000000 00000020 00000001 ee95e594=
 d000108c d0000000
[   95.461426] page dumped because: kasan: bad access detected
[   95.467307]=20
[   95.469012] Memory state around the buggy address:
[   95.474200]  cb681d80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   95.481179]  cb681e00: 00 00 00 00 00 03 fc fc fc fc fc fc fc fc fc fc=

[   95.488158] >cb681e80: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[   95.495050]                           ^
[   95.499247]  cb681f00: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[   95.506227]  cb681f80: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[   95.513133] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   95.524422] kasan test: kmem_cache_oob out-of-bounds in kmem_cache_all=
oc
[   95.532322] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   95.540461] BUG: KASAN: slab-out-of-bounds in kmem_cache_oob+0x88/0xb8=
 [test_kasan]
[   95.548629] Read of size 1 at addr cb32ef78 by task insmod/1456
[   95.554877]=20
[   95.556684] CPU: 0 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   95.567074] Hardware name: Broadcom STB (Flattened Device Tree)
[   95.573541] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   95.581912] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   95.589790] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   95.599117] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   95.609041] [<c02a7ab8>] (kasan_report) from [<bf004908>] (kmem_cache_=
oob+0x88/0xb8 [test_kasan])
[   95.619340] [<bf004908>] (kmem_cache_oob [test_kasan]) from [<bf004ddc=
>] (kmalloc_tests_init+0x4c/0x270 [test_kasan])
[   95.631070] [<bf004ddc>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   95.641383] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   95.650190] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   95.658902] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   95.667555] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   95.676124]=20
[   95.677831] Allocated by task 1456:
[   95.681712]  kmem_cache_alloc+0xac/0x16c
[   95.686353]  kmem_cache_oob+0x64/0xb8 [test_kasan]
[   95.691887]  kmalloc_tests_init+0x4c/0x270 [test_kasan]
[   95.697515]  do_one_initcall+0x60/0x1b0
[   95.701717]  do_init_module+0xd4/0x2cc
[   95.705827]  load_module+0x3110/0x3af0
[   95.709965]  SyS_init_module+0x19c/0x1d4
[   95.714269]  ret_fast_syscall+0x0/0x50
[   95.718272]=20
[   95.719984] Freed by task 0:
[   95.723111] (stack is not available)
[   95.726950]=20
[   95.728706] The buggy address belongs to the object at cb32eeb0
[   95.728706]  which belongs to the cache test_cache of size 200
[   95.741146] The buggy address is located 0 bytes to the right of
[   95.741146]  200-byte region [cb32eeb0, cb32ef78)
[   95.752433] The buggy address belongs to the page:
[   95.757575] page:ee95e5c0 count:1 mapcount:0 mapping:cb32e040 index:0x=
0
[   95.764583] flags: 0x100(slab)
[   95.768100] raw: 00000100 cb32e040 00000000 0000000f 00000001 cb681d0c=
 cb681d0c cdc6b000
[   95.776685] page dumped because: kasan: bad access detected
[   95.782566]=20
[   95.784261] Memory state around the buggy address:
[   95.789440]  cb32ee00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   95.796408]  cb32ee80: fc fc fc fc fc fc 00 00 00 00 00 00 00 00 00 00=

[   95.803376] >cb32ef00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 fc=

[   95.810268]                                                         ^
[   95.817156]  cb32ef80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   95.824135]  cb32f000: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff=

[   95.831043] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   95.859462] kasan test: memcg_accounted_kmem_cache allocate memcg acco=
unted object
[   96.407433] kasan test: kasan_stack_oob out-of-bounds on stack
[   96.413815] kasan test: kasan_global_oob out-of-bounds global variable=

[   96.421066] kasan test: ksize_unpoisons_memory ksize() unpoisons the w=
hole allocated chunk
[   96.430550] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   96.438688] BUG: KASAN: slab-out-of-bounds in ksize_unpoisons_memory+0=
x6c/0x84 [test_kasan]
[   96.447573] Write of size 1 at addr cac5ab00 by task insmod/1456
[   96.453899]=20
[   96.455700] CPU: 2 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   96.466080] Hardware name: Broadcom STB (Flattened Device Tree)
[   96.472554] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   96.480918] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   96.488792] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   96.498098] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   96.508019] [<c02a7ab8>] (kasan_report) from [<bf004a58>] (ksize_unpoi=
sons_memory+0x6c/0x84 [test_kasan])
[   96.519026] [<bf004a58>] (ksize_unpoisons_memory [test_kasan]) from [<=
bf004dec>] (kmalloc_tests_init+0x5c/0x270 [test_kasan])
[   96.531455] [<bf004dec>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   96.541758] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   96.550550] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   96.559254] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   96.567891] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   96.576451]=20
[   96.578156] Allocated by task 1456:
[   96.582043]  kmem_cache_alloc_trace+0xb4/0x170
[   96.587213]  ksize_unpoisons_memory+0x30/0x84 [test_kasan]
[   96.593457]  kmalloc_tests_init+0x5c/0x270 [test_kasan]
[   96.599075]  do_one_initcall+0x60/0x1b0
[   96.603274]  do_init_module+0xd4/0x2cc
[   96.607382]  load_module+0x3110/0x3af0
[   96.611495]  SyS_init_module+0x19c/0x1d4
[   96.615803]  ret_fast_syscall+0x0/0x50
[   96.619805]=20
[   96.621504] Freed by task 0:
[   96.624623] (stack is not available)
[   96.628446]=20
[   96.630201] The buggy address belongs to the object at cac5aa80
[   96.630201]  which belongs to the cache kmalloc-128 of size 128
[   96.642718] The buggy address is located 0 bytes to the right of
[   96.642718]  128-byte region [cac5aa80, cac5ab00)
[   96.654003] The buggy address belongs to the page:
[   96.659154] page:ee950b40 count:1 mapcount:0 mapping:cac5a000 index:0x=
cac5af00
[   96.666869] flags: 0x100(slab)
[   96.670382] raw: 00000100 cac5a000 cac5af00 00000008 00000001 ee965014=
 d0001104 d00000c0
[   96.678964] page dumped because: kasan: bad access detected
[   96.684846]=20
[   96.686541] Memory state around the buggy address:
[   96.691721]  cac5aa00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   96.698687]  cac5aa80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00=

[   96.705653] >cac5ab00: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb=

[   96.712528]            ^
[   96.715382]  cac5ab80: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[   96.722349]  cac5ac00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   96.729242] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   96.738725] kasan test: copy_user_test out-of-bounds in copy_from_user=
()
[   96.746098] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   96.754226] BUG: KASAN: slab-out-of-bounds in copy_user_test+0xb8/0x32=
0 [test_kasan]
[   96.762485] Write of size 11 at addr cb681400 by task insmod/1456
[   96.768900]=20
[   96.770701] CPU: 2 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   96.781081] Hardware name: Broadcom STB (Flattened Device Tree)
[   96.787548] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   96.795911] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   96.803782] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   96.813088] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   96.823003] [<c02a7ab8>] (kasan_report) from [<bf004b28>] (copy_user_t=
est+0xb8/0x320 [test_kasan])
[   96.833378] [<bf004b28>] (copy_user_test [test_kasan]) from [<bf004df0=
>] (kmalloc_tests_init+0x60/0x270 [test_kasan])
[   96.845096] [<bf004df0>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   96.855397] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   96.864191] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   96.872895] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   96.881531] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   96.890088]=20
[   96.891791] Allocated by task 1456:
[   96.895675]  kmem_cache_alloc_trace+0xb4/0x170
[   96.900843]  copy_user_test+0x24/0x320 [test_kasan]
[   96.906460]  kmalloc_tests_init+0x60/0x270 [test_kasan]
[   96.912077]  do_one_initcall+0x60/0x1b0
[   96.916276]  do_init_module+0xd4/0x2cc
[   96.920383]  load_module+0x3110/0x3af0
[   96.924497]  SyS_init_module+0x19c/0x1d4
[   96.928806]  ret_fast_syscall+0x0/0x50
[   96.932807]=20
[   96.934506] Freed by task 0:
[   96.937628] (stack is not available)
[   96.941451]=20
[   96.943204] The buggy address belongs to the object at cb681400
[   96.943204]  which belongs to the cache kmalloc-64 of size 64
[   96.955538] The buggy address is located 0 bytes inside of
[   96.955538]  64-byte region [cb681400, cb681440)
[   96.966198] The buggy address belongs to the page:
[   96.971339] page:ee965020 count:1 mapcount:0 mapping:cb681000 index:0x=
0
[   96.978349] flags: 0x100(slab)
[   96.981854] raw: 00000100 cb681000 00000000 00000020 00000001 ee962934=
 d000108c d0000000
[   96.990439] page dumped because: kasan: bad access detected
[   96.996321]=20
[   96.998019] Memory state around the buggy address:
[   97.003198]  cb681300: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   97.010164]  cb681380: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   97.017130] >cb681400: 00 02 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   97.024006]               ^
[   97.027127]  cb681480: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   97.034095]  cb681500: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   97.040989] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   97.049167] kasan test: copy_user_test out-of-bounds in copy_to_user()=

[   97.056238] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   97.064369] BUG: KASAN: slab-out-of-bounds in copy_user_test+0x15c/0x3=
20 [test_kasan]
[   97.072716] Read of size 11 at addr cb681400 by task insmod/1456
[   97.079043]=20
[   97.080842] CPU: 2 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   97.091223] Hardware name: Broadcom STB (Flattened Device Tree)
[   97.097690] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   97.106050] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   97.113921] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   97.123228] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   97.133145] [<c02a7ab8>] (kasan_report) from [<bf004bcc>] (copy_user_t=
est+0x15c/0x320 [test_kasan])
[   97.143608] [<bf004bcc>] (copy_user_test [test_kasan]) from [<bf004df0=
>] (kmalloc_tests_init+0x60/0x270 [test_kasan])
[   97.155326] [<bf004df0>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   97.165628] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   97.174421] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   97.183124] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   97.191761] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   97.200319]=20
[   97.202023] Allocated by task 1456:
[   97.205910]  kmem_cache_alloc_trace+0xb4/0x170
[   97.211078]  copy_user_test+0x24/0x320 [test_kasan]
[   97.216695]  kmalloc_tests_init+0x60/0x270 [test_kasan]
[   97.222312]  do_one_initcall+0x60/0x1b0
[   97.226512]  do_init_module+0xd4/0x2cc
[   97.230619]  load_module+0x3110/0x3af0
[   97.234735]  SyS_init_module+0x19c/0x1d4
[   97.239041]  ret_fast_syscall+0x0/0x50
[   97.243046]=20
[   97.244744] Freed by task 0:
[   97.247862] (stack is not available)
[   97.251685]=20
[   97.253435] The buggy address belongs to the object at cb681400
[   97.253435]  which belongs to the cache kmalloc-64 of size 64
[   97.265770] The buggy address is located 0 bytes inside of
[   97.265770]  64-byte region [cb681400, cb681440)
[   97.276428] The buggy address belongs to the page:
[   97.281570] page:ee965020 count:1 mapcount:0 mapping:cb681000 index:0x=
0
[   97.288581] flags: 0x100(slab)
[   97.292085] raw: 00000100 cb681000 00000000 00000020 00000001 ee95e594=
 d000108c d0000000
[   97.300671] page dumped because: kasan: bad access detected
[   97.306552]=20
[   97.308249] Memory state around the buggy address:
[   97.313427]  cb681300: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   97.320393]  cb681380: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   97.327360] >cb681400: 00 02 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   97.334235]               ^
[   97.337360]  cb681480: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   97.344326]  cb681500: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   97.351218] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   97.360461] kasan test: copy_user_test out-of-bounds in __copy_from_us=
er()
[   97.368031] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   97.376165] BUG: KASAN: slab-out-of-bounds in copy_user_test+0x1b4/0x3=
20 [test_kasan]
[   97.384514] Write of size 11 at addr cb681400 by task insmod/1456
[   97.390930]=20
[   97.392727] CPU: 2 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   97.403106] Hardware name: Broadcom STB (Flattened Device Tree)
[   97.409574] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   97.417935] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   97.425805] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   97.435112] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   97.445028] [<c02a7ab8>] (kasan_report) from [<bf004c24>] (copy_user_t=
est+0x1b4/0x320 [test_kasan])
[   97.455492] [<bf004c24>] (copy_user_test [test_kasan]) from [<bf004df0=
>] (kmalloc_tests_init+0x60/0x270 [test_kasan])
[   97.467205] [<bf004df0>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   97.477507] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   97.486302] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   97.495006] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   97.503641] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   97.512198]=20
[   97.513901] Allocated by task 1456:
[   97.517786]  kmem_cache_alloc_trace+0xb4/0x170
[   97.522950]  copy_user_test+0x24/0x320 [test_kasan]
[   97.528567]  kmalloc_tests_init+0x60/0x270 [test_kasan]
[   97.534184]  do_one_initcall+0x60/0x1b0
[   97.538383]  do_init_module+0xd4/0x2cc
[   97.542493]  load_module+0x3110/0x3af0
[   97.546606]  SyS_init_module+0x19c/0x1d4
[   97.550913]  ret_fast_syscall+0x0/0x50
[   97.554918]=20
[   97.556619] Freed by task 0:
[   97.559738] (stack is not available)
[   97.563563]=20
[   97.565314] The buggy address belongs to the object at cb681400
[   97.565314]  which belongs to the cache kmalloc-64 of size 64
[   97.577659] The buggy address is located 0 bytes inside of
[   97.577659]  64-byte region [cb681400, cb681440)
[   97.588325] The buggy address belongs to the page:
[   97.593471] page:ee965020 count:1 mapcount:0 mapping:cb681000 index:0x=
0
[   97.600481] flags: 0x100(slab)
[   97.603986] raw: 00000100 cb681000 00000000 00000020 00000001 ee95e594=
 d000108c d0000000
[   97.612570] page dumped because: kasan: bad access detected
[   97.618453]=20
[   97.620148] Memory state around the buggy address:
[   97.625327]  cb681300: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   97.632297]  cb681380: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   97.639263] >cb681400: 00 02 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   97.646138]               ^
[   97.649262]  cb681480: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   97.656228]  cb681500: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   97.663121] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   97.671127] kasan test: copy_user_test out-of-bounds in __copy_to_user=
()
[   97.678390] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   97.686523] BUG: KASAN: slab-out-of-bounds in copy_user_test+0x204/0x3=
20 [test_kasan]
[   97.694873] Read of size 11 at addr cb681400 by task insmod/1456
[   97.701201]=20
[   97.703001] CPU: 2 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   97.713382] Hardware name: Broadcom STB (Flattened Device Tree)
[   97.719851] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   97.728211] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   97.736081] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   97.745390] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   97.755306] [<c02a7ab8>] (kasan_report) from [<bf004c74>] (copy_user_t=
est+0x204/0x320 [test_kasan])
[   97.765770] [<bf004c74>] (copy_user_test [test_kasan]) from [<bf004df0=
>] (kmalloc_tests_init+0x60/0x270 [test_kasan])
[   97.777486] [<bf004df0>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   97.787789] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   97.796584] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   97.805287] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   97.813924] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   97.822480]=20
[   97.824187] Allocated by task 1456:
[   97.828073]  kmem_cache_alloc_trace+0xb4/0x170
[   97.833239]  copy_user_test+0x24/0x320 [test_kasan]
[   97.838857]  kmalloc_tests_init+0x60/0x270 [test_kasan]
[   97.844473]  do_one_initcall+0x60/0x1b0
[   97.848673]  do_init_module+0xd4/0x2cc
[   97.852783]  load_module+0x3110/0x3af0
[   97.856898]  SyS_init_module+0x19c/0x1d4
[   97.861205]  ret_fast_syscall+0x0/0x50
[   97.865208]=20
[   97.866905] Freed by task 0:
[   97.870024] (stack is not available)
[   97.873846]=20
[   97.875597] The buggy address belongs to the object at cb681400
[   97.875597]  which belongs to the cache kmalloc-64 of size 64
[   97.887930] The buggy address is located 0 bytes inside of
[   97.887930]  64-byte region [cb681400, cb681440)
[   97.898589] The buggy address belongs to the page:
[   97.903730] page:ee965020 count:1 mapcount:0 mapping:cb681000 index:0x=
0
[   97.910741] flags: 0x100(slab)
[   97.914246] raw: 00000100 cb681000 00000000 00000020 00000001 ee95e594=
 d000108c d0000000
[   97.922832] page dumped because: kasan: bad access detected
[   97.928713]=20
[   97.930407] Memory state around the buggy address:
[   97.935586]  cb681300: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   97.942551]  cb681380: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   97.949520] >cb681400: 00 02 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   97.956395]               ^
[   97.959520]  cb681480: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   97.966486]  cb681500: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   97.973379] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   97.981357] kasan test: copy_user_test out-of-bounds in __copy_from_us=
er_inatomic()
[   97.989682] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   97.997814] BUG: KASAN: slab-out-of-bounds in copy_user_test+0x254/0x3=
20 [test_kasan]
[   98.006164] Write of size 11 at addr cb681400 by task insmod/1456
[   98.012579]=20
[   98.014377] CPU: 2 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   98.024756] Hardware name: Broadcom STB (Flattened Device Tree)
[   98.031223] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   98.039584] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   98.047456] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   98.056762] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   98.066678] [<c02a7ab8>] (kasan_report) from [<bf004cc4>] (copy_user_t=
est+0x254/0x320 [test_kasan])
[   98.077142] [<bf004cc4>] (copy_user_test [test_kasan]) from [<bf004df0=
>] (kmalloc_tests_init+0x60/0x270 [test_kasan])
[   98.088855] [<bf004df0>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   98.099157] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   98.107950] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   98.116652] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   98.125287] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   98.133847]=20
[   98.135550] Allocated by task 1456:
[   98.139436]  kmem_cache_alloc_trace+0xb4/0x170
[   98.144603]  copy_user_test+0x24/0x320 [test_kasan]
[   98.150222]  kmalloc_tests_init+0x60/0x270 [test_kasan]
[   98.155839]  do_one_initcall+0x60/0x1b0
[   98.160039]  do_init_module+0xd4/0x2cc
[   98.164148]  load_module+0x3110/0x3af0
[   98.168263]  SyS_init_module+0x19c/0x1d4
[   98.172571]  ret_fast_syscall+0x0/0x50
[   98.176573]=20
[   98.178272] Freed by task 0:
[   98.181392] (stack is not available)
[   98.185216]=20
[   98.186968] The buggy address belongs to the object at cb681400
[   98.186968]  which belongs to the cache kmalloc-64 of size 64
[   98.199302] The buggy address is located 0 bytes inside of
[   98.199302]  64-byte region [cb681400, cb681440)
[   98.209962] The buggy address belongs to the page:
[   98.215104] page:ee965020 count:1 mapcount:0 mapping:cb681000 index:0x=
0
[   98.222112] flags: 0x100(slab)
[   98.225617] raw: 00000100 cb681000 00000000 00000020 00000001 ee95e594=
 d000108c d0000000
[   98.234202] page dumped because: kasan: bad access detected
[   98.240083]=20
[   98.241781] Memory state around the buggy address:
[   98.246961]  cb681300: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   98.253927]  cb681380: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   98.260893] >cb681400: 00 02 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   98.267771]               ^
[   98.270894]  cb681480: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   98.277861]  cb681500: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   98.284757] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   98.292719] kasan test: copy_user_test out-of-bounds in __copy_to_user=
_inatomic()
[   98.301045] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   98.309179] BUG: KASAN: slab-out-of-bounds in copy_user_test+0x2a4/0x3=
20 [test_kasan]
[   98.317528] Read of size 11 at addr cb681400 by task insmod/1456
[   98.323855]=20
[   98.325656] CPU: 2 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   98.336036] Hardware name: Broadcom STB (Flattened Device Tree)
[   98.342505] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   98.350868] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   98.358741] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   98.368048] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   98.377965] [<c02a7ab8>] (kasan_report) from [<bf004d14>] (copy_user_t=
est+0x2a4/0x320 [test_kasan])
[   98.388429] [<bf004d14>] (copy_user_test [test_kasan]) from [<bf004df0=
>] (kmalloc_tests_init+0x60/0x270 [test_kasan])
[   98.400144] [<bf004df0>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   98.410445] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   98.419240] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   98.427942] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   98.436578] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   98.445137]=20
[   98.446840] Allocated by task 1456:
[   98.450726]  kmem_cache_alloc_trace+0xb4/0x170
[   98.455893]  copy_user_test+0x24/0x320 [test_kasan]
[   98.461510]  kmalloc_tests_init+0x60/0x270 [test_kasan]
[   98.467126]  do_one_initcall+0x60/0x1b0
[   98.471326]  do_init_module+0xd4/0x2cc
[   98.475437]  load_module+0x3110/0x3af0
[   98.479551]  SyS_init_module+0x19c/0x1d4
[   98.483860]  ret_fast_syscall+0x0/0x50
[   98.487864]=20
[   98.489563] Freed by task 0:
[   98.492683] (stack is not available)
[   98.496507]=20
[   98.498258] The buggy address belongs to the object at cb681400
[   98.498258]  which belongs to the cache kmalloc-64 of size 64
[   98.510593] The buggy address is located 0 bytes inside of
[   98.510593]  64-byte region [cb681400, cb681440)
[   98.521253] The buggy address belongs to the page:
[   98.526394] page:ee965020 count:1 mapcount:0 mapping:cb681000 index:0x=
0
[   98.533404] flags: 0x100(slab)
[   98.536906] raw: 00000100 cb681000 00000000 00000020 00000001 ee95e594=
 d000108c d0000000
[   98.545491] page dumped because: kasan: bad access detected
[   98.551370]=20
[   98.553066] Memory state around the buggy address:
[   98.558246]  cb681300: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   98.565213]  cb681380: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   98.572179] >cb681400: 00 02 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   98.579054]               ^
[   98.582177]  cb681480: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   98.589144]  cb681500: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   98.596038] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   98.604200] kasan test: copy_user_test out-of-bounds in strncpy_from_u=
ser()
[   98.611705] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   98.619495] BUG: KASAN: slab-out-of-bounds in strncpy_from_user+0x58/0=
x1e4
[   98.626782] Write of size 11 at addr cb681400 by task insmod/1456
[   98.633196]=20
[   98.634993] CPU: 2 PID: 1456 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #27
[   98.645374] Hardware name: Broadcom STB (Flattened Device Tree)
[   98.651841] [<c01157c0>] (unwind_backtrace) from [<c010f118>] (show_st=
ack+0x10/0x14)
[   98.660204] [<c010f118>] (show_stack) from [<c0b85908>] (dump_stack+0x=
90/0xa4)
[   98.668075] [<c0b85908>] (dump_stack) from [<c02a73b4>] (print_address=
_description+0x50/0x24c)
[   98.677381] [<c02a73b4>] (print_address_description) from [<c02a7ab8>]=
 (kasan_report+0x238/0x324)
[   98.686951] [<c02a7ab8>] (kasan_report) from [<c05bbf68>] (strncpy_fro=
m_user+0x58/0x1e4)
[   98.696085] [<c05bbf68>] (strncpy_from_user) from [<bf004d68>] (copy_u=
ser_test+0x2f8/0x320 [test_kasan])
[   98.706998] [<bf004d68>] (copy_user_test [test_kasan]) from [<bf004df0=
>] (kmalloc_tests_init+0x60/0x270 [test_kasan])
[   98.718716] [<bf004df0>] (kmalloc_tests_init [test_kasan]) from [<c010=
1f54>] (do_one_initcall+0x60/0x1b0)
[   98.729018] [<c0101f54>] (do_one_initcall) from [<c01dcfc8>] (do_init_=
module+0xd4/0x2cc)
[   98.737812] [<c01dcfc8>] (do_init_module) from [<c01dbad8>] (load_modu=
le+0x3110/0x3af0)
[   98.746516] [<c01dbad8>] (load_module) from [<c01dc654>] (SyS_init_mod=
ule+0x19c/0x1d4)
[   98.755152] [<c01dc654>] (SyS_init_module) from [<c0109800>] (ret_fast=
_syscall+0x0/0x50)
[   98.763710]=20
[   98.765413] Allocated by task 1456:
[   98.769299]  kmem_cache_alloc_trace+0xb4/0x170
[   98.774466]  copy_user_test+0x24/0x320 [test_kasan]
[   98.780083]  kmalloc_tests_init+0x60/0x270 [test_kasan]
[   98.785700]  do_one_initcall+0x60/0x1b0
[   98.789900]  do_init_module+0xd4/0x2cc
[   98.794010]  load_module+0x3110/0x3af0
[   98.798124]  SyS_init_module+0x19c/0x1d4
[   98.802433]  ret_fast_syscall+0x0/0x50
[   98.806436]=20
[   98.808135] Freed by task 0:
[   98.811258] (stack is not available)
[   98.815081]=20
[   98.816834] The buggy address belongs to the object at cb681400
[   98.816834]  which belongs to the cache kmalloc-64 of size 64
[   98.829169] The buggy address is located 0 bytes inside of
[   98.829169]  64-byte region [cb681400, cb681440)
[   98.839829] The buggy address belongs to the page:
[   98.844971] page:ee965020 count:1 mapcount:0 mapping:cb681000 index:0x=
0
[   98.851979] flags: 0x100(slab)
[   98.855484] raw: 00000100 cb681000 00000000 00000020 00000001 ee95e594=
 d000108c d0000000
[   98.864067] page dumped because: kasan: bad access detected
[   98.869950]=20
[   98.871644] Memory state around the buggy address:
[   98.876824]  cb681300: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   98.883790]  cb681380: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   98.890756] >cb681400: 00 02 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   98.897632]               ^
[   98.900753]  cb681480: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   98.907720]  cb681500: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[   98.914615] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   98.924518] kasan test: use_after_scope_test use-after-scope on int
[   98.931329] kasan test: use_after_scope_test use-after-scope on array
insmod: can't insert 'test_kasan.ko': Resource temporarily unavailable


--------------51DFA7131273B4173E983701
Content-Type: text/x-patch;
 name="fix-build.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="fix-build.patch"

diff --git a/arch/arm/boot/compressed/decompress.c b/arch/arm/boot/compre=
ssed/decompress.c
index f3a4bedd1afc..7d4a47752760 100644
--- a/arch/arm/boot/compressed/decompress.c
+++ b/arch/arm/boot/compressed/decompress.c
@@ -48,8 +48,10 @@ extern int memcmp(const void *cs, const void *ct, size=
_t count);
 #endif
=20
 #ifdef CONFIG_KERNEL_XZ
+#ifndef CONFIG_KASAN
 #define memmove memmove
 #define memcpy memcpy
+#endif
 #include "../../../../lib/decompress_unxz.c"
 #endif
=20
diff --git a/arch/arm/kernel/entry-common.S b/arch/arm/kernel/entry-commo=
n.S
index 99c908226065..0de1160d136e 100644
--- a/arch/arm/kernel/entry-common.S
+++ b/arch/arm/kernel/entry-common.S
@@ -50,7 +50,13 @@ ret_fast_syscall:
  UNWIND(.cantunwind	)
 	disable_irq_notrace			@ disable interrupts
 	ldr	r2, [tsk, #TI_ADDR_LIMIT]
+#ifdef CONFIG_KASAN
+	movw	r1, #:lower16:TASK_SIZE
+	movt	r1, #:upper16:TASK_SIZE
+	cmp	r2, r1
+#else
 	cmp	r2, #TASK_SIZE
+#endif
 	blne	addr_limit_check_failed
 	ldr	r1, [tsk, #TI_FLAGS]		@ re-check for syscall tracing
 	tst	r1, #_TIF_SYSCALL_WORK | _TIF_WORK_MASK
@@ -115,7 +121,13 @@ ret_slow_syscall:
 	disable_irq_notrace			@ disable interrupts
 ENTRY(ret_to_user_from_irq)
 	ldr	r2, [tsk, #TI_ADDR_LIMIT]
+#ifdef CONFIG_KASAN
+	movw	r1, #:lower16:TASK_SIZE
+	movt	r1, #:upper16:TASK_SIZE
+	cmp	r2, r1
+#else
 	cmp	r2, #TASK_SIZE
+#endif
 	blne	addr_limit_check_failed
 	ldr	r1, [tsk, #TI_FLAGS]
 	tst	r1, #_TIF_WORK_MASK

--------------51DFA7131273B4173E983701
Content-Type: text/x-log;
 name="lpae.log"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="lpae.log"

test_kasan.ko
# insmod test_kasan.ko=20
[  101.420931] test_kasan: no symbol version for module_layout
[  101.470457] kasan test: kmalloc_oob_right out-of-bounds to right
[  101.477653] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  101.485794] BUG: KASAN: slab-out-of-bounds in kmalloc_oob_right+0x54/0=
x6c [test_kasan]
[  101.494242] Write of size 1 at addr cb7dcdfb by task insmod/1453
[  101.500584]=20
[  101.502400] CPU: 2 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  101.512802] Hardware name: Broadcom STB (Flattened Device Tree)
[  101.519288] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  101.527663] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  101.535547] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  101.544868] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  101.554822] [<c03a838c>] (kasan_report) from [<bf0041bc>] (kmalloc_oob=
_right+0x54/0x6c [test_kasan])
[  101.565384] [<bf0041bc>] (kmalloc_oob_right [test_kasan]) from [<bf004=
cb4>] (kmalloc_tests_init+0x10/0x35c [test_kasan])
[  101.577390] [<bf004cb4>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  101.587716] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  101.596532] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  101.605249] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  101.613918] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  101.622490]=20
[  101.624203] Allocated by task 1453:
[  101.628107]  kmem_cache_alloc_trace+0xb4/0x170
[  101.633291]  kmalloc_oob_right+0x30/0x6c [test_kasan]
[  101.639099]  kmalloc_tests_init+0x10/0x35c [test_kasan]
[  101.644726]  do_one_initcall+0x60/0x1b0
[  101.648937]  do_init_module+0xd4/0x2cc
[  101.653057]  load_module+0x3110/0x3af0
[  101.657178]  SyS_init_module+0x184/0x1bc
[  101.661500]  ret_fast_syscall+0x0/0x48
[  101.665511]=20
[  101.667219] Freed by task 0:
[  101.670362] (stack is not available)
[  101.674201]=20
[  101.675972] The buggy address belongs to the object at cb7dcd80
[  101.675972]  which belongs to the cache kmalloc-128 of size 128
[  101.688518] The buggy address is located 123 bytes inside of
[  101.688518]  128-byte region [cb7dcd80, cb7dce00)
[  101.699465] The buggy address belongs to the page:
[  101.704622] page:ee967b80 count:1 mapcount:0 mapping:cb7dc000 index:0x=
0
[  101.711646] flags: 0x100(slab)
[  101.715164] raw: 00000100 cb7dc000 00000000 00000015 00000001 ee96b514=
 ee95e8f4 d00000c0
[  101.723765] page dumped because: kasan: bad access detected
[  101.729653]=20
[  101.731366] Memory state around the buggy address:
[  101.736565]  cb7dcc80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  101.743559]  cb7dcd00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  101.750547] >cb7dcd80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03=

[  101.757462]                                                         ^
[  101.764367]  cb7dce00: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb=

[  101.771363]  cb7dce80: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  101.778274] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  101.786797] kasan test: kmalloc_oob_left out-of-bounds to left
[  101.793807] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  101.801963] BUG: KASAN: slab-out-of-bounds in kmalloc_oob_left+0x54/0x=
74 [test_kasan]
[  101.810337] Read of size 1 at addr cb18227f by task insmod/1453
[  101.816588]=20
[  101.818405] CPU: 2 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  101.828800] Hardware name: Broadcom STB (Flattened Device Tree)
[  101.835292] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  101.843683] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  101.851578] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  101.860909] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  101.870850] [<c03a838c>] (kasan_report) from [<bf004228>] (kmalloc_oob=
_left+0x54/0x74 [test_kasan])
[  101.881361] [<bf004228>] (kmalloc_oob_left [test_kasan]) from [<bf004c=
b8>] (kmalloc_tests_init+0x14/0x35c [test_kasan])
[  101.893292] [<bf004cb8>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  101.903621] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  101.912438] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  101.921154] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  101.929822] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  101.938404]=20
[  101.940113] Allocated by task 0:
[  101.943601] (stack is not available)
[  101.947442]=20
[  101.949150] Freed by task 0:
[  101.952288] (stack is not available)
[  101.956127]=20
[  101.957888] The buggy address belongs to the object at cb182200
[  101.957888]  which belongs to the cache kmalloc-64 of size 64
[  101.970258] The buggy address is located 63 bytes to the right of
[  101.970258]  64-byte region [cb182200, cb182240)
[  101.981570] The buggy address belongs to the page:
[  101.986721] page:ee95b040 count:1 mapcount:0 mapping:cb182000 index:0x=
0
[  101.993742] flags: 0x100(slab)
[  101.997267] raw: 00000100 cb182000 00000000 00000020 00000001 ee9616f4=
 ee95e894 d0000000
[  102.005866] page dumped because: kasan: bad access detected
[  102.011758]=20
[  102.013467] Memory state around the buggy address:
[  102.018660]  cb182100: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  102.025646]  cb182180: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  102.032634] >cb182200: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  102.039547]                                                         ^
[  102.046443]  cb182280: 00 07 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  102.053430]  cb182300: 00 04 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  102.060342] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  102.068609] kasan test: kmalloc_node_oob_right kmalloc_node(): out-of-=
bounds to right
[  102.077848] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  102.085999] BUG: KASAN: slab-out-of-bounds in kmalloc_node_oob_right+0=
x58/0x70 [test_kasan]
[  102.094898] Write of size 1 at addr cac85900 by task insmod/1453
[  102.101237]=20
[  102.103055] CPU: 2 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  102.113456] Hardware name: Broadcom STB (Flattened Device Tree)
[  102.119943] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  102.128327] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  102.136222] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  102.145567] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  102.155516] [<c03a838c>] (kasan_report) from [<bf0042a0>] (kmalloc_nod=
e_oob_right+0x58/0x70 [test_kasan])
[  102.166571] [<bf0042a0>] (kmalloc_node_oob_right [test_kasan]) from [<=
bf004cbc>] (kmalloc_tests_init+0x18/0x35c [test_kasan])
[  102.179031] [<bf004cbc>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  102.189356] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  102.198161] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  102.206895] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  102.215558] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  102.224126]=20
[  102.225841] Allocated by task 1453:
[  102.229744]  kmem_cache_alloc_trace+0xb4/0x170
[  102.234940]  kmalloc_node_oob_right+0x30/0x70 [test_kasan]
[  102.241200]  kmalloc_tests_init+0x18/0x35c [test_kasan]
[  102.246837]  do_one_initcall+0x60/0x1b0
[  102.251047]  do_init_module+0xd4/0x2cc
[  102.255165]  load_module+0x3110/0x3af0
[  102.259299]  SyS_init_module+0x184/0x1bc
[  102.263637]  ret_fast_syscall+0x0/0x48
[  102.267651]=20
[  102.269367] Freed by task 0:
[  102.272498] (stack is not available)
[  102.276338]=20
[  102.278107] The buggy address belongs to the object at cac84900
[  102.278107]  which belongs to the cache kmalloc-4096 of size 4096
[  102.290832] The buggy address is located 0 bytes to the right of
[  102.290832]  4096-byte region [cac84900, cac85900)
[  102.302216] The buggy address belongs to the page:
[  102.307378] page:ee951080 count:1 mapcount:0 mapping:cac84900 index:0x=
0 compound_mapcount: 0
[  102.316392] flags: 0x8100(slab|head)
[  102.320445] raw: 00008100 cac84900 00000000 00000001 00000001 ee95e754=
 d000140c d0000540
[  102.329029] page dumped because: kasan: bad access detected
[  102.334909]=20
[  102.336608] Memory state around the buggy address:
[  102.341793]  cac85800: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00=

[  102.348763]  cac85880: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00=

[  102.355733] >cac85900: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  102.362612]            ^
[  102.365479]  cac85980: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  102.372454]  cac85a00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  102.379362] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  102.387622] kasan test: kmalloc_large_oob_right kmalloc large allocati=
on: out-of-bounds to right
[  102.424790] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  102.432931] BUG: KASAN: slab-out-of-bounds in kmalloc_large_oob_right+=
0x60/0x78 [test_kasan]
[  102.441905] Write of size 1 at addr cabfff00 by task insmod/1453
[  102.448239]=20
[  102.450050] CPU: 2 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  102.460444] Hardware name: Broadcom STB (Flattened Device Tree)
[  102.466913] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  102.475282] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  102.483161] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  102.492489] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  102.502413] [<c03a838c>] (kasan_report) from [<bf004318>] (kmalloc_lar=
ge_oob_right+0x60/0x78 [test_kasan])
[  102.513523] [<bf004318>] (kmalloc_large_oob_right [test_kasan]) from [=
<bf004cc0>] (kmalloc_tests_init+0x1c/0x35c [test_kasan])
[  102.526051] [<bf004cc0>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  102.536368] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  102.545162] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  102.553890] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  102.562544] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  102.571104]=20
[  102.572865] The buggy address belongs to the object at ca800000
[  102.572865]  which belongs to the cache kmalloc-4194304 of size 419430=
4
[  102.586109] The buggy address is located 4194048 bytes inside of
[  102.586109]  4194304-byte region [ca800000, cac00000)
[  102.597768] The buggy address belongs to the page:
[  102.602912] page:ee948000 count:1 mapcount:0 mapping:ca800000 index:0x=
0 compound_mapcount: 0
[  102.611915] flags: 0x8100(slab|head)
[  102.615955] raw: 00008100 ca800000 00000000 00000001 00000001 d000190c=
 d000190c d0000cc0
[  102.624552] page dumped because: kasan: bad access detected
[  102.630442]=20
[  102.632138] Memory state around the buggy address:
[  102.637332]  cabffe00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00=

[  102.644311]  cabffe80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00=

[  102.651291] >cabfff00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  102.658173]            ^
[  102.661035]  cabfff80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  102.668002]  cac00000: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  102.674899] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  102.688490] kasan test: kmalloc_oob_krealloc_more out-of-bounds after =
krealloc more
[  102.697666] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  102.705816] BUG: KASAN: slab-out-of-bounds in kmalloc_oob_krealloc_mor=
e+0x78/0x90 [test_kasan]
[  102.714971] Write of size 1 at addr cb182213 by task insmod/1453
[  102.721310]=20
[  102.723113] CPU: 2 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  102.733503] Hardware name: Broadcom STB (Flattened Device Tree)
[  102.739971] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  102.748348] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  102.756226] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  102.765561] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  102.775491] [<c03a838c>] (kasan_report) from [<bf004558>] (kmalloc_oob=
_krealloc_more+0x78/0x90 [test_kasan])
[  102.786776] [<bf004558>] (kmalloc_oob_krealloc_more [test_kasan]) from=
 [<bf004cc4>] (kmalloc_tests_init+0x20/0x35c [test_kasan])
[  102.799486] [<bf004cc4>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  102.809801] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  102.818603] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  102.827313] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  102.835959] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  102.844530]=20
[  102.846238] Allocated by task 1453:
[  102.850081]  krealloc+0x44/0xc8
[  102.853917]  kmalloc_oob_krealloc_more+0x44/0x90 [test_kasan]
[  102.860440]  kmalloc_tests_init+0x20/0x35c [test_kasan]
[  102.866057]  do_one_initcall+0x60/0x1b0
[  102.870262]  do_init_module+0xd4/0x2cc
[  102.874395]  load_module+0x3110/0x3af0
[  102.878519]  SyS_init_module+0x184/0x1bc
[  102.882826]  ret_fast_syscall+0x0/0x48
[  102.886831]=20
[  102.888530] Freed by task 0:
[  102.891651] (stack is not available)
[  102.895483]=20
[  102.897239] The buggy address belongs to the object at cb182200
[  102.897239]  which belongs to the cache kmalloc-64 of size 64
[  102.909599] The buggy address is located 19 bytes inside of
[  102.909599]  64-byte region [cb182200, cb182240)
[  102.920360] The buggy address belongs to the page:
[  102.925516] page:ee95b040 count:1 mapcount:0 mapping:cb182000 index:0x=
0
[  102.932541] flags: 0x100(slab)
[  102.936045] raw: 00000100 cb182000 00000000 00000020 00000001 ee9616f4=
 ee95e894 d0000000
[  102.944642] page dumped because: kasan: bad access detected
[  102.950530]=20
[  102.952228] Memory state around the buggy address:
[  102.957429]  cb182100: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  102.964408]  cb182180: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  102.971391] >cb182200: 00 00 03 fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  102.978279]                  ^
[  102.981678]  cb182280: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  102.988653]  cb182300: 00 04 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  102.995558] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  103.003661] kasan test: kmalloc_oob_krealloc_less out-of-bounds after =
krealloc less
[  103.012824] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  103.020973] BUG: KASAN: slab-out-of-bounds in kmalloc_oob_krealloc_les=
s+0x78/0x90 [test_kasan]
[  103.030125] Write of size 1 at addr cb18218f by task insmod/1453
[  103.036467]=20
[  103.038272] CPU: 2 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  103.048670] Hardware name: Broadcom STB (Flattened Device Tree)
[  103.055136] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  103.063511] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  103.071394] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  103.080712] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  103.090645] [<c03a838c>] (kasan_report) from [<bf0045e8>] (kmalloc_oob=
_krealloc_less+0x78/0x90 [test_kasan])
[  103.101928] [<bf0045e8>] (kmalloc_oob_krealloc_less [test_kasan]) from=
 [<bf004cc8>] (kmalloc_tests_init+0x24/0x35c [test_kasan])
[  103.114640] [<bf004cc8>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  103.124951] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  103.133754] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  103.142470] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  103.151105] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  103.159673]=20
[  103.161390] Allocated by task 1453:
[  103.165227]  krealloc+0x44/0xc8
[  103.169068]  kmalloc_oob_krealloc_less+0x44/0x90 [test_kasan]
[  103.175589]  kmalloc_tests_init+0x24/0x35c [test_kasan]
[  103.181207]  do_one_initcall+0x60/0x1b0
[  103.185433]  do_init_module+0xd4/0x2cc
[  103.189553]  load_module+0x3110/0x3af0
[  103.193669]  SyS_init_module+0x184/0x1bc
[  103.197976]  ret_fast_syscall+0x0/0x48
[  103.201980]=20
[  103.203680] Freed by task 0:
[  103.206803] (stack is not available)
[  103.210628]=20
[  103.212393] The buggy address belongs to the object at cb182180
[  103.212393]  which belongs to the cache kmalloc-64 of size 64
[  103.224742] The buggy address is located 15 bytes inside of
[  103.224742]  64-byte region [cb182180, cb1821c0)
[  103.235500] The buggy address belongs to the page:
[  103.240643] page:ee95b040 count:1 mapcount:0 mapping:cb182000 index:0x=
0
[  103.247654] flags: 0x100(slab)
[  103.251157] raw: 00000100 cb182000 00000000 00000020 00000001 ee9616f4=
 ee95e894 d0000000
[  103.259751] page dumped because: kasan: bad access detected
[  103.265634]=20
[  103.267341] Memory state around the buggy address:
[  103.272534]  cb182080: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  103.279513]  cb182100: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  103.286490] >cb182180: 00 07 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  103.293378]               ^
[  103.296513]  cb182200: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  103.303491]  cb182280: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  103.310398] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  103.318645] kasan test: kmalloc_oob_16 kmalloc out-of-bounds for 16-by=
tes access
[  103.327807] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  103.335944] BUG: KASAN: slab-out-of-bounds in kmalloc_oob_16+0x78/0xa4=
 [test_kasan]
[  103.344114] Write of size 16 at addr cb182100 by task insmod/1453
[  103.350539]=20
[  103.352353] CPU: 2 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  103.362746] Hardware name: Broadcom STB (Flattened Device Tree)
[  103.369218] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  103.377603] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  103.385493] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  103.394819] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  103.404740] [<c03a838c>] (kasan_report) from [<bf0043a8>] (kmalloc_oob=
_16+0x78/0xa4 [test_kasan])
[  103.415029] [<bf0043a8>] (kmalloc_oob_16 [test_kasan]) from [<bf004ccc=
>] (kmalloc_tests_init+0x28/0x35c [test_kasan])
[  103.426756] [<bf004ccc>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  103.437058] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  103.445862] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  103.454577] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  103.463215] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  103.471786]=20
[  103.473494] Allocated by task 1453:
[  103.477395]  kmem_cache_alloc_trace+0xb4/0x170
[  103.482566]  kmalloc_oob_16+0x30/0xa4 [test_kasan]
[  103.488094]  kmalloc_tests_init+0x28/0x35c [test_kasan]
[  103.493713]  do_one_initcall+0x60/0x1b0
[  103.497913]  do_init_module+0xd4/0x2cc
[  103.502021]  load_module+0x3110/0x3af0
[  103.506136]  SyS_init_module+0x184/0x1bc
[  103.510456]  ret_fast_syscall+0x0/0x48
[  103.514471]=20
[  103.516172] Freed by task 0:
[  103.519309] (stack is not available)
[  103.523140]=20
[  103.524896] The buggy address belongs to the object at cb182100
[  103.524896]  which belongs to the cache kmalloc-64 of size 64
[  103.537236] The buggy address is located 0 bytes inside of
[  103.537236]  64-byte region [cb182100, cb182140)
[  103.547910] The buggy address belongs to the page:
[  103.553051] page:ee95b040 count:1 mapcount:0 mapping:cb182000 index:0x=
0
[  103.560062] flags: 0x100(slab)
[  103.563577] raw: 00000100 cb182000 00000000 00000020 00000001 ee9616f4=
 ee95e894 d0000000
[  103.572163] page dumped because: kasan: bad access detected
[  103.578051]=20
[  103.579751] Memory state around the buggy address:
[  103.584932]  cb182000: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  103.591900]  cb182080: 00 00 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  103.598867] >cb182100: 00 05 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  103.605744]               ^
[  103.608868]  cb182180: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  103.615834]  cb182200: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  103.622729] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  103.631013] kasan test: kmalloc_oob_in_memset out-of-bounds in memset
[  103.638659] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  103.646828] BUG: KASAN: slab-out-of-bounds in kmalloc_oob_in_memset+0x=
58/0x68 [test_kasan]
[  103.655638] Write of size 671 at addr cad5db40 by task insmod/1453
[  103.662145]=20
[  103.663946] CPU: 2 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  103.674342] Hardware name: Broadcom STB (Flattened Device Tree)
[  103.680815] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  103.689177] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  103.697056] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  103.706378] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  103.715985] [<c03a838c>] (kasan_report) from [<c03a7430>] (memset+0x20=
/0x34)
[  103.724003] [<c03a7430>] (memset) from [<bf004658>] (kmalloc_oob_in_me=
mset+0x58/0x68 [test_kasan])
[  103.734395] [<bf004658>] (kmalloc_oob_in_memset [test_kasan]) from [<b=
f004cd0>] (kmalloc_tests_init+0x2c/0x35c [test_kasan])
[  103.746745] [<bf004cd0>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  103.757048] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  103.765852] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  103.774567] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  103.783205] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  103.791774]=20
[  103.793484] Allocated by task 1453:
[  103.797385]  kmem_cache_alloc_trace+0xb4/0x170
[  103.802562]  kmalloc_oob_in_memset+0x30/0x68 [test_kasan]
[  103.808729]  kmalloc_tests_init+0x2c/0x35c [test_kasan]
[  103.814363]  do_one_initcall+0x60/0x1b0
[  103.818573]  do_init_module+0xd4/0x2cc
[  103.822681]  load_module+0x3110/0x3af0
[  103.826796]  SyS_init_module+0x184/0x1bc
[  103.831103]  ret_fast_syscall+0x0/0x48
[  103.835108]=20
[  103.836808] Freed by task 0:
[  103.839930] (stack is not available)
[  103.843754]=20
[  103.845519] The buggy address belongs to the object at cad5db40
[  103.845519]  which belongs to the cache kmalloc-1024 of size 1024
[  103.858218] The buggy address is located 0 bytes inside of
[  103.858218]  1024-byte region [cad5db40, cad5df40)
[  103.869071] The buggy address belongs to the page:
[  103.874215] page:ee952b80 count:1 mapcount:0 mapping:cad5c040 index:0x=
0 compound_mapcount: 0
[  103.883237] flags: 0x8100(slab|head)
[  103.887289] raw: 00008100 cad5c040 00000000 00000007 00000001 ee950f14=
 d000130c d00003c0
[  103.895881] page dumped because: kasan: bad access detected
[  103.901763]=20
[  103.903466] Memory state around the buggy address:
[  103.908650]  cad5dc80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00=

[  103.915629]  cad5dd00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00=

[  103.922609] >cad5dd80: 00 00 00 00 00 00 00 00 00 00 00 02 fc fc fc fc=

[  103.929513]                                             ^
[  103.935333]  cad5de00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  103.942308]  cad5de80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  103.949208] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  103.957453] kasan test: kmalloc_oob_memset_2 out-of-bounds in memset2
[  103.964912] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  103.973051] BUG: KASAN: slab-out-of-bounds in kmalloc_oob_memset_2+0x5=
c/0x6c [test_kasan]
[  103.981764] Write of size 2 at addr cb182007 by task insmod/1453
[  103.988094]=20
[  103.989893] CPU: 2 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  104.000283] Hardware name: Broadcom STB (Flattened Device Tree)
[  104.006766] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  104.015128] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  104.023002] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  104.032322] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  104.041940] [<c03a838c>] (kasan_report) from [<c03a7430>] (memset+0x20=
/0x34)
[  104.049960] [<c03a7430>] (memset) from [<bf0046c4>] (kmalloc_oob_memse=
t_2+0x5c/0x6c [test_kasan])
[  104.060258] [<bf0046c4>] (kmalloc_oob_memset_2 [test_kasan]) from [<bf=
004cd4>] (kmalloc_tests_init+0x30/0x35c [test_kasan])
[  104.072531] [<bf004cd4>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  104.082847] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  104.091650] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  104.100363] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  104.109000] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  104.117570]=20
[  104.119284] Allocated by task 1453:
[  104.123180]  kmem_cache_alloc_trace+0xb4/0x170
[  104.128367]  kmalloc_oob_memset_2+0x30/0x6c [test_kasan]
[  104.134442]  kmalloc_tests_init+0x30/0x35c [test_kasan]
[  104.140061]  do_one_initcall+0x60/0x1b0
[  104.144269]  do_init_module+0xd4/0x2cc
[  104.148402]  load_module+0x3110/0x3af0
[  104.152529]  SyS_init_module+0x184/0x1bc
[  104.156837]  ret_fast_syscall+0x0/0x48
[  104.160841]=20
[  104.162543] Freed by task 0:
[  104.165664] (stack is not available)
[  104.169498]=20
[  104.171259] The buggy address belongs to the object at cb182000
[  104.171259]  which belongs to the cache kmalloc-64 of size 64
[  104.183618] The buggy address is located 7 bytes inside of
[  104.183618]  64-byte region [cb182000, cb182040)
[  104.194288] The buggy address belongs to the page:
[  104.199448] page:ee95b040 count:1 mapcount:0 mapping:cb182000 index:0x=
0
[  104.206472] flags: 0x100(slab)
[  104.209977] raw: 00000100 cb182000 00000000 00000020 00000001 ee9616f4=
 ee95e894 d0000000
[  104.218573] page dumped because: kasan: bad access detected
[  104.224470]=20
[  104.226169] Memory state around the buggy address:
[  104.231367]  cb181f00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00=

[  104.238348]  cb181f80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00=

[  104.245324] >cb182000: 00 fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  104.252205]               ^
[  104.255354]  cb182080: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  104.262336]  cb182100: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  104.269235] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  104.277474] kasan test: kmalloc_oob_memset_4 out-of-bounds in memset4
[  104.284953] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  104.293092] BUG: KASAN: slab-out-of-bounds in kmalloc_oob_memset_4+0x5=
c/0x6c [test_kasan]
[  104.301799] Write of size 4 at addr cb183f85 by task insmod/1453
[  104.308129]=20
[  104.309928] CPU: 2 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  104.320321] Hardware name: Broadcom STB (Flattened Device Tree)
[  104.326799] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  104.335164] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  104.343045] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  104.352366] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  104.361979] [<c03a838c>] (kasan_report) from [<c03a7430>] (memset+0x20=
/0x34)
[  104.369999] [<c03a7430>] (memset) from [<bf004730>] (kmalloc_oob_memse=
t_4+0x5c/0x6c [test_kasan])
[  104.380298] [<bf004730>] (kmalloc_oob_memset_4 [test_kasan]) from [<bf=
004cd8>] (kmalloc_tests_init+0x34/0x35c [test_kasan])
[  104.392567] [<bf004cd8>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  104.402884] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  104.411686] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  104.420399] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  104.429038] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  104.437608]=20
[  104.439329] Allocated by task 1453:
[  104.443220]  kmem_cache_alloc_trace+0xb4/0x170
[  104.448408]  kmalloc_oob_memset_4+0x30/0x6c [test_kasan]
[  104.454482]  kmalloc_tests_init+0x34/0x35c [test_kasan]
[  104.460099]  do_one_initcall+0x60/0x1b0
[  104.464310]  do_init_module+0xd4/0x2cc
[  104.468438]  load_module+0x3110/0x3af0
[  104.472562]  SyS_init_module+0x184/0x1bc
[  104.476870]  ret_fast_syscall+0x0/0x48
[  104.480875]=20
[  104.482577] Freed by task 0:
[  104.485698] (stack is not available)
[  104.489525]=20
[  104.491284] The buggy address belongs to the object at cb183f80
[  104.491284]  which belongs to the cache kmalloc-64 of size 64
[  104.503637] The buggy address is located 5 bytes inside of
[  104.503637]  64-byte region [cb183f80, cb183fc0)
[  104.514309] The buggy address belongs to the page:
[  104.519465] page:ee95b060 count:1 mapcount:0 mapping:cb183000 index:0x=
0
[  104.526484] flags: 0x100(slab)
[  104.529989] raw: 00000100 cb183000 00000000 00000020 00000001 ee95e894=
 d000108c d0000000
[  104.538585] page dumped because: kasan: bad access detected
[  104.544480]=20
[  104.546178] Memory state around the buggy address:
[  104.551378]  cb183e80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  104.558360]  cb183f00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  104.565341] >cb183f80: 00 fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  104.572221]               ^
[  104.575366]  cb184000: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff=

[  104.582349]  cb184080: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff=

[  104.589249] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  104.597495] kasan test: kmalloc_oob_memset_8 out-of-bounds in memset8
[  104.604928] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  104.613072] BUG: KASAN: slab-out-of-bounds in kmalloc_oob_memset_8+0x5=
c/0x6c [test_kasan]
[  104.621782] Write of size 8 at addr cb183f01 by task insmod/1453
[  104.628110]=20
[  104.629909] CPU: 2 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  104.640299] Hardware name: Broadcom STB (Flattened Device Tree)
[  104.646779] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  104.655142] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  104.663017] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  104.672337] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  104.681949] [<c03a838c>] (kasan_report) from [<c03a7430>] (memset+0x20=
/0x34)
[  104.689970] [<c03a7430>] (memset) from [<bf00479c>] (kmalloc_oob_memse=
t_8+0x5c/0x6c [test_kasan])
[  104.700272] [<bf00479c>] (kmalloc_oob_memset_8 [test_kasan]) from [<bf=
004cdc>] (kmalloc_tests_init+0x38/0x35c [test_kasan])
[  104.712541] [<bf004cdc>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  104.722856] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  104.731661] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  104.740373] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  104.749010] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  104.757583]=20
[  104.759299] Allocated by task 1453:
[  104.763193]  kmem_cache_alloc_trace+0xb4/0x170
[  104.768378]  kmalloc_oob_memset_8+0x30/0x6c [test_kasan]
[  104.774453]  kmalloc_tests_init+0x38/0x35c [test_kasan]
[  104.780070]  do_one_initcall+0x60/0x1b0
[  104.784277]  do_init_module+0xd4/0x2cc
[  104.788403]  load_module+0x3110/0x3af0
[  104.792531]  SyS_init_module+0x184/0x1bc
[  104.796839]  ret_fast_syscall+0x0/0x48
[  104.800843]=20
[  104.802544] Freed by task 0:
[  104.805666] (stack is not available)
[  104.809498]=20
[  104.811258] The buggy address belongs to the object at cb183f00
[  104.811258]  which belongs to the cache kmalloc-64 of size 64
[  104.823614] The buggy address is located 1 bytes inside of
[  104.823614]  64-byte region [cb183f00, cb183f40)
[  104.834286] The buggy address belongs to the page:
[  104.839444] page:ee95b060 count:1 mapcount:0 mapping:cb183000 index:0x=
0
[  104.846467] flags: 0x100(slab)
[  104.849970] raw: 00000100 cb183000 00000000 00000020 00000001 ee95e894=
 d000108c d0000000
[  104.858570] page dumped because: kasan: bad access detected
[  104.864466]=20
[  104.866165] Memory state around the buggy address:
[  104.871364]  cb183e00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  104.878347]  cb183e80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  104.885326] >cb183f00: 00 fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  104.892207]               ^
[  104.895356]  cb183f80: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  104.902337]  cb184000: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff=

[  104.909235] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  104.917473] kasan test: kmalloc_oob_memset_16 out-of-bounds in memset1=
6
[  104.925082] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  104.933214] BUG: KASAN: slab-out-of-bounds in kmalloc_oob_memset_16+0x=
5c/0x6c [test_kasan]
[  104.942023] Write of size 16 at addr cb183e81 by task insmod/1453
[  104.948453]=20
[  104.950258] CPU: 2 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  104.960667] Hardware name: Broadcom STB (Flattened Device Tree)
[  104.967135] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  104.975510] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  104.983395] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  104.992717] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  105.002334] [<c03a838c>] (kasan_report) from [<c03a7430>] (memset+0x20=
/0x34)
[  105.010356] [<c03a7430>] (memset) from [<bf004808>] (kmalloc_oob_memse=
t_16+0x5c/0x6c [test_kasan])
[  105.020741] [<bf004808>] (kmalloc_oob_memset_16 [test_kasan]) from [<b=
f004ce0>] (kmalloc_tests_init+0x3c/0x35c [test_kasan])
[  105.033091] [<bf004ce0>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  105.043404] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  105.052196] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  105.060913] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  105.069564] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  105.078121]=20
[  105.079825] Allocated by task 1453:
[  105.083712]  kmem_cache_alloc_trace+0xb4/0x170
[  105.088892]  kmalloc_oob_memset_16+0x30/0x6c [test_kasan]
[  105.095046]  kmalloc_tests_init+0x3c/0x35c [test_kasan]
[  105.100664]  do_one_initcall+0x60/0x1b0
[  105.104865]  do_init_module+0xd4/0x2cc
[  105.108975]  load_module+0x3110/0x3af0
[  105.113088]  SyS_init_module+0x184/0x1bc
[  105.117409]  ret_fast_syscall+0x0/0x48
[  105.121428]=20
[  105.123130] Freed by task 0:
[  105.126260] (stack is not available)
[  105.130099]=20
[  105.131853] The buggy address belongs to the object at cb183e80
[  105.131853]  which belongs to the cache kmalloc-64 of size 64
[  105.144192] The buggy address is located 1 bytes inside of
[  105.144192]  64-byte region [cb183e80, cb183ec0)
[  105.154867] The buggy address belongs to the page:
[  105.160009] page:ee95b060 count:1 mapcount:0 mapping:cb183000 index:0x=
0
[  105.167020] flags: 0x100(slab)
[  105.170536] raw: 00000100 cb183000 00000000 00000020 00000001 ee95e894=
 d000108c d0000000
[  105.179122] page dumped because: kasan: bad access detected
[  105.185004]=20
[  105.186701] Memory state around the buggy address:
[  105.191884]  cb183d80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  105.198851]  cb183e00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  105.205820] >cb183e80: 00 00 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  105.212698]                  ^
[  105.216091]  cb183f00: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  105.223059]  cb183f80: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  105.229953] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  105.238004] kasan test: kmalloc_uaf use-after-free
[  105.244102] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  105.252221] BUG: KASAN: use-after-free in kmalloc_uaf+0x58/0x68 [test_=
kasan]
[  105.259698] Write of size 1 at addr cb183e08 by task insmod/1453
[  105.266027]=20
[  105.267827] CPU: 2 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  105.278209] Hardware name: Broadcom STB (Flattened Device Tree)
[  105.284703] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  105.293065] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  105.300939] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  105.310252] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  105.320182] [<c03a838c>] (kasan_report) from [<bf00442c>] (kmalloc_uaf=
+0x58/0x68 [test_kasan])
[  105.330209] [<bf00442c>] (kmalloc_uaf [test_kasan]) from [<bf004ce4>] =
(kmalloc_tests_init+0x40/0x35c [test_kasan])
[  105.341674] [<bf004ce4>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  105.351982] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  105.360787] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  105.369505] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  105.378142] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  105.386710]=20
[  105.388423] Allocated by task 1453:
[  105.392317]  kmem_cache_alloc_trace+0xb4/0x170
[  105.397487]  kmalloc_uaf+0x30/0x68 [test_kasan]
[  105.402758]  kmalloc_tests_init+0x40/0x35c [test_kasan]
[  105.408389]  do_one_initcall+0x60/0x1b0
[  105.412597]  do_init_module+0xd4/0x2cc
[  105.416705]  load_module+0x3110/0x3af0
[  105.420819]  SyS_init_module+0x184/0x1bc
[  105.425126]  ret_fast_syscall+0x0/0x48
[  105.429130]=20
[  105.430833] Freed by task 1453:
[  105.434344]  kfree+0x64/0x100
[  105.437983]  kmalloc_uaf+0x50/0x68 [test_kasan]
[  105.443246]  kmalloc_tests_init+0x40/0x35c [test_kasan]
[  105.448877]  do_one_initcall+0x60/0x1b0
[  105.453079]  do_init_module+0xd4/0x2cc
[  105.457188]  load_module+0x3110/0x3af0
[  105.461319]  SyS_init_module+0x184/0x1bc
[  105.465634]  ret_fast_syscall+0x0/0x48
[  105.469638]=20
[  105.471403] The buggy address belongs to the object at cb183e00
[  105.471403]  which belongs to the cache kmalloc-64 of size 64
[  105.483749] The buggy address is located 8 bytes inside of
[  105.483749]  64-byte region [cb183e00, cb183e40)
[  105.494422] The buggy address belongs to the page:
[  105.499573] page:ee95b060 count:1 mapcount:0 mapping:cb183000 index:0x=
0
[  105.506589] flags: 0x100(slab)
[  105.510094] raw: 00000100 cb183000 00000000 00000020 00000001 ee95e894=
 d000108c d0000000
[  105.518688] page dumped because: kasan: bad access detected
[  105.524572]=20
[  105.526279] Memory state around the buggy address:
[  105.531479]  cb183d00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  105.538456]  cb183d80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  105.545437] >cb183e00: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  105.552325]               ^
[  105.555460]  cb183e80: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  105.562442]  cb183f00: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  105.569352] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  105.577198] kasan test: kmalloc_uaf_memset use-after-free in memset
[  105.585014] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  105.593150] BUG: KASAN: use-after-free in kmalloc_tests_init+0x44/0x35=
c [test_kasan]
[  105.601420] Write of size 33 at addr cb183d80 by task insmod/1453
[  105.607836]=20
[  105.609637] CPU: 2 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  105.620019] Hardware name: Broadcom STB (Flattened Device Tree)
[  105.626501] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  105.634870] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  105.642758] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  105.652066] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  105.661682] [<c03a838c>] (kasan_report) from [<c03a7430>] (memset+0x20=
/0x34)
[  105.669707] [<c03a7430>] (memset) from [<bf004ce8>] (kmalloc_tests_ini=
t+0x44/0x35c [test_kasan])
[  105.679557] [<bf004ce8>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  105.689871] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  105.698676] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  105.707390] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  105.716025] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  105.724597]=20
[  105.726311] Allocated by task 1453:
[  105.730203]  kmem_cache_alloc_trace+0xb4/0x170
[  105.735391]  kmalloc_uaf_memset+0x30/0x68 [test_kasan]
[  105.741283]  kmalloc_tests_init+0x44/0x35c [test_kasan]
[  105.746909]  do_one_initcall+0x60/0x1b0
[  105.751109]  do_init_module+0xd4/0x2cc
[  105.755220]  load_module+0x3110/0x3af0
[  105.759361]  SyS_init_module+0x184/0x1bc
[  105.763668]  ret_fast_syscall+0x0/0x48
[  105.767672]=20
[  105.769385] Freed by task 1453:
[  105.772886]  kfree+0x64/0x100
[  105.776546]  kmalloc_uaf_memset+0x50/0x68 [test_kasan]
[  105.782446]  kmalloc_tests_init+0x44/0x35c [test_kasan]
[  105.788062]  do_one_initcall+0x60/0x1b0
[  105.792267]  do_init_module+0xd4/0x2cc
[  105.796396]  load_module+0x3110/0x3af0
[  105.800521]  SyS_init_module+0x184/0x1bc
[  105.804828]  ret_fast_syscall+0x0/0x48
[  105.808834]=20
[  105.810588] The buggy address belongs to the object at cb183d80
[  105.810588]  which belongs to the cache kmalloc-64 of size 64
[  105.822925] The buggy address is located 0 bytes inside of
[  105.822925]  64-byte region [cb183d80, cb183dc0)
[  105.833598] The buggy address belongs to the page:
[  105.838741] page:ee95b060 count:1 mapcount:0 mapping:cb183000 index:0x=
0
[  105.845752] flags: 0x100(slab)
[  105.849263] raw: 00000100 cb183000 00000000 00000020 00000001 ee95e894=
 d000108c d0000000
[  105.857858] page dumped because: kasan: bad access detected
[  105.863739]=20
[  105.865444] Memory state around the buggy address:
[  105.870631]  cb183c80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  105.877613]  cb183d00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  105.884593] >cb183d80: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  105.891483]            ^
[  105.894352]  cb183e00: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  105.901334]  cb183e80: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  105.908233] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  105.916094] kasan test: kmalloc_uaf2 use-after-free after another kmal=
loc
[  105.924783] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  105.932911] BUG: KASAN: use-after-free in kmalloc_uaf2+0x74/0xa4 [test=
_kasan]
[  105.940479] Write of size 1 at addr cb183d28 by task insmod/1453
[  105.946808]=20
[  105.948610] CPU: 2 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  105.958991] Hardware name: Broadcom STB (Flattened Device Tree)
[  105.965474] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  105.973845] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  105.981733] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  105.991041] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  106.000959] [<c03a838c>] (kasan_report) from [<bf0044b0>] (kmalloc_uaf=
2+0x74/0xa4 [test_kasan])
[  106.011065] [<bf0044b0>] (kmalloc_uaf2 [test_kasan]) from [<bf004cec>]=
 (kmalloc_tests_init+0x48/0x35c [test_kasan])
[  106.022610] [<bf004cec>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  106.032925] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  106.041727] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  106.050441] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  106.059077] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  106.067646]=20
[  106.069367] Allocated by task 1453:
[  106.073259]  kmem_cache_alloc_trace+0xb4/0x170
[  106.078436]  kmalloc_uaf2+0x30/0xa4 [test_kasan]
[  106.083796]  kmalloc_tests_init+0x48/0x35c [test_kasan]
[  106.089428]  do_one_initcall+0x60/0x1b0
[  106.093631]  do_init_module+0xd4/0x2cc
[  106.097739]  load_module+0x3110/0x3af0
[  106.101852]  SyS_init_module+0x184/0x1bc
[  106.106158]  ret_fast_syscall+0x0/0x48
[  106.110170]=20
[  106.111878] Freed by task 1453:
[  106.115390]  kfree+0x64/0x100
[  106.119030]  kmalloc_uaf2+0x50/0xa4 [test_kasan]
[  106.124389]  kmalloc_tests_init+0x48/0x35c [test_kasan]
[  106.130007]  do_one_initcall+0x60/0x1b0
[  106.134208]  do_init_module+0xd4/0x2cc
[  106.138345]  load_module+0x3110/0x3af0
[  106.142467]  SyS_init_module+0x184/0x1bc
[  106.146775]  ret_fast_syscall+0x0/0x48
[  106.150781]=20
[  106.152538] The buggy address belongs to the object at cb183d00
[  106.152538]  which belongs to the cache kmalloc-64 of size 64
[  106.164882] The buggy address is located 40 bytes inside of
[  106.164882]  64-byte region [cb183d00, cb183d40)
[  106.175645] The buggy address belongs to the page:
[  106.180788] page:ee95b060 count:1 mapcount:0 mapping:cb183000 index:0x=
0
[  106.187798] flags: 0x100(slab)
[  106.191312] raw: 00000100 cb183000 00000000 00000020 00000001 ee95e894=
 d000108c d0000000
[  106.199900] page dumped because: kasan: bad access detected
[  106.205782]=20
[  106.207483] Memory state around the buggy address:
[  106.212663]  cb183c00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  106.219640]  cb183c80: 00 00 00 00 00 03 fc fc fc fc fc fc fc fc fc fc=

[  106.226619] >cb183d00: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  106.233515]                           ^
[  106.237712]  cb183d80: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  106.244688]  cb183e00: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  106.251590] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  106.262793] kasan test: kmem_cache_oob out-of-bounds in kmem_cache_all=
oc
[  106.270686] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  106.278825] BUG: KASAN: slab-out-of-bounds in kmem_cache_oob+0x88/0xb8=
 [test_kasan]
[  106.286996] Read of size 1 at addr cb184f78 by task insmod/1453
[  106.293239]=20
[  106.295051] CPU: 2 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  106.305445] Hardware name: Broadcom STB (Flattened Device Tree)
[  106.311914] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  106.320283] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  106.328166] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  106.337495] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  106.347417] [<c03a838c>] (kasan_report) from [<bf004908>] (kmem_cache_=
oob+0x88/0xb8 [test_kasan])
[  106.357708] [<bf004908>] (kmem_cache_oob [test_kasan]) from [<bf004cf0=
>] (kmalloc_tests_init+0x4c/0x35c [test_kasan])
[  106.369435] [<bf004cf0>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  106.379750] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  106.388558] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  106.397267] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  106.405922] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  106.414491]=20
[  106.416198] Allocated by task 1453:
[  106.420081]  kmem_cache_alloc+0xac/0x16c
[  106.424720]  kmem_cache_oob+0x64/0xb8 [test_kasan]
[  106.430252]  kmalloc_tests_init+0x4c/0x35c [test_kasan]
[  106.435880]  do_one_initcall+0x60/0x1b0
[  106.440084]  do_init_module+0xd4/0x2cc
[  106.444191]  load_module+0x3110/0x3af0
[  106.448321]  SyS_init_module+0x184/0x1bc
[  106.452635]  ret_fast_syscall+0x0/0x48
[  106.456641]=20
[  106.458353] Freed by task 0:
[  106.461480] (stack is not available)
[  106.465313]=20
[  106.467071] The buggy address belongs to the object at cb184eb0
[  106.467071]  which belongs to the cache test_cache of size 200
[  106.479514] The buggy address is located 0 bytes to the right of
[  106.479514]  200-byte region [cb184eb0, cb184f78)
[  106.490804] The buggy address belongs to the page:
[  106.495945] page:ee95b080 count:1 mapcount:0 mapping:cb184040 index:0x=
0
[  106.502959] flags: 0x100(slab)
[  106.506476] raw: 00000100 cb184040 00000000 0000000f 00000001 cb183b8c=
 cb183b8c cdc35780
[  106.515063] page dumped because: kasan: bad access detected
[  106.520946]=20
[  106.522642] Memory state around the buggy address:
[  106.527824]  cb184e00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  106.534793]  cb184e80: fc fc fc fc fc fc 00 00 00 00 00 00 00 00 00 00=

[  106.541761] >cb184f00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 fc=

[  106.548655]                                                         ^
[  106.555546]  cb184f80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  106.562527]  cb185000: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff=

[  106.569433] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  106.598153] kasan test: memcg_accounted_kmem_cache allocate memcg acco=
unted object
[  107.145531] kasan test: kasan_stack_oob out-of-bounds on stack
[  107.151915] kasan test: kasan_global_oob out-of-bounds global variable=

[  107.159004] kasan test: ksize_unpoisons_memory ksize() unpoisons the w=
hole allocated chunk
[  107.168566] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  107.176705] BUG: KASAN: slab-out-of-bounds in ksize_unpoisons_memory+0=
x6c/0x84 [test_kasan]
[  107.185593] Write of size 1 at addr cb347a40 by task insmod/1453
[  107.191920]=20
[  107.193723] CPU: 3 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  107.204106] Hardware name: Broadcom STB (Flattened Device Tree)
[  107.210581] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  107.218944] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  107.226817] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  107.236127] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  107.246046] [<c03a838c>] (kasan_report) from [<bf004a58>] (ksize_unpoi=
sons_memory+0x6c/0x84 [test_kasan])
[  107.257051] [<bf004a58>] (ksize_unpoisons_memory [test_kasan]) from [<=
bf004d00>] (kmalloc_tests_init+0x5c/0x35c [test_kasan])
[  107.269479] [<bf004d00>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  107.279783] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  107.288579] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  107.297282] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  107.305919] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  107.314480]=20
[  107.316187] Allocated by task 1453:
[  107.320078]  kmem_cache_alloc_trace+0xb4/0x170
[  107.325251]  ksize_unpoisons_memory+0x30/0x84 [test_kasan]
[  107.331495]  kmalloc_tests_init+0x5c/0x35c [test_kasan]
[  107.337113]  do_one_initcall+0x60/0x1b0
[  107.341317]  do_init_module+0xd4/0x2cc
[  107.345424]  load_module+0x3110/0x3af0
[  107.349540]  SyS_init_module+0x184/0x1bc
[  107.353848]  ret_fast_syscall+0x0/0x48
[  107.357855]=20
[  107.359554] Freed by task 0:
[  107.362677] (stack is not available)
[  107.366501]=20
[  107.368256] The buggy address belongs to the object at cb3479c0
[  107.368256]  which belongs to the cache kmalloc-128 of size 128
[  107.380776] The buggy address is located 0 bytes to the right of
[  107.380776]  128-byte region [cb3479c0, cb347a40)
[  107.392062] The buggy address belongs to the page:
[  107.397206] page:ee95e8e0 count:1 mapcount:0 mapping:cb347000 index:0x=
0
[  107.404219] flags: 0x100(slab)
[  107.407727] raw: 00000100 cb347000 00000000 00000015 00000001 ee967b94=
 d000110c d00000c0
[  107.416312] page dumped because: kasan: bad access detected
[  107.422192]=20
[  107.423888] Memory state around the buggy address:
[  107.429068]  cb347900: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  107.436035]  cb347980: fc fc fc fc fc fc fc fc 00 00 00 00 00 00 00 00=

[  107.443004] >cb347a00: 00 00 00 00 00 00 00 00 fc fc fc fc fc fc fc fc=

[  107.449890]                                    ^
[  107.454892]  cb347a80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb=

[  107.461859]  cb347b00: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb=

[  107.468756] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  107.478535] kasan test: copy_user_test out-of-bounds in copy_from_user=
()
[  107.485803] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  107.493934] BUG: KASAN: slab-out-of-bounds in copy_user_test+0xb4/0x23=
4 [test_kasan]
[  107.502195] Write of size 11 at addr cb344100 by task insmod/1453
[  107.508613]=20
[  107.510413] CPU: 3 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  107.520797] Hardware name: Broadcom STB (Flattened Device Tree)
[  107.527267] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  107.535629] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  107.543505] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  107.552815] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  107.562729] [<c03a838c>] (kasan_report) from [<bf004b24>] (copy_user_t=
est+0xb4/0x234 [test_kasan])
[  107.573101] [<bf004b24>] (copy_user_test [test_kasan]) from [<bf004d04=
>] (kmalloc_tests_init+0x60/0x35c [test_kasan])
[  107.584818] [<bf004d04>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  107.595123] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  107.603918] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  107.612623] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  107.621261] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  107.629818]=20
[  107.631524] Allocated by task 1453:
[  107.635412]  kmem_cache_alloc_trace+0xb4/0x170
[  107.640577]  copy_user_test+0x24/0x234 [test_kasan]
[  107.646195]  kmalloc_tests_init+0x60/0x35c [test_kasan]
[  107.651813]  do_one_initcall+0x60/0x1b0
[  107.656014]  do_init_module+0xd4/0x2cc
[  107.660125]  load_module+0x3110/0x3af0
[  107.664241]  SyS_init_module+0x184/0x1bc
[  107.668549]  ret_fast_syscall+0x0/0x48
[  107.672553]=20
[  107.674254] Freed by task 0:
[  107.677374] (stack is not available)
[  107.681198]=20
[  107.682953] The buggy address belongs to the object at cb344100
[  107.682953]  which belongs to the cache kmalloc-64 of size 64
[  107.695289] The buggy address is located 0 bytes inside of
[  107.695289]  64-byte region [cb344100, cb344140)
[  107.705951] The buggy address belongs to the page:
[  107.711102] page:ee95e880 count:1 mapcount:0 mapping:cb344000 index:0x=
cb344800
[  107.718822] flags: 0x100(slab)
[  107.722333] raw: 00000100 cb344000 cb344800 0000001f 00000001 d0001084=
 ee963174 d0000000
[  107.730918] page dumped because: kasan: bad access detected
[  107.736798]=20
[  107.738496] Memory state around the buggy address:
[  107.743677]  cb344000: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  107.750644]  cb344080: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  107.757613] >cb344100: 00 02 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  107.764491]               ^
[  107.767617]  cb344180: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  107.774585]  cb344200: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  107.781477] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  107.789655] kasan test: copy_user_test out-of-bounds in copy_to_user()=

[  107.796746] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  107.804879] BUG: KASAN: slab-out-of-bounds in copy_user_test+0x12c/0x2=
34 [test_kasan]
[  107.813230] Read of size 11 at addr cb344100 by task insmod/1453
[  107.819558]=20
[  107.821357] CPU: 3 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  107.831739] Hardware name: Broadcom STB (Flattened Device Tree)
[  107.838207] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  107.846572] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  107.854448] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  107.863759] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  107.873676] [<c03a838c>] (kasan_report) from [<bf004b9c>] (copy_user_t=
est+0x12c/0x234 [test_kasan])
[  107.884138] [<bf004b9c>] (copy_user_test [test_kasan]) from [<bf004d04=
>] (kmalloc_tests_init+0x60/0x35c [test_kasan])
[  107.895852] [<bf004d04>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  107.906156] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  107.914947] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  107.923650] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  107.932286] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  107.940847]=20
[  107.942552] Allocated by task 1453:
[  107.946439]  kmem_cache_alloc_trace+0xb4/0x170
[  107.951604]  copy_user_test+0x24/0x234 [test_kasan]
[  107.957221]  kmalloc_tests_init+0x60/0x35c [test_kasan]
[  107.962839]  do_one_initcall+0x60/0x1b0
[  107.967039]  do_init_module+0xd4/0x2cc
[  107.971151]  load_module+0x3110/0x3af0
[  107.975266]  SyS_init_module+0x184/0x1bc
[  107.979575]  ret_fast_syscall+0x0/0x48
[  107.983581]=20
[  107.985281] Freed by task 0:
[  107.988405] (stack is not available)
[  107.992231]=20
[  107.993985] The buggy address belongs to the object at cb344100
[  107.993985]  which belongs to the cache kmalloc-64 of size 64
[  108.006323] The buggy address is located 0 bytes inside of
[  108.006323]  64-byte region [cb344100, cb344140)
[  108.016983] The buggy address belongs to the page:
[  108.022132] page:ee95e880 count:1 mapcount:0 mapping:cb344000 index:0x=
cb344800
[  108.029848] flags: 0x100(slab)
[  108.033360] raw: 00000100 cb344000 cb344800 0000001f 00000001 d0001084=
 ee963174 d0000000
[  108.041943] page dumped because: kasan: bad access detected
[  108.047827]=20
[  108.049523] Memory state around the buggy address:
[  108.054704]  cb344000: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  108.061671]  cb344080: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  108.068641] >cb344100: 00 02 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  108.075517]               ^
[  108.078643]  cb344180: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  108.085610]  cb344200: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  108.092507] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  108.101783] kasan test: copy_user_test out-of-bounds in __copy_from_us=
er()
[  108.109227] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  108.117361] BUG: KASAN: slab-out-of-bounds in copy_user_test+0x158/0x2=
34 [test_kasan]
[  108.125709] Write of size 11 at addr cb344100 by task insmod/1453
[  108.132128]=20
[  108.133928] CPU: 3 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  108.144311] Hardware name: Broadcom STB (Flattened Device Tree)
[  108.150781] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  108.159144] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  108.167016] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  108.176328] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  108.186244] [<c03a838c>] (kasan_report) from [<bf004bc8>] (copy_user_t=
est+0x158/0x234 [test_kasan])
[  108.196705] [<bf004bc8>] (copy_user_test [test_kasan]) from [<bf004d04=
>] (kmalloc_tests_init+0x60/0x35c [test_kasan])
[  108.208423] [<bf004d04>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  108.218726] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  108.227519] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  108.236221] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  108.244858] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  108.253418]=20
[  108.255125] Allocated by task 1453:
[  108.259014]  kmem_cache_alloc_trace+0xb4/0x170
[  108.264181]  copy_user_test+0x24/0x234 [test_kasan]
[  108.269799]  kmalloc_tests_init+0x60/0x35c [test_kasan]
[  108.275416]  do_one_initcall+0x60/0x1b0
[  108.279617]  do_init_module+0xd4/0x2cc
[  108.283727]  load_module+0x3110/0x3af0
[  108.287839]  SyS_init_module+0x184/0x1bc
[  108.292147]  ret_fast_syscall+0x0/0x48
[  108.296154]=20
[  108.297852] Freed by task 0:
[  108.300973] (stack is not available)
[  108.304797]=20
[  108.306555] The buggy address belongs to the object at cb344100
[  108.306555]  which belongs to the cache kmalloc-64 of size 64
[  108.318895] The buggy address is located 0 bytes inside of
[  108.318895]  64-byte region [cb344100, cb344140)
[  108.329557] The buggy address belongs to the page:
[  108.334708] page:ee95e880 count:1 mapcount:0 mapping:cb344000 index:0x=
cb344800
[  108.342426] flags: 0x100(slab)
[  108.345936] raw: 00000100 cb344000 cb344800 0000001f 00000001 d0001084=
 ee963174 d0000000
[  108.354520] page dumped because: kasan: bad access detected
[  108.360400]=20
[  108.362099] Memory state around the buggy address:
[  108.367278]  cb344000: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  108.374245]  cb344080: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  108.381212] >cb344100: 00 02 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  108.388088]               ^
[  108.391212]  cb344180: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  108.398180]  cb344200: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  108.405076] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  108.413052] kasan test: copy_user_test out-of-bounds in __copy_to_user=
()
[  108.420442] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  108.428575] BUG: KASAN: slab-out-of-bounds in copy_user_test+0x184/0x2=
34 [test_kasan]
[  108.436926] Read of size 11 at addr cb344100 by task insmod/1453
[  108.443256]=20
[  108.445055] CPU: 3 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  108.455438] Hardware name: Broadcom STB (Flattened Device Tree)
[  108.461907] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  108.470272] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  108.478148] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  108.487457] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  108.497374] [<c03a838c>] (kasan_report) from [<bf004bf4>] (copy_user_t=
est+0x184/0x234 [test_kasan])
[  108.507838] [<bf004bf4>] (copy_user_test [test_kasan]) from [<bf004d04=
>] (kmalloc_tests_init+0x60/0x35c [test_kasan])
[  108.519555] [<bf004d04>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  108.529858] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  108.538652] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  108.547355] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  108.555992] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  108.564551]=20
[  108.566256] Allocated by task 1453:
[  108.570143]  kmem_cache_alloc_trace+0xb4/0x170
[  108.575307]  copy_user_test+0x24/0x234 [test_kasan]
[  108.580926]  kmalloc_tests_init+0x60/0x35c [test_kasan]
[  108.586544]  do_one_initcall+0x60/0x1b0
[  108.590744]  do_init_module+0xd4/0x2cc
[  108.594852]  load_module+0x3110/0x3af0
[  108.598968]  SyS_init_module+0x184/0x1bc
[  108.603277]  ret_fast_syscall+0x0/0x48
[  108.607280]=20
[  108.608980] Freed by task 0:
[  108.612101] (stack is not available)
[  108.615927]=20
[  108.617680] The buggy address belongs to the object at cb344100
[  108.617680]  which belongs to the cache kmalloc-64 of size 64
[  108.630019] The buggy address is located 0 bytes inside of
[  108.630019]  64-byte region [cb344100, cb344140)
[  108.640683] The buggy address belongs to the page:
[  108.645833] page:ee95e880 count:1 mapcount:0 mapping:cb344000 index:0x=
cb344800
[  108.653549] flags: 0x100(slab)
[  108.657059] raw: 00000100 cb344000 cb344800 0000001f 00000001 d0001084=
 ee963174 d0000000
[  108.665644] page dumped because: kasan: bad access detected
[  108.671525]=20
[  108.673222] Memory state around the buggy address:
[  108.678403]  cb344000: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  108.685371]  cb344080: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  108.692338] >cb344100: 00 02 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  108.699215]               ^
[  108.702340]  cb344180: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  108.709306]  cb344200: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  108.716201] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  108.724182] kasan test: copy_user_test out-of-bounds in __copy_from_us=
er_inatomic()
[  108.732511] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  108.740646] BUG: KASAN: slab-out-of-bounds in copy_user_test+0x1b0/0x2=
34 [test_kasan]
[  108.748996] Write of size 11 at addr cb344100 by task insmod/1453
[  108.755415]=20
[  108.757209] CPU: 3 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  108.767593] Hardware name: Broadcom STB (Flattened Device Tree)
[  108.774063] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  108.782426] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  108.790300] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  108.799611] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  108.809526] [<c03a838c>] (kasan_report) from [<bf004c20>] (copy_user_t=
est+0x1b0/0x234 [test_kasan])
[  108.819989] [<bf004c20>] (copy_user_test [test_kasan]) from [<bf004d04=
>] (kmalloc_tests_init+0x60/0x35c [test_kasan])
[  108.831703] [<bf004d04>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  108.842007] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  108.850803] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  108.859506] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  108.868144] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  108.876702]=20
[  108.878410] Allocated by task 1453:
[  108.882300]  kmem_cache_alloc_trace+0xb4/0x170
[  108.887470]  copy_user_test+0x24/0x234 [test_kasan]
[  108.893088]  kmalloc_tests_init+0x60/0x35c [test_kasan]
[  108.898705]  do_one_initcall+0x60/0x1b0
[  108.902906]  do_init_module+0xd4/0x2cc
[  108.907016]  load_module+0x3110/0x3af0
[  108.911130]  SyS_init_module+0x184/0x1bc
[  108.915437]  ret_fast_syscall+0x0/0x48
[  108.919441]=20
[  108.921140] Freed by task 0:
[  108.924260] (stack is not available)
[  108.928084]=20
[  108.929836] The buggy address belongs to the object at cb344100
[  108.929836]  which belongs to the cache kmalloc-64 of size 64
[  108.942173] The buggy address is located 0 bytes inside of
[  108.942173]  64-byte region [cb344100, cb344140)
[  108.952835] The buggy address belongs to the page:
[  108.957986] page:ee95e880 count:1 mapcount:0 mapping:cb344000 index:0x=
cb344800
[  108.965702] flags: 0x100(slab)
[  108.969213] raw: 00000100 cb344000 cb344800 0000001f 00000001 d0001084=
 ee963174 d0000000
[  108.977800] page dumped because: kasan: bad access detected
[  108.983683]=20
[  108.985379] Memory state around the buggy address:
[  108.990559]  cb344000: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  108.997526]  cb344080: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  109.004496] >cb344100: 00 02 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  109.011374]               ^
[  109.014497]  cb344180: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  109.021465]  cb344200: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  109.028359] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  109.036546] kasan test: copy_user_test out-of-bounds in __copy_to_user=
_inatomic()
[  109.044665] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  109.052799] BUG: KASAN: slab-out-of-bounds in copy_user_test+0x1dc/0x2=
34 [test_kasan]
[  109.061147] Read of size 11 at addr cb344100 by task insmod/1453
[  109.067476]=20
[  109.069276] CPU: 3 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  109.079660] Hardware name: Broadcom STB (Flattened Device Tree)
[  109.086129] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  109.094491] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  109.102366] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  109.111678] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  109.121592] [<c03a838c>] (kasan_report) from [<bf004c4c>] (copy_user_t=
est+0x1dc/0x234 [test_kasan])
[  109.132052] [<bf004c4c>] (copy_user_test [test_kasan]) from [<bf004d04=
>] (kmalloc_tests_init+0x60/0x35c [test_kasan])
[  109.143765] [<bf004d04>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  109.154070] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  109.162863] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  109.171565] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  109.180203] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  109.188763]=20
[  109.190472] Allocated by task 1453:
[  109.194361]  kmem_cache_alloc_trace+0xb4/0x170
[  109.199529]  copy_user_test+0x24/0x234 [test_kasan]
[  109.205147]  kmalloc_tests_init+0x60/0x35c [test_kasan]
[  109.210765]  do_one_initcall+0x60/0x1b0
[  109.214965]  do_init_module+0xd4/0x2cc
[  109.219073]  load_module+0x3110/0x3af0
[  109.223188]  SyS_init_module+0x184/0x1bc
[  109.227497]  ret_fast_syscall+0x0/0x48
[  109.231503]=20
[  109.233201] Freed by task 0:
[  109.236322] (stack is not available)
[  109.240146]=20
[  109.241898] The buggy address belongs to the object at cb344100
[  109.241898]  which belongs to the cache kmalloc-64 of size 64
[  109.254235] The buggy address is located 0 bytes inside of
[  109.254235]  64-byte region [cb344100, cb344140)
[  109.264898] The buggy address belongs to the page:
[  109.270049] page:ee95e880 count:1 mapcount:0 mapping:cb344000 index:0x=
cb344800
[  109.277765] flags: 0x100(slab)
[  109.281277] raw: 00000100 cb344000 cb344800 0000001f 00000001 d0001084=
 ee963174 d0000000
[  109.289861] page dumped because: kasan: bad access detected
[  109.295742]=20
[  109.297438] Memory state around the buggy address:
[  109.302618]  cb344000: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  109.309585]  cb344080: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  109.316555] >cb344100: 00 02 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  109.323431]               ^
[  109.326556]  cb344180: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  109.333526]  cb344200: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  109.340420] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  109.348407] kasan test: copy_user_test out-of-bounds in strncpy_from_u=
ser()
[  109.355915] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  109.363705] BUG: KASAN: slab-out-of-bounds in strncpy_from_user+0x58/0=
x1f4
[  109.370996] Write of size 11 at addr cb344100 by task insmod/1453
[  109.377414]=20
[  109.379217] CPU: 3 PID: 1453 Comm: insmod Tainted: G    B           4.=
14.0-rc4-00095-gcd1a365fca2e-dirty #31
[  109.389600] Hardware name: Broadcom STB (Flattened Device Tree)
[  109.396070] [<c0214cb4>] (unwind_backtrace) from [<c020e664>] (show_st=
ack+0x10/0x14)
[  109.404433] [<c020e664>] (show_stack) from [<c0c7daa8>] (dump_stack+0x=
90/0xa4)
[  109.412306] [<c0c7daa8>] (dump_stack) from [<c03a7c88>] (print_address=
_description+0x50/0x24c)
[  109.421615] [<c03a7c88>] (print_address_description) from [<c03a838c>]=
 (kasan_report+0x238/0x324)
[  109.431187] [<c03a838c>] (kasan_report) from [<c06ba0e8>] (strncpy_fro=
m_user+0x58/0x1f4)
[  109.440325] [<c06ba0e8>] (strncpy_from_user) from [<bf004c7c>] (copy_u=
ser_test+0x20c/0x234 [test_kasan])
[  109.451233] [<bf004c7c>] (copy_user_test [test_kasan]) from [<bf004d04=
>] (kmalloc_tests_init+0x60/0x35c [test_kasan])
[  109.462947] [<bf004d04>] (kmalloc_tests_init [test_kasan]) from [<c020=
1ef4>] (do_one_initcall+0x60/0x1b0)
[  109.473251] [<c0201ef4>] (do_one_initcall) from [<c02db4bc>] (do_init_=
module+0xd4/0x2cc)
[  109.482046] [<c02db4bc>] (do_init_module) from [<c02d9fe4>] (load_modu=
le+0x3110/0x3af0)
[  109.490748] [<c02d9fe4>] (load_module) from [<c02dab48>] (SyS_init_mod=
ule+0x184/0x1bc)
[  109.499385] [<c02dab48>] (SyS_init_module) from [<c0209640>] (ret_fast=
_syscall+0x0/0x48)
[  109.507946]=20
[  109.509652] Allocated by task 1453:
[  109.513540]  kmem_cache_alloc_trace+0xb4/0x170
[  109.518705]  copy_user_test+0x24/0x234 [test_kasan]
[  109.524323]  kmalloc_tests_init+0x60/0x35c [test_kasan]
[  109.529941]  do_one_initcall+0x60/0x1b0
[  109.534142]  do_init_module+0xd4/0x2cc
[  109.538252]  load_module+0x3110/0x3af0
[  109.542359]  SyS_init_module+0x184/0x1bc
[  109.546668]  ret_fast_syscall+0x0/0x48
[  109.550672]=20
[  109.552370] Freed by task 0:
[  109.555490] (stack is not available)
[  109.559315]=20
[  109.561069] The buggy address belongs to the object at cb344100
[  109.561069]  which belongs to the cache kmalloc-64 of size 64
[  109.573405] The buggy address is located 0 bytes inside of
[  109.573405]  64-byte region [cb344100, cb344140)
[  109.584068] The buggy address belongs to the page:
[  109.589219] page:ee95e880 count:1 mapcount:0 mapping:cb344000 index:0x=
cb344800
[  109.596935] flags: 0x100(slab)
[  109.600444] raw: 00000100 cb344000 cb344800 0000001f 00000001 ee963174=
 d0001084 d0000000
[  109.609032] page dumped because: kasan: bad access detected
[  109.614911]=20
[  109.616608] Memory state around the buggy address:
[  109.621788]  cb344000: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  109.628756]  cb344080: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  109.635723] >cb344100: 00 02 fc fc fc fc fc fc fc fc fc fc fc fc fc fc=

[  109.642600]               ^
[  109.645725]  cb344180: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  109.652693]  cb344200: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc=

[  109.659589] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[  109.668931] kasan test: use_after_scope_test use-after-scope on int
[  109.675755] kasan test: use_after_scope_test use-after-scope on array
insmod: can't insert 'test_kasan.ko': Resource temporarily unavailable


--------------51DFA7131273B4173E983701--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
