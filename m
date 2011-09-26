Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id ABAE89000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 08:17:39 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8QBrRG8029354
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 07:53:27 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8QCHbZY262322
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 08:17:37 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8QCHYJu008574
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 08:17:37 -0400
Date: Mon, 26 Sep 2011 17:32:29 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 1/26]   uprobes: Auxillary routines to
 insert, find, delete uprobes
Message-ID: <20110926120229.GC4072@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920115949.25326.2469.sendpatchset@srdronam.in.ibm.com>
 <1317035920.9084.84.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1317035920.9084.84.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

* Peter Zijlstra <peterz@infradead.org> [2011-09-26 13:18:40]:

> On Tue, 2011-09-20 at 17:29 +0530, Srikar Dronamraju wrote:
> > +static struct uprobe *__insert_uprobe(struct uprobe *uprobe)
> > +{
> > +       struct rb_node **p = &uprobes_tree.rb_node;
> > +       struct rb_node *parent = NULL;
> > +       struct uprobe *u;
> > +       int match;
> > +
> > +       while (*p) {
> > +               parent = *p;
> > +               u = rb_entry(parent, struct uprobe, rb_node);
> > +               match = match_uprobe(uprobe, u);
> > +               if (!match) {
> > +                       atomic_inc(&u->ref);
> > +                       return u;
> > +               }
> > +
> > +               if (match < 0)
> > +                       p = &parent->rb_left;
> > +               else
> > +                       p = &parent->rb_right;
> > +
> > +       }
> > +       u = NULL;
> > +       rb_link_node(&uprobe->rb_node, parent, p);
> > +       rb_insert_color(&uprobe->rb_node, &uprobes_tree);
> > +       /* get access + drop ref */
> > +       atomic_set(&uprobe->ref, 2);
> > +       return u;
> > +} 
> 
> If you ever want to make a 'lockless' lookup work you need to set the
> refcount of the new object before its fully visible, instead of after.
> 

Agree, 

> Now much of a problem now since its fully serialized by that
> uprobes_treelock thing.
> 

Will stick with this for now; If and when we do a lockless lookup we
could fix this.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
