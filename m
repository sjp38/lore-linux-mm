Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id E5B5C6B0071
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 09:09:18 -0400 (EDT)
Date: Thu, 5 Jul 2012 15:09:02 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 09/40] autonuma: introduce kthread_bind_node()
Message-ID: <20120705130902.GF7881@cmpxchg.org>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
 <1340888180-15355-10-git-send-email-aarcange@redhat.com>
 <4FEDCB7A.1060007@redhat.com>
 <20120629163820.GQ6676@redhat.com>
 <4FEDDE99.2090105@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FEDDE99.2090105@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Fri, Jun 29, 2012 at 12:58:01PM -0400, Rik van Riel wrote:
> On 06/29/2012 12:38 PM, Andrea Arcangeli wrote:
> >On Fri, Jun 29, 2012 at 11:36:26AM -0400, Rik van Riel wrote:
> >>On 06/28/2012 08:55 AM, Andrea Arcangeli wrote:
> >>
> >>>--- a/include/linux/sched.h
> >>>+++ b/include/linux/sched.h
> >>>@@ -1792,7 +1792,7 @@ extern void thread_group_times(struct task_struct *p, cputime_t *ut, cputime_t *
> >>>   #define PF_SWAPWRITE	0x00800000	/* Allowed to write to swap */
> >>>   #define PF_SPREAD_PAGE	0x01000000	/* Spread page cache over cpuset */
> >>>   #define PF_SPREAD_SLAB	0x02000000	/* Spread some slab caches over cpuset */
> >>>-#define PF_THREAD_BOUND	0x04000000	/* Thread bound to specific cpu */
> >>>+#define PF_THREAD_BOUND	0x04000000	/* Thread bound to specific cpus */
> >>>   #define PF_MCE_EARLY    0x08000000      /* Early kill for mce process policy */
> >>>   #define PF_MEMPOLICY	0x10000000	/* Non-default NUMA mempolicy */
> >>>   #define PF_MUTEX_TESTER	0x20000000	/* Thread belongs to the rt mutex tester */
> >>
> >>Changing the semantics of PF_THREAD_BOUND without so much as
> >>a comment in your changelog or buy-in from the scheduler
> >>maintainers is a big no-no.
> >>
> >>Is there any reason you even need PF_THREAD_BOUND in your
> >>kernel numa threads?
> >>
> >>I do not see much at all in the scheduler code that uses
> >>PF_THREAD_BOUND and it is not clear at all that your
> >>numa threads get any benefit from them...
> >>
> >>Why do you think you need it?
> 
> >This flag is only used to prevent userland to mess with the kernel CPU
> >binds of kernel threads. It is used to avoid the root user to shoot
> >itself in the foot.
> >
> >So far it has been used to prevent changing bindings to a single
> >CPU. I'm setting it also after making a multiple-cpu bind (all CPUs of
> >the node, instead of just 1 CPU).
> 
> Fair enough.  Looking at the scheduler code some more, I
> see that all PF_THREAD_BOUND seems to do is block userspace
> from changing a thread's CPU bindings.
> 
> Peter and Ingo, what is the special magic in PF_THREAD_BOUND
> that should make it only apply to kernel threads that are bound
> to a single CPU?

In the very first review iteration of AutoNUMA, Peter argued that the
scheduler people want to use this flag in other places where they rely
on this thing meaning a single cpu, not a group of them (check out the
cpumask test in debug_smp_processor_id() in lib/smp_processor_id.c).

He also argued that preventing root from rebinding the numa daemons is
not critical to this feature at all.  And I have to agree.

I certainly think this is NOT the change to make a stand about in this
patch set, seriously.  Not about a nice-to-have thing like this that
doesn't really hurt dropping but does create contention.

It can always be a separate effort to bring in such a flag that would
allow it to be used by other daemons, but this really should be a
separate effort and I don't think anything is really lost by dropping
the change from this series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
