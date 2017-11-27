Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 90D6E6B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 16:43:19 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id x63so36450246ioe.18
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 13:43:19 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 72si14644470itg.141.2017.11.27.13.43.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 13:43:18 -0800 (PST)
Date: Mon, 27 Nov 2017 22:43:08 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [patch V2 5/5] x86/kaiser: Add boottime disable switch
Message-ID: <20171127214308.hxzturumrucfnlpy@hirez.programming.kicks-ass.net>
References: <20171126231403.657575796@linutronix.de>
 <20171126232414.645128754@linutronix.de>
 <20171127094846.gl6zo3rftiyucvny@hirez.programming.kicks-ass.net>
 <20171127102241.oj225ycxkc7rfvft@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171127102241.oj225ycxkc7rfvft@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Mon, Nov 27, 2017 at 11:22:41AM +0100, Peter Zijlstra wrote:

> Could be a simple as this.. but I've not tested.
> 
> 
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

Seems to work:

root@ivb-ep:~# rdmsr --all 0xc0000082 | uniq
ffffffff81beb780
root@ivb-ep:~# grep ffffffff81beb780 /proc/kallsyms 
ffffffff81beb780 T entry_SYSCALL_64


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
