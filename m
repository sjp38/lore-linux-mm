Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 978236B028A
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 16:03:30 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r63so2759789wmb.9
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 13:03:30 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id r10si2538459wrr.500.2018.01.16.13.03.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 16 Jan 2018 13:03:29 -0800 (PST)
Date: Tue, 16 Jan 2018 22:03:19 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 09/16] x86/mm/pti: Clone CPU_ENTRY_AREA on PMD level on
 x86_32
In-Reply-To: <1516120619-1159-10-git-send-email-joro@8bytes.org>
Message-ID: <alpine.DEB.2.20.1801162158350.2366@nanos>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org> <1516120619-1159-10-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

On Tue, 16 Jan 2018, Joerg Roedel wrote:
> +#ifdef CONFIG_X86_64
>  /*
>   * Clone a single p4d (i.e. a top-level entry on 4-level systems and a
>   * next-level entry on 5-level systems.
> @@ -322,13 +323,29 @@ static void __init pti_clone_p4d(unsigned long addr)
>  	kernel_p4d = p4d_offset(kernel_pgd, addr);
>  	*user_p4d = *kernel_p4d;
>  }
> +#endif
>  
>  /*
>   * Clone the CPU_ENTRY_AREA into the user space visible page table.
>   */
>  static void __init pti_clone_user_shared(void)
>  {
> +#ifdef CONFIG_X86_32
> +	/*
> +	 * On 32 bit PAE systems with 1GB of Kernel address space there is only
> +	 * one pgd/p4d for the whole kernel. Cloning that would map the whole
> +	 * address space into the user page-tables, making PTI useless. So clone
> +	 * the page-table on the PMD level to prevent that.
> +	 */
> +	unsigned long start, end;
> +
> +	start = CPU_ENTRY_AREA_BASE;
> +	end   = start + (PAGE_SIZE * CPU_ENTRY_AREA_PAGES);
> +
> +	pti_clone_pmds(start, end, _PAGE_GLOBAL);
> +#else
>  	pti_clone_p4d(CPU_ENTRY_AREA_BASE);
> +#endif
>  }

Just a minor nit. You already wrap pti_clone_p4d() into X86_64. So it would
be cleaner to do:

  	kernel_p4d = p4d_offset(kernel_pgd, addr);
  	*user_p4d = *kernel_p4d;
}

static void __init pti_clone_user_shared(void)
{
  	pti_clone_p4d(CPU_ENTRY_AREA_BASE);
}

#else /* CONFIG_X86_64 */

/*
 * Big fat comment.
 */
static void __init pti_clone_user_shared(void)
{
	....
}
#endif /* !CONFIG_X86_64 */

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
