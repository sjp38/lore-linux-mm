Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 695916B008C
	for <linux-mm@kvack.org>; Sun, 14 Jul 2013 22:56:18 -0400 (EDT)
Received: by mail-ve0-f177.google.com with SMTP id cz10so9557651veb.36
        for <linux-mm@kvack.org>; Sun, 14 Jul 2013 19:56:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAA_GA1fiEJYxqAZ1c0BneuftB5g8d+2_mYBj=4iE=1EcYaTx7w@mail.gmail.com>
References: <CAA_GA1fiEJYxqAZ1c0BneuftB5g8d+2_mYBj=4iE=1EcYaTx7w@mail.gmail.com>
Date: Mon, 15 Jul 2013 10:56:17 +0800
Message-ID: <CAA_GA1eft+RoE8CBz9pFD0ZsqE3S33sux2hGjdgk4CNFSL0LEg@mail.gmail.com>
Subject: Re: Testing results of zswap
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, bob.liu@oracle.com, Mel Gorman <mgorman@suse.de>, Robert Jennings <rcj@linux.vnet.ibm.com>

As my test results showed in this thread.
1. Zswap only useful when total ram size is large else the performance
was worse than disabled it!

2. Zswap occupies some memory but that's unfair to file pages, more
file pages maybe reclaimed during memory pressure.
I think that's why the performance of the background io-duration was
worse than disable zswap.

Seth, any feedback? Do you observe the same issue?

