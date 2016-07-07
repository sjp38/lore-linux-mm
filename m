Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A8E246B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 06:07:33 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 143so26898024pfx.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 03:07:33 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id sr7si3574295pab.10.2016.07.07.03.07.32
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 03:07:32 -0700 (PDT)
Date: Thu, 7 Jul 2016 11:07:18 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 4/9] arm64/uaccess: Enable hardened usercopy
Message-ID: <20160707100717.GB8306@leverpostej>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org>
 <1467843928-29351-5-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467843928-29351-5-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, kernel-hardening@lists.openwall.com, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King <linux@armlinux.org.uk>, linux-arm-kernel@lists.infradead.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, PaX Team <pageexec@freemail.hu>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>, Rik van Riel <riel@redhat.com>, Vitaly Wool <vitalywool@gmail.com>, David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, Brad Spengler <spender@grsecurity.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Pekka Enberg <penberg@kernel.org>, Casey Schaufler <casey@schaufler-ca.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

Hi,

On Wed, Jul 06, 2016 at 03:25:23PM -0700, Kees Cook wrote:
> Enables CONFIG_HARDENED_USERCOPY checks on arm64. As done by KASAN in -next,
> renames the low-level functions to __arch_copy_*_user() so a static inline
> can do additional work before the copy.

The checks themselves look fine, but as with the KASAN checks, it seems
a shame that this logic is duplicated per arch, integrated in subtly
different ways.

Can we not __arch prefix all the arch uaccess helpers, and place
kasan_check_*() and check_object_size() calls in generic wrappers?

If we're going to update all the arch uaccess helpers anyway, doing that
would make it easier to fix things up, or to add new checks in future.

Thanks,
Mark.

> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  arch/arm64/Kconfig               |  2 ++
>  arch/arm64/include/asm/uaccess.h | 18 ++++++++++++++++--
>  arch/arm64/kernel/arm64ksyms.c   |  4 ++--
>  arch/arm64/lib/copy_from_user.S  |  4 ++--
>  arch/arm64/lib/copy_to_user.S    |  4 ++--
>  5 files changed, 24 insertions(+), 8 deletions(-)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 5a0a691d4220..b771cd97f74b 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -51,10 +51,12 @@ config ARM64
>  	select HAVE_ALIGNED_STRUCT_PAGE if SLUB
>  	select HAVE_ARCH_AUDITSYSCALL
>  	select HAVE_ARCH_BITREVERSE
> +	select HAVE_ARCH_HARDENED_USERCOPY
>  	select HAVE_ARCH_HUGE_VMAP
>  	select HAVE_ARCH_JUMP_LABEL
>  	select HAVE_ARCH_KASAN if SPARSEMEM_VMEMMAP && !(ARM64_16K_PAGES && ARM64_VA_BITS_48)
>  	select HAVE_ARCH_KGDB
> +	select HAVE_ARCH_LINEAR_KERNEL_MAPPING
>  	select HAVE_ARCH_MMAP_RND_BITS
>  	select HAVE_ARCH_MMAP_RND_COMPAT_BITS if COMPAT
>  	select HAVE_ARCH_SECCOMP_FILTER
> diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
> index 9e397a542756..6d0f86300936 100644
> --- a/arch/arm64/include/asm/uaccess.h
> +++ b/arch/arm64/include/asm/uaccess.h
> @@ -256,11 +256,25 @@ do {									\
>  		-EFAULT;						\
>  })
>  
> -extern unsigned long __must_check __copy_from_user(void *to, const void __user *from, unsigned long n);
> -extern unsigned long __must_check __copy_to_user(void __user *to, const void *from, unsigned long n);
> +extern unsigned long __must_check __arch_copy_from_user(void *to, const void __user *from, unsigned long n);
> +extern unsigned long __must_check __arch_copy_to_user(void __user *to, const void *from, unsigned long n);
>  extern unsigned long __must_check __copy_in_user(void __user *to, const void __user *from, unsigned long n);
>  extern unsigned long __must_check __clear_user(void __user *addr, unsigned long n);
>  
> +static inline unsigned long __must_check
> +__copy_from_user(void *to, const void __user *from, unsigned long n)
> +{
> +	check_object_size(to, n, false);
> +	return __arch_copy_from_user(to, from, n);
> +}
> +
> +static inline unsigned long __must_check
> +__copy_to_user(void __user *to, const void *from, unsigned long n)
> +{
> +	check_object_size(from, n, true);
> +	return __arch_copy_to_user(to, from, n);
> +}
> +
>  static inline unsigned long __must_check copy_from_user(void *to, const void __user *from, unsigned long n)
>  {
>  	if (access_ok(VERIFY_READ, from, n))
> diff --git a/arch/arm64/kernel/arm64ksyms.c b/arch/arm64/kernel/arm64ksyms.c
> index 678f30b05a45..2dc44406a7ad 100644
> --- a/arch/arm64/kernel/arm64ksyms.c
> +++ b/arch/arm64/kernel/arm64ksyms.c
> @@ -34,8 +34,8 @@ EXPORT_SYMBOL(copy_page);
>  EXPORT_SYMBOL(clear_page);
>  
>  	/* user mem (segment) */
> -EXPORT_SYMBOL(__copy_from_user);
> -EXPORT_SYMBOL(__copy_to_user);
> +EXPORT_SYMBOL(__arch_copy_from_user);
> +EXPORT_SYMBOL(__arch_copy_to_user);
>  EXPORT_SYMBOL(__clear_user);
>  EXPORT_SYMBOL(__copy_in_user);
>  
> diff --git a/arch/arm64/lib/copy_from_user.S b/arch/arm64/lib/copy_from_user.S
> index 17e8306dca29..0b90497d4424 100644
> --- a/arch/arm64/lib/copy_from_user.S
> +++ b/arch/arm64/lib/copy_from_user.S
> @@ -66,7 +66,7 @@
>  	.endm
>  
>  end	.req	x5
> -ENTRY(__copy_from_user)
> +ENTRY(__arch_copy_from_user)
>  ALTERNATIVE("nop", __stringify(SET_PSTATE_PAN(0)), ARM64_ALT_PAN_NOT_UAO, \
>  	    CONFIG_ARM64_PAN)
>  	add	end, x0, x2
> @@ -75,7 +75,7 @@ ALTERNATIVE("nop", __stringify(SET_PSTATE_PAN(1)), ARM64_ALT_PAN_NOT_UAO, \
>  	    CONFIG_ARM64_PAN)
>  	mov	x0, #0				// Nothing to copy
>  	ret
> -ENDPROC(__copy_from_user)
> +ENDPROC(__arch_copy_from_user)
>  
>  	.section .fixup,"ax"
>  	.align	2
> diff --git a/arch/arm64/lib/copy_to_user.S b/arch/arm64/lib/copy_to_user.S
> index 21faae60f988..7a7efe255034 100644
> --- a/arch/arm64/lib/copy_to_user.S
> +++ b/arch/arm64/lib/copy_to_user.S
> @@ -65,7 +65,7 @@
>  	.endm
>  
>  end	.req	x5
> -ENTRY(__copy_to_user)
> +ENTRY(__arch_copy_to_user)
>  ALTERNATIVE("nop", __stringify(SET_PSTATE_PAN(0)), ARM64_ALT_PAN_NOT_UAO, \
>  	    CONFIG_ARM64_PAN)
>  	add	end, x0, x2
> @@ -74,7 +74,7 @@ ALTERNATIVE("nop", __stringify(SET_PSTATE_PAN(1)), ARM64_ALT_PAN_NOT_UAO, \
>  	    CONFIG_ARM64_PAN)
>  	mov	x0, #0
>  	ret
> -ENDPROC(__copy_to_user)
> +ENDPROC(__arch_copy_to_user)
>  
>  	.section .fixup,"ax"
>  	.align	2
> -- 
> 2.7.4
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
