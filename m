Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 06EB86B004D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 21:57:44 -0400 (EDT)
Date: Fri, 12 Jun 2009 09:59:27 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [patch v3] swap: virtual swap readahead
Message-ID: <20090612015927.GA6804@localhost>
References: <20090610081132.GA27519@localhost> <20090610173249.50e19966.kamezawa.hiroyu@jp.fujitsu.com> <20090610085638.GA32511@localhost> <1244626976.13761.11593.camel@twins> <20090610095950.GA514@localhost> <1244628314.13761.11617.camel@twins> <20090610113214.GA5657@localhost> <20090610102516.08f7300f@jbarnes-x200> <20090611052228.GA20100@localhost> <20090611101741.GA1974@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090611101741.GA1974@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Barnes, Jesse" <jesse.barnes@intel.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 11, 2009 at 06:17:42PM +0800, Johannes Weiner wrote:
> On Thu, Jun 11, 2009 at 01:22:28PM +0800, Wu Fengguang wrote:
> > Unfortunately, after fixing it up the swap readahead patch still performs slow
> > (even worse this time):
> 
> Thanks for doing the tests.  Do you know if the time difference comes
> from IO or CPU time?
> 
> Because one reason I could think of is that the original code walks
> the readaround window in two directions, starting from the target each
> time but immediately stops when it encounters a hole where the new
> code just skips holes but doesn't abort readaround and thus might
> indeed read more slots.
> 
> I have an old patch flying around that changed the physical ra code to
> use a bitmap that is able to represent holes.  If the increased time
> is waiting for IO, I would be interested if that patch has the same
> negative impact.

You can send me the patch :)

But for this patch it is IO bound. The CPU iowait field actually is
going up as the test goes on:

