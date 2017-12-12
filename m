Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8ED946B0266
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 13:03:25 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id a10so16288499pgq.3
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 10:03:25 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l17si12032378pgn.160.2017.12.12.10.03.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Dec 2017 10:03:24 -0800 (PST)
Received: from mail-it0-f45.google.com (mail-it0-f45.google.com [209.85.214.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id EA31420671
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 18:03:23 +0000 (UTC)
Received: by mail-it0-f45.google.com with SMTP id b5so547195itc.3
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 10:03:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171212173334.176469949@linutronix.de>
References: <20171212173221.496222173@linutronix.de> <20171212173334.176469949@linutronix.de>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 12 Dec 2017 10:03:02 -0800
Message-ID: <CALCETrX+d+5COyWX1gDxi3gX93zFuq79UE+fhs27+ySq85j3+Q@mail.gmail.com>
Subject: Re: [patch 11/16] x86/ldt: Force access bit for CS/SS
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Dec 12, 2017 at 9:32 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> From: Peter Zijlstra <peterz@infradead.org>
>
> When mapping the LDT RO the hardware will typically generate write faults
> on first use. These faults can be trapped and the backing pages can be
> modified by the kernel.
>
> There is one exception; IRET will immediately load CS/SS and unrecoverably
> #GP. To avoid this issue access the LDT descriptors used by CS/SS before
> the IRET to userspace.
>
> For this use LAR, which is a safe operation in that it will happily consume
> an invalid LDT descriptor without traps. It gets the CPU to load the
> descriptor and observes the (preset) ACCESS bit.
>
> So far none of the obvious candidates like dosemu/wine/etc. do care about
> the ACCESS bit at all, so it should be rather safe to enforce it.
>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> ---
>  arch/x86/entry/common.c            |    8 ++++-
>  arch/x86/include/asm/desc.h        |    2 +
>  arch/x86/include/asm/mmu_context.h |   53 +++++++++++++++++++++++--------------
>  arch/x86/include/asm/thread_info.h |    4 ++
>  arch/x86/kernel/cpu/common.c       |    4 +-
>  arch/x86/kernel/ldt.c              |   30 ++++++++++++++++++++
>  arch/x86/mm/tlb.c                  |    2 -
>  arch/x86/power/cpu.c               |    2 -
>  8 files changed, 78 insertions(+), 27 deletions(-)
>
> --- a/arch/x86/entry/common.c
> +++ b/arch/x86/entry/common.c
> @@ -30,6 +30,7 @@
>  #include <asm/vdso.h>
>  #include <linux/uaccess.h>
>  #include <asm/cpufeature.h>
> +#include <asm/mmu_context.h>
>
>  #define CREATE_TRACE_POINTS
>  #include <trace/events/syscalls.h>
> @@ -130,8 +131,8 @@ static long syscall_trace_enter(struct p
>         return ret ?: regs->orig_ax;
>  }
>
> -#define EXIT_TO_USERMODE_LOOP_FLAGS                            \
> -       (_TIF_SIGPENDING | _TIF_NOTIFY_RESUME | _TIF_UPROBE |   \
> +#define EXIT_TO_USERMODE_LOOP_FLAGS                                    \
> +       (_TIF_SIGPENDING | _TIF_NOTIFY_RESUME | _TIF_UPROBE | _TIF_LDT |\
>          _TIF_NEED_RESCHED | _TIF_USER_RETURN_NOTIFY | _TIF_PATCH_PENDING)
>
>  static void exit_to_usermode_loop(struct pt_regs *regs, u32 cached_flags)
> @@ -171,6 +172,9 @@ static void exit_to_usermode_loop(struct
>                 /* Disable IRQs and retry */
>                 local_irq_disable();
>
> +               if (cached_flags & _TIF_LDT)
> +                       ldt_exit_user(regs);

Nope.  To the extent that this code actually does anything (which it
shouldn't since you already forced the access bit), it's racy against
flush_ldt() from another thread, and that race will be exploitable for
privilege escalation.  It needs to be outside the loopy part.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
