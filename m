Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BB4638D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 12:58:47 -0400 (EDT)
Date: Mon, 14 Mar 2011 12:58:18 -0400
From: Stephen Wilson <wilsons@start.ca>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 3/20]  3: uprobes: Breakground page
	replacement.
Message-ID: <20110314165818.GA18507@fibrous.localdomain>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6> <20110314133433.27435.49566.sendpatchset@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110314133433.27435.49566.sendpatchset@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, Mar 14, 2011 at 07:04:33PM +0530, Srikar Dronamraju wrote:
> +/**
> + * read_opcode - read the opcode at a given virtual address.
> + * @tsk: the probed task.
> + * @vaddr: the virtual address to store the opcode.
> + * @opcode: location to store the read opcode.
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
> +
> +	lock_page(page);
> +	vaddr_new = kmap_atomic(page, KM_USER0);
> +	vaddr &= ~PAGE_MASK;
> +	memcpy(&opcode, vaddr_new + vaddr, uprobe_opcode_sz);
> +	kunmap_atomic(vaddr_new, KM_USER0);
> +	unlock_page(page);
> +	ret =  uprobe_opcode_sz;

This looks wrong.  We should be setting ret = 0 on success here?

> +
> +put_out:
> +	put_page(page); /* we did a get_page in the beginning */
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
