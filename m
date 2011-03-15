Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E7CA78D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 14:16:11 -0400 (EDT)
Date: Tue, 15 Mar 2011 19:15:42 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 5/20] 5: Uprobes: register/unregister
 probes.
In-Reply-To: <20110315171536.GA24254@linux.vnet.ibm.com>
Message-ID: <alpine.LFD.2.00.1103151826220.2787@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6> <20110314133454.27435.81020.sendpatchset@localhost6.localdomain6> <alpine.LFD.2.00.1103151439400.2787@localhost6.localdomain6> <20110315171536.GA24254@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Tue, 15 Mar 2011, Srikar Dronamraju wrote:
> * Thomas Gleixner <tglx@linutronix.de> [2011-03-15 15:28:04]:
> > > +	list_for_each_entry_safe(mm, tmpmm, &tmp_list, uprobes_list) {
> > > +		down_read(&mm->mmap_sem);
> > > +		if (!install_uprobe(mm, uprobe))
> > > +			ret = 0;
> > 
> > Installing it once is success ?
> 
> This is a little tricky. My intention was to return success even if one
> install is successful. If we return error, then the caller can go
> ahead and free the consumer. Since we return success if there are
> currently no processes that have mapped this inode, I was tempted to
> return success on atleast one successful install.

Ok. Wants to be documented in a comment.
 
> > 
> > > +		list_del(&mm->uprobes_list);
> > 
> > Also the locking rules for mm->uprobes_list want to be
> > documented. They are completely non obvious.
> > 
> > > +		up_read(&mm->mmap_sem);
> > > +		mmput(mm);
> > > +	}
> > > +
> > > +consumers_add:
> > > +	add_consumer(uprobe, consumer);
> > > +	mutex_unlock(&uprobes_mutex);
> > > +	put_uprobe(uprobe);
> > 
> > Why do we drop the refcount here?
> 
> The first time uprobe_add gets called for a unique inode:offset
> pair, it sets the refcount to 2 (One for the uprobe creation and the
> other for register activity). From next time onwards it
> increments the refcount by  (for register activity) 1.
> The refcount dropped here corresponds to the register activity.
> 
> Similarly unregister takes a refcount thro find_uprobe and drops it thro
> del_consumer().  However it drops the creation refcount if and if
> there are no more consumers.

Ok. That wants a few comments perhaps. It's not really obvious.
 
> I thought of just taking the refcount just for the first register and
> decrement for the last unregister. However register/unregister can race
> with each other causing the refcount to be zero and free the uprobe
> structure even though we were still registering the probe.

Right, that won't work.
 
> > 
> > > +	return ret;
> > > +}
> > 
> > > +	/*
> > > +	 * There could be other threads that could be spinning on
> > > +	 * treelock; some of these threads could be interested in this
> > > +	 * uprobe.  Give these threads a chance to run.
> > > +	 */
> > > +	synchronize_sched();
> > 
> > This makes no sense at all. We are not holding treelock, we are about
> > to acquire it. Also what does it matter when they spin on treelock and
> > are interested in this uprobe. Either they find it before we remove it
> > or not. So why synchronize_sched()? I find the lifetime rules of
> > uprobe utterly confusing. Could you explain please ?
> 
> There could be threads that have hit the breakpoint and are
> entering the notifier code(interrupt context) and then
> do_notify_resume(task context) and trying to acquire the treelock.
> (treelock is held by the breakpoint hit threads in
> uprobe_notify_resume which gets called in do_notify_resume()) The
> current thread that is removing the uprobe from the rb_tree can race
> with these threads and might acquire the treelock before some of the
> breakpoint hit threads. If this happens the interrupted threads have
> to re-read the opcode to see if the breakpoint location no more has the
> breakpoint instruction and retry the instruction. However before it can
> detect and retry, some other thread might insert a breakpoint at that
> location. This can go in a loop.

Ok, that makes sense, but you want to put a lenghty explanation into
the comment above the synchronize_sched() call.
 
Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
