Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 260C88D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 14:16:10 -0400 (EDT)
Subject: Re: [PATCH v2 2.6.38-rc8-tip 5/20] 5: Uprobes: register/unregister
 probes.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110315180423.GA10429@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
	 <20110314133454.27435.81020.sendpatchset@localhost6.localdomain6>
	 <alpine.LFD.2.00.1103151439400.2787@localhost6.localdomain6>
	 <20110315171536.GA24254@linux.vnet.ibm.com>
	 <1300211262.9910.295.camel@gandalf.stny.rr.com>
	 <1300211411.2203.290.camel@twins>
	 <20110315180423.GA10429@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 15 Mar 2011 19:15:49 +0100
Message-ID: <1300212949.2203.324.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Tue, 2011-03-15 at 23:34 +0530, Srikar Dronamraju wrote:
> * Peter Zijlstra <peterz@infradead.org> [2011-03-15 18:50:11]:
>=20
> > On Tue, 2011-03-15 at 13:47 -0400, Steven Rostedt wrote:
> > > On Tue, 2011-03-15 at 22:45 +0530, Srikar Dronamraju wrote:
> > > > > > +   }
> > > > > > +   list_for_each_entry_safe(mm, tmpmm, &tmp_list, uprobes_list=
) {
> > > > > > +           down_read(&mm->mmap_sem);
> > > > > > +           if (!install_uprobe(mm, uprobe))
> > > > > > +                   ret =3D 0;
> > > > >=20
> > > > > Installing it once is success ?
> > > >=20
> > > > This is a little tricky. My intention was to return success even if=
 one
> > > > install is successful. If we return error, then the caller can go
> > > > ahead and free the consumer. Since we return success if there are
> > > > currently no processes that have mapped this inode, I was tempted t=
o
> > > > return success on atleast one successful install.
> > >=20
> > > What about an all or nothing approach. If one fails, remove all that
> > > were installed, and give up.
> >=20
> > That sounds like a much saner semantic and is what we generally do in
> > the kernel.
>=20
> One of the install_uprobe could be failing because the process was
> almost exiting, something like there was no mm->owner. Also lets
> assume that the first few install_uprobes go thro and the last
> install_uprobe fails. There could be breakpoint hits corresponding to
> the already installed uprobes that get displayed. i.e all
> breakpoint hits from the first install_uprobe to the time we detect a
> failed a install_uprobe and revert all inserted breakpoints will be
> shown as being captured.

I think you can gracefully deal with the exit case and simply ignore
that one. But you cannot let arbitrary installs fail and still report
success, that gives very weak and nearly useless semantics.

> Also register_uprobe will only install probes for processes that are
> actively and have mapped the inode.  However install_uprobe called from
> uprobe_mmap which also registers the probe can fail. Now should we take
> the same yardstick and remove all the probes corresponding to the
> successful register_uprobe?

No, if uprobe_mmap() fails we should fail the mmap(), that also
guarantees consistency.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
