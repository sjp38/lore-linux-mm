Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 08A46900087
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 08:21:13 -0400 (EDT)
Subject: Re: [PATCH v3 2.6.39-rc1-tip 4/26]  4: uprobes: Breakground page
 replacement.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110401143318.15455.64841.sendpatchset@localhost6.localdomain6>
References: 
	 <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
	 <20110401143318.15455.64841.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 18 Apr 2011 14:20:25 +0200
Message-ID: <1303129225.32491.776.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, 2011-04-01 at 20:03 +0530, Srikar Dronamraju wrote:

> +static int write_opcode(struct task_struct *tsk, struct uprobe * uprobe,
> +			unsigned long vaddr, uprobe_opcode_t opcode)
> +{
> +	struct page *old_page, *new_page;
> +	void *vaddr_old, *vaddr_new;
> +	struct vm_area_struct *vma;
> +	spinlock_t *ptl;
> +	pte_t *orig_pte;
> +	unsigned long addr;
> +	int ret;
> +
> +	/* Read the page with vaddr into memory */
> +	ret =3D get_user_pages(tsk, tsk->mm, vaddr, 1, 1, 1, &old_page, &vma);
> +	if (ret <=3D 0)
> +		return -EINVAL;

Why not return the actual gup() error?

> +	ret =3D -EINVAL;
> +
> +	/*
> +	 * We are interested in text pages only. Our pages of interest
> +	 * should be mapped for read and execute only. We desist from
> +	 * adding probes in write mapped pages since the breakpoints
> +	 * might end up in the file copy.
> +	 */
> +	if ((vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)) !=3D
> +						(VM_READ|VM_EXEC))
> +		goto put_out;

Note how you return -EINVAL here when we're attempting to poke at the
wrong kind of mapping.

> +	/* Allocate a page */
> +	new_page =3D alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, vaddr);
> +	if (!new_page) {
> +		ret =3D -ENOMEM;
> +		goto put_out;
> +	}
> +
> +	/*
> +	 * lock page will serialize against do_wp_page()'s
> +	 * PageAnon() handling
> +	 */
> +	lock_page(old_page);
> +	/* copy the page now that we've got it stable */
> +	vaddr_old =3D kmap_atomic(old_page, KM_USER0);
> +	vaddr_new =3D kmap_atomic(new_page, KM_USER1);
> +
> +	memcpy(vaddr_new, vaddr_old, PAGE_SIZE);
> +	/* poke the new insn in, ASSUMES we don't cross page boundary */

Why not test this assertion with a VM_BUG_ON() or something.

> +	addr =3D vaddr;
> +	vaddr &=3D ~PAGE_MASK;
> +	memcpy(vaddr_new + vaddr, &opcode, uprobe_opcode_sz);
> +
> +	kunmap_atomic(vaddr_new, KM_USER1);
> +	kunmap_atomic(vaddr_old, KM_USER0);

The use of KM_foo is obsolete and un-needed.

> +	orig_pte =3D page_check_address(old_page, tsk->mm, addr, &ptl, 0);
> +	if (!orig_pte)
> +		goto unlock_out;
> +	pte_unmap_unlock(orig_pte, ptl);
> +
> +	lock_page(new_page);
> +	ret =3D anon_vma_prepare(vma);
> +	if (!ret)
> +		ret =3D replace_page(vma, old_page, new_page, *orig_pte);
> +
> +	unlock_page(new_page);
> +	if (ret !=3D 0)
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
> + * @vaddr: the virtual address to read the opcode.
> + * @opcode: location to store the read opcode.
> + *
> + * Called with tsk->mm->mmap_sem held (for read and with a reference to
> + * tsk->mm.
> + *
> + * For task @tsk, read the opcode at @vaddr and store it in @opcode.
> + * Return 0 (success) or a negative errno.
> + */
> +int __weak read_opcode(struct task_struct *tsk, unsigned long vaddr,
> +						uprobe_opcode_t *opcode)
> +{
> +	struct vm_area_struct *vma;
> +	struct page *page;
> +	void *vaddr_new;
> +	int ret;
> +
> +	ret =3D get_user_pages(tsk, tsk->mm, vaddr, 1, 0, 0, &page, &vma);
> +	if (ret <=3D 0)
> +		return -EFAULT;

Again, why not return the gup() error proper?

> +	ret =3D -EFAULT;
> +
> +	/*
> +	 * We are interested in text pages only. Our pages of interest
> +	 * should be mapped for read and execute only. We desist from
> +	 * adding probes in write mapped pages since the breakpoints
> +	 * might end up in the file copy.
> +	 */
> +	if ((vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)) !=3D
> +						(VM_READ|VM_EXEC))
> +		goto put_out;

But now you return -EFAULT if we peek at the wrong kind of mapping,
which is inconsistent with the -EINVAL of write_opcode().

> +	lock_page(page);
> +	vaddr_new =3D kmap_atomic(page, KM_USER0);
> +	vaddr &=3D ~PAGE_MASK;
> +	memcpy(opcode, vaddr_new + vaddr, uprobe_opcode_sz);
> +	kunmap_atomic(vaddr_new, KM_USER0);

Again, loose the KM_foo.

> +	unlock_page(page);
> +	ret =3D  0;
> +
> +put_out:
> +	put_page(page); /* we did a get_page in the beginning */
> +	return ret;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
