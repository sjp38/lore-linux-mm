Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 59E396B0068
	for <linux-mm@kvack.org>; Sun, 25 Nov 2012 18:37:42 -0500 (EST)
Date: Sun, 25 Nov 2012 23:37:34 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Comparison between three trees (was: Latest numa/core release,
 v17)
Message-ID: <20121125233734.GD8218@suse.de>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
 <20121123173205.GZ8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121123173205.GZ8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Fri, Nov 23, 2012 at 05:32:05PM +0000, Mel Gorman wrote:
> From here, we're onto the single JVM configuration. I suspect
> this is tested much more commonly but note that it behaves very
> differently to the multi JVM configuration as explained by Andrea
> (http://choon.net/forum/read.php?21,1599976,page=4).
> 
> A concern with the single JVM results as reported here is the maximum
> number of warehouses. In the Multi JVM configuration, the expected peak
> was 12 warehouses so I ran up to 18 so that the tests could complete in a
> reasonable amount of time. The expected peak for a single JVM is 48 (the
> number of CPUs) but the configuration file was derived from the multi JVM
> configuration so it was restricted to running up to 18 warehouses. Again,
> the reason was so it would complete in a reasonable amount of time but
> specjbb does not give a score for this type of configuration and I am
> only reporting on the 1-18 warehouses it ran for. I've reconfigured the
> 4 specjbb configs to run a full config and it'll run over the weekend.
> 

Ths use of just peak figures really is a factor.  The THP configuration,
single JVM is the best configuration for numacore but this is only visible
for peak numbers of warehouses. For lower number of warehouses it regresses
but this is not reported by the specjbb benchmark and could have been
easily missed. It also mostly explains why I was seeing very different
figures to other testers.

More below.

> SPECJBB: Single JVMs (one per node, 4 nodes), THP is enabled
> 
> SPECJBB BOPS
>                         3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
>                rc6-stats-v5r1 rc6-numacore-20121123rc6-autonuma-v28fastr4   rc6-thpmigrate-v5r1    rc6-adaptscan-v5r1   rc6-delaystart-v5r4
> TPut 1      26802.00 (  0.00%)     22808.00 (-14.90%)     24482.00 ( -8.66%)     25723.00 ( -4.03%)     24387.00 ( -9.01%)     25940.00 ( -3.22%)
> TPut 2      57720.00 (  0.00%)     51245.00 (-11.22%)     55018.00 ( -4.68%)     55498.00 ( -3.85%)     55259.00 ( -4.26%)     55581.00 ( -3.71%)
> TPut 3      86940.00 (  0.00%)     79172.00 ( -8.93%)     87705.00 (  0.88%)     86101.00 ( -0.97%)     86894.00 ( -0.05%)     86875.00 ( -0.07%)
> TPut 4     117203.00 (  0.00%)    107315.00 ( -8.44%)    117382.00 (  0.15%)    116282.00 ( -0.79%)    116322.00 ( -0.75%)    115263.00 ( -1.66%)
> TPut 5     145375.00 (  0.00%)    121178.00 (-16.64%)    145802.00 (  0.29%)    142378.00 ( -2.06%)    144947.00 ( -0.29%)    144211.00 ( -0.80%)
> TPut 6     169232.00 (  0.00%)    157796.00 ( -6.76%)    173409.00 (  2.47%)    171066.00 (  1.08%)    173341.00 (  2.43%)    169861.00 (  0.37%)
> TPut 7     195468.00 (  0.00%)    169834.00 (-13.11%)    197201.00 (  0.89%)    197536.00 (  1.06%)    198347.00 (  1.47%)    198047.00 (  1.32%)
> TPut 8     217863.00 (  0.00%)    169975.00 (-21.98%)    222559.00 (  2.16%)    224901.00 (  3.23%)    226268.00 (  3.86%)    218354.00 (  0.23%)
> TPut 9     240679.00 (  0.00%)    197498.00 (-17.94%)    245997.00 (  2.21%)    250022.00 (  3.88%)    253838.00 (  5.47%)    250264.00 (  3.98%)
> TPut 10    261454.00 (  0.00%)    204909.00 (-21.63%)    269551.00 (  3.10%)    275125.00 (  5.23%)    274658.00 (  5.05%)    274155.00 (  4.86%)
> TPut 11    281079.00 (  0.00%)    230118.00 (-18.13%)    281588.00 (  0.18%)    304383.00 (  8.29%)    297198.00 (  5.73%)    299131.00 (  6.42%)
> TPut 12    302007.00 (  0.00%)    275511.00 ( -8.77%)    313281.00 (  3.73%)    327826.00 (  8.55%)    325324.00 (  7.72%)    325372.00 (  7.74%)
> TPut 13    319139.00 (  0.00%)    293501.00 ( -8.03%)    332581.00 (  4.21%)    352389.00 ( 10.42%)    340169.00 (  6.59%)    351215.00 ( 10.05%)
> TPut 14    321069.00 (  0.00%)    312088.00 ( -2.80%)    337911.00 (  5.25%)    376198.00 ( 17.17%)    370669.00 ( 15.45%)    366491.00 ( 14.15%)
> TPut 15    345851.00 (  0.00%)    283856.00 (-17.93%)    369104.00 (  6.72%)    389772.00 ( 12.70%)    392963.00 ( 13.62%)    389254.00 ( 12.55%)
> TPut 16    346868.00 (  0.00%)    317127.00 ( -8.57%)    380930.00 (  9.82%)    420331.00 ( 21.18%)    412974.00 ( 19.06%)    408575.00 ( 17.79%)
> TPut 17    357755.00 (  0.00%)    349624.00 ( -2.27%)    387635.00 (  8.35%)    441223.00 ( 23.33%)    426558.00 ( 19.23%)    435985.00 ( 21.87%)
> TPut 18    357467.00 (  0.00%)    360056.00 (  0.72%)    399487.00 ( 11.75%)    464603.00 ( 29.97%)    442907.00 ( 23.90%)    453011.00 ( 26.73%)
> 
> numacore is not doing well here for low numbers of warehouses. However,
> note that by 18 warehouses it had drawn level and the expected peak is 48
> warehouses. The specjbb reported figure would be using the higher numbers
> of warehouses. I'll a full range over the weekend and report back. If
> time permits, I'll also run a "monitors disabled" run case the read of
> numa_maps every 10 seconds is crippling it.
> 

Over the weekend I ran a few configurations that used a large number of
warehouses. The numacore and autonuma kernels are as before.  The balancenuma
kernel is a reshuffled tree that moves the THP patches towards the end of the
series. It's functionally very similar to delaystart-v5r4 from the earlier
report. The differences are bug fixes from Hillf and accounting fixes.

In terms of testing, the big difference is the number of warehouses
tested. Here are the results.

SPECJBB: Single JVM, THP is enabled
                        3.7.0                 3.7.0                 3.7.0                 3.7.0
               rc6-stats-v5r1 rc6-numacore-20121123rc6-autonuma-v28fastr4  rc6-thpmigrate-v6r10
TPut 1      25598.00 (  0.00%)     24938.00 ( -2.58%)     24663.00 ( -3.65%)     25641.00 (  0.17%)
TPut 2      56182.00 (  0.00%)     50701.00 ( -9.76%)     55059.00 ( -2.00%)     56300.00 (  0.21%)
TPut 3      84856.00 (  0.00%)     80000.00 ( -5.72%)     86692.00 (  2.16%)     87656.00 (  3.30%)
TPut 4     115406.00 (  0.00%)    102629.00 (-11.07%)    118576.00 (  2.75%)    117089.00 (  1.46%)
TPut 5     143810.00 (  0.00%)    131824.00 ( -8.33%)    142516.00 ( -0.90%)    143652.00 ( -0.11%)
TPut 6     168681.00 (  0.00%)    138700.00 (-17.77%)    171938.00 (  1.93%)    171625.00 (  1.75%)
TPut 7     196629.00 (  0.00%)    158003.00 (-19.64%)    184263.00 ( -6.29%)    196422.00 ( -0.11%)
TPut 8     219888.00 (  0.00%)    173094.00 (-21.28%)    222689.00 (  1.27%)    226163.00 (  2.85%)
TPut 9     244790.00 (  0.00%)    201543.00 (-17.67%)    247785.00 (  1.22%)    252223.00 (  3.04%)
TPut 10    265824.00 (  0.00%)    224522.00 (-15.54%)    268362.00 (  0.95%)    273253.00 (  2.79%)
TPut 11    286745.00 (  0.00%)    240431.00 (-16.15%)    297968.00 (  3.91%)    303903.00 (  5.98%)
TPut 12    312593.00 (  0.00%)    278749.00 (-10.83%)    322880.00 (  3.29%)    324283.00 (  3.74%)
TPut 13    319508.00 (  0.00%)    297467.00 ( -6.90%)    337332.00 (  5.58%)    350443.00 (  9.68%)
TPut 14    348575.00 (  0.00%)    301683.00 (-13.45%)    374828.00 (  7.53%)    371199.00 (  6.49%)
TPut 15    350516.00 (  0.00%)    357707.00 (  2.05%)    370428.00 (  5.68%)    400114.00 ( 14.15%)
TPut 16    370886.00 (  0.00%)    326597.00 (-11.94%)    412694.00 ( 11.27%)    420616.00 ( 13.41%)
TPut 17    386422.00 (  0.00%)    363441.00 ( -5.95%)    427190.00 ( 10.55%)    444268.00 ( 14.97%)
TPut 18    387031.00 (  0.00%)    387802.00 (  0.20%)    449808.00 ( 16.22%)    459404.00 ( 18.70%)
TPut 19    397352.00 (  0.00%)    387513.00 ( -2.48%)    444231.00 ( 11.80%)    480527.00 ( 20.93%)
TPut 20    386512.00 (  0.00%)    409861.00 (  6.04%)    469152.00 ( 21.38%)    503000.00 ( 30.14%)
TPut 21    406441.00 (  0.00%)    453321.00 ( 11.53%)    475290.00 ( 16.94%)    517443.00 ( 27.31%)
TPut 22    399667.00 (  0.00%)    473069.00 ( 18.37%)    494780.00 ( 23.80%)    530384.00 ( 32.71%)
TPut 23    406795.00 (  0.00%)    459549.00 ( 12.97%)    498187.00 ( 22.47%)    545605.00 ( 34.12%)
TPut 24    410499.00 (  0.00%)    442373.00 (  7.76%)    506758.00 ( 23.45%)    555870.00 ( 35.41%)
TPut 25    400845.00 (  0.00%)    463657.00 ( 15.67%)    497653.00 ( 24.15%)    554370.00 ( 38.30%)
TPut 26    390073.00 (  0.00%)    488957.00 ( 25.35%)    500685.00 ( 28.36%)    553714.00 ( 41.95%)
TPut 27    391689.00 (  0.00%)    452545.00 ( 15.54%)    498155.00 ( 27.18%)    561167.00 ( 43.27%)
TPut 28    380903.00 (  0.00%)    483782.00 ( 27.01%)    494085.00 ( 29.71%)    546296.00 ( 43.42%)
TPut 29    381805.00 (  0.00%)    527448.00 ( 38.15%)    502872.00 ( 31.71%)    552729.00 ( 44.77%)
TPut 30    375810.00 (  0.00%)    483409.00 ( 28.63%)    494412.00 ( 31.56%)    548433.00 ( 45.93%)
TPut 31    378324.00 (  0.00%)    477776.00 ( 26.29%)    497701.00 ( 31.55%)    548419.00 ( 44.96%)
TPut 32    372322.00 (  0.00%)    444958.00 ( 19.51%)    488683.00 ( 31.25%)    536867.00 ( 44.19%)
TPut 33    359918.00 (  0.00%)    431751.00 ( 19.96%)    484478.00 ( 34.61%)    538970.00 ( 49.75%)
TPut 34    357685.00 (  0.00%)    452866.00 ( 26.61%)    476558.00 ( 33.23%)    521906.00 ( 45.91%)
TPut 35    354902.00 (  0.00%)    456795.00 ( 28.71%)    484244.00 ( 36.44%)    533609.00 ( 50.35%)
TPut 36    337517.00 (  0.00%)    469182.00 ( 39.01%)    454640.00 ( 34.70%)    526363.00 ( 55.95%)
TPut 37    332136.00 (  0.00%)    456822.00 ( 37.54%)    458413.00 ( 38.02%)    519400.00 ( 56.38%)
TPut 38    330084.00 (  0.00%)    453377.00 ( 37.35%)    434666.00 ( 31.68%)    512187.00 ( 55.17%)
TPut 39    319024.00 (  0.00%)    412778.00 ( 29.39%)    428688.00 ( 34.37%)    509798.00 ( 59.80%)
TPut 40    315002.00 (  0.00%)    391376.00 ( 24.25%)    398529.00 ( 26.52%)    480411.00 ( 52.51%)
TPut 41    299693.00 (  0.00%)    353819.00 ( 18.06%)    403541.00 ( 34.65%)    492599.00 ( 64.37%)
TPut 42    298226.00 (  0.00%)    347563.00 ( 16.54%)    362189.00 ( 21.45%)    476979.00 ( 59.94%)
TPut 43    295595.00 (  0.00%)    401208.00 ( 35.73%)    393026.00 ( 32.96%)    459142.00 ( 55.33%)
TPut 44    296490.00 (  0.00%)    419443.00 ( 41.47%)    341222.00 ( 15.09%)    452357.00 ( 52.57%)
TPut 45    292584.00 (  0.00%)    420579.00 ( 43.75%)    393112.00 ( 34.36%)    468680.00 ( 60.19%)
TPut 46    287256.00 (  0.00%)    384628.00 ( 33.90%)    375230.00 ( 30.63%)    433550.00 ( 50.93%)
TPut 47    277411.00 (  0.00%)    349226.00 ( 25.89%)    392540.00 ( 41.50%)    449038.00 ( 61.87%)
TPut 48    277058.00 (  0.00%)    396594.00 ( 43.14%)    398184.00 ( 43.72%)    457085.00 ( 64.98%)
TPut 49    279962.00 (  0.00%)    402671.00 ( 43.83%)    394294.00 ( 40.84%)    425650.00 ( 52.04%)
TPut 50    279948.00 (  0.00%)    372190.00 ( 32.95%)    420082.00 ( 50.06%)    447108.00 ( 59.71%)
TPut 51    282160.00 (  0.00%)    362593.00 ( 28.51%)    404464.00 ( 43.35%)    460767.00 ( 63.30%)
TPut 52    275574.00 (  0.00%)    343943.00 ( 24.81%)    397754.00 ( 44.34%)    425609.00 ( 54.44%)
TPut 53    283902.00 (  0.00%)    355129.00 ( 25.09%)    410938.00 ( 44.75%)    427099.00 ( 50.44%)
TPut 54    277341.00 (  0.00%)    371739.00 ( 34.04%)    398662.00 ( 43.74%)    427941.00 ( 54.30%)
TPut 55    272116.00 (  0.00%)    417531.00 ( 53.44%)    390286.00 ( 43.43%)    436491.00 ( 60.41%)
TPut 56    280207.00 (  0.00%)    347432.00 ( 23.99%)    404331.00 ( 44.30%)    439342.00 ( 56.79%)
TPut 57    282146.00 (  0.00%)    329932.00 ( 16.94%)    379562.00 ( 34.53%)    407568.00 ( 44.45%)
TPut 58    275901.00 (  0.00%)    373810.00 ( 35.49%)    394333.00 ( 42.93%)    428118.00 ( 55.17%)
TPut 59    276583.00 (  0.00%)    359812.00 ( 30.09%)    376969.00 ( 36.30%)    429891.00 ( 55.43%)
TPut 60    272523.00 (  0.00%)    368938.00 ( 35.38%)    385033.00 ( 41.28%)    427636.00 ( 56.92%)
TPut 61    272427.00 (  0.00%)    387343.00 ( 42.18%)    376525.00 ( 38.21%)    417755.00 ( 53.35%)
TPut 62    258730.00 (  0.00%)    390303.00 ( 50.85%)    373770.00 ( 44.46%)    438145.00 ( 69.34%)
TPut 63    269246.00 (  0.00%)    389464.00 ( 44.65%)    381536.00 ( 41.71%)    433943.00 ( 61.17%)
TPut 64    266261.00 (  0.00%)    387660.00 ( 45.59%)    387200.00 ( 45.42%)    399805.00 ( 50.16%)
TPut 65    259147.00 (  0.00%)    373458.00 ( 44.11%)    389666.00 ( 50.36%)    400191.00 ( 54.43%)
TPut 66    273445.00 (  0.00%)    374637.00 ( 37.01%)    359764.00 ( 31.57%)    419330.00 ( 53.35%)
TPut 67    269350.00 (  0.00%)    380035.00 ( 41.09%)    391560.00 ( 45.37%)    391418.00 ( 45.32%)
TPut 68    275532.00 (  0.00%)    379096.00 ( 37.59%)    396028.00 ( 43.73%)    390213.00 ( 41.62%)
TPut 69    274195.00 (  0.00%)    368116.00 ( 34.25%)    393802.00 ( 43.62%)    391539.00 ( 42.80%)
TPut 70    269523.00 (  0.00%)    372521.00 ( 38.21%)    381988.00 ( 41.73%)    360330.00 ( 33.69%)
TPut 71    264778.00 (  0.00%)    372533.00 ( 40.70%)    377377.00 ( 42.53%)    395088.00 ( 49.21%)
TPut 72    265705.00 (  0.00%)    359686.00 ( 35.37%)    390037.00 ( 46.79%)    399126.00 ( 50.21%)

Note for lower number of warehouses that numacore regresses and then
improves as the warehouses increase. The expected peak is 48 cores and
note how numacore gets a 43.14% improvement here, autonuma sees a 43.72%
gain and balancenuma sees a 64.98% gain.

This explains why there was a big difference in reported figures. I was
using Multiple JVMs as ordinarily one would expect one JVM per node and
to have each JVM bound to a node. Multiple JVMs and Single JVMs generate
very different results.  Second, there are massive differences depending on
whether THP is enabled or disabled. Lastly, as we can see here, numacore
regresses for small number of warehouses which is what I initially saw
but does very well as the number of warehouses increases. specjbb reports
based on peak number of warehouses so if people were using just the specjbb
score or were only testing peak number of warehouses, they would see the
performance gains but miss the regressions.

SPECJBB PEAKS
                                       3.7.0                      3.7.0                      3.7.0                      3.7.0
                              rc6-stats-v5r1      rc6-numacore-20121123     rc6-autonuma-v28fastr4       rc6-thpmigrate-v6r10
 Expctd Warehouse                   48.00 (  0.00%)                   48.00 (  0.00%)                   48.00 (  0.00%)                   48.00 (  0.00%)
 Expctd Peak Bops               277058.00 (  0.00%)               396594.00 ( 43.14%)               398184.00 ( 43.72%)               457085.00 ( 64.98%)
 Actual Warehouse                   24.00 (  0.00%)                   29.00 ( 20.83%)                   24.00 (  0.00%)                   27.00 ( 12.50%)
 Actual Peak Bops               410499.00 (  0.00%)               527448.00 ( 28.49%)               506758.00 ( 23.45%)               561167.00 ( 36.70%)
 SpecJBB Bops                   139464.00 (  0.00%)               190554.00 ( 36.63%)               199064.00 ( 42.74%)               213820.00 ( 53.32%)
 SpecJBB Bops/JVM               139464.00 (  0.00%)               190554.00 ( 36.63%)               199064.00 ( 42.74%)               213820.00 ( 53.32%)

Here you can see that numacore scales to a higher number of warehouses
and sees a 43.14% performance gain at the peak and a 36.63% gain on the
specjbb score. The peaks are great, just not the smaller number of
warehouses.

autonuma sees a 23.45% performance gain at the peak and a 42.74%
performance gain on the specjbb score.

balancenuma gets a 36.7% performance gain at the peak and a 53.32%
gain on the specjbb score.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v6r10
User       317241.10   311543.98   314980.59   315357.34
System        105.47     2989.96      341.54      431.13
Elapsed      7432.59     7439.32     7433.84     7433.72

Same comments about the sytem CPU usage. numacores is really high.
balancenuma's is higher than I'd like.

MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0
                          rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v6r10
Page Ins                         38252       38036       38212       37976
Page Outs                        55364       59772       55704       54824
Swap Ins                             0           0           0           0
Swap Outs                            0           0           0           0
Direct pages scanned                 0           0           0           0
Kswapd pages scanned                 0           0           0           0
Kswapd pages reclaimed               0           0           0           0
Direct pages reclaimed               0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%
Page writes by reclaim               0           0           0           0
Page writes file                     0           0           0           0
Page writes anon                     0           0           0           0
Page reclaim immediate               0           0           0           0
Page rescued immediate               0           0           0           0
Slabs scanned                        0           0           0           0
Direct inode steals                  0           0           0           0
Kswapd inode steals                  0           0           0           0
Kswapd skipped wait                  0           0           0           0
THP fault alloc                  51908       43137       46165       49523
THP collapse alloc                  62           3         179          59
THP splits                          72          45          86          75
THP fault fallback                   0           0           0           0
THP collapse fail                    0           0           0           0
Compaction stalls                    0           0           0           0
Compaction success                   0           0           0           0
Compaction failures                  0           0           0           0
Page migrate success                 0           0           0    46917509
Page migrate failure                 0           0           0           0
Compaction pages isolated            0           0           0           0
Compaction migrate scanned           0           0           0           0
Compaction free scanned              0           0           0           0
Compaction cost                      0           0           0       48700
NUMA PTE updates                     0           0           0   356453719
NUMA hint faults                     0           0           0     2056190
NUMA hint local faults               0           0           0      752408
NUMA pages migrated                  0           0           0    46917509
AutoNUMA cost                        0           0           0       13667

Note that THP was certainly in use here. balancenuma migrated a lot more
than I'd like but it cannot be compared with numacore or autonuma at
this point.


SPECJBB: Single JVMs (one per node, 4 nodes), THP is disabled
                        3.7.0                 3.7.0                 3.7.0                 3.7.0
               rc6-stats-v5r1 rc6-numacore-20121123rc6-autonuma-v28fastr4  rc6-thpmigrate-v6r10
TPut 1      20507.00 (  0.00%)     16702.00 (-18.55%)     19496.00 ( -4.93%)     19831.00 ( -3.30%)
TPut 2      48723.00 (  0.00%)     36714.00 (-24.65%)     49452.00 (  1.50%)     45973.00 ( -5.64%)
TPut 3      72618.00 (  0.00%)     59086.00 (-18.63%)     69728.00 ( -3.98%)     71996.00 ( -0.86%)
TPut 4      98383.00 (  0.00%)     76940.00 (-21.80%)     98216.00 ( -0.17%)     95339.00 ( -3.09%)
TPut 5     122240.00 (  0.00%)     95981.00 (-21.48%)    119822.00 ( -1.98%)    117487.00 ( -3.89%)
TPut 6     144010.00 (  0.00%)    100095.00 (-30.49%)    141127.00 ( -2.00%)    143931.00 ( -0.05%)
TPut 7     164690.00 (  0.00%)    119577.00 (-27.39%)    159922.00 ( -2.90%)    164073.00 ( -0.37%)
TPut 8     190702.00 (  0.00%)    125183.00 (-34.36%)    189187.00 ( -0.79%)    180400.00 ( -5.40%)
TPut 9     209898.00 (  0.00%)    137179.00 (-34.64%)    160205.00 (-23.67%)    206052.00 ( -1.83%)
TPut 10    234064.00 (  0.00%)    140225.00 (-40.09%)    220768.00 ( -5.68%)    218224.00 ( -6.77%)
TPut 11    252408.00 (  0.00%)    134453.00 (-46.73%)    250953.00 ( -0.58%)    248507.00 ( -1.55%)
TPut 12    278689.00 (  0.00%)    140355.00 (-49.64%)    271815.00 ( -2.47%)    255907.00 ( -8.17%)
TPut 13    298940.00 (  0.00%)    153780.00 (-48.56%)    190433.00 (-36.30%)    289418.00 ( -3.19%)
TPut 14    315971.00 (  0.00%)    126929.00 (-59.83%)    309899.00 ( -1.92%)    283315.00 (-10.34%)
TPut 15    340446.00 (  0.00%)    132710.00 (-61.02%)    290484.00 (-14.68%)    327168.00 ( -3.90%)
TPut 16    362010.00 (  0.00%)    156255.00 (-56.84%)    347844.00 ( -3.91%)    311160.00 (-14.05%)
TPut 17    376476.00 (  0.00%)     95441.00 (-74.65%)    333508.00 (-11.41%)    366629.00 ( -2.62%)
TPut 18    399230.00 (  0.00%)    132993.00 (-66.69%)    374946.00 ( -6.08%)    358280.00 (-10.26%)
TPut 19    414300.00 (  0.00%)    129194.00 (-68.82%)    392675.00 ( -5.22%)    363700.00 (-12.21%)
TPut 20    429780.00 (  0.00%)     90068.00 (-79.04%)    241891.00 (-43.72%)    413210.00 ( -3.86%)
TPut 21    439977.00 (  0.00%)    136793.00 (-68.91%)    412629.00 ( -6.22%)    398914.00 ( -9.33%)
TPut 22    459593.00 (  0.00%)    134292.00 (-70.78%)    426511.00 ( -7.20%)    414652.00 ( -9.78%)
TPut 23    473600.00 (  0.00%)    137794.00 (-70.90%)    436081.00 ( -7.92%)    421456.00 (-11.01%)
TPut 24    483442.00 (  0.00%)    139342.00 (-71.18%)    390536.00 (-19.22%)    453552.00 ( -6.18%)
TPut 25    484584.00 (  0.00%)    144745.00 (-70.13%)    430863.00 (-11.09%)    397971.00 (-17.87%)
TPut 26    483041.00 (  0.00%)    145326.00 (-69.91%)    333960.00 (-30.86%)    454575.00 ( -5.89%)
TPut 27    480788.00 (  0.00%)    145395.00 (-69.76%)    402433.00 (-16.30%)    415528.00 (-13.57%)
TPut 28    470141.00 (  0.00%)    146261.00 (-68.89%)    385008.00 (-18.11%)    445938.00 ( -5.15%)
TPut 29    476984.00 (  0.00%)    147988.00 (-68.97%)    379719.00 (-20.39%)    395984.00 (-16.98%)
TPut 30    471709.00 (  0.00%)    148658.00 (-68.49%)    417249.00 (-11.55%)    424000.00 (-10.11%)
TPut 31    470451.00 (  0.00%)    147949.00 (-68.55%)    408792.00 (-13.11%)    384502.00 (-18.27%)
TPut 32    468377.00 (  0.00%)    158685.00 (-66.12%)    414694.00 (-11.46%)    405441.00 (-13.44%)
TPut 33    463536.00 (  0.00%)    159097.00 (-65.68%)    412259.00 (-11.06%)    399323.00 (-13.85%)
TPut 34    457678.00 (  0.00%)    153025.00 (-66.56%)    408133.00 (-10.83%)    402190.00 (-12.12%)
TPut 35    448181.00 (  0.00%)    154037.00 (-65.63%)    405535.00 ( -9.52%)    422016.00 ( -5.84%)
TPut 36    450490.00 (  0.00%)    149057.00 (-66.91%)    407218.00 ( -9.61%)    381320.00 (-15.35%)
TPut 37    435425.00 (  0.00%)    153996.00 (-64.63%)    400370.00 ( -8.05%)    403088.00 ( -7.43%)
TPut 38    434985.00 (  0.00%)    158683.00 (-63.52%)    408266.00 ( -6.14%)    406860.00 ( -6.47%)
TPut 39    425064.00 (  0.00%)    160263.00 (-62.30%)    397737.00 ( -6.43%)    385657.00 ( -9.27%)
TPut 40    428366.00 (  0.00%)    161150.00 (-62.38%)    383404.00 (-10.50%)    405984.00 ( -5.22%)
TPut 41    417072.00 (  0.00%)    155817.00 (-62.64%)    394627.00 ( -5.38%)    398389.00 ( -4.48%)
TPut 42    398350.00 (  0.00%)    156774.00 (-60.64%)    388583.00 ( -2.45%)    329310.00 (-17.33%)
TPut 43    405526.00 (  0.00%)    162938.00 (-59.82%)    371761.00 ( -8.33%)    396379.00 ( -2.26%)
TPut 44    400696.00 (  0.00%)    167164.00 (-58.28%)    372067.00 ( -7.14%)    373746.00 ( -6.73%)
TPut 45    391357.00 (  0.00%)    163075.00 (-58.33%)    365494.00 ( -6.61%)    348089.00 (-11.06%)
TPut 46    394109.00 (  0.00%)    173557.00 (-55.96%)    357955.00 ( -9.17%)    372188.00 ( -5.56%)
TPut 47    383292.00 (  0.00%)    168575.00 (-56.02%)    357946.00 ( -6.61%)    352658.00 ( -7.99%)
TPut 48    373607.00 (  0.00%)    158491.00 (-57.58%)    358227.00 ( -4.12%)    373779.00 (  0.05%)
TPut 49    372131.00 (  0.00%)    145881.00 (-60.80%)    360147.00 ( -3.22%)    358224.00 ( -3.74%)
TPut 50    369060.00 (  0.00%)    139450.00 (-62.21%)    355721.00 ( -3.61%)    367608.00 ( -0.39%)
TPut 51    375906.00 (  0.00%)    139823.00 (-62.80%)    367783.00 ( -2.16%)    364796.00 ( -2.96%)
TPut 52    379731.00 (  0.00%)    158706.00 (-58.21%)    381289.00 (  0.41%)    370100.00 ( -2.54%)
TPut 53    366656.00 (  0.00%)    178068.00 (-51.43%)    382147.00 (  4.22%)    369301.00 (  0.72%)
TPut 54    373531.00 (  0.00%)    177087.00 (-52.59%)    374892.00 (  0.36%)    367863.00 ( -1.52%)
TPut 55    374440.00 (  0.00%)    174830.00 (-53.31%)    372036.00 ( -0.64%)    377606.00 (  0.85%)
TPut 56    351285.00 (  0.00%)    175761.00 (-49.97%)    370602.00 (  5.50%)    371896.00 (  5.87%)
TPut 57    366069.00 (  0.00%)    172227.00 (-52.95%)    377253.00 (  3.06%)    364024.00 ( -0.56%)
TPut 58    367753.00 (  0.00%)    174523.00 (-52.54%)    376854.00 (  2.47%)    372580.00 (  1.31%)
TPut 59    364282.00 (  0.00%)    176119.00 (-51.65%)    365806.00 (  0.42%)    370299.00 (  1.65%)
TPut 60    372531.00 (  0.00%)    175673.00 (-52.84%)    354662.00 ( -4.80%)    365126.00 ( -1.99%)
TPut 61    359648.00 (  0.00%)    174686.00 (-51.43%)    365387.00 (  1.60%)    370039.00 (  2.89%)
TPut 62    361856.00 (  0.00%)    171420.00 (-52.63%)    366173.00 (  1.19%)    345029.00 ( -4.65%)
TPut 63    363032.00 (  0.00%)    171603.00 (-52.73%)    360794.00 ( -0.62%)    349379.00 ( -3.76%)
TPut 64    351549.00 (  0.00%)    170967.00 (-51.37%)    354632.00 (  0.88%)    352406.00 (  0.24%)
TPut 65    360425.00 (  0.00%)    170349.00 (-52.74%)    346205.00 ( -3.95%)    351510.00 ( -2.47%)
TPut 66    359197.00 (  0.00%)    170037.00 (-52.66%)    355970.00 ( -0.90%)    330963.00 ( -7.86%)
TPut 67    356962.00 (  0.00%)    168949.00 (-52.67%)    355577.00 ( -0.39%)    358511.00 (  0.43%)
TPut 68    360411.00 (  0.00%)    167892.00 (-53.42%)    337932.00 ( -6.24%)    358516.00 ( -0.53%)
TPut 69    354346.00 (  0.00%)    166288.00 (-53.07%)    334951.00 ( -5.47%)    360614.00 (  1.77%)
TPut 70    354596.00 (  0.00%)    166214.00 (-53.13%)    333059.00 ( -6.07%)    337859.00 ( -4.72%)
TPut 71    351838.00 (  0.00%)    167198.00 (-52.48%)    316732.00 ( -9.98%)    350369.00 ( -0.42%)
TPut 72    357716.00 (  0.00%)    164325.00 (-54.06%)    309282.00 (-13.54%)    353090.00 ( -1.29%)

Without THP, numacore suffers really badly. Neither autonuma or
balancenuma do great. The reasons why balancenuma suffers have already
been explained -- the scan rate is not reducing but this can be
addressed with a big hammer. A patch already exists that does that but
is not included here.

SPECJBB PEAKS
                                       3.7.0                      3.7.0                      3.7.0                      3.7.0
                              rc6-stats-v5r1      rc6-numacore-20121123     rc6-autonuma-v28fastr4       rc6-thpmigrate-v6r10
 Expctd Warehouse                   48.00 (  0.00%)                   48.00 (  0.00%)                   48.00 (  0.00%)                   48.00 (  0.00%)
 Expctd Peak Bops               373607.00 (  0.00%)               158491.00 (-57.58%)               358227.00 ( -4.12%)               373779.00 (  0.05%)
 Actual Warehouse                   25.00 (  0.00%)                   53.00 (112.00%)                   23.00 ( -8.00%)                   26.00 (  4.00%)
 Actual Peak Bops               484584.00 (  0.00%)               178068.00 (-63.25%)               436081.00 (-10.01%)               454575.00 ( -6.19%)
 SpecJBB Bops                   185685.00 (  0.00%)                85236.00 (-54.10%)               182329.00 ( -1.81%)               183908.00 ( -0.96%)
 SpecJBB Bops/JVM               185685.00 (  0.00%)                85236.00 (-54.10%)               182329.00 ( -1.81%)               183908.00 ( -0.96%)

numacore regresses 63.25% at it's peak and has a 54.10% loss on its
specjbb score.

autonuma regresses 10.01% at its peak, 1.81% on the specjbb score.

balancenuma does "best" in that it regresses the least.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v6r10
User       316094.47   169409.35        0.00   308074.71
System         62.67   123927.05        0.00     1897.43
Elapsed      7434.12     7452.00        0.00     7438.16

The autonuma file that stored the system CPu usage was truncated for some
reason. I've set it to rerun.

numacores system CPU usage is massive.

balancenumas is also far too high due to it failing to reduce the scan
rate.

So, now I'm seeing compatible figures that have been reported elsewhere.
To get those figures you must use a single JVM, THP must be enabled and it
must run with a large enough number of warehouses. For other configurations
or lower number of warehouses, it can suffer.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
