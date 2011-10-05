Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 27CB6900149
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 07:10:04 -0400 (EDT)
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 5 Oct 2011 07:10:02 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p95B9vKa214150
	for <linux-mm@kvack.org>; Wed, 5 Oct 2011 07:09:59 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p95B9t9Z018221
	for <linux-mm@kvack.org>; Wed, 5 Oct 2011 08:09:57 -0300
Date: Wed, 5 Oct 2011 16:22:43 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 5/26]   Uprobes: copy of the original
 instruction.
Message-ID: <20111005105243.GA806@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920120057.25326.63780.sendpatchset@srdronam.in.ibm.com>
 <20111003162905.GA3752@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20111003162905.GA3752@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>

* Oleg Nesterov <oleg@redhat.com> [2011-10-03 18:29:05]:

> On 09/20, Srikar Dronamraju wrote:
> >
> > +static int __copy_insn(struct address_space *mapping,
> > +			struct vm_area_struct *vma, char *insn,
> > +			unsigned long nbytes, unsigned long offset)
> > +{
> > +	struct file *filp = vma->vm_file;
> > +	struct page *page;
> > +	void *vaddr;
> > +	unsigned long off1;
> > +	unsigned long idx;
> > +
> > +	if (!filp)
> > +		return -EINVAL;
> > +
> > +	idx = (unsigned long) (offset >> PAGE_CACHE_SHIFT);
> > +	off1 = offset &= ~PAGE_MASK;
> > +
> > +	/*
> > +	 * Ensure that the page that has the original instruction is
> > +	 * populated and in page-cache.
> > +	 */
> 
> Hmm. But how we can ensure?


> 
> > +	page_cache_sync_readahead(mapping, &filp->f_ra, filp, idx, 1);
> 
> This schedules the i/o,
> 
> > +	page = grab_cache_page(mapping, idx);
> 
> This finds/locks the page in the page-cache,
> 
> > +	if (!page)
> > +		return -ENOMEM;
> > +
> > +	vaddr = kmap_atomic(page);
> > +	memcpy(insn, vaddr + off1, nbytes);
> 
> What if this page is not PageUptodate() ?

Since we do a synchronous read ahead, I thought the page would be 
populated and upto date. 

would these two lines after grab_cache_page help?

	if (!PageUptodate(page)) 
		mapping->a_ops->readpage(filp, page);


> 
> Somehow this assumes that the i/o was already completed, I don't
> understand this.
> 
> But I am starting to think I simply do not understand this change.
> To the point, I do not underestand why do we need copy_insn() at all.
> We are going to replace this page, can't we save/analyze ->insn later
> when we copy the content of the old page? Most probably I missed
> something simple...
> 
> 
> > +static struct task_struct *get_mm_owner(struct mm_struct *mm)
> > +{
> > +	struct task_struct *tsk;
> > +
> > +	rcu_read_lock();
> > +	tsk = rcu_dereference(mm->owner);
> > +	if (tsk)
> > +		get_task_struct(tsk);
> > +	rcu_read_unlock();
> > +	return tsk;
> > +}
> 
> Hmm. Do we really need task_struct?
> 
> > -static int install_breakpoint(struct mm_struct *mm, struct uprobe *uprobe)
> > +static int install_breakpoint(struct mm_struct *mm, struct uprobe *uprobe,
> > +				struct vm_area_struct *vma, loff_t vaddr)
> >  {
> > -	/* Placeholder: Yet to be implemented */
> > +	struct task_struct *tsk;
> > +	unsigned long addr;
> > +	int ret = -EINVAL;
> > +
> >  	if (!uprobe->consumers)
> >  		return 0;
> >
> > -	atomic_inc(&mm->mm_uprobes_count);
> > -	return 0;
> > +	tsk = get_mm_owner(mm);
> > +	if (!tsk)	/* task is probably exiting; bail-out */
> > +		return -ESRCH;
> > +
> > +	if (vaddr > TASK_SIZE_OF(tsk))
> > +		goto put_return;
> 
> But this should not be possible, no? How it can map this vaddr above
> TASK_SIZE ?
> 
> get_user_pages(tsk => NULL) is fine. Why else do we need mm->owner ?

> 
> Probably used by the next patches... Say, is_32bit_app(tsk). This
> can use mm->context.ia32_compat (hopefully will be replaced with
> MMF_COMPAT).
> 

We used the tsk struct for checking if the application was 32 bit and
for calling get_user_pages. Since we can pass NULL to get_user_pages and
since we can use mm->context.ia32_compat or MMF_COMPAT, I will remove
get_mm_owner, that way we dont need to be dependent on CONFIG_MM_OWNER.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
