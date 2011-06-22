Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 388B9900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 11:03:17 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5MEZ7NZ009965
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 10:35:07 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5MF3AdO103322
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 11:03:11 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5M933Nv010900
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 03:03:06 -0600
Date: Wed, 22 Jun 2011 20:24:24 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 14/22] 14: x86: uprobes exception
 notifier for x86.
Message-ID: <20110622145424.GG16471@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <20110607130101.28590.99984.sendpatchset@localhost6.localdomain6>
 <1308663084.26237.145.camel@twins>
 <1308663167.26237.146.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1308663167.26237.146.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

* Peter Zijlstra <peterz@infradead.org> [2011-06-21 15:32:47]:

> On Tue, 2011-06-21 at 15:31 +0200, Peter Zijlstra wrote:
> > On Tue, 2011-06-07 at 18:31 +0530, Srikar Dronamraju wrote:
> > > @@ -844,6 +845,19 @@ do_notify_resume(struct pt_regs *regs, void *unused, __u32 thread_info_flags)
> > >         if (thread_info_flags & _TIF_SIGPENDING)
> > >                 do_signal(regs);
> > >  
> > > +       if (thread_info_flags & _TIF_UPROBE) {
> > > +               clear_thread_flag(TIF_UPROBE);
> > > +#ifdef CONFIG_X86_32
> > > +               /*
> > > +                * On x86_32, do_notify_resume() gets called with
> > > +                * interrupts disabled. Hence enable interrupts if they
> > > +                * are still disabled.
> > > +                */
> > > +               local_irq_enable();
> > > +#endif
> > > +               uprobe_notify_resume(regs);
> > > +       } 
> > 
> > Would it make sense to do TIF_UPROBE before TIF_SIGPENDING? That way
> > when uprobe decides it ought to have send a signal we don't have to do
> > another loop through all this.
> 

Okay, 

> 
> Also, it might be good to unify x86_86 and i386 on the interrupt thing,
> instead of propagating this difference (unless of course there's a good
> reason they're different, but I really don't know this code well).

I am not sure if this has changed lately. So I will try removing the
local_irq_enable. 

Oleg, Roland, do you know why do_notify_resume() gets called with
interrupts disabled on i386? 

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
