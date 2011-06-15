Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id EF9626B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 13:32:19 -0400 (EDT)
Date: Wed, 15 Jun 2011 19:30:07 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 4/22]  4: Uprobes: register/unregister
	probes.
Message-ID: <20110615173007.GA12652@redhat.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6> <20110607125900.28590.16071.sendpatchset@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110607125900.28590.16071.sendpatchset@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

I still didn't actually read this/next patches, but

On 06/07, Srikar Dronamraju wrote:
>
> +#ifdef CONFIG_UPROBES
> +	unsigned long uprobes_vaddr;

Srikar, I know it is very easy to blame the patches ;) But why does this
patch add mm->uprobes_vaddr ? Look, it is write-only, register/unregister
do

	mm->uprobes_vaddr = (unsigned long) vaddr;

and it is not used otherwise. It is not possible to understand its purpose
without reading the next patches. And the code above looks very strange,
the next vma can overwrite uprobes_vaddr.

If possible, please try to re-split this series. If uprobes_vaddr is used
in 6/22, then this patch should introduce this member. Note that this is
only one particular example, there are a lot more.

> +int register_uprobe(struct inode *inode, loff_t offset,
> +				struct uprobe_consumer *consumer)
> +{
> ...
> +	mutex_lock(&mapping->i_mmap_mutex);
> +	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, 0, 0) {
> +		loff_t vaddr;
> +		struct task_struct *tsk;
> +
> +		if (!atomic_inc_not_zero(&vma->vm_mm->mm_users))
> +			continue;
> +
> +		mm = vma->vm_mm;
> +		if (!valid_vma(vma)) {
> +			mmput(mm);

This looks deadlockable. If mmput()->atomic_dec_and_test() succeeds
unlink_file_vma() needs the same ->i_mmap_mutex, no?

I think you can simply remove mmput(). Why do you increment ->mm_users
in advance? I think you can do this right before list_add(), after all
valid_vma/etc checks.

> +		vaddr = vma->vm_start + offset;
> +		vaddr -= vma->vm_pgoff << PAGE_SHIFT;
> +		if (vaddr < vma->vm_start || vaddr > vma->vm_end) {
> +			/* Not in this vma */
> +			mmput(mm);
> +			continue;
> +		}

Not sure that "Not in this vma" is possible if we pass the correct pgoff
to vma_prio_tree_foreach()... but OK, I forgot everything I knew about
vma prio_tree.

So, we verified that vaddr is valid. Then,

> +		tsk = get_mm_owner(mm);
> +		if (tsk && vaddr > TASK_SIZE_OF(tsk)) {

how it it possible to map ->vm_file above TASK_SIZE ?

And why do you need get/put_task_struct? You could simply read
TASK_SIZE_OF(tsk) under rcu_read_lock.

> +void unregister_uprobe(struct inode *inode, loff_t offset,
> +				struct uprobe_consumer *consumer)
> +{
> ...
> +
> +	mutex_lock(&mapping->i_mmap_mutex);
> +	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, 0, 0) {
> +		struct task_struct *tsk;
> +
> +		if (!atomic_inc_not_zero(&vma->vm_mm->mm_users))
> +			continue;
> +
> +		mm = vma->vm_mm;
> +
> +		if (!atomic_read(&mm->uprobes_count)) {
> +			mmput(mm);

Again, mmput() doesn't look safe.

> +	list_for_each_entry_safe(mm, tmpmm, &tmp_list, uprobes_list)
> +		remove_breakpoint(mm, uprobe);

What if the application, say, unmaps the vma with bkpt before
unregister_uprobe() ? Or it can do mprotect(PROT_WRITE), then valid_vma()
fails. Probably this is fine, but mm->uprobes_count becomes wrong, no?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
