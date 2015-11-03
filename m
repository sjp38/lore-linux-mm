Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 211AF6B0255
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 14:19:46 -0500 (EST)
Received: by igpw7 with SMTP id w7so87655609igp.0
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 11:19:45 -0800 (PST)
Received: from mail-io0-x233.google.com (mail-io0-x233.google.com. [2607:f8b0:4001:c06::233])
        by mx.google.com with ESMTPS id 3si21798792ioo.57.2015.11.03.11.19.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 11:19:45 -0800 (PST)
Received: by iody8 with SMTP id y8so29606060iod.1
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 11:19:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1446574204-15567-2-git-send-email-dcashman@android.com>
References: <1446574204-15567-1-git-send-email-dcashman@android.com>
	<1446574204-15567-2-git-send-email-dcashman@android.com>
Date: Tue, 3 Nov 2015 11:19:44 -0800
Message-ID: <CAGXu5jKGzDD9WVQnMTT2EfupZtjpdcASUpx-3npLAB-FctLodA@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] arm: mm: support ARCH_MMAP_RND_BITS.
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@android.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Don Zickus <dzickus@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Heinrich Schuchardt <xypron.glpk@gmx.de>, jpoimboe@redhat.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, n-horiguchi@ah.jp.nec.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Mark Salyzyn <salyzyn@android.com>, Jeffrey Vander Stoep <jeffv@google.com>, Nick Kralevich <nnk@google.com>, dcashman <dcashman@google.com>

On Tue, Nov 3, 2015 at 10:10 AM, Daniel Cashman <dcashman@android.com> wrote:
> From: dcashman <dcashman@google.com>
>
> arm: arch_mmap_rnd() uses a hard-code value of 8 to generate the
> random offset for the mmap base address.  This value represents a
> compromise between increased ASLR effectiveness and avoiding
> address-space fragmentation. Replace it with a Kconfig option, which
> is sensibly bounded, so that platform developers may choose where to
> place this compromise. Keep 8 as the minimum acceptable value.
>
> Signed-off-by: Daniel Cashman <dcashman@google.com>

Acked-by: Kees Cook <keescook@chromium.org>

Russell, if you don't see any problems here, it might make sense not
to put this through the ARM patch tracker since it depends on the 1/2,
and I think x86 and arm64 (and possibly other arch) changes are coming
too.

> ---
> Changes in v2:
>   - Changed arch/arm/Kconfig and arch/arm/mm/mmap.c to reflect changes
>   in [PATCH v2 1/2], specifically the movement of variables to global
>   rather than arch-specific files.
>
>  arch/arm/Kconfig   | 10 ++++++++++
>  arch/arm/mm/mmap.c |  3 +--
>  2 files changed, 11 insertions(+), 2 deletions(-)
>
> diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> index 639411f..47d7561 100644
> --- a/arch/arm/Kconfig
> +++ b/arch/arm/Kconfig
> @@ -35,6 +35,7 @@ config ARM
>         select HAVE_ARCH_BITREVERSE if (CPU_32v7M || CPU_32v7) && !CPU_32v6
>         select HAVE_ARCH_JUMP_LABEL if !XIP_KERNEL && !CPU_ENDIAN_BE32
>         select HAVE_ARCH_KGDB if !CPU_ENDIAN_BE32
> +       select HAVE_ARCH_MMAP_RND_BITS
>         select HAVE_ARCH_SECCOMP_FILTER if (AEABI && !OABI_COMPAT)
>         select HAVE_ARCH_TRACEHOOK
>         select HAVE_BPF_JIT
> @@ -306,6 +307,15 @@ config MMU
>           Select if you want MMU-based virtualised addressing space
>           support by paged memory management. If unsure, say 'Y'.
>
> +config ARCH_MMAP_RND_BITS_MIN
> +       default 8
> +
> +config ARCH_MMAP_RND_BITS_MAX
> +       default 14 if MMU && PAGE_OFFSET=0x40000000
> +       default 15 if MMU && PAGE_OFFSET=0x80000000
> +       default 16 if MMU
> +       default 8
> +
>  #
>  # The "ARM system type" choice list is ordered alphabetically by option
>  # text.  Please add new entries in the option alphabetic order.
> diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
> index 407dc78..c938693 100644
> --- a/arch/arm/mm/mmap.c
> +++ b/arch/arm/mm/mmap.c
> @@ -173,8 +173,7 @@ unsigned long arch_mmap_rnd(void)
>  {
>         unsigned long rnd;
>
> -       /* 8 bits of randomness in 20 address space bits */
> -       rnd = (unsigned long)get_random_int() % (1 << 8);
> +       rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_bits);
>
>         return rnd << PAGE_SHIFT;
>  }

I like this getting pulled closer and closer to having arch_mmap_rnd()
be identical across all architectures, and then we can just pull it
out and leave the true variable: the entropy size.

Do you have patches for x86 and arm64?

-Kees

> --
> 2.6.0.rc2.230.g3dd15c0
>



-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
