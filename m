Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 070B19000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 10:20:43 -0400 (EDT)
Subject: Re: [PATCH v5 3.1.0-rc4-tip 13/26]   x86: define a x86 specific
 exception notifier.
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 26 Sep 2011 16:19:51 +0200
In-Reply-To: <20110920120238.25326.71868.sendpatchset@srdronam.in.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
	 <20110920120238.25326.71868.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317046791.1763.26.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 2011-09-20 at 17:32 +0530, Srikar Dronamraju wrote:
> @@ -820,6 +821,19 @@ do_notify_resume(struct pt_regs *regs, void *unused,=
 __u32 thread_info_flags)
>                 mce_notify_process();
>  #endif /* CONFIG_X86_64 && CONFIG_X86_MCE */
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
> +       }
> +
>         /* deal with pending signal delivery */
>         if (thread_info_flags & _TIF_SIGPENDING)
>                 do_signal(regs);=20

It would be good to remove this difference between i386 and x86_64.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
