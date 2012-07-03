Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id BEC426B0070
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 07:53:53 -0400 (EDT)
Message-ID: <1341316406.23484.64.camel@twins>
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 03 Jul 2012 13:53:26 +0200
In-Reply-To: <1340894776.28750.44.camel@twins>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
	 <1340888180-15355-14-git-send-email-aarcange@redhat.com>
	 <1340894776.28750.44.camel@twins>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, 2012-06-28 at 16:46 +0200, Peter Zijlstra wrote:
> As it stands you wrote a lot of words.. but none of them were really
> helpful in understanding what you do.=20

Can you write something like the below for autonuma?

That is, present what your balancing goals are and why and in what
measures and at what cost.

Present it in 'proper' math, not examples.

Don't try and make it perfect -- the below isn't, just try and make it a
coherent story.

As a side note, anybody has a good way to show 7 follows from 6 other
than waving hands? One has to show 6 is fully connected and that the max
path length is indeed log n. I spend an hour last night trying but I've
forgotten too much of graph theory to make it stick.

---
 kernel/sched/fair.c | 118 ++++++++++++++++++++++++++++++++++++++++++++++++=
+++-
 1 file changed, 116 insertions(+), 2 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 3704ad3..2e44318 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -3077,8 +3077,122 @@ static bool yield_to_task_fair(struct rq *rq, struc=
t task_struct *p, bool preemp
=20
 #ifdef CONFIG_SMP
 /**************************************************
- * Fair scheduling class load-balancing methods:
- */
+ * Fair scheduling class load-balancing methods.
+ *
+ * BASICS
+ *
+ * The purpose of load-balancing is to achieve the same basic fairness the
+ * per-cpu scheduler provides, namely provide a proportional amount of com=
pute
+ * time to each task. This is expressed in the following equation:
+ *
+ *   W_i,n/P_i =3D=3D W_j,n/P_j for all i,j                               =
(1)
+ *
+ * Where W_i,n is the n-th weight average for cpu i. The instantaneous wei=
ght
+ * W_i,0 is defined as:
+ *
+ *   W_i,0 =3D \Sum_j w_i,j                                             (2=
)
+ *
+ * Where w_i,j is the weight of the j-th runnable task on cpu i. This weig=
ht
+ * is derived from the nice value as per prio_to_weight[].
+ *
+ * The weight average is an exponential decay average of the instantaneous
+ * weight:
+ *
+ *   W'_i,n =3D (2^n - 1) / 2^n * W_i,n + 1 / 2^n * W_i,0               (3=
)
+ *
+ * P_i is the cpu power (or compute capacity) of cpu i, typically it is th=
e
+ * fraction of 'recent' time available for SCHED_OTHER task execution. But=
 it
+ * can also include other factors [XXX].
+ *
+ * To achieve this balance we define a measure of imbalance which follows
+ * directly from (1):
+ *
+ *   imb_i,j =3D max{ avg(W/P), W_i/P_i } - min{ avg(W/P), W_j/P_j }    (4=
)
+ *
+ * We them move tasks around to minimize the imbalance. In the continuous
+ * function space it is obvious this converges, in the discrete case we ge=
t
+ * a few fun cases generally called infeasible weight scenarios.
+ *
+ * [XXX expand on:
+ *     - infeasible weights;
+ *     - local vs global optima in the discrete case. ]
+ *
+ *
+ * SCHED DOMAINS
+ *
+ * In order to solve the imbalance equation (4), and avoid the obvious O(n=
^2)
+ * for all i,j solution, we create a tree of cpus that follows the hardwar=
e
+ * topology where each level pairs two lower groups (or better). This resu=
lts
+ * in O(log n) layers. Furthermore we reduce the number of cpus going up t=
he
+ * tree to only the first of the previous level and we decrease the freque=
ncy
+ * of load-balance at each level inv. proportional to the number of cpus i=
n
+ * the groups.
+ *
+ * This yields:
+ *
+ *     log_2 n     1     n
+ *   \Sum       { --- * --- * 2^i } =3D O(n)                            (5=
)
+ *     i =3D 0      2^i   2^i
+ *                               `- size of each group
+ *         |         |     `- number of cpus doing load-balance
+ *         |         `- freq
+ *         `- sum over all levels
+ *
+ * Coupled with a limit on how many tasks we can migrate every balance pas=
s,
+ * this makes (5) the runtime complexity of the balancer.
+ *
+ * An important property here is that each CPU is still (indirectly) conne=
cted
+ * to every other cpu in at most O(log n) steps:
+ *
+ * The adjacency matrix of the resulting graph is given by:
+ *
+ *             log_2 n    =20
+ *   A_i,j =3D \Union     (i % 2^k =3D=3D 0) && i / 2^(k+1) =3D=3D j / 2^(=
k+1)  (6)
+ *             k =3D 0
+ *
+ * And you'll find that:
+ *
+ *   A^(log_2 n)_i,j !=3D 0  for all i,j                                (7=
)
+ *
+ * Showing there's indeed a path between every cpu in at most O(log n) ste=
ps.
+ * The task movement gives a factor of O(m), giving a convergence complexi=
ty
+ * of:
+ *
+ *   O(nm log n),  n :=3D nr_cpus, m :=3D nr_tasks                        =
(8)
+ *
+ *
+ * WORK CONSERVING
+ *
+ * In order to avoid CPUs going idle while there's still work to do, new i=
dle
+ * balancing is more aggressive and has the newly idle cpu iterate up the =
domain
+ * tree itself instead of relying on other CPUs to bring it work.
+ *
+ * This adds some complexity to both (5) and (8) but it reduces the total =
idle
+ * time.
+ *
+ * [XXX more?]
+ *
+ *
+ * CGROUPS
+ *
+ * Cgroups make a horror show out of (2), instead of a simple sum we get:
+ *
+ *                                s_k,i
+ *   W_i,0 =3D \Sum_j \Prod_k w_k * -----                               (9=
)
+ *                                 S_k
+ *
+ * Where
+ *
+ *   s_k,i =3D \Sum_j w_i,j,k  and  S_k =3D \Sum_i s_k,i                 (=
10)
+ *
+ * w_i,j,k is the weight of the j-th runnable task in the k-th cgroup on c=
pu i.
+ *
+ * The big problem is S_k, its a global sum needed to compute a local (W_i=
)
+ * property.
+ *
+ * [XXX write more on how we solve this.. _after_ merging pjt's patches th=
at
+ *      rewrite all of this once again.]
+ */=20
=20
 static unsigned long __read_mostly max_load_balance_interval =3D HZ/10;
=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
