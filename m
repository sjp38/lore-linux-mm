Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 996BF8D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 13:57:09 -0400 (EDT)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2FHl4C0018803
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 13:47:05 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 1DB1A6E8036
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 13:57:03 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2FHv3h6405960
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 13:57:03 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2FHv1IY000417
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 14:57:02 -0300
Date: Tue, 15 Mar 2011 23:21:01 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 3/20] 3: uprobes: Breakground page
 replacement.
Message-ID: <20110315175048.GC24254@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
 <20110314133433.27435.49566.sendpatchset@localhost6.localdomain6>
 <alpine.LFD.2.00.1103151206430.2787@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1103151206430.2787@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

* Thomas Gleixner <tglx@linutronix.de> [2011-03-15 14:22:09]:

> On Mon, 14 Mar 2011, Srikar Dronamraju wrote:
> > +/*
> > + * Called with tsk->mm->mmap_sem held (either for read or write and
> > + * with a reference to tsk->mm
> 
> Hmm, why is holding it for read sufficient?

We are not adding a new vma to the mm; but just replacing a page with
another after holding the locks for the pages. Existing routines
doing close to similar things like the
access_process_vm/get_user_pages seem to be taking the read_lock. Do
you see a resaon why readlock wouldnt suffice?

> .
> > + */
> > +static int write_opcode(struct task_struct *tsk, struct uprobe * uprobe,
> > +			unsigned long vaddr, uprobe_opcode_t opcode)
> > +{
> > +	struct page *old_page, *new_page;
> > +	void *vaddr_old, *vaddr_new;
> > +	struct vm_area_struct *vma;
> > +	spinlock_t *ptl;
> > +	pte_t *orig_pte;
> > +	unsigned long addr;
> > +	int ret = -EINVAL;
> 
> That initialization is pointless.
Okay, 

> 
> > +	/* Read the page with vaddr into memory */
> > +	ret = get_user_pages(tsk, tsk->mm, vaddr, 1, 1, 1, &old_page, &vma);
> > +	if (ret <= 0)
> > +		return -EINVAL;
> > +	ret = -EINVAL;
> > +
> > +	/*
> > +	 * check if the page we are interested is read-only mapped
> > +	 * Since we are interested in text pages, Our pages of interest
> > +	 * should be mapped read-only.
> > +	 */
> > +	if ((vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)) ==
> > +						(VM_READ|VM_EXEC))
> > +		goto put_out;
> 
> IIRC then text pages are (VM_READ|VM_EXEC)

Steven Rostedt already pointed this out.


> 
> > +	/* Allocate a page */
> > +	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, vaddr);
> > +	if (!new_page) {
> > +		ret = -ENOMEM;
> > +		goto put_out;
> > +	}
> > +
> > +	/*
> > +	 * lock page will serialize against do_wp_page()'s
> > +	 * PageAnon() handling
> > +	 */
> > +	lock_page(old_page);
> > +	/* copy the page now that we've got it stable */
> > +	vaddr_old = kmap_atomic(old_page, KM_USER0);
> > +	vaddr_new = kmap_atomic(new_page, KM_USER1);
> > +
> > +	memcpy(vaddr_new, vaddr_old, PAGE_SIZE);
> > +	/* poke the new insn in, ASSUMES we don't cross page boundary */
> 
> And what makes sure that we don't ?

We are expecting the breakpoint instruction to be the minimum size
instruction for that architecture. This wouldnt be a problem for
architectures that have fixed length instructions.
For architectures which have variable size instructions, I am
hoping that the opcode size will be small enuf that it will always not
cross boundary. Something like 0xCC on x86. If and when we support
architectures that have variable length instructions whose
breakpoint instruction can span across page boundary, we have to add
more meat to take care of the case.

> 
> > +	addr = vaddr;
> > +	vaddr &= ~PAGE_MASK;
> > +	memcpy(vaddr_new + vaddr, &opcode, uprobe_opcode_sz);
> > +
> > +	kunmap_atomic(vaddr_new, KM_USER1);
> > +	kunmap_atomic(vaddr_old, KM_USER0);
> > +
> > +	orig_pte = page_check_address(old_page, tsk->mm, addr, &ptl, 0);
> > +	if (!orig_pte)
> > +		goto unlock_out;
> > +	pte_unmap_unlock(orig_pte, ptl);
> > +
> > +	lock_page(new_page);
> > +	if (!anon_vma_prepare(vma))
> 
> Why don't you get the error code of anon_vma_prepare()?

Okay, will capture the error_code of anon_vma_prepare.

> 
> > +		/* flip pages, do_wp_page() will fail pte_same() and bail */
> 
> -ENOPARSE
> 
> > +		ret = replace_page(vma, old_page, new_page, *orig_pte);
> > +
> > +	unlock_page(new_page);
> > +	if (ret != 0)
> > +		page_cache_release(new_page);
> > +unlock_out:
> > +	unlock_page(old_page);
> > +
> > +put_out:
> > +	put_page(old_page); /* we did a get_page in the beginning */
> > +	return ret;
> > +}
> > +
> > +/**
> > + * read_opcode - read the opcode at a given virtual address.
> > + * @tsk: the probed task.
> > + * @vaddr: the virtual address to store the opcode.
> > + * @opcode: location to store the read opcode.
> > + *
> > + * For task @tsk, read the opcode at @vaddr and store it in @opcode.
> > + * Return 0 (success) or a negative errno.
> 
> Wants to called with mmap_sem held as well, right ?

Yes, will document.

> 
> > + */
> > +int __weak read_opcode(struct task_struct *tsk, unsigned long vaddr,
> > +						uprobe_opcode_t *opcode)
> > +{
> > +	struct vm_area_struct *vma;
> > +	struct page *page;
> > +	void *vaddr_new;
> > +	int ret;
> > +
> > +	ret = get_user_pages(tsk, tsk->mm, vaddr, 1, 0, 0, &page, &vma);
> > +	if (ret <= 0)
> > +		return -EFAULT;
> > +	ret = -EFAULT;
> > +
> > +	/*
> > +	 * check if the page we are interested is read-only mapped
> > +	 * Since we are interested in text pages, Our pages of interest
> > +	 * should be mapped read-only.
> > +	 */
> > +	if ((vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)) ==
> > +						(VM_READ|VM_EXEC))
> > +		goto put_out;
> 
> Same as above
> 
> > +	lock_page(page);
> > +	vaddr_new = kmap_atomic(page, KM_USER0);
> > +	vaddr &= ~PAGE_MASK;
> > +	memcpy(&opcode, vaddr_new + vaddr, uprobe_opcode_sz);
> > +	kunmap_atomic(vaddr_new, KM_USER0);
> > +	unlock_page(page);
> > +	ret =  uprobe_opcode_sz;
> 
>   ret = 0 ?? At least, that's what the comment above says.

Has been already been pointed out by Stephen Wilson.
setting ret = 0 here.

> 
> > +
> > +put_out:
> > +	put_page(page); /* we did a get_page in the beginning */
> > +	return ret;
> > +}
> > +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
