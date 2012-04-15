Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id CD53C6B004D
	for <linux-mm@kvack.org>; Sun, 15 Apr 2012 15:54:43 -0400 (EDT)
Date: Sun, 15 Apr 2012 21:53:51 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC 0/6] uprobes: kill uprobes_srcu/uprobe_srcu_id
Message-ID: <20120415195351.GA22095@redhat.com>
References: <20120405222024.GA19154@redhat.com> <1334409396.2528.100.camel@twins> <20120414205200.GA9083@redhat.com> <1334487062.2528.113.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1334487062.2528.113.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

On 04/15, Peter Zijlstra wrote:
>
> On Sat, 2012-04-14 at 22:52 +0200, Oleg Nesterov wrote:
> > > >     - can it work or I missed something "in general" ?
> > >
> > > So we insert in the rb-tree before we take mmap_sem, this means we can
> > > hit a non-uprobe int3 and still find a uprobe there, no?
> >
> > Yes, but unless I miss something this is "off-topic", this
> > can happen with or without these changes. If find_uprobe()
> > succeeds we assume that this bp was inserted by uprobe.
>
> OK, but then I completely missed what the point of that
> down_write() stuff is..

To ensure handle_swbp() can't race with unregister + register
and send the wrong SIGTRAP.

handle_swbp() roughly does under down_read(mmap_sem)


	if (find_uprobe(vaddr))
		process_uprobe();
	else
	if (is_swbp_at_addr_fast(vaddr))	// non-uprobe int3
		send_sig(SIGTRAP);
	else
		restart_insn(vaddr);		// raced with unregister


note that is_swbp_at_addr_fast() is used (currently) to detect
the race with upbrobe_unregister() and that is why we can remove
uprobes_srcu.

But if find_uprobe() fails, there is a window before
is_swbp_at_addr_fast() reads the memory. Suppose that the next
uprobe_register() inserts the new uprobe at the same address.
In this case the task will be wrongly killed.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
