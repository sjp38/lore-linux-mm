Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD146B0006
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 15:42:50 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id t27so13252511qki.11
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 12:42:50 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id y83si3775297qka.369.2018.04.03.12.42.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 12:42:48 -0700 (PDT)
From: Buddy Lumpkin <buddy.lumpkin@oracle.com>
Message-Id: <EB9E8FC6-8B02-4D7C-AA50-2B5B6BD2AF40@oracle.com>
Content-Type: multipart/alternative;
 boundary="Apple-Mail=_5457D46B-9C77-4861-AC28-6419E5BD99E1"
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [RFC PATCH 1/1] vmscan: Support multiple kswapd threads per node
Date: Tue, 3 Apr 2018 12:41:56 -0700
In-Reply-To: <20180403133115.GA5501@dhcp22.suse.cz>
References: <1522661062-39745-1-git-send-email-buddy.lumpkin@oracle.com>
 <1522661062-39745-2-git-send-email-buddy.lumpkin@oracle.com>
 <20180403133115.GA5501@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, riel@surriel.com, mgorman@suse.de, willy@infradead.org, akpm@linux-foundation.org


--Apple-Mail=_5457D46B-9C77-4861-AC28-6419E5BD99E1
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8


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

It works great. I will have results to share very soon.=20

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


> I would be also very interested
> to see how to scale the number of threads based on how CPUs are =
utilized
> by other workloads.

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

> --=20
> Michal Hocko
> SUSE Labs


--Apple-Mail=_5457D46B-9C77-4861-AC28-6419E5BD99E1
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=utf-8

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html =
charset=3Dutf-8"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; -webkit-line-break: after-white-space;" =
class=3D""><br class=3D""><div><blockquote type=3D"cite" class=3D""><div =
class=3D"">On Apr 3, 2018, at 6:31 AM, Michal Hocko &lt;<a =
href=3D"mailto:mhocko@kernel.org" class=3D"">mhocko@kernel.org</a>&gt; =
wrote:</div><br class=3D"Apple-interchange-newline"><div class=3D""><span =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">On Mon 02-04-18 09:24:22, Buddy =
Lumpkin wrote:</span><br style=3D"font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px;" class=3D""><blockquote type=3D"cite" =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;" =
class=3D"">Page replacement is handled in the Linux Kernel in one of two =
ways:<br class=3D""><br class=3D"">1) Asynchronously via kswapd<br =
class=3D"">2) Synchronously, via direct reclaim<br class=3D""><br =
class=3D"">At page allocation time the allocating task is immediately =
given a page<br class=3D"">from the zone free list allowing it to go =
right back to work doing<br class=3D"">whatever it was doing; Probably =
directly or indirectly executing business<br class=3D"">logic.<br =
class=3D""><br class=3D"">Just prior to satisfying the allocation, free =
pages is checked to see if<br class=3D"">it has reached the zone low =
watermark and if so, kswapd is awakened.<br class=3D"">Kswapd will start =
scanning pages looking for inactive pages to evict to<br class=3D"">make =
room for new page allocations. The work of kswapd allows tasks to<br =
class=3D"">continue allocating memory from their respective zone free =
list without<br class=3D"">incurring any delay.<br class=3D""><br =
class=3D"">When the demand for free pages exceeds the rate that kswapd =
tasks can<br class=3D"">supply them, page allocation works differently. =
Once the allocating task<br class=3D"">finds that the number of free =
pages is at or below the zone min watermark,<br class=3D"">the task will =
no longer pull pages from the free list. Instead, the task<br =
class=3D"">will run the same CPU-bound routines as kswapd to satisfy its =
own<br class=3D"">allocation by scanning and evicting pages. This is =
called a direct reclaim.<br class=3D""><br class=3D"">The time spent =
performing a direct reclaim can be substantial, often<br class=3D"">taking=
 tens to hundreds of milliseconds for small order0 allocations to<br =
class=3D"">half a second or more for order9 huge-page allocations. In =
fact, kswapd is<br class=3D"">not actually required on a linux system. =
It exists for the sole purpose of<br class=3D"">optimizing performance =
by preventing direct reclaims.<br class=3D""><br class=3D"">When memory =
shortfall is sufficient to trigger direct reclaims, they can<br =
class=3D"">occur in any task that is running on the system. A single =
aggressive<br class=3D"">memory allocating task can set the stage for =
collateral damage to occur in<br class=3D"">small tasks that rarely =
allocate additional memory. Consider the impact of<br class=3D"">injecting=
 an additional 100ms of latency when nscd allocates memory to<br =
