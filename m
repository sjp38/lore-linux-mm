Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8A56B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 12:17:38 -0500 (EST)
Subject: Re: [RFC] [PATCH 2.6.37-rc5-tip 5/20]  5: Uprobes:
 register/unregister probes.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110126165645.GP19725@linux.vnet.ibm.com>
References: 
	 <20101216095714.23751.52601.sendpatchset@localhost6.localdomain6>
	 <20101216095817.23751.76989.sendpatchset@localhost6.localdomain6>
	 <1295957744.28776.722.camel@laptop>
	 <20110126075558.GB19725@linux.vnet.ibm.com>
	 <1296036708.28776.1138.camel@laptop>
	 <20110126153036.GN19725@linux.vnet.ibm.com>
	 <1296056756.28776.1247.camel@laptop>
	 <20110126165645.GP19725@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 26 Jan 2011 18:12:29 +0100
Message-ID: <1296061949.28776.1343.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2011-01-26 at 22:26 +0530, Srikar Dronamraju wrote:

> >  - lookup the vma relating to the address you stored,
>=20
> We already do this thro get_user_pages in write_opcode().

Ah, I didn't read that far..

> >  - validate that the vma is indeed a map of the right inode
>=20
> We can add a check in write_opcode( we need to pass the inode to
> write_opcode).

sure..

> >  - validate that the offset of the probe corresponds with the stored
> > address
>=20
> I am not clear on this. We would have derived the address from the
> offset. So is that we check for
>  (vaddr =3D=3D vma->vm_start + uprobe->offset)

Sure, but the vma might have changed since you computed the offset -)

> >=20
> > Otherwise you can race with unmap/map and end up installing the probe i=
n
> > a random location.
> >=20
> > Also, I think the whole thing goes funny if someone maps the same text
> > twice ;-)
>=20
> I am not sure if we can map the same text twice. If something like
> this is possible then we would have 2 addresses for each function.
> So how does the linker know which address to jump to out of the 2 or
> multiple matching addresses. What would be the usecases for same
> text being mapped multiple times and both being executable?

You can, if only to wreck your thing, you can call mmap() as often as
you like (until your virtual memory space runs out) and get many many
mapping of the same file.

It doesn't need to make sense to the linker, all it needs to do is
confuse your code ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
