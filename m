Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id DC70F6B002D
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 14:54:08 -0500 (EST)
Message-ID: <1322510018.2921.161.camel@twins>
Subject: Re: [PATCH 2/5] uprobes: introduce uprobe_switch_to()
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 28 Nov 2011 20:53:38 +0100
In-Reply-To: <20111128190655.GC4602@redhat.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
	 <20111128190614.GA4602@redhat.com> <20111128190655.GC4602@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

On Mon, 2011-11-28 at 20:06 +0100, Oleg Nesterov wrote:
> +void uprobe_switch_to(struct task_struct *curr)
> +{
> +       struct uprobe_task *utask =3D curr->utask;
> +       struct pt_regs *regs =3D task_pt_regs(curr);
> +
> +       if (!utask || utask->state !=3D UTASK_SSTEP)
> +               return;
> +
> +       if (!(regs->flags & X86_EFLAGS_TF))
> +               return;
> +
> +       set_xol_ip(regs);
> +}=20

> void __weak set_xol_ip(struct pt_regs *regs)
>  {
> +       int cpu =3D smp_processor_id();
> +       struct uprobe_task *utask =3D current->utask;
> +       struct uprobe *uprobe =3D utask->active_uprobe;
> +
> +       memcpy(uprobe_xol_slots[cpu], uprobe->insn, MAX_UINSN_BYTES);
> +
> +       utask->xol_vaddr =3D fix_to_virt(UPROBE_XOL_FIRST_PAGE)
> +                               + UPROBES_XOL_SLOT_BYTES * cpu;
> +       set_instruction_pointer(regs, utask->xol_vaddr);
>  }

So uprobe_switch_to() will always reset the IP to the start of the slot?
That sounds wrong, things like the RIP relative stuff needs multiple
instructions.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
