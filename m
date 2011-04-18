Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 83E60900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 12:46:46 -0400 (EDT)
Subject: Re: [PATCH v3 2.6.39-rc1-tip 12/26] 12: uprobes: slot allocation
 for uprobes
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110401143457.15455.64839.sendpatchset@localhost6.localdomain6>
References: 
	 <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
	 <20110401143457.15455.64839.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 18 Apr 2011 18:46:11 +0200
Message-ID: <1303145171.32491.886.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 2011-04-01 at 20:04 +0530, Srikar Dronamraju wrote:
> Every task is allocated a fixed slot. When a probe is hit, the original
> instruction corresponding to the probe hit is copied to per-task fixed
> slot. Currently we allocate one page of slots for each mm. Bitmaps are
> used to know which slots are free. Each slot is made of 128 bytes so
> that its cache aligned.
>=20
> TODO: On massively threaded processes (or if a huge number of processes
> share the same mm), there is a possiblilty of running out of slots.
> One alternative could be to extend the slots as when slots are required.

As long as you're single stepping things and not using boosted probes
you can fully serialize the slot usage. Claim a slot on trap and release
the slot on finish. Claiming can wait on a free slot since you already
have the whole SLEEPY thing.


> +static int xol_add_vma(struct uprobes_xol_area *area)
> +{
> +	struct vm_area_struct *vma;
> +	struct mm_struct *mm;
> +	struct file *file;
> +	unsigned long addr;
> +	int ret =3D -ENOMEM;
> +
> +	mm =3D get_task_mm(current);
> +	if (!mm)
> +		return -ESRCH;
> +
> +	down_write(&mm->mmap_sem);
> +	if (mm->uprobes_xol_area) {
> +		ret =3D -EALREADY;
> +		goto fail;
> +	}
> +
> +	/*
> +	 * Find the end of the top mapping and skip a page.
> +	 * If there is no space for PAGE_SIZE above
> +	 * that, mmap will ignore our address hint.
> +	 *
> +	 * We allocate a "fake" unlinked shmem file because
> +	 * anonymous memory might not be granted execute
> +	 * permission when the selinux security hooks have
> +	 * their way.
> +	 */

That just annoys me, so we're working around some stupid sekurity crap,
executable anonymous maps are perfectly fine, also what do JITs do?

> +	vma =3D rb_entry(rb_last(&mm->mm_rb), struct vm_area_struct, vm_rb);
> +	addr =3D vma->vm_end + PAGE_SIZE;
> +	file =3D shmem_file_setup("uprobes/xol", PAGE_SIZE, VM_NORESERVE);
> +	if (!file) {
> +		printk(KERN_ERR "uprobes_xol failed to setup shmem_file "
> +			"while allocating vma for pid/tgid %d/%d for "
> +			"single-stepping out of line.\n",
> +			current->pid, current->tgid);
> +		goto fail;
> +	}
> +	addr =3D do_mmap_pgoff(file, addr, PAGE_SIZE, PROT_EXEC, MAP_PRIVATE, 0=
);
> +	fput(file);
> +
> +	if (addr & ~PAGE_MASK) {
> +		printk(KERN_ERR "uprobes_xol failed to allocate a vma for "
> +				"pid/tgid %d/%d for single-stepping out of "
> +				"line.\n", current->pid, current->tgid);
> +		goto fail;
> +	}
> +	vma =3D find_vma(mm, addr);
> +
> +	/* Don't expand vma on mremap(). */
> +	vma->vm_flags |=3D VM_DONTEXPAND | VM_DONTCOPY;
> +	area->vaddr =3D vma->vm_start;
> +	if (get_user_pages(current, mm, area->vaddr, 1, 1, 1, &area->page,
> +				&vma) > 0)
> +		ret =3D 0;
> +
> +fail:
> +	up_write(&mm->mmap_sem);
> +	mmput(mm);
> +	return ret;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
