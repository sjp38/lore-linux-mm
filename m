Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 824738D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 09:38:57 -0400 (EDT)
Date: Tue, 15 Mar 2011 14:38:33 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 4/20] 4: uprobes: Adding and remove a
 uprobe in a rb tree.
In-Reply-To: <20110314133444.27435.50684.sendpatchset@localhost6.localdomain6>
Message-ID: <alpine.LFD.2.00.1103151425060.2787@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6> <20110314133444.27435.50684.sendpatchset@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, 14 Mar 2011, Srikar Dronamraju wrote:
>  
> +static int valid_vma(struct vm_area_struct *vma)

  bool perpaps ?

> +{
> +	if (!vma->vm_file)
> +		return 0;
> +
> +	if ((vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)) ==
> +						(VM_READ|VM_EXEC))

Looks more correct than the code it replaces :)

> +		return 1;
> +
> +	return 0;
> +}
> +

> +static struct rb_root uprobes_tree = RB_ROOT;
> +static DEFINE_MUTEX(uprobes_mutex);
> +static DEFINE_SPINLOCK(treelock);

Why do you need a mutex and a spinlock ? Also the mutex is not
referenced.

> +static int match_inode(struct uprobe *uprobe, struct inode *inode,
> +						struct rb_node **p)
> +{
> +	struct rb_node *n = *p;
> +
> +	if (inode < uprobe->inode)
> +		*p = n->rb_left;
> +	else if (inode > uprobe->inode)
> +		*p = n->rb_right;
> +	else
> +		return 1;
> +	return 0;
> +}
> +
> +static int match_offset(struct uprobe *uprobe, loff_t offset,
> +						struct rb_node **p)
> +{
> +	struct rb_node *n = *p;
> +
> +	if (offset < uprobe->offset)
> +		*p = n->rb_left;
> +	else if (offset > uprobe->offset)
> +		*p = n->rb_right;
> +	else
> +		return 1;
> +	return 0;
> +}
> +
> +
> +/* Called with treelock held */
> +static struct uprobe *__find_uprobe(struct inode * inode,
> +			 loff_t offset, struct rb_node **near_match)
> +{
> +	struct rb_node *n = uprobes_tree.rb_node;
> +	struct uprobe *uprobe, *u = NULL;
> +
> +	while (n) {
> +		uprobe = rb_entry(n, struct uprobe, rb_node);
> +		if (match_inode(uprobe, inode, &n)) {
> +			if (near_match)
> +				*near_match = n;
> +			if (match_offset(uprobe, offset, &n)) {
> +				atomic_inc(&uprobe->ref);
> +				u = uprobe;
> +				break;
> +			}
> +		}
> +	}
> +	return u;
> +}
> +
> +/*
> + * Find a uprobe corresponding to a given inode:offset
> + * Acquires treelock
> + */
> +static struct uprobe *find_uprobe(struct inode * inode, loff_t offset)
> +{
> +	struct uprobe *uprobe;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&treelock, flags);
> +	uprobe = __find_uprobe(inode, offset, NULL);
> +	spin_unlock_irqrestore(&treelock, flags);

What's the calling context ? Do we really need a spinlock here for
walking the rb tree ?

> +
> +/* Should be called lock-less */

-ENOPARSE

> +static void put_uprobe(struct uprobe *uprobe)
> +{
> +	if (atomic_dec_and_test(&uprobe->ref))
> +		kfree(uprobe);
> +}
> +
> +static struct uprobe *uprobes_add(struct inode *inode, loff_t offset)
> +{
> +	struct uprobe *uprobe, *cur_uprobe;
> +
> +	__iget(inode);
> +	uprobe = kzalloc(sizeof(struct uprobe), GFP_KERNEL);
> +
> +	if (!uprobe) {
> +		iput(inode);
> +		return NULL;
> +	}

Please move the __iget() after the kzalloc()

> +	uprobe->inode = inode;
> +	uprobe->offset = offset;
> +
> +	/* add to uprobes_tree, sorted on inode:offset */
> +	cur_uprobe = insert_uprobe(uprobe);
> +
> +	/* a uprobe exists for this inode:offset combination*/
> +	if (cur_uprobe) {
> +		kfree(uprobe);
> +		uprobe = cur_uprobe;
> +		iput(inode);
> +	} else
> +		init_rwsem(&uprobe->consumer_rwsem);

Please init stuff _before_ inserting not afterwards.

> +
> +	return uprobe;
> +}
> +
> +/* Acquires uprobe->consumer_rwsem */
> +static void handler_chain(struct uprobe *uprobe, struct pt_regs *regs)
> +{
> +	struct uprobe_consumer *consumer;
> +
> +	down_read(&uprobe->consumer_rwsem);
> +	consumer = uprobe->consumers;
> +	while (consumer) {
> +		if (!consumer->filter || consumer->filter(consumer, current))
> +			consumer->handler(consumer, regs);
> +
> +		consumer = consumer->next;
> +	}
> +	up_read(&uprobe->consumer_rwsem);
> +}
> +
> +/* Acquires uprobe->consumer_rwsem */
> +static void add_consumer(struct uprobe *uprobe,
> +				struct uprobe_consumer *consumer)
> +{
> +	down_write(&uprobe->consumer_rwsem);
> +	consumer->next = uprobe->consumers;
> +	uprobe->consumers = consumer;
> +	up_write(&uprobe->consumer_rwsem);
> +	return;

  pointless return

> +}
> +
> +/* Acquires uprobe->consumer_rwsem */

I'd prefer a comment about the return code over this redundant
information.

> +static int del_consumer(struct uprobe *uprobe,
> +				struct uprobe_consumer *consumer)
> +{

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
