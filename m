Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id D4C8A6B0035
	for <linux-mm@kvack.org>; Sat, 13 Sep 2014 21:35:56 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so3845537pdj.38
        for <linux-mm@kvack.org>; Sat, 13 Sep 2014 18:35:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id nr9si16033563pdb.206.2014.09.13.18.35.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Sep 2014 18:35:55 -0700 (PDT)
Message-ID: <5414F0F3.4000001@infradead.org>
Date: Sat, 13 Sep 2014 18:35:47 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH v2 01/10] Add kernel address sanitizer infrastructure.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com> <1410359487-31938-2-git-send-email-a.ryabinin@samsung.com>
In-Reply-To: <1410359487-31938-2-git-send-email-a.ryabinin@samsung.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, Michal Marek <mmarek@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On 09/10/14 07:31, Andrey Ryabinin wrote:
> Kernel Address sanitizer (KASan) is a dynamic memory error detector. It provides
> fast and comprehensive solution for finding use-after-free and out-of-bounds bugs.
> 
> KASAN uses compile-time instrumentation for checking every memory access,
> therefore fresh GCC >= v5.0.0 required.
> 
> This patch only adds infrastructure for kernel address sanitizer. It's not
> available for use yet. The idea and some code was borrowed from [1].
> 
> Basic idea:
> The main idea of KASAN is to use shadow memory to record whether each byte of memory
> is safe to access or not, and use compiler's instrumentation to check the shadow memory
> on each memory access.
> 
> Address sanitizer uses 1/8 of the memory addressable in kernel for shadow memory
> and uses direct mapping with a scale and offset to translate a memory
> address to its corresponding shadow address.
> 
> Here is function to translate address to corresponding shadow address:
> 
>      unsigned long kasan_mem_to_shadow(unsigned long addr)
>      {
>                 return ((addr - KASAN_SHADOW_START) >> KASAN_SHADOW_SCALE_SHIFT)
>                              + KASAN_SHADOW_START;
>      }
> where KASAN_SHADOW_SCALE_SHIFT = 3.
> 
> So for every 8 bytes there is one corresponding byte of shadow memory.
> The following encoding used for each shadow byte: 0 means that all 8 bytes of the
> corresponding memory region are valid for access; k (1 <= k <= 7) means that
> the first k bytes are valid for access, and other (8 - k) bytes are not;
> Any negative value indicates that the entire 8-bytes are unaccessible.

                                                           inaccessible.

> Different negative values used to distinguish between different kinds of
> unaccessible memory (redzones, freed memory) (see mm/kasan/kasan.h).

  inaccessible

> 
> To be able to detect accesses to bad memory we need a special compiler.
> Such compiler inserts a specific function calls (__asan_load*(addr), __asan_store*(addr))
> before each memory access of size 1, 2, 4, 8 or 16.
> 
> These functions check whether memory region is valid to access or not by checking
> corresponding shadow memory. If access is not valid an error printed.
> 
> [1] https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerForKernel
> 
> Based on work by Andrey Konovalov <adech.fo@gmail.com>
> 
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> ---
>  Documentation/kasan.txt | 180 ++++++++++++++++++++++++++++++++++++++++++++++
>  Makefile                |  10 ++-
>  include/linux/kasan.h   |  42 +++++++++++
>  include/linux/sched.h   |   3 +
>  lib/Kconfig.debug       |   2 +
>  lib/Kconfig.kasan       |  16 +++++
>  mm/Makefile             |   1 +
>  mm/kasan/Makefile       |   3 +
>  mm/kasan/kasan.c        | 188 ++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/kasan/kasan.h        |  32 +++++++++
>  mm/kasan/report.c       | 183 ++++++++++++++++++++++++++++++++++++++++++++++
>  scripts/Makefile.lib    |  10 +++
>  12 files changed, 669 insertions(+), 1 deletion(-)
>  create mode 100644 Documentation/kasan.txt
>  create mode 100644 include/linux/kasan.h
>  create mode 100644 lib/Kconfig.kasan
>  create mode 100644 mm/kasan/Makefile
>  create mode 100644 mm/kasan/kasan.c
>  create mode 100644 mm/kasan/kasan.h
>  create mode 100644 mm/kasan/report.c
> 
> diff --git a/Documentation/kasan.txt b/Documentation/kasan.txt
> new file mode 100644
> index 0000000..5a9d903
> --- /dev/null
> +++ b/Documentation/kasan.txt
> @@ -0,0 +1,180 @@
> +Kernel address sanitizer
> +================
> +
> +0. Overview
> +===========
> +
> +Kernel Address sanitizer (KASan) is a dynamic memory error detector. It provides
> +fast and comprehensive solution for finding use-after-free and out-of-bounds bugs.

   a fast and ...

> +
> +KASAN uses compile-time instrumentation for checking every memory access, therefore you
> +will need a special compiler: GCC >= 5.0.0.
> +
> +Currently KASAN supported only for x86_64 architecture and requires kernel

                   is supported

> +to be build with SLUB allocator.

         built

