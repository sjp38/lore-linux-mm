Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7166B007E
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 05:32:35 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p6I9BPvd013007
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 05:11:25 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p6I9WWFQ147240
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 05:32:32 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6I9WSgd005663
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 06:32:29 -0300
Date: Mon, 18 Jul 2011 14:50:55 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 7/22]  7: uprobes: mmap and fork hooks.
Message-ID: <20110718092055.GA1210@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110617045000.GM4952@linux.vnet.ibm.com>
 <1308297836.13240.380.camel@twins>
 <20110617090504.GN4952@linux.vnet.ibm.com>
 <1308303665.2355.11.camel@twins>
 <1308662243.26237.144.camel@twins>
 <20110622143906.GF16471@linux.vnet.ibm.com>
 <20110624020659.GA24776@linux.vnet.ibm.com>
 <1308901324.27849.7.camel@twins>
 <20110627064502.GB24776@linux.vnet.ibm.com>
 <1309165071.6701.4.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1309165071.6701.4.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

Here is another take at locking for uprobes.

/*
 *  Register/Unregister:
 *  	- walks thro vma-rmap creates a temp list of vmas.
 *	- Cannot sleep while walking thro vma-rmap; hence temp list.
 * 	- Iterate thro the temp list and insert/delete breakpoints.
 *	- Insertion/deletion of breakpoint needs mmap_sem to be held and
 *	  dropped in the loop.
 *
 * mmap/munmap:
 *	- called with down_write(mmap_sem)
 * 	- walk thro the uprobe rbtree and create a temp list of uprobes.
 *	- Cannot sleep while walking thro rbtree; hence temp list.
 * 	- Iterate thro the temp list and insert/delete breakpoints.
 *
 * Issues:
 *	- Lock ordering issues since mmap/munmap are called with mmap_sem
 *	  held for write unlike register/unregister where they need to
 *	  held just before insertion of breakpoints.
 * 	- Cannot allocate when i_mmap_mutex is held.
 *	- Vma objects can vanish after munmap.
 *	- Multiple vmas mapping to same text area of an inode in the same mm
 *	  struct.
 *
 * Changes:
 *
 *  - Introduce uprobes_list and uprobes_vaddr in vm_area_struct.
 *    uprobes_list is a node in the temp list of vmas while
 *    registering/unregistering uprobes. uprobes_vaddr caches the vaddr to
 *    insert/remove the breakpoint.
 *
 *  - Introduce srcu to synchronize vma deletion with walking the list of
 *    vma in register/unregister_uprobe.
 *
 *  - Introduce uprobes_mmap_mutex to synchronize uprobe deletion and
 *    mmap_uprobe().
 *
 * Locking:
 *   hierarcy:
 *    --> inode->i_mutex
 *    		--> mm->mmap_sem
 *    			--> mapping->i_mmap_mutex
 *    			--> uprobes_mmap_mutex
 *    				--> treelock
 *
 *   i_mutex: serializes register/unregister on the same inode.
 *
 *   i_mmap_mutex: allows to walk the vma-rmap but cannot be held across
 *  		kzalloc.
 *
 *   mmap_sem : insert an instruction into the address-space.
 *
 *   uprobes_mmap_mutex : serializes multiple mmap_uprobes since the
 *			  same uprobe cannot be in more than one list.
 *   			: serializes walking the uprobe list with deleting
 *   			  the uprobe. (this can be achieved by taking a
 *   			  reference to uprobe while we walk).
 *
 *   treelock (spinlock) : modification/walking thro the rb tree.
 *
 *   srcu : synchronize walking the vma list with munmap.
 *
 *  Assumptions:
 *  Can sleep including sleeping for page allocations/copying original
 *  instructions while holding the srcu.
 *
 * Advantages:
 * 1. No need to drop mmap_sem.
 * 2. Now register/unregister can run in parallel except unless when uprobe
 *    gets deleted.
 *
 * Disadvantages:
 * 1. All calls to mmap_uprobe are serialized.
 * 2. Locking gets complicated with 3 mutexs, mmap_sem, treelock and srcu.
 *
 * Note:
 *      Can avoid uprobes_mmap_mutex/srcu/serializing the mmap_uprobes by
 * 	try_mutex_lock(i_mutex) followed by dropping mmap_sem; acquiring
 * 	i_mutex and mmap_sem in order and verifying the vma in both
 * 	mmap_uprobe and munmap_uprobe but Peter Zijlstra not happy with that
 * 	approach.
 */

