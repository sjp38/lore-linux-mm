Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9D3F76B0263
	for <linux-mm@kvack.org>; Thu,  6 Oct 2011 07:23:08 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p96B1mox005721
	for <linux-mm@kvack.org>; Thu, 6 Oct 2011 05:01:48 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p96BN2rS122448
	for <linux-mm@kvack.org>; Thu, 6 Oct 2011 05:23:02 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p96BMxIP000812
	for <linux-mm@kvack.org>; Thu, 6 Oct 2011 05:23:02 -0600
Date: Thu, 6 Oct 2011 16:35:31 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 4/26]   uprobes: Define hooks for
 mmap/munmap.
Message-ID: <20111006110531.GE17591@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920120040.25326.63549.sendpatchset@srdronam.in.ibm.com>
 <20111003133710.GA28118@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20111003133710.GA28118@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

* Oleg Nesterov <oleg@redhat.com> [2011-10-03 15:37:10]:

> On 09/20, Srikar Dronamraju wrote:
> >
> > @@ -739,6 +740,10 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
> >  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> >  	mm->pmd_huge_pte = NULL;
> >  #endif
> > +#ifdef CONFIG_UPROBES
> > +	atomic_set(&mm->mm_uprobes_count,
> > +			atomic_read(&oldmm->mm_uprobes_count));
> 
> Hmm. Why this can't race with install_breakpoint/remove_breakpoint
> between _read and _set ?

At this time the child vmas are not yet created, so I dont see a 
install_breakpoints/remove_breakpoints from child affecting.

However if install_breakpoints/remove_breakpoints happen from a parent
context, from now on till we do a vma_prio_tree_add (actually down_write(oldmm->mmap_sem) in dup_mmap()),  then the count in the child may not be the right one. If you are pointing to this race, then its probably bigger than just between read and set.

or are you talking of some other issue?

> 
> What about VM_DONTCOPY vma's with breakpoints ?

Ah... I have missed this.

One solution could be to call mmap_uprobe() like routine just before we
release the mmap_sem of the child but after we do a vma_prio_tree_add.

This should also solve the problem of install_breakpoints/remove
breakpoints called in parent context that we talked about above.

