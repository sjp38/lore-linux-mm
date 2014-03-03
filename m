Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 53AF06B0035
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 06:02:04 -0500 (EST)
Received: by mail-we0-f177.google.com with SMTP id u57so1127727wes.22
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 03:02:03 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hl1si9395007wjb.19.2014.03.03.03.02.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Mar 2014 03:02:02 -0800 (PST)
Message-ID: <53146128.1010802@suse.cz>
Date: Mon, 03 Mar 2014 12:02:00 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] compaction related commits
References: <1392360843-22261-1-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1392360843-22261-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/14/2014 07:53 AM, Joonsoo Kim wrote:
> changes for v2
> o include more experiment data in cover letter
> o deal with vlastimil's comments mostly about commit description on 4/5
> 
> This patchset is related to the compaction.
> 
> patch 1 fixes contrary implementation of the purpose of compaction.
> patch 2~4 are for optimization.
> patch 5 is just for clean-up.
> 
> I tested this patchset with stress-highalloc benchmark on Mel's mmtest
> and cannot find any regression in terms of success rate. And I find
> much reduced(9%) elapsed time.
> 
> Below is the average result of 10 runs on my 4GB quad core system.
> 
> compaction-base+ is based on 3.13.0 with Vlastimil's recent fixes.
> compaction-fix+ has this patch series on top of compaction-base+.
> 
> Thanks.
> 
> 
> stress-highalloc	
> 			3.13.0			3.13.0
> 			compaction-base+	compaction-fix+
> Success 1		14.10				15.00
> Success 2		20.20				20.00
> Success 3		68.30				73.40
> 																			
> 			3.13.0			3.13.0
> 			compaction-base+	compaction-fix+
> User			3486.02				3437.13
> System			757.92				741.15
> Elapsed			1638.52				1488.32
> 
> 			3.13.0			3.13.0
> 			compaction-base+	compaction-fix+
> Minor Faults 			172591561		167116621
> Major Faults 			     984		     859
> Swap Ins 			     743		     653
> Swap Outs 			    3657		    3535
> Direct pages scanned 		  129742		  127344
> Kswapd pages scanned 		 1852277		 1817825
> Kswapd pages reclaimed 		 1838000		 1804212
> Direct pages reclaimed 		  129719		  127327
> Kswapd efficiency 		     98%		     98%
> Kswapd velocity 		1130.066		1221.296
> Direct efficiency 		     99%		     99%
> Direct velocity 		  79.367		  85.585
> Percentage direct scans 	      6%		      6%
> Zone normal velocity 		 231.829		 246.097
> Zone dma32 velocity 		 972.589		1055.158
> Zone dma velocity 		   5.015		   5.626
> Page writes by reclaim 		    6287		    6534
> Page writes file 		    2630		    2999
> Page writes anon 		    3657		    3535
> Page reclaim immediate 		    2187		    2080
> Sector Reads 			 2917808		 2877336
> Sector Writes 			11477891		11206722
> Page rescued immediate 		       0		       0
> Slabs scanned 			 2214118		 2168524
> Direct inode steals 		   12181		    9788
> Kswapd inode steals 		  144830		  132109
> Kswapd skipped wait 		       0		       0
> THP fault alloc 		       0		       0
> THP collapse alloc 		       0		       0
> THP splits 			       0		       0
> THP fault fallback 		       0		       0
> THP collapse fail 		       0		       0
> Compaction stalls 		     738		     714
> Compaction success 		     194		     207
> Compaction failures 		     543		     507
> Page migrate success 		 1806083		 1464014
> Page migrate failure 		       0		       0
> Compaction pages isolated 	 3873329	 	 3162974
> Compaction migrate scanned 	74594862	 	59874420
> Compaction free scanned 	125888854	 	110868637
> Compaction cost 		    2469		    1998

FWIW, I've let a machine run the series with individual patches applied
on 3.13 with my compaction patches, so 6 is the end of my series and 7-11 yours:
The average is of 10 runs (in case you wonder how that's done, the success rates are
calculated with a new R support that's pending Mel's merge; system time and vmstats
are currently a hack, but I hope to add R support for them as well, and maybe publish
to github or something if there's interest).

Interestingly, you have a much lower success rate and also much lower compaction cost
and, well, even the benchmark times. Wonder what difference in config or hw causes this.
You seem to have THP disabled, I enabled, but that would be weird to cause this.
Anyway, it seems nothing statistically significant happens here. But the patches make
sense so this is not an argument against them :)

                                 3.13                  3.13                  3.13                  3.13                  3.13                  3.13
                              6-nothp               7-nothp               8-nothp               9-nothp              10-nothp              11-nothp
