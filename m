Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id 18F68900021
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 13:20:47 -0400 (EDT)
Received: by mail-oi0-f53.google.com with SMTP id v63so3687788oia.40
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 10:20:46 -0700 (PDT)
Received: from vena.lwn.net (tex.lwn.net. [70.33.254.29])
        by mx.google.com with ESMTPS id r187si13220963oib.102.2014.10.27.10.20.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Oct 2014 10:20:46 -0700 (PDT)
Date: Mon, 27 Oct 2014 13:20:41 -0400
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v5 01/12] Add kernel address sanitizer infrastructure.
Message-ID: <20141027132041.68edd349@lwn.net>
In-Reply-To: <1414428419-17860-2-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1414428419-17860-1-git-send-email-a.ryabinin@samsung.com>
	<1414428419-17860-2-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Randy Dunlap <rdunlap@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Marek <mmarek@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>

Just looking at kasan.txt...

> diff --git a/Documentation/kasan.txt b/Documentation/kasan.txt
> new file mode 100644
> index 0000000..12c50da
> --- /dev/null
> +++ b/Documentation/kasan.txt
> @@ -0,0 +1,174 @@
> +Kernel address sanitizer
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +0. Overview
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +Kernel Address sanitizer (KASan) is a dynamic memory error detector. It =
provides
> +a fast and comprehensive solution for finding use-after-free and out-of-=
bounds bugs.

Documentation is a good place to stick to the 80-column (or slightly less)
limit.  There's no reason to use wide lines here.

> +KASan uses compile-time instrumentation for checking every memory access=
, therefore you
> +will need a special compiler: GCC >=3D 4.9.2
> +
> +Currently KASan is supported only for x86_64 architecture and requires k=
ernel
> +to be built with SLUB allocator.

"and requires that the kernel be built with the SLUB allocator."

> +1. Usage
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +KASAN requires the kernel to be built with a special compiler (GCC >=3D =
5.0.0).

That differs from the requirement listed just a few lines above.  Which is
right?  I'm also not sure that a version requirement qualifies as
"special." =20

> +To enable KASAN configure kernel with:
> +
> +	  CONFIG_KASAN =3D y
> +
> +Currently KASAN works only with the SLUB memory allocator.
> +For better bug detection and nicer report, enable CONFIG_STACKTRACE and =
put
> +at least 'slub_debug=3DU' in the boot cmdline.
> +
> +To disable instrumentation for specific files or directories, add a line
> +similar to the following to the respective kernel Makefile:
> +
> +        For a single file (e.g. main.o):
> +                KASAN_SANITIZE_main.o :=3D n
> +
> +        For all files in one directory:
> +                KASAN_SANITIZE :=3D n
> +
> +Only files which are linked to the main kernel image or are compiled as
> +kernel modules are supported by this mechanism.

Can you do the opposite?  Disable for all but a few files where you want to
turn it on?  That seems more useful somehow...

> +1.1 Error reports
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +A typical out of bounds access report looks like this:
> +
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +BUG: AddressSanitizer: buffer overflow in kasan_kmalloc_oob_right+0x6a/0=
x7a at addr c6006f1b
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
> +BUG kmalloc-128 (Not tainted): kasan error
> +------------------------------------------------------------------------=
-----
> +
> +Disabling lock debugging due to kernel taint
> +INFO: Allocated in kasan_kmalloc_oob_right+0x2c/0x7a age=3D5 cpu=3D0 pid=
=3D1
> +	__slab_alloc.constprop.72+0x64f/0x680
> +	kmem_cache_alloc+0xa8/0xe0
> +	kasan_kmalloc_oob_rigth+0x2c/0x7a
> +	kasan_tests_init+0x8/0xc
> +	do_one_initcall+0x85/0x1a0
> +	kernel_init_freeable+0x1f1/0x279
> +	kernel_init+0x8/0xd0
> +	ret_from_kernel_thread+0x21/0x30
> +INFO: Slab 0xc7f3d0c0 objects=3D14 used=3D2 fp=3D0xc6006120 flags=3D0x50=
00080
> +INFO: Object 0xc6006ea0 @offset=3D3744 fp=3D0xc6006d80
> +
> +Bytes b4 c6006e90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ....=
............
> +Object c6006ea0: 80 6d 00 c6 00 00 00 00 00 00 00 00 00 00 00 00  .m....=
..........
> +Object c6006eb0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ......=
..........
> +Object c6006ec0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ......=
..........
> +Object c6006ed0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ......=
..........
> +Object c6006ee0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ......=
..........
> +Object c6006ef0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ......=
..........
> +Object c6006f00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ......=
..........
> +Object c6006f10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ......=
..........
> +CPU: 0 PID: 1 Comm: swapper/0 Tainted: G    B          3.16.0-rc3-next-2=
0140704+ #216
> +Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/=
2011
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
> + [<c1f82763>] ? kasan_kmalloc_oob_right+0x7a/0x7a
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
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +In the last section the report shows memory state around the accessed ad=
dress.
> +Reading this part requires some more understanding of how KASAN works.

