Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 154876B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 14:23:56 -0400 (EDT)
Subject: Re: [PATCH v4 3.0-rc2-tip 7/22]  7: uprobes: mmap and fork hooks.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110616130012.GL4952@linux.vnet.ibm.com>
References: 
	 <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
	 <20110607125931.28590.12362.sendpatchset@localhost6.localdomain6>
	 <1308161486.2171.61.camel@laptop>
	 <20110616032645.GF4952@linux.vnet.ibm.com>
	 <1308225626.13240.34.camel@twins>
	 <20110616130012.GL4952@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 16 Jun 2011 20:23:08 +0200
Message-ID: <1308248588.13240.267.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 2011-06-16 at 18:30 +0530, Srikar Dronamraju wrote:

> Now since a register and mmap operations can run in parallel, we could
> have subtle race conditions like this:
>=20
> 1. register_uprobe inserts the uprobe in RB tree.
> 2. register_uprobe loops thro vmas and inserts breakpoints.
>=20
> 3. mmap is called for same inode, mmap_uprobe() takes reference;=20
> 4. mmap completes insertion and releases reference.
>=20
> 5. register uprobe tries to install breakpoint on one vma fails and not
> due to -ESRCH or -EEXIST.
> 6. register_uprobe rolls back all install breakpoints except the one
> inserted by mmap.
>=20
> We end up with breakpoints that we have inserted by havent cleared.
>=20
> Similarly unregister_uprobe might be looping to remove the breakpoints
> when mmap comes in installs the breakpoint and returns.
> unregister_uprobe might erase the uprobe from rbtree after mmap is done.

Well yes, but that's mostly because of how you use those lists.

int __register_uprobe(...)
{
  uprobe =3D alloc_uprobe(...); // find or insert in tree

  vma_prio_tree_foreach(..) {
    // get mm ref, add to list blah blah
  }

  list_for_each_entry_safe() {
    // del from list etc..
    down_read(mm->mmap_sem);
    ret =3D install_breakpoint();
    if (ret && (ret !=3D -ESRCH || ret !=3D -EEXIST)) {
      up_read(..);
      goto fail;
  }

  return 0;

fail:
  list_for_each_entry_safe() {
    // del from list, put mm
  }

  return ret;
}

void __unregister_uprobe(...)
{
  uprobe =3D find_uprobe(); // ref++
  if (delete_consumer(...)); // includes tree removal on last consumer
                             // implies we own the last ref
     return; // consumers

  vma_prio_tree_foreach() {
     // create list
  }

  list_for_each_entry_safe() {
    // remove from list
    remove_breakpoint(); // unconditional, if it wasn't there
                         // its a nop anyway, can't get any new
                         // new probes on account of holding
                         // uprobes_mutex and mmap() doesn't see
                         // it due to tree removal.
  }
}

int register_uprobe(...)
{
  int ret;

  mutex_lock(&uprobes_mutex);
  ret =3D __register_uprobe(...);
  if (!ret)
    __unregister_uprobe(...);
  mutex_unlock(&uprobes_mutex);

  ret;
}

int mmap_uprobe(...)
{
  spin_lock(&uprobes_treelock);
  for_each_probe_in_inode() {
    // create list;
  }
  spin_unlock(..);

  list_for_each_entry_safe() {
    // remove from list
    ret =3D install_breakpoint();
    if (ret)
      goto fail;
    if (!uprobe_still_there()) // takes treelock
      remove_breakpoint();
  }

  return 0;

fail:
  list_for_each_entry_safe() {
    // destroy list
  }
  return ret;
}

Should work I think, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
