Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 451FC6B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 08:26:42 -0400 (EDT)
Message-ID: <1341836787.3462.64.camel@twins>
Subject: Re: [RFC][PATCH 25/26] sched, numa: Only migrate long-running
 entities
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 09 Jul 2012 14:26:27 +0200
In-Reply-To: <4FF9D29D.8030903@redhat.com>
References: <20120316144028.036474157@chello.nl>
	 <20120316144241.749359061@chello.nl> <4FF9D29D.8030903@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 2012-07-08 at 14:34 -0400, Rik van Riel wrote:
> On 03/16/2012 10:40 AM, Peter Zijlstra wrote:
>=20
> > +static u64 process_cpu_runtime(struct numa_entity *ne)
> > +{
> > +	struct task_struct *p, *t;
> > +	u64 runtime =3D 0;
> > +
> > +	rcu_read_lock();
> > +	t =3D p =3D ne_owner(ne);
> > +	if (p) do {
> > +		runtime +=3D t->se.sum_exec_runtime; // @#$#@ 32bit
> > +	} while ((t =3D next_thread(t)) !=3D p);
> > +	rcu_read_unlock();
> > +
> > +	return runtime;
> > +}
>=20
> > +	/*
> > +	 * Don't bother migrating memory if there's less than 1 second
> > +	 * of runtime on the tasks.
> > +	 */
> > +	if (ne->nops->cpu_runtime(ne) < NSEC_PER_SEC)
> > +		return false;
>=20
> Do we really want to calculate the amount of CPU time used
> by a process, and start migrating after just one second?
>=20
> Or would it be ok to start migrating once a process has
> been scanned once or twice by the NUMA code?

You mean, the 2-3rd time we try and migrate this task, not the memory
scanning thing as per Andrea, right?

Yeah, that might work too..=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
