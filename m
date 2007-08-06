Subject: Re: [RFC][PATCH 4/5] hugetlb: fix cpuset-constrained pool resizing
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0708061101470.24256@schroedinger.engr.sgi.com>
References: <20070806163254.GJ15714@us.ibm.com>
	 <20070806163726.GK15714@us.ibm.com> <20070806163841.GL15714@us.ibm.com>
	 <20070806164055.GN15714@us.ibm.com> <20070806164410.GO15714@us.ibm.com>
	 <Pine.LNX.4.64.0708061101470.24256@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 06 Aug 2007 15:37:18 -0400
Message-Id: <1186429038.5065.11.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, wli@holomorphy.com, melgor@ie.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, agl@us.ibm.com, pj@sgi.com, "Kenneth W. Chen" <kenneth.w.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-08-06 at 11:04 -0700, Christoph Lameter wrote:
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
> No it does not. Cpusets do not affect the administrative rights of users.

I agree.  nr_hugepages allocates fresh pages for the system wide pool.
I don't think this should not be constrained by cpusets.  I supposed
that if there is a need for this feature, we could document the behavior
and warn admins to only modify nr_hugepages from a program/shell in the
top level cpuset to achieve the current system-wide behavior.

>  
> > For pool growth: fix the sysctl case by only interleaving across the
> > nodes in current's cpuset; fix the sysfs attribute case by verifying the
> > requested node is in current's cpuset. For pool shrinking: both cases
> > are mostly already covered by the cpuset_zone_allowed_softwall() check
> > in dequeue_huge_page_node(), but make sure that we only iterate over the
> > cpusets's nodes in try_to_free_low().
> 
> In that case the number of huge pages is a cpuset attribute. Create 
> nr_hugepages under /dev/cpuset/ ...? The sysctl is global and should not 
> be cpuset relative.
>  
> Otherwise the /proc/sys/vm/nr_hugepages and systecl becomes dependend on 
> the cpuset context. Which will be a bit strange.

I'd like to see it stay a system-wide attribute to preserve current
behavior--with the fixes for memoryless nodes, of course.

I'll queue these up for testing atop Christoph's v5 memoryless nodes
patches.


Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
