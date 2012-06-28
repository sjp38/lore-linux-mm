Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id C9AA56B00AC
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 10:46:46 -0400 (EDT)
Message-ID: <1340894776.28750.44.camel@twins>
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu, 28 Jun 2012 16:46:16 +0200
In-Reply-To: <1340888180-15355-14-git-send-email-aarcange@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
	 <1340888180-15355-14-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, 2012-06-28 at 14:55 +0200, Andrea Arcangeli wrote:
> +/*
> + * This function sched_autonuma_balance() is responsible for deciding
> + * which is the best CPU each process should be running on according
> + * to the NUMA statistics collected in mm->mm_autonuma and
> + * tsk->task_autonuma.
> + *
> + * The core math that evaluates the current CPU against the CPUs of
> + * all _other_ nodes is this:
> + *
> + *     if (w_nid > w_other && w_nid > w_cpu_nid)
> + *             weight =3D w_nid - w_other + w_nid - w_cpu_nid;
> + *
> + * w_nid: NUMA affinity of the current thread/process if run on the
> + * other CPU.
> + *
> + * w_other: NUMA affinity of the other thread/process if run on the
> + * other CPU.
> + *
> + * w_cpu_nid: NUMA affinity of the current thread/process if run on
> + * the current CPU.
> + *
> + * weight: combined NUMA affinity benefit in moving the current
> + * thread/process to the other CPU taking into account both the
> higher
> + * NUMA affinity of the current process if run on the other CPU, and
> + * the increase in NUMA affinity in the other CPU by replacing the
> + * other process.

A lot of words, all meaningless without a proper definition of w_*
stuff. How are they calculated and why.

> + * We run the above math on every CPU not part of the current NUMA
> + * node, and we compare the current process against the other
> + * processes running in the other CPUs in the remote NUMA nodes. The
> + * objective is to select the cpu (in selected_cpu) with a bigger
> + * "weight". The bigger the "weight" the biggest gain we'll get by
> + * moving the current process to the selected_cpu (not only the
> + * biggest immediate CPU gain but also the fewer async memory
> + * migrations that will be required to reach full convergence
> + * later). If we select a cpu we migrate the current process to it.

So you do something like:=20

	max_(i, node(i) !=3D curr_node) { weight_i }

That is, you have this weight, then what do you do?

> + * Checking that the current process has higher NUMA affinity than
> the
> + * other process on the other CPU (w_nid > w_other) and not only that
> + * the current process has higher NUMA affinity on the other CPU than
> + * on the current CPU (w_nid > w_cpu_nid) completely avoids ping
> pongs
> + * and ensures (temporary) convergence of the algorithm (at least
> from
> + * a CPU standpoint).

How does that follow?

> + * It's then up to the idle balancing code that will run as soon as
> + * the current CPU goes idle to pick the other process and move it
> + * here (or in some other idle CPU if any).
> + *
> + * By only evaluating running processes against running processes we
> + * avoid interfering with the CFS stock active idle balancing, which
> + * is critical to optimal performance with HT enabled. (getting HT
> + * wrong is worse than running on remote memory so the active idle
> + * balancing has priority)

what?

> + * Idle balancing and all other CFS load balancing become NUMA
> + * affinity aware through the introduction of
> + * sched_autonuma_can_migrate_task(). CFS searches CPUs in the task's
> + * autonuma_node first when it needs to find idle CPUs during idle
> + * balancing or tasks to pick during load balancing.

You talk a lot about idle balance, but there's zero mention of fairness.
This is worrysome.

> + * The task's autonuma_node is the node selected by
> + * sched_autonuma_balance() when it migrates a task to the
> + * selected_cpu in the selected_nid

I think I already said that strict was out of the question and hard
movement like that simply didn't make sense.

> + * Once a process/thread has been moved to another node, closer to
> the
> + * much of memory it has recently accessed,

closer to the recently accessed memory you mean?

>  any memory for that task
> + * not in the new node moves slowly (asynchronously in the
> background)
> + * to the new node. This is done by the knuma_migratedN (where the
> + * suffix N is the node id) daemon described in mm/autonuma.c.
> + *
> + * One non trivial bit of this logic that deserves an explanation is
> + * how the three crucial variables of the core math
> + * (w_nid/w_other/wcpu_nid) are going to change depending on whether
> + * the other CPU is running a thread of the current process, or a
> + * thread of a different process.

No no no,.. its not a friggin detail, its absolutely crucial. Also, if
you'd given proper definition you wouldn't need to hand wave your way
around the dynamics either because that would simply follow from the
definition.

<snip terrible example>

> + * Before scanning all other CPUs' runqueues to compute the above
> + * math,

OK, lets stop calling the one isolated conditional you mentioned 'math'.
On its own its useless.

>  we also verify that the current CPU is not already in the
> + * preferred NUMA node from the point of view of both the process
> + * statistics and the thread statistics. In such case we can return
> to
> + * the caller without having to check any other CPUs' runqueues
> + * because full convergence has been already reached.

Things being in the 'preferred' place don't have much to do with
convergence. Does your model have local minima/maxima where it can get
stuck, or does it always find a global min/max?


> + * This algorithm might be expanded to take all runnable processes
> + * into account but examining just the currently running processes is
> + * a good enough approximation because some runnable processes may
> run
> + * only for a short time so statistically there will always be a bias
> + * on the processes that uses most the of the CPU. This is ideal
> + * because it doesn't matter if NUMA balancing isn't optimal for
> + * processes that run only for a short time.

Almost, but not quite.. it would be so if the sampling could be proven
to be unbiased. But its quite possible for a task to consume most cpu
time and never show up as the current task in your load-balance run.



As it stands you wrote a lot of words.. but none of them were really
helpful in understanding what you do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
