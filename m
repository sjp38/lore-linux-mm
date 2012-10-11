Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 8F6136B0068
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 11:53:06 -0400 (EDT)
Date: Thu, 11 Oct 2012 16:53:02 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 15/33] autonuma: alloc/free/init task_autonuma
Message-ID: <20121011155302.GA3317@csn.ul.ie>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <1349308275-2174-16-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1349308275-2174-16-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, Oct 04, 2012 at 01:50:57AM +0200, Andrea Arcangeli wrote:
> This is where the dynamically allocated task_autonuma structure is
> being handled.
> 
> This is the structure holding the per-thread NUMA statistics generated
> by the NUMA hinting page faults. This per-thread NUMA statistical
> information is needed by sched_autonuma_balance to make optimal NUMA
> balancing decisions.
> 
> It also contains the task_selected_nid which hints the stock CPU
> scheduler on the best NUMA node to schedule this thread on (as decided
> by sched_autonuma_balance).
> 
> The reason for keeping this outside of the task_struct besides not
> using too much kernel stack, is to only allocate it on NUMA
> hardware. So the non NUMA hardware only pays the memory of a pointer
> in the kernel stack (which remains NULL at all times in that case).
> 
> If the kernel is compiled with CONFIG_AUTONUMA=n, not even the pointer
> is allocated on the kernel stack of course.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

There is a possibility that someone will complain about the extra
kmalloc() during fork that is now necessary for the autonuma structure.
Microbenchmarks will howl but who cares -- autonuma only makes sense for
long-lived processes anyway. It may be necessary in the future to defer
this allocation until the process has consumed a few CPU seconds and
likely to hang around for a while. Overkill for now though so

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