wfg@hp ~% dstat 10
----total-cpu-usage---- -dsk/total- -net/total- ---paging-- ---system--
usr sys idl wai hiq siq| read  writ| recv  send|  in   out | int   csw
  3   3  89   4   0   1|  18k   27B|   0     0 |   0     0 |1530  1006
  0   1  99   0   0   0|   0     0 |  31k 9609B|   0     0 |1071   444
  1   1  97   1   0   0|   0     0 |  57k   13k|   0     0 |1139   870
 30  31  24  13   0   3|   0   741k|1648k  294k|   0   370k|3666    10k
 27  30  26  14   0   3| 361k 3227k|1264k  262k| 180k 1614k|3471  9457
 25  25  29  18   0   2| 479k 4102k|2353k  285k| 240k 2051k|3707  9429
 39  44   5   8   0   4| 256k 7646k|2711k  564k| 128k 3823k|7055    13k
 33  18  17  30   0   2|1654k 4357k|2565k  306k| 830k 2366k|4033    10k
 25  17  25  31   0   2|1130k 4053k|2540k  312k| 562k 1838k|3906  9722
 26  17  15  38   0   3|2481k 7118k|3870k  456k|1244k 3559k|5301    11k
 21  12  15  49   0   3|2406k 5041k|4389k  371k|1206k 2818k|4684  8747
 26  15  12  42   0   4|3582k 7320k|5002k  484k|1784k 3362k|5675  9934
 26  19  17  35   0   3|2412k 3452k|3165k  300k|1209k 1726k|4090  8727
 26  15  13  43   0   3|2531k 5294k|3727k  350k|1281k 2738k|4570  8857
 19  13   5  60   0   4|5471k 5148k|4661k  354k|2736k 2484k|4563  8084
 16   9  10  62   0   2|3656k 1818k|3464k  189k|1815k  948k|3121  5361
 22  15   5  54   0   4|5016k 3176k|5773k  412k|2524k 1549k|5337    10k
 20  12   9  57   0   3|2277k 1528k|3405k  288k|1120k  764k|3786  7112
 15   9   4  69   0   3|4410k 2786k|4233k  311k|2228k 1411k|4115  6685
 20  12  10  56   0   2|3765k 1953k|2490k  159k|1863k  964k|2550  6832
 26  14  22  36   0   2|1709k  569k|2969k  219k| 848k  279k|3229  8640
 16  11   7  63   0   3|4095k 2934k|4986k  316k|2047k 1471k|4413  7165
 18  11   3  66   0   3|4219k 1238k|3623k  247k|2119k  616k|3767  6728
 16  12   5  64   0   3|4122k 2278k|4400k  343k|2066k 1184k|4325  7220
 15  11   5  66   0   3|3715k 1467k|4760k  282k|1858k  824k|4130  5918
  7   9   0  80   0   3|4986k 2773k|5811k  328k|2652k 1255k|4244  5173
  9   6  10  74   0   2|4465k  846k|2100k  116k|2061k  420k|2106  2349
 13   8  12  63   0   4|3813k 2607k|5926k  365k|1917k 1309k|4588  5611
  6   6   0  84   0   3|3898k 1206k|4807k  236k|1976k  983k|3477  4210  missed 2 ticks
  6   4   6  83   0   1|4312k 1281k| 679k   58k|2118k  255k|1618  2035
 15   9  18  55   0   4|3489k 1354k|5087k  323k|1746k  713k|4396  5182
  9   5   2  82   0   2|4026k 1134k|1792k  101k|2020k  548k|2183  3555
 14  13   3  66   0   4|3269k 1974k|8776k  476k|1642k 1074k|5937  7077
 10   8   3  77   0   2|4211k 1192k|3227k  196k|2092k  492k|3098  4070
  7   6   7  78   0   3|3672k 2268k|4879k  234k|1833k 1134k|3490  3608
  8   7   6  74   0   4|3782k 2708k|5389k  309k|1902k 1357k|4026  4887
  1   6   0  91   0   2|4662k   33k|1720k  145k|2357k  117k|2587  2066
  3  11   0  85   0   1|4285k  941k|1506k   78k|2118k  431k|2026  1968
  5   8   0  83   0   4|4463k 3075k|5975k  364k|2219k 1729k|4167  4147
  3   4   5  86   0   2|4004k  834k|2943k  137k|2027k  161k|2518  2195
  3   3   0  93   0   2|3016k  974k|1979k   93k|1490k  676k|2034  1717
  7   5   2  85   0   2|4066k 2286k|2617k  195k|2047k  954k|2955  3344
  8   6   7  77   0   3|4247k 2599k|3422k  252k|2108k 1300k|3623  3129
  8   4  12  72   0   3|4056k 1235k|4237k  201k|2028k  618k|3190  2675
  5   7   0  84   0   3|3789k 1222k|5824k  314k|1955k  612k|3758  5173
  0   5   0  94   0   1|3544k  418k| 646k   29k|1744k  216k|1527   989
  1   3   0  94   0   2|3263k  263k|2193k  105k|1614k  165k|2173  1673
  2  13   0  83   0   2|3252k 1124k|2546k  200k|1612k  521k|2832  2386
  3  34   0  59   0   3|2959k  342k|7795k  325k|1472k  171k|4462  3451
  5  22   2  67   0   4|2898k 1534k|  10M  452k|1452k  767k|4380  4124
  9  12  12  66   0   2|3530k  479k|2890k  140k|1764k  240k|2453  2538
  6   6  12  74   0   2|3334k 2631k|2660k  122k|1672k 1546k|2480  2070  missed 2 ticks
