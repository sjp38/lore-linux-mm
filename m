Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id C541D6B004D
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 10:29:38 -0500 (EST)
Date: Mon, 7 Jan 2013 15:29:31 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 29/49] mm: numa: Add pte updates, hinting and migration
 stats
Message-ID: <20130107152931.GM3885@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
 <1354875832-9700-30-git-send-email-mgorman@suse.de>
 <1357299744.5273.4.camel@kernel.cn.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1357299744.5273.4.camel@kernel.cn.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jan 04, 2013 at 05:42:24AM -0600, Simon Jeons wrote:
> On Fri, 2012-12-07 at 10:23 +0000, Mel Gorman wrote:
> > It is tricky to quantify the basic cost of automatic NUMA placement in a
> > meaningful manner. This patch adds some vmstats that can be used as part
> > of a basic costing model.
> 
> Hi Gorman, 
> 
> > 
> > u    = basic unit = sizeof(void *)
> > Ca   = cost of struct page access = sizeof(struct page) / u
> > Cpte = Cost PTE access = Ca
> > Cupdate = Cost PTE update = (2 * Cpte) + (2 * Wlock)
> > 	where Cpte is incurred twice for a read and a write and Wlock
> > 	is a constant representing the cost of taking or releasing a
> > 	lock
> > Cnumahint = Cost of a minor page fault = some high constant e.g. 1000
> > Cpagerw = Cost to read or write a full page = Ca + PAGE_SIZE/u
> 
> Why cpagerw = Ca + PAGE_SIZE/u instead of Cpte + PAGE_SIZE/u ?
> 

Because I was thinking of the cost of just access the struct page.  Arguably
it would be both Ca and Cpte and if I wanted to be very comprehensive I
would also take into account the potential cost of kmapping the page in
the 32-bit case but it'd be overkill. The cost of the PTE and struct page
is negligible in comparison to the actual copy.

> > Ci = Cost of page isolation = Ca + Wi
> > 	where Wi is a constant that should reflect the approximate cost
> > 	of the locking operation
> > Cpagecopy = Cpagerw + (Cpagerw * Wnuma) + Ci + (Ci * Wnuma)
> > 	where Wnuma is the approximate NUMA factor. 1 is local. 1.2
> > 	would imply that remote accesses are 20% more expensive
> > 
> > Balancing cost = Cpte * numa_pte_updates +
> > 		Cnumahint * numa_hint_faults +
> > 		Ci * numa_pages_migrated +
> > 		Cpagecopy * numa_pages_migrated
> > 
> 
> Since Cpagecopy has already accumulated ci why count ci twice ?
> 

Good point. Interestingly when I went to fix this in mmtests I found
that I accounted for Ci properly there but got it wrong in the
changelog.

> > Note that numa_pages_migrated is used as a measure of how many pages
> > were isolated even though it would miss pages that failed to migrate. A
> > vmstat counter could have been added for it but the isolation cost is
> > pretty marginal in comparison to the overall cost so it seemed overkill.
> > 
> > The ideal way to measure automatic placement benefit would be to count
> > the number of remote accesses versus local accesses and do something like
> > 
> > 	benefit = (remote_accesses_before - remove_access_after) * Wnuma
> > 
> > but the information is not readily available. As a workload converges, the
> > expection would be that the number of remote numa hints would reduce to 0.
> > 
> > 	convergence = numa_hint_faults_local / numa_hint_faults
> > 		where this is measured for the last N number of
> > 		numa hints recorded. When the workload is fully
> > 		converged the value is 1.
> > 
> 
> convergence tend to 0 is better or 1 is better

1 is better.

> If tend to 1, Cpte *
> numa_pte_updates + Cnumahint * numa_hint_faults are just waste, where I
> miss?
> 

I don't get the question, waste of what? None of these calculations are
used by the kernel. The kernel only maintains counters and the point of
the changelog was to illustrate how the counters can be used to do some
meaningful evaluation.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
