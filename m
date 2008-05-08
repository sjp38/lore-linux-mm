Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m481v8ke006270
	for <linux-mm@kvack.org>; Thu, 8 May 2008 11:57:08 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m481v1Kj4055088
	for <linux-mm@kvack.org>; Thu, 8 May 2008 11:57:01 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m481v9Gi001290
	for <linux-mm@kvack.org>; Thu, 8 May 2008 11:57:10 +1000
Date: Thu, 8 May 2008 11:48:22 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH 0/3] Guarantee faults for processes that call
	mmap(MAP_PRIVATE) on hugetlbfs v2
Message-ID: <20080508014822.GE5156@yookeroo.seuss>
References: <20080507193826.5765.49292.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080507193826.5765.49292.sendpatchset@skynet.skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, dean@arctic.org, apw@shadowen.org, linux-kernel@vger.kernel.org, wli@holomorphy.com, andi@firstfloor.org, kenchen@google.com, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, May 07, 2008 at 08:38:26PM +0100, Mel Gorman wrote:
> MAP_SHARED mappings on hugetlbfs reserve huge pages at mmap() time.
> This guarantees all future faults against the mapping will succeed.
> This allows local allocations at first use improving NUMA locality whilst
> retaining reliability.
> 
> MAP_PRIVATE mappings do not reserve pages. This can result in an application
> being SIGKILLed later if a huge page is not available at fault time. This
> makes huge pages usage very ill-advised in some cases as the unexpected
> application failure cannot be detected and handled as it is immediately fatal.
> Although an application may force instantiation of the pages using mlock(),
> this may lead to poor memory placement and the process may still be killed
> when performing COW.
> 
> This patchset introduces a reliability guarantee for the process which creates
> a private mapping, i.e. the process that calls mmap() on a hugetlbfs file
> successfully.  The first patch of the set is purely mechanical code move to
> make later diffs easier to read. The second patch will guarantee faults up
> until the process calls fork(). After patch two, as long as the child keeps
> the mappings, the parent is no longer guaranteed to be reliable. Patch
> 3 guarantees that the parent will always successfully COW by unmapping
> the pages from the child in the event there are insufficient pages in the
> hugepage pool in allocate a new page, be it via a static or dynamic pool.

I don't think patch 3 is a good idea.  It's a fair bit of code to
implement a pretty bizarre semantic that I really don't think is all
that useful.  Patches 1-2 are already sufficient to cover the
fork()/exec() case and a fair proportion of fork()/minor
frobbing/exit() cases.  If the child also needs to write the hugepage
area, chances are it's doing real work and we care about its
reliability too.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
