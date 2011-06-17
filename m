Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E4E836B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 05:13:26 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5H8oWRG011881
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 04:50:32 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5H9D6Ta1376380
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 05:13:09 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5H9D4Z6000916
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 06:13:06 -0300
Date: Fri, 17 Jun 2011 14:35:04 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 7/22]  7: uprobes: mmap and fork hooks.
Message-ID: <20110617090504.GN4952@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <20110607125931.28590.12362.sendpatchset@localhost6.localdomain6>
 <1308161486.2171.61.camel@laptop>
 <20110616032645.GF4952@linux.vnet.ibm.com>
 <1308225626.13240.34.camel@twins>
 <20110616130012.GL4952@linux.vnet.ibm.com>
 <1308248588.13240.267.camel@twins>
 <20110617045000.GM4952@linux.vnet.ibm.com>
 <1308297836.13240.380.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1308297836.13240.380.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

* Peter Zijlstra <peterz@infradead.org> [2011-06-17 10:03:56]:

> On Fri, 2011-06-17 at 10:20 +0530, Srikar Dronamraju wrote:
> > > 
> > > void __unregister_uprobe(...)
> > > {
> > >   uprobe = find_uprobe(); // ref++
> > >   if (delete_consumer(...)); // includes tree removal on last consumer
> > >                              // implies we own the last ref
> > >      return; // consumers
> > > 
> > >   vma_prio_tree_foreach() {
> > >      // create list
> > >   }
> > > 
> > >   list_for_each_entry_safe() {
> > >     // remove from list
> > >     remove_breakpoint(); // unconditional, if it wasn't there
> > >                          // its a nop anyway, can't get any new
> > >                          // new probes on account of holding
> > >                          // uprobes_mutex and mmap() doesn't see
> > >                          // it due to tree removal.
> > >   }
> > > }
> > > 
> > 
> > This would have a bigger race.
> > A breakpoint might be hit by which time the node is removed and we
> > have no way to find out the uprobe. So we deliver an extra TRAP to the
> > app.
> 
> Gah indeed. Back to the drawing board for me.
> 
> > > int mmap_uprobe(...)
> > > {
> > >   spin_lock(&uprobes_treelock);
> > >   for_each_probe_in_inode() {
> > >     // create list;

Here again if we have multiple mmaps for the same inode occuring on two
process contexts (I mean two different mm's), we have to manage how we
add the same uprobe to more than one list. Atleast my current
uprobe->pending_list wouldnt work.

> > >   }
> > >   spin_unlock(..);
> > > 
> > >   list_for_each_entry_safe() {
> > >     // remove from list
> > >     ret = install_breakpoint();
> > >     if (ret)
> > >       goto fail;
> > >     if (!uprobe_still_there()) // takes treelock
> > >       remove_breakpoint();
> > >   }
> > > 
> > >   return 0;
> > > 
> > > fail:
> > >   list_for_each_entry_safe() {
> > >     // destroy list
> > >   }
> > >   return ret;
> > > }
> > > 
> > 
> > 
> > register_uprobe will race with mmap_uprobe's first pass.
> > So we might end up with a vma that doesnot have a breakpoint inserted
> > but inserted in all other vma that map to the same inode.
> 
> I'm not seeing this though, if mmap_uprobe() is before register_uprobe()
> inserts the probe in the tree, the vma is already in the rmap and
> register_uprobe() will find it in its vma walk. If its after,
> mmap_uprobe() will find it and install, if a concurrent
> register_uprobe()'s vma walk also finds it, it will -EEXISTS and ignore
> the error.
> 

You are right here. 

What happens if the register_uprobe comes first and walks around the
vmas, Between mmap comes in does the insertion including the second pass
and returns.  register_uprobe now finds that it cannot insert breakpoint
on one of the vmas and hence has to roll-back. The vma on which
mmap_uprobe inserted will not be in the list of vmas from which we try
to remove the breakpoint.


How about something like this:

/* Change from previous time:
 * - add a atomic counter to inode (this is optional)
 * - trylock first.
 *   - take down_write instead of down_read if we drop mmap_sem
 *   - no releasing mmap_sem second time since we take a down_write.
 */

int mmap_uprobe(struct vm_area_struct *vma)
{
	struct list_head tmp_list;
	struct uprobe *uprobe, *u;
	struct mm_struct *mm;
	struct inode *inode;
	unsigned long start, pgoff;
	int ret = 0;

	if (!valid_vma(vma))
		return ret;     /* Bail-out */

	inode = vma->vm_file->f_mapping->host;
	if (!atomic_read(&inode->uprobes_count))
		return ret;

	INIT_LIST_HEAD(&tmp_list);

	mm = vma->vm_mm;
	start = vma->vm_start;
	pgoff = vma->vm_pgoff;
	__iget(inode);

	if (!mutex_trylock(uprobes_mutex)) {

		/*
		 * Unable to get uprobes_mutex; Probably contending with
		 * someother thread. Drop mmap_sem; acquire uprobes_mutex
		 * and mmap_sem and then verify vma.
		 */

		up_write(&mm->mmap_sem);
		mutex_lock&(uprobes_mutex);
		down_write(&mm->mmap_sem);
		vma = find_vma(mm, start);
		/* Not the same vma */
		if (!vma || vma->vm_start != start ||
				vma->vm_pgoff != pgoff || !valid_vma(vma) ||
				inode->i_mapping != vma->vm_file->f_mapping)
			goto mmap_out;
	}

	add_to_temp_list(vma, inode, &tmp_list);
	list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
		loff_t vaddr;

		list_del(&uprobe->pending_list);
		if (ret)
			continue;

		vaddr = vma->vm_start + uprobe->offset;
		vaddr -= vma->vm_pgoff << PAGE_SHIFT;
		if (vaddr < vma->vm_start || vaddr >= vma->vm_end)
			/* Not in this vma */
			continue;
		if (vaddr > TASK_SIZE)
			/*
			 * We cannot have a virtual address that is
			 * greater than TASK_SIZE
			 */
			continue;
		ret = install_breakpoint(mm, uprobe, vaddr);

		if (ret && (ret == -ESRCH || ret == -EEXIST))
			ret = 0;
        }

mmap_out:
	mutex_unlock(&uprobes_mutex);
	iput(inode);
	return ret;
}

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
