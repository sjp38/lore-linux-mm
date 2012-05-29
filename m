Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 2595D6B0068
	for <linux-mm@kvack.org>; Tue, 29 May 2012 10:03:12 -0400 (EDT)
Message-ID: <1338300173.26856.83.camel@twins>
Subject: Re: [PATCH 20/35] autonuma: avoid CFS select_task_rq_fair to return
 -1
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 29 May 2012 16:02:53 +0200
In-Reply-To: <1337965359-29725-21-git-send-email-aarcange@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
	 <1337965359-29725-21-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Fri, 2012-05-25 at 19:02 +0200, Andrea Arcangeli wrote:
> Fix to avoid -1 retval.
>=20
> Includes fixes from Hillf Danton <dhillf@gmail.com>.

This changelog is very much insufficient. It fails to mention why your
solution is the right one or if there's something else wrong with that
code.

> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  kernel/sched/fair.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
>=20
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index 940e6d1..137119f 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -2789,6 +2789,9 @@ select_task_rq_fair(struct task_struct *p, int sd_f=
lag, int wake_flags)
>  		if (new_cpu =3D=3D -1 || new_cpu =3D=3D cpu) {
>  			/* Now try balancing at a lower domain level of cpu */
>  			sd =3D sd->child;
> +			if (new_cpu < 0)
> +				/* Return prev_cpu is find_idlest_cpu failed */
> +				new_cpu =3D prev_cpu;
>  			continue;
>  		}
> =20
> @@ -2807,6 +2810,7 @@ select_task_rq_fair(struct task_struct *p, int sd_f=
lag, int wake_flags)
>  unlock:
>  	rcu_read_unlock();
> =20
> +	BUG_ON(new_cpu < 0);
>  	return new_cpu;
>  }
>  #endif /* CONFIG_SMP */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
