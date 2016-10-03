Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CA9A66B0069
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 06:47:46 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l138so88479515wmg.3
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 03:47:46 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id lm3si10336873wjc.1.2016.10.03.03.47.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Oct 2016 03:47:45 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id C6B299908E
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 10:47:44 +0000 (UTC)
Date: Mon, 3 Oct 2016 11:47:43 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20161003104743.GD3903@techsingularity.net>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <20160927083104.GC2838@techsingularity.net>
 <20160927143426.GP2794@worktop>
 <20160928104500.GC3903@techsingularity.net>
 <20160928111115.GS5016@twins.programming.kicks-ass.net>
 <CA+55aFxTPk-3zXEAWfXN2Hfm5Qw__B_2BJw7vNN_hFY+NTctgw@mail.gmail.com>
 <20160929130827.GX5016@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160929130827.GX5016@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Nicholas Piggin <npiggin@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Thu, Sep 29, 2016 at 03:08:27PM +0200, Peter Zijlstra wrote:
> > is not racy (the add_wait_queue() will now already guarantee that
> > nobody else clears the bit).
> > 
> > Hmm?
> 
> Yes. I got my brain in a complete twist, but you're right, that is
> indeed required.
> 
> Here's a new version with hopefully clearer comments.
> 
> Same caveat about 32bit, naming etc..
> 

I was able to run this with basic workloads over the weekend on small
UMA machines. Both machines behaved similarly so I'm only reporting one
from a single socket Skylake machine. NUMA machines rarely show anything
much more interesting for these type of workloads but as always, the full
impact is machine and workload dependant. Generally, I expect this type
of patch to have marginal but detectable impact.

This is a workload doing parallel dd of files large enough to trigger
reclaim which locks/unlocks pages

paralleldd
                              4.8.0-rc8             4.8.0-rc8
                                vanilla        waitqueue-v1r2
Amean    Elapsd-1      215.05 (  0.00%)      214.53 (  0.24%)
Amean    Elapsd-3      214.72 (  0.00%)      214.42 (  0.14%)
Amean    Elapsd-5      215.29 (  0.00%)      214.88 (  0.19%)
Amean    Elapsd-7      215.75 (  0.00%)      214.79 (  0.44%)
Amean    Elapsd-8      214.96 (  0.00%)      215.21 ( -0.12%)

That's basically within the noise. CPU usage overall looks like

           4.8.0-rc8   4.8.0-rc8
             vanillawaitqueue-v1r2
User         3409.66     3421.72
System      18298.66    18251.99
Elapsed      7178.82     7181.14

Marginal decrease in system CPU usage. Profiles showed the vanilla
kernel spending less than 0.1% on unlock_page but it's eliminated by the
patch.

This is some microbenchmarks from the vm-scalability benchmark. It's
similar to dd in that it triggers reclaim from a single thread

vmscale
                                                           4.8.0-rc8                          4.8.0-rc8
                                                             vanilla                     waitqueue-v1r2
Ops lru-file-mmap-read-elapsed                       19.50 (  0.00%)                    19.43 (  0.36%)
Ops lru-file-readonce-elapsed                        12.44 (  0.00%)                    12.29 (  1.21%)
Ops lru-file-readtwice-elapsed                       22.27 (  0.00%)                    22.19 (  0.36%)
Ops lru-memcg-elapsed                                12.18 (  0.00%)                    12.00 (  1.48%)

           4.8.0-rc8   4.8.0-rc8
             vanillawaitqueue-v1r2
User           50.54       50.88
System        398.72      388.81
Elapsed        69.48       68.99

Again, differences are marginal but detectable. I accidentally did not
collect profile data but I have no reason to believe it's significantly
different to dd.

This is "gitsource" from mmtests but it's a checkout of the git source
tree and a run of make test which is where Linus first noticed the
problem. The metric here is time-based, I don't actually check the
results of the regression suite.

gitsource
                             4.8.0-rc8             4.8.0-rc8
                               vanilla        waitqueue-v1r2
User    min           192.28 (  0.00%)      192.49 ( -0.11%)
User    mean          193.55 (  0.00%)      194.88 ( -0.69%)
User    stddev          1.52 (  0.00%)        2.39 (-57.58%)
User    coeffvar        0.79 (  0.00%)        1.23 (-56.51%)
User    max           196.34 (  0.00%)      199.06 ( -1.39%)
System  min           122.70 (  0.00%)      118.69 (  3.27%)
System  mean          123.87 (  0.00%)      120.68 (  2.57%)
System  stddev          0.84 (  0.00%)        1.65 (-97.67%)
System  coeffvar        0.67 (  0.00%)        1.37 (-102.89%)
System  max           124.95 (  0.00%)      123.14 (  1.45%)
Elapsed min           718.09 (  0.00%)      711.48 (  0.92%)
Elapsed mean          724.23 (  0.00%)      716.52 (  1.07%)
Elapsed stddev          4.20 (  0.00%)        4.84 (-15.42%)
Elapsed coeffvar        0.58 (  0.00%)        0.68 (-16.66%)
Elapsed max           730.51 (  0.00%)      724.45 (  0.83%)

           4.8.0-rc8   4.8.0-rc8
             vanillawaitqueue-v1r2
