Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id A5CA56B0003
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 16:14:12 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id t24so14070574qtn.21
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 13:14:12 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 134si1445105qkf.37.2018.04.03.13.14.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 13:14:08 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [RFC PATCH 1/1] vmscan: Support multiple kswapd threads per node
From: Buddy Lumpkin <buddy.lumpkin@oracle.com>
In-Reply-To: <20180403133115.GA5501@dhcp22.suse.cz>
Date: Tue, 3 Apr 2018 13:13:31 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <7964A110-D912-4BB7-B469-70D16A968E21@oracle.com>
References: <1522661062-39745-1-git-send-email-buddy.lumpkin@oracle.com>
 <1522661062-39745-2-git-send-email-buddy.lumpkin@oracle.com>
 <20180403133115.GA5501@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, riel@surriel.com, mgorman@suse.de, willy@infradead.org, akpm@linux-foundation.org

Very sorry, I forgot to send my last response as plain text.

> On Apr 3, 2018, at 6:31 AM, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> On Mon 02-04-18 09:24:22, Buddy Lumpkin wrote:
>> Page replacement is handled in the Linux Kernel in one of two ways:
>>=20
>> 1) Asynchronously via kswapd
>> 2) Synchronously, via direct reclaim
>>=20
>> At page allocation time the allocating task is immediately given a =
page
>> from the zone free list allowing it to go right back to work doing
>> whatever it was doing; Probably directly or indirectly executing =
business
>> logic.
>>=20
>> Just prior to satisfying the allocation, free pages is checked to see =
if
>> it has reached the zone low watermark and if so, kswapd is awakened.
>> Kswapd will start scanning pages looking for inactive pages to evict =
to
>> make room for new page allocations. The work of kswapd allows tasks =
to
>> continue allocating memory from their respective zone free list =
without
>> incurring any delay.
>>=20
>> When the demand for free pages exceeds the rate that kswapd tasks can
>> supply them, page allocation works differently. Once the allocating =
task
>> finds that the number of free pages is at or below the zone min =
watermark,
>> the task will no longer pull pages from the free list. Instead, the =
task
>> will run the same CPU-bound routines as kswapd to satisfy its own
>> allocation by scanning and evicting pages. This is called a direct =
reclaim.
>>=20
>> The time spent performing a direct reclaim can be substantial, often
>> taking tens to hundreds of milliseconds for small order0 allocations =
to
>> half a second or more for order9 huge-page allocations. In fact, =
kswapd is
>> not actually required on a linux system. It exists for the sole =
purpose of
>> optimizing performance by preventing direct reclaims.
>>=20
>> When memory shortfall is sufficient to trigger direct reclaims, they =
can
>> occur in any task that is running on the system. A single aggressive
>> memory allocating task can set the stage for collateral damage to =
occur in
>> small tasks that rarely allocate additional memory. Consider the =
impact of
>> injecting an additional 100ms of latency when nscd allocates memory =
to
>> facilitate caching of a DNS query.
>>=20
>> The presence of direct reclaims 10 years ago was a fairly reliable
>> indicator that too much was being asked of a Linux system. Kswapd was
>> likely wasting time scanning pages that were ineligible for eviction.
>> Adding RAM or reducing the working set size would usually make the =
problem
>> go away. Since then hardware has evolved to bring a new struggle for
>> kswapd. Storage speeds have increased by orders of magnitude while =
CPU
>> clock speeds stayed the same or even slowed down in exchange for more
>> cores per package. This presents a throughput problem for a single
>> threaded kswapd that will get worse with each generation of new =
hardware.
>=20
> AFAIR we used to scale the number of kswapd workers many years ago. It
> just turned out to be not all that great. We have a kswapd reclaim
> window for quite some time and that can allow to tune how much =
proactive
> kswapd should be.

