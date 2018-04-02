Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 740A76B0023
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 05:25:03 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id l81so10608596vkd.18
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 02:25:03 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id i6si5427986vkg.253.2018.04.02.02.25.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Apr 2018 02:25:01 -0700 (PDT)
From: Buddy Lumpkin <buddy.lumpkin@oracle.com>
Subject: [RFC PATCH 0/1] mm: Support multiple kswapd threads per node
Date: Mon,  2 Apr 2018 09:24:21 +0000
Message-Id: <1522661062-39745-1-git-send-email-buddy.lumpkin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: buddy.lumpkin@oracle.com, hannes@cmpxchg.org, riel@surriel.com, mgorman@suse.de, willy@infradead.org, akpm@linux-foundation.org

I created this patch to address performance problems we are seeing in 
Oracle Cloud Infrastructure. We run the Oracle Linux UEK4 kernel
internally, which is based on upstream 4.1. I created and tested this
patch for the latest upstream kernel and UEK4. I was able to show
substantial benefits in both kernels, using workloads that provide a
mix of anonymous memory allocations with filesystem writes.

As I went through the process of getting this patch approved internally, I 
learned that it was hard to come up with a concise set of test results 
that clearly demonstrate that devoting more threads toward proactive page 
replacement is actually necessary. I was more focused on the impact that 
direct reclaims had on latency at the time, so I came up with a systemtap 
script that measures the latency of direct reclaims. On systems that were 
doing large volumes of filesystem IO, I saw order 0 allocations regularly 
taking over 10ms, and occasionally over 100ms. Since we were seeing large 
volumes of direct reclaims triggered as a side effect of filesystem IO, I 
figured this had to have a substantial impact on throughput.

I compared the maximum read throughput that could be obtained using direct 
IO streams to standard filesystem IO through the page cache on one of the 
dense storage systems that we vend. Direct IO was 55% higher in throughput 
than standard filesystem IO. I can't remember the last time I measured 
this but I know it was over 15 years ago, and I am quite sure the number 
was no more than 10%. I was pretty sure that direct reclaims were to blame 
for most of this and it would only take a few more tests to prove it. At 
23GB/s, it only takes 32.6 seconds to fill the page cache on one of these 
systems, but that is enough time to measure throughput without any page 
replacement occuring. In this case direct IO throughput was only 13.5% 
higher. It was pretty clear that direct reclaims were causing a 
substantial reduction in throughput. I decided this would be the ideal way 
to show the benefits of threading kswapd.

On the UEK4 kernel, six kswapd threads provided a 48% increase over one.
When I ran the same tests on upstream kernel version 4.16.0-rc7, I only
saw a 20% increase with 6 threads and the numbers fluctuated quite a bit
when I watched with iostat with a 2 second sample interval. The output
stalled periodically as well. When I profiled the system using perf, I
saw that 70% of the CPU time was being spent in a single function, it was
native_queued_spin_lock_slowpath(). 38% was during shrink_inactive_list()
and another 34% was spent during __lru_cache_add()

I eventually determined that my tests were presenting a difficult pattern 
for the logic that uses shadow entries to periodically resize the LRU 
lists. This was not a problem in the UEK4 kernel which also has shadow 
entries, so something has changed in that regard. I have not had time to 
really dig into this particular problem however, I assume those that are 
more familiar with the code might see the test results below and have an 
idea about what is going on.

I have appended a small patch to the end of this cover letter that 
effectively disables most of the routines in mm/workingset.c so that 
filesystem IO can be used to demonstrate the benefits of a threaded 
kswapd. I am not suggesting that this is the correct solution for this 
problem.

Test results below are the same that were run to demonstrate threaded 
kswapd performance. For more context, read the patch commit log before 
continuing and the test results below will make more sense

Direct IO results are roughly the same as expected ...