Success 1 Min         30.00 (  0.00%)       25.00 ( 16.67%)       46.00 (-53.33%)       41.00 (-36.67%)       25.00 ( 16.67%)       44.00 (-46.67%)
Success 1 Mean        45.50 (  0.00%)       45.20 (  0.66%)       47.30 ( -3.96%)       46.20 ( -1.54%)       44.60 (  1.98%)       46.70 ( -2.64%)
Success 1 Max         52.00 (  0.00%)       52.00 (  0.00%)       50.00 (  3.85%)       49.00 (  5.77%)       53.00 ( -1.92%)       49.00 (  5.77%)
Success 2 Min         36.00 (  0.00%)       30.00 ( 16.67%)       46.00 (-27.78%)       42.00 (-16.67%)       25.00 ( 30.56%)       46.00 (-27.78%)
Success 2 Mean        47.70 (  0.00%)       47.20 (  1.05%)       49.00 ( -2.73%)       47.80 ( -0.21%)       45.60 (  4.40%)       48.60 ( -1.89%)
Success 2 Max         56.00 (  0.00%)       55.00 (  1.79%)       52.00 (  7.14%)       51.00 (  8.93%)       53.00 (  5.36%)       52.00 (  7.14%)
Success 3 Min         84.00 (  0.00%)       84.00 (  0.00%)       84.00 (  0.00%)       84.00 (  0.00%)       83.00 (  1.19%)       84.00 (  0.00%)
Success 3 Mean        84.30 (  0.00%)       85.00 ( -0.83%)       85.40 ( -1.30%)       84.90 ( -0.71%)       84.50 ( -0.24%)       84.80 ( -0.59%)
Success 3 Max         85.00 (  0.00%)       86.00 ( -1.18%)       87.00 ( -2.35%)       86.00 ( -1.18%)       85.00 (  0.00%)       85.00 (  0.00%)

                3.13        3.13        3.13        3.13        3.13        3.13
             6-nothp     7-nothp     8-nothp     9-nothp    10-nothp    11-nothp
User         6059.77     6161.19     6037.71     6145.80     6157.28     6180.10
System       1034.15     1040.78     1034.66     1037.29     1034.39     1038.79
Elapsed      2132.04     2141.36     2149.86     2128.43     2110.11     2126.12

                                  3.13        3.13        3.13        3.13        3.13        3.13
                               6-nothp     7-nothp     8-nothp     9-nothp    10-nothp    11-nothp
Minor Faults                 252919751   253905255   252187591   253325723   252655233   253489596
Major Faults                       637         618         626         619         619         622
Swap Ins                             6           4           7           6          10           9
Swap Outs                          322         404         339         334         393         367
Direct pages scanned            287033      285148      276390      279039      271468      285491
Kswapd pages scanned           1891892     1893049     1912150     1897328     1890594     1901914
Kswapd pages reclaimed         1889422     1890396     1909624     1894755     1888005     1899281
Direct pages reclaimed          286843      284965      276160      278852      271262      285257
Kswapd efficiency                  99%         99%         99%         99%         99%         99%
Kswapd velocity                896.585     883.055     876.040     875.818     893.235     895.381
Direct efficiency                  99%         99%         99%         99%         99%         99%
Direct velocity                136.028     133.014     126.626     128.806     128.259     134.403
Percentage direct scans            13%         13%         12%         12%         12%         13%
Zone normal velocity           321.232     316.821     310.244     310.490     320.010     315.868
Zone dma32 velocity            711.380     699.247     692.423     694.134     701.483     713.917
Zone dma velocity                0.000       0.000       0.000       0.000       0.000       0.000
Page writes by reclaim         340.600     440.800     381.300     377.300     429.400     452.400
Page writes file                    17          36          41          42          35          84
Page writes anon                   322         404         339         334         393         367
Page reclaim immediate             383         470         435         453         491         477
Sector Reads                   2984072     3001944     3009073     2985139     2983261     2994914
Sector Writes                 12175402    12179276    12145946    12116400    12108622    12113503
Page rescued immediate               0           0           0           0           0           0
Slabs scanned                  1773696     1767654     1788134     1774720     1751065     1786291
Direct inode steals              15265       16402       16089       14913       14130       16178
Kswapd inode steals              52119       51160       51969       52261       50276       51807
Kswapd skipped wait                  0           0           0           0           0           0
THP fault alloc                     99         104          93          96          90          90
THP collapse alloc                 559         560         592         585         531         608
THP splits                           7           6           5           5           5           5
THP fault fallback                   2           0           0           0           0           0
THP collapse fail                   12          12          12          12          13          11
Compaction stalls                 1528        1574        1613        1580        1507        1537
Compaction success                 552         571         594         574         554         579
Compaction failures                975        1003        1018        1006         953         958
Page migrate success           3913572     4071734     4016156     3981713     3944844     3846041
Page migrate failure                 0           0           0           0           0           0
Compaction pages isolated      8256377     8608215     8489839     8395767     8316197     8135089
Compaction migrate scanned   155216300   161068938   165093536   158926355   157504384   157996946
Compaction free scanned      348489189   367790502   363524078   358476708   354952212   340442016
Compaction cost                   5305        5517        5485        5405        5355        5252
NUMA alloc hit               170245991   170939361   169815871   170557197   170160298   170719930
NUMA alloc miss                      0           0           0           0           0           0
NUMA interleave hit                  0           0           0           0           0           0
NUMA alloc local             170245991   170939361   169815871   170557197   170160298   170719930
NUMA page range updates              0           0           0           0           0           0
NUMA huge PMD updates                0           0           0           0           0           0
NUMA PTE updates                     0           0           0           0           0           0
NUMA hint faults                     0           0           0           0           0           0
NUMA hint local faults               0           0           0           0           0           0
NUMA hint local percent            100         100         100         100         100         100
NUMA pages migrated                  0           0           0           0           0           0
AutoNUMA cost                        0           0           0           0           0           0

 

> 
> Joonsoo Kim (5):
>    mm/compaction: disallow high-order page for migration target
>    mm/compaction: do not call suitable_migration_target() on every page
>    mm/compaction: change the timing to check to drop the spinlock
>    mm/compaction: check pageblock suitability once per pageblock
>    mm/compaction: clean-up code on success of ballon isolation
> 
>   mm/compaction.c |   75 ++++++++++++++++++++++++++++---------------------------
>   1 file changed, 38 insertions(+), 37 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
