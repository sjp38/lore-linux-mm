Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 364D96B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 06:21:26 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id y16so58475583wmd.6
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 03:21:26 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id u189si9849899wmg.133.2016.11.07.03.21.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 03:21:25 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id p190so15913381wmp.1
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 03:21:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161027170948.8279-1-dsafonov@virtuozzo.com>
References: <20161027170948.8279-1-dsafonov@virtuozzo.com>
From: Dmitry Safonov <0x7f454c46@gmail.com>
Date: Mon, 7 Nov 2016 14:21:04 +0300
Message-ID: <CAJwJo6b16mt0N_xJeeQ0EikyPhoo-UvAx-FaXO9hGzwW=o+s5Q@mail.gmail.com>
Subject: Re: [PATCHv3 0/8] powerpc/mm: refactor vDSO mapping code
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, open list <linux-kernel@vger.kernel.org>

2016-10-27 20:09 GMT+03:00 Dmitry Safonov <dsafonov@virtuozzo.com>:
> Changes since v1, v2:
> - use vdso64_pages only under CONFIG_PPC64 (32-bit build fix)
> - remove arch_vma_name helper as not needed anymore,
>   simplify vdso_base pointer initializing in map_vdso()
>
> Cleanup patches for vDSO on powerpc.
> Originally, I wanted to add vDSO remapping on arm/aarch64 and
> I decided to cleanup that part on powerpc.
> I've add a hook for vm_ops for vDSO just like I did for x86,
> which makes cross-arch arch_mremap hook no more needed.
> Other changes - reduce exhaustive code duplication by
> separating the common vdso code.
>
> No visible to userspace changes expected.
> Tested on qemu with buildroot rootfs.
>
> Dmitry Safonov (8):
>   powerpc/vdso: unify return paths in setup_additional_pages
>   powerpc/vdso: remove unused params in vdso_do_func_patch{32,64}
>   powerpc/vdso: separate common code in vdso_common
>   powerpc/vdso: introduce init_vdso{32,64}_pagelist
>   powerpc/vdso: split map_vdso from arch_setup_additional_pages
>   powerpc/vdso: switch from legacy_special_mapping_vmops
>   mm: kill arch_mremap
>   powerpc/vdso: remove arch_vma_name
>
>  arch/alpha/include/asm/Kbuild            |   1 -
>  arch/arc/include/asm/Kbuild              |   1 -
>  arch/arm/include/asm/Kbuild              |   1 -
>  arch/arm64/include/asm/Kbuild            |   1 -
>  arch/avr32/include/asm/Kbuild            |   1 -
>  arch/blackfin/include/asm/Kbuild         |   1 -
>  arch/c6x/include/asm/Kbuild              |   1 -
>  arch/cris/include/asm/Kbuild             |   1 -
>  arch/frv/include/asm/Kbuild              |   1 -
>  arch/h8300/include/asm/Kbuild            |   1 -
>  arch/hexagon/include/asm/Kbuild          |   1 -
>  arch/ia64/include/asm/Kbuild             |   1 -
>  arch/m32r/include/asm/Kbuild             |   1 -
>  arch/m68k/include/asm/Kbuild             |   1 -
>  arch/metag/include/asm/Kbuild            |   1 -
>  arch/microblaze/include/asm/Kbuild       |   1 -
>  arch/mips/include/asm/Kbuild             |   1 -
>  arch/mn10300/include/asm/Kbuild          |   1 -
>  arch/nios2/include/asm/Kbuild            |   1 -
>  arch/openrisc/include/asm/Kbuild         |   1 -
>  arch/parisc/include/asm/Kbuild           |   1 -
>  arch/powerpc/include/asm/mm-arch-hooks.h |  28 --
>  arch/powerpc/kernel/vdso.c               | 502 +++++--------------------------
>  arch/powerpc/kernel/vdso_common.c        | 248 +++++++++++++++
>  arch/s390/include/asm/Kbuild             |   1 -
>  arch/score/include/asm/Kbuild            |   1 -
>  arch/sh/include/asm/Kbuild               |   1 -
>  arch/sparc/include/asm/Kbuild            |   1 -
>  arch/tile/include/asm/Kbuild             |   1 -
>  arch/um/include/asm/Kbuild               |   1 -
>  arch/unicore32/include/asm/Kbuild        |   1 -
>  arch/x86/include/asm/Kbuild              |   1 -
>  arch/xtensa/include/asm/Kbuild           |   1 -
>  include/asm-generic/mm-arch-hooks.h      |  16 -
>  include/linux/mm-arch-hooks.h            |  25 --
>  mm/mremap.c                              |   4 -
>  36 files changed, 324 insertions(+), 529 deletions(-)
>  delete mode 100644 arch/powerpc/include/asm/mm-arch-hooks.h
>  create mode 100644 arch/powerpc/kernel/vdso_common.c
>  delete mode 100644 include/asm-generic/mm-arch-hooks.h
>  delete mode 100644 include/linux/mm-arch-hooks.h

ping?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