> +
> +1. Usage
> +=========
> +
> +KASAN requires the kernel to be built with a special compiler (GCC >= 5.0.0).
> +
> +To enable KASAN configure kernel with:
> +
> +	  CONFIG_KASAN = y
> +
> +Currently KASAN works only with SLUB.

                              with the SLUB memory allocator.

> +For better bug detection and nicer report enable CONFIG_STACKTRACE, CONFIG_SLUB_DEBUG

                                      report,

> +and put 'slub_debug=FU' to boot cmdline.

                           in the boot cmdline.


Following sentence is confusing.  I'm not sure how to fix it.

> +Please don't use slab poisoning with KASan (slub_debug=P), beacuse if KASan will

                                                                         drop: will

> +detects use after free allocation and free stacktraces will be overwritten by

maybe:     use after free,

> +poison bytes, and KASan won't be able to print this backtraces.

                                                       backtrace.

> +
> +To exclude files from being instrumented by compiler, add a line
> +similar to the following to the respective kernel Makefile:
> +
> +
> +        For a single file (e.g. main.o):
> +                KASAN_SANITIZE_main.o := n
> +
> +        For all files in one directory:
> +                KASAN_SANITIZE := n
> +
> +Only files which are linked to the main kernel image or are compiled as
> +kernel modules are supported by this mechanism.
> +
> +
> +1.1 Error reports
> +==========
> +
> +A typical out of bounds access report looks like this:
> +
> +==================================================================
> +AddressSanitizer: buffer overflow in kasan_kmalloc_oob_rigth+0x6a/0x7a at addr c6006f1b

Curious:  what does "rigth" mean?

> +=============================================================================
> +BUG kmalloc-128 (Not tainted): kasan error
> +-----------------------------------------------------------------------------
> +
> +Disabling lock debugging due to kernel taint
> +INFO: Allocated in kasan_kmalloc_oob_rigth+0x2c/0x7a age=5 cpu=0 pid=1
> +	__slab_alloc.constprop.72+0x64f/0x680
> +	kmem_cache_alloc+0xa8/0xe0
> +	kasan_kmalloc_oob_rigth+0x2c/0x7a
> +	kasan_tests_init+0x8/0xc
> +	do_one_initcall+0x85/0x1a0
> +	kernel_init_freeable+0x1f1/0x279
> +	kernel_init+0x8/0xd0
> +	ret_from_kernel_thread+0x21/0x30
> +INFO: Slab 0xc7f3d0c0 objects=14 used=2 fp=0xc6006120 flags=0x5000080
> +INFO: Object 0xc6006ea0 @offset=3744 fp=0xc6006d80
> +
> +Bytes b4 c6006e90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> +Object c6006ea0: 80 6d 00 c6 00 00 00 00 00 00 00 00 00 00 00 00  .m..............
> +Object c6006eb0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> +Object c6006ec0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> +Object c6006ed0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> +Object c6006ee0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> +Object c6006ef0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> +Object c6006f00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> +Object c6006f10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> +CPU: 0 PID: 1 Comm: swapper/0 Tainted: G    B          3.16.0-rc3-next-20140704+ #216
> +Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> + 00000000 00000000 c6006ea0 c6889e30 c1c4446f c6801b40 c6889e48 c11c3f32
> + c6006000 c6801b40 c7f3d0c0 c6006ea0 c6889e68 c11c4ff5 c6801b40 c1e44906
> + c1e11352 c7f3d0c0 c6889efc c6801b40 c6889ef4 c11ccb78 c1e11352 00000286
> +Call Trace:
> + [<c1c4446f>] dump_stack+0x4b/0x75
> + [<c11c3f32>] print_trailer+0xf2/0x180
> + [<c11c4ff5>] object_err+0x25/0x30
> + [<c11ccb78>] kasan_report_error+0xf8/0x380
> + [<c1c57940>] ? need_resched+0x21/0x25
> + [<c11cb92b>] ? poison_shadow+0x2b/0x30
> + [<c11cb92b>] ? poison_shadow+0x2b/0x30
> + [<c11cb92b>] ? poison_shadow+0x2b/0x30
> + [<c1f82763>] ? kasan_kmalloc_oob_rigth+0x7a/0x7a
> + [<c11cbacc>] __asan_store1+0x9c/0xa0
> + [<c1f82753>] ? kasan_kmalloc_oob_rigth+0x6a/0x7a
> + [<c1f82753>] kasan_kmalloc_oob_rigth+0x6a/0x7a
> + [<c1f8276b>] kasan_tests_init+0x8/0xc
> + [<c1000435>] do_one_initcall+0x85/0x1a0
> + [<c1f6f508>] ? repair_env_string+0x23/0x66
> + [<c1f6f4e5>] ? initcall_blacklist+0x85/0x85
> + [<c10c9883>] ? parse_args+0x33/0x450
> + [<c1f6fdb7>] kernel_init_freeable+0x1f1/0x279
> + [<c1000558>] kernel_init+0x8/0xd0
> + [<c1c578c1>] ret_from_kernel_thread+0x21/0x30
> + [<c1000550>] ? do_one_initcall+0x1a0/0x1a0
> +Write of size 1 by thread T1:
> +Memory state around the buggy address:
> + c6006c80: fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd
> + c6006d00: fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd
> + c6006d80: fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd
> + c6006e00: fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd
> + c6006e80: fd fd fd fd 00 00 00 00 00 00 00 00 00 00 00 00
> +>c6006f00: 00 00 00 03 fc fc fc fc fc fc fc fc fc fc fc fc
> +                    ^
> + c6006f80: fc fc fc fc fc fc fc fc fd fd fd fd fd fd fd fd
> + c6007000: 00 00 00 00 00 00 00 00 00 fc fc fc fc fc fc fc
> + c6007080: fc fc fc fc fc fc fc fc fc fc fc fc fc 00 00 00
> + c6007100: 00 00 00 00 00 00 fc fc fc fc fc fc fc fc fc fc
> + c6007180: fc fc fc fc fc fc fc fc fc fc 00 00 00 00 00 00
> +==================================================================
> +
> +In the last section the report shows memory state around the accessed address.
> +Reading this part requires some more undestanding of how KASAN works.

                                        understanding

