Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D33226B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 01:18:00 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5G56ZPX032735
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 01:06:35 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5G5Hg7Z040900
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 01:17:49 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5G5HdPG027981
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 01:17:41 -0400
Date: Thu, 16 Jun 2011 10:39:46 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 4/22]  4: Uprobes: register/unregister
 probes.
Message-ID: <20110616050946.GH4952@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <20110607125900.28590.16071.sendpatchset@localhost6.localdomain6>
 <20110615173007.GA12652@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110615173007.GA12652@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

> >
> > +#ifdef CONFIG_UPROBES
> > +	unsigned long uprobes_vaddr;
> 
> Srikar, I know it is very easy to blame the patches ;) But why does this
> patch add mm->uprobes_vaddr ? Look, it is write-only, register/unregister
> do
> 
> 	mm->uprobes_vaddr = (unsigned long) vaddr;
> 
> and it is not used otherwise. It is not possible to understand its purpose

mm->uprobes_vaddr is used in helper routines insert(remove)_breakpoint
routines which are just stubs here. mm->uprobes_vaddr caches the vaddr
for subsequent use in insert_breakpoint.

I could have moved the mm->uprobes_vaddr to the 6th patch that
implemented the insert_breakpoint routine.  However at that time I felt
that people would comment back saying we do all the checks and get the
correct vaddr, but we dont cache it for subsequent use.

I will move adding the uprobes_vaddr initialization to the next patch.
Infact I might remove mm->uprobes_vaddr in the subsequent posting.

In one of the previous postings, I had the patches that used the helper
routines (like insert_breakpoint) first and then patches for wrapper
routines (like register/unregister) followed in the next patch. I was
told that it was tough to understand the context in which these helper
routines would be called. So I moved to having the wrapper routines with
stubs and implementing the stubs later.
 

> without reading the next patches. And the code above looks very strange,
> the next vma can overwrite uprobes_vaddr.

For this posting, handling two vmas for the same inode in the same mm
was a TODO. Since you and Peter have raised this I will handle it in the next posting. I will give a brief description of how I plan to implement this in my response to Peter's comments. Please do review and comment to it.

> 
> If possible, please try to re-split this series. If uprobes_vaddr is used
> in 6/22, then this patch should introduce this member. Note that this is
> only one particular example, there are a lot more.
> 
> > +int register_uprobe(struct inode *inode, loff_t offset,
> > +				struct uprobe_consumer *consumer)
> > +{
> > ...
> > +	mutex_lock(&mapping->i_mmap_mutex);
> > +	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, 0, 0) {
> > +		loff_t vaddr;
> > +		struct task_struct *tsk;
> > +
> > +		if (!atomic_inc_not_zero(&vma->vm_mm->mm_users))
> > +			continue;
> > +
> > +		mm = vma->vm_mm;
> > +		if (!valid_vma(vma)) {
> > +			mmput(mm);
> 
> This looks deadlockable. If mmput()->atomic_dec_and_test() succeeds
> unlink_file_vma() needs the same ->i_mmap_mutex, no?


okay, 

> 
> I think you can simply remove mmput(). Why do you increment ->mm_users
> in advance? I think you can do this right before list_add(), after all
> valid_vma/etc checks.

Okay, will modify as suggested.

> 
> > +		vaddr = vma->vm_start + offset;
> > +		vaddr -= vma->vm_pgoff << PAGE_SHIFT;
> > +		if (vaddr < vma->vm_start || vaddr > vma->vm_end) {
> > +			/* Not in this vma */
> > +			mmput(mm);
> > +			continue;
> > +		}
> 

> Not sure that "Not in this vma" is possible if we pass the correct pgoff
> to vma_prio_tree_foreach()... but OK, I forgot everything I knew about
> vma prio_tree.
> 

I was asked what if the arithmetic to arrive at vaddr would end up not
being in the range.

> So, we verified that vaddr is valid. Then,
> 
> > +		tsk = get_mm_owner(mm);
> > +		if (tsk && vaddr > TASK_SIZE_OF(tsk)) {
> 
> how it it possible to map ->vm_file above TASK_SIZE ?

Same as above. I will do a rethink on both of these checks.

> 
> And why do you need get/put_task_struct? You could simply read
> TASK_SIZE_OF(tsk) under rcu_read_lock.

Yes, for register/unregister case I could have just done the check under
rcu_read_lock instead of doing a get/put_task_struct. Since I needed
get_mm_owner() for insert/remove_breakpoint, I thought I will reuse it
here. 

> 
> > +void unregister_uprobe(struct inode *inode, loff_t offset,
> > +				struct uprobe_consumer *consumer)
> > +{
> > ...
> > +
> > +	mutex_lock(&mapping->i_mmap_mutex);
> > +	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, 0, 0) {
> > +		struct task_struct *tsk;
> > +
> > +		if (!atomic_inc_not_zero(&vma->vm_mm->mm_users))
> > +			continue;
> > +
> > +		mm = vma->vm_mm;
> > +
> > +		if (!atomic_read(&mm->uprobes_count)) {
> > +			mmput(mm);
> 
> Again, mmput() doesn't look safe.


Okay, I will increment the mm_users while adding to the list.

> 
> > +	list_for_each_entry_safe(mm, tmpmm, &tmp_list, uprobes_list)
> > +		remove_breakpoint(mm, uprobe);
> 
> What if the application, say, unmaps the vma with bkpt before
> unregister_uprobe() ? Or it can do mprotect(PROT_WRITE), then valid_vma()
> fails. Probably this is fine, but mm->uprobes_count becomes wrong, no?

Okay, will add a hook in unmap to keep the mm->uprobes_count sane.

> 
> Oleg.
> 

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
