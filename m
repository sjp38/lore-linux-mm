Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 070106B0044
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 18:35:59 -0400 (EDT)
Message-ID: <1332786755.16159.174.camel@twins>
Subject: Re: [PATCH 07/39] autonuma: introduce kthread_bind_node()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 26 Mar 2012 20:32:35 +0200
In-Reply-To: <1332783986-24195-8-git-send-email-aarcange@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
	 <1332783986-24195-8-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, 2012-03-26 at 19:45 +0200, Andrea Arcangeli wrote:
> +void kthread_bind_node(struct task_struct *p, int nid)
> +{
> +       /* Must have done schedule() in kthread() before we set_task_cpu =
*/
> +       if (!wait_task_inactive(p, TASK_UNINTERRUPTIBLE)) {
> +               WARN_ON(1);
> +               return;
> +       }
> +
> +       /* It's safe because the task is inactive. */
> +       do_set_cpus_allowed(p, cpumask_of_node(nid));
> +       p->flags |=3D PF_THREAD_BOUND;
> +}
> +EXPORT_SYMBOL(kthread_bind_node);

That's a wrong use of PF_THREAD_BOUND, we should only use that for
cpumask_weight(tsk_cpus_allowed()) =3D=3D 1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