> +
> +Each KASAN_SHADOW_SCALE_SIZE bytes of memory can be marked as addressable,
> +partially addressable, freed or they can be part of a redzone.
> +If bytes are marked as addressable that means that they belong to some
> +allocated memory block and it is possible to read or modify any of these
> +bytes. Addressable KASAN_SHADOW_SCALE_SIZE bytes are marked by 0 in the report.
> +When only the first N bytes of KASAN_SHADOW_SCALE_SIZE belong to an allocated
> +memory block, this bytes are partially addressable and marked by 'N'.
> +
> +Markers of unaccessible bytes could be found in mm/kasan/kasan.h header:

              inaccessible

> +
> +#define KASAN_FREE_PAGE         0xFF  /* page was freed */
> +#define KASAN_PAGE_REDZONE      0xFE  /* redzone for kmalloc_large allocations */
> +#define KASAN_SLAB_PADDING      0xFD  /* Slab page redzone, does not belong to any slub object */
> +#define KASAN_KMALLOC_REDZONE   0xFC  /* redzone inside slub object */
> +#define KASAN_KMALLOC_FREE      0xFB  /* object was freed (kmem_cache_free/kfree) */
> +#define KASAN_SLAB_FREE         0xFA  /* free slab page */
> +#define KASAN_SHADOW_GAP        0xF9  /* address belongs to shadow memory */
> +
> +In the report above the arrows point to the shadow byte 03, which means that the
> +accessed address is partially addressable.
> +
> +
> +2. Implementation details
> +========================
> +
> +From a high level, our approach to memory error detection is similar to that
> +of kmemcheck: use shadow memory to record whether each byte of memory is safe
> +to access, and use compile-time instrumentation to check shadow on each memory
> +access.
> +
> +AddressSanitizer dedicates 1/8 of the addressable in kernel memory to its shadow

                                                     in-kernel or just kernel memory

> +memory (e.g. 16TB to cover 128TB on x86_64) and uses direct mapping with a
> +scale and offset to translate a memory address to its corresponding shadow address.
> +
> +Here is function witch translate address to corresponding shadow address:

   Here is the function which translates an address to its corresponding shadow address:

> +
> +unsigned long kasan_mem_to_shadow(unsigned long addr)
> +{
> +	return ((addr - KASAN_SHADOW_START) >> KASAN_SHADOW_SCALE_SHIFT)
> +		+ KASAN_SHADOW_START;
> +}
> +
> +where KASAN_SHADOW_SCALE_SHIFT = 3.
> +
> +Each shadow byte corresponds to 8 bytes of the main memory. We use the
> +following encoding for each shadow byte: 0 means that all 8 bytes of the
> +corresponding memory region are addressable; k (1 <= k <= 7) means that
> +the first k bytes are addressable, and other (8 - k) bytes are not;
> +any negative value indicates that the entire 8-byte word is unaddressable.
> +We use different negative values to distinguish between different kinds of
> +unaddressable memory (redzones, freed memory) (see mm/kasan/kasan.h).
> +

Is there any need for something similar to k (1 <= k <= 7) but meaning that the
*last* k bytes are addressable instead of the first k bytes?

> +Poisoning or unpoisoning a byte in the main memory means writing some special
> +value into the corresponding shadow memory. This value indicates whether the
> +byte is addressable or not.
> +


> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> new file mode 100644
> index 0000000..65f8145
> --- /dev/null
> +++ b/mm/kasan/kasan.c
> @@ -0,0 +1,188 @@
> +
> +/* to shut up compiler complains */

                          complaints

> +void __asan_init_v3(void) {}
> +EXPORT_SYMBOL(__asan_init_v3);
> +void __asan_handle_no_return(void) {}
> +EXPORT_SYMBOL(__asan_handle_no_return);


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
