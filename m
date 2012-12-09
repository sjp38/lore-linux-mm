Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 550576B0044
	for <linux-mm@kvack.org>; Sun,  9 Dec 2012 15:36:40 -0500 (EST)
Date: Sun, 9 Dec 2012 20:36:31 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/49] Automatic NUMA Balancing v10
Message-ID: <20121209203630.GC1009@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
 <20121207110113.GB21482@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121207110113.GB21482@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Dec 07, 2012 at 12:01:13PM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > This is a full release of all the patches so apologies for the 
> > flood. [...]
> 
> I have yet to process all your mails, but assuming I address all 
> your review feedback and the latest unified tree in tip:master 
> shows no regression in your testing, would you be willing to 
> start using it for ongoing work?
> 

Ingo,

If you had read the second paragraph of the mail you just responded to or
the results at the end then you would have seen that I had problems with
the performance. You would also know that tip/master testing for the last
week was failing due to a boot problem (issue was in mainline not tip and
has been already fixed) and would have known that since the -v18 release
that numacore was effectively disabled on my test machine.

Clearly you are not reading the bug reports you are receiving and you're not
seeing the small bit of review feedback or answering the review questions
you have received either. Why would I be more forthcoming when I feel that
it'll simply be ignored?  You simply assume that each batch of patches
you place on top must be fixing all known regressions and ignoring any
evidence to the contrary.

If you had read my mail from last Tuesday you would even know which patch
was causing the problem that effectively disabled numacore although not
why. The comment about p->numa_faults was completely off the mark (long
journey, was tired, assumed numa_faults was a counter and not a pointer
which was careless).  If you had called me on it then I would have spotted
the actual problem sooner. The problem was indeed with the nr_cpus_allowed
== num_online_cpus()s check which I had pointed out was a suspicious check
although for different reasons. As it turns out, a printk() bodge showed
that nr_cpus_allowed == 80 set in sched_init_smp() while num_online_cpus()
== 48. This effectively disabling numacore. If you had responded to the
bug report, this would likely have been found last Wednesday.

As for my ongoing work, I have not actually changed much in the last
two weeks or so -- build fixes and your scalability patches. As I've
said multiple times, my primary objective was to build something minimal
that did something better than mainline although not necessarily as good
as the kernel potentially if either numacore or autonuma were rebased
on top. I left the tree so that other testing might validate it was
correct and avoid changing the tree too much prior to the merge window.
I deliberately avoided working on anything that would directly collide
with what numacore was trying to achieve.

> It would make it much easier for me to pick up your 
> enhancements, fixes, etc.
> 
> > Changelog since V9
> >   o Migration scalability                                             (mingo)
> 
> To *really* see migration scalability bottlenecks you need to 
> remove the migration-bandwidth throttling kludge from your tree 
> (or configure it up very high if you want to do it simple).
> 

Why is it a kludge? I already explained what the rational behind the rate
limiting was. It's not about scalability, it's about mitigating worse-case
behaviour and the amount of time the kernel spends moving data around which
a deliberately adverse workload can trigger. It is unacceptable if during a
phase change that a process would stall potentially for milliseconds (seconds
if the node is large enough I guess) while the data is being migrated. Here
is it again -- http://www.spinics.net/lists/linux-mm/msg47440.html . You
either ignored the mail or simply could not be bothered explaining why
you thought this was the incorrect decision or why the concerns about an
adverse workload were unimportant.

I have a vague suspicion actually that when you are modelling the task->data
relationship that you make an implicit assumption that moving data has
zero or near-zero cost. In such a model it would always make sense to move
quickly and immediately but in practice the cost of moving can exceed the
performance benefit of accessing local data and lead to regressions. It
becomes more pronounced if the nodes are not fully connected.

> Some (certainly not all) of the performance regressions you 
> reported were certainly due to numa/core code hitting the 
> migration codepaths as aggressively as the workload demanded - 
> and hitting scalability bottlenecks.
> 

How are you so certain? How do you not know it's because your code is
migrating excessively for no good reason because the algorithm has a flaw
in it? Or that the cost of excessive migration is not being offset by
local data accesses? The critical point to note is that if it really was
only scalability problems then autonuma would suffer the same problems
and would be impossible to autonumas performance to exceed numacores.
This isn't the case making it unlikely the scalability is your only problem.

Either way, last night I applied a patch on top of latest tip/master to
remove the nr_cpus_allowed check so that numacore would be enabled again
and tested that. In some places it has indeed much improved. In others
it is still regressing badly and in two case, it's corrupting memory --
specjbb when THP is enabled crashes when running for single or multiple
JVMs. It is likely that a zero page is being inserted due to a race with
migration and causes the JVM to throw a null pointer exception. Here is
the comparison on the rough off-chance you actually read it this time.

stats-v8r6		Same collection of TLB flush fixes and stats
numacore-20121130	Roughly numacore v17
numafix-20121209	numacore as of December 9th with the nr_cpus_allowed check removed.
			Note that this is a 3.7-rc8 based test because that's what tip/master
			is.
autonuma-v28fastr4	Autonuma v28fast with THP patch on top
balancenuma-v9r2	Balance numa v9
balancenuma-v10r3	V9 + the migration scalability patches

AutoNUMA Benchmark
==================

                                      3.7.0-rc7             3.7.0-rc6             3.7.0-rc8             3.7.0-rc7             3.7.0-rc7             3.7.0-rc7
                                     stats-v8r6     numacore-20121130      numafix-20121209    autonuma-v28fastr4      balancenuma-v9r2     balancenuma-v10r3
User    NUMA01               65230.85 (  0.00%)    24835.22 ( 61.93%)    21882.80 ( 66.45%)    30410.22 ( 53.38%)    52436.65 ( 19.61%)    59949.95 (  8.10%)
User    NUMA01_THEADLOCAL    60794.67 (  0.00%)    17856.17 ( 70.63%)    18367.20 ( 69.79%)    17185.34 ( 71.73%)    17829.96 ( 70.67%)    17501.83 ( 71.21%)
User    NUMA02                7031.50 (  0.00%)     2084.38 ( 70.36%)     2391.47 ( 65.99%)     2238.73 ( 68.16%)     2079.48 ( 70.43%)     2094.68 ( 70.21%)
User    NUMA02_SMT            2916.19 (  0.00%)     1009.28 ( 65.39%)     1046.49 ( 64.11%)     1037.07 ( 64.44%)      997.57 ( 65.79%)     1010.15 ( 65.36%)
System  NUMA01                  39.66 (  0.00%)      926.55 (-2236.23%)      134.00 (-237.87%)      236.83 (-497.15%)      275.09 (-593.62%)      265.02 (-568.23%)
System  NUMA01_THEADLOCAL       42.33 (  0.00%)      513.99 (-1114.25%)      201.65 (-376.38%)       70.90 (-67.49%)      110.82 (-161.80%)      130.30 (-207.82%)
System  NUMA02                   1.25 (  0.00%)       18.57 (-1385.60%)       13.00 (-940.00%)        6.39 (-411.20%)        6.42 (-413.60%)        9.17 (-633.60%)
System  NUMA02_SMT              16.66 (  0.00%)       12.32 ( 26.05%)        7.26 ( 56.42%)        3.17 ( 80.97%)        3.58 ( 78.51%)        6.21 ( 62.73%)
Elapsed NUMA01                1511.76 (  0.00%)      575.93 ( 61.90%)      475.26 ( 68.56%)      701.62 ( 53.59%)     1185.53 ( 21.58%)     1352.74 ( 10.52%)
Elapsed NUMA01_THEADLOCAL     1387.17 (  0.00%)      398.55 ( 71.27%)      405.25 ( 70.79%)      378.47 ( 72.72%)      397.37 ( 71.35%)      387.93 ( 72.03%)
Elapsed NUMA02                 176.81 (  0.00%)       51.14 ( 71.08%)       62.08 ( 64.89%)       53.45 ( 69.77%)       49.51 ( 72.00%)       49.77 ( 71.85%)
Elapsed NUMA02_SMT             163.96 (  0.00%)       48.92 ( 70.16%)       54.45 ( 66.79%)       48.17 ( 70.62%)       47.71 ( 70.90%)       48.63 ( 70.34%)
CPU     NUMA01                4317.00 (  0.00%)     4473.00 ( -3.61%)     4632.00 ( -7.30%)     4368.00 ( -1.18%)     4446.00 ( -2.99%)     4451.00 ( -3.10%)
CPU     NUMA01_THEADLOCAL     4385.00 (  0.00%)     4609.00 ( -5.11%)     4582.00 ( -4.49%)     4559.00 ( -3.97%)     4514.00 ( -2.94%)     4545.00 ( -3.65%)
CPU     NUMA02                3977.00 (  0.00%)     4111.00 ( -3.37%)     3873.00 (  2.62%)     4200.00 ( -5.61%)     4212.00 ( -5.91%)     4226.00 ( -6.26%)
CPU     NUMA02_SMT            1788.00 (  0.00%)     2087.00 (-16.72%)     1935.00 ( -8.22%)     2159.00 (-20.75%)     2098.00 (-17.34%)     2089.00 (-16.83%)

Latest numacore has improved on the numa01 case quite a bit. However, this is
the adverse workload.  For the workloads that actually do something sensible,
autonuma and balancenuma are both beating numacore by a good margin.

numacores system CPU usage continues to be excessive -- over triple
balancenumas in the numa01 case. Over quadruple in the numa01_threadlocal
case. Double in numa02 and over double in the numa02_smt case.

Duration and vmstats showed nothing interesting so I excluded them this time.

SpecJBB, Multiple JVMs, THP is enabled
======================================

There is no latest numacore figures available because the JVM in two
separate tests crashed with this report

Input Properties:
  per_jvm_warehouse_rampup = 3.0
  per_jvm_warehouse_rampdown = 20.0
  jvm_instances = 4
  deterministic_random_seed = false
  ramp_up_seconds = 30
  measurement_seconds = 240
  starting_number_warehouses = 1
  increment_number_warehouses = 1
  ending_number_warehouses = 24
  expected_peak_warehouse = 12
Waiting on instance 1 pid 4028 to finish.
Accepted client /127.0.0.1:59130
Accepted client /127.0.0.1:58393
Accepted client /127.0.0.1:53374
Accepted client /127.0.0.1:40128
java.lang.NullPointerException: error
/root/git-private/autonuma-test/shellpacks/shellpack-bench-specjbb: line 203:  4028 Aborted                 java $USE_HUGEPAGE $SPECJBB_MAXHEAP spec.jbb.JBBmain -propfile SPECjbb.props -id $INSTANCE > $SHELLPACK_TEMP/jvm-instance-$INSTANCE.log
Waiting on instance 1 pid 4029 to finish.
Exception in thread "main" java.lang.NullPointerException
	at spec.jbb.Company.displayResultTotals(Unknown Source)
	at spec.jbb.JBBmain.DoARun(Unknown Source)
	at spec.jbb.JBBmain.runWarehouse(Unknown Source)
	at spec.jbb.JBBmain.doIt(Unknown Source)
	at spec.jbb.JBBmain.main(Unknown Source)
Exception in thread "main" java.lang.NullPointerException
	at spec.jbb.Company.displayResultTotals(Unknown Source)
	at spec.jbb.JBBmain.DoARun(Unknown Source)
	at spec.jbb.JBBmain.runWarehouse(Unknown Source)
	at spec.jbb.JBBmain.doIt(Unknown Source)
	at spec.jbb.JBBmain.main(Unknown Source)
Exception in thread "main" java.lang.NullPointerException
	at spec.jbb.Company.displayResultTotals(Unknown Source)
	at spec.jbb.JBBmain.DoARun(Unknown Source)
	at spec.jbb.JBBmain.runWarehouse(Unknown Source)
	at spec.jbb.JBBmain.doIt(Unknown Source)
	at spec.jbb.JBBmain.main(Unknown Source)
