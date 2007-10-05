Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l95KUmea028641
	for <linux-mm@kvack.org>; Fri, 5 Oct 2007 16:30:49 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l95KUlaS222218
	for <linux-mm@kvack.org>; Fri, 5 Oct 2007 14:30:47 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l95KUkS0017741
	for <linux-mm@kvack.org>; Fri, 5 Oct 2007 14:30:47 -0600
Date: Fri, 5 Oct 2007 13:30:45 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH 2/2] hugetlb: fix pool allocation with empty nodes
Message-ID: <20071005203045.GR29663@us.ibm.com>
References: <20071003224538.GB29663@us.ibm.com> <20071003224904.GC29663@us.ibm.com> <20071004031229.GE29663@us.ibm.com> <1191614168.5299.19.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1191614168.5299.19.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: clameter@sgi.com, wli@holomorphy.com, anton@samba.org, agl@us.ibm.com, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On 05.10.2007 [15:56:08 -0400], Lee Schermerhorn wrote:
> On Wed, 2007-10-03 at 20:12 -0700, Nishanth Aravamudan wrote:
> > On 03.10.2007 [15:49:04 -0700], Nishanth Aravamudan wrote:
> > > hugetlb: fix pool allocation with empty nodes
> > > 
> > > Anton found a problem with the hugetlb pool allocation when some nodes
> > > have no memory (http://marc.info/?l=linux-mm&m=118133042025995&w=2). Lee
> > > worked on versions that tried to fix it, but none were accepted.
> > > Christoph has created a set of patches which allow for GFP_THISNODE
> > > allocations to fail if the node has no memory and for exporting a
> > > nodemask indicating which nodes have memory. Simply interleave across
> > > this nodemask rather than the online nodemask.
> > > 
> > > Tested on x86 !NUMA, x86 NUMA, x86_64 NUMA, ppc64 NUMA with 2 memoryless
> > > nodes.
> > > 
> > > Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> > > 
> > > ---
> > > Would it be better to combine this patch directly in 1/2? There is no
> > > functional difference, really, just a matter of 'correctness'. Without
> > > this patch, we'll iterate over nodes that we can't possibly do THISNODE
> > > allocations on. So I guess this falls more into an optimization?
> > > 
> > > Also, I see that Adam's patches have been pulled in for the next -mm. I
> > > can rebase on top of them and retest to minimise Andrew's work.
> > 
> > FWIW, both patches apply pretty easily on top of Adam's stack. 1/2
> > requires a bit of massaging because functions have moved out of their
> > context, but 2/2 applies cleanly. I noticed, though, that Adam's patches
> > use node_online_map when they should use node_states[N_HIGH_MEMORY], so
> > shall I modify this patch to simply be
> > 
> > hugetlb: only iterate over populated nodes
> > 
> > and fix all of the instances in hugetlb.c?
> > 
> > Still need to test the patches on top of Adam's stack before I'll ask
> > Andrew to pick them up.
> 
> Nish:  Have you tried these atop Mel Gorman's onezonelist patches.
> I've been maintaining your previous posting of the 4 hugetlb patches
> [i.e., including the per node sysfs attributes] atop Mel's patches and
> some of my additional mempolicy "cleanups".  I just go around to
> testing the whole mess and found that I can only allocate hugetlb
> pages on node 1, whether I set /proc/sys/vm/nr_hugepages or the per
> node sysfs attributes.  

I have not tested with Mel's one-zonelist patches. I can add that to my
queue to test, with, though.

> I'm trying to isolate the problem now.  I've determined that with just
> your rebased patched on 23-rc8-mm2, allocations appear to work as
> expected.  E.g., writing '64' to /proc/sys/vm/nr_hugepages yields 16
> huge pages on each of 4 nodes.  My dma-only node 4 is skipped because
> it doesn't have sufficient memory to allocate a single ia64 huge page.
> If it did, I fear I'd see a huge page there with the current patches.
> Have to reconfig the hardware to test that.

Hrm, I'll look at Mel's patches to see if I see anything obvious.

> Anyway, I won't get back to this until mid-next week.  Just wanted to
> give you [and Mel] a heads up about the possible interaction.
> However, it could be my patches that are causing the problem.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
