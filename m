Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id C0FE76B0068
	for <linux-mm@kvack.org>; Tue, 29 May 2012 08:49:34 -0400 (EDT)
Message-ID: <1338295753.26856.60.camel@twins>
Subject: Re: [PATCH 08/35] autonuma: introduce kthread_bind_node()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 29 May 2012 14:49:13 +0200
In-Reply-To: <1337965359-29725-9-git-send-email-aarcange@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
	 <1337965359-29725-9-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Fri, 2012-05-25 at 19:02 +0200, Andrea Arcangeli wrote:
>  /**
> + * kthread_bind_node - bind a just-created kthread to the CPUs of a node=
.
> + * @p: thread created by kthread_create().
> + * @nid: node (might not be online, must be possible) for @k to run on.
> + *
> + * Description: This function is equivalent to set_cpus_allowed(),
> + * except that @nid doesn't need to be online, and the thread must be
> + * stopped (i.e., just returned from kthread_create()).
> + */
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

No, I've said before, this is wrong. You should only ever use
PF_THREAD_BOUND when its strictly per-cpu. Moving the your numa threads
to a different node is silly but not fatal in any way.

> +}
> +EXPORT_SYMBOL(kthread_bind_node);=20


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
