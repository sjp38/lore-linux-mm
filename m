Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 97E666B002D
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 12:46:48 -0400 (EDT)
Date: Fri, 21 Oct 2011 18:42:21 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 12/X] uprobes: x86: introduce abort_xol()
Message-ID: <20111021164221.GA30770@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20111015190007.GA30243@redhat.com> <20111019215139.GA16395@redhat.com> <20111019215326.GF16395@redhat.com> <20111021144207.GN11831@linux.vnet.ibm.com> <20111021162631.GB2552@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111021162631.GB2552@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

On 10/21, Ananth N Mavinakayanahalli wrote:
>
> On Fri, Oct 21, 2011 at 08:12:07PM +0530, Srikar Dronamraju wrote:
>
> > > +void abort_xol(struct pt_regs *regs)
> > > +{
> > > +	// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
> > > +	// !!! Dear Srikar and Ananth, please implement me !!!
> > > +	// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
> > > +	struct uprobe_task *utask = current->utask;
> > > +	regs->ip = utask->vaddr;
> >
> > nit:
> > Shouldnt we be setting the ip to the next instruction after this
> > instruction?
>
> No, since we should re-execute the original instruction

Yes,

> after removing
> the breakpoint.

No? we should not remove this uprobe?

> Also, wrt ip being set to the next instruction on a breakpoint hit,
> that's arch specific.

Probably yes, I am not sure. But:

> For instance, on x86, it points to the next
> instruction,

No?

	/**
	 * get_uprobe_bkpt_addr - compute address of bkpt given post-bkpt regs
	 * @regs: Reflects the saved state of the task after it has hit a breakpoint
	 * instruction.
	 * Return the address of the breakpoint instruction.
	 */
	unsigned long __weak get_uprobe_bkpt_addr(struct pt_regs *regs)
	{
		return instruction_pointer(regs) - UPROBES_BKPT_INSN_SIZE;
	}

Yes, initially regs->ip points to the next insn after int3, but
utask->vaddr == get_uprobe_bkpt_addr() == addr of int3.

Right?

> while on powerpc, the nip points to the breakpoint vaddr
> at the time of exception.

I think get_uprobe_bkpt_addr() should be consistent on every arch.
That is why (I think) it is __weak.

Anyway, abort_xol() has to be arch-specific.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