Read from remote host compass: Connection reset by peer

Here are the results for the kernels that succeeded

                      3.7.0-rc7             3.7.0-rc6             3.7.0-rc7             3.7.0-rc7             3.7.0-rc7
                     stats-v8r6     numacore-20121130    autonuma-v28fastr4      balancenuma-v9r2     balancenuma-v10r3
Mean   1      31311.75 (  0.00%)     27938.00 (-10.77%)     31474.25 (  0.52%)     31112.00 ( -0.64%)     31281.50 ( -0.10%)
Mean   2      62972.75 (  0.00%)     51899.00 (-17.58%)     66654.00 (  5.85%)     62937.50 ( -0.06%)     62483.50 ( -0.78%)
Mean   3      91292.00 (  0.00%)     80908.00 (-11.37%)     97177.50 (  6.45%)     90665.50 ( -0.69%)     90667.00 ( -0.68%)
Mean   4     115768.75 (  0.00%)     99497.25 (-14.06%)    125596.00 (  8.49%)    116812.50 (  0.90%)    116193.50 (  0.37%)
Mean   5     137248.50 (  0.00%)     92837.75 (-32.36%)    152795.25 ( 11.33%)    139037.75 (  1.30%)    139055.50 (  1.32%)
Mean   6     155528.50 (  0.00%)    105554.50 (-32.13%)    177455.25 ( 14.10%)    155769.25 (  0.15%)    159129.50 (  2.32%)
Mean   7     156747.50 (  0.00%)    122582.25 (-21.80%)    184578.75 ( 17.76%)    157103.25 (  0.23%)    163234.00 (  4.14%)
Mean   8     152069.50 (  0.00%)    122439.00 (-19.48%)    186619.25 ( 22.72%)    157631.00 (  3.66%)    163077.75 (  7.24%)
Mean   9     146609.75 (  0.00%)    112410.00 (-23.33%)    186165.00 ( 26.98%)    152561.00 (  4.06%)    159656.00 (  8.90%)
Mean   10    142819.00 (  0.00%)    111456.00 (-21.96%)    182569.75 ( 27.83%)    145320.00 (  1.75%)    153414.25 (  7.42%)
Mean   11    128292.25 (  0.00%)     98027.00 (-23.59%)    176104.75 ( 37.27%)    138599.50 (  8.03%)    147194.25 ( 14.73%)
Mean   12    128769.75 (  0.00%)    129469.50 (  0.54%)    169003.00 ( 31.24%)    131994.75 (  2.50%)    140049.75 (  8.76%)
Mean   13    126488.50 (  0.00%)    110133.75 (-12.93%)    162725.75 ( 28.65%)    130005.25 (  2.78%)    139109.75 (  9.98%)
Mean   14    123400.00 (  0.00%)    117929.75 ( -4.43%)    163781.25 ( 32.72%)    126340.75 (  2.38%)    137883.00 ( 11.74%)
Mean   15    122139.50 (  0.00%)    122404.25 (  0.22%)    160800.25 ( 31.65%)    128612.75 (  5.30%)    136624.00 ( 11.86%)
Mean   16    116413.50 (  0.00%)    124573.50 (  7.01%)    160882.75 ( 38.20%)    117793.75 (  1.19%)    134005.75 ( 15.11%)
Mean   17    117263.25 (  0.00%)    121937.25 (  3.99%)    159069.75 ( 35.65%)    121991.75 (  4.03%)    133444.50 ( 13.80%)
Mean   18    117277.00 (  0.00%)    116633.75 ( -0.55%)    158694.75 ( 35.32%)    119089.75 (  1.55%)    129650.75 ( 10.55%)
Mean   19    113231.00 (  0.00%)    111035.75 ( -1.94%)    155563.25 ( 37.39%)    119699.75 (  5.71%)    123403.25 (  8.98%)
Mean   20    113628.75 (  0.00%)    113451.25 ( -0.16%)    154779.75 ( 36.22%)    118400.75 (  4.20%)    126041.25 ( 10.92%)
Mean   21    110982.50 (  0.00%)    107660.50 ( -2.99%)    151147.25 ( 36.19%)    115663.25 (  4.22%)    121906.50 (  9.84%)
Mean   22    107660.25 (  0.00%)    104771.50 ( -2.68%)    151180.50 ( 40.42%)    111038.00 (  3.14%)    125519.00 ( 16.59%)
Mean   23    105320.50 (  0.00%)     88275.25 (-16.18%)    147032.00 ( 39.60%)    112817.50 (  7.12%)    124148.25 ( 17.88%)
Mean   24    110900.50 (  0.00%)     85169.00 (-23.20%)    147407.00 ( 32.92%)    109556.50 ( -1.21%)    122544.00 ( 10.50%)
Stddev 1        720.83 (  0.00%)       982.31 (-36.28%)       942.80 (-30.79%)      1170.23 (-62.35%)       539.84 ( 25.11%)
Stddev 2        466.00 (  0.00%)      1770.75 (-279.99%)      1327.32 (-184.83%)      1368.51 (-193.67%)      2103.32 (-351.35%)
Stddev 3        509.61 (  0.00%)      4849.62 (-851.63%)      1803.72 (-253.94%)      1088.04 (-113.50%)       410.73 ( 19.40%)
Stddev 4       1750.10 (  0.00%)     10708.16 (-511.86%)      2010.11 (-14.86%)      1456.90 ( 16.75%)      1370.22 ( 21.71%)
Stddev 5        700.05 (  0.00%)     16497.79 (-2256.66%)      2354.70 (-236.36%)       759.38 ( -8.48%)      1869.54 (-167.06%)
Stddev 6       2259.33 (  0.00%)     24221.98 (-972.09%)      1516.32 ( 32.89%)      1032.39 ( 54.31%)      1720.87 ( 23.83%)
Stddev 7       3390.99 (  0.00%)      4721.80 (-39.25%)      2398.34 ( 29.27%)      2487.08 ( 26.66%)      4327.85 (-27.63%)
Stddev 8       7533.18 (  0.00%)      8609.90 (-14.29%)      2895.55 ( 61.56%)      3902.53 ( 48.20%)      2536.68 ( 66.33%)
Stddev 9       9223.98 (  0.00%)     10731.70 (-16.35%)      4726.23 ( 48.76%)      5673.20 ( 38.50%)      3377.59 ( 63.38%)
Stddev 10      4578.09 (  0.00%)     11136.27 (-143.25%)      6705.48 (-46.47%)      5516.47 (-20.50%)      7227.58 (-57.87%)
Stddev 11      8201.30 (  0.00%)      3580.27 ( 56.35%)     10915.90 (-33.10%)      4757.42 ( 41.99%)      4056.02 ( 50.54%)
Stddev 12      5713.70 (  0.00%)     13923.12 (-143.68%)     16555.64 (-189.75%)      4573.05 ( 19.96%)      3678.89 ( 35.61%)
Stddev 13      5878.95 (  0.00%)     10471.09 (-78.11%)     18628.01 (-216.86%)      1680.65 ( 71.41%)      3947.39 ( 32.86%)
Stddev 14      4783.95 (  0.00%)      4051.35 ( 15.31%)     18324.63 (-283.04%)      2637.82 ( 44.86%)      4806.09 ( -0.46%)
Stddev 15      6281.48 (  0.00%)      3357.07 ( 46.56%)     17654.58 (-181.06%)      2003.38 ( 68.11%)      3005.22 ( 52.16%)
Stddev 16      6948.12 (  0.00%)      3763.32 ( 45.84%)     18280.52 (-163.10%)      3526.10 ( 49.25%)      3309.24 ( 52.37%)
Stddev 17      5603.77 (  0.00%)      1452.04 ( 74.09%)     18230.53 (-225.33%)      1712.95 ( 69.43%)      3516.09 ( 37.25%)
Stddev 18      6200.90 (  0.00%)      1870.12 ( 69.84%)     18486.73 (-198.13%)       751.36 ( 87.88%)      2412.60 ( 61.09%)
Stddev 19      6726.31 (  0.00%)      1045.21 ( 84.46%)     18465.25 (-174.52%)      1750.49 ( 73.98%)      4482.82 ( 33.35%)
Stddev 20      5713.58 (  0.00%)      2066.90 ( 63.82%)     19947.77 (-249.13%)      1892.91 ( 66.87%)      2612.62 ( 54.27%)
Stddev 21      4566.92 (  0.00%)      2460.40 ( 46.13%)     21189.08 (-363.97%)      3639.75 ( 20.30%)      1963.17 ( 57.01%)
Stddev 22      6168.05 (  0.00%)      2770.81 ( 55.08%)     20033.82 (-224.80%)      3682.20 ( 40.30%)      1159.17 ( 81.21%)
Stddev 23      6295.45 (  0.00%)      1337.32 ( 78.76%)     22610.91 (-259.16%)      2013.53 ( 68.02%)      3842.61 ( 38.96%)
Stddev 24      3108.17 (  0.00%)      1381.20 ( 55.56%)     21243.56 (-583.47%)      4044.16 (-30.11%)      2673.39 ( 13.99%)
TPut   1     125247.00 (  0.00%)    111752.00 (-10.77%)    125897.00 (  0.52%)    124448.00 ( -0.64%)    125126.00 ( -0.10%)
TPut   2     251891.00 (  0.00%)    207596.00 (-17.58%)    266616.00 (  5.85%)    251750.00 ( -0.06%)    249934.00 ( -0.78%)
TPut   3     365168.00 (  0.00%)    323632.00 (-11.37%)    388710.00 (  6.45%)    362662.00 ( -0.69%)    362668.00 ( -0.68%)
TPut   4     463075.00 (  0.00%)    397989.00 (-14.06%)    502384.00 (  8.49%)    467250.00 (  0.90%)    464774.00 (  0.37%)
TPut   5     548994.00 (  0.00%)    371351.00 (-32.36%)    611181.00 ( 11.33%)    556151.00 (  1.30%)    556222.00 (  1.32%)
TPut   6     622114.00 (  0.00%)    422218.00 (-32.13%)    709821.00 ( 14.10%)    623077.00 (  0.15%)    636518.00 (  2.32%)
TPut   7     626990.00 (  0.00%)    490329.00 (-21.80%)    738315.00 ( 17.76%)    628413.00 (  0.23%)    652936.00 (  4.14%)
TPut   8     608278.00 (  0.00%)    489756.00 (-19.48%)    746477.00 ( 22.72%)    630524.00 (  3.66%)    652311.00 (  7.24%)
TPut   9     586439.00 (  0.00%)    449640.00 (-23.33%)    744660.00 ( 26.98%)    610244.00 (  4.06%)    638624.00 (  8.90%)
TPut   10    571276.00 (  0.00%)    445824.00 (-21.96%)    730279.00 ( 27.83%)    581280.00 (  1.75%)    613657.00 (  7.42%)
TPut   11    513169.00 (  0.00%)    392108.00 (-23.59%)    704419.00 ( 37.27%)    554398.00 (  8.03%)    588777.00 ( 14.73%)
TPut   12    515079.00 (  0.00%)    517878.00 (  0.54%)    676012.00 ( 31.24%)    527979.00 (  2.50%)    560199.00 (  8.76%)
TPut   13    505954.00 (  0.00%)    440535.00 (-12.93%)    650903.00 ( 28.65%)    520021.00 (  2.78%)    556439.00 (  9.98%)
TPut   14    493600.00 (  0.00%)    471719.00 ( -4.43%)    655125.00 ( 32.72%)    505363.00 (  2.38%)    551532.00 ( 11.74%)
TPut   15    488558.00 (  0.00%)    489617.00 (  0.22%)    643201.00 ( 31.65%)    514451.00 (  5.30%)    546496.00 ( 11.86%)
TPut   16    465654.00 (  0.00%)    498294.00 (  7.01%)    643531.00 ( 38.20%)    471175.00 (  1.19%)    536023.00 ( 15.11%)
TPut   17    469053.00 (  0.00%)    487749.00 (  3.99%)    636279.00 ( 35.65%)    487967.00 (  4.03%)    533778.00 ( 13.80%)
TPut   18    469108.00 (  0.00%)    466535.00 ( -0.55%)    634779.00 ( 35.32%)    476359.00 (  1.55%)    518603.00 ( 10.55%)
TPut   19    452924.00 (  0.00%)    444143.00 ( -1.94%)    622253.00 ( 37.39%)    478799.00 (  5.71%)    493613.00 (  8.98%)
TPut   20    454515.00 (  0.00%)    453805.00 ( -0.16%)    619119.00 ( 36.22%)    473603.00 (  4.20%)    504165.00 ( 10.92%)
TPut   21    443930.00 (  0.00%)    430642.00 ( -2.99%)    604589.00 ( 36.19%)    462653.00 (  4.22%)    487626.00 (  9.84%)
TPut   22    430641.00 (  0.00%)    419086.00 ( -2.68%)    604722.00 ( 40.42%)    444152.00 (  3.14%)    502076.00 ( 16.59%)
TPut   23    421282.00 (  0.00%)    353101.00 (-16.18%)    588128.00 ( 39.60%)    451270.00 (  7.12%)    496593.00 ( 17.88%)
TPut   24    443602.00 (  0.00%)    340676.00 (-23.20%)    589628.00 ( 32.92%)    438226.00 ( -1.21%)    490176.00 ( 10.50%)

