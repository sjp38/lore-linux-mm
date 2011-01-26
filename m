Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5046D6B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 03:44:23 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0Q8KhSH007068
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 03:20:43 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id BA90F728049
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 03:44:17 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0Q8iHaO2588904
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 03:44:17 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0Q8iFnW001661
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 03:44:17 -0500
Date: Wed, 26 Jan 2011 14:07:43 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [RFC] [PATCH 2.6.37-rc5-tip 4/20]  4: uprobes: Adding and
 remove a uprobe in a rb tree.
Message-ID: <20110126083743.GC19725@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20101216095714.23751.52601.sendpatchset@localhost6.localdomain6>
 <20101216095803.23751.41491.sendpatchset@localhost6.localdomain6>
 <1295957740.28776.718.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1295957740.28776.718.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Linux-mm <linux-mm@kvack.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> > +       spin_lock_irqsave(&treelock, flags);
> > +       while (*p) {
> > +               parent = *p;
> > +               u = rb_entry(parent, struct uprobe, rb_node);
> > +               if (u->inode > uprobe->inode)
> > +                       p = &(*p)->rb_left;
> > +               else if (u->inode < uprobe->inode)
> > +                       p = &(*p)->rb_right;
> > +               else {
> > +                       if (u->offset > uprobe->offset)
> > +                               p = &(*p)->rb_left;
> > +                       else if (u->offset < uprobe->offset)
> > +                               p = &(*p)->rb_right;
> > +                       else {
> > +                               atomic_inc(&u->ref);
> 
> If the lookup can find a 'dead' entry, then why can't we here?
> 

If a new user of a uprobe comes up as when the last registered user was
removing the uprobe, we keep the uprobe entry till the new user
loses interest in that uprobe.

> > +                               goto unlock_return;
> > +                       }
> > +               }
> > +       }
> > +       u = NULL;
> > +       rb_link_node(&uprobe->rb_node, parent, p);
> > +       rb_insert_color(&uprobe->rb_node, &uprobes_tree);
> > +       atomic_set(&uprobe->ref, 2);
> > +
> > +unlock_return:
> > +       spin_unlock_irqrestore(&treelock, flags);
> > +       return u;
> > +} 
> 
> It would be nice if you could merge the find and 'acquire' thing, the
> lookup is basically the same in both cases.
> 
> Also, I'm not quite sure on the name of that last function, its not a
> strict insert and what's the trailing _rb_node about? That lookup isn't
> called find_uprobe_rb_node() either is it?

Since we already have a install_uprobe, register_uprobe, I thought
insert_uprobe_rb_node would give context to that function that it was
only inserting an rb_node but not installing the actual breakpoint.
I am okay to rename it to insert_uprobe(). 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
