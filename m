Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 87F696B005C
	for <linux-mm@kvack.org>; Tue, 29 May 2012 12:28:12 -0400 (EDT)
Message-ID: <1338308875.26856.121.camel@twins>
Subject: Re: [PATCH 23/35] autonuma: core
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 29 May 2012 18:27:55 +0200
In-Reply-To: <1337965359-29725-24-git-send-email-aarcange@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
	 <1337965359-29725-24-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Fri, 2012-05-25 at 19:02 +0200, Andrea Arcangeli wrote:
> This implements knuma_scand, the numa_hinting faults started by
> knuma_scand, the knuma_migrated that migrates the memory queued by the
> NUMA hinting faults, the statistics gathering code that is done by
> knuma_scand for the mm_autonuma and by the numa hinting page faults
> for the sched_autonuma, and most of the rest of the AutoNUMA core
> logics like the false sharing detection, sysfs and initialization
> routines.
>=20
> The AutoNUMA algorithm when knuma_scand is not running is a full
> bypass and it must not alter the runtime of memory management and
> scheduler.
>=20
> The whole AutoNUMA logic is a chain reaction as result of the actions
> of the knuma_scand. The various parts of the code can be described
> like different gears (gears as in glxgears).
>=20
> knuma_scand is the first gear and it collects the mm_autonuma per-process
> statistics and at the same time it sets the pte/pmd it scans as
> pte_numa and pmd_numa.
>=20
> The second gear are the numa hinting page faults. These are triggered
> by the pte_numa/pmd_numa pmd/ptes. They collect the sched_autonuma
> per-thread statistics. They also implement the memory follow CPU logic
> where we track if pages are repeatedly accessed by remote nodes. The
> memory follow CPU logic can decide to migrate pages across different
> NUMA nodes by queuing the pages for migration in the per-node
> knuma_migrated queues.
>=20
> The third gear is knuma_migrated. There is one knuma_migrated daemon
> per node. Pages pending for migration are queued in a matrix of
> lists. Each knuma_migrated (in parallel with each other) goes over
> those lists and migrates the pages queued for migration in round robin
> from each incoming node to the node where knuma_migrated is running
> on.
>=20
> The fourth gear is the NUMA scheduler balancing code. That computes
> the statistical information collected in mm->mm_autonuma and
> p->sched_autonuma and evaluates the status of all CPUs to decide if
> tasks should be migrated to CPUs in remote nodes.=20

IOW:

"knuma_scand 'unmaps' ptes and collects mm stats, this triggers
numa_hinting pagefaults, using these we collect per task stats.

knuma_migrated migrates pages to their destination node. Something
queues pages.

The numa scheduling code uses the gathered stats to place tasks."


That covers just about all you said, now the interesting bits are still
missing:

 - how do you do false sharing;

 - what stats do you gather, and how are they used at each stage;

 - what's your balance goal, and how is that expressed and=20
   converged upon.

Also, what I've not seen anywhere are scheduling stats, what if, despite
you giving a hint a particular process should run on a particular node
it doesn't and sticks to where its at (granted with strict this can't
happen -- but it should).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