----total-cpu-usage---- -dsk/total- -net/total- ---paging-- ---system--
usr sys idl wai hiq siq| read  writ| recv  send|  in   out | int   csw
  9   3  21  65   0   2|3750k  765k|3169k  134k|1872k  152k|2273  1921
  5   6   1  83   0   4|3618k 1295k|6543k  330k|1891k  648k|4030  4131
  3   5   2  87   0   2|3600k 1054k|2851k  173k|1720k  527k|2815  2687
  4   7   1  83   0   5|3677k 1344k|6024k  314k|1844k  734k|3877  4376
  4   5   3  85   0   3|3953k  933k|3196k  152k|1989k  405k|2618  2321
  2   3   0  94   0   1|3106k  131k| 486k   24k|1544k  131k|1466  1374
  2   3   0  93   0   1|3089k  672k|1454k   65k|1540k  362k|1825  1909
  7   4   2  86   0   1|3393k  878k|1503k   84k|1694k  416k|1882  2033
  9   3  25  62   0   2|3496k 1833k|1979k   90k|1748k  848k|2112  1797
  6   4   3  84   0   3|3592k  861k|4340k  191k|1795k  432k|2926  3143
  4   6   0  87   0   3|3399k  847k|3758k  186k|1740k  440k|2699  4299
  1   2   0  97   0   1|2807k  365k| 685k   49k|1394k  168k|1175   840  missed 2 ticks
  2   3   4  90   0   2|3183k  801k|2022k   87k|1568k  399k|1998  1561
  2   3   2  91   0   2|3014k  726k|2214k   96k|1521k  368k|2072  1652
  4   5   2  86   0   3|3344k 1686k|4970k  217k|1659k  838k|3209  2936
  8   4  17  69   0   2|3026k  741k|1923k  107k|1510k  370k|1993  2227
  8   4  23  63   0   2|3496k 1026k|2948k  129k|1754k  513k|2347  2048
  6   7   2  81   0   4|3438k 1222k|5658k  272k|1746k  626k|3740  5708
  0   5   0  94   0   1|2902k   30k|1012k   43k|1435k    0 |1637  1161
  1   2   2  93   0   1|2968k  102k| 985k   59k|1471k  122k|1402  1101
  4   5   1  88   0   3|3651k 1814k|3838k  170k|1840k  841k|2769  2382
  2   2   1  94   0   1|2570k  344k| 500k   23k|1283k  214k|1360  1299
  5   3   2  89   0   1|2728k  964k|1119k   70k|1378k  450k|1760  2024
  8   3  24  64   0   1|2993k  967k| 737k   29k|1470k  468k|1432  1251
 12   2  37  48   0   1|2547k  710k| 651k   26k|1274k  360k|1435  1199
  9   3  26  60   0   2|3218k 1630k|3540k  153k|1612k  847k|2723  2174
  3   4   5  85   0   3|3618k  870k|3796k  168k|1807k  414k|2653  2497
  4   5   0  90   0   1|3134k  841k|1489k   81k|1591k  419k|1972  3498
  1   2   0  97   0   1|2910k  349k| 816k   55k|1438k  191k|1525  1096
  3   4   2  89   0   2|3240k  930k|2779k  122k|1610k  433k|2313  2036
  4   5   0  89   0   2|3079k 1340k|4054k  184k|1549k  670k|2981  3567
  2   6   1  90   0   1|2702k  256k|1080k   50k|1348k  178k|1658  1413
  3   4   6  85   0   2|3798k 1128k|2208k  105k|1890k  513k|2194  1984
 10   3  33  53   0   1|3619k 1239k|1147k   50k|1821k  620k|1708  1563
  7   5  12  73   0   3|3689k 1795k|3633k  185k|1833k  898k|2744  2404  missed 2 ticks
  4   4   4  85   0   3|3309k  282k|3728k  168k|1662k  166k|2661  2891
  2  11   0  84   0   2|2989k  195k|3949k  186k|1530k   92k|2528  3687
  0   2   0  96   0   1|2576k   67k|1148k   67k|1278k   40k|1668  1124
  1   2   0  95   0   2|2680k  896k|2093k   94k|1317k  548k|2088  1564
  1   2   0  95   0   1|2938k  809k|1769k   72k|1461k  279k|1825  1385
  2   3   3  90   0   2|3099k 1158k|2854k  125k|1562k  611k|2317  1841
  4   4   1  90   0   2|2806k  670k|2139k   94k|1398k  303k|2096  2173
  9   5  11  73   0   2|2930k 1646k|2741k  122k|1454k  823k|2504  2515
 11   3  29  56   0   1|3154k 1049k|1453k   85k|1578k  524k|1849  1599
  5   4   5  84   0   2|3135k  489k|3718k  161k|1570k  268k|2806  2712
  3   4   2  90   0   1|3010k  513k|1514k   82k|1530k  233k|1936  2989
  3   4   0  91   0   2|2891k  378k|3174k  148k|1430k  196k|2562  2776
  2  12   0  83   0   2|3146k  310k|3730k  184k|1569k  149k|2399  2101
  3   3   0  93   0   1|2491k  358k|1628k   73k|1245k  179k|1837  1755

  Thanks,
  Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