numacore v17 regressed but we knew that already.

autonuma does the best overall

balancenuma does all right and the scalability patches help quite a bit.

SPECJBB PEAKS
                                   3.7.0-rc7                  3.7.0-rc6                  3.7.0-rc7                  3.7.0-rc7                  3.7.0-rc7
                                  stats-v8r6          numacore-20121130         autonuma-v28fastr4           balancenuma-v9r2          balancenuma-v10r3
 Expctd Warehouse            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)
 Expctd Peak Bops        515079.00 (  0.00%)        517878.00 (  0.54%)        676012.00 ( 31.24%)        527979.00 (  2.50%)        560199.00 (  8.76%)
 Actual Warehouse             7.00 (  0.00%)            12.00 ( 71.43%)             8.00 ( 14.29%)             8.00 ( 14.29%)             7.00 (  0.00%)
 Actual Peak Bops        626990.00 (  0.00%)        517878.00 (-17.40%)        746477.00 ( 19.06%)        630524.00 (  0.56%)        652936.00 (  4.14%)
 SpecJBB Bops            465685.00 (  0.00%)        447214.00 ( -3.97%)        628328.00 ( 34.93%)        480925.00 (  3.27%)        521332.00 ( 11.95%)
 SpecJBB Bops/JVM        116421.00 (  0.00%)        111804.00 ( -3.97%)        157082.00 ( 34.93%)        120231.00 (  3.27%)        130333.00 ( 11.95%)

numacore is pretty old here so ignore the regression.

autonuma is the best but balancenuma sees some of the performance gain.

MMTests Statistics: vmstat
                             3.7.0-rc7   3.7.0-rc6   3.7.0-rc7   3.7.0-rc7   3.7.0-rc7
                            stats-v8r6numacore-20121130autonuma-v28fastr4balancenuma-v9r2balancenuma-v10r3
Page Ins                         37116       36404       36740       35664       34832
Page Outs                        30340       33624       29428       29656       30320
Swap Ins                             0           0           0           0           0
Swap Outs                            0           0           0           0           0
Direct pages scanned                 0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0
Page writes file                     0           0           0           0           0
Page writes anon                     0           0           0           0           0
Page reclaim immediate               0           0           0           0           0
Page rescued immediate               0           0           0           0           0
Slabs scanned                        0           0           0           0           0
Direct inode steals                  0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0
THP fault alloc                  63322       49889       52514       65794       66963
THP collapse alloc                 130          53         463         128         121
THP splits                         355         192         376         371         362
THP fault fallback                   0           0           0           0           0
THP collapse fail                    0           0           0           0           0
Compaction stalls                    0           0           0           0           0
Compaction success                   0           0           0           0           0
Compaction failures                  0           0           0           0           0
Page migrate success                 0           0           0    51424061    50195011
Page migrate failure                 0           0           0           0           0
Compaction pages isolated            0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0
Compaction free scanned              0           0           0           0           0
Compaction cost                      0           0           0       53378       52102
NUMA PTE updates                     0           0           0   411047238   404964644
NUMA hint faults                     0           0           0     3077302     3075026
NUMA hint local faults               0           0           0      958617      870171
NUMA pages migrated                  0           0           0    51424061    50195011
AutoNUMA cost                        0           0           0       19240       19163

All it shows really is that THP is enabled and that balancenuma is migrating
more than I'd like -- 48MB/sec on average throughout the test.

SpecJBB, Multiple JVMs, THP is disabled
=======================================
                      3.7.0-rc7             3.7.0-rc6             3.7.0-rc8             3.7.0-rc7             3.7.0-rc7             3.7.0-rc7
                     stats-v8r6     numacore-20121130      numafix-20121209    autonuma-v28fastr4      balancenuma-v9r2     balancenuma-v10r3
