Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id A2B659000BD
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 04:59:04 -0400 (EDT)
Subject: Re: [PATCH v4 3.0-rc2-tip 7/22]  7: uprobes: mmap and fork hooks.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110627064502.GB24776@linux.vnet.ibm.com>
References: <20110616130012.GL4952@linux.vnet.ibm.com>
	 <1308248588.13240.267.camel@twins>
	 <20110617045000.GM4952@linux.vnet.ibm.com>
	 <1308297836.13240.380.camel@twins>
	 <20110617090504.GN4952@linux.vnet.ibm.com> <1308303665.2355.11.camel@twins>
	 <1308662243.26237.144.camel@twins>
	 <20110622143906.GF16471@linux.vnet.ibm.com>
	 <20110624020659.GA24776@linux.vnet.ibm.com>
	 <1308901324.27849.7.camel@twins>
	 <20110627064502.GB24776@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 27 Jun 2011 10:57:51 +0200
Message-ID: <1309165071.6701.4.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 2011-06-27 at 12:15 +0530, Srikar Dronamraju wrote:

> > > 	mutex_lock(&mapping->i_mmap_mutex);
> > > 	add_to_temp_list(vma, inode, &tmp_list);
> > > 	list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
> > > 		loff_t vaddr;
> > >=20
> > > 		list_del(&uprobe->pending_list);
> > > 		if (ret)
> > > 			continue;
> > >=20
> > > 		vaddr =3D vma->vm_start + uprobe->offset;
> > > 		vaddr -=3D vma->vm_pgoff << PAGE_SHIFT;
> > > 		ret =3D install_breakpoint(mm, uprobe, vaddr);
> >=20
> > Right, so this is the problem, you cannot do allocations under
> > i_mmap_mutex, however I think you can under i_mutex.
>=20
> I didnt know that we cannot do allocations under i_mmap_mutex.
> Why is this?=20

Because we try to take i_mmap_mutex during reclaim, trying to unmap
pages. So suppose we do an allocation while holding i_mmap_mutex, find
there's no free memory, try and unmap a page in order to free it, and
we're stuck.

> I cant take i_mutex, because we would have already held
> down_write(mmap_sem) here.=20

Right. So can we add a lock in the uprobe? All we need is per uprobe
serialization, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
