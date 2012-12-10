Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 6A5FA6B005D
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 17:19:42 -0500 (EST)
Date: Mon, 10 Dec 2012 22:19:36 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [GIT TREE] Unified NUMA balancing tree, v3
Message-ID: <20121210221936.GO1009@suse.de>
References: <1354839566-15697-1-git-send-email-mingo@kernel.org>
 <alpine.LFD.2.02.1212101902050.4422@ionos>
 <50C62CE7.2000306@redhat.com>
 <20121210191545.GA14412@gmail.com>
 <20121210192828.GL1009@suse.de>
 <20121210200755.GA15097@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121210200755.GA15097@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Mon, Dec 10, 2012 at 09:07:55PM +0100, Ingo Molnar wrote:
> > > 
> > 
> > Yes, I have. The drop I took and the results I posted to you 
> > were based on a tip/master pull from December 9th. v3 was 
> > released on December 7th and your release said to test based 
> > on tip/master. The results are here 
> > https://lkml.org/lkml/2012/12/9/108 . Look at the columns 
> > marked numafix-20121209 which is tip/master with a bodge on 
> > top to remove the "if (p->nr_cpus_allowed != 
> > num_online_cpus())" check.
> 
> Ah, indeed - I saw those results but the 'numafix' tag threw me 
> off.
> 
> Looks like at least in terms of AutoNUMA-benchmark numbers you 
> measured the best-ever results with the -v3 tree? That aspect is 
> obviously good news.
> 

It's still regressing specjbb for lower numbers of warehouses and single
JVM with THP disabled performed very poorly. The system CPU usage is
still through the roof for a number of tests. The rate of migration looks
excessive at parts. Maybe that rate of migration is really necessary but
it seems doubtful that so much bandwidth should be consumed moving data
around by the kernel.

> This part isn't:
> 
> > > If there are any such instances left then I'll investigate, 
> > > but right now it's looking pretty good.
> > 
> > If you had read that report, you would know that I didn't have 
> > results for specjbb with THP enabled due to the JVM crashing 
> > with null pointer exceptions.
> 
> Hm, it's the unified tree where most of the mm/ bits are the 
> AutoNUMA bits from your tree.

The handling of PTEs as an effective hugepage is a major difference.
Holding PTL across task_numa_fault() is a major difference and could be a
significant contributer to the ptl-related bottlenecks you are complaining
about. The fault stats are busted but that's a minor issue. All this is
already in another mail http://www.spinics.net/lists/linux-mm/msg47888.html.

> (It does not match 100%, because 
> your tree has an ancient version of key memory usage statistics 
> that the scheduler needs for its convergence model. I'll take a 
> look at the differences.)
> 

I'm assuming you are referring to the last_cpuid versus last_nid
information that is fed in. That should have been a fairly minor delta
between balancenuma and numacore. It would also affect what mpol_misplaced()
returned.

> Given how well the unified kernel performs,

Except for the places where it doesn't such as single JVM with THP disabled.
Maybe I have a spectacularly unlucky machine.

> and given that the 
> segfaults occur on your box, would you be willing to debug this 
> a bit and help me out fixing the bug? Thanks!
> 

The machine is currently occupied running current tip/master. When it
frees up, I'll try find the time to debug it. My strong suspicion is
that the bug is in the patch that treats 4K as effect hugepage faults,
particularly as an earlier version of that patch had serious problems.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