Mean   1      26036.50 (  0.00%)     19595.00 (-24.74%)     23791.25 ( -8.62%)     24738.25 ( -4.99%)     25595.00 ( -1.70%)     25610.50 ( -1.64%)
Mean   2      53629.75 (  0.00%)     38481.50 (-28.25%)     46966.75 (-12.42%)     55646.75 (  3.76%)     53045.25 ( -1.09%)     53383.00 ( -0.46%)
Mean   3      77385.00 (  0.00%)     53685.50 (-30.63%)     66913.25 (-13.53%)     82714.75 (  6.89%)     76596.00 ( -1.02%)     76502.75 ( -1.14%)
Mean   4     100097.75 (  0.00%)     68253.50 (-31.81%)     72186.50 (-27.88%)    107883.25 (  7.78%)     98618.00 ( -1.48%)     99786.50 ( -0.31%)
Mean   5     119012.75 (  0.00%)     74164.50 (-37.68%)     72126.50 (-39.40%)    130260.25 (  9.45%)    119354.50 (  0.29%)    121741.75 (  2.29%)
Mean   6     137419.25 (  0.00%)     86158.50 (-37.30%)     52123.00 (-62.07%)    154244.50 ( 12.24%)    136901.75 ( -0.38%)    136990.50 ( -0.31%)
Mean   7     138018.25 (  0.00%)     96059.25 (-30.40%)     55582.50 (-59.73%)    159501.00 ( 15.57%)    138265.50 (  0.18%)    139398.75 (  1.00%)
Mean   8     136774.00 (  0.00%)     97003.50 (-29.08%)     30208.25 (-77.91%)    162868.00 ( 19.08%)    138554.50 (  1.30%)    137340.75 (  0.41%)
Mean   9     127966.50 (  0.00%)     95261.00 (-25.56%)    125900.50 ( -1.61%)    163008.00 ( 27.38%)    137954.00 (  7.80%)    134200.50 (  4.87%)
Mean   10    124628.75 (  0.00%)     96202.25 (-22.81%)     73809.00 (-40.78%)    159696.50 ( 28.14%)    131322.25 (  5.37%)    126927.50 (  1.84%)
Mean   11    117269.00 (  0.00%)     95924.25 (-18.20%)    127804.25 (  8.98%)    154701.50 ( 31.92%)    125032.75 (  6.62%)    122925.00 (  4.82%)
Mean   12    111962.25 (  0.00%)     94247.25 (-15.82%)    146580.25 ( 30.92%)    150936.50 ( 34.81%)    118119.50 (  5.50%)    119931.75 (  7.12%)
Mean   13    111595.50 (  0.00%)    106538.50 ( -4.53%)    134462.75 ( 20.49%)    147193.25 ( 31.90%)    116398.75 (  4.30%)    117349.75 (  5.16%)
Mean   14    110881.00 (  0.00%)    103549.00 ( -6.61%)    137573.25 ( 24.07%)    144584.00 ( 30.40%)    114934.50 (  3.66%)    115838.25 (  4.47%)
Mean   15    109337.50 (  0.00%)    101729.00 ( -6.96%)    139722.50 ( 27.79%)    143333.00 ( 31.09%)    115523.75 (  5.66%)    115151.25 (  5.32%)
Mean   16    107031.75 (  0.00%)    101983.75 ( -4.72%)    121221.75 ( 13.26%)    141907.75 ( 32.58%)    113666.00 (  6.20%)    113673.50 (  6.21%)
Mean   17    105491.25 (  0.00%)    100205.75 ( -5.01%)    129429.75 ( 22.69%)    140691.00 ( 33.37%)    112751.50 (  6.88%)    113221.25 (  7.33%)
Mean   18    101102.75 (  0.00%)     96635.50 ( -4.42%)    115086.50 ( 13.83%)    137784.25 ( 36.28%)    112582.50 ( 11.35%)    111533.50 ( 10.32%)
Mean   19    103907.25 (  0.00%)     94578.25 ( -8.98%)    126392.75 ( 21.64%)    135719.25 ( 30.62%)    110152.25 (  6.01%)    113959.25 (  9.67%)
Mean   20    100496.00 (  0.00%)     92683.75 ( -7.77%)    123318.75 ( 22.71%)    135264.25 ( 34.60%)    108861.50 (  8.32%)    113746.00 ( 13.18%)
Mean   21     99570.00 (  0.00%)     92955.75 ( -6.64%)    111293.00 ( 11.77%)    133891.00 ( 34.47%)    110094.00 ( 10.57%)    109462.50 (  9.94%)
Mean   22     98611.75 (  0.00%)     89781.75 ( -8.95%)    118218.50 ( 19.88%)    132399.75 ( 34.26%)    109322.75 ( 10.86%)    110502.75 ( 12.06%)
Mean   23     98173.00 (  0.00%)     88846.00 ( -9.50%)    118210.00 ( 20.41%)    130726.00 ( 33.16%)    106046.25 (  8.02%)    107304.25 (  9.30%)
Mean   24     92074.75 (  0.00%)     88581.00 ( -3.79%)    111965.00 ( 21.60%)    127552.25 ( 38.53%)    102362.00 ( 11.17%)    107119.25 ( 16.34%)
Stddev 1        735.13 (  0.00%)       538.24 ( 26.78%)       854.37 (-16.22%)       121.08 ( 83.53%)       906.62 (-23.33%)       788.06 ( -7.20%)
Stddev 2        406.26 (  0.00%)      3458.87 (-751.39%)      4220.03 (-938.75%)       477.32 (-17.49%)      1322.57 (-225.55%)       468.57 (-15.34%)
Stddev 3        644.20 (  0.00%)      1360.89 (-111.25%)      2573.27 (-299.45%)       922.47 (-43.20%)       609.27 (  5.42%)       599.26 (  6.98%)
Stddev 4        743.93 (  0.00%)      2149.34 (-188.92%)     14533.01 (-1853.53%)      1385.42 (-86.23%)      1119.02 (-50.42%)       801.13 ( -7.69%)
Stddev 5        898.53 (  0.00%)      2521.01 (-180.57%)     15303.97 (-1603.23%)       763.24 ( 15.06%)       942.52 ( -4.90%)      1718.19 (-91.22%)
Stddev 6       1126.61 (  0.00%)      3818.22 (-238.91%)     23616.59 (-1996.26%)      1527.03 (-35.54%)      2445.69 (-117.08%)      1754.32 (-55.72%)
Stddev 7       2907.61 (  0.00%)      4419.29 (-51.99%)     29664.97 (-920.25%)      1536.66 ( 47.15%)      4881.65 (-67.89%)      4863.83 (-67.28%)
Stddev 8       3200.64 (  0.00%)       382.01 ( 88.06%)     10743.99 (-235.68%)      1228.09 ( 61.63%)      5459.06 (-70.56%)      5583.95 (-74.46%)
Stddev 9       2907.92 (  0.00%)      1813.39 ( 37.64%)     11763.90 (-304.55%)      1502.61 ( 48.33%)      2501.16 ( 13.99%)      2525.02 ( 13.17%)
Stddev 10      5093.23 (  0.00%)      1313.58 ( 74.21%)     34926.95 (-585.75%)      2763.19 ( 45.75%)      2973.78 ( 41.61%)      2005.95 ( 60.62%)
Stddev 11      4982.41 (  0.00%)      1163.02 ( 76.66%)     13792.07 (-176.81%)      4776.28 (  4.14%)      6068.34 (-21.80%)      4256.77 ( 14.56%)
Stddev 12      3051.38 (  0.00%)      2117.59 ( 30.60%)      5819.48 (-90.72%)      9252.59 (-203.23%)      3885.96 (-27.35%)      2580.44 ( 15.43%)
Stddev 13      2918.03 (  0.00%)      2252.11 ( 22.82%)      8340.05 (-185.81%)      9384.83 (-221.62%)      1833.07 ( 37.18%)      2523.28 ( 13.53%)
Stddev 14      3178.97 (  0.00%)      2337.49 ( 26.47%)      6166.98 (-93.99%)      9353.03 (-194.22%)      1072.60 ( 66.26%)      1140.55 ( 64.12%)
Stddev 15      2438.31 (  0.00%)      1707.72 ( 29.96%)     10687.74 (-338.33%)     10494.03 (-330.38%)      2295.76 (  5.85%)      1213.75 ( 50.22%)
Stddev 16      2682.25 (  0.00%)       840.47 ( 68.67%)     10963.32 (-308.74%)     10343.25 (-285.62%)      2416.09 (  9.92%)      1697.27 ( 36.72%)
Stddev 17      2807.66 (  0.00%)      1546.16 ( 44.93%)     10755.81 (-283.09%)     11446.15 (-307.68%)      2484.08 ( 11.52%)       563.50 ( 79.93%)
Stddev 18      3049.27 (  0.00%)       934.11 ( 69.37%)      8523.80 (-179.54%)     11779.80 (-286.31%)      1472.27 ( 51.72%)      1533.68 ( 49.70%)
Stddev 19      2782.65 (  0.00%)       735.28 ( 73.58%)      9045.84 (-225.08%)     11416.35 (-310.27%)       514.78 ( 81.50%)      1283.38 ( 53.88%)
Stddev 20      2379.12 (  0.00%)       956.25 ( 59.81%)      3789.62 (-59.29%)     10511.63 (-341.83%)      1641.25 ( 31.01%)      1758.22 ( 26.10%)
Stddev 21      2975.22 (  0.00%)       438.31 ( 85.27%)      8160.39 (-174.28%)     11292.91 (-279.57%)      1087.60 ( 63.44%)       434.51 ( 85.40%)
Stddev 22      2260.61 (  0.00%)       718.23 ( 68.23%)     10418.90 (-360.89%)     11993.84 (-430.56%)       909.16 ( 59.78%)       322.32 ( 85.74%)
Stddev 23      2900.85 (  0.00%)       275.47 ( 90.50%)      9829.57 (-238.85%)     12234.80 (-321.77%)       701.39 ( 75.82%)      1444.19 ( 50.21%)
Stddev 24      2578.98 (  0.00%)       481.68 ( 81.32%)      7696.37 (-198.43%)     12769.61 (-395.14%)       732.56 ( 71.60%)      1777.60 ( 31.07%)
TPut   1     104146.00 (  0.00%)     78380.00 (-24.74%)     95165.00 ( -8.62%)     98953.00 ( -4.99%)    102380.00 ( -1.70%)    102442.00 ( -1.64%)
TPut   2     214519.00 (  0.00%)    153926.00 (-28.25%)    187867.00 (-12.42%)    222587.00 (  3.76%)    212181.00 ( -1.09%)    213532.00 ( -0.46%)
TPut   3     309540.00 (  0.00%)    214742.00 (-30.63%)    267653.00 (-13.53%)    330859.00 (  6.89%)    306384.00 ( -1.02%)    306011.00 ( -1.14%)
TPut   4     400391.00 (  0.00%)    273014.00 (-31.81%)    288746.00 (-27.88%)    431533.00 (  7.78%)    394472.00 ( -1.48%)    399146.00 ( -0.31%)
TPut   5     476051.00 (  0.00%)    296658.00 (-37.68%)    288506.00 (-39.40%)    521041.00 (  9.45%)    477418.00 (  0.29%)    486967.00 (  2.29%)
TPut   6     549677.00 (  0.00%)    344634.00 (-37.30%)    208492.00 (-62.07%)    616978.00 ( 12.24%)    547607.00 ( -0.38%)    547962.00 ( -0.31%)
TPut   7     552073.00 (  0.00%)    384237.00 (-30.40%)    222330.00 (-59.73%)    638004.00 ( 15.57%)    553062.00 (  0.18%)    557595.00 (  1.00%)
TPut   8     547096.00 (  0.00%)    388014.00 (-29.08%)    120833.00 (-77.91%)    651472.00 ( 19.08%)    554218.00 (  1.30%)    549363.00 (  0.41%)
TPut   9     511866.00 (  0.00%)    381044.00 (-25.56%)    503602.00 ( -1.61%)    652032.00 ( 27.38%)    551816.00 (  7.80%)    536802.00 (  4.87%)
TPut   10    498515.00 (  0.00%)    384809.00 (-22.81%)    295236.00 (-40.78%)    638786.00 ( 28.14%)    525289.00 (  5.37%)    507710.00 (  1.84%)
TPut   11    469076.00 (  0.00%)    383697.00 (-18.20%)    511217.00 (  8.98%)    618806.00 ( 31.92%)    500131.00 (  6.62%)    491700.00 (  4.82%)
TPut   12    447849.00 (  0.00%)    376989.00 (-15.82%)    586321.00 ( 30.92%)    603746.00 ( 34.81%)    472478.00 (  5.50%)    479727.00 (  7.12%)
TPut   13    446382.00 (  0.00%)    426154.00 ( -4.53%)    537851.00 ( 20.49%)    588773.00 ( 31.90%)    465595.00 (  4.30%)    469399.00 (  5.16%)
TPut   14    443524.00 (  0.00%)    414196.00 ( -6.61%)    550293.00 ( 24.07%)    578336.00 ( 30.40%)    459738.00 (  3.66%)    463353.00 (  4.47%)
TPut   15    437350.00 (  0.00%)    406916.00 ( -6.96%)    558890.00 ( 27.79%)    573332.00 ( 31.09%)    462095.00 (  5.66%)    460605.00 (  5.32%)
TPut   16    428127.00 (  0.00%)    407935.00 ( -4.72%)    484887.00 ( 13.26%)    567631.00 ( 32.58%)    454664.00 (  6.20%)    454694.00 (  6.21%)
TPut   17    421965.00 (  0.00%)    400823.00 ( -5.01%)    517719.00 ( 22.69%)    562764.00 ( 33.37%)    451006.00 (  6.88%)    452885.00 (  7.33%)
TPut   18    404411.00 (  0.00%)    386542.00 ( -4.42%)    460346.00 ( 13.83%)    551137.00 ( 36.28%)    450330.00 ( 11.35%)    446134.00 ( 10.32%)
TPut   19    415629.00 (  0.00%)    378313.00 ( -8.98%)    505571.00 ( 21.64%)    542877.00 ( 30.62%)    440609.00 (  6.01%)    455837.00 (  9.67%)
TPut   20    401984.00 (  0.00%)    370735.00 ( -7.77%)    493275.00 ( 22.71%)    541057.00 ( 34.60%)    435446.00 (  8.32%)    454984.00 ( 13.18%)
TPut   21    398280.00 (  0.00%)    371823.00 ( -6.64%)    445172.00 ( 11.77%)    535564.00 ( 34.47%)    440376.00 ( 10.57%)    437850.00 (  9.94%)
TPut   22    394447.00 (  0.00%)    359127.00 ( -8.95%)    472874.00 ( 19.88%)    529599.00 ( 34.26%)    437291.00 ( 10.86%)    442011.00 ( 12.06%)
TPut   23    392692.00 (  0.00%)    355384.00 ( -9.50%)    472840.00 ( 20.41%)    522904.00 ( 33.16%)    424185.00 (  8.02%)    429217.00 (  9.30%)
TPut   24    368299.00 (  0.00%)    354324.00 ( -3.79%)    447860.00 ( 21.60%)    510209.00 ( 38.53%)    409448.00 ( 11.17%)    428477.00 ( 16.34%)

Latest numacore has improved dramatically here. In v17, it was regressing
heavily across the board. The latest figures show that it regresses heavily
for small numbers of warehouses and shows very large performance gains
for larger numbers of warehouses. This problem with regressions for smaller
numbers of warehouses has been reported repeatedly and it has been pointed out
multiple times that specjbb by default ignores these results which can be
very misleading.

autonuma shows large gains even for small numbers of warehouses and larger
performnace gains than numacore does. This is without the TLB optimisations.

balancenuma is not great, but it's better than mainline.


SPECJBB PEAKS
                                   3.7.0-rc7                  3.7.0-rc6                  3.7.0-rc8                  3.7.0-rc7                  3.7.0-rc7                  3.7.0-rc7
                                  stats-v8r6          numacore-20121130           numafix-20121209         autonuma-v28fastr4           balancenuma-v9r2          balancenuma-v10r3
 Expctd Warehouse            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)
 Expctd Peak Bops        447849.00 (  0.00%)        376989.00 (-15.82%)        586321.00 ( 30.92%)        603746.00 ( 34.81%)        472478.00 (  5.50%)        479727.00 (  7.12%)
 Actual Warehouse             7.00 (  0.00%)            13.00 ( 85.71%)            12.00 ( 71.43%)             9.00 ( 28.57%)             8.00 ( 14.29%)             7.00 (  0.00%)
 Actual Peak Bops        552073.00 (  0.00%)        426154.00 (-22.81%)        586321.00 (  6.20%)        652032.00 ( 18.11%)        554218.00 (  0.39%)        557595.00 (  1.00%)
 SpecJBB Bops            415458.00 (  0.00%)        385328.00 ( -7.25%)        502608.00 ( 20.98%)        554456.00 ( 33.46%)        446405.00 (  7.45%)        451937.00 (  8.78%)
 SpecJBB Bops/JVM        103865.00 (  0.00%)         96332.00 ( -7.25%)        125652.00 ( 20.98%)        138614.00 ( 33.46%)        111601.00 (  7.45%)        112984.00 (  8.78%)

numacore is showing good performance gains both at the peak and in the
specjbb score. Note that the specjbb score ignored the regressions for
smaller numbers of warehouses.

autonuma was still better.

balancenuma was all right, better than mainline.

MMTests Statistics: duration
           3.7.0-rc7   3.7.0-rc6   3.7.0-rc8   3.7.0-rc7   3.7.0-rc7   3.7.0-rc7
          stats-v8r6numacore-20121130numafix-20121209autonuma-v28fastr4balancenuma-v9r2balancenuma-v10r3
User       177832.71   148340.09   165197.46   177337.90   176411.93   176466.36
System         89.07    28052.02    12438.18      287.31     1464.93     1467.74
Elapsed      4035.81     4041.26     4038.34     4028.05     4041.53     4031.74

numacores system CPU usage is incredibly high -- over 8 times higher
than balancenumas.

balancenumas system CPU usage also sucks to be honest.

MMTests Statistics: vmstat
                             3.7.0-rc7   3.7.0-rc6   3.7.0-rc8   3.7.0-rc7   3.7.0-rc7   3.7.0-rc7
                            stats-v8r6numacore-20121130numafix-20121209autonuma-v28fastr4balancenuma-v9r2balancenuma-v10r3
