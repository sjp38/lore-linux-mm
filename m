Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E25219000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 07:19:24 -0400 (EDT)
Subject: Re: [PATCH v5 3.1.0-rc4-tip 1/26]   uprobes: Auxillary routines to
 insert, find, delete uprobes
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 26 Sep 2011 13:18:38 +0200
In-Reply-To: <20110920154259.GA25610@stefanha-thinkpad.localdomain>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
	 <20110920115949.25326.2469.sendpatchset@srdronam.in.ibm.com>
	 <20110920154259.GA25610@stefanha-thinkpad.localdomain>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317035918.9084.83.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Hajnoczi <stefanha@linux.vnet.ibm.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 2011-09-20 at 16:42 +0100, Stefan Hajnoczi wrote:
> On Tue, Sep 20, 2011 at 05:29:49PM +0530, Srikar Dronamraju wrote:
> > +static void delete_uprobe(struct uprobe *uprobe)
> > +{
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(&uprobes_treelock, flags);
> > +	rb_erase(&uprobe->rb_node, &uprobes_tree);
> > +	spin_unlock_irqrestore(&uprobes_treelock, flags);
> > +	put_uprobe(uprobe);
> > +	iput(uprobe->inode);
>=20
> Use-after-free when put_uprobe() kfrees() the uprobe?

I suspect the caller still has one, and this was the reference for being
part of the tree. But yes, that could do with a comment.

The comment near atomic_set() in __insert_uprobe() isn't too clear
either. /* get access + drop ref */, would naively seem +1 -1 =3D 0,
instead of +1 +1 =3D 2.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
