Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id C0B8A900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 08:24:36 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so609503pab.38
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 05:24:36 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id we1si1164323pab.167.2014.10.28.05.24.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 28 Oct 2014 05:24:34 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NE5001UAMLOFS10@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 28 Oct 2014 12:27:24 +0000 (GMT)
Message-id: <544F8AFE.4090200@samsung.com>
Date: Tue, 28 Oct 2014 15:24:30 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v5 01/12] Add kernel address sanitizer infrastructure.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1414428419-17860-1-git-send-email-a.ryabinin@samsung.com>
 <1414428419-17860-2-git-send-email-a.ryabinin@samsung.com>
 <20141027132041.68edd349@lwn.net>
In-reply-to: <20141027132041.68edd349@lwn.net>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Randy Dunlap <rdunlap@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Marek <mmarek@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On 10/27/2014 08:20 PM, Jonathan Corbet wrote:
> Just looking at kasan.txt...
> 
>> diff --git a/Documentation/kasan.txt b/Documentation/kasan.txt
>> new file mode 100644
>> index 0000000..12c50da
>> --- /dev/null
>> +++ b/Documentation/kasan.txt
>> @@ -0,0 +1,174 @@
>> +Kernel address sanitizer
>> +================
>> +
>> +0. Overview
>> +===========
>> +
>> +Kernel Address sanitizer (KASan) is a dynamic memory error detector. It provides
>> +a fast and comprehensive solution for finding use-after-free and out-of-bounds bugs.
> 
> Documentation is a good place to stick to the 80-column (or slightly less)
> limit.  There's no reason to use wide lines here.
> 

Agree. I wonder why checkpatch doesn't warns here.

>> +KASan uses compile-time instrumentation for checking every memory access, therefore you
>> +will need a special compiler: GCC >= 4.9.2
>> +
>> +Currently KASan is supported only for x86_64 architecture and requires kernel
>> +to be built with SLUB allocator.
> 
> "and requires that the kernel be built with the SLUB allocator."
> 
>> +1. Usage
>> +=========
>> +
>> +KASAN requires the kernel to be built with a special compiler (GCC >= 5.0.0).
> 
> That differs from the requirement listed just a few lines above.  Which is
> right?  I'm also not sure that a version requirement qualifies as
> "special."  
> 

4.9.2 is correct now. Yuri backported kasan patches to 4.9 branch recently.
I agree that "special" doesn't fit here. "Certain" would be better here:

KASAN requires the kernel to be built with a certain compiler version GCC >= 4.9.2

>> +To enable KASAN configure kernel with:
>> +
>> +	  CONFIG_KASAN = y
>> +
>> +Currently KASAN works only with the SLUB memory allocator.
>> +For better bug detection and nicer report, enable CONFIG_STACKTRACE and put
>> +at least 'slub_debug=U' in the boot cmdline.
>> +
>> +To disable instrumentation for specific files or directories, add a line
>> +similar to the following to the respective kernel Makefile:
>> +
>> +        For a single file (e.g. main.o):
>> +                KASAN_SANITIZE_main.o := n
>> +
>> +        For all files in one directory:
>> +                KASAN_SANITIZE := n
>> +
>> +Only files which are linked to the main kernel image or are compiled as
>> +kernel modules are supported by this mechanism.
> 
> Can you do the opposite?  Disable for all but a few files where you want to
> turn it on?  That seems more useful somehow...
> 

There was a config option KASAN_SANTIZE_ALL in v1 patch set, but I decided to remove it
because I think there is no good use case for it. Instrumentation only for few files
is not a good idea because it's quite common to pass pointer to the external function
where pointer deference actually happens.

So bug could be in the instrumented code, but it could be missed because deference happens in
some generic external function.


