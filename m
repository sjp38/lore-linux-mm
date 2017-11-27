Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5CF316B0069
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 06:51:13 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id u98so13338278wrb.17
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 03:51:13 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id t194si11530972wmt.213.2017.11.27.03.51.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 03:51:12 -0800 (PST)
Date: Mon, 27 Nov 2017 12:50:45 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch V2 5/5] x86/kaiser: Add boottime disable switch
In-Reply-To: <20171127102241.oj225ycxkc7rfvft@hirez.programming.kicks-ass.net>
Message-ID: <alpine.DEB.2.20.1711271250001.1799@nanos>
References: <20171126231403.657575796@linutronix.de> <20171126232414.645128754@linutronix.de> <20171127094846.gl6zo3rftiyucvny@hirez.programming.kicks-ass.net> <20171127102241.oj225ycxkc7rfvft@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Mon, 27 Nov 2017, Peter Zijlstra wrote:
> On Mon, Nov 27, 2017 at 10:48:46AM +0100, Peter Zijlstra wrote:
> > On Mon, Nov 27, 2017 at 12:14:08AM +0100, Thomas Gleixner wrote:
> > > KAISER comes with overhead. The most expensive part is the CR3 switching in
> > > the entry code.
> > > 
> > > Add a command line parameter which allows to disable KAISER at boot time.
> > > 
> > > Most code pathes simply check a variable, but the entry code uses a static
> > > branch. The other code pathes cannot use a static branch because they are
> > > used before jump label patching is possible. Not an issue as the code
> > > pathes are not so performance sensitive as the entry/exit code.
> > > 
> > > This makes KAISER depend on JUMP_LABEL and on a GCC which supports
> > > it, but that's a resonable requirement.
> > > 
> > > The PGD allocation is still 8k when CONFIG_KAISER is enabled. This can be
> > > addressed on top of this.
> > 
> > So in patch 15 Andy notes that we should probably also disable the
> > SYSCALL trampoline when we disable KAISER.
> > 
> >   https://lkml.kernel.org/r/20171124172411.19476-16-mingo@kernel.org
> 
> Could be a simple as this.. but I've not tested.

That's only one part of it. I think we need to fiddle with the exit side as
well.

Thanks,

	tglx

> diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
> index f4f4ab8525bd..1be393a97421 100644
> --- a/arch/x86/kernel/cpu/common.c
> +++ b/arch/x86/kernel/cpu/common.c
> @@ -1442,7 +1442,10 @@ void syscall_init(void)
>  		(entry_SYSCALL_64_trampoline - _entry_trampoline);
>  
>  	wrmsr(MSR_STAR, 0, (__USER32_CS << 16) | __KERNEL_CS);
> -	wrmsrl(MSR_LSTAR, SYSCALL64_entry_trampoline);
> +	if (kaiser_enabled)
> +		wrmsrl(MSR_LSTAR, SYSCALL64_entry_trampoline);
> +	else
> +		wrmsrl(MSR_LSTAR, (unsigned long)entry_SYSCALL_64);
>  
>  #ifdef CONFIG_IA32_EMULATION
>  	wrmsrl(MSR_CSTAR, (unsigned long)entry_SYSCALL_compat);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
