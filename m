Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D18826B0296
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 15:30:27 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 31so6626372wru.0
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 12:30:27 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id z66si2372723wmh.76.2018.01.16.12.30.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 16 Jan 2018 12:30:26 -0800 (PST)
Date: Tue, 16 Jan 2018 21:30:14 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 02/16] x86/entry/32: Enter the kernel via trampoline
 stack
In-Reply-To: <1516120619-1159-3-git-send-email-joro@8bytes.org>
Message-ID: <alpine.DEB.2.20.1801162117330.2366@nanos>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org> <1516120619-1159-3-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

On Tue, 16 Jan 2018, Joerg Roedel wrote:
> @@ -89,13 +89,9 @@ static inline void refresh_sysenter_cs(struct thread_struct *thread)
>  /* This is used when switching tasks or entering/exiting vm86 mode. */
>  static inline void update_sp0(struct task_struct *task)
>  {
> -	/* On x86_64, sp0 always points to the entry trampoline stack, which is constant: */
> -#ifdef CONFIG_X86_32
> -	load_sp0(task->thread.sp0);
> -#else
> +	/* sp0 always points to the entry trampoline stack, which is constant: */
>  	if (static_cpu_has(X86_FEATURE_XENPV))
>  		load_sp0(task_top_of_stack(task));
> -#endif
>  }
>  
>  #endif /* _ASM_X86_SWITCH_TO_H */
> diff --git a/arch/x86/kernel/asm-offsets_32.c b/arch/x86/kernel/asm-offsets_32.c
> index 654229bac2fc..7270dd834f4b 100644
> --- a/arch/x86/kernel/asm-offsets_32.c
> +++ b/arch/x86/kernel/asm-offsets_32.c
> @@ -47,9 +47,11 @@ void foo(void)
>  	BLANK();
>  
>  	/* Offset from the sysenter stack to tss.sp0 */
> -	DEFINE(TSS_sysenter_stack, offsetof(struct cpu_entry_area, tss.x86_tss.sp0) -
> +	DEFINE(TSS_sysenter_stack, offsetof(struct cpu_entry_area, tss.x86_tss.sp1) -
>  	       offsetofend(struct cpu_entry_area, entry_stack_page.stack));
>  
> +	OFFSET(TSS_sp1, tss_struct, x86_tss.sp1);

Can you please split out the change of TSS_sysenter_stack into a separate
patch?

Other than that, this looks good.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
