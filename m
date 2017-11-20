Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3929F6B0038
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 07:17:57 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y41so5817461wrc.22
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 04:17:57 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id t84si6107441wmt.58.2017.11.20.04.17.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 20 Nov 2017 04:17:55 -0800 (PST)
Date: Mon, 20 Nov 2017 13:17:52 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 05/30] x86, kaiser: prepare assembly for entry/exit CR3
 switching
In-Reply-To: <20171110193107.67B798C3@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.20.1711201226370.1734@nanos>
References: <20171110193058.BECA7D88@viggo.jf.intel.com> <20171110193107.67B798C3@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Fri, 10 Nov 2017, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> This is largely code from Andy Lutomirski.  I fixed a few bugs
> in it, and added a few SWITCH_TO_* spots.
> 
> KAISER needs to switch to a different CR3 value when it enters
> the kernel and switch back when it exits.  This essentially
> needs to be done before leaving assembly code.
> 
> This is extra challenging because the switching context is
> tricky: the registers that can be clobbered can vary.  It is also
> hard to store things on the stack because there is an established
> ABI (ptregs) or the stack is entirely unsafe to use.

Changelog nitpicking starts here

> This patch establishes a set of macros that allow changing to

s/This patch establishes/Establish/

> the user and kernel CR3 values.
> 
> Interactions with SWAPGS: previous versions of the KAISER code
> relied on having per-cpu scratch space to save/restore a register
> that can be used for the CR3 MOV.  The %GS register is used to
> index into our per-cpu space, so SWAPGS *had* to be done before

s/our/the/

> the CR3 switch.  That scratch space is gone now, but the semantic
> that SWAPGS must be done before the CR3 MOV is retained.  This is
> good to keep because it is not that hard to do and it allows us

s/us//

> to do things like add per-cpu debugging information to help us
> figure out what goes wrong sometimes.

the part after 'information' is fairy tale mode and redundant. Debugging
information says it all, right?

> What this does in the NMI code is worth pointing out.  NMIs
> can interrupt *any* context and they can also be nested with
> NMIs interrupting other NMIs.  The comments below
> ".Lnmi_from_kernel" explain the format of the stack during this
> situation.  Changing the format of this stack is not a fun
> exercise: I tried.  Instead of storing the old CR3 value on the
> stack, this patch depend on the *regular* register save/restore
> mechanism and then uses %r14 to keep CR3 during the NMI.  It is
> callee-saved and will not be clobbered by the C NMI handlers that
> get called.

  The comments below ".Lnmi_from_kernel" explain the format of the stack
  during this situation. Changing this stack format is too complex and
  risky, so the following solution has been used:

  Instead of storing the old CR3 value on the stack, depend on the regular
  register save/restore mechanism and use %r14 to hold CR3 during the
  NMI. r14 is callee-saved and will not be clobbered by the C NMI handlers
  that get called.

End of nitpicking

> +.macro SAVE_AND_SWITCH_TO_KERNEL_CR3 scratch_reg:req save_reg:req
> +	movq	%cr3, %r\scratch_reg
> +	movq	%r\scratch_reg, \save_reg
> +	/*
> +	 * Is the switch bit zero?  This means the address is
> +	 * up in real KAISER patches in a moment.

  	 * If the switch bit is zero, CR3 points at the kernel page tables
	 * already.
Hmm?

>  /*
> @@ -1189,6 +1201,7 @@ ENTRY(paranoid_exit)
>  	testl	%ebx, %ebx			/* swapgs needed? */
>  	jnz	.Lparanoid_exit_no_swapgs
>  	TRACE_IRQS_IRETQ
> +	RESTORE_CR3	%r14

You have the named macro arguments everywhere, just not here.

Other than that.

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
