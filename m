Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0A7546B002D
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 14:32:55 -0400 (EDT)
Date: Fri, 7 Oct 2011 20:28:34 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 12/26]   Uprobes: Handle breakpoint
	and Singlestep
Message-ID: <20111007182834.GA1655@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20110920120221.25326.74714.sendpatchset@srdronam.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110920120221.25326.74714.sendpatchset@srdronam.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On 09/20, Srikar Dronamraju wrote:
>
> @@ -1285,6 +1286,9 @@ static struct task_struct *copy_process(unsigned long clone_flags,
>  	INIT_LIST_HEAD(&p->pi_state_list);
>  	p->pi_state_cache = NULL;
>  #endif
> +#ifdef CONFIG_UPROBES
> +	p->utask = NULL;
> +#endif

I am not sure I understand this all right, but I am not sure this
is enough...

What if the forking task (current) is in UTASK_BP_HIT state?

IOW, uprobe replaces the original syscall insn with "int3", then we
enter the kernel from the xol_vma. The new child has the same
modified instruction pointer (pointing to nowhere without CLONE_VM)
and in any case it doesn't have TIF_SINGLESTEP.

No?

> +void uprobe_notify_resume(struct pt_regs *regs)
> +{
> +	struct vm_area_struct *vma;
> +	struct uprobe_task *utask;
> +	struct mm_struct *mm;
> +	struct uprobe *u = NULL;
> +	unsigned long probept;
> +
> +	utask = current->utask;
> +	mm = current->mm;
> +	if (!utask || utask->state == UTASK_BP_HIT) {
> +		probept = get_uprobe_bkpt_addr(regs);
> +		down_read(&mm->mmap_sem);
> +		vma = find_vma(mm, probept);
> +		if (vma && valid_vma(vma))
> +			u = find_uprobe(vma->vm_file->f_mapping->host,
> +					probept - vma->vm_start +
> +					(vma->vm_pgoff << PAGE_SHIFT));
> +		up_read(&mm->mmap_sem);
> +		if (!u)
> +			/* No matching uprobe; signal SIGTRAP. */
> +			goto cleanup_ret;
> +		if (!utask) {
> +			utask = add_utask();
> +			/* Cannot Allocate; re-execute the instruction. */
> +			if (!utask)
> +				goto cleanup_ret;
> +		}
> +		/* TODO Start queueing signals. */
> +		utask->active_uprobe = u;
> +		handler_chain(u, regs);
> +		utask->state = UTASK_SSTEP;
> +		if (!pre_ssout(u, regs, probept))
> +			user_enable_single_step(current);

Oooh. Playing with user_*_single_step() is obviously not very nice...
But I guess you have no choice. Although I _hope_ we can do something
else later.

And what if we step into a syscall insn? I do not understand this
low level code, but it seems that in this case we trap in kernel mode
and do_debug() doesn't clear X86_EFLAGS_TF because uprobes hook
DIE_DEBUG. IOW, the task will trap again and again inside this syscall,
no?

> +	} else if (utask->state == UTASK_SSTEP) {
> +		u = utask->active_uprobe;
> +		if (sstep_complete(u, regs)) {

It is not clear to me if it is correct to simply return if
sstep_complete() returns false... What if X86_EFLAGS_TF was "lost"
somehow?


Again, I am not saying I understand this magic. Not at all ;)
Please simply ignore my email if you think everything is fine.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
