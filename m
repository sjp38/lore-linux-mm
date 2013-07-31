Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 989FE6B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 06:10:44 -0400 (EDT)
Date: Wed, 31 Jul 2013 11:10:41 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 15/18] sched: Set preferred NUMA node based on number of
 private faults
Message-ID: <20130731101041.GQ2296@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-16-git-send-email-mgorman@suse.de>
 <20130726112050.GJ27075@twins.programming.kicks-ass.net>
 <20130731092938.GM2296@suse.de>
 <20130731093437.GX3008@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130731093437.GX3008@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 31, 2013 at 11:34:37AM +0200, Peter Zijlstra wrote:
> On Wed, Jul 31, 2013 at 10:29:38AM +0100, Mel Gorman wrote:
> > > Hurmph I just stumbled upon this PMD 'trick' and I'm not at all sure I
> > > like it. If an application would pre-fault/initialize its memory with
> > > the main thread we'll collapse it into a PMDs and forever thereafter (by
> > > virtue of do_pmd_numa_page()) they'll all stay the same. Resulting in
> > > PMD granularity.
> > > 
> > 
> > Potentially yes. When that PMD trick was introduced it was because the cost
> > of faults was very high due to a high scanning rate. The trick mitigated
> > worse-case scenarios until faults were properly accounted for and the scan
> > rates were better controlled. As these *should* be addressed by the series
> > I think I will be adding a patch to kick away this PMD crutch and see how
> > it looks in profiles.
> 
> I've been thinking on this a bit and I think we should split these and
> thp pages when we get shared faults from different nodes on them and
> refuse thp collapses when the pages are on different nodes.
> 

Agreed, I reached the same conclusion when thinking about THP false sharing
just before I went on holiday. The first prototype patch was a bit messy
and performed very badly so "Handle false sharing of THP" was chucked onto
the TODO pile to worry about when I got back. It also collided a little with
the PMD handling of base pages which is another reason to get rid of that.

> With the exception that when we introduce the interleave mempolicies we
> should define 'different node' as being outside of the interleave mask.

Understood.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
