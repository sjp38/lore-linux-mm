Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 836506B0085
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 02:41:37 -0400 (EDT)
Message-ID: <1349419285.6984.98.camel@marge.simpson.net>
Subject: Re: [PATCH 18/33] autonuma: teach CFS about autonuma affinity
From: Mike Galbraith <efault@gmx.de>
Date: Fri, 05 Oct 2012 08:41:25 +0200
In-Reply-To: <1349308275-2174-19-git-send-email-aarcange@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
	 <1349308275-2174-19-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, 2012-10-04 at 01:51 +0200, Andrea Arcangeli wrote: 
> The CFS scheduler is still in charge of all scheduling decisions. At
> times, however, AutoNUMA balancing will override them.
> 
> Generally, we'll just rely on the CFS scheduler to keep doing its
> thing, while preferring the task's AutoNUMA affine node when deciding
> to move a task to a different runqueue or when waking it up.

Why does AutoNuma fiddle with wakeup decisions _within_ a node?

pgbench intensely disliked me recently depriving it of migration routes
in select_idle_sibling(), so AutoNuma saying NAK seems unlikely to make
it or ilk any happier.

> For example, idle balancing, while looking into the runqueues of busy
> CPUs, will first look for a task that "wants" to run on the NUMA node
> of this idle CPU (one where task_autonuma_cpu() returns true).
> 
> Most of this is encoded in can_migrate_task becoming AutoNUMA aware
> and running two passes for each balancing pass, the first NUMA aware,
> and the second one relaxed.
> 
> Idle or newidle balancing is always allowed to fall back to scheduling
> non-affine AutoNUMA tasks (ones with task_selected_nid set to another
> node). Load_balancing, which affects fairness more than performance,
> is only able to schedule against AutoNUMA affinity if the flag
> /sys/kernel/mm/autonuma/scheduler/load_balance_strict is not set.
> 
> Tasks that haven't been fully profiled yet, are not affected by this
> because their p->task_autonuma->task_selected_nid is still set to the
> original value of -1 and task_autonuma_cpu will always return true in
> that case.

Hm.  How does this profiling work for 1:N loads?  Once you need two or
more nodes, there is no best node for the 1, so restricting it can only
do harm.  For pgbench and ilk, loads of cross node traffic should mean
the 1 is succeeding at keeping the N busy.

-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
