Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id EB5E928024A
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 17:49:05 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id t2so6909341plm.7
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:49:05 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m15si3037361pln.714.2018.01.16.14.49.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 14:49:04 -0800 (PST)
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 76A5E21783
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 22:49:04 +0000 (UTC)
Received: by mail-io0-f172.google.com with SMTP id l17so8741154ioc.3
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:49:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1516120619-1159-4-git-send-email-joro@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org> <1516120619-1159-4-git-send-email-joro@8bytes.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 16 Jan 2018 14:48:43 -0800
Message-ID: <CALCETrW9F4QDFPG=ATs0QiyQO526SK0s==oYKhvVhxaYCw+65g@mail.gmail.com>
Subject: Re: [PATCH 03/16] x86/entry/32: Leave the kernel via the trampoline stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On Tue, Jan 16, 2018 at 8:36 AM, Joerg Roedel <joro@8bytes.org> wrote:
> From: Joerg Roedel <jroedel@suse.de>
>
> Switch back to the trampoline stack before returning to
> userspace.
>
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>  arch/x86/entry/entry_32.S        | 58 ++++++++++++++++++++++++++++++++++++++++
>  arch/x86/kernel/asm-offsets_32.c |  1 +
>  2 files changed, 59 insertions(+)
>
> diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
> index 5a7bdb73be9f..14018eeb11c3 100644
> --- a/arch/x86/entry/entry_32.S
> +++ b/arch/x86/entry/entry_32.S
> @@ -263,6 +263,61 @@
>  .endm
>
>  /*
> + * Switch back from the kernel stack to the entry stack.
> + *
> + * iret_frame > 0 adds code to copie over an iret frame from the old to
> + *                the new stack. It also adds a check which bails out if
> + *                we are not returning to user-space.
> + *
> + * This macro is allowed not modify eflags when iret_frame == 0.
> + */
> +.macro SWITCH_TO_ENTRY_STACK iret_frame=0
> +       .if \iret_frame > 0
> +       /* Are we returning to userspace? */
> +       testb   $3, 4(%esp) /* return CS */
> +       jz .Lend_\@
> +       .endif
> +
> +       /*
> +        * We run with user-%fs already loaded from pt_regs, so we don't
> +        * have access to per_cpu data anymore, and there is no swapgs
> +        * equivalent on x86_32.
> +        * We work around this by loading the kernel-%fs again and
> +        * reading the entry stack address from there. Then we restore
> +        * the user-%fs and return.
> +        */
> +       pushl %fs
> +       pushl %edi
> +
> +       /* Re-load kernel-%fs, after that we can use PER_CPU_VAR */
> +       movl $(__KERNEL_PERCPU), %edi
> +       movl %edi, %fs
> +
> +       /* Save old stack pointer to copy the return frame over if needed */
> +       movl %esp, %edi
> +       movl PER_CPU_VAR(cpu_tss_rw + TSS_sp0), %esp
> +
> +       /* Now we are on the entry stack */
> +
> +       .if \iret_frame > 0
> +       /* Stack frame: ss, esp, eflags, cs, eip, fs, edi */
> +       pushl 6*4(%edi) /* ss */
> +       pushl 5*4(%edi) /* esp */
> +       pushl 4*4(%edi) /* eflags */
> +       pushl 3*4(%edi) /* cs */
> +       pushl 2*4(%edi) /* eip */
> +       .endif
> +
> +       pushl 4(%edi)   /* fs */
> +
> +       /* Restore user %edi and user %fs */
> +       movl (%edi), %edi
> +       popl %fs

Yikes!  We're not *supposed* to be able to observe an asynchronous
descriptor table change, but if the LDT changes out from under you,
this is going to blow up badly.  It would be really nice if you could
pull this off without percpu access or without needing to do this
dance where you load user FS, then kernel FS, then user FS.  If that's
not doable, then you should at least add exception handling -- look at
the other 'pop %fs' instructions in entry_32.S.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