Page Ins                         37380       66040       34576       36416       35452       34948
Page Outs                        29224       46900       31972       29584       29612       30892
Swap Ins                             0           0           0           0           0           0
Swap Outs                            0           0           0           0           0           0
Direct pages scanned                 0           0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0           0
Page writes file                     0           0           0           0           0           0
Page writes anon                     0           0           0           0           0           0
Page reclaim immediate               0           0           0           0           0           0
Page rescued immediate               0           0           0           0           0           0
Slabs scanned                        0           0           0           0           0           0
Direct inode steals                  0           0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0           0
THP fault alloc                      2           3           1           2           2           2
THP collapse alloc                   0           0           0           0           0           0
THP splits                           0           0           0           0           0           0
THP fault fallback                   0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0
Page migrate success                 0           0   193988041           0    37611432    39796961
Page migrate failure                 0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0
Compaction cost                      0           0      201359           0       39040       41309
NUMA PTE updates                     0           0   904384590           0   288455303   286931926
NUMA hint faults                     0           0           0           0   270103189   269176121
NUMA hint local faults               0           0           0           0    70822016    70400386
NUMA pages migrated                  0           0   193988041           0    37611432    39796961
AutoNUMA cost                        0           0       10016           0     1353249     1348645

According to this, numacore never had a NUMA fault. This is completely broken
obviously and it's because PTE NUMA hinting faults are not accounted for
by numacore because that path does not call numa_migration_target(). The
consequences are not that great, it just means that the notional "AutoNUMA
cost" is meaningless for numacore.

What is interesting is numacores migration rate -- 187MB/sec on average. This
is over quadruple balancenumas migration rate of 38MB/sec on average.

SpecJBB, Single JVM, THP is enabled
===================================

As with the Multiple JVM test with THP enabled, numacore crashes. This
time the message is

Timing Measurement began Sun Dec 09 17:12:53 GMT 2012 for 0.5 minutes
Exception in thread "Thread-1040" java.lang.NullPointerException
        at java.util.TreeMap.access$100(Unknown Source)
        at java.util.TreeMap$PrivateEntryIterator.nextEntry(Unknown Source)
        at java.util.TreeMap$ValueIterator.next(Unknown Source)
        at spec.jbb.DeliveryTransaction.preprocess(Unknown Source)
        at spec.jbb.DeliveryHandler.handleDelivery(Unknown Source)
        at spec.jbb.DeliveryTransaction.process(Unknown Source)
        at spec.jbb.TransactionManager.runTxn(Unknown Source)
        at spec.jbb.TransactionManager.goManual(Unknown Source)
        at spec.jbb.TransactionManager.go(Unknown Source)
        at spec.jbb.JBBmain.run(Unknown Source)
        at java.lang.Thread.run(Unknown Source)
Timing Measurement ended Sun Dec 09 17:13:23 GMT 2012

Here are the rest of the resutls

                    3.7.0-rc7             3.7.0-rc6             3.7.0-rc7             3.7.0-rc7             3.7.0-rc7
                   stats-v8r6     numacore-20121130    autonuma-v28fastr4      balancenuma-v9r2     balancenuma-v10r3
TPut 1      25550.00 (  0.00%)     25491.00 ( -0.23%)     24233.00 ( -5.15%)     24913.00 ( -2.49%)     26480.00 (  3.64%)
TPut 2      55943.00 (  0.00%)     51630.00 ( -7.71%)     55312.00 ( -1.13%)     55042.00 ( -1.61%)     56920.00 (  1.75%)
TPut 3      87707.00 (  0.00%)     74497.00 (-15.06%)     88569.00 (  0.98%)     86135.00 ( -1.79%)     88608.00 (  1.03%)
TPut 4     117911.00 (  0.00%)     98435.00 (-16.52%)    118561.00 (  0.55%)    117486.00 ( -0.36%)    117953.00 (  0.04%)
TPut 5     143285.00 (  0.00%)    133964.00 ( -6.51%)    145703.00 (  1.69%)    142821.00 ( -0.32%)    144926.00 (  1.15%)
TPut 6     171208.00 (  0.00%)    152795.00 (-10.75%)    171006.00 ( -0.12%)    170635.00 ( -0.33%)    169394.00 ( -1.06%)
TPut 7     195635.00 (  0.00%)    162517.00 (-16.93%)    198699.00 (  1.57%)    196108.00 (  0.24%)    196491.00 (  0.44%)
TPut 8     222655.00 (  0.00%)    168679.00 (-24.24%)    224903.00 (  1.01%)    223494.00 (  0.38%)    225978.00 (  1.49%)
TPut 9     244787.00 (  0.00%)    193394.00 (-20.99%)    248313.00 (  1.44%)    251858.00 (  2.89%)    251569.00 (  2.77%)
TPut 10    271565.00 (  0.00%)    237987.00 (-12.36%)    272148.00 (  0.21%)    275869.00 (  1.58%)    279049.00 (  2.76%)
TPut 11    298270.00 (  0.00%)    207908.00 (-30.30%)    303749.00 (  1.84%)    301763.00 (  1.17%)    301399.00 (  1.05%)
TPut 12    320867.00 (  0.00%)    257937.00 (-19.61%)    327808.00 (  2.16%)    329681.00 (  2.75%)    330506.00 (  3.00%)
TPut 13    343514.00 (  0.00%)    248474.00 (-27.67%)    349080.00 (  1.62%)    340606.00 ( -0.85%)    350817.00 (  2.13%)
TPut 14    365321.00 (  0.00%)    298876.00 (-18.19%)    370026.00 (  1.29%)    379939.00 (  4.00%)    361752.00 ( -0.98%)
TPut 15    377071.00 (  0.00%)    296562.00 (-21.35%)    329847.00 (-12.52%)    395421.00 (  4.87%)    396091.00 (  5.04%)
TPut 16    404979.00 (  0.00%)    287964.00 (-28.89%)    411066.00 (  1.50%)    420551.00 (  3.85%)    411673.00 (  1.65%)
TPut 17    420593.00 (  0.00%)    342590.00 (-18.55%)    428242.00 (  1.82%)    437461.00 (  4.01%)    428270.00 (  1.83%)
TPut 18    440178.00 (  0.00%)    377508.00 (-14.24%)    440392.00 (  0.05%)    455014.00 (  3.37%)    447671.00 (  1.70%)
TPut 19    448876.00 (  0.00%)    397727.00 (-11.39%)    462036.00 (  2.93%)    479223.00 (  6.76%)    461881.00 (  2.90%)
TPut 20    460513.00 (  0.00%)    411831.00 (-10.57%)    476437.00 (  3.46%)    493176.00 (  7.09%)    474824.00 (  3.11%)
TPut 21    474161.00 (  0.00%)    442153.00 ( -6.75%)    487513.00 (  2.82%)    505246.00 (  6.56%)    468938.00 ( -1.10%)
TPut 22    474493.00 (  0.00%)    429921.00 ( -9.39%)    487920.00 (  2.83%)    527360.00 ( 11.14%)    475208.00 (  0.15%)
TPut 23    489559.00 (  0.00%)    460354.00 ( -5.97%)    508298.00 (  3.83%)    534820.00 (  9.25%)    490743.00 (  0.24%)
TPut 24    495378.00 (  0.00%)    486826.00 ( -1.73%)    514403.00 (  3.84%)    545294.00 ( 10.08%)    493974.00 ( -0.28%)
TPut 25    491795.00 (  0.00%)    520474.00 (  5.83%)    507373.00 (  3.17%)    543526.00 ( 10.52%)    489850.00 ( -0.40%)
TPut 26    490038.00 (  0.00%)    465587.00 ( -4.99%)    376322.00 (-23.21%)    545175.00 ( 11.25%)    491352.00 (  0.27%)
TPut 27    491233.00 (  0.00%)    469764.00 ( -4.37%)    366225.00 (-25.45%)    536927.00 (  9.30%)    489611.00 ( -0.33%)
TPut 28    489058.00 (  0.00%)    489561.00 (  0.10%)    414027.00 (-15.34%)    543127.00 ( 11.06%)    473835.00 ( -3.11%)
TPut 29    471539.00 (  0.00%)    492496.00 (  4.44%)    400529.00 (-15.06%)    541615.00 ( 14.86%)    486009.00 (  3.07%)
TPut 30    480343.00 (  0.00%)    488349.00 (  1.67%)    405612.00 (-15.56%)    542904.00 ( 13.02%)    478384.00 ( -0.41%)
TPut 31    478109.00 (  0.00%)    460043.00 ( -3.78%)    401471.00 (-16.03%)    529079.00 ( 10.66%)    466457.00 ( -2.44%)
TPut 32    475736.00 (  0.00%)    472007.00 ( -0.78%)    401075.00 (-15.69%)    532423.00 ( 11.92%)    467866.00 ( -1.65%)
TPut 33    470758.00 (  0.00%)    474348.00 (  0.76%)    399592.00 (-15.12%)    518811.00 ( 10.21%)    464764.00 ( -1.27%)
TPut 34    467304.00 (  0.00%)    475878.00 (  1.83%)    394589.00 (-15.56%)    518334.00 ( 10.92%)    446719.00 ( -4.41%)
TPut 35    466391.00 (  0.00%)    487411.00 (  4.51%)    382799.00 (-17.92%)    513591.00 ( 10.12%)    447071.00 ( -4.14%)
TPut 36    452722.00 (  0.00%)    478050.00 (  5.59%)    381120.00 (-15.82%)    503801.00 ( 11.28%)    452243.00 ( -0.11%)
TPut 37    447878.00 (  0.00%)    478467.00 (  6.83%)    382803.00 (-14.53%)    494555.00 ( 10.42%)    442751.00 ( -1.14%)
TPut 38    447907.00 (  0.00%)    455542.00 (  1.70%)    341693.00 (-23.71%)    482758.00 (  7.78%)    444023.00 ( -0.87%)
TPut 39    428322.00 (  0.00%)    367921.00 (-14.10%)    404210.00 ( -5.63%)    464550.00 (  8.46%)    440482.00 (  2.84%)
TPut 40    429157.00 (  0.00%)    394277.00 ( -8.13%)    378554.00 (-11.79%)    467767.00 (  9.00%)    411807.00 ( -4.04%)
TPut 41    424339.00 (  0.00%)    415413.00 ( -2.10%)    399220.00 ( -5.92%)    457669.00 (  7.85%)    428273.00 (  0.93%)
TPut 42    397440.00 (  0.00%)    421027.00 (  5.93%)    372161.00 ( -6.36%)    458156.00 ( 15.28%)    422535.00 (  6.31%)
TPut 43    405391.00 (  0.00%)    433900.00 (  7.03%)    383936.00 ( -5.29%)    438929.00 (  8.27%)    410196.00 (  1.19%)
TPut 44    400692.00 (  0.00%)    427504.00 (  6.69%)    374757.00 ( -6.47%)    423538.00 (  5.70%)    399471.00 ( -0.30%)
TPut 45    399623.00 (  0.00%)    372622.00 ( -6.76%)    379797.00 ( -4.96%)    407255.00 (  1.91%)    374068.00 ( -6.39%)
TPut 46    391920.00 (  0.00%)    351205.00 (-10.39%)    368042.00 ( -6.09%)    411353.00 (  4.96%)    384363.00 ( -1.93%)
TPut 47    378199.00 (  0.00%)    358150.00 ( -5.30%)    368744.00 ( -2.50%)    408739.00 (  8.08%)    385670.00 (  1.98%)
TPut 48    379346.00 (  0.00%)    387287.00 (  2.09%)    373581.00 ( -1.52%)    423791.00 ( 11.72%)    380665.00 (  0.35%)
TPut 49    373614.00 (  0.00%)    395793.00 (  5.94%)    372621.00 ( -0.27%)    423024.00 ( 13.22%)    377985.00 (  1.17%)
TPut 50    372494.00 (  0.00%)    366488.00 ( -1.61%)    388778.00 (  4.37%)    410647.00 ( 10.24%)    378831.00 (  1.70%)
TPut 51    382195.00 (  0.00%)    381771.00 ( -0.11%)    387687.00 (  1.44%)    423249.00 ( 10.74%)    402233.00 (  5.24%)
TPut 52    369118.00 (  0.00%)    429441.00 ( 16.34%)    390226.00 (  5.72%)    410023.00 ( 11.08%)    396558.00 (  7.43%)
TPut 53    366453.00 (  0.00%)    445744.00 ( 21.64%)    399257.00 (  8.95%)    405937.00 ( 10.77%)    383916.00 (  4.77%)
TPut 54    366571.00 (  0.00%)    375762.00 (  2.51%)    395098.00 (  7.78%)    402220.00 (  9.72%)    395417.00 (  7.87%)
TPut 55    367580.00 (  0.00%)    336113.00 ( -8.56%)    400550.00 (  8.97%)    420978.00 ( 14.53%)    398098.00 (  8.30%)
TPut 56    367056.00 (  0.00%)    375635.00 (  2.34%)    385743.00 (  5.09%)    412685.00 ( 12.43%)    384029.00 (  4.62%)
TPut 57    359163.00 (  0.00%)    354001.00 ( -1.44%)    389827.00 (  8.54%)    394688.00 (  9.89%)    381032.00 (  6.09%)
TPut 58    360552.00 (  0.00%)    353312.00 ( -2.01%)    394099.00 (  9.30%)    388655.00 (  7.79%)    378132.00 (  4.88%)
TPut 59    354967.00 (  0.00%)    368534.00 (  3.82%)    390746.00 ( 10.08%)    399086.00 ( 12.43%)    387101.00 (  9.05%)
TPut 60    362976.00 (  0.00%)    388472.00 (  7.02%)    383073.00 (  5.54%)    399713.00 ( 10.12%)    390635.00 (  7.62%)
TPut 61    368072.00 (  0.00%)    399476.00 (  8.53%)    380807.00 (  3.46%)    372060.00 (  1.08%)    383187.00 (  4.11%)
TPut 62    356938.00 (  0.00%)    385648.00 (  8.04%)    387736.00 (  8.63%)    377183.00 (  5.67%)    378484.00 (  6.04%)
TPut 63    357491.00 (  0.00%)    404325.00 ( 13.10%)    396672.00 ( 10.96%)    384221.00 (  7.48%)    378907.00 (  5.99%)
TPut 64    357322.00 (  0.00%)    389552.00 (  9.02%)    386826.00 (  8.26%)    378601.00 (  5.96%)    369852.00 (  3.51%)
TPut 65    341262.00 (  0.00%)    394964.00 ( 15.74%)    380271.00 ( 11.43%)    382896.00 ( 12.20%)    382897.00 ( 12.20%)
TPut 66    357807.00 (  0.00%)    384846.00 (  7.56%)    362723.00 (  1.37%)    361530.00 (  1.04%)    380023.00 (  6.21%)
TPut 67    345092.00 (  0.00%)    376842.00 (  9.20%)    364193.00 (  5.54%)    374449.00 (  8.51%)    373877.00 (  8.34%)
TPut 68    350334.00 (  0.00%)    358330.00 (  2.28%)    359368.00 (  2.58%)    384920.00 (  9.87%)    381888.00 (  9.01%)
TPut 69    348372.00 (  0.00%)    356188.00 (  2.24%)    364449.00 (  4.61%)    395611.00 ( 13.56%)    375892.00 (  7.90%)
TPut 70    335077.00 (  0.00%)    359313.00 (  7.23%)    356418.00 (  6.37%)    375448.00 ( 12.05%)    372358.00 ( 11.13%)
TPut 71    341197.00 (  0.00%)    364168.00 (  6.73%)    343847.00 (  0.78%)    376113.00 ( 10.23%)    384292.00 ( 12.63%)
TPut 72    345032.00 (  0.00%)    356934.00 (  3.45%)    345007.00 ( -0.01%)    375313.00 (  8.78%)    381504.00 ( 10.57%)