void _unregister_uprobe(...)
{
	if (!del_consumer(...)) {	// includes tree removal on last consumer
		return;
	}
	if (uprobe->consumers)
		return;		// Not the last consumer.

	INIT_LIST_HEAD(&tmp_list);

	mutex_lock(&mapping->i_mmap_mutex);	//sync with mmap.
	vma_prio_tree_foreach() {
		list_add(&vma->uprobes_list, &tmplist);
		// set vma->uprobes_vaddr;
	}

	mutex_unlock(&mapping->i_mmap_mutex);

	srcu_read_lock(&uprobes_srcu);	// synch with munmap_uprobe.
	list_for_each_entry_safe() {
		mm = vma->vm_mm;
		vaddr = vma->uprobes_vaddr;
		// remove from list
		down_read(&mm->mmap_sem);
		remove_breakpoint();	// unconditional, if it wasn't there
		up_read(&mm->mmap_sem);
	}
	srcu_read_unlock(&uprobes_srcu, ..);

	inode->uprobes_count--;

	mutex_lock(&uprobe_mmap_mutex);	// sync with mmap_uprobe.
	delete_uprobe(uprobe);
	mutex_unlock(&uprobe_mmap_mutex);
}

int register_uprobe(...)
{
	uprobe = alloc_uprobe(...);	// find or insert in tree

	INIT_LIST_HEAD(&tmp_list);

	mutex_lock(&inode->i_mutex);	// sync with register/unregister
	if (uprobe->consumers) {
		add_consumer();
		goto put_unlock;
	}
	add_consumer();
	inode->uprobes_count++;
	mutex_lock(&mapping->i_mmap_mutex);	//sync with mmap_uprobe
	vma_prio_tree_foreach(..) {
		list_add(&vma->uprobes_list, &tmplist);
		// get mm ref, add to list blah blah
		// set vma->uprobes_vaddr;
	}

	mutex_unlock(&mapping->i_mmap_mutex);

	srcu_read_lock(&uprobes_srcu);	// synch with munmap_uprobe.
	list_for_each_entry_safe() {
		mm = vma->vm_mm;
		vaddr = vma->uprobes_vaddr;
		if (ret) {
			// del from list etc..
			//
			continue;
		}
		down_read(mm->mmap_sem);
		ret = install_breakpoint();
		up_read(..);
		// del from list etc..
		//
		if (ret && (ret == -ESRCH || ret == -EEXIST))
			ret = 0;
	}
	srcu_read_unlock(&uprobes_srcu, ..);

	if (ret)
		_unregister_uprobe();

      put_unlock:
	mutex_unlock(&inode->i_mutex);
	put_uprobe(uprobe);
	return ret;
}

void unregister_uprobe(...)
{
	mutex_lock(&inode->i_mutex);	// sync with register/unregister
	uprobe = find_uprobe();	// ref++
	_unregister_uprobe();
	mutex_unlock(&inode->i_mutex);
	put_uprobe(uprobe);
}

int mmap_uprobe(struct vm_area_struct *vma)
{
	struct list_head tmp_list;
	struct uprobe *uprobe, *u;
	struct mm_struct *mm;
	struct inode *inode;
	int ret = 0;

	if (!valid_vma(vma))
		return ret;	/* Bail-out */

	mm = vma->vm_mm;
	inode = vma->vm_file->f_mapping->host;
	if (!inode->uprobes_count)
		return ret;
	__iget(inode);

	INIT_LIST_HEAD(&tmp_list);

	mutex_lock(&uprobes_mmap_mutex);
	add_to_temp_list(vma, inode, &tmp_list);
	list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
		loff_t vaddr;
		if (!uprobe->consumer)
			continue;

		list_del(&uprobe->pending_list);
		if (ret)
			continue;

		vaddr = vma->vm_start + uprobe->offset;
		vaddr -= vma->vm_pgoff << PAGE_SHIFT;
		ret = install_breakpoint(mm, uprobe, vaddr);

		if (ret && (ret == -ESRCH || ret == -EEXIST))
			ret = 0;
	}

	mutex_unlock(&uprobes_mmap_mutex);
	iput(inode);
	return ret;
}

void munmap_uprobe(struct vm_area_struct *vma)
{
	struct list_head tmp_list;
	struct uprobe *uprobe, *u;
	struct mm_struct *mm;
	struct inode *inode;

	if (!valid_vma(vma))
		return;	/* Bail-out */

	mm = vma->vm_mm;
	inode = vma->vm_file->f_mapping->host;
	if (!inode->uprobes_count)
		return;

	list_del(&vma->uprobes_list);
	synchronize_srcu(..);	// synchronize with (un)register_uprobe

	if (!mm->uprobes_count)
		return;

//      walk thro RB tree and decrement mm->uprobes_count
	walk_rbtree_and_dec_uprobes_count();	//hold treelock.

	return;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