Which is all great, but it might be nice to say briefly what the other
sections are telling us?

> +Each KASAN_SHADOW_SCALE_SIZE bytes of memory can be marked as addressabl=
e,

What's KASAN_SHADOW_SCALE_SIZE and why is it something we should care
about?  Is it a parameter people can set?

> +partially addressable, freed or they can be part of a redzone.
> +If bytes are marked as addressable that means that they belong to some
> +allocated memory block and it is possible to read or modify any of these
> +bytes. Addressable KASAN_SHADOW_SCALE_SIZE bytes are marked by 0 in the =
report.
> +When only the first N bytes of KASAN_SHADOW_SCALE_SIZE belong to an allo=
cated
> +memory block, this bytes are partially addressable and marked by 'N'.

Is that a literal "N" or some number indicating which bytes are accessible?
=46rom what's below, I'm guessing the latter.  It would be far better to be
clear on that.

> +Markers of inaccessible bytes could be found in mm/kasan/kasan.h header:
> +
> +#define KASAN_FREE_PAGE         0xFF  /* page was freed */
> +#define KASAN_PAGE_REDZONE      0xFE  /* redzone for kmalloc_large alloc=
ations */
> +#define KASAN_SLAB_PADDING      0xFD  /* Slab page redzone, does not bel=
ong to any slub object */
> +#define KASAN_KMALLOC_REDZONE   0xFC  /* redzone inside slub object */
> +#define KASAN_KMALLOC_FREE      0xFB  /* object was freed (kmem_cache_fr=
ee/kfree) */
> +#define KASAN_SLAB_FREE         0xFA  /* free slab page */
> +#define KASAN_SHADOW_GAP        0xF9  /* address belongs to shadow memor=
y */
> +
> +In the report above the arrows point to the shadow byte 03, which means =
that the
> +accessed address is partially addressable.

So N =3D 03 here?

> +2. Implementation details
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +From a high level, our approach to memory error detection is similar to =
that
> +of kmemcheck: use shadow memory to record whether each byte of memory is=
 safe
> +to access, and use compile-time instrumentation to check shadow on each =
memory
> +access.

"to check the shadow memory on each..."

> +AddressSanitizer dedicates 1/8 of kernel memory to its shadow
> +memory (e.g. 16TB to cover 128TB on x86_64) and uses direct mapping with=
 a
> +scale and offset to translate a memory address to its corresponding shad=
ow address.
> +
> +Here is the function witch translate an address to its corresponding sha=
dow address:
> +
> +unsigned long kasan_mem_to_shadow(unsigned long addr)
> +{
> +	return (addr >> KASAN_SHADOW_SCALE_SHIFT) + KASAN_SHADOW_OFFSET;
> +}
> +
> +where KASAN_SHADOW_SCALE_SHIFT =3D 3.
> +
> +Each shadow byte corresponds to 8 bytes of the main memory. We use the
> +following encoding for each shadow byte: 0 means that all 8 bytes of the
> +corresponding memory region are addressable; k (1 <=3D k <=3D 7) means t=
hat
> +the first k bytes are addressable, and other (8 - k) bytes are not;
> +any negative value indicates that the entire 8-byte word is inaccessible.
> +We use different negative values to distinguish between different kinds =
of
> +inaccessible memory (redzones, freed memory) (see mm/kasan/kasan.h).

This discussion belongs in the section above where you're talking about
interpreting the markings.

> +Poisoning or unpoisoning a byte in the main memory means writing some sp=
ecial
> +value into the corresponding shadow memory. This value indicates whether=
 the
> +byte is addressable or not.

Is this something developers would do?  Are there helper functions to do
it?  I'd say either fill that in or leave this last bit out.

Interesting work!

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
