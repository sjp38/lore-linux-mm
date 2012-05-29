Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id CBF176B0075
	for <linux-mm@kvack.org>; Tue, 29 May 2012 12:12:43 -0400 (EDT)
Message-ID: <1338307942.26856.111.camel@twins>
Subject: Re: [PATCH 22/35] autonuma: sched_set_autonuma_need_balance
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 29 May 2012 18:12:22 +0200
In-Reply-To: <1337965359-29725-23-git-send-email-aarcange@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
	 <1337965359-29725-23-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Fri, 2012-05-25 at 19:02 +0200, Andrea Arcangeli wrote:
> Invoke autonuma_balance only on the busy CPUs at the same frequency of
> the CFS load balance.
>=20
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  kernel/sched/fair.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
>=20
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index 99d1d33..1357938 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -4893,6 +4893,9 @@ static void run_rebalance_domains(struct softirq_ac=
tion *h)
> =20
>  	rebalance_domains(this_cpu, idle);
> =20
> +	if (!this_rq->idle_balance)
> +		sched_set_autonuma_need_balance();
> +

This just isn't enough.. the whole thing needs to move out of
schedule(). The only time schedule() should ever look at another cpu is
if its idle.

As it stands load-balance actually takes too much time as it is to live
in a softirq, -rt gets around that by pushing all softirqs into a thread
and I was thinking of doing some of that for mainline too.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
