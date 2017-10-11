Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id A92706B025E
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 15:50:28 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id m6so6789276qtc.6
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 12:50:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k35sor3037339qta.53.2017.10.11.12.50.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Oct 2017 12:50:27 -0700 (PDT)
Subject: Re: [PATCH 00/11] KASan for arm
From: Florian Fainelli <f.fainelli@gmail.com>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <26660524-3b0a-c634-e8ce-4ba7e10c055d@gmail.com>
Message-ID: <bb809843-4fb8-0827-170e-26efde0eb37f@gmail.com>
Date: Wed, 11 Oct 2017 12:50:21 -0700
MIME-Version: 1.0
In-Reply-To: <26660524-3b0a-c634-e8ce-4ba7e10c055d@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Abbott Liu <liuwenliang@huawei.com>, linux@armlinux.org.uk, aryabinin@virtuozzo.com, afzal.mohd.ma@gmail.com, labbott@redhat.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, cdall@linaro.org, marc.zyngier@arm.com, catalin.marinas@arm.com, akpm@linux-foundation.org, mawilcox@microsoft.com, tglx@linutronix.de, thgarnie@google.com, keescook@chromium.org, arnd@arndb.de, vladimir.murzin@arm.com, tixy@linaro.org, ard.biesheuvel@linaro.org, robin.murphy@arm.com, mingo@kernel.org, grygorii.strashko@linaro.org
Cc: glider@google.com, dvyukov@google.com, opendmb@gmail.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, jiazhenghua@huawei.com, dylix.dailei@huawei.com, zengweilin@huawei.com, heshaoliang@huawei.com

