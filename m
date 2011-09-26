Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C13DC9000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 12:16:04 -0400 (EDT)
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 26 Sep 2011 12:09:23 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8QG83CH227280
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 12:08:03 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8QG7xV3011776
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 10:08:00 -0600
Date: Mon, 26 Sep 2011 21:22:52 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 13/26] x86: define a x86 specific
 exception notifier.
Message-ID: <20110926155252.GA8087@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920120238.25326.71868.sendpatchset@srdronam.in.ibm.com>
 <1317046791.1763.26.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1317046791.1763.26.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

* Peter Zijlstra <peterz@infradead.org> [2011-09-26 16:19:51]:

> On Tue, 2011-09-20 at 17:32 +0530, Srikar Dronamraju wrote:
> > @@ -820,6 +821,19 @@ do_notify_resume(struct pt_regs *regs, void *unused, __u32 thread_info_flags)
> >                 mce_notify_process();
> >  #endif /* CONFIG_X86_64 && CONFIG_X86_MCE */
> >  
> > +       if (thread_info_flags & _TIF_UPROBE) {
> > +               clear_thread_flag(TIF_UPROBE);
> > +#ifdef CONFIG_X86_32
> > +               /*
> > +                * On x86_32, do_notify_resume() gets called with
> > +                * interrupts disabled. Hence enable interrupts if they
> > +                * are still disabled.
> > +                */
> > +               local_irq_enable();
> > +#endif
> > +               uprobe_notify_resume(regs);
> > +       }
> > +
> >         /* deal with pending signal delivery */
> >         if (thread_info_flags & _TIF_SIGPENDING)
> >                 do_signal(regs); 
> 
> It would be good to remove this difference between i386 and x86_64.


I think, we have already discussed this. I tried getting to know why we
have this difference in behaviour. However I havent been able to find
the answer.

If you can get somebody to answer this, I would be happy to modify as
required.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
