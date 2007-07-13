Date: Fri, 13 Jul 2007 15:21:44 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 5/5] [hugetlb] Try to grow pool for MAP_SHARED mappings
Message-Id: <20070713152144.6a7fdaf2.pj@sgi.com>
In-Reply-To: <b040c32a0707131438q64b7f526x6805ec3ee1d0c190@mail.gmail.com>
References: <20070713151621.17750.58171.stgit@kernel>
	<20070713151717.17750.44865.stgit@kernel>
	<20070713130508.6f5b9bbb.pj@sgi.com>
	<1184360742.16671.55.camel@localhost.localdomain>
	<Pine.LNX.4.64.0707131427140.25414@schroedinger.engr.sgi.com>
	<b040c32a0707131438q64b7f526x6805ec3ee1d0c190@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: clameter@sgi.com, agl@us.ibm.com, linux-mm@kvack.org, mel@skynet.ie, apw@shadowen.org, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Ken wrote:
> But we need per cpuset reservation to
> preserve current hugetlb semantics on shared mapping.

Would it make sense to reserve on each node N/M hugetlb pages, where N
is how many hugetlb pages we needed in total for that jobs request,
and M is how many nodes are in the current cpuset:
	nodes_weight(task->mems_allowed)

The general case of nested cpusets is probably too weird to worry much
about, but if we have say three long running jobs in non-overlapping
cpusets, which have differing hugetlb needs (perhaps one of them use
no hugetlb pages, one uses a few, and one uses alot), then can we get
that working, so that each job has the number of hugetlb pages it needs,
spread reasonably uniformly across the nodes it is using.

This could even involve an explicit request, when the job started up,
from userland to the kernel, clearing out any existing hugetlb pages,
so that left over non-uniformities in the spread of hugetlb pages, or
excess allocation of them by prior jobs, don't intrude on the new job.

If we could get to the point where the start of a long running job, on
a set of nodes that it pretty much owned exclusively, was like the
system boot point has been until now, in that the job could wipe the
slate clean and setup some new set of hugetlb pages, in a whatever
balance (uniformly spread, or differing particular numbers on
particular nodes in that cpuset) the job required, assuming the job is
willing to be sufficiently well behaved in its requests, then that
would be good.

Then if ill behaved, convoluted or overlapping uses are tried, it's ok
if we kind of stumble along, not looking too pretty in what hugetlb
pages go where, just so long as we don't crash and don't oom fail when
there is mucho free and contiguous memory left.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
