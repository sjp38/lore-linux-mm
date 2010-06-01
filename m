Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 751716B022C
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 05:05:39 -0400 (EDT)
Subject: Re: [rfc] forked kernel task and mm structures imbalanced on NUMA
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100601084157.GS9453@laptop>
References: <20100601073343.GQ9453@laptop>
	 <1275380202.27810.26214.camel@twins>  <20100601084157.GS9453@laptop>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 01 Jun 2010 11:05:52 +0200
Message-ID: <1275383152.27810.26387.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-06-01 at 18:41 +1000, Nick Piggin wrote:
> > So I think it would make sense to rework the fork balancing muck to be
> > called only once and stick with its decision.
>=20
> Just need to close that race somehow. AFAIKS we can't use TASK_WAKING
> because that must not be preempted?

Right its basically a bit-spinlock and since it interacts with the
rq->lock it needs to have IRQs disabled while we have it set -- which
isn't a problem for the wakeup path, but it would be for the whole fork
path.

> > One thing that would make the whole fork path much easier is fully
> > ripping out that child_runs_first mess for CONFIG_SMP, I think its been
> > disabled by default for long enough, and its always been broken in the
> > face of fork balancing anyway.
>=20
> Interesting problem. vfork is nice for fork+exec, but it's a bit
> restrictive.

Right, and all that is a separate issue, its broken now, its still
broken with child_runs_first ripped out.
=20
> > So basically we have to move fork balancing back to sched_fork(), I'd
> > have to again look at wth happens to ->cpus_allowed, but I guess it
> > should be fixable, and I don't think we should care overly much about
> > cpu-hotplug.
>=20
> No more than simply getting it right. Simply calling into the balancer
> again seems to be the simplest way to do it.

Right.

> > A specific code comment:
> >=20
> > > @@ -2550,14 +2561,16 @@ void wake_up_new_task(struct task_struct
> > >          * We set TASK_WAKING so that select_task_rq() can drop rq->l=
ock
> > >          * without people poking at ->cpus_allowed.
> > >          */
> > > -       cpu =3D select_task_rq(rq, p, SD_BALANCE_FORK, 0);
> > > -       set_task_cpu(p, cpu);
> > > -
> > > -       p->state =3D TASK_RUNNING;
> > > -       task_rq_unlock(rq, &flags);
> > > +       if (!cpumask_test_cpu(cpu, &p->cpus_allowed)) {
> > > +               p->state =3D TASK_WAKING;
> > > +               cpu =3D select_task_rq(rq, p, SD_BALANCE_FORK, 0);
> > > +               set_task_cpu(p, cpu);
> > > +               p->state =3D TASK_RUNNING;
> > > +               task_rq_unlock(rq, &flags);
> > > +               rq =3D task_rq_lock(p, &flags);
> > > +       }
> > >  #endif
> >=20
> > That's iffy because p->cpus_allowed isn't stable when we're not holding
> > the task's current rq->lock or p->state is not TASK_WAKING.
> >=20
>=20
> Oop, yeah missed that. Half hearted attempt to avoid more rq locks.=20

Yeah, something well worth the effort. At one point I considered making
p->cpus_allowed an RCU managed cpumask, but I never sat down and ran
through all the interesting races that that would bring.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
