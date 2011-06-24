Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 76DD9900194
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 03:43:15 -0400 (EDT)
Subject: Re: [PATCH v4 3.0-rc2-tip 7/22]  7: uprobes: mmap and fork hooks.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110624020659.GA24776@linux.vnet.ibm.com>
References: <20110616032645.GF4952@linux.vnet.ibm.com>
	 <1308225626.13240.34.camel@twins>
	 <20110616130012.GL4952@linux.vnet.ibm.com>
	 <1308248588.13240.267.camel@twins>
	 <20110617045000.GM4952@linux.vnet.ibm.com>
	 <1308297836.13240.380.camel@twins>
	 <20110617090504.GN4952@linux.vnet.ibm.com> <1308303665.2355.11.camel@twins>
	 <1308662243.26237.144.camel@twins>
	 <20110622143906.GF16471@linux.vnet.ibm.com>
	 <20110624020659.GA24776@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 24 Jun 2011 09:42:04 +0200
Message-ID: <1308901324.27849.7.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 2011-06-24 at 07:36 +0530, Srikar Dronamraju wrote:
> >=20
> > so I am thinking of a solution that includes most of your ideas along
> > with using i_mmap_mutex in mmap_uprobe path.
> >=20
>=20
> Addressing Peter's comments given on irc wrt i_mmap_mutex.
>=20

> void _unregister_uprobe(...)
> {
> 	if (!del_consumer(...)) {	// includes tree removal on last consumer
> 		return;
> 	}
> 	if (uprobe->consumers)
> 		return;
>=20
> 	mutex_lock(&mapping->i_mmap_mutex);	//sync with mmap.
> 	vma_prio_tree_foreach() {
> 		// create list
> 	}
>=20
> 	mutex_unlock(&mapping->i_mmap_mutex);
>=20
> 	list_for_each_entry_safe() {
> 		// remove from list
> 		down_read(&mm->mmap_sem);
> 		remove_breakpoint();	// unconditional, if it wasn't there
> 		up_read(&mm->mmap_sem);
> 	}
>=20
> 	mutex_lock(&mapping->i_mmap_mutex);
> 	delete_uprobe(uprobe);
> 	mutex_unlock(&mapping->i_mmap_mutex);
>=20
> 	inode->uprobes_count--;
> 	mutex_unlock(&inode->i_mutex);

Right, so this lonesome unlock got me puzzled for a while, I always find
it best not to do asymmetric locking like this, keep the lock and unlock
in the same function.

> }
>=20
> int register_uprobe(...)
> {
> 	uprobe =3D alloc_uprobe(...);	// find or insert in tree
>=20
> 	mutex_lock(&inode->i_mutex);	// sync with register/unregister
> 	if (uprobe->consumers) {
> 		add_consumer();
> 		goto put_unlock;
> 	}
> 	add_consumer();
> 	inode->uprobes_count++;
> 	mutex_lock(&mapping->i_mmap_mutex);	//sync with mmap.
> 	vma_prio_tree_foreach(..) {
> 		// get mm ref, add to list blah blah
> 	}
>=20
> 	mutex_unlock(&mapping->i_mmap_mutex);
> 	list_for_each_entry_safe() {
> 		if (ret) {
> 			// del from list etc..
> 			//
> 			continue;
> 		}
> 		down_read(mm->mmap_sem);
> 		ret =3D install_breakpoint();
> 		up_read(..);
> 		// del from list etc..
> 		//
> 		if (ret && (ret =3D=3D -ESRCH || ret =3D=3D -EEXIST))
> 			ret =3D 0;
> 	}
>=20
> 	if (ret)
> 		_unregister_uprobe();
>=20
>       put_unlock:
> 	mutex_unlock(&inode->i_mutex);

You see, now this is a double unlock

> 	put_uprobe(uprobe);
> 	return ret;
> }
>=20
> void unregister_uprobe(...)
> {
> 	mutex_lock(&inode->i_mutex);	// sync with register/unregister
> 	uprobe =3D find_uprobe();	// ref++
> 	_unregister_uprobe();
> 	mutex_unlock(&inode->i_mutex);

idem

> 	put_uprobe(uprobe);
> }
>=20
> int mmap_uprobe(struct vm_area_struct *vma)
> {
> 	struct list_head tmp_list;
> 	struct uprobe *uprobe, *u;
> 	struct mm_struct *mm;
> 	struct inode *inode;
> 	int ret =3D 0;
>=20
> 	if (!valid_vma(vma))
> 		return ret;	/* Bail-out */
>=20
> 	mm =3D vma->vm_mm;
> 	inode =3D vma->vm_file->f_mapping->host;
> 	if (inode->uprobes_count)
> 		return ret;
> 	__iget(inode);
>=20
> 	INIT_LIST_HEAD(&tmp_list);
>=20
> 	mutex_lock(&mapping->i_mmap_mutex);
> 	add_to_temp_list(vma, inode, &tmp_list);
> 	list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
> 		loff_t vaddr;
>=20
> 		list_del(&uprobe->pending_list);
> 		if (ret)
> 			continue;
>=20
> 		vaddr =3D vma->vm_start + uprobe->offset;
> 		vaddr -=3D vma->vm_pgoff << PAGE_SHIFT;
> 		ret =3D install_breakpoint(mm, uprobe, vaddr);

Right, so this is the problem, you cannot do allocations under
i_mmap_mutex, however I think you can under i_mutex.

> 		if (ret && (ret =3D=3D -ESRCH || ret =3D=3D -EEXIST))
> 			ret =3D 0;
> 	}
>=20
> 	mutex_unlock(&mapping->i_mmap_mutex);
> 	iput(inode);
> 	return ret;
> }
>=20
> int munmap_uprobe(struct vm_area_struct *vma)
> {
> 	struct list_head tmp_list;
> 	struct uprobe *uprobe, *u;
> 	struct mm_struct *mm;
> 	struct inode *inode;
> 	int ret =3D 0;
>=20
> 	if (!valid_vma(vma))
> 		return ret;	/* Bail-out */
>=20
> 	mm =3D vma->vm_mm;
> 	inode =3D vma->vm_file->f_mapping->host;
> 	if (inode->uprobes_count)
> 		return ret;

Should that be !->uprobes_count?

> //      walk thro RB tree and decrement mm->uprobes_count
> 	walk_rbtree_and_dec_uprobes_count();	//hold treelock.
>=20
> 	return ret;
> }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
