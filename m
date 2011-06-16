Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9F90B6B004A
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 14:26:10 -0400 (EDT)
Subject: Re: [PATCH v4 3.0-rc2-tip 7/22]  7: uprobes: mmap and fork hooks.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1308248588.13240.267.camel@twins>
References: 
	 <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
	 <20110607125931.28590.12362.sendpatchset@localhost6.localdomain6>
	 <1308161486.2171.61.camel@laptop>
	 <20110616032645.GF4952@linux.vnet.ibm.com>
	 <1308225626.13240.34.camel@twins>
	 <20110616130012.GL4952@linux.vnet.ibm.com>
	 <1308248588.13240.267.camel@twins>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 16 Jun 2011 20:25:33 +0200
Message-ID: <1308248733.13240.269.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 2011-06-16 at 20:23 +0200, Peter Zijlstra wrote:
> int __register_uprobe(...)
> {
>   uprobe =3D alloc_uprobe(...); // find or insert in tree
>=20
>   vma_prio_tree_foreach(..) {
>     // get mm ref, add to list blah blah
>   }
>=20
>   list_for_each_entry_safe() {
>     // del from list etc..
>     down_read(mm->mmap_sem);
>     ret =3D install_breakpoint();
>     if (ret && (ret !=3D -ESRCH || ret !=3D -EEXIST)) {
>       up_read(..);
>       goto fail;
>   }
>=20
>   return 0;
>=20
> fail:
>   list_for_each_entry_safe() {
>     // del from list, put mm
>   }
>=20
>   return ret;
> }
>=20
> void __unregister_uprobe(...)
> {
>   uprobe =3D find_uprobe(); // ref++
>   if (delete_consumer(...)); // includes tree removal on last consumer
>                              // implies we own the last ref
>      return; // consumers
>=20
>   vma_prio_tree_foreach() {
>      // create list
>   }
>=20
>   list_for_each_entry_safe() {
>     // remove from list
>     remove_breakpoint(); // unconditional, if it wasn't there
>                          // its a nop anyway, can't get any new
>                          // new probes on account of holding
>                          // uprobes_mutex and mmap() doesn't see
>                          // it due to tree removal.
>   }

   put_uprobe(); // last ref, *poof*
> }
>=20
> int register_uprobe(...)
> {
>   int ret;
>=20
>   mutex_lock(&uprobes_mutex);
>   ret =3D __register_uprobe(...);
>   if (!ret)
>     __unregister_uprobe(...);
>   mutex_unlock(&uprobes_mutex);
>=20
>   ret;
> }
>=20
> int mmap_uprobe(...)
> {
>   spin_lock(&uprobes_treelock);
>   for_each_probe_in_inode() {
>     // create list;
>   }
>   spin_unlock(..);
>=20
>   list_for_each_entry_safe() {
>     // remove from list
>     ret =3D install_breakpoint();
>     if (ret)
>       goto fail;
>     if (!uprobe_still_there()) // takes treelock
>       remove_breakpoint();
>   }
>=20
>   return 0;
>=20
> fail:
>   list_for_each_entry_safe() {
>     // destroy list
>   }
>   return ret;
> }=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