On Thu, Jun 27, 2013 at 10:03 AM, Bob Liu <lliubbo@gmail.com> wrote:
> Hi All,
>
> These days I have been testing zswap.
> I found that the total ram size of my testing machine effected the
> testing result.
>
> If I limit  RAM size to 2G using "mem=", the performance of zswap is
> very disappointing,
> But if I use larger RAM size such as 8G, the performance is much better.
> Even with RAM size 8G, zswap will slow down the speed of parallelio.
>
> I run the testing(mmtest-0.10 with
> config-global-dhp__parallelio-memcachetest) after the default
> distribution booted every time.
>
> Below are some results:
>
> 1) kernel verion 3.10-rc6, mem=2G
>
> parallelio
>                                                rc6                         rc6
>                                            base-2G                    zswap-2G
> Ops memcachetest-0M             14719.00 (  0.00%)          10617.00 (-27.87%)
> Ops memcachetest-200M           14711.00 (  0.00%)          10152.00 (-30.99%)
> Ops memcachetest-433M           14839.00 (  0.00%)          10245.00 (-30.96%)
> Ops memcachetest-666M           14989.00 (  0.00%)          10134.00 (-32.39%)
> Ops memcachetest-900M           15180.00 (  0.00%)           9821.00 (-35.30%)
> Ops memcachetest-1133M          15654.00 (  0.00%)           9178.00 (-41.37%)
> Ops memcachetest-1367M          16100.00 (  0.00%)           9740.00 (-39.50%)
> Ops io-duration-0M                  0.00 (  0.00%)              0.00 (  0.00%)
> Ops io-duration-200M                3.00 (  0.00%)              5.00 (-66.67%)
> Ops io-duration-433M                6.00 (  0.00%)             10.00 (-66.67%)
> Ops io-duration-666M               10.00 (  0.00%)             14.00 (-40.00%)
> Ops io-duration-900M               13.00 (  0.00%)             21.00 (-61.54%)
> Ops io-duration-1133M              17.00 (  0.00%)             25.00 (-47.06%)
> Ops io-duration-1367M              20.00 (  0.00%)             31.00 (-55.00%)
> Ops swaptotal-0M                   39.00 (  0.00%)          81481.00
> (-208825.64%)
> Ops swaptotal-200M               1400.00 (  0.00%)         106825.00 (-7530.36%)
> Ops swaptotal-433M                 16.00 (  0.00%)         103052.00
> (-643975.00%)
> Ops swaptotal-666M                  8.00 (  0.00%)          93693.00
> (-1171062.50%)
> Ops swaptotal-900M                  0.00 (  0.00%)          91009.00 (-99.00%)
> Ops swaptotal-1133M              3609.00 (  0.00%)         103650.00 (-2771.99%)
> Ops swaptotal-1367M                95.00 (  0.00%)          89652.00
> (-94270.53%)
> Ops swapin-0M                      39.00 (  0.00%)          39283.00
> (-100625.64%)
> Ops swapin-200M                   678.00 (  0.00%)          50220.00 (-7307.08%)
> Ops swapin-433M                    16.00 (  0.00%)          48372.00
> (-302225.00%)
> Ops swapin-666M                     8.00 (  0.00%)          43669.00
> (-545762.50%)
> Ops swapin-900M                     0.00 (  0.00%)          42791.00 (-99.00%)
> Ops swapin-1133M                  716.00 (  0.00%)          49320.00 (-6788.27%)
> Ops swapin-1367M                   91.00 (  0.00%)          42094.00
> (-46157.14%)
> Ops minorfaults-0M             511226.00 (  0.00%)         532594.00 ( -4.18%)
> Ops minorfaults-200M           507501.00 (  0.00%)         577895.00 (-13.87%)
> Ops minorfaults-433M           507342.00 (  0.00%)         573211.00 (-12.98%)
> Ops minorfaults-666M           506917.00 (  0.00%)         565424.00 (-11.54%)
> Ops minorfaults-900M           513814.00 (  0.00%)         569420.00 (-10.82%)
> Ops minorfaults-1133M          559981.00 (  0.00%)         592414.00 ( -5.79%)
> Ops minorfaults-1367M          511420.00 (  0.00%)         572809.00 (-12.00%)
> Ops majorfaults-0M                  6.00 (  0.00%)           8593.00
> (-143116.67%)
> Ops majorfaults-200M              200.00 (  0.00%)          11335.00 (-5567.50%)
> Ops majorfaults-433M               55.00 (  0.00%)          10729.00
> (-19407.27%)
> Ops majorfaults-666M               68.00 (  0.00%)           9258.00
> (-13514.71%)
> Ops majorfaults-900M               94.00 (  0.00%)           9935.00
> (-10469.15%)
> Ops majorfaults-1133M             411.00 (  0.00%)          10902.00 (-2552.55%)
> Ops majorfaults-1367M             133.00 (  0.00%)           9340.00 (-6922.56%)
>
>                  rc6         rc6
>              base-2G    zswap-2G
> User         1068.98      715.36
> System       3910.06     2696.03
> Elapsed      7871.94     7890.20
>
>                                    rc6         rc6
>                                base-2G    zswap-2G
> Page Ins                       1322220    10206472
> Page Outs                     24675096    31069608
> Swap Ins                        100636     1548495
> Swap Outs                       134568     1734841
> Direct pages scanned             14441    16430214
> Kswapd pages scanned           7792848    35445764
> Kswapd pages reclaimed         6486627     7514907
> Direct pages reclaimed            4342     2166004
> Kswapd efficiency                  83%         21%
> Kswapd velocity                989.953    4492.378
> Direct efficiency                  30%         13%
> Direct velocity                  1.834    2082.357
> Percentage direct scans             0%         31%
> Page writes by reclaim          135881     5002899
> Page writes file                  1313     3268058
> Page writes anon                134568     1734841
> Page reclaim immediate             111     8048646
> Page rescued immediate               0           0
> Slabs scanned                  1532032     8295040
>
> 2) kernel verion 3.10-rc6, mem=8G
> parallelio
>                                                rc6                         rc6
>                                            base-8G                    zswap-8G
> Ops memcachetest-0M             16298.00 (  0.00%)          15496.00 ( -4.92%)
> Ops memcachetest-773M           13594.00 (  0.00%)          12175.00 (-10.44%)
> Ops memcachetest-1675M           5937.00 (  0.00%)           8520.00 ( 43.51%)
> Ops memcachetest-2577M           5972.00 (  0.00%)           8378.00 ( 40.29%)
> Ops memcachetest-3479M           2810.00 (  0.00%)           3422.00 ( 21.78%)
> Ops memcachetest-4381M           3579.00 (  0.00%)           2760.00 (-22.88%)
> Ops memcachetest-5284M           2266.00 (  0.00%)           2166.00 ( -4.41%)
> Ops io-duration-0M                  0.00 (  0.00%)              0.00 (  0.00%)
> Ops io-duration-773M               16.00 (  0.00%)             18.00 (-12.50%)
> Ops io-duration-1675M              34.00 (  0.00%)             51.00 (-50.00%)
> Ops io-duration-2577M              46.00 (  0.00%)             55.00 (-19.57%)
> Ops io-duration-3479M              64.00 (  0.00%)             82.00 (-28.12%)
> Ops io-duration-4381M              77.00 (  0.00%)            102.00 (-32.47%)
> Ops io-duration-5284M              91.00 (  0.00%)            128.00 (-40.66%)
> Ops swaptotal-0M                    0.00 (  0.00%)              0.00 (  0.00%)
> Ops swaptotal-773M              86867.00 (  0.00%)          64298.00 ( 25.98%)
> Ops swaptotal-1675M            258889.00 (  0.00%)         119483.00 ( 53.85%)
> Ops swaptotal-2577M            249005.00 (  0.00%)         110535.00 ( 55.61%)
> Ops swaptotal-3479M            317495.00 (  0.00%)         177709.00 ( 44.03%)
> Ops swaptotal-4381M            239539.00 (  0.00%)         166971.00 ( 30.29%)
> Ops swaptotal-5284M            286595.00 (  0.00%)         154143.00 ( 46.22%)
> Ops swapin-0M                       0.00 (  0.00%)              0.00 (  0.00%)
> Ops swapin-773M                 39739.00 (  0.00%)          31843.00 ( 19.87%)
> Ops swapin-1675M               128380.00 (  0.00%)          59499.00 ( 53.65%)
> Ops swapin-2577M               115923.00 (  0.00%)          55016.00 ( 52.54%)
> Ops swapin-3479M               143563.00 (  0.00%)          87498.00 ( 39.05%)
> Ops swapin-4381M               115248.00 (  0.00%)          77465.00 ( 32.78%)
> Ops swapin-5284M               120546.00 (  0.00%)          61451.00 ( 49.02%)
> Ops minorfaults-0M            1526324.00 (  0.00%)        1521203.00 (  0.34%)
> Ops minorfaults-773M          1592495.00 (  0.00%)        1581814.00 (  0.67%)
> Ops minorfaults-1675M         1652153.00 (  0.00%)        1603339.00 (  2.95%)
> Ops minorfaults-2577M         1648158.00 (  0.00%)        1596046.00 (  3.16%)
> Ops minorfaults-3479M         1581514.00 (  0.00%)        1562471.00 (  1.20%)
> Ops minorfaults-4381M         1587579.00 (  0.00%)        1526344.00 (  3.86%)
> Ops minorfaults-5284M         1540904.00 (  0.00%)        1506546.00 (  2.23%)
> Ops majorfaults-0M                  0.00 (  0.00%)              0.00 (  0.00%)
> Ops majorfaults-773M             5371.00 (  0.00%)           5562.00 ( -3.56%)
> Ops majorfaults-1675M           16701.00 (  0.00%)          10265.00 ( 38.54%)
> Ops majorfaults-2577M           14799.00 (  0.00%)           9205.00 ( 37.80%)
> Ops majorfaults-3479M           18279.00 (  0.00%)          14593.00 ( 20.17%)
> Ops majorfaults-4381M           14562.00 (  0.00%)          12985.00 ( 10.83%)
> Ops majorfaults-5284M           15177.00 (  0.00%)          10454.00 ( 31.12%)
>
>                  rc6         rc6
>              base-8G    zswap-8G
> User          538.84      606.68
> System       2192.36     2449.63
> Elapsed      8569.89     8601.77
>
>                                    rc6         rc6
>                                base-8G    zswap-8G
> Page Ins                      12122756     6361132
> Page Outs                    107059860    99973488
> Swap Ins                       2973693     1536266
> Swap Outs                      3489272     1716774
> Direct pages scanned                 0     8914107
> Kswapd pages scanned          25711001    11516911
> Kswapd pages reclaimed        13957707     5221461
> Direct pages reclaimed               0     8848421
> Kswapd efficiency                  54%         45%
> Kswapd velocity               3000.155    1338.900
> Direct efficiency                 100%         99%
> Direct velocity                  0.000    1036.311
> Percentage direct scans             0%         43%
> Page writes by reclaim         6587157     3306649
> Page writes file               3097885     1589875
> Page writes anon               3489272     1716774
> Page reclaim immediate           25168       61862
> Page rescued immediate               0           0
> Slabs scanned                  4218112     3148672
> Direct inode steals                  0           0
> Kswapd inode steals                252           0
> Kswapd skipped wait                  0           0
>

--
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
