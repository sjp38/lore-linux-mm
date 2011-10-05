Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 120FC9400BF
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 12:28:00 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p95FujiG017115
	for <linux-mm@kvack.org>; Wed, 5 Oct 2011 11:56:45 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p95GRwvi175324
	for <linux-mm@kvack.org>; Wed, 5 Oct 2011 12:27:58 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p95GQpl4027685
	for <linux-mm@kvack.org>; Wed, 5 Oct 2011 10:26:52 -0600
Date: Wed, 5 Oct 2011 21:39:34 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 5/26]   Uprobes: copy of the original
 instruction.
Message-ID: <20111005160934.GC806@linux.vnet.ibm.com>
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

Copying the instruction at the time we replace the original instruction
would have been ideal. However there are a few irritants to handle.

 - While inserting the breakpoint, we might find that the original
   instruction to be the breakpoint instruction itself. (This could
   happen if mmap_uprobe were to race with register_uprobe() or somebody
   else like gdb inserted a breakpoint). How do we distinguish if the
   breakpoint instruction was around in the text or somebody inserted a
   breakpoint in that address-space? Since we read from the page-cache,
   we can easily resolve this.

-  On archs like x86, with variable size instructions, the original
   instruction can be across 2 pages. This is because we copy the
   maximum instruction size from the given vaddr into a buffer for
   subsequent analysis. So the copy_insn takes care of getting two pages
   if and when required. 
   Currently the insert and remove breakpoint
   assumes that the instruction size of a breakpoint is the smallest
   size for that architecture. Hence reading/writing to one page in
   write_opcode is good enough.

-  Again on variable instruction size supporting archs, if two
   subsequent instructions are probed, the original instruction if
   copied using get_user_pages might already have a breakpoint included.
   (This shouldnt have any effect on the uprobes though.)

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