numacore v17 was doing reasonably well but we knew that already.

autonuma does not do great on this test.

balancenuma does all right. The scalability patches actually hurt in this case
but it's likely down to varability in the decisions made by the scheduler as much
as anything else.

SPECJBB PEAKS
                                   3.7.0-rc7                  3.7.0-rc6                  3.7.0-rc7                  3.7.0-rc7                  3.7.0-rc7
                                  stats-v8r6          numacore-20121130         autonuma-v28fastr4           balancenuma-v9r2          balancenuma-v10r3
 Expctd Warehouse            48.00 (  0.00%)            48.00 (  0.00%)            48.00 (  0.00%)            48.00 (  0.00%)            48.00 (  0.00%)
 Expctd Peak Bops        379346.00 (  0.00%)        387287.00 (  2.09%)        373581.00 ( -1.52%)        423791.00 ( 11.72%)        380665.00 (  0.35%)
 Actual Warehouse            24.00 (  0.00%)            25.00 (  4.17%)            24.00 (  0.00%)            24.00 (  0.00%)            24.00 (  0.00%)
 Actual Peak Bops        495378.00 (  0.00%)        520474.00 (  5.07%)        514403.00 (  3.84%)        545294.00 ( 10.08%)        493974.00 ( -0.28%)
 SpecJBB Bops            183389.00 (  0.00%)        193652.00 (  5.60%)        193461.00 (  5.49%)        201083.00 (  9.65%)        195465.00 (  6.58%)
 SpecJBB Bops/JVM        183389.00 (  0.00%)        193652.00 (  5.60%)        193461.00 (  5.49%)        201083.00 (  9.65%)        195465.00 (  6.58%)

Balancenuma does all right on its specjbb score but the peak score with
the migration scalability patches applied is hurt. At least it's still
comparable to mainline.

MMTests Statistics: duration
           3.7.0-rc7   3.7.0-rc6   3.7.0-rc8   3.7.0-rc7   3.7.0-rc7   3.7.0-rc7
          stats-v8r6numacore-20121130numafix-20121209autonuma-v28fastr4balancenuma-v9r2balancenuma-v10r3
User       316340.52   311420.23    31308.52   314589.64   316061.23   315584.37
System        102.08     3067.27      803.23      352.70      428.76      450.71
Elapsed      7433.22     7436.63     1398.05     7434.74     7432.60     7435.03

Usual comments about system CPU usage. You actually see latest numacore
figures here because they are based on what happened up until the crash.

MMTests Statistics: vmstat
                             3.7.0-rc7   3.7.0-rc6   3.7.0-rc8   3.7.0-rc7   3.7.0-rc7   3.7.0-rc7
                            stats-v8r6numacore-20121130numafix-20121209autonuma-v28fastr4balancenuma-v9r2balancenuma-v10r3
Page Ins                         66212       36180       31560       36152       36188       63852
Page Outs                        31248       35544       12016       28388       28024       42360
Swap Ins                             0           0           0           0           0           0
Swap Outs                            0           0           0           0           0           0
Direct pages scanned                 0           0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0           0
Page writes file                     0           0           0           0           0           0
Page writes anon                     0           0           0           0           0           0
Page reclaim immediate               0           0           0           0           0           0
Page rescued immediate               0           0           0           0           0           0
Slabs scanned                        0           0           0           0           0           0
Direct inode steals                  0           0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0           0
THP fault alloc                  48874       45657       34986       48296       48697       47056
THP collapse alloc                  51           2           9         157          53          69
THP splits                          70          37          28          83          78          56
THP fault fallback                   0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0
Page migrate success                 0           0   110442307           0    45908125    46995604
Page migrate failure                 0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0
Compaction cost                      0           0      114639           0       47652       48781
NUMA PTE updates                     0           0   391813174           0   351907231   361308027
NUMA hint faults                     0           0      796717           0     2010327     1867697
NUMA hint local faults               0           0      261885           0      677602      572742
NUMA pages migrated                  0           0   110442307           0    45908125    46995604
AutoNUMA cost                        0           0        8824           0       13387       12760

THP was certainly enabled.

numacores migration rate is extremely high until it crashed -- 308MB/sec
as opposed to balancenumas 24MB/sec on average.

SpecJBB, Single JVM, THP is disabled
====================================

                    3.7.0-rc7             3.7.0-rc6             3.7.0-rc8             3.7.0-rc7             3.7.0-rc7             3.7.0-rc7
                   stats-v8r6     numacore-20121130      numafix-20121209    autonuma-v28fastr4      balancenuma-v9r2     balancenuma-v10r3
