Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D7F6A6B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 02:54:25 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0Q7jC3b002437
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 02:45:12 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 48183728047
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 02:54:15 -0500 (EST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0Q7sEGY439718
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 02:54:15 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0Q7sDxu028940
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 00:54:14 -0700
Date: Wed, 26 Jan 2011 13:17:37 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [RFC] [PATCH 2.6.37-rc5-tip 5/20]  5: Uprobes:
 register/unregister probes.
Message-ID: <20110126074737.GA19725@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20101216095714.23751.52601.sendpatchset@localhost6.localdomain6>
 <20101216095817.23751.76989.sendpatchset@localhost6.localdomain6>
 <1295957745.28776.723.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1295957745.28776.723.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra <peterz@infradead.org> [2011-01-25 13:15:45]:

> > +
> > +       if (atomic_read(&uprobe->ref) == 1) {
> > +               synchronize_sched();
> > +               rb_erase(&uprobe->rb_node, &uprobes_tree);
> 
> How is that safe without holding the treelock?

Right, 
Something like this should be good enuf right?

if (atomic_read(&uprobe->ref) == 1) {
	synchronize_sched();
	spin_lock_irqsave(&treelock, flags);
	rb_erase(&uprobe->rb_node, &uprobes_tree);
	spin_lock_irqrestore(&treelock, flags);
	iput(uprobe->inode);
}
	
-- 
Thanks and Regards
Srikar

PS: Last time I had goofed up with Linux-mm mailing alias. 
Hopefully this time it goes to the right list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
