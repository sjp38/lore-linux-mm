Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 8B5FE6B004D
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 13:31:03 -0400 (EDT)
Date: Mon, 23 Apr 2012 19:29:57 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC 0/6] uprobes: kill uprobes_srcu/uprobe_srcu_id
Message-ID: <20120423172957.GA29708@redhat.com>
References: <20120415195351.GA22095@redhat.com> <1334526513.28150.23.camel@twins> <20120415234401.GA32662@redhat.com> <1334571419.28150.30.camel@twins> <20120416214707.GA27639@redhat.com> <1334916861.2463.50.camel@laptop> <20120420183718.GA2236@redhat.com> <1335165240.28150.89.camel@twins> <20120423072445.GC8357@linux.vnet.ibm.com> <1335166842.28150.92.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1335166842.28150.92.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

On 04/23, Peter Zijlstra wrote:
>
> On Mon, 2012-04-23 at 12:54 +0530, Srikar Dronamraju wrote:
> > * Peter Zijlstra <peterz@infradead.org> [2012-04-23 09:14:00]:
> >
> > > On Fri, 2012-04-20 at 20:37 +0200, Oleg Nesterov wrote:
> > > > Say, a user wants to probe /sbin/init only. What if init forks?
> > > > We should remove breakpoints from child->mm somehow.
> > >
> > > How is that hard? dup_mmap() only copies the VMAs, this doesn't actually
> > > copy the breakpoint. So the child doesn't have a breakpoint to be
> > > removed.
> > >
> >
> > Because the pages are COWED, the breakpoint gets copied over to the
> > child. If we dont want the breakpoints to be not visible to the child,
> > then we would have to remove them explicitly based on the filter (i.e if
> > and if we had inserted breakpoints conditionally based on filter).
>
> I thought we didn't COW shared maps since the fault handler will fill in
> the pages right and only anon stuff gets copied.

Confused...

Do you mean the "Don't copy ptes where a page fault will fill them correctly"
check in copy_page_range() ? Yes, but this vma should have ->anon_vma != NULL
if it has the breakpoint installed by uprobes.

Yes, we do not COW this page during dup_mmap(), but the new child's pte
should point to the same page with bp.

OK, I guess I misunderstood.

> > Once we add the conditional breakpoint insertion (which is tricky),
>
> How so?

I agree with Srikar this doesn't look simple to me. First of all,
currently it is not easy to find the tasks which use this ->mm.
OK, we can simply do for_each_process() under tasklist, but this is
not very nice.

But again, to me this is not the main problem.

> > Conditional removal
> > of breakpoints in fork path would just be an extension of the
> > conditional breakpoint insertion.
>
> Right, I don't think that removal is particularly hard if needed.

I agree that remove_breakpoint() itself is not that hard, probably.

But the whole idea of filtering is not clear to me. I mean, when/how
we should call the filter, and what should be the argument.
task_struct? Probably, but I am not sure.

And btw fork()->dup_mmap() should call the filter too. Suppose that
uprobe_consumer wants to trace the task T and its children, this looks
very natural.

And we need to rework uprobe_register(). It can't simply return if
this (inode, offset) already has the consumer.

So far I think this needs more thinking. And imho we should merge the
working code Srikar already has, then try to add this (agreed, very
important) optimization.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
