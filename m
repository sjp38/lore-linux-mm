Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 83C2C6B00EA
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 10:45:56 -0400 (EDT)
Date: Mon, 16 Apr 2012 16:44:57 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 2/6] uprobes: introduce is_swbp_at_addr_fast()
Message-ID: <20120416144457.GA7018@redhat.com>
References: <20120405222024.GA19154@redhat.com> <20120405222106.GB19166@redhat.com> <1334570935.28150.25.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1334570935.28150.25.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

On 04/16, Peter Zijlstra wrote:
>
> On Fri, 2012-04-06 at 00:21 +0200, Oleg Nesterov wrote:
> > +int __weak is_swbp_at_addr_fast(unsigned long vaddr)
> > +{
> > +       uprobe_opcode_t opcode;
> > +       int fault;
> > +
> > +       pagefault_disable();
> > +       fault = __copy_from_user_inatomic(&opcode, (void __user*)vaddr,
> > +                                                       sizeof(opcode));
> > +       pagefault_enable();
> > +
> > +       if (unlikely(fault)) {
> > +               /*
> > +                * XXX: read_opcode() lacks FOLL_FORCE, it can fail if
> > +                * we race with another thread which does mprotect(NONE)
> > +                * after we hit bp.
> > +                */
> > +               if (read_opcode(current->mm, vaddr, &opcode))
> > +                       return -EFAULT;
> > +       }
> > +
> > +       return is_swbp_insn(&opcode);
> > +}
>
> Why bother with the pagefault_disable() and unlikely fault case and not
> simply do copy_from_user() and have it deal with the fault if its needed
> anyway?

But we can't do this under down_read(mmap_sem) ?

If another thread waits for down_write() then do_page_fault() can't take
this lock, right?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