Are you referring to vm.watermark_scale_factor? This helps quite a bit. =
Previously
I had to increase min_free_kbytes in order to get a larger gap between =
the low
and min watemarks. I was very excited when saw that this had been added
upstream.=20

>=20
> Also please note that the direct reclaim is a way to throttle overly
> aggressive memory consumers.

I totally agree, in fact I think this should be the primary role of =
direct reclaims
because they have a substantial impact on performance. Direct reclaims =
are
the emergency brakes for page allocation, and the case I am making here =
is=20
that they used to only occur when kswapd had to skip over a lot of =
pages.=20

This changed over time as the rate a system can allocate pages =
increased.=20
Direct reclaims slowly became a normal part of page replacement.=20


> The more we do in the background context
> the easier for them it will be to allocate faster. So I am not really
> sure that more background threads will solve the underlying problem. =
It
> is just a matter of memory hogs tunning to end in the very same
> situtation AFAICS. Moreover the more they are going to allocate the =
more
> less CPU time will _other_ (non-allocating) task get.

The important thing to realize here is that kswapd and direct reclaims =
run the
same code paths. There is very little that they do differently. If you =
compare
my test results with one kswapd vs four, your an see that direct =
reclaims
increase the kernel mode CPU consumption considerably. By dedicating
more threads to proactive page replacement, you eliminate direct =
reclaims
which reduces the total number of parallel threads that are spinning on =
the
CPU.

>=20
>> Test Details
>=20
> I will have to study this more to comment.
>=20
> [...]
>> By increasing the number of kswapd threads, throughput increased by =
~50%
>> while kernel mode CPU utilization decreased or stayed the same, =
likely due
>> to a decrease in the number of parallel tasks at any given time doing =
page
>> replacement.
>=20
> Well, isn't that just an effect of more work being done on behalf of
> other workload that might run along with your tests (and which doesn't
> really need to allocate a lot of memory)? In other words how
> does the patch behaves with a non-artificial mixed workloads?

It works quite well. We are just starting to test our production apps. I =
will have=20
results to share soon.

>=20
> Please note that I am not saying that we absolutely have to stick with =
the
> current single-thread-per-node implementation but I would really like =
to
> see more background on why we should be allowing heavy memory hogs to
> allocate faster or how to prevent that.

My test results demonstrate the problem very well. It shows that a =
handful of
SSDs can create enough demand for kswapd that it consumes ~100% CPU
long before throughput is able to reach it=E2=80=99s peak. Direct =
reclaims start occurring=20
at that point. Aggregate throughput continues to increase, but =
eventually the
pauses generated by the direct reclaims cause throughput to plateau:


Test #3: 1 kswapd thread per node
dd sy dd_cpu kswapd0 kswapd1 throughput  dr    pgscan_kswapd =
pgscan_direct
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

I think we have reached the point where it makes sense for page =
replacement to have more
than one mode. Enterprise class servers with lots of memory and a large =
number of CPU
cores would benefit heavily if more threads could be devoted toward =
proactive page
replacement. The polar opposite case is my Raspberry PI which I want to =
run as efficiently
as possible. This problem is only going to get worse. I think it makes =
sense to be able to=20
choose between efficiency and performance (throughput and latency =
reduction).

> I would be also very interested
> to see how to scale the number of threads based on how CPUs are =
utilized
> by other workloads.
> --=20
> Michal Hocko
> SUSE Labs

I agree. I think it would be nice to have a work queue that can sense =
when CPU utilization
for a task peaks at 100% and uses that as criteria to start another task =
up to some maximum=20
that was determined at boot time.

I would also determine a max gap size for the watermarks at boot time as =
well, specifically the
gap between min and low since that provides the buffer that absorbs =
spikey reclaim behavior
as free pages drops. Each time an direct reclaim occurs, increase the =
gap up to the limit. Make
the limit tunable as well. If at any time along the way CPU peaks at =
100%, start another thread
up to the limit established at boot (which is also tunable).
