Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 98FD28D003B
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:30:31 -0400 (EDT)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2EH6BMm011339
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:06:11 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 587FE6E803C
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:30:28 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2EHURH52756664
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:30:27 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2EHUPWv026071
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:30:26 -0400
Date: Mon, 14 Mar 2011 22:54:39 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 3/20]  3: uprobes: Breakground page
 replacement.
Message-ID: <20110314172439.GO24254@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
 <20110314133433.27435.49566.sendpatchset@localhost6.localdomain6>
 <1300117137.9910.110.camel@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1300117137.9910.110.camel@gandalf.stny.rr.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

* Steven Rostedt <rostedt@goodmis.org> [2011-03-14 11:38:57]:

> On Mon, 2011-03-14 at 19:04 +0530, Srikar Dronamraju wrote:
> > +/*
> > + * Called with tsk->mm->mmap_sem held (either for read or write and
> > + * with a reference to tsk->mm.
> > + */
> > +static int write_opcode(struct task_struct *tsk, struct uprobe * uprobe,
> > +                       unsigned long vaddr, uprobe_opcode_t opcode)
> > +{
> > +       struct page *old_page, *new_page;
> > +       void *vaddr_old, *vaddr_new;
> > +       struct vm_area_struct *vma;
> > +       spinlock_t *ptl;
> > +       pte_t *orig_pte;
> > +       unsigned long addr;
> > +       int ret = -EINVAL;
> > +
> > +       /* Read the page with vaddr into memory */
> > +       ret = get_user_pages(tsk, tsk->mm, vaddr, 1, 1, 1, &old_page, &vma);
> > +       if (ret <= 0)
> > +               return -EINVAL;
> > +       ret = -EINVAL;
> > +
> > +       /*
> > +        * check if the page we are interested is read-only mapped
> > +        * Since we are interested in text pages, Our pages of interest
> > +        * should be mapped read-only.
> > +        */
> > +       if ((vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)) ==
> > +                                               (VM_READ|VM_EXEC))
> > +               goto put_out;
> > + 
> 
> I'm confused by the above comment and code. You state we are only
> interested text pages mapped read-only, but then if the page is mapped
> read/exec we exit out? It is fine if it is anything but READ/EXEC.

You are right, it should have been
	if ((vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)) !=
					(VM_READ|VM_EXEC))
		goto put_out;


Your comment applied for read_opcode function too.
Will correct in the next version of the patchset.

However in the next patch, where we replace the above with
valid_vma and that does the right thing.

> 
> I'm also curious to why we can't modify text code that is also mapped as
> read/write.
> 

If text code is mapped read/write then on memory pressure the page gets
written to the disk. Hence breakpoints inserted may end up being in the
disk copy modifying the actual copy.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
