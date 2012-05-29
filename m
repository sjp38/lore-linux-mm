Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 1C6086B0072
	for <linux-mm@kvack.org>; Tue, 29 May 2012 12:05:47 -0400 (EDT)
Message-ID: <1338307528.26856.106.camel@twins>
Subject: Re: [PATCH 21/35] autonuma: teach CFS about autonuma affinity
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 29 May 2012 18:05:28 +0200
In-Reply-To: <1337965359-29725-22-git-send-email-aarcange@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
	 <1337965359-29725-22-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Fri, 2012-05-25 at 19:02 +0200, Andrea Arcangeli wrote:
> The CFS scheduler is still in charge of all scheduling
> decisions. AutoNUMA balancing at times will override those. But
> generally we'll just relay on the CFS scheduler to keep doing its
> thing, but while preferring the autonuma affine nodes when deciding
> to move a process to a different runqueue or when waking it up.
>
> For example the idle balancing, will look into the runqueues of the
> busy CPUs, but it'll search first for a task that wants to run into
> the idle CPU in AutoNUMA terms (task_autonuma_cpu() being true).
>=20
> Most of this is encoded in the can_migrate_task becoming AutoNUMA
> aware and running two passes for each balancing pass, the first NUMA
> aware, and the second one relaxed.
>=20
> The idle/newidle balancing is always allowed to fallback into
> non-affine AutoNUMA tasks. The load_balancing (which is more a
> fariness than a performance issue) is instead only able to cross over
> the AutoNUMA affinity if the flag controlled by
> /sys/kernel/mm/autonuma/scheduler/load_balance_strict is not set (it
> is set by default).

This is unacceptable, and contradicts your earlier claim that you rely
on the regular load-balancer.

The strict mode needs to go, load-balancing is a best effort and
fairness is important -- so much so to some people that I get complaints
the current thing isn't strong enough.

Your strict mode basically supplants any and all balancing done at node
level and above.

Please use something like:=20

  https://lkml.org/lkml/2012/5/19/53

with the sched_setnode() function from:

  https://lkml.org/lkml/2012/5/18/109

Fairness matters because people expect similar throughput or runtimes so
balancing such that we first ensure equal load on cpus and only then
bother with node placement should be the order.

Furthermore, load-balancing does things like trying to place tasks that
wake each-other closer together, your strict mode completely breaks
that. Instead, if the balancer finds these tasks are related and should
be together that should be a hint the memory needs to come to them, not
the other way around.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
