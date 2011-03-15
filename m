Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7C5BD8D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 09:22:45 -0400 (EDT)
Date: Tue, 15 Mar 2011 14:22:09 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 3/20] 3: uprobes: Breakground page
 replacement.
In-Reply-To: <20110314133433.27435.49566.sendpatchset@localhost6.localdomain6>
Message-ID: <alpine.LFD.2.00.1103151206430.2787@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6> <20110314133433.27435.49566.sendpatchset@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, 14 Mar 2011, Srikar Dronamraju wrote:
> +/*
> + * Called with tsk->mm->mmap_sem held (either for read or write and
> + * with a reference to tsk->mm

Hmm, why is holding it for read sufficient?
.
> + */
> +static int write_opcode(struct task_struct *tsk, struct uprobe * uprobe,
> +			unsigned long vaddr, uprobe_opcode_t opcode)
> +{
> +	struct page *old_page, *new_page;
> +	void *vaddr_old, *vaddr_new;
> +	struct vm_area_struct *vma;
> +	spinlock_t *ptl;
> +	pte_t *orig_pte;
> +	unsigned long addr;
> +	int ret = -EINVAL;

That initialization is pointless.

> +	/* Read the page with vaddr into memory */
> +	ret = get_user_pages(tsk, tsk->mm, vaddr, 1, 1, 1, &old_page, &vma);
> +	if (ret <= 0)
> +		return -EINVAL;
> +	ret = -EINVAL;
> +
> +	/*
> +	 * check if the page we are interested is read-only mapped
> +	 * Since we are interested in text pages, Our pages of interest
> +	 * should be mapped read-only.
> +	 */
> +	if ((vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)) ==
> +						(VM_READ|VM_EXEC))
> +		goto put_out;

IIRC then text pages are (VM_READ|VM_EXEC)

> +	/* Allocate a page */
> +	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, vaddr);
> +	if (!new_page) {
> +		ret = -ENOMEM;
> +		goto put_out;
> +	}
> +
> +	/*
> +	 * lock page will serialize against do_wp_page()'s
> +	 * PageAnon() handling
> +	 */
> +	lock_page(old_page);
> +	/* copy the page now that we've got it stable */
> +	vaddr_old = kmap_atomic(old_page, KM_USER0);
> +	vaddr_new = kmap_atomic(new_page, KM_USER1);
> +
> +	memcpy(vaddr_new, vaddr_old, PAGE_SIZE);
> +	/* poke the new insn in, ASSUMES we don't cross page boundary */

And what makes sure that we don't ?

> +	addr = vaddr;
> +	vaddr &= ~PAGE_MASK;
> +	memcpy(vaddr_new + vaddr, &opcode, uprobe_opcode_sz);
> +
> +	kunmap_atomic(vaddr_new, KM_USER1);
> +	kunmap_atomic(vaddr_old, KM_USER0);
> +
> +	orig_pte = page_check_address(old_page, tsk->mm, addr, &ptl, 0);
> +	if (!orig_pte)
> +		goto unlock_out;
> +	pte_unmap_unlock(orig_pte, ptl);
> +
> +	lock_page(new_page);
> +	if (!anon_vma_prepare(vma))

Why don't you get the error code of anon_vma_prepare()?

> +		/* flip pages, do_wp_page() will fail pte_same() and bail */

-ENOPARSE

> +		ret = replace_page(vma, old_page, new_page, *orig_pte);
> +
> +	unlock_page(new_page);
> +	if (ret != 0)
> +		page_cache_release(new_page);
> +unlock_out:
> +	unlock_page(old_page);
> +
> +put_out:
> +	put_page(old_page); /* we did a get_page in the beginning */
> +	return ret;
> +}
> +
> +/**
> + * read_opcode - read the opcode at a given virtual address.
> + * @tsk: the probed task.
> + * @vaddr: the virtual address to store the opcode.
> + * @opcode: location to store the read opcode.
> + *
> + * For task @tsk, read the opcode at @vaddr and store it in @opcode.
> + * Return 0 (success) or a negative errno.

Wants to called with mmap_sem held as well, right ?

> + */
> +int __weak read_opcode(struct task_struct *tsk, unsigned long vaddr,
> +						uprobe_opcode_t *opcode)
> +{
> +	struct vm_area_struct *vma;
> +	struct page *page;
> +	void *vaddr_new;
> +	int ret;
> +
> +	ret = get_user_pages(tsk, tsk->mm, vaddr, 1, 0, 0, &page, &vma);
> +	if (ret <= 0)
> +		return -EFAULT;
> +	ret = -EFAULT;
> +
> +	/*
> +	 * check if the page we are interested is read-only mapped
> +	 * Since we are interested in text pages, Our pages of interest
> +	 * should be mapped read-only.
> +	 */
> +	if ((vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)) ==
> +						(VM_READ|VM_EXEC))
> +		goto put_out;

Same as above

> +	lock_page(page);
> +	vaddr_new = kmap_atomic(page, KM_USER0);
> +	vaddr &= ~PAGE_MASK;
> +	memcpy(&opcode, vaddr_new + vaddr, uprobe_opcode_sz);
> +	kunmap_atomic(vaddr_new, KM_USER0);
> +	unlock_page(page);
> +	ret =  uprobe_opcode_sz;

  ret = 0 ?? At least, that's what the comment above says.

> +
> +put_out:
> +	put_page(page); /* we did a get_page in the beginning */
> +	return ret;
> +}
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
