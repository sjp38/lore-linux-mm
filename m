Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5F1E56B006A
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 13:27:48 -0400 (EDT)
Subject: Re: [RFC 0/3] hugetlb: constrain allocation/free based on task
	mempolicy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090630154716.1583.25274.sendpatchset@lts-notebook>
References: <20090630154716.1583.25274.sendpatchset@lts-notebook>
Content-Type: text/plain
Date: Wed, 01 Jul 2009 13:28:23 -0400
Message-Id: <1246469303.23497.187.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-numa@vger.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 2009-06-30 at 11:47 -0400, Lee Schermerhorn wrote: 
> RFC 0/3 hugetlb: constrain allocation/free based on task mempolicy
> 
> Against:  25jun09 mmotm atop the "hugetlb:  balance freeing..."
> series
> 
> This is V1 of a series of patches to constrain the allocation and
> freeing of persistent huge pages using the task NUMA mempolicy of
> the task modifying "nr_hugepages".  This series is based on Mel
> Gorman's suggestion to use task mempolicy.
> 
> I have some concerns about a subtle change in behavior [see patch
> 2/3 and the updated documentation] and the fact that
> this mechanism ignores some of the semantics of the mempolicy
> mode [again, see the doc].   However, this method seems to work
> fairly well.  And, IMO, the resulting code doesn't look all that
> bad.
> 
> A couple of limitations in this version:
> 
> 1) I haven't implemented a boot time parameter to constrain the
>    boot time allocation of huge pages.  This can be added if
>    anyone feels strongly that it is required.
> 
> 2) I have not implemented a per node nr_overcommit_hugepages as
>    David Rientjes and I discussed earlier.  Again, this can be
>    added and specific nodes can be addressed using the mempolicy
>    as this series does for allocation and free.
> 

I have tested this series atop the 25jun mmotm, based on .31-rc1, and
the "hugetlb: balance freeing..." series using the libhugetlbfs 2.5 test
suite and instructions from Mel Gorman on how to run it:

./obj/hugeadm --pool-pages-min 2M:64
./obj/hugeadm --create-global-mounts
make func >Log 2>&1 ...

With default mempolicy, the tests complete without error on a 4-node, 8
core x86_64 system w/ 8G/node:

********** TEST SUMMARY
*                      2M
*                      32-bit 64-bit
*     Total testcases:    90     93
*             Skipped:     0      0
*                PASS:    90     93
*                FAIL:     0      0
*    Killed by signal:     0      0
*   Bad configuration:     0      0
*       Expected FAIL:     0      0
*     Unexpected PASS:     0      0
* Strange test result:     0      0
**********

Next, I tried to run the test on just nodes 2 and 3 with the same
hugepage setup as above--64 pages across all 4 nodes:

numactl -m 2,3 make func

This resulted in LOTS of OOM kills of innocent bystander tasks.  I
thought this was because the tests would only have access to 1/2 of the
64 pre-allocated huge pages--those on nodes 2 & 3.  So, I increased the
number of preallocated pages to 256 with default mempolicy, resulting in
64 huge pages per node.  This would give the tests 128 huge pages.  More
than enough, I thought.

However, I still saw OOM kills [but no dumps of the memory state]:

Out of memory: kill process 5225 (httpd) score 59046 or a child
Killed process 5225 (httpd)
Out of memory: kill process 5226 (httpd) score 59046 or a child
Killed process 5226 (httpd)
Out of memory: kill process 5227 (httpd) score 59046 or a child
Killed process 5227 (httpd)
Out of memory: kill process 5228 (httpd) score 59046 or a child
Killed process 5228 (httpd)
Out of memory: kill process 5229 (httpd) score 59046 or a child
Killed process 5229 (httpd)
Out of memory: kill process 5230 (httpd) score 59046 or a child
Killed process 5230 (httpd)
Out of memory: kill process 5828 (alloc-instantia) score 8188 or a child
Killed process 5828 (alloc-instantia)
Out of memory: kill process 5829 (alloc-instantia) score 8349 or a child
Killed process 5829 (alloc-instantia)
Out of memory: kill process 5830 (alloc-instantia) score 8188 or a child
Killed process 5830 (alloc-instantia)
Out of memory: kill process 5831 (alloc-instantia) score 8349 or a child
Killed process 5831 (alloc-instantia)
Out of memory: kill process 5834 (truncate_sigbus) score 8252 or a child
Killed process 5834 (truncate_sigbus)
Out of memory: kill process 5835 (truncate_sigbus) score 8413 or a child
Killed process 5835 (truncate_sigbus)

