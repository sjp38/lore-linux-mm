Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id E1B296B0038
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 12:44:48 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so3945812pab.31
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 09:44:48 -0700 (PDT)
Date: Tue, 24 Sep 2013 11:44:43 -0500
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [PATCHv2 0/9] split page table lock for PMD tables
Message-ID: <20130924164443.GB2940@sgi.com>
References: <1379330740-5602-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20130919171727.GC6802@sgi.com>
 <20130920123137.BE2F7E0090@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130920123137.BE2F7E0090@blue.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Kirill,

I've merged a couple of our e-mails together for this reply:

On Fri, Sep 20, 2013 at 03:31:37PM +0300, Kirill A. Shutemov wrote:
> Alex Thorlton noticed that some massivly threaded workloads work poorly,
> if THP enabled. This patchset fixes this by introducing split page table
> lock for PMD tables. hugetlbfs is not covered yet.
> 
> This patchset is based on work by Naoya Horiguchi.
> 
> Changes:
>  v2:
>   - reuse CONFIG_SPLIT_PTLOCK_CPUS for PMD split lock;
>   - s/huge_pmd_lock/pmd_lock/g;
>   - assume pgtable_pmd_page_ctor() can fail;
>   - fix format line in task_mem() for VmPTE;
> 
> Benchmark (from Alex): ftp://shell.sgi.com/collect/appsx_test/pthread_test.tar.gz
> Run on 4 socket Westmere with 128 GiB of RAM.

First off, this test, although still somewhat relevant here, wasn't
exactly crafted to show the particular page fault scaling problem that
I was looking to address by changing to the split PTLs.  I wrote this
one to show what happens when an application allocates memory in such
a way that all of its pages get stuck on one node due to the use of
THP.  This problem is much more evident on large machines, although
it appears to still be a significant issue even on this 4 socket.
 
> THP off:
> --------
> 
>  Performance counter stats for './thp_pthread -C 0 -m 0 -c 80 -b 100g' (5 runs):
> 
>     1738259.808012 task-clock                #   47.571 CPUs utilized            ( +-  9.49% )
>            147,359 context-switches          #    0.085 K/sec                    ( +-  9.67% )
>                 14 cpu-migrations            #    0.000 K/sec                    ( +- 13.25% )
>         24,410,139 page-faults               #    0.014 M/sec                    ( +-  0.00% )
>  4,149,037,526,252 cycles                    #    2.387 GHz                      ( +-  9.50% )
>  3,649,839,735,027 stalled-cycles-frontend   #   87.97% frontend cycles idle     ( +-  6.60% )
>  2,455,558,969,567 stalled-cycles-backend    #   59.18% backend  cycles idle     ( +- 22.92% )
>  1,434,961,518,604 instructions              #    0.35  insns per cycle
>                                              #    2.54  stalled cycles per insn  ( +- 92.86% )
>    241,472,020,951 branches                  #  138.916 M/sec                    ( +- 91.72% )
>         84,022,172 branch-misses             #    0.03% of all branches          ( +-  3.16% )
> 
>       36.540185552 seconds time elapsed                                          ( +- 18.36% )

I'm assuming this was THP off, no patchset, correct?
 
