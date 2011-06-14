Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 101166B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 08:43:15 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5ECLi0F005956
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 08:21:44 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5EChDGL119054
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 08:43:13 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5EChB8w011032
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 08:43:13 -0400
Date: Tue, 14 Jun 2011 18:05:30 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 2/22]  2: uprobes: Breakground page
 replacement.
Message-ID: <20110614123530.GC4952@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <20110607125835.28590.25476.sendpatchset@localhost6.localdomain6>
 <20110613170020.GA27137@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110613170020.GA27137@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

> > +static int write_opcode(struct task_struct *tsk, struct uprobe * uprobe,
> > +			unsigned long vaddr, uprobe_opcode_t opcode)
> > +{
> > +	struct page *old_page, *new_page;
> > +	void *vaddr_old, *vaddr_new;
> > +	struct vm_area_struct *vma;
> > +	unsigned long addr;
> > +	int ret;
> > +
> > +	/* Read the page with vaddr into memory */
> > +	ret = get_user_pages(tsk, tsk->mm, vaddr, 1, 1, 1, &old_page, &vma);
> 
> Sorry if this was already discussed... But why we are using FOLL_WRITE here?
> We are not going to write into this page, and this provokes the unnecessary
> cow, no?

Yes, We are not going to write to the page returned by get_user_pages
but a copy of that page. The idea was if we cow the page then we dont
need to cow it at the replace_page time and since get_user_pages knows
the right way to cow the page, we dont have to write another routine to
cow the page.

I am still not clear on your concern.

Is it that we should delay cowing the page to the time we actually write
into the page? 

or

Is it that we dont need to cow at all if we are replacing a file backed
page with anon page?


I think we have to cow the page either at page replacement time or at
the beginning. I had tried the option of not cowing the page and it
failed but I dont recollect why it failed but back then we used
write_protect_page and replace_page from ksm.c

> 
> Also. This is called under down_read(mmap_sem), can't we race with
> access_process_vm() modifying the same memory?

Yes, we could be racing with access_process_vm on the same memory.

Do we have any other option other than making write_opcode/read_opcode
being called under down_write(mmap_sem)? I know that write_opcode worked
when we take down_write(mmap_sem). Just that 
anon_vma_prepare() documents that it should be called under read lock
for mmap_sem.

Also Thomas had once asked why we were calling it under down_write.
May be race with access_process_vm is a good enough reason to call it
with down_write.

-- 
Thanks and Regards
Srikar

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
