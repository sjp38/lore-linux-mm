Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 2A37D6B004A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 09:58:45 -0400 (EDT)
Date: Mon, 19 Mar 2012 14:57:45 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH 00/26] sched/numa
Message-ID: <20120319135745.GL24602@redhat.com>
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

With your code they will get -ENOMEM from split_vma and a slowdown in
all regular page faults and vma mangling operations, before they run
out of memory...

The per-page memory loss is 24bytes, AutoNUMA in page terms costs 0.5%
of ram (and only if booted on NUMA hardware, unless noautonuma is
passed as parameter), and I can't imagine that to be a problem on a
system where hardware vendor took shortcuts to install massive amounts
of RAM that is fast to access only locally. If you buy that kind of
hardware losing the cost of 0.5% of RAM of it, is ridiculous compared
to the programmer cost of patching all apps.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
