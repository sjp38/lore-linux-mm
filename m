Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C6DEF6B00E9
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 10:22:46 -0400 (EDT)
Date: Tue, 14 Jun 2011 16:20:23 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 2/22]  2: uprobes: Breakground page
	replacement.
Message-ID: <20110614142023.GA5139@redhat.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6> <20110607125835.28590.25476.sendpatchset@localhost6.localdomain6> <20110613170020.GA27137@redhat.com> <20110614123530.GC4952@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110614123530.GC4952@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On 06/14, Srikar Dronamraju wrote:
>
> > > +static int write_opcode(struct task_struct *tsk, struct uprobe * uprobe,
> > > +			unsigned long vaddr, uprobe_opcode_t opcode)
> > > +{
> > > +	struct page *old_page, *new_page;
> > > +	void *vaddr_old, *vaddr_new;
> > > +	struct vm_area_struct *vma;
> > > +	unsigned long addr;
> > > +	int ret;
> > > +
> > > +	/* Read the page with vaddr into memory */
> > > +	ret = get_user_pages(tsk, tsk->mm, vaddr, 1, 1, 1, &old_page, &vma);
> >
> > Sorry if this was already discussed... But why we are using FOLL_WRITE here?
> > We are not going to write into this page, and this provokes the unnecessary
> > cow, no?
>
> Yes, We are not going to write to the page returned by get_user_pages
> but a copy of that page.

Yes I see. But the page returned by get_user_pages(write => 1) is already
a cow'ed copy (this mapping should be read-only).

> The idea was if we cow the page then we dont
> need to cow it at the replace_page time

Yes, replace_page() shouldn't cow.

> and since get_user_pages knows
> the right way to cow the page, we dont have to write another routine to
> cow the page.

Confused. write_opcode() allocs another page and does memcpy. This is
correct, but I don't understand the first cow.

> I am still not clear on your concern.

Probably I missed something... but could you please explain why we can't

	- ret = get_user_pages(tsk, tsk->mm, vaddr, 1, 1, 1, &old_page, &vma);
	+ ret = get_user_pages(tsk, tsk->mm, vaddr, 1, 0, 0, &old_page, &vma);

?

> > Also. This is called under down_read(mmap_sem), can't we race with
> > access_process_vm() modifying the same memory?
>
> Yes, we could be racing with access_process_vm on the same memory.
>
> Do we have any other option other than making write_opcode/read_opcode
> being called under down_write(mmap_sem)?

I dunno. Probably we can simply ignore this issue, there are other ways
to modify this memory.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
