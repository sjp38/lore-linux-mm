Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C99D86B0082
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 04:04:47 -0400 (EDT)
Subject: Re: [PATCH v4 3.0-rc2-tip 7/22]  7: uprobes: mmap and fork hooks.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110617045000.GM4952@linux.vnet.ibm.com>
References: 
	 <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
	 <20110607125931.28590.12362.sendpatchset@localhost6.localdomain6>
	 <1308161486.2171.61.camel@laptop>
	 <20110616032645.GF4952@linux.vnet.ibm.com>
	 <1308225626.13240.34.camel@twins>
	 <20110616130012.GL4952@linux.vnet.ibm.com>
	 <1308248588.13240.267.camel@twins>
	 <20110617045000.GM4952@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 17 Jun 2011 10:03:56 +0200
Message-ID: <1308297836.13240.380.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 2011-06-17 at 10:20 +0530, Srikar Dronamraju wrote:
> >=20
> > void __unregister_uprobe(...)
> > {
> >   uprobe =3D find_uprobe(); // ref++
> >   if (delete_consumer(...)); // includes tree removal on last consumer
> >                              // implies we own the last ref
> >      return; // consumers
> >=20
> >   vma_prio_tree_foreach() {
> >      // create list
> >   }
> >=20
> >   list_for_each_entry_safe() {
> >     // remove from list
> >     remove_breakpoint(); // unconditional, if it wasn't there
> >                          // its a nop anyway, can't get any new
> >                          // new probes on account of holding
> >                          // uprobes_mutex and mmap() doesn't see
> >                          // it due to tree removal.
> >   }
> > }
> >=20
>=20
> This would have a bigger race.
> A breakpoint might be hit by which time the node is removed and we
> have no way to find out the uprobe. So we deliver an extra TRAP to the
> app.

Gah indeed. Back to the drawing board for me.

> > int mmap_uprobe(...)
> > {
> >   spin_lock(&uprobes_treelock);
> >   for_each_probe_in_inode() {
> >     // create list;
> >   }
> >   spin_unlock(..);
> >=20
> >   list_for_each_entry_safe() {
> >     // remove from list
> >     ret =3D install_breakpoint();
> >     if (ret)
> >       goto fail;
> >     if (!uprobe_still_there()) // takes treelock
> >       remove_breakpoint();
> >   }
> >=20
> >   return 0;
> >=20
> > fail:
> >   list_for_each_entry_safe() {
> >     // destroy list
> >   }
> >   return ret;
> > }
> >=20
>=20
>=20
> register_uprobe will race with mmap_uprobe's first pass.
> So we might end up with a vma that doesnot have a breakpoint inserted
> but inserted in all other vma that map to the same inode.

I'm not seeing this though, if mmap_uprobe() is before register_uprobe()
inserts the probe in the tree, the vma is already in the rmap and
register_uprobe() will find it in its vma walk. If its after,
mmap_uprobe() will find it and install, if a concurrent
register_uprobe()'s vma walk also finds it, it will -EEXISTS and ignore
the error.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
