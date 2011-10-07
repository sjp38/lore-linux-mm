Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 973796B002D
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 13:40:38 -0400 (EDT)
Date: Fri, 7 Oct 2011 19:36:23 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 4/26]   uprobes: Define hooks for
	mmap/munmap.
Message-ID: <20111007173623.GC32319@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20110920120040.25326.63549.sendpatchset@srdronam.in.ibm.com> <20111003133710.GA28118@redhat.com> <20111006110531.GE17591@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111006110531.GE17591@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On 10/06, Srikar Dronamraju wrote:
>
> * Oleg Nesterov <oleg@redhat.com> [2011-10-03 15:37:10]:
>
> > On 09/20, Srikar Dronamraju wrote:
> > >
> > > @@ -739,6 +740,10 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
> > >  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> > >  	mm->pmd_huge_pte = NULL;
> > >  #endif
> > > +#ifdef CONFIG_UPROBES
> > > +	atomic_set(&mm->mm_uprobes_count,
> > > +			atomic_read(&oldmm->mm_uprobes_count));
> >
> > Hmm. Why this can't race with install_breakpoint/remove_breakpoint
> > between _read and _set ?
>
> At this time the child vmas are not yet created, so I dont see a
> install_breakpoints/remove_breakpoints from child affecting.

I meant oldmm.

> However if install_breakpoints/remove_breakpoints happen from a parent
> context, from now on till we do a vma_prio_tree_add (actually down_write(oldmm->mmap_sem)
> in dup_mmap()),  then the count in the child may not be the right one.
> If you are pointing to this race, then its probably bigger than just between read and set.

Yes, this too. IOW, atomic_read/set(mm_uprobes_count) looks always
wrong without down_write(mmap_sem).

> > > +static int install_breakpoint(struct mm_struct *mm, struct uprobe *uprobe)
> > >  {
> > >  	/* Placeholder: Yet to be implemented */
> > > +	if (!uprobe->consumers)
> > > +		return 0;
> >
> > How it is possible to see ->consumers == NULL?
>
> consumers == NULL check is mostly for the mmap_uprobe path.

mmap_uprobe() explicitely checks ->consumers != NULL before
install_breakpoint().

> _register_uprobe and _unregister_uprobe() use the same lock to serialize
> so they can check consumers after taking the lock.

Yes,

> > OK, afaics it _is_ possible, but only because unregister does del_consumer()
> > without ->i_mutex, but this is bug afaics (see the previous email).
>
> We have discussed this in the other thread.

Yes. So afaics we can remove this check if unregister() does del_consumer()
under mutex.

Note: I am not saying you should do this ;) I just tried to understand
this code.

> > > +int mmap_uprobe(struct vm_area_struct *vma)
> > > +{
> > > +	struct list_head tmp_list;
> > > +	struct uprobe *uprobe, *u;
> > > +	struct inode *inode;
> > > +	int ret = 0;
> > > +
> > > +	if (!valid_vma(vma))
> > > +		return ret;	/* Bail-out */
> > > +
> > > +	inode = igrab(vma->vm_file->f_mapping->host);
> > > +	if (!inode)
> > > +		return ret;
> > > +
> > > +	INIT_LIST_HEAD(&tmp_list);
> > > +	mutex_lock(&uprobes_mmap_mutex);
> > > +	build_probe_list(inode, &tmp_list);
> > > +	list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
> > > +		loff_t vaddr;
> > > +
> > > +		list_del(&uprobe->pending_list);
> > > +		if (!ret && uprobe->consumers) {
> > > +			vaddr = vma->vm_start + uprobe->offset;
> > > +			vaddr -= vma->vm_pgoff << PAGE_SHIFT;
> > > +			if (vaddr < vma->vm_start || vaddr >= vma->vm_end)
> > > +				continue;
> > > +			ret = install_breakpoint(vma->vm_mm, uprobe);
> >
> > So. We are adding the new mapping, we should find all breakpoints this
> > file has in the start/end range.
> >
> > We are holding ->mmap_sem... this seems enough to protect against the
> > races with register/unregister. Except, what if __register_uprobe()
> > fails? In this case __unregister_uprobe() does delete_uprobe() at the
> > very end. What if mmap mmap_uprobe() is called right before delete_?
> >
>
> Because consumers would be NULL before _unregister_uprobe kicks in, we
> shouldnt have a problem here.

Hmm. But it is not NULL.

Once again, I didn't mean unregister_uprobe(). I meant register_uprobe().
In this case, if __register_uprobe() fails, we are doing __unregister
but uprobe->consumer != NULL.

Just suppose that the caller of register_uprobe() gets a (long) preemption
right before __unregister_uprobe()->delete_uprobe(). What if mmap() is
called at this time?

> Am I missing something?

May be you, may be me. Please recheck ;)

> > Also, truncate() obviously changes ->i_size. Doesn't this mean
> > unregister_uprobe() should return if offset > i_size ? We need to
> > free uprobes anyway.

Argh, I meant "should NOT return if offset > i_size".

> Do you mean we shouldnt check for the offset in unregister_uprobe() and
> just search in the rbtree for the matching uprobe?
> Thats also possible to do.

Yes, we can't trust this check afaics.

> I think this would be taken care of if we move the munmap_uprobe() hook
> from unmap_vmas to unlink_file_vma().

Probably yes, we should rely on prio_tree locking/changes.

> The other thing that I need to investigate a bit more is if I have
> handle all cases of mremap correctly.

Yes. May be mmap_uprobe() should be "closer" to vma_prio_tree_add/insert
too, but I am not sure.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
