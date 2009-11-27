Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C5D0D6B0044
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 13:21:13 -0500 (EST)
Received: by ywh3 with SMTP id 3so1550439ywh.22
        for <linux-mm@kvack.org>; Fri, 27 Nov 2009 10:21:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091127155841.GM13095@csn.ul.ie>
References: <20091126121945.GB13095@csn.ul.ie>
	 <4e5e476b0911260547r33424098v456ed23203a61dd@mail.gmail.com>
	 <20091126141738.GE13095@csn.ul.ie>
	 <4e5e476b0911260718h35fab3b1hc63587b23c02d43f@mail.gmail.com>
	 <20091127114450.GK13095@csn.ul.ie>
	 <4e5e476b0911270403n1387dcdco6a36e5923b8e04bc@mail.gmail.com>
	 <20091127155841.GM13095@csn.ul.ie>
Date: Fri, 27 Nov 2009 19:14:41 +0100
Message-ID: <4e5e476b0911271014k1d507a02o60c11723948dcfa@mail.gmail.com>
Subject: Re: [PATCH-RFC] cfq: Disable low_latency by default for 2.6.32
From: Corrado Zoccolo <czoccolo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Jens Axboe <jens.axboe@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Nov 27, 2009 at 4:58 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Fri, Nov 27, 2009 at 01:03:29PM +0100, Corrado Zoccolo wrote:
>> On Fri, Nov 27, 2009 at 12:44 PM, Mel Gorman <mel@csn.ul.ie> wrote:

> How would one go about selecting the proper ratio at which to disable
> the low_latency logic?
Can we measure the dirty ratio when the allocation failures start to happen=
?

>> >
>> > I haven't tested the high-order allocation scenario yet but the result=
s
>> > as thing stands are below. There are four kernels being compared
>> >
>> > 1. with-low-latency =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 i=
s 2.6.32-rc8 vanilla
>> > 2. with-low-latency-block-2.6.33 =C2=A0is with the for-2.6.33 from lin=
ux-block applied
>> > 3. with-low-latency-async-rampup =C2=A0is with "[RFC,PATCH] cfq-iosche=
d: improve async queue ramp up formula"
>> > 4. without-low-latency =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0is wit=
h low_latency disabled
>> >
>> > desktop-net-gitk
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
gitk-with =C2=A0 =C2=A0 =C2=A0 low-latency =C2=A0 =C2=A0 =C2=A0 low-latency=
 =C2=A0 =C2=A0 =C2=A0gitk-without
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 low-lat=
ency =C2=A0 =C2=A0 =C2=A0block-2.6.33 =C2=A0 =C2=A0 =C2=A0async-rampup =C2=
=A0 =C2=A0 =C2=A0 low-latency
>> > min =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0954.46 ( 0.00%) =C2=A0 57=
0.06 (40.27%) =C2=A0 796.22 (16.58%) =C2=A0 640.65 (32.88%)
>> > mean =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 964.79 ( 0.00%) =C2=A0 573.96 =
(40.51%) =C2=A0 798.01 (17.29%) =C2=A0 655.57 (32.05%)
>> > stddev =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A010.01 ( 0.00%) =C2=A0 =C2=A0 =
2.65 (73.55%) =C2=A0 =C2=A0 1.91 (80.95%) =C2=A0 =C2=A013.33 (-33.18%)
>> > max =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0981.23 ( 0.00%) =C2=A0 57=
7.21 (41.17%) =C2=A0 800.91 (18.38%) =C2=A0 675.65 (31.14%)
>> >
>> > The changes for block in 2.6.33 make a massive difference here, notabl=
y
>> > beating the disabling of low_latency.
>>
> I did a quick test for when high-order-atomic-allocations-for-network
> are happening but the results are not great. By quick test, I mean I
> only did the gitk tests as there wasn't time to do the sysbench and
> iozone tests as well before I'd go offline.
>
> desktop-net-gitk
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hig=
h-with =C2=A0 =C2=A0 =C2=A0 low-latency =C2=A0 =C2=A0 =C2=A0 low-latency =
=C2=A0 =C2=A0 =C2=A0high-without
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 low-latenc=
y =C2=A0 =C2=A0 =C2=A0block-2.6.33 =C2=A0 =C2=A0 =C2=A0async-rampup =C2=A0 =
=C2=A0 =C2=A0 low-latency
> min =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0861.03 ( 0.00%) =C2=A0 467.8=
3 (45.67%) =C2=A01185.51 (-37.69%) =C2=A0 303.43 (64.76%)
> mean =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 866.60 ( 0.00%) =C2=A0 616.28 (28=
.89%) =C2=A01201.82 (-38.68%) =C2=A0 459.69 (46.96%)
> stddev =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 4.39 ( 0.00%) =C2=A0 =C2=A086.9=
0 (-1877.46%) =C2=A0 =C2=A023.63 (-437.75%) =C2=A0 =C2=A092.75 (-2010.76%)
> max =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0872.56 ( 0.00%) =C2=A0 679.3=
6 (22.14%) =C2=A01242.63 (-42.41%) =C2=A0 537.31 (38.42%)
> pgalloc-fail =C2=A0 =C2=A0 =C2=A0 25 ( 0.00%) =C2=A0 =C2=A0 =C2=A0 10 (50=
.00%) =C2=A0 =C2=A0 =C2=A0 39 (-95.00%) =C2=A0 =C2=A0 =C2=A0 20 ( 0.00%)
>
> The patches for 2.6.33 help a little all right but the async-rampup
> patches both make the performance worse and causes more page allocation
> failures to occur. In other words, on most machines it'll appear fine
> but people with wireless cards doing high-order allocations may run into
> trouble.
>
> Disabling low_latency again helps performance significantly in this
> scenario. There were still page allocation failures because not all the
> patches related to that problem made it to mainline.
I'm puzzled how almost all kernels, excluding the async rampup,
perform better when high order allocations are enabled, than in
previous test.