class=3D"">facilitate caching of a DNS query.<br class=3D""><br =
class=3D"">The presence of direct reclaims 10 years ago was a fairly =
reliable<br class=3D"">indicator that too much was being asked of a =
Linux system. Kswapd was<br class=3D"">likely wasting time scanning =
pages that were ineligible for eviction.<br class=3D"">Adding RAM or =
reducing the working set size would usually make the problem<br =
class=3D"">go away. Since then hardware has evolved to bring a new =
struggle for<br class=3D"">kswapd. Storage speeds have increased by =
orders of magnitude while CPU<br class=3D"">clock speeds stayed the same =
or even slowed down in exchange for more<br class=3D"">cores per =
package. This presents a throughput problem for a single<br =
class=3D"">threaded kswapd that will get worse with each generation of =
new hardware.<br class=3D""></blockquote><br style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><span =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">AFAIR we used to scale the =
number of kswapd workers many years ago. It</span><br =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px;" =
class=3D""><span style=3D"font-family: Helvetica; font-size: 12px; =
font-style: normal; font-variant-caps: normal; font-weight: normal; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; float: none; display: inline =
!important;" class=3D"">just turned out to be not all that great. We =
have a kswapd reclaim</span><br style=3D"font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><span =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">window for quite some time and =
that can allow to tune how much proactive</span><br style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><span =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">kswapd should be.</span><br =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px;" =
class=3D""></div></blockquote><div><br class=3D""></div><div>Are you =
referring to vm.<span style=3D"background-color: rgb(255, 255, 255);" =
class=3D"">watermark_scale_factor? This helps quite a bit. =
Previously</span></div><div><span style=3D"background-color: rgb(255, =
255, 255);" class=3D"">I had to increase min_free_kbytes in order to get =
a larger gap between the low</span></div><div><span =
style=3D"background-color: rgb(255, 255, 255);" class=3D"">and min =
watemarks. I was very excited when saw that this had been =
added</span></div><div><span style=3D"background-color: rgb(255, 255, =
255);" class=3D"">upstream.&nbsp;</span></div><br class=3D""><blockquote =
type=3D"cite" class=3D""><div class=3D""><br style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><span =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">Also please note that the direct =
reclaim is a way to throttle overly</span><br style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><span =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">aggressive memory consumers. =
</span></div></blockquote><div><br class=3D""></div><div>I totally =
agree, in fact I think this should be the primary role of direct =
reclaims</div><div>because they have a substantial impact on =
performance. Direct reclaims are</div><div>the emergency brakes for page =
allocation, and the case I am making here is&nbsp;</div><div>that they =
used to only occur when kswapd had to skip over a lot of =
pages.&nbsp;</div><div><br class=3D""></div><div>This changed over time =
as the rate a system can allocate pages =
increased.&nbsp;</div><div>Direct reclaims slowly became a normal part =
of page replacement.&nbsp;</div><div><br class=3D""></div><blockquote =
type=3D"cite" class=3D""><div class=3D""><span style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; display: =
inline !important;" class=3D"">The more we do in the background =
context</span><br style=3D"font-family: Helvetica; font-size: 12px; =
font-style: normal; font-variant-caps: normal; font-weight: normal; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px;" class=3D""><span style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; display: =
inline !important;" class=3D"">the easier for them it will be to =
allocate faster. So I am not really</span><br style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><span =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">sure that more background =
threads will solve the underlying problem. It</span><br =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px;" =
class=3D""><span style=3D"font-family: Helvetica; font-size: 12px; =
font-style: normal; font-variant-caps: normal; font-weight: normal; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; float: none; display: inline =
!important;" class=3D"">is just a matter of memory hogs tunning to end =
in the very same</span><br style=3D"font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px;" class=3D""><span style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; display: =
inline !important;" class=3D"">situtation AFAICS. Moreover the more they =
are going to allocate the more</span><br style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><span =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">less CPU time will _other_ =
(non-allocating) task get.</span><br style=3D"font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" =
class=3D""></div></blockquote><div><br class=3D""></div><div>The =
important thing to realize here is that kswapd and direct reclaims run =
the</div><div>same code paths. There is very little that they do =
differently. If you compare</div><div>my test results with one kswapd vs =
four, your an see that direct reclaims</div><div>increase the kernel =
mode CPU consumption considerably. By dedicating</div><div>more threads =
to proactive page replacement, you eliminate direct =
reclaims</div><div>which reduces the total number of parallel threads =
that are spinning on the</div><div>CPU.</div><br class=3D""><blockquote =
type=3D"cite" class=3D""><div class=3D""><br style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><blockquote=
 type=3D"cite" style=3D"font-family: Helvetica; font-size: 12px; =
