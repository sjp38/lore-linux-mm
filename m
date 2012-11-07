Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 405B86B0062
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 05:57:47 -0500 (EST)
Date: Wed, 7 Nov 2012 10:57:42 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 16/19] mm: numa: Add pte updates, hinting and migration
 stats
Message-ID: <20121107105742.GV8218@suse.de>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
 <1352193295-26815-17-git-send-email-mgorman@suse.de>
 <50996B1A.7040601@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <50996B1A.7040601@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Nov 06, 2012 at 02:55:06PM -0500, Rik van Riel wrote:
> On 11/06/2012 04:14 AM, Mel Gorman wrote:
> >It is tricky to quantify the basic cost of automatic NUMA placement in a
> >meaningful manner. This patch adds some vmstats that can be used as part
> >of a basic costing model.
> >
> >u    = basic unit = sizeof(void *)
> >Ca   = cost of struct page access = sizeof(struct page) / u
> >Cpte = Cost PTE access = Ca
> >Cupdate = Cost PTE update = (2 * Cpte) + (2 * Wlock)
> >	where Cpte is incurred twice for a read and a write and Wlock
> >	is a constant representing the cost of taking or releasing a
> >	lock
> >Cnumahint = Cost of a minor page fault = some high constant e.g. 1000
> >Cpagerw = Cost to read or write a full page = Ca + PAGE_SIZE/u
> >Ci = Cost of page isolation = Ca + Wi
> >	where Wi is a constant that should reflect the approximate cost
> >	of the locking operation
> >Cpagecopy = Cpagerw + (Cpagerw * Wnuma) + Ci + (Ci * Wnuma)
> >	where Wnuma is the approximate NUMA factor. 1 is local. 1.2
> >	would imply that remote accesses are 20% more expensive
> >
> >Balancing cost = Cpte * numa_pte_updates +
> >		Cnumahint * numa_hint_faults +
> >		Ci * numa_pages_migrated +
> >		Cpagecopy * numa_pages_migrated
> >
> >Note that numa_pages_migrated is used as a measure of how many pages
> >were isolated even though it would miss pages that failed to migrate. A
> >vmstat counter could have been added for it but the isolation cost is
> >pretty marginal in comparison to the overall cost so it seemed overkill.
> >
> >The ideal way to measure automatic placement benefit would be to count
> >the number of remote accesses versus local accesses and do something like
> >
> >	benefit = (remote_accesses_before - remove_access_after) * Wnuma
> >
> >but the information is not readily available. As a workload converges, the
> >expection would be that the number of remote numa hints would reduce to 0.
> >
> >	convergence = numa_hint_faults_local / numa_hint_faults
> >		where this is measured for the last N number of
> >		numa hints recorded. When the workload is fully
> >		converged the value is 1.
> >
> >This can measure if the placement policy is converging and how fast it is
> >doing it.
> >
> >Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> I'm skipping the ACKing of the policy patches, which
> appear to be meant to be placeholders for a "real"
> policy. 

I do expect the MORON policy to disappear or at least change so much it
is not recognisable.

> However, you have a few more mechanism patches
> left in the series, which would be required regardless
> of what policy gets merged, so ...
> 

Initially, I had the slow WSS sampling at the end because superficially
they could be considered an optimisation and I wanted to avoid sneaking
optimisations in. On reflection, the slow WSS sampling is pretty fundamental
and I've moved it earlier in the series like so;

 mm: mempolicy: Add MPOL_MF_LAZY mm: mempolicy: Use _PAGE_NUMA to migrate pages
 mm: numa: Add fault driven placement and migration
 mm: sched: numa: Implement constant, per task Working Set Sampling (WSS) rate
 mm: sched: numa: Implement slow start for working set sampling
 mm: numa: Add pte updates, hinting and migration stats
 mm: numa: Migrate on reference policy

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