>> +1.1 Error reports
>> +==========
>> +
>> +A typical out of bounds access report looks like this:
>> +
>> +==================================================================
>> +BUG: AddressSanitizer: buffer overflow in kasan_kmalloc_oob_right+0x6a/0x7a at addr c6006f1b
>> +=============================================================================
>> +BUG kmalloc-128 (Not tainted): kasan error
>> +-----------------------------------------------------------------------------
>> +
>> +Disabling lock debugging due to kernel taint
>> +INFO: Allocated in kasan_kmalloc_oob_right+0x2c/0x7a age=5 cpu=0 pid=1
>> +	__slab_alloc.constprop.72+0x64f/0x680
>> +	kmem_cache_alloc+0xa8/0xe0
>> +	kasan_kmalloc_oob_rigth+0x2c/0x7a
>> +	kasan_tests_init+0x8/0xc
>> +	do_one_initcall+0x85/0x1a0
>> +	kernel_init_freeable+0x1f1/0x279
>> +	kernel_init+0x8/0xd0
>> +	ret_from_kernel_thread+0x21/0x30
>> +INFO: Slab 0xc7f3d0c0 objects=14 used=2 fp=0xc6006120 flags=0x5000080
>> +INFO: Object 0xc6006ea0 @offset=3744 fp=0xc6006d80
>> +
>> +Bytes b4 c6006e90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>> +Object c6006ea0: 80 6d 00 c6 00 00 00 00 00 00 00 00 00 00 00 00  .m..............
>> +Object c6006eb0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>> +Object c6006ec0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>> +Object c6006ed0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>> +Object c6006ee0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>> +Object c6006ef0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>> +Object c6006f00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>> +Object c6006f10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>> +CPU: 0 PID: 1 Comm: swapper/0 Tainted: G    B          3.16.0-rc3-next-20140704+ #216
>> +Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> + 00000000 00000000 c6006ea0 c6889e30 c1c4446f c6801b40 c6889e48 c11c3f32
>> + c6006000 c6801b40 c7f3d0c0 c6006ea0 c6889e68 c11c4ff5 c6801b40 c1e44906
>> + c1e11352 c7f3d0c0 c6889efc c6801b40 c6889ef4 c11ccb78 c1e11352 00000286
>> +Call Trace:
>> + [<c1c4446f>] dump_stack+0x4b/0x75
>> + [<c11c3f32>] print_trailer+0xf2/0x180
>> + [<c11c4ff5>] object_err+0x25/0x30
>> + [<c11ccb78>] kasan_report_error+0xf8/0x380
>> + [<c1c57940>] ? need_resched+0x21/0x25
>> + [<c11cb92b>] ? poison_shadow+0x2b/0x30
>> + [<c11cb92b>] ? poison_shadow+0x2b/0x30
>> + [<c11cb92b>] ? poison_shadow+0x2b/0x30
>> + [<c1f82763>] ? kasan_kmalloc_oob_right+0x7a/0x7a
>> + [<c11cbacc>] __asan_store1+0x9c/0xa0
>> + [<c1f82753>] ? kasan_kmalloc_oob_rigth+0x6a/0x7a
>> + [<c1f82753>] kasan_kmalloc_oob_rigth+0x6a/0x7a
>> + [<c1f8276b>] kasan_tests_init+0x8/0xc
>> + [<c1000435>] do_one_initcall+0x85/0x1a0
>> + [<c1f6f508>] ? repair_env_string+0x23/0x66
>> + [<c1f6f4e5>] ? initcall_blacklist+0x85/0x85
>> + [<c10c9883>] ? parse_args+0x33/0x450
>> + [<c1f6fdb7>] kernel_init_freeable+0x1f1/0x279
>> + [<c1000558>] kernel_init+0x8/0xd0
>> + [<c1c578c1>] ret_from_kernel_thread+0x21/0x30
>> + [<c1000550>] ? do_one_initcall+0x1a0/0x1a0
>> +Write of size 1 by thread T1:
>> +Memory state around the buggy address:
>> + c6006c80: fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd
>> + c6006d00: fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd
>> + c6006d80: fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd
>> + c6006e00: fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd
>> + c6006e80: fd fd fd fd 00 00 00 00 00 00 00 00 00 00 00 00
>> +>c6006f00: 00 00 00 03 fc fc fc fc fc fc fc fc fc fc fc fc
>> +                    ^
>> + c6006f80: fc fc fc fc fc fc fc fc fd fd fd fd fd fd fd fd
>> + c6007000: 00 00 00 00 00 00 00 00 00 fc fc fc fc fc fc fc
>> + c6007080: fc fc fc fc fc fc fc fc fc fc fc fc fc 00 00 00
>> + c6007100: 00 00 00 00 00 00 fc fc fc fc fc fc fc fc fc fc
>> + c6007180: fc fc fc fc fc fc fc fc fc fc 00 00 00 00 00 00
>> +==================================================================
>> +
>> +In the last section the report shows memory state around the accessed address.
>> +Reading this part requires some more understanding of how KASAN works.
> 
> Which is all great, but it might be nice to say briefly what the other
> sections are telling us?
> 

