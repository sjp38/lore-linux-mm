Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id BBF226B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 17:34:36 -0400 (EDT)
Date: Thu, 11 Oct 2012 22:34:32 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00/33] AutoNUMA27
Message-ID: <20121011213432.GQ3317@csn.ul.ie>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, Oct 04, 2012 at 01:50:42AM +0200, Andrea Arcangeli wrote:
> Hello everyone,
> 
> This is a new AutoNUMA27 release for Linux v3.6.
> 

So after getting through the full review of it, there wasn't anything
I could not stand. I think it's *very* heavy on some of the paths like
the idle balancer which I was not keen on and the fault paths are also
quite heavy.  I think the weight on some of these paths can be reduced
but not to 0 if the objectives to autonuma are to be met.

I'm not fully convinced that the task exchange is actually necessary or
beneficial because it somewhat assumes that there is a symmetry between CPU
and memory balancing that may not be true. The fact that it only considers
tasks that are currently running feels a bit random but examining all tasks
that recently ran on the node would be far too expensive to there is no
good answer. You are caught between a rock and a hard place and either
direction you go is wrong for different reasons. You need something more
frequent than scans (because it'll converge too slowly) but doing it from
the balancer misses some tasks and may run too frequently and it's unclear
how it effects the current load balancer decisions. I don't have a good
alternative solution for this but ideally it would be better integrated with
the existing scheduler when there is more data on what those scheduling
decisions should be. That will only come from a wide range of testing and
the inevitable bug reports.

That said, this is concentrating on the problems without considering the
situations where it would work very well.  I think it'll come down to HPC
and anything jitter-sensitive will hate this while workloads like JVM,
virtualisation or anything that uses a lot of memory without caring about
placement will love it. It's not perfect but it's better than incurring
the cost of remote access unconditionally.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
