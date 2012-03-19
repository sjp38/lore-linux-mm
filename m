Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id BFBE86B004A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 10:08:10 -0400 (EDT)
Date: Mon, 19 Mar 2012 15:07:01 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH 00/26] sched/numa
Message-ID: <20120319140701.GM24602@redhat.com>
References: <20120316144028.036474157@chello.nl>
 <4F670325.7080700@redhat.com>
 <1332155527.18960.292.camel@twins>
 <20120319130401.GI24602@redhat.com>
 <1332163591.18960.334.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1332163591.18960.334.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Avi Kivity <avi@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 19, 2012 at 02:26:31PM +0100, Peter Zijlstra wrote:
> On Mon, 2012-03-19 at 14:04 +0100, Andrea Arcangeli wrote:
> > If you boot with memcg compiled in, that's taking an equivalent amount
> > of memory per-page.
> > 
> > If you can bear the memory loss when memcg is compiled in even when
> > not enabled, you sure can bear it on NUMA systems that have lots of
> > memory, so it's perfectly ok to sacrifice a bit of it so that it
> > performs like not-NUMA but you still have more memory than not-NUMA.
> > 
> I think the overhead of memcg is quite insane as well. And no I cannot
> bear that and have it disabled in all my kernels.
> 
> NUMA systems having lots of memory is a false argument, that doesn't
> mean we can just waste tons of it, people pay good money for that
> memory, they want to use it.
> 
> I fact, I know that HPC people want things like swap-over-nfs so they
> can push infrequently running system crap out into swap so they can get
> these few extra megabytes of memory. And you're proposing they give up
> ~100M just like that?

If they run 20% faster absolutely they will give up the 100M.

You may want to check how many gigabytes they swap... going through
the mess of swap-over-nfs to swap _only_ ~100M would be laughable. If
they push to swap several gigabytes ok, but then 100M more or less
won't matter.

If you intend to proof AutoNUMA design isn't ok, do not complain about
the memory use per page, do not complain about the pagetable scanner,
only complain about the cost of the numa hinting page fault in
presence of virt and vmexists. That is frankly my only slight concern
and it largely depends on hardware and not enough benchmarking has
been done to give it a green light yet. I am optimistic though because
worst case the page fault numa hinting fault frequency should be
reduced for tasks with mmu notifier attached to it and in turn
secondary mmus and higher page fault costs.

Pagetable scanner and memory use will be absolutely ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
