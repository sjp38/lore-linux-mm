Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 940FF6B007D
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 16:37:14 -0500 (EST)
Date: Mon, 19 Nov 2012 21:37:08 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
Message-ID: <20121119213708.GN8218@suse.de>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
 <20121119162909.GL8218@suse.de>
 <20121119200707.GA12381@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121119200707.GA12381@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Mon, Nov 19, 2012 at 09:07:07PM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > >   [ SPECjbb transactions/sec ]            |
> > >   [ higher is better         ]            |
> > >                                           |
> > >   SPECjbb single-1x32    524k     507k    |       638k           +21.7%
> > >   -----------------------------------------------------------------------
> > > 
> > 
> > I was not able to run a full sets of tests today as I was 
> > distracted so all I have is a multi JVM comparison. I'll keep 
> > it shorter than average
> > 
> >                           3.7.0                 3.7.0
> >                  rc5-stats-v4r2   rc5-schednuma-v16r1
> > TPut   1     101903.00 (  0.00%)     77651.00 (-23.80%)
> > TPut   2     213825.00 (  0.00%)    160285.00 (-25.04%)
> > TPut   3     307905.00 (  0.00%)    237472.00 (-22.87%)
> > TPut   4     397046.00 (  0.00%)    302814.00 (-23.73%)
> > TPut   5     477557.00 (  0.00%)    364281.00 (-23.72%)
> > TPut   6     542973.00 (  0.00%)    420810.00 (-22.50%)
> > TPut   7     540466.00 (  0.00%)    448976.00 (-16.93%)
> > TPut   8     543226.00 (  0.00%)    463568.00 (-14.66%)
> > TPut   9     513351.00 (  0.00%)    468238.00 ( -8.79%)
> > TPut   10    484126.00 (  0.00%)    457018.00 ( -5.60%)
> 
> These figures are IMO way too low for a 64-way system. I have a 
> 32-way system with midrange server CPUs and get 650k+/sec 
> easily.
> 

48-way as I said here https://lkml.org/lkml/2012/11/3/109. If I said
64-way somewhere else, it was a mistake. The lack of THP would account
for some of the difference. As I was looking for potential
locking-related issues, I also had CONFIG_DEBUG_VMA nd
CONFIG_DEBUG_MUTEXES set which would account for more overhead. Any
options set are set for all tests that make up a group.

> Have you tried to analyze the root cause, what does 'perf top' 
> show during the run and how much idle time is there?
> 

No, I haven't and the machine is currently occupied. However, a second
profile run was run as part of the test above. The figures I reported are
based on a run without profiling. With profiling, oprofile reported

Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a unit mask of 0x00 (No unit mask) count 6000
samples  %        image name               app name                 symbol name
176552   42.9662  vmlinux-3.7.0-rc5-schednuma-v16r1 vmlinux-3.7.0-rc5-schednuma-v16r1 intel_idle
22790     5.5462  vmlinux-3.7.0-rc5-schednuma-v16r1 vmlinux-3.7.0-rc5-schednuma-v16r1 find_busiest_group
10533     2.5633  vmlinux-3.7.0-rc5-schednuma-v16r1 vmlinux-3.7.0-rc5-schednuma-v16r1 update_blocked_averages
10489     2.5526  vmlinux-3.7.0-rc5-schednuma-v16r1 vmlinux-3.7.0-rc5-schednuma-v16r1 rb_get_reader_page
9514      2.3154  vmlinux-3.7.0-rc5-schednuma-v16r1 vmlinux-3.7.0-rc5-schednuma-v16r1 native_write_msr_safe
8511      2.0713  vmlinux-3.7.0-rc5-schednuma-v16r1 vmlinux-3.7.0-rc5-schednuma-v16r1 ring_buffer_consume
7406      1.8023  vmlinux-3.7.0-rc5-schednuma-v16r1 vmlinux-3.7.0-rc5-schednuma-v16r1 idle_cpu
6549      1.5938  vmlinux-3.7.0-rc5-schednuma-v16r1 vmlinux-3.7.0-rc5-schednuma-v16r1 update_cfs_rq_blocked_load
6482      1.5775  vmlinux-3.7.0-rc5-schednuma-v16r1 vmlinux-3.7.0-rc5-schednuma-v16r1 rebalance_domains
5212      1.2684  vmlinux-3.7.0-rc5-schednuma-v16r1 vmlinux-3.7.0-rc5-schednuma-v16r1 run_rebalance_domains
5037      1.2258  perl                     perl                     /usr/bin/perl
4167      1.0141  vmlinux-3.7.0-rc5-schednuma-v16r1 vmlinux-3.7.0-rc5-schednuma-v16r1 page_fault
3885      0.9455  vmlinux-3.7.0-rc5-schednuma-v16r1 vmlinux-3.7.0-rc5-schednuma-v16r1 cpumask_next_and
3704      0.9014  vmlinux-3.7.0-rc5-schednuma-v16r1 vmlinux-3.7.0-rc5-schednuma-v16r1 find_next_bit
3498      0.8513  vmlinux-3.7.0-rc5-schednuma-v16r1 vmlinux-3.7.0-rc5-schednuma-v16r1 getnstimeofday
3345      0.8140  vmlinux-3.7.0-rc5-schednuma-v16r1 vmlinux-3.7.0-rc5-schednuma-v16r1 __update_cpu_load
3175      0.7727  vmlinux-3.7.0-rc5-schednuma-v16r1 vmlinux-3.7.0-rc5-schednuma-v16r1 load_balance
3018      0.7345  vmlinux-3.7.0-rc5-schednuma-v16r1 vmlinux-3.7.0-rc5-schednuma-v16r1 menu_select

> Trying to reproduce your findings I have done 4x JVM tests 
> myself, using 4x 8-warehouse setups, with a sizing of -Xms8192m 
> -Xmx8192m -Xss256k, and here are the results:
> 
>                          v3.7       v3.7                                  
>   SPECjbb single-1x32    524k       638k         +21.7%
>   SPECjbb  multi-4x8     633k       655k          +3.4%
> 

I'll re-run with THP enabled the next time and see what I find.

> So while here we are only marginally better than the 
> single-instance numbers (I will try to improve that in numa/core 
> v17), they are still better than mainline - and they are 
> definitely not slower as your numbers suggest ...
> 
> So we need to go back to the basics to figure this out: please 
> outline exactly which commit ID of the numa/core tree you have 
> booted. Also, how does 'perf top' look like on your box?
> 

I'll find out what perf top looks like ASAP.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
