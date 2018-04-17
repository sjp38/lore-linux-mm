Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 913C26B002E
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 23:03:01 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id r28so3369386uae.7
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 20:03:01 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id g4si1190795vkg.318.2018.04.16.20.02.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 20:02:59 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [RFC PATCH 1/1] vmscan: Support multiple kswapd threads per node
From: Buddy Lumpkin <buddy.lumpkin@oracle.com>
In-Reply-To: <20180412131634.GF23400@dhcp22.suse.cz>
Date: Mon, 16 Apr 2018 20:02:22 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <0D92091A-A135-4707-A981-9A4559ED8701@oracle.com>
References: <1522661062-39745-1-git-send-email-buddy.lumpkin@oracle.com>
 <1522661062-39745-2-git-send-email-buddy.lumpkin@oracle.com>
 <20180403133115.GA5501@dhcp22.suse.cz>
 <EB9E8FC6-8B02-4D7C-AA50-2B5B6BD2AF40@oracle.com>
 <20180412131634.GF23400@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, riel@surriel.com, mgorman@suse.de, willy@infradead.org, akpm@linux-foundation.org


> On Apr 12, 2018, at 6:16 AM, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> On Tue 03-04-18 12:41:56, Buddy Lumpkin wrote:
>>=20
>>> On Apr 3, 2018, at 6:31 AM, Michal Hocko <mhocko@kernel.org> wrote:
>>>=20
>>> On Mon 02-04-18 09:24:22, Buddy Lumpkin wrote:
>>>> Page replacement is handled in the Linux Kernel in one of two ways:
>>>>=20
>>>> 1) Asynchronously via kswapd
>>>> 2) Synchronously, via direct reclaim
>>>>=20
>>>> At page allocation time the allocating task is immediately given a =
page
>>>> from the zone free list allowing it to go right back to work doing
>>>> whatever it was doing; Probably directly or indirectly executing =
business
>>>> logic.
>>>>=20
>>>> Just prior to satisfying the allocation, free pages is checked to =
see if
>>>> it has reached the zone low watermark and if so, kswapd is =
awakened.
>>>> Kswapd will start scanning pages looking for inactive pages to =
evict to
>>>> make room for new page allocations. The work of kswapd allows tasks =
to
>>>> continue allocating memory from their respective zone free list =
without
>>>> incurring any delay.
>>>>=20
>>>> When the demand for free pages exceeds the rate that kswapd tasks =
can
>>>> supply them, page allocation works differently. Once the allocating =
task
>>>> finds that the number of free pages is at or below the zone min =
watermark,
>>>> the task will no longer pull pages from the free list. Instead, the =
task
>>>> will run the same CPU-bound routines as kswapd to satisfy its own
>>>> allocation by scanning and evicting pages. This is called a direct =
reclaim.
>>>>=20
>>>> The time spent performing a direct reclaim can be substantial, =
often
>>>> taking tens to hundreds of milliseconds for small order0 =
allocations to
>>>> half a second or more for order9 huge-page allocations. In fact, =
kswapd is
>>>> not actually required on a linux system. It exists for the sole =
purpose of
>>>> optimizing performance by preventing direct reclaims.
>>>>=20
>>>> When memory shortfall is sufficient to trigger direct reclaims, =
they can
>>>> occur in any task that is running on the system. A single =
aggressive
>>>> memory allocating task can set the stage for collateral damage to =
occur in
>>>> small tasks that rarely allocate additional memory. Consider the =
impact of
>>>> injecting an additional 100ms of latency when nscd allocates memory =
to
>>>> facilitate caching of a DNS query.
>>>>=20
>>>> The presence of direct reclaims 10 years ago was a fairly reliable
>>>> indicator that too much was being asked of a Linux system. Kswapd =
was
>>>> likely wasting time scanning pages that were ineligible for =
eviction.
>>>> Adding RAM or reducing the working set size would usually make the =
problem
>>>> go away. Since then hardware has evolved to bring a new struggle =
for
>>>> kswapd. Storage speeds have increased by orders of magnitude while =
CPU
>>>> clock speeds stayed the same or even slowed down in exchange for =
more
>>>> cores per package. This presents a throughput problem for a single
>>>> threaded kswapd that will get worse with each generation of new =
hardware.
>>>=20
>>> AFAIR we used to scale the number of kswapd workers many years ago. =
It
>>> just turned out to be not all that great. We have a kswapd reclaim
>>> window for quite some time and that can allow to tune how much =
proactive
>>> kswapd should be.
>>=20
>> Are you referring to vm.watermark_scale_factor?
>=20
> Yes along with min_free_kbytes
>=20
>> This helps quite a bit. Previously
>> I had to increase min_free_kbytes in order to get a larger gap =
between the low
>> and min watemarks. I was very excited when saw that this had been =
added
>> upstream.=20
>>=20
>>>=20
>>> Also please note that the direct reclaim is a way to throttle overly
>>> aggressive memory consumers.
>>=20
>> I totally agree, in fact I think this should be the primary role of =
direct reclaims
>> because they have a substantial impact on performance. Direct =
reclaims are
>> the emergency brakes for page allocation, and the case I am making =
here is=20
>> that they used to only occur when kswapd had to skip over a lot of =
pages.=20
>=20
> Or when it is busy reclaiming which can be the case quite easily if =
you
> do not have the inactive file LRU full of clean page cache. And that =
is
> another problem. If you have a trivial reclaim situation then a single
> kswapd thread can reclaim quickly enough.