> 
> > -static int match_uprobe(struct uprobe *l, struct uprobe *r)
> > +static int match_uprobe(struct uprobe *l, struct uprobe *r, int *match_inode)
> >  {
> > +	/*
> > +	 * if match_inode is non NULL then indicate if the
> > +	 * inode atleast match.
> > +	 */
> > +	if (match_inode)
> > +		*match_inode = 0;
> > +
> >  	if (l->inode < r->inode)
> >  		return -1;
> >  	if (l->inode > r->inode)
> >  		return 1;
> >  	else {
> > +		if (match_inode)
> > +			*match_inode = 1;
> > +
> 
> It is very possible I missed something, but imho this looks confusing.
> 
> This close_match logic is only needed for build_probe_list() and
> dec_mm_uprobes_count(), and both do not actually need the returned
> uprobe.
> 
> Instead of complicating match_uprobe() and __find_uprobe(), perhaps
> it makes sense to add "struct rb_node *__find_close_rb_node(inode)" ?


Yes, we do this too.

> 
> > +static int install_breakpoint(struct mm_struct *mm, struct uprobe *uprobe)
> >  {
> >  	/* Placeholder: Yet to be implemented */
> > +	if (!uprobe->consumers)
> > +		return 0;
> 
> How it is possible to see ->consumers == NULL?
> 

consumers == NULL check is mostly for the mmap_uprobe path.
_register_uprobe and _unregister_uprobe() use the same lock to serialize
so they can check consumers after taking the lock.

> OK, afaics it _is_ possible, but only because unregister does del_consumer()
> without ->i_mutex, but this is bug afaics (see the previous email).

We have discussed this in the other thread.

> 
> Another user is mmap_uprobe() and it checks ->consumers != NULL itself (but
> see below).
> 
> > +int mmap_uprobe(struct vm_area_struct *vma)
> > +{
> > +	struct list_head tmp_list;
> > +	struct uprobe *uprobe, *u;
> > +	struct inode *inode;
> > +	int ret = 0;
> > +
> > +	if (!valid_vma(vma))
> > +		return ret;	/* Bail-out */
> > +
> > +	inode = igrab(vma->vm_file->f_mapping->host);
> > +	if (!inode)
> > +		return ret;
> > +
> > +	INIT_LIST_HEAD(&tmp_list);
> > +	mutex_lock(&uprobes_mmap_mutex);
> > +	build_probe_list(inode, &tmp_list);
> > +	list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
> > +		loff_t vaddr;
> > +
> > +		list_del(&uprobe->pending_list);
> > +		if (!ret && uprobe->consumers) {
> > +			vaddr = vma->vm_start + uprobe->offset;
> > +			vaddr -= vma->vm_pgoff << PAGE_SHIFT;
> > +			if (vaddr < vma->vm_start || vaddr >= vma->vm_end)
> > +				continue;
> > +			ret = install_breakpoint(vma->vm_mm, uprobe);
> 
> So. We are adding the new mapping, we should find all breakpoints this
> file has in the start/end range.
> 
> We are holding ->mmap_sem... this seems enough to protect against the
> races with register/unregister. Except, what if __register_uprobe()
> fails? In this case __unregister_uprobe() does delete_uprobe() at the
> very end. What if mmap mmap_uprobe() is called right before delete_?
> 

Because consumers would be NULL before _unregister_uprobe kicks in, we
shouldnt have a problem here.

_unregister_uprobe and mmap_uprobe() would race for
down_read(&mm->mmap_sem), if _unregister_uprobe() gets the read_lock,
then by the time mmap_uprobe() gets to run, consumers would be NULL and
we are fine since we dont go ahead an insert.

If mmap_uprobe() were to get the write_lock, _unregister_uprobe would do
the necessary cleanup.

we are checking consumers twice, but thats just being conservative.
we should able to do with just one check too.

Am I missing something?

> > +static void dec_mm_uprobes_count(struct vm_area_struct *vma,
> > +		struct inode *inode)
> > +{
> > +	struct uprobe *uprobe;
> > +	struct rb_node *n;
> > +	unsigned long flags;
> > +
> > +	n = uprobes_tree.rb_node;
> > +	spin_lock_irqsave(&uprobes_treelock, flags);
> > +	uprobe = __find_uprobe(inode, 0, &n);
> > +
> > +	/*
> > +	 * If indeed there is a probe for the inode and with offset zero,
> > +	 * then lets release its reference. (ref got thro __find_uprobe)
> > +	 */
> > +	if (uprobe)
> > +		put_uprobe(uprobe);
> > +	for (; n; n = rb_next(n)) {
> > +		loff_t vaddr;
> > +
> > +		uprobe = rb_entry(n, struct uprobe, rb_node);
> > +		if (uprobe->inode != inode)
> > +			break;
> > +		vaddr = vma->vm_start + uprobe->offset;
> > +		vaddr -= vma->vm_pgoff << PAGE_SHIFT;
> > +		if (vaddr < vma->vm_start || vaddr >= vma->vm_end)
> > +			continue;
> > +		atomic_dec(&vma->vm_mm->mm_uprobes_count);
> 
> So, this does atomic_dec() for each bp in this vma?

yes.

> 
> And the caller is
> 
> > @@ -1337,6 +1338,9 @@ unsigned long unmap_vmas(struct mmu_gather *tlb,
> >  		if (unlikely(is_pfn_mapping(vma)))
> >  			untrack_pfn_vma(vma, 0, 0);
> >
> > +		if (vma->vm_file)
> > +			munmap_uprobe(vma);
> 
> Doesn't look right...
> 
> munmap_uprobe() assumes that the whole region goes away. This is
> true in munmap() case afaics, it does __split_vma() if necessary.
> 
> But what about truncate() ? In this case this vma is not unmapped,
> but unmap_vmas() is called anyway and [start, end) can be different.
> IOW, unless I missed something (this is very possible) we can do
> more atomic_dec's then needed.
> 
would unlink_file_vma be a good place to call munmap_uprobe().

The other idea could be to call munmap_uprobe in unmap_region() just
before free_pgtables() and call atomic_set to set the count to 0 in
exit_mmap() (again before free_pgtables.).


One other thing that we probably need to do at mmap_uprobe() is cache
the number of probes mmap_uprobe installed successfully and then
substract the same from mm_uprobes_count if and only if mmap_uprobe()
were to return -ve number.

> Also, truncate() obviously changes ->i_size. Doesn't this mean
> unregister_uprobe() should return if offset > i_size ? We need to
> free uprobes anyway.

Do you mean we shouldnt check for the offset in unregister_uprobe() and
just search in the rbtree for the matching uprobe?
Thats also possible to do.

> 
> MADV_DONTNEED? It calls unmap_vmas() too. And application can do
> madvise(DONTNEED) in a loop.
> 

I think this would be taken care of if we move the munmap_uprobe() hook
from unmap_vmas to unlink_file_vma().

The other thing that I need to investigate a bit more is if I have
handle all cases of mremap correctly.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
