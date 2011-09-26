Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 987E79000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 08:15:33 -0400 (EDT)
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 26 Sep 2011 08:15:12 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8QCEWsb092578
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 08:14:32 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8QCEN4E009799
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 09:14:32 -0300
Date: Mon, 26 Sep 2011 17:29:19 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 1/26]   uprobes: Auxillary routines to
 insert, find, delete uprobes
Message-ID: <20110926115919.GB4072@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920115949.25326.2469.sendpatchset@srdronam.in.ibm.com>
 <20110920154259.GA25610@stefanha-thinkpad.localdomain>
 <1317035918.9084.83.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1317035918.9084.83.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Stefan Hajnoczi <stefanha@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

* Peter Zijlstra <peterz@infradead.org> [2011-09-26 13:18:38]:

> On Tue, 2011-09-20 at 16:42 +0100, Stefan Hajnoczi wrote:
> > On Tue, Sep 20, 2011 at 05:29:49PM +0530, Srikar Dronamraju wrote:
> > > +static void delete_uprobe(struct uprobe *uprobe)
> > > +{
> > > +	unsigned long flags;
> > > +
> > > +	spin_lock_irqsave(&uprobes_treelock, flags);
> > > +	rb_erase(&uprobe->rb_node, &uprobes_tree);
> > > +	spin_unlock_irqrestore(&uprobes_treelock, flags);
> > > +	put_uprobe(uprobe);
> > > +	iput(uprobe->inode);
> > 
> > Use-after-free when put_uprobe() kfrees() the uprobe?
> 
> I suspect the caller still has one, and this was the reference for being
> part of the tree. But yes, that could do with a comment.
> 

Yes, the caller has a reference, However I went ahead and changed the
order of the last two statements.

> The comment near atomic_set() in __insert_uprobe() isn't too clear
> either. /* get access + drop ref */, would naively seem +1 -1 = 0,
> instead of +1 +1 = 2.
> 

Okay, Have modified the comment to /* get access + creation ref */

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