Other sections are from slub debug output. They are described in Documentation/vm/slub.txt.
To clear this out I will add here following:

First sections describe slub object where bad access happened. See 'SLUB Debug output' section in
Documentation/vm/slub.txt for details.

>> +Each KASAN_SHADOW_SCALE_SIZE bytes of memory can be marked as addressable,
> 
> What's KASAN_SHADOW_SCALE_SIZE and why is it something we should care
> about?  Is it a parameter people can set?
> 

It's constant equals to 8. It implies how many bytes of memory mapped to one shadow byte.
Just changing this value won't work, so I'll replace it with 8.

>> +partially addressable, freed or they can be part of a redzone.
>> +If bytes are marked as addressable that means that they belong to some
>> +allocated memory block and it is possible to read or modify any of these
>> +bytes. Addressable KASAN_SHADOW_SCALE_SIZE bytes are marked by 0 in the report.
>> +When only the first N bytes of KASAN_SHADOW_SCALE_SIZE belong to an allocated
>> +memory block, this bytes are partially addressable and marked by 'N'.
> 
> Is that a literal "N" or some number indicating which bytes are accessible?
> From what's below, I'm guessing the latter.  It would be far better to be
> clear on that.
> 

Will do.

>> +Markers of inaccessible bytes could be found in mm/kasan/kasan.h header:
>> +
>> +#define KASAN_FREE_PAGE         0xFF  /* page was freed */
>> +#define KASAN_PAGE_REDZONE      0xFE  /* redzone for kmalloc_large allocations */
>> +#define KASAN_SLAB_PADDING      0xFD  /* Slab page redzone, does not belong to any slub object */
>> +#define KASAN_KMALLOC_REDZONE   0xFC  /* redzone inside slub object */
>> +#define KASAN_KMALLOC_FREE      0xFB  /* object was freed (kmem_cache_free/kfree) */
>> +#define KASAN_SLAB_FREE         0xFA  /* free slab page */
>> +#define KASAN_SHADOW_GAP        0xF9  /* address belongs to shadow memory */
>> +
>> +In the report above the arrows point to the shadow byte 03, which means that the
>> +accessed address is partially addressable.
> 
> So N = 03 here?
> 

Right.

>> +2. Implementation details
>> +========================
>> +
>> +From a high level, our approach to memory error detection is similar to that
>> +of kmemcheck: use shadow memory to record whether each byte of memory is safe
>> +to access, and use compile-time instrumentation to check shadow on each memory
>> +access.
> 
> "to check the shadow memory on each..."
> 
>> +AddressSanitizer dedicates 1/8 of kernel memory to its shadow
>> +memory (e.g. 16TB to cover 128TB on x86_64) and uses direct mapping with a
>> +scale and offset to translate a memory address to its corresponding shadow address.
>> +
>> +Here is the function witch translate an address to its corresponding shadow address:
>> +
>> +unsigned long kasan_mem_to_shadow(unsigned long addr)
>> +{
>> +	return (addr >> KASAN_SHADOW_SCALE_SHIFT) + KASAN_SHADOW_OFFSET;
>> +}
>> +
>> +where KASAN_SHADOW_SCALE_SHIFT = 3.
>> +
>> +Each shadow byte corresponds to 8 bytes of the main memory. We use the
>> +following encoding for each shadow byte: 0 means that all 8 bytes of the
>> +corresponding memory region are addressable; k (1 <= k <= 7) means that
>> +the first k bytes are addressable, and other (8 - k) bytes are not;
>> +any negative value indicates that the entire 8-byte word is inaccessible.
>> +We use different negative values to distinguish between different kinds of
>> +inaccessible memory (redzones, freed memory) (see mm/kasan/kasan.h).
> 
> This discussion belongs in the section above where you're talking about
> interpreting the markings.
> 
Right, I'll move it in a proper place

>> +Poisoning or unpoisoning a byte in the main memory means writing some special
>> +value into the corresponding shadow memory. This value indicates whether the
>> +byte is addressable or not.
> 
> Is this something developers would do?  Are there helper functions to do
> it?  I'd say either fill that in or leave this last bit out.
> 

Currently it almost internal thing with the only exceptional case.
Details in patch 10/12 "fs: dcache: manually unpoison dname after allocation to shut up kasan's reports".
I'll remove this paragraph then.

FYI at some future point poisoning magic fields in structs could be used to catch memory corruptions inside structures.


> Interesting work!
> 
> jon
> 


Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
