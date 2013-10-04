Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id D411C6B0031
	for <linux-mm@kvack.org>; Fri,  4 Oct 2013 16:26:12 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so4660762pab.15
        for <linux-mm@kvack.org>; Fri, 04 Oct 2013 13:26:12 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20131004201213.GB32110@sgi.com>
References: <1380287787-30252-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20131004201213.GB32110@sgi.com>
Subject: Re: [PATCHv4 00/10] split page table lock for PMD tables
Content-Transfer-Encoding: 7bit
Message-Id: <20131004202602.2D389E0090@blue.fi.intel.com>
Date: Fri,  4 Oct 2013 23:26:02 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Alex Thorlton wrote:
> Kirill,
> 
> I've pasted in my results for 512 cores below.  Things are looking 
> really good here.  I don't have a test for HUGETLBFS, but if you want to
> pass me the one you used, I can run that too.  I suppose I could write
> one, but why reinvent the wheel? :)

Patch below.

> Sorry for the delay on these results.  I hit some strange issues with
> running thp_memscale on systems with either of the following
> combinations of configuration options set:
> 
> [thp off]
> HUGETLBFS=y
> HUGETLB_PAGE=y
> NUMA_BALANCING=y
> NUMA_BALANCING_DEFAULT_ENABLED=y
> 
> [thp on or off]
> HUGETLBFS=n
> HUGETLB_PAGE=n
> NUMA_BALANCING=y
> NUMA_BALANCING_DEFAULT_ENABLED=y
> 
> I'm getting segfaults intermittently, as well as some weird RCU sched
> errors.  This happens in vanilla 3.12-rc2, so it doesn't have anything
> to do with your patches, but I thought I'd let you know.  There didn't
> used to be any issues with this test, so I think there's a subtle kernel
> bug here.  That's, of course, an entirely separate issue though.

I'll take a look next week, if nobody does it before.

> 
> As far as these patches go, I think everything looks good (save for the
> bit of discussion you were having with Andrew earlier, which I think
> you've worked out).  My testing shows that the page fault rates are
> actually better on this threaded test than in the non-threaded case!
> 
> - Alex
> 
> THP on, v3.12-rc2:
> ------------------
> 
>  Performance counter stats for './thp_memscale -C 0 -m 0 -c 512 -b 512m' (5 runs):
> 
>   568668865.944994 task-clock                #  528.547 CPUs utilized            ( +-  0.21% ) [100.00%]
>          1,491,589 context-switches          #    0.000 M/sec                    ( +-  0.25% ) [100.00%]
>              1,085 CPU-migrations            #    0.000 M/sec                    ( +-  1.80% ) [100.00%]
>            400,822 page-faults               #    0.000 M/sec                    ( +-  0.41% )
> 1,306,612,476,049,478 cycles                    #    2.298 GHz                      ( +-  0.23% ) [100.00%]
> 1,277,211,694,318,724 stalled-cycles-frontend   #   97.75% frontend cycles idle     ( +-  0.21% ) [100.00%]
> 1,163,736,844,232,064 stalled-cycles-backend    #   89.07% backend  cycles idle     ( +-  0.20% ) [100.00%]
> 53,855,178,678,230 instructions              #    0.04  insns per cycle        
>                                              #   23.72  stalled cycles per insn  ( +-  1.15% ) [100.00%]
> 21,041,661,816,782 branches                  #   37.002 M/sec                    ( +-  0.64% ) [100.00%]
>        606,665,092 branch-misses             #    0.00% of all branches          ( +-  0.63% )
> 
>     1075.909782795 seconds time elapsed                                          ( +-  0.21% )
>
> THP on, patched:
> ----------------
> 
>  Performance counter stats for './runt -t -c 512 -b 512m' (5 runs):
> 
>    15836198.490485 task-clock                #  533.304 CPUs utilized            ( +-  0.95% ) [100.00%]
>            127,507 context-switches          #    0.000 M/sec                    ( +-  1.65% ) [100.00%]
>              1,223 CPU-migrations            #    0.000 M/sec                    ( +-  3.23% ) [100.00%]
>            302,080 page-faults               #    0.000 M/sec                    ( +-  6.88% )
> 18,925,875,973,975 cycles                    #    1.195 GHz                      ( +-  0.43% ) [100.00%]
> 18,325,469,464,007 stalled-cycles-frontend   #   96.83% frontend cycles idle     ( +-  0.44% ) [100.00%]
> 17,522,272,147,141 stalled-cycles-backend    #   92.58% backend  cycles idle     ( +-  0.49% ) [100.00%]
>  2,686,490,067,197 instructions              #    0.14  insns per cycle        
>                                              #    6.82  stalled cycles per insn  ( +-  2.16% ) [100.00%]
>    944,712,646,402 branches                  #   59.655 M/sec                    ( +-  2.03% ) [100.00%]
>        145,956,565 branch-misses             #    0.02% of all branches          ( +-  0.88% )
> 
>       29.694499652 seconds time elapsed                                          ( +-  0.95% )
> 
> (these results are from the test suite that I ripped thp_memscale out
> of, but it's the same test)

36 times faster. Not bad I think. ;)

Naive patch to use HUGETLB:

--- thp_memscale/thp_memscale.c	2013-09-23 23:44:21.000000000 +0300
+++ thp_memscale/thp_memscale.c	2013-09-26 17:45:47.878429885 +0300
@@ -191,7 +191,10 @@
 	int id, i, cnt;
 
 	id = (long)arg;
-	p = malloc(bytes);
+	p = mmap(NULL, bytes, PROT_READ | PROT_WRITE,
+			MAP_ANONYMOUS | MAP_PRIVATE | MAP_HUGETLB, 0, 0);
+	if (p == MAP_FAILED)
+		perrorx("mmap failed");
 	ps = p;
 
 	if (runon(basecpu + id) < 0)
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
