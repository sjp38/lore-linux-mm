Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E9ED78D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 13:58:08 -0400 (EDT)
Subject: Re: [PATCH v2 2.6.38-rc8-tip 7/20]  7: uprobes: store/restore
 original instruction.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110315092247.GW24254@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
	 <20110314133522.27435.45121.sendpatchset@localhost6.localdomain6>
	 <20110314180914.GA18855@fibrous.localdomain>
	 <20110315092247.GW24254@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 15 Mar 2011 18:57:42 +0100
Message-ID: <1300211862.2203.302.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Stephen Wilson <wilsons@start.ca>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>

On Tue, 2011-03-15 at 14:52 +0530, Srikar Dronamraju wrote:
> * Stephen Wilson <wilsons@start.ca> [2011-03-14 14:09:14]:
>=20
> > On Mon, Mar 14, 2011 at 07:05:22PM +0530, Srikar Dronamraju wrote:
> > >  static int install_uprobe(struct mm_struct *mm, struct uprobe *uprob=
e)
> > >  {
> > > -	int ret =3D 0;
> > > +	struct task_struct *tsk;
> > > +	int ret =3D -EINVAL;
> > > =20
> > > -	/*TODO: install breakpoint */
> > > -	if (!ret)
> > > +	get_task_struct(mm->owner);
> > > +	tsk =3D mm->owner;
> > > +	if (!tsk)
> > > +		return ret;
> >=20
> > I think you need to check that tsk !=3D NULL before calling
> > get_task_struct()...
> >=20
>=20
> Guess checking for tsk !=3D NULL would only help if and only if we are do=
ing
> within rcu.  i.e we have to change to something like this
>=20
> 	rcu_read_lock()
> 	if (mm->owner) {
> 		get_task_struct(mm->owner)
> 		tsk =3D mm->owner;
> 	}
> 	rcu_read_unlock()
> 	if (!tsk)
> 		return ret;

so the whole mm->owner semantics seem vague, memcontrol.c doesn't seem
consistent in itself, one site uses rcu_dereference() the other site
doesn't.

Also, the assignments in kernel/fork.c and kernel/exit.c don't use
rcu_assign_pointer() and therefore lack the needed write barrier.

Git blames Balbir for this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
