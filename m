Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8C11F6B0139
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 02:54:19 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5R6TaIg013267
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 02:29:36 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5R6sBnY440992
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 02:54:11 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5R6s96t004498
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 02:54:11 -0400
Date: Mon, 27 Jun 2011 12:15:02 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 7/22]  7: uprobes: mmap and fork hooks.
Message-ID: <20110627064502.GB24776@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110616130012.GL4952@linux.vnet.ibm.com>
 <1308248588.13240.267.camel@twins>
 <20110617045000.GM4952@linux.vnet.ibm.com>
 <1308297836.13240.380.camel@twins>
 <20110617090504.GN4952@linux.vnet.ibm.com>
 <1308303665.2355.11.camel@twins>
 <1308662243.26237.144.camel@twins>
 <20110622143906.GF16471@linux.vnet.ibm.com>
 <20110624020659.GA24776@linux.vnet.ibm.com>
 <1308901324.27849.7.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1308901324.27849.7.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

> > 	mutex_lock(&mapping->i_mmap_mutex);
> > 	delete_uprobe(uprobe);
> > 	mutex_unlock(&mapping->i_mmap_mutex);
> > 
> > 	inode->uprobes_count--;
> > 	mutex_unlock(&inode->i_mutex);
> 
> Right, so this lonesome unlock got me puzzled for a while, I always find
> it best not to do asymmetric locking like this, keep the lock and unlock
> in the same function.
> 

Okay, will do.

> > }
> > 
> > int register_uprobe(...)
> > {
> > 	uprobe = alloc_uprobe(...);	// find or insert in tree
> > 
> > 	mutex_lock(&inode->i_mutex);	// sync with register/unregister
> > 	if (uprobe->consumers) {
> > 		add_consumer();
> > 		goto put_unlock;
> > 	}
> > 	add_consumer();
> > 	inode->uprobes_count++;
> > 	mutex_lock(&mapping->i_mmap_mutex);	//sync with mmap.
> > 	vma_prio_tree_foreach(..) {
> > 		// get mm ref, add to list blah blah
> > 	}
> > 
> > 	mutex_unlock(&mapping->i_mmap_mutex);
> > 	list_for_each_entry_safe() {
> > 		if (ret) {
> > 			// del from list etc..
> > 			//
> > 			continue;
> > 		}
> > 		down_read(mm->mmap_sem);
> > 		ret = install_breakpoint();
> > 		up_read(..);
> > 		// del from list etc..
> > 		//
> > 		if (ret && (ret == -ESRCH || ret == -EEXIST))
> > 			ret = 0;
> > 	}
> > 
> > 	if (ret)
> > 		_unregister_uprobe();
> > 
> >       put_unlock:
> > 	mutex_unlock(&inode->i_mutex);
> 
> You see, now this is a double unlock

hmm . .will correct this.

> 
> > 	put_uprobe(uprobe);
> > 	return ret;
> > }
> > 
> > void unregister_uprobe(...)
> > {
> > 	mutex_lock(&inode->i_mutex);	// sync with register/unregister
> > 	uprobe = find_uprobe();	// ref++
> > 	_unregister_uprobe();
> > 	mutex_unlock(&inode->i_mutex);
> 
> idem
> 
> > 	put_uprobe(uprobe);
> > }
> > 
> > int mmap_uprobe(struct vm_area_struct *vma)
> > {
> > 	struct list_head tmp_list;
> > 	struct uprobe *uprobe, *u;
> > 	struct mm_struct *mm;
> > 	struct inode *inode;
> > 	int ret = 0;
> > 
> > 	if (!valid_vma(vma))
> > 		return ret;	/* Bail-out */
> > 
> > 	mm = vma->vm_mm;
> > 	inode = vma->vm_file->f_mapping->host;
> > 	if (inode->uprobes_count)
> > 		return ret;
> > 	__iget(inode);
> > 
> > 	INIT_LIST_HEAD(&tmp_list);
> > 
> > 	mutex_lock(&mapping->i_mmap_mutex);
> > 	add_to_temp_list(vma, inode, &tmp_list);
> > 	list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
> > 		loff_t vaddr;
> > 
> > 		list_del(&uprobe->pending_list);
> > 		if (ret)
> > 			continue;
> > 
> > 		vaddr = vma->vm_start + uprobe->offset;
> > 		vaddr -= vma->vm_pgoff << PAGE_SHIFT;
> > 		ret = install_breakpoint(mm, uprobe, vaddr);
> 
> Right, so this is the problem, you cannot do allocations under
> i_mmap_mutex, however I think you can under i_mutex.

I didnt know that we cannot do allocations under i_mmap_mutex.
Why is this? 

I cant take i_mutex, because we would have already held
down_write(mmap_sem) here. 


> 
> > 		if (ret && (ret == -ESRCH || ret == -EEXIST))
> > 			ret = 0;
> > 	}
> > 
> > 	mutex_unlock(&mapping->i_mmap_mutex);
> > 	iput(inode);
> > 	return ret;
> > }
> > 
> > int munmap_uprobe(struct vm_area_struct *vma)
> > {
> > 	struct list_head tmp_list;
> > 	struct uprobe *uprobe, *u;
> > 	struct mm_struct *mm;
> > 	struct inode *inode;
> > 	int ret = 0;
> > 
> > 	if (!valid_vma(vma))
> > 		return ret;	/* Bail-out */
> > 
> > 	mm = vma->vm_mm;
> > 	inode = vma->vm_file->f_mapping->host;
> > 	if (inode->uprobes_count)
> > 		return ret;
> 
> Should that be !->uprobes_count?

Yes it should be !inode->uprobes_count.
(both here and in mmap_uprobe)

> 
> 

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
