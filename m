Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6554F6B0035
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 13:00:48 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id i8so589505qcq.24
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 10:00:48 -0800 (PST)
Date: Thu, 12 Dec 2013 12:00:37 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: [RFC PATCH 0/3] Change how we determine when to hand out THPs
Message-ID: <20131212180037.GA134240@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Benjamin LaHaise <bcrl@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Glauber Costa <glommer@parallels.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org

This patch changes the way we decide whether or not to give out THPs to
processes when they fault in pages.  The way things are right now,
touching one byte in a 2M chunk where no pages have been faulted in
results in a process being handed a 2M hugepage, which, in some cases,
is undesirable.  The most common issue seems to arise when a process
uses many cores to work on small portions of an allocated chunk of
memory.

Here are some results from a test that I wrote, which allocates memory
in a way that doesn't benefit from the use of THPs:

# echo always > /sys/kernel/mm/transparent_hugepage/enabled
# perf stat -a -r 5 ./thp_pthread -C 0 -m 0 -c 64 -b 128g

 Performance counter stats for './thp_pthread -C 0 -m 0 -c 64 -b 128g' (5 runs):

   61971685.470621 task-clock                #  662.557 CPUs utilized            ( +-  0.68% ) [100.00%]
           200,365 context-switches          #    0.000 M/sec                    ( +-  0.64% ) [100.00%]
                94 CPU-migrations            #    0.000 M/sec                    ( +-  3.76% ) [100.00%]
            61,644 page-faults               #    0.000 M/sec                    ( +-  0.00% )
11,771,748,145,744 cycles                    #    0.190 GHz                      ( +-  0.78% ) [100.00%]
17,958,073,323,609 stalled-cycles-frontend   #  152.55% frontend cycles idle     ( +-  0.97% ) [100.00%]
     <not counted> stalled-cycles-backend
10,691,478,094,935 instructions              #    0.91  insns per cycle
                                             #    1.68  stalled cycles per insn  ( +-  0.66% ) [100.00%]
 1,593,798,555,131 branches                  #   25.718 M/sec                    ( +-  0.62% ) [100.00%]
       102,473,582 branch-misses             #    0.01% of all branches          ( +-  0.43% )

      93.534078104 seconds time elapsed                                          ( +-  0.68% )

# echo never > /sys/kernel/mm/transparent_hugepage/enabled
# perf stat -a -r 5 ./thp_pthread -C 0 -m 0 -c 64 -b 128g

 Performance counter stats for './thp_pthread -C 0 -m 0 -c 64 -b 128g' (5 runs):

   50703784.027438 task-clock                #  663.073 CPUs utilized            ( +-  0.18% ) [100.00%]
           162,324 context-switches          #    0.000 M/sec                    ( +-  0.22% ) [100.00%]
                91 CPU-migrations            #    0.000 M/sec                    ( +-  9.22% ) [100.00%]
        31,250,840 page-faults               #    0.001 M/sec                    ( +-  0.00% )
 7,962,585,261,769 cycles                    #    0.157 GHz                      ( +-  0.21% ) [100.00%]
 9,230,610,615,208 stalled-cycles-frontend   #  115.92% frontend cycles idle     ( +-  0.23% ) [100.00%]
     <not counted> stalled-cycles-backend
16,899,387,283,411 instructions              #    2.12  insns per cycle
                                             #    0.55  stalled cycles per insn  ( +-  0.16% ) [100.00%]
 2,422,269,260,013 branches                  #   47.773 M/sec                    ( +-  0.16% ) [100.00%]
        99,419,683 branch-misses             #    0.00% of all branches          ( +-  0.22% )

      76.467835263 seconds time elapsed                                          ( +-  0.18% )

As you can see there's a significant performance increase when running
this test with THP off.  Here's a pointer to the test, for those who are
interested:

http://oss.sgi.com/projects/memtests/thp_pthread.tar.gz

My proposed solution to the problem is to allow users to set a
threshold at which THPs will be handed out.  The idea here is that, when
a user faults in a page in an area where they would usually be handed a
THP, we pull 512 pages off the free list, as we would with a regular
THP, but we only fault in single pages from that chunk, until the user
has faulted in enough pages to pass the threshold we've set.  Once they
pass the threshold, we do the necessary work to turn our 512 page chunk
into a proper THP.  As it stands now, if the user tries to fault in
pages from different nodes, we completely give up on ever turning a
particular chunk into a THP, and just fault in the 4K pages as they're
requested.  We may want to make this tunable in the future (i.e. allow
them to fault in from only 2 different nodes).

This patch is still a work in progress, and it has a few known issues
that I've yet to sort out:

- Bad page state bug resulting from pages being added to the pagevecs
  improperly
    + This bug doesn't seem to hit when allocating small amounts of
      memory on 32 or less cores, but it becomes an issue on larger test
      runs.
    + I believe the best way to avoid this is to make sure we don't
      lru_cache_add any of the pages in our chunk until we decide
      whether or not we'll turn the chunk into a THP.  Haven't quite
      gotten this working yet.
- A few small accounting issues with some of the mm counters
- Some spots are still pretty hacky, need to be cleaned up a bit

Just to let people know, I've been doing most of my testing with the
memscale test:

http://oss.sgi.com/projects/memtests/thp_memscale.tar.gz

The pthread test hits the first bug I mentioned here much more often,
but the patch seems to be more stable when tested with memscale.  I
typically run something like this to test:

# ./thp_memscale -C 0 -m 0 -c 32 -b 16m

As you increase the amount of memory/number of cores, you become more
likely to run into issues.

Although there's still work to be done here, I wanted to get an early
version of the patch out so that everyone could give their
opinions/suggestions.  The patch should apply cleanly to the 3.12
kernel.  I'll rebase it as soon as some of the remaining issues have
been sorted out, this will also mean changing over to the split PTL
where appropriate.

Signed-off-by: Alex Thorlton <athorlton@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Nate Zimmer <nzimmer@sgi.com>
Cc: Cliff Wickman <cpw@sgi.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michel Lespinasse <walken@google.com>
Cc: Benjamin LaHaise <bcrl@kvack.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: David Rientjes <rientjes@google.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Jiang Liu <jiang.liu@huawei.com>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Glauber Costa <glommer@parallels.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Alex Thorlton (3):
  Add flags for temporary compound pages
  Add tunable to control THP behavior
  Change THP behavior

 include/linux/gfp.h      |   5 +
 include/linux/huge_mm.h  |   8 ++
 include/linux/mm_types.h |  14 +++
 kernel/fork.c            |   1 +
 mm/huge_memory.c         | 313 +++++++++++++++++++++++++++++++++++++++++++++++
 mm/internal.h            |   1 +
 mm/memory.c              |  29 ++++-
 mm/page_alloc.c          |  66 +++++++++-
 8 files changed, 430 insertions(+), 7 deletions(-)

-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
