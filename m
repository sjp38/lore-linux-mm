Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0E37C6B0006
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 05:10:03 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c1-v6so11701976eds.15
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 02:10:03 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id u30-v6si6660031edi.142.2018.10.15.02.10.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 02:10:01 -0700 (PDT)
Date: Mon, 15 Oct 2018 11:10:00 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH] x86/entry/32: Fix setup of CS high bits
Message-ID: <20181015091000.GE3630@8bytes.org>
References: <1531906876-13451-1-git-send-email-joro@8bytes.org>
 <1531906876-13451-11-git-send-email-joro@8bytes.org>
 <97421241-2bc4-c3f1-4128-95b3e8a230d1@siemens.com>
 <35a24feb-5970-aa03-acbf-53428a159ace@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35a24feb-5970-aa03-acbf-53428a159ace@web.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kiszka <jan.kiszka@web.de>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>

Hey Jan,

thanks for tracking this down and sending the fix! So your hardware
probably doesn't zero out the CS high bits, so that the code wrongly
detects that it came from the entry stack on return. Clearing the bits
earlier before the entry-stack check makes sense.

Acked-by: Joerg Roedel <jroedel@suse.de>
Reviewed-by: Joerg Roedel <jroedel@suse.de>

On Sat, Oct 13, 2018 at 11:54:54AM +0200, Jan Kiszka wrote:
> diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
> index 2767c625a52c..95c94d48ecd2 100644
> --- a/arch/x86/entry/entry_32.S
> +++ b/arch/x86/entry/entry_32.S
> @@ -389,6 +389,12 @@
>  	 * that register for the time this macro runs
>  	 */
>  
> +	/*
> +	 * Clear unused upper bits of the dword containing the word-sized CS
> +	 * slot in pt_regs in case hardware didn't clear it for us.
> +	 */
> +	andl	$(0x0000ffff), PT_CS(%esp)
> +
>  	/* Are we on the entry stack? Bail out if not! */
>  	movl	PER_CPU_VAR(cpu_entry_area), %ecx
>  	addl	$CPU_ENTRY_AREA_entry_stack + SIZEOF_entry_stack, %ecx
> @@ -407,12 +413,6 @@
>  	/* Load top of task-stack into %edi */
>  	movl	TSS_entry2task_stack(%edi), %edi
>  
> -	/*
> -	 * Clear unused upper bits of the dword containing the word-sized CS
> -	 * slot in pt_regs in case hardware didn't clear it for us.
> -	 */
> -	andl	$(0x0000ffff), PT_CS(%esp)
> -
>  	/* Special case - entry from kernel mode via entry stack */
>  #ifdef CONFIG_VM86
>  	movl	PT_EFLAGS(%esp), %ecx		# mix EFLAGS and CS
> -- 
> 2.16.4
