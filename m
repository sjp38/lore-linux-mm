Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id A51956B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 08:25:22 -0400 (EDT)
Message-ID: <1341836705.3462.62.camel@twins>
Subject: Re: [RFC][PATCH 14/26] sched, numa: Numa balancer
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 09 Jul 2012 14:25:05 +0200
In-Reply-To: <4FF9D2EF.7010901@redhat.com>
References: <20120316144028.036474157@chello.nl>
	 <20120316144241.012558280@chello.nl> <4FF9D2EF.7010901@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 2012-07-08 at 14:35 -0400, Rik van Riel wrote:
>=20
> This looks like something that should be fixed before the
> code is submitted for merging upstream.=20

static bool __task_can_migrate(struct task_struct *t, u64 *runtime, int nod=
e)
{
#ifdef CONFIG_CPUSETS
        if (!node_isset(node, t->mems_allowed))
                return false;
#endif

        if (!cpumask_intersects(cpumask_of_node(node), tsk_cpus_allowed(t))=
)
                return false;

        *runtime +=3D t->se.sum_exec_runtime; // @#$#@ 32bit

        return true;
}

static bool process_can_migrate(struct numa_entity *ne, int node)
{
        struct task_struct *p, *t;
        bool allowed =3D false;
        u64 runtime =3D 0;

        rcu_read_lock();
        t =3D p =3D ne_owner(ne);
        if (p) do {
                allowed =3D __task_can_migrate(t, &runtime, node);
                if (!allowed)
                        break;
        } while ((t =3D next_thread(t)) !=3D p);
        rcu_read_unlock();

        /*
         * Don't bother migrating memory if there's less than 1 second
         * of runtime on the tasks.
         */
        return allowed && runtime > NSEC_PER_SEC;
}

is what it looks like..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
