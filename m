Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id B40336B0270
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 16:53:23 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id z21-v6so10490836plo.13
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 13:53:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p20-v6sor5898397pgb.313.2018.07.12.13.53.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Jul 2018 13:53:22 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 05/39] x86/entry/32: Unshare NMI return path
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <1531308586-29340-6-git-send-email-joro@8bytes.org>
Date: Thu, 12 Jul 2018 13:53:19 -0700
Content-Transfer-Encoding: 7bit
Message-Id: <BEEA447A-26A1-49C9-925A-63F96E9115B0@amacapital.net>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org> <1531308586-29340-6-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de



> On Jul 11, 2018, at 4:29 AM, Joerg Roedel <joro@8bytes.org> wrote:
> 
> From: Joerg Roedel <jroedel@suse.de>
> 
> NMI will no longer use most of the shared return path,
> because NMI needs special handling when the CR3 switches for
> PTI are added.

Why?  What would go wrong?

How many return-to-usermode paths will we have?  64-bit has only one.

> This patch prepares for that.
> 
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
> arch/x86/entry/entry_32.S | 8 ++++++--
> 1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
> index d35a69a..571209e 100644
> --- a/arch/x86/entry/entry_32.S
> +++ b/arch/x86/entry/entry_32.S
> @@ -1017,7 +1017,7 @@ ENTRY(nmi)
> 
>    /* Not on SYSENTER stack. */
>    call    do_nmi
> -    jmp    .Lrestore_all_notrace
> +    jmp    .Lnmi_return
> 
> .Lnmi_from_sysenter_stack:
>    /*
> @@ -1028,7 +1028,11 @@ ENTRY(nmi)
>    movl    PER_CPU_VAR(cpu_current_top_of_stack), %esp
>    call    do_nmi
>    movl    %ebx, %esp
> -    jmp    .Lrestore_all_notrace
> +
> +.Lnmi_return:
> +    CHECK_AND_APPLY_ESPFIX
> +    RESTORE_REGS 4
> +    jmp    .Lirq_return
> 
> #ifdef CONFIG_X86_ESPFIX32
> .Lnmi_espfix_stack:
> -- 
> 2.7.4
> 
