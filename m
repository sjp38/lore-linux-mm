Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id D3F736B0031
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 06:51:01 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so994748pde.10
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 03:51:01 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20130924164443.GB2940@sgi.com>
References: <1379330740-5602-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20130919171727.GC6802@sgi.com>
 <20130920123137.BE2F7E0090@blue.fi.intel.com>
 <20130924164443.GB2940@sgi.com>
Subject: Re: [PATCHv2 0/9] split page table lock for PMD tables
Content-Transfer-Encoding: 7bit
Message-Id: <20130926105052.0205AE0090@blue.fi.intel.com>
Date: Thu, 26 Sep 2013 13:50:51 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Alex Thorlton wrote:
> > THP off:
> > --------
...
> >       36.540185552 seconds time elapsed                                          ( +- 18.36% )
> 
> I'm assuming this was THP off, no patchset, correct?

Yes. But THP off patched is *very* close to this, so I didn't post it separately.

> Here are my results from this test on 3.12-rc1:
...
>     1138.759708820 seconds time elapsed                                          ( +-  0.47% )
> 
> And the same test on 3.12-rc1 with your patchset:
> 
>  Performance counter stats for './runt -t -c 512 -b 512m' (5 runs):
...
>     1115.214191126 seconds time elapsed                                          ( +-  0.18% )
> 
> Looks like we're getting a mild performance increase here, but we still
> have a problem.

Let me guess: you have HUGETLBFS enabled in your config, right? ;)

HUGETLBFS hasn't converted to new locking and we disable split pmd lock if
HUGETLBFS is enabled.

I'm going to convert HUGETLBFS too, but it might take some time.

Without HUGETLBFS numbers looks pretty solid on my machine:

THP off, v3.12-rc2:
-------------------

 Performance counter stats for './thp_memscale -c 80 -b 512m' (5 runs):

    1037072.835207 task-clock                #   57.426 CPUs utilized            ( +-  3.59% )
            95,093 context-switches          #    0.092 K/sec                    ( +-  3.93% )
               140 cpu-migrations            #    0.000 K/sec                    ( +-  5.28% )
        10,000,550 page-faults               #    0.010 M/sec                    ( +-  0.00% )
 2,455,210,400,261 cycles                    #    2.367 GHz                      ( +-  3.62% ) [83.33%]
 2,429,281,882,056 stalled-cycles-frontend   #   98.94% frontend cycles idle     ( +-  3.67% ) [83.33%]
 1,975,960,019,659 stalled-cycles-backend    #   80.48% backend  cycles idle     ( +-  3.88% ) [66.68%]
    46,503,296,013 instructions              #    0.02  insns per cycle
                                             #   52.24  stalled cycles per insn  ( +-  3.21% ) [83.34%]
     9,278,997,542 branches                  #    8.947 M/sec                    ( +-  4.00% ) [83.34%]
        89,881,640 branch-misses             #    0.97% of all branches          ( +-  1.17% ) [83.33%]

      18.059261877 seconds time elapsed                                          ( +-  2.65% )

THP on, v3.12-rc2:
------------------

 Performance counter stats for './thp_memscale -c 80 -b 512m' (5 runs):

    3114745.395974 task-clock                #   73.875 CPUs utilized            ( +-  1.84% )
           267,356 context-switches          #    0.086 K/sec                    ( +-  1.84% )
                99 cpu-migrations            #    0.000 K/sec                    ( +-  1.40% )
            58,313 page-faults               #    0.019 K/sec                    ( +-  0.28% )
 7,416,635,817,510 cycles                    #    2.381 GHz                      ( +-  1.83% ) [83.33%]
 7,342,619,196,993 stalled-cycles-frontend   #   99.00% frontend cycles idle     ( +-  1.88% ) [83.33%]
 6,267,671,641,967 stalled-cycles-backend    #   84.51% backend  cycles idle     ( +-  2.03% ) [66.67%]
   117,819,935,165 instructions              #    0.02  insns per cycle
                                             #   62.32  stalled cycles per insn  ( +-  4.39% ) [83.34%]
    28,899,314,777 branches                  #    9.278 M/sec                    ( +-  4.48% ) [83.34%]
        71,787,032 branch-misses             #    0.25% of all branches          ( +-  1.03% ) [83.33%]

      42.162306788 seconds time elapsed                                          ( +-  1.73% )

THP off, patched, no HUGETLBFS:
-------------------------------

 Performance counter stats for './thp_memscale -c 80 -b 512m' (5 runs):

     943301.957892 task-clock                #   56.256 CPUs utilized            ( +-  3.01% )
            86,218 context-switches          #    0.091 K/sec                    ( +-  3.17% )
               121 cpu-migrations            #    0.000 K/sec                    ( +-  6.64% )
        10,000,551 page-faults               #    0.011 M/sec                    ( +-  0.00% )
 2,230,462,457,654 cycles                    #    2.365 GHz                      ( +-  3.04% ) [83.32%]
 2,204,616,385,805 stalled-cycles-frontend   #   98.84% frontend cycles idle     ( +-  3.09% ) [83.32%]
 1,778,640,046,926 stalled-cycles-backend    #   79.74% backend  cycles idle     ( +-  3.47% ) [66.69%]
    45,995,472,617 instructions              #    0.02  insns per cycle
                                             #   47.93  stalled cycles per insn  ( +-  2.51% ) [83.34%]
     9,179,700,174 branches                  #    9.731 M/sec                    ( +-  3.04% ) [83.35%]
        89,166,529 branch-misses             #    0.97% of all branches          ( +-  1.45% ) [83.33%]

      16.768027318 seconds time elapsed                                          ( +-  2.47% )

THP on, patched, no HUGETLBFS:
------------------------------

 Performance counter stats for './thp_memscale -c 80 -b 512m' (5 runs):

     458793.837905 task-clock                #   54.632 CPUs utilized            ( +-  0.79% )
            41,831 context-switches          #    0.091 K/sec                    ( +-  0.97% )
                98 cpu-migrations            #    0.000 K/sec                    ( +-  1.66% )
            57,829 page-faults               #    0.126 K/sec                    ( +-  0.62% )
 1,077,543,336,716 cycles                    #    2.349 GHz                      ( +-  0.81% ) [83.33%]
 1,067,403,802,964 stalled-cycles-frontend   #   99.06% frontend cycles idle     ( +-  0.87% ) [83.33%]
   864,764,616,143 stalled-cycles-backend    #   80.25% backend  cycles idle     ( +-  0.73% ) [66.68%]
    16,129,177,440 instructions              #    0.01  insns per cycle
                                             #   66.18  stalled cycles per insn  ( +-  7.94% ) [83.35%]
     3,618,938,569 branches                  #    7.888 M/sec                    ( +-  8.46% ) [83.36%]
        33,242,032 branch-misses             #    0.92% of all branches          ( +-  2.02% ) [83.32%]

       8.397885779 seconds time elapsed                                          ( +-  0.18% )

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