> THP on, no patchset:
> --------------------
>  Performance counter stats for './thp_pthread -C 0 -m 0 -c 80 -b 100g' (5 runs):
> 
>     2528378.966949 task-clock                #   50.715 CPUs utilized            ( +- 11.86% )
>            214,063 context-switches          #    0.085 K/sec                    ( +- 11.94% )
>                 19 cpu-migrations            #    0.000 K/sec                    ( +- 22.72% )
>             49,226 page-faults               #    0.019 K/sec                    ( +-  0.33% )
>  6,034,640,598,498 cycles                    #    2.387 GHz                      ( +- 11.91% )
>  5,685,933,794,081 stalled-cycles-frontend   #   94.22% frontend cycles idle     ( +-  7.67% )
>  4,414,381,393,353 stalled-cycles-backend    #   73.15% backend  cycles idle     ( +-  2.09% )
>    952,086,804,776 instructions              #    0.16  insns per cycle
>                                              #    5.97  stalled cycles per insn  ( +- 89.59% )
>    166,191,211,974 branches                  #   65.730 M/sec                    ( +- 85.52% )
>         33,341,022 branch-misses             #    0.02% of all branches          ( +-  3.90% )
> 
>       49.854741504 seconds time elapsed                                          ( +- 14.76% )
> 
> THP on, with patchset:
> ----------------------
> 
> echo always > /sys/kernel/mm/transparent_hugepage/enabled
>  Performance counter stats for './thp_pthread -C 0 -m 0 -c 80 -b 100g' (5 runs):
> 
>     1538763.343568 task-clock                #   45.386 CPUs utilized            ( +-  7.21% )
>            130,469 context-switches          #    0.085 K/sec                    ( +-  7.32% )
>                 14 cpu-migrations            #    0.000 K/sec                    ( +- 23.58% )
>             49,299 page-faults               #    0.032 K/sec                    ( +-  0.15% )
>  3,666,748,502,650 cycles                    #    2.383 GHz                      ( +-  7.25% )
>  3,330,488,035,212 stalled-cycles-frontend   #   90.83% frontend cycles idle     ( +-  4.70% )
>  2,383,357,073,990 stalled-cycles-backend    #   65.00% backend  cycles idle     ( +- 16.06% )
>    935,504,610,528 instructions              #    0.26  insns per cycle
>                                              #    3.56  stalled cycles per insn  ( +- 91.16% )
>    161,466,689,532 branches                  #  104.933 M/sec                    ( +- 87.67% )
>         22,602,225 branch-misses             #    0.01% of all branches          ( +-  6.43% )
> 
>       33.903917543 seconds time elapsed                                          ( +- 12.57% )

These results all make sense, although I think that the granularity of
the locking here is only part of the issue.  I can see that increasing
the granularity has gotten us a solid performance boost, but I think
we're still seeing the problem that this test was originally written to
cause.  Can you run it with THP off, with the patchset, and see what
those results look like?  In theory, they should be the same as the THP
off, no patchset, but I'd just like to confirm.