TPut 1      19861.00 (  0.00%)     18255.00 ( -8.09%)     20169.00 (  1.55%)     19636.00 ( -1.13%)     19838.00 ( -0.12%)     20650.00 (  3.97%)
TPut 2      47613.00 (  0.00%)     37136.00 (-22.00%)     45050.00 ( -5.38%)     47153.00 ( -0.97%)     47481.00 ( -0.28%)     48199.00 (  1.23%)
TPut 3      72438.00 (  0.00%)     55692.00 (-23.12%)     64075.00 (-11.55%)     69394.00 ( -4.20%)     72029.00 ( -0.56%)     72932.00 (  0.68%)
TPut 4      98455.00 (  0.00%)     81301.00 (-17.42%)     93595.00 ( -4.94%)     98577.00 (  0.12%)     98437.00 ( -0.02%)     99748.00 (  1.31%)
TPut 5     120831.00 (  0.00%)     89067.00 (-26.29%)    115796.00 ( -4.17%)    120805.00 ( -0.02%)    117218.00 ( -2.99%)    121254.00 (  0.35%)
TPut 6     140013.00 (  0.00%)    108349.00 (-22.62%)    116704.00 (-16.65%)    125079.00 (-10.67%)    139878.00 ( -0.10%)    145360.00 (  3.82%)
TPut 7     163553.00 (  0.00%)    116192.00 (-28.96%)    118711.00 (-27.42%)    164368.00 (  0.50%)    167133.00 (  2.19%)    169539.00 (  3.66%)
TPut 8     190148.00 (  0.00%)    125955.00 (-33.76%)    118079.00 (-37.90%)    188906.00 ( -0.65%)    183058.00 ( -3.73%)    188936.00 ( -0.64%)
TPut 9     211343.00 (  0.00%)    144068.00 (-31.83%)    170067.00 (-19.53%)    206645.00 ( -2.22%)    205699.00 ( -2.67%)    217322.00 (  2.83%)
TPut 10    233190.00 (  0.00%)    148098.00 (-36.49%)    133365.00 (-42.81%)    234533.00 (  0.58%)    233632.00 (  0.19%)    227292.00 ( -2.53%)
TPut 11    253333.00 (  0.00%)    146043.00 (-42.35%)    108866.00 (-57.03%)    254167.00 (  0.33%)    251938.00 ( -0.55%)    259924.00 (  2.60%)
TPut 12    270661.00 (  0.00%)    131739.00 (-51.33%)    146170.00 (-46.00%)    271490.00 (  0.31%)    271393.00 (  0.27%)    272536.00 (  0.69%)
TPut 13    299807.00 (  0.00%)    169396.00 (-43.50%)    134946.00 (-54.99%)    299758.00 ( -0.02%)    270594.00 ( -9.74%)    299110.00 ( -0.23%)
TPut 14    319243.00 (  0.00%)    150705.00 (-52.79%)    145135.00 (-54.54%)    318481.00 ( -0.24%)    318566.00 ( -0.21%)    325133.00 (  1.84%)
TPut 15    339054.00 (  0.00%)    116872.00 (-65.53%)    127277.00 (-62.46%)    331534.00 ( -2.22%)    344672.00 (  1.66%)    318119.00 ( -6.17%)
TPut 16    354315.00 (  0.00%)    124346.00 (-64.91%)     86657.00 (-75.54%)    352600.00 ( -0.48%)    316761.00 (-10.60%)    364648.00 (  2.92%)
TPut 17    371306.00 (  0.00%)    118493.00 (-68.09%)     93297.00 (-74.87%)    368260.00 ( -0.82%)    328888.00 (-11.42%)    371088.00 ( -0.06%)
TPut 18    386361.00 (  0.00%)    138571.00 (-64.13%)    208447.00 (-46.05%)    374358.00 ( -3.11%)    356148.00 ( -7.82%)    399913.00 (  3.51%)
TPut 19    401827.00 (  0.00%)    118855.00 (-70.42%)    155803.00 (-61.23%)    399476.00 ( -0.59%)    393918.00 ( -1.97%)    405771.00 (  0.98%)
TPut 20    411130.00 (  0.00%)    144024.00 (-64.97%)    116524.00 (-71.66%)    407799.00 ( -0.81%)    377706.00 ( -8.13%)    406038.00 ( -1.24%)
TPut 21    425352.00 (  0.00%)    154264.00 (-63.73%)    144766.00 (-65.97%)    429226.00 (  0.91%)    431677.00 (  1.49%)    431583.00 (  1.46%)
TPut 22    438150.00 (  0.00%)    153892.00 (-64.88%)    222211.00 (-49.28%)    385827.00 (-11.94%)    440379.00 (  0.51%)    438861.00 (  0.16%)
TPut 23    438425.00 (  0.00%)    146506.00 (-66.58%)    213367.00 (-51.33%)    433963.00 ( -1.02%)    361427.00 (-17.56%)    445293.00 (  1.57%)
TPut 24    461598.00 (  0.00%)    138869.00 (-69.92%)    189745.00 (-58.89%)    439691.00 ( -4.75%)    471567.00 (  2.16%)    488259.00 (  5.78%)
TPut 25    459475.00 (  0.00%)    141698.00 (-69.16%)    105196.00 (-77.11%)    431373.00 ( -6.12%)    487921.00 (  6.19%)    447353.00 ( -2.64%)
TPut 26    452651.00 (  0.00%)    142844.00 (-68.44%)    125573.00 (-72.26%)    447517.00 ( -1.13%)    425336.00 ( -6.03%)    469793.00 (  3.79%)
TPut 27    450436.00 (  0.00%)    140870.00 (-68.73%)     68802.00 (-84.73%)    430805.00 ( -4.36%)    456114.00 (  1.26%)    461172.00 (  2.38%)
TPut 28    459770.00 (  0.00%)    143078.00 (-68.88%)    144373.00 (-68.60%)    432260.00 ( -5.98%)    478317.00 (  4.03%)    452144.00 ( -1.66%)
TPut 29    450347.00 (  0.00%)    142076.00 (-68.45%)    221760.00 (-50.76%)    440423.00 ( -2.20%)    388175.00 (-13.81%)    473273.00 (  5.09%)
TPut 30    449252.00 (  0.00%)    146900.00 (-67.30%)    139971.00 (-68.84%)    435082.00 ( -3.15%)    440795.00 ( -1.88%)    435189.00 ( -3.13%)
TPut 31    446802.00 (  0.00%)    148008.00 (-66.87%)    195143.00 (-56.32%)    418684.00 ( -6.29%)    417343.00 ( -6.59%)    437562.00 ( -2.07%)
TPut 32    439701.00 (  0.00%)    149591.00 (-65.98%)    159107.00 (-63.81%)    421866.00 ( -4.06%)    438719.00 ( -0.22%)    469763.00 (  6.84%)
TPut 33    434477.00 (  0.00%)    142801.00 (-67.13%)    110758.00 (-74.51%)    420631.00 ( -3.19%)    454673.00 (  4.65%)    451224.00 (  3.85%)
TPut 34    423014.00 (  0.00%)    152308.00 (-63.99%)    111701.00 (-73.59%)    415202.00 ( -1.85%)    415194.00 ( -1.85%)    446735.00 (  5.61%)
TPut 35    429012.00 (  0.00%)    154116.00 (-64.08%)    118968.00 (-72.27%)    402395.00 ( -6.20%)    425151.00 ( -0.90%)    434230.00 (  1.22%)
TPut 36    421097.00 (  0.00%)    157571.00 (-62.58%)    174626.00 (-58.53%)    404770.00 ( -3.88%)    430480.00 (  2.23%)    425324.00 (  1.00%)
TPut 37    414815.00 (  0.00%)    150771.00 (-63.65%)    238764.00 (-42.44%)    388842.00 ( -6.26%)    393351.00 ( -5.17%)    405824.00 ( -2.17%)
TPut 38    412361.00 (  0.00%)    157070.00 (-61.91%)    173206.00 (-58.00%)    398947.00 ( -3.25%)    401555.00 ( -2.62%)    432074.00 (  4.78%)
TPut 39    402234.00 (  0.00%)    161487.00 (-59.85%)    119790.00 (-70.22%)    382645.00 ( -4.87%)    423106.00 (  5.19%)    401091.00 ( -0.28%)
TPut 40    380278.00 (  0.00%)    165947.00 (-56.36%)    309375.00 (-18.65%)    394039.00 (  3.62%)    405371.00 (  6.60%)    410739.00 (  8.01%)
TPut 41    393204.00 (  0.00%)    160540.00 (-59.17%)    146153.00 (-62.83%)    385605.00 ( -1.93%)    403383.00 (  2.59%)    372466.00 ( -5.27%)
TPut 42    380622.00 (  0.00%)    151946.00 (-60.08%)    269523.00 (-29.19%)    374843.00 ( -1.52%)    380797.00 (  0.05%)    396227.00 (  4.10%)
TPut 43    371566.00 (  0.00%)    162369.00 (-56.30%)    344584.00 ( -7.26%)    347951.00 ( -6.36%)    386765.00 (  4.09%)    345633.00 ( -6.98%)
TPut 44    365538.00 (  0.00%)    161127.00 (-55.92%)    147195.00 (-59.73%)    355070.00 ( -2.86%)    344701.00 ( -5.70%)    391276.00 (  7.04%)
TPut 45    359305.00 (  0.00%)    159062.00 (-55.73%)    102716.00 (-71.41%)    350973.00 ( -2.32%)    370666.00 (  3.16%)    331191.00 ( -7.82%)
TPut 46    343160.00 (  0.00%)    163889.00 (-52.24%)    309203.00 ( -9.90%)    347960.00 (  1.40%)    380147.00 ( 10.78%)    323176.00 ( -5.82%)
TPut 47    346983.00 (  0.00%)    168666.00 (-51.39%)    330345.00 ( -4.80%)    313612.00 ( -9.62%)    362189.00 (  4.38%)    343154.00 ( -1.10%)
TPut 48    338143.00 (  0.00%)    153448.00 (-54.62%)    291944.00 (-13.66%)    341809.00 (  1.08%)    365342.00 (  8.04%)    354348.00 (  4.79%)
TPut 49    333941.00 (  0.00%)    142784.00 (-57.24%)    252850.00 (-24.28%)    336174.00 (  0.67%)    371700.00 ( 11.31%)    353148.00 (  5.75%)
TPut 50    334001.00 (  0.00%)    135713.00 (-59.37%)    252350.00 (-24.45%)    322489.00 ( -3.45%)    367963.00 ( 10.17%)    355823.00 (  6.53%)
TPut 51    338310.00 (  0.00%)    133402.00 (-60.57%)    232361.00 (-31.32%)    354805.00 (  4.88%)    372592.00 ( 10.13%)    351194.00 (  3.81%)
TPut 52    322897.00 (  0.00%)    150293.00 (-53.45%)    193895.00 (-39.95%)    353169.00 (  9.38%)    363024.00 ( 12.43%)    344846.00 (  6.80%)
TPut 53    329801.00 (  0.00%)    160792.00 (-51.25%)    180672.00 (-45.22%)    353588.00 (  7.21%)    365359.00 ( 10.78%)    355499.00 (  7.79%)
TPut 54    336610.00 (  0.00%)    164696.00 (-51.07%)    248332.00 (-26.23%)    361189.00 (  7.30%)    377851.00 ( 12.25%)    363987.00 (  8.13%)
TPut 55    325920.00 (  0.00%)    172380.00 (-47.11%)    271331.00 (-16.75%)    365678.00 ( 12.20%)    375735.00 ( 15.28%)    363697.00 ( 11.59%)
TPut 56    318997.00 (  0.00%)    176071.00 (-44.80%)    155354.00 (-51.30%)    367048.00 ( 15.06%)    380588.00 ( 19.31%)    362614.00 ( 13.67%)
TPut 57    321776.00 (  0.00%)    174531.00 (-45.76%)    279294.00 (-13.20%)    341874.00 (  6.25%)    378996.00 ( 17.78%)    360366.00 ( 11.99%)
TPut 58    308532.00 (  0.00%)    174202.00 (-43.54%)    170351.00 (-44.79%)    348156.00 ( 12.84%)    361623.00 ( 17.21%)    369693.00 ( 19.82%)
TPut 59    318974.00 (  0.00%)    175343.00 (-45.03%)    243463.00 (-23.67%)    358252.00 ( 12.31%)    360457.00 ( 13.01%)    364556.00 ( 14.29%)
TPut 60    325465.00 (  0.00%)    173694.00 (-46.63%)    222867.00 (-31.52%)    360808.00 ( 10.86%)    362745.00 ( 11.45%)    354232.00 (  8.84%)
TPut 61    319151.00 (  0.00%)    172320.00 (-46.01%)    218542.00 (-31.52%)    350597.00 (  9.85%)    371277.00 ( 16.33%)    352478.00 ( 10.44%)
TPut 62    320837.00 (  0.00%)    172312.00 (-46.29%)    251630.00 (-21.57%)    359062.00 ( 11.91%)    361009.00 ( 12.52%)    352930.00 ( 10.00%)
TPut 63    318198.00 (  0.00%)    172297.00 (-45.85%)    172040.00 (-45.93%)    356137.00 ( 11.92%)    347637.00 (  9.25%)    335322.00 (  5.38%)
TPut 64    321438.00 (  0.00%)    171894.00 (-46.52%)    151337.00 (-52.92%)    347376.00 (  8.07%)    346756.00 (  7.88%)    351410.00 (  9.32%)
TPut 65    314482.00 (  0.00%)    169147.00 (-46.21%)    143487.00 (-54.37%)    351726.00 ( 11.84%)    357429.00 ( 13.66%)    351236.00 ( 11.69%)
TPut 66    316802.00 (  0.00%)    170234.00 (-46.26%)    230207.00 (-27.33%)    344548.00 (  8.76%)    362143.00 ( 14.31%)    347058.00 (  9.55%)
TPut 67    312139.00 (  0.00%)    168180.00 (-46.12%)    148468.00 (-52.44%)    329030.00 (  5.41%)    353305.00 ( 13.19%)    345903.00 ( 10.82%)
TPut 68    323918.00 (  0.00%)    168392.00 (-48.01%)    184696.00 (-42.98%)    319985.00 ( -1.21%)    344250.00 (  6.28%)    345703.00 (  6.73%)
TPut 69    307506.00 (  0.00%)    167082.00 (-45.67%)    221855.00 (-27.85%)    340673.00 ( 10.79%)    339346.00 ( 10.35%)    336071.00 (  9.29%)
TPut 70    306799.00 (  0.00%)    165764.00 (-45.97%)    246518.00 (-19.65%)    331678.00 (  8.11%)    349583.00 ( 13.95%)    341944.00 ( 11.46%)
TPut 71    304232.00 (  0.00%)    165289.00 (-45.67%)    225582.00 (-25.85%)    319824.00 (  5.13%)    335238.00 ( 10.19%)    343396.00 ( 12.87%)
TPut 72    301619.00 (  0.00%)    163909.00 (-45.66%)    154552.00 (-48.76%)    326875.00 (  8.37%)    345999.00 ( 14.71%)    343949.00 ( 14.03%)

Latest numacore is regressing really badly here.

autonuma is all right.

