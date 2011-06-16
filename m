Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A288D6B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 07:53:04 -0400 (EDT)
Subject: Re: [PATCH v4 3.0-rc2-tip 13/22] 13: uprobes: Handing int3 and
 singlestep exception.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110607130051.28590.68088.sendpatchset@localhost6.localdomain6>
References: 
	 <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
	 <20110607130051.28590.68088.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 16 Jun 2011 13:52:21 +0200
Message-ID: <1308225141.13240.25.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 2011-06-07 at 18:30 +0530, Srikar Dronamraju wrote:
> +void uprobe_notify_resume(struct pt_regs *regs)
> +{
> +       struct vm_area_struct *vma;
> +       struct uprobe_task *utask;
> +       struct mm_struct *mm;
> +       struct uprobe *u =3D NULL;
> +       unsigned long probept;
> +
> +       utask =3D current->utask;
> +       mm =3D current->mm;
> +       if (!utask || utask->state =3D=3D UTASK_BP_HIT) {
> +               probept =3D get_uprobe_bkpt_addr(regs);
> +               down_read(&mm->mmap_sem);
> +               vma =3D find_vma(mm, probept);
> +               if (vma && valid_vma(vma))
> +                       u =3D find_uprobe(vma->vm_file->f_mapping->host,
> +                                       probept - vma->vm_start +
> +                                       (vma->vm_pgoff << PAGE_SHIFT));
> +               up_read(&mm->mmap_sem);
> +               if (!u)
> +                       goto cleanup_ret;
> +               if (!utask) {
> +                       utask =3D add_utask();
> +                       if (!utask)
> +                               goto cleanup_ret;

So if we fail to allocate task state,..

> +               }
> +               /* TODO Start queueing signals. */
> +               utask->active_uprobe =3D u;
> +               handler_chain(u, regs);
> +               utask->state =3D UTASK_SSTEP;
> +               if (!pre_ssout(u, regs, probept))
> +                       user_enable_single_step(current);
> +               else
> +                       goto cleanup_ret;
> +       } else if (utask->state =3D=3D UTASK_SSTEP) {
> +               u =3D utask->active_uprobe;
> +               if (sstep_complete(u, regs)) {
> +                       put_uprobe(u);
> +                       utask->active_uprobe =3D NULL;
> +                       utask->state =3D UTASK_RUNNING;
> +                       user_disable_single_step(current);
> +                       xol_free_insn_slot(current);
> +
> +                       /* TODO Stop queueing signals. */
> +               }
> +       }
> +       return;
> +
> +cleanup_ret:
> +       if (u) {
> +               down_read(&mm->mmap_sem);
> +               if (!set_orig_insn(current, u, probept, true))

we try to undo the probe? That doesn't make any sense. I thought you
meant to return to userspace, let it re-take the trap and try again
until you do manage to allocate the user resource.

This behaviour makes probes totally unreliable under memory pressure.=20

> +                       atomic_dec(&mm->uprobes_count);
> +               up_read(&mm->mmap_sem);
> +               put_uprobe(u);
> +       } else {
> +       /*TODO Return SIGTRAP signal */
> +       }
> +       if (utask) {
> +               utask->active_uprobe =3D NULL;
> +               utask->state =3D UTASK_RUNNING;
> +       }
> +       set_instruction_pointer(regs, probept);
> +}=20

Also, there's a scary amount of TODO in there...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
