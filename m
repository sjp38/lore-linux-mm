Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 565D26B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 03:12:04 -0400 (EDT)
Received: by oiax193 with SMTP id x193so46292808oia.2
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 00:12:04 -0700 (PDT)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id c3si19107533oem.52.2015.06.25.00.12.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 00:12:03 -0700 (PDT)
Received: by oiax193 with SMTP id x193so46292583oia.2
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 00:12:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150625040814.6C421660F7B@gitolite.kernel.org>
References: <20150625040814.6C421660F7B@gitolite.kernel.org>
Date: Thu, 25 Jun 2015 09:12:02 +0200
Message-ID: <CAMuHMdUG3CbPGvTuPF_JO4JL1C6aqPpLwuZjfixF1zU117Vjfw@mail.gmail.com>
Subject: Re: mm: new mm hook framework
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux-Arch <linux-arch@vger.kernel.org>

On Thu, Jun 25, 2015 at 6:08 AM, Linux Kernel Mailing List
<linux-kernel@vger.kernel.org> wrote:
> Gitweb:     http://git.kernel.org/linus/;a=commit;h=2ae416b142b625c58c9ccb039aa3ef48ad0e9bae
> Commit:     2ae416b142b625c58c9ccb039aa3ef48ad0e9bae
> Parent:     e81f2d22370f8231cb7f13f454bcc8c0eb4e23f2
> Refname:    refs/heads/master
> Author:     Laurent Dufour <ldufour@linux.vnet.ibm.com>
> AuthorDate: Wed Jun 24 16:56:16 2015 -0700
> Committer:  Linus Torvalds <torvalds@linux-foundation.org>
> CommitDate: Wed Jun 24 17:49:41 2015 -0700
>
>     mm: new mm hook framework
>
>     CRIU is recreating the process memory layout by remapping the checkpointee
>     memory area on top of the current process (criu).  This includes remapping
>     the vDSO to the place it has at checkpoint time.
>
>     However some architectures like powerpc are keeping a reference to the
>     vDSO base address to build the signal return stack frame by calling the
>     vDSO sigreturn service.  So once the vDSO has been moved, this reference
>     is no more valid and the signal frame built later are not usable.
>
>     This patch serie is introducing a new mm hook framework, and a new
>     arch_remap hook which is called when mremap is done and the mm lock still
>     hold.  The next patch is adding the vDSO remap and unmap tracking to the
>     powerpc architecture.
>
>     This patch (of 3):
>
>     This patch introduces a new set of header file to manage mm hooks:
>     - per architecture empty header file (arch/x/include/asm/mm-arch-hooks.h)
>     - a generic header (include/linux/mm-arch-hooks.h)
>
>     The architecture which need to overwrite a hook as to redefine it in its
>     header file, while architecture which doesn't need have nothing to do.
>
>     The default hooks are defined in the generic header and are used in the
>     case the architecture is not defining it.
>
>     In a next step, mm hooks defined in include/asm-generic/mm_hooks.h should
>     be moved here.
>
>     Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>     Suggested-by: Andrew Morton <akpm@linux-foundation.org>
>     Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>     Cc: Hugh Dickins <hughd@google.com>
>     Cc: Rik van Riel <riel@redhat.com>
>     Cc: Mel Gorman <mgorman@suse.de>
>     Cc: Pavel Emelyanov <xemul@parallels.com>
>     Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>     Cc: Paul Mackerras <paulus@samba.org>
>     Cc: Michael Ellerman <mpe@ellerman.id.au>
>     Cc: Ingo Molnar <mingo@kernel.org>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> ---
>  arch/alpha/include/asm/mm-arch-hooks.h      | 15 +++++++++++++++
>  arch/arc/include/asm/mm-arch-hooks.h        | 15 +++++++++++++++
>  arch/arm/include/asm/mm-arch-hooks.h        | 15 +++++++++++++++
>  arch/arm64/include/asm/mm-arch-hooks.h      | 15 +++++++++++++++
>  arch/avr32/include/asm/mm-arch-hooks.h      | 15 +++++++++++++++
>  arch/blackfin/include/asm/mm-arch-hooks.h   | 15 +++++++++++++++
>  arch/c6x/include/asm/mm-arch-hooks.h        | 15 +++++++++++++++
>  arch/cris/include/asm/mm-arch-hooks.h       | 15 +++++++++++++++
>  arch/frv/include/asm/mm-arch-hooks.h        | 15 +++++++++++++++
>  arch/hexagon/include/asm/mm-arch-hooks.h    | 15 +++++++++++++++
>  arch/ia64/include/asm/mm-arch-hooks.h       | 15 +++++++++++++++
>  arch/m32r/include/asm/mm-arch-hooks.h       | 15 +++++++++++++++
>  arch/m68k/include/asm/mm-arch-hooks.h       | 15 +++++++++++++++
>  arch/metag/include/asm/mm-arch-hooks.h      | 15 +++++++++++++++
>  arch/microblaze/include/asm/mm-arch-hooks.h | 15 +++++++++++++++
>  arch/mips/include/asm/mm-arch-hooks.h       | 15 +++++++++++++++
>  arch/mn10300/include/asm/mm-arch-hooks.h    | 15 +++++++++++++++
>  arch/nios2/include/asm/mm-arch-hooks.h      | 15 +++++++++++++++
>  arch/openrisc/include/asm/mm-arch-hooks.h   | 15 +++++++++++++++
>  arch/parisc/include/asm/mm-arch-hooks.h     | 15 +++++++++++++++
>  arch/powerpc/include/asm/mm-arch-hooks.h    | 15 +++++++++++++++
>  arch/s390/include/asm/mm-arch-hooks.h       | 15 +++++++++++++++
>  arch/score/include/asm/mm-arch-hooks.h      | 15 +++++++++++++++
>  arch/sh/include/asm/mm-arch-hooks.h         | 15 +++++++++++++++
>  arch/sparc/include/asm/mm-arch-hooks.h      | 15 +++++++++++++++
>  arch/tile/include/asm/mm-arch-hooks.h       | 15 +++++++++++++++
>  arch/um/include/asm/mm-arch-hooks.h         | 15 +++++++++++++++
>  arch/unicore32/include/asm/mm-arch-hooks.h  | 15 +++++++++++++++
>  arch/x86/include/asm/mm-arch-hooks.h        | 15 +++++++++++++++
>  arch/xtensa/include/asm/mm-arch-hooks.h     | 15 +++++++++++++++
>  include/linux/mm-arch-hooks.h               | 16 ++++++++++++++++

Touching all arch/ directories without a CC to linux-arch?

>  31 files changed, 466 insertions(+)
>
> diff --git a/arch/alpha/include/asm/mm-arch-hooks.h b/arch/alpha/include/asm/mm-arch-hooks.h
> new file mode 100644
> index 0000000..b07fd86
> --- /dev/null
> +++ b/arch/alpha/include/asm/mm-arch-hooks.h
> @@ -0,0 +1,15 @@
> +/*
> + * Architecture specific mm hooks
> + *
> + * Copyright (C) 2015, IBM Corporation
> + * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>

Cool, copyright on an empty header!

> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + */
> +
> +#ifndef _ASM_ALPHA_MM_ARCH_HOOKS_H
> +#define _ASM_ALPHA_MM_ARCH_HOOKS_H
> +
> +#endif /* _ASM_ALPHA_MM_ARCH_HOOKS_H */

[...]

IMHO this screams for the generic version in include/asm-generic/,
and "generic-y += mm-arch-hooks.h" in arch/*/include/asm/Kbuild/.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
