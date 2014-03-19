Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 912BB6B0155
	for <linux-mm@kvack.org>; Wed, 19 Mar 2014 05:38:31 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id k14so6766371wgh.34
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 02:38:30 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pl10si9402596wic.8.2014.03.19.02.38.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 19 Mar 2014 02:38:29 -0700 (PDT)
Message-ID: <53296594.3020800@suse.cz>
Date: Wed, 19 Mar 2014 10:38:28 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] compaction related commits
References: <1392360843-22261-1-git-send-email-iamjoonsoo.kim@lge.com> <53146128.1010802@suse.cz> <20140304002326.GA32172@lge.com>
In-Reply-To: <20140304002326.GA32172@lge.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/04/2014 01:23 AM, Joonsoo Kim wrote:
> On Mon, Mar 03, 2014 at 12:02:00PM +0100, Vlastimil Babka wrote:
>> On 02/14/2014 07:53 AM, Joonsoo Kim wrote:
>>> changes for v2
>>> o include more experiment data in cover letter
>>> o deal with vlastimil's comments mostly about commit description on 4/5
>>>
>>> This patchset is related to the compaction.
>>>
>>> patch 1 fixes contrary implementation of the purpose of compaction.
>>> patch 2~4 are for optimization.
>>> patch 5 is just for clean-up.
>>>
>>> I tested this patchset with stress-highalloc benchmark on Mel's mmtest
>>> and cannot find any regression in terms of success rate. And I find
>>> much reduced(9%) elapsed time.
>>>
>>> Below is the average result of 10 runs on my 4GB quad core system.
>>>
>>> compaction-base+ is based on 3.13.0 with Vlastimil's recent fixes.
>>> compaction-fix+ has this patch series on top of compaction-base+.
>>>
>>> Thanks.
>>>
>>>
>>> stress-highalloc	
>>> 			3.13.0			3.13.0
>>> 			compaction-base+	compaction-fix+
>>> Success 1		14.10				15.00
>>> Success 2		20.20				20.00
>>> Success 3		68.30				73.40
>>> 																			
>>> 			3.13.0			3.13.0
>>> 			compaction-base+	compaction-fix+
>>> User			3486.02				3437.13
>>> System			757.92				741.15
>>> Elapsed			1638.52				1488.32
>>>
>>> 			3.13.0			3.13.0
>>> 			compaction-base+	compaction-fix+
>>> Minor Faults 			172591561		167116621
>>> Major Faults 			     984		     859
>>> Swap Ins 			     743		     653
>>> Swap Outs 			    3657		    3535
>>> Direct pages scanned 		  129742		  127344
>>> Kswapd pages scanned 		 1852277		 1817825
>>> Kswapd pages reclaimed 		 1838000		 1804212
>>> Direct pages reclaimed 		  129719		  127327
>>> Kswapd efficiency 		     98%		     98%
>>> Kswapd velocity 		1130.066		1221.296
>>> Direct efficiency 		     99%		     99%
>>> Direct velocity 		  79.367		  85.585
>>> Percentage direct scans 	      6%		      6%
>>> Zone normal velocity 		 231.829		 246.097
>>> Zone dma32 velocity 		 972.589		1055.158
>>> Zone dma velocity 		   5.015		   5.626
>>> Page writes by reclaim 		    6287		    6534
>>> Page writes file 		    2630		    2999
>>> Page writes anon 		    3657		    3535
>>> Page reclaim immediate 		    2187		    2080
>>> Sector Reads 			 2917808		 2877336
>>> Sector Writes 			11477891		11206722
>>> Page rescued immediate 		       0		       0
>>> Slabs scanned 			 2214118		 2168524
>>> Direct inode steals 		   12181		    9788
>>> Kswapd inode steals 		  144830		  132109
>>> Kswapd skipped wait 		       0		       0
>>> THP fault alloc 		       0		       0
>>> THP collapse alloc 		       0		       0
>>> THP splits 			       0		       0
>>> THP fault fallback 		       0		       0
>>> THP collapse fail 		       0		       0
>>> Compaction stalls 		     738		     714
>>> Compaction success 		     194		     207
>>> Compaction failures 		     543		     507
>>> Page migrate success 		 1806083		 1464014
>>> Page migrate failure 		       0		       0
>>> Compaction pages isolated 	 3873329	 	 3162974
>>> Compaction migrate scanned 	74594862	 	59874420
>>> Compaction free scanned 	125888854	 	110868637
>>> Compaction cost 		    2469		    1998
>>
>> FWIW, I've let a machine run the series with individual patches applied
>> on 3.13 with my compaction patches, so 6 is the end of my series and 7-11 yours:
>> The average is of 10 runs (in case you wonder how that's done, the success rates are
>> calculated with a new R support that's pending Mel's merge; system time and vmstats
>> are currently a hack, but I hope to add R support for them as well, and maybe publish
>> to github or something if there's interest).
> 
> Good! I have an interest on it.

Most of the support is now in mmtests' master branch on github. The system time
and vmstats is a hack with hardcoded number of iterations (now 10) that I attach
at the end of the mail.

You need R installed and run compare like this:
compare-kernels.sh --R --iterations 10

> 
>>
>> Interestingly, you have a much lower success rate and also much lower compaction cost
>> and, well, even the benchmark times. Wonder what difference in config or hw causes this.
>> You seem to have THP disabled, I enabled, but that would be weird to cause this.
> 
> My 10 runs are continuous 10 runs without reboot. It makes compaction success
> rate decline on every trial and therefore average result is so low than yours.
> I heard that you did 10 runs because of large stdev, so I thought that continuous 10 runs
> also can makes the result reliable. Therefore I decided this method although it is not
> proper method to get the average. I had to notify about it. If it confuses you,
> sorry about that.
> 
> Anyway, noticeable point of continuous 10 runs is that success rate decrease continuously
> and significantly. I attach the rate of success 3 on every trial on below.
> 
> Base
> % Success:            80
> % Success:            60
> % Success:            76
> % Success:            74
> % Success:            70
> % Success:            68
> % Success:            66
> % Success:            65
> % Success:            63
> % Success:            61
> 
> 
> Applied with my patches
> % Success:            81
> % Success:            78
> % Success:            75
> % Success:            74
> % Success:            71
> % Success:            72
> % Success:            73
> % Success:            70
> % Success:            70
> % Success:            70
> 
> It means that memory is fragmented continously. I didn't dig into this problem, but
> it would be good subject to investigate.

You're right, I see that too. And the reduction of work done by compaction,
especially within first 3 iterations, is interestingly large.
The number of reclaimable and unmovable pageblocks indeed slightly grows,
although not as much as to translate directly into the success rates.

stress-highalloc
                           test                  test                  test                  test                  test                  test                  test                  test                  test                  test
                              1                     2                     3                     4                     5                     6                     7                     8                     9                    10
Success 1       49.00 (  0.00%)       51.00 ( -4.08%)       51.00 ( -4.08%)       62.00 (-26.53%)       53.00 ( -8.16%)       57.00 (-16.33%)       55.00 (-12.24%)       58.00 (-18.37%)       58.00 (-18.37%)       46.00 (  6.12%)
Success 2       55.00 (  0.00%)       64.00 (-16.36%)       62.00 (-12.73%)       62.00 (-12.73%)       56.00 ( -1.82%)       57.00 ( -3.64%)       58.00 ( -5.45%)       59.00 ( -7.27%)       57.00 ( -3.64%)       55.00 (  0.00%)
Success 3       85.00 (  0.00%)       81.00 (  4.71%)       77.00 (  9.41%)       77.00 (  9.41%)       75.00 ( 11.76%)       74.00 ( 12.94%)       74.00 ( 12.94%)       73.00 ( 14.12%)       73.00 ( 14.12%)       71.00 ( 16.47%)

                test        test        test        test        test        test        test        test        test        test
                   1           2           3           4           5           6           7           8           9          10
User         5696.69     5713.20     5668.87     5412.19     5425.39     5357.67     5402.08     5345.72     5575.73     5473.66
System       1008.77     1028.72     1025.66     1015.87     1023.82     1023.45     1023.26     1019.52     1026.88     1028.05
Elapsed      2253.63     2285.87     2531.58     2198.46     2220.21     2199.75     2237.43     2266.97     2724.87     2288.90

                                  test        test        test        test        test        test        test        test        test        test
                                     1           2           3           4           5           6           7           8           9          10
Minor Faults                 248584347   241444309   238931712   229339487   234134233   234113609   236172742   235955684   235274197   234072299
Major Faults                       768        6273        5624        6146        7638        7038        7279        8475        6837        8948
Swap Ins                            24       17320       12557       11956       31729       28434       29228       43494       29528       41212
Swap Outs                          958       94106      106680       81672      147012       95169      133733      142124      133492      157440
Direct pages scanned            213760       42549      118178       22266        4818        3634       51636       23166       17319       40327
Kswapd pages scanned           2137836     3449877     3500913     3909294     3343227     3800324     3840356     3035274     3048595     3192582
Kswapd pages reclaimed         2134695     2231079     2536612     2238583     2232883     2219601     2180405     2324381     2331881     2276682
Direct pages reclaimed          213422       42304      117833       22134        4711        3562       51551       23088       17240       40281
Kswapd efficiency                  99%         64%         72%         57%         66%         58%         56%         76%         76%         71%
Kswapd velocity                948.619    1509.218    1382.896    1778.197    1505.816    1727.616    1716.414    1338.912    1118.804    1394.811
Direct efficiency                  99%         99%         99%         99%         97%         98%         99%         99%         99%         99%
Direct velocity                 94.851      18.614      46.682      10.128       2.170       1.652      23.078      10.219       6.356      17.619
Percentage direct scans             9%          1%          3%          0%          0%          0%          1%          0%          0%          1%
Zone normal velocity           329.358     931.485     794.284    1165.576     922.453    1122.753    1146.195     711.711     594.119     801.484
Zone dma32 velocity            714.112     596.348     635.294     622.749     585.533     606.515     593.297     637.420     531.040     610.945
Zone dma velocity                0.000       0.000       0.000       0.000       0.000       0.000       0.000       0.000       0.000       0.000
Page writes by reclaim         958.000  142306.000  147653.000  154673.000  168131.000  120184.000  157196.000  158862.000  155427.000  178478.000
Page writes file                     0       48200       40973       73001       21119       25015       23463       16738       21935       21038
Page writes anon                   958       94106      106680       81672      147012       95169      133733      142124      133492      157440
Page reclaim immediate             227      978397      717495     1393234      747156     1277758     1307521      315722      396171      528904
Sector Reads                   3146168     3275924     4886280     3301644     3328564     3341776     3357484     3431016     3375072     3329768
Sector Writes                 12552716    12767728    12971248    12339364    12829408    12581020    12810572    12822476    12836888    12906372
Page rescued immediate               0           0           0           0           0           0           0           0           0           0
Slabs scanned                  1857664     2226176     2273280     2238464     2250752     2269184     2297856     2229248     2216960     2219008
Direct inode steals              10976       10215       17701        2688       19256        8041        3827       11226       10767       13599
Kswapd inode steals              58552      341409      352875      362913      406943      392956      454265      326993      310959      341106
Kswapd skipped wait                  0           0           0           0           0           0           0           0           0           0
THP fault alloc                     97          59          96           8          58          54          58          68          68          54
THP collapse alloc                 655         416         616         396         396         393         402         386         396         387
THP splits                           6           5          18          12          10          11           9          12          11           7
THP fault fallback                   0           0           0           0           0           0           0           0           1           0
THP collapse fail                   11          21          13          21          21          20          22          18          20          21
Compaction stalls                 5851        6125        6925        5572        6183        6064        6224        6069        6196        6861
Compaction success                1163        1811        2144        1783        1747        1886        1833        1823        1781        1748
Compaction failures               3250        2200        2195        1800        1754        1421        1834        1521        1929        1753
Page migrate success           6110592     3508332     3093592     2740374     2091309     1400876     2208633     1516013     2223733     1699633
Page migrate failure                 0           0           0           0           0           0           0           0           0           0
Compaction pages isolated     15360926    10185640     9900328     8228257     6719820     5195540     6677838     4841171     6708180     5479883
Compaction migrate scanned   349981387   300209536   297909273   286215718   268660759   256103243   285198850   241549363   287544164   261619750
Compaction free scanned      556386189   260105925   296420166   196203596   148614315    98672618   174033818    82384264   165998395   123011890
Compaction cost                   9084        5936        5484        5004        4179        3345        4415        3356        4448        3699
NUMA alloc hit               167473642   162715095   160968619   154496168   157513861   157598611   159117516   158854501   158279702   157440309
NUMA alloc miss                      0           0           0           0           0           0           0           0           0           0
NUMA interleave hit                  0           0           0           0           0           0           0           0           0           0
NUMA alloc local             167473642   162715095   160968619   154496168   157513861   157598611   159117516   158854501   158279702   157440309
NUMA page range updates              0           0           0           0           0           0           0           0           0           0
NUMA huge PMD updates                0           0           0           0           0           0           0           0           0           0
NUMA PTE updates                     0           0           0           0           0           0           0           0           0           0
NUMA hint faults                     0           0           0           0           0           0           0           0           0           0
NUMA hint local faults               0           0           0           0           0           0           0           0           0           0
NUMA hint local percent            100         100         100         100         100         100         100         100         100         100
NUMA pages migrated                  0           0           0           0           0           0           0           0           0           0
AutoNUMA cost                        0           0           0           0           0           0           0           0           0           0

                        test        test        test        test        test        test        test        test        test        test
                           1           2           3           4           5           6           7           8           9          10
Mean sda-avgqz         62.27       64.24       67.82       68.47       64.52       74.36       68.65       66.98       52.45       61.41
Mean sda-await        356.96      384.46      396.37      426.02      384.43      447.38      409.69      384.68      315.29      357.33
Mean sda-r_await       43.62       44.58       40.66       49.54       45.40       47.44       48.68       41.98       35.12       39.42
Mean sda-w_await      705.15      813.62     1136.46     1029.17      834.44     1127.80      971.66      914.88      712.12      784.44
Max  sda-avgqz        291.35      286.96      162.48      265.33      161.77      240.23      196.98      203.30      162.28      283.29
Max  sda-await       1258.88     1680.93     2309.73     1566.46     1711.69     1948.61     1381.23     1986.32     1583.03     1737.79
Max  sda-r_await      274.27      185.52      125.71      272.05      340.00      332.00      312.00      188.16      159.23      173.33
Max  sda-w_await     8174.71    12488.89    13484.06    12931.84     9821.61    10462.28     9182.25     9573.30    12516.77     8842.26


> Thanks.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

------8<------
commit 596bad5b6505b8b606c197a8ee2af8a74a7edbc6
Author: Vlastimil Babka <vbabka@suse.cz>
Date:   Mon Dec 16 13:38:36 2013 +0100

    HACK: iteration support for MonitorDuration and MonitorMmtestsvmstat

diff --git a/bin/lib/MMTests/MonitorDuration.pm b/bin/lib/MMTests/MonitorDuration.pm
index 1069e83..313eb0a 100644
--- a/bin/lib/MMTests/MonitorDuration.pm
+++ b/bin/lib/MMTests/MonitorDuration.pm
@@ -19,22 +19,33 @@ sub new() {
 sub extractReport($$$) {
 	my ($self, $reportDir, $testName, $testBenchmark) = @_;
 
-	my $file = "$reportDir/tests-timestamp-$testName";
+	my $file;
+	my $i;
+	my ($user, $system, $elapsed);
+	my $iterations = 10;
+
+	for ($i = 1; $i <= $iterations; $i++) {
+	$file = "$reportDir/$i/tests-timestamp-$testName";
 
 	open(INPUT, $file) || die("Failed to open $file\n");
 	while (<INPUT>) {
 		if ($_ =~ /^time \:\: $testBenchmark (.*)/) {
 			my $dummy;
-			my ($user, $system, $elapsed);
+			my ($useri, $systemi, $elapsedi);
 
-			($user, $dummy,
-			 $system, $dummy,
-			 $elapsed, $dummy) = split(/\s/, $1);
+			($useri, $dummy,
+			 $systemi, $dummy,
+			 $elapsedi, $dummy) = split(/\s/, $1);
 
-			push @{$self->{_ResultData}}, [ "", $user, $system, $elapsed];
+			$user += $useri;
+			$system += $systemi;
+			$elapsed += $elapsedi;
 		}
 	}
 	close INPUT;
+	}
+
+	push @{$self->{_ResultData}}, [ "", $user / $iterations, $system / $iterations, $elapsed / $iterations];
 }
 
 1;
diff --git a/bin/lib/MMTests/MonitorMmtestsvmstat.pm b/bin/lib/MMTests/MonitorMmtestsvmstat.pm
index 7bd3a21..bec917b 100644
--- a/bin/lib/MMTests/MonitorMmtestsvmstat.pm
+++ b/bin/lib/MMTests/MonitorMmtestsvmstat.pm
@@ -167,8 +167,13 @@ sub extractReport($$$$) {
 	my $elapsed_time;
 	my %zones_seen;
 
-	my $file = "$reportDir/tests-timestamp-$testName";
+	my $i;
+	my $iterations = 10;
 
+	my $file;
+
+	for ($i = 1; $i <= $iterations; $i++) {
+	$file = "$reportDir/$i/tests-timestamp-$testName";
 	open(INPUT, $file) || die("Failed to open $file\n");
 	while (<INPUT>) {
 		if ($_ =~ /^test begin \:\: $testBenchmark/) {
@@ -209,9 +214,9 @@ sub extractReport($$$$) {
 
 			my ($key, $value) = split(/\s/, $_);
 			if ($reading_before) {
-				$vmstat_before{$key} = $value;
+				$vmstat_before{$key} += $value;
 			} elsif ($reading_after) {
-				$vmstat_after{$key} = $value;
+				$vmstat_after{$key} += $value;
 			}
 			if ($key eq "pgmigrate_success") {
 				$new_compaction_stats = 1;
@@ -222,6 +227,12 @@ sub extractReport($$$$) {
 		}
 	}
 	close INPUT;
+	}
+
+	foreach my $key (sort keys %vmstat_before) {
+		$vmstat_before{$key} /= $iterations;
+		$vmstat_after{$key} /= $iterations;
+	}
 
 	# kswapd steal
 	foreach my $key ("kswapd_steal", "pgsteal_kswapd_dma", "pgsteal_kswapd_dma32",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