Test #1: Direct IO - shadow entries enabled
dd sy dd_cpu throughput
6  0  2.33   14726026.40
10 1  2.95   19954974.80
16 1  2.63   24419689.30
22 1  2.63   25430303.20
28 1  2.91   26026513.20
34 1  2.53   26178618.00
40 1  2.18   26239229.20
46 1  1.91   26250550.40
52 1  1.69   26251845.60
58 1  1.54   26253205.60
64 1  1.43   26253780.80
70 1  1.31   26254154.80
76 1  1.21   26253660.80
82 1  1.12   26254214.80
88 1  1.07   26253770.00
90 1  1.04   26252406.40

Going through the pagecache is a different story entirely. Let's look at 
throughput with a single kswapd thread with shadow entries enabled, vs 
disabled:

shadow entries ENABLED, 1 kswapd thread per node
dd sy dd_cpu kswapd0 kswapd1 throughput  dr     pgscan_kswapd pgscan_direct
10 5  27.96  35.52   34.94   7964174.80  0      460161197     0
16 8  40.75  84.86   81.92   11143540.00 0      907793664     0
22 12 45.01  99.96   99.98   12790778.40 6751   884827215     162344947
28 18 49.10  99.97   99.97   14410621.02 17989  719328362     536886953
34 22 52.87  99.80   99.98   14331978.80 25180  609680315     661201785
40 26 55.66  99.90   99.96   14612901.20 26843  449047388     810399311
46 28 56.37  99.74   99.96   15831410.40 33854  518952367     807944791
52 37 59.78  99.80   99.97   15264190.80 37042  372258422     881626890
58 50 71.90  99.44   99.53   14979692.40 45761  190511392     1114810023
64 53 72.14  99.84   99.95   14747164.80 83665  168461850     1013498958
70 50 68.09  99.80   99.90   15176129.60 113546 203506041     1008655113
76 59 73.77  99.73   99.96   14947922.40 98798  137174015     1057487320
82 66 79.25  99.66   99.98   14624100.40 100242 101830859     1074332196
88 73 81.26  98.85   99.98   14827533.60 101262 90402914      1086186724
90 78 85.48  99.55   99.98   14469963.20 101063 75722196      1083603245

shadow entries DISABLED, 1 kswapd thread per node
dd sy dd_cpu kswapd0 kswapd1 throughput  dr    pgscan_kswapd pgscan_direct
10 4  26.07  28.56   27.03   7355924.40  0     459316976     0
16 7  34.94  69.33   69.66   10867895.20 0     872661643     0
22 10 36.03  93.99   99.33   13130613.60 489   1037654473    11268334
28 10 30.34  95.90   98.60   14601509.60 671   1182591373    15429142
34 14 34.77  97.50   99.23   16468012.00 10850 1069005644    249839515
40 17 36.32  91.49   97.11   17335987.60 18903 975417728     434467710
46 19 38.40  90.54   91.61   17705394.40 25369 855737040     582427973
52 22 40.88  83.97   83.70   17607680.40 31250 709532935     724282458
58 25 40.89  82.19   80.14   17976905.60 35060 657796473     804117540
64 28 41.77  73.49   75.20   18001910.00 39073 561813658     895289337
70 33 45.51  63.78   64.39   17061897.20 44523 379465571     1020726436
76 36 46.95  57.96   60.32   16964459.60 47717 291299464     1093172384
82 39 47.16  55.43   56.16   16949956.00 49479 247071062     1134163008
88 42 47.41  53.75   47.62   16930911.20 51521 195449924     1180442208
90 43 47.18  51.40   50.59   16864428.00 51618 190758156     1183203901

When shadow entries are disabled, kernel mode CPU consumption drops and 
peak throughput increases by 13.7%

Here is the same test with 4 kswapd threads:

shadow entries ENABLED, 4 kswapd threads per node
dd sy dd_cpu kswapd0 kswapd1 throughput  dr    pgscan_kswapd pgscan_direct
10 6  30.09  17.36   16.82   7692440.40  0     460386412     0
16 11 42.86  34.35   33.86   10836456.80 23    885908695     550482
22 14 46.00  55.30   50.53   13125285.20 0     1075382922    0
28 17 43.74  87.18   44.18   15298355.20 0     1254927179    0
34 26 53.78  99.88   89.93   16203179.20 3443  1247514636    80817567
40 35 62.99  99.88   97.58   16653526.80 15376 960519369     369681969
46 36 51.66  99.85   90.87   18668439.60 10907 1239045416    259575692
52 46 66.96  99.61   99.96   16970211.60 24264 751180033     577278765
58 52 76.53  99.91   99.97   15336601.60 30676 513418729     725394427
64 58 78.20  99.79   99.96   15266654.40 33466 450869495     791218349
70 65 82.98  99.93   99.98   15285421.60 35647 370270673     843608871
76 69 81.52  99.87   99.87   15681812.00 37625 358457523     889023203
82 78 85.68  99.97   99.98   15370775.60 39010 302132025     921379809
88 85 88.52  99.88   99.56   15410439.20 40100 267031806     947441566
90 88 90.11  99.67   99.41   15400593.20 40443 249090848     953893493

shadow entries DISABLED, 4 kswapd threads per node
dd sy dd_cpu kswapd0 kswapd1 throughput  dr    pgscan_kswapd pgscan_direct
10 5  27.09  16.65   14.17   7842605.60  0     459105291     0
16 10 37.12  26.02   24.85   11352920.40 15    920527796     358515
22 11 36.94  37.13   35.82   13771869.60 0     1132169011    0
28 13 35.23  48.43   46.86   16089746.00 0     1312902070    0
34 15 33.37  53.02   55.69   18314856.40 0     1476169080    0
40 19 35.90  69.60   64.41   19836126.80 0     1629999149    0
46 22 36.82  88.55   57.20   20740216.40 0     1708478106    0
52 24 34.38  93.76   68.34   21758352.00 0     1794055559    0
58 24 30.51  79.20   82.33   22735594.00 0     1872794397    0
64 26 30.21  97.12   76.73   23302203.60 176   1916593721    4206821
70 33 32.92  92.91   92.87   23776588.00 3575  1817685086    85574159
76 37 31.62  91.20   89.83   24308196.80 4752  1812262569    113981763
82 29 25.53  93.23   92.33   24802791.20 306   2032093122    7350704
88 43 37.12  76.18   77.01   25145694.40 20310 1253204719    487048202
90 42 38.56  73.90   74.57   22516787.60 22774 1193637495    545463615

With four kswapd threads, the effects are more pronounced. Kernel mode CPU 
consumption is substantially higher with shadow entries enabled while 
throughput is substantially lower. 

When shadow entries are disabled, additional kswapd tasks increase 
throughput while kernel mode CPU consumption stays roughly the same 

---
 mm/workingset.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/workingset.c b/mm/workingset.c
index b7d616a3bbbe..656451ce2d5e 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -213,6 +213,7 @@ void *workingset_eviction(struct address_space *mapping, struct page *page)
 	unsigned long eviction;
 	struct lruvec *lruvec;
 
+	return NULL;
 	/* Page is fully exclusive and pins page->mem_cgroup */
 	VM_BUG_ON_PAGE(PageLRU(page), page);
 	VM_BUG_ON_PAGE(page_count(page), page);
-- 

Buddy Lumpkin (1):
  vmscan: Support multiple kswapd threads per node

 Documentation/sysctl/vm.txt |  21 ++++++++
 include/linux/mm.h          |   2 +
 include/linux/mmzone.h      |  10 +++-
 kernel/sysctl.c             |  10 ++++
 mm/page_alloc.c             |  15 ++++++
 mm/vmscan.c                 | 116 +++++++++++++++++++++++++++++++++++++-------
 6 files changed, 155 insertions(+), 19 deletions(-)

-- 
1.8.3.1