On 10/11/2017 12:13 PM, Florian Fainelli wrote:
> Hi Abbott,
> 
> On 10/11/2017 01:22 AM, Abbott Liu wrote:
>> Hi,all:
>>    These patches add arch specific code for kernel address sanitizer 
>> (see Documentation/kasan.txt). 
>>
>>    1/8 of kernel addresses reserved for shadow memory. There was no 
>> big enough hole for this, so virtual addresses for shadow were 
>> stolen from user space.
>>    
>>    At early boot stage the whole shadow region populated with just 
>> one physical page (kasan_zero_page). Later, this page reused 
>> as readonly zero shadow for some memory that KASan currently 
>> don't track (vmalloc). 
>>
>>   After mapping the physical memory, pages for shadow memory are 
>> allocated and mapped. 
>>
>>   KASan's stack instrumentation significantly increases stack's 
>> consumption, so CONFIG_KASAN doubles THREAD_SIZE.
>>   
>>   Functions like memset/memmove/memcpy do a lot of memory accesses. 
>> If bad pointer passed to one of these function it is important 
>> to catch this. Compiler's instrumentation cannot do this since 
>> these functions are written in assembly. 
>>
>>   KASan replaces memory functions with manually instrumented variants. 
>> Original functions declared as weak symbols so strong definitions 
>> in mm/kasan/kasan.c could replace them. Original functions have aliases 
>> with '__' prefix in name, so we could call non-instrumented variant 
>> if needed. 
>>
>>   Some files built without kasan instrumentation (e.g. mm/slub.c). 
>> Original mem* function replaced (via #define) with prefixed variants 
>> to disable memory access checks for such files. 
>>
>>   On arm LPAE architecture,  the mapping table of KASan shadow memory(if 
>> PAGE_OFFSET is 0xc0000000, the KASan shadow memory's virtual space is 
>> 0xb6e000000~0xbf000000) can't be filled in do_translation_fault function, 
>> because kasan instrumentation maybe cause do_translation_fault function 
>> accessing KASan shadow memory. The accessing of KASan shadow memory in 
>> do_translation_fault function maybe cause dead circle. So the mapping table 
>> of KASan shadow memory need be copyed in pgd_alloc function.
>>
>>
>> Most of the code comes from:
>> https://github.com/aryabinin/linux/commit/0b54f17e70ff50a902c4af05bb92716eb95acefe.
> 
> Thanks for putting these patches together, I can't get a kernel to build
> with ARM_LPAE=y or ARM_LPAE=n that does not result in the following:
> 
>   AS      arch/arm/kernel/entry-common.o
> arch/arm/kernel/entry-common.S: Assembler messages:
> arch/arm/kernel/entry-common.S:53: Error: invalid constant
> (ffffffffb6e00000) after fixup
> arch/arm/kernel/entry-common.S:118: Error: invalid constant
> (ffffffffb6e00000) after fixup
> scripts/Makefile.build:412: recipe for target
> 'arch/arm/kernel/entry-common.o' failed
> make[3]: *** [arch/arm/kernel/entry-common.o] Error 1
> Makefile:1019: recipe for target 'arch/arm/kernel' failed
> make[2]: *** [arch/arm/kernel] Error 2
> make[2]: *** Waiting for unfinished jobs....
> 
> This is coming from the increase in TASK_SIZE it seems.
> 
> This is on top of v4.14-rc4-84-gff5abbe799e2

Seems like we can use the following to get through that build failure:

diff --git a/arch/arm/kernel/entry-common.S b/arch/arm/kernel/entry-common.S
index 99c908226065..0de1160d136e 100644
--- a/arch/arm/kernel/entry-common.S
+++ b/arch/arm/kernel/entry-common.S
@@ -50,7 +50,13 @@ ret_fast_syscall:
  UNWIND(.cantunwind    )
        disable_irq_notrace                     @ disable interrupts
        ldr     r2, [tsk, #TI_ADDR_LIMIT]
+#ifdef CONFIG_KASAN
+       movw    r1, #:lower16:TASK_SIZE
+       movt    r1, #:upper16:TASK_SIZE
+       cmp     r2, r1
+#else
        cmp     r2, #TASK_SIZE
+#endif
        blne    addr_limit_check_failed
        ldr     r1, [tsk, #TI_FLAGS]            @ re-check for syscall
tracing
        tst     r1, #_TIF_SYSCALL_WORK | _TIF_WORK_MASK
@@ -115,7 +121,13 @@ ret_slow_syscall:
        disable_irq_notrace                     @ disable interrupts
 ENTRY(ret_to_user_from_irq)
        ldr     r2, [tsk, #TI_ADDR_LIMIT]
+#ifdef CONFIG_KASAN
+       movw    r1, #:lower16:TASK_SIZE
+       movt    r1, #:upper16:TASK_SIZE
+       cmp     r2, r1
+#else
        cmp     r2, #TASK_SIZE
+#endif
        blne    addr_limit_check_failed
        ldr     r1, [tsk, #TI_FLAGS]
        tst     r1, #_TIF_WORK_MASK



but then we will see another set of build failures with the decompressor
code:

WARNING: modpost: Found 2 section mismatch(es).
To see full details build your kernel with:
'make CONFIG_DEBUG_SECTION_MISMATCH=y'
  KSYM    .tmp_kallsyms1.o
  KSYM    .tmp_kallsyms2.o
  LD      vmlinux
  SORTEX  vmlinux
  SYSMAP  System.map
  OBJCOPY arch/arm/boot/Image
  Kernel: arch/arm/boot/Image is ready
  LDS     arch/arm/boot/compressed/vmlinux.lds
  AS      arch/arm/boot/compressed/head.o
  XZKERN  arch/arm/boot/compressed/piggy_data
  CC      arch/arm/boot/compressed/misc.o
  CC      arch/arm/boot/compressed/decompress.o
  CC      arch/arm/boot/compressed/string.o
arch/arm/boot/compressed/decompress.c:51:0: warning: "memmove" redefined
 #define memmove memmove

In file included from arch/arm/boot/compressed/decompress.c:7:0:
./arch/arm/include/asm/string.h:67:0: note: this is the location of the
previous definition
 #define memmove(dst, src, len) __memmove(dst, src, len)

arch/arm/boot/compressed/decompress.c:52:0: warning: "memcpy" redefined
 #define memcpy memcpy

In file included from arch/arm/boot/compressed/decompress.c:7:0:
./arch/arm/include/asm/string.h:66:0: note: this is the location of the
previous definition
 #define memcpy(dst, src, len) __memcpy(dst, src, len)

  SHIPPED arch/arm/boot/compressed/hyp-stub.S
  SHIPPED arch/arm/boot/compressed/fdt_rw.c
  SHIPPED arch/arm/boot/compressed/fdt.h
  SHIPPED arch/arm/boot/compressed/libfdt.h
  SHIPPED arch/arm/boot/compressed/libfdt_internal.h
  SHIPPED arch/arm/boot/compressed/fdt_ro.c
  SHIPPED arch/arm/boot/compressed/fdt_wip.c
  SHIPPED arch/arm/boot/compressed/fdt.c
  CC      arch/arm/boot/compressed/atags_to_fdt.o
  SHIPPED arch/arm/boot/compressed/lib1funcs.S
  SHIPPED arch/arm/boot/compressed/ashldi3.S
  SHIPPED arch/arm/boot/compressed/bswapsdi2.S
  AS      arch/arm/boot/compressed/hyp-stub.o
  CC      arch/arm/boot/compressed/fdt_rw.o
  CC      arch/arm/boot/compressed/fdt_ro.o
  CC      arch/arm/boot/compressed/fdt_wip.o
  CC      arch/arm/boot/compressed/fdt.o
  AS      arch/arm/boot/compressed/lib1funcs.o
  AS      arch/arm/boot/compressed/ashldi3.o
  AS      arch/arm/boot/compressed/bswapsdi2.o
  AS      arch/arm/boot/compressed/piggy.o
  LD      arch/arm/boot/compressed/vmlinux
arch/arm/boot/compressed/decompress.o: In function `fill_temp':
/home/fainelli/dev/linux/arch/arm/boot/compressed/../../../../lib/xz/xz_dec_stream.c:162:
undefined reference to `memcpy'
arch/arm/boot/compressed/decompress.o: In function `bcj_flush':
/home/fainelli/dev/linux/arch/arm/boot/compressed/../../../../lib/xz/xz_dec_bcj.c:404:
undefined reference to `memcpy'
/home/fainelli/dev/linux/arch/arm/boot/compressed/../../../../lib/xz/xz_dec_bcj.c:409:
undefined reference to `memmove'
arch/arm/boot/compressed/decompress.o: In function `lzma2_lzma':
/home/fainelli/dev/linux/arch/arm/boot/compressed/../../../../lib/xz/xz_dec_lzma2.c:919:
undefined reference to `memcpy'
arch/arm/boot/compressed/decompress.o: In function `dict_flush':
/home/fainelli/dev/linux/arch/arm/boot/compressed/../../../../lib/xz/xz_dec_lzma2.c:424:
undefined reference to `memcpy'
arch/arm/boot/compressed/decompress.o: In function `dict_uncompressed':
/home/fainelli/dev/linux/arch/arm/boot/compressed/../../../../lib/xz/xz_dec_lzma2.c:390:
undefined reference to `memcpy'
/home/fainelli/dev/linux/arch/arm/boot/compressed/../../../../lib/xz/xz_dec_lzma2.c:400:
undefined reference to `memcpy'
arch/arm/boot/compressed/decompress.o: In function `lzma2_lzma':
/home/fainelli/dev/linux/arch/arm/boot/compressed/../../../../lib/xz/xz_dec_lzma2.c:859:
undefined reference to `memcpy'
/home/fainelli/dev/linux/arch/arm/boot/compressed/../../../../lib/xz/xz_dec_lzma2.c:884:
undefined reference to `memmove'
arch/arm/boot/compressed/decompress.o: In function `xz_dec_bcj_run':
/home/fainelli/dev/linux/arch/arm/boot/compressed/../../../../lib/xz/xz_dec_bcj.c:451:
undefined reference to `memcpy'
/home/fainelli/dev/linux/arch/arm/boot/compressed/../../../../lib/xz/xz_dec_bcj.c:471:
undefined reference to `memcpy'
arch/arm/boot/compressed/fdt_rw.o: In function `fdt_add_subnode_namelen':
/home/fainelli/dev/linux/arch/arm/boot/compressed/fdt_rw.c:366:
undefined reference to `__memset'
arch/arm/boot/compressed/Makefile:182: recipe for target
'arch/arm/boot/compressed/vmlinux' failed
make[4]: *** [arch/arm/boot/compressed/vmlinux] Error 1
arch/arm/boot/Makefile:53: recipe for target
'arch/arm/boot/compressed/vmlinux' failed
make[3]: *** [arch/arm/boot/compressed/vmlinux] Error 2

> 
> Thank you
> 
>>
>> These patches are tested on vexpress-ca15, vexpress-ca9
>>
>> Cc: Andrey Ryabinin <a.ryabinin@samsung.com>
>> Tested-by: Abbott Liu <liuwenliang@huawei.com>
>> Signed-off-by: Abbott Liu <liuwenliang@huawei.com>
>>
>> Abbott Liu (6):
>>   Define the virtual space of KASan's shadow region
>>   change memory_is_poisoned_16 for aligned error
>>   Add support arm LPAE
>>   Don't need to map the shadow of KASan's shadow memory
>>   Change mapping of kasan_zero_page int readonly
>>   Add KASan layout
>>
>> Andrey Ryabinin (5):
>>   Initialize the mapping of KASan shadow memory
>>   replace memory function
>>   arm: Kconfig: enable KASan
>>   Disable kasan's instrumentation
>>   Avoid cleaning the KASan shadow area's mapping table
>>
>>  arch/arm/Kconfig                   |   1 +
>>  arch/arm/boot/compressed/Makefile  |   1 +
>>  arch/arm/include/asm/kasan.h       |  20 +++
>>  arch/arm/include/asm/kasan_def.h   |  51 +++++++
>>  arch/arm/include/asm/memory.h      |   5 +
>>  arch/arm/include/asm/pgalloc.h     |   5 +-
>>  arch/arm/include/asm/pgtable.h     |   1 +
>>  arch/arm/include/asm/proc-fns.h    |  33 +++++
>>  arch/arm/include/asm/string.h      |  18 ++-
>>  arch/arm/include/asm/thread_info.h |   4 +
>>  arch/arm/kernel/entry-armv.S       |   7 +-
>>  arch/arm/kernel/head-common.S      |   4 +
>>  arch/arm/kernel/setup.c            |   2 +
>>  arch/arm/kernel/unwind.c           |   3 +-
>>  arch/arm/lib/memcpy.S              |   3 +
>>  arch/arm/lib/memmove.S             |   5 +-
>>  arch/arm/lib/memset.S              |   3 +
>>  arch/arm/mm/Makefile               |   5 +
>>  arch/arm/mm/init.c                 |   6 +
>>  arch/arm/mm/kasan_init.c           | 265 +++++++++++++++++++++++++++++++++++++
>>  arch/arm/mm/mmu.c                  |   7 +-
>>  arch/arm/mm/pgd.c                  |  12 ++
>>  arch/arm/vdso/Makefile             |   2 +
>>  mm/kasan/kasan.c                   |  22 ++-
>>  24 files changed, 478 insertions(+), 7 deletions(-)
>>  create mode 100644 arch/arm/include/asm/kasan.h
>>  create mode 100644 arch/arm/include/asm/kasan_def.h
>>  create mode 100644 arch/arm/mm/kasan_init.c
>>
> 
> 


-- 
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
