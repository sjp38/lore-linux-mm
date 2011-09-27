Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5A23D9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 09:04:31 -0400 (EDT)
Subject: Re: [PATCH v5 3.1.0-rc4-tip 26/26]   uprobes: queue signals while
 thread is singlestepping.
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 27 Sep 2011 15:03:46 +0200
In-Reply-To: <20110920120517.25326.57657.sendpatchset@srdronam.in.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
	 <20110920120517.25326.57657.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317128626.15383.61.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2011-09-20 at 17:35 +0530, Srikar Dronamraju wrote:
> +#ifdef CONFIG_UPROBES
> +       if (!group && t->utask && t->utask->active_uprobe)
> +               pending =3D &t->utask->delayed;
> +#endif
> +
>         /*
>          * Short-circuit ignored signals and support queuing
>          * exactly one non-rt signal, so that we can get more
> @@ -1106,6 +1111,11 @@ static int __send_signal(int sig, struct siginfo *=
info, struct task_struct *t,
>                 }
>         }
> =20
> +#ifdef CONFIG_UPROBES
> +       if (!group && t->utask && t->utask->active_uprobe)
> +               return 0;
> +#endif
> +
>  out_set:
>         signalfd_notify(t, sig);
>         sigaddset(&pending->signal, sig);
> @@ -1569,6 +1579,13 @@ int send_sigqueue(struct sigqueue *q, struct task_=
struct *t, int group)
>         }
>         q->info.si_overrun =3D 0;
> =20
> +#ifdef CONFIG_UPROBES
> +       if (!group && t->utask && t->utask->active_uprobe) {
> +               pending =3D &t->utask->delayed;
> +               list_add_tail(&q->list, &pending->list);
> +               goto out;
> +       }
> +#endif
>         signalfd_notify(t, sig);
>         pending =3D group ? &t->signal->shared_pending : &t->pending;
>         list_add_tail(&q->list, &pending->list);
> @@ -2199,7 +2216,10 @@ int get_signal_to_deliver(siginfo_t *info, struct =
k_sigaction *return_ka,
>                         spin_unlock_irq(&sighand->siglock);
>                         goto relock;
>                 }
> -
> +#ifdef CONFIG_UPROBES
> +               if (current->utask && current->utask->active_uprobe)
> +                       break;
> +#endif=20

That's just crying for something like:

#ifdef CONFIG_UPROBES
static inline bool uprobe_delay_signal(struct task_struct *p)
{
	return p->utask && p->utask->active_uprobe;
}
#else
static inline bool uprobe_delay_signal(struct task_struct *p)
{
	return false;
}
#endif

That'll instantly kill the #ifdeffery as well as describe wtf you're
actually doing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
