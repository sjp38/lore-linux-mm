Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 83AB76B002C
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 16:04:00 -0400 (EDT)
Date: Wed, 12 Oct 2011 21:59:35 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 26/26]   uprobes: queue signals while
	thread is singlestepping.
Message-ID: <20111012195935.GA12269@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20110920120517.25326.57657.sendpatchset@srdronam.in.ibm.com> <1317128626.15383.61.camel@twins> <20110927131213.GE3685@linux.vnet.ibm.com> <20111005180139.GA5704@redhat.com> <20111006054710.GB17591@linux.vnet.ibm.com> <20111007165828.GA32319@redhat.com> <20111010122556.GB16268@linux.vnet.ibm.com> <20111010182535.GA6934@redhat.com> <20111011172603.GD16268@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111011172603.GD16268@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On 10/11, Srikar Dronamraju wrote:
>
> --- a/kernel/uprobes.c
> +++ b/kernel/uprobes.c
> @@ -1366,6 +1366,26 @@ static bool sstep_complete(struct uprobe *uprobe, struct pt_regs *regs)
>  }
>
>  /*
> + * While we are handling breakpoint / singlestep, ensure that a
> + * SIGTRAP is not delivered to the task.
> + */
> +static void __clear_trap_flag(void)
> +{
> +	sigdelset(&current->pending.signal, SIGTRAP);
> +	sigdelset(&current->signal->shared_pending.signal, SIGTRAP);
> +}
> +
> +static void clear_trap_flag(void)
> +{
> +	if (!test_and_clear_thread_flag(TIF_SIGPENDING))
> +		return;
> +
> +	spin_lock_irq(&current->sighand->siglock);
> +	__clear_trap_flag();
> +	spin_unlock_irq(&current->sighand->siglock);
> +}

And this is called before and after the step.

Confused... For what? What makes SIGTRAP special? Where does this
signal come from? If you meant do_debug() this seems impossible,
uprobe_exception_notify(DIE_DEBUG) returns NOTIFY_STOP.

I certainly missed something.

> @@ -1401,13 +1422,18 @@ void uprobe_notify_resume(struct pt_regs *regs)
>  			if (!utask)
>  				goto cleanup_ret;
>  		}
> -		/* TODO Start queueing signals. */
>  		utask->active_uprobe = u;
>  		handler_chain(u, regs);
>  		utask->state = UTASK_SSTEP;
> -		if (!pre_ssout(u, regs, probept))
> +		if (!pre_ssout(u, regs, probept)) {
> +			sigfillset(&masksigs);
> +			sigdelsetmask(&masksigs,
> +					sigmask(SIGKILL)|sigmask(SIGSTOP));
> +			current->saved_sigmask = current->blocked;
> +			set_current_blocked(&masksigs);

OK, we already discussed the problems with this approach.

> +			clear_trap_flag();

In any case unneeded, we already blocked SIGTRAP.

> @@ -1418,8 +1444,8 @@ void uprobe_notify_resume(struct pt_regs *regs)
>  			utask->state = UTASK_RUNNING;
>  			user_disable_single_step(current);
>  			xol_free_insn_slot(current);
> -
> -			/* TODO Stop queueing signals. */
> +			clear_trap_flag();

This is what I can't understand.

> +			set_restore_sigmask();

No, this is not right. If we have a pending signal, the signal handler
will run with the almost-all-blocked mask we set before.

And this is overkill anyway, you could simply do
set_current_blocked(&current->saved_sigmask).

->saved_sigmask is only used when we return from syscall, so uprobes
can (ab)use it safely.

> @@ -1433,7 +1459,7 @@ void uprobe_notify_resume(struct pt_regs *regs)
>  		put_uprobe(u);
>  		set_instruction_pointer(regs, probept);
>  	} else
> -		/*TODO Return SIGTRAP signal */
> +		send_sig(SIGTRAP, current, 0);

This change looks "offtopic" to the problems we are discussing.

Or I missed something and this is connected to the clear_trap_flag()
somehow?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
