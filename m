Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 037756B0062
	for <linux-mm@kvack.org>; Tue, 29 May 2012 13:45:14 -0400 (EDT)
Date: Tue, 29 May 2012 19:44:23 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 08/35] autonuma: introduce kthread_bind_node()
Message-ID: <20120529174423.GK21339@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
 <1337965359-29725-9-git-send-email-aarcange@redhat.com>
 <1338295753.26856.60.camel@twins>
 <20120529161157.GE21339@redhat.com>
 <1338311091.26856.146.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1338311091.26856.146.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Tue, May 29, 2012 at 07:04:51PM +0200, Peter Zijlstra wrote:
> doing it without mention and keeping a misleading comment near the
> definition.

Right, I forgot to update the comment, I fixed it now.

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 60a699c..0b84494 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1788,7 +1788,7 @@ extern void thread_group_times(struct task_struct *p, cputime_t *ut, cputime_t *
 #define PF_SWAPWRITE	0x00800000	/* Allowed to write to swap */
 #define PF_SPREAD_PAGE	0x01000000	/* Spread page cache over cpuset */
 #define PF_SPREAD_SLAB	0x02000000	/* Spread some slab caches over cpuset */
-#define PF_THREAD_BOUND	0x04000000	/* Thread bound to specific cpu */
+#define PF_THREAD_BOUND	0x04000000	/* Thread bound to specific cpus */
 #define PF_MCE_EARLY    0x08000000      /* Early kill for mce process policy */
 #define PF_MEMPOLICY	0x10000000	/* Non-default NUMA mempolicy */
 #define PF_MUTEX_TESTER	0x20000000	/* Thread belongs to the rt mutex tester */
 

> Just teach each knuma_migrated what node it represents and don't use
> numa_node_id().

It already works like that, I absolutely never use numa_node_id(), I
always use the pgdat passed as parameter to the kernel thread through
the pointer parameter.

But it'd be totally bad not to do the hard bindings to the cpu_s_ of
the node, and not using PF_THREAD_BOUND would just allow userland to
shoot itself in the foot. I mean if PF_THREAD_BOUND wouldn't exist
already I wouldn't add it, but considering somebody bothered to
implement it for the sake to make userland root user "safer", it'd be
really silly not to take advantage of that for knuma_migrated too
(even if it binds to more than 1 CPU).

Additionally I added a bugcheck in the main knuma_migrated loop:

		VM_BUG_ON(numa_node_id() != pgdat->node_id);

to be sure it never goes wrong. This above bugcheck is what allowed me
to find a bug in the numa emulation fixed in commit
d71b5a73fe9af42752c4329b087f7911b35f8f79.

> That way you can change the affinity just fine, it'll be sub-optimal,
> copying memory from node x to node y through node z, but it'll still
> work correctly.

I don't think allowing userland to do suboptimal things (even if it
will only decrease performance and still work correctly) makes
sense (considering somebody added PF_THREAD_BOUND already and it's
zero cost to use).

> numa isn't special in the way per-cpu stuff is special.

Agreed that it won't be as bad as getting per-cpu stuff wrong, it only
slowdown -50% in the worst case, but it's a guaranteed regression in
the best case too, so there's no reason to allow root to shoot itself
in the foot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
