Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 600196B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 13:11:16 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x202so29618593pgx.1
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 10:11:16 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id p27si23295651pgc.402.2017.11.27.10.11.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 10:11:15 -0800 (PST)
Subject: Re: [patch V2 1/5] x86/kaiser: Respect disabled CPU features
References: <20171126231403.657575796@linutronix.de>
 <20171126232414.313869499@linutronix.de>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <07d101b3-d17a-7781-f05e-96738e6d6848@linux.intel.com>
Date: Mon, 27 Nov 2017 10:11:12 -0800
MIME-Version: 1.0
In-Reply-To: <20171126232414.313869499@linutronix.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

> --- a/arch/x86/include/asm/pgtable_64.h
> +++ b/arch/x86/include/asm/pgtable_64.h
> @@ -222,7 +222,8 @@ static inline pgd_t kaiser_set_shadow_pg
>  			 * wrong CR3 value, userspace will crash
>  			 * instead of running.
>  			 */
> -			pgd.pgd |= _PAGE_NX;
> +			if (__supported_pte_mask & _PAGE_NX)
> +				pgd.pgd |= _PAGE_NX;
>  		}

Thanks for catching that.  It's definitely a bug.  Although,
practically, it's hard to hit, right?  I think everything 64-bit
supports NX unless the hypervisor disabled it or something.

>  	} else if (pgd_userspace_access(*pgdp)) {
>  		/*
> --- a/arch/x86/mm/kaiser.c
> +++ b/arch/x86/mm/kaiser.c
> @@ -42,6 +42,8 @@
>  
>  #define KAISER_WALK_ATOMIC  0x1
>  
> +static pteval_t kaiser_pte_mask __ro_after_init = ~(_PAGE_NX | _PAGE_GLOBAL);

Do we need a comment on this, like:

/*
 * The NX and GLOBAL bits are not supported on all CPUs.
 * We will add them back to this mask at runtime in
 * kaiser_init_all_pgds() if supported.
 */

>  /*
>   * At runtime, the only things we map are some things for CPU
>   * hotplug, and stacks for new processes.  No two CPUs will ever
> @@ -244,11 +246,14 @@ static pte_t *kaiser_shadow_pagetable_wa
>  int kaiser_add_user_map(const void *__start_addr, unsigned long size,
>  			unsigned long flags)
>  {
> -	pte_t *pte;
>  	unsigned long start_addr = (unsigned long)__start_addr;
>  	unsigned long address = start_addr & PAGE_MASK;
>  	unsigned long end_addr = PAGE_ALIGN(start_addr + size);
>  	unsigned long target_address;
> +	pte_t *pte;
> +
> +	/* Clear not supported bits */
> +	flags &= kaiser_pte_mask;

Should we be warning on these if we clear them?  Seems kinda funky to
silently fix them up.

>  	for (; address < end_addr; address += PAGE_SIZE) {
>  		target_address = get_pa_from_kernel_map(address);
> @@ -308,6 +313,11 @@ static void __init kaiser_init_all_pgds(
>  	pgd_t *pgd;
>  	int i;
>  
> +	if (__supported_pte_mask & _PAGE_NX)
> +		kaiser_pte_mask |= _PAGE_NX;
> +	if (boot_cpu_has(X86_FEATURE_PGE))
> +		kaiser_pte_mask |= _PAGE_GLOBAL;

Practically, I guess boot_cpu_has(X86_FEATURE_PGE) == (cr4_read() &
X86_CR4_PGE).  But, in a slow path like this, is it perhaps better to
just be checking CR4 directly?

Looks functionally fine to me, though.  Feel free to add my Reviewed-by
or Acked-by.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
