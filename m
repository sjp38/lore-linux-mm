Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id B30066B00A6
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 10:54:40 -0400 (EDT)
Date: Fri, 12 Oct 2012 15:54:32 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/33] AutoNUMA27
Message-ID: <20121012145432.GA29125@suse.de>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <20121011101930.GM3317@csn.ul.ie>
 <20121011145611.GI1818@redhat.com>
 <20121011153503.GX3317@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121011153503.GX3317@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Thu, Oct 11, 2012 at 04:35:03PM +0100, Mel Gorman wrote:
> On Thu, Oct 11, 2012 at 04:56:11PM +0200, Andrea Arcangeli wrote:
> > Hi Mel,
> > 
> > On Thu, Oct 11, 2012 at 11:19:30AM +0100, Mel Gorman wrote:
> > > As a basic sniff test I added a test to MMtests for the AutoNUMA
> > > Benchmark on a 4-node machine and the following fell out.
> > > 
> > >                                      3.6.0                 3.6.0
> > >                                    vanilla        autonuma-v33r6
> > > User    SMT             82851.82 (  0.00%)    33084.03 ( 60.07%)
> > > User    THREAD_ALLOC   142723.90 (  0.00%)    47707.38 ( 66.57%)
> > > System  SMT               396.68 (  0.00%)      621.46 (-56.67%)
> > > System  THREAD_ALLOC      675.22 (  0.00%)      836.96 (-23.95%)
> > > Elapsed SMT              1987.08 (  0.00%)      828.57 ( 58.30%)
> > > Elapsed THREAD_ALLOC     3222.99 (  0.00%)     1101.31 ( 65.83%)
> > > CPU     SMT              4189.00 (  0.00%)     4067.00 (  2.91%)
> > > CPU     THREAD_ALLOC     4449.00 (  0.00%)     4407.00 (  0.94%)
> > 
> > Thanks a lot for the help and for looking into it!
> > 
> > Just curious, why are you running only numa02_SMT and
> > numa01_THREAD_ALLOC? And not numa01 and numa02? (the standard version
> > without _suffix)
> > 
> 
> Bug in the testing script on my end. Each of them are run separtly and it

Ok, MMTests 0.06 (released a few minutes ago) patches autonumabench so
it can run the tests individually. I know start_bench.sh can run all the
tests itself but in time I'll want mmtests to collect additional stats
that can also be applied to other benchmarks consistently. The revised
results look like this

AUTONUMA BENCH
                                          3.6.0                 3.6.0
                                        vanilla        autonuma-v33r6
User    NUMA01               66395.58 (  0.00%)    32000.83 ( 51.80%)
User    NUMA01_THEADLOCAL    55952.48 (  0.00%)    16950.48 ( 69.71%)
User    NUMA02                6988.51 (  0.00%)     2150.56 ( 69.23%)
User    NUMA02_SMT            2914.25 (  0.00%)     1013.11 ( 65.24%)
System  NUMA01                 319.12 (  0.00%)      483.60 (-51.54%)
System  NUMA01_THEADLOCAL       40.60 (  0.00%)      184.39 (-354.16%)
System  NUMA02                   1.62 (  0.00%)       23.92 (-1376.54%)
System  NUMA02_SMT               0.90 (  0.00%)       16.20 (-1700.00%)
Elapsed NUMA01                1519.53 (  0.00%)      757.40 ( 50.16%)
Elapsed NUMA01_THEADLOCAL     1269.49 (  0.00%)      398.63 ( 68.60%)
Elapsed NUMA02                 181.12 (  0.00%)       57.09 ( 68.48%)
Elapsed NUMA02_SMT             164.18 (  0.00%)       53.16 ( 67.62%)
CPU     NUMA01                4390.00 (  0.00%)     4288.00 (  2.32%)
CPU     NUMA01_THEADLOCAL     4410.00 (  0.00%)     4298.00 (  2.54%)
CPU     NUMA02                3859.00 (  0.00%)     3808.00 (  1.32%)
CPU     NUMA02_SMT            1775.00 (  0.00%)     1935.00 ( -9.01%)

MMTests Statistics: duration
               3.6.0       3.6.0
             vanilla autonuma-v33r6
User       132257.44    52121.30
System        362.79      708.62
Elapsed      3142.66     1275.72

MMTests Statistics: vmstat
                              3.6.0       3.6.0
                            vanilla autonuma-v33r6
THP fault alloc               17660       19927
THP collapse alloc               10       12399
THP splits                        4       12637

The System CPU usage is high but is compenstated for with reduced User
and Elapsed times in this particular case.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
