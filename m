Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E31ED9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 09:27:43 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8RDRckN017001
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 07:27:38 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8RDRamS169116
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 07:27:36 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8RDRYZR015863
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 07:27:36 -0600
Date: Tue, 27 Sep 2011 18:42:13 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 26/26]   uprobes: queue signals while
 thread is singlestepping.
Message-ID: <20110927131213.GE3685@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920120517.25326.57657.sendpatchset@srdronam.in.ibm.com>
 <1317128626.15383.61.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1317128626.15383.61.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

* Peter Zijlstra <peterz@infradead.org> [2011-09-27 15:03:46]:

> On Tue, 2011-09-20 at 17:35 +0530, Srikar Dronamraju wrote:
> > +#ifdef CONFIG_UPROBES
> > +       if (!group && t->utask && t->utask->active_uprobe)
> > +               pending = &t->utask->delayed;
> > +#endif
> > +
> >         /*
> >          * Short-circuit ignored signals and support queuing
> >          * exactly one non-rt signal, so that we can get more
> > @@ -1106,6 +1111,11 @@ static int __send_signal(int sig, struct siginfo *info, struct task_struct *t,
> >                 }
> >         }
> >  
> > +#ifdef CONFIG_UPROBES
> > +       if (!group && t->utask && t->utask->active_uprobe)
> > +               return 0;
> > +#endif
> > +
> >  out_set:
> >         signalfd_notify(t, sig);
> >         sigaddset(&pending->signal, sig);
> > @@ -1569,6 +1579,13 @@ int send_sigqueue(struct sigqueue *q, struct task_struct *t, int group)
> >         }
> >         q->info.si_overrun = 0;
> >  
> > +#ifdef CONFIG_UPROBES
> > +       if (!group && t->utask && t->utask->active_uprobe) {
> > +               pending = &t->utask->delayed;
> > +               list_add_tail(&q->list, &pending->list);
> > +               goto out;
> > +       }
> > +#endif
> >         signalfd_notify(t, sig);
> >         pending = group ? &t->signal->shared_pending : &t->pending;
> >         list_add_tail(&q->list, &pending->list);
> > @@ -2199,7 +2216,10 @@ int get_signal_to_deliver(siginfo_t *info, struct k_sigaction *return_ka,
> >                         spin_unlock_irq(&sighand->siglock);
> >                         goto relock;
> >                 }
> > -
> > +#ifdef CONFIG_UPROBES
> > +               if (current->utask && current->utask->active_uprobe)
> > +                       break;
> > +#endif 
> 
> That's just crying for something like:
> 
> #ifdef CONFIG_UPROBES
> static inline bool uprobe_delay_signal(struct task_struct *p)
> {
> 	return p->utask && p->utask->active_uprobe;
> }
> #else
> static inline bool uprobe_delay_signal(struct task_struct *p)
> {
> 	return false;
> }
> #endif
> 
> That'll instantly kill the #ifdeffery as well as describe wtf you're
> actually doing.


Okay, 

I did a rethink and implemented this patch a little differently using
block_all_signals, unblock_all_signals. This wouldnt need the 
#ifdeffery + no changes in kernel/signal.c

Will post the same in the next patchset.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