User         2730.60     2808.48
System       2184.85     2108.68
Elapsed      9938.01     9929.56

Overall, it's showing a drop in system CPU usage as expected. The detailed
results show a drop of 2.57% in system CPU usage running the benchmark
itself and 3.48% overall which is measuring everything and not just "make
test". The drop in elapsed time is marginal but measurable.

It may raise an eyebrow that the overall elapsed time doesn't match the
detailed results. The detailed results report 5 iterations of "make test"
without profiling enabled which takes takes about an hour. The way I
configured it, the profiled run happened immediately after it and it's much
slower as well as having to compile git itself which takes a few minutes.

This is the top lock/unlock activity in the vanilla kernel

     0.80%  git              [kernel.vmlinux]              [k] unlock_page
     0.28%  sh               [kernel.vmlinux]              [k] unlock_page
     0.20%  git-rebase       [kernel.vmlinux]              [k] unlock_page
     0.13%  git              [kernel.vmlinux]              [k] lock_page_memcg
     0.10%  git              [kernel.vmlinux]              [k] unlock_page_memcg
     0.07%  git-submodule    [kernel.vmlinux]              [k] unlock_page
     0.04%  sh               [kernel.vmlinux]              [k] lock_page_memcg
     0.03%  git-rebase       [kernel.vmlinux]              [k] lock_page_memcg
     0.03%  sh               [kernel.vmlinux]              [k] unlock_page_memcg
     0.03%  sed              [kernel.vmlinux]              [k] unlock_page
     0.03%  perf             [kernel.vmlinux]              [k] unlock_page
     0.02%  git-rebase       [kernel.vmlinux]              [k] unlock_page_memcg
     0.02%  rm               [kernel.vmlinux]              [k] unlock_page
     0.02%  git-stash        [kernel.vmlinux]              [k] unlock_page
     0.02%  git-bisect       [kernel.vmlinux]              [k] unlock_page
     0.02%  diff             [kernel.vmlinux]              [k] unlock_page
     0.02%  cat              [kernel.vmlinux]              [k] unlock_page
     0.02%  wc               [kernel.vmlinux]              [k] unlock_page
     0.01%  mv               [kernel.vmlinux]              [k] unlock_page
     0.01%  git-submodule    [kernel.vmlinux]              [k] lock_page_memcg

This is with the patch applied

     0.49%  git              [kernel.vmlinux]             [k] unlock_page
     0.14%  sh               [kernel.vmlinux]             [k] unlock_page
     0.13%  git              [kernel.vmlinux]             [k] lock_page_memcg
     0.11%  git-rebase       [kernel.vmlinux]             [k] unlock_page
     0.10%  git              [kernel.vmlinux]             [k] unlock_page_memcg
     0.04%  sh               [kernel.vmlinux]             [k] lock_page_memcg
     0.04%  git-submodule    [kernel.vmlinux]             [k] unlock_page
     0.03%  sh               [kernel.vmlinux]             [k] unlock_page_memcg
     0.03%  git-rebase       [kernel.vmlinux]             [k] lock_page_memcg
     0.02%  git-rebase       [kernel.vmlinux]             [k] unlock_page_memcg
     0.02%  sed              [kernel.vmlinux]             [k] unlock_page
     0.01%  rm               [kernel.vmlinux]             [k] unlock_page
     0.01%  git-stash        [kernel.vmlinux]             [k] unlock_page
     0.01%  git-submodule    [kernel.vmlinux]             [k] lock_page_memcg
     0.01%  git-bisect       [kernel.vmlinux]             [k] unlock_page
     0.01%  diff             [kernel.vmlinux]             [k] unlock_page
     0.01%  cat              [kernel.vmlinux]             [k] unlock_page
     0.01%  wc               [kernel.vmlinux]             [k] unlock_page
     0.01%  git-submodule    [kernel.vmlinux]             [k] unlock_page_memcg
     0.01%  mv               [kernel.vmlinux]             [k] unlock_page

The drop in time spent by git in unlock_page is noticable. I did not
drill down into the annotated profile but this roughly matches what I
measured before when avoiding page_waitqueue lookups.

The full profile is not exactly great but I didn't see anything in there
I haven't seen before. Top entries with the patch applied looks like
this

     7.44%  swapper          [kernel.vmlinux]             [k] intel_idle
     1.25%  git              [kernel.vmlinux]             [k] filemap_map_pages
     1.08%  git              [kernel.vmlinux]             [k] native_irq_return_iret
     0.79%  git              [kernel.vmlinux]             [k] unmap_page_range
     0.56%  git              [kernel.vmlinux]             [k] release_pages
     0.51%  git              [kernel.vmlinux]             [k] handle_mm_fault
     0.49%  git              [kernel.vmlinux]             [k] unlock_page
     0.46%  git              [kernel.vmlinux]             [k] page_remove_rmap
     0.46%  git              [kernel.vmlinux]             [k] _raw_spin_lock
     0.42%  git              [kernel.vmlinux]             [k] clear_page_c_e

Lot of map/unmap activity like you'd expect and release_pages being a pig
as usual.

Overall, this patch shows similar behaviour to my own patch from 2014.
There is a definite benefit but it's marginal. The big difference is
that this patch is a lot similar than the 2014 version and may meet less
resistance as a result.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
