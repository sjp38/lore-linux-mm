Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id B862A6B007E
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 15:18:30 -0400 (EDT)
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by merlin.infradead.org with esmtps (Exim 4.76 #1 (Red Hat Linux))
	id 1SMOmL-0002Vy-LC
	for linux-mm@kvack.org; Mon, 23 Apr 2012 19:18:29 +0000
Received: from dhcp-089-099-019-018.chello.nl ([89.99.19.18] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1SMOmL-0006qI-7w
	for linux-mm@kvack.org; Mon, 23 Apr 2012 19:18:29 +0000
Subject: Re: [RFC 0/6] uprobes: kill uprobes_srcu/uprobe_srcu_id
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20120423172957.GA29708@redhat.com>
References: <20120415195351.GA22095@redhat.com>
	 <1334526513.28150.23.camel@twins> <20120415234401.GA32662@redhat.com>
	 <1334571419.28150.30.camel@twins> <20120416214707.GA27639@redhat.com>
	 <1334916861.2463.50.camel@laptop> <20120420183718.GA2236@redhat.com>
	 <1335165240.28150.89.camel@twins>
	 <20120423072445.GC8357@linux.vnet.ibm.com>
	 <1335166842.28150.92.camel@twins>  <20120423172957.GA29708@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 23 Apr 2012 21:18:10 +0200
Message-ID: <1335208690.2463.84.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

On Mon, 2012-04-23 at 19:29 +0200, Oleg Nesterov wrote:
> On 04/23, Peter Zijlstra wrote:
> >
> > On Mon, 2012-04-23 at 12:54 +0530, Srikar Dronamraju wrote:
> > > * Peter Zijlstra <peterz@infradead.org> [2012-04-23 09:14:00]:
> > >
> > > > On Fri, 2012-04-20 at 20:37 +0200, Oleg Nesterov wrote:
> > > > > Say, a user wants to probe /sbin/init only. What if init forks?
> > > > > We should remove breakpoints from child->mm somehow.
> > > >
> > > > How is that hard? dup_mmap() only copies the VMAs, this doesn't actually
> > > > copy the breakpoint. So the child doesn't have a breakpoint to be
> > > > removed.
> > > >
> > >
> > > Because the pages are COWED, the breakpoint gets copied over to the
> > > child. If we dont want the breakpoints to be not visible to the child,
> > > then we would have to remove them explicitly based on the filter (i.e if
> > > and if we had inserted breakpoints conditionally based on filter).
> >
> > I thought we didn't COW shared maps since the fault handler will fill in
> > the pages right and only anon stuff gets copied.
> 
> Confused...
> 
> Do you mean the "Don't copy ptes where a page fault will fill them correctly"
> check in copy_page_range() ? Yes, but this vma should have ->anon_vma != NULL
> if it has the breakpoint installed by uprobes.

Oh, argh yeah, we add an anon_vma there..

> > > Once we add the conditional breakpoint insertion (which is tricky),
> >
> > How so?
> 
> I agree with Srikar this doesn't look simple to me. First of all,
> currently it is not easy to find the tasks which use this ->mm.
> OK, we can simply do for_each_process() under tasklist, but this is
> not very nice.
> 
> But again, to me this is not the main problem.

CLONE_VM without CLONE_THREAD is the problem, right?

Can we get away with not supporting that, at least initially?

> > > Conditional removal
> > > of breakpoints in fork path would just be an extension of the
> > > conditional breakpoint insertion.
> >
> > Right, I don't think that removal is particularly hard if needed.
> 
> I agree that remove_breakpoint() itself is not that hard, probably.
> 
> But the whole idea of filtering is not clear to me. I mean, when/how
> we should call the filter, and what should be the argument.
> task_struct? Probably, but I am not sure.

Well, the idea is really very simple: if for a probe an {mm,tasks} set
has all negative filters we do not install the probe on that mm.

The filters already take a uprobe_consumer and task_struct as argument.

> And btw fork()->dup_mmap() should call the filter too. Suppose that
> uprobe_consumer wants to trace the task T and its children, this looks
> very natural.

Agreed.

> And we need to rework uprobe_register(). It can't simply return if
> this (inode, offset) already has the consumer.

Not quite sure what you mean. uprobe_register() doesn't have such a
return value. It returns 0 on success and an error otherwise. Do you
mean __uprobe_register() ? That calls register_for_each_vma() and that
can simply call ->filter() for each vma it iterates. In fact, it can get
away with only calling the filter for the new consumer.

> So far I think this needs more thinking. And imho we should merge the
> working code Srikar already has, then try to add this (agreed, very
> important) optimization.

Sure..


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
