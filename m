Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7620B6B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 12:24:10 -0500 (EST)
Date: Tue, 29 Nov 2011 18:18:22 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 2/5] uprobes: introduce uprobe_switch_to()
Message-ID: <20111129171822.GA28234@redhat.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com> <20111128190614.GA4602@redhat.com> <20111128190655.GC4602@redhat.com> <1322510018.2921.161.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1322510018.2921.161.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

On 11/28, Peter Zijlstra wrote:
>
> On Mon, 2011-11-28 at 20:06 +0100, Oleg Nesterov wrote:
> > +void uprobe_switch_to(struct task_struct *curr)
> > +{
> > +       struct uprobe_task *utask = curr->utask;
> > +       struct pt_regs *regs = task_pt_regs(curr);
> > +
> > +       if (!utask || utask->state != UTASK_SSTEP)
> > +               return;
> > +
> > +       if (!(regs->flags & X86_EFLAGS_TF))
> > +               return;
> > +
> > +       set_xol_ip(regs);
> > +}
>
> > void __weak set_xol_ip(struct pt_regs *regs)
> >  {
> > +       int cpu = smp_processor_id();
> > +       struct uprobe_task *utask = current->utask;
> > +       struct uprobe *uprobe = utask->active_uprobe;
> > +
> > +       memcpy(uprobe_xol_slots[cpu], uprobe->insn, MAX_UINSN_BYTES);
> > +
> > +       utask->xol_vaddr = fix_to_virt(UPROBE_XOL_FIRST_PAGE)
> > +                               + UPROBES_XOL_SLOT_BYTES * cpu;
> > +       set_instruction_pointer(regs, utask->xol_vaddr);
> >  }
>
> So uprobe_switch_to() will always reset the IP to the start of the slot?
> That sounds wrong, things like the RIP relative stuff needs multiple
> instructions.

Hmm. Could you explain? Especially the "multiple instructions" part.

In any case we should reset the IP to the start of the slot.

But yes, I'm afraid this is too simple. Before this patches pre_xol()
is called when we already know ->xol_vaddr. But afaics x86 doesn't use
this info (post_xol() does). So this looks equally correct or wrong.

But perhaps we need another arch-dependent hook which takes ->xol_vaddr
into account instead of simple memcpy(), to handle the RIP relative
case.

Or I misunderstood?


Peter, all, I apologize in advance, I can't be responsive today.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
