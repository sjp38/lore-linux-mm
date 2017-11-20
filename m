Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 896A86B0268
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 15:12:53 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id k3so6984634wmg.6
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 12:12:53 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id b196si8116519wmf.157.2017.11.20.12.12.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 20 Nov 2017 12:12:52 -0800 (PST)
Date: Mon, 20 Nov 2017 21:12:40 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 09/30] x86, kaiser: only populate shadow page tables for
 userspace
In-Reply-To: <20171110193113.E35BC3BF@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.20.1711202057581.2348@nanos>
References: <20171110193058.BECA7D88@viggo.jf.intel.com> <20171110193113.E35BC3BF@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Fri, 10 Nov 2017, Dave Hansen wrote:

This should be folded into the previous patch.

>  b/arch/x86/include/asm/pgtable_64.h |   94 +++++++++++++++++++++++-------------
>  1 file changed, 61 insertions(+), 33 deletions(-)
> 
> diff -puN arch/x86/include/asm/pgtable_64.h~kaiser-set-pgd-careful-plus-NX arch/x86/include/asm/pgtable_64.h
> --- a/arch/x86/include/asm/pgtable_64.h~kaiser-set-pgd-careful-plus-NX	2017-11-10 11:22:09.932244947 -0800
> +++ b/arch/x86/include/asm/pgtable_64.h	2017-11-10 11:22:09.935244947 -0800
> @@ -177,38 +177,76 @@ static inline p4d_t *native_get_normal_p
>  /*
>   * Page table pages are page-aligned.  The lower half of the top
>   * level is used for userspace and the top half for the kernel.
> - * This returns true for user pages that need to get copied into
> - * both the user and kernel copies of the page tables, and false
> - * for kernel pages that should only be in the kernel copy.
> + *
> + * Returns true for parts of the PGD that map userspace and
> + * false for the parts that map the kernel.
>   */
> -static inline bool is_userspace_pgd(void *__ptr)
> +static inline bool pgdp_maps_userspace(void *__ptr)
>  {
>  	unsigned long ptr = (unsigned long)__ptr;
>  
>  	return ((ptr % PAGE_SIZE) < (PAGE_SIZE / 2));
>  }
>  
> +/*
> + * Does this PGD allow access via userspace?

s/via/from/

> + */
> +static inline bool pgd_userspace_access(pgd_t pgd)
> +{
> +	return (pgd.pgd & _PAGE_USER);
> +}
> +
> +/*
> + * Returns the pgd_t that the kernel should use in its page tables.

Should? Can the caller still decide to put something different there? I
doubt that.

> +static inline pgd_t kaiser_set_shadow_pgd(pgd_t *pgdp, pgd_t pgd)
> +{
> +#ifdef CONFIG_KAISER
> +	if (pgd_userspace_access(pgd)) {
> +		if (pgdp_maps_userspace(pgdp)) {
> +			/*
> +			 * The user/shadow page tables get the full
> +			 * PGD, accessible to userspace:

s/to/from/

> +			 */
> +			native_get_shadow_pgd(pgdp)->pgd = pgd.pgd;
> +			/*
> +			 * For the copy of the pgd that the kernel
> +			 * uses, make it unusable to userspace.  This
> +			 * ensures if we get out to userspace with the
> +			 * wrong CR3 value, userspace will crash
> +			 * instead of running.
> +			 */
> +			pgd.pgd |= _PAGE_NX;
> +		}
> +	} else if (!pgd.pgd) {
> +		/*
> +		 * We are clearing the PGD and can not check  _PAGE_USER
> +		 * in the zero'd PGD.

Just the argument cannot be checked because it's clearing the entry. The
pgd entry itself is not yet modified, so it could be checked.

  		 * We never do this on the
> +		 * pre-populated kernel PGDs, except for pgd_bad().
> +		 */
> +		if (pgdp_maps_userspace(pgdp)) {
> +			native_get_shadow_pgd(pgdp)->pgd = pgd.pgd;
> +		} else {
> +			/*
> +			 * Uh, we are very confused.  We have been
> +			 * asked to clear a PGD that is in the kernel
> +			 * part of the address space.  We preallocated
> +			 * all the KAISER PGDs, so this should never
> +			 * happen.
> +			 */
> +			WARN_ON_ONCE(1);
> +		}
> +	}

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