A single kswapd thread does not help quickly enough. That is the entire =
point
of this patch.

> But once you hit a wall with
> hard-to-reclaim pages then I would expect multiple threads will simply
> contend more (e.g. on fs locks in shrinkers etc=E2=80=A6).

If that is the case, this is already happening since direct reclaims do =
just about
everything that kswapd does. I have tested with a mix of filesystem =
reads, writes
and anonymous memory with and without a swap device. The only locking
problems I have run into so far are related to routines in =
mm/workingset.c.

It is a lot harder to burden the page scan logic than it used to be. =
Somewhere
around 2007 a change was made where page types that had to be skipped
over were simply removed from the LRU list. Anonymous pages were only
scanned if a swap device exists, mlocked pages are not scanned at all. =
It took
a couple years before this was available in the common distros though.
Also, 64 bit kernels help as well as you don=E2=80=99t have the problem =
where objects
held in ZONE_NORMAL pin pages in ZONE_HIGHMEM.

Getting real world results is a waiting game on my end. Once we have a =
version
available to service owners, they need to coordinate an outage so that =
systems
can be rebooted. Only then can I coordinate with them to test for =
improvements.

> Or how do you want
> to prevent that?

Kswapd has a throughput problem. Once that problem is solved new =
bottlenecks
will reveal themselves. There is nothing to prevent here. When you =
remove
bottlenecks, new bottlenecks materialize and someone will need to =
identify
them and make them go away.
>=20
> Or more specifically. How is the admin supposed to know how many
> background threads are still improving the situation?

Reduce the setting and check to see if pgscan_direct is still =
incrementing.

>=20
>> This changed over time as the rate a system can allocate pages =
increased.=20
>> Direct reclaims slowly became a normal part of page replacement.=20
>>=20
>>> The more we do in the background context
>>> the easier for them it will be to allocate faster. So I am not =
really
>>> sure that more background threads will solve the underlying problem. =
It
>>> is just a matter of memory hogs tunning to end in the very same
>>> situtation AFAICS. Moreover the more they are going to allocate the =
more
>>> less CPU time will _other_ (non-allocating) task get.
>>=20
>> The important thing to realize here is that kswapd and direct =
reclaims run the
>> same code paths. There is very little that they do differently.
>=20
> Their target is however completely different. Kswapd want to keep =
nodes
> balanced while direct reclaim aims to reclaim _some_ memory. That is
> quite some difference. Especially for the throttle by reclaiming =
memory
> part.

Routines like balance_pgdat showed up in 2.4.10 when Andrea Arcangeli
rewrote a lot of the page replacement logic. He referred to his work as =
the
classzone patch and the whole selling point on what it would provide was
making allocation and page replacement more cohesive and balanced to
avoid cases where kswapd would behave pathologically, scanning to evict
pages in the wrong location, or in the wrong order. That doesn=E2=80=99t =
mean that
kswapd=E2=80=99s primary occupation is balancing, in fact if you read =
the comments
direct reclaims and kswapd sound pretty similar to me:

/*
 * This is the direct reclaim path, for page-allocating processes.  We =
only
 * try to reclaim pages from zones which will satisfy the caller's =
allocation
 * request.
 *
 * If a zone is deemed to be full of pinned pages then just give it a =
light
 * scan then give up on it.
 */
static void shrink_zones(struct zonelist *zonelist, struct scan_control =
*sc)

/*
 * For kswapd, balance_pgdat() will reclaim pages across a node from =
zones
 * that are eligible for use by the caller until at least one zone is
 * balanced.
 *
 * Returns the order kswapd finished reclaiming at.
 *
 * kswapd scans the zones in the highmem->normal->dma direction.  It =
skips
 * zones which have free_pages > high_wmark_pages(zone), but once a zone =
is
 * found to have free_pages <=3D high_wmark_pages(zone), any page is =
that zone
 * or lower is eligible for reclaim until at least one usable zone is
 * balanced.
 */
static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)

Kswapd makes an effort toward proving balance, but that is clearly not =
the
main goal. Both code paths are triggered by a need for memory, and both
code paths scan zones that are eligible to satisfy the allocation that =
triggered
them.

>=20
>> If you compare
>> my test results with one kswapd vs four, your an see that direct =
reclaims
>> increase the kernel mode CPU consumption considerably. By dedicating
>> more threads to proactive page replacement, you eliminate direct =
reclaims
>> which reduces the total number of parallel threads that are spinning =
on the
>> CPU.
>=20
> I still haven't looked at your test results in detail because they =
seem
> quite artificial. Clean pagecache reclaim is not all that interesting
> IMHO

Clean page cache is extremely interesting for demonstrating this =
bottleneck.
kswapd reads from the tail of the inactive list, and practically every =
page it
encounters is eligible for eviction, and yet it still cannot keep up =
with the demand
for fresh pages.

In the test data I provided, you can see that peak throughput with =
direct IO was:

26,254,215 Kbytes/s

Peak throughput without direct IO and 1 kswapd thread was:

18,001,910 Kbytes/s

Direct IO is 46% higher, and this gap is only going to continue to =
increase. It used
to be around 10%.

Any negative effects that can be seen with additional kswapd threads can =
already be
seen with multiple concurrent direct reclaims. The additional throughput =
that is gained
by scanning proactively in kswapd can certainly push harder against any =
additional
lock contention. In that case kswapd is just the canary in the coal =
mine, finding
problems that would eventually need to be solved anyway.

>=20
> [...]
>>> I would be also very interested
>>> to see how to scale the number of threads based on how CPUs are =
utilized
>>> by other workloads.
>>=20
>> I think we have reached the point where it makes sense for page =
replacement to have more
>> than one mode. Enterprise class servers with lots of memory and a =
large number of CPU
>> cores would benefit heavily if more threads could be devoted toward =
proactive page
>> replacement. The polar opposite case is my Raspberry PI which I want =
to run as efficiently
>> as possible. This problem is only going to get worse. I think it =
makes sense to be able to=20
>> choose between efficiency and performance (throughput and latency =
reduction).
>=20
> The thing is that as long as this would require admin to guess then =
this
> is not all that useful. People will simply not know what to set and we
> are going to end up with stupid admin guides claiming that you should
> use 1/N of per node cpus for kswapd and that will not work.

I think this sysctl is very intuitive to use. Only use it if direct =
reclaims are
occurring. This can be seen with sar -B. Justify any increase with =
testing.
That is a whole lot easier to wrap your head around than a lot of the =
other
sysctls that are available today. Find me an admin that actually =
understands
what the swappiness tunable does.=20

> Not to
> mention that the reclaim logic is full of heuristics which change over
> time and a subtle implementation detail that would work for a =
particular
> scaling might break without anybody noticing. Really, if we are not =
able
> to come up with some auto tuning then I think that this is not really
> worth it.

This is all speculation about how a patch behaves that you have not even
tested. Similar arguments can be made about most of the sysctls that are
available.=20


> --=20
> Michal Hocko
> SUSE Labs
