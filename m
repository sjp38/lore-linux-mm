Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 58F52900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 22:15:57 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5O2CoV9023093
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 20:12:50 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5O2Fm8g326816
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 20:15:48 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5NKFjf5028577
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 14:15:48 -0600
Date: Fri, 24 Jun 2011 07:36:59 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 7/22]  7: uprobes: mmap and fork hooks.
Message-ID: <20110624020659.GA24776@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110616032645.GF4952@linux.vnet.ibm.com>
 <1308225626.13240.34.camel@twins>
 <20110616130012.GL4952@linux.vnet.ibm.com>
 <1308248588.13240.267.camel@twins>
 <20110617045000.GM4952@linux.vnet.ibm.com>
 <1308297836.13240.380.camel@twins>
 <20110617090504.GN4952@linux.vnet.ibm.com>
 <1308303665.2355.11.camel@twins>
 <1308662243.26237.144.camel@twins>
 <20110622143906.GF16471@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110622143906.GF16471@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

> 
> so I am thinking of a solution that includes most of your ideas along
> with using i_mmap_mutex in mmap_uprobe path.
> 

Addressing Peter's comments given on irc wrt i_mmap_mutex.

/*
Changes:
1. Uses inode->i_mutex instead of uprobes_mutex.
2. Now along with vma rma walk, i_mmap_mutex is even held when we do deletion of uprobes into RB tree.
3. mmap_uprobe takes i_mmap_mutex.

Advantages:
1. No need to drop mmap_sem.
2. Now register/unregister can run in parallel.
3.
*/

void _unregister_uprobe(...)
{
	if (!del_consumer(...)) {	// includes tree removal on last consumer
		return;
	}
	if (uprobe->consumers)
		return;

	mutex_lock(&mapping->i_mmap_mutex);	//sync with mmap.
	vma_prio_tree_foreach() {
		// create list
	}

	mutex_unlock(&mapping->i_mmap_mutex);

	list_for_each_entry_safe() {
		// remove from list
		down_read(&mm->mmap_sem);
		remove_breakpoint();	// unconditional, if it wasn't there
		up_read(&mm->mmap_sem);
	}

	mutex_lock(&mapping->i_mmap_mutex);
	delete_uprobe(uprobe);
	mutex_unlock(&mapping->i_mmap_mutex);

	inode->uprobes_count--;
	mutex_unlock(&inode->i_mutex);
}

int register_uprobe(...)
{
	uprobe = alloc_uprobe(...);	// find or insert in tree

	mutex_lock(&inode->i_mutex);	// sync with register/unregister
	if (uprobe->consumers) {
		add_consumer();
		goto put_unlock;
	}
	add_consumer();
	inode->uprobes_count++;
	mutex_lock(&mapping->i_mmap_mutex);	//sync with mmap.
	vma_prio_tree_foreach(..) {
		// get mm ref, add to list blah blah
	}

	mutex_unlock(&mapping->i_mmap_mutex);
	list_for_each_entry_safe() {
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
	if (inode->uprobes_count)
		return ret;
	__iget(inode);

	INIT_LIST_HEAD(&tmp_list);

	mutex_lock(&mapping->i_mmap_mutex);
	add_to_temp_list(vma, inode, &tmp_list);
	list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
		loff_t vaddr;

		list_del(&uprobe->pending_list);
		if (ret)
			continue;

		vaddr = vma->vm_start + uprobe->offset;
		vaddr -= vma->vm_pgoff << PAGE_SHIFT;
		ret = install_breakpoint(mm, uprobe, vaddr);

		if (ret && (ret == -ESRCH || ret == -EEXIST))
			ret = 0;
	}

	mutex_unlock(&mapping->i_mmap_mutex);
	iput(inode);
	return ret;
}

int munmap_uprobe(struct vm_area_struct *vma)
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
	if (inode->uprobes_count)
		return ret;

//      walk thro RB tree and decrement mm->uprobes_count
	walk_rbtree_and_dec_uprobes_count();	//hold treelock.

	return ret;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
