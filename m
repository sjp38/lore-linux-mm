Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8573C6B0005
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 08:34:33 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id j4so4045056wrg.11
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 05:34:33 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id v28si3538603edd.488.2018.03.01.05.34.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Mar 2018 05:34:32 -0800 (PST)
Date: Thu, 1 Mar 2018 14:34:30 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 12/31] x86/entry/32: Add PTI cr3 switch to non-NMI
 entry/exit points
Message-ID: <20180301133430.wda4qesqhxnww7d6@8bytes.org>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <1518168340-9392-13-git-send-email-joro@8bytes.org>
 <afd5bae9-f53e-a225-58f1-4ba2422044e3@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <afd5bae9-f53e-a225-58f1-4ba2422044e3@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de

On Tue, Feb 27, 2018 at 02:18:36PM -0500, Waiman Long wrote:
> > +	/* Make sure we are running on kernel cr3 */
> > +	SWITCH_TO_KERNEL_CR3 scratch_reg=%eax
> > +
> >  	xorl	%edx, %edx			# error code 0
> >  	movl	%esp, %eax			# pt_regs pointer
> >  
> 
> The debug exception calls ret_from_exception on exit. If coming from
> userspace, the C function prepare_exit_to_usermode() will be called.
> With the PTI-32 code, it means that function will be called with the
> entry stack instead of the task stack. This can be problematic as macro
> like current won't work anymore.

Okay, I had another look at the debug handler. As I said before, it
already handles the from-entry-stack case, but with these patches it
gets more likely that we actually hit that path.

Also, with the special handling for from-kernel-with-entry-stack
situations we can simplify the debug handler and make it more robust
with the diff below. Thoughts?

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index 8c149f5..844aff1 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -1318,33 +1318,14 @@ ENTRY(debug)
 	ASM_CLAC
 	pushl	$-1				# mark this as an int
 
-	SAVE_ALL
+	SAVE_ALL switch_stacks=1
 	ENCODE_FRAME_POINTER
 
-	/* Make sure we are running on kernel cr3 */
-	SWITCH_TO_KERNEL_CR3 scratch_reg=%eax
-
 	xorl	%edx, %edx			# error code 0
 	movl	%esp, %eax			# pt_regs pointer
 
-	/* Are we currently on the SYSENTER stack? */
-	movl	PER_CPU_VAR(cpu_entry_area), %ecx
-	addl	$CPU_ENTRY_AREA_entry_stack + SIZEOF_entry_stack, %ecx
-	subl	%eax, %ecx	/* ecx = (end of entry_stack) - esp */
-	cmpl	$SIZEOF_entry_stack, %ecx
-	jb	.Ldebug_from_sysenter_stack
-
-	TRACE_IRQS_OFF
-	call	do_debug
-	jmp	ret_from_exception
-
-.Ldebug_from_sysenter_stack:
-	/* We're on the SYSENTER stack.  Switch off. */
-	movl	%esp, %ebx
-	movl	PER_CPU_VAR(cpu_current_top_of_stack), %esp
 	TRACE_IRQS_OFF
 	call	do_debug
-	movl	%ebx, %esp
 	jmp	ret_from_exception
 END(debug)
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
