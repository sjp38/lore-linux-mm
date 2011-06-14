Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 829B46B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 08:08:23 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5EBtREX013828
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 05:55:27 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5EC88fe051292
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 06:08:08 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5E685tT006860
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 00:08:07 -0600
Date: Tue, 14 Jun 2011 17:30:23 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 4/22]  4: Uprobes: register/unregister
 probes.
Message-ID: <20110614120023.GB4952@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <20110607125900.28590.16071.sendpatchset@localhost6.localdomain6>
 <20110613195701.GA14656@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110613195701.GA14656@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

* Oleg Nesterov <oleg@redhat.com> [2011-06-13 21:57:01]:

> On 06/07, Srikar Dronamraju wrote:
> >
> > +int register_uprobe(struct inode *inode, loff_t offset,
> > +				struct uprobe_consumer *consumer)
> > +{
> > +	struct prio_tree_iter iter;
> > +	struct list_head try_list, success_list;
> > +	struct address_space *mapping;
> > +	struct mm_struct *mm, *tmpmm;
> > +	struct vm_area_struct *vma;
> > +	struct uprobe *uprobe;
> > +	int ret = -1;
> > +
> > +	if (!inode || !consumer || consumer->next)
> > +		return -EINVAL;
> > +
> > +	if (offset > inode->i_size)
> > +		return -EINVAL;
> > +
> > +	uprobe = alloc_uprobe(inode, offset);
> > +	if (!uprobe)
> > +		return -ENOMEM;
> > +
> > +	INIT_LIST_HEAD(&try_list);
> > +	INIT_LIST_HEAD(&success_list);
> > +	mapping = inode->i_mapping;
> > +
> > +	mutex_lock(&uprobes_mutex);
> > +	if (uprobe->consumers) {
> > +		ret = 0;
> > +		goto consumers_add;
> > +	}
> > +
> > +	mutex_lock(&mapping->i_mmap_mutex);
> > +	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, 0, 0) {
> 
> I didn't actually read this patch yet, but this looks suspicious.
> Why begin == end == 0? Doesn't this mean we are ignoring the mappings
> with vm_pgoff != 0 ?
> 
> Perhaps this should be offset >> PAGE_SIZE?
> 

Okay, 
I guess you meant something like this.

	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {

where pgoff == offset >> PAGE_SIZE
Right?

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
