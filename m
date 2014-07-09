Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id DBA7B6B0035
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 15:30:20 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y13so9406880pdi.41
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 12:30:20 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id sg10si46685870pbb.249.2014.07.09.12.30.18
        for <linux-mm@kvack.org>;
        Wed, 09 Jul 2014 12:30:19 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC/PATCH RESEND -next 01/21] Add kernel address sanitizer infrastructure.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1404905415-9046-2-git-send-email-a.ryabinin@samsung.com>
Date: Wed, 09 Jul 2014 12:29:26 -0700
In-Reply-To: <1404905415-9046-2-git-send-email-a.ryabinin@samsung.com> (Andrey
	Ryabinin's message of "Wed, 09 Jul 2014 15:29:55 +0400")
Message-ID: <87pphenxex.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

Andrey Ryabinin <a.ryabinin@samsung.com> writes:

Seems like a useful facility. Thanks for working on it. Overall the code
looks fairly good. Some comments below.


> +
> +Address sanitizer for kernel (KASAN) is a dynamic memory error detector. It provides
> +fast and comprehensive solution for finding use-after-free and out-of-bounds bugs.
> +
> +KASAN is better than all of CONFIG_DEBUG_PAGEALLOC, because it:
> + - is based on compiler instrumentation (fast),
> + - detects OOB for both writes and reads,
> + - provides UAF detection,

Please expand the acronym.

> +
> +|--------|        |--------|
> +| Memory |----    | Memory |
> +|--------|    \   |--------|
> +| Shadow |--   -->| Shadow |
> +|--------|  \     |--------|
> +|   Bad  |   ---->|  Bad   |
> +|--------|  /     |--------|
> +| Shadow |--   -->| Shadow |
> +|--------|    /   |--------|
> +| Memory |----    | Memory |
> +|--------|        |--------|

I guess this implies it's incompatible with memory hotplug, as the 
shadow couldn't be extended?

That's fine, but you should exclude that in Kconfig.

There are likely more exclude dependencies for Kconfig too.
Neds dependencies on the right sparse mem options?
Does it work with kmemcheck? If not exclude.

Perhaps try to boot it with all other debug options and see which ones break.

> diff --git a/Makefile b/Makefile
> index 64ab7b3..08a07f2 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -384,6 +384,12 @@ LDFLAGS_MODULE  =
>  CFLAGS_KERNEL	=
>  AFLAGS_KERNEL	=
>  CFLAGS_GCOV	= -fprofile-arcs -ftest-coverage
> +CFLAGS_KASAN	= -fsanitize=address --param asan-stack=0 \
> +			--param asan-use-after-return=0 \
> +			--param asan-globals=0 \
> +			--param asan-memintrin=0 \
> +			--param asan-instrumentation-with-call-threshold=0 \

Hardcoding --param is not very nice. They can change from compiler
to compiler version. Need some version checking?

Also you should probably have some check that the compiler supports it
(and print some warning if not)
Otherwise randconfig builds will be broken if the compiler doesn't.

Also does the kernel really build/work without the other patches?
If not please move this patchkit to the end of the series, to keep
the patchkit bisectable (this may need moving parts of the includes
into a separate patch)

> diff --git a/commit b/commit
> new file mode 100644
> index 0000000..134f4dd
> --- /dev/null
> +++ b/commit
> @@ -0,0 +1,3 @@
> +
> +I'm working on address sanitizer for kernel.
> +fuck this bloody.
> \ No newline at end of file

Heh. Please remove.

> diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> new file mode 100644
> index 0000000..2bfff78
> --- /dev/null
> +++ b/lib/Kconfig.kasan
> @@ -0,0 +1,20 @@
> +config HAVE_ARCH_KASAN
> +	bool
> +
> +if HAVE_ARCH_KASAN
> +
> +config KASAN
> +	bool "AddressSanitizer: dynamic memory error detector"
> +	default n
> +	help
> +	  Enables AddressSanitizer - dynamic memory error detector,
> +	  that finds out-of-bounds and use-after-free bugs.

Needs much more description.

> +
> +config KASAN_SANITIZE_ALL
> +	bool "Instrument entire kernel"
> +	depends on KASAN
> +	default y
> +	help
> +	  This enables compiler intrumentation for entire kernel
> +

Same.


> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> new file mode 100644
> index 0000000..e2cd345
> --- /dev/null
> +++ b/mm/kasan/kasan.c
> @@ -0,0 +1,292 @@
> +/*
> + *

Add one line here what the file does. Same for other files.

> + * Copyright (c) 2014 Samsung Electronics Co., Ltd.
> + * Author: Andrey Ryabinin <a.ryabinin@samsung.com>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> +#include "kasan.h"
> +#include "../slab.h"

That's ugly, but ok.

> +
> +static bool __read_mostly kasan_initialized;

It would be better to use a static_key, but I guess your initialization
is too early?

Of course the proposal to move it into start_kernel and get rid of the
flag would be best.

> +
> +unsigned long kasan_shadow_start;
> +unsigned long kasan_shadow_end;
> +
> +/* equals to (kasan_shadow_start - PAGE_OFFSET/KASAN_SHADOW_SCALE_SIZE) */
> +unsigned long __read_mostly kasan_shadow_offset; /* it's not a very good name for this variable */

Do these all need to be global?

> +
> +
> +static inline bool addr_is_in_mem(unsigned long addr)
> +{
> +	return likely(addr >= PAGE_OFFSET && addr < (unsigned long)high_memory);
> +}

Of course there are lots of cases where this doesn't work (like large
holes), but I assume this has been checked elsewhere?


