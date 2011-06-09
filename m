Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8CEF5900119
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 18:59:57 -0400 (EDT)
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by merlin.infradead.org with esmtps (Exim 4.76 #1 (Red Hat Linux))
	id 1QUoCh-0004kq-D7
	for linux-mm@kvack.org; Thu, 09 Jun 2011 22:59:55 +0000
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1QUoCg-0007BK-Rc
	for linux-mm@kvack.org; Thu, 09 Jun 2011 22:59:55 +0000
Subject: Re: [PATCH v4 3.0-rc2-tip 4/22]  4: Uprobes: register/unregister
 probes.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110607125900.28590.16071.sendpatchset@localhost6.localdomain6>
References: 
	 <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
	 <20110607125900.28590.16071.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 10 Jun 2011 01:03:26 +0200
Message-ID: <1307660606.2497.1770.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2011-06-07 at 18:29 +0530, Srikar Dronamraju wrote:
> +/*
> + * There could be threads that have hit the breakpoint and are entering the
> + * notifier code and trying to acquire the uprobes_treelock. The thread
> + * calling delete_uprobe() that is removing the uprobe from the rb_tree can
> + * race with these threads and might acquire the uprobes_treelock compared
> + * to some of the breakpoint hit threads. In such a case, the breakpoint hit
> + * threads will not find the uprobe. Finding if a "trap" instruction was
> + * present at the interrupting address is racy. Hence provide some extra
> + * time (by way of synchronize_sched() for breakpoint hit threads to acquire
> + * the uprobes_treelock before the uprobe is removed from the rbtree.
> + */

'some' extra time doesn't really sound convincing to me. Either it is
sufficient to avoid the race or it is not. It reads to me like: we add a
delay so that the race mostly doesn't occur. Not good ;-)

> +static void delete_uprobe(struct uprobe *uprobe)
> +{
> +       unsigned long flags;
> +
> +       synchronize_sched();
> +       spin_lock_irqsave(&uprobes_treelock, flags);
> +       rb_erase(&uprobe->rb_node, &uprobes_tree);
> +       spin_unlock_irqrestore(&uprobes_treelock, flags);
> +       iput(uprobe->inode);
> +} 

Also what are the uprobe lifetime rules here? Does it still exist after
this returns?

The comment in del_consumer() that says: 'drop creation ref' worries me
and makes me thing that is the last reference around and the uprobe will
be freed right there, which clearly cannot happen since its not yet
removed from the RB-tree.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
