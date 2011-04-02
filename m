Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 01E618D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 20:27:24 -0400 (EDT)
Date: Fri, 1 Apr 2011 20:26:33 -0400
From: Stephen Wilson <wilsons@start.ca>
Subject: Re: [PATCH v3 2.6.39-rc1-tip 6/26]  6: Uprobes:
	register/unregister probes.
Message-ID: <20110402002633.GA13277@fibrous.localdomain>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6> <20110401143338.15455.98645.sendpatchset@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110401143338.15455.98645.sendpatchset@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Apr 01, 2011 at 08:03:38PM +0530, Srikar Dronamraju wrote:
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
> +	uprobe = uprobes_add(inode, offset);
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

What happens here when someone passes an offset that is out of bounds
for the vma?  Looks like we could oops when the kernel tries to set a
breakpoint.  Perhaps check wrt ->vm_end?

-- 
steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
