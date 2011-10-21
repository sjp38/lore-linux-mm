Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6F8616B002D
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 12:26:57 -0400 (EDT)
Date: Fri, 21 Oct 2011 18:22:19 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 12/X] uprobes: x86: introduce abort_xol()
Message-ID: <20111021162219.GA29753@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20111015190007.GA30243@redhat.com> <20111019215139.GA16395@redhat.com> <20111019215326.GF16395@redhat.com> <20111021144207.GN11831@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111021144207.GN11831@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

On 10/21, Srikar Dronamraju wrote:
>
> > If it is not clear, abort_xol() is needed when we should
> > re-execute the original insn (replaced with int3), see the
> > next patch.
>
> We should be removing the breakpoint in abort_xol().

Why? See also below.

> Otherwise if we just set the instruction pointer to int3 and signal a
> sigill, then the user may be confused why a breakpoint is generating
> SIGILL.

Which user?

gdb? Of course it can be confused. But it can be confused in any case.

> > +void abort_xol(struct pt_regs *regs)
> > +{
> > +	// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
> > +	// !!! Dear Srikar and Ananth, please implement me !!!
> > +	// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
> > +	struct uprobe_task *utask = current->utask;
> > +	regs->ip = utask->vaddr;
>
> nit:
> Shouldnt we be setting the ip to the next instruction after this
> instruction?

Not sure...

We should restart the same insn. Say, if the probed insn
was "*(int*)0 = 0", it should be executed again after SIGSEGV. Unless
the task was killed by this signal.

And in this case we should call uprobe_consumer()->handler() again,
we shouldn't remove "int3".

> I have applied all your patches and ran tests, the tests are all
> passing.
>
> I will fold them into my patches and send them out.

Great, thanks.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
