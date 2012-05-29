Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 94BEE6B0072
	for <linux-mm@kvack.org>; Tue, 29 May 2012 12:12:19 -0400 (EDT)
Date: Tue, 29 May 2012 18:11:57 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 08/35] autonuma: introduce kthread_bind_node()
Message-ID: <20120529161157.GE21339@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
 <1337965359-29725-9-git-send-email-aarcange@redhat.com>
 <1338295753.26856.60.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1338295753.26856.60.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Tue, May 29, 2012 at 02:49:13PM +0200, Peter Zijlstra wrote:
> On Fri, 2012-05-25 at 19:02 +0200, Andrea Arcangeli wrote:
> >  /**
> > + * kthread_bind_node - bind a just-created kthread to the CPUs of a node.
> > + * @p: thread created by kthread_create().
> > + * @nid: node (might not be online, must be possible) for @k to run on.
> > + *
> > + * Description: This function is equivalent to set_cpus_allowed(),
> > + * except that @nid doesn't need to be online, and the thread must be
> > + * stopped (i.e., just returned from kthread_create()).
> > + */
> > +void kthread_bind_node(struct task_struct *p, int nid)
> > +{
> > +       /* Must have done schedule() in kthread() before we set_task_cpu */
> > +       if (!wait_task_inactive(p, TASK_UNINTERRUPTIBLE)) {
> > +               WARN_ON(1);
> > +               return;
> > +       }
> > +
> > +       /* It's safe because the task is inactive. */
> > +       do_set_cpus_allowed(p, cpumask_of_node(nid));
> > +       p->flags |= PF_THREAD_BOUND;
> 
> No, I've said before, this is wrong. You should only ever use
> PF_THREAD_BOUND when its strictly per-cpu. Moving the your numa threads
> to a different node is silly but not fatal in any way.

I changed the semantics of that bitflag, now it means: userland isn't
allowed to shoot itself in the foot and mess with whatever CPU
bindings the kernel has set for the kernel thread.

It'd be a clear regress not to set PF_THREAD_BOUND there. It would be
even worse to remove the CPU binding to the node: it'd risk to copy
memory with both src and dst being in remote nodes from the CPU where
knuma_migrate runs on (there aren't just 2 node systems out there).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
