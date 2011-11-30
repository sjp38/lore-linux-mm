Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 524316B0047
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 12:16:01 -0500 (EST)
Date: Wed, 30 Nov 2011 18:10:29 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 2/5] uprobes: introduce uprobe_switch_to()
Message-ID: <20111130171029.GA3742@redhat.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com> <20111128190614.GA4602@redhat.com> <20111128190655.GC4602@redhat.com> <1322510018.2921.161.camel@twins> <20111129171822.GA28234@redhat.com> <1322655112.2921.267.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1322655112.2921.267.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

On 11/30, Peter Zijlstra wrote:
>
> On Tue, 2011-11-29 at 18:18 +0100, Oleg Nesterov wrote:
> > On 11/28, Peter Zijlstra wrote:
> > >
> > > So uprobe_switch_to() will always reset the IP to the start of the slot?
> > > That sounds wrong, things like the RIP relative stuff needs multiple
> > > instructions.
> >
> > Hmm. Could you explain? Especially the "multiple instructions" part.
> >
> > In any case we should reset the IP to the start of the slot.
> >
> > But yes, I'm afraid this is too simple. Before this patches pre_xol()
> > is called when we already know ->xol_vaddr. But afaics x86 doesn't use
> > this info (post_xol() does). So this looks equally correct or wrong.
> >
> > But perhaps we need another arch-dependent hook which takes ->xol_vaddr
> > into account instead of simple memcpy(), to handle the RIP relative
> > case.
> >
> > Or I misunderstood?
>
> Suppose you need multiple instructions to replace the one you patched
> out,

Ah, I see, thanks...

Yes, in this case set_xol_ip() should add the offset,
regs->ip % UPROBES_XOL_SLOT_BYTES.

But the current code doesn't use multiple instructions and it relies
on the single-stepping, so I think currently this is correct.

> for example because the instruction was RIP relative (the effect
> relied on the IP the instruction is at, eg. short jumps instead of
> absolute jumps).
>
> One way to translate these instructions is something like
>
>   push eax
>   mov eax, $previous_ip
>   $ins eax+offset
>   pop eax

I can be easily wrong, but afaics this particular case is covered by
pre_xol/post_xol. But I guess this doesn't matter.

Yes, I thought about multiple insns in xol slot too.

> Also, the thing Srikar mentioned is boosted probes, in that case you
> forgo the whole single step thing and rewrite the probe as:
>
>   $ins
>   jmp $next_insn

Yes! it would be nice to avoid the stepping if possible. But so far
I am not sure how/when this can work...

> Now in the former case you still single step so the context switch hook
> can function as proposed (triggered off of TIF_SINGLESTEP). However if
> you get preempted after the mov you want to continue with the $ins, not
> restart at push.

This is not clear to me. Single step with multiple insns?

> So uprobe_switch_to() will have to preserve the
> relative offset within the slot.

Yes, agreed.

> On the second example there's no singlestepping left, so we need to
> create a new TIF flag, when you first set up the probe you toggle that
> flag and on the first context switch where the IP is outside of the slot
> you clear it. But still you need to maintain relative offset within the
> slot when you move it around.

Yes. Currently uprobe_switch_to() checks X86_EFLAGS_TF() to verify that
it is correct to change regs->ip. But if we know that, say, this insn
can't jump/call/rep we can simply check regs->ip. And in this case we
can avoid the stepping.

Thanks,

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