Alex Thorlton wrote:
> > Kirill,
> >
> > I'm hitting some performance issues with these patches on our larger
> > machines (>=128 cores/256 threads).  I've managed to livelock larger
> > systems with one of our tests (I'll publish this one soon), and I'm
> > actually seeing a performance hit on some of the smaller ones.
> 
> Does "performance hit" mean performance degradation?

Yes, sorry if I wasn't clear about that, although, after some more
thorough testing, I think the one test where I saw a performance
degradation was just a fluke.  It looks like we are getting a bit of a
performance increase here.
  
Below are the results from a test that we use to get an idea of how
well page fault rates scale with threaded applications.  I've
included a pointer to the code, after the results.

Here are my results from this test on 3.12-rc1:

 Performance counter stats for './runt -t -c 512 -b 512m' (5 runs):

  601876434.115594 task-clock                #  528.537 CPUs utilized            ( +-  0.47% ) [100.00%]
           1623458 context-switches          #    0.000 M/sec                    ( +-  1.53% ) [100.00%]
              1516 CPU-migrations            #    0.000 M/sec                    ( +-  2.77% ) [100.00%]
            384463 page-faults               #   : 0.000 M/sec                    ( +-  2.67% )
  1379590734249907 cycles                    #    2.292 GHz                      ( +-  0.44% ) [100.00%]
  1341758692269274 stalled-cycles-frontend   #   97.26% frontend cycles idle     ( +-  0.40% ) [100.00%]
  1221638993634458 stalled-cycles-backend    #   88.55% backend  cycles idle     ( +-  0.40% ) [100.00%]
    84690378275421 instructions              #    0.06  insns per cycle
                                             #   15.84  stalled cycles per insn  ( +-  8.33% ) [100.00%]
    31688643150502 branches                  #   52.650 M/sec                    ( +-  7.41% ) [100.00%]
         596215444 branch-misses             #    0.00% of all branches          ( +-  1.29% )

    1138.759708820 seconds time elapsed                                          ( +-  0.47% )

And the same test on 3.12-rc1 with your patchset:

 Performance counter stats for './runt -t -c 512 -b 512m' (5 runs):

  589443340.500156 task-clock                #  528.547 CPUs utilized            ( +-  0.18% ) [100.00%]
           1581275 context-switches          #    0.000 M/sec                    ( +-  0.21% ) [100.00%]
              1396 CPU-migrations            #    0.000 M/sec                    ( +-  1.03% ) [100.00%]
            396751 page-faults               #    0.000 M/sec                    ( +-  1.00% )
  1349678173115306 cycles                    #    2.290 GHz                      ( +-  0.19% ) [100.00%]
  1312632685809142 stalled-cycles-frontend   #   97.26% frontend cycles idle     ( +-  0.16% ) [100.00%]
  1195309877165326 stalled-cycles-backend    #   88.56% backend  cycles idle     ( +-  0.15% ) [100.00%]
    86399944669187 instructions              #    0.06  insns per cycle        
                                             #   15.19  stalled cycles per insn  ( +-  3.67% ) [100.00%]
    32155627498040 branches                  #   54.553 M/sec                    ( +-  3.29% ) [100.00%]
         571881894 branch-misses             #    0.00% of all branches          ( +-  0.85% )

    1115.214191126 seconds time elapsed                                          ( +-  0.18% )

Looks like we're getting a mild performance increase here, but we still
have a problem.  Here are the results from my *very* primitive attempt
at something similar to your patches:

 Performance counter stats for './runt -t -c 512 -b 512m' (5 runs):

   29789210.870386 task-clock                #  531.115 CPUs utilized            ( +-  2.89% ) [100.00%]
            116533 context-switches          #    0.000 M/sec                    ( +-  9.63% ) [100.00%]
              1035 CPU-migrations            #    0.000 M/sec                    ( +-  1.31% ) [100.00%]
            348985 page-faults               #    0.000 M/sec                    ( +-  2.17% )
    46809677863909 cycles                    #    1.571 GHz                      ( +-  4.17% ) [100.00%]
    37484346945854 stalled-cycles-frontend   #   80.08% frontend cycles idle     ( +-  5.20% ) [100.00%]
    34441194088742 stalled-cycles-backend    #   73.58% backend  cycles idle     ( +-  5.84% ) [100.00%]
    43467215183285 instructions              #    0.93  insns per cycle
                                             #    0.86  stalled cycles per insn  ( +-  3.45% ) [100.00%]
    14551423412527 branches                  #  488.480 M/sec                    ( +-  3.45% ) [100.00%]
         141577229 branch-misses             #    0.00% of all branches          ( +-  2.27% )

      56.088059717 seconds time elapsed                                          ( +-  2.90% )

Now, I know that my patch doesn't perform proper locking here.
Actually, all I've done is narrow down the one lock where the test was
spending most of its time, and switch that over to the PUD split-PTL.
You can see the diff for that, here:

http://www.spinics.net/lists/kernel/msg1594736.html

Here's a pointer to the test that I used to get these results:

ftp://shell.sgi.com/collect/memscale/thp_memscale.tar.gz

And a brief description of how the test works:
 
- Once all threads are ready they are turned loose to perform the
  following steps concurrently:
	+ Reserve a chunk of memory local to each thread's CPU (-b
	  option)
	+ Write to the first byte of each 4k chunk of the memory the
	  thread just allocated

Looking at these results, I think we can do better here, but I need to
really spend some time figuring out exactly what's causing the
difference in performance between the little tweak that I made, and the
full-fledged patches you've got here.

>From what I can tell we're getting hung up on the same lock that we were
originally getting stuck at (with this test, at least); "why" is a
different story.

I'm going to keep looking into this.  Let me know if anybody has any
ideas!

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
