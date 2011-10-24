Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0BDA56B0033
	for <linux-mm@kvack.org>; Mon, 24 Oct 2011 11:18:22 -0400 (EDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ananth@in.ibm.com>;
	Mon, 24 Oct 2011 09:18:04 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9OFGTI4102762
	for <linux-mm@kvack.org>; Mon, 24 Oct 2011 09:16:32 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9OFGFcA014225
	for <linux-mm@kvack.org>; Mon, 24 Oct 2011 09:16:16 -0600
Date: Mon, 24 Oct 2011 20:46:14 +0530
From: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Subject: Re: [PATCH 13/X] uprobes: introduce UTASK_SSTEP_TRAPPED logic
Message-ID: <20111024151614.GA6034@in.ibm.com>
Reply-To: ananth@in.ibm.com
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20111015190007.GA30243@redhat.com> <20111019215139.GA16395@redhat.com> <20111019215344.GG16395@redhat.com> <20111022072030.GB24475@in.ibm.com> <20111024144127.GA14975@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111024144127.GA14975@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, Oct 24, 2011 at 04:41:27PM +0200, Oleg Nesterov wrote:
> On 10/22, Ananth N Mavinakayanahalli wrote:
> >
> > On Wed, Oct 19, 2011 at 11:53:44PM +0200, Oleg Nesterov wrote:
> > > Finally, add UTASK_SSTEP_TRAPPED state/code to handle the case when
> > > xol insn itself triggers the signal.
> > >
> > > In this case we should restart the original insn even if the task is
> > > already SIGKILL'ed (say, the coredump should report the correct ip).
> > > This is even more important if the task has a handler for SIGSEGV/etc,
> > > The _same_ instruction should be repeated again after return from the
> > > signal handler, and SSTEP can never finish in this case.
> >
> > Oleg,
> >
> > Not sure I understand this completely...
> 
> I hope you do not think I do ;)

I think you understand it better than you think you do :-)

> > When you say 'correct ip' you mean the original vaddr where we now have
> > a uprobe breakpoint and not the xol copy, right?
> 
> Yes,
> 
> > Coredump needs to report the correct ip, but should it also not report
> > correctly the instruction that caused the signal? Ergo, shouldn't we
> > put the original instruction back at the uprobed vaddr?
> 
> OK, now I see what you mean. I was confused by the "restore the original
> instruction before _restart_" suggestion.
> 
> Agreed! it would be nice to "hide" these int3's if we dump the core, but
> I think this is a bit off-topic. It makes sense to do this in any case,
> even if the core-dumping was triggered by another thread/insn. It makes
> sense to remove all int3's, not only at regs->ip location. But how can
> we do this? This is nontrivial.

I don't think that is a problem.. see below...

> And. Even worse. Suppose that you do "gdb probed_application". Now you
> see int3's in the disassemble output. What can we do?

In this case, nothing.

> I think we can do nothing, at least currently. This just reflects the
> fact that uprobe connects to inode, not to process/mm/etc.
> 
> What do you think?

Thinking further on this, in the normal 'running gdb on a core' case, we
won't have this problem, as the binary that we point gdb to, will be a
pristine one, without the uprobe int3s, right?

Ananth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
