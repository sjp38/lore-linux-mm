Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id BC13B900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 10:48:23 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5MEU0gY020472
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 08:30:00 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5MElwKh101030
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 08:48:01 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5M8lTBl030636
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 02:47:30 -0600
Date: Wed, 22 Jun 2011 20:09:06 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 7/22]  7: uprobes: mmap and fork hooks.
Message-ID: <20110622143906.GF16471@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1308161486.2171.61.camel@laptop>
 <20110616032645.GF4952@linux.vnet.ibm.com>
 <1308225626.13240.34.camel@twins>
 <20110616130012.GL4952@linux.vnet.ibm.com>
 <1308248588.13240.267.camel@twins>
 <20110617045000.GM4952@linux.vnet.ibm.com>
 <1308297836.13240.380.camel@twins>
 <20110617090504.GN4952@linux.vnet.ibm.com>
 <1308303665.2355.11.camel@twins>
 <1308662243.26237.144.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1308662243.26237.144.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

* Peter Zijlstra <peterz@infradead.org> [2011-06-21 15:17:23]:

> On Fri, 2011-06-17 at 11:41 +0200, Peter Zijlstra wrote:
> > 
> > On thing I was thinking of to fix that initial problem of spurious traps
> > was to leave the uprobe in the tree but skip all probes without
> > consumers in mmap_uprobe().
> 
> Can you find fault with using __unregister_uprobe() as a cleanup path
> for __register_uprobe() so that we do a second vma-rmap walk, and
> ignoring empty probes on uprobe_mmap()?

It gets a little complicated to handle simultaneous mmaps of the same
inode/file on different processes. 

- Same uprobe cannot be in two different temporary lists at the same
  time. So we have to serialize the mmap_uprobe hook.
  
- If we use auxillary structures that refers to uprobes as nodes of
  tmplist, we dont know how many of them to preallocate. We cannot allocate
  on demand since we traverse RB tree with uprobes_treelock.

> 
> We won't get spurious traps because the empty (no consumers) uprobe is
> still in the tree, we won't get any 'lost' probe insn because the
> cleanup does a second vma-rmap walk which will include the new mmap().
> And double probe insertion is harmless.
> 

so I am thinking of a solution that includes most of your ideas along
with using i_mmap_mutex in mmap_uprobe path.

/*
Changes:
1. Uses inode->i_mutex instead of uprobes_mutex. (This is optional).
2. Now along with vma rma walk, i_mmap_mutex is even held when we do deletion of uprobes into RB tree.
3. mmap_uprobe takes i_mmap_mutex.
4. inode->uprobes_count ( Again this is optional.)


Advantages:
1. No need to drop mmap_sem.
2. Now register/unregister can run in parallel. (iff we use i_mutex);
3. No need to take extra reference to uprobe in mmap_uprobe().
*/

void _unregister_uprobe(...)
{
	if (!del_consumer(...)) {	// includes tree removal on last consumer
		return;
	}
	if (uprobe->consumers)
		return;

	mutex_lock(&inode->i_map_mutex);	//sync with mmap.
	vma_prio_tree_foreach() {
		// create list
	}

	mutex_unlock(&inode->i_map_mutex);

	list_for_each_entry_safe() {
		// remove from list
		down_read(&mm->mmap_sem);
		remove_breakpoint();	// unconditional, if it wasn't there
		up_read(&mm->mmap_sem);
	}

	mutex_lock(&inode->i_mmap_mutex);
	delete_uprobe(uprobe);
	mutex_unlock(&inode->i_mmap_mutex);

	inode->uprobes_count --;
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
	inode->uprobes_count ++;
	mutex_lock(&inode->i_map_mutex);	//sync with mmap.
	vma_prio_tree_foreach(..) {
		// get mm ref, add to list blah blah
	}

	mutex_unlock(&inode->i_map_mutex);
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

	if (ret) {
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

	mutex_lock(&inode->i_map_mutex);
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

	mutex_unlock(&inode->i_map_mutex);
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


//	walk thro RB tree and decrement mm->uprobes_count
	walk_rbtree_and_dec_uprobes_count(); //hold treelock.

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
