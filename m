Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B29CD8D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 10:28:40 -0400 (EDT)
Date: Tue, 15 Mar 2011 15:28:04 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 5/20] 5: Uprobes: register/unregister
 probes.
In-Reply-To: <20110314133454.27435.81020.sendpatchset@localhost6.localdomain6>
Message-ID: <alpine.LFD.2.00.1103151439400.2787@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6> <20110314133454.27435.81020.sendpatchset@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, 14 Mar 2011, Srikar Dronamraju wrote:
> +/* Returns 0 if it can install one probe */
> +int register_uprobe(struct inode *inode, loff_t offset,
> +				struct uprobe_consumer *consumer)
> +{
> +	struct prio_tree_iter iter;
> +	struct list_head tmp_list;
> +	struct address_space *mapping;
> +	struct mm_struct *mm, *tmpmm;
> +	struct vm_area_struct *vma;
> +	struct uprobe *uprobe;
> +	int ret = -1;
> +
> +	if (!inode || !consumer || consumer->next)
> +		return -EINVAL;
> +	uprobe = uprobes_add(inode, offset);

Does uprobes_add() always succeed ?

> +	INIT_LIST_HEAD(&tmp_list);
> +	mapping = inode->i_mapping;
> +
> +	mutex_lock(&uprobes_mutex);
> +	if (uprobe->consumers) {
> +		ret = 0;
> +		goto consumers_add;
> +	}
> +
> +	spin_lock(&mapping->i_mmap_lock);
> +	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, 0, 0) {
> +		loff_t vaddr;
> +
> +		if (!atomic_inc_not_zero(&vma->vm_mm->mm_users))
> +			continue;
> +
> +		mm = vma->vm_mm;
> +		if (!valid_vma(vma)) {
> +			mmput(mm);
> +			continue;
> +		}
> +
> +		vaddr = vma->vm_start + offset;
> +		vaddr -= vma->vm_pgoff << PAGE_SHIFT;
> +		if (vaddr > ULONG_MAX) {
> +			/*
> +			 * We cannot have a virtual address that is
> +			 * greater than ULONG_MAX
> +			 */
> +			mmput(mm);
> +			continue;
> +		}
> +		mm->uprobes_vaddr = (unsigned long) vaddr;
> +		list_add(&mm->uprobes_list, &tmp_list);
> +	}
> +	spin_unlock(&mapping->i_mmap_lock);
> +
> +	if (list_empty(&tmp_list)) {
> +		ret = 0;
> +		goto consumers_add;
> +	}
> +	list_for_each_entry_safe(mm, tmpmm, &tmp_list, uprobes_list) {
> +		down_read(&mm->mmap_sem);
> +		if (!install_uprobe(mm, uprobe))
> +			ret = 0;

Installing it once is success ?

> +		list_del(&mm->uprobes_list);

Also the locking rules for mm->uprobes_list want to be
documented. They are completely non obvious.

> +		up_read(&mm->mmap_sem);
> +		mmput(mm);
> +	}
> +
> +consumers_add:
> +	add_consumer(uprobe, consumer);
> +	mutex_unlock(&uprobes_mutex);
> +	put_uprobe(uprobe);

Why do we drop the refcount here?

> +	return ret;
> +}

> +	/*
> +	 * There could be other threads that could be spinning on
> +	 * treelock; some of these threads could be interested in this
> +	 * uprobe.  Give these threads a chance to run.
> +	 */
> +	synchronize_sched();

This makes no sense at all. We are not holding treelock, we are about
to acquire it. Also what does it matter when they spin on treelock and
are interested in this uprobe. Either they find it before we remove it
or not. So why synchronize_sched()? I find the lifetime rules of
uprobe utterly confusing. Could you explain please ?

> +	spin_lock_irqsave(&treelock, flags);
> +	rb_erase(&uprobe->rb_node, &uprobes_tree);
> +	spin_unlock_irqrestore(&treelock, flags);
> +	iput(uprobe->inode);
> +
> +put_unlock:
> +	mutex_unlock(&uprobes_mutex);
> +	put_uprobe(uprobe);
> +}
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
