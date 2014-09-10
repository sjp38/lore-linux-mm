Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C61756B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 11:50:35 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id fa1so7243191pad.16
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 08:50:35 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id k2si24684522pde.98.2014.09.10.08.50.34
        for <linux-mm@kvack.org>;
        Wed, 10 Sep 2014 08:50:34 -0700 (PDT)
Message-ID: <5410724B.8000803@intel.com>
Date: Wed, 10 Sep 2014 08:46:19 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH v2 02/10] x86_64: add KASan support
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com> <1410359487-31938-3-git-send-email-a.ryabinin@samsung.com>
In-Reply-To: <1410359487-31938-3-git-send-email-a.ryabinin@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

Overall, the approach here looks pretty sane.  As you noted, it would be
nice to keep PAGE_OFFSET in one place, but it's not a deal breaker for
me.  The use of the vmemmap code looks to be a nice fit.

Few nits below.

On 09/10/2014 07:31 AM, Andrey Ryabinin wrote:
> 16TB of virtual addressed used for shadow memory.
> It's located in range [0xffff800000000000 - 0xffff900000000000]
> Therefore PAGE_OFFSET has to be changed from 0xffff880000000000
> to 0xffff900000000000.
...
> It would be nice to not have different PAGE_OFFSET with and without CONFIG_KASAN.
> We have big enough hole between vmemmap and esp fixup stacks.
> So how about moving all direct mapping, vmalloc and vmemmap 8TB up without
> hiding it under CONFIG_KASAN?

Is there a reason this has to be _below_ the linear map?  Couldn't we
just carve some space out of the vmalloc() area for the kasan area?


>  arch/x86/Kconfig                     |  1 +
>  arch/x86/boot/Makefile               |  2 ++
>  arch/x86/boot/compressed/Makefile    |  2 ++
>  arch/x86/include/asm/kasan.h         | 20 ++++++++++++
>  arch/x86/include/asm/page_64_types.h |  4 +++
>  arch/x86/include/asm/pgtable.h       |  7 ++++-
>  arch/x86/kernel/Makefile             |  2 ++
>  arch/x86/kernel/dumpstack.c          |  5 ++-
>  arch/x86/kernel/head64.c             |  6 ++++
>  arch/x86/kernel/head_64.S            | 16 ++++++++++
>  arch/x86/mm/Makefile                 |  3 ++
>  arch/x86/mm/init.c                   |  3 ++
>  arch/x86/mm/kasan_init_64.c          | 59 ++++++++++++++++++++++++++++++++++++
>  arch/x86/realmode/Makefile           |  2 +-
>  arch/x86/realmode/rm/Makefile        |  1 +
>  arch/x86/vdso/Makefile               |  1 +
>  include/linux/kasan.h                |  3 ++
>  lib/Kconfig.kasan                    |  1 +
>  18 files changed, 135 insertions(+), 3 deletions(-)
>  create mode 100644 arch/x86/include/asm/kasan.h
>  create mode 100644 arch/x86/mm/kasan_init_64.c

This probably deserves an update of Documentation/x86/x86_64/mm.txt, too.

> +void __init kasan_map_shadow(void)
> +{
> +	int i;
> +
> +	memcpy(early_level4_pgt, init_level4_pgt, 4096);
> +	load_cr3(early_level4_pgt);
> +
> +	clear_zero_shadow_mapping(kasan_mem_to_shadow(PAGE_OFFSET),
> +				kasan_mem_to_shadow(0xffffc80000000000UL));

This 0xffffc80000000000UL could be PAGE_OFFSET+MAXMEM.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