font-style: normal; font-variant-caps: normal; font-weight: normal; =
letter-spacing: normal; orphans: auto; text-align: start; text-indent: =
0px; text-transform: none; white-space: normal; widows: auto; =
word-spacing: 0px; -webkit-text-size-adjust: auto; =
-webkit-text-stroke-width: 0px;" class=3D"">Test Details<br =
class=3D""></blockquote><br style=3D"font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px;" class=3D""><span style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; display: =
inline !important;" class=3D"">I will have to study this more to =
comment.</span><br style=3D"font-family: Helvetica; font-size: 12px; =
font-style: normal; font-variant-caps: normal; font-weight: normal; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px;" class=3D""><br style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><span =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">[...]</span><br =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px;" =
class=3D""><blockquote type=3D"cite" style=3D"font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: normal; letter-spacing: normal; orphans: auto; text-align: =
start; text-indent: 0px; text-transform: none; white-space: normal; =
widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto; =
-webkit-text-stroke-width: 0px;" class=3D"">By increasing the number of =
kswapd threads, throughput increased by ~50%<br class=3D"">while kernel =
mode CPU utilization decreased or stayed the same, likely due<br =
class=3D"">to a decrease in the number of parallel tasks at any given =
time doing page<br class=3D"">replacement.<br class=3D""></blockquote><br =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px;" =
class=3D""><span style=3D"font-family: Helvetica; font-size: 12px; =
font-style: normal; font-variant-caps: normal; font-weight: normal; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; float: none; display: inline =
!important;" class=3D"">Well, isn't that just an effect of more work =
being done on behalf of</span><br style=3D"font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><span =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">other workload that might run =
along with your tests (and which doesn't</span><br style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><span =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">really need to allocate a lot of =
memory)? In other words how</span><br style=3D"font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><span =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">does the patch behaves with a =
non-artificial mixed workloads?</span><br style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" =
class=3D""></div></blockquote><div><br class=3D""></div><div>It works =
great. I will have results to share very soon.&nbsp;</div><br =
class=3D""><blockquote type=3D"cite" class=3D""><div class=3D""><br =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px;" =
class=3D""><span style=3D"font-family: Helvetica; font-size: 12px; =
font-style: normal; font-variant-caps: normal; font-weight: normal; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; float: none; display: inline =
!important;" class=3D"">Please note that I am not saying that we =
absolutely have to stick with the</span><br style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><span =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">current single-thread-per-node =
implementation but I would really like to</span><br style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><span =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">see more background on why we =
should be allowing heavy memory hogs to</span><br style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><span =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">allocate faster or how to =
prevent that. </span></div></blockquote><div><br class=3D""></div><div>My =
test results demonstrate the problem very well. It shows that a handful =
of</div><div>SSDs can create enough demand for kswapd that it consumes =
~100% CPU</div><div>long before throughput is able to reach it=E2=80=99s =
peak. Direct reclaims start occurring&nbsp;</div><div>at that point. =
Aggregate throughput continues to increase, but eventually =
the</div><div>pauses generated by the direct reclaims cause throughput =
to plateau:</div><div><br class=3D""></div><div><br =
class=3D""></div><div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">Test #3: 1 kswapd thread per =
node</span></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">dd sy dd_cpu kswapd0 kswapd1 =
throughput&nbsp; dr&nbsp; &nbsp; pgscan_kswapd =
pgscan_direct</span></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">10 4&nbsp; 26.07&nbsp; 28.56 &nbsp; =
27.03 &nbsp; 7355924.40&nbsp; 0 &nbsp; &nbsp; 459316976 &nbsp; &nbsp; =
0</span></div><div style=3D"margin: 0px; font-size: 11px; line-height: =
normal; font-family: Menlo; background-color: rgb(255, 255, 255);" =
class=3D""><span style=3D"font-variant-ligatures: no-common-ligatures" =
class=3D"">16 7&nbsp; 34.94&nbsp; 69.33 &nbsp; 69.66 &nbsp; 10867895.20 =
0 &nbsp; &nbsp; 872661643 &nbsp; &nbsp; 0</span></div><div =
style=3D"margin: 0px; font-size: 11px; line-height: normal; font-family: =
Menlo; background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">22 10 =
36.03&nbsp; 93.99 &nbsp; 99.33 &nbsp; 13130613.60 489 &nbsp; =
1037654473&nbsp; &nbsp; 11268334</span></div><div style=3D"margin: 0px; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">28 10 =
30.34&nbsp; 95.90 &nbsp; 98.60 &nbsp; 14601509.60 671 &nbsp; =
1182591373&nbsp; &nbsp; 15429142</span></div><div style=3D"margin: 0px; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">34 14 =
34.77&nbsp; 97.50 &nbsp; 99.23 &nbsp; 16468012.00 10850 1069005644&nbsp; =
&nbsp; 249839515</span></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">40 17 36.32&nbsp; 91.49 &nbsp; 97.11 =
&nbsp; 17335987.60 18903 975417728 &nbsp; &nbsp; =
434467710</span></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">46 19 38.40&nbsp; 90.54 &nbsp; 91.61 =
&nbsp; 17705394.40 25369 855737040 &nbsp; &nbsp; =
582427973</span></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">52 22 40.88&nbsp; 83.97 &nbsp; 83.70 =
&nbsp; 17607680.40 31250 709532935 &nbsp; &nbsp; =
724282458</span></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">58 25 40.89&nbsp; 82.19 &nbsp; 80.14 =
&nbsp; 17976905.60 35060 657796473 &nbsp; &nbsp; =
804117540</span></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">64 28 41.77&nbsp; 73.49 &nbsp; 75.20 =
&nbsp; 18001910.00 39073 561813658 &nbsp; &nbsp; =
895289337</span></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">70 33 45.51&nbsp; 63.78 &nbsp; 64.39 =
&nbsp; 17061897.20 44523 379465571 &nbsp; &nbsp; =
1020726436</span></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">76 36 46.95&nbsp; 57.96 &nbsp; 60.32 =
&nbsp; 16964459.60 47717 291299464 &nbsp; &nbsp; =
1093172384</span></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">82 39 47.16&nbsp; 55.43 &nbsp; 56.16 =
&nbsp; 16949956.00 49479 247071062 &nbsp; &nbsp; =
1134163008</span></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">88 42 47.41&nbsp; 53.75 &nbsp; 47.62 =
&nbsp; 16930911.20 51521 195449924 &nbsp; &nbsp; =
1180442208</span></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">90 43 47.18&nbsp; 51.40 &nbsp; 50.59 =
&nbsp; 16864428.00 51618 190758156 &nbsp; &nbsp; =
1183203901</span></div><div class=3D""><br class=3D""></div></div><br =
class=3D""><blockquote type=3D"cite" class=3D""><div class=3D""><span =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">I would be also very =
interested</span><br style=3D"font-family: Helvetica; font-size: 12px; =
font-style: normal; font-variant-caps: normal; font-weight: normal; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px;" class=3D""><span style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; display: =
inline !important;" class=3D"">to see how to scale the number of threads =
based on how CPUs are utilized</span><br style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><span =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">by other workloads.</span><br =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px;" =
class=3D""></div></blockquote><div><br class=3D""></div><div>I think we =
have reached the point where it makes sense for page replacement to have =
more</div><div>than one mode. Enterprise class servers with lots of =
memory and a large number of CPU</div><div>cores would benefit heavily =
if more threads could be devoted toward proactive =
page</div><div>replacement. The polar opposite case is my Raspberry PI =
which I want to run as efficiently</div><div>as possible. This problem =
is only going to get worse. I think it makes sense to be able =
to&nbsp;</div><div>choose between efficiency and performance (throughput =
and latency reduction).</div><br class=3D""><blockquote type=3D"cite" =
class=3D""><div class=3D""><span style=3D"font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant-caps: normal; =
font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; display: =
inline !important;" class=3D"">--<span =
class=3D"Apple-converted-space">&nbsp;</span></span><br =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px;" =
class=3D""><span style=3D"font-family: Helvetica; font-size: 12px; =
font-style: normal; font-variant-caps: normal; font-weight: normal; =
letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; float: none; display: inline =
!important;" class=3D"">Michal Hocko</span><br style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><span =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; float: none; =
display: inline !important;" class=3D"">SUSE =
Labs</span></div></blockquote></div><br class=3D""></body></html>=

--Apple-Mail=_5457D46B-9C77-4861-AC28-6419E5BD99E1--
