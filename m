Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id EF7126B0103
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 12:20:12 -0400 (EDT)
Message-ID: <1332865192.16159.243.camel@twins>
Subject: Re: [PATCH 07/39] autonuma: introduce kthread_bind_node()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 27 Mar 2012 18:19:52 +0200
In-Reply-To: <20120327160422.GR5906@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
	 <1332783986-24195-8-git-send-email-aarcange@redhat.com>
	 <1332786755.16159.174.camel@twins> <20120327152209.GL5906@redhat.com>
	 <1332863135.16159.239.camel@twins> <20120327160422.GR5906@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, 2012-03-27 at 18:04 +0200, Andrea Arcangeli wrote:
> On Tue, Mar 27, 2012 at 05:45:35PM +0200, Peter Zijlstra wrote:
> > On Tue, 2012-03-27 at 17:22 +0200, Andrea Arcangeli wrote:
> > > I don't see what's wrong with more than 1 CPU in the hard bind
> > > cpumask.
> >=20
> > Because its currently broken, but we're trying to restore its pure
> > semantic so that we can use it in more places again, like
> > debug_smp_processor_id(). Testing a single process flag is _much_
> > cheaper than testing ->cpus_allowed.
> >=20
> > Adding more broken isn't an option.
>=20
> I would suggest you to use a new bitflag for that _future_
> optimization that you plan to do without altering the way the current
> bitflag works.
>=20
> I doubt knuma_migrated will ever be the only kernel thread that wants
> to run with a NUMA NODE-wide CPU binding (instead of single-CPU
> binding).
>=20
> Being able to keep using this bitflag for NUMA-wide bindings too in
> the future as well (after you do the optimization you planned), is
> going to reduce the chances of the root user shooting himself in the
> foot for both the kernel thread node-BIND and the single-cpu-BIND.

But then the current flag is a mis-nomer. Also, there's no correctness
issue with the per-node threads, its perfectly fine if they run some
place else so I don't think we should restrict userspace to force them
away from their preferred node.

So even if you were to introduce a new flag, I'd still object.

The only reason to ever refuse userspace moving a task around is if it
will break stuff. Worst that can happen with a node affine thread is
that it'll incur remote memory penalties, that's not fatal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