balancenuma is all right. Migration scalability patches actually seem to
hurt a little.

SPECJBB PEAKS
                                   3.7.0-rc7                  3.7.0-rc6                  3.7.0-rc8                  3.7.0-rc7                  3.7.0-rc7                  3.7.0-rc7
                                  stats-v8r6          numacore-20121130           numafix-20121209         autonuma-v28fastr4           balancenuma-v9r2          balancenuma-v10r3
 Expctd Warehouse            48.00 (  0.00%)            48.00 (  0.00%)            48.00 (  0.00%)            48.00 (  0.00%)            48.00 (  0.00%)            48.00 (  0.00%)
 Expctd Peak Bops        338143.00 (  0.00%)        153448.00 (-54.62%)        291944.00 (-13.66%)        341809.00 (  1.08%)        365342.00 (  8.04%)        354348.00 (  4.79%)
 Actual Warehouse            24.00 (  0.00%)            56.00 (133.33%)            43.00 ( 79.17%)            26.00 (  8.33%)            25.00 (  4.17%)            24.00 (  0.00%)
 Actual Peak Bops        461598.00 (  0.00%)        176071.00 (-61.86%)        344584.00 (-25.35%)        447517.00 ( -3.05%)        487921.00 (  5.70%)        488259.00 (  5.78%)
 SpecJBB Bops            163683.00 (  0.00%)         83963.00 (-48.70%)        109061.00 (-33.37%)        176379.00 (  7.76%)        184040.00 ( 12.44%)        179621.00 (  9.74%)
 SpecJBB Bops/JVM        163683.00 (  0.00%)         83963.00 (-48.70%)        109061.00 (-33.37%)        176379.00 (  7.76%)        184040.00 ( 12.44%)        179621.00 (  9.74%)

numacore regresses 25.35% at the peak and 33.37% on its specjbb score.

balancenuma does all right -- 5.78% gain at the peak, 9.74% on its overall
specjbb score.

MMTests Statistics: duration
           3.7.0-rc7   3.7.0-rc6   3.7.0-rc8   3.7.0-rc7   3.7.0-rc7   3.7.0-rc7
          stats-v8r6numacore-20121130numafix-20121209autonuma-v28fastr4balancenuma-v9r2balancenuma-v10r3
User       316751.91   167098.56   227496.59   307598.67   309109.47   313644.48
System         60.28   122511.08    72477.33     4411.81     1820.70     2654.77
Elapsed      7434.08     7451.36     7476.09     7437.52     7438.28     7438.19

numacores system CPu usage has improved but it's still insane -- 27 times
higher than balancenumas which itself is high. Put another way, numacore
is using over 1000 times more system CPU than the mainline kernel is.

MMTests Statistics: vmstat
                             3.7.0-rc7   3.7.0-rc6   3.7.0-rc8   3.7.0-rc7   3.7.0-rc7   3.7.0-rc7
                            stats-v8r6numacore-20121130numafix-20121209autonuma-v28fastr4balancenuma-v9r2balancenuma-v10r3
Page Ins                         37112       36416       34572       37436       35400       34708
Page Outs                        29252       35664       29788       28120       28504       28292
Swap Ins                             0           0           0           0           0           0
Swap Outs                            0           0           0           0           0           0
Direct pages scanned                 0           0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0           0
Page writes file                     0           0           0           0           0           0
Page writes anon                     0           0           0           0           0           0
Page reclaim immediate               0           0           0           0           0           0
Page rescued immediate               0           0           0           0           0           0
Slabs scanned                        0           0           0           0           0           0
Direct inode steals                  0           0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0           0
THP fault alloc                      3           2           3           2           2           2
THP collapse alloc                   0           0           0           4           0           0
THP splits                           0           0           0           1           0           0
THP fault fallback                   0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0
Page migrate success                 0           0   472734998           0    24675369    36216149
Page migrate failure                 0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0
Compaction cost                      0           0      490698           0       25613       37592
NUMA PTE updates                     0           0  2978374076           0   200854895   256255594
NUMA hint faults                     0           0           0           0   195451244   250219588
NUMA hint local faults               0           0           0           0    50377035    63739483
NUMA pages migrated                  0           0   472734998           0    24675369    36216149
AutoNUMA cost                        0           0       29830           0      979131     1253579

numacore is migrating on average 247MB/sec. balancenuma is migrating
19MB/sec on average.

I ran the other normal benchmarks too. kernbench and aim9 are more or less ok. The impact is on hackbench

HACKBENCH PIPES
                     3.7.0-rc7             3.7.0-rc6             3.7.0-rc8             3.7.0-rc7             3.7.0-rc7             3.7.0-rc7
                    stats-v8r6     numacore-20121130      numafix-20121209    autonuma-v28fastr4      balancenuma-v9r2     balancenuma-v10r3
Procs 1       0.0250 (  0.00%)      0.0260 ( -4.00%)      0.0246 (  1.48%)      0.0261 ( -4.27%)      0.0325 (-30.07%)      0.0353 (-41.14%)
Procs 4       0.0696 (  0.00%)      0.0702 ( -0.84%)      0.0602 ( 13.57%)      0.0707 ( -1.65%)      0.0760 ( -9.20%)      0.0738 ( -5.98%)
Procs 8       0.0836 (  0.00%)      0.0973 (-16.43%)      0.0949 (-13.53%)      0.1030 (-23.21%)      0.0887 ( -6.15%)      0.1031 (-23.36%)
Procs 12      0.0971 (  0.00%)      0.0969 (  0.21%)      0.1447 (-49.00%)      0.1235 (-27.19%)      0.0953 (  1.88%)      0.1394 (-43.56%)
Procs 16      0.1218 (  0.00%)      0.1286 ( -5.52%)      0.2214 (-81.70%)      0.1775 (-45.69%)      0.1105 (  9.33%)      0.2188 (-79.57%)
Procs 20      0.1472 (  0.00%)      0.1508 ( -2.48%)      0.2744 (-86.43%)      0.1584 ( -7.64%)      0.1378 (  6.38%)      0.2567 (-74.37%)
Procs 24      0.1684 (  0.00%)      0.1823 ( -8.20%)      0.3602 (-113.82%)      0.4648 (-175.96%)      0.1623 (  3.68%)      0.3118 (-85.12%)
Procs 28      0.1919 (  0.00%)      0.1969 ( -2.61%)      0.4632 (-141.39%)      0.5287 (-175.57%)      0.1900 (  0.96%)      0.4326 (-125.48%)
Procs 32      0.2256 (  0.00%)      0.2163 (  4.12%)      0.5040 (-123.40%)      0.4607 (-104.23%)      0.2163 (  4.13%)      0.4583 (-103.16%)
Procs 36      0.2228 (  0.00%)      0.2658 (-19.29%)      0.5481 (-145.98%)      0.6190 (-177.83%)      0.2570 (-15.33%)      0.5267 (-136.38%)
Procs 40      0.2811 (  0.00%)      0.2906 ( -3.37%)      0.6223 (-121.36%)      0.2595 (  7.69%)      0.2638 (  6.15%)      0.5941 (-111.35%)

HACKBENCH SOCKETS
                     3.7.0-rc7             3.7.0-rc6             3.7.0-rc8             3.7.0-rc7             3.7.0-rc7             3.7.0-rc7
                    stats-v8r6     numacore-20121130      numafix-20121209    autonuma-v28fastr4      balancenuma-v9r2     balancenuma-v10r3
Procs 1       0.0220 (  0.00%)      0.0220 (  0.00%)      0.0229 ( -4.20%)      0.0283 (-28.66%)      0.0216 (  1.89%)      0.0256 (-16.36%)
Procs 4       0.0456 (  0.00%)      0.0513 (-12.51%)      0.0559 (-22.50%)      0.0820 (-79.73%)      0.0407 ( 10.76%)      0.0627 (-37.46%)
Procs 8       0.0679 (  0.00%)      0.0714 ( -5.20%)      0.1472 (-116.82%)      0.2772 (-308.32%)      0.0697 ( -2.60%)      0.1715 (-152.63%)
Procs 12      0.0940 (  0.00%)      0.0973 ( -3.56%)      0.2259 (-140.32%)      0.1155 (-22.87%)      0.0973 ( -3.55%)      0.2459 (-161.55%)
Procs 16      0.1181 (  0.00%)      0.1263 ( -6.96%)      0.3248 (-174.92%)      0.4467 (-278.19%)      0.1234 ( -4.46%)      0.3231 (-173.55%)
Procs 20      0.1504 (  0.00%)      0.1531 ( -1.83%)      0.4039 (-168.54%)      0.4917 (-226.94%)      0.1534 ( -1.97%)      0.4172 (-177.36%)
Procs 24      0.1757 (  0.00%)      0.1826 ( -3.92%)      0.3965 (-125.60%)      0.5142 (-192.57%)      0.1826 ( -3.89%)      0.4759 (-170.78%)
Procs 28      0.2044 (  0.00%)      0.2166 ( -5.93%)      0.5438 (-165.99%)      0.6600 (-222.85%)      0.2164 ( -5.88%)      0.5455 (-166.83%)
Procs 32      0.2456 (  0.00%)      0.2501 ( -1.86%)      0.6261 (-154.93%)      0.6391 (-160.22%)      0.2449 (  0.27%)      0.6093 (-148.11%)
Procs 36      0.2649 (  0.00%)      0.2747 ( -3.70%)      0.7066 (-166.71%)      0.5775 (-117.97%)      0.2815 ( -6.27%)      0.6840 (-158.19%)
Procs 40      0.3067 (  0.00%)      0.3114 ( -1.56%)      0.7588 (-147.42%)      0.7517 (-145.12%)      0.3081 ( -0.48%)      0.8871 (-189.27%)

Latest numacore, autonuma and balancenuma are all butchering hackbench
performance. Considering that balancenuma started hurting performance with
the migration scalability patches leads me to conclude that they might be
directly or indirectly responsible.

MMTests Statistics: vmstat
                             3.7.0-rc7   3.7.0-rc6   3.7.0-rc8   3.7.0-rc7   3.7.0-rc7   3.7.0-rc7
                            stats-v8r6numacore-20121130numafix-20121209autonuma-v28fastr4balancenuma-v9r2balancenuma-v10r3
Page Ins                             4           4           4           4           4           4
Page Outs                         1540        1636        2568        2264        1548        2484
Swap Ins                             0           0           0           0           0           0
Swap Outs                            0           0           0           0           0           0
Direct pages scanned                 0           0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0           0
Page writes file                     0           0           0           0           0           0
Page writes anon                     0           0           0           0           0           0
Page reclaim immediate               0           0           0           0           0           0
Page rescued immediate               0           0           0           0           0           0
Slabs scanned                        0           0           0           0           0           0
Direct inode steals                  0           0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0           0
THP fault alloc                      5           0           0           0           6           5
THP collapse alloc                   0           0           0           0           0           0
THP splits                           0           0           0           0           0           0
THP fault fallback                   0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0
Page migrate success                 0           0           0           0        1649          49
Page migrate failure                 0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0
Compaction cost                      0           0           0           0           1           0
NUMA PTE updates                     0           0           0           0       21646       22884
NUMA hint faults                     0           0           0           0        1045        2131
NUMA hint local faults               0           0           0           0          40        1218
NUMA pages migrated                  0           0           0           0        1649          49
AutoNUMA cost                        0           0           0           0           5          10

Based on this, I believe the migration patches are only indirectly
responsible. No way should hackbench be migrating or receiving a PTE update
at all. Rather than withdrawing the scalability patches it might make more
sense to either increase the length of time before a PTE takes place or
to delay NUMA PTE updates until the RSS reaches a particular size instead
of just relying on where the task gets scheduled.

So overall, I still believe that balancenuma should be merged at this point
based on these results. Nothing stops you doing a rebase of numacore on
top afterwards and introduce it in parts validating at each point it's
actually improving performance and not just assuming it does.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