And 3 of the tests complained about unexpected huge page count--e.g,
expected 0, saw 128.  The '128' huge pages are those on nodes 0 and 1
that the tests couldn't manipulate because of the mempolicy constraints.
It turns out that the libhugetlbfs tests assume they have access to the
entire system and use the global counters from /proc/meminfo
and /sys/kernel/mm/hugepages/* to size the tests and set expectations.
When constrained by mempolicy, these assumptions break down.  I've seen
this behavior in other test suites--e.g., trying to run the numactl
regression tests in a cpuset.

So, I emptied the huge page pool by setting nr_hugepages to 0, and
populated the huge page pool from only the nodes I was going to use in
the tests:

numactl -m 2,3 ./obj/hugeadm --pool-pages-min 2M:64

Then, rerun the tests constrained to nodes 2 and 3:

numactl -m 2,3 make func

This time the tests ran to completion with no OOM kills and no errors.

So, this series doesn't actually break the hugetlb functionality, but
running the test suite under a constrained mempolicy does break its
assumptions.

Perhaps, libhugetlbfs functions like get_huge_page_counter() should be
enhanced, or a numa-aware version provided, to return the sum of the per
node values for the nodes allowed by the calling task's mempolicy,
rather than the system-wide count?

Cpuset interaction:

I created a test cpuset with nodes/mems 2,3.  With my shell in that
cpuset:

./obj/hugeadm --pool-pages-min 2M:64

[i.e., with default mempolicy] still distributes the 64 huge pages
across all 4 nodes, as cpuset mems_allowed does not constrain "fresh"
huge page allocation and default mempolicy translates to all on-line
nodes allowed.  However,

numactl -m all ./obj/hugeadm --pool-pages-min 2M:64

results in 32 huge pages on each of nodes 2 and 3 because the memory
policy installed by numactl IS constrained by the cpuset mems_allowed.
Then,

numactl -m 2,3 make func

from within the test cpuset [nodes 2,3], results in:
********** TEST SUMMARY
*                      2M
*                      32-bit 64-bit
*     Total testcases:    90     93
*             Skipped:     0      0
*                PASS:    87     90
*                FAIL:     1      1
*    Killed by signal:     0      0
*   Bad configuration:     2      2
*       Expected FAIL:     0      0
*     Unexpected PASS:     0      0
* Strange test result:     0      0
**********

The "Bad configuration"s are the result of sched_setaffinity() failing
because of cpuset constraints.  Again, the tests are not set up to work
in a cpuset/mempolicy constrained environment.  The failures are the
result of a child of "alloc-instantiate-race" being killed by a signal
[segfault?] in both 32 and 64 bit modes.

Running the tests in the cpuset with default mempolicy results in a
similar, but different set of failures because the tests free and
reallocate the huge pages and they end up spread across all nodes again.

All of these failures can be attributed to the tests, and perhaps
libhugetlbfs, not considering the effects of running in a constrained
environment.

-------------------

I suspected that some of these errors would occur on a kernel without
this patch set.  Indeed, under 2.6.31-rc1 with mmotm of 25jun only,

numactl -m 2,3 make func

results in OOM kills similar to those listed above, as well as
"strageness" and one failure:

counters.sh (2M: 32):   FAIL Line 338: Bad HugePages_Total: expected 1, actual 2
counters.sh (2M: 64):   FAIL Line 326: Bad HugePages_Total: expected 0, actual 1
********** TEST SUMMARY
*                      2M
*                      32-bit 64-bit
*     Total testcases:    90     93
*             Skipped:     0      0
*                PASS:    86     89
*                FAIL:     1      1
*    Killed by signal:     0      0
*   Bad configuration:     0      0
*       Expected FAIL:     0      0
*     Unexpected PASS:     0      0
* Strange test result:     3      3
**********

Running under the test cpuset [nodes 2 and 3 out of 0-3] with default
mempolicy yields:

chunk-overcommit (2M: 32):      FAIL    mmap() chunk1: Cannot allocate memory
chunk-overcommit (2M: 64):      FAIL    mmap() chunk1: Cannot allocate memory
alloc-instantiate-race shared (2M: 32): FAIL    mmap() 1: Cannot allocate memory
alloc-instantiate-race shared (2M: 64): FAIL    mmap() 1: Cannot allocate memory
alloc-instantiate-race private (2M: 32):        FAIL    mmap() 1: Cannot allocate memory
alloc-instantiate-race private (2M: 64):        FAIL    mmap() 1: Cannot allocate memory
truncate_sigbus_versus_oom (2M: 32):    FAIL    mmap() reserving all pages: Cannot allocate memory
truncate_sigbus_versus_oom (2M: 64):    FAIL    mmap() reserving all pages: Cannot allocate memory

counters.sh (2M: 32):   FAIL Line 326: Bad HugePages_Total: expected 0, actual 1
counters.sh (2M: 64):   FAIL Line 326: Bad HugePages_Total: expected 0, actual 1
********** TEST SUMMARY
*                      2M
*                      32-bit 64-bit
*     Total testcases:    90     93
*             Skipped:     0      0
*                PASS:    84     87
*                FAIL:     5      5
*    Killed by signal:     0      0
*   Bad configuration:     1      1
*       Expected FAIL:     0      0
*     Unexpected PASS:     0      0
* Strange test result:     0      0
**********

Running in the cpuset, under numactl -m 2,3 yields the same results.

So, independent of the "hugetlb:  constrained by mempolicy" patches, the
libhugetlbfs test suite doesn't deal well with cpuset and memory policy
constraints.  In fact, we seem to have fewer failures with this patch
set.






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