> I was somewhat aggrevated by the page allocation failures until I remembe=
red
> that there are three patches in -mm that I failed to convince either Jens=
 or
> Andrew of them being suitable for mainline. When they are added to the mi=
x,
> the results are as follows;
>
> desktop-net-gitk
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0atomics-wit=
h =C2=A0 =C2=A0 =C2=A0 low-latency =C2=A0 =C2=A0 =C2=A0 low-latency =C2=A0 =
atomics-without
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 low-latenc=
y =C2=A0 =C2=A0 =C2=A0block-2.6.33 =C2=A0 =C2=A0 =C2=A0async-rampup =C2=A0 =
=C2=A0 =C2=A0 low-latency
> min =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0641.12 ( 0.00%) =C2=A0 627.9=
1 ( 2.06%) =C2=A01254.75 (-95.71%) =C2=A0 375.05 (41.50%)
> mean =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 743.61 ( 0.00%) =C2=A0 631.20 (15=
.12%) =C2=A01272.70 (-71.15%) =C2=A0 389.71 (47.59%)
> stddev =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A060.30 ( 0.00%) =C2=A0 =C2=A0 2.5=
3 (95.80%) =C2=A0 =C2=A010.64 (82.35%) =C2=A0 =C2=A022.38 (62.89%)
> max =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0793.85 ( 0.00%) =C2=A0 633.7=
6 (20.17%) =C2=A01281.65 (-61.45%) =C2=A0 428.41 (46.03%)
> pgalloc-fail =C2=A0 =C2=A0 =C2=A0 =C2=A03 ( 0.00%) =C2=A0 =C2=A0 =C2=A0 =
=C2=A02 ( 0.00%) =C2=A0 =C2=A0 =C2=A0 23 ( 0.00%) =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 ( 0.00%)
>
Those patches penalize block-2.6.33, that was the one with lowest
number of failures in previous test.
I think the heuristics were tailored to 2.6.32. They need to be
re-tuned for 2.6.33.

> Again, plain old disabling low_latency both performs the best and fails p=
age
> allocations the least. The three patches for page allocation failures are
> in -mm but not mainline are;
>
> [PATCH 3/5] page allocator: Wait on both sync and async congestion after =
direct reclaim
> [PATCH 4/5] vmscan: Have kswapd sleep for a short interval and double che=
ck it should be asleep
> [PATCH 5/5] vmscan: Take order into consideration when deciding if kswapd=
 is in trouble
>
> It still seems to be that the route of least damage is to disable low_lat=
ency
> by default for 2.6.32. It's very unfortunate that I wasn't able to fully
> justify the 3 patches for page allocation failures in time but all that
> can be done there is consider them for -stable I suppose.

Just disabling low_latency will not solve the allocation issues (20
instead of 25).
Moreover, it will improve some workloads, but penalize others.

Your 3 patches, though, seem to improve the situation also for
low_latency enabled, both for performance and allocation failures (25
to 3). Having those 3 patches with low_latency enabled seems better,
since it won't penalize the workloads that are benefited by
low_latency (if you add a sequential read to your test, you should see
a big difference).

Thanks,
Corrado

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
