Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6DL5pKp023254
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 17:05:51 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6DL5hqd154648
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 15:05:43 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6DL5g3h020146
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 15:05:43 -0600
Subject: Re: [PATCH 5/5] [hugetlb] Try to grow pool for MAP_SHARED mappings
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20070713130508.6f5b9bbb.pj@sgi.com>
References: <20070713151621.17750.58171.stgit@kernel>
	 <20070713151717.17750.44865.stgit@kernel>
	 <20070713130508.6f5b9bbb.pj@sgi.com>
Content-Type: text/plain
Date: Fri, 13 Jul 2007 16:05:42 -0500
Message-Id: <1184360742.16671.55.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, apw@shadowen.org, wli@holomorphy.com, clameter@sgi.com, kenchen@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-07-13 at 13:05 -0700, Paul Jackson wrote:
> Adam wrote:
> > +	/*
> > +	 * I haven't figured out how to incorporate this cpuset bodge into
> > +	 * the dynamic hugetlb pool yet.  Hopefully someone more familiar with
> > +	 * cpusets can weigh in on their desired semantics.  Maybe we can just
> > +	 * drop this check?
> > +	 *
> >  	if (chg > cpuset_mems_nr(free_huge_pages_node))
> >  		return -ENOMEM;
> > +	 */
> 
> I can't figure out the value of this check either -- Ken Chen added it, perhaps
> he can comment.

To be honest, I just don't think a global hugetlb pool and cpusets are
compatible, period.  I wonder if moving to the mempool interface and
having dynamic adjustable per-cpuset hugetlb mempools (ick) could make
things work saner.  It's on my list to see if mempools could be used to
replace the custom hugetlb pool code.  Otherwise, Mel's zone_movable
stuff could possibly remove the need for hugetlb pools as we know them.

> But the cpuset behaviour of this hugetlb stuff looks suspicious to me:
>  1) The code in alloc_fresh_huge_page() seems to round robin over
>     the entire system, spreading the hugetlb pages uniformly on all nodes.
>     If one a task in one small cpuset starts aggressively allocating hugetlb
>     pages, do you think this will work, Adam -- looks to me like we will end
>     up calling alloc_fresh_huge_page() many times, most of which will fail to
>     alloc_pages_node() anything because the 'static nid' clock hand will be
>     pointing at a node outside of the current tasks cpuset (not in that tasks
>     mems_allowed).  Inefficient, but I guess ok.

Very good point.  I guess we call alloc_fresh_huge_page in two scenarios
now... 1) By echoing a number into /proc/sys/vm/nr_hugepages, and 2) by
trying to dynamically increase the pool size for a particular process.
Case 1 is not in the context of any process (per se) and so
node_online_map makes sense.  For case 2 we could teach the
__alloc_fresh_huge_page() to take a nodemask.  That could get nasty
though since we'd have to move away from a static variable to get proper
interleaving.

>  2) I don't see what keeps us from picking hugetlb pages off -any- node in the
>     system, perhaps way outside the current cpuset.  We shouldn't be looking for
>     enough available (free_huge_pages - resv_huge_pages) pages in the whole
>     system.  Rather we should be looking for and reserving enough such pages
>     that are in the current tasks cpuset (set in its mems_allowed, to be precise)
>     Folks aren't going to want their hugetlb pages coming from outside their
>     tasks cpuset.

Hmm, I see what you mean, but cpusets are already broken because we use
the global resv_huge_pages counter.  I realize that's what the
cpuset_mems_nr() thing was meant to address but it's not correct.

Perhaps if we make sure __alloc_fresh_huge_page() can be restricted to a
nodemask then we can avoid stealing pages from other cpusets.  But we'd
still be stuck with the existing problem for shared mappings: cpusets +
our strict_reservation algorithm cannot provide guarantees (like we can
without cpusets).

>  3) If there is some code I missed (good chance) that enforces the rule that
>     a task can only get a hugetlb page from a node in its cpuset, then this
>     uniform global allocation of hugetlb pages, as noted in (1) above, can't
>     be right.  Either it will force all nodes, including many nodes outside
>     of the current tasks cpuset, to bulk up on free hugetlb pages, just to
>     get enough of them on nodes allowed by the current tasks cpuset, or else
>     it will fail to get enough on nodes local to the current tasks cpuset.
>     I don't understand the logic well enough to know which, but either way
>     sucks.

I'll cook up a __alloc_fresh_huge_page(nodemask) patch and see if that
makes things better.  Thanks for your review and comments.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
