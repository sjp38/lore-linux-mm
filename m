Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7A1386B004D
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 07:12:27 -0500 (EST)
Message-ID: <1322655112.2921.267.camel@twins>
Subject: Re: [PATCH 2/5] uprobes: introduce uprobe_switch_to()
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 30 Nov 2011 13:11:52 +0100
In-Reply-To: <20111129171822.GA28234@redhat.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
	 <20111128190614.GA4602@redhat.com> <20111128190655.GC4602@redhat.com>
	 <1322510018.2921.161.camel@twins> <20111129171822.GA28234@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

On Tue, 2011-11-29 at 18:18 +0100, Oleg Nesterov wrote:
> On 11/28, Peter Zijlstra wrote:
> >
> > On Mon, 2011-11-28 at 20:06 +0100, Oleg Nesterov wrote:
> > > +void uprobe_switch_to(struct task_struct *curr)
> > > +{
> > > +       struct uprobe_task *utask =3D curr->utask;
> > > +       struct pt_regs *regs =3D task_pt_regs(curr);
> > > +
> > > +       if (!utask || utask->state !=3D UTASK_SSTEP)
> > > +               return;
> > > +
> > > +       if (!(regs->flags & X86_EFLAGS_TF))
> > > +               return;
> > > +
> > > +       set_xol_ip(regs);
> > > +}
> >
> > > void __weak set_xol_ip(struct pt_regs *regs)
> > >  {
> > > +       int cpu =3D smp_processor_id();
> > > +       struct uprobe_task *utask =3D current->utask;
> > > +       struct uprobe *uprobe =3D utask->active_uprobe;
> > > +
> > > +       memcpy(uprobe_xol_slots[cpu], uprobe->insn, MAX_UINSN_BYTES);
> > > +
> > > +       utask->xol_vaddr =3D fix_to_virt(UPROBE_XOL_FIRST_PAGE)
> > > +                               + UPROBES_XOL_SLOT_BYTES * cpu;
> > > +       set_instruction_pointer(regs, utask->xol_vaddr);
> > >  }
> >
> > So uprobe_switch_to() will always reset the IP to the start of the slot=
?
> > That sounds wrong, things like the RIP relative stuff needs multiple
> > instructions.
>=20
> Hmm. Could you explain? Especially the "multiple instructions" part.
>=20
> In any case we should reset the IP to the start of the slot.
>=20
> But yes, I'm afraid this is too simple. Before this patches pre_xol()
> is called when we already know ->xol_vaddr. But afaics x86 doesn't use
> this info (post_xol() does). So this looks equally correct or wrong.
>=20
> But perhaps we need another arch-dependent hook which takes ->xol_vaddr
> into account instead of simple memcpy(), to handle the RIP relative
> case.
>=20
> Or I misunderstood?

Suppose you need multiple instructions to replace the one you patched
out, for example because the instruction was RIP relative (the effect
relied on the IP the instruction is at, eg. short jumps instead of
absolute jumps).

One way to translate these instructions is something like

  push eax
  mov eax, $previous_ip
  $ins eax+offset
  pop eax

Also, the thing Srikar mentioned is boosted probes, in that case you
forgo the whole single step thing and rewrite the probe as:

  $ins
  jmp $next_insn

Now in the former case you still single step so the context switch hook
can function as proposed (triggered off of TIF_SINGLESTEP). However if
you get preempted after the mov you want to continue with the $ins, not
restart at push. So uprobe_switch_to() will have to preserve the
relative offset within the slot.

On the second example there's no singlestepping left, so we need to
create a new TIF flag, when you first set up the probe you toggle that
flag and on the first context switch where the IP is outside of the slot
you clear it. But still you need to maintain relative offset within the
slot when you move it around.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
