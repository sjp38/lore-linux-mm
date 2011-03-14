Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 581A48D003B
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:35:56 -0400 (EDT)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2EHArQl029951
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:10:53 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 217146E8036
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:35:54 -0400 (EDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2EHZrY2480640
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:35:53 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2EHZq4N016757
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 11:35:53 -0600
Date: Mon, 14 Mar 2011 23:00:04 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 3/20]  3: uprobes: Breakground page
 replacement.
Message-ID: <20110314173004.GQ24254@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
 <20110314133433.27435.49566.sendpatchset@localhost6.localdomain6>
 <20110314165818.GA18507@fibrous.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110314165818.GA18507@fibrous.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Wilson <wilsons@start.ca>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

* Stephen Wilson <wilsons@start.ca> [2011-03-14 12:58:18]:

> On Mon, Mar 14, 2011 at 07:04:33PM +0530, Srikar Dronamraju wrote:
> > +/**
> > + * read_opcode - read the opcode at a given virtual address.
> > + * @tsk: the probed task.
> > + * @vaddr: the virtual address to store the opcode.
> > + * @opcode: location to store the read opcode.
> > + *
> > + * For task @tsk, read the opcode at @vaddr and store it in @opcode.
> > + * Return 0 (success) or a negative errno.
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
> > +
> > +	lock_page(page);
> > +	vaddr_new = kmap_atomic(page, KM_USER0);
> > +	vaddr &= ~PAGE_MASK;
> > +	memcpy(&opcode, vaddr_new + vaddr, uprobe_opcode_sz);
> > +	kunmap_atomic(vaddr_new, KM_USER0);
> > +	unlock_page(page);
> > +	ret =  uprobe_opcode_sz;
> 
> This looks wrong.  We should be setting ret = 0 on success here?

Right, I should have set ret = 0 here.

> 
> > +
> > +put_out:
> > +	put_page(page); /* we did a get_page in the beginning */
> > +	return ret;
> > +}
> 
> -- 
> steve
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
