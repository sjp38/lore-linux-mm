Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 352899000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 00:21:19 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8L4LDDn013681
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 22:21:13 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8L4LD4b086730
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 22:21:13 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8L4LBqG032413
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 22:21:13 -0600
Date: Wed, 21 Sep 2011 09:37:22 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 3/26]   Uprobes: register/unregister
 probes.
Message-ID: <20110921040722.GE6568@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920120022.25326.35868.sendpatchset@srdronam.in.ibm.com>
 <20110920165019.GA27959@stefanha-thinkpad.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110920165019.GA27959@stefanha-thinkpad.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Hajnoczi <stefanha@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

* Stefan Hajnoczi <stefanha@linux.vnet.ibm.com> [2011-09-20 17:50:19]:

> On Tue, Sep 20, 2011 at 05:30:22PM +0530, Srikar Dronamraju wrote:
> > +int register_uprobe(struct inode *inode, loff_t offset,
> > +				struct uprobe_consumer *consumer)
> > +{
> > +	struct uprobe *uprobe;
> > +	int ret = 0;
> > +
> > +	inode = igrab(inode);
> > +	if (!inode || !consumer || consumer->next)
> > +		return -EINVAL;
> > +
> > +	if (offset > inode->i_size)
> > +		return -EINVAL;
> > +
> > +	mutex_lock(&inode->i_mutex);
> > +	uprobe = alloc_uprobe(inode, offset);
> > +	if (!uprobe)
> > +		return -ENOMEM;
> 
> The error returns above don't iput(inode).  And inode->i_mutex stays
> locked on this return.

Yes will fix this .. by clubbing the !uprobe with the next condition.
Thanks for pointing this.

> 
> > +void unregister_uprobe(struct inode *inode, loff_t offset,
> > +				struct uprobe_consumer *consumer)
> > +{
> > +	struct uprobe *uprobe;
> > +
> > +	inode = igrab(inode);
> > +	if (!inode || !consumer)
> > +		return;
> > +
> > +	if (offset > inode->i_size)
> > +		return;
> > +
> > +	uprobe = find_uprobe(inode, offset);
> > +	if (!uprobe)
> > +		return;
> > +
> > +	if (!del_consumer(uprobe, consumer)) {
> > +		put_uprobe(uprobe);
> > +		return;
> > +	}
> 
> More returns that do not iput(inode).

Yes. will fix these too.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
