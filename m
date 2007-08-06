Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l76HJrDu002529
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 13:19:53 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l76IQHx9263696
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 12:26:17 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l76IQGuj029528
	for <linux-mm@kvack.org>; Mon, 6 Aug 2007 12:26:17 -0600
Date: Mon, 6 Aug 2007 11:26:16 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 4/5] hugetlb: fix cpuset-constrained pool resizing
Message-ID: <20070806182616.GT15714@us.ibm.com>
References: <20070806163254.GJ15714@us.ibm.com> <20070806163726.GK15714@us.ibm.com> <20070806163841.GL15714@us.ibm.com> <20070806164055.GN15714@us.ibm.com> <20070806164410.GO15714@us.ibm.com> <Pine.LNX.4.64.0708061101470.24256@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708061101470.24256@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: lee.schermerhorn@hp.com, wli@holomorphy.com, melgor@ie.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, agl@us.ibm.com, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On 06.08.2007 [11:04:48 -0700], Christoph Lameter wrote:
> On Mon, 6 Aug 2007, Nishanth Aravamudan wrote:
> 
> > hugetlb: fix cpuset-constrained pool resizing
> > 
> > With the previous 3 patches in this series applied, if a process is in a
> > constrained cpuset, and tries to grow the hugetlb pool, hugepages may be
> > allocated on nodes outside of the process' cpuset. More concretely,
> > growing the pool via
> > 
> > echo some_value > /proc/sys/vm/nr_hugepages
> > 
> > interleaves across all nodes with memory such that hugepage allocations
> > occur on nodes outside the cpuset. Similarly, this process is able to
> > change the values in values in
> > /sys/devices/system/node/nodeX/nr_hugepages, even when X is not in the
> > cpuset. This directly violates the isolation that cpusets is supposed to
> > guarantee.
> 
> No it does not. Cpusets do not affect the administrative rights of
> users.

A process is limited to nodes 1 and 2.

You think said process should be able to remove hugepages from nodes 0
and 4?

That sounds like a violation of isolation to me.

I understand what you mean, that root should be able to do whatever it
wants, but at the same time, if a root-owned process is running in a
cpuset, it's constrained for a reason.

More importantly, let's say your process (owned by root or not) is
running in a restricted cpuset on  nodes 2 and 3 of a 4-node system and
wants to use 100 hugepages. Using the global sysctl, presuming an equal
distribution of free memory on all nodes, said process would need to
allocate 200 hugepages on the system (50 on each node), to get 100
hugepages on nodes 2 and 3. With this patch, it only needs to allocate
100 hugepages.

Seems far more sane to me that an intentionally restricted process
(i.e., cpusets) can only affect the bits of the system it's restricted
to.

> > For pool growth: fix the sysctl case by only interleaving across the
> > nodes in current's cpuset; fix the sysfs attribute case by verifying the
> > requested node is in current's cpuset. For pool shrinking: both cases
> > are mostly already covered by the cpuset_zone_allowed_softwall() check
> > in dequeue_huge_page_node(), but make sure that we only iterate over the
> > cpusets's nodes in try_to_free_low().
> 
> In that case the number of huge pages is a cpuset attribute. Create
> nr_hugepages under /dev/cpuset/ ...? The sysctl is global and should
> not be cpuset relative.

No, the number of huge pages is a global still. But the huge pages a
*process* has access to is defined by its enclosing cpuset (or memory
policy, I suppose). I think you're confusing the two. Or I am, I don't
know which.

> Otherwise the /proc/sys/vm/nr_hugepages and systecl becomes dependend
> on the cpuset context. Which will be a bit strange.

Become dependent on the *proccess* context, which is, to me, what would
be expected. If a process is restricted in some way, I would expect it
to be restricted in that way across the board.

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
