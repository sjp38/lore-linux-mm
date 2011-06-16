Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DAFCF6B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 01:34:41 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5G5QEib026019
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 23:26:14 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5G5YYYr316076
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 23:34:34 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5FNYWMP025740
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 17:34:34 -0600
Date: Thu, 16 Jun 2011 10:56:39 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 4/22]  4: Uprobes: register/unregister
 probes.
Message-ID: <20110616052639.GI4952@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <20110607125900.28590.16071.sendpatchset@localhost6.localdomain6>
 <1307660606.2497.1770.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1307660606.2497.1770.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

* Peter Zijlstra <peterz@infradead.org> [2011-06-10 01:03:26]:

> On Tue, 2011-06-07 at 18:29 +0530, Srikar Dronamraju wrote:
> > +/*
> > + * There could be threads that have hit the breakpoint and are entering the
> > + * notifier code and trying to acquire the uprobes_treelock. The thread
> > + * calling delete_uprobe() that is removing the uprobe from the rb_tree can
> > + * race with these threads and might acquire the uprobes_treelock compared
> > + * to some of the breakpoint hit threads. In such a case, the breakpoint hit
> > + * threads will not find the uprobe. Finding if a "trap" instruction was
> > + * present at the interrupting address is racy. Hence provide some extra
> > + * time (by way of synchronize_sched() for breakpoint hit threads to acquire
> > + * the uprobes_treelock before the uprobe is removed from the rbtree.
> > + */
> 
> 'some' extra time doesn't really sound convincing to me. Either it is
> sufficient to avoid the race or it is not. It reads to me like: we add a
> delay so that the race mostly doesn't occur. Not good ;-)

The extra time provided is sufficient to avoid the race. So will modify
it to mean "sufficient" instead of "some".

> 
> > +static void delete_uprobe(struct uprobe *uprobe)
> > +{
> > +       unsigned long flags;
> > +
> > +       synchronize_sched();
> > +       spin_lock_irqsave(&uprobes_treelock, flags);
> > +       rb_erase(&uprobe->rb_node, &uprobes_tree);
> > +       spin_unlock_irqrestore(&uprobes_treelock, flags);
> > +       iput(uprobe->inode);
> > +} 
> 
> Also what are the uprobe lifetime rules here? Does it still exist after
> this returns?
> 
> The comment in del_consumer() that says: 'drop creation ref' worries me
> and makes me thing that is the last reference around and the uprobe will
> be freed right there, which clearly cannot happen since its not yet
> removed from the RB-tree.
> 

When del_consumer() is called in unregister_uprobe() it has atleast two
(or more if the uprobe is hit) references. One at the creation time and
the other thro find_uprobe() called in unregister_uprobe before
del_consumer. So the reference lost in del_consumer is never the last
reference.  I added a commented this as creation reference so that the
find_uprobe and the put_uprobe() before return would match.

If the comment is confusing I can delete it or reword it as suggested by
Steven Rostedt which is  /* Have caller drop the creation ref */

I would prefer to delete the comment.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
