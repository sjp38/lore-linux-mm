Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id EDDA86B0044
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 09:48:48 -0400 (EDT)
Date: Tue, 16 Oct 2012 14:48:44 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00/33] AutoNUMA27
Message-ID: <20121016134844.GV3317@csn.ul.ie>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, Oct 04, 2012 at 01:50:42AM +0200, Andrea Arcangeli wrote:
> Key to the kernels used in the testing:
> 
> - 3.6.0         = upstream 3.6.0 kernel
> - 3.6.0numactl  = 3.6.0 kernel with numactl hard NUMA bindings
> - autonuma26MoF = previous autonuma version based 3.6.0-rc7 kernel
> 
> == specjbb multi instance, 4 nodes, 4 instances ==
> 
> autonuma26MoF outperform 3.6.0 by 11% while 3.6.0numactl provides an
> additional 9% increase.
> 
> 3.6.0numactl:
> Per-node process memory usage (in MBs):
>              PID             N0             N1             N2             N3
>       ----------     ----------     ----------     ----------     ----------
>            38901        3075.56           0.54           0.07           7.53
>            38902           1.31           0.54        3065.37           7.53
>            38903           1.31           0.54           0.07        3070.10
>            38904           1.31        3064.56           0.07           7.53
> 
> autonuma26MoF:
> Per-node process memory usage (in MBs):
>              PID             N0             N1             N2             N3
>       ----------     ----------     ----------     ----------     ----------
>             9704          94.85        2862.37          50.86         139.35
>             9705          61.51          20.05        2963.78          40.62
>             9706        2941.80          11.68         104.12           7.70
>             9707          35.02          10.62           9.57        3042.25
> 

This is a somewhat opaque view of what specjbb measures. You mention that
it out-performs but that actually hides useful information in specjbb which
only reports on a range of measurements around the "expected peak". This
expected peak may or may not be related to the actual peak.

In the interest of being able to make fair comparisons, I automated specjbb
in MMTests (will be in 0.07) and compared just vanilla with autonuma -
no comparison with hard-binding. Mean values are between JVM instances
which is one per node or 4 instances in this particular case.

SPECJBB PEAKS
                                       3.6.0                      3.6.0
                                     vanilla             autonuma-v33r6
 Expctd Warehouse                   12.00 (  0.00%)                   12.00 (  0.00%)
 Expctd Peak Bops               448606.00 (  0.00%)               596993.00 ( 33.08%)
 Actual Warehouse                    6.00 (  0.00%)                    8.00 ( 33.33%)
 Actual Peak Bops               551074.00 (  0.00%)               640830.00 ( 16.29%)

The expected number of warehouses the workload was to peak at was 12 in
both cases as it's related to the number of CPUs. autonuma peaked with
more warehouses although both fall far short of the expected peaks. Be
it the expected or actual peak values, autonuma performed better.

I've truncated the following report. It goes up to 48 warehouses but
I'll cut it off at 12.

SPECJBB BOPS
                          3.6.0                 3.6.0
                        vanilla        autonuma-v33r6
Mean   1      25867.75 (  0.00%)     25373.00 ( -1.91%)
Mean   2      53529.25 (  0.00%)     56647.25 (  5.82%)
Mean   3      77217.75 (  0.00%)     82738.75 (  7.15%)
Mean   4      99545.25 (  0.00%)    107591.25 (  8.08%)
Mean   5     120928.50 (  0.00%)    131507.75 (  8.75%)
Mean   6     137768.50 (  0.00%)    152805.25 ( 10.91%)
Mean   7     137708.25 (  0.00%)    158663.50 ( 15.22%)
Mean   8     135210.50 (  0.00%)    160207.50 ( 18.49%)
Mean   9     133033.25 (  0.00%)    159569.50 ( 19.95%)
Mean   10    124737.00 (  0.00%)    158120.50 ( 26.76%)
Mean   11    122714.00 (  0.00%)    154189.50 ( 25.65%)
Mean   12    112151.50 (  0.00%)    149248.25 ( 33.08%)
Stddev 1        636.78 (  0.00%)      1476.21 (-131.82%)
Stddev 2        718.08 (  0.00%)      1141.74 (-59.00%)
Stddev 3        780.06 (  0.00%)       913.81 (-17.15%)
Stddev 4        755.54 (  0.00%)      1128.75 (-49.40%)
Stddev 5        825.39 (  0.00%)      1346.97 (-63.19%)
Stddev 6        563.58 (  0.00%)      1283.66 (-127.77%)
Stddev 7        848.47 (  0.00%)       715.98 ( 15.62%)
Stddev 8       1361.77 (  0.00%)      1020.32 ( 25.07%)
Stddev 9       5559.53 (  0.00%)       120.52 ( 97.83%)
Stddev 10      5128.25 (  0.00%)      2245.96 ( 56.20%)
Stddev 11      4086.70 (  0.00%)      3452.71 ( 15.51%)
Stddev 12      4410.86 (  0.00%)      9030.55 (-104.73%)
TPut   1     103471.00 (  0.00%)    101492.00 ( -1.91%)
TPut   2     214117.00 (  0.00%)    226589.00 (  5.82%)
TPut   3     308871.00 (  0.00%)    330955.00 (  7.15%)
TPut   4     398181.00 (  0.00%)    430365.00 (  8.08%)
TPut   5     483714.00 (  0.00%)    526031.00 (  8.75%)
TPut   6     551074.00 (  0.00%)    611221.00 ( 10.91%)
TPut   7     550833.00 (  0.00%)    634654.00 ( 15.22%)
TPut   8     540842.00 (  0.00%)    640830.00 ( 18.49%)
TPut   9     532133.00 (  0.00%)    638278.00 ( 19.95%)
TPut   10    498948.00 (  0.00%)    632482.00 ( 26.76%)
TPut   11    490856.00 (  0.00%)    616758.00 ( 25.65%)
TPut   12    448606.00 (  0.00%)    596993.00 ( 33.08%)

The average Bops per JVM instance and overall throughput is higher with
autonuma but note the standard deviations are higher. I do not have an
explanation for this as it could be due to anything.

MMTests Statistics: duration
               3.6.0       3.6.0
             vanillaautonuma-v33r6
User       481036.95   478932.80
System        185.86      824.27
Elapsed     10385.16    10356.73

Time to complete is unchanged which is expected as it runs for a fixed
length of time. Again, the System CPU usage is very high with autonuma
which matches what was seen with the autonuma benchmark.

MMTests Statistics: vmstat
                              3.6.0       3.6.0
                            vanillaautonuma-v33r6
THP fault alloc                   0           0
THP collapse alloc                0           0
THP splits                        0           2
THP fault fallback                0           0
THP collapse fail                 0           0
Compaction stalls                 0           0
Compaction success                0           0
Compaction failures               0           0
Compaction pages moved            0           0
Compaction move failure           0           0

No THP activity at all - suspiciously low actually but it implies that
native migration of THP pages would make no difference to JVMs (or at
least this JVM).

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
