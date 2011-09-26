Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 30D959000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 11:59:28 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8QFZFZw020911
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 11:35:15 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8QFxOUh1175638
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 11:59:24 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8QFxK0h030339
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 11:59:23 -0400
Date: Mon, 26 Sep 2011 21:14:14 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 4/26]   uprobes: Define hooks for
 mmap/munmap.
Message-ID: <20110926154414.GB13535@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920120040.25326.63549.sendpatchset@srdronam.in.ibm.com>
 <1317045191.1763.22.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1317045191.1763.22.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

> >  
> > -static struct uprobe *__find_uprobe(struct inode * inode, loff_t offset)
> > +static struct uprobe *__find_uprobe(struct inode * inode, loff_t offset,
> > +					struct rb_node **close_match)
> >  {
> >  	struct uprobe u = { .inode = inode, .offset = offset };
> >  	struct rb_node *n = uprobes_tree.rb_node;
> >  	struct uprobe *uprobe;
> > -	int match;
> > +	int match, match_inode;
> >  
> >  	while (n) {
> >  		uprobe = rb_entry(n, struct uprobe, rb_node);
> > -		match = match_uprobe(&u, uprobe);
> > +		match = match_uprobe(&u, uprobe, &match_inode);
> > +		if (close_match && match_inode)
> > +			*close_match = n;
> 
> Because:
> 
> 		if (close_match && uprobe->inode == inode)
> 
> Isn't good enough? Also, returning an rb_node just seems iffy.. 

yup this can be done. can you please elaborate on why passing back an
rb_node is an issue?

> 
> >  		if (!match) {
> >  			atomic_inc(&uprobe->ref);
> >  			return uprobe;
> 
> 
> Why not something like:
> 
> 
> +static struct uprobe *__find_uprobe(struct inode * inode, loff_t offset,
> 					bool inode_only)
> +{
>         struct uprobe u = { .inode = inode, .offset = inode_only ? 0 : offset };
> +       struct rb_node *n = uprobes_tree.rb_node;
> +       struct uprobe *uprobe;
> 	struct uprobe *ret = NULL;
> +       int match;
> +
> +       while (n) {
> +               uprobe = rb_entry(n, struct uprobe, rb_node);
> +               match = match_uprobe(&u, uprobe);
> +               if (!match) {
> 			if (!inode_only)
> 	                       atomic_inc(&uprobe->ref);
> +                       return uprobe;
> +               }
> 		if (inode_only && uprobe->inode == inode)
> 			ret = uprobe;
> +               if (match < 0)
> +                       n = n->rb_left;
> +               else
> +                       n = n->rb_right;
> +
> +       }
>         return ret;
> +}
> 

I am not comfortable with this change.
find_uprobe() was suppose to return back a uprobe if and only if
the inode and offset match, However with your approach, we end up
returning a uprobe that isnt matching and one that isnt refcounted.
Moreover if even if we have a matching uprobe, we end up sending a
unrefcounted uprobe back.

> 
> > +/*
> > + * For a given inode, build a list of probes that need to be inserted.
> > + */
> > +static void build_probe_list(struct inode *inode, struct list_head *head)
> > +{
> > +	struct uprobe *uprobe;
> > +	struct rb_node *n;
> > +	unsigned long flags;
> > +
> > +	n = uprobes_tree.rb_node;
> > +	spin_lock_irqsave(&uprobes_treelock, flags);
> > +	uprobe = __find_uprobe(inode, 0, &n);
> 
> 
> > +	/*
> > +	 * If indeed there is a probe for the inode and with offset zero,
> > +	 * then lets release its reference. (ref got thro __find_uprobe)
> > +	 */
> > +	if (uprobe)
> > +		put_uprobe(uprobe);
> 
> The above would make this ^ unneeded.
> 
> 	n = &uprobe->rb_node;
> 
> > +	for (; n; n = rb_next(n)) {
> > +		uprobe = rb_entry(n, struct uprobe, rb_node);
> > +		if (uprobe->inode != inode)
> > +			break;
> > +		list_add(&uprobe->pending_list, head);
> > +		atomic_inc(&uprobe->ref);
> > +	}
> > +	spin_unlock_irqrestore(&uprobes_treelock, flags);
> > +}
> 
> If this ever gets to be a latency issue (linear lookup under spinlock)
> you can use a double lock (mutex+spinlock) and require that modification
> acquires both but lookups can get away with either.
> 
> That way you can do the linear search using a mutex instead of the
> spinlock.
> 

Okay, 

> > +
> > +/*
> > + * Called from mmap_region.
> > + * called with mm->mmap_sem acquired.
> > + *
> > + * Return -ve no if we fail to insert probes and we cannot
> > + * bail-out.
> > + * Return 0 otherwise. i.e :
> > + *	- successful insertion of probes
> > + *	- (or) no possible probes to be inserted.
> > + *	- (or) insertion of probes failed but we can bail-out.
> > + */
> > +int mmap_uprobe(struct vm_area_struct *vma)
> > +{
> > +	struct list_head tmp_list;
> > +	struct uprobe *uprobe, *u;
> > +	struct inode *inode;
> > +	int ret = 0;
> > +
> > +	if (!valid_vma(vma))
> > +		return ret;	/* Bail-out */
> > +
> > +	inode = igrab(vma->vm_file->f_mapping->host);
> > +	if (!inode)
> > +		return ret;
> > +
> > +	INIT_LIST_HEAD(&tmp_list);
> > +	mutex_lock(&uprobes_mmap_mutex);
> > +	build_probe_list(inode, &tmp_list);
> > +	list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
> > +		loff_t vaddr;
> > +
> > +		list_del(&uprobe->pending_list);
> > +		if (!ret && uprobe->consumers) {
> > +			vaddr = vma->vm_start + uprobe->offset;
> > +			vaddr -= vma->vm_pgoff << PAGE_SHIFT;
> > +			if (vaddr < vma->vm_start || vaddr >= vma->vm_end)
> > +				continue;
> > +			ret = install_breakpoint(vma->vm_mm, uprobe);
> > +
> > +			if (ret && (ret == -ESRCH || ret == -EEXIST))
> > +				ret = 0;
> > +		}
> > +		put_uprobe(uprobe);
> > +	}
> > +
> > +	mutex_unlock(&uprobes_mmap_mutex);
> > +	iput(inode);
> > +	return ret;
> > +}
> > +
> > +static void dec_mm_uprobes_count(struct vm_area_struct *vma,
> > +		struct inode *inode)
> > +{
> > +	struct uprobe *uprobe;
> > +	struct rb_node *n;
> > +	unsigned long flags;
> > +
> > +	n = uprobes_tree.rb_node;
> > +	spin_lock_irqsave(&uprobes_treelock, flags);
> > +	uprobe = __find_uprobe(inode, 0, &n);
> > +
> > +	/*
> > +	 * If indeed there is a probe for the inode and with offset zero,
> > +	 * then lets release its reference. (ref got thro __find_uprobe)
> > +	 */
> > +	if (uprobe)
> > +		put_uprobe(uprobe);
> > +	for (; n; n = rb_next(n)) {
> > +		loff_t vaddr;
> > +
> > +		uprobe = rb_entry(n, struct uprobe, rb_node);
> > +		if (uprobe->inode != inode)
> > +			break;
> > +		vaddr = vma->vm_start + uprobe->offset;
> > +		vaddr -= vma->vm_pgoff << PAGE_SHIFT;
> > +		if (vaddr < vma->vm_start || vaddr >= vma->vm_end)
> > +			continue;
> > +		atomic_dec(&vma->vm_mm->mm_uprobes_count);
> > +	}
> > +	spin_unlock_irqrestore(&uprobes_treelock, flags);
> > +}
> > +
> > +/*
> > + * Called in context of a munmap of a vma.
> > + */
> > +void munmap_uprobe(struct vm_area_struct *vma)
> > +{
> > +	struct inode *inode;
> > +
> > +	if (!valid_vma(vma))
> > +		return;		/* Bail-out */
> > +
> > +	if (!atomic_read(&vma->vm_mm->mm_uprobes_count))
> > +		return;
> > +
> > +	inode = igrab(vma->vm_file->f_mapping->host);
> > +	if (!inode)
> > +		return;
> > +
> > +	dec_mm_uprobes_count(vma, inode);
> > +	iput(inode);
> > +	return;
> > +}
> 
> One has to wonder why mmap_uprobe() can be one function but
> munmap_uprobe() cannot.
> 

I didnt understand this comment, Can you please elaborate?
mmap_uprobe uses build_probe_list and munmap_uprobe uses
dec_mm_uprobes_count.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
