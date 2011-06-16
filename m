Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AEB176B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 05:47:04 -0400 (EDT)
Subject: Re: [PATCH v4 3.0-rc2-tip 4/22]  4: Uprobes: register/unregister
 probes.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110616041137.GG4952@linux.vnet.ibm.com>
References: 
	 <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
	 <20110607125900.28590.16071.sendpatchset@localhost6.localdomain6>
	 <1308159719.2171.57.camel@laptop>
	 <20110616041137.GG4952@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 16 Jun 2011 11:46:22 +0200
Message-ID: <1308217582.15315.94.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 2011-06-16 at 09:41 +0530, Srikar Dronamraju wrote:
> * Peter Zijlstra <peterz@infradead.org> [2011-06-15 19:41:59]:
>=20
> > On Tue, 2011-06-07 at 18:29 +0530, Srikar Dronamraju wrote:
> > > 1. Use mm->owner and walk thro the thread_group of mm->owner, sibling=
s
> > > of mm->owner, siblings of parent of mm->owner.  This should be
> > > good list to traverse. Not sure if this is an exhaustive
> > > enough list that all tasks that have a mm set to this mm_struct are
> > > walked through.=20
> >=20
> > As per copy_process():
> >=20
> > 	/*
> > 	 * Thread groups must share signals as well, and detached threads
> > 	 * can only be started up within the thread group.
> > 	 */
> > 	if ((clone_flags & CLONE_THREAD) && !(clone_flags & CLONE_SIGHAND))
> > 		return ERR_PTR(-EINVAL);
> >=20
> > 	/*
> > 	 * Shared signal handlers imply shared VM. By way of the above,
> > 	 * thread groups also imply shared VM. Blocking this case allows
> > 	 * for various simplifications in other code.
> > 	 */
> > 	if ((clone_flags & CLONE_SIGHAND) && !(clone_flags & CLONE_VM))
> > 		return ERR_PTR(-EINVAL);
> >=20
> > CLONE_THREAD implies CLONE_VM, but not the other way around, we
> > therefore would be able to CLONE_VM and not be part of the primary
> > owner's thread group.
> >=20
> > This is of course all terribly sad..
>=20
> Agree,=20
>=20
> If clone(CLONE_VM) were to be done by a thread_group leader, we can walk
> thro the siblings of parent of mm->owner.
>=20
> However if clone(CLONE_VM) were to be done by non thread_group_leader
> thread, then we dont even seem to add it to the init_task. i.e I dont
> think we can refer to such a thread even when we walk thro
> do_each_thread(g,t) { .. } while_each_thread(g,t);
>=20
> right?

No, we initialize p->group_leader =3D p; and only change that for
CLONE_THREAD, so a clone without CLONE_THREAD always results in a new
thread group leader, which are always added to the init_task list.

Or I'm now confused, which isn't at all impossible with that code ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
