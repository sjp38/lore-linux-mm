Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B273F8D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 13:36:51 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2FHUDX2021744
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 11:30:13 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2FHajGq098964
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 11:36:45 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2FHagRN020996
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 11:36:45 -0600
Date: Tue, 15 Mar 2011 23:00:41 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 4/20] 4: uprobes: Adding and remove a
 uprobe in a rb tree.
Message-ID: <20110315173041.GB24254@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
 <20110314133444.27435.50684.sendpatchset@localhost6.localdomain6>
 <alpine.LFD.2.00.1103151425060.2787@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1103151425060.2787@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

* Thomas Gleixner <tglx@linutronix.de> [2011-03-15 14:38:33]:

> On Mon, 14 Mar 2011, Srikar Dronamraju wrote:
> >  
> > +static int valid_vma(struct vm_area_struct *vma)
> 
>   bool perpaps ?

Okay, 

> 
> > +{
> > +	if (!vma->vm_file)
> > +		return 0;
> > +
> > +	if ((vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)) ==
> > +						(VM_READ|VM_EXEC))
> 
> Looks more correct than the code it replaces :)

Yes, Steven Rostedt has already pointed this out.

> 
> > +		return 1;
> > +
> > +	return 0;
> > +}
> > +
> 
> > +static struct rb_root uprobes_tree = RB_ROOT;
> > +static DEFINE_MUTEX(uprobes_mutex);
> > +static DEFINE_SPINLOCK(treelock);
> 
> Why do you need a mutex and a spinlock ? Also the mutex is not
> referenced.

We can move the mutex to the next patch, (i.e register/unregister
patch), where it gets used. mutex for now serializes
register_uprobe/unregister_uprobe/mmap_uprobe.
This mutex is the one that guards mm->uprobes_list. 

> 
> > +/*
> > + * Find a uprobe corresponding to a given inode:offset
> > + * Acquires treelock
> > + */
> > +static struct uprobe *find_uprobe(struct inode * inode, loff_t offset)
> > +{
> > +	struct uprobe *uprobe;
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(&treelock, flags);
> > +	uprobe = __find_uprobe(inode, offset, NULL);
> > +	spin_unlock_irqrestore(&treelock, flags);
> 
> What's the calling context ? Do we really need a spinlock here for
> walking the rb tree ?
> 

find_uprobe() gets called from unregister_uprobe and on probe hit from
uprobe_notify_resume. I am not sure if its a good idea to walk the tree
as and when the tree is changing either because of a insertion or
deletion of a probe.

> > +
> > +/* Should be called lock-less */
> 
> -ENOPARSE
> 
> > +static void put_uprobe(struct uprobe *uprobe)
> > +{
> > +	if (atomic_dec_and_test(&uprobe->ref))
> > +		kfree(uprobe);
> > +}
> > +
> > +static struct uprobe *uprobes_add(struct inode *inode, loff_t offset)
> > +{
> > +	struct uprobe *uprobe, *cur_uprobe;
> > +
> > +	__iget(inode);
> > +	uprobe = kzalloc(sizeof(struct uprobe), GFP_KERNEL);
> > +
> > +	if (!uprobe) {
> > +		iput(inode);
> > +		return NULL;
> > +	}
> 
> Please move the __iget() after the kzalloc()

Okay.

> 
> > +	uprobe->inode = inode;
> > +	uprobe->offset = offset;
> > +
> > +	/* add to uprobes_tree, sorted on inode:offset */
> > +	cur_uprobe = insert_uprobe(uprobe);
> > +
> > +	/* a uprobe exists for this inode:offset combination*/
> > +	if (cur_uprobe) {
> > +		kfree(uprobe);
> > +		uprobe = cur_uprobe;
> > +		iput(inode);
> > +	} else
> > +		init_rwsem(&uprobe->consumer_rwsem);
> 
> Please init stuff _before_ inserting not afterwards.

Okay. 

> 
> > +
> > +	return uprobe;
> > +}
> > +
> > +/* Acquires uprobe->consumer_rwsem */
> > +static void handler_chain(struct uprobe *uprobe, struct pt_regs *regs)
> > +{
> > +	struct uprobe_consumer *consumer;
> > +
> > +	down_read(&uprobe->consumer_rwsem);
> > +	consumer = uprobe->consumers;
> > +	while (consumer) {
> > +		if (!consumer->filter || consumer->filter(consumer, current))
> > +			consumer->handler(consumer, regs);
> > +
> > +		consumer = consumer->next;
> > +	}
> > +	up_read(&uprobe->consumer_rwsem);
> > +}
> > +
> > +/* Acquires uprobe->consumer_rwsem */
> > +static void add_consumer(struct uprobe *uprobe,
> > +				struct uprobe_consumer *consumer)
> > +{
> > +	down_write(&uprobe->consumer_rwsem);
> > +	consumer->next = uprobe->consumers;
> > +	uprobe->consumers = consumer;
> > +	up_write(&uprobe->consumer_rwsem);
> > +	return;
> 
>   pointless return

Okay,

> 
> > +}
> > +
> > +/* Acquires uprobe->consumer_rwsem */
> 
> I'd prefer a comment about the return code over this redundant
> information.
> 

Okay, 

> > +static int del_consumer(struct uprobe *uprobe,
> > +				struct uprobe_consumer *consumer)
> > +{

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
