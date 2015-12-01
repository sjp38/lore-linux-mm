Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5F1986B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 19:03:20 -0500 (EST)
Received: by igbxm8 with SMTP id xm8so85538157igb.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 16:03:20 -0800 (PST)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com. [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id 10si8512132igy.27.2015.11.30.16.03.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 16:03:19 -0800 (PST)
Received: by igcmv3 with SMTP id mv3so82632208igc.0
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 16:03:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1448578785-17656-5-git-send-email-dcashman@android.com>
References: <1448578785-17656-1-git-send-email-dcashman@android.com>
	<1448578785-17656-2-git-send-email-dcashman@android.com>
	<1448578785-17656-3-git-send-email-dcashman@android.com>
	<1448578785-17656-4-git-send-email-dcashman@android.com>
	<1448578785-17656-5-git-send-email-dcashman@android.com>
Date: Mon, 30 Nov 2015 16:03:19 -0800
Message-ID: <CAGXu5j+Wj_=27gsYStV5OuwNSznux7MtDcMuYe5wM2ORrna_TQ@mail.gmail.com>
Subject: Re: [PATCH v4 4/4] x86: mm: support ARCH_MMAP_RND_BITS.
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@android.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Don Zickus <dzickus@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Heinrich Schuchardt <xypron.glpk@gmx.de>, jpoimboe@redhat.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, n-horiguchi@ah.jp.nec.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Mark Salyzyn <salyzyn@android.com>, Jeffrey Vander Stoep <jeffv@google.com>, Nick Kralevich <nnk@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Hector Marco <hecmargi@upv.es>, Borislav Petkov <bp@suse.de>, Daniel Cashman <dcashman@google.com>

On Thu, Nov 26, 2015 at 2:59 PM, Daniel Cashman <dcashman@android.com> wrote:
> x86: arch_mmap_rnd() uses hard-coded values, 8 for 32-bit and 28 for
> 64-bit, to generate the random offset for the mmap base address.
> This value represents a compromise between increased ASLR
> effectiveness and avoiding address-space fragmentation. Replace it
> with a Kconfig option, which is sensibly bounded, so that platform
> developers may choose where to place this compromise. Keep default
> values as new minimums.
>
> Signed-off-by: Daniel Cashman <dcashman@android.com>
> ---
>  arch/x86/Kconfig   | 16 ++++++++++++++++
>  arch/x86/mm/mmap.c | 12 ++++++------
>  2 files changed, 22 insertions(+), 6 deletions(-)
>
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index db3622f..12768c4 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -82,6 +82,8 @@ config X86
>         select HAVE_ARCH_KASAN                  if X86_64 && SPARSEMEM_VMEMMAP
>         select HAVE_ARCH_KGDB
>         select HAVE_ARCH_KMEMCHECK
> +       select HAVE_ARCH_MMAP_RND_BITS
> +       select HAVE_ARCH_MMAP_RND_COMPAT_BITS if COMPAT
>         select HAVE_ARCH_SECCOMP_FILTER
>         select HAVE_ARCH_SOFT_DIRTY             if X86_64
>         select HAVE_ARCH_TRACEHOOK
> @@ -183,6 +185,20 @@ config HAVE_LATENCYTOP_SUPPORT
>  config MMU
>         def_bool y
>
> +config ARCH_MMAP_RND_BITS_MIN
> +       default 28 if 64BIT
> +       default 8
> +
> +config ARCH_MMAP_RND_BITS_MAX
> +       default 32 if 64BIT
> +       default 16
> +
> +config ARCH_MMAP_RND_COMPAT_BITS_MIN
> +       default 8
> +
> +config ARCH_MMAP_RND_COMPAT_BITS_MAX
> +       default 16
> +
>  config SBUS
>         bool
>
> diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
> index 844b06d..647fecf 100644
> --- a/arch/x86/mm/mmap.c
> +++ b/arch/x86/mm/mmap.c
> @@ -69,14 +69,14 @@ unsigned long arch_mmap_rnd(void)
>  {
>         unsigned long rnd;
>
> -       /*
> -        *  8 bits of randomness in 32bit mmaps, 20 address space bits
> -        * 28 bits of randomness in 64bit mmaps, 40 address space bits
> -        */
>         if (mmap_is_ia32())
> -               rnd = (unsigned long)get_random_int() % (1<<8);
> +#ifdef CONFIG_COMPAT
> +               rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_compat_bits);
> +#else
> +               rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_bits);
> +#endif
>         else
> -               rnd = (unsigned long)get_random_int() % (1<<28);
> +               rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_bits);
>
>         return rnd << PAGE_SHIFT;
>  }
> --
> 2.6.0.rc2.230.g3dd15c0
>

Can you rework this logic to look more like the arm64 one? I think
it's more readable as:

#ifdef CONFIG_COMPAT
    if (mmap_is_ia32())
            rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_compat_bits);
    else
#endif
            rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_bits);

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
