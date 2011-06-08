Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3D8B16B0078
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 18:11:07 -0400 (EDT)
Date: Wed, 8 Jun 2011 18:10:32 -0400
From: Stephen Wilson <wilsons@start.ca>
Subject: Re: [PATCH v4 3.0-rc2-tip 4/22]  4: Uprobes: register/unregister
 probes.
Message-ID: <20110608221032.GA9965@wicker.gateway.2wire.net>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <20110607125900.28590.16071.sendpatchset@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110607125900.28590.16071.sendpatchset@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>


Hi Srikar,

Just a few questions/comments inline below.

On Tue, Jun 07, 2011 at 06:29:00PM +0530, Srikar Dronamraju wrote:
> +int register_uprobe(struct inode *inode, loff_t offset,
> +				struct uprobe_consumer *consumer)
> +{
> +	struct prio_tree_iter iter;
> +	struct list_head try_list, success_list;
> +	struct address_space *mapping;
> +	struct mm_struct *mm, *tmpmm;
> +	struct vm_area_struct *vma;
> +	struct uprobe *uprobe;
> +	int ret = -1;
> +
> +	if (!inode || !consumer || consumer->next)
> +		return -EINVAL;
> +
> +	if (offset > inode->i_size)
> +		return -EINVAL;
> +
> +	uprobe = alloc_uprobe(inode, offset);
> +	if (!uprobe)
> +		return -ENOMEM;
> +
> +	INIT_LIST_HEAD(&try_list);
> +	INIT_LIST_HEAD(&success_list);
> +	mapping = inode->i_mapping;
> +
> +	mutex_lock(&uprobes_mutex);
> +	if (uprobe->consumers) {
> +		ret = 0;
> +		goto consumers_add;
> +	}
> +
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
> +			continue;
> +		}
> +
> +		vaddr = vma->vm_start + offset;
> +		vaddr -= vma->vm_pgoff << PAGE_SHIFT;
> +		if (vaddr < vma->vm_start || vaddr > vma->vm_end) {

This check looks like it is off by one?  vma->vm_end is already one byte
past the last valid address in the vma, so we should compare using ">="
here I think.

> +			/* Not in this vma */
> +			mmput(mm);
> +			continue;
> +		}
> +		tsk = get_mm_owner(mm);
> +		if (tsk && vaddr > TASK_SIZE_OF(tsk)) {
> +			/*
> +			 * We cannot have a virtual address that is
> +			 * greater than TASK_SIZE_OF(tsk)
> +			 */
> +			put_task_struct(tsk);
> +			mmput(mm);
> +			continue;
> +		}
> +		put_task_struct(tsk);
> +		mm->uprobes_vaddr = (unsigned long) vaddr;
> +		list_add(&mm->uprobes_list, &try_list);
> +	}
> +	mutex_unlock(&mapping->i_mmap_mutex);
> +
> +	if (list_empty(&try_list)) {
> +		ret = 0;
> +		goto consumers_add;
> +	}
> +	list_for_each_entry_safe(mm, tmpmm, &try_list, uprobes_list) {
> +		down_read(&mm->mmap_sem);
> +		ret = install_breakpoint(mm, uprobe);
> +
> +		if (ret && (ret != -ESRCH || ret != -EEXIST)) {
> +			up_read(&mm->mmap_sem);
> +			break;
> +		}
> +		if (!ret)
> +			list_move(&mm->uprobes_list, &success_list);
> +		else {
> +			/*
> +			 * install_breakpoint failed as there are no active
> +			 * threads for the mm; ignore the error.
> +			 */
> +			list_del(&mm->uprobes_list);
> +			mmput(mm);
> +		}
> +		up_read(&mm->mmap_sem);
> +	}
> +
> +	if (list_empty(&try_list)) {
> +		/*
> +		 * All install_breakpoints were successful;
> +		 * cleanup successful entries.
> +		 */
> +		ret = 0;
> +		list_for_each_entry_safe(mm, tmpmm, &success_list,
> +						uprobes_list) {
> +			list_del(&mm->uprobes_list);
> +			mmput(mm);
> +		}
> +		goto consumers_add;
> +	}
> +
> +	/*
> +	 * Atleast one unsuccessful install_breakpoint;
> +	 * remove successful probes and cleanup untried entries.
> +	 */
> +	list_for_each_entry_safe(mm, tmpmm, &success_list, uprobes_list)
> +		remove_breakpoint(mm, uprobe);
> +	list_for_each_entry_safe(mm, tmpmm, &try_list, uprobes_list) {
> +		list_del(&mm->uprobes_list);
> +		mmput(mm);
> +	}
> +	delete_uprobe(uprobe);
> +	goto put_unlock;
> +
> +consumers_add:
> +	add_consumer(uprobe, consumer);
> +
> +put_unlock:
> +	mutex_unlock(&uprobes_mutex);
> +	put_uprobe(uprobe); /* drop access ref */
> +	return ret;
> +}
> +
> +/*
> + * unregister_uprobe - unregister a already registered probe.
> + * @inode: the file in which the probe has to be removed.
> + * @offset: offset from the start of the file.
> + * @consumer: identify which probe if multiple probes are colocated.
> + */
> +void unregister_uprobe(struct inode *inode, loff_t offset,
> +				struct uprobe_consumer *consumer)
> +{
> +	struct prio_tree_iter iter;
> +	struct list_head tmp_list;
> +	struct address_space *mapping;
> +	struct mm_struct *mm, *tmpmm;
> +	struct vm_area_struct *vma;
> +	struct uprobe *uprobe;
> +
> +	if (!inode || !consumer)
> +		return;
> +
> +	uprobe = find_uprobe(inode, offset);
> +	if (!uprobe) {
> +		pr_debug("No uprobe found with inode:offset %p %lld\n",
> +				inode, offset);
> +		return;
> +	}
> +
> +	if (!del_consumer(uprobe, consumer)) {
> +		pr_debug("No uprobe found with consumer %p\n",
> +				consumer);
> +		return;
> +	}

When del_consumer() fails dont we still need to do a put_uprobe(uprobe)
to drop the extra access ref?

> +
> +	INIT_LIST_HEAD(&tmp_list);
> +
> +	mapping = inode->i_mapping;
> +
> +	mutex_lock(&uprobes_mutex);
> +	if (uprobe->consumers)
> +		goto put_unlock;
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
> +			continue;
> +		}
> +
> +		if (valid_vma(vma)) {
> +			loff_t vaddr;
> +
> +			vaddr = vma->vm_start + offset;
> +			vaddr -= vma->vm_pgoff << PAGE_SHIFT;
> +			if (vaddr < vma->vm_start || vaddr > vma->vm_end) {

Same issue with the comparison against vma->vm_end here as well. 


Thanks,

> +				/* Not in this vma */
> +				mmput(mm);
> +				continue;
> +			}
> +			tsk = get_mm_owner(mm);
> +			if (tsk && vaddr > TASK_SIZE_OF(tsk)) {
> +				/*
> +				 * We cannot have a virtual address that is
> +				 * greater than TASK_SIZE_OF(tsk)
> +				 */
> +				put_task_struct(tsk);
> +				mmput(mm);
> +				continue;
> +			}
> +			put_task_struct(tsk);
> +			mm->uprobes_vaddr = (unsigned long) vaddr;
> +			list_add(&mm->uprobes_list, &tmp_list);
> +		} else
> +			mmput(mm);
> +	}
> +	mutex_unlock(&mapping->i_mmap_mutex);
> +	list_for_each_entry_safe(mm, tmpmm, &tmp_list, uprobes_list)
> +		remove_breakpoint(mm, uprobe);
> +
> +	delete_uprobe(uprobe);
> +
> +put_unlock:
> +	mutex_unlock(&uprobes_mutex);
> +	put_uprobe(uprobe); /* drop access ref */
> +}

-- 
steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
