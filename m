Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D5FCC8D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 15:41:24 -0400 (EDT)
Date: Tue, 15 Mar 2011 20:22:50 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 4/20] 4: uprobes: Adding and remove a
 uprobe in a rb tree.
In-Reply-To: <20110315173041.GB24254@linux.vnet.ibm.com>
Message-ID: <alpine.LFD.2.00.1103151916120.2787@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6> <20110314133444.27435.50684.sendpatchset@localhost6.localdomain6> <alpine.LFD.2.00.1103151425060.2787@localhost6.localdomain6> <20110315173041.GB24254@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Tue, 15 Mar 2011, Srikar Dronamraju wrote:
> * Thomas Gleixner <tglx@linutronix.de> [2011-03-15 14:38:33]:
> > > +/*
> > > + * Find a uprobe corresponding to a given inode:offset
> > > + * Acquires treelock
> > > + */
> > > +static struct uprobe *find_uprobe(struct inode * inode, loff_t offset)
> > > +{
> > > +	struct uprobe *uprobe;
> > > +	unsigned long flags;
> > > +
> > > +	spin_lock_irqsave(&treelock, flags);
> > > +	uprobe = __find_uprobe(inode, offset, NULL);
> > > +	spin_unlock_irqrestore(&treelock, flags);
> > 
> > What's the calling context ? Do we really need a spinlock here for
> > walking the rb tree ?
> > 
> 
> find_uprobe() gets called from unregister_uprobe and on probe hit from
> uprobe_notify_resume. I am not sure if its a good idea to walk the tree
> as and when the tree is changing either because of a insertion or
> deletion of a probe.

I know that you cannot walk the tree lockless except you would use
some rcu based container for your probes.

Though my question is more whether this needs to be a spinlock or if
that could be replaced by a mutex. At least there is no reason to
disable interrupts. You cannot trap into a probe from the thread in
which you are installing/removing it.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
