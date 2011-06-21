Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D298790013A
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 09:32:15 -0400 (EDT)
Subject: Re: [PATCH v4 3.0-rc2-tip 14/22] 14: x86: uprobes exception
 notifier for x86.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110607130101.28590.99984.sendpatchset@localhost6.localdomain6>
References: 
	 <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
	 <20110607130101.28590.99984.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 21 Jun 2011 15:31:24 +0200
Message-ID: <1308663084.26237.145.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2011-06-07 at 18:31 +0530, Srikar Dronamraju wrote:
> @@ -844,6 +845,19 @@ do_notify_resume(struct pt_regs *regs, void *unused,=
 __u32 thread_info_flags)
>         if (thread_info_flags & _TIF_SIGPENDING)
>                 do_signal(regs);
> =20
> +       if (thread_info_flags & _TIF_UPROBE) {
> +               clear_thread_flag(TIF_UPROBE);
> +#ifdef CONFIG_X86_32
> +               /*
> +                * On x86_32, do_notify_resume() gets called with
> +                * interrupts disabled. Hence enable interrupts if they
> +                * are still disabled.
> +                */
> +               local_irq_enable();
> +#endif
> +               uprobe_notify_resume(regs);
> +       }=20

Would it make sense to do TIF_UPROBE before TIF_SIGPENDING? That way
when uprobe decides it ought to have send a signal we don't have to do
another loop through all this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
