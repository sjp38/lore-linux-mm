Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 12EF16B0078
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 18:14:03 -0400 (EDT)
Date: Wed, 8 Jun 2011 18:12:55 -0400
From: Stephen Wilson <wilsons@start.ca>
Subject: Re: [PATCH v4 3.0-rc2-tip 7/22]  7: uprobes: mmap and fork hooks.
Message-ID: <20110608221255.GC9965@wicker.gateway.2wire.net>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <20110607125931.28590.12362.sendpatchset@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110607125931.28590.12362.sendpatchset@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>




On Tue, Jun 07, 2011 at 06:29:31PM +0530, Srikar Dronamraju wrote:
> +static void add_to_temp_list(struct vm_area_struct *vma, struct inode *inode,
> +		struct list_head *tmp_list)
> +{
> +	struct uprobe *uprobe;
> +	struct rb_node *n;
> +	unsigned long flags;
> +
> +	n = uprobes_tree.rb_node;
> +	spin_lock_irqsave(&uprobes_treelock, flags);
> +	uprobe = __find_uprobe(inode, 0, &n);

It is valid for a uprobe offset to be zero I guess, so perhaps we need
to do a put_uprobe() here when the result of __find_uprobe() is
non-null.

> +	for (; n; n = rb_next(n)) {
> +		uprobe = rb_entry(n, struct uprobe, rb_node);
> +		if (uprobe->inode != inode)
> +			break;
> +		list_add(&uprobe->pending_list, tmp_list);
> +		continue;
> +	}
> +	spin_unlock_irqrestore(&uprobes_treelock, flags);
> +}
> +
> +/*
> + * Called from dup_mmap.
> + * called with mm->mmap_sem and old_mm->mmap_sem acquired.
> + */
> +void dup_mmap_uprobe(struct mm_struct *old_mm, struct mm_struct *mm)
> +{
> +	atomic_set(&old_mm->uprobes_count,
> +			atomic_read(&mm->uprobes_count));
> +}
> +
> +/*
> + * Called from mmap_region.
> + * called with mm->mmap_sem acquired.
> + *
> + * Return -ve no if we fail to insert probes and we cannot
> + * bail-out.
> + * Return 0 otherwise. i.e :
> + *	- successful insertion of probes
> + *	- no possible probes to be inserted.
> + *	- insertion of probes failed but we can bail-out.
> + */
> +int mmap_uprobe(struct vm_area_struct *vma)
> +{
> +	struct list_head tmp_list;
> +	struct uprobe *uprobe, *u;
> +	struct mm_struct *mm;
> +	struct inode *inode;
> +	unsigned long start, pgoff;
> +	int ret = 0;
> +
> +	if (!valid_vma(vma))
> +		return ret;	/* Bail-out */
> +
> +	INIT_LIST_HEAD(&tmp_list);
> +
> +	mm = vma->vm_mm;
> +	inode = vma->vm_file->f_mapping->host;
> +	start = vma->vm_start;
> +	pgoff = vma->vm_pgoff;
> +	__iget(inode);
> +
> +	up_write(&mm->mmap_sem);
> +	mutex_lock(&uprobes_mutex);
> +	down_read(&mm->mmap_sem);
> +
> +	vma = find_vma(mm, start);
> +	/* Not the same vma */
> +	if (!vma || vma->vm_start != start ||
> +			vma->vm_pgoff != pgoff || !valid_vma(vma) ||
> +			inode->i_mapping != vma->vm_file->f_mapping)
> +		goto mmap_out;
> +
> +	add_to_temp_list(vma, inode, &tmp_list);
> +	list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
> +		loff_t vaddr;
> +
> +		list_del(&uprobe->pending_list);
> +		if (ret)
> +			continue;
> +
> +		vaddr = vma->vm_start + uprobe->offset;
> +		vaddr -= vma->vm_pgoff << PAGE_SHIFT;
> +		if (vaddr < vma->vm_start || vaddr > vma->vm_end)

Another place where the check should be "vaddr >= vma->vm_end" I think? 


Thanks,

> +			/* Not in this vma */
> +			continue;
> +		if (vaddr > TASK_SIZE)
> +			/*
> +			 * We cannot have a virtual address that is
> +			 * greater than TASK_SIZE
> +			 */
> +			continue;
> +		mm->uprobes_vaddr = (unsigned long)vaddr;
> +		ret = install_breakpoint(mm, uprobe);
> +		if (ret && (ret == -ESRCH || ret == -EEXIST))
> +			ret = 0;
> +	}
> +
> +mmap_out:
> +	mutex_unlock(&uprobes_mutex);
> +	iput(inode);
> +	up_read(&mm->mmap_sem);
> +	down_write(&mm->mmap_sem);
> +	return ret;
> +}

-- 
steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