> +
> +void kasan_enable_local(void)
> +{
> +	if (likely(kasan_initialized))
> +		current->kasan_depth--;
> +}
> +
> +void kasan_disable_local(void)
> +{
> +	if (likely(kasan_initialized))
> +		current->kasan_depth++;
> +}

Couldn't this be done without checking the flag?


> +		return;
> +
> +	if (unlikely(addr < TASK_SIZE)) {
> +		info.access_addr = addr;
> +		info.access_size = size;
> +		info.is_write = write;
> +		info.ip = _RET_IP_;
> +		kasan_report_user_access(&info);
> +		return;
> +	}

How about vsyscall pages here?

> +
> +	if (!addr_is_in_mem(addr))
> +		return;
> +
> +	access_addr = memory_is_poisoned(addr, size);
> +	if (likely(access_addr == 0))
> +		return;
> +
> +	info.access_addr = access_addr;
> +	info.access_size = size;
> +	info.is_write = write;
> +	info.ip = _RET_IP_;
> +	kasan_report_error(&info);
> +}
> +
> +void __init kasan_alloc_shadow(void)
> +{
> +	unsigned long lowmem_size = (unsigned long)high_memory - PAGE_OFFSET;
> +	unsigned long shadow_size;
> +	phys_addr_t shadow_phys_start;
> +
> +	shadow_size = lowmem_size >> KASAN_SHADOW_SCALE_SHIFT;
> +
> +	shadow_phys_start = memblock_alloc(shadow_size, PAGE_SIZE);
> +	if (!shadow_phys_start) {
> +		pr_err("Unable to reserve shadow memory\n");
> +		return;

Wouldn't this crash&burn later? panic?

> +void *kasan_memcpy(void *dst, const void *src, size_t len)
> +{
> +	if (unlikely(len == 0))
> +		return dst;
> +
> +	check_memory_region((unsigned long)src, len, false);
> +	check_memory_region((unsigned long)dst, len, true);

I assume this handles negative len?
Also check for overlaps?

> +
> +static inline void *virt_to_obj(struct kmem_cache *s, void *slab_start, void *x)
> +{
> +	return x - ((x - slab_start) % s->size);
> +}

This should be in the respective slab headers, not hard coded.

> +void kasan_report_error(struct access_info *info)
> +{
> +	kasan_disable_local();
> +	pr_err("================================="
> +		"=================================\n");
> +	print_error_description(info);
> +	print_address_description(info);
> +	print_shadow_for_address(info->access_addr);
> +	pr_err("================================="
> +		"=================================\n");
> +	kasan_enable_local();
> +}
> +
> +void kasan_report_user_access(struct access_info *info)
> +{
> +	kasan_disable_local();

Should print the same prefix oopses use, a lot of log grep tools
look for that. 

Also you may want some lock to prevent multiple
reports mixing. 

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
