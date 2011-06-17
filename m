Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D8DE86B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 05:42:29 -0400 (EDT)
Subject: Re: [PATCH v4 3.0-rc2-tip 7/22]  7: uprobes: mmap and fork hooks.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110617090504.GN4952@linux.vnet.ibm.com>
References: 
	 <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
	 <20110607125931.28590.12362.sendpatchset@localhost6.localdomain6>
	 <1308161486.2171.61.camel@laptop>
	 <20110616032645.GF4952@linux.vnet.ibm.com>
	 <1308225626.13240.34.camel@twins>
	 <20110616130012.GL4952@linux.vnet.ibm.com>
	 <1308248588.13240.267.camel@twins>
	 <20110617045000.GM4952@linux.vnet.ibm.com>
	 <1308297836.13240.380.camel@twins>
	 <20110617090504.GN4952@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 17 Jun 2011 11:41:05 +0200
Message-ID: <1308303665.2355.11.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 2011-06-17 at 14:35 +0530, Srikar Dronamraju wrote:

> > > > int mmap_uprobe(...)
> > > > {
> > > >   spin_lock(&uprobes_treelock);
> > > >   for_each_probe_in_inode() {
> > > >     // create list;
>=20
> Here again if we have multiple mmaps for the same inode occuring on two
> process contexts (I mean two different mm's), we have to manage how we
> add the same uprobe to more than one list. Atleast my current
> uprobe->pending_list wouldnt work.

Sure, wasn't concerned about that particular problem.

> > > >   }
> > > >   spin_unlock(..);
> > > >=20
> > > >   list_for_each_entry_safe() {
> > > >     // remove from list
> > > >     ret =3D install_breakpoint();
> > > >     if (ret)
> > > >       goto fail;
> > > >     if (!uprobe_still_there()) // takes treelock
> > > >       remove_breakpoint();
> > > >   }
> > > >=20
> > > >   return 0;
> > > >=20
> > > > fail:
> > > >   list_for_each_entry_safe() {
> > > >     // destroy list
> > > >   }
> > > >   return ret;
> > > > }
> > > >=20
> > >=20
> > >=20
> > > register_uprobe will race with mmap_uprobe's first pass.
> > > So we might end up with a vma that doesnot have a breakpoint inserted
> > > but inserted in all other vma that map to the same inode.
> >=20
> > I'm not seeing this though, if mmap_uprobe() is before register_uprobe(=
)
> > inserts the probe in the tree, the vma is already in the rmap and
> > register_uprobe() will find it in its vma walk. If its after,
> > mmap_uprobe() will find it and install, if a concurrent
> > register_uprobe()'s vma walk also finds it, it will -EEXISTS and ignore
> > the error.
> >=20
>=20
> You are right here.=20
>=20
> What happens if the register_uprobe comes first and walks around the
> vmas, Between mmap comes in does the insertion including the second pass
> and returns.  register_uprobe now finds that it cannot insert breakpoint
> on one of the vmas and hence has to roll-back. The vma on which
> mmap_uprobe inserted will not be in the list of vmas from which we try
> to remove the breakpoint.

Yes it will, remember __register_uprobe() will call
__unregister_uprobe() on fail, which does a new vma-rmap walk which will
then see the newly added mmap.

> How about something like this:

> 	if (!mutex_trylock(uprobes_mutex)) {
>=20
> 		/*
> 		 * Unable to get uprobes_mutex; Probably contending with
> 		 * someother thread. Drop mmap_sem; acquire uprobes_mutex
> 		 * and mmap_sem and then verify vma.
> 		 */
>=20
> 		up_write(&mm->mmap_sem);
> 		mutex_lock&(uprobes_mutex);
> 		down_write(&mm->mmap_sem);
> 		vma =3D find_vma(mm, start);
> 		/* Not the same vma */
> 		if (!vma || vma->vm_start !=3D start ||
> 				vma->vm_pgoff !=3D pgoff || !valid_vma(vma) ||
> 				inode->i_mapping !=3D vma->vm_file->f_mapping)
> 			goto mmap_out;
> 	}

Only if we have to, I really don't like dropping mmap_sem in the middle
of mmap. I'm fairly sure we can come up with some ordering scheme that
ought to make mmap_uprobe() work without the uprobes_mutex.

On thing I was thinking of to fix that initial problem of spurious traps
was to leave the uprobe in the tree but skip all probes without
consumers in mmap_uprobe().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
