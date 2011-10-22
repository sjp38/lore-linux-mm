Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DD4E76B0031
	for <linux-mm@kvack.org>; Sat, 22 Oct 2011 03:09:50 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p9M6XD4U010782
	for <linux-mm@kvack.org>; Sat, 22 Oct 2011 02:33:13 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9M79jHX380484
	for <linux-mm@kvack.org>; Sat, 22 Oct 2011 03:09:45 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9M79iTv008285
	for <linux-mm@kvack.org>; Sat, 22 Oct 2011 05:09:45 -0200
Date: Sat, 22 Oct 2011 12:39:52 +0530
From: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Subject: Re: [PATCH 12/X] uprobes: x86: introduce abort_xol()
Message-ID: <20111022070952.GA24475@in.ibm.com>
Reply-To: ananth@in.ibm.com
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20111015190007.GA30243@redhat.com> <20111019215139.GA16395@redhat.com> <20111019215326.GF16395@redhat.com> <20111021144207.GN11831@linux.vnet.ibm.com> <20111021162631.GB2552@in.ibm.com> <20111021164221.GA30770@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111021164221.GA30770@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Oct 21, 2011 at 06:42:21PM +0200, Oleg Nesterov wrote:
> On 10/21, Ananth N Mavinakayanahalli wrote:

...

> > For instance, on x86, it points to the next
> > instruction,
> 
> No?

At exception entry, we'd not have done the following fixup...

> 	/**
> 	 * get_uprobe_bkpt_addr - compute address of bkpt given post-bkpt regs
> 	 * @regs: Reflects the saved state of the task after it has hit a breakpoint
> 	 * instruction.
> 	 * Return the address of the breakpoint instruction.
> 	 */
> 	unsigned long __weak get_uprobe_bkpt_addr(struct pt_regs *regs)
> 	{
> 		return instruction_pointer(regs) - UPROBES_BKPT_INSN_SIZE;
> 	}
> 
> Yes, initially regs->ip points to the next insn after int3, but
> utask->vaddr == get_uprobe_bkpt_addr() == addr of int3.
> 
> Right?

Yes, we fix it up so we point to the right (breakpoint) address.

> > while on powerpc, the nip points to the breakpoint vaddr
> > at the time of exception.
> 
> I think get_uprobe_bkpt_addr() should be consistent on every arch.
> That is why (I think) it is __weak.

Yes, that is the intention.

> Anyway, abort_xol() has to be arch-specific.

Agree.

Ananth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
